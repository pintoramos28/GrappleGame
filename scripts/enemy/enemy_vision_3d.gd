class_name EnemyVision3D
extends Area3D

signal target_spotted(target: Node3D)
signal target_lost(target: Node3D)
signal target_visibility_changed(target: Node3D, can_see_target: bool)

@export var vision_range := 12.0:
	set(value):
		vision_range = maxf(value, 0.1)
		_update_shape_radius()
@export_range(1.0, 360.0, 1.0) var vision_angle_degrees := 110.0
@export var lose_target_after_seconds := 1.5
@export var require_line_of_sight := true
@export var close_visibility_distance := 1.25
@export var eye_height := 1.35
@export var target_eye_height := 1.0
@export var target_group := "player"
@export_flags_3d_physics var line_of_sight_collision_mask := 0xFFFFFFFF

var current_target: Node3D
var last_seen_position := Vector3.ZERO
var has_line_of_sight := false

var _candidates: Array[Node3D] = []
var _time_since_seen := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	monitoring = true
	_update_shape_radius()


func _physics_process(delta: float) -> void:
	_update_target(delta)


func configure(definition: EnemyDefinition) -> void:
	if definition == null:
		return

	vision_range = definition.vision_range
	vision_angle_degrees = definition.vision_angle_degrees
	lose_target_after_seconds = definition.lose_target_after_seconds
	require_line_of_sight = definition.require_line_of_sight


func can_see_target(target: Node3D) -> bool:
	if not is_instance_valid(target):
		return false

	if global_position.distance_to(target.global_position) > vision_range:
		return false

	if global_position.distance_to(target.global_position) <= close_visibility_distance:
		return true

	if not _is_inside_vision_angle(target):
		return false

	if require_line_of_sight and not _has_line_of_sight(target):
		return false

	return true


func _update_target(delta: float) -> void:
	var visible_target := _find_visible_target()
	if is_instance_valid(visible_target):
		var was_target := visible_target == current_target
		current_target = visible_target
		last_seen_position = visible_target.global_position
		_time_since_seen = 0.0
		_set_line_of_sight(true)
		if not was_target:
			target_spotted.emit(current_target)
		return

	_set_line_of_sight(false)
	if not is_instance_valid(current_target):
		return

	_time_since_seen += delta
	if _time_since_seen >= lose_target_after_seconds:
		var lost_target := current_target
		current_target = null
		target_lost.emit(lost_target)


func _find_visible_target() -> Node3D:
	var closest_target: Node3D
	var closest_distance_squared := INF
	var visible_candidates := _candidates.duplicate()

	for group_member in get_tree().get_nodes_in_group(target_group):
		var candidate := group_member as Node3D
		if candidate != null and candidate not in visible_candidates:
			visible_candidates.append(candidate)

	for candidate in visible_candidates:
		if not is_instance_valid(candidate):
			continue
		if not can_see_target(candidate):
			continue

		var distance_squared := global_position.distance_squared_to(candidate.global_position)
		if distance_squared < closest_distance_squared:
			closest_distance_squared = distance_squared
			closest_target = candidate

	return closest_target


func _is_inside_vision_angle(target: Node3D) -> bool:
	if vision_angle_degrees >= 359.0:
		return true

	var to_target := target.global_position - global_position
	to_target.y = 0.0
	if to_target.length_squared() <= 0.001:
		return true

	var forward := -global_transform.basis.z
	forward.y = 0.0
	forward = forward.normalized()

	var min_dot := cos(deg_to_rad(vision_angle_degrees) * 0.5)
	return forward.dot(to_target.normalized()) >= min_dot


func _has_line_of_sight(target: Node3D) -> bool:
	var owner_body := get_parent()
	var from := global_position + Vector3.UP * eye_height
	var to := target.global_position + Vector3.UP * target_eye_height
	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = line_of_sight_collision_mask
	if owner_body is CollisionObject3D:
		query.exclude = [(owner_body as CollisionObject3D).get_rid()]

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return not require_line_of_sight

	var collider := hit.get("collider") as Node
	return collider != null and (collider == target or target.is_ancestor_of(collider))


func _set_line_of_sight(value: bool) -> void:
	if has_line_of_sight == value:
		return

	has_line_of_sight = value
	if is_instance_valid(current_target):
		target_visibility_changed.emit(current_target, has_line_of_sight)


func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group(target_group) and body not in _candidates:
		_candidates.append(body)


func _on_body_exited(body: Node3D) -> void:
	_candidates.erase(body)


func _update_shape_radius() -> void:
	if not is_inside_tree():
		return

	for child in get_children():
		var shape_node := child as CollisionShape3D
		if shape_node == null:
			continue

		var sphere := shape_node.shape as SphereShape3D
		if sphere:
			sphere.radius = vision_range
