class_name GrappleTargetResponse
extends RefCounted


## Immutable bounded grapple target response (architecture "Grapple target
## contract"). Exceptional targets author typed response fields on
## `Grappleable3D`; ordinary collision geometry receives `static_default()`.
##
## Runtime anchor modification creates target-owned runtime response state on the
## `Grappleable3D` component and never mutates shared definitions.

enum AnchorMode {
	STATIC,
	MOVING,
}

enum HazardResponse {
	NONE,
	DAMAGE_ON_ATTACH,
	DAMAGE_WHILE_ATTACHED,
}


const MAX_PULL_MULTIPLIER := 4.0
const MAX_INSTABILITY := 1.0


static var _static_default: GrappleTargetResponse


var eligible: bool:
	get:
		return _eligible

var anchor_mode: AnchorMode:
	get:
		return _anchor_mode

var pull_multiplier: float:
	get:
		return _pull_multiplier

var directional_adjustment: Vector3:
	get:
		return _directional_adjustment

var instability: float:
	get:
		return _instability

var hazard_response: HazardResponse:
	get:
		return _hazard_response


var _eligible: bool
var _anchor_mode: AnchorMode
var _pull_multiplier: float
var _directional_adjustment: Vector3
var _instability: float
var _hazard_response: HazardResponse


func _init(
	is_eligible: bool = true,
	response_anchor_mode: AnchorMode = AnchorMode.STATIC,
	response_pull_multiplier: float = 1.0,
	response_directional_adjustment: Vector3 = Vector3.ZERO,
	response_instability: float = 0.0,
	response_hazard_response: HazardResponse = HazardResponse.NONE
) -> void:
	_eligible = is_eligible
	_anchor_mode = response_anchor_mode
	_pull_multiplier = _bounded(
		response_pull_multiplier,
		1.0,
		0.0,
		MAX_PULL_MULTIPLIER
	)
	_directional_adjustment = (
		response_directional_adjustment
		if response_directional_adjustment.is_finite()
		else Vector3.ZERO
	)
	_instability = _bounded(response_instability, 0.0, 0.0, MAX_INSTABILITY)
	_hazard_response = response_hazard_response


## Built-in static response for ordinary collision geometry (AC 2). Shared and
## immutable; GDScript consts cannot construct RefCounted instances, so the
## constant is exposed as a lazily built shared instance.
static func static_default() -> GrappleTargetResponse:
	if _static_default == null:
		_static_default = GrappleTargetResponse.new()
	return _static_default


func is_finite() -> bool:
	return _directional_adjustment.is_finite()


func is_value_only() -> bool:
	return true


func get_stable_content_key() -> String:
	return "%d|%d|%d|%d,%d,%d|%d|%d" % [
		1 if _eligible else 0,
		int(_anchor_mode),
		_quantize(_pull_multiplier),
		_quantize(_directional_adjustment.x),
		_quantize(_directional_adjustment.y),
		_quantize(_directional_adjustment.z),
		_quantize(_instability),
		int(_hazard_response),
	]


static func _bounded(value: float, fallback: float, low: float, high: float) -> float:
	if is_nan(value) or is_inf(value):
		return fallback
	return clampf(value, low, high)


static func _quantize(value: float) -> int:
	if is_nan(value) or is_inf(value):
		return 0
	return roundi(value * 1000.0)
