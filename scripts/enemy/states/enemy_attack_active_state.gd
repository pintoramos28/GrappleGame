extends LimboState

var time_left := 0.0


func _enter() -> void:
	time_left = maxf(agent.get_attack_active_time(), 0.0)
	agent.perform_attack_active_phase(time_left)


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_ATTACK_CANCELLED)
		return

	agent.stop_horizontal_movement(delta)
	time_left -= delta
	if time_left <= 0.0:
		get_root().dispatch(agent.EVENT_ATTACK_PHASE_FINISHED)


func _exit() -> void:
	if agent.attack_hitbox:
		agent.attack_hitbox.deactivate()
