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
## If enabled, inverts the vertical mouse-look axis at the player input boundary.
@export var invert_mouse_y := false

@export_group("Grapple")
## Maximum distance for the grapple targeting ray.
@export var grapple_length := 35.0
## Initial pull acceleration applied when a grapple starts, in meters per second squared.
@export var grapple_initial_acceleration := 48.0
## Lowest pull acceleration maintained while the grapple remains active, in meters per second squared.
@export var grapple_min_acceleration := 8.0
## Rate at which pull acceleration decreases, in meters per second cubed.
@export var grapple_acceleration_jerk := 53.333333
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
@onready var input_source: PlayerInputSource = $PlayerInputSource
@onready var player_motor: PlayerMotor = get_node_or_null(^"PlayerMotor") as PlayerMotor
@onready var player_mesh: MeshInstance3D = $MeshInstance3D
@onready var health: CombatHealth = get_node_or_null("Health")
@onready var attack_hitbox: CombatHitbox3D = get_node_or_null("AttackHitbox")
@onready var attack_visual: AttackArcVisual3D = get_node_or_null("AttackVisual")
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
const LOCOMOTION_GROUNDED := &"player.locomotion.grounded"
const LOCOMOTION_AIRBORNE := &"player.locomotion.airborne"
const LOCOMOTION_GRAPPLING := &"player.locomotion.grappling"
const LOCOMOTION_WALL_RUN := &"player.locomotion.wall_run"
const LOCOMOTION_WALL_STICK := &"player.locomotion.wall_stick"
const LOCOMOTION_DEAD := &"player.locomotion.dead"
const COMMAND_JUMP_PRESSED := &"player.command.jump_pressed"
const SOURCE_TERMINAL_DEAD := &"player.terminal.dead"
const SOURCE_BASE_GROUNDED := &"player.locomotion.grounded.base"
const SOURCE_BASE_AIRBORNE := &"player.locomotion.airborne.base"
const SOURCE_BASE_GRAPPLING := &"player.locomotion.grappling.base"
const SOURCE_BASE_WALL_RUN := &"player.locomotion.wall_run.base"
const SOURCE_BASE_WALL_STICK := &"player.locomotion.wall_stick.base"
const SOURCE_BASE_DEAD := &"player.locomotion.dead.base"
const SOURCE_GRAVITY_DEFAULT := &"player.gravity.default"
const SOURCE_GRAVITY_GRAPPLE := &"player.gravity.grapple"
const SOURCE_GRAVITY_WALL_RUN := &"player.gravity.wall_run"
const SOURCE_GRAPPLE_PULL := &"player.grapple.pull"
const SOURCE_GRAPPLE_SPEED_CAP := &"player.grapple.speed_cap"
const SOURCE_JUMP_GROUND := &"player.jump.ground"
const SOURCE_JUMP_WALL := &"player.jump.wall"
const SOURCE_WALL_RUN_CONSTRAINT := &"player.wall_run.constraint"
const SOURCE_WALL_STICK_HOLD := &"player.wall_stick.hold"

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pitch := 0.0
var is_grappling := false
var grapple_elapsed := 0.0
var grapple_applied_acceleration := 0.0
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
var _player_physics_step := 0
var _current_command_frame: PlayerCommandFrame
var _current_motor_result: PlayerMotorCommitResult
var _submitted_locomotion_state_id: StringName = &""
var _pending_locomotion_event: StringName = &""
var _motion_submission_failed := false
var _motion_submission_failure_status := PlayerMotor.SubmissionStatus.SUCCESS
var _player_initialized := false
var _player_log: GameLog = GameLog.new()


