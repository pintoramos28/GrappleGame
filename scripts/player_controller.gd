extends CharacterBody3D

@export var speed := 5.0
@export var acceleration := 16.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.003
@export var trackpad_pan_sensitivity := 0.03
@export var pitch_min := -45.0
@export var pitch_max := 45.0
@export var capture_mouse_on_start := true

@onready var camera_pivot: Node3D = $CameraPivot

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pitch := 0.0


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
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = jump_velocity

	var input_dir := Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var target_velocity := direction * speed

	velocity.x = move_toward(velocity.x, target_velocity.x, acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, acceleration * delta)

	move_and_slide()
