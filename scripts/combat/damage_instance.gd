class_name DamageInstance
extends RefCounted

var source: Node
var target: Node
var hitbox: Node
var attack_data: AttackData
var damage_by_type: Dictionary = {}
var final_damage_by_type: Dictionary = {}
var final_damage := 0.0
var poise_damage := 0.0
var is_critical := false
var tags: PackedStringArray = []
var hit_position := Vector3.ZERO
var knockback_direction := Vector3.ZERO


func get_largest_damage_type() -> String:
	var largest_type := ""
	var largest_amount := -INF

	for damage_type in final_damage_by_type.keys():
		var amount := float(final_damage_by_type[damage_type])
		if amount > largest_amount:
			largest_amount = amount
			largest_type = str(damage_type)

	return largest_type
