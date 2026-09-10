extends LimboState


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		return

	if agent.is_on_floor():
		agent._clear_wall_run()
		get_root().dispatch(agent.EVENT_LANDED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.GRAPPLE) and agent.try_start_grapple():
		agent._clear_wall_run()
		get_root().dispatch(agent.EVENT_GRAPPLE_STARTED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		agent._wall_jump()
		agent.move_and_slide()
		agent.update_grapple_feedback()
		get_root().dispatch(agent.EVENT_WALL_RUN_FINISHED)
		return

	var input_dir: Vector2 = command_frame.movement_axis
	agent._update_wall_run_state(input_dir)
	if not agent.is_wall_running:
		get_root().dispatch(agent.EVENT_WALL_RUN_FINISHED)
		return

	agent.apply_default_gravity(delta)
	agent._apply_wall_run_movement(delta)
	agent.move_and_slide()
	agent.update_grapple_feedback()

	if agent.is_on_floor():
		agent._clear_wall_run()
		get_root().dispatch(agent.EVENT_LANDED)


func _exit() -> void:
	agent._clear_wall_run()
