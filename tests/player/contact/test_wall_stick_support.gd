extends GutTest
const FIXTURE := preload("res://tests/fixtures/wall_stick_motion_fixture.tscn")

func test_wall_point_velocity_and_controller_relative_entry_use_owner_and_native_motion() -> void:
	var saved_rate := Engine.physics_ticks_per_second
	for rate in [60, 120]:
		for scenario in ["owner_local", "rigid_first", "static_surface", "animatable_first", "character_first"]:
			var report := await WallStickReviewCases.run_support_velocity(get_tree(), scenario, rate)
			assert_true(report.passed, str(report))
			print("[wall-stick-support-velocity] ", report)
	Engine.physics_ticks_per_second = saved_rate

func test_multiple_bindings_have_independent_weak_shape_listeners() -> void:
	var viewport := SubViewport.new()
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var fixture := FIXTURE.instantiate() as WallStickMotionFixture
	viewport.add_child(fixture)
	for _i in range(6):
		await get_tree().physics_frame
	await get_tree().process_frame
	var original: WallStickAttachment = fixture.player.get("_wall_stick_attachment")
	var shape := fixture.wall.get_node(^"WallShape").shape as BoxShape3D
	var original_count := shape.changed.get_connections().size()
	var provider := fixture.motor.get_contact_provider()
	var second := provider.bind_wall_stick_attachment(fixture.motor.get_previous_contact_frame(), fixture.player.global_position, fixture.player.get("wall_stick_definition"))
	assert_not_null(second)
	assert_eq(shape.changed.get_connections().size(), original_count + 1)
	shape.size.x += 1.0
	assert_eq(original.status, WallStickAttachment.Status.VALID)
	assert_eq(second.status, WallStickAttachment.Status.VALID)
	assert_true(bool(original.get("_geometry_dirty")))
	assert_true(bool(second.get("_geometry_dirty")))
	second.release()
	assert_eq(shape.changed.get_connections().size(), original_count)
	fixture.player.call("_clear_wall_stick")
	assert_eq(shape.changed.get_connections().size(), original_count - 1)

func test_binding_requires_the_selected_physical_publication_not_a_candidate_guess() -> void:
	var viewport := SubViewport.new()
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var fixture := FIXTURE.instantiate() as WallStickMotionFixture
	viewport.add_child(fixture)
	for _i in range(6):
		await get_tree().physics_frame
	await get_tree().process_frame
	var frame := fixture.motor.get_previous_contact_frame()
	var provider := fixture.motor.get_contact_provider()
	var definition: WallStickDefinition = fixture.player.get("wall_stick_definition")
	assert_not_null(frame.wall_support)
	assert_true(frame.wall_support.is_value_only())
	assert_eq(frame.wall_support.surface_identity, &"fixture.wall.stick")
	assert_gte(frame.wall_support.shape_index, 0)
	assert_true(frame.wall_point_velocity.is_finite())
	assert_not_null(provider.bind_wall_stick_attachment(frame, fixture.player.global_position, definition))
	var forged := ContactFrame.new(frame.physics_step, ContactFrame.Origin.POST_COMMIT, ContactFrame.Status.SUCCESS, frame.physics_step, true, false, false, Vector3.ZERO, &"", ContactFrame.GroundProvenance.NONE, true, frame.wall_normal, frame.wall_surface_identity, frame.wall_provenance, frame.wall_relation, frame.continuity_action)
	assert_null(provider.bind_wall_stick_attachment(forged, fixture.player.global_position, definition))
	var previous := frame
	await get_tree().physics_frame
	await get_tree().process_frame
	assert_null(provider.bind_wall_stick_attachment(previous, fixture.player.global_position, definition), "stale support publications cannot bind")
	assert_ne(frame.wall_support.transient_identity, &"", "RID is corroboration, not persistent surface identity")
	assert_true(frame.is_value_only())
