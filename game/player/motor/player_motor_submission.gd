class_name PlayerMotorSubmission
extends RefCounted


enum Kind {
	TERMINAL_POLICY,
	STATE_POLICY,
	BASE_POLICY,
	GRAVITY,
	SUSTAINED_ACCELERATION,
	ONE_SHOT_IMPULSE,
	WALL_RUN_CONSTRAINT,
	WALL_STICK_HOLD,
	SPEED_CAP,
}


const CAP_SCOPE_TOTAL_SPEED: StringName = &"total_speed"
const MIN_VALID_WALL_VECTOR_LENGTH_SQUARED := 0.000001


var physics_step: int:
	get:
		return _physics_step

var phase: MotorPhase.Phase:
	get:
		return _phase

var kind: Kind:
	get:
		return _kind

var source_id: StringName:
	get:
		return _source_id

var occurrence_id: StringName:
	get:
		return _occurrence_id

var locomotion_state_id: StringName:
	get:
		return _locomotion_state_id

var target_velocity: Vector3:
	get:
		return _target_velocity

var acceleration_mps2: Vector3:
	get:
		return _acceleration_mps2

var rate_mps2: float:
	get:
		return _rate_mps2

var velocity_delta: Vector3:
	get:
		return _velocity_delta

var wall_normal: Vector3:
	get:
		return _wall_normal

var wall_direction: Vector3:
	get:
		return _wall_direction

var hold_position: Vector3:
	get:
		return _hold_position

var cap_scope: StringName:
	get:
		return _cap_scope

var cap_limit_mps: float:
	get:
		return _cap_limit_mps

var horizontal_only: bool:
	get:
		return _horizontal_only

var zero_vertical: bool:
	get:
		return _zero_vertical

var _physics_step: int
var _phase: MotorPhase.Phase
var _kind: Kind
var _source_id: StringName
var _occurrence_id: StringName
var _locomotion_state_id: StringName
var _target_velocity: Vector3
var _acceleration_mps2: Vector3
var _rate_mps2: float
var _velocity_delta: Vector3
var _wall_normal: Vector3
var _wall_direction: Vector3
var _hold_position: Vector3
var _cap_scope: StringName
var _cap_limit_mps: float
var _horizontal_only: bool
var _zero_vertical: bool


func _init(
	submission_kind: Kind,
	submission_phase: MotorPhase.Phase,
	step: int,
	source: StringName,
	occurrence: StringName = &"",
	state_id: StringName = &"",
	target: Vector3 = Vector3.ZERO,
	acceleration: Vector3 = Vector3.ZERO,
	rate: float = 0.0,
	impulse: Vector3 = Vector3.ZERO,
	normal: Vector3 = Vector3.ZERO,
	direction: Vector3 = Vector3.ZERO,
	hold: Vector3 = Vector3.ZERO,
	scope: StringName = &"",
	limit_mps: float = 0.0,
	horizontal: bool = true,
	zero_y: bool = false
) -> void:
	_kind = submission_kind
	_phase = submission_phase
	_physics_step = step
	_source_id = source
	_occurrence_id = occurrence
	_locomotion_state_id = state_id
	_target_velocity = target
	_acceleration_mps2 = acceleration
	_rate_mps2 = rate
	_velocity_delta = impulse
	_wall_normal = normal
	_wall_direction = direction
	_hold_position = hold
	_cap_scope = scope
	_cap_limit_mps = limit_mps
	_horizontal_only = horizontal
	_zero_vertical = zero_y


static func terminal(step: int, source: StringName) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.TERMINAL_POLICY,
		MotorPhase.Phase.TERMINAL_COMMANDS,
		step,
		source
	)


static func state_policy(
	step: int,
	source: StringName,
	state_id: StringName
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.STATE_POLICY,
		MotorPhase.Phase.STATE_GATING_AND_INTERRUPTS,
		step,
		source,
		&"",
		state_id
	)


static func base_motion(
	step: int,
	source: StringName,
	target: Vector3,
	rate: float,
	horizontal: bool = true,
	zero_y: bool = false
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.BASE_POLICY,
		MotorPhase.Phase.BASE_LOCOMOTION_AND_GRAVITY,
		step,
		source,
		&"",
		&"",
		target,
		Vector3.ZERO,
		rate,
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
		&"",
		0.0,
		horizontal,
		zero_y
	)


