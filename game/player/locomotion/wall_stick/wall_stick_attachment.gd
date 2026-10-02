class_name WallStickAttachment
extends RefCounted
## Owner-local attachment. Contact snapshots stay value-only; only this private
## weak handle follows the actual selected physical shape, never the rope target.

enum Status { VALID, DESTROYED, INVALID_SUPPORT, CONTACT_LOST, DIFFERENT_FACE, DISCONTINUITY }

var target_world_position: Vector3:
	get:
		return _target_world_position
var world_normal: Vector3:
	get:
		return _world_normal
var point_velocity: Vector3:
	get:
		return _point_velocity
var status: Status:
	get:
		return _status

var _body_ref: WeakRef
var _shape_owner_id: int
var _shape_index: int
var _shape: Shape3D
var _local_point: Vector3
var _local_normal: Vector3
var _local_player_position: Vector3
var _previous_transform: Transform3D
var _previous_query_transform: Transform3D
var _binding_basis: Basis
var _validated_frame: ContactFrame
var _geometry_dirty := false
var _released := false
var _shape_changed_callback: Callable
var _target_world_position: Vector3
var _world_normal: Vector3
var _point_velocity := Vector3.ZERO
var _definition: WallStickDefinition
var _collision_mask: int
var _face_angle_radians: float
var _sample_step: int
var _status := Status.VALID

static func bind(body: CollisionObject3D, evidence: ContactCandidate, player_position: Vector3, definition: WallStickDefinition, collision_mask: int, face_angle_radians: float, delta: float = 1.0 / 60.0) -> WallStickAttachment:
	if not is_instance_valid(body) or not body is PhysicsBody3D or evidence == null or definition == null or evidence.shape_index < 0:
		return null
	if not definition.is_locked() or not evidence.point.is_finite() or not evidence.normal.is_finite():
		return null
	var owner_id := body.shape_find_owner(evidence.shape_index)
	if single_active_shape_owner(body) != owner_id:
		return null
	var support_transform := physical_body_transform(body) * body.shape_owner_get_transform(owner_id)
	var author_transform := body.global_transform * body.shape_owner_get_transform(owner_id)
	if not _usable_transform(support_transform) or not _usable_transform(author_transform) or not player_position.is_finite():
		return null
	var result := WallStickAttachment.new()
	result._body_ref = weakref(body)
	result._shape_owner_id = owner_id
	result._shape_index = evidence.shape_index
	result._shape = body.shape_owner_get_shape(owner_id, 0)
	result._local_point = support_transform.affine_inverse() * evidence.point
	result._local_normal = (support_transform.basis.transposed() * evidence.normal).normalized()
	result._local_player_position = support_transform.affine_inverse() * player_position
	if not _safe_motion(support_transform, author_transform, result._local_player_position, result._local_point, definition, delta) or not _yaw_only(author_transform.basis, support_transform.basis):
		return null
	# Bind the physical face/stand-off, but start motion from the author's current
	# pose. Do not replay already elapsed tangential query lag as another tick.
	var author_local_player := author_transform.affine_inverse() * player_position
	author_local_player += result._local_normal * (result._local_player_position - author_local_player).dot(result._local_normal)
	result._local_player_position = author_local_player
	result._previous_transform = author_transform
	result._previous_query_transform = support_transform
	result._binding_basis = author_transform.basis
	result._target_world_position = player_position
	result._world_normal = evidence.normal
	result._definition = definition
	result._collision_mask = collision_mask
	result._face_angle_radians = face_angle_radians
	result._sample_step = evidence.physics_step
	# The callback holds only a weak attachment reference. It marks pending
	# geometry dirty; only the next physics sample may change gameplay status.
	# A closure gives each listener its own callable identity. Capture only the
	# weak handle, never result/self, to avoid a Shape -> attachment cycle.
	var attachment_ref: WeakRef = weakref(result)
	result._shape_changed_callback = func() -> void:
		var attachment := attachment_ref.get_ref() as WallStickAttachment
		if attachment != null:
			attachment._geometry_dirty = true
	result._shape.changed.connect(result._shape_changed_callback)
	return result

