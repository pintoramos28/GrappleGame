extends StaticBody3D
## Test-only transform mover reproduces the production StaticBody motion model.
## It moves before the production player, never writes player state.
var motion_velocity := Vector3.ZERO
var yaw_rate_rps := 0.0
var owner_motion_velocity := Vector3.ZERO
var roll_increment_radians := 0.0
var pitch_increment_radians := 0.0
var first_tick_teleport := Vector3.ZERO
var _ticks := 0

func _ready() -> void:
	process_physics_priority = -10

func _physics_process(delta: float) -> void:
	_ticks += 1
	if _ticks == 1:
		position += first_tick_teleport
	position += motion_velocity * delta
	rotation.y += yaw_rate_rps * delta
	rotation.z += roll_increment_radians
	rotation.x += pitch_increment_radians
	var shape := get_node_or_null(^"WallShape") as CollisionShape3D
	if shape != null:
		shape.position += owner_motion_velocity * delta
