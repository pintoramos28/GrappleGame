class_name GrappleSurfaceBinding
extends RefCounted
## Private contact-local tracking mode. It never owns carry/contact continuity,
## publishes collider references, raycasts, or changes ordinary static sampling.

enum Status { VALID, DESTROYED, INVALID_SURFACE, DISCONTINUITY }

var status := Status.VALID
var target_identity: StringName = &""
var _body_ref: WeakRef
var _shape_owner_id: int
var _shape: Shape3D
var _local_point: Vector3
var _local_normal: Vector3
var _previous_transform: Transform3D
var _previous_owner_transform: Transform3D
var _binding_basis: Basis
var _definition: WallStickDefinition
var _collision_mask: int
var _profile: PhysicsQueryProfile
var _component_ref: WeakRef
var _geometry_dirty := false
var _released := false
var _shape_changed_callback: Callable
var _sample: GrappleAnchorState
var _sample_step: int

static func bind(body: CollisionObject3D, owner_id: int, shape: Shape3D, local_point: Vector3, local_normal: Vector3, definition: WallStickDefinition, collision_mask: int, step: int, contact_velocity: Vector3) -> GrappleSurfaceBinding:
	if not is_instance_valid(body) or body.is_queued_for_deletion() or not body.is_inside_tree() or not body is PhysicsBody3D or definition == null or not definition.is_locked() or shape == null or WallStickAttachment.single_active_shape_owner(body) != owner_id or not local_point.is_finite() or not local_normal.is_finite() or not contact_velocity.is_finite():
		return null
	var owner_transform := body.shape_owner_get_transform(owner_id)
	var pose := body.global_transform * owner_transform
	if not WallStickAttachment._usable_transform(pose):
		return null
	var binding := GrappleSurfaceBinding.new()
	binding._body_ref = weakref(body)
	binding._shape_owner_id = owner_id
	binding._shape = shape
	binding._local_point = local_point
	binding._local_normal = local_normal
	binding._definition = definition
	binding._collision_mask = collision_mask
	binding._previous_transform = pose
	binding._previous_owner_transform = owner_transform
	binding._binding_basis = pose.basis
	binding._sample_step = step
	binding._sample = GrappleAnchorState.new(pose * local_point, contact_velocity)
	var binding_ref: WeakRef = weakref(binding)
	binding._shape_changed_callback = func() -> void:
		var live := binding_ref.get_ref() as GrappleSurfaceBinding
		if live != null:
			live._geometry_dirty = true
	shape.changed.connect(binding._shape_changed_callback)
	return binding

func get_target() -> CollisionObject3D:
	return _body_ref.get_ref() as CollisionObject3D if _body_ref != null else null

func get_local_contact_point() -> Vector3:
	return _local_point

func get_world_normal() -> Vector3:
	return (_previous_transform.basis.inverse().transposed() * _local_normal).normalized()

func get_sample() -> GrappleAnchorState:
	return _sample

func is_prepared_state_current() -> bool:
	if not is_live_geometry():
		return false
	var body := get_target()
	if not (body.global_transform * body.shape_owner_get_transform(_shape_owner_id)).is_equal_approx(_previous_transform):
		return false
	_sample = _sample_policy(_sample.anchor_world_position, _sample.target_velocity)
	return _sample != null and _sample.is_valid

## No legacy component sample/reset call: this binding owns its baseline.
func configure_policy(profile: PhysicsQueryProfile, policy: GrappleTargetResolver.SurfacePolicy) -> void:
	_profile = profile
	target_identity = policy.target_identity
	_component_ref = weakref(policy.component) if policy.component != null else null
	_sample = _sample_policy(_sample.anchor_world_position, _sample.target_velocity)

func is_live_geometry() -> bool:
	var current := _query_geometry_status()
	if current != Status.VALID:
		status = current
		return false
	return true

## Transaction guards must not invalidate/release the installed original binding.
func _query_geometry_status() -> Status:
	var body := get_target()
	if not is_instance_valid(body) or body.is_queued_for_deletion() or not body.is_inside_tree():
		return Status.DESTROYED
	if _released or _geometry_dirty or WallStickAttachment.single_active_shape_owner(body) != _shape_owner_id or (body.collision_layer & _collision_mask) == 0:
		return Status.INVALID_SURFACE
	if body.shape_owner_get_shape_count(_shape_owner_id) != 1 or body.shape_owner_get_shape(_shape_owner_id, 0) != _shape:
		return Status.INVALID_SURFACE
	return Status.VALID

