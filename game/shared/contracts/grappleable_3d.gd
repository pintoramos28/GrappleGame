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


func get_target_id() -> StringName:
	return target_id


func is_eligible() -> bool:
	return eligible


func has_stable_target_identity() -> bool:
	return target_id != &""


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
