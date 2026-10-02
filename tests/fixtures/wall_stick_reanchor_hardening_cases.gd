extends RefCounted
## Framework-neutral cases shared by GUT and a fresh MCP game. Fixtures advance
## real physics. Only explicitly identified frozen transaction/sampling probes
## call narrow seams directly; no result pretends those probes are a full route.

const FIXTURE := preload("res://tests/fixtures/wall_stick_reanchor_fixture.tscn")
const NATIVE := preload("res://tests/fixtures/wall_stick_native_reanchor_fixture.tscn")
const DEFINITION := preload("res://game/player/abilities/grapple/definitions/grapple_definition.tres")
const STICK_DEFINITION := preload("res://game/player/locomotion/wall_stick/definitions/wall_stick_definition.tres")

class MotorStepProbe:
	extends Node
	var motor: PlayerMotor
	var step: int
	var through_step := -1
	var successful_commits := 0
	var result: PlayerMotorCommitResult
	func _physics_process(delta: float) -> void:
		motor.begin_motion_frame(step, delta)
		motor.select_state_policy(&"fixture.hardening.policy")
		motor.submit_base_motion(&"fixture.hardening.base", Vector3.ZERO, 0.0, false)
		result = motor.resolve_and_commit()
		if result != null and result.success:
			successful_commits += 1
			if step < through_step:
				step += 1
				return
		set_physics_process(false)

static func run_case(tree: SceneTree, scenario: String, rate: int) -> Dictionary:
	Engine.physics_ticks_per_second = rate
	var report: Dictionary
	if scenario.begins_with("response_"):
		report = await _response_case(tree, scenario == "response_tighten", rate)
	elif scenario.begins_with("gap_"):
		report = await _gap_case(tree, scenario.trim_prefix("gap_"), rate)
	elif scenario.begins_with("malformed_"):
		report = await _malformed_case(tree, scenario.trim_prefix("malformed_"))
	elif scenario.begins_with("original_") and not scenario.begins_with("original_surface_"):
		report = await _original_case(tree, scenario.trim_prefix("original_"))
	elif scenario.begins_with("native_"):
		report = await _native_case(tree, scenario.trim_prefix("native_"), rate)
	elif scenario.begins_with("visual_"):
		report = await _visual_case(tree, scenario.trim_prefix("visual_"))
	elif scenario == "clock":
		report = await _clock_case(tree, rate)
	else:
		report = await _transaction_case(tree, scenario)
	report["case"] = scenario
	report["rate"] = rate
	return report

static func _spawn(tree: SceneTree, options: Dictionary = {}) -> WallStickReanchorFixture:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.world_3d = World3D.new()
	tree.root.add_child(viewport)
	var fixture := (NATIVE if options.has("support_kind") else FIXTURE).instantiate() as WallStickReanchorFixture
	for key: String in options:
		fixture.set(key, options[key])
	viewport.add_child(fixture)
	await ticks(tree, 6)
	return fixture

static func ticks(tree: SceneTree, count: int) -> void:
	for i in range(count):
		await tree.physics_frame
	await tree.process_frame

static func _freeze(fixture: WallStickReanchorFixture) -> void:
	fixture.player.set_physics_process(false)
	fixture.set_physics_process(false)

static func _finish(tree: SceneTree, fixture: WallStickReanchorFixture, report: Dictionary) -> Dictionary:
	fixture.get_parent().queue_free()
	await tree.process_frame
	return report

