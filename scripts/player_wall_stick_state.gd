extends LimboState


func _update(_delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		return

	if not command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE) or not agent.has_valid_grapple():
		agent._clear_grapple()
		get_root().dispatch(agent.EVENT_GRAPPLE_RELEASED)
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		agent._wall_stick_jump()
		agent.move_and_slide()
		agent.update_grapple_feedback()
		get_root().dispatch(agent.EVENT_WALL_STICK_JUMPED)
		return

	agent._apply_wall_stick()
	agent.update_grapple_feedback()
