class_name ContactRejection
extends RefCounted


enum Reason {
	NON_FINITE,
	INVALID_NORMAL,
	FLOOR_LIKE,
	CEILING_LIKE,
	DUPLICATE,
	STALE_STEP,
	DUPLICATE_STEP,
	SKIPPED_STEP,
	INVALID_PROFILE,
	INVALID_BODY,
	OVERFLOW,
	BODY_PROBE_DISAGREEMENT,
	WALL_UNAVAILABLE,
	GROUND_UNAVAILABLE,
}


var physics_step: int:
	get:
		return _physics_step

var source: ContactCandidate.Source:
	get:
		return _source

var reason: Reason:
	get:
		return _reason

var normal: Vector3:
	get:
		return _normal

var point: Vector3:
	get:
		return _point


var _physics_step: int
var _source: ContactCandidate.Source
var _reason: Reason
var _normal: Vector3
var _point: Vector3


func _init(
	step: int,
	rejection_source: ContactCandidate.Source,
	rejection_reason: Reason,
	rejection_normal: Vector3 = Vector3.ZERO,
	rejection_point: Vector3 = Vector3.ZERO
) -> void:
	_physics_step = step
	_source = rejection_source
	_reason = rejection_reason
	_normal = rejection_normal
	_point = rejection_point


func is_value_only() -> bool:
	return true
