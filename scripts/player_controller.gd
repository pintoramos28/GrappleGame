extends CharacterBody3D

@export var speed := 5.0
@export var acceleration := 16.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.003
@export var trackpad_pan_sensitivity := 0.03
@export var pitch_min := -45.0
@export var pitch_max := 45.0
@export var capture_mouse_on_start := true
@export var grapple_length := 35.0
@export var grapple_acceleration := 35.0
@export var grapple_max_velocity := 22.0

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pitch := 0.0
var is_grappling := false
var grapple_point := Vector3.ZERO
var grapple_target: StaticBody3D


func _ready() -> void:
	camera_pitch = clamp(camera_pivot.rotation.x, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	camera_pivot.rotation.x = camera_pitch

	if capture_mouse_on_start:
		call_deferred("_capture_mouse")

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	if event is InputEventMouseButton and event.pressed:
		_capture_mouse()
		return

	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_apply_mouse_look(event.relative)

	if event is InputEventPanGesture and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_apply_mouse_look(event.delta * trackpad_pan_sensitivity / mouse_sensitivity)


func _capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _apply_mouse_look(relative_motion: Vector2) -> void:
	if relative_motion == Vector2.ZERO:
		return

	rotate_y(-relative_motion.x * mouse_sensitivity)
	camera_pitch = clamp(
		camera_pitch - relative_motion.y * mouse_sensitivity,
		deg_to_rad(pitch_min),
		deg_to_rad(pitch_max)
	)
	camera_pivot.rotation.x = camera_pitch


func _physics_process(delta: float) -> void:
	if Input.is_action_just_released("fire_grapple"):
		_clear_grapple()

	if Input.is_action_just_pressed("fire_grapple"):
		_try_start_grapple()

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var target_velocity := direction * speed

	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	if is_grappling and Input.is_action_pressed("fire_grapple"):
		_apply_grapple_acceleration(delta)

	move_and_slide()


func _try_start_grapple() -> void:
	var origin := camera.global_position
	var direction := -camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * grapple_length)
	query.exclude = [get_rid()]

	var hit := get_world_3d().direct_space_state.intersect_ray(query)
	if hit.is_empty():
		return

	var collider: Object = hit["collider"]
	if collider is StaticBody3D:
		is_grappling = true
		grapple_point = hit["position"]
		grapple_target = collider as StaticBody3D


func _apply_grapple_acceleration(delta: float) -> void:
	if not is_instance_valid(grapple_target):
		_clear_grapple()
		return

	var pull_direction := global_position.direction_to(grapple_point)
	if pull_direction == Vector3.ZERO:
		return

	velocity += pull_direction * grapple_acceleration * delta

	if grapple_max_velocity > 0.0 and velocity.length() > grapple_max_velocity:
		velocity = velocity.normalized() * grapple_max_velocity


func _clear_grapple() -> void:
	is_grappling = false
	grapple_point = Vector3.ZERO
	grapple_target = null
