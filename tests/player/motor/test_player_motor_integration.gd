extends GutTest


const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")


func test_real_character_body_fixture_accepts_one_commit_for_each_traversal_state_id() -> void:
	var fixture := _new_physics_fixture()
	var motor: PlayerMotor = fixture[1]
	var traversal_ids: Array[StringName] = [
		&"player.locomotion.grounded",
		&"player.locomotion.airborne",
		&"player.locomotion.grappling",
		&"player.locomotion.wall_run",
		&"player.locomotion.wall_stick",
		&"player.locomotion.dead",
	]

	for step in range(traversal_ids.size()):
		var physics_step := step + 1
		assert_eq(motor.begin_motion_frame(physics_step), PlayerMotor.FrameStatus.SUCCESS)
		assert_eq(
			motor.select_state_policy(traversal_ids[step]),
			PlayerMotor.SubmissionStatus.SUCCESS
		)
		assert_eq(
			motor.submit_base_motion(
				StringName("%s.base" % String(traversal_ids[step])),
				Vector3(0.5 + step, -0.25, 0.0),
				0.0,
				false
			),
			PlayerMotor.SubmissionStatus.SUCCESS
		)
		var result := motor.resolve_and_commit()
		assert_true(result.success)
		assert_eq(result.physics_step, physics_step)
		assert_eq(result.locomotion_state_id, traversal_ids[step])
		assert_eq(result.commit_count, 1)
		_assert_post_commit_contact_frame(result.contact_frame, physics_step, true)


func test_real_character_body_fixture_returns_bounded_slide_collisions_without_second_commit() -> void:
	var fixture := _new_physics_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	body.global_position = Vector3(0.0, 1.1, 0.0)

	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.airborne"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(&"player.airborne.base", Vector3(0.0, -4.0, 0.0), 0.0, false),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	_assert_post_commit_contact_frame(result.contact_frame, 1, true)
	assert_lte(result.contact_frame.reported_collision_count, PlayerMotor.MAX_REPORTED_COLLISIONS)
	assert_false(result.collision_facts_truncated)
	var transform_after_commit := body.global_transform
	var second := motor.resolve_and_commit()
	assert_push_error("player.motor.duplicate_commit")
	assert_false(second.success)
	assert_eq(body.global_transform, transform_after_commit)


func test_real_player_scene_commits_once_per_controller_physics_step() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	input_source.enable_test_input_seam()

	player.call("_physics_process", 1.0 / 60.0)
	var first_result: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_gte(motor.get_accepted_submission_count(), 2)
	assert_eq(motor.get_commit_count(), 1)
	assert_eq(first_result.physics_step, 1)
	_assert_post_commit_contact_frame(first_result.contact_frame, 1, true)

	player.call("_physics_process", 1.0 / 60.0)
	var second_result: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_gte(motor.get_accepted_submission_count(), 2)
	assert_eq(motor.get_commit_count(), 1)
	assert_eq(second_result.physics_step, 2)
	_assert_post_commit_contact_frame(second_result.contact_frame, 2, true)


func test_real_player_scene_commits_once_per_real_physics_tick() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	input_source.enable_test_input_seam()

	var observed_steps: Array[int] = []
	for _frame in range(8):
		await get_tree().physics_frame
		var result: PlayerMotorCommitResult = motor.get_last_commit_result()
		if result == null:
			continue
		assert_true(result.success)
		assert_eq(result.commit_count, 1)
		_assert_post_commit_contact_frame(result.contact_frame, result.physics_step, true)
		assert_gte(motor.get_accepted_submission_count(), 2)
		if not observed_steps.is_empty():
			assert_eq(result.physics_step, observed_steps.back() + 1)
		observed_steps.append(result.physics_step)
	assert_gte(observed_steps.size(), 4)


func test_real_player_scene_aborts_an_accepted_request_when_begin_is_rejected() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	input_source.enable_test_input_seam()
	var before := player.global_transform

	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.locomotion.grounded"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grounded.base",
			Vector3(4.0, 0.0, 0.0),
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	player.call("_physics_process", 1.0 / 60.0)
	assert_push_error("player.motor.duplicate_active_frame")

	assert_false(player.is_player_physics_active())
	assert_false(motor.has_active_motion_frame())
	assert_null(motor.get_last_commit_result())
	assert_eq(motor.get_commit_count(), 0)
	assert_eq(player.global_transform, before)