static func _response_case(tree: SceneTree, tightening: bool, rate: int) -> Dictionary:
	var definition := DEFINITION.duplicate(true) as GrappleDefinition
	definition.anchor_continuous_motion_tolerance_mps = 3.0
	definition.anchor_severe_discontinuity_threshold_mps = 10.0
	var validated := definition.validate() == GrappleDefinition.ValidationStatus.SUCCESS
	var fixture := await _spawn(tree, {"wall_policy": "static", "initial_wall_instability": 0.0 if tightening else 1.0, "grapple_definition_override": definition})
	_freeze(fixture)
	var attachment := fixture.original_attachment
	var controller: GrappleController = fixture.player.get("_grapple_controller")
	var previous := attachment.get_sampled_anchor_state()
	var previous_position := previous.anchor_world_position
	var previous_threshold := attachment.resolved_severe_discontinuity_threshold_mps
	var elapsed := attachment.elapsed_seconds
	fixture.wall_component.instability = 1.0 if tightening else 0.0
	var threshold := attachment.get_surface_severe_threshold_mps(fixture.wall_component.build_response())
	var pure_query := attachment.get_sampled_anchor_state() == previous and attachment.resolved_severe_discontinuity_threshold_mps == previous_threshold
	fixture.wall.position.x += 7.5 / float(rate)
	var active := controller.sample_anchor_state(attachment.get_sampled_anchor_step() + 1, 1.0 / float(rate))
	var actual_speed := attachment.anchor_world_position.distance_to(previous_position) * float(rate)
	var ended := attachment.get_terminal()
	var passed: bool = validated and pure_query and previous.anchor_world_position == previous_position and absf(actual_speed - 7.5) < 0.001 and active == not tightening and attachment.elapsed_seconds == elapsed and attachment.anchor_revision == 1
	passed = passed and (fixture.terminal_count == 1 and ended != null and ended.reason == GrappleEndReason.Reason.ANCHOR_DISCONTINUITY if tightening else fixture.terminal_count == 0 and ended == null)
	controller.sample_anchor_state(attachment.get_sampled_anchor_step() + 1, 1.0 / float(rate))
	return await _finish(tree, fixture, {"passed": passed, "definition_validated": validated, "previous_threshold_mps": previous_threshold, "incoming_threshold_mps": threshold, "actual_point_speed_mps": actual_speed, "observed_active": active, "previous_sample_retained_for_classification": pure_query, "terminal_count": fixture.terminal_count, "reason": ended.reason_id if ended != null else &"none"})

static func _gap_case(tree: SceneTree, change: String, rate: int) -> Dictionary:
	var options: Dictionary = {}
	if change == "speed":
		# Default 0.25 m/step is stricter than 50 m/s at either rate. A VALID
		# test-only lower speed isolates the independent speed gate instead of
		# accidentally passing a negative control via the displacement gate.
		var definition := STICK_DEFINITION.duplicate(true) as WallStickDefinition
		definition.maximum_support_speed_mps = 3.0
		definition.validate()
		options["wall_stick_definition_override"] = definition
	var fixture := await _spawn(tree, options)
	_freeze(fixture)
	fixture.player.call("_clear_wall_stick")
	var controller: GrappleController = fixture.player.get("_grapple_controller")
	var attachment := fixture.original_attachment
	var before := attachment.anchor_world_position
	var safe := change == "safe"
	var distance := 0.4 if change in ["safe", "speed"] else 1.2
	if change in ["rotation", "scale", "tilt"]:
		distance = 0.0
	fixture.wall.position.x += distance
	match change:
		"rotation": fixture.wall.rotation.y += 1.0
		"scale": fixture.wall.scale.x = 1.1
		"tilt": fixture.wall.rotation.z += 0.01
	var gap := 4
	var active := controller.sample_anchor_state(attachment.get_sampled_anchor_step() + gap, 1.0 / float(rate))
	var expected_velocity := distance * float(rate) / 4.0
	var ended := attachment.get_terminal()
	var expected_reason := GrappleEndReason.Reason.TARGET_INVALIDATED if change == "tilt" else GrappleEndReason.Reason.ANCHOR_DISCONTINUITY
	var passed: bool = active == safe and (absf(attachment.get_sampled_anchor_state().target_velocity.x - expected_velocity) < 0.001 and absf(attachment.anchor_world_position.x - before.x - distance) < 0.0001 if safe else ended != null and ended.reason == expected_reason)
	# The same displacement still fails the unchanged ONE-step carry bound.
	var carry_unchanged := change not in ["safe", "oversized"] or not WallStickAttachment._safe_motion(Transform3D.IDENTITY, Transform3D(Basis.IDENTITY, Vector3(distance, 0.0, 0.0)), Vector3.ZERO, Vector3.ZERO, fixture.player.get("wall_stick_definition"), 4.0 / float(rate))
	return await _finish(tree, fixture, {"passed": passed and carry_unchanged, "gap_steps": gap, "distance_m": distance, "expected_point_velocity_mps": expected_velocity, "observed_active": active, "carry_one_step_bound_unchanged": carry_unchanged, "terminal_count": fixture.terminal_count, "reason": ended.reason_id if ended != null else &"none"})

