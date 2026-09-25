class_name GrappleAttachment
extends RefCounted


## Player-owned, occurrence-local grapple attachment (architecture "Cross-System
## Contract Specifications" -> grapple contract; Story 1.7 Task 2). Exactly one
## attachment exists per committed grapple occurrence and it carries:
## - the stable attachment identity (execution ID),
## - the immutable `GrappleDefinition` it resolved against,
## - the accepted `GrappleTargetSeed` facts (anchor world position, target
##   identity, weak target reference),
## - occurrence-local resolved values (pull profile, maximum length, speed cap),
## - the single committed terminal result (NFR15).
##
## ATTACHMENT DISTANCE IS NEVER ROPE LENGTH (AC 4): nothing here stores or
## infers a tether length from the distance at attachment time.
## `resolved_maximum_length_m` always resolves from the authored definition and
## is occurrence-local so runtime modifiers can scale it later without touching
## the shared definition (AC 10).
##
## The shared `GrappleDefinition` and `GrappleTargetResponse` stay immutable
## during play; every runtime modifier becomes a local resolved value. The
## anti-pattern is `definition.max_grapple_length_m *= x`.

class Terminal:
	extends RefCounted

	## Committed, value-only terminal result for one attachment occurrence
	## (Story 1.7 Task 3.3). Exactly one is committed per attachment; every
	## later termination request returns this same record unchanged and repeats
	## no transition, presentation effect, signal, or cleanup.

	var attachment_id: StringName
	var reason: GrappleEndReason.Reason
	var reason_id: StringName
	var physics_step: int
	## Velocity the motor had resolved when the terminal committed. Release
	## preserves it (AC 8); it is recorded here, never applied by the record.
	var release_velocity: Vector3

	func _init(
		terminal_attachment_id: StringName,
		terminal_reason: GrappleEndReason.Reason,
		terminal_step: int,
		terminal_release_velocity: Vector3
	) -> void:
		attachment_id = terminal_attachment_id
		reason = terminal_reason
		reason_id = GrappleEndReason.reason_id(terminal_reason)
		physics_step = terminal_step
		release_velocity = (
			terminal_release_velocity
			if terminal_release_velocity.is_finite()
			else Vector3.ZERO
		)


var attachment_id: StringName:
	get:
		return _attachment_id

var creation_physics_step: int:
	get:
		return _creation_physics_step

var definition_id: StringName:
	get:
		return _definition_id

## The ONGOING anchor is the latest sampled `GrappleAnchorState` (Story 1.8 Task
## 3.1); the frozen world `hit_position` from the seed is only the initial
## sample and is never read back as current anchor truth while sampling runs.
var anchor_world_position: Vector3:
	get:
		if _sampled_anchor_state != null:
			return _sampled_anchor_state.anchor_world_position
		return _initial_anchor_world_position

var target_identity: StringName:
	get:
		return _target_identity

var target_local_hit_offset: Vector3:
	get:
		return _target_local_hit_offset

## Full bounded effective response values captured at commit (Task 1.2) - not
## just `pull_multiplier`. The record is immutable authored data; resolution
## below is occurrence-local and never writes back to it (NFR13).
var response: GrappleTargetResponse:
	get:
		return _response

var response_pull_multiplier: float:
	get:
		return _response_pull_multiplier

## Optional originating encounter-scope identity (Task 1.2 / 5): supplied by the
## injectable provider at commit time (a stable `StringName`). `&""` means the
## attachment is unscoped and never scope-checks (AC 10 scope guard).
var originating_scope_identity: StringName:
	get:
		return _originating_scope_identity

var resolved_pull_initial_acceleration_mps2: float:
	get:
		return _resolved_pull_initial_acceleration_mps2

var resolved_pull_min_acceleration_mps2: float:
	get:
		return _resolved_pull_min_acceleration_mps2

var resolved_pull_acceleration_jerk_mps3: float:
	get:
		return _resolved_pull_acceleration_jerk_mps3

var resolved_maximum_speed_mps: float:
	get:
		return _resolved_maximum_speed_mps

var resolved_maximum_length_m: float:
	get:
		return _resolved_maximum_length_m

## Occurrence-local discontinuity tolerances (Task 6.1, AC 7): the authored
## `GrappleDefinition` values scaled by the bounded target `instability` (0..1)
## by at most half. Tolerances only - never a range (Story 1.7 lesson).
var resolved_continuous_motion_tolerance_mps: float:
	get:
		return _resolved_continuous_motion_tolerance_mps

var resolved_severe_discontinuity_threshold_mps: float:
	get:
		return _resolved_severe_discontinuity_threshold_mps

