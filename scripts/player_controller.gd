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
## Highest total speed that can still enter a wall run.
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

@export_group("Wall Sticking")
@export var wall_stick_definition: WallStickDefinition

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
## Gravity multiplier applied while grappling (context tuning, not definition
## tuning: `main.tscn` overrides it to 0.0 and the tutorial to 0.65).
@export var grapple_gravity_scale := 1.0
## Zero-input horizontal slowing while grappling. These are independent of
## ordinary ground/air deceleration; zero preserves an angled pull from rest.
@export var grapple_ground_deceleration := 0.0
@export var grapple_air_deceleration := 0.0
## Player-local Node3D used for pull and rope start. Unassigned or freed nodes
## fall back to the body root without affecting camera-ray targeting.
@export var grapple_origin: Node3D:
	set(value):
		grapple_origin = value
		if _grapple_controller != null:
			_grapple_controller.set_pull_origin(value)

@export_group("Grapple Visuals")
## Radius of the grapple rope cylinder.
@export var grapple_visual_radius := 0.035
## Color used for the grapple rope.
@export var grapple_visual_color := Color(0.1, 0.85, 1.0)

@export_group("Grapple Targeting")
## Immutable authored grapple definition - the single authoritative pull, speed
## cap, and acquisition/active-range source.
@export var grapple_definition: GrappleDefinition
## Immutable occlusion profile marking blocking-but-unacquirable surfaces.
@export var grapple_occlusion_profile: PhysicsQueryProfile

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
@onready var grapple_marker: GrappleTargetMarker = get_node_or_null(^"GrappleTargetMarker") as GrappleTargetMarker

const EVENT_LEFT_GROUND := &"left_ground"
const EVENT_LANDED := &"landed"
const EVENT_JUMPED := &"jumped"
const EVENT_GRAPPLE_STARTED := &"grapple_started"
const EVENT_GRAPPLE_RELEASED := &"grapple_released"
const EVENT_WALL_RUN_STARTED := &"wall_run_started"
const EVENT_WALL_RUN_FINISHED := &"wall_run_finished"
const EVENT_WALL_STICK_STARTED := &"wall_stick_started"
const EVENT_WALL_STICK_JUMPED := &"wall_stick_jumped"
const EVENT_WALL_STICK_RELEASED := &"wall_stick_released"
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
const SOURCE_JUMP_GROUND := &"player.jump.ground"
const SOURCE_JUMP_WALL := &"player.jump.wall"
const SOURCE_WALL_RUN_CONSTRAINT := &"player.wall_run.constraint"
const SOURCE_WALL_STICK_HOLD := &"player.wall_stick.hold"
## Standard Godot Vector3 components use single-precision real_t.
const WALL_PROJECTION_COMPONENT_EPSILON := 1.1920928955078125e-7

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_pitch := 0.0
var grapple_visual: MeshInstance3D
var grapple_visual_mesh: CylinderMesh
## Reveal/revision rope resets, counted at the single reset call site.
var grapple_visual_reset_count: int = 0
var _grapple_visual_attachment_identity: StringName = &""
var _grapple_visual_revision := -1

## Read-through views of the player-owned `GrappleAttachment` (Story 1.7 Task
## 2.2): the attachment is the single grapple runtime authority and these are
## never an independent state copy. Every view is gated on a LIVE attachment -
## a committed terminal zeroes it, matching the pre-Story-1.7 contract that the
## cleared grapple reads back as absent rather than as its last occurrence.
var is_grappling: bool:
	get:
		return _grapple_controller != null and _grapple_controller.has_active_attachment()

var grapple_elapsed: float:
	get:
		var attachment := get_grapple_attachment()
		return attachment.elapsed_seconds if _is_live_attachment(attachment) else 0.0

var grapple_applied_acceleration: float:
	get:
		var attachment := get_grapple_attachment()
		return (
			attachment.applied_acceleration_mps2
			if _is_live_attachment(attachment)
			else 0.0
		)

var grapple_point: Vector3:
	get:
		var attachment := get_grapple_attachment()
		return (
			attachment.anchor_world_position
			if _is_live_attachment(attachment)
			else Vector3.ZERO
		)

var grapple_target: Node3D:
	get:
		var attachment := get_grapple_attachment()
		if not _is_live_attachment(attachment):
			return null
		return attachment.get_target() as Node3D