func _ready() -> void:
	add_to_group("player")
	_setup_grapple_visual()
	_setup_grapple_cursor()

	if health:
		health.damaged.connect(_on_health_damaged)
		health.died.connect(_on_died)

	camera_pitch = clamp(camera_pivot.rotation.x, deg_to_rad(pitch_min), deg_to_rad(pitch_max))
	camera_pivot.rotation.x = camera_pitch

	if input_source == null:
		push_error("PlayerController requires its PlayerInputSource child.")
		return
	input_source.mouse_sensitivity = mouse_sensitivity
	input_source.trackpad_pan_sensitivity = trackpad_pan_sensitivity
	input_source.pitch_min_radians = deg_to_rad(pitch_min)
	input_source.pitch_max_radians = deg_to_rad(pitch_max)
	input_source.invert_mouse_y = invert_mouse_y
	var input_initialization := input_source.initialize(self, camera_pivot)
	if input_initialization != PlayerInputSource.InitializationStatus.SUCCESS:
		push_error("PlayerController input initialization failed: %s" % input_source.initialization_error)
		return

	if player_motor == null:
		_player_log.record_invariant(
			&"player.controller.motor_missing",
			DiagnosticContext.new(-1, &"", &"missing_motor")
		)
		input_source.set_enabled(false)
		return
	var motor_initialization := player_motor.initialize(self)
	if motor_initialization != PlayerMotor.InitializationStatus.SUCCESS:
		_player_log.record_invariant(
			&"player.controller.motor_initialization_failed",
			DiagnosticContext.new(
				-1,
				&"",
				PlayerMotor.initialization_status_id(motor_initialization)
			)
		)
		input_source.set_enabled(false)
		return
	_player_initialized = true

	if capture_mouse_on_start:
		input_source.request_mouse_capture()

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
	movement_hsm.set_process(false)
	movement_hsm.set_physics_process(false)

	attack_hsm.add_transition(attack_ready_state, attack_windup_state, EVENT_ATTACK_STARTED)
	attack_hsm.add_transition(attack_windup_state, attack_active_state, EVENT_ATTACK_PHASE_FINISHED)
	attack_hsm.add_transition(attack_active_state, attack_recovery_state, EVENT_ATTACK_PHASE_FINISHED)
	attack_hsm.add_transition(attack_recovery_state, attack_ready_state, EVENT_ATTACK_PHASE_FINISHED)
	attack_hsm.add_transition(attack_hsm.ANYSTATE, attack_ready_state, EVENT_ATTACK_CANCELLED)
	attack_hsm.initialize(self)
	attack_hsm.set_active(true)
	attack_hsm.set_process(false)
	attack_hsm.set_physics_process(false)


func _physics_process(delta: float) -> void:
	if not _player_initialized:
		return

	_player_physics_step += 1
	var frame := input_source.capture_command_frame(_player_physics_step)
	if frame == null:
		_player_log.record_invariant(
			&"player.controller.command_frame_failed",
			DiagnosticContext.new(_player_physics_step, &"", &"command_frame_failed")
		)
		_deactivate_player()
		return
	_current_command_frame = frame

	if player_motor == null or not is_instance_valid(player_motor):
		_player_log.record_invariant(
			&"player.controller.motor_unavailable",
			DiagnosticContext.new(_player_physics_step, &"", &"motor_unavailable")
		)
		_deactivate_player()
		return

	_apply_canonical_presentation(frame)
	var frame_status := player_motor.begin_motion_frame(_player_physics_step, delta)
	if frame_status != PlayerMotor.FrameStatus.SUCCESS:
		_abort_motion_frame_safely()
		_deactivate_player()
		return
	_pending_locomotion_event = &""
	_submitted_locomotion_state_id = &""
	_motion_submission_failed = false
	_motion_submission_failure_status = PlayerMotor.SubmissionStatus.SUCCESS

	if movement_hsm and movement_hsm.is_active():
		movement_hsm.update(delta)
	else:
		_abort_motion_frame_safely()
		_player_log.record_invariant(
			&"player.controller.movement_hsm_inactive",
			DiagnosticContext.new(_player_physics_step, &"", &"movement_hsm_inactive")
		)
		_deactivate_player()
		return

	if _motion_submission_failed:
		_abort_motion_frame_safely()
		_deactivate_player()
		return

	var motor_result := player_motor.resolve_and_commit()
	if motor_result == null or not motor_result.success:
		_abort_motion_frame_safely()
		_deactivate_player()
		return
	_current_motor_result = motor_result
	_coordinate_post_commit(motor_result)
	if not _player_initialized:
		return
	if not is_dead:
		update_grapple_feedback()
	if attack_hsm and attack_hsm.is_active():
		attack_hsm.update(delta)


func _deactivate_player() -> void:
	_player_initialized = false
	if input_source:
		input_source.set_enabled(false)
	if movement_hsm:
		movement_hsm.set_active(false)
	if attack_hsm:
		attack_hsm.set_active(false)


func _abort_motion_frame_safely() -> void:
	if (
		player_motor != null
		and is_instance_valid(player_motor)
		and player_motor.has_active_motion_frame()
	):
		player_motor.abort_motion_frame()


