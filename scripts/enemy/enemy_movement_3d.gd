class_name EnemyMovement3D
extends Node

@export var move_speed := 4.0
@export var acceleration := 14.0
@export var deceleration := 18.0
@export var stopping_distance := 0.25

var body: CharacterBody3D


func _ready() -> void:
	body = get_parent() as CharacterBody3D


func configure(definition: EnemyDefinition) -> void:
	if definition == null:
		return

	if body == null:
		body = get_parent() as CharacterBody3D

	move_speed = definition.move_speed
	acceleration = definition.acceleration
	deceleration = definition.deceleration
	stopping_distance = definition.stopping_distance


func move_toward_position(position: Vector3, delta: float) -> bool:
	if body == null:
		return false

	var offset := position - body.global_position
	offset.y = 0.0
	if offset.length() <= stopping_distance:
		stop_horizontal_movement(delta)
		return true

	_apply_desired_direction(offset.normalized(), delta)
	return false


func move_away_from_position(position: Vector3, delta: float) -> void:
	if body == null:
		return

	var offset := body.global_position - position
	offset.y = 0.0
	if offset.length_squared() <= 0.001:
		stop_horizontal_movement(delta)
		return

	_apply_desired_direction(offset.normalized(), delta)


func stop_horizontal_movement(delta: float) -> void:
	if body == null:
		return

	body.velocity.x = move_toward(body.velocity.x, 0.0, deceleration * delta)
	body.velocity.z = move_toward(body.velocity.z, 0.0, deceleration * delta)


func _apply_desired_direction(direction: Vector3, delta: float) -> void:
	var target_velocity := direction * move_speed
	body.velocity.x = move_toward(body.velocity.x, target_velocity.x, acceleration * delta)
	body.velocity.z = move_toward(body.velocity.z, target_velocity.z, acceleration * delta)
