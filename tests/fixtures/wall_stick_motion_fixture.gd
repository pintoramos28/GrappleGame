class_name WallStickMotionFixture
extends Node3D
## Engine-driven fixture shared by GUT and MCP live smoke. No manual controller
## stepping, fake motor delta, production geometry edits or production retuning.
const PLAYER := preload("res://scenes/player.tscn")
const MOVER := preload("res://tests/fixtures/wall_stick_support_mover.gd")

var player: CharacterBody3D
var motor: PlayerMotor
var input_source: PlayerInputSource
var wall: PhysicsBody3D
var anchor: StaticBody3D
var held_frames := 0
var entry_count := 0
var terminal_count := 0
var blocked_count := 0
var maximum_error_m := 0.0
var minimum_side_distance_m := INF
var overlap_count := 0
var maximum_commits := 0
var entry_submitted_velocity := Vector3.ZERO
var jump_velocity := Vector3.ZERO
var detachment_commit: PlayerMotorCommitResult
var detachment_reference_velocity := Vector3.ZERO
var _previous_committed_velocity := Vector3.ZERO
var maximum_recovery_m := 0.0
var legacy_switch_count := 0
var physics_wall_transform := Transform3D.IDENTITY
var obsolete_pose_overlap_count := 0
var overlap_facts: Array[Dictionary] = []
var _last_overlap_step := -1
var terminal_wall_clear := true
var _previous_stick := false
var _latched_local_position := Vector3.ZERO
var entry_step := -1
var first_hold_commit: PlayerMotorCommitResult
var hold_step_ids: Array[int] = []
var settled_overlap_step_ids: Array[int] = []
var blocked_overlap_step_ids: Array[int] = []
var overlap_step_id_overflow := 0
var _overlap_observed_steps: Dictionary = {}
var _pending_blocked_pose: Dictionary = {}
var _last_observed_commit_step := -1
const MAX_OBSERVATION_IDS := 4096
@export var moving_grapple_anchor := false
var initial_wall_motion := Vector3.ZERO
var initial_owner_motion := Vector3.ZERO
var initial_wall_position := Vector3(0.0, 4.0, -0.65)
var initial_teleport := Vector3.ZERO
var initial_compound := false
var initial_disabled_owner := false
var freeze_after_first_commit := false
var grapple_definition_override: GrappleDefinition
var wall_stick_definition_override: WallStickDefinition

func _ready() -> void:
	process_physics_priority = 10
	wall = _create_support_body()
	wall.name = "SupportingWall"
	wall.position = initial_wall_position
	wall.set("motion_velocity", initial_wall_motion)
	wall.set("owner_motion_velocity", initial_owner_motion)
	wall.set("first_tick_teleport", initial_teleport)
	wall.set_meta(&"physics_surface_id", &"fixture.wall.stick")
	if initial_disabled_owner:
		var disabled_shape := _add_shape(wall, Vector3.ONE)
		disabled_shape.name = "DisabledUnrelatedShape"
		disabled_shape.disabled = true
	var wall_shape := _add_shape(wall, Vector3(16.0, 16.0, 0.4))
	wall_shape.name = "WallShape"
	if initial_compound:
		var ceiling := _add_shape(wall, Vector3(4.0, 0.2, 4.0))
		ceiling.name = "SameBodyCeiling"
		ceiling.position = Vector3(0.0, 2.3, -initial_wall_position.z)
	add_child(wall)
	anchor = StaticBody3D.new()
	anchor.name = "DistinctGrappleAnchor"
	anchor.position = Vector3(0.0, 4.0, -2.0)
	_add_shape(anchor, Vector3(0.2, 0.2, 0.2))
	var grappleable: Grappleable3D
	if moving_grapple_anchor:
		anchor.set_script(MOVER)
		grappleable = Grappleable3D.new()
		grappleable.name = "Grappleable"
		grappleable.target_id = &"fixture.grapple.moving"
		grappleable.anchor_mode = GrappleTargetResponse.AnchorMode.MOVING
		anchor.add_child(grappleable)
	add_child(anchor)
	player = PLAYER.instantiate()
	if grapple_definition_override != null:
		player.set("grapple_definition", grapple_definition_override)
	if wall_stick_definition_override != null:
		player.set("wall_stick_definition", wall_stick_definition_override)
	player.name = "Player"
	player.position = Vector3(0.0, 4.0, 0.0)
	player.set("capture_mouse_on_start", false)
	add_child(player)
	motor = player.get_node(^"PlayerMotor") as PlayerMotor
	input_source = player.get_node(^"PlayerInputSource") as PlayerInputSource
	input_source.inject_movement_strengths(0.0, 0.0, 1.0, 1.0)
	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	var controller: GrappleController = player.get("_grapple_controller")
	controller.attachment_ended.connect(_on_terminal)
	var target_seed := GrappleTargetSeed.new(grappleable.target_id if grappleable != null else &"", anchor.global_position, Vector3.BACK, grappleable.build_response() if grappleable != null else GrappleTargetResponse.static_default(), weakref(anchor), Vector3.ZERO)
	controller.commit_attachment(target_seed, 0)
	player.call("dispatch_locomotion_event", &"grapple_started")

