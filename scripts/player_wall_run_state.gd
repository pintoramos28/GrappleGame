extends LimboState


func _update(_delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_WALL_RUN)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_RUN)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_RUN)
		return

	if agent.has_ground_contact():
		agent._clear_wall_run()
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_RUN)
		agent.dispatch_locomotion_event(agent.EVENT_LANDED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.GRAPPLE) and agent.try_start_grapple():
		agent._clear_wall_run()
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_RUN)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_STARTED)
		return

	if (
		command_frame.was_pressed(PlayerCommandFrame.Action.JUMP)
		and agent.has_valid_wall_jump_relationship(reference_velocity)
	):
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_RUN)
		agent.submit_wall_jump(reference_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_WALL_RUN_FINISHED)
		return

	var input_dir: Vector2 = command_frame.movement_axis
	agent._update_wall_run_state(input_dir, reference_velocity)
	if not agent.is_wall_running:
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_RUN)
		agent.dispatch_locomotion_event(agent.EVENT_WALL_RUN_FINISHED)
		return

	agent.submit_wall_run_base()
	agent.submit_gravity_policy()
	agent.submit_wall_run_constraint()


func _exit() -> void:
	agent._clear_wall_run()
