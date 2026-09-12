class_name PlayerMotor
extends Node


enum InitializationStatus {
	NOT_INITIALIZED,
	SUCCESS,
	MISSING_BODY,
	WRONG_BODY,
	BODY_NOT_IN_TREE,
	ALREADY_INITIALIZED,
}

enum FrameStatus {
	SUCCESS,
	NOT_INITIALIZED,
	INVALID_BODY,
	DUPLICATE_ACTIVE_FRAME,
	DUPLICATE_STEP,
	NON_MONOTONIC_STEP,
	CONFLICTING_ACTIVE_FRAME,
}

enum SubmissionStatus {
	SUCCESS,
	NOT_INITIALIZED,
	INVALID_BODY,
	NO_ACTIVE_FRAME,
	WRONG_STEP,
	INVALID_REQUEST,
	DUPLICATE_SUBMISSION,
}

enum BaselineStatus {
	SUCCESS,
	NOT_INITIALIZED,
	INVALID_BODY,
	ACTIVE_FRAME,
	INVALID_VELOCITY,
}


const MAX_REPORTED_COLLISIONS := 8
const MAX_SCANNED_COLLISIONS := 32

signal diagnostic_recorded(event: DiagnosticEvent)


var _body: CharacterBody3D
var _initialized := false
var _frame_open := false
var _active_step := -1
var _last_started_step := -1
var _last_closed_step := -1
var _last_committed_step := -1
var _initial_position := Vector3.ZERO
var _initial_velocity := Vector3.ZERO
var _submitted_velocity := Vector3.ZERO
var _committed_velocity := Vector3.ZERO
var _last_locomotion_state_id: StringName = &""
var _last_rejection_reason := PlayerMotorCommitResult.RejectionReason.NONE
var _last_diagnostic_code: StringName = &""
var _request: PlayerMotionRequest
var _last_commit_result: PlayerMotorCommitResult
var _accepted_submission_count := 0
var _commit_count := 0
var _has_next_frame_velocity_baseline := false
var _next_frame_velocity_baseline := Vector3.ZERO
var _diagnostics_enabled := false
var _debug_assertions_enabled := true
var _game_log: GameLog = GameLog.new()


func _init() -> void:
	_game_log.diagnostic_recorded.connect(_on_diagnostic_recorded)


func initialize(body: Node) -> InitializationStatus:
	if _initialized:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
			&"player.motor.already_initialized",
			-1,
			&""
		)
		return InitializationStatus.ALREADY_INITIALIZED

	if not is_instance_valid(body):
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.NOT_INITIALIZED,
			&"player.motor.missing_body",
			-1,
			&""
		)
		return InitializationStatus.MISSING_BODY

	if not body is CharacterBody3D:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
			&"player.motor.wrong_body",
			-1,
			&""
		)
		return InitializationStatus.WRONG_BODY

	var character_body := body as CharacterBody3D
	if not character_body.is_inside_tree():
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_BODY,
			&"player.motor.body_not_in_tree",
			-1,
			&""
		)
		return InitializationStatus.BODY_NOT_IN_TREE

	_body = character_body
	_initialized = true
	_has_next_frame_velocity_baseline = false
	_next_frame_velocity_baseline = Vector3.ZERO
	_last_rejection_reason = PlayerMotorCommitResult.RejectionReason.NONE
	_last_diagnostic_code = &""
	return InitializationStatus.SUCCESS


func is_initialized() -> bool:
	return _initialized


static func initialization_status_id(status: InitializationStatus) -> StringName:
	return StringName(InitializationStatus.keys()[int(status)].to_lower())