static func _malformed_case(tree: SceneTree, field: String) -> Dictionary:
	var fixture := await _spawn(tree, {"start_forward": false, "moving_grapple_anchor": true})
	var component := fixture.anchor.get_node(^"Grappleable") as Grappleable3D
	fixture.anchor.set("motion_velocity", Vector3.RIGHT)
	await ticks(tree, 3)
	var attachment := fixture.original_attachment
	var positive := attachment.is_active() and attachment.anchor_revision == 0 and attachment.anchor_world_position.x > 0.01 and attachment.elapsed_seconds > fixture.initial_elapsed_seconds and bool(component.get("_has_sample"))
	var cache_point: Vector3 = component.get("_last_sample_anchor_position")
	var cache_local: Vector3 = component.get("_last_sample_local_offset")
	var elapsed := attachment.elapsed_seconds
	match field:
		"pull_nan": component.pull_multiplier = NAN
		"pull_inf": component.pull_multiplier = INF
		"instability_nan": component.instability = NAN
		"instability_inf": component.instability = INF
		"direction_nan": component.directional_adjustment.x = NAN
		"direction_inf": component.directional_adjustment.x = INF
		"anchor_negative": component.set("anchor_mode", -1)
		"anchor_overflow": component.set("anchor_mode", GrappleTargetResponse.AnchorMode.size())
		"hazard_negative": component.set("hazard_response", -1)
		"hazard_overflow": component.set("hazard_response", GrappleTargetResponse.HazardResponse.size())
	await ticks(tree, 5)
	var terminal := attachment.get_terminal()
	var cache_unchanged: bool = component.get("_last_sample_anchor_position") == cache_point and component.get("_last_sample_local_offset") == cache_local
	var passed: bool = positive and terminal != null and terminal.reason == GrappleEndReason.Reason.TARGET_INVALIDATED and fixture.terminal_count == 1 and not attachment.is_active() and attachment.elapsed_seconds == elapsed and cache_unchanged and fixture.terminal_visuals_clear
	return await _finish(tree, fixture, {"passed": passed, "valid_tracking_positive_control": positive, "cache_unchanged": cache_unchanged, "elapsed_unchanged_on_rejection": attachment.elapsed_seconds == elapsed, "terminal_count": fixture.terminal_count, "reason": terminal.reason_id if terminal != null else &"none"})

static func _new_binding(fixture: WallStickReanchorFixture) -> Dictionary:
	var frame := fixture.motor.get_previous_contact_frame()
	var carry := fixture.motor.get_contact_provider().bind_wall_stick_attachment(frame, fixture.player.global_position, fixture.player.get("wall_stick_definition"))
	return {"carry": carry, "binding": carry.create_grapple_surface_binding(frame), "step": frame.physics_step}