var is_wall_running := false
var wall_normal := Vector3.ZERO
var wall_run_direction := Vector3.ZERO
var wall_surface_identity: StringName = &""
var wall_identity_persistent := false
var is_wall_sticking := false
var wall_stick_position := Vector3.ZERO
var wall_stick_normal := Vector3.ZERO
var wall_stick_run_direction := Vector3.ZERO
var wall_stick_surface_identity: StringName = &""
var wall_stick_identity_persistent := false
var _wall_stick_attachment: WallStickAttachment
var _wall_stick_committed_velocity := Vector3.ZERO
var _wall_stick_has_committed_hold := false
var _last_wall_stick_reanchor_status := GrappleController.ReanchorStatus.SUCCESS
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
var _grapple_target_resolver: GrappleTargetResolver
var _grapple_controller: GrappleController
var _grapple_targeting_available := false
var _current_targeting_result: GrappleTargetingResult
var _last_activation_rejection: GrappleRejection.Reason = GrappleRejection.Reason.NONE
## Injectable encounter-scope identity source (Story 1.8 Tasks 1.2/5, AC 1/6/10).
## Encounter systems (or tests) provide a `Callable` returning the current
## stable scope identity (lowercase dotted `StringName`). Empty means the
## attachment is unscoped and never scope-checks. Only this identity contract
## exists here - no encounter lifecycle, registry, or reset machinery.
var grapple_encounter_scope_provider: Callable