## Occurrence-local pull-profile clock, advanced in seconds after each pull
## submission (pre-increment read, Story 1.7 Task 2.5).
var elapsed_seconds: float:
	get:
		return _elapsed_seconds

## Last pull acceleration magnitude this attachment submitted, in m/s^2.
var applied_acceleration_mps2: float:
	get:
		return _applied_acceleration_mps2

var _attachment_id: StringName
var _creation_physics_step: int
var _definition: GrappleDefinition
var _definition_id: StringName
var _initial_anchor_world_position: Vector3
var _target_identity: StringName
var _target_local_hit_offset: Vector3
var _target_reference: WeakRef
var _response: GrappleTargetResponse
var _response_pull_multiplier: float
var _originating_scope_identity: StringName
var _resolved_pull_initial_acceleration_mps2: float
var _resolved_pull_min_acceleration_mps2: float
var _resolved_pull_acceleration_jerk_mps3: float
var _resolved_maximum_speed_mps: float
var _resolved_maximum_length_m: float
var _resolved_continuous_motion_tolerance_mps: float
var _resolved_severe_discontinuity_threshold_mps: float
var _authored_pull_initial_acceleration_mps2: float
var _authored_pull_min_acceleration_mps2: float
var _authored_pull_acceleration_jerk_mps3: float
var _authored_maximum_speed_mps: float
var _authored_maximum_length_m: float
var _authored_continuous_motion_tolerance_mps: float
var _authored_severe_discontinuity_threshold_mps: float
var _elapsed_seconds := 0.0
var _applied_acceleration_mps2 := 0.0
var _sampled_anchor_state: GrappleAnchorState
var _sampled_anchor_step := -1
var _terminal: Terminal


func _init(
	attachment_identity: StringName,
	physics_step: int,
	definition: GrappleDefinition,
	target_seed: GrappleTargetSeed,
	attachment_originating_scope_identity: StringName = &""
) -> void:
	_attachment_id = attachment_identity
	_creation_physics_step = physics_step
	_definition = definition
	_definition_id = definition.definition_id
	_initial_anchor_world_position = target_seed.hit_position
	_target_identity = target_seed.target_identity
	_target_local_hit_offset = target_seed.target_local_hit_offset
	_target_reference = target_seed.get_target_reference()
	_response = (
		target_seed.response
		if target_seed.response != null
		else GrappleTargetResponse.static_default()
	)
	_response_pull_multiplier = _response.pull_multiplier
	_originating_scope_identity = attachment_originating_scope_identity
	# The accepted hit position is the initial sample (Task 1.1): the ongoing
	# anchor is whatever the sampling phase records each physics step.
	_sampled_anchor_state = GrappleAnchorState.static_default(target_seed.hit_position)
	_sampled_anchor_step = physics_step

	_authored_pull_initial_acceleration_mps2 = definition.pull_initial_acceleration_mps2
	_authored_pull_min_acceleration_mps2 = definition.pull_min_acceleration_mps2
	_authored_pull_acceleration_jerk_mps3 = definition.pull_acceleration_jerk_mps3
	_authored_maximum_speed_mps = definition.maximum_speed_mps
	_authored_maximum_length_m = definition.max_grapple_length_m
	_authored_continuous_motion_tolerance_mps = definition.anchor_continuous_motion_tolerance_mps
	_authored_severe_discontinuity_threshold_mps = (
		definition.anchor_severe_discontinuity_threshold_mps
	)

	# Occurrence-local resolution (AC 10): the shared definition is read, never
	# written. `pull_multiplier` scales the authored pull profile uniformly so
	# its shape (initial -> floor, floor-reached time) is preserved; the speed
	# cap and the maximum length resolve 1:1 from the authored definition
	# because no current target response modifier alters them.
	_resolved_pull_initial_acceleration_mps2 = (
		_authored_pull_initial_acceleration_mps2 * _response_pull_multiplier
	)
	_resolved_pull_min_acceleration_mps2 = (
		_authored_pull_min_acceleration_mps2 * _response_pull_multiplier
	)
	_resolved_pull_acceleration_jerk_mps3 = (
		_authored_pull_acceleration_jerk_mps3 * _response_pull_multiplier
	)
	_resolved_maximum_speed_mps = _authored_maximum_speed_mps
	_resolved_maximum_length_m = _authored_maximum_length_m
	# Task 6.1: bounded `instability` (0..1) scales both discontinuity
	# tolerances down by at most half, occurrence-locally.
	var instability_scale := 1.0 - 0.5 * clampf(_response.instability, 0.0, 1.0)
	_resolved_continuous_motion_tolerance_mps = (
		_authored_continuous_motion_tolerance_mps * instability_scale
	)
	_resolved_severe_discontinuity_threshold_mps = (
		_authored_severe_discontinuity_threshold_mps * instability_scale
	)
	# The pull acceleration currently IN EFFECT for this occurrence. It is seeded
	# from the resolved profile so it reads correctly from the commit step, and is
	# refreshed only by pulls the motor actually accepted - a rejected pull is
	# never reported as having been applied. It is a profile fact, not a claim
	# that a submission was posted.
	_applied_acceleration_mps2 = _resolved_pull_initial_acceleration_mps2


