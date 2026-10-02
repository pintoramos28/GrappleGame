extends GutTest


func test_movement_preserves_cardinal_opposite_and_circular_diagonal_semantics() -> void:
	var source := _new_source()

	source.inject_movement_strengths(0.0, 1.0, 0.0, 0.0)
	var right := source.capture_command_frame(1)
	assert_eq(right.movement_axis, Vector2.RIGHT)

	source.inject_movement_strengths(1.0, 1.0, 0.0, 0.0)
	var cancelled := source.capture_command_frame(2)
	assert_eq(cancelled.movement_axis, Vector2.ZERO)

	source.inject_movement_strengths(0.0, 1.0, 1.0, 0.0)
	var diagonal := source.capture_command_frame(3)
	assert_almost_eq(diagonal.movement_axis.length(), 1.0, 0.00001)
	assert_true(diagonal.movement_axis.x > 0.0)
	assert_true(diagonal.movement_axis.y < 0.0)

	source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	var released := source.capture_command_frame(4)
	assert_eq(released.movement_axis, Vector2.ZERO)


func test_action_progression_is_press_then_held_then_release_then_neutral() -> void:
	var source := _new_source()
	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
	var pressed := source.capture_command_frame(1)
	assert_true(pressed.was_pressed(PlayerCommandFrame.Action.JUMP))
	assert_true(pressed.is_held(PlayerCommandFrame.Action.JUMP))
	assert_false(pressed.was_released(PlayerCommandFrame.Action.JUMP))

	var held := source.capture_command_frame(2)
	assert_false(held.was_pressed(PlayerCommandFrame.Action.JUMP))
	assert_true(held.is_held(PlayerCommandFrame.Action.JUMP))
	assert_false(held.was_released(PlayerCommandFrame.Action.JUMP))

	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
	var released := source.capture_command_frame(3)
	assert_false(released.was_pressed(PlayerCommandFrame.Action.JUMP))
	assert_false(released.is_held(PlayerCommandFrame.Action.JUMP))
	assert_true(released.was_released(PlayerCommandFrame.Action.JUMP))

	var neutral := source.capture_command_frame(4)
	assert_false(neutral.was_pressed(PlayerCommandFrame.Action.JUMP))
	assert_false(neutral.is_held(PlayerCommandFrame.Action.JUMP))
	assert_false(neutral.was_released(PlayerCommandFrame.Action.JUMP))


func test_literal_forward_survives_opposing_movement_and_clears_on_focus_loss() -> void:
	var source := _new_source()
	source.inject_movement_strengths(0.0, 0.0, 1.0, 1.0)
	var opposing := source.capture_command_frame(1)
	assert_eq(opposing.movement_axis, Vector2.ZERO)
	assert_true(opposing.move_forward_held)
	source.notify_focus_lost()
	assert_false(source.capture_command_frame(2).move_forward_held)
	assert_true(opposing.move_forward_held, "published facts are immutable")
	source.notify_focus_restored()
	assert_false(source.capture_command_frame(3).move_forward_held)
	source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
	assert_eq(source.capture_command_frame(4).movement_axis, Vector2.ZERO, "opposing keys must not prematurely rearm")
	source.inject_movement_strengths(1.0, 1.0, 0.0, 0.0)
	assert_eq(source.capture_command_frame(5).movement_axis, Vector2.ZERO)
	source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	source.capture_command_frame(6)
	source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
	assert_true(source.capture_command_frame(7).move_forward_held)
	assert_eq(source.capture_command_frame(7).movement_axis, Vector2.UP)
	source.inject_movement_strengths(0.0, 0.0, 0.0, 1.0)
	assert_false(source.capture_command_frame(8).move_forward_held)


func test_hardware_forward_fact_does_not_depend_on_net_axis_and_rearms_all_keys() -> void:
	var source := _new_source()
	source.set("_test_input_seam_enabled", false)
	Input.action_press(&"move_forward")
	Input.action_press(&"move_back")
	var opposing := source.capture_command_frame(1)
	assert_true(opposing.move_forward_held)
	assert_eq(opposing.movement_axis, Vector2.ZERO)
	source.notify_focus_lost()
	source.notify_focus_restored()
	assert_false(source.capture_command_frame(2).move_forward_held)
	Input.action_release(&"move_back")
	assert_eq(source.capture_command_frame(3).movement_axis, Vector2.ZERO)
	Input.action_release(&"move_forward")
	source.capture_command_frame(4)
	Input.action_press(&"move_forward")
	assert_true(source.capture_command_frame(5).move_forward_held)
	Input.action_release(&"move_forward")


func test_short_tap_keeps_both_edges_in_one_frame() -> void:
	var source := _new_source()
	source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	var tap := source.capture_command_frame(1)

	assert_true(tap.was_pressed(PlayerCommandFrame.Action.GRAPPLE))
	assert_false(tap.is_held(PlayerCommandFrame.Action.GRAPPLE))
	assert_true(tap.was_released(PlayerCommandFrame.Action.GRAPPLE))
	var next := source.capture_command_frame(2)
	assert_false(next.was_pressed(PlayerCommandFrame.Action.GRAPPLE))
	assert_false(next.was_released(PlayerCommandFrame.Action.GRAPPLE))


