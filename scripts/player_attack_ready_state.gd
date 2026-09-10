extends LimboState


func _enter() -> void:
	if agent.attack_hitbox:
		agent.attack_hitbox.cancel()


func _update(_delta: float) -> void:
	if agent.is_dead:
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		return

	if command_frame.was_pressed(PlayerCommandFrame.Action.ATTACK) and agent.attack_hitbox:
		get_root().dispatch(agent.EVENT_ATTACK_STARTED)
