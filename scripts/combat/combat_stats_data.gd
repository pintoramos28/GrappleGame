class_name CombatStatsData
extends Resource

@export_group("Offense")
## Flat attack power added to attacks based on their scaling.
@export var attack_power := 0.0
## Base chance for outgoing attacks to critically hit.
@export var crit_chance := 0.0
## Damage multiplier applied when outgoing attacks critically hit.
@export var crit_multiplier := 1.5
## Per-type outgoing damage multipliers keyed by damage type.
@export var outgoing_damage_multipliers: Dictionary = {}

@export_group("Defense")
## Flat defense subtracted from physical damage before resistances.
@export var defense := 0.0
## Per-type incoming damage multipliers keyed by damage type.
@export var incoming_damage_multipliers: Dictionary = {}
## Per-type damage reduction values where 0.25 means 25 percent resistance.
@export var resistances: Dictionary = {
	"physical": 0.0,
	"fire": 0.0,
	"ice": 0.0,
	"lightning": 0.0,
	"poison": 0.0,
	"arcane": 0.0,
}


func get_outgoing_multiplier(damage_type: String) -> float:
	return maxf(float(outgoing_damage_multipliers.get(damage_type, 1.0)), 0.0)


func get_incoming_multiplier(damage_type: String) -> float:
	return maxf(float(incoming_damage_multipliers.get(damage_type, 1.0)), 0.0)


func get_resistance(damage_type: String) -> float:
	if damage_type == "true":
		return 0.0

	return clampf(float(resistances.get(damage_type, 0.0)), -10.0, 1.0)
