extends GutTest

const FIXTURE := preload("res://tests/fixtures/wall_stick_reanchor_fixture.tscn")

func test_visible_reanchor_resets_once_then_continuous_follow_does_not_reset() -> void:
	var fixture := await _spawn(false)
	var marker := fixture.player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	var rope: MeshInstance3D = fixture.player.get("grapple_visual")
	assert_true(rope.visible)
	assert_true(marker.is_marker_visible())
	var rope_resets: int = fixture.player.get("grapple_visual_reset_count")
	var marker_resets := marker.interpolation_reset_count
	assert_eq(fixture.original_attachment.anchor_revision, 0)
	fixture.input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
	await _ticks(3)
	assert_true(bool(fixture.player.get("is_wall_sticking")))
	assert_eq(fixture.original_attachment.anchor_revision, 1)
	assert_eq(fixture.player.get("grapple_visual_reset_count"), rope_resets + 1)
	assert_eq(marker.interpolation_reset_count, marker_resets + 1)
	fixture.wall.set("motion_velocity", Vector3.RIGHT)
	await _ticks(8)
	assert_eq(fixture.player.get("grapple_visual_reset_count"), rope_resets + 1)
	assert_eq(marker.interpolation_reset_count, marker_resets + 1)
	assert_lte(fixture.maximum_marker_error_m, 0.0001)
	assert_lte(fixture.maximum_rope_end_error_m, 0.0001)

func test_active_snapshot_beats_stale_or_missing_aim_result_without_mutating_history() -> void:
	var fixture := await _spawn(true)
	var marker := fixture.player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	var old_hit := fixture.anchor.global_position
	var historical := GrappleTargetResolver.resolve_hit_result(0, 0, Vector3(0.0, 4.0, 0.0), Vector3.FORWARD, 35.0, 0.005, 0.001, true, old_hit, Vector3.BACK, 2.0, GrappleTargetResolver.HitKind.CANDIDATE, fixture.anchor, null, &"physics.grapple_candidate", &"physics.grapple_occlusion", 1)
	fixture.player.set("_current_targeting_result", historical)
	fixture.wall.set("motion_velocity", Vector3.RIGHT)
	await _ticks(8)
	var snapshot: GrappleAttachmentDiagnosticSnapshot = fixture.player.call("get_grapple_attachment_diagnostic_snapshot")
	assert_true(snapshot.is_value_only())
	assert_eq(marker.get_presented_world_position(), snapshot.anchor_world_position)
	assert_ne(marker.get_presented_world_position(), old_hit)
	assert_eq(historical.hit_position, old_hit)
	assert_eq(historical.query_count, 1)
	fixture.player.set("_current_targeting_result", null)
	fixture.player.call("update_grapple_feedback")
	assert_true(marker.is_marker_visible())
	assert_eq(marker.get_presented_world_position(), snapshot.anchor_world_position)

func test_ordinary_moving_active_marker_follows_sample_with_no_reselection_or_resets() -> void:
	var fixture := await _spawn(false, true)
	var marker := fixture.player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	var marker_resets := marker.interpolation_reset_count
	fixture.anchor.set("motion_velocity", Vector3.RIGHT)
	await _ticks(10)
	var snapshot: GrappleAttachmentDiagnosticSnapshot = fixture.player.call("get_grapple_attachment_diagnostic_snapshot")
	assert_eq(snapshot.anchor_revision, 0)
	assert_gt(snapshot.anchor_world_position.x, 0.1)
	assert_eq(marker.get_presented_world_position(), snapshot.anchor_world_position)
	assert_eq(marker.interpolation_reset_count, marker_resets)
	assert_eq(fixture.player.get("grapple_visual_reset_count"), 1)

func test_terminal_clears_marker_rope_and_historical_result_synchronously() -> void:
	var fixture := await _spawn(true)
	assert_true(fixture.player.call("terminate_grapple", GrappleEndReason.Reason.RELEASE))
	var marker := fixture.player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	var rope: MeshInstance3D = fixture.player.get("grapple_visual")
	assert_false(marker.is_marker_visible())
	assert_eq(marker.get_presented_world_position(), Vector3.ZERO)
	assert_eq(marker.get_presented_target_identity(), &"")
	assert_null(marker.get("_active_snapshot"))
	assert_null(fixture.player.call("get_latest_grapple_targeting_result"))
	assert_false(rope.visible)
	assert_eq(rope.global_transform, Transform3D.IDENTITY)
	assert_null(rope.mesh)
	assert_true(fixture.terminal_visuals_clear)
	assert_false(fixture.player.call("terminate_grapple", GrappleEndReason.Reason.OWNER_DEATH))
	assert_eq(fixture.terminal_count, 1)

func _spawn(forward: bool, moving_old: bool = false) -> WallStickReanchorFixture:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var fixture := FIXTURE.instantiate() as WallStickReanchorFixture
	fixture.start_forward = forward
	fixture.moving_grapple_anchor = moving_old
	viewport.add_child(fixture)
	await _ticks(6)
	assert_true(fixture.original_attachment.is_active())
	return fixture

func _ticks(count: int) -> void:
	for _i in range(count):
		await get_tree().physics_frame
	await get_tree().process_frame
