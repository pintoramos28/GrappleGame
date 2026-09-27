extends StaticBody3D

## Bounded target-owned motion. The player consumes the published anchor facts;
## this node never touches movement commands, the player, or the grapple definition.
@export var excursion_m := 1.5
@export var cycle_radians_per_second := 0.8

var _origin: Vector3
var _elapsed_seconds := 0.0
@onready var _grappleable: Grappleable3D = $Grappleable


func _ready() -> void:
	_origin = position


func _physics_process(delta: float) -> void:
	_elapsed_seconds += delta
	var previous := position
	position = _origin + Vector3(sin(_elapsed_seconds * cycle_radians_per_second) * excursion_m, 0.0, 0.0)
	_grappleable.supply_anchor_velocity((position - previous) / delta)


func request_anchor_invalidation() -> void:
	_grappleable.invalidate_grapple_anchor()
