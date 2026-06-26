extends LimboState


func _enter() -> void:
	agent._clear_wall_run()


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_DIED)
		return

	if Input.is_action_just_released("fire_grapple") or not agent.has_valid_grapple():
		agent._clear_grapple()
		agent.dispatch_locomotion_after_grapple_clear()
		return

	var input_dir: Vector2 = agent.get_movement_input()
	agent.apply_default_gravity(delta)

	if Input.is_action_just_pressed("jump") and agent.is_on_floor():
		agent.apply_ground_jump()

	agent._apply_horizontal_movement(input_dir, delta)
	agent._apply_grapple_acceleration(delta)
	if not agent.has_valid_grapple():
		agent.dispatch_locomotion_after_grapple_clear()
		return

	agent.slide_and_check_wall_stick(input_dir)
	agent.update_grapple_feedback()

	if agent.is_wall_sticking:
		get_root().dispatch(agent.EVENT_WALL_STICK_STARTED)
