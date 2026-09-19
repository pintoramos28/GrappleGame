class_name PhysicsQueryProfile
extends Resource


enum ValidationStatus {
	SUCCESS,
	INVALID_ID,
	INVALID_MASK,
	INVALID_SHAPE,
	INVALID_DIRECTION,
	INVALID_LIMITS,
	INVALID_TOLERANCE,
}


const MAX_PROBE_DISTANCE_M := 4.0
const MAX_SWEEP_DISTANCE_M := 4.0
const MAX_CONTINUITY_LOSS_STEPS := 2
const MAX_CANDIDATE_LIMIT := 16
const MAX_REPORT_LIMIT := 8
const MAX_SCAN_LIMIT := 32


var _locked := false
var _resolved_collision_mask := 0


@export var profile_id: StringName = &"physics.query.profile":
	set(value):
		if not _locked:
			profile_id = value

@export var collision_mask_names := PackedStringArray(["world_geometry"]):
	set(value):
		if not _locked:
			collision_mask_names = value

@export var shape: Shape3D:
	set(value):
		if not _locked:
			shape = value

@export var probe_offset := Vector3.ZERO:
	set(value):
		if not _locked:
			probe_offset = value

@export var probe_direction := Vector3.DOWN:
	set(value):
		if not _locked:
			probe_direction = value

@export var probe_distance_m := 0.25:
	set(value):
		if not _locked:
			probe_distance_m = value

@export var sweep_distance_cap_m := 1.0:
	set(value):
		if not _locked:
			sweep_distance_cap_m = value

@export var margin_m := 0.001:
	set(value):
		if not _locked:
			margin_m = value

@export var thickness_m := 0.08:
	set(value):
		if not _locked:
			thickness_m = value

@export var support_max_distance_m := 0.18:
	set(value):
		if not _locked:
			support_max_distance_m = value

@export var support_separation_epsilon_m := 0.01:
	set(value):
		if not _locked:
			support_separation_epsilon_m = value

@export var non_separating_velocity_epsilon_m := 0.05:
	set(value):
		if not _locked:
			non_separating_velocity_epsilon_m = value

@export_range(-1.0, 1.0, 0.01) var ground_min_normal_y := 0.7:
	set(value):
		if not _locked:
			ground_min_normal_y = value

@export_range(0.0, 1.0, 0.01) var wall_max_abs_normal_y := 0.2:
	set(value):
		if not _locked:
			wall_max_abs_normal_y = value

@export var continuity_angle_degrees := 25.0:
	set(value):
		if not _locked:
			continuity_angle_degrees = value

@export var continuity_distance_m := 0.2:
	set(value):
		if not _locked:
			continuity_distance_m = value

@export var continuity_loss_steps := 2:
	set(value):
		if not _locked:
			continuity_loss_steps = value

@export var point_quantization_m := 0.001:
	set(value):
		if not _locked:
			point_quantization_m = value

@export var normal_quantization := 0.001:
	set(value):
		if not _locked:
			normal_quantization = value

@export var time_quantization := 0.001:
	set(value):
		if not _locked:
			time_quantization = value

@export var candidate_limit := 16:
	set(value):
		if not _locked:
			candidate_limit = value

@export var report_limit := 8:
	set(value):
		if not _locked:
			report_limit = value

@export var scan_limit := 32:
	set(value):
		if not _locked:
			scan_limit = value

@export var collide_with_bodies := true:
	set(value):
		if not _locked:
			collide_with_bodies = value

@export var collide_with_areas := false:
	set(value):
		if not _locked:
			collide_with_areas = value

@export var overlap_check_enabled := true:
	set(value):
		if not _locked:
			overlap_check_enabled = value

@export var exclude_body := true:
	set(value):
		if not _locked:
			exclude_body = value


func validate() -> ValidationStatus:
	if profile_id == &"":
		return ValidationStatus.INVALID_ID
	if collision_mask_names.is_empty():
		return ValidationStatus.INVALID_MASK
	var seen_layer_names: Dictionary = {}
	for layer_name in collision_mask_names:
		var layer_name_string := String(layer_name).strip_edges()
		if layer_name_string.is_empty() or seen_layer_names.has(layer_name_string):
			return ValidationStatus.INVALID_MASK
		seen_layer_names[layer_name_string] = true
	if shape == null:
		return ValidationStatus.INVALID_SHAPE
	if not probe_offset.is_finite() or not probe_direction.is_finite() or probe_direction.length_squared() <= 0.000001:
		return ValidationStatus.INVALID_DIRECTION
	for numeric_value in [
		probe_distance_m,
		sweep_distance_cap_m,
		margin_m,
		thickness_m,
		support_max_distance_m,
		support_separation_epsilon_m,
		non_separating_velocity_epsilon_m,
		ground_min_normal_y,
		wall_max_abs_normal_y,
		continuity_angle_degrees,
		continuity_distance_m,
		point_quantization_m,
		normal_quantization,
		time_quantization,
	]:
		if is_nan(float(numeric_value)) or is_inf(float(numeric_value)):
			return ValidationStatus.INVALID_TOLERANCE
	if (
		probe_distance_m <= 0.0
		or probe_distance_m > MAX_PROBE_DISTANCE_M
		or sweep_distance_cap_m <= 0.0
		or sweep_distance_cap_m > MAX_SWEEP_DISTANCE_M
		or margin_m < 0.0
		or thickness_m <= 0.0
		or support_max_distance_m < 0.0
		or support_separation_epsilon_m < 0.0
		or non_separating_velocity_epsilon_m < 0.0
		or continuity_angle_degrees < 0.0
		or continuity_distance_m < 0.0
		or continuity_loss_steps < 0
		or continuity_loss_steps > MAX_CONTINUITY_LOSS_STEPS
		or point_quantization_m <= 0.0
		or normal_quantization <= 0.0
		or time_quantization <= 0.0
	):
		return ValidationStatus.INVALID_TOLERANCE
	if (
		candidate_limit <= 0
		or report_limit <= 0
		or scan_limit <= 0
		or candidate_limit > MAX_CANDIDATE_LIMIT
		or report_limit > MAX_REPORT_LIMIT
		or scan_limit > MAX_SCAN_LIMIT
		or report_limit > candidate_limit
		or candidate_limit > scan_limit
	):
		return ValidationStatus.INVALID_LIMITS
	if ground_min_normal_y < -1.0 or ground_min_normal_y > 1.0:
		return ValidationStatus.INVALID_TOLERANCE
	if wall_max_abs_normal_y < 0.0 or wall_max_abs_normal_y > 1.0:
		return ValidationStatus.INVALID_TOLERANCE

	var mask := 0
	for layer_name in collision_mask_names:
		var bit := _resolve_layer_name(String(layer_name))
		if bit == 0:
			return ValidationStatus.INVALID_MASK
		mask |= bit
	_resolved_collision_mask = mask
	_locked = true
	return ValidationStatus.SUCCESS


func is_locked() -> bool:
	return _locked


func get_collision_mask() -> int:
	return _resolved_collision_mask


func unlock_for_editor() -> void:
	# Runtime consumers never call this. It exists for explicit editor tooling
	# that needs to replace a profile and validate it again before use.
	_locked = false


func _resolve_layer_name(requested_name: String) -> int:
	for layer_index in range(1, 33):
		var setting_key := "layer_names/3d_physics/layer_%d" % layer_index
		var configured_name := String(ProjectSettings.get_setting(setting_key, ""))
		if configured_name == requested_name:
			return 1 << (layer_index - 1)
	return 0
