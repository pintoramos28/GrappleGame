extends LimboState


func _enter() -> void:
	agent._clear_wall_run()


func _update(delta: float) -> void:
	var motion_velocity: Vector3 = agent.get_motion_start_velocity()
	if agent.is_dead:
		agent.submit_motion_velocity(agent.LOCOMOTION_GRAPPLING, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_motion_velocity(agent.LOCOMOTION_GRAPPLING, motion_velocity)
		return

	if command_frame.was_released(PlayerCommandFrame.Action.GRAPPLE) or not agent.has_valid_grapple():
		agent._clear_grapple()
		agent.submit_motion_velocity(agent.LOCOMOTION_GRAPPLING, motion_velocity)
		agent.dispatch_locomotion_after_grapple_clear()
		return

	var input_dir: Vector2 = command_frame.movement_axis
	motion_velocity = agent.apply_default_gravity(delta, motion_velocity)

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP) and agent.is_on_floor():
		motion_velocity = agent.apply_ground_jump(motion_velocity)

	motion_velocity = agent._apply_horizontal_movement(input_dir, delta, motion_velocity)
	motion_velocity = agent._apply_grapple_acceleration(delta, motion_velocity)
	if not agent.has_valid_grapple():
		agent.submit_motion_velocity(agent.LOCOMOTION_GRAPPLING, motion_velocity)
		agent.dispatch_locomotion_after_grapple_clear()
		return

	agent.submit_motion_velocity(agent.LOCOMOTION_GRAPPLING, motion_velocity)