func test_multiple_bindings_do_not_release_attack_until_all_bindings_are_up() -> void:
	var source := _new_source()
	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 0, true)
	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 1, true)
	var pressed := source.capture_command_frame(1)
	assert_true(pressed.was_pressed(PlayerCommandFrame.Action.ATTACK))

	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 0, false)
	var still_held := source.capture_command_frame(2)
	assert_true(still_held.is_held(PlayerCommandFrame.Action.ATTACK))
	assert_false(still_held.was_released(PlayerCommandFrame.Action.ATTACK))

	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 1, false)
	var released := source.capture_command_frame(3)
	assert_false(released.is_held(PlayerCommandFrame.Action.ATTACK))
	assert_true(released.was_released(PlayerCommandFrame.Action.ATTACK))

	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 0, true, true)
	var ignored_echo := source.capture_command_frame(4)
	assert_false(ignored_echo.was_pressed(PlayerCommandFrame.Action.ATTACK))


func test_focus_loss_clears_edges_motion_and_requires_neutral_rearm() -> void:
	var source := _new_source()
	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 0, true)
	source.inject_mouse_motion(Vector2(12.0, -4.0))
	source.notify_focus_lost()
	var unfocused := source.capture_command_frame(1)
	assert_eq(unfocused.movement_axis, Vector2.ZERO)
	assert_false(unfocused.is_held(PlayerCommandFrame.Action.ATTACK))
	assert_false(unfocused.was_pressed(PlayerCommandFrame.Action.ATTACK))
	assert_false(unfocused.was_released(PlayerCommandFrame.Action.ATTACK))

	source.notify_focus_restored()
	var still_held := source.capture_command_frame(2)
	assert_false(still_held.is_held(PlayerCommandFrame.Action.ATTACK))
	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 0, false)
	var rearmed := source.capture_command_frame(3)
	assert_false(rearmed.was_pressed(PlayerCommandFrame.Action.ATTACK))
	assert_false(rearmed.was_released(PlayerCommandFrame.Action.ATTACK))

	source.inject_action_binding(PlayerCommandFrame.Action.ATTACK, 0, true)
	var fresh_press := source.capture_command_frame(4)
	assert_true(fresh_press.was_pressed(PlayerCommandFrame.Action.ATTACK))


func test_movement_and_each_action_stay_neutral_until_focus_rearm_is_complete() -> void:
	var source := _new_source()
	source.inject_movement_strengths(0.0, 1.0, 0.0, 0.0)
	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
	source.notify_focus_lost()
	source.notify_focus_restored()

	var blocked := source.capture_command_frame(1)
	assert_eq(blocked.movement_axis, Vector2.ZERO)
	assert_false(blocked.is_held(PlayerCommandFrame.Action.JUMP))

	source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
	var neutral_observation := source.capture_command_frame(2)
	assert_eq(neutral_observation.movement_axis, Vector2.ZERO)
	assert_false(neutral_observation.was_released(PlayerCommandFrame.Action.JUMP))

	source.inject_movement_strengths(0.0, 1.0, 0.0, 0.0)
	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
	var fresh := source.capture_command_frame(3)
	assert_eq(fresh.movement_axis, Vector2.RIGHT)
	assert_true(fresh.was_pressed(PlayerCommandFrame.Action.JUMP))


func test_mouse_motion_is_applied_once_with_sensitivity_and_pitch_clamp() -> void:
	var source := _new_source(0.0, 0.0, 0.1, 0.2, -0.5, 0.5)
	source.set_test_mouse_captured(true)
	var motion := InputEventMouseMotion.new()
	motion.screen_relative = Vector2(2.0, -10.0)
	source._input(motion)
	var first := source.capture_command_frame(1)
	assert_almost_eq(first.view_yaw_radians, -0.2, 0.00001)
	assert_almost_eq(first.view_pitch_radians, 0.5, 0.00001)
	assert_almost_eq(first.aim_world_direction.length(), 1.0, 0.00001)

	var second := source.capture_command_frame(2)
	assert_almost_eq(second.view_yaw_radians, first.view_yaw_radians, 0.00001)
	assert_almost_eq(second.view_pitch_radians, first.view_pitch_radians, 0.00001)


func test_pan_motion_uses_trackpad_sensitivity_once_without_mouse_scaling() -> void:
	var source := _new_source(0.0, 0.0, 0.1, 0.2, -2.0, 2.0)
	source.set_test_mouse_captured(true)
	var pan := InputEventPanGesture.new()
	pan.delta = Vector2(1.0, 2.0)
	source._input(pan)
	var frame := source.capture_command_frame(1)
	assert_almost_eq(frame.view_yaw_radians, -0.2, 0.00001)
	assert_almost_eq(frame.view_pitch_radians, -0.4, 0.00001)


