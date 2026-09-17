class_name DiagnosticContext
extends RefCounted


var physics_step: int:
	get:
		return _physics_step

var locomotion_state_id: StringName:
	get:
		return _locomotion_state_id

var reason: StringName:
	get:
		return _reason

var request_kind: int:
	get:
		return _request_kind

var source_id: StringName:
	get:
		return _source_id

var _physics_step: int
var _locomotion_state_id: StringName
var _reason: StringName
var _request_kind: int
var _source_id: StringName


func _init(
	step: int = -1,
	locomotion_id: StringName = &"",
	rejection_reason: StringName = &"",
	kind: int = -1,
	submission_source_id: StringName = &""
) -> void:
	_physics_step = step
	_locomotion_state_id = locomotion_id
	_reason = rejection_reason
	_request_kind = kind
	_source_id = submission_source_id


func get_deduplication_key() -> String:
	return get_stable_deduplication_key()


func get_stable_deduplication_key() -> String:
	return "%s|%s|%d|%s" % [
		String(_locomotion_state_id),
		String(_reason),
		_request_kind,
		String(_source_id),
	]
