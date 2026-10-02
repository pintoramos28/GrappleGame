extends GutTest

const FIXTURE := preload("res://tests/fixtures/wall_stick_reanchor_fixture.tscn")
var _saved_rate: int

func before_all() -> void:
	_saved_rate = Engine.physics_ticks_per_second

func after_each() -> void:
	Engine.physics_ticks_per_second = _saved_rate
	for action in [&"move_forward", &"move_back", &"fire_grapple", &"jump"]:
		Input.action_release(action)

func test_entry_replaces_actual_contact_on_same_occurrence_and_preserves_time_and_commit() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := await _spawn()
		var attachment := fixture.original_attachment
		assert_true(bool(fixture.player.get("is_wall_sticking")))
		assert_same(fixture.player.call("get_grapple_attachment"), attachment)
		assert_same(attachment.get_target(), fixture.wall)
		assert_eq(attachment.anchor_revision, 1)
		assert_eq(attachment.target_identity, &"", "ordinary geometry gets no fabricated Grappleable ID")
		assert_gt(attachment.elapsed_seconds, fixture.initial_elapsed_seconds)
		assert_eq(attachment.creation_physics_step, 0)
		assert_eq(attachment.resolved_maximum_length_m, 35.0)
		assert_eq(attachment.resolved_maximum_speed_mps, 22.0)
		assert_true(attachment.is_definition_unmodified())
		assert_gte(fixture.entry_commit.position_after.distance_to(fixture.entry_commit.contact_frame.wall_support.point), 0.4, "contact is not player stand-off")
		assert_eq(fixture.entry_commit.anchor_constraint_records[0].anchor_position, Vector3(0.0, 4.0, -2.0), "entry forces consumed the OLD revision")
		assert_eq(fixture.entry_commit.commit_count, 1)
		assert_lte(fixture.maximum_anchor_error_m, 0.0001)
		assert_gt(fixture.anchor_samples, 1)

func test_engine_translation_yaw_owner_motion_and_forward_release_share_both_actual_visuals() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		for policy in ["ordinary", "static", "moving"]:
			var fixture := await _spawn(policy)
			fixture.wall.set("motion_velocity", Vector3(1.0, 0.1, -0.2))
			fixture.wall.set("yaw_rate_rps", 0.2)
			fixture.wall.set("owner_motion_velocity", Vector3(0.3, 0.05, 0.0))
			await _ticks(int(rate * 0.2))
			var rope_resets: int = fixture.player.get("grapple_visual_reset_count")
			var marker := fixture.player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
			var marker_resets := marker.interpolation_reset_count
			assert_true(bool(fixture.player.get("is_wall_sticking")))
			fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
			await _ticks(int(rate * 0.2))
			var report := fixture.reanchor_report()
			assert_false(report.sticking)
			assert_true(report.grappling)
			assert_true(report.same_occurrence)
			assert_eq(report.revision, 1)
			assert_eq(report.entry_count, 1)
			assert_eq(report.terminal_count, 0)
			assert_lte(report.maximum_anchor_error_m, 0.0001)
			assert_lte(report.maximum_marker_error_m, 0.0001)
			assert_lte(report.maximum_rope_end_error_m, 0.0001)
			assert_lte(report.maximum_point_velocity_error_mps, 0.005)
			assert_gt(report.visible_visual_samples, 0)
			assert_eq(report.missing_visual_sample_count, 0)
			assert_eq(report.rope_resets, rope_resets, "continuous follow/release is not an intentional revision")
			assert_eq(report.marker_resets, marker_resets)
			assert_eq(report.maximum_commits, 1)
			print("[reanchor-engine-visuals] ", policy, " ", report)

