class_name ContactFrame
extends RefCounted


enum Origin {
	BOOTSTRAP,
	POST_COMMIT,
}

enum Status {
	SUCCESS,
	NOT_INITIALIZED,
	INVALID_COMPOSITION,
	INVALID_BODY,
	INVALID_STEP,
	STALE_STEP,
	DUPLICATE_STEP,
	SKIPPED_STEP,
	INVALID_DATA,
	WALL_UNAVAILABLE,
	GROUND_UNAVAILABLE,
	OVERFLOW,
}

enum GroundProvenance {
	NONE,
	BODY,
	GROUND_PROBE,
	BODY_AND_PROBE,
	PROXIMITY_ONLY,
}

enum WallProvenance {
	NONE,
	COMMITTED_COLLISION,
	CURRENT_OVERLAP,
	SWEEP_PREDICTION,
	COMBINED,
	CONTINUITY,
}

enum WallRelation {
	NONE,
	LEFT,
	RIGHT,
	FRONT,
	BACK,
	GENERIC,
}

enum ContinuityAction {
	NONE,
	INITIAL,
	PRESERVED,
	SWITCHED,
	LOST,
	UNAVAILABLE,
}


const MAX_REPORTED_CANDIDATES := 8
const MAX_REJECTIONS := 32
const MAX_SCANNED_COLLISIONS := 32
const MAX_QUERY_COUNT := 64


var physics_step: int:
	get:
		return _physics_step

var source_motor_step: int:
	get:
		return _source_motor_step

var origin: Origin:
	get:
		return _origin

var status: Status:
	get:
		return _status

var success: bool:
	get:
		return _status == Status.SUCCESS

var committed_evidence_available: bool:
	get:
		return _committed_evidence_available

var is_grounded: bool:
	get:
		return _is_grounded

var has_ground_surface: bool:
	get:
		return _has_ground_surface

var ground_normal: Vector3:
	get:
		return _ground_normal

var ground_surface_identity: StringName:
	get:
		return _ground_surface_identity

var ground_identity_persistent: bool:
	get:
		return _ground_identity_persistent

var ground_provenance: GroundProvenance:
	get:
		return _ground_provenance

var has_wall_contact: bool:
	get:
		return _has_wall_contact

var wall_normal: Vector3:
	get:
		return _wall_normal

var wall_surface_identity: StringName:
	get:
		return _wall_surface_identity

var wall_identity_persistent: bool:
	get:
		return _wall_identity_persistent

var wall_provenance: WallProvenance:
	get:
		return _wall_provenance

var wall_relation: WallRelation:
	get:
		return _wall_relation

var continuity_action: ContinuityAction:
	get:
		return _continuity_action

var candidates: Array[ContactCandidate]:
	get:
		return _copy_candidates(_candidates)

var rejections: Array[ContactRejection]:
	get:
		return _copy_rejections(_rejections)

var scanned_collision_count: int:
	get:
		return _scanned_collision_count

var reported_collision_count: int:
	get:
		return _reported_collision_count

var query_count: int:
	get:
		return _query_count

var rejected_candidate_count: int:
	get:
		return _rejected_candidate_count

var overflow_count: int:
	get:
		return _overflow_count

var overflowed: bool:
	get:
		return _overflow_count > 0

var wall_contact_lost: bool:
	get:
		return _wall_contact_lost

var body_probe_disagreement: bool:
	get:
		return _body_probe_disagreement

var ground_probe_query_succeeded: bool:
	get:
		return _ground_probe_query_succeeded

var wall_probe_query_succeeded: bool:
	get:
		return _wall_probe_query_succeeded

## Physical evidence compatible with the selected wall, never a collider ref.
## BODY_FACT may win legacy run selection; its physical corroboration is separate.
var wall_support: ContactCandidate:
	get:
		return _wall_support

var wall_point_velocity: Vector3:
	get:
		return _wall_point_velocity

var wall_support_token: int:
	get:
		return _wall_support_token


var _physics_step: int
var _source_motor_step: int
var _origin: Origin
var _status: Status
var _committed_evidence_available: bool
var _is_grounded: bool
var _has_ground_surface: bool
var _ground_normal: Vector3
var _ground_surface_identity: StringName
var _ground_identity_persistent: bool
var _ground_provenance: GroundProvenance
var _has_wall_contact: bool
var _wall_normal: Vector3
var _wall_surface_identity: StringName
var _wall_identity_persistent: bool
var _wall_provenance: WallProvenance
var _wall_relation: WallRelation
var _continuity_action: ContinuityAction
var _candidates: Array[ContactCandidate] = []
var _rejections: Array[ContactRejection] = []
var _scanned_collision_count: int
var _reported_collision_count: int
var _query_count: int
var _rejected_candidate_count: int
var _overflow_count: int
var _wall_contact_lost: bool
var _body_probe_disagreement: bool
var _ground_probe_query_succeeded: bool
var _wall_probe_query_succeeded: bool
var _wall_support: ContactCandidate
var _wall_point_velocity: Vector3
var _wall_support_token: int


