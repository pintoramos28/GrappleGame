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
	if not is_instance_valid(player):
		return
	# Every member the overlay touches is guarded, so a player without these
	# surfaces degrades to an empty overlay instead of erroring each refresh.
	for required_method in [
		&"get_grapple_attachment_diagnostic_snapshot",
		&"get_grapple_targeting_diagnostic_snapshot",
	]:
		if not player.has_method(required_method):
			return

	# Typed read-only snapshots only (Story 1.7 Task 5.3): the overlay formats
	# already-resolved facts and never computes gameplay, queries physics, or
	# recalculates constraint resolution.
	var attachment: GrappleAttachmentDiagnosticSnapshot = (
		player.get_grapple_attachment_diagnostic_snapshot()
	)
	var targeting: GrappleTargetingDiagnosticSnapshot = (
		player.get_grapple_targeting_diagnostic_snapshot()
	)
	var lines := PackedStringArray(["GRAPPLE DEBUG  [F3 toggle]"])
	lines.append_array(_attachment_lines(attachment))
	lines.append_array(_traversal_lines())
	lines.append_array(_targeting_lines(targeting))
	label.text = "\n".join(lines)


func _attachment_lines(
	attachment: GrappleAttachmentDiagnosticSnapshot
) -> PackedStringArray:
	if attachment == null:
		return PackedStringArray(["Attachment: none"])
	var state := "ACTIVE" if attachment.is_active else "ENDED"
	var terminal := String(attachment.terminal_reason_id)
	if attachment.is_active:
		terminal = "-"
	var boundary := "none"
	if attachment.boundary_correction_applied:
		boundary = "clipped %s m/s outward" % _format_number(attachment.boundary_correction_mps)
	if attachment.boundary_carry_applied_mps > 0.0:
		boundary += "    carry %s m/s" % _format_number(attachment.boundary_carry_applied_mps)
	if attachment.boundary_carry_refused_mps > 0.0:
		boundary += "    carry REFUSED %s m/s" % _format_number(
			attachment.boundary_carry_refused_mps
		)
	# Both scalars come from the snapshot: the overlay formats facts and never
	# derives a gameplay comparison of its own.
	var speed := attachment.committed_speed_mps
	var cap_state := "YES" if attachment.speed_cap_reached else "NO"
	return PackedStringArray([
		"Attachment: %s    %s    terminal: %s" % [
			String(attachment.attachment_identity),
			state,
			terminal,
		],
		"Anchor: (%s, %s, %s)" % [
			_format_number(attachment.anchor_world_position.x),
			_format_number(attachment.anchor_world_position.y),
			_format_number(attachment.anchor_world_position.z),
		],
		"Anchor status: %s    Target velocity: (%s, %s, %s) m/s" % [
			String(attachment.anchor_status_id),
			_format_number(attachment.target_velocity_mps.x),
			_format_number(attachment.target_velocity_mps.y),
			_format_number(attachment.target_velocity_mps.z),
		],
		"Time: %s s    Distance: %s / %s m    range %s" % [
			_format_number(attachment.elapsed_seconds),
			_format_number(attachment.current_distance_m),
			_format_number(attachment.maximum_distance_m),
			_format_number(attachment.range_fraction),
		],
		"Acceleration: %s m/s^2    Speed cap: %s m/s" % [
			_format_number(attachment.submitted_acceleration_mps2),
			_format_number(attachment.resolved_maximum_speed_mps),
		],
		"Pull dir: (%s, %s, %s)" % [
			_format_number(attachment.pull_direction.x),
			_format_number(attachment.pull_direction.y),
			_format_number(attachment.pull_direction.z),
		],
		"Speed: %s / %s m/s    Cap reached: %s" % [
			_format_number(speed),
			_format_number(attachment.resolved_maximum_speed_mps),
			cap_state,
		],
		"Velocity: (%s, %s, %s)" % [
			_format_number(attachment.committed_velocity_mps.x),
			_format_number(attachment.committed_velocity_mps.y),
			_format_number(attachment.committed_velocity_mps.z),
		],
		"Resolved radial: %s m/s    Resolved tangential: %s m/s" % [
			_format_number(attachment.resolved_radial_velocity_mps),
			_format_number(attachment.resolved_tangential_velocity_mps),
		],
		"Boundary: %s    (tolerance %s m)" % [
			boundary,
			_format_number(attachment.boundary_positional_tolerance_m),
		],
		"Distance at boundary resolution: %s m" % [
			_format_number(attachment.distance_at_resolution_m),
		],
	])


func _traversal_lines() -> PackedStringArray:
	if not _exposes_traversal_facts():
		return PackedStringArray(["Traversal: (unavailable)"])
	var wall_gate := "PASS" if player.is_wall_stick_speed_gate_open() else "BLOCKED"
	return PackedStringArray([
		"Floor: %s    Wall run: %s    Wall stick: %s" % [
			player.has_ground_contact(),
			player.is_wall_running,
			player.is_wall_sticking,
		],
		"Wall-stick speed gate: %s (%s)" % [
			wall_gate,
			String(player.get_wall_stick_speed_gate_reason_id()),
		],
	])


## True only when the player exposes every fact the traversal section reads.
func _exposes_traversal_facts() -> bool:
	return (
		player.has_method("has_ground_contact")
		and player.has_method("is_wall_stick_speed_gate_open")
		and player.has_method("get_wall_stick_speed_gate_reason_id")
		and "is_wall_running" in player
		and "is_wall_sticking" in player
	)


## Presentation-only formatting of the authoritative targeting diagnostics.
func _targeting_lines(
	targeting: GrappleTargetingDiagnosticSnapshot
) -> PackedStringArray:
	if targeting == null:
		return PackedStringArray(["Targeting: no result"])
	var targeting_state := "accepted" if targeting.is_accepted else String(targeting.rejection_id)
	var target_identity := String(targeting.target_identity)
	if target_identity.is_empty():
		target_identity = "(default geometry)"
	return PackedStringArray([
		"Targeting: %s    step %s    queries %s" % [
			targeting_state,
			targeting.source_physics_step,
			targeting.query_count,
		],
		"Target id: %s    range fraction: %s / max %s m" % [
			target_identity,
			_format_number(targeting.range_fraction),
			_format_number(targeting.max_grapple_length_m),
		],
	])


func _format_number(value: float) -> String:
	return String.num(value, 2)
