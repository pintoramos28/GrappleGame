@tool
extends BTAction


func _generate_name() -> String:
	return "RequestEnemyAttack"


func _tick(_delta: float) -> Status:
	if not agent.has_method("request_attack"):
		return FAILURE

	return SUCCESS if agent.request_attack() or bool(agent.get("is_attacking")) else FAILURE
