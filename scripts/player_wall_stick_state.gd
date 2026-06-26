extends LimboState


func _update(_delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_DIED)
		return

	if not Input.is_action_pressed("fire_grapple") or not agent.has_valid_grapple():
		agent._clear_grapple()
		get_root().dispatch(agent.EVENT_GRAPPLE_RELEASED)
		return

	if Input.is_action_just_pressed("jump"):
		agent._wall_stick_jump()
		agent.move_and_slide()
		agent.update_grapple_feedback()
		get_root().dispatch(agent.EVENT_WALL_STICK_JUMPED)
		return

	agent._apply_wall_stick()
	agent.update_grapple_feedback()
