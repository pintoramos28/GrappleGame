class_name PlayerMotor
extends Node


enum InitializationStatus {
	NOT_INITIALIZED,
	SUCCESS,
	MISSING_BODY,
	WRONG_BODY,
	BODY_NOT_IN_TREE,
	ALREADY_INITIALIZED,
	INVALID_GROUND_PROFILE,
	INVALID_WALL_PROFILE,
	CONTACT_PROVIDER_UNAVAILABLE,
}

enum FrameStatus {
	SUCCESS,
	NOT_INITIALIZED,
	INVALID_BODY,
	DUPLICATE_ACTIVE_FRAME,
	DUPLICATE_STEP,
	NON_MONOTONIC_STEP,
	CONFLICTING_ACTIVE_FRAME,
	INVALID_DELTA,
	INVALID_CONTACT_FRAME,
}

enum SubmissionStatus {
	SUCCESS,
	NOT_INITIALIZED,
	INVALID_BODY,
	NO_ACTIVE_FRAME,
	STALE_STEP,
	WRONG_STEP,
	INVALID_REQUEST,
	ILLEGAL_PHASE_OR_KIND,
	INVALID_SOURCE,
	NON_FINITE_VALUE,
	DUPLICATE_SOURCE,
	DUPLICATE_OCCURRENCE,
	ALREADY_RESOLVED,
	EXCLUSIVE_POLICY_CONFLICT,
	UNSUPPORTED_CAP_SCOPE,
	INVALID_WALL_CONSTRAINT,
	OVERFLOW,
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
const MAX_ACCEPTED_SUBMISSIONS := 16
const MAX_REJECTED_CONTRIBUTIONS := 16
const MAX_STABLE_ID_LENGTH := 96
const CAP_SCOPE_TOTAL_SPEED: StringName = PlayerMotorSubmission.CAP_SCOPE_TOTAL_SPEED

signal diagnostic_recorded(event: DiagnosticEvent)


@export_group("Authoritative Contact")
## Required authored ground query profile. The profile is validated and locked at initialization.
@export var ground_probe: GroundProbe
## Optional authored wall query profile. Invalid wall data disables wall contact only.
@export var wall_probe: WallProbe
## Direct test fixtures may use sparse steps; the scene-owned motor stays strict.
@export var contact_lifecycle_strict := true


var _body: CharacterBody3D
var _initialized := false
var _contact_provider: PlayerContactProvider
var _last_contact_frame: ContactFrame
var _contact_bootstrapped := false
var _contact_lifecycle_is_strict := true
var _frame_open := false
var _active_step := -1
var _last_started_step := -1
var _last_closed_step := -1
var _last_committed_step := -1
var _delta_seconds := 1.0 / 60.0
var _initial_position := Vector3.ZERO
var _initial_velocity := Vector3.ZERO
var _submitted_velocity := Vector3.ZERO
var _committed_velocity := Vector3.ZERO
var _last_locomotion_state_id: StringName = &""
var _last_rejection_reason := PlayerMotorCommitResult.RejectionReason.NONE
var _last_diagnostic_code: StringName = &""
var _last_commit_result: PlayerMotorCommitResult
var _submissions: Array[PlayerMotorSubmission] = []
var _accepted_submission_count := 0
var _commit_count := 0
var _submission_keys: Dictionary = {}
var _one_shot_occurrence_keys: Dictionary = {}
var _phase_order: Array[StringName] = []
var _phase_intermediates: Array[Dictionary] = []
var _accepted_sources_by_phase: Array = []
var _rejected_contributions: Array[Dictionary] = []
var _applied_constraints: Array[StringName] = []
var _applied_caps: Array[StringName] = []
var _rejected_contribution_overflow_count := 0
var _rejected_contributions_truncated := false
var _has_next_frame_velocity_baseline := false
var _next_frame_velocity_baseline := Vector3.ZERO
var _diagnostics_enabled := false
var _debug_assertions_enabled := true
var _game_log: GameLog = GameLog.new()


func _init() -> void:
	_game_log.diagnostic_recorded.connect(_on_diagnostic_recorded)


func initialize(body: Node, strict_contact_lifecycle: bool = true) -> InitializationStatus:
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
	if ground_probe == null:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.CONTACT_PROVIDER_UNAVAILABLE,
			&"player.motor.missing_ground_probe",
			-1,
			&""
		)
		return InitializationStatus.INVALID_GROUND_PROFILE
	_contact_provider = PlayerContactProvider.new()
	var provider_status := _contact_provider.initialize(body, ground_probe, wall_probe)
	if provider_status != PlayerContactProvider.InitializationStatus.SUCCESS:
		_contact_provider = null
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.CONTACT_PROVIDER_UNAVAILABLE,
			&"player.motor.contact_provider_initialization_failed",
			-1,
			&""
		)
		return InitializationStatus.CONTACT_PROVIDER_UNAVAILABLE
	_contact_lifecycle_is_strict = strict_contact_lifecycle and contact_lifecycle_strict
	_contact_provider.set_strict_lifecycle(_contact_lifecycle_is_strict)
	_initialized = true
	_contact_bootstrapped = false
	_last_contact_frame = null
	_has_next_frame_velocity_baseline = false
	_next_frame_velocity_baseline = Vector3.ZERO
	_last_rejection_reason = PlayerMotorCommitResult.RejectionReason.NONE
	_last_diagnostic_code = &""
	return InitializationStatus.SUCCESS


