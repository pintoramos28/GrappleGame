class_name DamageResolver
extends Object

const PHYSICAL_DAMAGE_TYPES := ["physical", "slash", "pierce", "blunt"]


static func resolve(
	attack_data: AttackData,
	source: Node,
	target: Node,
	hitbox: Node = null,
	hit_position := Vector3.ZERO
) -> DamageInstance:
	var damage_instance := DamageInstance.new()
	damage_instance.source = source
	damage_instance.target = target
	damage_instance.hitbox = hitbox
	damage_instance.attack_data = attack_data
	damage_instance.hit_position = hit_position

	if source is Node3D and target is Node3D:
		damage_instance.knockback_direction = (
			(target as Node3D).global_position - (source as Node3D).global_position
		).normalized()

	if attack_data == null:
		return damage_instance

	damage_instance.damage_by_type = attack_data.get_damage_map()
	damage_instance.poise_damage = attack_data.poise_damage
	damage_instance.tags = attack_data.tags

	var attacker_stats := _get_stats(source)
	var defender_stats := _get_stats(target)

	_apply_attack_power(damage_instance, attacker_stats)
	_apply_critical_hit(damage_instance, attack_data, attacker_stats)
	_apply_stat_multipliers(damage_instance, attacker_stats, true)
	_apply_modifiers(source, "modify_outgoing_damage", damage_instance)
	_apply_stat_multipliers(damage_instance, defender_stats, false)
	_apply_modifiers(target, "modify_incoming_damage", damage_instance)
	_apply_defense(damage_instance, attack_data, defender_stats)
	_apply_resistances(damage_instance, defender_stats)
	_finalize_damage(damage_instance)
	_apply_modifiers(target, "modify_resolved_damage", damage_instance)
	_recalculate_final_damage(damage_instance)

	if damage_instance.final_damage > 0.0:
		damage_instance.final_damage = maxf(damage_instance.final_damage, attack_data.minimum_final_damage)

	return damage_instance


static func _get_stats(combatant: Node) -> CombatStats:
	if combatant == null:
		return null

	if combatant is CombatStats:
		return combatant

	return combatant.get_node_or_null("CombatStats") as CombatStats


static func _apply_attack_power(damage_instance: DamageInstance, attacker_stats: CombatStats) -> void:
	if attacker_stats == null:
		return

	var attack_data := damage_instance.attack_data
	if attack_data == null or attack_data.attack_power_scale == 0.0:
		return

	var primary_type := attack_data.get_primary_damage_type()
	var current_amount := float(damage_instance.damage_by_type.get(primary_type, 0.0))
	damage_instance.damage_by_type[primary_type] = (
		current_amount + attacker_stats.get_attack_power() * attack_data.attack_power_scale
	)


static func _apply_critical_hit(
	damage_instance: DamageInstance,
	attack_data: AttackData,
	attacker_stats: CombatStats
) -> void:
	if attacker_stats == null:
		return

	var crit_chance := clampf(attacker_stats.get_crit_chance() + attack_data.crit_chance_bonus, 0.0, 1.0)
	if randf() >= crit_chance:
		return

	var crit_multiplier := maxf(
		attacker_stats.get_crit_multiplier() + attack_data.crit_multiplier_bonus,
		1.0
	)
	damage_instance.is_critical = true
	_multiply_damage_map(damage_instance.damage_by_type, crit_multiplier)


static func _apply_stat_multipliers(
	damage_instance: DamageInstance,
	stats: CombatStats,
	is_outgoing: bool
) -> void:
	if stats == null:
		return

	for damage_type in damage_instance.damage_by_type.keys():
		var type_name := str(damage_type)
		var multiplier := (
			stats.get_outgoing_multiplier(type_name)
			if is_outgoing
			else stats.get_incoming_multiplier(type_name)
		)
		damage_instance.damage_by_type[type_name] = (
			float(damage_instance.damage_by_type[type_name]) * multiplier
		)


static func _apply_modifiers(combatant: Node, method_name: String, damage_instance: DamageInstance) -> void:
	if combatant == null:
		return

	for child in combatant.get_children():
		if child is CombatModifier:
			child.call(method_name, damage_instance)


static func _apply_defense(
	damage_instance: DamageInstance,
	attack_data: AttackData,
	defender_stats: CombatStats
) -> void:
	if defender_stats == null or defender_stats.get_defense() <= 0.0:
		return

	var physical_total := 0.0
	for damage_type in PHYSICAL_DAMAGE_TYPES:
		physical_total += float(damage_instance.damage_by_type.get(damage_type, 0.0))

	if physical_total <= 0.0:
		return

	var penetration := clampf(attack_data.armor_penetration, 0.0, 1.0) if attack_data else 0.0
	var reduction := minf(physical_total, defender_stats.get_defense() * (1.0 - penetration))

	for damage_type in PHYSICAL_DAMAGE_TYPES:
		var amount := float(damage_instance.damage_by_type.get(damage_type, 0.0))
		if amount <= 0.0:
			continue

		var share := amount / physical_total
		damage_instance.damage_by_type[damage_type] = maxf(amount - reduction * share, 0.0)


static func _apply_resistances(damage_instance: DamageInstance, defender_stats: CombatStats) -> void:
	if defender_stats == null:
		damage_instance.final_damage_by_type = damage_instance.damage_by_type.duplicate()
		return

	damage_instance.final_damage_by_type.clear()
	for damage_type in damage_instance.damage_by_type.keys():
		var type_name := str(damage_type)
		var amount := float(damage_instance.damage_by_type[type_name])
		var resistance := defender_stats.get_resistance(type_name)
		damage_instance.final_damage_by_type[type_name] = maxf(amount * (1.0 - resistance), 0.0)


static func _finalize_damage(damage_instance: DamageInstance) -> void:
	if damage_instance.final_damage_by_type.is_empty():
		damage_instance.final_damage_by_type = damage_instance.damage_by_type.duplicate()

	_recalculate_final_damage(damage_instance)


static func _recalculate_final_damage(damage_instance: DamageInstance) -> void:
	damage_instance.final_damage = 0.0
	for damage_type in damage_instance.final_damage_by_type.keys():
		damage_instance.final_damage += float(damage_instance.final_damage_by_type[damage_type])


static func _multiply_damage_map(damage_map: Dictionary, multiplier: float) -> void:
	for damage_type in damage_map.keys():
		damage_map[damage_type] = float(damage_map[damage_type]) * multiplier
