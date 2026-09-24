class_name GrappleTargetingDiagnosticSnapshot
extends RefCounted


## Bounded read-only grapple targeting diagnostic snapshot (AC 13). Built only
## from the authoritative `GrappleTargetingResult` - copied scalars and stable
## identifiers, zero extra physics queries, no gameplay computation.

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

var is_accepted: bool:
	get:
		return _is_accepted

var rejection: GrappleRejection.Reason:
	get:
		return _rejection

var rejection_id: StringName:
	get:
		return _rejection_id

var range_fraction: float:
	get:
		return _range_fraction

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
var _is_accepted: bool
var _rejection: GrappleRejection.Reason
var _rejection_id: StringName
var _range_fraction: float
var _candidate_profile_id: StringName
var _occlusion_profile_id: StringName
var _query_count: int


func _init(
	step: int,
	frame_step: int,
	origin: Vector3,
	direction: Vector3,
	maximum_length_m: float,
	position: Vector3,
	normal: Vector3,
	distance_m: float,
	identity: StringName,
	accepted: bool,
	rejection_reason: GrappleRejection.Reason,
	fraction: float,
	candidate_profile: StringName,
	occlusion_profile: StringName,
	performed_query_count: int
) -> void:
	_source_physics_step = step
	_command_frame_step = frame_step
	_query_origin = origin
	_query_direction = direction
	_max_grapple_length_m = maximum_length_m
	_hit_position = position
	_hit_normal = normal
	_hit_distance_m = distance_m
	_target_identity = identity
	_is_accepted = accepted
	_rejection = rejection_reason
	_rejection_id = GrappleRejection.reason_id(rejection_reason)
	_range_fraction = fraction
	_candidate_profile_id = candidate_profile
	_occlusion_profile_id = occlusion_profile
	_query_count = performed_query_count


static func from_result(result: GrappleTargetingResult) -> GrappleTargetingDiagnosticSnapshot:
	if result == null:
		return null
	return GrappleTargetingDiagnosticSnapshot.new(
		result.source_physics_step,
		result.command_frame_step,
		result.query_origin,
		result.query_direction,
		result.max_grapple_length_m,
		result.hit_position,
		result.hit_normal,
		result.hit_distance_m,
		result.target_identity,
		result.is_accepted(),
		result.rejection,
		result.range_fraction,
		result.candidate_profile_id,
		result.occlusion_profile_id,
		result.query_count
	)


func is_value_only() -> bool:
	return true