func is_initialized() -> bool:
	return _initialized


func bootstrap_contact_frame() -> ContactFrame:
	if not _initialized or _contact_provider == null:
		return ContactFrame.failure(0, ContactFrame.Status.NOT_INITIALIZED, ContactFrame.Origin.BOOTSTRAP)
	if _contact_bootstrapped:
		return _last_contact_frame
	var frame := _contact_provider.bootstrap()
	if frame.success:
		_contact_bootstrapped = true
		_last_contact_frame = frame
	else:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.CONTACT_FRAME_FAILED,
			&"player.motor.contact_bootstrap_failed",
			0,
			&""
		)
	return frame


func get_previous_contact_frame() -> ContactFrame:
	return _last_contact_frame


func get_contact_provider() -> PlayerContactProvider:
	return _contact_provider


static func initialization_status_id(status: InitializationStatus) -> StringName:
	return StringName(InitializationStatus.keys()[int(status)].to_lower())


func begin_motion_frame(
	physics_step: int,
	delta_seconds: float = 1.0 / 60.0
) -> FrameStatus:
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
	if is_nan(delta_seconds) or is_inf(delta_seconds) or delta_seconds <= 0.0:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
			&"player.motor.invalid_delta_seconds",
			physics_step,
			&""
		)
		return FrameStatus.INVALID_DELTA
	if _contact_provider == null:
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.CONTACT_PROVIDER_UNAVAILABLE,
			&"player.motor.contact_provider_unavailable",
			physics_step,
			&""
		)
		return FrameStatus.INVALID_CONTACT_FRAME
	if not _contact_bootstrapped:
		var bootstrap_frame := bootstrap_contact_frame()
		if bootstrap_frame == null or not bootstrap_frame.success:
			_record_rejection(
				PlayerMotorCommitResult.RejectionReason.CONTACT_FRAME_FAILED,
				&"player.motor.contact_bootstrap_failed",
				physics_step,
				&""
			)
			return FrameStatus.INVALID_CONTACT_FRAME

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
	_delta_seconds = delta_seconds
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
	_last_commit_result = null
	_accepted_submission_count = 0
	_commit_count = 0
	_clear_frame_facts()
	return FrameStatus.SUCCESS


func select_terminal_policy(source_id: StringName) -> SubmissionStatus:
	return _submit_submission(PlayerMotorSubmission.terminal(_active_step, source_id))


func select_state_policy(
	source_id: StringName,
	locomotion_state_id: StringName = &""
) -> SubmissionStatus:
	var state_id := locomotion_state_id if locomotion_state_id != &"" else source_id
	return _submit_submission(
		PlayerMotorSubmission.state_policy(_active_step, source_id, state_id)
	)


func submit_base_motion(
	source_id: StringName,
	target_velocity: Vector3,
	rate_mps2: float,
	horizontal_only: bool = true,
	zero_vertical: bool = false
) -> SubmissionStatus:
	return _submit_submission(
		PlayerMotorSubmission.base_motion(
			_active_step,
			source_id,
			target_velocity,
			rate_mps2,
			horizontal_only,
			zero_vertical
		)
	)


func submit_gravity(source_id: StringName, acceleration_mps2: Vector3) -> SubmissionStatus:
	return _submit_submission(
		PlayerMotorSubmission.gravity(_active_step, source_id, acceleration_mps2)
	)


func submit_sustained_acceleration(
	source_id: StringName,
	acceleration_mps2: Vector3
) -> SubmissionStatus:
	return _submit_submission(
		PlayerMotorSubmission.sustained_acceleration(
			_active_step,
			source_id,
			acceleration_mps2
		)
	)


