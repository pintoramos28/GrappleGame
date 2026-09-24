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
## (NFR14: never retain destroyed nodes). Continuous moving-target tracking,
## lifetime sampling, and invalidation belong to Story 1.8 and are absent here.


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


func is_value_only() -> bool:
	return true
