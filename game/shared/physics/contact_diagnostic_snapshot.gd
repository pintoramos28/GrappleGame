class_name ContactDiagnosticSnapshot
extends RefCounted


## Immutable, value-only diagnostics emitted from the contact owner.
## Shape resources and engine query objects are represented by scalar metadata;
## this record never retains a live physics object.
var provider_status: StringName:
	get:
		return _provider_status

var frame: ContactFrame:
	get:
		return _frame

var physics_step: int:
	get:
		return _frame.physics_step if _frame != null else -1

var frame_status: ContactFrame.Status:
	get:
		return _frame.status if _frame != null else ContactFrame.Status.NOT_INITIALIZED

var ground_profile_id: StringName:
	get:
		return _ground_profile_id

var wall_profile_id: StringName:
	get:
		return _wall_profile_id

var ground_collision_mask_names: PackedStringArray:
	get:
		return _ground_collision_mask_names.duplicate()

var wall_collision_mask_names: PackedStringArray:
	get:
		return _wall_collision_mask_names.duplicate()

var ground_shape_type: StringName:
	get:
		return _ground_shape_type

var wall_shape_type: StringName:
	get:
		return _wall_shape_type

var ground_probe_offset: Vector3:
	get:
		return _ground_probe_offset

var wall_probe_offset: Vector3:
	get:
		return _wall_probe_offset

var ground_probe_direction: Vector3:
	get:
		return _ground_probe_direction

var wall_probe_directions: Array[Vector3]:
	get:
		return _wall_probe_directions.duplicate()

var ground_sweep_distance_m: float:
	get:
		return _ground_sweep_distance_m

var wall_sweep_distance_m: float:
	get:
		return _wall_sweep_distance_m

var ground_query_count: int:
	get:
		return _ground_query_count

var wall_query_count: int:
	get:
		return _wall_query_count

var ground_candidate_limit: int:
	get:
		return _ground_candidate_limit

var ground_report_limit: int:
	get:
		return _ground_report_limit

var ground_scan_limit: int:
	get:
		return _ground_scan_limit

var wall_candidate_limit: int:
	get:
		return _wall_candidate_limit

var wall_report_limit: int:
	get:
		return _wall_report_limit

var wall_scan_limit: int:
	get:
		return _wall_scan_limit


var _provider_status: StringName
var _frame: ContactFrame
var _ground_profile_id: StringName
var _wall_profile_id: StringName
var _ground_collision_mask_names := PackedStringArray()
var _wall_collision_mask_names := PackedStringArray()
var _ground_shape_type: StringName = &""
var _wall_shape_type: StringName = &""
var _ground_probe_offset := Vector3.ZERO
var _wall_probe_offset := Vector3.ZERO
var _ground_probe_direction := Vector3.DOWN
var _wall_probe_directions: Array[Vector3] = []
var _ground_sweep_distance_m := 0.0
var _wall_sweep_distance_m := 0.0
var _ground_query_count := 0
var _wall_query_count := 0
var _ground_candidate_limit := 0
var _ground_report_limit := 0
var _ground_scan_limit := 0
var _wall_candidate_limit := 0
var _wall_report_limit := 0
var _wall_scan_limit := 0


func _init(
	contact_frame: ContactFrame,
	status_id: StringName,
	ground_profile: PhysicsQueryProfile = null,
	wall_profile: PhysicsQueryProfile = null,
	ground_directions: Array = [],
	wall_directions: Array = [],
	ground_sweep_distance: float = 0.0,
	wall_sweep_distance: float = 0.0,
	ground_queries: int = 0,
	wall_queries: int = 0
) -> void:
	_frame = contact_frame
	_provider_status = status_id
	if ground_profile != null:
		_ground_profile_id = ground_profile.profile_id
		_ground_collision_mask_names = ground_profile.collision_mask_names.duplicate()
		_ground_shape_type = StringName(ground_profile.shape.get_class()) if ground_profile.shape != null else &""
		_ground_probe_offset = ground_profile.probe_offset
		_ground_probe_direction = ground_profile.probe_direction.normalized()
		_ground_candidate_limit = ground_profile.candidate_limit
		_ground_report_limit = ground_profile.report_limit
		_ground_scan_limit = ground_profile.scan_limit
	if wall_profile != null:
		_wall_profile_id = wall_profile.profile_id
		_wall_collision_mask_names = wall_profile.collision_mask_names.duplicate()
		_wall_shape_type = StringName(wall_profile.shape.get_class()) if wall_profile.shape != null else &""
		_wall_probe_offset = wall_profile.probe_offset
		_wall_candidate_limit = wall_profile.candidate_limit
		_wall_report_limit = wall_profile.report_limit
		_wall_scan_limit = wall_profile.scan_limit
	if not ground_directions.is_empty() and ground_directions[0] is Vector3:
		var ground_direction: Vector3 = ground_directions[0]
		if ground_direction.is_finite() and ground_direction.length_squared() > 0.000001:
			_ground_probe_direction = ground_direction.normalized()
	for direction_value in wall_directions:
		if not direction_value is Vector3:
			continue
		var direction: Vector3 = direction_value
		if direction.is_finite() and direction.length_squared() > 0.000001:
			_wall_probe_directions.append(direction.normalized())
	_ground_sweep_distance_m = maxf(ground_sweep_distance, 0.0)
	_wall_sweep_distance_m = maxf(wall_sweep_distance, 0.0)
	_ground_query_count = maxi(ground_queries, 0)
	_wall_query_count = maxi(wall_queries, 0)


func is_value_only() -> bool:
	return true