func test_nonzero_entry_commit_is_reported_honestly_without_cancelling_zero_baseline_first_hold() -> void:
	var viewport := SubViewport.new()
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var fixture := FIXTURE.instantiate() as WallStickReanchorFixture
	fixture.initial_wall_position.z = -0.8
	fixture.freeze_after_first_commit = true
	viewport.add_child(fixture)
	await _ticks(3)
	assert_true(bool(fixture.player.get("is_wall_sticking")))
	assert_not_null(fixture.entry_commit)
	assert_gt(fixture.entry_commit.committed_velocity.length(), 0.01, "nonzero entry positive control")
	assert_eq(fixture.player.get("_wall_stick_committed_velocity"), fixture.entry_commit.committed_velocity)
	var snapshot: GrappleAttachmentDiagnosticSnapshot = fixture.player.call("get_grapple_attachment_diagnostic_snapshot")
	assert_eq(snapshot.committed_velocity_mps, fixture.entry_commit.committed_velocity)
	fixture.freeze_after_first_commit = false
	fixture.player.set_physics_process(true)
	await _ticks(6)
	assert_true(bool(fixture.player.get("is_wall_sticking")))
	assert_gt(fixture.held_frames, 0)
	assert_eq(fixture.terminal_count, 0)

func test_destroyed_or_invalidated_former_target_is_not_a_validity_dependency() -> void:
	for moving_old in [false, true]:
		var fixture := await _spawn("ordinary", true, moving_old)
		var attachment := fixture.original_attachment
		if moving_old:
			var old_component := fixture.anchor.get_node(^"Grappleable") as Grappleable3D
			old_component.invalidate_grapple_anchor()
			old_component.encounter_scope_identity = &"encounter.obsolete"
		fixture.anchor.queue_free()
		fixture.wall.set("motion_velocity", Vector3.RIGHT)
		await _ticks(8)
		assert_true(attachment.is_active())
		assert_same(attachment.get_target(), fixture.wall)
		assert_eq(fixture.terminal_count, 0)
		fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
		await _ticks(8)
		assert_true(attachment.is_active())
		assert_gt(attachment.anchor_world_position.x, 0.2)

func test_new_surface_lifetime_policy_geometry_and_motion_end_once_after_carry_release() -> void:
	for scenario in ["destroyed", "queued", "disabled", "replaced", "resized", "owner_added", "ineligible", "invalidated", "removed_contract", "identity_changed", "scope_changed", "teleport", "tilt", "scale"]:
		var fixture := await _spawn("static", true, false, &"encounter.original" if scenario == "scope_changed" else &"", &"encounter.original" if scenario == "scope_changed" else &"")
		fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
		await _ticks(3)
		assert_false(bool(fixture.player.get("is_wall_sticking")), "positive forward-release control")
		assert_true(fixture.original_attachment.is_active())
		match scenario:
			"destroyed": fixture.wall.free()
			"queued": fixture.wall.queue_free()
			"disabled": fixture.wall.get_node(^"WallShape").disabled = true
			"replaced": fixture.wall.get_node(^"WallShape").shape = BoxShape3D.new()
			"resized": fixture.wall.get_node(^"WallShape").shape.size.x += 0.1
			"owner_added": fixture._add_shape(fixture.wall, Vector3.ONE * 0.1)
			"ineligible": fixture.wall_component.eligible = false
			"invalidated": fixture.wall_component.invalidate_grapple_anchor()
			"removed_contract": fixture.wall_component.queue_free()
			"identity_changed": fixture.wall_component.target_id = &"fixture.other"
			"scope_changed":
				fixture.wall_component.encounter_scope_identity = &"encounter.new"
			"teleport": fixture.wall.position.x += 4.0
			"tilt": fixture.wall.rotation.x += 0.01
			"scale": fixture.wall.scale *= 1.1
		await _ticks(4)
		assert_false(fixture.original_attachment.is_active(), scenario)
		assert_eq(fixture.terminal_count, 1, scenario)
		var reason := fixture.original_attachment.get_terminal().reason
		if scenario in ["destroyed", "queued"]:
			assert_eq(reason, GrappleEndReason.Reason.TARGET_DESTROYED)
		elif scenario == "scope_changed":
			assert_eq(reason, GrappleEndReason.Reason.SCOPE_MISMATCH)
		elif scenario in ["teleport", "scale"]:
			assert_eq(reason, GrappleEndReason.Reason.ANCHOR_DISCONTINUITY)
		else:
			assert_eq(reason, GrappleEndReason.Reason.TARGET_INVALIDATED)
		assert_true(fixture.terminal_visuals_clear, scenario)
		assert_null(fixture.original_attachment.get_surface_binding(), "terminal releases private geometric state")
		await _ticks(3)
		assert_eq(fixture.terminal_count, 1)

