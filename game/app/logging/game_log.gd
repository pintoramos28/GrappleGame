class_name GameLog
extends RefCounted


signal diagnostic_recorded(event: DiagnosticEvent)


const MAX_TRACKED_DIAGNOSTICS := 32


var _tracked_deduplication_keys: Dictionary = {}
var _deduplication_order: Array[String] = []


func record_invariant(event_code: StringName, context: DiagnosticContext) -> void:
	var event := DiagnosticEvent.new(event_code, context)
	var deduplication_key := event.get_stable_deduplication_key()
	if _tracked_deduplication_keys.has(deduplication_key):
		return

	if _deduplication_order.size() >= MAX_TRACKED_DIAGNOSTICS:
		var oldest_key: String = _deduplication_order[0]
		_deduplication_order.remove_at(0)
		_tracked_deduplication_keys.erase(oldest_key)
	_tracked_deduplication_keys[deduplication_key] = true
	_deduplication_order.append(deduplication_key)
	diagnostic_recorded.emit(event)
	push_error(
		"GameLog %s (step=%d locomotion=%s reason=%s kind=%d)" % [
			String(event.code),
			event.context.physics_step,
			String(event.context.locomotion_state_id),
			String(event.context.reason),
			event.context.request_kind,
		]
	)
