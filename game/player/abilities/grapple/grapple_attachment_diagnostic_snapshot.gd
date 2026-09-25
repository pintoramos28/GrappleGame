class_name GrappleAttachmentDiagnosticSnapshot
extends RefCounted


## Bounded read-only grapple attachment diagnostics (Story 1.7 Task 5.1, AC 12).
## Built only from the authoritative `GrappleAttachment` and the already-resolved
## motor boundary record - copied scalars and stable identifiers, no live
## references, zero extra physics queries, no constraint recomputation.
##
## VELOCITY BASIS (AC 12 / Dev Notes require this to be explicit):
## `resolved_radial_velocity_mps` / `resolved_tangential_velocity_mps` decompose
## the motor's WORKING velocity at the moment the boundary constraint resolved -
## the pre-commit vector the constraint actually acted on. That is deliberately
## not `committed_velocity_mps`, which is `CharacterBody3D.velocity` after the
## single `move_and_slide()`. They are different vectors and each field is named
## for the one it holds.
##
## `boundary_correction_*` reports what the constraint actually did this step.
## A correction only ever removes the outward radial component of the player's
## motion relative to the anchor that would carry the player past the maximum
## boundary; inward and tangential motion are never touched (AC 5).
## `boundary_carry_applied_mps` names the anchor-separating part of that
## correction (the only part that moves the player with the anchor), and
## `boundary_carry_refused_mps` the part that was refused because it exceeded
## the configured discontinuity tolerance (AC 4). Inside the boundary the
## constraint is silent except for overshoot prevention (AC 6), which is the one
## case where it corrects before the boundary is reached. Development-only,
## opt-in, read-only, bounded (NFR19, FR58).

var attachment_identity: StringName:
	get:
		return _attachment_identity

var target_identity: StringName:
	get:
		return _target_identity

var is_active: bool:
	get:
		return _is_active

var creation_physics_step: int:
	get:
		return _creation_physics_step

var last_physics_step: int:
	get:
		return _last_physics_step

var elapsed_seconds: float:
	get:
		return _elapsed_seconds

var anchor_world_position: Vector3:
	get:
		return _anchor_world_position

## Sampled target velocity in m/s (Story 1.8 Task 7.1): copied from this step's
## authoritative `GrappleAnchorState`, never recomputed here.
var target_velocity_mps: Vector3:
	get:
		return _target_velocity_mps

## Whether the sampled anchor is valid (Task 7.1).
var anchor_valid: bool:
	get:
		return _anchor_valid

## Stable typed anchor status id: `valid`, else the sampled invalidation reason
## id (`target_invalidated`, `target_destroyed`, `scope_mismatch`).
var anchor_status_id: StringName:
	get:
		return _anchor_status_id

## Distance to the anchor at the moment the snapshot is built (AC 12 "current
## distance"). Distinct from `distance_at_resolution_m`, which is the distance
## the motor's boundary constraint measured during its own resolution step.
var current_distance_m: float:
	get:
		return _current_distance_m

var distance_at_resolution_m: float:
	get:
		return _distance_at_resolution_m

var maximum_distance_m: float:
	get:
		return _maximum_distance_m

var range_fraction: float:
	get:
		return _range_fraction

var pull_direction: Vector3:
	get:
		return _pull_direction

## Pull acceleration currently in effect for this occurrence: seeded from the
## resolved profile at commit and refreshed only by pulls the motor accepted.
var submitted_acceleration_mps2: float:
	get:
		return _submitted_acceleration_mps2

var resolved_maximum_speed_mps: float:
	get:
		return _resolved_maximum_speed_mps

## `CharacterBody3D.velocity` after the single `move_and_slide()`.
var committed_velocity_mps: Vector3:
	get:
		return _committed_velocity_mps

## Magnitude of `committed_velocity_mps`, carried as a scalar so consumers do
## not derive their own gameplay facts from the vector.
var committed_speed_mps: float:
	get:
		return _committed_speed_mps

## Whether the resolved total-speed cap was reached at commit. Reported, not
## recomputed by consumers.
var speed_cap_reached: bool:
	get:
		return _speed_cap_reached

