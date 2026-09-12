class_name PlayerMotionRequest
extends RefCounted


enum RequestKind {
	MOVEMENT,
	HOLD,
}


var physics_step: int:
	get:
		return _physics_step

var locomotion_state_id: StringName:
	get:
		return _locomotion_state_id

var kind: RequestKind:
	get:
		return _kind

var provisional_velocity: Vector3:
	get:
		return _provisional_velocity

var hold_position: Vector3:
	get:
		return _hold_position

var _physics_step: int
var _locomotion_state_id: StringName
var _kind: RequestKind
var _provisional_velocity: Vector3
var _hold_position: Vector3


func _init(
	request_kind: RequestKind,
	step: int,
	locomotion_id: StringName,
	velocity: Vector3,
	position: Vector3 = Vector3.ZERO
) -> void:
	_kind = request_kind
	_physics_step = step
	_locomotion_state_id = locomotion_id
	_provisional_velocity = velocity
	_hold_position = position


static func movement(
	step: int,
	locomotion_id: StringName,
	velocity: Vector3
) -> PlayerMotionRequest:
	return PlayerMotionRequest.new(RequestKind.MOVEMENT, step, locomotion_id, velocity)


static func hold(
	step: int,
	locomotion_id: StringName,
	position: Vector3
) -> PlayerMotionRequest:
	return PlayerMotionRequest.new(RequestKind.HOLD, step, locomotion_id, Vector3.ZERO, position)


func is_hold_request() -> bool:
	return _kind == RequestKind.HOLD


func is_valid() -> bool:
	if _physics_step < 0 or _locomotion_state_id == &"":
		return false
	if not _provisional_velocity.is_finite():
		return false
	if _kind == RequestKind.HOLD:
		return _hold_position.is_finite() and _provisional_velocity == Vector3.ZERO
	return _kind == RequestKind.MOVEMENT
