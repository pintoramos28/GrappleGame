class_name WallStickNativeReanchorFixture
extends WallStickReanchorFixture
## Real engine motion, never pose-driven Rigid/Character substitutes. Only the
## support body differs; entry/carry/release use the same production player.

var support_kind := "animatable"

class AnimatableSupport:
	extends AnimatableBody3D
	var motion_velocity := Vector3.ZERO
	var yaw_rate_rps := 0.0
	var owner_motion_velocity := Vector3.ZERO
	var first_tick_teleport := Vector3.ZERO
	func _ready() -> void:
		process_physics_priority = -10
		# This fixture moves on the physics callback already; editor/tween sync
		# would restore the last pose and erase its intended per-step translation.
		sync_to_physics = false
	func _physics_process(delta: float) -> void:
		position += motion_velocity * delta
		rotation.y += yaw_rate_rps * delta
		get_node(^"WallShape").position += owner_motion_velocity * delta

class CharacterSupport:
	extends CharacterBody3D
	var motion_velocity := Vector3.ZERO
	var yaw_rate_rps := 0.0
	var owner_motion_velocity := Vector3.ZERO
	var first_tick_teleport := Vector3.ZERO
	func _ready() -> void:
		process_physics_priority = -10
		collision_mask = 0
	func _physics_process(delta: float) -> void:
		velocity = motion_velocity
		move_and_slide()
		get_node(^"WallShape").position += owner_motion_velocity * delta

class RigidSupport:
	extends RigidBody3D
	var motion_velocity := Vector3.ZERO
	var yaw_rate_rps := 0.0
	var owner_motion_velocity := Vector3.ZERO
	var first_tick_teleport := Vector3.ZERO
	func _ready() -> void:
		process_physics_priority = -10
		gravity_scale = 0.0
		linear_damp = 0.0
		angular_damp = 0.0
		can_sleep = false
		collision_mask = 0
	func _physics_process(delta: float) -> void:
		linear_velocity = motion_velocity
		angular_velocity = Vector3.UP * yaw_rate_rps
		get_node(^"WallShape").position += owner_motion_velocity * delta

func _create_support_body() -> PhysicsBody3D:
	match support_kind:
		"character": return CharacterSupport.new()
		"rigid": return RigidSupport.new()
		_: return AnimatableSupport.new()