func _coordinate_post_commit(result: PlayerMotorCommitResult) -> void:
	if _submitted_locomotion_state_id == LOCOMOTION_GRAPPLING and is_grappling and not result.on_floor:
		var started_wall_stick := _try_start_wall_stick_from_collisions(
			_current_command_frame.movement_axis,
			result.submitted_velocity,
			result.slide_collisions,
			result.position_after
		)
		if started_wall_stick:
			dispatch_locomotion_event(EVENT_WALL_STICK_STARTED)

	if _submitted_locomotion_state_id == LOCOMOTION_GRAPPLING and result.on_floor:
		if is_grappling:
			_clear_grapple()
		if _pending_locomotion_event != &"":
			return
		dispatch_locomotion_event(EVENT_LANDED)
		return

	if _pending_locomotion_event != &"":
		return
	if _submitted_locomotion_state_id == LOCOMOTION_GROUNDED and not result.on_floor:
		dispatch_locomotion_event(EVENT_LEFT_GROUND)
	elif (
		_submitted_locomotion_state_id == LOCOMOTION_AIRBORNE
		or _submitted_locomotion_state_id == LOCOMOTION_WALL_RUN
	) and result.on_floor:
		dispatch_locomotion_event(EVENT_LANDED)


func _apply_canonical_presentation(frame: PlayerCommandFrame) -> void:
	var body_rotation := global_rotation
	body_rotation.y = frame.view_yaw_radians
	global_rotation = body_rotation
	camera_pitch = frame.view_pitch_radians
	camera_pivot.rotation.x = camera_pitch


func get_player_command_frame() -> PlayerCommandFrame:
	if _current_command_frame == null:
		push_error("PlayerController command frame requested before a valid physics-step commit.")
	return _current_command_frame


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


func submit_state_policy(locomotion_state_id: StringName) -> bool:
	var status := player_motor.select_state_policy(locomotion_state_id, locomotion_state_id)
	if status == PlayerMotor.SubmissionStatus.SUCCESS:
		_submitted_locomotion_state_id = locomotion_state_id
	return _submit_motor_status(status, locomotion_state_id)


func submit_terminal_policy() -> bool:
	return _submit_motor_status(
		player_motor.select_terminal_policy(SOURCE_TERMINAL_DEAD),
		SOURCE_TERMINAL_DEAD
	)


func submit_base_policy(
	locomotion_state_id: StringName,
	input_dir: Vector2
) -> bool:
	var grounded := is_on_floor()
	var max_speed := max_ground_speed if grounded else max_air_speed
	var target_velocity := _get_horizontal_target_velocity(input_dir, max_speed)
	var acceleration := _get_horizontal_acceleration(input_dir, grounded)
	var source_id := _base_source_for_state(locomotion_state_id)
	return _submit_motor_status(
		player_motor.submit_base_motion(source_id, target_velocity, acceleration),
		source_id
	)


func submit_base_passthrough(locomotion_state_id: StringName) -> bool:
	var source_id := _base_source_for_state(locomotion_state_id)
	return _submit_motor_status(
		player_motor.submit_base_motion(
			source_id,
			get_motion_start_velocity(),
			0.0,
			false
		),
		source_id
	)


func submit_gravity_policy() -> bool:
	if is_on_floor():
		return true
	if is_wall_running and wall_run_zero_vertical_velocity:
		return true
	var source_id := SOURCE_GRAVITY_DEFAULT
	if is_wall_running:
		source_id = SOURCE_GRAVITY_WALL_RUN
	elif is_grappling:
		source_id = SOURCE_GRAVITY_GRAPPLE
	return _submit_motor_status(
		player_motor.submit_gravity(
			source_id,
			Vector3.DOWN * gravity * _get_gravity_scale()
		),
		source_id
	)


func submit_ground_jump(reference_velocity: Vector3) -> bool:
	var impulse := Vector3(0.0, jump_velocity - reference_velocity.y, 0.0)
	return _submit_motor_status(
		player_motor.submit_one_shot_impulse(
			SOURCE_JUMP_GROUND,
			COMMAND_JUMP_PRESSED,
			impulse
		),
		SOURCE_JUMP_GROUND
	)


func submit_grapple_pull(delta: float) -> bool:
	if not is_instance_valid(grapple_target):
		_clear_grapple()
		return false
	var current_acceleration := _get_grapple_acceleration()
	grapple_applied_acceleration = current_acceleration
	grapple_elapsed += delta
	var pull_direction := _get_player_mesh_center().direction_to(grapple_point)
	if pull_direction == Vector3.ZERO:
		return true
	return _submit_motor_status(
		player_motor.submit_sustained_acceleration(
			SOURCE_GRAPPLE_PULL,
			pull_direction * current_acceleration
		),
		SOURCE_GRAPPLE_PULL
	)


