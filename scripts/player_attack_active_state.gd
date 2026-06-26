extends LimboState

var time_left := 0.0


func _enter() -> void:
	time_left = maxf(agent.attack_active_time, 0.0)
	if agent.attack_hitbox:
		agent.attack_hitbox.activate()


func _update(delta: float) -> void:
	if agent.is_dead:
		get_root().dispatch(agent.EVENT_ATTACK_CANCELLED)
		return

	time_left -= delta
	if time_left <= 0.0:
		get_root().dispatch(agent.EVENT_ATTACK_PHASE_FINISHED)


func _exit() -> void:
	if agent.attack_hitbox:
		agent.attack_hitbox.deactivate()
