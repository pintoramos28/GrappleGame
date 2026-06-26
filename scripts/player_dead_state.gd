extends LimboState


func _enter() -> void:
	agent._cancel_attack()
	agent._clear_grapple()
	agent._clear_wall_run()
	agent._clear_wall_stick()


func _update(delta: float) -> void:
	agent._apply_dead_physics(delta)