func query_current_policy_state() -> GrappleAnchorState:
	if _query_geometry_status() != Status.VALID or _profile == null or _sample == null:
		return null
	var body := get_target()
	var pose := body.global_transform * body.shape_owner_get_transform(_shape_owner_id)
	if not WallStickAttachment._usable_transform(pose) or not pose.basis.get_scale().is_equal_approx(_previous_transform.basis.get_scale()) or not WallStickAttachment._yaw_only(pose.basis, _binding_basis):
		return null
	var normal := (pose.basis.inverse().transposed() * _local_normal).normalized()
	if absf(normal.y) > _definition.maximum_abs_normal_y:
		return null
	return _query_policy(_sample.anchor_world_position, _sample.target_velocity)

func sample(physics_step: int, elapsed_seconds: float) -> GrappleAnchorState:
	if not is_live_geometry():
		return _reject(status)
	if physics_step == _sample_step:
		return _sample
	var body := get_target()
	var owner_transform := body.shape_owner_get_transform(_shape_owner_id)
	var pose := body.global_transform * owner_transform
	if not WallStickAttachment._usable_transform(pose) or not is_finite(elapsed_seconds) or elapsed_seconds <= 0.0:
		return _reject(Status.DISCONTINUITY)
	if not WallStickAttachment._yaw_only(pose.basis, _binding_basis):
		return _reject(Status.INVALID_SURFACE)
	var sample_gap_steps := maxi(physics_step - _sample_step, 1)
	if not WallStickAttachment._safe_motion(_previous_transform, pose, _local_point, _local_point, _definition, elapsed_seconds, sample_gap_steps):
		return _reject(Status.DISCONTINUITY)
	var point := pose * _local_point
	var normal := (pose.basis.inverse().transposed() * _local_normal).normalized()
	if absf(normal.y) > _definition.maximum_abs_normal_y:
		return _reject(Status.INVALID_SURFACE)
	var velocity := (point - _previous_transform * _local_point) / elapsed_seconds
	if body is StaticBody3D and not body is AnimatableBody3D:
		velocity += body.constant_linear_velocity + body.constant_angular_velocity.cross(point - body.global_position)
	else:
		var state := PhysicsServer3D.body_get_direct_state(body.get_rid())
		if state == null:
			return _reject(Status.INVALID_SURFACE)
		var physical_point := state.transform * owner_transform * _local_point
		velocity = state.get_velocity_at_local_position(physical_point - state.transform.origin)
		velocity += body.global_basis * (owner_transform * _local_point - _previous_owner_transform * _local_point) / elapsed_seconds
	if not point.is_finite() or not velocity.is_finite():
		return _reject(Status.DISCONTINUITY)
	_sample = _sample_policy(point, velocity)
	_previous_transform = pose
	_previous_owner_transform = owner_transform
	_sample_step = physics_step
	return _sample

func _sample_policy(point: Vector3, velocity: Vector3) -> GrappleAnchorState:
	var state := _query_policy(point, velocity)
	return state if state.is_valid else _reject(Status.INVALID_SURFACE)

func _query_policy(point: Vector3, velocity: Vector3) -> GrappleAnchorState:
	var body := get_target()
	var selected := GrappleTargetResolver.select_grappleable(Grappleable3D.find_explicit_grappleables(body), _profile, 0.0, point, get_world_normal())
	# Changing/removing the accepted contract is invalidation, not a new target.
	if _component_ref != null:
		var component := _component_ref.get_ref() as Grappleable3D
		if not is_instance_valid(component) or component.is_queued_for_deletion() or not component.is_inside_tree() or selected != component or component.get_target_id() != target_identity:
			return GrappleAnchorState.invalid(point, GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED)
		return component.sample_surface_anchor_state(point, velocity)
	if selected != null or (body.collision_layer & _profile.get_collision_mask()) == 0:
		return GrappleAnchorState.invalid(point, GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED)
	return GrappleAnchorState.new(point, velocity)

func _reject(reason: Status) -> GrappleAnchorState:
	status = reason
	var point := _sample.anchor_world_position if _sample != null else Vector3.ZERO
	_sample = GrappleAnchorState.invalid(point, GrappleAnchorState.InvalidationReason.TARGET_DESTROYED if reason == Status.DESTROYED else GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED)
	release()
	return _sample

func release() -> void:
	_released = true
	if _shape != null and _shape_changed_callback.is_valid() and _shape.changed.is_connected(_shape_changed_callback):
		_shape.changed.disconnect(_shape_changed_callback)
	_shape_changed_callback = Callable()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE and _shape != null and _shape_changed_callback.is_valid() and _shape.changed.is_connected(_shape_changed_callback):
		_shape.changed.disconnect(_shape_changed_callback)
