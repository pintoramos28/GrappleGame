extends LimboState


func _update(_delta: float) -> void:
	var motion_velocity: Vector3 = agent.get_motion_start_velocity()
	if agent.is_dead:
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_STICK, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_wall_stick_hold(agent.LOCOMOTION_WALL_STICK, agent.wall_stick_position)
		return

	if not command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE) or not agent.has_valid_grapple():
		agent._clear_grapple()
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_STICK, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		motion_velocity = agent._wall_stick_jump()
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_STICK, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_WALL_STICK_JUMPED)
		return

	agent.submit_wall_stick_hold(agent.LOCOMOTION_WALL_STICK, agent.wall_stick_position)