func submit_grapple_speed_cap() -> bool:
	return _submit_motor_status(
		player_motor.submit_total_speed_cap(
			SOURCE_GRAPPLE_SPEED_CAP,
			grapple_max_velocity
		),
		SOURCE_GRAPPLE_SPEED_CAP
	)


func submit_wall_run_base() -> bool:
	return _submit_motor_status(
		player_motor.submit_base_motion(
			SOURCE_BASE_WALL_RUN,
			wall_run_direction * wall_run_speed,
			wall_run_acceleration,
			true,
			wall_run_zero_vertical_velocity
		),
		SOURCE_BASE_WALL_RUN
	)


func submit_wall_run_constraint() -> bool:
	return _submit_motor_status(
		player_motor.submit_wall_run_constraint(
			SOURCE_WALL_RUN_CONSTRAINT,
			wall_normal,
			wall_run_direction
		),
		SOURCE_WALL_RUN_CONSTRAINT
	)


func submit_wall_jump(reference_velocity: Vector3) -> bool:
	var along_wall_velocity: Vector3 = wall_run_direction * max(
		Vector3(reference_velocity.x, 0.0, reference_velocity.z).dot(wall_run_direction),
		0.0
	)
	var desired_velocity := wall_normal * wall_jump_away_velocity + along_wall_velocity
	desired_velocity.y = wall_jump_up_velocity
	_clear_wall_run()
	return _submit_motor_status(
		player_motor.submit_one_shot_impulse(
			SOURCE_JUMP_WALL,
			COMMAND_JUMP_PRESSED,
			desired_velocity - reference_velocity
		),
		SOURCE_JUMP_WALL
	)


func submit_wall_stick_hold() -> bool:
	return _submit_motor_status(
		player_motor.submit_wall_stick_hold(
			SOURCE_WALL_STICK_HOLD,
			wall_stick_position
		),
		SOURCE_WALL_STICK_HOLD
	)


func submit_wall_stick_release(reference_velocity: Vector3) -> bool:
	return _submit_motor_status(
		player_motor.submit_base_motion(
			SOURCE_BASE_WALL_STICK,
			reference_velocity,
			0.0,
			false
		),
		SOURCE_BASE_WALL_STICK
	)


func submit_wall_stick_jump(reference_velocity: Vector3) -> bool:
	var along_wall_velocity := wall_stick_run_direction * wall_run_speed
	var desired_velocity := wall_stick_normal * wall_jump_away_velocity + along_wall_velocity
	desired_velocity.y = wall_jump_up_velocity
	_clear_wall_stick()
	_clear_grapple()
	return _submit_motor_status(
		player_motor.submit_one_shot_impulse(
			SOURCE_JUMP_WALL,
			COMMAND_JUMP_PRESSED,
			desired_velocity - reference_velocity
		),
		SOURCE_JUMP_WALL
	)


func submit_dead_motion() -> bool:
	var source_id := SOURCE_BASE_DEAD
	var success := _submit_motor_status(
		player_motor.submit_base_motion(
			source_id,
			Vector3.ZERO,
			ground_deceleration
		),
		source_id
	)
	if not success:
		return false
	return submit_gravity_policy()


func _submit_motor_status(
	status: PlayerMotor.SubmissionStatus,
	source_id: StringName
) -> bool:
	if status == PlayerMotor.SubmissionStatus.SUCCESS:
		return true
	_player_log.record_invariant(
		&"player.controller.motor_submission_rejected",
		DiagnosticContext.new(
			_player_physics_step,
			_submitted_locomotion_state_id,
			StringName(PlayerMotor.SubmissionStatus.keys()[int(status)].to_lower()),
			0,
			source_id
		)
	)
	if PlayerMotor.is_isolated_submission_status(status):
		return true
	_motion_submission_failed = true
	_motion_submission_failure_status = status
	return false