func submit_one_shot_impulse(
	source_id: StringName,
	occurrence_id: StringName,
	velocity_delta: Vector3
) -> SubmissionStatus:
	return _submit_submission(
		PlayerMotorSubmission.one_shot_impulse(
			_active_step,
			source_id,
			occurrence_id,
			velocity_delta
		)
	)


func submit_wall_run_constraint(
	source_id: StringName,
	wall_normal: Vector3,
	wall_direction: Vector3
) -> SubmissionStatus:
	return _submit_submission(
		PlayerMotorSubmission.wall_run_constraint(
			_active_step,
			source_id,
			wall_normal,
			wall_direction
		)
	)


func submit_wall_stick_hold(
	source_id: StringName,
	hold_position: Vector3
) -> SubmissionStatus:
	return _submit_submission(
		PlayerMotorSubmission.wall_stick_hold(
			_active_step,
			source_id,
			hold_position
		)
	)


func submit_total_speed_cap(
	source_id: StringName,
	limit_mps: float,
	scope: StringName = CAP_SCOPE_TOTAL_SPEED
) -> SubmissionStatus:
	return _submit_submission(
		PlayerMotorSubmission.speed_cap(_active_step, source_id, scope, limit_mps)
	)


func _submit_submission(submission: PlayerMotorSubmission) -> SubmissionStatus:
	if not _initialized:
		return _reject_submission(
			SubmissionStatus.NOT_INITIALIZED,
			PlayerMotorCommitResult.RejectionReason.NOT_INITIALIZED,
			&"player.motor.submit_not_initialized",
			-1,
			&"",
			submission
		)
	if not _has_usable_body():
		return _reject_submission(
			SubmissionStatus.INVALID_BODY,
			PlayerMotorCommitResult.RejectionReason.INVALID_BODY,
			&"player.motor.submit_invalid_body",
			_active_step,
			&"",
			submission
		)
	if not _frame_open:
		return _reject_submission(
			SubmissionStatus.NO_ACTIVE_FRAME,
			PlayerMotorCommitResult.RejectionReason.NO_ACTIVE_FRAME,
			&"player.motor.no_active_motion_frame",
			_active_step,
			&"",
			submission
		)
	if submission == null:
		return _reject_submission(
			SubmissionStatus.INVALID_REQUEST,
			PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
			&"player.motor.invalid_motion_submission",
			_active_step,
			&"",
			null
		)
	if submission.physics_step != _active_step:
		var step_status := SubmissionStatus.WRONG_STEP
		var step_reason := PlayerMotorCommitResult.RejectionReason.WRONG_STEP
		var step_code := &"player.motor.wrong_physics_step"
		if submission.physics_step < _active_step:
			step_status = SubmissionStatus.STALE_STEP
			step_reason = PlayerMotorCommitResult.RejectionReason.STALE_STEP
			step_code = &"player.motor.stale_physics_step"
		return _reject_submission(
			step_status,
			step_reason,
			step_code,
			submission.physics_step,
			submission.source_id,
			submission
		)
	if not submission.has_valid_kind_and_phase():
		return _reject_submission(
			SubmissionStatus.ILLEGAL_PHASE_OR_KIND,
			PlayerMotorCommitResult.RejectionReason.ILLEGAL_PHASE_OR_KIND,
			&"player.motor.illegal_phase_or_kind",
			_active_step,
			submission.source_id,
			submission
		)
	if not _is_stable_id(submission.source_id):
		var empty_source := submission.source_id == &""
		return _reject_submission(
			SubmissionStatus.INVALID_SOURCE,
			PlayerMotorCommitResult.RejectionReason.EMPTY_SOURCE_ID
				if empty_source
				else PlayerMotorCommitResult.RejectionReason.UNSTABLE_SOURCE_ID,
			&"player.motor.empty_source_id"
				if empty_source
				else &"player.motor.unstable_source_id",
			_active_step,
			submission.source_id,
			submission
		)
	if submission.kind == PlayerMotorSubmission.Kind.STATE_POLICY:
		if not _is_stable_id(submission.locomotion_state_id):
			return _reject_submission(
				SubmissionStatus.INVALID_SOURCE,
				PlayerMotorCommitResult.RejectionReason.UNSTABLE_SOURCE_ID,
				&"player.motor.unstable_locomotion_state_id",
				_active_step,
				submission.source_id,
				submission
			)
	if submission.kind == PlayerMotorSubmission.Kind.ONE_SHOT_IMPULSE:
		if not _is_stable_id(submission.occurrence_id):
			return _reject_submission(
				SubmissionStatus.INVALID_SOURCE,
				PlayerMotorCommitResult.RejectionReason.UNSTABLE_SOURCE_ID,
				&"player.motor.unstable_occurrence_id",
				_active_step,
				submission.source_id,
				submission
			)
	if submission.kind == PlayerMotorSubmission.Kind.SPEED_CAP:
		if submission.cap_limit_mps <= 0.0:
			return _reject_submission(
				SubmissionStatus.INVALID_REQUEST,
				PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
				&"player.motor.invalid_speed_cap",
				_active_step,
				submission.source_id,
				submission
			)
		if submission.cap_scope != CAP_SCOPE_TOTAL_SPEED:
			return _reject_submission(
				SubmissionStatus.UNSUPPORTED_CAP_SCOPE,
				PlayerMotorCommitResult.RejectionReason.UNSUPPORTED_CAP_SCOPE,
				&"player.motor.unsupported_cap_scope",
				_active_step,
				submission.source_id,
				submission
			)
	if submission.kind == PlayerMotorSubmission.Kind.BASE_POLICY and submission.rate_mps2 < 0.0:
		return _reject_submission(
			SubmissionStatus.INVALID_REQUEST,
			PlayerMotorCommitResult.RejectionReason.INVALID_REQUEST,
			&"player.motor.invalid_base_rate",
			_active_step,
			submission.source_id,
			submission
		)
	if not submission.is_finite_payload():
		return _reject_submission(
			SubmissionStatus.NON_FINITE_VALUE,
			PlayerMotorCommitResult.RejectionReason.NON_FINITE_VALUE,
			&"player.motor.non_finite_value",
			_active_step,
			submission.source_id,
			 submission
		)
	if submission.kind == PlayerMotorSubmission.Kind.WALL_RUN_CONSTRAINT:
		if not submission.has_valid_wall_constraint_vectors():
			return _reject_submission(
				SubmissionStatus.INVALID_WALL_CONSTRAINT,
				PlayerMotorCommitResult.RejectionReason.INVALID_WALL_CONSTRAINT,
				&"player.motor.invalid_wall_constraint",
				_active_step,
				submission.source_id,
				submission
			)

	var source_key := "%d|%s" % [int(submission.kind), String(submission.source_id)]
	var occurrence_key := ""
	if submission.kind == PlayerMotorSubmission.Kind.ONE_SHOT_IMPULSE:
		occurrence_key = "%s|%s" % [source_key, String(submission.occurrence_id)]
		if _one_shot_occurrence_keys.has(occurrence_key):
			return _reject_submission(
				SubmissionStatus.DUPLICATE_OCCURRENCE,
				PlayerMotorCommitResult.RejectionReason.DUPLICATE_OCCURRENCE,
				&"player.motor.duplicate_occurrence",
				_active_step,
				submission.source_id,
				submission
			)
	elif _submission_keys.has(source_key):
		return _reject_submission(
			SubmissionStatus.DUPLICATE_SOURCE,
			PlayerMotorCommitResult.RejectionReason.DUPLICATE_SOURCE,
			&"player.motor.duplicate_source",
			_active_step,
			submission.source_id,
			submission
		)
	if _accepted_submission_count >= MAX_ACCEPTED_SUBMISSIONS:
		return _reject_submission(
			SubmissionStatus.OVERFLOW,
			PlayerMotorCommitResult.RejectionReason.OVERFLOW,
			&"player.motor.submission_overflow",
			_active_step,
			submission.source_id,
			submission
		)
	if submission.kind == PlayerMotorSubmission.Kind.ONE_SHOT_IMPULSE:
		_one_shot_occurrence_keys[occurrence_key] = true
	_submission_keys[source_key] = true
	_submissions.append(submission)
	_accepted_submission_count += 1
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
			PlayerMotorCommitResult.RejectionReason.NON_FINITE_VALUE,
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
			_close_frame()
		return invalid_body_result
	if not _frame_open:
		if _last_commit_result != null:
			return _reject_result(
				_last_committed_step,
				PlayerMotorCommitResult.RejectionReason.DUPLICATE_COMMIT,
				&"player.motor.duplicate_commit",
				_last_locomotion_state_id
			)
		return _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.NO_ACTIVE_FRAME,
			&"player.motor.no_active_frame_at_commit",
			_last_locomotion_state_id
		)

	var validation_reason := _validate_frame()
	if validation_reason != PlayerMotorCommitResult.RejectionReason.NONE:
		var validation_code := _reason_to_code(validation_reason)
		var validation_result := _reject_result(
			_active_step,
			validation_reason,
			validation_code,
			_last_locomotion_state_id
		)
		_close_frame()
		return validation_result

	var working_velocity := _initial_velocity
	var hold_request := false
	var requested_hold_position := Vector3.ZERO
	_phase_intermediates.clear()
	_applied_constraints.clear()
	_applied_caps.clear()

	for phase in MotorPhase.canonical_order():
		var before_velocity := working_velocity
		var phase_submissions := _sorted_submissions_for_phase(phase)
		var accepted_sources: Array[Dictionary] = []
		for submission in phase_submissions:
			accepted_sources.append(_submission_identity(submission))
		_accepted_sources_by_phase[phase] = accepted_sources.duplicate()
		var applied_sources: Array[StringName] = []

		match phase:
			MotorPhase.Phase.TERMINAL_COMMANDS:
				for submission in phase_submissions:
					applied_sources.append(submission.source_id)

			MotorPhase.Phase.STATE_GATING_AND_INTERRUPTS:
				var state_submissions := _submissions_of_kind(
					PlayerMotorSubmission.Kind.STATE_POLICY
				)
				if not state_submissions.is_empty():
					_last_locomotion_state_id = state_submissions[0].locomotion_state_id
					applied_sources.append(state_submissions[0].source_id)

			MotorPhase.Phase.BASE_LOCOMOTION_AND_GRAVITY:
				var base_submissions := _submissions_of_kind(
					PlayerMotorSubmission.Kind.BASE_POLICY
				)
				if not base_submissions.is_empty():
					var base_submission := base_submissions[0]
					working_velocity = _apply_base_submission(working_velocity, base_submission)
					applied_sources.append(base_submission.source_id)
					for submission in _sorted_submissions_of_kind(
						PlayerMotorSubmission.Kind.GRAVITY
					):
						working_velocity += submission.acceleration_mps2 * _delta_seconds
						applied_sources.append(submission.source_id)

			MotorPhase.Phase.SUSTAINED_INFLUENCES:
				for submission in phase_submissions:
					working_velocity += submission.acceleration_mps2 * _delta_seconds
					applied_sources.append(submission.source_id)

			MotorPhase.Phase.ONE_SHOT_IMPULSES:
				for submission in phase_submissions:
					working_velocity += submission.velocity_delta
					applied_sources.append(submission.source_id)

			MotorPhase.Phase.CONSTRAINTS_AND_REDIRECTIONS:
				var hold_submissions := _submissions_of_kind(
					PlayerMotorSubmission.Kind.WALL_STICK_HOLD
				)
				if not hold_submissions.is_empty():
					hold_request = true
					requested_hold_position = hold_submissions[0].hold_position
					working_velocity = Vector3.ZERO
					_applied_constraints.append(hold_submissions[0].source_id)
					applied_sources.append(hold_submissions[0].source_id)
				else:
					for submission in phase_submissions:
						if submission.kind != PlayerMotorSubmission.Kind.WALL_RUN_CONSTRAINT:
							continue
						var wall_direction := Vector3(
							submission.wall_direction.x,
							0.0,
							submission.wall_direction.z
						).normalized()
						var horizontal_velocity := Vector3(
							working_velocity.x,
							0.0,
							working_velocity.z
						)
						var wall_relative_speed := horizontal_velocity.dot(wall_direction)
						var redirected_horizontal := wall_direction * wall_relative_speed
						working_velocity.x = redirected_horizontal.x
						working_velocity.z = redirected_horizontal.z
						var wall_normal := submission.wall_normal.normalized()
						var outward_speed := working_velocity.dot(wall_normal)
						if outward_speed > 0.0:
							working_velocity -= wall_normal * outward_speed
						_applied_constraints.append(submission.source_id)
						applied_sources.append(submission.source_id)

			MotorPhase.Phase.CAPS_AND_FINAL_COMMIT:
				for submission in phase_submissions:
					if submission.cap_scope == CAP_SCOPE_TOTAL_SPEED:
						working_velocity = working_velocity.limit_length(submission.cap_limit_mps)
					_applied_caps.append(submission.source_id)
					applied_sources.append(submission.source_id)

		_record_phase_intermediate(
			phase,
			before_velocity,
			working_velocity,
			accepted_sources,
			applied_sources
		)

	if not working_velocity.is_finite():
		var non_finite_result := _reject_result(
			_active_step,
			PlayerMotorCommitResult.RejectionReason.NON_FINITE_VALUE,
			&"player.motor.non_finite_resolved_velocity",
			_last_locomotion_state_id
		)
		_close_frame()
		return non_finite_result

	_submitted_velocity = working_velocity
	if hold_request:
		_body.global_position = requested_hold_position
	_body.velocity = working_velocity
	_body.move_and_slide()

	_commit_count = 1
	_last_committed_step = _active_step
	_last_closed_step = _active_step
	_committed_velocity = _body.velocity
	var after_position := _body.global_position
	var contact_frame := _contact_provider.publish_committed_frame(
		_active_step,
		_delta_seconds,
		_submitted_velocity
	)
	if contact_frame == null or not contact_frame.success:
		var contact_failure := _make_result(
			_active_step,
			false,
			PlayerMotorCommitResult.RejectionReason.CONTACT_FRAME_FAILED,
			&"player.motor.contact_frame_failed",
			_last_locomotion_state_id,
			_submitted_velocity,
			_committed_velocity,
			_initial_position,
			after_position,
			hold_request,
			requested_hold_position,
			_commit_count,
			contact_frame,
			true
		)
		_record_rejection(
			PlayerMotorCommitResult.RejectionReason.CONTACT_FRAME_FAILED,
			&"player.motor.contact_frame_failed",
			_active_step,
			_last_locomotion_state_id
		)
		_last_commit_result = contact_failure
		_frame_open = false
		_last_closed_step = _active_step
		return contact_failure
	_last_contact_frame = contact_frame

	var result := _make_result(
		_active_step,
		true,
		PlayerMotorCommitResult.RejectionReason.NONE,
		&"player.motor.commit_succeeded",
		_last_locomotion_state_id,
		_submitted_velocity,
		_committed_velocity,
		_initial_position,
		after_position,
		hold_request,
		requested_hold_position,
		_commit_count,
		contact_frame,
		contact_frame.overflowed
	)
	_last_commit_result = result
	_frame_open = false
	_last_closed_step = _active_step
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

	var aborted_result := _make_result(
		_active_step,
		false,
		PlayerMotorCommitResult.RejectionReason.FRAME_ABORTED,
		&"player.motor.frame_aborted",
		_last_locomotion_state_id,
		_submitted_velocity,
		_committed_velocity,
		_initial_position,
		_initial_position,
		_has_hold_submission(),
		_get_hold_position(),
		0,
		ContactFrame.failure(_active_step, ContactFrame.Status.INVALID_DATA),
		false
	)
	_last_rejection_reason = PlayerMotorCommitResult.RejectionReason.FRAME_ABORTED
	_last_diagnostic_code = &"player.motor.frame_aborted"
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
		_last_rejection_reason,
		_delta_seconds,
		_phase_order,
		_phase_intermediates,
		_accepted_sources_by_phase,
		_rejected_contributions,
		_applied_constraints,
		_applied_caps,
		_rejected_contribution_overflow_count,
		_rejected_contributions_truncated,
		_last_contact_frame,
		_contact_provider.get_diagnostic_snapshot() if _contact_provider != null else null
	)