static func gravity(
	step: int,
	source: StringName,
	acceleration: Vector3
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.GRAVITY,
		MotorPhase.Phase.BASE_LOCOMOTION_AND_GRAVITY,
		step,
		source,
		&"",
		&"",
		Vector3.ZERO,
		acceleration
	)


static func sustained_acceleration(
	step: int,
	source: StringName,
	acceleration: Vector3
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.SUSTAINED_ACCELERATION,
		MotorPhase.Phase.SUSTAINED_INFLUENCES,
		step,
		source,
		&"",
		&"",
		Vector3.ZERO,
		acceleration
	)


static func one_shot_impulse(
	step: int,
	source: StringName,
	occurrence: StringName,
	impulse: Vector3
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.ONE_SHOT_IMPULSE,
		MotorPhase.Phase.ONE_SHOT_IMPULSES,
		step,
		source,
		occurrence,
		&"",
		Vector3.ZERO,
		Vector3.ZERO,
		0.0,
		impulse
	)


static func wall_run_constraint(
	step: int,
	source: StringName,
	normal: Vector3,
	direction: Vector3
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.WALL_RUN_CONSTRAINT,
		MotorPhase.Phase.CONSTRAINTS_AND_REDIRECTIONS,
		step,
		source,
		&"",
		&"",
		Vector3.ZERO,
		Vector3.ZERO,
		0.0,
		Vector3.ZERO,
		normal,
		direction
	)


static func wall_stick_hold(
	step: int,
	source: StringName,
	hold: Vector3
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.WALL_STICK_HOLD,
		MotorPhase.Phase.CONSTRAINTS_AND_REDIRECTIONS,
		step,
		source,
		&"",
		&"",
		Vector3.ZERO,
		Vector3.ZERO,
		0.0,
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
		hold
	)


static func speed_cap(
	step: int,
	source: StringName,
	scope: StringName,
	limit_mps: float
) -> PlayerMotorSubmission:
	return PlayerMotorSubmission.new(
		Kind.SPEED_CAP,
		MotorPhase.Phase.CAPS_AND_FINAL_COMMIT,
		step,
		source,
		&"",
		&"",
		Vector3.ZERO,
		Vector3.ZERO,
		0.0,
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3.ZERO,
		scope,
		limit_mps
	)


func is_finite_payload() -> bool:
	return (
		_target_velocity.is_finite()
		and _acceleration_mps2.is_finite()
		and _velocity_delta.is_finite()
		and _wall_normal.is_finite()
		and _wall_direction.is_finite()
		and _hold_position.is_finite()
		and not is_nan(_rate_mps2)
		and not is_inf(_rate_mps2)
		and not is_nan(_cap_limit_mps)
		and not is_inf(_cap_limit_mps)
	)


func has_valid_wall_constraint_vectors() -> bool:
	var horizontal_direction := Vector3(_wall_direction.x, 0.0, _wall_direction.z)
	return (
		_wall_normal.length_squared() > MIN_VALID_WALL_VECTOR_LENGTH_SQUARED
		and horizontal_direction.length_squared() > MIN_VALID_WALL_VECTOR_LENGTH_SQUARED
	)


func has_valid_kind_and_phase() -> bool:
	if int(_kind) < 0 or int(_kind) >= Kind.size():
		return false
	if not MotorPhase.is_valid_phase(int(_phase)):
		return false
	return expected_phase_for_kind(_kind) == int(_phase)


static func expected_phase_for_kind(submission_kind: Kind) -> int:
	match submission_kind:
		Kind.TERMINAL_POLICY:
			return MotorPhase.Phase.TERMINAL_COMMANDS
		Kind.STATE_POLICY:
			return MotorPhase.Phase.STATE_GATING_AND_INTERRUPTS
		Kind.BASE_POLICY, Kind.GRAVITY:
			return MotorPhase.Phase.BASE_LOCOMOTION_AND_GRAVITY
		Kind.SUSTAINED_ACCELERATION:
			return MotorPhase.Phase.SUSTAINED_INFLUENCES
		Kind.ONE_SHOT_IMPULSE:
			return MotorPhase.Phase.ONE_SHOT_IMPULSES
		Kind.WALL_RUN_CONSTRAINT, Kind.WALL_STICK_HOLD:
			return MotorPhase.Phase.CONSTRAINTS_AND_REDIRECTIONS
		Kind.SPEED_CAP:
			return MotorPhase.Phase.CAPS_AND_FINAL_COMMIT
		_:
			return -1
