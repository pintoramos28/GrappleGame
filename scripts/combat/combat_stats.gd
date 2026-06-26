class_name CombatStats
extends Node

@export_group("Base Stats")
## Reusable base stat data for this combat actor.
@export var base_stats: CombatStatsData


func get_attack_power() -> float:
	return base_stats.attack_power if base_stats else 0.0


func get_defense() -> float:
	return base_stats.defense if base_stats else 0.0


func get_crit_chance() -> float:
	return base_stats.crit_chance if base_stats else 0.0


func get_crit_multiplier() -> float:
	return base_stats.crit_multiplier if base_stats else 1.5


func get_outgoing_multiplier(damage_type: String) -> float:
	return base_stats.get_outgoing_multiplier(damage_type) if base_stats else 1.0


func get_incoming_multiplier(damage_type: String) -> float:
	return base_stats.get_incoming_multiplier(damage_type) if base_stats else 1.0


func get_resistance(damage_type: String) -> float:
	return base_stats.get_resistance(damage_type) if base_stats else 0.0
