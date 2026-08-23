@tool
extends Node3D

const PLAYER_SCENE := preload("res://scenes/player.tscn")

const GENERATED_ROOT := "Generated"
const START_POSITION := Vector3(0.0, 0.1, 24.0)

var bark_material: StandardMaterial3D
var leaf_material: StandardMaterial3D
var platform_material: StandardMaterial3D
var root_material: StandardMaterial3D
var anchor_material: StandardMaterial3D
var sign_material: StandardMaterial3D
var goal_material: StandardMaterial3D
var floor_material: StandardMaterial3D


func _ready() -> void:
	call_deferred("_rebuild_level")


func _rebuild_level() -> void:
	var previous := get_node_or_null(GENERATED_ROOT)
	if previous:
		previous.queue_free()
		await previous.tree_exited

	_create_materials()

	var generated := Node3D.new()
	generated.name = GENERATED_ROOT
	add_child(generated)

	_build_world(generated)
	_build_tutorial_route(generated)

	if Engine.is_editor_hint():
		_add_preview_camera(generated)
	else:
		_add_player(generated)


func _build_world(parent: Node3D) -> void:
	_add_lighting(parent)
	_add_box(parent, "ClearingFloor", Vector3(0.0, -0.1, 0.0), Vector3(90.0, 0.2, 90.0), floor_material)

	_add_cylinder(parent, "SkyTreeTrunk", Vector3(0.0, 40.0, 0.0), 4.0, 80.0, bark_material)
	_add_cylinder(parent, "CanopyTrunkCap", Vector3(0.0, 81.0, 0.0), 4.4, 2.0, bark_material)

	_add_root(parent, "RootRampNorth", 0.0, 13.0)
	_add_root(parent, "RootRampEast", PI * 0.5, 11.0)
	_add_root(parent, "RootRampWest", -PI * 0.55, 12.0)

	_add_leaf_cluster(parent, "LowerLeaves", Vector3(-6.0, 18.0, 2.0), Vector3(7.0, 3.0, 6.0))
	_add_leaf_cluster(parent, "MiddleLeaves", Vector3(7.0, 42.0, -4.0), Vector3(8.0, 4.0, 6.5))
	_add_leaf_cluster(parent, "UpperLeaves", Vector3(-3.0, 66.0, 5.0), Vector3(9.0, 4.5, 7.0))

	_add_sign(
		parent,
		"StartSign",
		Vector3(5.0, 2.4, 18.5),
		"GRAPPLE TUTORIAL\nAim at amber knots\nHold right mouse to pull",
		0.0
	)


func _build_tutorial_route(parent: Node3D) -> void:
	var stages := [
		{
			"name": "FirstPull",
			"height": 5.0,
			"angle": PI * 0.5,
			"length": 12.0,
			"width": 3.3,
			"pad_radius": 3.2,
			"lesson": "1  PULL\nHold grapple until\nyou reach the branch",
		},
		{
			"name": "ReleaseLaunch",
			"height": 12.0,
			"angle": PI * 0.12,
			"length": 12.5,
			"width": 3.0,
			"pad_radius": 3.0,
			"lesson": "2  RELEASE\nLet go before impact\nto keep momentum",
		},
		{
			"name": "SwingAround",
			"height": 20.0,
			"angle": -PI * 0.34,
			"length": 13.0,
			"width": 2.8,
			"pad_radius": 3.0,
			"lesson": "3  STEER\nUse WASD while pulling\nto arc around the trunk",
		},
		{
			"name": "VerticalCatch",
			"height": 29.0,
			"angle": -PI * 0.88,
			"length": 12.0,
			"width": 2.7,
			"pad_radius": 2.8,
			"lesson": "4  CATCH\nLook up and grab the\nnext knot before falling",
		},
		{
			"name": "WallStickPractice",
			"height": 39.0,
			"angle": PI * 0.78,
			"length": 14.0,
			"width": 3.0,
			"pad_radius": 3.0,
			"lesson": "5  SIDE INPUT\nHold a direction near\nthe trunk to stick/run",
		},
		{
			"name": "LongGap",
			"height": 50.0,
			"angle": PI * 0.28,
			"length": 15.0,
			"width": 2.8,
			"pad_radius": 3.1,
			"lesson": "6  LONG GAP\nStart the pull early\nthen release into space",
		},
		{
			"name": "CanopyEntry",
			"height": 62.0,
			"angle": -PI * 0.18,
			"length": 13.0,
			"width": 3.4,
			"pad_radius": 3.4,
			"lesson": "7  COMMIT\nChain grapple points\nwithout landing low",
		},
	]

	for stage in stages:
		_add_stage(parent, stage)

	_add_canopy_goal(parent)


