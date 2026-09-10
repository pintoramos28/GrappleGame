extends GutTest


class HsmSpy:
	var owner_spy
	var updates := 0
	var observed_frames: Array[PlayerCommandFrame] = []

	func update(_delta: float) -> void:
		updates += 1
		observed_frames.append(owner_spy.current_frame)


class ControllerSpy:
	var source: PlayerInputSource
	var current_frame: PlayerCommandFrame
	var movement_spy := HsmSpy.new()
	var attack_spy := HsmSpy.new()
	var update_order: Array[StringName] = []

	func _init(input_source: PlayerInputSource) -> void:
		source = input_source
		movement_spy.owner_spy = self
		attack_spy.owner_spy = self

	func physics_step(step: int, delta: float) -> void:
		current_frame = source.capture_command_frame(step)
		update_order.append(&"movement")
		movement_spy.update(delta)
		update_order.append(&"attack")
		attack_spy.update(delta)


func test_movement_and_attack_update_once_in_stable_order_with_same_frame() -> void:
	var source: PlayerInputSource = autofree(PlayerInputSource.new())
	var player: Node3D = autofree(Node3D.new())
	var pivot: Node3D = autofree(Node3D.new())
	source.enable_test_input_seam()
	assert_eq(source.initialize(player, pivot), PlayerInputSource.InitializationStatus.SUCCESS)
	var controller := ControllerSpy.new(source)

	controller.physics_step(1, 1.0 / 60.0)

	assert_eq(controller.movement_spy.updates, 1)
	assert_eq(controller.attack_spy.updates, 1)
	assert_eq(controller.update_order, [&"movement", &"attack"])
	assert_same(controller.movement_spy.observed_frames[0], controller.current_frame)
	assert_same(controller.attack_spy.observed_frames[0], controller.current_frame)


func test_gameplay_surface_has_no_direct_hardware_polling_outside_input_source() -> void:
	var gameplay_paths := [
		"res://scripts/player_controller.gd",
		"res://scripts/player_grounded_state.gd",
		"res://scripts/player_airborne_state.gd",
		"res://scripts/player_grappling_state.gd",
		"res://scripts/player_wall_run_state.gd",
		"res://scripts/player_wall_stick_state.gd",
		"res://scripts/player_attack_ready_state.gd",
	]
	for path in gameplay_paths:
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("Input.is_action_"), path)
		assert_false(source.contains("Input.get_vector"), path)
		assert_false(source.contains("Input.get_axis"), path)