func _base_source_for_state(locomotion_state_id: StringName) -> StringName:
	match locomotion_state_id:
		LOCOMOTION_GROUNDED:
			return SOURCE_BASE_GROUNDED
		LOCOMOTION_AIRBORNE:
			return SOURCE_BASE_AIRBORNE
		LOCOMOTION_GRAPPLING:
			return SOURCE_BASE_GRAPPLING
		LOCOMOTION_WALL_RUN:
			return SOURCE_BASE_WALL_RUN
		LOCOMOTION_WALL_STICK:
			return SOURCE_BASE_WALL_STICK
		LOCOMOTION_DEAD:
			return SOURCE_BASE_DEAD
		_:
			return StringName("player.locomotion.%s.base" % String(locomotion_state_id))


func is_player_physics_active() -> bool:
	return _player_initialized


func get_motion_start_velocity() -> Vector3:
	if player_motor == null or not is_instance_valid(player_motor):
		return Vector3.ZERO
	return player_motor.get_frame_initial_velocity()


func get_motion_step() -> int:
	return _player_physics_step


func dispatch_locomotion_event(event: StringName) -> void:
	_pending_locomotion_event = event
	if movement_hsm:
		movement_hsm.dispatch(event)


func _get_horizontal_target_velocity(input_dir: Vector2, max_speed: float) -> Vector3:
	var direction := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	return direction * max_speed


func _get_horizontal_acceleration(input_dir: Vector2, grounded: bool = false) -> float:
	if input_dir == Vector2.ZERO:
		return ground_deceleration if grounded else air_deceleration

	return ground_acceleration if grounded else air_acceleration


func _get_gravity_scale() -> float:
	if is_wall_running:
		return wall_run_gravity_scale

	if is_grappling:
		return grapple_gravity_scale

	return 1.0


func _update_wall_run_state(input_dir: Vector2, reference_velocity: Vector3) -> void:
	if is_on_floor() or is_grappling:
		_clear_wall_run()
		return

	var wall_hit := _find_wall_with_velocity_rays(reference_velocity)
	if wall_hit.is_empty():
		_clear_wall_run()
		return

	if not is_wall_running and not _can_start_wall_run(reference_velocity):
		return

	var normal: Vector3 = wall_hit["normal"]
	_set_wall_run(normal, reference_velocity)
	if not _has_wall_run_input_for_direction(input_dir, wall_run_direction):
		_clear_wall_run()


func _find_wall_with_velocity_rays(reference_velocity: Vector3) -> Dictionary:
	var horizontal_velocity := Vector3(reference_velocity.x, 0.0, reference_velocity.z)
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


func _clear_wall_run() -> void:
	is_wall_running = false
	wall_normal = Vector3.ZERO
	wall_run_direction = Vector3.ZERO


func _try_start_wall_stick_from_collisions(
	input_dir: Vector2,
	entry_velocity: Vector3,
	collisions: Array[KinematicCollision3D],
	committed_position: Vector3
) -> bool:
	if (
		is_wall_sticking
		or not is_grappling
		or _current_command_frame == null
		or not _current_command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE)
		or is_on_floor()
		or not _can_start_wall_run(entry_velocity)
	):
		return false

	for collision in collisions:
		var collider := collision.get_collider()
		if not collider is StaticBody3D:
			continue

		var normal := collision.get_normal()
		if not _is_valid_wall_normal(normal):
			continue

		var run_direction := _get_wall_run_direction(normal, entry_velocity)
		if not _has_wall_run_input_for_direction(input_dir, run_direction):
			continue

		return _set_wall_stick(normal, run_direction, committed_position)

	return false


func _set_wall_stick(
	normal: Vector3,
	run_direction: Vector3,
	committed_position: Vector3
) -> bool:
	if player_motor == null or not is_instance_valid(player_motor):
		_player_log.record_invariant(
			&"player.controller.wall_stick_baseline_failed",
			DiagnosticContext.new(
				_player_physics_step,
				LOCOMOTION_WALL_STICK,
				&"motor_unavailable"
			)
		)
		_deactivate_player()
		return false

	var baseline_status := player_motor.set_next_frame_velocity_baseline(Vector3.ZERO)
	if baseline_status != PlayerMotor.BaselineStatus.SUCCESS:
		_player_log.record_invariant(
			&"player.controller.wall_stick_baseline_failed",
			DiagnosticContext.new(
				_player_physics_step,
				LOCOMOTION_WALL_STICK,
				StringName(PlayerMotor.BaselineStatus.keys()[int(baseline_status)].to_lower())
			)
		)
		_deactivate_player()
		return false

	is_wall_sticking = true
	wall_stick_position = committed_position
	wall_stick_normal = normal.normalized()
	wall_stick_run_direction = run_direction
	_clear_wall_run()
	return true


