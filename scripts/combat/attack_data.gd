class_name AttackData
extends Resource

@export_group("Identity")
## Name shown in the Inspector and combat debug output.
@export var display_name := "Attack"

@export_group("Damage")
## Base damage amounts keyed by damage type, such as physical or fire.
@export var damage_by_type: Dictionary = {
	"physical": 10.0,
}
## Multiplier for how much of the attacker's attack power is added.
@export var attack_power_scale := 1.0
## Amount of stagger or poise pressure this attack applies.
@export var poise_damage := 0.0
## Additional critical hit chance added to the attacker's crit chance.
@export var crit_chance_bonus := 0.0
## Additional critical damage multiplier added on critical hits.
@export var crit_multiplier_bonus := 0.0
## Fraction of physical defense ignored by this attack.
@export var armor_penetration := 0.0
## Lowest non-zero final damage this attack can deal after mitigation.
@export var minimum_final_damage := 1.0
## Labels used by modifiers and status effects to identify attack traits.
@export var tags: PackedStringArray = []


func get_primary_damage_type() -> String:
	for damage_type in damage_by_type.keys():
		return str(damage_type)

	return "physical"


func get_damage_map() -> Dictionary:
	var result := {}

	for damage_type in damage_by_type.keys():
		var amount := float(damage_by_type[damage_type])
		if amount > 0.0:
			result[str(damage_type)] = amount

	return result
