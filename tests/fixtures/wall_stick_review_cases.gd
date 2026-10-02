class_name WallStickReviewCases
extends RefCounted
## Small framework-neutral engine repro cases shared by GUT and fresh MCP eval.
const FIXTURE := preload("res://tests/fixtures/wall_stick_motion_fixture.tscn")
const CASES := ["same_resource_growth", "compound", "added_owner", "added_shape_same_owner", "two_walls", "already_moving", "entry_teleport", "slow_roll", "slow_pitch", "disabled_owner_removed", "delta_mismatch", "missing_definition", "invalid_definition"]

static func run(tree: SceneTree, scenario: String, rate: int) -> Dictionary:
	Engine.physics_ticks_per_second = rate
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.world_3d = World3D.new()
	tree.root.add_child(viewport)
	if tree.current_scene == null:
		tree.current_scene = viewport
	var fixture := FIXTURE.instantiate() as WallStickMotionFixture
	match scenario:
		"compound":
			fixture.initial_compound = true
			fixture.initial_owner_motion = Vector3.UP * 2.0
		"already_moving":
			fixture.initial_wall_motion = Vector3.RIGHT * (20.0 if rate == 120 else 12.0)
		"entry_teleport":
			fixture.initial_teleport = Vector3.RIGHT * 4.0
			fixture.freeze_after_first_commit = true
		"two_walls":
			fixture.initial_wall_position.z = -0.8
		"disabled_owner_removed":
			fixture.initial_disabled_owner = true
	viewport.add_child(fixture)
	await _ticks(tree, 8)
	var entered := bool(fixture.player.get("is_wall_sticking"))
	var held_before := fixture.held_frames
	var attachment: WallStickAttachment = fixture.player.get("_wall_stick_attachment")
	var extra: Dictionary = {"entered_before_change": entered}
	var passed := false
	match scenario:
		"same_resource_growth":
			var shape := fixture.wall.get_node(^"WallShape").shape as BoxShape3D
			var connections := shape.changed.get_connections().size()
			shape.size.z += 0.2
			extra["idle_status_unchanged"] = attachment != null and attachment.status == WallStickAttachment.Status.VALID
			await _ticks(tree, 3)
			# Carry and grapple now have independent weak listeners; terminal
			# cleanup removes BOTH, including after a prior forward release.
			extra["listener_removed"] = shape.changed.get_connections().size() == connections - 2
			extra["rejection"] = int(attachment.status) if attachment != null else -1
			passed = entered and extra.idle_status_unchanged and extra.listener_removed and extra.rejection == WallStickAttachment.Status.INVALID_SUPPORT and fixture.held_frames == held_before and fixture.terminal_count == 1
		"compound":
			await _ticks(tree, 20)
			extra["selected_shape_local_y"] = fixture.wall.get_node(^"WallShape").position.y
			passed = not entered and fixture.entry_count == 0 and fixture.held_frames == 0 and extra.selected_shape_local_y > 0.3 and fixture.player.global_position.y < 4.401
		"added_owner":
			var ceiling := fixture._add_shape(fixture.wall, Vector3(4.0, 0.2, 4.0))
			ceiling.position = fixture.wall.global_transform.affine_inverse() * (fixture.player.global_position + Vector3.UP * 2.3)
			fixture.wall.set("owner_motion_velocity", Vector3.UP * 2.0)
			await _ticks(tree, 12)
			passed = entered and fixture.held_frames == held_before and fixture.terminal_count == 1 and not bool(fixture.player.get("is_wall_sticking")) and fixture.player.global_position.y < 4.401
		"added_shape_same_owner":
			var owner_id := fixture.wall.shape_find_owner(fixture.motor.get_previous_contact_frame().wall_support.shape_index)
			var sibling := BoxShape3D.new()
			# Keep the appended geometry inside the existing wall, isolating the
			# owner cardinality guard from an externally-created player overlap.
			sibling.size = Vector3(2.0, 0.2, 0.1)
			fixture.wall.shape_owner_add_shape(owner_id, sibling)
			await _ticks(tree, 3)
			passed = entered and fixture.held_frames == held_before and fixture.terminal_count == 1 and not bool(fixture.player.get("is_wall_sticking"))
		"two_walls":
			var neighbor := StaticBody3D.new()
			neighbor.position = fixture.player.global_position + Vector3(0.60, 0.0, 0.0)
			neighbor.set_meta(&"physics_surface_id", &"fixture.wall.neighbor")
			fixture._add_shape(neighbor, Vector3(0.1, 16.0, 16.0))
			fixture.add_child(neighbor)
			fixture.input_source.inject_mouse_motion(Vector2(-PI / fixture.input_source.mouse_sensitivity, 0.0))
			await _ticks(tree, 8)
			var frame := fixture.motor.get_previous_contact_frame()
			extra["legacy_winner"] = frame.wall_surface_identity
			extra["bound_support"] = frame.wall_support.surface_identity if frame.wall_support != null else &""
			extra["query_count"] = frame.query_count
			extra["value_only"] = frame.is_value_only()
			extra["kept_original"] = bool(fixture.player.get("is_wall_sticking")) and fixture.entry_count == 1 and fixture.terminal_count == 0
			fixture.wall.get_node(^"WallShape").disabled = true
			await _ticks(tree, 3)
			extra["genuine_switch_detached"] = not bool(fixture.player.get("is_wall_sticking")) and fixture.terminal_count == 1
			passed = entered and extra.legacy_winner == &"fixture.wall.neighbor" and extra.bound_support == &"fixture.wall.stick" and extra.kept_original and extra.genuine_switch_detached and extra.value_only and extra.query_count <= 32
		"already_moving":
			var first := fixture.first_hold_commit
			extra["first_hold_error_m"] = first.hold_position_error_m if first != null else INF
			extra["first_hold_displacement_m"] = first.position_after.distance_to(first.position_before) if first != null else INF
			extra["speed_mps"] = fixture.initial_wall_motion.x
			passed = entered and first != null and not first.hold_carry_blocked and extra.first_hold_error_m < 0.003 and extra.first_hold_displacement_m <= 0.25 and fixture.entry_count == 1 and fixture.terminal_count == 0 and fixture.minimum_side_distance_m >= 0.45
		"entry_teleport":
			passed = not entered and fixture.entry_count == 0 and fixture.held_frames == 0 and fixture.motor.get_last_commit_result().physics_step == 1
		"slow_roll", "slow_pitch":
			fixture.wall.set("roll_increment_radians" if scenario == "slow_roll" else "pitch_increment_radians", 0.00009)
			await _ticks(tree, 3)
			extra["rejection"] = int(attachment.status) if attachment != null else -1
			extra["tilt_radians"] = absf(fixture.wall.rotation.z if scenario == "slow_roll" else fixture.wall.rotation.x)
			passed = entered and extra.rejection == WallStickAttachment.Status.INVALID_SUPPORT and fixture.terminal_count == 1 and not bool(fixture.player.get("is_wall_sticking")) and extra.tilt_radians < 0.001 and fixture.held_frames - held_before <= 1
		"disabled_owner_removed":
			extra["old_shape_index"] = fixture.motor.get_previous_contact_frame().wall_support.shape_index
			fixture.wall.get_node(^"DisabledUnrelatedShape").queue_free()
			await _ticks(tree, 4)
			var frame := fixture.motor.get_previous_contact_frame()
			extra["new_shape_index"] = frame.wall_support.shape_index if frame.wall_support != null else -1
			passed = entered and extra.old_shape_index != extra.new_shape_index and bool(fixture.player.get("is_wall_sticking")) and fixture.entry_count == 1 and fixture.terminal_count == 0
		"delta_mismatch":
			fixture.player.set_physics_process(false)
			await tree.physics_frame
			var before := fixture.player.global_position
			var step := int(fixture.player.call("get_motion_step")) + 1
			fixture.motor.begin_motion_frame(step, fixture.player.get_physics_process_delta_time() * 2.0)
			fixture.motor.select_state_policy(&"player.locomotion.wall_stick")
			fixture.motor.submit_wall_stick_hold(&"player.wall_stick.hold", before + Vector3.RIGHT * 0.01, 0.02, Vector3.ZERO, 0.0, Vector3.ZERO, weakref(fixture.wall))
			var result := fixture.motor.resolve_and_commit()
			extra["delta_mismatch_blocked"] = result.hold_carry_blocked
			extra["refused_motion_m"] = fixture.player.global_position.distance_to(before)
			passed = result.success and result.hold_carry_blocked and result.commit_count == 1 and extra.refused_motion_m < 0.00001
		"missing_definition", "invalid_definition":
			fixture.player.set_physics_process(false)
			fixture.player.call("_clear_wall_stick")
			var frame := fixture.motor.get_previous_contact_frame()
			extra["physical_positive_control"] = bool(fixture.player.call("_try_start_wall_stick_from_contact", Vector2.ZERO, Vector3.ZERO, frame, fixture.player.global_position))
			fixture.player.call("_clear_wall_stick")
			var invalid := WallStickDefinition.new()
			invalid.maximum_entry_speed_mps = -1.0
			fixture.player.set("wall_stick_definition", null if scenario == "missing_definition" else invalid)
			extra["invalid_entry_refused"] = not bool(fixture.player.call("_try_start_wall_stick_from_contact", Vector2.ZERO, Vector3.ZERO, frame, fixture.player.global_position))
			passed = entered and extra.physical_positive_control and extra.invalid_entry_refused and not bool(fixture.player.get("is_wall_sticking"))
	var report := fixture.report()
	report.merge(extra)
	report["scenario"] = scenario
	report["rate"] = rate
	report["additional_holds"] = fixture.held_frames - held_before
	# Resizing occupied geometry is allowed to intersect the old capsule before
	# the next physics sample. Prove no further hold/exclusion, not impossible
	# retroactive collision prevention. Preserve every observed overlap fact.
	report["externally_resized_geometry"] = scenario == "same_resource_growth"
	report["passed"] = passed and report.maximum_commits == 1 and (report.overlap_count == 0 or scenario == "same_resource_growth")
	viewport.queue_free()
	await tree.process_frame
	return report

