@tool
extends BTAction


func _generate_name() -> String:
	return "StopHorizontalMovement"


func _tick(_delta: float) -> Status:
	if not agent is CharacterBody3D:
		return FAILURE

	var body := agent as CharacterBody3D
	body.velocity.x = 0.0
	body.velocity.z = 0.0
	return SUCCESS
