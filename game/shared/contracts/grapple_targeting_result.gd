class_name GrappleTargetingResult
extends RefCounted


## One authoritative typed grapple targeting result per evaluated physics step
## (value-only, bounded, copy-on-read like `ContactFrame`). It carries the first
## blocking hit facts, candidate identity, validity, typed rejection reason,
## range fraction, profile identifiers, and the query/step identity.
##
## ENGINE-REFERENCE EXCEPTION: the accepted `GrappleTargetSeed` may hold one
## bounded `WeakRef` target reference (AC 4). Nothing else escapes: no `Node`,
## `PhysicsBody3D`, `Dictionary`, or live engine reference.

const MAX_QUERY_COUNT := 1


var source_physics_step: int:
	get:
		return _source_physics_step

var command_frame_step: int:
	get:
		return _command_frame_step

var query_origin: Vector3:
	get:
		return _query_origin

var query_direction: Vector3:
	get:
		return _query_direction

var max_grapple_length_m: float:
	get:
		return _max_grapple_length_m

var hit_position: Vector3:
	get:
		return _hit_position

var hit_normal: Vector3:
	get:
		return _hit_normal

var hit_distance_m: float:
	get:
		return _hit_distance_m

var target_identity: StringName:
	get:
		return _target_identity

var rejection: GrappleRejection.Reason:
	get:
		return _rejection

var range_fraction: float:
	get:
		return _range_fraction

var accepted_seed: GrappleTargetSeed:
	get:
		return _accepted_seed

var candidate_profile_id: StringName:
	get:
		return _candidate_profile_id

var occlusion_profile_id: StringName:
	get:
		return _occlusion_profile_id

var query_count: int:
	get:
		return _query_count


var _source_physics_step: int
var _command_frame_step: int
var _query_origin: Vector3
var _query_direction: Vector3
var _max_grapple_length_m: float
var _hit_position: Vector3
var _hit_normal: Vector3
var _hit_distance_m: float
var _target_identity: StringName
var _rejection: GrappleRejection.Reason
var _range_fraction: float
var _accepted_seed: GrappleTargetSeed
var _candidate_profile_id: StringName
var _occlusion_profile_id: StringName
var _query_count: int


func _init(
	step: int,
	frame_step: int,
	origin: Vector3,
	direction: Vector3,
	maximum_length_m: float,
	rejection_reason: GrappleRejection.Reason,
	position: Vector3,
	normal: Vector3,
	distance_m: float,
	fraction: float,
	identity: StringName,
	seed: GrappleTargetSeed,
	candidate_profile: StringName,
	occlusion_profile: StringName,
	performed_query_count: int
) -> void:
	var payload_is_finite := (
		origin.is_finite()
		and direction.is_finite()
		and not is_nan(maximum_length_m)
		and not is_inf(maximum_length_m)
		and position.is_finite()
		and normal.is_finite()
		and not is_nan(distance_m)
		and not is_inf(distance_m)
		and not is_nan(fraction)
		and not is_inf(fraction)
	)
	if not payload_is_finite and rejection_reason == GrappleRejection.Reason.NONE:
		rejection_reason = GrappleRejection.Reason.MALFORMED_TARGET_DATA
	if rejection_reason != GrappleRejection.Reason.NONE:
		seed = null
	_source_physics_step = step
	_command_frame_step = frame_step
	_query_origin = origin if origin.is_finite() else Vector3.ZERO
	_query_direction = direction if direction.is_finite() else Vector3.ZERO
	_max_grapple_length_m = maximum_length_m if not is_nan(maximum_length_m) and not is_inf(maximum_length_m) else 0.0
	_hit_position = position if position.is_finite() else Vector3.ZERO
	_hit_normal = normal.normalized() if normal.is_finite() else Vector3.ZERO
	_hit_distance_m = maxf(distance_m, 0.0) if not is_nan(distance_m) and not is_inf(distance_m) else 0.0
	_target_identity = identity
	_rejection = rejection_reason
	_range_fraction = maxf(fraction, 0.0)
	_accepted_seed = seed if rejection_reason == GrappleRejection.Reason.NONE else null
	_candidate_profile_id = candidate_profile
	_occlusion_profile_id = occlusion_profile
	_query_count = clampi(performed_query_count, 0, MAX_QUERY_COUNT)


func is_accepted() -> bool:
	return _rejection == GrappleRejection.Reason.NONE and _accepted_seed != null


func has_accepted_seed() -> bool:
	return _accepted_seed != null


func is_finite() -> bool:
	return (
		_query_origin.is_finite()
		and _query_direction.is_finite()
		and not is_nan(_max_grapple_length_m)
		and not is_inf(_max_grapple_length_m)
		and _hit_position.is_finite()
		and _hit_normal.is_finite()
		and not is_nan(_hit_distance_m)
		and not is_inf(_hit_distance_m)
		and not is_nan(_range_fraction)
		and not is_inf(_range_fraction)
	)


func is_value_only() -> bool:
	return true
