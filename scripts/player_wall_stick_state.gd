extends LimboState


func _update(_delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_WALL_STICK)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_STICK)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_wall_stick_hold()
		return

	if not command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE) or not agent.has_valid_grapple():
		agent._clear_grapple()
		agent.submit_wall_stick_release(reference_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_STICK)
		agent.submit_wall_stick_jump(reference_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_WALL_STICK_JUMPED)
		return

	agent.submit_wall_stick_hold()
