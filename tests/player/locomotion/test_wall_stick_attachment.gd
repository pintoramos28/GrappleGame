extends GutTest

const FIXTURE := preload("res://tests/fixtures/wall_stick_motion_fixture.tscn")
const PLAYER := preload("res://scenes/player.tscn")
var _saved_rate: int

func before_all() -> void:
	_saved_rate = Engine.physics_ticks_per_second

func after_each() -> void:
	Engine.physics_ticks_per_second = _saved_rate
	Input.action_release(&"move_forward")
	Input.action_release(&"move_back")
	Input.action_release(&"fire_grapple")
	Input.action_release(&"jump")

func test_definition_is_validated_locked_and_independent_of_run_tuning() -> void:
	var definition := WallStickDefinition.new()
	definition.maximum_entry_speed_mps = 12.0
	assert_eq(definition.validate(), WallStickDefinition.ValidationStatus.SUCCESS)
	definition.maximum_entry_speed_mps = 1.0
	definition.jump_up_speed_mps = 99.0
	assert_eq(definition.maximum_entry_speed_mps, 12.0)
	assert_eq(definition.jump_up_speed_mps, 5.5)
	for invalid_value in [0.0, -1.0, INF, NAN]:
		var invalid := WallStickDefinition.new()
		invalid.maximum_entry_speed_mps = invalid_value
		assert_eq(invalid.validate(), WallStickDefinition.ValidationStatus.INVALID_SPEED)
	var player: CharacterBody3D = autofree(PLAYER.instantiate())
	player.set("wall_stick_definition", definition)
	player.set("wall_run_max_entry_speed", 18.0)
	assert_false(bool(player.call("_can_start_wall_stick", Vector3.RIGHT * 13.0)))
	assert_true(bool(player.call("_can_start_wall_run", Vector3.RIGHT * 13.0)))
	player.set("wall_run_max_entry_speed", 4.0)
	assert_true(bool(player.call("_can_start_wall_stick", Vector3.RIGHT * 12.0)))
	assert_false(bool(player.call("_can_start_wall_run", Vector3.RIGHT * 12.0)))
	var wider := WallStickDefinition.new()
	wider.maximum_entry_speed_mps = 100.0
	wider.validate()
	player.set("wall_stick_definition", wider)
	assert_true(bool(player.call("_can_start_wall_stick", Vector3.RIGHT * 100.0)))
	assert_false(bool(player.call("_can_start_wall_run", Vector3.RIGHT * 12.0)))
	assert_true(bool(player.call("_can_start_wall_stick", Vector3.RIGHT * 110.0, Vector3.RIGHT * 10.0)))
	assert_false(bool(player.call("_can_start_wall_stick", Vector3.RIGHT * 110.01, Vector3.RIGHT * 10.0)))
	assert_false(bool(player.call("_can_start_wall_stick", Vector3.ZERO, Vector3(INF, 0.0, 0.0))))

func test_real_continuous_transform_walls_carry_on_the_same_side_at_60_and_120() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := await _spawn()
		for motion in [Vector3(1.0, 0.0, -1.0), Vector3(1.0, 0.0, 1.0), Vector3.ZERO, Vector3(-1.0, 0.0, -1.0)]:
			fixture.wall.set("motion_velocity", motion)
			await _ticks(int(rate * 0.3))
			assert_true(bool(fixture.player.get("is_wall_sticking")), "%s @ %d Hz: %s" % [motion, rate, fixture.report()])
		fixture.wall.set("motion_velocity", Vector3.ZERO)
		fixture.wall.set("yaw_rate_rps", 0.2)
		fixture.input_source.inject_mouse_motion(Vector2(-PI / fixture.input_source.mouse_sensitivity, 0.0))
		await _ticks(int(rate * 0.3))
		var report: Dictionary = fixture.report()
		assert_true(report["sticking"], str(report))
		assert_eq(report["entry_count"], 1)
		assert_eq(report["terminal_count"], 0)
		assert_eq(report["blocked_count"], 0)
		assert_eq(report["overlap_count"], 0, "real capsule overlap, not only a point-side check")
		assert_gte(report["minimum_side_distance_m"], 0.45)
		assert_lte(report["maximum_error_m"], 0.003)
		assert_eq(report["maximum_commits"], 1)
		assert_lt(report["maximum_recovery_m"], 0.003, "bound support must not double-carry through native recovery")
		print("[wall-stick-engine-motion] ", rate, " Hz ", report)