func _validate_frame() -> PlayerMotorCommitResult.RejectionReason:
	var terminal_count := _submissions_of_kind(
		PlayerMotorSubmission.Kind.TERMINAL_POLICY
	).size()
	if terminal_count > 1:
		return PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT
	var state_count := _submissions_of_kind(
		PlayerMotorSubmission.Kind.STATE_POLICY
	).size()
	if state_count == 0:
		return PlayerMotorCommitResult.RejectionReason.MISSING_REQUIRED_POLICY
	if state_count > 1:
		return PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT

	var base_count := _submissions_of_kind(
		PlayerMotorSubmission.Kind.BASE_POLICY
	).size()
	var hold_count := _submissions_of_kind(
		PlayerMotorSubmission.Kind.WALL_STICK_HOLD
	).size()
	if hold_count > 1 or base_count > 1:
		return PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT
	if hold_count == 1:
		for submission in _submissions:
			if submission.kind == PlayerMotorSubmission.Kind.STATE_POLICY:
				continue
			if submission.kind == PlayerMotorSubmission.Kind.WALL_STICK_HOLD:
				continue
			return PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT
	elif base_count != 1:
		return PlayerMotorCommitResult.RejectionReason.MISSING_REQUIRED_POLICY
	return PlayerMotorCommitResult.RejectionReason.NONE


