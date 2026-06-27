extends LimboState

var time_left := 0.0


func _enter() -> void:
	agent.is_attacking = true
	time_left = maxf(agent.get_attack_windup_time(), 0.0)
	agent.stop_horizontal_movement(0.0)


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_ATTACK_CANCELLED)
		return

	agent.stop_horizontal_movement(delta)
	time_left -= delta
	if time_left <= 0.0:
		get_root().dispatch(agent.EVENT_ATTACK_PHASE_FINISHED)
