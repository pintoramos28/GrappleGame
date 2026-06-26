extends LimboState


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_DIED)
		return

	if agent.is_on_floor():
		get_root().dispatch(agent.EVENT_LANDED)
		return

	if Input.is_action_just_pressed("fire_grapple") and agent.try_start_grapple():
		get_root().dispatch(agent.EVENT_GRAPPLE_STARTED)
		return

	var input_dir: Vector2 = agent.get_movement_input()
	agent._update_wall_run_state(input_dir)
	if agent.is_wall_running:
		get_root().dispatch(agent.EVENT_WALL_RUN_STARTED)
		return

	agent.apply_default_gravity(delta)
	agent._apply_horizontal_movement(input_dir, delta)
	agent.move_and_slide()
	agent.update_grapple_feedback()

	if agent.is_on_floor():
		get_root().dispatch(agent.EVENT_LANDED)
