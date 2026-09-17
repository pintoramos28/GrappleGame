extends LimboState


func _enter() -> void:
	agent._cancel_attack()
	agent._clear_grapple()
	agent._clear_wall_run()
	agent._clear_wall_stick()


func _update(_delta: float) -> void:
	agent.submit_terminal_policy()
	agent.submit_state_policy(agent.LOCOMOTION_DEAD)
	agent.submit_dead_motion()
