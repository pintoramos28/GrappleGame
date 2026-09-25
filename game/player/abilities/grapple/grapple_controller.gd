class_name GrappleController
extends RefCounted


## Player-owned grapple ability controller (architecture "Semantic Motor
## Influence Pipeline" and "Data Patterns"; Story 1.7 Task 2). It owns the active
## `GrappleAttachment`, resolves occurrence-local values against the immutable
## `GrappleDefinition`, and submits grapple motor influences.
##
## It is an influence submitter, never a movement writer (AC 2): it never assigns
## body velocity, never calls movement, and never discards pre-existing momentum.
## `PlayerMotor` remains the only writer of `CharacterBody3D.velocity` and the
## only caller of `move_and_slide()`.
##
## PLAYER REFERENCE POINT (Story 1.7 Task 4.4): the owner `CharacterBody3D`
## origin (`get_reference_position()`), matching the motor's commit transform.
## Pull direction, distance measurement, boundary resolution, and the diagnostics
## snapshot all use this one reference point. The rope visual's mesh-center start
## point is presentation only and is not a gameplay reference.
##
## Termination is requested by the owning player controller (`terminate()`); this
## class commits exactly one reason-coded terminal per attachment and emits
## `attachment_ended` once (NFR15).

signal attachment_committed(attachment_id: StringName)
signal attachment_ended(attachment_id: StringName, reason: GrappleEndReason.Reason)


enum InitializationStatus {
	SUCCESS,
	ALREADY_INITIALIZED,
	MISSING_BODY,
	MISSING_DEFINITION,
}

enum CommitStatus {
	SUCCESS,
	NOT_INITIALIZED,
	INVALID_SEED,
	TARGET_INVALID,
	ATTACHMENT_ALREADY_ACTIVE,
}


## Stable motor source identifiers (lowercase dotted namespaces).
const SOURCE_PULL: StringName = &"player.grapple.pull"
const SOURCE_SPEED_CAP: StringName = &"player.grapple.speed_cap"
const SOURCE_MAXIMUM_DISTANCE: StringName = &"player.grapple.maximum_distance"

var _owner_body: CharacterBody3D
var _definition: GrappleDefinition
var _attachment: GrappleAttachment
var _attachment_serial := 0
var _initialized := false
var _scope_identity_provider: Callable
var _last_pull_direction := Vector3.ZERO
var _last_committed_velocity := Vector3.ZERO
var _last_physics_step := -1
var _last_boundary_record: Dictionary = {}


func initialize(
	owner_body: CharacterBody3D,
	definition: GrappleDefinition
) -> InitializationStatus:
	if _initialized:
		return InitializationStatus.ALREADY_INITIALIZED
	if owner_body == null or not is_instance_valid(owner_body):
		return InitializationStatus.MISSING_BODY
	if definition == null:
		return InitializationStatus.MISSING_DEFINITION
	_owner_body = owner_body
	_definition = definition
	_initialized = true
	return InitializationStatus.SUCCESS


func is_initialized() -> bool:
	return _initialized


## Injectable encounter-scope identity source (Story 1.8 Task 1.2, AC 1/6/10).
## The provider is a `Callable` returning the current stable scope identity (a
## lowercase dotted `StringName`); it is resolved at commit time and stored on
## the attachment. Empty / no provider means the attachment is unscoped and
## never scope-checks. Only this identity contract is in scope - no encounter
## lifecycle, registry, or reset machinery is built here.
func set_scope_identity_provider(provider: Callable) -> void:
	_scope_identity_provider = provider


func get_originating_scope_identity() -> StringName:
	if not _scope_identity_provider.is_valid():
		return &""
	var supplied: Variant = _scope_identity_provider.call()
	if supplied == null:
		return &""
	var identity := StringName(supplied)
	return identity if identity != &"" else &""


## The one documented player reference point (Task 4.4).
func get_reference_position() -> Vector3:
	if _owner_body == null or not is_instance_valid(_owner_body):
		return Vector3.ZERO
	return _owner_body.global_position


