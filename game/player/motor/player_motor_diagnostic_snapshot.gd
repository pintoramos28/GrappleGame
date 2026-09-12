class_name PlayerMotorDiagnosticSnapshot
extends RefCounted


var physics_step: int:
	get:
		return _physics_step

var initial_velocity: Vector3:
	get:
		return _initial_velocity

var submitted_provisional_velocity: Vector3:
	get:
		return _submitted_provisional_velocity

var committed_velocity: Vector3:
	get:
		return _committed_velocity

var commit_count: int:
	get:
		return _commit_count

var locomotion_state_id: StringName:
	get:
		return _locomotion_state_id

var last_rejection_reason: PlayerMotorCommitResult.RejectionReason:
	get:
		return _last_rejection_reason

var _physics_step: int
var _initial_velocity: Vector3
var _submitted_provisional_velocity: Vector3
var _committed_velocity: Vector3
var _commit_count: int
var _locomotion_state_id: StringName
var _last_rejection_reason: PlayerMotorCommitResult.RejectionReason


func _init(
	step: int,
	initial: Vector3,
	submitted: Vector3,
	committed: Vector3,
	commits: int,
	locomotion_id: StringName,
	rejection_reason: PlayerMotorCommitResult.RejectionReason
) -> void:
	_physics_step = step
	_initial_velocity = initial
	_submitted_provisional_velocity = submitted
	_committed_velocity = committed
	_commit_count = commits
	_locomotion_state_id = locomotion_id
	_last_rejection_reason = rejection_reason
