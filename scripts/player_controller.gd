extends CharacterBody3D

@export_group("Ground And Air Movement")
## Maximum horizontal speed while grounded, in meters per second.
@export var max_ground_speed := 5.0
## Maximum horizontal speed while airborne, in meters per second.
@export var max_air_speed := 10.0
## How quickly grounded movement reaches the target speed.
@export var ground_acceleration := 16.0
## How quickly airborne movement reaches the target speed.
@export var air_acceleration := 5.0
## How quickly grounded movement slows when there is no input.
@export var ground_deceleration := 20.0
## How quickly airborne movement slows when there is no input.
@export var air_deceleration := 1.0
## Upward velocity applied when jumping from the floor.
@export var jump_velocity := 4.5

@export_group("Wall Running")
## Highest total speed that can still enter a wall run or wall stick.
@export var wall_run_max_entry_speed := 18.0
## Minimum horizontal speed required to start or keep wall running.
@export var wall_run_min_horizontal_speed := 1.0
## Target movement speed while running along a wall.
@export var wall_run_speed := 10.0
## How quickly wall-run movement reaches its target speed.
@export var wall_run_acceleration := 12.0
## Gravity multiplier applied while wall running.
@export var wall_run_gravity_scale := 0.25
## If enabled, vertical velocity is reset while wall running.
@export var wall_run_zero_vertical_velocity := true
## Largest allowed absolute Y value for a surface normal to count as a wall.
@export var wall_run_max_normal_y := 0.2
## Minimum dot product between movement input and wall-run direction.
@export var wall_run_min_input_alignment := 0.2
## Distance used by side rays when searching for runnable walls.
@export var wall_check_distance := 0.8
## Upward velocity applied when jumping away from a wall.
@export var wall_jump_up_velocity := 5.5
## Horizontal velocity applied away from the wall during a wall jump.
@export var wall_jump_away_velocity := 8.0

@export_group("Camera And Input")
## Mouse-look sensitivity for captured mouse motion.
@export var mouse_sensitivity := 0.003
## Trackpad pan sensitivity before conversion into mouse-look motion.
@export var trackpad_pan_sensitivity := 0.03
## Lowest camera pitch angle, in degrees.
@export var pitch_min := -45.0
## Highest camera pitch angle, in degrees.
@export var pitch_max := 45.0
## If enabled, captures the mouse when the player becomes ready.
@export var capture_mouse_on_start := true

@export_group("Grapple")
## Maximum distance for the grapple targeting ray.
@export var grapple_length := 35.0
## Pull acceleration applied toward the grapple point.
@export var grapple_acceleration := 35.0
## Maximum total velocity allowed while grapple acceleration is applied.
@export var grapple_max_velocity := 22.0
## Gravity multiplier applied while grappling.
@export var grapple_gravity_scale := 1.0

@export_group("Grapple Visuals")
## Radius of the grapple rope cylinder.
@export var grapple_visual_radius := 0.035
## Color used for the grapple rope.
@export var grapple_visual_color := Color(0.1, 0.85, 1.0)
## Radius of the grapple target cursor.
@export var grapple_cursor_radius := 0.2
## Cursor color when a valid grapple target is under the crosshair.
@export var grapple_cursor_color := Color(1.0, 0.9, 0.1)
## Cursor color while actively grappling.
@export var grapple_cursor_active_color := Color(0.2, 1.0, 0.25)

@export_group("Attack Timing")
## Total time before another player attack can begin.
@export var attack_cooldown_time := 0.45
## Delay between attack input and hitbox activation.
@export var attack_windup_time := 0.08
## Duration that the player attack hitbox remains active.
@export var attack_active_time := 0.18

@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var player_mesh: MeshInstance3D = $MeshInstance3D
@onready var health: CombatHealth = get_node_or_null("Health")
@onready var attack_hitbox: CombatHitbox3D = get_node_or_null("AttackHitbox")
@onready var movement_hsm: LimboHSM = $MovementHSM
@onready var grounded_state: LimboState = $MovementHSM/GroundedState
@onready var airborne_state: LimboState = $MovementHSM/AirborneState
@onready var grappling_state: LimboState = $MovementHSM/GrapplingState
@onready var wall_run_state: LimboState = $MovementHSM/WallRunState
@onready var wall_stick_state: LimboState = $MovementHSM/WallStickState
@onready var dead_state: LimboState = $MovementHSM/DeadState
@onready var attack_hsm: LimboHSM = $AttackHSM
@onready var attack_ready_state: LimboState = $AttackHSM/AttackReadyState
@onready var attack_windup_state: LimboState = $AttackHSM/AttackWindupState
@onready var attack_active_state: LimboState = $AttackHSM/AttackActiveState
@onready var attack_recovery_state: LimboState = $AttackHSM/AttackRecoveryState

