class_name PlayerMotorDiagnosticSnapshot
extends RefCounted


var physics_step: int:
	get:
		return _physics_step

var delta_seconds: float:
	get:
		return _delta_seconds

var initial_velocity: Vector3:
	get:
		return _initial_velocity

var submitted_provisional_velocity: Vector3:
	get:
		return _submitted_provisional_velocity

var final_resolved_velocity: Vector3:
	get:
		return _final_resolved_velocity

var committed_velocity: Vector3:
	get:
		return _committed_velocity

var final_committed_velocity: Vector3:
	get:
		return _final_committed_velocity

var commit_count: int:
	get:
		return _commit_count

var locomotion_state_id: StringName:
	get:
		return _locomotion_state_id

var last_rejection_reason: PlayerMotorCommitResult.RejectionReason:
	get:
		return _last_rejection_reason

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
var _delta_seconds: float
var _initial_velocity: Vector3
var _submitted_provisional_velocity: Vector3
var _final_resolved_velocity: Vector3
var _committed_velocity: Vector3
var _final_committed_velocity: Vector3
var _commit_count: int
var _locomotion_state_id: StringName
var _last_rejection_reason: PlayerMotorCommitResult.RejectionReason
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
	initial: Vector3,
	submitted: Vector3,
	committed: Vector3,
	commits: int,
	locomotion_id: StringName,
	rejection_reason: PlayerMotorCommitResult.RejectionReason,
	delta: float = 1.0 / 60.0,
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
	_delta_seconds = delta
	_initial_velocity = initial
	_submitted_provisional_velocity = submitted
	_final_resolved_velocity = submitted
	_committed_velocity = committed
	_final_committed_velocity = committed
	_commit_count = commits
	_locomotion_state_id = locomotion_id
	_last_rejection_reason = rejection_reason
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
