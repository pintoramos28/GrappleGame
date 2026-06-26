class_name AttackArcVisual3D
extends Node3D

@export_group("Shape")
@export_range(0.05, 2.0, 0.01) var inner_radius := 0.35
@export_range(0.05, 3.0, 0.01) var outer_radius := 0.9
@export_range(20.0, 270.0, 1.0) var arc_angle_degrees := 130.0
@export_range(3, 48, 1) var segments := 20
@export var mesh_rotation_degrees := Vector3(0.0, 0.0, -25.0)

@export_group("Appearance")
@export var arc_color := Color(0.35, 0.95, 1.0, 0.85)
@export_range(0.0, 8.0, 0.1) var emission_energy := 2.0

@export_group("Animation")
@export_range(0.03, 1.0, 0.01) var default_duration := 0.16
@export var start_scale := Vector3(0.72, 0.72, 0.72)
@export var end_scale := Vector3(1.22, 1.22, 1.22)
@export var sweep_rotation_degrees := Vector3(0.0, 0.0, 32.0)

var _mesh_instance: MeshInstance3D
var _material: StandardMaterial3D
var _tween: Tween


func _ready() -> void:
	_material = StandardMaterial3D.new()
	_material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	_material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	_material.cull_mode = BaseMaterial3D.CULL_DISABLED
	_material.emission_enabled = true
	_material.no_depth_test = true

	_mesh_instance = MeshInstance3D.new()
	_mesh_instance.name = "ArcMesh"
	_mesh_instance.mesh = _build_arc_mesh()
	_mesh_instance.material_override = _material
	_mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	_mesh_instance.visible = false
	add_child(_mesh_instance)

	_set_alpha(0.0)


func play(duration := -1.0) -> void:
	if not is_inside_tree():
		return

	var play_duration := default_duration if duration <= 0.0 else duration
	if _tween:
		_tween.kill()

	_mesh_instance.visible = true
	_mesh_instance.scale = start_scale
	_mesh_instance.rotation_degrees = mesh_rotation_degrees
	_set_alpha(arc_color.a)

	_tween = create_tween()
	_tween.set_parallel(true)
	_tween.tween_property(_mesh_instance, "scale", end_scale, play_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_property(
		_mesh_instance,
		"rotation_degrees",
		mesh_rotation_degrees + sweep_rotation_degrees,
		play_duration
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_method(_set_alpha, arc_color.a, 0.0, play_duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	_tween.finished.connect(_hide)


func _hide() -> void:
	if _mesh_instance:
		_mesh_instance.visible = false


func _set_alpha(alpha: float) -> void:
	if not _material:
		return

	var color := arc_color
	color.a = alpha
	_material.albedo_color = color
	_material.emission = Color(arc_color.r, arc_color.g, arc_color.b, 1.0) * emission_energy


func _build_arc_mesh() -> ArrayMesh:
	var mesh := ArrayMesh.new()
	var vertices := PackedVector3Array()
	var normals := PackedVector3Array()
	var uvs := PackedVector2Array()
	var indices := PackedInt32Array()

	var half_angle := deg_to_rad(arc_angle_degrees) * 0.5
	for segment_index in range(segments + 1):
		var ratio := float(segment_index) / float(segments)
		var angle := lerpf(-half_angle, half_angle, ratio)
		var direction := Vector3(cos(angle), sin(angle), 0.0)

		vertices.append(direction * outer_radius)
		vertices.append(direction * inner_radius)
		normals.append(Vector3.BACK)
		normals.append(Vector3.BACK)
		uvs.append(Vector2(ratio, 0.0))
		uvs.append(Vector2(ratio, 1.0))

	for segment_index in range(segments):
		var outer_a := segment_index * 2
		var inner_a := outer_a + 1
		var outer_b := outer_a + 2
		var inner_b := outer_a + 3

		indices.append_array([outer_a, outer_b, inner_a, inner_a, outer_b, inner_b])

	var arrays := []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = vertices
	arrays[Mesh.ARRAY_NORMAL] = normals
	arrays[Mesh.ARRAY_TEX_UV] = uvs
	arrays[Mesh.ARRAY_INDEX] = indices
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
	return mesh
