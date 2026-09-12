extends LimboState


func _update(delta: float) -> void:
	var motion_velocity: Vector3 = agent.get_motion_start_velocity()
	if agent.is_dead:
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_RUN, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_RUN, motion_velocity)
		return

	if agent.is_on_floor():
		agent._clear_wall_run()
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_RUN, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_LANDED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.GRAPPLE) and agent.try_start_grapple():
		agent._clear_wall_run()
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_RUN, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_STARTED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		motion_velocity = agent._wall_jump(motion_velocity)
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_RUN, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_WALL_RUN_FINISHED)
		return

	var input_dir: Vector2 = command_frame.movement_axis
	agent._update_wall_run_state(input_dir, motion_velocity)
	if not agent.is_wall_running:
		agent.submit_motion_velocity(agent.LOCOMOTION_WALL_RUN, motion_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_WALL_RUN_FINISHED)
		return

	motion_velocity = agent.apply_default_gravity(delta, motion_velocity)
	motion_velocity = agent._apply_wall_run_movement(delta, motion_velocity)
	agent.submit_motion_velocity(agent.LOCOMOTION_WALL_RUN, motion_velocity)


func _exit() -> void:
	agent._clear_wall_run()