func _add_stage(parent: Node3D, stage: Dictionary) -> void:
	var angle: float = stage["angle"]
	var height: float = stage["height"]
	var length: float = stage["length"]
	var width: float = stage["width"]
	var pad_radius: float = stage["pad_radius"]
	var stage_name: String = stage["name"]
	var direction := Vector3(cos(angle), 0.0, sin(angle)).normalized()
	var branch_center := direction * (4.0 + length * 0.5)
	var branch_position := Vector3(branch_center.x, height, branch_center.z)
	var pad_position := direction * (4.0 + length + pad_radius * 0.35)
	var anchor_position := direction * (4.0 + length * 0.72)

	_add_box(
		parent,
		"%sBranch" % stage_name,
		branch_position,
		Vector3(length, 0.8, width),
		platform_material,
		Vector3(0.0, -angle, 0.0)
	)

	_add_cylinder(
		parent,
		"%sLandingPad" % stage_name,
		Vector3(pad_position.x, height + 0.15, pad_position.z),
		pad_radius,
		0.55,
		leaf_material
	)

	_add_anchor(
		parent,
		"%sGrappleKnot" % stage_name,
		Vector3(anchor_position.x, height + 1.6, anchor_position.z),
		0.55
	)

	_add_anchor(
		parent,
		"%sTrunkKnot" % stage_name,
		Vector3(direction.x * 4.35, height + 4.4, direction.z * 4.35),
		0.45
	)

	_add_sign(
		parent,
		"%sSign" % stage_name,
		Vector3(pad_position.x, height + 2.0, pad_position.z),
		stage["lesson"],
		angle + PI
	)


func _add_canopy_goal(parent: Node3D) -> void:
	_add_cylinder(parent, "CanopySummit", Vector3(0.0, 74.0, 0.0), 8.0, 0.7, leaf_material)
	_add_cylinder(parent, "SummitWoodDeck", Vector3(0.0, 74.45, 0.0), 5.5, 0.35, platform_material)
	_add_anchor(parent, "FinalHighKnot", Vector3(0.0, 71.0, -4.5), 0.7)
	_add_anchor(parent, "SummitKnot", Vector3(2.5, 78.0, -2.0), 0.8)

	_add_sign(
		parent,
		"GoalSign",
		Vector3(0.0, 76.2, -3.7),
		"TUTORIAL COMPLETE\nYou can now climb,\nswing, and chain grapples",
		0.0
	)

	var ring_mesh := TorusMesh.new()
	ring_mesh.inner_radius = 1.2
	ring_mesh.outer_radius = 1.55

	var ring := MeshInstance3D.new()
	ring.name = "SummitGoalRing"
	ring.mesh = ring_mesh
	ring.material_override = goal_material
	ring.position = Vector3(0.0, 77.8, -1.0)
	ring.rotation_degrees = Vector3(90.0, 0.0, 0.0)
	parent.add_child(ring)


func _add_root(parent: Node3D, root_name: String, angle: float, length: float) -> void:
	var direction := Vector3(cos(angle), 0.0, sin(angle)).normalized()
	var center := direction * (4.0 + length * 0.5)
	_add_box(
		parent,
		root_name,
		Vector3(center.x, 0.45, center.z),
		Vector3(length, 0.8, 2.4),
		root_material,
		Vector3(0.0, -angle, 0.0)
	)


func _add_leaf_cluster(parent: Node3D, cluster_name: String, cluster_position: Vector3, size: Vector3) -> void:
	_add_box(parent, "%sA" % cluster_name, cluster_position, size, leaf_material, Vector3(0.0, 0.35, 0.0))
	_add_box(
		parent,
		"%sB" % cluster_name,
		cluster_position + Vector3(2.0, 1.0, -1.0),
		size * Vector3(0.75, 0.85, 0.75),
		leaf_material,
		Vector3(0.0, -0.45, 0.0)
	)


func _add_player(parent: Node3D) -> void:
	var player := PLAYER_SCENE.instantiate()
	player.name = "Player"
	parent.add_child(player)
	player.global_position = START_POSITION
	player.set("grapple_length", 35.0)
	player.set("grapple_gravity_scale", 0.65)


func _add_preview_camera(parent: Node3D) -> void:
	var camera := Camera3D.new()
	camera.name = "PreviewCamera"
	camera.current = true
	camera.position = Vector3(23.0, 28.0, 38.0)
	camera.rotation_degrees = Vector3(-30.0, 32.0, 0.0)
	camera.fov = 55.0
	parent.add_child(camera)