func begin_motion_frame(physics_step: int) -> FrameStatus:
	if not _initialized:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.NOT_INITIALIZED,
			&"player.motor.begin_not_initialized",
			physics_step,
			&""
		)
		return FrameStatus.NOT_INITIALIZED
	if not _has_usable_body():
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_BODY,
			&"player.motor.begin_invalid_body",
			physics_step,
			&""
		)
		return FrameStatus.INVALID_BODY

	if _frame_open:
		if physics_step == _active_step:
			_record_rejection(
				PlayerMotorCommitResult.RejectionReason.DUPLICATE_STEP,
				&"player.motor.duplicate_active_frame",
				physics_step,
				_last_locomotion_state_id
			)
			return FrameStatus.DUPLICATE_ACTIVE_FRAME
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.CONFLICTING_ACTIVE_FRAME,
			&"player.motor.conflicting_active_frame",
			physics_step,
			_last_locomotion_state_id
		)
		return FrameStatus.CONFLICTING_ACTIVE_FRAME

	if physics_step < _last_started_step:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.NON_MONOTONIC_STEP,
			&"player.motor.non_monotonic_step",
			physics_step,
			&""
		)
		return FrameStatus.NON_MONOTONIC_STEP
	if physics_step == _last_started_step or physics_step == _last_closed_step:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.DUPLICATE_STEP,
			&"player.motor.duplicate_step",
			physics_step,
			&""
		)
		return FrameStatus.DUPLICATE_STEP

	_frame_open = true
	_active_step = physics_step
	_last_started_step = physics_step
	_initial_position = _body.global_position
	_initial_velocity = (
		_next_frame_velocity_baseline
		if _has_next_frame_velocity_baseline
		else _body.velocity
	)
	_has_next_frame_velocity_baseline = false
	_next_frame_velocity_baseline = Vector3.ZERO
	_submitted_velocity = _initial_velocity
	_committed_velocity = _initial_velocity
	_last_locomotion_state_id = &""
	_last_rejection_reason = PlayerMotorCommitResult.RejectionReason.NONE
	_last_diagnostic_code = &""
	_request = null
	_last_commit_result = null
	_accepted_submission_count = 0
	_commit_count = 0
	return FrameStatus.SUCCESS


func submit_motion_request(request: PlayerMotionRequest) -> SubmissionStatus:
	if not _initialized:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.NOT_INITIALIZED,
			&"player.motor.submit_not_initialized",
			-1,
			&""
		)
		return SubmissionStatus.NOT_INITIALIZED
	if not _has_usable_body():
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_BODY,
			&"player.motor.submit_invalid_body",
			_active_step,
			request.locomotion_state_id if request != null else &""
		)
		return SubmissionStatus.INVALID_BODY
	if not _frame_open:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.NO_ACTIVE_FRAME,
			&"player.motor.no_active_motion_frame",
			_active_step,
			&""
		)
		return SubmissionStatus.NO_ACTIVE_FRAME
	if request == null or not request.is_valid():
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
			&"player.motor.invalid_motion_request",
			_active_step,
			request.locomotion_state_id if request != null else &""
		)
		return SubmissionStatus.INVALID_REQUEST
	if request.physics_step != _active_step:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.WRONG_STEP,
			&"player.motor.wrong_physics_step",
			request.physics_step,
			request.locomotion_state_id
		)
		return SubmissionStatus.WRONG_STEP
	if _request != null:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.DUPLICATE_SUBMISSION,
			&"player.motor.duplicate_motion_submission",
			_active_step,
			request.locomotion_state_id
		)
		return SubmissionStatus.DUPLICATE_SUBMISSION

	_request = request
	_submitted_velocity = request.provisional_velocity
	_last_locomotion_state_id = request.locomotion_state_id
	_accepted_submission_count = 1
	return SubmissionStatus.SUCCESS


func set_next_frame_velocity_baseline(velocity_baseline: Vector3) -> BaselineStatus:
	if not _initialized:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.NOT_INITIALIZED,
			&"player.motor.baseline_not_initialized",
			-1,
			&""
		)
		return BaselineStatus.NOT_INITIALIZED
	if not _has_usable_body():
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_BODY,
			&"player.motor.baseline_invalid_body",
			_active_step,
			&""
		)
		return BaselineStatus.INVALID_BODY
	if _frame_open:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.CONFLICTING_ACTIVE_FRAME,
			&"player.motor.baseline_active_frame",
			_active_step,
			_last_locomotion_state_id
		)
		return BaselineStatus.ACTIVE_FRAME
	if not velocity_baseline.is_finite():
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
			&"player.motor.invalid_velocity_baseline",
			_active_step,
			&""
		)
		return BaselineStatus.INVALID_VELOCITY

	_next_frame_velocity_baseline = velocity_baseline
	_has_next_frame_velocity_baseline = true
	return BaselineStatus.SUCCESS