func _clear_wall_stick() -> void:
	is_wall_sticking = false
	wall_stick_position = Vector3.ZERO
	wall_stick_normal = Vector3.ZERO
	wall_stick_run_direction = Vector3.ZERO


func get_movement_input() -> Vector2:
	var frame := get_player_command_frame()
	if frame == null:
		return Vector2.ZERO
	return frame.movement_axis


func update_grapple_feedback() -> void:
	_update_grapple_visual()
	_update_grapple_cursor()


func dispatch_locomotion_after_grapple_clear() -> void:
	if is_on_floor():
		dispatch_locomotion_event(EVENT_LANDED)
	else:
		dispatch_locomotion_event(EVENT_GRAPPLE_RELEASED)


func try_start_grapple() -> bool:
	var hit := _get_grapple_ray_hit()
	if hit.is_empty():
		return false

	var collider: Object = hit["collider"]
	if collider is StaticBody3D:
		is_grappling = true
		grapple_elapsed = 0.0
		grapple_applied_acceleration = grapple_initial_acceleration
		grapple_point = hit["position"]
		grapple_target = collider as StaticBody3D
		return true

	return false


func has_valid_grapple() -> bool:
	return is_grappling and is_instance_valid(grapple_target)


func get_grapple_telemetry() -> Dictionary:
	var committed_velocity := player_motor.get_committed_velocity() if player_motor else Vector3.ZERO
	var target_distance := 0.0
	var pull_direction := Vector3.ZERO
	var pull_speed := 0.0
	if is_grappling and is_instance_valid(player_mesh):
		var player_center := _get_player_mesh_center()
		target_distance = player_center.distance_to(grapple_point)
		pull_direction = player_center.direction_to(grapple_point)
		if pull_direction != Vector3.ZERO:
			pull_speed = committed_velocity.dot(pull_direction)

	var speed_gate_passed := _can_start_wall_run(committed_velocity)
	var speed_gate_reason := "pass"
	if Vector3(committed_velocity.x, 0.0, committed_velocity.z).length() < wall_run_min_horizontal_speed:
		speed_gate_reason = "horizontal speed below %.1f" % wall_run_min_horizontal_speed
	elif committed_velocity.length() > wall_run_max_entry_speed:
		speed_gate_reason = "total speed above %.1f" % wall_run_max_entry_speed

	return {
		"active": is_grappling,
		"target_valid": is_instance_valid(grapple_target),
		"elapsed": grapple_elapsed,
		"acceleration": grapple_applied_acceleration if is_grappling else 0.0,
		"initial_acceleration": grapple_initial_acceleration,
		"min_acceleration": grapple_min_acceleration,
		"jerk": grapple_acceleration_jerk,
		"max_velocity": grapple_max_velocity,
		"target_distance": target_distance,
		"pull_speed": pull_speed,
		"speed": committed_velocity.length(),
		"velocity": committed_velocity,
		"cap_reached": grapple_max_velocity > 0.0 and committed_velocity.length() >= grapple_max_velocity - 0.01,
		"on_floor": is_on_floor(),
		"wall_running": is_wall_running,
		"wall_sticking": is_wall_sticking,
		"wall_stick_speed_gate": speed_gate_passed,
		"wall_stick_speed_gate_reason": speed_gate_reason,
	}


func _get_grapple_ray_hit() -> Dictionary:
	var frame := get_player_command_frame()
	if frame == null:
		return {}
	var origin := camera.global_position
	var direction := frame.aim_world_direction
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


func _get_grapple_acceleration() -> float:
	return max(
		grapple_min_acceleration,
		grapple_initial_acceleration - max(grapple_acceleration_jerk, 0.0) * grapple_elapsed
	)


func _clear_grapple() -> void:
	is_grappling = false
	grapple_elapsed = 0.0
	grapple_applied_acceleration = 0.0
	grapple_point = Vector3.ZERO
	grapple_target = null
	_clear_wall_stick()
	if grapple_visual:
		grapple_visual.visible = false


func _cancel_attack() -> void:
	if attack_hitbox:
		attack_hitbox.cancel()


func _set_dead() -> void:
	if is_dead:
		return

	is_dead = true
	if input_source:
		input_source.set_enabled(false)
	_cancel_attack()
	_clear_grapple()
	_clear_wall_run()
	_clear_wall_stick()
	if grapple_cursor:
		grapple_cursor.visible = false
	if movement_hsm:
		dispatch_locomotion_event(EVENT_DIED)
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