static func _transaction_case(tree: SceneTree, scenario: String) -> Dictionary:
	var installed := scenario in ["alias", "mutated_alias", "released_carry", "original_surface_geometry", "original_surface_pose"]
	var fixture := await _spawn(tree, {"start_forward": installed, "wall_policy": "static", "moving_grapple_anchor": true, "initial_scope": &"fixture.hardening.scope", "wall_scope": &"fixture.hardening.scope"})
	_freeze(fixture)
	var controller: GrappleController = fixture.player.get("_grapple_controller")
	var original := fixture.original_attachment
	var old_sample := original.get_sampled_anchor_state()
	var old_binding := original.get_surface_binding()
	var old_revision := original.anchor_revision
	var old_elapsed := original.elapsed_seconds
	var incoming := _new_binding(fixture)
	var carry: WallStickAttachment = incoming.carry
	var binding: GrappleSurfaceBinding = incoming.binding
	var prepared := controller.prepare_surface_reanchor(binding, incoming.step)
	var positive := prepared.status == GrappleController.ReanchorStatus.SUCCESS
	fixture.motor.set_next_frame_velocity_baseline(Vector3(3.0, 2.0, 1.0))
	var observed := GrappleController.ReanchorStatus.SUCCESS
	var expected := GrappleController.ReanchorStatus.INVALID_BINDING
	var extra: Dictionary = {}
	var foreign_viewport: SubViewport
	match scenario:
		"alias":
			observed = controller.prepare_surface_reanchor(old_binding, incoming.step).status
		"mutated_alias":
			prepared.binding = old_binding
			observed = controller.commit_surface_reanchor(prepared, fixture.motor)
		"null_binding":
			prepared.binding = null
			observed = controller.commit_surface_reanchor(prepared, fixture.motor)
		"null_preparation", "stale_preparation":
			expected = GrappleController.ReanchorStatus.STALE_PREPARATION
			if scenario == "stale_preparation":
				prepared._attachment_ref = null
			observed = controller.commit_surface_reanchor(null if scenario == "null_preparation" else prepared, fixture.motor)
		"detached_original":
			expected = GrappleController.ReanchorStatus.INVALID_ORIGINAL
			fixture.remove_child(fixture.anchor)
			extra["prepare_rejected"] = controller.prepare_surface_reanchor(binding, incoming.step).status == expected
			observed = controller.commit_surface_reanchor(prepared, fixture.motor)
			fixture.add_child(fixture.anchor)
		"foreign_motor":
			expected = GrappleController.ReanchorStatus.MOTOR_BASELINE_REJECTED
			# Equal await counts do not guarantee equal player-local step IDs at
			# 120 Hz. Advance the foreign motor through EVERY preceding stamp
			# in real physics callbacks, then stop at the exact wanted stamp.
			# Preserve its strict contact lifecycle and disabled coordinator.
			foreign_viewport = SubViewport.new()
			foreign_viewport.world_3d = World3D.new()
			tree.root.add_child(foreign_viewport)
			var foreign_player := WallStickMotionFixture.PLAYER.instantiate() as CharacterBody3D
			foreign_player.set("capture_mouse_on_start", false)
			foreign_viewport.add_child(foreign_player)
			foreign_player.set_physics_process(false)
			var foreign_motor := foreign_player.get_node(^"PlayerMotor") as PlayerMotor
			var probe := MotorStepProbe.new()
			probe.motor = foreign_motor
			probe.step = 1
			probe.through_step = incoming.step
			foreign_viewport.add_child(probe)
			await ticks(tree, incoming.step)
			foreign_motor.set_next_frame_velocity_baseline(Vector3(7.0, 6.0, 5.0))
			extra["foreign_completed_step_matches"] = probe.result != null and probe.result.success and probe.result.commit_count == 1 and foreign_motor.has_successful_commit_for(foreign_player, incoming.step)
			extra["foreign_completed_step"] = probe.result.physics_step == incoming.step if probe.result != null else false
			extra["foreign_contiguous_commits"] = probe.successful_commits == incoming.step
			observed = controller.commit_surface_reanchor(prepared, foreign_motor)
			extra["foreign_baseline_unchanged"] = foreign_motor.get("_next_frame_velocity_baseline") == Vector3(7.0, 6.0, 5.0)
		"wrong_completed_step":
			expected = GrappleController.ReanchorStatus.MOTOR_BASELINE_REJECTED
			var probe := MotorStepProbe.new()
			probe.motor = fixture.motor
			probe.step = incoming.step + 1
			fixture.add_child(probe)
			await ticks(tree, 1)
			extra["real_later_commit_succeeded"] = probe.result != null and probe.result.success and probe.result.commit_count == 1
			probe.queue_free()
			fixture.motor.set_next_frame_velocity_baseline(Vector3(3.0, 2.0, 1.0))
			observed = controller.commit_surface_reanchor(prepared, fixture.motor)
		"released_carry":
			carry.release()
			extra["copy_rejected_after_release"] = carry.create_grapple_surface_binding(fixture.motor.get_previous_contact_frame()) == null
			fixture.wall.get_node(^"WallShape").shape.size.x += 0.1
			extra["copy_rejected_after_resize"] = carry.create_grapple_surface_binding(fixture.motor.get_previous_contact_frame()) == null
			extra["historical_status_preserved"] = carry.status == WallStickAttachment.Status.VALID
			observed = GrappleController.ReanchorStatus.INVALID_BINDING
		"original_surface_geometry", "original_surface_pose":
			expected = GrappleController.ReanchorStatus.INVALID_ORIGINAL
			if scenario == "original_surface_geometry":
				fixture.wall.get_node(^"WallShape").shape.size.x += 0.1
			else:
				fixture.wall.scale.x = 1.1
			observed = controller.commit_surface_reanchor(prepared, fixture.motor)
			extra["prepare_rejected"] = controller.prepare_surface_reanchor(binding, incoming.step).status == expected
			extra["installed_status_not_mutated"] = old_binding.status == GrappleSurfaceBinding.Status.VALID
	var atomic: bool = original.is_active() and original.get_sampled_anchor_state() == old_sample and original.get_surface_binding() == old_binding and original.anchor_revision == old_revision and original.elapsed_seconds == old_elapsed and original.originating_scope_identity == &"fixture.hardening.scope" and fixture.motor.get("_next_frame_velocity_baseline") == Vector3(3.0, 2.0, 1.0)
	if scenario in ["alias", "mutated_alias"]:
		extra["original_binding_active"] = old_binding.is_live_geometry() and not old_binding._released and old_binding.status == GrappleSurfaceBinding.Status.VALID
	var passed: bool = positive and atomic and observed == expected
	for value: bool in extra.values():
		passed = passed and value
	if scenario in ["foreign_motor", "detached_original"]:
		extra["owned_restored_positive_commit"] = controller.commit_surface_reanchor(prepared, fixture.motor) == GrappleController.ReanchorStatus.SUCCESS
		passed = passed and extra.owned_restored_positive_commit
	if foreign_viewport != null:
		foreign_viewport.queue_free()
		await tree.process_frame
	carry.release()
	if binding != original.get_surface_binding():
		binding.release()
	return await _finish(tree, fixture, {"passed": passed, "prepare_positive_control": positive, "atomic_original_and_baseline": atomic, "observed_status": int(observed), "expected_status": int(expected), "extra": extra})