## Override only in native-body test fixtures; production mover types are unchanged.
func _create_support_body() -> PhysicsBody3D:
	var support := StaticBody3D.new()
	support.set_script(MOVER)
	return support

func _physics_process(_delta: float) -> void:
	if is_instance_valid(wall):
		physics_wall_transform = PhysicsServer3D.body_get_direct_state(wall.get_rid()).transform
	var result := motor.get_last_commit_result()
	if result == null or result.physics_step == _last_observed_commit_step:
		return
	_last_observed_commit_step = result.physics_step
	if freeze_after_first_commit:
		player.set_physics_process(false)
	maximum_commits = maxi(maximum_commits, result.commit_count)
	var sticking := bool(player.get("is_wall_sticking"))
	if sticking and not _previous_stick:
		entry_count += 1
		entry_step = result.physics_step
		entry_submitted_velocity = result.submitted_velocity
		_latched_local_position = wall.global_transform.affine_inverse() * player.global_position
	# At 120 Hz an idle-frame await can observe the next grapple acceleration
	# instead of release. Latch the first detachment commit on the physics tick.
	if _previous_stick and not sticking and detachment_commit == null:
		detachment_commit = result
		detachment_reference_velocity = _previous_committed_velocity
	_previous_committed_velocity = result.committed_velocity
	_previous_stick = sticking
	if result.applied_constraints.has(&"player.wall_stick.hold"):
		if first_hold_commit == null:
			first_hold_commit = result
		held_frames += 1
		if hold_step_ids.size() < MAX_OBSERVATION_IDS:
			hold_step_ids.append(result.physics_step)
		else:
			overlap_step_id_overflow += 1
		maximum_error_m = maxf(maximum_error_m, result.hold_position_error_m)
		maximum_recovery_m = maxf(maximum_recovery_m, result.hold_recovery_displacement.length())
		blocked_count += int(result.hold_carry_blocked)
		legacy_switch_count += int(result.contact_frame.continuity_action == ContactFrame.ContinuityAction.SWITCHED)
		if result.hold_carry_blocked:
			_pending_blocked_pose = {"step": result.physics_step, "transform": player.get_node(^"CollisionShape3D").global_transform}
	if result.phase_intermediates.size() > MotorPhase.Phase.ONE_SHOT_IMPULSES:
		for source: StringName in result.phase_intermediates[MotorPhase.Phase.ONE_SHOT_IMPULSES].get("applied_sources", []):
			if source == &"player.jump.wall":
				jump_velocity = result.submitted_velocity
	if is_instance_valid(wall) and result.is_hold_request:
		var local_position := wall.global_transform.affine_inverse() * player.global_position
		minimum_side_distance_m = minf(minimum_side_distance_m, local_position.z - 0.2)
		var query := PhysicsShapeQueryParameters3D.new()
		var collision_shape := player.get_node(^"CollisionShape3D") as CollisionShape3D
		query.shape = collision_shape.shape
		query.transform = collision_shape.global_transform
		query.collision_mask = 1
		query.margin = 0.0
		query.exclude = [player.get_rid()]
		if not get_world_3d().direct_space_state.intersect_shape(query).is_empty():
			obsolete_pose_overlap_count += 1

