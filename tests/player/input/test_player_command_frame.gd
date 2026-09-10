extends GutTest


func test_frame_exposes_immutable_step_movement_view_aim_and_action_facts() -> void:
	var pressed := 1 << PlayerCommandFrame.Action.JUMP
	var held := 1 << PlayerCommandFrame.Action.GRAPPLE
	var released := 1 << PlayerCommandFrame.Action.ATTACK
	var frame := PlayerCommandFrame.new(
		7,
		Vector2(1.0, -1.0),
		0.25,
		-0.4,
		Vector3(0.0, 0.0, -2.0),
		pressed,
		held,
		released
	)

	assert_eq(frame.physics_step, 7)
	assert_almost_eq(frame.movement_axis.length(), 1.0, 0.00001)
	assert_true(frame.movement_axis.x > 0.0)
	assert_true(frame.movement_axis.y < 0.0)
	assert_almost_eq(frame.view_yaw_radians, 0.25, 0.00001)
	assert_almost_eq(frame.view_pitch_radians, -0.4, 0.00001)
	assert_almost_eq(frame.aim_world_direction.length(), 1.0, 0.00001)
	assert_true(frame.was_pressed(PlayerCommandFrame.Action.JUMP))
	assert_true(frame.is_held(PlayerCommandFrame.Action.GRAPPLE))
	assert_true(frame.was_released(PlayerCommandFrame.Action.ATTACK))
	assert_false(frame.was_pressed(PlayerCommandFrame.Action.ATTACK))
	assert_false(frame.is_held(PlayerCommandFrame.Action.JUMP))
	assert_false(frame.was_released(PlayerCommandFrame.Action.GRAPPLE))


func test_neutral_frame_has_zero_axis_and_no_action_edges() -> void:
	var frame := PlayerCommandFrame.new(
		1,
		Vector2.ZERO,
		0.0,
		0.0,
		Vector3(0.0, 0.0, -1.0)
	)

	assert_eq(frame.movement_axis, Vector2.ZERO)
	assert_eq(frame.aim_world_direction, Vector3(0.0, 0.0, -1.0))
	for action in [
		PlayerCommandFrame.Action.JUMP,
		PlayerCommandFrame.Action.GRAPPLE,
		PlayerCommandFrame.Action.ATTACK,
	]:
		assert_false(frame.was_pressed(action))
		assert_false(frame.is_held(action))
		assert_false(frame.was_released(action))


func test_source_returns_one_cached_instance_per_step_and_distinct_instances_between_steps() -> void:
	var source := _new_source()
	var first := source.capture_command_frame(1)
	var first_again := source.capture_command_frame(1)
	var second := source.capture_command_frame(2)

	assert_same(first_again, first)
	assert_not_same(second, first)
	assert_eq(first.physics_step, 1)
	assert_eq(second.physics_step, 2)


func _new_source() -> PlayerInputSource:
	var source: PlayerInputSource = autofree(PlayerInputSource.new())
	var player: Node3D = autofree(Node3D.new())
	var pivot: Node3D = autofree(Node3D.new())
	source.enable_test_input_seam()
	var result := source.initialize(player, pivot)
	assert_eq(result, PlayerInputSource.InitializationStatus.SUCCESS)
	return source