## Commit exactly one attachment from the accepted same-step seed (AC 1, Task
## 2.3). The accepted hit position is the INITIAL anchor sample only; the
## ongoing anchor is the per-step sampled `GrappleAnchorState` (Task 1.1). No
## rope length is stored and the maximum length never derives from the
## attachment distance (AC 4). The optional originating encounter-scope
## identity is resolved from the injectable provider at commit time (Task 1.2).
func commit_attachment(
	target_seed: GrappleTargetSeed,
	physics_step: int
) -> CommitStatus:
	if not _initialized:
		return CommitStatus.NOT_INITIALIZED
	if target_seed == null:
		return CommitStatus.INVALID_SEED
	if _attachment != null and _attachment.is_active():
		return CommitStatus.ATTACHMENT_ALREADY_ACTIVE
	var target := target_seed.get_target()
	if not is_instance_valid(target):
		return CommitStatus.TARGET_INVALID
	_attachment_serial += 1
	var attachment_identity := StringName(
		"player.grapple.attachment_%d" % _attachment_serial
	)
	_attachment = GrappleAttachment.new(
		attachment_identity,
		physics_step,
		_definition,
		target_seed,
		get_originating_scope_identity()
	)
	_last_pull_direction = Vector3.ZERO
	_last_committed_velocity = Vector3.ZERO
	_last_physics_step = physics_step
	_last_boundary_record = {}
	attachment_committed.emit(attachment_identity)
	return CommitStatus.SUCCESS


func has_active_attachment() -> bool:
	return _attachment != null and _attachment.is_active()


func get_attachment() -> GrappleAttachment:
	return _attachment


## The authoritative sampled anchor state for the current physics step (Task
## 3.1). Submissions, presentation, and diagnostics all read this one stored
## sample; nothing recomputes anchor facts later in the frame (AC 2).
func get_sampled_anchor_state() -> GrappleAnchorState:
	if _attachment == null:
		return null
	return _attachment.get_sampled_anchor_state()


## Grapple-sampling phase (Story 1.8 Task 3.1, AC 2/3/6/7/8): sample exactly one
## `GrappleAnchorState` for this physics step BEFORE any motor submission and
## store it as the step's authoritative state.
##
## An invalid sample commits exactly one typed terminal through the existing
## single funnel (`terminate` -> `GrappleAttachment.commit_terminal`) and
## returns false so the caller submits nothing for this step:
## - target freed -> `TARGET_DESTROYED` (no stale dereference, NFR14),
## - explicit invalidation / unusable anchor -> `TARGET_INVALIDATED`,
## - incompatible encounter-scope identity -> `SCOPE_MISMATCH`,
## - severe anchor discontinuity -> `ANCHOR_DISCONTINUITY` (AC 7).
##
## Sampling is idempotent within one physics step: repeated calls for the same
## step return the earlier verdict and never re-sample (one sample per step).
func sample_anchor_state(physics_step: int, delta_seconds: float) -> bool:
	if _attachment == null or not _attachment.is_active():
		return false
	if _attachment.get_sampled_anchor_step() == physics_step:
		return _attachment.get_sampled_anchor_state().is_valid
	var target := _attachment.get_target()
	if not is_instance_valid(target):
		_record_invalid_sample(
			GrappleAnchorState.InvalidationReason.TARGET_DESTROYED,
			physics_step
		)
		_terminate_from_sample(GrappleEndReason.Reason.TARGET_DESTROYED, physics_step)
		return false
	var state := _sample_target_anchor_state(target, delta_seconds)
	if state == null or not state.is_valid:
		if state != null:
			_attachment.record_sampled_anchor_state(state, physics_step)
		else:
			_record_invalid_sample(
				GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED,
				physics_step
			)
		_terminate_from_sample(_sample_terminal_reason(state), physics_step)
		return false
	if _is_scope_mismatch(state):
		_attachment.record_sampled_anchor_state(state, physics_step)
		_terminate_from_sample(GrappleEndReason.Reason.SCOPE_MISMATCH, physics_step)
		return false
	if _is_severe_anchor_discontinuity(state, delta_seconds):
		_attachment.record_sampled_anchor_state(state, physics_step)
		_terminate_from_sample(GrappleEndReason.Reason.ANCHOR_DISCONTINUITY, physics_step)
		return false
	_attachment.record_sampled_anchor_state(state, physics_step)
	return true


## Store the step's sampled facts even when the sample is invalid (AC 6/9): the
## diagnostics snapshot reports the LAST sampled anchor state, and an invalid
## sample is still the authoritative fact of that step. The synthesized record
## keeps the previous anchor position and reports only the typed reason.
func _record_invalid_sample(
	reason: GrappleAnchorState.InvalidationReason,
	physics_step: int
) -> void:
	var previous := _attachment.get_sampled_anchor_state()
	var anchor_position := previous.anchor_world_position if previous != null else Vector3.ZERO
	var scope := previous.scope_identity if previous != null else &""
	_attachment.record_sampled_anchor_state(
		GrappleAnchorState.invalid(anchor_position, reason, scope),
		physics_step
	)


