extends Area3D

## Completion is a committed physical arrival, independent of presentation.
signal route_completed

var is_complete := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node3D) -> void:
	if is_complete or not body is CharacterBody3D:
		return
	if not body.get_node_or_null(^"PlayerMotor") is PlayerMotor:
		return
	is_complete = true
	route_completed.emit()
