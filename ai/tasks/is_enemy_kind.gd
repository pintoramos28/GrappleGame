@tool
extends BTCondition

@export var enemy_definition_var: StringName = &"enemy_definition"
@export_enum("Melee", "Ranged") var enemy_kind: int = EnemyDefinition.EnemyKind.MELEE


func _generate_name() -> String:
	var kind_name := "Melee" if enemy_kind == EnemyDefinition.EnemyKind.MELEE else "Ranged"
	return "IsEnemyKind %s" % [kind_name]


func _tick(_delta: float) -> Status:
	var definition := blackboard.get_var(enemy_definition_var, null) as EnemyDefinition
	if definition == null and agent != null:
		definition = agent.get("enemy_definition") as EnemyDefinition

	if definition == null:
		return FAILURE

	return SUCCESS if definition.enemy_kind == enemy_kind else FAILURE