static func _original_case(tree: SceneTree, scenario: String) -> Dictionary:
	var parts := scenario.split("_")
	var before_prepare := parts[0] == "before"
	var change := parts[1]
	var fixture := await _spawn(tree, {"start_forward": false, "wall_policy": "static", "moving_grapple_anchor": true, "initial_scope": &"fixture.hardening.scope", "wall_scope": &"fixture.hardening.scope"})
	_freeze(fixture)
	var controller: GrappleController = fixture.player.get("_grapple_controller")
	var original := fixture.original_attachment
	var component := fixture.anchor.get_node(^"Grappleable") as Grappleable3D
	var cache_point: Vector3 = component.get("_last_sample_anchor_position")
	var cache_local: Vector3 = component.get("_last_sample_local_offset")
	var old_sample := original.get_sampled_anchor_state()
	var old_elapsed := original.elapsed_seconds
	var incoming := _new_binding(fixture)
	var prepared := controller.prepare_surface_reanchor(incoming.binding, incoming.step)
	var positive := prepared.status == GrappleController.ReanchorStatus.SUCCESS
	fixture.motor.set_next_frame_velocity_baseline(Vector3(3.0, 2.0, 1.0))
	match change:
		"invalidated": component.invalidate_grapple_anchor()
		"removed": fixture.anchor.remove_child(component)
		"ineligible": component.eligible = false
		"malformed": component.pull_multiplier = INF
		"scope": component.encounter_scope_identity = &"fixture.other.scope"
		"identity": component.target_id = &"fixture.other.target"
	var status := controller.prepare_surface_reanchor(incoming.binding, incoming.step).status if before_prepare else controller.commit_surface_reanchor(prepared, fixture.motor)
	var atomic: bool = original.is_active() and original.get_sampled_anchor_state() == old_sample and original.elapsed_seconds == old_elapsed and original.anchor_revision == 0 and fixture.motor.get("_next_frame_velocity_baseline") == Vector3(3.0, 2.0, 1.0) and component.get("_last_sample_anchor_position") == cache_point and component.get("_last_sample_local_offset") == cache_local
	if change == "removed":
		fixture.anchor.add_child(component)
	component.set("_anchor_explicitly_invalidated", false)
	component.eligible = true
	component.pull_multiplier = 1.0
	component.encounter_scope_identity = &"fixture.hardening.scope"
	component.target_id = &"fixture.grapple.moving"
	var restored := controller.commit_surface_reanchor(prepared, fixture.motor) == GrappleController.ReanchorStatus.SUCCESS
	var cache_unchanged: bool = component.get("_last_sample_anchor_position") == cache_point and component.get("_last_sample_local_offset") == cache_local
	incoming.carry.release()
	return await _finish(tree, fixture, {"passed": positive and atomic and restored and cache_unchanged and status == GrappleController.ReanchorStatus.INVALID_ORIGINAL, "initial_positive_prepare": positive, "atomic_rejection": atomic, "restored_positive_commit": restored, "original_legacy_cache_unchanged": cache_unchanged, "observed_status": int(status)})