## Pre-commit working velocity decomposed by the boundary resolution; positive
## radial means motion away from the anchor.
var resolved_radial_velocity_mps: float:
	get:
		return _resolved_radial_velocity_mps

var resolved_tangential_velocity_mps: float:
	get:
		return _resolved_tangential_velocity_mps

var boundary_correction_applied: bool:
	get:
		return _boundary_correction_applied

var boundary_correction_mps: float:
	get:
		return _boundary_correction_mps

## Anchor-separating carry the boundary actually applied this step (Story 1.8
## Task 7.1, AC 4/9): the only part of the correction that moves the player
## with the anchor.
var boundary_carry_applied_mps: float:
	get:
		return _boundary_carry_applied_mps

## Required carry the boundary refused because it exceeded the configured
## discontinuity tolerance (AC 4). Nonzero means the grapple terminated with
## `ANCHOR_DISCONTINUITY` instead of snapping the player.
var boundary_carry_refused_mps: float:
	get:
		return _boundary_carry_refused_mps

var boundary_positional_tolerance_m: float:
	get:
		return _boundary_positional_tolerance_m

var terminal_reason: GrappleEndReason.Reason:
	get:
		return _terminal_reason

var terminal_reason_id: StringName:
	get:
		return _terminal_reason_id


var _attachment_identity: StringName
var _target_identity: StringName
var _is_active: bool
var _creation_physics_step: int
var _last_physics_step: int
var _elapsed_seconds: float
var _anchor_world_position: Vector3
var _target_velocity_mps: Vector3
var _anchor_valid: bool
var _anchor_status_id: StringName
var _current_distance_m: float
var _distance_at_resolution_m: float
var _maximum_distance_m: float
var _range_fraction: float
var _pull_direction: Vector3
var _submitted_acceleration_mps2: float
var _resolved_maximum_speed_mps: float
var _committed_velocity_mps: Vector3
var _committed_speed_mps: float
var _speed_cap_reached: bool
var _resolved_radial_velocity_mps: float
var _resolved_tangential_velocity_mps: float
var _boundary_correction_applied: bool
var _boundary_correction_mps: float
var _boundary_carry_applied_mps: float
var _boundary_carry_refused_mps: float
var _boundary_positional_tolerance_m: float
var _terminal_reason: GrappleEndReason.Reason
var _terminal_reason_id: StringName


func _init(
	attachment_identity_value: StringName,
	target_identity_value: StringName,
	is_active_value: bool,
	creation_step: int,
	last_step: int,
	elapsed: float,
	anchor_position: Vector3,
	target_velocity: Vector3,
	anchor_valid_value: bool,
	anchor_status_id_value: StringName,
	distance_m: float,
	distance_at_resolution_m_value: float,
	maximum_distance_m_value: float,
	fraction: float,
	pull_direction_value: Vector3,
	acceleration_mps2: float,
	speed_cap_mps: float,
	committed_velocity: Vector3,
	resolved_radial_mps: float,
	resolved_tangential_mps: float,
	committed_speed_mps_value: float,
	speed_cap_reached_value: bool,
	correction_applied: bool,
	correction_mps: float,
	carry_applied_mps: float,
	carry_refused_mps: float,
	positional_tolerance_m: float,
	reason: GrappleEndReason.Reason
) -> void:
	_attachment_identity = attachment_identity_value
	_target_identity = target_identity_value
	_is_active = is_active_value
	_creation_physics_step = creation_step
	_last_physics_step = last_step
	_elapsed_seconds = elapsed
	_anchor_world_position = anchor_position
	_target_velocity_mps = target_velocity
	_anchor_valid = anchor_valid_value
	_anchor_status_id = anchor_status_id_value
	_current_distance_m = distance_m
	_distance_at_resolution_m = distance_at_resolution_m_value
	_maximum_distance_m = maximum_distance_m_value
	_range_fraction = fraction
	_pull_direction = pull_direction_value
	_submitted_acceleration_mps2 = acceleration_mps2
	_resolved_maximum_speed_mps = speed_cap_mps
	_committed_velocity_mps = committed_velocity
	_committed_speed_mps = committed_speed_mps_value
	_speed_cap_reached = speed_cap_reached_value
	_resolved_radial_velocity_mps = resolved_radial_mps
	_resolved_tangential_velocity_mps = resolved_tangential_mps
	_boundary_correction_applied = correction_applied
	_boundary_correction_mps = correction_mps
	_boundary_carry_applied_mps = carry_applied_mps
	_boundary_carry_refused_mps = carry_refused_mps
	_boundary_positional_tolerance_m = positional_tolerance_m
	_terminal_reason = reason
	_terminal_reason_id = GrappleEndReason.reason_id(reason)


