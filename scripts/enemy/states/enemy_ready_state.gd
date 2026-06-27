extends LimboState


func _enter() -> void:
	agent.is_attacking = false
	if agent.attack_hitbox:
		agent.attack_hitbox.cancel()
