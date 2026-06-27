@tool
extends BTCondition

@export var target_var: StringName = &"target"
@export var range_buffer := 0.1


func _generate_name() -> String:
	return "IsTargetInAttackRange %s" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var, null) as Node3D
	if not is_instance_valid(target):
		return FAILURE

	if not agent.has_method("get_distance_to_target") or not agent.has_method("get_attack_range"):
		return FAILURE

	var distance := float(agent.get_distance_to_target(target))
	var attack_range := float(agent.get_attack_range())
	return SUCCESS if distance <= attack_range + range_buffer else FAILURE
