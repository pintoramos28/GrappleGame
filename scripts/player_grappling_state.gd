extends LimboState


func _enter() -> void:
	agent._clear_wall_run()


func _update(delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_GRAPPLING)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		return

	if command_frame.was_released(PlayerCommandFrame.Action.GRAPPLE) or not agent.has_valid_grapple():
		agent._clear_grapple()
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_after_grapple_clear()
		return

	var input_dir: Vector2 = command_frame.movement_axis
	agent.submit_base_policy(agent.LOCOMOTION_GRAPPLING, input_dir)
	agent.submit_gravity_policy()
	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP) and agent.is_on_floor():
		agent.submit_ground_jump(reference_velocity)
	agent.submit_grapple_pull(delta)
	if not agent.has_valid_grapple():
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_after_grapple_clear()
		return
	agent.submit_grapple_speed_cap()
