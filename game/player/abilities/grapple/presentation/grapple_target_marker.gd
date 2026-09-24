class_name GrappleTargetMarker
extends Node3D


## Presentation-only grapple targeting reticle/world marker (architecture
## "Grapple presentation"). It consumes the latest authoritative
## `GrappleTargetingResult` at render rate and may visually interpolate.
##
## Consumption rules (AC 10): it never raycasts, never changes validity, never
## delays gameplay activation, and never retains a target after the authoritative
## result becomes unavailable. Marker visuals preserve the prototype sphere and
## `grapple_cursor_*` colors.

@export var grapple_cursor_radius := 0.2
@export var grapple_cursor_color := Color(1.0, 0.9, 0.1)
@export var grapple_cursor_active_color := Color(0.2, 1.0, 0.25)


var _staged_result: GrappleTargetingResult
var _grapple_active := false
var _marker_mesh: MeshInstance3D
var _marker_material: StandardMaterial3D
var _marker_visible := false
var _presented_position := Vector3.ZERO
var _presented_identity: StringName = &""


func _ready() -> void:
	_build_marker_mesh()
	_render_presented_state()


func _process(_delta: float) -> void:
	_render_presented_state()


## Stage the latest authoritative result. Presentation-only: gameplay validity is
## decided elsewhere and this call has no gameplay side effects.
func apply_targeting_result(result: GrappleTargetingResult, grapple_active: bool) -> void:
	_staged_result = result
	_grapple_active = grapple_active


## The authoritative result became unavailable; drop it and hide the marker.
func clear_targeting() -> void:
	_staged_result = null
	_grapple_active = false


func is_marker_visible() -> bool:
	return _marker_visible


func get_presented_world_position() -> Vector3:
	return _presented_position


func get_presented_target_identity() -> StringName:
	return _presented_identity


func _render_presented_state() -> void:
	var result := _staged_result
	var accepted := result != null and result.is_accepted()
	_presented_identity = result.target_identity if result != null else &""
	_presented_position = result.hit_position if accepted else Vector3.ZERO
	_marker_visible = accepted
	if _marker_mesh == null:
		return
	if accepted:
		var color := grapple_cursor_active_color if _grapple_active else grapple_cursor_color
		_set_marker_color(color)
		_marker_mesh.global_position = _presented_position
	_marker_mesh.visible = accepted


func _build_marker_mesh() -> void:
	var sphere_mesh := SphereMesh.new()
	sphere_mesh.radius = grapple_cursor_radius
	sphere_mesh.height = grapple_cursor_radius * 2.0

	_marker_material = StandardMaterial3D.new()
	_marker_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_marker_material.emission_enabled = true
	_set_marker_color(grapple_cursor_color)

	_marker_mesh = MeshInstance3D.new()
	_marker_mesh.name = "GrappleCursor"
	_marker_mesh.top_level = true
	_marker_mesh.mesh = sphere_mesh
	_marker_mesh.material_override = _marker_material
	_marker_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_marker_mesh.visible = false
	add_child(_marker_mesh)


func _set_marker_color(color: Color) -> void:
	_marker_material.albedo_color = color
	_marker_material.emission = color