func _add_box(
	parent: Node3D,
	body_name: String,
	body_position: Vector3,
	size: Vector3,
	material: Material,
	body_rotation: Vector3 = Vector3.ZERO
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.position = body_position
	body.rotation = body_rotation
	parent.add_child(body)

	var mesh := BoxMesh.new()
	mesh.size = size

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var shape := BoxShape3D.new()
	shape.size = size

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	body.add_child(collision)

	return body


func _add_cylinder(
	parent: Node3D,
	body_name: String,
	body_position: Vector3,
	radius: float,
	height: float,
	material: Material
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.position = body_position
	parent.add_child(body)

	var mesh := CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 24

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	mesh_instance.mesh = mesh
	mesh_instance.material_override = material
	body.add_child(mesh_instance)

	var shape := CylinderShape3D.new()
	shape.radius = radius
	shape.height = height

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	body.add_child(collision)

	return body


func _add_anchor(parent: Node3D, body_name: String, body_position: Vector3, radius: float) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.name = body_name
	body.position = body_position
	parent.add_child(body)

	var mesh := SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 24
	mesh.rings = 12

	var mesh_instance := MeshInstance3D.new()
	mesh_instance.name = "Mesh"
	mesh_instance.mesh = mesh
	mesh_instance.material_override = anchor_material
	body.add_child(mesh_instance)

	var shape := SphereShape3D.new()
	shape.radius = radius

	var collision := CollisionShape3D.new()
	collision.name = "CollisionShape3D"
	collision.shape = shape
	body.add_child(collision)

	var light := OmniLight3D.new()
	light.name = "Glow"
	light.light_color = Color(1.0, 0.78, 0.16)
	light.light_energy = 0.7
	light.omni_range = 4.0
	body.add_child(light)

	return body


func _add_sign(parent: Node3D, sign_name: String, sign_position: Vector3, text: String, yaw: float) -> void:
	var holder := Node3D.new()
	holder.name = sign_name
	holder.position = sign_position
	holder.rotation.y = yaw
	parent.add_child(holder)

	_add_box(holder, "Board", Vector3(0.0, 0.0, 0.08), Vector3(5.8, 1.9, 0.16), sign_material)

	var label := Label3D.new()
	label.name = "Text"
	label.text = text
	label.font_size = 44
	label.pixel_size = 0.012
	label.modulate = Color(0.96, 0.98, 0.92)
	label.outline_size = 10
	label.outline_modulate = Color(0.05, 0.04, 0.03)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.position = Vector3(0.0, 0.0, 0.19)
	holder.add_child(label)


func _add_lighting(parent: Node3D) -> void:
	var sun := DirectionalLight3D.new()
	sun.name = "SunLight"
	sun.rotation_degrees = Vector3(-58.0, 35.0, 0.0)
	sun.light_energy = 2.6
	parent.add_child(sun)

	var sky_material := ProceduralSkyMaterial.new()
	sky_material.sky_top_color = Color(0.42, 0.7, 1.0)
	sky_material.sky_horizon_color = Color(0.82, 0.94, 1.0)
	sky_material.ground_bottom_color = Color(0.13, 0.2, 0.12)
	sky_material.ground_horizon_color = Color(0.38, 0.5, 0.42)

	var sky := Sky.new()
	sky.sky_material = sky_material

	var environment := Environment.new()
	environment.background_mode = Environment.BG_SKY
	environment.sky = sky
	environment.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	environment.ambient_light_energy = 0.7

	var world_environment := WorldEnvironment.new()
	world_environment.name = "WorldEnvironment"
	world_environment.environment = environment
	parent.add_child(world_environment)


func _create_materials() -> void:
	bark_material = _material("Bark", Color(0.34, 0.19, 0.1), Color(0.18, 0.09, 0.04))
	root_material = _material("Root", Color(0.26, 0.14, 0.08), Color(0.12, 0.06, 0.03))
	leaf_material = _material("Leaves", Color(0.16, 0.46, 0.2), Color(0.05, 0.16, 0.07))
	platform_material = _material("BranchPlatform", Color(0.44, 0.27, 0.13), Color(0.2, 0.1, 0.04))
	sign_material = _material("SignBoard", Color(0.12, 0.09, 0.06), Color(0.05, 0.035, 0.02))
	floor_material = _material("ForestFloor", Color(0.18, 0.32, 0.14), Color(0.08, 0.12, 0.05))
	anchor_material = _material(
		"GrappleAnchor",
		Color(1.0, 0.67, 0.11),
		Color(1.0, 0.55, 0.06),
		1.8
	)
	goal_material = _material("Goal", Color(0.28, 0.95, 1.0), Color(0.2, 0.85, 1.0), 1.6)


func _material(
	material_name: String,
	albedo: Color,
	emission: Color,
	emission_energy: float = 0.0
) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.resource_name = material_name
	material.albedo_color = albedo
	material.roughness = 0.75
	if emission_energy > 0.0:
		material.emission_enabled = true
		material.emission = emission
		material.emission_energy_multiplier = emission_energy
	return material
