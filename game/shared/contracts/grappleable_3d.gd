class_name Grappleable3D
extends Node3D


## Optional direct-child `Grappleable` component for exceptional grapple targets
## (moving, stateful, hazardous, resistant, modified, or ineligible bodies).
##
## Query-only contract (AC 3): this component answers bounded typed response data
## and can never move the player, write player velocity, change locomotion state,
## or call player abilities. That boundary is enforced by the narrow read-only API
## surface below - there is no player, motor, or locomotion reference anywhere in
## this type - and the dev assertion keeps every produced response bounded.
##
## Ordinary collision geometry needs no component and receives the built-in static
## response from `GrappleTargetResponse.static_default()`.
##
## ANCHOR SAMPLING (Story 1.8 Task 2.2): while an attachment is active the
## player samples exactly one `GrappleAnchorState` per physics step through
## `sample_anchor_state()`. It resolves the stored target-local hit offset
## against the anchor body's global transform - pure transform math, never a
## raycast or a re-selection (AC 3) - and reports bounded facts only.

const COMPONENT_NODE_NAME := &"Grappleable"


## Stable authored target identity (lowercase dotted `StringName`). Required for
## explicit acceptance; never derived from node names or scene paths.
@export var target_id: StringName = &""
@export var eligible := true
@export var anchor_mode: GrappleTargetResponse.AnchorMode = GrappleTargetResponse.AnchorMode.STATIC
@export var pull_multiplier := 1.0
@export var directional_adjustment := Vector3.ZERO
@export var instability := 0.0
@export var hazard_response: GrappleTargetResponse.HazardResponse = GrappleTargetResponse.HazardResponse.NONE
## Optional encounter-scope identity this target currently belongs to
## (`&""` = unscoped). Story 1.8 introduces the identity contract only: no
## encounter lifecycle, registry, or reset machinery (AC 10 scope guard).
@export var encounter_scope_identity: StringName = &""


var _anchor_explicitly_invalidated := false
var _has_supplied_anchor_velocity := false
var _supplied_anchor_velocity_mps := Vector3.ZERO
var _has_sample := false
var _last_sample_anchor_position := Vector3.ZERO
var _last_sample_local_offset := Vector3.ZERO


func get_target_id() -> StringName:
	return target_id


func is_eligible() -> bool:
	return eligible


func has_stable_target_identity() -> bool:
	return target_id != &""


## True while this anchor may be sampled: authored eligibility is still in
## effect and no explicit invalidation was requested (AC 6).
func is_grapple_anchor_valid() -> bool:
	return eligible and not _anchor_explicitly_invalidated


## Stateful targets invalidate their anchor explicitly (AC 6). The next sample
## reports `TARGET_INVALIDATED`; the player-side sampler commits the terminal.
func invalidate_grapple_anchor() -> void:
	_anchor_explicitly_invalidated = true


## Explicit supplied anchor velocity (Task 2.3): target-owned runtime state for
## bodies that know their own velocity. When supplied, sampling reports it
## instead of the finite difference. Never mutates shared definitions.
func supply_anchor_velocity(velocity_mps: Vector3) -> void:
	if not velocity_mps.is_finite():
		return
	_supplied_anchor_velocity_mps = velocity_mps
	_has_supplied_anchor_velocity = true


func clear_supplied_anchor_velocity() -> void:
	_has_supplied_anchor_velocity = false
	_supplied_anchor_velocity_mps = Vector3.ZERO


## Query-only anchor sampling (Task 2.2). Resolves
## `target_global_transform * target_local_hit_offset`, reports the anchor
## velocity (supplied, else the finite difference of sampled anchor positions
## over `delta_seconds`), and returns typed invalidation/scope reasons. The
## target never touches player state (AC 2).
##
## `target_local_hit_offset` is expressed in the anchor body's local space (the
## direct parent of this component - the collider the seed was taken against),
## and `initial_anchor_world_position` is the accepted hit position used as the
## frozen world anchor for `STATIC` targets.
func sample_anchor_state(
	target_local_hit_offset: Vector3,
	delta_seconds: float,
	initial_anchor_world_position: Vector3
) -> GrappleAnchorState:
	var response := build_response()
	var scope := encounter_scope_identity
	if not is_grapple_anchor_valid():
		return GrappleAnchorState.invalid(
			initial_anchor_world_position,
			GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED,
			scope,
			response
		)
	var anchor_world_position := initial_anchor_world_position
	var target_velocity := Vector3.ZERO
	if anchor_mode == GrappleTargetResponse.AnchorMode.MOVING:
		anchor_world_position = _anchor_transform() * target_local_hit_offset
		if _has_supplied_anchor_velocity:
			target_velocity = _supplied_anchor_velocity_mps
		elif (
			_has_sample
			and delta_seconds > 0.0
			and target_local_hit_offset.is_equal_approx(_last_sample_local_offset)
		):
			target_velocity = (
				anchor_world_position - _last_sample_anchor_position
			) / delta_seconds
	# STATIC mode keeps the frozen world anchor (the initial sample) and zero
	# velocity - the built-in static response Story 1.7 resolved against.
	_last_sample_anchor_position = anchor_world_position
	_last_sample_local_offset = target_local_hit_offset
	_has_sample = true
	return GrappleAnchorState.new(
		anchor_world_position,
		target_velocity,
		true,
		GrappleAnchorState.InvalidationReason.NONE,
		scope,
		response
	)


## The anchor body's transform: the direct parent this component was authored
## against (the collider the seed's local offset was computed from), with the
## component's own transform as the detached fallback.
func _anchor_transform() -> Transform3D:
	var parent := get_parent_node_3d()
	if parent != null:
		return parent.global_transform
	return global_transform


## Bounded typed response snapshot of this target's authored values. Query-only:
## it reads state and performs no side effects.
func build_response() -> GrappleTargetResponse:
	var response := GrappleTargetResponse.new(
		eligible,
		anchor_mode,
		pull_multiplier,
		directional_adjustment,
		instability,
		hazard_response
	)
	assert(response.is_finite(), "Grappleable3D responses must stay bounded and finite")
	return response


## All direct children named `Grappleable` typed `Grappleable3D` on the blocking
## collider. Scene-tree order is preserved here for reporting only; duplicate
## normalization and selection are order-independent (see `GrappleTargetResolver`).
static func find_explicit_grappleables(collider: Object) -> Array[Grappleable3D]:
	var found: Array[Grappleable3D] = []
	if collider == null or not is_instance_valid(collider) or not collider is Node:
		return found
	for child in (collider as Node).get_children():
		if child is Grappleable3D and child.name == COMPONENT_NODE_NAME:
			found.append(child as Grappleable3D)
	return found