const EVENT_LEFT_GROUND := &"left_ground"
const EVENT_LANDED := &"landed"
const EVENT_JUMPED := &"jumped"
const EVENT_GRAPPLE_STARTED := &"grapple_started"
const EVENT_GRAPPLE_RELEASED := &"grapple_released"
const EVENT_WALL_RUN_STARTED := &"wall_run_started"
const EVENT_WALL_RUN_FINISHED := &"wall_run_finished"
const EVENT_WALL_STICK_STARTED := &"wall_stick_started"
const EVENT_WALL_STICK_JUMPED := &"wall_stick_jumped"
const EVENT_DIED := &"died"
const EVENT_ATTACK_STARTED := &"attack_started"
const EVENT_ATTACK_PHASE_FINISHED := &"attack_phase_finished"
const EVENT_ATTACK_CANCELLED := &"attack_cancelled"

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pitch := 0.0
var is_grappling := false
var grapple_point := Vector3.ZERO
var grapple_target: StaticBody3D
var grapple_visual: MeshInstance3D
var grapple_visual_mesh: CylinderMesh
var grapple_cursor: MeshInstance3D
var grapple_cursor_mesh: SphereMesh
var grapple_cursor_material: StandardMaterial3D
var is_wall_running := false
var wall_normal := Vector3.ZERO
var wall_run_direction := Vector3.ZERO
var is_wall_sticking := false
var wall_stick_position := Vector3.ZERO
var wall_stick_normal := Vector3.ZERO
var wall_stick_run_direction := Vector3.ZERO
var is_dead := false