func test_forward_release_preserves_live_grapple_and_does_not_relatch() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := await _spawn()
		fixture.wall.set("motion_velocity", Vector3.RIGHT)
		await _ticks(10)
		fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
		await _ticks(1)
		var result := fixture.detachment_commit
		assert_not_null(result, "capture the actual release commit, not later grapple acceleration")
		if result == null:
			continue
		assert_almost_eq((result.submitted_velocity - fixture.detachment_reference_velocity).length(), 0.0, 0.001)
		assert_false(result.is_hold_request)
		assert_eq(result.locomotion_state_id, &"player.locomotion.wall_stick")
		await _ticks(8)
		assert_false(bool(fixture.player.get("is_wall_sticking")))
		assert_true(bool(fixture.player.get("is_grappling")))
		assert_eq(fixture.motor.get_last_commit_result().locomotion_state_id, &"player.locomotion.grappling")
		assert_eq(fixture.terminal_count, 0)
		assert_eq(fixture.entry_count, 1)

func test_jump_removes_player_and_wall_tangent_and_wins_both_releases() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := await _spawn()
		fixture.wall.set("motion_velocity", Vector3.RIGHT * 3.0)
		await _ticks(8)
		fixture.player.velocity = Vector3(7.0, -2.0, 0.5)
		fixture.input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
		fixture.input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
		fixture.input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
		await _ticks(1)
		assert_almost_eq(fixture.jump_velocity.x, 0.0, 0.0001)
		assert_almost_eq(fixture.jump_velocity.y, 5.5, 0.0001)
		assert_almost_eq(fixture.jump_velocity.z, 8.0, 0.0001)
		assert_false(bool(fixture.player.get("is_grappling")))
		assert_false(bool(fixture.player.get("is_wall_sticking")))
		assert_eq(fixture.terminal_count, 1)
		assert_true(fixture.terminal_wall_clear)
		await _ticks(4)
		assert_eq(fixture.terminal_count, 1)
		assert_eq(fixture.maximum_commits, 1)

func test_distinct_grapple_anchor_motion_never_carries_the_wall_attachment() -> void:
	var fixture := await _spawn()
	var position := fixture.player.global_position
	fixture.anchor.position += Vector3.RIGHT * 2.0
	await _ticks(12)
	assert_true(bool(fixture.player.get("is_wall_sticking")))
	assert_almost_eq(fixture.player.global_position.distance_to(position), 0.0, 0.001)
	assert_eq(fixture.terminal_count, 0)
	fixture.wall.set("motion_velocity", Vector3.RIGHT)
	await _ticks(12)
	assert_gt(fixture.player.global_position.x - position.x, 0.15)
	var attachment: GrappleAttachment = fixture.player.call("get_grapple_attachment")
	assert_same(attachment.get_target(), fixture.wall, "successful entry replaces the old validity dependency")
	assert_gt(attachment.anchor_world_position.x, 0.15, "contact-local mode follows the actual supporting wall")

func test_former_moving_grapple_target_no_longer_controls_anchor_or_support() -> void:
	var fixture := await _spawn(true)
	var position := fixture.player.global_position
	fixture.anchor.set("motion_velocity", Vector3.RIGHT)
	await _ticks(18)
	var attachment: GrappleAttachment = fixture.player.call("get_grapple_attachment")
	assert_almost_eq(attachment.anchor_world_position.x, 0.0, 0.001, "former target movement cannot change the replaced anchor")
	assert_almost_eq(fixture.player.global_position.distance_to(position), 0.0, 0.001)
	fixture.wall.set("motion_velocity", Vector3.LEFT)
	await _ticks(18)
	assert_lt(fixture.player.global_position.x, position.x - 0.2)
	assert_lt(attachment.anchor_world_position.x, -0.2)
	assert_true(bool(fixture.player.get("is_wall_sticking")))
	assert_eq(fixture.terminal_count, 0)

func test_forward_only_entry_needs_no_along_wall_alignment_and_missing_forward_cannot_enter() -> void:
	for forward in [false, true]:
		var viewport := SubViewport.new()
		viewport.world_3d = World3D.new()
		get_tree().root.add_child(viewport)
		autofree(viewport)
		var fixture := FIXTURE.instantiate() as WallStickMotionFixture
		viewport.add_child(fixture)
		fixture.input_source.inject_movement_strengths(0.0, 0.0, 1.0 if forward else 0.0, 0.0)
		await _ticks(8)
		assert_eq(bool(fixture.player.get("is_wall_sticking")), forward)
		assert_true(bool(fixture.player.get("is_grappling")))
		assert_eq(fixture.entry_count, 1 if forward else 0)