static func run_support_velocity(tree: SceneTree, scenario: String, rate: int) -> Dictionary:
	Engine.physics_ticks_per_second = rate
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.world_3d = World3D.new()
	tree.root.add_child(viewport)
	if tree.current_scene == null:
		tree.current_scene = viewport
	var fixture := FIXTURE.instantiate() as WallStickMotionFixture
	viewport.add_child(fixture)
	await _ticks(tree, 6)
	fixture.player.set_physics_process(false)
	fixture.player.call("_clear_wall_stick")
	# This focused native-support entry probe replaces/disables the old wall.
	# Start from a genuinely VALID ordinary tether to the separate anchor, not
	# from a cached surface grapple whose supporting geometry is being removed.
	# The transaction now correctly refuses that invalid-original migration.
	var controller: GrappleController = fixture.player.get("_grapple_controller")
	var original_step := fixture.motor.get_previous_contact_frame().physics_step
	controller.terminate(GrappleEndReason.Reason.RELEASE, original_step)
	controller.commit_attachment(GrappleTargetSeed.new(&"", fixture.anchor.global_position, Vector3.BACK, GrappleTargetResponse.static_default(), weakref(fixture.anchor), Vector3.ZERO), original_step)
	fixture.player.set("is_grappling", true)
	var body: PhysicsBody3D = fixture.wall
	var shape := body.get_node(^"WallShape") as CollisionShape3D
	var provider := fixture.motor.get_contact_provider()
	var delta := 1.0 / float(rate)
	var step := fixture.motor.get_previous_contact_frame().physics_step + 1
	var expected := Vector3.RIGHT * 12.0
	match scenario:
		"owner_local":
			shape.position.x += 12.0 * delta
		"static_surface":
			fixture.wall.constant_linear_velocity = Vector3.RIGHT * 12.0
			fixture.wall.constant_angular_velocity = Vector3.UP * 2.0
		"rigid_first":
			fixture.wall.collision_layer = 0
			var rigid := RigidBody3D.new()
			rigid.position = fixture.wall.position
			rigid.gravity_scale = 0.0
			rigid.linear_damp_mode = RigidBody3D.DAMP_MODE_REPLACE
			rigid.linear_damp = 0.0
			rigid.linear_velocity = expected
			rigid.collision_mask = 0
			rigid.set_meta(&"physics_surface_id", &"fixture.wall.rigid")
			fixture._add_shape(rigid, Vector3(16.0, 16.0, 0.4))
			fixture.add_child(rigid)
			body = rigid
			await _ticks(tree, 2)
		# Clear only the pose history to exercise native first-sample fallback.
		"animatable_first", "character_first":
			fixture.wall.collision_layer = 0
			body = AnimatableBody3D.new() if scenario == "animatable_first" else CharacterBody3D.new()
			body.position = fixture.wall.position
			body.collision_mask = 0
			body.set_meta(&"physics_surface_id", &"fixture.wall.native")
			fixture._add_shape(body, Vector3(16.0, 16.0, 0.4))
			fixture.add_child(body)
			await _ticks(tree, 2)
			await tree.physics_frame
			if body is AnimatableBody3D:
				body.position.x += 12.0 * delta
			else:
				body.velocity = expected
				body.move_and_slide()
			await tree.physics_frame
	# Sample the real body/owner shapes through a real motor publication. These
	# are focused entry-policy cases, not synthetic-delta swept-collision proof.
	fixture.motor.begin_motion_frame(step, delta)
	fixture.motor.select_state_policy(&"player.locomotion.airborne")
	fixture.motor.submit_base_motion(&"player.locomotion.airborne.base", Vector3.ZERO, 0.0, false)
	var result := fixture.motor.resolve_and_commit()
	controller.record_committed_facts(result)
	var frame := result.contact_frame
	if scenario == "static_surface" and frame.wall_support != null:
		expected += fixture.wall.constant_angular_velocity.cross(frame.wall_support.point - fixture.wall.global_position)
	var native_state := PhysicsServer3D.body_get_direct_state(body.get_rid())
	var native_velocity := native_state.get_velocity_at_local_position(frame.wall_support.point - native_state.transform.origin) if native_state != null and frame.wall_support != null else Vector3(INF, 0.0, 0.0)
	fixture.player.set("_player_physics_step", step)
	var grapple_bit := 1 << int(PlayerCommandFrame.Action.GRAPPLE)
	fixture.player.set("_current_command_frame", PlayerCommandFrame.new(step, Vector2.ZERO, 0.0, 0.0, Vector3.FORWARD, 0, grapple_bit, 0, true))
	var positive := bool(fixture.player.call("_try_start_wall_stick_from_contact", Vector2.ZERO, frame.wall_point_velocity + Vector3.RIGHT * 99.0, frame, result.position_after))
	fixture.player.call("_clear_wall_stick")
	var negative := bool(fixture.player.call("_try_start_wall_stick_from_contact", Vector2.ZERO, frame.wall_point_velocity - Vector3.RIGHT * 100.1, frame, result.position_after))
	var report := {"scenario": scenario, "rate": rate, "wall_point_velocity": frame.wall_point_velocity, "expected": expected, "native_velocity": native_velocity, "body_position": body.global_position, "entry_positive": positive, "entry_over_relative_maximum": negative, "support": frame.wall_support.surface_identity if frame.wall_support != null else &"", "query_count": frame.query_count, "value_only": frame.is_value_only()}
	report["passed"] = frame.wall_support != null and frame.wall_point_velocity.distance_to(expected) < 0.003 and positive and not negative and frame.is_value_only()
	if scenario in ["rigid_first", "animatable_first", "character_first"]:
		# Once an adjacent owner/body pose exists, native linear/angular motion
		# is already represented by that delta. Verify it is not added twice.
		if body is AnimatableBody3D:
			body.position.x += 12.0 * delta
		elif body is CharacterBody3D:
			body.velocity = expected
			body.move_and_slide()
		await tree.physics_frame
		fixture.motor.begin_motion_frame(step + 1, delta)
		fixture.motor.select_state_policy(&"player.locomotion.airborne")
		fixture.motor.submit_base_motion(&"player.locomotion.airborne.base", Vector3.ZERO, 0.0, false)
		var adjacent := fixture.motor.resolve_and_commit().contact_frame
		report["adjacent_velocity"] = adjacent.wall_point_velocity
		report["adjacent_not_double_counted"] = adjacent.wall_point_velocity.distance_to(expected) < 0.003
		report["passed"] = report.passed and report.adjacent_not_double_counted
	viewport.queue_free()
	await tree.process_frame
	return report

static func _ticks(tree: SceneTree, count: int) -> void:
	for _i in range(count):
		await tree.physics_frame
	await tree.process_frame