func test_entry_policy_rejections_keep_original_grapple_and_motor_baseline() -> void:
	for policy in ["ineligible", "invalidated", "missing_id", "malformed"]:
		var fixture := await _spawn(policy)
		assert_false(bool(fixture.player.get("is_wall_sticking")), policy)
		assert_same(fixture.original_attachment.get_target(), fixture.anchor)
		assert_eq(fixture.original_attachment.anchor_revision, 0)
		assert_true(fixture.original_attachment.is_active())
		assert_false(bool(fixture.motor.get("_has_next_frame_velocity_baseline")))
		assert_eq(fixture.player.get("_last_wall_stick_reanchor_status"), GrappleController.ReanchorStatus.POLICY_REJECTED)
		assert_eq(fixture.terminal_count, 0)
		# Correct the one rejected policy with no other setup change; same physical
		# contact must now enter, preventing a trivially non-entering fixture.
		fixture.wall_component.eligible = true
		fixture.wall_component.target_id = &"fixture.reanchor.wall"
		fixture.wall_component.directional_adjustment = Vector3.ZERO
		fixture.wall_component.set("_anchor_explicitly_invalidated", false)
		await _ticks(3)
		assert_true(bool(fixture.player.get("is_wall_sticking")), "positive control: " + policy)
		assert_eq(fixture.original_attachment.anchor_revision, 1)

func test_scope_preservation_and_mismatch_rejection_have_positive_controls() -> void:
	for matching in [false, true]:
		var fixture := await _spawn("static", true, false, &"encounter.original", &"encounter.original" if matching else &"encounter.other")
		assert_eq(bool(fixture.player.get("is_wall_sticking")), matching)
		assert_eq(fixture.original_attachment.originating_scope_identity, &"encounter.original")
		assert_eq(fixture.original_attachment.anchor_revision, 1 if matching else 0)
		assert_eq(fixture.terminal_count, 0)
		if not matching:
			assert_eq(fixture.player.get("_last_wall_stick_reanchor_status"), GrappleController.ReanchorStatus.SCOPE_MISMATCH)
			assert_false(bool(fixture.motor.get("_has_next_frame_velocity_baseline")))
			fixture.wall_component.encounter_scope_identity = &"encounter.original"
			await _ticks(3)
			assert_true(bool(fixture.player.get("is_wall_sticking")))