func sample(frame: ContactFrame, physics_step: int, delta: float) -> bool:
	if _released:
		return false
	if physics_step == _sample_step:
		return _status == Status.VALID
	if _status != Status.VALID:
		return false
	var body := _body_ref.get_ref() as CollisionObject3D
	if not is_instance_valid(body) or body.is_queued_for_deletion() or not body.is_inside_tree():
		return _reject(Status.DESTROYED)
	if _geometry_dirty or single_active_shape_owner(body) != _shape_owner_id or (body.collision_layer & _collision_mask) == 0:
		return _reject(Status.INVALID_SUPPORT)
	if body.shape_owner_get_shape_count(_shape_owner_id) != 1 or body.shape_owner_get_shape(_shape_owner_id, 0) != _shape:
		return _reject(Status.INVALID_SUPPORT)
	if frame == null or frame.physics_step != physics_step - 1 or not frame.wall_probe_query_succeeded or frame.wall_contact_lost or not frame.has_wall_contact:
		return _reject(Status.CONTACT_LOST)
	var evidence := frame.wall_support
	if evidence == null:
		return _reject(Status.CONTACT_LOST)
	# The transient RID is only corroboration of this private live weak handle,
	# not a persistent identity or a lookup mechanism.
	if evidence.shape_index != _shape_index or evidence.transient_identity != StringName("physics_rid:%d" % body.get_rid().get_id()):
		return _reject(Status.DIFFERENT_FACE)
	var evidence_normal := (_previous_query_transform.basis.transposed() * evidence.normal).normalized()
	if evidence_normal.angle_to(_local_normal) > _face_angle_radians:
		return _reject(Status.DIFFERENT_FACE)
	var current_transform := body.global_transform * body.shape_owner_get_transform(_shape_owner_id)
	if not _usable_transform(current_transform) or delta <= 0.0 or not is_finite(delta):
		return _reject(Status.DISCONTINUITY)
	if not current_transform.basis.get_scale().is_equal_approx(_previous_transform.basis.get_scale()):
		return _reject(Status.DISCONTINUITY)
	# The production upright capsule is invariant under yaw, not pitch/roll.
	# Changing that support orientation invalidates its captured stand-off.
	if not _yaw_only(current_transform.basis, _binding_basis):
		return _reject(Status.INVALID_SUPPORT)
	var new_position := current_transform * _local_player_position
	var displacement := new_position - _previous_transform * _local_player_position
	if not _safe_motion(_previous_transform, current_transform, _local_player_position, _local_point, _definition, delta) or new_position.distance_to(_target_world_position) > _definition.maximum_support_step_m:
		return _reject(Status.DISCONTINUITY)
	var normal := (current_transform.basis.inverse().transposed() * _local_normal).normalized()
	if absf(normal.y) > _definition.maximum_abs_normal_y:
		return _reject(Status.INVALID_SUPPORT)
	_target_world_position = new_position
	_world_normal = normal
	_point_velocity = displacement / delta
	_previous_transform = current_transform
	_previous_query_transform = physical_body_transform(body) * body.shape_owner_get_transform(_shape_owner_id)
	# Public shape indices can renumber when an unrelated disabled owner is
	# removed. The owner/local shape is stable; refresh the next publication key.
	_shape_index = body.shape_owner_get_shape_index(_shape_owner_id, 0)
	_validated_frame = frame
	_sample_step = physics_step
	return true

func _reject(reason: Status) -> bool:
	_status = reason
	release()
	return false

func matches_contact(frame: ContactFrame) -> bool:
	if _released or _status != Status.VALID:
		return false
	if frame != null and frame == _validated_frame:
		return true
	var body := _body_ref.get_ref() as CollisionObject3D
	if not is_instance_valid(body) or body.is_queued_for_deletion() or frame == null or frame.wall_support == null:
		return false
	var evidence := frame.wall_support
	return evidence.shape_index == _shape_index and evidence.transient_identity == StringName("physics_rid:%d" % body.get_rid().get_id()) and (_previous_query_transform.basis.transposed() * evidence.normal).normalized().angle_to(_local_normal) <= _face_angle_radians

