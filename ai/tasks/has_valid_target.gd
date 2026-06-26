@tool
extends BTCondition

@export var target_var: StringName = &"target"


func _generate_name() -> String:
	return "HasValidTarget %s" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var, null) as Node3D
	if is_instance_valid(target):
		return SUCCESS

	return FAILURE
