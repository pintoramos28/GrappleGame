class_name ContactCandidate
extends RefCounted


enum Source {
	COMMITTED_COLLISION,
	BODY_FACT,
	CURRENT_OVERLAP,
	SWEEP_PREDICTION,
}

enum Classification {
	INVALID,
	GROUND,
	WALL,
	FLOOR_LIKE,
	CEILING_LIKE,
	DUPLICATE,
}


var physics_step: int:
	get:
		return _physics_step

var source: Source:
	get:
		return _source

var classification: Classification:
	get:
		return _classification

var normal: Vector3:
	get:
		return _normal

var point: Vector3:
	get:
		return _point

var surface_identity: StringName:
	get:
		return _surface_identity

var transient_identity: StringName:
	get:
		return _transient_identity

var shape_index: int:
	get:
		return _shape_index

var query_index: int:
	get:
		return _query_index

var distance: float:
	get:
		return _distance

var time_of_impact: float:
	get:
		return _time_of_impact

var approach_opposition: float:
	get:
		return _approach_opposition


var _physics_step: int
var _source: Source
var _classification: Classification
var _normal: Vector3
var _point: Vector3
var _surface_identity: StringName
var _transient_identity: StringName
var _shape_index: int
var _query_index: int
var _distance: float
var _time_of_impact: float
var _approach_opposition: float
var _valid_payload := true


func _init(
	step: int,
	candidate_source: Source,
	candidate_classification: Classification,
	candidate_normal: Vector3,
	candidate_point: Vector3,
	authored_surface_identity: StringName = &"",
	candidate_shape_index: int = -1,
	candidate_query_index: int = -1,
	candidate_distance: float = INF,
	candidate_time_of_impact: float = INF,
	candidate_approach_opposition: float = 0.0,
	candidate_transient_identity: StringName = &""
) -> void:
	_valid_payload = (
		candidate_normal.is_finite()
		and candidate_normal.length_squared() > 0.000001
		and candidate_point.is_finite()
		and not is_nan(candidate_distance)
		and not is_inf(candidate_distance)
		and not is_nan(candidate_time_of_impact)
		and not is_inf(candidate_time_of_impact)
		and not is_nan(candidate_approach_opposition)
		and not is_inf(candidate_approach_opposition)
	)
	_physics_step = step
	_source = candidate_source
	_classification = candidate_classification if _valid_payload else Classification.INVALID
	_normal = candidate_normal.normalized() if _valid_payload else Vector3.ZERO
	_point = candidate_point if candidate_point.is_finite() else Vector3.ZERO
	_surface_identity = authored_surface_identity
	_transient_identity = candidate_transient_identity
	_shape_index = candidate_shape_index
	_query_index = candidate_query_index
	_distance = maxf(candidate_distance, 0.0) if not is_nan(candidate_distance) and not is_inf(candidate_distance) else 0.0
	_time_of_impact = clampf(candidate_time_of_impact, 0.0, 1.0) if not is_nan(candidate_time_of_impact) and not is_inf(candidate_time_of_impact) else 0.0
	_approach_opposition = maxf(candidate_approach_opposition, 0.0) if not is_nan(candidate_approach_opposition) and not is_inf(candidate_approach_opposition) else 0.0


func has_authored_identity() -> bool:
	return _surface_identity != &""


func has_transient_identity() -> bool:
	return _transient_identity != &""


func is_finite() -> bool:
	return (
		_valid_payload
		and _normal.is_finite()
		and _point.is_finite()
		and not is_nan(_distance)
		and not is_inf(_distance)
		and not is_nan(_time_of_impact)
		and not is_inf(_time_of_impact)
		and not is_nan(_approach_opposition)
		and not is_inf(_approach_opposition)
	)


func is_value_only() -> bool:
	return true
