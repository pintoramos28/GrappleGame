class_name GrappleDefinition
extends Resource


## Immutable authored grapple definition (architecture "Data Patterns"). Runtime
## code never writes this Resource; validate/lock semantics mirror
## `PhysicsQueryProfile.validate()`.

enum ValidationStatus {
	SUCCESS,
	INVALID_ID,
	INVALID_RANGE,
	INVALID_TOLERANCE,
	INVALID_PROFILE,
	INVALID_PULL_TUNING,
	INVALID_SPEED_CAP,
}


## `acquisition_tolerance_m` is a physics/quantization tolerance for boundary
## classification only - never a second range scalar. Its bound is
## `MAX_ACQUISITION_TOLERANCE_MULTIPLIER * max(point_quantization_m, margin_m)`
## of the target query profile (0.01 m with the authored 0.001 m quantization and
## margin); `max_grapple_length_m` stays the only authoritative acquisition range.
const MAX_ACQUISITION_TOLERANCE_MULTIPLIER := 10.0


var _locked := false


@export var definition_id: StringName = &"player.grapple.default":
	set(value):
		if not _locked:
			definition_id = value

## Sole authoritative grapple acquisition range (AC 11).
@export var max_grapple_length_m: float = 35.0:
	set(value):
		if not _locked:
			max_grapple_length_m = value

## Boundary-classification tolerance only (see MAX_ACQUISITION_TOLERANCE_MULTIPLIER).
@export var acquisition_tolerance_m: float = 0.005:
	set(value):
		if not _locked:
			acquisition_tolerance_m = value

## Candidate (acquisition) query profile reference carried on the definition.
@export var target_query_profile: PhysicsQueryProfile:
	set(value):
		if not _locked:
			target_query_profile = value

@export var pull_initial_acceleration_mps2: float = 48.0:
	set(value):
		if not _locked:
			pull_initial_acceleration_mps2 = value

@export var pull_min_acceleration_mps2: float = 8.0:
	set(value):
		if not _locked:
			pull_min_acceleration_mps2 = value

@export var pull_acceleration_jerk_mps3: float = 53.333333:
	set(value):
		if not _locked:
			pull_acceleration_jerk_mps3 = value

@export var maximum_speed_mps: float = 22.0:
	set(value):
		if not _locked:
			maximum_speed_mps = value


func validate() -> ValidationStatus:
	if not is_stable_definition_id(definition_id):
		return ValidationStatus.INVALID_ID
	if not _is_finite_value(max_grapple_length_m) or max_grapple_length_m <= 0.0:
		return ValidationStatus.INVALID_RANGE
	if target_query_profile == null or not target_query_profile is PhysicsQueryProfile:
		return ValidationStatus.INVALID_PROFILE
	if target_query_profile.validate() != PhysicsQueryProfile.ValidationStatus.SUCCESS:
		return ValidationStatus.INVALID_PROFILE
	if not target_query_profile.is_ray_profile():
		return ValidationStatus.INVALID_PROFILE
	if not _is_finite_value(acquisition_tolerance_m) or acquisition_tolerance_m <= 0.0:
		return ValidationStatus.INVALID_TOLERANCE
	var tolerance_limit := MAX_ACQUISITION_TOLERANCE_MULTIPLIER * maxf(
		target_query_profile.point_quantization_m,
		target_query_profile.margin_m
	)
	if acquisition_tolerance_m > tolerance_limit:
		return ValidationStatus.INVALID_TOLERANCE
	for pull_value in [
		pull_initial_acceleration_mps2,
		pull_min_acceleration_mps2,
		pull_acceleration_jerk_mps3,
	]:
		if not _is_finite_value(pull_value) or pull_value < 0.0:
			return ValidationStatus.INVALID_PULL_TUNING
	if pull_min_acceleration_mps2 > pull_initial_acceleration_mps2:
		return ValidationStatus.INVALID_PULL_TUNING
	if not _is_finite_value(maximum_speed_mps) or maximum_speed_mps <= 0.0:
		return ValidationStatus.INVALID_SPEED_CAP

	_locked = true
	return ValidationStatus.SUCCESS


func is_locked() -> bool:
	return _locked


func unlock_for_editor() -> void:
	# Runtime consumers never call this. It exists for explicit editor tooling
	# that needs to replace definition values and validate again before use.
	_locked = false


static func validation_status_id(status: ValidationStatus) -> StringName:
	return StringName(ValidationStatus.keys()[int(status)].to_lower())


## Stable authored identifiers are lowercase dotted `StringName`s (`a.b_c`); they
## are never derived from node names, filenames, or scene paths.
static func is_stable_definition_id(value: StringName) -> bool:
	var text := String(value)
	if text.is_empty() or text.length() > 96:
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


static func _is_finite_value(value: float) -> bool:
	return not is_nan(value) and not is_inf(value)