func _ready() -> void:
	add_to_group("player")
	_setup_grapple_visual()
	_setup_grapple_cursor()

	if health:
		health.damaged.connect(_on_health_damaged)
		health.died.connect(_on_died)

	camera_pitch = clamp(camera_pivot.rotation.x, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	camera_pivot.rotation.x = camera_pitch

	if capture_mouse_on_start:
		call_deferred("_capture_mouse")

	_init_player_state_machines()


func _init_player_state_machines() -> void:
	movement_hsm.add_transition(grounded_state, airborne_state, EVENT_LEFT_GROUND)
	movement_hsm.add_transition(grounded_state, airborne_state, EVENT_JUMPED)
	movement_hsm.add_transition(grounded_state, grappling_state, EVENT_GRAPPLE_STARTED)
	movement_hsm.add_transition(airborne_state, grounded_state, EVENT_LANDED)
	movement_hsm.add_transition(airborne_state, grappling_state, EVENT_GRAPPLE_STARTED)
	movement_hsm.add_transition(airborne_state, wall_run_state, EVENT_WALL_RUN_STARTED)
	movement_hsm.add_transition(grappling_state, grounded_state, EVENT_LANDED)
	movement_hsm.add_transition(grappling_state, airborne_state, EVENT_GRAPPLE_RELEASED)
	movement_hsm.add_transition(grappling_state, wall_stick_state, EVENT_WALL_STICK_STARTED)
	movement_hsm.add_transition(wall_run_state, grounded_state, EVENT_LANDED)
	movement_hsm.add_transition(wall_run_state, airborne_state, EVENT_WALL_RUN_FINISHED)
	movement_hsm.add_transition(wall_run_state, grappling_state, EVENT_GRAPPLE_STARTED)
	movement_hsm.add_transition(wall_stick_state, airborne_state, EVENT_GRAPPLE_RELEASED)
	movement_hsm.add_transition(wall_stick_state, airborne_state, EVENT_WALL_STICK_JUMPED)
	movement_hsm.add_transition(movement_hsm.ANYSTATE, dead_state, EVENT_DIED)
	movement_hsm.initialize(self)
	movement_hsm.set_active(true)

	attack_hsm.add_transition(attack_ready_state, attack_windup_state, EVENT_ATTACK_STARTED)
	attack_hsm.add_transition(attack_windup_state, attack_active_state, EVENT_ATTACK_PHASE_FINISHED)
	attack_hsm.add_transition(attack_active_state, attack_recovery_state, EVENT_ATTACK_PHASE_FINISHED)
	attack_hsm.add_transition(attack_recovery_state, attack_ready_state, EVENT_ATTACK_PHASE_FINISHED)
	attack_hsm.add_transition(attack_hsm.ANYSTATE, attack_ready_state, EVENT_ATTACK_CANCELLED)
	attack_hsm.initialize(self)
	attack_hsm.set_active(true)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		return

	if is_dead:
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


func _setup_grapple_visual() -> void:
	grapple_visual_mesh = CylinderMesh.new()
	grapple_visual_mesh.radial_segments = 8
	grapple_visual_mesh.rings = 1
	grapple_visual_mesh.top_radius = grapple_visual_radius
	grapple_visual_mesh.bottom_radius = grapple_visual_radius
	grapple_visual_mesh.height = 1.0

	var material := StandardMaterial3D.new()
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = grapple_visual_color
	material.emission_enabled = true
	material.emission = grapple_visual_color

	grapple_visual = MeshInstance3D.new()
	grapple_visual.name = "GrappleVisual"
	grapple_visual.top_level = true
	grapple_visual.mesh = grapple_visual_mesh
	grapple_visual.material_override = material
	grapple_visual.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	grapple_visual.visible = false
	add_child(grapple_visual)


func _setup_grapple_cursor() -> void:
	grapple_cursor_mesh = SphereMesh.new()
	grapple_cursor_mesh.radius = grapple_cursor_radius
	grapple_cursor_mesh.height = grapple_cursor_radius * 2.0

	grapple_cursor_material = StandardMaterial3D.new()
	grapple_cursor_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	grapple_cursor_material.emission_enabled = true
	_set_grapple_cursor_color(grapple_cursor_color)

	grapple_cursor = MeshInstance3D.new()
	grapple_cursor.name = "GrappleCursor"
	grapple_cursor.top_level = true
	grapple_cursor.mesh = grapple_cursor_mesh
	grapple_cursor.material_override = grapple_cursor_material
	grapple_cursor.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	grapple_cursor.visible = false
	add_child(grapple_cursor)


func _apply_horizontal_movement(input_dir: Vector2, delta: float) -> void:
	var direction := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	var current_max_speed := max_ground_speed if is_on_floor() else max_air_speed
	var target_velocity := direction * current_max_speed
	var horizontal_acceleration := _get_horizontal_acceleration(input_dir)

	velocity.x = move_toward(velocity.x, target_velocity.x, horizontal_acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, horizontal_acceleration * delta)


func _get_horizontal_acceleration(input_dir: Vector2) -> float:
	if input_dir == Vector2.ZERO:
		return ground_deceleration if is_on_floor() else air_deceleration

	return ground_acceleration if is_on_floor() else air_acceleration


func _get_gravity_scale() -> float:
	if is_wall_running:
		return wall_run_gravity_scale

	if is_grappling:
		return grapple_gravity_scale

	return 1.0


func _update_wall_run_state(input_dir: Vector2) -> void:
	if is_on_floor() or is_grappling:
		_clear_wall_run()
		return

	var wall_hit := _find_wall_with_velocity_rays()
	if wall_hit.is_empty():
		_clear_wall_run()
		return

	if not is_wall_running and not _can_start_wall_run(velocity):
		return

	var normal: Vector3 = wall_hit["normal"]
	_set_wall_run(normal, velocity)
	if not _has_wall_run_input_for_direction(input_dir, wall_run_direction):
		_clear_wall_run()


func _find_wall_with_velocity_rays() -> Dictionary:
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal_velocity.length() < wall_run_min_horizontal_speed:
		return {}

	var move_forward := horizontal_velocity.normalized()
	var move_right := move_forward.cross(Vector3.UP).normalized()
	var check_dirs: Array[Vector3] = [
		move_right,
		-move_right,
		(move_right + move_forward).normalized(),
		(-move_right + move_forward).normalized(),
	]

	var origin := _get_player_mesh_center()
	var best_hit := {}
	var best_score := -INF
	var space_state := get_world_3d().direct_space_state

	for check_dir in check_dirs:
		var query := PhysicsRayQueryParameters3D.create(origin, origin + check_dir * wall_check_distance)
		query.exclude = [get_rid()]

		var hit := space_state.intersect_ray(query)
		if hit.is_empty():
			continue

		var collider: Object = hit["collider"]
		if not collider is StaticBody3D:
			continue

		var normal: Vector3 = hit["normal"]
		if not _is_valid_wall_normal(normal):
			continue

		var score := normal.dot(-check_dir)
		if score > best_score:
			best_score = score
			best_hit = hit

	return best_hit


func _can_start_wall_run(check_velocity: Vector3) -> bool:
	var horizontal_speed := Vector3(check_velocity.x, 0.0, check_velocity.z).length()
	return (
		horizontal_speed >= wall_run_min_horizontal_speed
		and check_velocity.length() <= wall_run_max_entry_speed
	)


func _is_valid_wall_normal(normal: Vector3) -> bool:
	return abs(normal.y) <= wall_run_max_normal_y


func _set_wall_run(normal: Vector3, reference_velocity: Vector3) -> void:
	wall_normal = normal.normalized()
	wall_run_direction = _get_wall_run_direction(wall_normal, reference_velocity)

	is_wall_running = true


func _get_wall_run_direction(normal: Vector3, reference_velocity: Vector3) -> Vector3:
	var run_direction := normal.normalized().cross(Vector3.UP).normalized()
	var horizontal_velocity := Vector3(reference_velocity.x, 0.0, reference_velocity.z)
	if run_direction.dot(horizontal_velocity) < 0.0:
		run_direction = -run_direction

	return run_direction


func _has_wall_run_input_for_direction(input_dir: Vector2, run_direction: Vector3) -> bool:
	if input_dir == Vector2.ZERO:
		return false

	var input_direction := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	return input_direction.dot(run_direction) >= wall_run_min_input_alignment


func _apply_wall_run_movement(delta: float) -> void:
	if wall_run_zero_vertical_velocity:
		velocity.y = 0.0

	var target_velocity := wall_run_direction * wall_run_speed

	velocity.x = move_toward(velocity.x, target_velocity.x, wall_run_acceleration * delta)
	velocity.z = move_toward(velocity.z, target_velocity.z, wall_run_acceleration * delta)

	var away_from_wall_speed := velocity.dot(wall_normal)
	if away_from_wall_speed > 0.0:
		velocity -= wall_normal * away_from_wall_speed


func _wall_jump() -> void:
	var along_wall_velocity: Vector3 = wall_run_direction * max(
		Vector3(velocity.x, 0.0, velocity.z).dot(wall_run_direction),
		0.0
	)
	velocity = wall_normal * wall_jump_away_velocity + along_wall_velocity
	velocity.y = wall_jump_up_velocity
	_clear_wall_run()


func _wall_stick_jump() -> void:
	var along_wall_velocity: Vector3 = wall_stick_run_direction * wall_run_speed
	velocity = wall_stick_normal * wall_jump_away_velocity + along_wall_velocity
	velocity.y = wall_jump_up_velocity
	_clear_wall_stick()
	_clear_grapple()


func _clear_wall_run() -> void:
	is_wall_running = false
	wall_normal = Vector3.ZERO
	wall_run_direction = Vector3.ZERO


func _try_start_wall_stick_from_collisions(input_dir: Vector2, entry_velocity: Vector3) -> void:
	if (
		is_wall_sticking
		or not is_grappling
		or not Input.is_action_pressed("fire_grapple")
		or is_on_floor()
		or not _can_start_wall_run(entry_velocity)
	):
		return

	for collision_index in range(get_slide_collision_count()):
		var collision := get_slide_collision(collision_index)
		var collider := collision.get_collider()
		if not collider is StaticBody3D:
			continue

		var normal := collision.get_normal()
		if not _is_valid_wall_normal(normal):
			continue

		var run_direction := _get_wall_run_direction(normal, entry_velocity)
		if not _has_wall_run_input_for_direction(input_dir, run_direction):
			continue

		_set_wall_stick(normal, run_direction)
		return


func _set_wall_stick(normal: Vector3, run_direction: Vector3) -> void:
	is_wall_sticking = true
	wall_stick_position = global_position
	wall_stick_normal = normal.normalized()
	wall_stick_run_direction = run_direction
	velocity = Vector3.ZERO
	_clear_wall_run()


func _apply_wall_stick() -> void:
	global_position = wall_stick_position
	velocity = Vector3.ZERO


func _clear_wall_stick() -> void:
	is_wall_sticking = false
	wall_stick_position = Vector3.ZERO
	wall_stick_normal = Vector3.ZERO
	wall_stick_run_direction = Vector3.ZERO


func get_movement_input() -> Vector2:
	return Input.get_vector("move_left", "move_right", "move_forward", "move_back")


func update_grapple_feedback() -> void:
	_update_grapple_visual()
	_update_grapple_cursor()


func apply_default_gravity(delta: float) -> void:
	if not is_on_floor():
		if is_wall_running and wall_run_zero_vertical_velocity:
			velocity.y = 0.0
		else:
			velocity.y -= gravity * _get_gravity_scale() * delta


func apply_ground_jump() -> void:
	velocity.y = jump_velocity


func slide_and_check_wall_stick(input_dir: Vector2) -> void:
	var slide_entry_velocity := velocity
	move_and_slide()
	_try_start_wall_stick_from_collisions(input_dir, slide_entry_velocity)


func dispatch_locomotion_after_grapple_clear() -> void:
	if is_on_floor():
		movement_hsm.dispatch(EVENT_LANDED)
	else:
		movement_hsm.dispatch(EVENT_GRAPPLE_RELEASED)


func try_start_grapple() -> bool:
	var hit := _get_grapple_ray_hit()
	if hit.is_empty():
		return false

	var collider: Object = hit["collider"]
	if collider is StaticBody3D:
		is_grappling = true
		grapple_point = hit["position"]
		grapple_target = collider as StaticBody3D
		return true

	return false


func has_valid_grapple() -> bool:
	return is_grappling and is_instance_valid(grapple_target)


func _get_grapple_ray_hit() -> Dictionary:
	var origin := camera.global_position
	var direction := -camera.global_transform.basis.z
	var query := PhysicsRayQueryParameters3D.create(origin, origin + direction * grapple_length)
	query.exclude = [get_rid()]

	return get_world_3d().direct_space_state.intersect_ray(query)


func _update_grapple_visual() -> void:
	if not is_grappling:
		grapple_visual.visible = false
		return

	var start := _get_player_mesh_center()
	var end := grapple_point
	var segment := end - start
	var length := segment.length()
	if length <= 0.001:
		grapple_visual.visible = false
		return

	grapple_visual_mesh.height = length
	grapple_visual.global_transform = Transform3D(_basis_from_y_axis(segment), start + segment * 0.5)
	grapple_visual.visible = true


func _update_grapple_cursor() -> void:
	var hit := _get_grapple_ray_hit()
	if hit.is_empty():
		grapple_cursor.visible = false
		return

	var collider: Object = hit["collider"]
	if not collider is StaticBody3D:
		grapple_cursor.visible = false
		return

	var cursor_color: Color = grapple_cursor_active_color if is_grappling else grapple_cursor_color
	_set_grapple_cursor_color(cursor_color)
	grapple_cursor.global_position = hit["position"]
	grapple_cursor.visible = true


func _set_grapple_cursor_color(color: Color) -> void:
	grapple_cursor_material.albedo_color = color
	grapple_cursor_material.emission = color


func _basis_from_y_axis(y_axis: Vector3) -> Basis:
	var y := y_axis.normalized()
	var helper := Vector3.FORWARD
	if abs(y.dot(helper)) > 0.98:
		helper = Vector3.RIGHT

	var x := helper.cross(y).normalized()
	var z := x.cross(y).normalized()
	return Basis(x, y, z)


func _get_player_mesh_center() -> Vector3:
	var bounds: AABB = player_mesh.get_aabb()
	return player_mesh.to_global(bounds.get_center())


func _apply_grapple_acceleration(delta: float) -> void:
	if not is_instance_valid(grapple_target):
		_clear_grapple()
		return

	var pull_direction := _get_player_mesh_center().direction_to(grapple_point)
	if pull_direction == Vector3.ZERO:
		return

	velocity += pull_direction * grapple_acceleration * delta

	if grapple_max_velocity > 0.0 and velocity.length() > grapple_max_velocity:
		velocity = velocity.normalized() * grapple_max_velocity


func _clear_grapple() -> void:
	is_grappling = false
	grapple_point = Vector3.ZERO
	grapple_target = null
	_clear_wall_stick()
	if grapple_visual:
		grapple_visual.visible = false


func _apply_dead_physics(delta: float) -> void:
	velocity.x = move_toward(velocity.x, 0.0, ground_deceleration * delta)
	velocity.z = move_toward(velocity.z, 0.0, ground_deceleration * delta)
	if not is_on_floor():
		velocity.y -= gravity * delta

	move_and_slide()
	_update_grapple_visual()


func _cancel_attack() -> void:
	if attack_hitbox:
		attack_hitbox.cancel()


func _set_dead() -> void:
	if is_dead:
		return

	is_dead = true
	_cancel_attack()
	_clear_grapple()
	_clear_wall_run()
	_clear_wall_stick()
	if grapple_cursor:
		grapple_cursor.visible = false
	if movement_hsm:
		movement_hsm.dispatch(EVENT_DIED)
	if attack_hsm:
		attack_hsm.dispatch(EVENT_ATTACK_CANCELLED)


func _on_health_damaged(damage_instance: DamageInstance) -> void:
	print(
		"Player took %.1f %s damage. HP: %.1f/%.1f" % [
			damage_instance.final_damage,
			damage_instance.get_largest_damage_type(),
			health.current_health,
			health.max_health,
		]
	)


func _on_died(_damage_instance: DamageInstance) -> void:
	_set_dead()
	print("Player died")