func test_numbered_sequences_have_exactly_one_distinct_frame_at_60_and_120_steps() -> void:
	var source := _new_source()
	var previous: PlayerCommandFrame = null
	for step in range(1, 61):
		var frame := source.capture_command_frame(step)
		assert_eq(frame.physics_step, step)
		if previous != null:
			assert_not_same(frame, previous)
		assert_same(source.capture_command_frame(step), frame)
		previous = frame

	var high_rate_source := _new_source()
	previous = null
	for step in range(1, 121):
		var frame := high_rate_source.capture_command_frame(step)
		assert_eq(frame.physics_step, step)
		if previous != null:
			assert_not_same(frame, previous)
		assert_same(high_rate_source.capture_command_frame(step), frame)
		previous = frame


func test_disabled_source_clears_future_input_without_mutating_committed_frame() -> void:
	var source := _new_source()
	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
	var committed := source.capture_command_frame(1)
	source.set_enabled(false)
	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
	var gated := source.capture_command_frame(2)

	assert_true(committed.is_held(PlayerCommandFrame.Action.JUMP))
	assert_false(gated.is_held(PlayerCommandFrame.Action.JUMP))
	assert_false(gated.was_pressed(PlayerCommandFrame.Action.JUMP))
	assert_false(gated.was_released(PlayerCommandFrame.Action.JUMP))


func test_non_monotonic_step_is_rejected_without_replacing_cached_frame() -> void:
	var source := _new_source()
	var committed := source.capture_command_frame(2)
	var rejected := source.capture_command_frame(1)
	assert_push_error("non-monotonic")

	assert_null(rejected)
	assert_same(source.capture_command_frame(2), committed)


func test_visible_recapture_click_is_consumed_before_gameplay_action() -> void:
	var source := _new_source()
	source.set_test_mouse_captured(false)
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	var recapture := InputEventMouseButton.new()
	recapture.button_index = MOUSE_BUTTON_LEFT
	recapture.pressed = true
	source._input(recapture)
	var application_frame := source.capture_command_frame(1)
	assert_false(application_frame.was_pressed(PlayerCommandFrame.Action.ATTACK))

	var gameplay_click := InputEventMouseButton.new()
	gameplay_click.button_index = MOUSE_BUTTON_LEFT
	gameplay_click.pressed = true
	source._input(gameplay_click)
	var gameplay_frame := source.capture_command_frame(2)
	assert_true(gameplay_frame.was_pressed(PlayerCommandFrame.Action.ATTACK))
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func test_key_echo_does_not_create_a_press_edge() -> void:
	var source := _new_source()
	var echo := InputEventKey.new()
	echo.keycode = KEY_SPACE
	echo.pressed = true
	echo.echo = true
	source._input(echo)
	var frame := source.capture_command_frame(1)
	assert_false(frame.was_pressed(PlayerCommandFrame.Action.JUMP))


func test_vertical_inversion_is_applied_once_at_the_input_boundary() -> void:
	var source := _new_source(0.0, 0.0, 0.1, 0.03, -2.0, 2.0)
	source.invert_mouse_y = true
	source.inject_mouse_motion(Vector2(0.0, 1.0))
	var frame := source.capture_command_frame(1)
	assert_almost_eq(frame.view_pitch_radians, 0.1, 0.00001)


func test_invalid_required_action_initialization_is_explicit_and_inactive() -> void:
	var source: PlayerInputSource = autofree(PlayerInputSource.new())
	var player: Node3D = autofree(Node3D.new())
	var pivot: Node3D = autofree(Node3D.new())
	var result := source.initialize(player, pivot, PackedStringArray(["missing_story_1_2_action"]))
	assert_push_error("missing_story_1_2_action")

	assert_eq(result, PlayerInputSource.InitializationStatus.MISSING_ACTION)
	assert_false(source.is_initialized())
	assert_string_contains(source.initialization_error, "missing_story_1_2_action")


func test_missing_node_dependency_is_explicit_and_inactive() -> void:
	var source: PlayerInputSource = autofree(PlayerInputSource.new())
	var pivot: Node3D = autofree(Node3D.new())
	var result := source.initialize(null, pivot)

	assert_push_error("valid player body and camera pivot")
	assert_eq(result, PlayerInputSource.InitializationStatus.MISSING_DEPENDENCY)
	assert_false(source.is_initialized())


func _new_source(
	yaw: float = 0.0,
	pitch: float = 0.0,
	mouse_sensitivity: float = 0.003,
	trackpad_sensitivity: float = 0.03,
	pitch_min: float = -0.785398,
	pitch_max: float = 0.785398
) -> PlayerInputSource:
	var source: PlayerInputSource = autofree(PlayerInputSource.new())
	var player: Node3D = autofree(Node3D.new())
	var pivot: Node3D = autofree(Node3D.new())
	player.rotation.y = yaw
	pivot.rotation.x = pitch
	source.enable_test_input_seam()
	source.mouse_sensitivity = mouse_sensitivity
	source.trackpad_pan_sensitivity = trackpad_sensitivity
	source.pitch_min_radians = pitch_min
	source.pitch_max_radians = pitch_max
	var result := source.initialize(player, pivot)
	assert_eq(result, PlayerInputSource.InitializationStatus.SUCCESS)
	return source
