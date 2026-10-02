@tool
extends McpTestSuite
## Editor-authored schema checks only. Non-@tool gameplay is placeholder scope;
## canonical behavior is recursive GUT plus a fresh MCP-launched live game.

func suite_name() -> String:
	return "wall_stick"

func test_authored_stick_definition_is_independent() -> void:
	var definition = load("res://game/player/locomotion/wall_stick/definitions/wall_stick_definition.tres")
	assert_true(definition != null)
	if definition == null:
		return
	assert_true(is_equal_approx(float(definition.get("maximum_entry_speed_mps")), 100.0))
	assert_true(is_equal_approx(float(definition.get("jump_up_speed_mps")), 5.5))
	assert_true(is_equal_approx(float(definition.get("jump_away_speed_mps")), 8.0))
	assert_true(_code("res://scenes/player.tscn").contains("wall_stick_definition = ExtResource(\"28_wall_stick\")"))

func test_public_contact_schema_remains_value_only() -> void:
	var source := _code("res://game/shared/physics/contact_frame.gd")
	assert_true(source.contains("var wall_support: ContactCandidate:"))
	assert_true(source.contains("var wall_point_velocity: Vector3:"))
	assert_true(not source.contains("WeakRef"))
	assert_true(not source.contains("CollisionObject3D"))

func test_hold_schema_keeps_single_commit_and_forward_fact() -> void:
	var motor := _code("res://game/player/motor/player_motor.gd")
	assert_true(motor.count("_body.move_and_slide()") == 1)
	assert_true(motor.count("_body.velocity =") == 1)
	assert_true(not motor.contains("_body.global_position ="))
	assert_true(_code("res://game/player/input/player_command_frame.gd").contains("var move_forward_held: bool:"))
	var result := _code("res://game/player/motor/player_motor_commit_result.gd")
	assert_true(result.contains("var hold_carry_blocked: bool:"))
	assert_true(result.contains("var hold_position_error_m: float:"))

func test_reanchor_schema_has_independent_binding_revision_and_shared_active_visuals() -> void:
	var binding := _code("res://game/player/abilities/grapple/grapple_surface_binding.gd")
	assert_true(binding.contains("var _body_ref: WeakRef"))
	assert_true(binding.contains("var _local_point: Vector3"))
	assert_true(not binding.contains("intersect_ray"))
	assert_true(not binding.contains("WallStickAttachment\n"))
	assert_true(_code("res://game/player/abilities/grapple/grapple_attachment.gd").contains("var anchor_revision: int:"))
	assert_true(_code("res://game/player/abilities/grapple/grapple_attachment_diagnostic_snapshot.gd").contains("var anchor_revision: int:"))
	var controller := _code("res://scripts/player_controller.gd")
	assert_true(controller.contains("prepare_surface_reanchor(binding"))
	assert_true(controller.contains("_update_grapple_visual(snapshot)"))
	assert_true(controller.contains("_update_grapple_marker(snapshot)"))
	assert_true(controller.contains("if was_hidden or revision_changed:"))
	assert_true(_code("res://game/player/abilities/grapple/presentation/grapple_target_marker.gd").contains("snapshot.anchor_world_position if attached"))

func _code(path: String) -> String:
	var lines := PackedStringArray()
	for line in FileAccess.get_file_as_string(path).split("\n"):
		if not line.strip_edges().begins_with("#"):
			lines.append(line)
	return "\n".join(lines)
