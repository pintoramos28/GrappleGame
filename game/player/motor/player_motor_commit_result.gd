class_name PlayerMotorCommitResult
extends RefCounted


enum RejectionReason {
	NONE,
	NOT_INITIALIZED,
	INVALID_BODY,
	NO_ACTIVE_FRAME,
	CONFLICTING_ACTIVE_FRAME,
	DUPLICATE_STEP,
	NON_MONOTONIC_STEP,
	STALE_STEP,
	WRONG_STEP,
	NO_MOTION_REQUEST,
	INVALID_REQUEST,
	ILLEGAL_PHASE_OR_KIND,
	EMPTY_SOURCE_ID,
	UNSTABLE_SOURCE_ID,
	NON_FINITE_VALUE,
	DUPLICATE_SOURCE,
	DUPLICATE_OCCURRENCE,
	MISSING_REQUIRED_POLICY,
	EXCLUSIVE_POLICY_CONFLICT,
	DUPLICATE_SUBMISSION,
	DUPLICATE_COMMIT,
	FRAME_ABORTED,
	OVERFLOW,
	ALREADY_RESOLVED,
	UNSUPPORTED_CAP_SCOPE,
	INVALID_WALL_CONSTRAINT,
}


var physics_step: int:
	get:
		return _physics_step

var physics_delta_seconds: float:
	get:
		return _physics_delta_seconds

var success: bool:
	get:
		return _success

var rejection_reason: RejectionReason:
	get:
		return _rejection_reason

var diagnostic_code: StringName:
	get:
		return _diagnostic_code

var locomotion_state_id: StringName:
	get:
		return _locomotion_state_id

## The velocity immediately before the motor's single body velocity write.
var submitted_velocity: Vector3:
	get:
		return _submitted_velocity

var committed_velocity: Vector3:
	get:
		return _committed_velocity

var final_resolved_velocity: Vector3:
	get:
		return _submitted_velocity

var final_committed_velocity: Vector3:
	get:
		return _committed_velocity

var position_before: Vector3:
	get:
		return _position_before

var position_after: Vector3:
	get:
		return _position_after

var position_delta: Vector3:
	get:
		return _position_after - _position_before

var is_hold_request: bool:
	get:
		return _is_hold_request

var hold_position: Vector3:
	get:
		return _hold_position

var on_floor: bool:
	get:
		return _on_floor

var on_wall: bool:
	get:
		return _on_wall

var commit_count: int:
	get:
		return _commit_count

var slide_collisions: Array[KinematicCollision3D]:
	get:
		return _slide_collisions.duplicate()

var collision_facts_truncated: bool:
	get:
		return _collision_facts_truncated

var phase_order: Array[StringName]:
	get:
		return _phase_order.duplicate()

var phase_intermediates: Array[Dictionary]:
	get:
		return _duplicate_dictionaries(_phase_intermediates)

var accepted_sources_by_phase: Array:
	get:
		return _duplicate_nested_arrays(_accepted_sources_by_phase)

var rejected_contributions: Array[Dictionary]:
	get:
		return _duplicate_dictionaries(_rejected_contributions)

var applied_constraints: Array[StringName]:
	get:
		return _applied_constraints.duplicate()

var applied_caps: Array[StringName]:
	get:
		return _applied_caps.duplicate()

var rejected_contribution_overflow_count: int:
	get:
		return _rejected_contribution_overflow_count

var rejected_contributions_truncated: bool:
	get:
		return _rejected_contributions_truncated

var _physics_step: int
var _physics_delta_seconds: float
var _success: bool
var _rejection_reason: RejectionReason
var _diagnostic_code: StringName
var _locomotion_state_id: StringName
var _submitted_velocity: Vector3
var _committed_velocity: Vector3
var _position_before: Vector3
var _position_after: Vector3
var _is_hold_request: bool
var _hold_position: Vector3
var _on_floor: bool
var _on_wall: bool
var _commit_count: int
var _slide_collisions: Array[KinematicCollision3D] = []
var _collision_facts_truncated := false
var _phase_order: Array[StringName] = []
var _phase_intermediates: Array[Dictionary] = []
var _accepted_sources_by_phase: Array = []
var _rejected_contributions: Array[Dictionary] = []
var _applied_constraints: Array[StringName] = []
var _applied_caps: Array[StringName] = []
var _rejected_contribution_overflow_count := 0
var _rejected_contributions_truncated := false


func _init(
	step: int,
	was_successful: bool,
	reason: RejectionReason,
	code: StringName,
	locomotion_id: StringName,
	pre_slide_velocity: Vector3,
	post_slide_velocity: Vector3,
	before_position: Vector3,
	after_position: Vector3,
	hold_request: bool,
	requested_hold_position: Vector3,
	floor_contact: bool,
	wall_contact: bool,
	actual_commit_count: int,
	collisions: Array[KinematicCollision3D],
	contact_facts_were_truncated: bool = false,
	delta_seconds: float = 1.0 / 60.0,
	resolved_phase_order: Array[StringName] = [],
	resolved_phase_intermediates: Array[Dictionary] = [],
	resolved_sources_by_phase: Array = [],
	resolved_rejected_contributions: Array[Dictionary] = [],
	resolved_constraints: Array[StringName] = [],
	resolved_caps: Array[StringName] = [],
	rejected_overflow_count: int = 0,
	rejected_facts_were_truncated: bool = false
) -> void:
	_physics_step = step
	_physics_delta_seconds = delta_seconds
	_success = was_successful
	_rejection_reason = reason
	_diagnostic_code = code
	_locomotion_state_id = locomotion_id
	_submitted_velocity = pre_slide_velocity
	_committed_velocity = post_slide_velocity
	_position_before = before_position
	_position_after = after_position
	_is_hold_request = hold_request
	_hold_position = requested_hold_position
	_on_floor = floor_contact
	_on_wall = wall_contact
	_commit_count = actual_commit_count
	_slide_collisions = collisions.duplicate()
	_collision_facts_truncated = contact_facts_were_truncated
	_phase_order = resolved_phase_order.duplicate()
	_phase_intermediates = _duplicate_dictionaries(resolved_phase_intermediates)
	_accepted_sources_by_phase = _duplicate_nested_arrays(resolved_sources_by_phase)
	_rejected_contributions = _duplicate_dictionaries(resolved_rejected_contributions)
	_applied_constraints = resolved_constraints.duplicate()
	_applied_caps = resolved_caps.duplicate()
	_rejected_contribution_overflow_count = rejected_overflow_count
	_rejected_contributions_truncated = rejected_facts_were_truncated


static func _duplicate_dictionaries(source: Array[Dictionary]) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for entry in source:
		result.append(entry.duplicate(true))
	return result


static func _duplicate_nested_arrays(source: Array) -> Array:
	var result: Array = []
	for entry in source:
		result.append(entry.duplicate(true))
	return result
