extends LimboState


func _update(_delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_AIRBORNE)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_AIRBORNE)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_base_passthrough(agent.LOCOMOTION_AIRBORNE)
		return

	if agent.has_ground_contact():
		agent.submit_base_passthrough(agent.LOCOMOTION_AIRBORNE)
		agent.dispatch_locomotion_event(agent.EVENT_LANDED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.GRAPPLE) and agent.try_start_grapple():
		agent.submit_base_passthrough(agent.LOCOMOTION_AIRBORNE)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_STARTED)
		return

	var input_dir: Vector2 = command_frame.movement_axis
	agent._update_wall_run_state(input_dir, reference_velocity)
	if agent.is_wall_running:
		agent.submit_base_passthrough(agent.LOCOMOTION_AIRBORNE)
		agent.dispatch_locomotion_event(agent.EVENT_WALL_RUN_STARTED)
		return

	agent.submit_base_policy(agent.LOCOMOTION_AIRBORNE, input_dir)
	agent.submit_gravity_policy()