func _apply_base_submission(
	current_velocity: Vector3,
	submission: PlayerMotorSubmission
) -> Vector3:
	var resolved := current_velocity
	var distance := submission.rate_mps2 * _delta_seconds
	if submission.horizontal_only:
		resolved.x = move_toward(resolved.x, submission.target_velocity.x, distance)
		resolved.z = move_toward(resolved.z, submission.target_velocity.z, distance)
	else:
		resolved.x = move_toward(resolved.x, submission.target_velocity.x, distance)
		resolved.y = move_toward(resolved.y, submission.target_velocity.y, distance)
		resolved.z = move_toward(resolved.z, submission.target_velocity.z, distance)
	if submission.zero_vertical:
		resolved.y = 0.0
	return resolved


func _sorted_submissions_for_phase(phase: int) -> Array[PlayerMotorSubmission]:
	var entries: Array[PlayerMotorSubmission] = []
	for submission in _submissions:
		if int(submission.phase) == phase:
			entries.append(submission)
	entries.sort_custom(Callable(self, "_compare_submissions"))
	return entries


func _sorted_submissions_of_kind(kind: PlayerMotorSubmission.Kind) -> Array[PlayerMotorSubmission]:
	var entries := _submissions_of_kind(kind)
	entries.sort_custom(Callable(self, "_compare_submissions"))
	return entries