func _init(
	step: int,
	frame_origin: Origin,
	frame_status: Status,
	motor_step: int,
	has_committed_evidence: bool,
	grounded: bool,
	has_ground: bool,
	support_normal: Vector3,
	support_surface_identity: StringName,
	support_provenance: GroundProvenance,
	has_wall: bool,
	selected_wall_normal: Vector3,
	selected_wall_surface_identity: StringName,
	selected_wall_provenance: WallProvenance,
	selected_wall_relation: WallRelation,
	wall_continuity_action: ContinuityAction,
	frame_candidates: Array[ContactCandidate] = [],
	frame_rejections: Array[ContactRejection] = [],
	scanned_count: int = 0,
	reported_count: int = 0,
	direct_query_count: int = 0,
	rejected_count: int = 0,
	frame_overflow_count: int = 0,
	ground_identity_is_persistent: bool = false,
	wall_identity_is_persistent: bool = false,
	wall_was_lost: bool = false,
	probe_disagreement: bool = false,
	ground_query_succeeded: bool = false,
	wall_query_succeeded: bool = false,
	physical_wall_support: ContactCandidate = null,
	physical_wall_point_velocity: Vector3 = Vector3.ZERO,
	physical_wall_support_token: int = 0
) -> void:
	var validation_failed := false
	if not physical_wall_point_velocity.is_finite() or (physical_wall_support != null and (not physical_wall_support.is_finite() or physical_wall_support.physics_step != step)):
		validation_failed = true
	var normalized_ground_normal := Vector3.ZERO
	if has_ground_surface:
		if support_normal.is_finite() and support_normal.length_squared() > 0.000001:
			normalized_ground_normal = support_normal.normalized()
		else:
			validation_failed = true
	var normalized_wall_normal := Vector3.ZERO
	if has_wall:
		if selected_wall_normal.is_finite() and selected_wall_normal.length_squared() > 0.000001:
			normalized_wall_normal = selected_wall_normal.normalized()
		else:
			validation_failed = true
	if grounded and not has_ground:
		validation_failed = true
	if frame_status == Status.SUCCESS:
		if step < 0 or motor_step != step:
			validation_failed = true
		if frame_origin == Origin.BOOTSTRAP and has_committed_evidence:
			validation_failed = true
	var bounded_candidates := _copy_candidates(frame_candidates, MAX_REPORTED_CANDIDATES)
	var bounded_rejections := _copy_rejections(frame_rejections, MAX_REJECTIONS)
	if bounded_candidates.size() < frame_candidates.size():
		frame_overflow_count += frame_candidates.size() - bounded_candidates.size()
	if validation_failed and frame_status == Status.SUCCESS:
		frame_status = Status.INVALID_DATA
	_physics_step = step
	_origin = frame_origin
	_status = frame_status
	_source_motor_step = motor_step
	_committed_evidence_available = has_committed_evidence
	_is_grounded = grounded
	_has_ground_surface = has_ground
	_ground_normal = normalized_ground_normal
	_ground_surface_identity = support_surface_identity
	_ground_identity_persistent = ground_identity_is_persistent
	_ground_provenance = support_provenance
	_has_wall_contact = has_wall
	_wall_normal = normalized_wall_normal
	_wall_surface_identity = selected_wall_surface_identity
	_wall_identity_persistent = wall_identity_is_persistent
	_wall_provenance = selected_wall_provenance
	_wall_relation = selected_wall_relation
	_continuity_action = wall_continuity_action
	_candidates = bounded_candidates
	_rejections = bounded_rejections
	_scanned_collision_count = clampi(scanned_count, 0, MAX_SCANNED_COLLISIONS)
	_reported_collision_count = clampi(reported_count, 0, MAX_REPORTED_CANDIDATES)
	_query_count = clampi(direct_query_count, 0, MAX_QUERY_COUNT)
	_rejected_candidate_count = clampi(rejected_count, 0, MAX_REJECTIONS)
	_overflow_count = maxi(frame_overflow_count, 0)
	_wall_contact_lost = wall_was_lost
	_body_probe_disagreement = probe_disagreement
	_ground_probe_query_succeeded = ground_query_succeeded
	_wall_probe_query_succeeded = wall_query_succeeded
	_wall_support = physical_wall_support
	_wall_point_velocity = physical_wall_point_velocity
	_wall_support_token = physical_wall_support_token


static func failure(
	step: int,
	frame_status: Status,
	frame_origin: Origin = Origin.POST_COMMIT,
	motor_step: int = -1
) -> ContactFrame:
	return ContactFrame.new(
		step,
		frame_origin,
		frame_status,
		motor_step,
		false,
		false,
		false,
		Vector3.ZERO,
		&"",
		GroundProvenance.NONE,
		false,
		Vector3.ZERO,
		&"",
		WallProvenance.NONE,
		WallRelation.NONE,
		ContinuityAction.NONE
	)


func is_value_only() -> bool:
	return true


static func _copy_candidates(
	source: Array[ContactCandidate],
	max_count: int = -1
) -> Array[ContactCandidate]:
	var result: Array[ContactCandidate] = []
	var limit := source.size() if max_count < 0 else mini(source.size(), max_count)
	for index in range(limit):
		var candidate := source[index]
		if candidate != null and candidate.is_finite():
			result.append(candidate)
	return result


static func _copy_rejections(
	source: Array[ContactRejection],
	max_count: int = -1
) -> Array[ContactRejection]:
	var result: Array[ContactRejection] = []
	var limit := source.size() if max_count < 0 else mini(source.size(), max_count)
	for index in range(limit):
		var rejection := source[index]
		if rejection != null:
			result.append(rejection)
	return result
