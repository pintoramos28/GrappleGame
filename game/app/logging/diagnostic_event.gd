class_name DiagnosticEvent
extends RefCounted


var code: StringName:
	get:
		return _code

var context: DiagnosticContext:
	get:
		return _context

var _code: StringName
var _context: DiagnosticContext


func _init(event_code: StringName, event_context: DiagnosticContext) -> void:
	_code = event_code
	_context = event_context


func get_deduplication_key() -> String:
	return get_stable_deduplication_key()


func get_stable_deduplication_key() -> String:
	return "%s|%s" % [String(_code), _context.get_stable_deduplication_key()]