func _process(_delta: float) -> void:
	# Read-only verification after Jolt consumes queued StaticBody transforms.
	# A query inside _physics_process still sees the obsolete support pose;
	# report that separately rather than mislabel it as post-sync penetration.
	# A second 120 Hz tick may detach before idle observes the blocked commit.
	# Query its latched player pose against the next settled space explicitly;
	# this is a follow-up observation, not a reconstructed historical world.
	if not _pending_blocked_pose.is_empty():
		_observe_settled_overlap(_pending_blocked_pose.step, _pending_blocked_pose.transform, true)
		_pending_blocked_pose.clear()
	var result := motor.get_last_commit_result()
	if result != null and result.is_hold_request:
		_observe_settled_overlap(result.physics_step, player.get_node(^"CollisionShape3D").global_transform, result.hold_carry_blocked)

func _observe_settled_overlap(step: int, pose: Transform3D, blocked: bool) -> void:
	if _overlap_observed_steps.has(step) or settled_overlap_step_ids.size() >= MAX_OBSERVATION_IDS:
		return
	_overlap_observed_steps[step] = true
	settled_overlap_step_ids.append(step)
	if blocked:
		blocked_overlap_step_ids.append(step)
	_last_overlap_step = step
	var query := PhysicsShapeQueryParameters3D.new()
	var collision_shape := player.get_node(^"CollisionShape3D") as CollisionShape3D
	query.shape = collision_shape.shape
	query.transform = pose
	query.collision_mask = 1
	query.margin = 0.0
	query.exclude = [player.get_rid()]
	var overlaps := get_world_3d().direct_space_state.intersect_shape(query)
	if not overlaps.is_empty():
		overlap_count += 1
		if overlap_facts.size() < 3:
			overlap_facts.append({"step": step, "position": pose.origin, "blocked": blocked, "collider": overlaps[0].collider.name, "rest": get_world_3d().direct_space_state.get_rest_info(query)})

func report() -> Dictionary:
	return {"held_frames": held_frames, "entry_count": entry_count, "terminal_count": terminal_count,
		"blocked_count": blocked_count, "maximum_error_m": maximum_error_m,
		"minimum_side_distance_m": minimum_side_distance_m, "overlap_count": overlap_count,
		"maximum_commits": maximum_commits, "maximum_recovery_m": maximum_recovery_m,
		"legacy_switch_count": legacy_switch_count, "jump_velocity": jump_velocity,
		"sticking": player.get("is_wall_sticking"), "grappling": player.get("is_grappling"),
		"terminal_wall_clear": terminal_wall_clear, "position": player.global_position,
		"physics_wall_position": physics_wall_transform.origin,
		"obsolete_pose_overlap_count": obsolete_pose_overlap_count,
		"overlap_facts": overlap_facts.duplicate(true),
		"hold_step_ids": hold_step_ids.duplicate(), "settled_overlap_step_ids": settled_overlap_step_ids.duplicate(),
		"missed_overlap_step_count": held_frames - settled_overlap_step_ids.size(),
		"overlap_step_id_overflow": overlap_step_id_overflow, "blocked_overlap_step_ids": blocked_overlap_step_ids.duplicate(),
		"wall_position": wall.global_position if is_instance_valid(wall) else Vector3.ZERO}

func add_blocker() -> StaticBody3D:
	var blocker := StaticBody3D.new()
	blocker.name = "CarryBlocker"
	# A ceiling blocks carry without becoming a different selected WALL.
	blocker.position = player.global_position + Vector3(0.0, 2.3, 0.0)
	_add_shape(blocker, Vector3(4.0, 0.2, 4.0))
	add_child(blocker)
	return blocker

func _on_terminal(_id: StringName, _reason: GrappleEndReason.Reason) -> void:
	terminal_count += 1
	terminal_wall_clear = terminal_wall_clear and not bool(player.get("is_wall_sticking"))

func _add_shape(body: CollisionObject3D, size: Vector3) -> CollisionShape3D:
	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = size
	collision.shape = shape
	body.add_child(collision)
	return collision