func resolve_and_commit() -> PlayerMotorCommitResult:
	if not _initialized:
		return _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.NOT_INITIALIZED,
			&"player.motor.commit_not_initialized",
			&""
		)
	if not _has_usable_body():
		var invalid_body_result := _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.INVALID_BODY,
			&"player.motor.commit_invalid_body",
			_last_locomotion_state_id
		)
		_last_commit_result = null
		if _frame_open:
			_request = null
			_close_frame()
		return invalid_body_result
	if not _frame_open:
		if _last_commit_result != null:
			var duplicate_result := _reject_result(
				_last_committed_step,
				PlayerMotorCommitResult.RejectionReason.DUPLICATE_COMMIT,
				&"player.motor.duplicate_commit",
				_last_locomotion_state_id
			)
			if OS.is_debug_build() and _debug_assertions_enabled:
				assert(_last_commit_result == null, "PlayerMotor duplicate commit")
			return duplicate_result
		return _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.NO_ACTIVE_FRAME,
			&"player.motor.no_active_frame_at_commit",
			_last_locomotion_state_id
		)
	if _request == null:
		var missing_result := _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.NO_MOTION_REQUEST,
			&"player.motor.no_motion_request",
			&""
		)
		_close_frame()
		return missing_result

	var request := _request
	var before_position := _initial_position
	var hold_position := request.hold_position
	if request.is_hold_request():
		_body.global_position = hold_position
	_body.velocity = request.provisional_velocity
	_body.move_and_slide()

	_commit_count = 1
	_last_committed_step = _active_step
	_last_closed_step = _active_step
	_committed_velocity = _body.velocity
	var after_position := _body.global_position
	var collisions: Array[KinematicCollision3D] = []
	var collision_candidates: Array[KinematicCollision3D] = []
	var collision_normals: Array[Vector3] = []
	var total_collision_count := _body.get_slide_collision_count()
	var collision_scan_count := mini(total_collision_count, MAX_SCANNED_COLLISIONS)
	for collision_index in range(collision_scan_count):
		var collision := _body.get_slide_collision(collision_index)
		if collision != null:
			collision_candidates.append(collision)
			collision_normals.append(collision.get_normal())
	var prioritized_indices := prioritize_collision_indices(
		collision_normals,
		MAX_REPORTED_COLLISIONS
	)
	for candidate_index in prioritized_indices:
		collisions.append(collision_candidates[candidate_index])

	var result := PlayerMotorCommitResult.new(
		_active_step,
		true,
		PlayerMotorCommitResult.RejectionReason.NONE,
		&"player.motor.commit_succeeded",
		request.locomotion_state_id,
		request.provisional_velocity,
		_committed_velocity,
		before_position,
		after_position,
		request.is_hold_request(),
		hold_position,
		_body.is_on_floor(),
		_body.is_on_wall(),
		_commit_count,
		collisions,
		total_collision_count > MAX_REPORTED_COLLISIONS
			or total_collision_count > MAX_SCANNED_COLLISIONS
	)
	_last_commit_result = result
	_frame_open = false
	return result


func get_frame_initial_velocity() -> Vector3:
	return _initial_velocity


func get_committed_velocity() -> Vector3:
	return _committed_velocity


func get_accepted_submission_count() -> int:
	return _accepted_submission_count


func get_commit_count() -> int:
	return _commit_count


func has_active_motion_frame() -> bool:
	return _frame_open