func get_target() -> Object:
	if _target_reference == null:
		return null
	return _target_reference.get_ref()


func has_live_target() -> bool:
	return is_instance_valid(get_target())


func is_active() -> bool:
	return _terminal == null


## Authored pull profile at the attachment's current clock: `min` floor with a
## linear `jerk` decay from `initial`, exactly the Story 1.6 formula (Task 2.5).
func current_pull_acceleration_mps2() -> float:
	return maxf(
		_resolved_pull_min_acceleration_mps2,
		_resolved_pull_initial_acceleration_mps2
		- maxf(_resolved_pull_acceleration_jerk_mps3, 0.0) * _elapsed_seconds
	)


func record_applied_acceleration(acceleration_mps2: float) -> void:
	_applied_acceleration_mps2 = acceleration_mps2


func advance_elapsed(delta_seconds: float) -> void:
	_elapsed_seconds += delta_seconds


## The authoritative sampled anchor state for the current physics step (Task
## 3.1). Presentation and diagnostics read it read-only; submissions consume
## it; nothing recomputes anchor facts elsewhere in the frame (AC 2).
func get_sampled_anchor_state() -> GrappleAnchorState:
	return _sampled_anchor_state


## The physics step the current sample was taken at (Task 3.1: exactly one
## sample per step while the attachment is active).
func get_sampled_anchor_step() -> int:
	return _sampled_anchor_step


## Store this step's one sampled anchor state (Task 3.1). The stored state
## becomes the ongoing anchor, the pull direction source, and the boundary
## payload source for the step.
func record_sampled_anchor_state(state: GrappleAnchorState, physics_step: int) -> void:
	if state == null:
		return
	_sampled_anchor_state = state
	_sampled_anchor_step = physics_step


## Definition-immutability contract (AC 10, NFR13): the occurrence resolved its
## values from these authored scalars, and the shared definition must still hold
## them unchanged.
func is_definition_unmodified() -> bool:
	if _definition == null:
		return false
	return (
		_definition.definition_id == _definition_id
		and absf(_definition.pull_initial_acceleration_mps2 - _authored_pull_initial_acceleration_mps2) <= 0.000001
		and absf(_definition.pull_min_acceleration_mps2 - _authored_pull_min_acceleration_mps2) <= 0.000001
		and absf(_definition.pull_acceleration_jerk_mps3 - _authored_pull_acceleration_jerk_mps3) <= 0.000001
		and absf(_definition.maximum_speed_mps - _authored_maximum_speed_mps) <= 0.000001
		and absf(_definition.max_grapple_length_m - _authored_maximum_length_m) <= 0.000001
		and absf(_definition.anchor_continuous_motion_tolerance_mps - _authored_continuous_motion_tolerance_mps) <= 0.000001
		and absf(_definition.anchor_severe_discontinuity_threshold_mps - _authored_severe_discontinuity_threshold_mps) <= 0.000001
	)



## Commit the one reason-coded terminal for this attachment (AC 9, NFR15).
## Repeated requests return the already-committed record unchanged.
func commit_terminal(
	reason: GrappleEndReason.Reason,
	physics_step: int,
	release_velocity: Vector3
) -> Terminal:
	if _terminal != null:
		return _terminal
	# Fail closed in every build, not assert-only: `assert` is stripped from
	# release exports, so a `NONE` or garbage reason would otherwise commit a
	# terminal the closed schema forbids. Refusing leaves the attachment active
	# so a later valid request can still terminate it (AC 9, NFR15).
	assert(GrappleEndReason.is_valid_reason(int(reason)))
	if not GrappleEndReason.is_valid_reason(int(reason)):
		return null
	_terminal = Terminal.new(_attachment_id, reason, physics_step, release_velocity)
	return _terminal


func get_terminal() -> Terminal:
	return _terminal


func has_committed_terminal() -> bool:
	return _terminal != null
