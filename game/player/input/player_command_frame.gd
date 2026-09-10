class_name PlayerCommandFrame
extends RefCounted


enum Action {
	JUMP,
	GRAPPLE,
	ATTACK,
	COUNT,
}


var physics_step: int:
	get:
		return _physics_step

var movement_axis: Vector2:
	get:
		return _movement_axis

var view_yaw_radians: float:
	get:
		return _view_yaw_radians

var view_pitch_radians: float:
	get:
		return _view_pitch_radians

var aim_world_direction: Vector3:
	get:
		return _aim_world_direction

var _physics_step: int
var _movement_axis: Vector2
var _view_yaw_radians: float
var _view_pitch_radians: float
var _aim_world_direction: Vector3
var _pressed_flags: int
var _held_flags: int
var _released_flags: int


func _init(
	step: int,
	axis: Vector2,
	yaw_radians: float,
	pitch_radians: float,
	aim_direction: Vector3,
	pressed_flags: int = 0,
	held_flags: int = 0,
	released_flags: int = 0
) -> void:
	_physics_step = step
	_movement_axis = axis.limit_length(1.0)
	_view_yaw_radians = yaw_radians
	_view_pitch_radians = pitch_radians
	_aim_world_direction = aim_direction.normalized() if aim_direction.length_squared() > 0.000001 else Vector3.FORWARD
	_pressed_flags = pressed_flags
	_held_flags = held_flags
	_released_flags = released_flags


func was_pressed(action: Action) -> bool:
	return _has_action_flag(_pressed_flags, action)


func is_held(action: Action) -> bool:
	return _has_action_flag(_held_flags, action)


func was_released(action: Action) -> bool:
	return _has_action_flag(_released_flags, action)


func _has_action_flag(flags: int, action: Action) -> bool:
	if action < 0 or action >= Action.COUNT:
		return false
	return (flags & (1 << int(action))) != 0
