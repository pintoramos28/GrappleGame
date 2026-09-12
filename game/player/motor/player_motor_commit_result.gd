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
	WRONG_STEP,
	NO_MOTION_REQUEST,
	INVALID_REQUEST,
	DUPLICATE_SUBMISSION,
	DUPLICATE_COMMIT,
	FRAME_ABORTED,
}


var physics_step: int:
	get:
		return _physics_step

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

var submitted_velocity: Vector3:
	get:
		return _submitted_velocity

var committed_velocity: Vector3:
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

var _physics_step: int
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
	contact_facts_were_truncated: bool = false
) -> void:
	_physics_step = step
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
