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

var _physics_step: int
var _locomotion_state_id: StringName
var _reason: StringName
var _request_kind: int


func _init(
	step: int = -1,
	locomotion_id: StringName = &"",
	rejection_reason: StringName = &"",
	kind: int = -1
) -> void:
	_physics_step = step
	_locomotion_state_id = locomotion_id
	_reason = rejection_reason
	_request_kind = kind


func get_deduplication_key() -> String:
	return get_stable_deduplication_key()


func get_stable_deduplication_key() -> String:
	return "%s|%s|%d" % [
		String(_locomotion_state_id),
		String(_reason),
		_request_kind,
	]
