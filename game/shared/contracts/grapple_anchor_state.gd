class_name GrappleAnchorState
extends RefCounted


## Immutable value-only per-step sampled grapple anchor state (architecture
## "Cross-System Contract Specifications" -> grapple target contract; Story 1.8
## Task 2.1). Exactly one is sampled per physics step while an attachment is
## active, and it is the single source for that step's pull direction, boundary
## resolution, presentation endpoint, and diagnostics (AC 2).
##
## VALUE-ONLY PURITY: follows the `GrappleTargetSeed`/`GrappleTargetResponse`
## pattern - value types plus the one documented nested value-only
## `GrappleTargetResponse` member. Nothing here holds a node, a scene reference,
## or a player/motor handle; targets can report bounded facts only and can never
## move the player or change player state (AC 2).
##
## `target_velocity` is the sampled anchor velocity in m/s: an explicitly
## supplied velocity when the target authors one, otherwise the finite
## difference of sampled anchor positions over `delta_seconds` (Task 2.3,
## rate-equivalent at 60 Hz and 120 Hz).

enum InvalidationReason {
	## The anchor is usable.
	NONE,
	## The target reports the anchor unusable (explicit invalidation or an
	## eligibility change).
	TARGET_INVALIDATED,
	## The target reference is gone (synthesized by the sampler; the target can
	## no longer report anything).
	TARGET_DESTROYED,
	## The target reports an encounter-scope identity incompatible with the
	## attachment's originating scope (AC 6).
	SCOPE_MISMATCH,
}


var anchor_world_position: Vector3:
	get:
		return _anchor_world_position

## Sampled anchor velocity in m/s (see the type header).
var target_velocity: Vector3:
	get:
		return _target_velocity

var is_valid: bool:
	get:
		return _is_valid

var invalidation_reason: InvalidationReason:
	get:
		return _invalidation_reason

## Encounter-scope identity the target reports (`&""` = unscoped).
var scope_identity: StringName:
	get:
		return _scope_identity

## Bounded effective response values for this sample (never mutated).
var response: GrappleTargetResponse:
	get:
		return _response


var _anchor_world_position: Vector3
var _target_velocity: Vector3
var _is_valid: bool
var _invalidation_reason: InvalidationReason
var _scope_identity: StringName
var _response: GrappleTargetResponse


func _init(
	anchor_position: Vector3 = Vector3.ZERO,
	velocity: Vector3 = Vector3.ZERO,
	valid: bool = true,
	invalidation: InvalidationReason = InvalidationReason.NONE,
	scope: StringName = &"",
	effective_response: GrappleTargetResponse = null
) -> void:
	_anchor_world_position = anchor_position if anchor_position.is_finite() else Vector3.ZERO
	_target_velocity = velocity if velocity.is_finite() else Vector3.ZERO
	_is_valid = valid
	_invalidation_reason = invalidation
	_scope_identity = scope
	_response = (
		effective_response
		if effective_response != null
		else GrappleTargetResponse.static_default()
	)


## Built-in static anchor state for ordinary collision geometry (Task 2.2):
## frozen world anchor (the accepted hit position), zero velocity, and the
## shared immutable static response.
static func static_default(initial_anchor_world_position: Vector3) -> GrappleAnchorState:
	return GrappleAnchorState.new(
		initial_anchor_world_position,
		Vector3.ZERO,
		true,
		InvalidationReason.NONE,
		&"",
		GrappleTargetResponse.static_default()
	)


## Invalid sample with a typed reason, used when the sampler must synthesize a
## verdict the (possibly gone) target can no longer report.
static func invalid(
	anchor_position: Vector3,
	reason: InvalidationReason,
	scope: StringName = &"",
	effective_response: GrappleTargetResponse = null
) -> GrappleAnchorState:
	return GrappleAnchorState.new(
		anchor_position,
		Vector3.ZERO,
		false,
		reason,
		scope,
		effective_response
	)


static func invalidation_reason_id(reason: InvalidationReason) -> StringName:
	var value := int(reason)
	if value < 0 or value >= InvalidationReason.size():
		return &"invalid"
	return StringName(InvalidationReason.keys()[value].to_lower())


## True only when every script variable holds a value type (int, float, bool,
## String, StringName, Vector3; enums are ints) or the one documented nested
## value-only `GrappleTargetResponse`. Nothing else object-typed is allowed.
func is_value_only() -> bool:
	return GrappleAnchorState.value_is_value_only(self)


static func value_is_value_only(value: Variant) -> bool:
	if value == null or not (value is GrappleAnchorState):
		return false
	for property in value.get_property_list():
		if (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		match int(property.type):
			TYPE_INT, TYPE_FLOAT, TYPE_BOOL, TYPE_STRING, TYPE_STRING_NAME, TYPE_VECTOR3:
				continue
			TYPE_OBJECT:
				if not _is_allowed_object_property(value, property):
					return false
			_:
				return false
	return true


static func _is_allowed_object_property(value: Variant, property: Dictionary) -> bool:
	var property_name := StringName(property.name)
	var class_id := String(property.get("class_name", ""))
	if (
		(property_name == &"response" or property_name == &"_response")
		and class_id == "GrappleTargetResponse"
	):
		var response_value: Variant = value.get(property.name)
		if response_value == null:
			return true
		return GrappleTargetResponse.value_is_value_only(response_value)
	return false