func abort_motion_frame() -> PlayerMotorCommitResult:
	if not _initialized:
		return _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.NOT_INITIALIZED,
			&"player.motor.abort_not_initialized",
			&""
		)
	if not _frame_open:
		return _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.NO_ACTIVE_FRAME,
			&"player.motor.abort_no_active_frame",
			_last_locomotion_state_id
		)

	var aborted_result := PlayerMotorCommitResult.new(
		_active_step,
		false,
		PlayerMotorCommitResult.RejectionReason.FRAME_ABORTED,
		&"player.motor.frame_aborted",
		_last_locomotion_state_id,
		_submitted_velocity,
		_committed_velocity,
		_initial_position,
		_initial_position,
		_request != null and _request.is_hold_request(),
		_request.hold_position if _request != null else Vector3.ZERO,
		false,
		false,
		0,
		[],
		false
	)
	_last_rejection_reason = PlayerMotorCommitResult.RejectionReason.FRAME_ABORTED
	_last_diagnostic_code = &"player.motor.frame_aborted"
	_request = null
	_last_commit_result = null
	_close_frame()
	return aborted_result


static func prioritize_collision_indices(
	normals: Array[Vector3],
	max_count: int
) -> Array[int]:
	var prioritized: Array[int] = []
	if max_count <= 0:
		return prioritized

	for candidate_index in range(normals.size()):
		var candidate_score := absf(normals[candidate_index].y)
		var insert_at := prioritized.size()
		for prioritized_index in range(prioritized.size()):
			var retained_score := absf(normals[prioritized[prioritized_index]].y)
			if candidate_score < retained_score:
				insert_at = prioritized_index
				break
		if prioritized.size() < max_count:
			prioritized.insert(insert_at, candidate_index)
		elif insert_at < max_count:
			prioritized.insert(insert_at, candidate_index)
			prioritized.resize(max_count)
	return prioritized


func get_last_commit_result() -> PlayerMotorCommitResult:
	return _last_commit_result


func set_diagnostics_enabled(enabled: bool) -> void:
	_diagnostics_enabled = enabled


func set_debug_assertions_enabled(enabled: bool) -> void:
	_debug_assertions_enabled = enabled


func get_diagnostic_snapshot() -> PlayerMotorDiagnosticSnapshot:
	if not _diagnostics_enabled:
		return null
	return PlayerMotorDiagnosticSnapshot.new(
		_last_started_step,
		_initial_velocity,
		_submitted_velocity,
		_committed_velocity,
		_commit_count,
		_last_locomotion_state_id,
		_last_rejection_reason
	)


func _close_frame() -> void:
	_frame_open = false
	_last_closed_step = _active_step
	_last_committed_step = -1


func _reject_result(
	physics_step: int,
	reason: PlayerMotorCommitResult.RejectionReason,
	code: StringName,
	locomotion_id: StringName
) -> PlayerMotorCommitResult:
	_record_rejection(reason, code, physics_step, locomotion_id)
	var body_is_usable := _has_usable_body()
	return PlayerMotorCommitResult.new(
		physics_step,
		false,
		reason,
		code,
		locomotion_id,
		_submitted_velocity,
		_committed_velocity,
		_initial_position,
		_body.global_position if body_is_usable else _initial_position,
		_request != null and _request.is_hold_request(),
		_request.hold_position if _request != null else Vector3.ZERO,
		_body.is_on_floor() if body_is_usable else false,
		_body.is_on_wall() if body_is_usable else false,
		_commit_count,
		[],
		false
	)


func _has_usable_body() -> bool:
	return _initialized and is_instance_valid(_body) and _body.is_inside_tree()


func _record_rejection(
	reason: PlayerMotorCommitResult.RejectionReason,
	code: StringName,
	physics_step: int,
	locomotion_id: StringName
) -> void:
	_last_rejection_reason = reason
	_last_diagnostic_code = code
	_game_log.record_invariant(
		code,
		DiagnosticContext.new(physics_step, locomotion_id, _reason_to_id(reason), -1)
	)


func _reason_to_id(reason: PlayerMotorCommitResult.RejectionReason) -> StringName:
	return StringName(PlayerMotorCommitResult.RejectionReason.keys()[int(reason)].to_lower())


func _on_diagnostic_recorded(event: DiagnosticEvent) -> void:
	diagnostic_recorded.emit(event)