func test_empty_command_frame_cannot_bypass_forward_hold_policy() -> void:
	var fixture := await _spawn()
	fixture.player.set_physics_process(false)
	var step := int(fixture.player.call("get_motion_step")) + 1
	assert_eq(fixture.motor.begin_motion_frame(step), PlayerMotor.FrameStatus.SUCCESS)
	fixture.player.set("_player_physics_step", step)
	fixture.player.set("_current_command_frame", null)
	fixture.player.get_node(^"MovementHSM/WallStickState").call("_update", 1.0 / float(Engine.physics_ticks_per_second))
	assert_push_error("command frame requested before")
	var result := fixture.motor.resolve_and_commit()
	assert_true(result.success)
	assert_false(result.is_hold_request)
	assert_false(bool(fixture.player.get("is_wall_sticking")))
	assert_eq(fixture.terminal_count, 1)

func test_support_exception_and_platform_configuration_are_transaction_local() -> void:
	var fixture := await _spawn()
	var floor_layers := fixture.player.platform_floor_layers
	var wall_layers := fixture.player.platform_wall_layers
	var on_leave := fixture.player.platform_on_leave
	fixture.wall.set("motion_velocity", Vector3(1.0, 0.0, -1.0))
	await _ticks(12)
	assert_true(fixture.player.get_collision_exceptions().is_empty())
	assert_eq(fixture.player.platform_floor_layers, floor_layers)
	assert_eq(fixture.player.platform_wall_layers, wall_layers)
	assert_eq(fixture.player.platform_on_leave, on_leave)

func test_blocked_carry_detaches_without_snapping_through_an_obstacle() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := await _spawn()
		fixture.add_blocker()
		var initial_y := fixture.player.global_position.y
		fixture.wall.set("motion_velocity", Vector3.UP * 2.0)
		await _ticks(int(rate * 0.5))
		assert_eq(fixture.blocked_count, 1, str(fixture.report()))
		assert_eq(fixture.terminal_count, 1)
		assert_false(bool(fixture.player.get("is_wall_sticking")))
		assert_lte(fixture.player.global_position.y, initial_y + 0.401)
		assert_eq(fixture.overlap_count, 0, str(fixture.report()))
		assert_true(fixture.blocked_overlap_step_ids.has(fixture.detachment_commit.physics_step), "latched blocked detachment pose receives a settled-space follow-up observation")
		assert_eq(fixture.maximum_commits, 1)

func test_support_destruction_disabled_shape_and_teleports_fail_closed() -> void:
	for interruption in ["destroyed", "disabled", "teleport", "shape_replaced"]:
		var fixture := await _spawn()
		match interruption:
			"destroyed":
				fixture.wall.queue_free()
			"disabled":
				(fixture.wall.get_child(0) as CollisionShape3D).disabled = true
			"teleport":
				fixture.wall.position.x += 4.0
			"shape_replaced":
				var replacement := BoxShape3D.new()
				replacement.size = Vector3(16.0, 16.0, 0.4)
				(fixture.wall.get_child(0) as CollisionShape3D).shape = replacement
		await _ticks(3)
		assert_false(bool(fixture.player.get("is_wall_sticking")), interruption)
		assert_eq(fixture.terminal_count, 1, interruption)
		assert_true(fixture.terminal_wall_clear)
		assert_lt(absf(fixture.player.global_position.x), 0.01, "unsafe motion was not followed")

func test_same_shape_motion_may_switch_legacy_world_point_but_not_stick_support() -> void:
	var fixture := await _spawn()
	fixture.wall.set("motion_velocity", Vector3.RIGHT * 20.0)
	# At 120 Hz the 0.167 m motion is below the explicit safety bound; the
	# aggregate point movement is deliberately beyond legacy world continuity.
	Engine.physics_ticks_per_second = 120
	await _ticks(30)
	assert_true(bool(fixture.player.get("is_wall_sticking")), str(fixture.report()))
	assert_eq(fixture.entry_count, 1)
	assert_eq(fixture.terminal_count, 0)
	assert_gt(fixture.player.global_position.x, 4.0)
	assert_eq(fixture.overlap_count, 0)

func _spawn(moving_anchor: bool = false) -> WallStickMotionFixture:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var fixture := FIXTURE.instantiate() as WallStickMotionFixture
	fixture.moving_grapple_anchor = moving_anchor
	viewport.add_child(fixture)
	await _ticks(6)
	assert_true(bool(fixture.player.get("is_wall_sticking")), "fixture must enter through production HSM/contact/motor")
	assert_true(fixture.motor.get_previous_contact_frame().is_value_only())
	assert_not_null(fixture.motor.get_previous_contact_frame().wall_support)
	return fixture

func _ticks(count: int) -> void:
	for _i in range(count):
		await get_tree().physics_frame
	await get_tree().process_frame
