extends LimboState


func _enter() -> void:
	agent._clear_wall_run()


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		return

	if not agent.is_on_floor():
		get_root().dispatch(agent.EVENT_LEFT_GROUND)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.GRAPPLE) and agent.try_start_grapple():
		get_root().dispatch(agent.EVENT_GRAPPLE_STARTED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		agent.apply_ground_jump()
		get_root().dispatch(agent.EVENT_JUMPED)
		return

	var input_dir: Vector2 = command_frame.movement_axis
	agent._apply_horizontal_movement(input_dir, delta)
	agent.move_and_slide()
	agent.update_grapple_feedback()

	if not agent.is_on_floor():
		get_root().dispatch(agent.EVENT_LEFT_GROUND)
