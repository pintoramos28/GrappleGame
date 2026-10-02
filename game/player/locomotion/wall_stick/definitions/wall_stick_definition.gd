class_name WallStickDefinition
extends Resource

enum ValidationStatus { SUCCESS, INVALID_ID, INVALID_SPEED, INVALID_GEOMETRY, INVALID_TOLERANCE }

var _locked := false

@export var definition_id: StringName = &"player.wall_stick.default":
	set(value):
		if not _locked:
			definition_id = value
@export var maximum_entry_speed_mps: float = 100.0:
	set(value):
		if not _locked:
			maximum_entry_speed_mps = value
@export var jump_up_speed_mps: float = 5.5:
	set(value):
		if not _locked:
			jump_up_speed_mps = value
@export var jump_away_speed_mps: float = 8.0:
	set(value):
		if not _locked:
			jump_away_speed_mps = value
@export var maximum_abs_normal_y: float = 0.2:
	set(value):
		if not _locked:
			maximum_abs_normal_y = value
## Safety bounds, not entry tuning. Transform teleports are not swept movers.
@export var maximum_support_speed_mps: float = 50.0:
	set(value):
		if not _locked:
			maximum_support_speed_mps = value
@export var maximum_support_step_m: float = 0.25:
	set(value):
		if not _locked:
			maximum_support_step_m = value
@export var maximum_support_rotation_rps: float = PI:
	set(value):
		if not _locked:
			maximum_support_rotation_rps = value
@export var carry_error_tolerance_m: float = 0.02:
	set(value):
		if not _locked:
			carry_error_tolerance_m = value

func validate() -> ValidationStatus:
	if not GrappleDefinition.is_stable_definition_id(definition_id):
		return ValidationStatus.INVALID_ID
	for speed in [maximum_entry_speed_mps, jump_up_speed_mps, jump_away_speed_mps]:
		if not is_finite(speed) or speed <= 0.0:
			return ValidationStatus.INVALID_SPEED
	if not is_finite(maximum_abs_normal_y) or maximum_abs_normal_y < 0.0 or maximum_abs_normal_y >= 1.0:
		return ValidationStatus.INVALID_GEOMETRY
	for tolerance in [maximum_support_speed_mps, maximum_support_step_m, maximum_support_rotation_rps, carry_error_tolerance_m]:
		if not is_finite(tolerance) or tolerance <= 0.0:
			return ValidationStatus.INVALID_TOLERANCE
	_locked = true
	return ValidationStatus.SUCCESS

func is_locked() -> bool:
	return _locked