## Target-side sampling (Task 2.2). Ordinary geometry keeps the built-in static
## response (frozen world anchor, zero velocity); explicit targets are sampled
## through the query-only `Grappleable3D` API. No raycast is issued here - the
## anchor follows transform math only (AC 3).
func _sample_target_anchor_state(
	target: Object,
	delta_seconds: float
) -> GrappleAnchorState:
	var identity := _attachment.target_identity
	var initial_anchor := _attachment.get_sampled_anchor_state().anchor_world_position
	if identity == &"":
		return GrappleAnchorState.static_default(initial_anchor)
	var component := _find_anchor_component(target, identity)
	if component == null:
		# The accepted target's anchor contract is gone while its body lives:
		# the anchor became unusable (AC 6).
		return GrappleAnchorState.invalid(
			initial_anchor,
			GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED,
			&"",
			_attachment.response
		)
	return component.sample_anchor_state(
		_attachment.target_local_hit_offset,
		delta_seconds,
		initial_anchor
	)


## The accepted `Grappleable3D` component on the anchor body (direct-child
## contract), matched by stable target identity.
func _find_anchor_component(target: Object, identity: StringName) -> Grappleable3D:
	for component in Grappleable3D.find_explicit_grappleables(target):
		if component.get_target_id() == identity:
			return component
	return null


func _sample_terminal_reason(state: GrappleAnchorState) -> GrappleEndReason.Reason:
	if state != null:
		match state.invalidation_reason:
			GrappleAnchorState.InvalidationReason.TARGET_DESTROYED:
				return GrappleEndReason.Reason.TARGET_DESTROYED
			GrappleAnchorState.InvalidationReason.SCOPE_MISMATCH:
				return GrappleEndReason.Reason.SCOPE_MISMATCH
	return GrappleEndReason.Reason.TARGET_INVALIDATED


## Scope-identity contract (AC 1/6/10): a mismatch exists only when both sides
## declare a scope identity and they differ. Unscoped attachments accept any
## target, and unscoped targets accept any attachment.
func _is_scope_mismatch(state: GrappleAnchorState) -> bool:
	var originating := _attachment.originating_scope_identity
	if originating == &"" or state.scope_identity == &"":
		return false
	return state.scope_identity != originating


## Discontinuity classification (AC 7, Task 6.2): the sampled anchor position is
## compared with the previous step's sampled position. The implied speed
## (displacement / delta_seconds) is rate-equivalent at 60 Hz and 120 Hz. At or
## above the severe threshold the grapple terminates before any submission for
## the step; below the continuous tolerance the anchor follows normally; the
## band between them keeps following while any required boundary carry above the
## continuous tolerance terminates instead of snapping (AC 4).
func _is_severe_anchor_discontinuity(
	state: GrappleAnchorState,
	delta_seconds: float
) -> bool:
	if delta_seconds <= 0.0:
		return false
	var previous := _attachment.get_sampled_anchor_state()
	if previous == null:
		return false
	var implied_speed := (
		state.anchor_world_position - previous.anchor_world_position
	).length() / delta_seconds
	return implied_speed >= _attachment.resolved_severe_discontinuity_threshold_mps


func _terminate_from_sample(
	reason: GrappleEndReason.Reason,
	physics_step: int
) -> void:
	terminate(reason, physics_step)


## Per-step grapple motor influences (Task 4.6; Story 1.8 Task 3.2): the
## sustained zip-pull toward the sampled anchor (SUSTAINED_INFLUENCES) plus the
## maximum-anchor-distance boundary constraint (CONSTRAINTS_AND_REDIRECTIONS),
## both derived from THIS step's one stored `GrappleAnchorState` - never from a
## live transform read (AC 2). The speed cap is a separate per-step submission
## (`submit_speed_cap`) so the owning state keeps its declared submission
## ordering. Nothing is submitted once the attachment is absent or terminated.
func submit_motor_influences(
	motor: PlayerMotor,
	delta_seconds: float
) -> PlayerMotor.SubmissionStatus:
	if _attachment == null or not _attachment.is_active():
		return PlayerMotor.SubmissionStatus.NO_ACTIVE_ATTACHMENT
	var sample := _attachment.get_sampled_anchor_state()
	var pull_direction := get_reference_position().direction_to(
		sample.anchor_world_position
	)
	# Byte-identical Story 1.6 pull timing (Task 2.5): the acceleration is read
	# from the pre-increment clock, then the clock advances by delta.
	var acceleration_mps2 := _attachment.current_pull_acceleration_mps2()
	_last_pull_direction = pull_direction

	var status := PlayerMotor.SubmissionStatus.SUCCESS
	if pull_direction != Vector3.ZERO:
		status = motor.submit_sustained_acceleration(
			SOURCE_PULL,
			pull_direction * acceleration_mps2
		)
		# Record only a pull the motor actually accepted; a rejected pull must
		# not be reported as applied.
		if status == PlayerMotor.SubmissionStatus.SUCCESS:
			_attachment.record_applied_acceleration(acceleration_mps2)
	# The profile clock is elapsed attachment time, not accepted submissions
	# (the floor is reached ~0.75 s after attachment), so it advances with the
	# step regardless of acceptance.
	_attachment.advance_elapsed(delta_seconds)
	var constraint_status := motor.submit_maximum_anchor_distance(
		SOURCE_MAXIMUM_DISTANCE,
		sample.anchor_world_position,
		_attachment.resolved_maximum_length_m,
		sample.target_velocity,
		_attachment.resolved_continuous_motion_tolerance_mps
	)
	if status == PlayerMotor.SubmissionStatus.SUCCESS:
		status = constraint_status
	return status