func _ready() -> void:
	add_to_group("player")
	_setup_grapple_visual()
	_compose_grapple_targeting()
	_compose_grapple_controller()
	if wall_stick_definition == null or wall_stick_definition.validate() != WallStickDefinition.ValidationStatus.SUCCESS:
		push_error("PlayerController requires a valid WallStickDefinition.")
		_deactivate_player()
		return

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
	var contact_bootstrap := player_motor.bootstrap_contact_frame()
	if contact_bootstrap == null or not contact_bootstrap.success:
		_player_log.record_invariant(
			&"player.controller.contact_bootstrap_failed",
			DiagnosticContext.new(-1, &"", &"contact_bootstrap_failed")
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
	movement_hsm.add_transition(wall_stick_state, grappling_state, EVENT_WALL_STICK_RELEASED)
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
	_evaluate_grapple_targeting(frame)
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
	if _grapple_controller != null:
		_grapple_controller.record_committed_facts(motor_result)
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
	if movement_hsm and movement_hsm.is_active():
		movement_hsm.set_active(false)
	if attack_hsm and attack_hsm.is_active():
		attack_hsm.set_active(false)
	_current_targeting_result = null
	if grapple_marker:
		grapple_marker.clear_targeting()


func _abort_motion_frame_safely() -> void:
	if (
		player_motor != null
		and is_instance_valid(player_motor)
		and player_motor.has_active_motion_frame()
	):
		player_motor.abort_motion_frame()


func _coordinate_post_commit(result: PlayerMotorCommitResult) -> void:
	var contact_frame := result.contact_frame
	if (
		contact_frame == null
		or contact_frame.physics_step != result.physics_step
	):
		_player_log.record_invariant(
			&"player.controller.contact_frame_mismatch",
			DiagnosticContext.new(_player_physics_step, &"", &"contact_frame_mismatch")
		)
		_deactivate_player()
		return

	if result.is_hold_request and is_wall_sticking:
		_wall_stick_committed_velocity = result.committed_velocity
		_wall_stick_has_committed_hold = true
		if result.hold_carry_blocked:
			terminate_grapple(GrappleEndReason.Reason.STATE_CANCELLATION)
			dispatch_locomotion_event(EVENT_GRAPPLE_RELEASED)
			return

	if _submitted_locomotion_state_id == LOCOMOTION_GRAPPLING and is_grappling and not contact_frame.is_grounded:
		var started_wall_stick := _try_start_wall_stick_from_contact(
			_current_command_frame.movement_axis,
			result.submitted_velocity,
			contact_frame,
			result.position_after
		)
		if started_wall_stick:
			dispatch_locomotion_event(EVENT_WALL_STICK_STARTED)

	if _submitted_locomotion_state_id == LOCOMOTION_GRAPPLING and contact_frame.is_grounded:
		if is_grappling:
			terminate_grapple(GrappleEndReason.Reason.GROUND_CONTACT)
		if _pending_locomotion_event != &"":
			return
		dispatch_locomotion_event(EVENT_LANDED)
		return

	if _pending_locomotion_event != &"":
		return
	if _submitted_locomotion_state_id == LOCOMOTION_GROUNDED and not contact_frame.is_grounded:
		dispatch_locomotion_event(EVENT_LEFT_GROUND)
	elif (
		_submitted_locomotion_state_id == LOCOMOTION_AIRBORNE
		or _submitted_locomotion_state_id == LOCOMOTION_WALL_RUN
	) and contact_frame.is_grounded:
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


func _compose_grapple_targeting() -> void:
	var resolver := GrappleTargetResolver.new()
	var initialization := resolver.initialize(self, grapple_definition, grapple_occlusion_profile)
	if initialization != GrappleTargetResolver.InitializationStatus.SUCCESS:
		_player_log.record_invariant(
			&"player.grapple.targeting_initialization_failed",
			DiagnosticContext.new(
				-1,
				&"",
				GrappleTargetResolver.initialization_status_id(initialization)
			)
		)
		if grapple_marker:
			grapple_marker.clear_targeting()
		return
	_grapple_target_resolver = resolver
	_grapple_targeting_available = true


## Compose the player-owned grapple controller (Story 1.7 Task 2.2). The
## `GrappleDefinition` is the sole pull/cap/range source (Task 1); the Story 1.6
## composition-time parity machinery is retired with the duplication it guarded.
func _compose_grapple_controller() -> void:
	var controller := GrappleController.new()
	var initialization := controller.initialize(self, grapple_definition)
	if initialization != GrappleController.InitializationStatus.SUCCESS:
		_player_log.record_invariant(
			&"player.grapple.controller_initialization_failed",
			DiagnosticContext.new(
				-1,
				&"",
				StringName(
					GrappleController.InitializationStatus.keys()[int(initialization)].to_lower()
				)
			)
		)
		return
	_grapple_controller = controller
	controller.set_pull_origin(grapple_origin)
	# The optional originating encounter-scope identity is resolved from the
	# injectable provider at commit time (Story 1.8 Task 1.2).
	controller.set_scope_identity_provider(
		Callable(self, "get_grapple_encounter_scope_identity")
	)
	# Exactly-once cleanup is enforced at the emitter (NFR15): every terminal
	# path - not only `terminate_grapple()` - drops the rope and the wall-stick
	# coupling through this one connection, and `attachment_ended` fires only on
	# the first committed terminal.
	controller.attachment_ended.connect(_on_grapple_attachment_ended)


## Resolved at commit time through the injectable provider (Story 1.8 Task 1.2).
func get_grapple_encounter_scope_identity() -> StringName:
	if not grapple_encounter_scope_provider.is_valid():
		return &""
	var supplied: Variant = grapple_encounter_scope_provider.call()
	if supplied == null:
		return &""
	return StringName(supplied)


func _evaluate_grapple_targeting(frame: PlayerCommandFrame) -> void:
	if not _grapple_targeting_available or _grapple_target_resolver == null:
		_current_targeting_result = null
		return
	if is_grappling:
		# Story 1.8 Task 3.3 (AC 3): while attached, the anchor follows the
		# stored target-local hit point through transform math only - the
		# target-selection raycast is NOT repeated for the attachment. The 1.6
		# discipline stands: every EVALUATED step still performs exactly one
		# authoritative query, and an attached step is not an evaluated step.
		return
	_current_targeting_result = _grapple_target_resolver.evaluate(
		_player_physics_step,
		frame,
		camera.global_position
	)


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
	var grounded := has_ground_contact()
	var max_speed := max_ground_speed if grounded else max_air_speed
	var target_velocity := _get_horizontal_target_velocity(input_dir, max_speed)
	var acceleration := _get_horizontal_acceleration(input_dir, grounded, locomotion_state_id)
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
	if has_ground_contact():
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


## Grapple-sampling phase (Story 1.8 Task 3.1): sample exactly one
## `GrappleAnchorState` for this physics step before any grapple submission.
## Returns false when the sample was invalid and the attachment terminated with
## its typed reason - the caller then submits nothing grapple-related for the
## step (AC 6).
func sample_grapple_anchor(delta: float) -> bool:
	if _grapple_controller == null:
		return false
	return _grapple_controller.sample_anchor_state(_player_physics_step, delta)


## Per-step grapple motor influences (Story 1.7 Task 4.6), delegated to the
## player-owned `GrappleController`: the sustained zip-pull toward the sampled
## anchor plus the maximum-anchor-distance boundary constraint. Both consume
## this step's stored `GrappleAnchorState` (Story 1.8 Task 3.2). The pull
## direction uses the scene-assigned pull origin (or body-root fallback); the
## maximum-distance constraint still resolves from the body root. A dead anchor
## terminates the attachment with a typed reason and submits nothing this step.
func submit_grapple_pull(delta: float) -> bool:
	if not has_valid_grapple():
		terminate_grapple(GrappleEndReason.Reason.TARGET_INVALIDATED)
		return false
	if _grapple_controller == null:
		return false
	return _submit_motor_status(
		_grapple_controller.submit_motor_influences(
			player_motor,
			delta,
			_player_physics_step
		),
		GrappleController.SOURCE_PULL
	)


## Per-step total-speed cap from the occurrence-local resolved value (Task 4.6).
func submit_grapple_speed_cap() -> bool:
	if not has_valid_grapple() or _grapple_controller == null:
		return false
	return _submit_motor_status(
		_grapple_controller.submit_speed_cap(player_motor, _player_physics_step),
		GrappleController.SOURCE_SPEED_CAP
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
	var attachment := get_grapple_attachment()
	var anchor_state := attachment.get_sampled_anchor_state() if _is_live_attachment(attachment) else null
	if anchor_state == null:
		return false
	return _submit_motor_status(
		_wall_stick_attachment.submit_hold(
			player_motor,
			SOURCE_WALL_STICK_HOLD,
			anchor_state,
			attachment.resolved_maximum_length_m
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
	var outward := Vector3(wall_stick_normal.x, 0.0, wall_stick_normal.z).normalized()
	var desired_velocity := outward * wall_stick_definition.jump_away_speed_mps
	desired_velocity.y = wall_stick_definition.jump_up_speed_mps
	terminate_grapple(GrappleEndReason.Reason.STATE_CANCELLATION)
	_clear_wall_stick()
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


func get_previous_contact_frame() -> ContactFrame:
	if player_motor == null or not is_instance_valid(player_motor):
		return null
	return player_motor.get_previous_contact_frame()


func has_ground_contact() -> bool:
	var frame := get_previous_contact_frame()
	return frame != null and frame.is_grounded


func get_wall_contact() -> ContactFrame:
	return get_previous_contact_frame()


func dispatch_locomotion_event(event: StringName) -> void:
	_pending_locomotion_event = event
	if movement_hsm:
		movement_hsm.dispatch(event)


func _get_horizontal_target_velocity(input_dir: Vector2, max_speed: float) -> Vector3:
	var direction := (global_transform.basis * Vector3(input_dir.x, 0.0, input_dir.y)).normalized()
	return direction * max_speed


func _get_horizontal_acceleration(
	input_dir: Vector2,
	grounded: bool,
	locomotion_state_id: StringName
) -> float:
	if input_dir == Vector2.ZERO:
		if locomotion_state_id == LOCOMOTION_GRAPPLING:
			return grapple_ground_deceleration if grounded else grapple_air_deceleration
		return ground_deceleration if grounded else air_deceleration

	return ground_acceleration if grounded else air_acceleration


func _get_gravity_scale() -> float:
	if is_wall_running:
		return wall_run_gravity_scale

	if is_grappling:
		return grapple_gravity_scale

	return 1.0


## Wall-run entry and maintenance consume the shared `ContactFrame` wall facts
## only (Story 1.9 Task 1.1). No collision query, no raw body wall flag or wall
## normal read, no slide-collision enumeration, and no hardware-input read ever
## happens in wall policy: the contact provider answers "which wall", the
## traversal layer answers "may we run it" (Story 1.5 AC 6 boundary).
func _update_wall_run_state(input_dir: Vector2, reference_velocity: Vector3) -> void:
	var contact_frame := get_previous_contact_frame()
	if (
		has_ground_contact()
		or is_grappling
		or not _is_runnable_wall_frame(contact_frame, _player_physics_step - 1)
	):
		_clear_wall_run()
		return

	if _has_outward_wall_speed(reference_velocity, contact_frame.wall_normal):
		_clear_wall_run()
		return

	if not is_wall_running and not _can_start_wall_run(reference_velocity):
		return

	if not _update_wall_run_relationship(contact_frame, reference_velocity):
		return

	if not _has_wall_run_input_for_direction(input_dir, wall_run_direction):
		_clear_wall_run()


## Fail-closed wall-fact gate (Story 1.9 Task 4.2). A carried previous-step
## frame, an exhausted continuity loss window, `wall_contact_lost`, an
## unavailable wall profile, or a failed wall probe must end wall running and
## wall sticking rather than holding them: stale wall facts fail toward exit,
## never toward staying. `expected_step` is the physics step the caller needs
## the frame to belong to (the pre-commit step reads `ContactFrame(N-1)`, the
## post-commit wall-stick entry reads the just-committed `ContactFrame(N)`).
func _is_runnable_wall_frame(contact_frame: ContactFrame, expected_step: int) -> bool:
	if contact_frame == null:
		return false
	if contact_frame.physics_step != expected_step:
		return false
	if not contact_frame.wall_probe_query_succeeded:
		return false
	if contact_frame.wall_contact_lost:
		return false
	if not contact_frame.has_wall_contact:
		return false
	return (
		contact_frame.continuity_action == ContactFrame.ContinuityAction.INITIAL
		or contact_frame.continuity_action == ContactFrame.ContinuityAction.PRESERVED
		or contact_frame.continuity_action == ContactFrame.ContinuityAction.SWITCHED
	)


## Wall-relationship maintenance (Story 1.9 Tasks 1.3 / 3.1 / 3.2) given the
## authoritative `ContactFrame` wall facts only. The relationship - identity,
## normal, and the deterministic run direction - is established exactly once on
## entry and re-established deliberately and only on `SWITCHED`. `PRESERVED`
## keeps it untouched, so normal noise inside the authored `WallProbe`
## continuity tolerance (25 degrees / 0.2 m / 2-step loss window) can never
## re-derive or reverse the run direction (AC 3). Returns true while a
## relationship is held afterwards.
func _update_wall_run_relationship(
	contact_frame: ContactFrame,
	reference_velocity: Vector3
) -> bool:
	var action := contact_frame.continuity_action
	var is_preserved := action == ContactFrame.ContinuityAction.PRESERVED
	var is_establishing := (
		action == ContactFrame.ContinuityAction.INITIAL
		or action == ContactFrame.ContinuityAction.SWITCHED
	)
	# `PRESERVED` establishes on entry (the provider was already tracking this
	# wall) and then holds the established relationship for the whole run.
	if is_establishing or (is_preserved and not is_wall_running):
		_set_wall_run(contact_frame, reference_velocity)
		return true
	if is_preserved:
		return true
	_clear_wall_run()
	return false


func _can_start_wall_run(check_velocity: Vector3) -> bool:
	var horizontal_speed := Vector3(check_velocity.x, 0.0, check_velocity.z).length()
	return (
		horizontal_speed >= wall_run_min_horizontal_speed
		and check_velocity.length() <= wall_run_max_entry_speed
	)


## A shared traversal gate: only horizontal motion and the horizontal component
## of the authoritative wall normal decide whether the player is separating.
## A zero horizontal normal projects to zero and therefore cannot spuriously
## reject traversal.
func _has_outward_wall_speed(reference_velocity: Vector3, outward_wall_normal: Vector3) -> bool:
	var horizontal_velocity := Vector3(reference_velocity.x, 0.0, reference_velocity.z)
	var horizontal_normal := Vector3(
		outward_wall_normal.x,
		0.0,
		outward_wall_normal.z
	).normalized()
	var outward_speed := (
		horizontal_velocity.x * horizontal_normal.x
		+ horizontal_velocity.z * horizontal_normal.z
	)
	var cancellation_scale := (
		absf(horizontal_velocity.x * horizontal_normal.x)
		+ absf(horizontal_velocity.z * horizontal_normal.z)
	)
	# A fast tangent can leave a few positive ULPs after the Vector3 components
	# are rounded. Ignore only that cancellation-relative representation error;
	# unlike a fixed m/s dead zone, this still detects small direct outward motion.
	var projection_roundoff := 4.0 * WALL_PROJECTION_COMPONENT_EPSILON * cancellation_scale
	return outward_speed > projection_roundoff


## Establish the wall relationship once per relationship (Story 1.9 Task 1.3):
## capture the shared wall identity and derive the deterministic run direction
## here, never every step.
func _set_wall_run(contact_frame: ContactFrame, reference_velocity: Vector3) -> void:
	wall_normal = contact_frame.wall_normal.normalized()
	wall_run_direction = _get_wall_run_direction(wall_normal, reference_velocity)
	wall_surface_identity = contact_frame.wall_surface_identity
	wall_identity_persistent = contact_frame.wall_identity_persistent

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
	wall_surface_identity = &""
	wall_identity_persistent = false


## Inclusive incoming total-speed gate in the supporting wall's frame.
func _can_start_wall_stick(check_velocity: Vector3, wall_velocity: Vector3 = Vector3.ZERO) -> bool:
	return wall_stick_definition != null and wall_stick_definition.is_locked() and check_velocity.is_finite() and wall_velocity.is_finite() and (check_velocity - wall_velocity).length() <= wall_stick_definition.maximum_entry_speed_mps


## Grapple-assisted wall-stick entry (Story 1.9 AC 6), post-commit only. The
## authoritative wall relationship comes from the just-committed
## `ContactFrame`; there is deliberately no airborne-to-wall-stick path.
func _try_start_wall_stick_from_contact(
	_input_dir: Vector2,
	entry_velocity: Vector3,
	contact_frame: ContactFrame,
	committed_position: Vector3
) -> bool:
	if (
		wall_stick_definition == null
		or not wall_stick_definition.is_locked()
		or is_wall_sticking
		or not is_grappling
		or _current_command_frame == null
		or not _current_command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE)
		or not _current_command_frame.move_forward_held
		or contact_frame == null
		or contact_frame.is_grounded
		or not _is_runnable_wall_frame(contact_frame, _player_physics_step)
		or contact_frame.wall_support == null
		or absf(contact_frame.wall_support.normal.y) > wall_stick_definition.maximum_abs_normal_y
		or _has_outward_wall_speed(entry_velocity - contact_frame.wall_point_velocity, contact_frame.wall_support.normal)
		or not _can_start_wall_stick(entry_velocity, contact_frame.wall_point_velocity)
	):
		return false

	var provider := player_motor.get_contact_provider()
	var attachment := provider.bind_wall_stick_attachment(contact_frame, committed_position, wall_stick_definition)
	if attachment == null:
		return false

	var binding := attachment.create_grapple_surface_binding(contact_frame)
	var prepared := _grapple_controller.prepare_surface_reanchor(binding, _player_physics_step)
	_last_wall_stick_reanchor_status = prepared.status
	if prepared.status != GrappleController.ReanchorStatus.SUCCESS:
		attachment.release()
		if binding != null:
			binding.release()
		return false
	return _set_wall_stick(contact_frame, attachment, committed_position, prepared)


func _set_wall_stick(
	contact_frame: ContactFrame,
	attachment: WallStickAttachment,
	committed_position: Vector3,
	prepared: GrappleController.ReanchorPreparation
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

	_last_wall_stick_reanchor_status = _grapple_controller.commit_surface_reanchor(prepared, player_motor)
	if _last_wall_stick_reanchor_status != GrappleController.ReanchorStatus.SUCCESS:
		attachment.release()
		prepared.binding.release()
		return false

	is_wall_sticking = true
	_wall_stick_attachment = attachment
	player_motor.get_contact_provider().set_wall_stick_attachment(attachment)
	# Entry already committed movement with the old revision. Do not rewrite its
	# reported velocity; zero is only the next-frame motor baseline.
	_wall_stick_committed_velocity = player_motor.get_committed_velocity()
	_wall_stick_has_committed_hold = false
	wall_stick_position = committed_position
	wall_stick_normal = attachment.world_normal
	wall_stick_run_direction = wall_stick_normal.cross(Vector3.UP).normalized()
	wall_stick_surface_identity = contact_frame.wall_support.surface_identity
	wall_stick_identity_persistent = contact_frame.wall_support.has_authored_identity()
	player_motor.get_contact_provider().set_wall_stick_probe_normal(wall_stick_normal)
	_clear_wall_run()
	return true


func _clear_wall_stick() -> void:
	is_wall_sticking = false
	if _wall_stick_attachment != null:
		_wall_stick_attachment.release()
	_wall_stick_attachment = null
	_wall_stick_committed_velocity = Vector3.ZERO
	_wall_stick_has_committed_hold = false
	if player_motor != null and player_motor.get_contact_provider() != null:
		player_motor.get_contact_provider().set_wall_stick_probe_normal(Vector3.ZERO)
	wall_stick_position = Vector3.ZERO
	wall_stick_normal = Vector3.ZERO
	wall_stick_run_direction = Vector3.ZERO
	wall_stick_surface_identity = &""
	wall_stick_identity_persistent = false


## Required wall contact for a wall-stick hold (Story 1.9 Task 7.1). Consumes
## the same shared `ContactFrame` continuity facts the wall-run path uses, so a
## lost or unsupported wall ends the hold instead of pinning the player to a
## wall that is gone.
func has_supported_wall_contact() -> bool:
	var contact_frame := get_previous_contact_frame()
	if not _is_runnable_wall_frame(contact_frame, _player_physics_step - 1):
		return false
	if not is_wall_sticking:
		return true
	return _wall_stick_attachment != null and _wall_stick_attachment.status == WallStickAttachment.Status.VALID and _wall_stick_attachment.matches_contact(contact_frame)


func sample_wall_stick_support(delta: float) -> bool:
	if _wall_stick_attachment == null or not _wall_stick_attachment.sample(get_previous_contact_frame(), _player_physics_step, delta):
		return false
	wall_stick_position = _wall_stick_attachment.target_world_position
	wall_stick_normal = _wall_stick_attachment.world_normal
	player_motor.get_contact_provider().set_wall_stick_probe_normal(wall_stick_normal)
	return true


func has_outward_wall_stick_motion(reference_velocity: Vector3) -> bool:
	# Recovery can consume approaching carry without leaving body velocity.
	# Compare to the last hold's actual commit, not a guessed platform velocity.
	# Before the first hold, the motor intentionally consumes the armed ZERO
	# baseline. Compare to that baseline, not to the old-revision entry commit.
	var carry_reference := _wall_stick_committed_velocity if _wall_stick_has_committed_hold else Vector3.ZERO
	return _has_outward_wall_speed(reference_velocity - carry_reference, wall_stick_normal)


func release_wall_stick_to_grapple(reference_velocity: Vector3) -> void:
	_clear_wall_stick()
	submit_wall_stick_release(reference_velocity)
	dispatch_locomotion_event(EVENT_WALL_STICK_RELEASED)


## A jump must use the current selected wall, not the previous run normal if
## contact was lost or switched on the preceding commit. Preserve jump priority
## over the movement-input gate while refreshing only the shared relationship.
func has_valid_wall_jump_relationship(reference_velocity: Vector3) -> bool:
	if not is_wall_running or not has_supported_wall_contact():
		return false
	return _update_wall_run_relationship(get_previous_contact_frame(), reference_velocity)


func get_movement_input() -> Vector2:
	var frame := get_player_command_frame()
	if frame == null:
		return Vector2.ZERO
	return frame.movement_axis


func update_grapple_feedback() -> void:
	var snapshot := get_grapple_attachment_diagnostic_snapshot()
	_update_grapple_visual(snapshot)
	_update_grapple_marker(snapshot)


func dispatch_locomotion_after_grapple_clear() -> void:
	if has_ground_contact():
		dispatch_locomotion_event(EVENT_LANDED)
	else:
		dispatch_locomotion_event(EVENT_GRAPPLE_RELEASED)


func try_start_grapple() -> bool:
	var frame := _current_command_frame
	var result := _current_targeting_result
	if result == null:
		# An unavailable feature (init failure) was already reported once at
		# composition and stays quiet per press; a live feature that produced
		# no result stays developer-visible.
		var feature_composed := _grapple_targeting_available and _grapple_target_resolver != null
		return _reject_grapple_activation(
			GrappleRejection.Reason.MISSING_RESULT,
			feature_composed
		)
	if (
		frame == null
		or result.source_physics_step != _player_physics_step
		or result.command_frame_step != frame.physics_step
	):
		return _reject_grapple_activation(GrappleRejection.Reason.STALE_RESULT, true)
	if not result.is_accepted() or result.accepted_seed == null:
		return _reject_grapple_activation(result.rejection, false)

	var seed := result.accepted_seed
	var target := seed.get_target()
	if not is_instance_valid(target) or not target is Node3D:
		return _reject_grapple_activation(GrappleRejection.Reason.TARGET_INVALID, true)
	if _grapple_controller == null:
		return _reject_grapple_activation(GrappleRejection.Reason.TARGET_INVALID, true)

	# Commit exactly one occurrence-local attachment from the accepted same-step
	# seed (Story 1.7 Task 2.3). The authoritative anchor is `seed.hit_position`;
	# no rope length is stored and the maximum length never derives from the
	# attachment distance (AC 4).
	var commit_status := _grapple_controller.commit_attachment(seed, _player_physics_step)
	if commit_status != GrappleController.CommitStatus.SUCCESS:
		# The closed `GrappleRejection` set (Story 1.6, locked schema) has no
		# "already attached" value; an unusable activation target - including an
		# attachment that is somehow still active - reports as TARGET_INVALID and
		# stays developer-visible through the same invariant. The true commit
		# status is recorded alongside it as a stable dotted id, so a
		# controller/state fault is never mistaken for a targeting fault without
		# widening the locked `GrappleRejection` schema.
		return _reject_grapple_activation(
			GrappleRejection.Reason.TARGET_INVALID,
			true,
			StringName(
				"player.grapple.commit_%s" % String(
					GrappleController.CommitStatus.keys()[int(commit_status)].to_lower()
				)
			)
		)
	_last_activation_rejection = GrappleRejection.Reason.NONE
	return true


func _reject_grapple_activation(
	reason: GrappleRejection.Reason,
	log_contract_violation: bool,
	detail_id: StringName = &""
) -> bool:
	_last_activation_rejection = reason
	if log_contract_violation:
		_player_log.record_invariant(
			_activation_diagnostic_code(reason),
			DiagnosticContext.new(
				_player_physics_step,
				&"",
				detail_id if detail_id != &"" else GrappleRejection.reason_id(reason)
			)
		)
	return false


func _activation_diagnostic_code(reason: GrappleRejection.Reason) -> StringName:
	match reason:
		GrappleRejection.Reason.STALE_RESULT:
			return &"player.grapple.activation_stale_result"
		GrappleRejection.Reason.TARGET_INVALID:
			return &"player.grapple.activation_target_invalid"
		_:
			return &"player.grapple.activation_missing_result"


func has_valid_grapple() -> bool:
	return is_grappling and is_instance_valid(grapple_target)


## INTERNAL / TEST-ONLY accessor (Story 1.8 review fix, AC 9): the attachment
## record carries mutators (`record_sampled_anchor_state`, `commit_terminal`,
## ...), so presentation, diagnostics, and every external consumer must read
## `get_grapple_attachment_diagnostic_snapshot()` instead. A source-scan
## contract test keeps presentation/diagnostic consumers off this accessor.
func get_grapple_attachment() -> GrappleAttachment:
	if _grapple_controller == null:
		return null
	return _grapple_controller.get_attachment()


## True only while an attachment occurrence is still active. A committed
## terminal leaves the occurrence record in place for diagnostics, but it is no
## longer live state and must not be read back as current gameplay truth.
func _is_live_attachment(attachment: GrappleAttachment) -> bool:
	return attachment != null and attachment.is_active()


## Typed read-only attachment diagnostics (Story 1.7 Task 5, AC 12). Built from
## already-resolved facts only - no physics query, no constraint recomputation.
func get_grapple_attachment_diagnostic_snapshot() -> GrappleAttachmentDiagnosticSnapshot:
	if _grapple_controller == null:
		return null
	return _grapple_controller.get_diagnostic_snapshot()


## Typed read-only wall-stick entry gate status (dev overlay consumption).
## Speed only: uses the same incoming transaction and wall frame as entry.
func is_wall_stick_speed_gate_open() -> bool:
	var result := player_motor.get_last_commit_result() if player_motor != null else null
	return result != null and _can_start_wall_stick(result.submitted_velocity, result.contact_frame.wall_point_velocity)


func get_wall_stick_speed_gate_reason_id() -> StringName:
	var result := player_motor.get_last_commit_result() if player_motor != null else null
	if result == null:
		return &"blocked"
	var incoming_velocity := result.submitted_velocity
	if _can_start_wall_stick(incoming_velocity, result.contact_frame.wall_point_velocity):
		return &"pass"
	if not incoming_velocity.is_finite() or not result.contact_frame.wall_point_velocity.is_finite():
		return &"non_finite_speed"
	return &"total_speed_high"


func get_latest_grapple_targeting_result() -> GrappleTargetingResult:
	return _current_targeting_result


func get_last_activation_rejection() -> GrappleRejection.Reason:
	return _last_activation_rejection


func get_grapple_targeting_diagnostic_snapshot() -> GrappleTargetingDiagnosticSnapshot:
	if _current_targeting_result == null:
		return null
	return GrappleTargetingDiagnosticSnapshot.from_result(_current_targeting_result)


func _update_grapple_visual(snapshot: GrappleAttachmentDiagnosticSnapshot = null) -> void:
	if snapshot == null:
		snapshot = get_grapple_attachment_diagnostic_snapshot()
	if snapshot == null or not snapshot.is_active or not snapshot.anchor_valid:
		_clear_grapple_visual()
		return

	var start := _grapple_controller.get_pull_origin_position()
	var end := snapshot.anchor_world_position
	var segment := end - start
	var length := segment.length()
	if length <= 0.001:
		grapple_visual.visible = false
		return

	var was_hidden := not grapple_visual.visible
	var revision_changed := _grapple_visual_attachment_identity != snapshot.attachment_identity or _grapple_visual_revision != snapshot.anchor_revision
	grapple_visual_mesh.height = length
	grapple_visual.mesh = grapple_visual_mesh
	grapple_visual.global_transform = Transform3D(_basis_from_y_axis(segment), start + segment * 0.5)
	if was_hidden or revision_changed:
		grapple_visual.reset_physics_interpolation()
		grapple_visual_reset_count += 1
	_grapple_visual_attachment_identity = snapshot.attachment_identity
	_grapple_visual_revision = snapshot.anchor_revision
	grapple_visual.visible = true

func _clear_grapple_visual() -> void:
	if grapple_visual != null:
		grapple_visual.visible = false
		grapple_visual.global_transform = Transform3D.IDENTITY
		# Detach geometry rather than building a zero-height cylinder (which
		# generates non-finite normals). Hidden presentation has no endpoints.
		grapple_visual.mesh = null
		grapple_visual_mesh.height = 1.0
	_grapple_visual_attachment_identity = &""
	_grapple_visual_revision = -1

func _update_grapple_marker(snapshot: GrappleAttachmentDiagnosticSnapshot = null) -> void:
	if grapple_marker == null:
		return
	if snapshot == null:
		snapshot = get_grapple_attachment_diagnostic_snapshot()
	grapple_marker.apply_active_attachment(snapshot)
	grapple_marker.apply_targeting_result(_current_targeting_result, is_grappling)


func _basis_from_y_axis(y_axis: Vector3) -> Basis:
	var y := y_axis.normalized()
	var helper := Vector3.FORWARD
	if abs(y.dot(helper)) > 0.98:
		helper = Vector3.RIGHT

	var x := helper.cross(y).normalized()
	var z := x.cross(y).normalized()
	return Basis(x, y, z)


## Idempotent, emitter-driven cleanup for a committed attachment terminal
## (Story 1.7 Task 3.5 / NFR15): the wall-stick coupling and the rope hide run
## at emission time, so a subscriber to `attachment_ended` never observes an
## ended attachment with the rope still up or wall-stick still live.
func _on_grapple_attachment_ended(
	_attachment_id: StringName,
	_reason: GrappleEndReason.Reason
) -> void:
	_clear_wall_stick()
	_clear_grapple_visual()
	_current_targeting_result = null
	if grapple_marker != null:
		grapple_marker.clear_targeting()


## Request exactly one reason-coded attachment terminal (Story 1.7 Task 3.3).
## The preserved `_clear_grapple()` side effects (wall-stick coupling, rope
## hide) run from the controller's `attachment_ended` emission rather than
## here, so they happen exactly once on every terminal path and cannot be
## bypassed by calling `GrappleController.terminate()` directly. Repeated
## requests commit nothing new and return false (NFR15).
func terminate_grapple(reason: GrappleEndReason.Reason) -> bool:
	if _grapple_controller == null:
		return false
	var attachment := _grapple_controller.get_attachment()
	if attachment == null or not attachment.is_active():
		return false
	return _grapple_controller.terminate(reason, _player_physics_step) != null


func get_committed_motion_velocity() -> Vector3:
	if player_motor == null or not is_instance_valid(player_motor):
		return Vector3.ZERO
	return player_motor.get_committed_velocity()


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
	terminate_grapple(GrappleEndReason.Reason.OWNER_DEATH)
	_clear_wall_run()
	_clear_wall_stick()
	_current_targeting_result = null
	if grapple_marker:
		grapple_marker.clear_targeting()
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
