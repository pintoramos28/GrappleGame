extends LimboState

var time_left := 0.0


func _enter() -> void:
	time_left = maxf(agent.attack_cooldown_time - agent.attack_windup_time - agent.attack_active_time, 0.0)


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_ATTACK_CANCELLED)
		return

	time_left -= delta
	if time_left <= 0.0:
		get_root().dispatch(agent.EVENT_ATTACK_PHASE_FINISHED)
