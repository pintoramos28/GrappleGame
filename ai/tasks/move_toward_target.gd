@tool
extends BTAction

@export var target_var: StringName = &"target"


func _generate_name() -> String:
	return "MoveTowardTarget %s" % [LimboUtility.decorate_var(target_var)]


func _tick(delta: float) -> Status:
	var target := blackboard.get_var(target_var, null) as Node3D
	if not is_instance_valid(target):
		return FAILURE
	if not agent.has_method("move_toward_target"):
		return FAILURE

	agent.move_toward_target(target, delta)
	return SUCCESS
