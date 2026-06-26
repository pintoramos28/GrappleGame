@tool
extends BTAction

@export var attack_hitbox_var: StringName = &"attack_hitbox"
@export var attack_active_time_var: StringName = &"attack_active_time"


func _generate_name() -> String:
	return "ActivateAttackHitbox %s" % [LimboUtility.decorate_var(attack_hitbox_var)]


func _tick(_delta: float) -> Status:
	var attack_hitbox := blackboard.get_var(attack_hitbox_var, null) as CombatHitbox3D
	if not is_instance_valid(attack_hitbox):
		return FAILURE

	var active_time := float(blackboard.get_var(attack_active_time_var, 0.2))
	attack_hitbox.activate_for(active_time)
	return SUCCESS