func test_real_player_scene_preserves_ground_commit_and_jump_launch() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	player.set("max_ground_speed", 10.0)
	player.set("ground_deceleration", 30.0)
	input_source.enable_test_input_seam()
	await get_tree().physics_frame

	input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
	for _frame in range(30):
		await get_tree().physics_frame
	input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	await get_tree().physics_frame
	await get_tree().physics_frame

	assert_true(player.get_previous_contact_frame().is_grounded)
	assert_lt(player.global_position.z, -1.0)
	assert_lte(absf(player.velocity.z), 10.0)
	assert_eq(motor.get_commit_count(), 1)

	input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
	await get_tree().physics_frame
	var jump_result := motor.get_last_commit_result()
	assert_true(jump_result.success)
	assert_almost_eq(jump_result.submitted_velocity.y, 4.5, 0.00001)
	assert_eq(jump_result.commit_count, 1)
	input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)


func test_real_player_scene_routes_dead_state_once() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	input_source.enable_test_input_seam()
	await get_tree().physics_frame

	player.call("_set_dead")
	player.call("_physics_process", 1.0 / 60.0)
	var dead_result := motor.get_last_commit_result()
	assert_eq(dead_result.locomotion_state_id, &"player.locomotion.dead")
	assert_eq(dead_result.commit_count, 1)
	var terminal_record: Dictionary = dead_result.accepted_sources_by_phase[
		MotorPhase.Phase.TERMINAL_COMMANDS
	][0]
	assert_eq(terminal_record["source_id"], &"player.terminal.dead")
	assert_eq(
		terminal_record["kind"],
		int(PlayerMotorSubmission.Kind.TERMINAL_POLICY)
	)


func test_real_player_scene_routes_wall_run_and_wall_jump_once() -> void:
	var fixture := _new_player_scene_fixture(Vector3(0.0, 4.0, -0.25))
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	_add_wall_target(player.get_parent())
	input_source.enable_test_input_seam()
	var found_airborne_state := false
	for _frame in range(8):
		await get_tree().physics_frame
		var current_result: PlayerMotorCommitResult = motor.get_last_commit_result()
		if current_result != null and current_result.locomotion_state_id == &"player.locomotion.airborne":
			found_airborne_state = true
			break
	assert_true(found_airborne_state)

	player.velocity = Vector3(6.0, 0.0, 0.0)
	input_source.inject_movement_strengths(0.0, 1.0, 0.0, 0.0)
	player.call("_physics_process", 1.0 / 60.0)
	var wall_run_entry_result := motor.get_last_commit_result()
	assert_eq(wall_run_entry_result.locomotion_state_id, &"player.locomotion.airborne")
	assert_eq(wall_run_entry_result.commit_count, 1)
	_assert_post_commit_contact_frame(
		wall_run_entry_result.contact_frame,
		wall_run_entry_result.physics_step,
		true
	)
	assert_true(wall_run_entry_result.contact_frame.has_wall_contact)
	assert_true(bool(player.get("is_wall_running")))

	input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
	player.call("_physics_process", 1.0 / 60.0)
	var wall_jump_result := motor.get_last_commit_result()
	assert_eq(wall_jump_result.locomotion_state_id, &"player.locomotion.wall_run")
	assert_almost_eq(wall_jump_result.submitted_velocity.y, 5.5, 0.00001)
	assert_eq(wall_jump_result.commit_count, 1)
	assert_false(bool(player.get("is_wall_running")))
	input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)


