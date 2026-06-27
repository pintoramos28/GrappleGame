@tool
extends BTCondition

@export var target_var: StringName = &"target"
@export var enemy_definition_var: StringName = &"enemy_definition"


func _generate_name() -> String:
	return "IsTargetTooFar %s" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var, null) as Node3D
	var definition := blackboard.get_var(enemy_definition_var, null) as EnemyDefinition
	if not is_instance_valid(target) or definition == null:
		return FAILURE
	if not agent.has_method("get_distance_to_target"):
		return FAILURE

	return SUCCESS if agent.get_distance_to_target(target) > definition.ranged_max_distance else FAILURE