## Provider-private corroboration against current physical candidates, never
## against the legacy run winner or a RID-to-object lookup.
func matches_physical_candidate(candidate: ContactCandidate, body: CollisionObject3D) -> bool:
	return not _released and _status == Status.VALID and is_instance_valid(body) and body == _body_ref.get_ref() and single_active_shape_owner(body) == _shape_owner_id and candidate.shape_index == body.shape_owner_get_shape_index(_shape_owner_id, 0) and (_previous_query_transform.basis.transposed() * candidate.normal).normalized().angle_to(_local_normal) <= _face_angle_radians

func release() -> void:
	_released = true
	if _shape != null and _shape_changed_callback.is_valid() and _shape.changed.is_connected(_shape_changed_callback):
		_shape.changed.disconnect(_shape_changed_callback)
	_shape_changed_callback = Callable()

## Copy the proven physical shape-local CONTACT, never the capsule stand-off.
## The grapple owns its independent listener/baseline after carry is released.
func create_grapple_surface_binding(frame: ContactFrame) -> GrappleSurfaceBinding:
	if _released or _status != Status.VALID or _geometry_dirty or frame == null or frame.wall_support == null or not matches_contact(frame):
		return null
	return GrappleSurfaceBinding.bind(_body_ref.get_ref() as CollisionObject3D, _shape_owner_id, _shape, _local_point, _local_normal, _definition, _collision_mask, frame.physics_step, frame.wall_point_velocity)

func _notification(what: int) -> void:
	# RefCounted's last-reference notification cannot call another instance
	# method (self is already invalid for such calls). Disconnect inline.
	if what == NOTIFICATION_PREDELETE and _shape != null and _shape_changed_callback.is_valid() and _shape.changed.is_connected(_shape_changed_callback):
		_shape.changed.disconnect(_shape_changed_callback)

## Whole-body exclusion is safe only for this deliberately narrow geometry
## contract. Empty/disabled unrelated owners are allowed; compounds are not.
static func single_active_shape_owner(body: CollisionObject3D) -> int:
	var selected := -1
	for owner_id in body.get_shape_owners():
		if body.is_shape_owner_disabled(owner_id) or body.shape_owner_get_shape_count(owner_id) == 0:
			continue
		if selected != -1 or body.shape_owner_get_shape_count(owner_id) != 1:
			return -1
		selected = owner_id
	return selected

static func _yaw_only(current: Basis, binding: Basis) -> bool:
	var change := current.orthonormalized() * binding.orthonormalized().inverse()
	return (change * Vector3.UP).angle_to(Vector3.UP) <= 0.0001

static func _safe_motion(before: Transform3D, after: Transform3D, player_point: Vector3, contact_point: Vector3, definition: WallStickDefinition, delta: float, sample_gap_steps: int = 1) -> bool:
	if delta <= 0.0 or not is_finite(delta) or not before.basis.get_scale().is_equal_approx(after.basis.get_scale()):
		return false
	var displacement := after * player_point - before * player_point
	var point_displacement := after * contact_point - before * contact_point
	var rotation_delta := after.basis.orthonormalized().get_rotation_quaternion().angle_to(before.basis.orthonormalized().get_rotation_quaternion())
	return displacement.length() <= definition.maximum_support_step_m * float(maxi(sample_gap_steps, 1)) and maxf(displacement.length(), point_displacement.length()) / delta <= definition.maximum_support_speed_mps and rotation_delta / delta <= definition.maximum_support_rotation_rps

## Internal influence seam; the weak collider is never exposed in snapshots.
func submit_hold(motor: PlayerMotor, source: StringName, anchor: GrappleAnchorState, maximum_length_m: float) -> PlayerMotor.SubmissionStatus:
	return motor.submit_wall_stick_hold(source, _target_world_position, _definition.carry_error_tolerance_m, anchor.anchor_world_position, maximum_length_m, anchor.target_velocity, _body_ref)

static func physical_body_transform(body: CollisionObject3D) -> Transform3D:
	if body is PhysicsBody3D:
		var state := PhysicsServer3D.body_get_direct_state(body.get_rid())
		if state != null:
			return state.transform
	return body.global_transform

static func _usable_transform(value: Transform3D) -> bool:
	return value.is_finite() and absf(value.basis.determinant()) > 0.000001
