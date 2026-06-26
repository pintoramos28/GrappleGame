@tool
extends BTAction

@export var target_var: StringName = &"target"
@export var horizontal_only := true


func _generate_name() -> String:
	return "FaceTarget3D %s" % [LimboUtility.decorate_var(target_var)]


func _tick(_delta: float) -> Status:
	var target := blackboard.get_var(target_var, null) as Node3D
	if not is_instance_valid(target):
		return FAILURE

	if not agent is Node3D:
		return FAILURE

	var agent_3d := agent as Node3D
	var look_position := target.global_position
	if horizontal_only:
		look_position.y = agent_3d.global_position.y

	if agent_3d.global_position.distance_squared_to(look_position) > 0.01:
		agent_3d.look_at(look_position, Vector3.UP)

	return SUCCESS
