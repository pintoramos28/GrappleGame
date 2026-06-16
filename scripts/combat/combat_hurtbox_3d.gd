class_name CombatHurtbox3D
extends Area3D

signal damage_received(damage_instance: DamageInstance)

@export_group("Damage Receiving")
## Health component that receives resolved damage from this hurtbox.
@export var health: CombatHealth
## Team name used by hitboxes to prevent friendly fire.
@export var team := "neutral"
## Optional node path used as the combat target; defaults to this node's parent.
@export var combatant_path: NodePath


func receive_attack(attack_data: AttackData, source: Node, hitbox: Node = null) -> DamageInstance:
	var target := get_combatant()
	var damage_instance := DamageResolver.resolve(
		attack_data,
		source,
		target,
		hitbox,
		global_position
	)

	if health:
		health.apply_damage(damage_instance)

	damage_received.emit(damage_instance)
	return damage_instance


func get_combatant() -> Node:
	if not combatant_path.is_empty():
		var combatant := get_node_or_null(combatant_path)
		if combatant:
			return combatant

	return get_parent()