func test_prepared_transaction_range_stale_geometry_and_motor_rejections_are_atomic() -> void:
	for guard in ["range", "geometry", "policy", "scope", "stale", "motor", "invalid_original"]:
		var fixture := await _spawn("static", false, false, &"encounter.original" if guard == "scope" else &"", &"encounter.original" if guard == "scope" else &"")
		fixture.player.set_physics_process(false)
		var controller: GrappleController = fixture.player.get("_grapple_controller")
		var frame := fixture.motor.get_previous_contact_frame()
		var carry := fixture.motor.get_contact_provider().bind_wall_stick_attachment(frame, fixture.player.global_position, fixture.player.get("wall_stick_definition"))
		assert_not_null(carry, "actual corroborated physical contact positive control")
		var binding := carry.create_grapple_surface_binding(frame)
		var prepared := controller.prepare_surface_reanchor(binding, frame.physics_step)
		assert_eq(prepared.status, GrappleController.ReanchorStatus.SUCCESS, "prepare positive control")
		var old_sample := fixture.original_attachment.get_sampled_anchor_state()
		var elapsed := fixture.original_attachment.elapsed_seconds
		var velocity := controller.get_diagnostic_snapshot().committed_velocity_mps
		fixture.motor.set_next_frame_velocity_baseline(Vector3(3.0, 2.0, 1.0))
		var expected := GrappleController.ReanchorStatus.INVALID_BINDING
		match guard:
			"range":
				fixture.player.position.x += 36.0
				expected = GrappleController.ReanchorStatus.OUT_OF_RANGE
			"geometry": fixture.wall.get_node(^"WallShape").shape.size.x += 0.1
			"policy": fixture.wall_component.eligible = false
			"scope":
				fixture.wall_component.encounter_scope_identity = &"encounter.other"
				expected = GrappleController.ReanchorStatus.SCOPE_MISMATCH
			"stale":
				prepared.physics_step -= 1
				expected = GrappleController.ReanchorStatus.STALE_PREPARATION
			"motor":
				fixture.motor.begin_motion_frame(frame.physics_step + 1)
				expected = GrappleController.ReanchorStatus.MOTOR_BASELINE_REJECTED
			"invalid_original":
				fixture.anchor.queue_free()
				expected = GrappleController.ReanchorStatus.INVALID_ORIGINAL
		assert_eq(controller.commit_surface_reanchor(prepared, fixture.motor), expected, guard)
		if guard == "motor":
			assert_push_error("baseline_active_frame")
			# begin_motion_frame legitimately consumes the previous baseline;
			# the rejected replacement must not arm a new zero one.
			assert_false(bool(fixture.motor.get("_has_next_frame_velocity_baseline")))
			fixture.motor.abort_motion_frame()
		else:
			assert_eq(fixture.motor.get("_next_frame_velocity_baseline"), Vector3(3.0, 2.0, 1.0), guard)
		assert_eq(fixture.original_attachment.anchor_revision, 0)
		assert_same(fixture.original_attachment.get_sampled_anchor_state(), old_sample)
		assert_eq(fixture.original_attachment.elapsed_seconds, elapsed)
		assert_eq(controller.get_diagnostic_snapshot().committed_velocity_mps, velocity)
		assert_false(bool(fixture.player.get("is_wall_sticking")))
		carry.release()
		binding.release()

func test_successful_prepare_commit_preserves_velocity_and_clears_old_geometric_facts() -> void:
	var fixture := await _spawn("static", false)
	fixture.player.set_physics_process(false)
	var controller: GrappleController = fixture.player.get("_grapple_controller")
	var frame := fixture.motor.get_previous_contact_frame()
	var carry := fixture.motor.get_contact_provider().bind_wall_stick_attachment(frame, fixture.player.global_position, fixture.player.get("wall_stick_definition"))
	var binding := carry.create_grapple_surface_binding(frame)
	var prepared := controller.prepare_surface_reanchor(binding, frame.physics_step)
	var before := controller.get_diagnostic_snapshot()
	assert_gt(before.committed_velocity_mps.length(), 0.01)
	assert_gt(before.pull_direction.length(), 0.5)
	assert_eq(controller.commit_surface_reanchor(prepared, fixture.motor), GrappleController.ReanchorStatus.SUCCESS)
	var after := controller.get_diagnostic_snapshot()
	assert_eq(after.committed_velocity_mps, before.committed_velocity_mps)
	assert_eq(after.elapsed_seconds, before.elapsed_seconds)
	assert_eq(after.pull_direction, Vector3.ZERO, "no old-anchor forces claimed on new revision")
	assert_eq(after.submitted_acceleration_mps2, 0.0)
	assert_false(after.boundary_correction_applied)
	assert_eq(after.anchor_revision, 1)
	assert_eq(controller.commit_surface_reanchor(prepared, fixture.motor), GrappleController.ReanchorStatus.STALE_PREPARATION)
	assert_true(bool(fixture.motor.get("_has_next_frame_velocity_baseline")))
	carry.release()

