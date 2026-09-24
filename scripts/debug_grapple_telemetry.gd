extends CanvasLayer

## Development-only grapple telemetry. Toggle with F3 while running the game.
@export var start_visible := true
@export var refresh_interval := 0.05

var player: Node
var panel: PanelContainer
var label: Label
var overlay_visible := true
var refresh_timer := 0.0


func _ready() -> void:
	player = get_parent()
	overlay_visible = start_visible
	_build_overlay()
	panel.visible = overlay_visible
	call_deferred("_update_overlay")


func _process(delta: float) -> void:
	if not overlay_visible:
		return

	refresh_timer += delta
	if refresh_timer < refresh_interval:
		return

	refresh_timer = 0.0
	_update_overlay()


func _unhandled_input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return

	var key_event := event as InputEventKey
	if not key_event.pressed or key_event.echo or key_event.keycode != KEY_F3:
		return

	overlay_visible = not overlay_visible
	panel.visible = overlay_visible
	get_viewport().set_input_as_handled()


func _build_overlay() -> void:
	panel = PanelContainer.new()
	panel.position = Vector2(16.0, 16.0)
	panel.custom_minimum_size = Vector2(430.0, 0.0)
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE

	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.02, 0.03, 0.05, 0.9)
	panel_style.border_color = Color(0.15, 0.8, 1.0, 0.8)
	panel_style.set_border_width_all(1)
	panel_style.set_corner_radius_all(4)
	panel_style.content_margin_left = 12.0
	panel_style.content_margin_top = 10.0
	panel_style.content_margin_right = 12.0
	panel_style.content_margin_bottom = 10.0
	panel.add_theme_stylebox_override("panel", panel_style)
	add_child(panel)

	label = Label.new()
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.86, 0.96, 1.0))
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	panel.add_child(label)


func _update_overlay() -> void:
	if not is_instance_valid(player) or not player.has_method("get_grapple_telemetry"):
		return

	var telemetry: Dictionary = player.get_grapple_telemetry()
	var active: bool = telemetry["active"]
	var velocity: Vector3 = telemetry["velocity"]
	var state := "ACTIVE" if active else "INACTIVE"
	var cap_state := "YES" if telemetry["cap_reached"] else "NO"
	var wall_gate := "PASS" if telemetry["wall_stick_speed_gate"] else "BLOCKED"

	var lines := PackedStringArray([
		"GRAPPLE DEBUG  [F3 toggle]",
		"State: %s    Target valid: %s" % [state, telemetry["target_valid"]],
		"Time: %s s    Distance: %s m" % [
			_format_number(telemetry["elapsed"]),
			_format_number(telemetry["target_distance"])
		],
		"Acceleration: %s m/s^2" % _format_number(telemetry["acceleration"]),
		"Profile: %s -> %s m/s^2    Jerk: %s m/s^3" % [
			_format_number(telemetry["initial_acceleration"]),
			_format_number(telemetry["min_acceleration"]),
			_format_number(telemetry["jerk"])
		],
		"Speed: %s / %s m/s    Cap reached: %s" % [
			_format_number(telemetry["speed"]),
			_format_number(telemetry["max_velocity"]),
			cap_state
		],
		"Pull speed: %s m/s" % _format_number(telemetry["pull_speed"]),
		"Velocity: (%s, %s, %s)" % [
			_format_number(velocity.x),
			_format_number(velocity.y),
			_format_number(velocity.z)
		],
		"Floor: %s    Wall run: %s    Wall stick: %s" % [
			telemetry["on_floor"],
			telemetry["wall_running"],
			telemetry["wall_sticking"]
		],
		"Wall-stick speed gate: %s (%s)" % [wall_gate, telemetry["wall_stick_speed_gate_reason"]],
	])
	lines.append_array(_targeting_lines(telemetry))

	label.text = "\n".join(lines)


## Presentation-only formatting of the authoritative targeting diagnostics. The
## overlay never computes gameplay facts and never queries physics.
func _targeting_lines(telemetry: Dictionary) -> PackedStringArray:
	var targeting_state := "accepted" if telemetry["targeting_valid"] else String(telemetry["targeting_rejection_id"])
	var target_identity := String(telemetry["target_identity"])
	if target_identity.is_empty():
		target_identity = "(default geometry)"
	return PackedStringArray([
		"Targeting: %s    step %s    queries %s" % [
			targeting_state,
			telemetry["targeting_physics_step"],
			telemetry["targeting_query_count"],
		],
		"Target id: %s    range fraction: %s / max %s m" % [
			target_identity,
			_format_number(telemetry["range_fraction"]),
			_format_number(telemetry["max_grapple_length_m"]),
		],
	])


func _format_number(value: float) -> String:
	return String.num(value, 2)