func test_real_player_scene_routes_wall_stick_hold_and_release_once() -> void:
	var fixture := _new_player_scene_fixture(Vector3(0.0, 4.0, -0.25))
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	_add_wall_target(player.get_parent())
	input_source.enable_test_input_seam()
	var found_airborne_state := false
	for _frame in range(8):
		await get_tree().physics_frame
		var current_result: PlayerMotorCommitResult = motor.get_last_commit_result()
		if current_result != null and current_result.locomotion_state_id == &"player.locomotion.airborne":
			found_airborne_state = true
			break
	assert_true(found_airborne_state)

	player.velocity = Vector3(6.0, 0.0, 0.0)
	input_source.inject_movement_strengths(0.0, 1.0, 0.0, 0.0)
	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	player.call("_physics_process", 1.0 / 60.0)

	var became_stuck := bool(player.get("is_wall_sticking"))
	for _frame in range(20):
		if became_stuck:
			break
		player.call("_physics_process", 1.0 / 60.0)
		became_stuck = bool(player.get("is_wall_sticking"))
	assert_true(became_stuck)

	player.call("_physics_process", 1.0 / 60.0)
	var hold_result := motor.get_last_commit_result()
	assert_eq(hold_result.locomotion_state_id, &"player.locomotion.wall_stick")
	_assert_post_commit_contact_frame(hold_result.contact_frame, hold_result.physics_step, true)
	assert_true(hold_result.contact_frame.has_wall_contact)
	assert_true(hold_result.is_hold_request)
	assert_eq(hold_result.commit_count, 1)

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	player.call("_physics_process", 1.0 / 60.0)
	var release_result := motor.get_last_commit_result()
	assert_eq(release_result.locomotion_state_id, &"player.locomotion.wall_stick")
	assert_false(release_result.is_hold_request)
	assert_eq(release_result.submitted_velocity, Vector3.ZERO)
	assert_eq(release_result.commit_count, 1)


func test_real_player_scene_clears_grapple_before_landing_transition() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	var grapple_target := _add_wall_target(player.get_parent())
	input_source.enable_test_input_seam()
	await get_tree().physics_frame
	player.set("is_grappling", true)
	player.set("grapple_target", grapple_target)
	player.set("grapple_point", Vector3(0.0, 0.1, -1.0))
	player.call("dispatch_locomotion_event", &"grapple_started")
	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)

	player.call("_physics_process", 1.0 / 60.0)
	var landing_result := motor.get_last_commit_result()

	assert_true(landing_result.success)
	assert_eq(landing_result.locomotion_state_id, &"player.locomotion.grappling")
	assert_eq(landing_result.commit_count, 1)
	assert_true(landing_result.contact_frame.is_grounded)
	assert_false(bool(player.get("is_grappling")))
	assert_true(player.is_player_physics_active())


func test_player_surface_keeps_motion_commit_inside_motor() -> void:
	var player_surface_paths: Array[String] = [
		"res://scripts/player_controller.gd",
		"res://scripts/player_grounded_state.gd",
		"res://scripts/player_airborne_state.gd",
		"res://scripts/player_grappling_state.gd",
		"res://scripts/player_wall_run_state.gd",
		"res://scripts/player_wall_stick_state.gd",
		"res://scripts/player_dead_state.gd",
	]
	for path in player_surface_paths:
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("move_and_slide("), path)
		assert_false(source.contains("\n\tvelocity"), path)
		assert_false(source.contains("\n\tglobal_position"), path)

	var motor_source := FileAccess.get_file_as_string("res://game/player/motor/player_motor.gd")
	assert_true(motor_source.contains("_body.move_and_slide()"))
	assert_true(motor_source.contains("_body.velocity = working_velocity"))
	assert_true(motor_source.contains("_body.global_position = requested_hold_position"))

	var attack_surface_paths: Array[String] = [
		"res://scripts/player_attack_ready_state.gd",
		"res://scripts/player_attack_windup_state.gd",
		"res://scripts/player_attack_active_state.gd",
		"res://scripts/player_attack_recovery_state.gd",
	]
	for path in attack_surface_paths:
		var attack_source := FileAccess.get_file_as_string(path)
		assert_false(attack_source.contains("move_and_slide("), path)
		assert_false(attack_source.contains("PlayerMotor"), path)
		assert_false(attack_source.contains("submit_motion"), path)