func _submissions_of_kind(kind: PlayerMotorSubmission.Kind) -> Array[PlayerMotorSubmission]:
	var entries: Array[PlayerMotorSubmission] = []
	for submission in _submissions:
		if submission.kind == kind:
			entries.append(submission)
	return entries


func _compare_submissions(
	left: PlayerMotorSubmission,
	right: PlayerMotorSubmission
) -> bool:
	var left_key := "%s|%s" % [String(left.source_id), String(left.occurrence_id)]
	var right_key := "%s|%s" % [String(right.source_id), String(right.occurrence_id)]
	return left_key < right_key


func _record_phase_intermediate(
	phase: int,
	before_velocity: Vector3,
	after_velocity: Vector3,
	accepted_sources: Array[Dictionary],
	applied_sources: Array[StringName]
) -> void:
	_phase_intermediates.append({
		"phase": phase,
		"id": MotorPhase.phase_id(phase),
		"before_velocity": before_velocity,
		"after_velocity": after_velocity,
		"accepted_sources": accepted_sources.duplicate(true),
		"applied_sources": applied_sources.duplicate(),
	})


func _submission_identity(submission: PlayerMotorSubmission) -> Dictionary:
	return {
		"source_id": submission.source_id,
		"kind": int(submission.kind),
		"occurrence_id": submission.occurrence_id,
	}


