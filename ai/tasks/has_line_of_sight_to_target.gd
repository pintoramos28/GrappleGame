@tool
extends BTCondition

@export var has_line_of_sight_var: StringName = &"has_line_of_sight"


func _generate_name() -> String:
	return "HasLineOfSightToTarget"


func _tick(_delta: float) -> Status:
	return SUCCESS if bool(blackboard.get_var(has_line_of_sight_var, false)) else FAILURE
