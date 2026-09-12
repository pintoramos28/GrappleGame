extends LimboState


func _enter() -> void:
	agent._cancel_attack()
	agent._clear_grapple()
	agent._clear_wall_run()
	agent._clear_wall_stick()


func _update(delta: float) -> void:
	var motion_velocity: Vector3 = agent.calculate_dead_motion(delta)
	agent.submit_motion_velocity(agent.LOCOMOTION_DEAD, motion_velocity)