func _make_result(
	physics_step: int,
	was_successful: bool,
	reason: PlayerMotorCommitResult.RejectionReason,
	code: StringName,
	locomotion_id: StringName,
	pre_slide_velocity: Vector3,
	post_slide_velocity: Vector3,
	before_position: Vector3,
	after_position: Vector3,
	hold_request: bool,
	requested_hold_position: Vector3,
	actual_commit_count: int,
	contact_frame: ContactFrame,
	contact_facts_were_truncated: bool
) -> PlayerMotorCommitResult:
	return PlayerMotorCommitResult.new(
		physics_step,
		was_successful,
		reason,
		code,
		locomotion_id,
		pre_slide_velocity,
		post_slide_velocity,
		before_position,
		after_position,
		hold_request,
		requested_hold_position,
		actual_commit_count,
		contact_frame,
		contact_facts_were_truncated,
		_delta_seconds,
		_phase_order,
		_phase_intermediates,
		_accepted_sources_by_phase,
		_rejected_contributions,
		_applied_constraints,
		_applied_caps,
		_rejected_contribution_overflow_count,
		_rejected_contributions_truncated
	)


func _reject_result(
	physics_step: int,
	reason: PlayerMotorCommitResult.RejectionReason,
	code: StringName,
	locomotion_id: StringName
) -> PlayerMotorCommitResult:
	_record_rejection(reason, code, physics_step, locomotion_id)
	var body_is_usable := _has_usable_body()
	return _make_result(
		physics_step,
		false,
		reason,
		code,
		locomotion_id,
		_submitted_velocity,
		_committed_velocity,
		_initial_position,
		_body.global_position if body_is_usable else _initial_position,
		_has_hold_submission(),
		_get_hold_position(),
		_commit_count,
		ContactFrame.failure(physics_step, ContactFrame.Status.INVALID_DATA),
		false
	)