func test_fresh_wall_response_changes_pull_with_elapsed_time_without_legacy_cache_mutation() -> void:
	var fixture := await _spawn("static")
	var component := fixture.wall_component
	component.set("_has_sample", true)
	component.set("_last_sample_anchor_position", Vector3(99.0, 88.0, 77.0))
	component.set("_last_sample_local_offset", Vector3(6.0, 5.0, 4.0))
	component.pull_multiplier = 0.5
	component.instability = 0.4
	component.hazard_response = GrappleTargetResponse.HazardResponse.DAMAGE_WHILE_ATTACHED
	await _ticks(2)
	var attachment := fixture.original_attachment
	assert_almost_eq(attachment.response.pull_multiplier, 0.5, 0.0001)
	assert_eq(attachment.response.hazard_response, GrappleTargetResponse.HazardResponse.DAMAGE_WHILE_ATTACHED)
	assert_almost_eq(attachment.resolved_pull_initial_acceleration_mps2, 30.0, 0.0001)
	assert_almost_eq(attachment.resolved_continuous_motion_tolerance_mps, 40.0, 0.0001)
	assert_eq(component.get("_last_sample_anchor_position"), Vector3(99.0, 88.0, 77.0))
	assert_eq(component.get("_last_sample_local_offset"), Vector3(6.0, 5.0, 4.0))
	fixture.capture_release_clock_baseline()
	fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	await _ticks(5)
	var clock := fixture.release_clock_report()
	assert_true(clock.clock_matches, str(clock))
	assert_true(clock.curve_matches, str(clock))
	assert_true(clock.forced_reset_would_fail, "reset + decay must fail this control, not just remain below 30")
	assert_eq(attachment.resolved_maximum_length_m, 35.0)
	assert_eq(attachment.resolved_maximum_speed_mps, 22.0)
	assert_true(attachment.is_definition_unmodified())

func test_surface_listener_is_independent_from_carry_and_does_not_retain_binding() -> void:
	var fixture := await _spawn()
	fixture.player.set_physics_process(false)
	var shape := fixture.wall.get_node(^"WallShape").shape as Shape3D
	var binding_ref: WeakRef = weakref(fixture.original_attachment.get_surface_binding())
	var count := shape.changed.get_connections().size()
	fixture.player.call("_clear_wall_stick")
	assert_not_null(binding_ref.get_ref())
	assert_eq(shape.changed.get_connections().size(), count - 1)
	fixture.player.call("terminate_grapple", GrappleEndReason.Reason.RELEASE)
	assert_null(binding_ref.get_ref(), "Shape.changed captures weak handle only")
	assert_eq(shape.changed.get_connections().size(), count - 2)

func test_ordinary_nonstick_geometry_keeps_frozen_anchor_and_acquisition_query_budget() -> void:
	var fixture := await _spawn("ordinary", false)
	fixture.wall.set("motion_velocity", Vector3.RIGHT)
	fixture.anchor.position.x += 2.0
	await _ticks(8)
	assert_eq(fixture.original_attachment.anchor_revision, 0)
	assert_eq(fixture.original_attachment.anchor_world_position, Vector3(0.0, 4.0, -2.0))
	assert_null(fixture.original_attachment.get_surface_binding())
	var source := FileAccess.get_file_as_string("res://game/player/abilities/grapple/grapple_surface_binding.gd")
	assert_false(source.contains("intersect_ray"))
	var resolver := FileAccess.get_file_as_string("res://game/player/abilities/grapple/grapple_target_resolver.gd")
	assert_eq(resolver.count("return space_state.intersect_ray(params)"), 1)

func _spawn(policy: String = "ordinary", forward: bool = true, moving_old: bool = false, scope: StringName = &"", target_scope: StringName = &"") -> WallStickReanchorFixture:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var fixture := FIXTURE.instantiate() as WallStickReanchorFixture
	fixture.wall_policy = policy
	fixture.start_forward = forward
	fixture.moving_grapple_anchor = moving_old
	fixture.initial_scope = scope
	fixture.wall_scope = target_scope
	viewport.add_child(fixture)
	await _ticks(6)
	assert_eq(fixture.maximum_commits, 1)
	assert_true(fixture.original_attachment.is_active(), "positive original-grapple control")
	return fixture

func _ticks(count: int) -> void:
	for _i in range(count):
		await get_tree().physics_frame
	await get_tree().process_frame
