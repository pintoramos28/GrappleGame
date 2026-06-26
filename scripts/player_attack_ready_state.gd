extends LimboState


func _enter() -> void:
	if agent.attack_hitbox:
		agent.attack_hitbox.cancel()


func _update(_delta: float) -> void:
	if agent.is_dead:
		return

	if Input.is_action_just_pressed("attack") and agent.attack_hitbox:
		get_root().dispatch(agent.EVENT_ATTACK_STARTED)
