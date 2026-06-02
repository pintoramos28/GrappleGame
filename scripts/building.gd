@tool
extends StaticBody3D

@export var building_size := Vector3(6.0, 12.0, 6.0):
	set(value):
		building_size = Vector3(
			maxf(value.x, 0.1),
			maxf(value.y, 0.1),
			maxf(value.z, 0.1)
		)
		_refresh_shape()

@onready var mesh_instance: MeshInstance3D = $MeshInstance3D
@onready var collision_shape: CollisionShape3D = $CollisionShape3D


func _ready() -> void:
	_ensure_unique_resources()
	_refresh_shape()


func _ensure_unique_resources() -> void:
	var box_mesh := mesh_instance.mesh as BoxMesh
	if box_mesh == null or not box_mesh.resource_local_to_scene:
		box_mesh = BoxMesh.new()
		box_mesh.resource_local_to_scene = true
		mesh_instance.mesh = box_mesh

	var box_shape := collision_shape.shape as BoxShape3D
	if box_shape == null or not box_shape.resource_local_to_scene:
		box_shape = BoxShape3D.new()
		box_shape.resource_local_to_scene = true
		collision_shape.shape = box_shape


func _refresh_shape() -> void:
	if not is_node_ready():
		return

	var box_mesh := mesh_instance.mesh as BoxMesh
	var box_shape := collision_shape.shape as BoxShape3D
	if box_mesh == null or box_shape == null:
		return

	box_mesh.size = building_size
	box_shape.size = building_size

	var center_offset := Vector3(0.0, building_size.y * 0.5, 0.0)
	mesh_instance.position = center_offset
	collision_shape.position = center_offset