## Per-step total-speed cap (CAPS_AND_FINAL_COMMIT) from the occurrence-local
## resolved value.
func submit_speed_cap(motor: PlayerMotor) -> PlayerMotor.SubmissionStatus:
	if _attachment == null or not _attachment.is_active():
		return PlayerMotor.SubmissionStatus.NO_ACTIVE_ATTACHMENT
	return motor.submit_total_speed_cap(
		SOURCE_SPEED_CAP,
		_attachment.resolved_maximum_speed_mps
	)


## Commit exactly one reason-coded terminal for the current attachment (AC 9,
## NFR15). Repeated requests return the already-committed record unchanged and
## repeat no state transition, presentation effect, signal, or cleanup. A null
## result means there was nothing to terminate.
func terminate(
	reason: GrappleEndReason.Reason,
	physics_step: int
) -> GrappleAttachment.Terminal:
	if _attachment == null:
		return null
	var already_committed := _attachment.has_committed_terminal()
	var terminal := _attachment.commit_terminal(
		reason,
		physics_step,
		_last_committed_velocity
	)
	# A null terminal means the request was refused (see
	# `GrappleAttachment.commit_terminal`); nothing was committed, so nothing is
	# announced and no cleanup runs.
	if terminal != null and not already_committed:
		attachment_ended.emit(terminal.attachment_id, terminal.reason)
	return terminal


## Cache the already-resolved motor facts after the physics-step commit so the
## diagnostics snapshot can report them without recomputation (Task 5.2).
## A refused boundary carry (the required correction exceeded the configured
## discontinuity tolerance, AC 4) terminates the attachment here through the
## single funnel - same step, after the commit that applied nothing from the
## anchor - instead of ever snapping the player.
func record_committed_facts(result: PlayerMotorCommitResult) -> void:
	if result == null:
		return
	_last_committed_velocity = result.committed_velocity
	_last_physics_step = result.physics_step
	# Clear first: a frame that commits no boundary record (release step, a
	# WALL_STICK_HOLD frame, a post-termination poll) must not keep serving the
	# previous step's distance and correction as current facts.
	_last_boundary_record = {}
	for record in result.anchor_constraint_records:
		if StringName(record.get("source_id", &"")) == SOURCE_MAXIMUM_DISTANCE:
			_last_boundary_record = record.duplicate(true)
			break
	if (
		_attachment != null
		and _attachment.is_active()
		and bool(_last_boundary_record.get("carry_refused", false))
	):
		terminate(GrappleEndReason.Reason.ANCHOR_DISCONTINUITY, result.physics_step)


func get_diagnostic_snapshot() -> GrappleAttachmentDiagnosticSnapshot:
	if _attachment == null:
		return null
	var facts := _last_boundary_record.duplicate(true)
	# The "current" distance is read once at snapshot build from two known
	# scalar positions - never a physics query, never constraint recomputation.
	# It is reported separately from `distance_m`, which is the distance the
	# motor measured while resolving the boundary this step.
	var current_distance_m := get_reference_position().distance_to(
		_attachment.anchor_world_position
	)
	if facts.is_empty():
		# Before the first resolved boundary record there is no motor fact to
		# copy; the velocity decomposition stays at its zero default.
		facts["physics_step"] = _last_physics_step
		facts["positional_tolerance_m"] = (
			PlayerMotor.ANCHOR_DISTANCE_POSITIONAL_TOLERANCE_M
		)
	# `range_fraction` pairs with the distance the boundary ENFORCED
	# (`distance_m`), so it is bounded by the authored maximum plus the documented
	# positional tolerance; `current_distance_m` is the separately-named live read.
	var resolution_distance_m := float(facts.get("distance_m", current_distance_m))
	facts["distance_m"] = resolution_distance_m
	facts["current_distance_m"] = current_distance_m
	facts["range_fraction"] = (
		resolution_distance_m / _attachment.resolved_maximum_length_m
		if _attachment.resolved_maximum_length_m > 0.0
		else 0.0
	)
	facts["pull_direction"] = _last_pull_direction
	facts["committed_velocity"] = _last_committed_velocity
	return GrappleAttachmentDiagnosticSnapshot.from_attachment(_attachment, facts)