func test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band() -> void:
	var direct_player: CharacterBody3D = PLAYER_SCENE.instantiate()
	autofree(direct_player)
	assert_almost_eq(direct_player.ground_deceleration, 20.0, 0.000001)
	assert_almost_eq(direct_player.grapple_gravity_scale, 1.0, 0.000001)

	var main_source := FileAccess.get_file_as_string("res://main.tscn")
	assert_true(main_source.contains("ground_deceleration = 30.0"))
	assert_true(main_source.contains("grapple_gravity_scale = 0.0"))

	var tutorial_source := FileAccess.get_file_as_string(
		"res://scripts/levels/tree_grapple_tutorial.gd"
	)
	assert_true(tutorial_source.contains("const START_POSITION := Vector3(0.0, 0.1, 24.0)"))
	assert_true(tutorial_source.contains("player.global_position = START_POSITION"))
	assert_false(
		tutorial_source.contains("grapple_length"),
		"tutorial must not carry grapple-range scalars (Story 1.6 single range source)"
	)
	assert_false(
		tutorial_source.contains("max_grapple"),
		"tutorial must not carry grapple-range scalars (Story 1.6 single range source)"
	)
	assert_true(tutorial_source.contains('player.set("grapple_gravity_scale", 0.65)'))


func _new_player_scene_fixture(
	player_position: Vector3 = Vector3(0.0, 0.1, 0.0)
) -> Array[Node]:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var floor := StaticBody3D.new()
	world.add_child(floor)
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(20.0, 0.2, 20.0)
	floor_shape.shape = floor_box
	floor.add_child(floor_shape)

	var player: CharacterBody3D = PLAYER_SCENE.instantiate()
	player.set("capture_mouse_on_start", false)
	player.position = player_position
	world.add_child(player)
	return [player]


func _add_wall_target(world: Node) -> StaticBody3D:
	var wall := StaticBody3D.new()
	wall.position = Vector3(0.0, 4.0, -1.0)
	world.add_child(wall)
	var wall_shape := CollisionShape3D.new()
	var wall_box := BoxShape3D.new()
	wall_box.size = Vector3(20.0, 8.0, 0.2)
	wall_shape.shape = wall_box
	wall.add_child(wall_shape)
	return wall


func _new_physics_fixture() -> Array[Node]:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var floor := StaticBody3D.new()
	world.add_child(floor)
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(20.0, 0.2, 20.0)
	floor_shape.shape = floor_box
	floor.add_child(floor_shape)
	floor.position = Vector3(0.0, 0.0, 0.0)

	var body := CharacterBody3D.new()
	world.add_child(body)
	var body_shape := CollisionShape3D.new()
	var body_capsule := CapsuleShape3D.new()
	body_capsule.radius = 0.45
	body_capsule.height = 1.8
	body_shape.shape = body_capsule
	body_shape.position.y = 0.9
	body.add_child(body_shape)

	var motor := PlayerMotor.new()
	world.add_child(motor)
	_configure_contact_profiles(motor)
	assert_eq(motor.initialize(body), PlayerMotor.InitializationStatus.SUCCESS)
	return [body, motor]


func _configure_contact_profiles(motor: PlayerMotor) -> void:
	var ground := GroundProbe.new()
	var ground_shape := SphereShape3D.new()
	ground_shape.radius = 0.08
	ground.shape = ground_shape
	ground.collision_mask_names = PackedStringArray(["world_geometry"])
	var wall := WallProbe.new()
	var wall_shape := SphereShape3D.new()
	wall_shape.radius = 0.12
	wall.shape = wall_shape
	wall.collision_mask_names = PackedStringArray(["world_geometry"])
	motor.ground_probe = ground
	motor.wall_probe = wall


func _assert_post_commit_contact_frame(
	frame: ContactFrame,
	physics_step: int,
	committed_evidence: bool
) -> void:
	assert_not_null(frame)
	assert_true(frame.success)
	assert_eq(frame.physics_step, physics_step)
	assert_eq(frame.source_motor_step, physics_step)
	assert_eq(frame.origin, ContactFrame.Origin.POST_COMMIT)
	assert_eq(frame.committed_evidence_available, committed_evidence)
	assert_true(frame.is_value_only())
	assert_lte(frame.scanned_collision_count, PlayerMotor.MAX_SCANNED_COLLISIONS)
	assert_lte(frame.reported_collision_count, PlayerMotor.MAX_REPORTED_COLLISIONS)
	assert_gte(frame.query_count, 1)