func _reject_submission(
	status: SubmissionStatus,
	reason: PlayerMotorCommitResult.RejectionReason,
	code: StringName,
	physics_step: int,
	locomotion_id: StringName,
	submission: PlayerMotorSubmission
) -> SubmissionStatus:
	_record_rejection(
		reason,
		code,
		physics_step,
		locomotion_id,
		submission.source_id if submission != null else &"",
		int(submission.kind) if submission != null else -1,
		submission.occurrence_id if submission != null else &""
	)
	return status


func _has_hold_submission() -> bool:
	return not _submissions_of_kind(PlayerMotorSubmission.Kind.WALL_STICK_HOLD).is_empty()


func _get_hold_position() -> Vector3:
	var hold_submissions := _submissions_of_kind(PlayerMotorSubmission.Kind.WALL_STICK_HOLD)
	return hold_submissions[0].hold_position if not hold_submissions.is_empty() else Vector3.ZERO


func _close_frame() -> void:
	_frame_open = false
	_last_closed_step = _active_step


func _clear_frame_facts() -> void:
	_submissions.clear()
	_submission_keys.clear()
	_one_shot_occurrence_keys.clear()
	_phase_order = MotorPhase.canonical_phase_ids()
	_phase_intermediates.clear()
	_accepted_sources_by_phase.clear()
	for _phase in range(MotorPhase.PHASE_COUNT):
		_accepted_sources_by_phase.append([])
	_rejected_contributions.clear()
	_applied_constraints.clear()
	_applied_caps.clear()
	_rejected_contribution_overflow_count = 0
	_rejected_contributions_truncated = false


func _record_rejection(
	reason: PlayerMotorCommitResult.RejectionReason,
	code: StringName,
	physics_step: int,
	locomotion_id: StringName,
	source_id: StringName = &"",
	kind: int = -1,
	occurrence_id: StringName = &""
) -> void:
	_last_rejection_reason = reason
	_last_diagnostic_code = code
	_append_rejected_contribution({
		"physics_step": physics_step,
		"source_id": source_id,
		"occurrence_id": occurrence_id,
		"kind": kind,
		"reason": reason,
		"diagnostic_code": code,
	})
	_game_log.record_invariant(
		code,
		DiagnosticContext.new(
			physics_step,
			locomotion_id,
			_reason_to_id(reason),
			kind,
			source_id
		)
	)


func _append_rejected_contribution(record: Dictionary) -> void:
	if _rejected_contributions.size() >= MAX_REJECTED_CONTRIBUTIONS:
		_rejected_contribution_overflow_count += 1
		_rejected_contributions_truncated = true
		return
	_rejected_contributions.append(record.duplicate(true))


func _reason_to_id(reason: PlayerMotorCommitResult.RejectionReason) -> StringName:
	return StringName(PlayerMotorCommitResult.RejectionReason.keys()[int(reason)].to_lower())


func _reason_to_code(reason: PlayerMotorCommitResult.RejectionReason) -> StringName:
	match reason:
		PlayerMotorCommitResult.RejectionReason.MISSING_REQUIRED_POLICY:
			return &"player.motor.missing_required_policy"
		PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT:
			return &"player.motor.exclusive_policy_conflict"
		_:
			return StringName("player.motor.%s" % String(_reason_to_id(reason)))


static func is_isolated_submission_status(status: SubmissionStatus) -> bool:
	match status:
		SubmissionStatus.SUCCESS, SubmissionStatus.NOT_INITIALIZED, SubmissionStatus.INVALID_BODY, SubmissionStatus.NO_ACTIVE_FRAME, SubmissionStatus.STALE_STEP, SubmissionStatus.WRONG_STEP, SubmissionStatus.ALREADY_RESOLVED:
			return false
		_:
			return true


func _is_stable_id(value: StringName) -> bool:
	var text := String(value)
	if text.is_empty() or text.length() > MAX_STABLE_ID_LENGTH:
		return false
	var segments := text.split(".")
	if segments.size() < 2:
		return false
	for segment in segments:
		if segment.is_empty():
			return false
		var first_code := segment.unicode_at(0)
		if first_code < 97 or first_code > 122:
			return false
		for character in segment:
			var code := character.unicode_at(0)
			if not (
				(code >= 97 and code <= 122)
				or (code >= 48 and code <= 57)
				or code == 95
			):
				return false
	return true


func _has_usable_body() -> bool:
	return _initialized and is_instance_valid(_body) and _body.is_inside_tree()


func _on_diagnostic_recorded(event: DiagnosticEvent) -> void:
	diagnostic_recorded.emit(event)
