class_name CombatHealth
extends Node

signal damaged(damage_instance: DamageInstance)
signal health_changed(current_health: float, max_health: float)
signal died(damage_instance: DamageInstance)

@export_group("Health")
## Maximum health restored when this component is reset.
@export var max_health := 100.0
## If enabled, incoming damage is ignored.
@export var invulnerable := false

var current_health := 0.0
var is_dead := false


func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health, max_health)


func apply_damage(damage_instance: DamageInstance) -> void:
	if invulnerable or is_dead or damage_instance == null:
		return

	var amount := maxf(damage_instance.final_damage, 0.0)
	if amount <= 0.0:
		return

	current_health = maxf(current_health - amount, 0.0)
	damaged.emit(damage_instance)
	health_changed.emit(current_health, max_health)

	if current_health <= 0.0:
		is_dead = true
		died.emit(damage_instance)


func heal(amount: float) -> void:
	if is_dead:
		return

	current_health = minf(current_health + maxf(amount, 0.0), max_health)
	health_changed.emit(current_health, max_health)


func reset() -> void:
	is_dead = false
	current_health = max_health
	health_changed.emit(current_health, max_health)
