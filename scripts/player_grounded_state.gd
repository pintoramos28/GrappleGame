extends LimboState


func _enter() -> void:
	agent._clear_wall_run()


func _update(_delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_GROUNDED)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_GROUNDED)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_base_passthrough(agent.LOCOMOTION_GROUNDED)
		return

	if not agent.has_ground_contact():
		agent.submit_base_passthrough(agent.LOCOMOTION_GROUNDED)
		agent.dispatch_locomotion_event(agent.EVENT_LEFT_GROUND)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.GRAPPLE) and agent.try_start_grapple():
		agent.submit_base_passthrough(agent.LOCOMOTION_GROUNDED)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_STARTED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		agent.submit_base_passthrough(agent.LOCOMOTION_GROUNDED)
		agent.submit_ground_jump(reference_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_JUMPED)
		return

	agent.submit_base_policy(agent.LOCOMOTION_GROUNDED, command_frame.movement_axis)
