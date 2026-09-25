class_name GrappleTargetSeed
extends RefCounted


## Immutable accepted-target seed for a later player-owned `GrappleAttachment`
## (Stories 1.7/1.8). Carries stable target identity, the world hit position and
## normal, the applicable authored response, the target-local hit offset computed
## once at acquisition, and the target reference.
##
## ENGINE-REFERENCE EXCEPTION (documented, AC 4): `get_target_reference()` is the
## single weak engine reference allowed inside grapple result records. Every
## consumer must gate dereferences with `is_instance_valid` / `has_live_target()`
## (NFR14: never retain destroyed nodes). Story 1.8 owns continuous anchor
## sampling (`Grappleable3D.sample_anchor_state` + the controller's per-step
## sampling phase) and typed invalidation; this seed stays the immutable
## acquisition record.


var target_identity: StringName:
	get:
		return _target_identity

var hit_position: Vector3:
	get:
		return _hit_position

var hit_normal: Vector3:
	get:
		return _hit_normal

var response: GrappleTargetResponse:
	get:
		return _response

var target_local_hit_offset: Vector3:
	get:
		return _target_local_hit_offset


var _target_identity: StringName
var _hit_position: Vector3
var _hit_normal: Vector3
var _response: GrappleTargetResponse
var _target_reference: WeakRef
var _target_local_hit_offset: Vector3


func _init(
	identity: StringName,
	world_hit_position: Vector3,
	world_hit_normal: Vector3,
	authored_response: GrappleTargetResponse,
	target_reference: WeakRef,
	local_hit_offset: Vector3
) -> void:
	_target_identity = identity
	_hit_position = world_hit_position if world_hit_position.is_finite() else Vector3.ZERO
	_hit_normal = (
		world_hit_normal.normalized()
		if world_hit_normal.is_finite() and world_hit_normal.length_squared() > 0.000001
		else Vector3.ZERO
	)
	_response = authored_response if authored_response != null else GrappleTargetResponse.static_default()
	_target_reference = target_reference
	_target_local_hit_offset = local_hit_offset if local_hit_offset.is_finite() else Vector3.ZERO


func get_target_reference() -> WeakRef:
	return _target_reference


## Dereference the weak target reference. Callers gate with `is_instance_valid`
## (or `has_live_target()`) before using the returned object.
func get_target() -> Object:
	if _target_reference == null:
		return null
	return _target_reference.get_ref()


func has_live_target() -> bool:
	return is_instance_valid(get_target())


## True only when every script variable holds a value type (int, float, bool,
## String, StringName, Vector3; enums are ints) or an allowed class member:
## `response` (null or a value-only `GrappleTargetResponse`) and the documented
## engine-reference exception `_target_reference` (`WeakRef`). Any other
## object-typed script variable (including on subclasses) reports false.
func is_value_only() -> bool:
	return GrappleTargetSeed.value_is_value_only(self)


## Static so nested purity checks dispatch here even if a subclass overrides
## `is_value_only()`; subclass instances are still inspected field by field.
static func value_is_value_only(value: Variant) -> bool:
	if value == null or not (value is GrappleTargetSeed):
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
	if property_name == &"_target_reference" and class_id == "WeakRef":
		return true
	if (
		(property_name == &"response" or property_name == &"_response")
		and class_id == "GrappleTargetResponse"
	):
		var response_value: Variant = value.get(property.name)
		if response_value == null:
			return true
		return GrappleTargetResponse.value_is_value_only(response_value)
	return false