static func _native_case(tree: SceneTree, kind: String, rate: int) -> Dictionary:
	var fixture := await _spawn(tree, {"support_kind": kind, "wall_policy": "static"})
	var initial := fixture.original_attachment.anchor_world_position
	if fixture.wall is AnimatableBody3D:
		fixture.wall.constant_linear_velocity = Vector3(0.75, 0.0, 0.0)
	fixture.wall.set("motion_velocity", Vector3(1.0, 0.1, 0.0))
	fixture.wall.set("owner_motion_velocity", Vector3(0.2, 0.05, 0.0))
	if kind != "character":
		fixture.wall.set("yaw_rate_rps", 0.2)
	await ticks(tree, int(rate * 0.2))
	var held := fixture.reanchor_report()
	fixture.capture_release_clock_baseline()
	fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	fixture.anchor.queue_free()
	await ticks(tree, int(rate * 0.2))
	var released := fixture.reanchor_report()
	var clock := fixture.release_clock_report()
	var displacement := fixture.original_attachment.anchor_world_position.distance_to(initial)
	fixture.wall.queue_free()
	await ticks(tree, 4)
	var terminal := fixture.reanchor_report()
	var ended := fixture.original_attachment.get_terminal()
	var passed: bool = held.sticking and held.grappling and released.grappling and not released.sticking and released.same_occurrence and released.revision == 1 and released.entry_count == 1 and released.terminal_count == 0 and displacement > 0.1 and released.maximum_native_point_speed_mps > 0.5 and released.maximum_anchor_error_m < 0.0001 and released.maximum_marker_error_m < 0.0001 and released.maximum_rope_end_error_m < 0.0001 and released.maximum_point_velocity_error_mps < 0.005 and released.visible_visual_samples > 0 and released.missing_visual_sample_count == 0 and released.rope_resets == held.rope_resets and released.marker_resets == held.marker_resets and clock.clock_matches and clock.curve_matches and clock.forced_reset_would_fail and terminal.terminal_count == 1 and terminal.terminal_visuals_clear and ended != null and ended.reason == GrappleEndReason.Reason.TARGET_DESTROYED and terminal.maximum_commits == 1
	if kind == "animatable":
		passed = passed and released.maximum_old_static_velocity_error_mps > 0.1
	return await _finish(tree, fixture, {"passed": passed, "body_type": kind, "held": held, "released": released, "clock": clock, "anchor_displacement_m": displacement, "terminal": terminal, "reason": ended.reason_id if ended != null else &"none"})

static func _visual_case(tree: SceneTree, change: String) -> Dictionary:
	var fixture := await _spawn(tree)
	_freeze(fixture)
	var marker := fixture.player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	marker.set_process(false)
	var marker_mesh := marker.get_node(^"GrappleCursor") as MeshInstance3D
	var rope: MeshInstance3D = fixture.player.get("grapple_visual")
	var assigned := rope.mesh
	var snapshot: GrappleAttachmentDiagnosticSnapshot = fixture.player.call("get_grapple_attachment_diagnostic_snapshot")
	var positive := fixture.measure_active_visuals(snapshot)
	var before := fixture.missing_visual_sample_count
	match change:
		"marker": marker_mesh.visible = false
		"rope": rope.visible = false
		"detached": rope.mesh = null
		"replaced": rope.mesh = BoxMesh.new()
		"wrong_cylinder":
			var wrong := CylinderMesh.new()
			wrong.height = (assigned as CylinderMesh).height * 3.0
			rope.mesh = wrong
	var visible := fixture.measure_active_visuals(snapshot)
	var detected := fixture.maximum_rope_end_error_m > 0.05 if change == "wrong_cylinder" else not visible and fixture.missing_visual_sample_count == before + 1
	marker_mesh.visible = true
	rope.visible = true
	rope.mesh = assigned
	var restored := fixture.measure_active_visuals(snapshot)
	return await _finish(tree, fixture, {"passed": positive and detected and restored, "visible_positive_control": positive, "negative_control_detected": detected, "restored_visible": restored, "missing_visual_sample_count": fixture.missing_visual_sample_count, "actual_assigned_mesh_endpoint_error_m": fixture.maximum_rope_end_error_m})

static func _clock_case(tree: SceneTree, rate: int) -> Dictionary:
	var fixture := await _spawn(tree, {"wall_policy": "static"})
	fixture.wall_component.pull_multiplier = 0.5
	await ticks(tree, 2)
	fixture.capture_release_clock_baseline()
	fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	await ticks(tree, int(rate * 0.2))
	var clock := fixture.release_clock_report()
	return await _finish(tree, fixture, {"passed": clock.clock_matches and clock.curve_matches and clock.forced_reset_would_fail and fixture.original_attachment.anchor_revision == 1 and fixture.terminal_count == 0, "clock": clock})