## Derive the snapshot from the attachment's own scalars plus the motor's
## already-resolved boundary facts (`facts` mirrors the motor's bounded
## anchor-constraint record; the record keys are the motor's schema and are
## mapped onto the snapshot's explicitly-named fields here). Nothing here
## recomputes constraint resolution.
static func from_attachment(
	attachment: GrappleAttachment,
	facts: Dictionary
) -> GrappleAttachmentDiagnosticSnapshot:
	if attachment == null:
		return null
	var terminal := attachment.get_terminal()
	var reason := GrappleEndReason.Reason.NONE
	if terminal != null:
		reason = terminal.reason
	var committed_velocity := Vector3(facts.get("committed_velocity", Vector3.ZERO))
	var resolved_committed_speed := committed_velocity.length()
	# Derived once here, from copied scalars, so no consumer (presentation
	# included) recomputes a gameplay fact for itself. Locals are named away from
	# the property names so nothing shadows anything.
	var resolved_cap_reached := (
		attachment.resolved_maximum_speed_mps > 0.0
		and resolved_committed_speed >= attachment.resolved_maximum_speed_mps - 0.01
	)
	# Sampled anchor facts (Story 1.8 Task 7.1): copied from this step's stored
	# `GrappleAnchorState`, read-only, never recomputed.
	var sampled := attachment.get_sampled_anchor_state()
	var sampled_velocity := Vector3.ZERO
	var sampled_valid := true
	var sampled_status_id: StringName = &"valid"
	if sampled != null:
		sampled_velocity = sampled.target_velocity
		sampled_valid = sampled.is_valid
		if not sampled.is_valid:
			sampled_status_id = GrappleAnchorState.invalidation_reason_id(
				sampled.invalidation_reason
			)
	return GrappleAttachmentDiagnosticSnapshot.new(
		attachment.attachment_id,
		attachment.target_identity,
		attachment.is_active(),
		attachment.creation_physics_step,
		int(facts.get("physics_step", attachment.creation_physics_step)),
		attachment.elapsed_seconds,
		attachment.anchor_world_position,
		sampled_velocity,
		sampled_valid,
		sampled_status_id,
		float(facts.get("current_distance_m", 0.0)),
		float(facts.get("distance_m", float(facts.get("current_distance_m", 0.0)))),
		attachment.resolved_maximum_length_m,
		float(facts.get("range_fraction", 0.0)),
		Vector3(facts.get("pull_direction", Vector3.ZERO)),
		attachment.applied_acceleration_mps2,
		attachment.resolved_maximum_speed_mps,
		committed_velocity,
		float(facts.get("radial_velocity_mps", 0.0)),
		float(facts.get("tangential_velocity_mps", 0.0)),
		resolved_committed_speed,
		resolved_cap_reached,
		bool(facts.get("correction_applied", false)),
		float(facts.get("correction_mps", 0.0)),
		float(facts.get("carry_applied_mps", 0.0)),
		float(facts.get("carry_refused_mps", 0.0)),
		float(facts.get("positional_tolerance_m", 0.0)),
		reason
	)


## True only when every script variable holds a value type (int, float, bool,
## StringName, Vector3; enums are ints). Nothing object-typed is allowed here -
## the snapshot is built from copied scalars only (Task 5.2).
func is_value_only() -> bool:
	return GrappleAttachmentDiagnosticSnapshot.value_is_value_only(self)


static func value_is_value_only(value: Variant) -> bool:
	if value == null or not (value is GrappleAttachmentDiagnosticSnapshot):
		return false
	for property in value.get_property_list():
		if (property.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) == 0:
			continue
		match int(property.type):
			TYPE_INT, TYPE_FLOAT, TYPE_BOOL, TYPE_STRING, TYPE_STRING_NAME, TYPE_VECTOR3:
				continue
			_:
				return false
	return true
