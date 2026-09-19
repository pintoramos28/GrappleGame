extends GutTest


func test_contact_frame_is_value_only_and_copies_bounded_records() -> void:
	var candidates: Array[ContactCandidate] = [
		ContactCandidate.new(
			4,
			ContactCandidate.Source.COMMITTED_COLLISION,
			ContactCandidate.Classification.WALL,
			Vector3.RIGHT,
			Vector3(2.0, 1.0, 0.0),
			&"surface.wall_a",
			11,
			0,
			0.2,
			0.25,
			0.9
		)
	]
	var rejections: Array[ContactRejection] = [
		ContactRejection.new(
			4,
			ContactCandidate.Source.SWEEP_PREDICTION,
			ContactRejection.Reason.FLOOR_LIKE,
			Vector3.UP,
			Vector3.ZERO
		)
	]
	var frame := ContactFrame.new(
		4,
		ContactFrame.Origin.POST_COMMIT,
		ContactFrame.Status.SUCCESS,
		4,
		true,
		false,
		true,
		Vector3.UP,
		&"",
		ContactFrame.GroundProvenance.PROXIMITY_ONLY,
		true,
		Vector3.RIGHT,
		&"surface.wall_a",
		ContactFrame.WallProvenance.COMMITTED_COLLISION,
		ContactFrame.WallRelation.LEFT,
		ContactFrame.ContinuityAction.INITIAL,
		candidates,
		rejections,
		32,
		8,
		5,
		1,
		0
	)

	assert_eq(frame.physics_step, 4)
	assert_eq(frame.origin, ContactFrame.Origin.POST_COMMIT)
	assert_true(frame.committed_evidence_available)
	assert_true(frame.has_wall_contact)
	assert_eq(frame.wall_surface_identity, &"surface.wall_a")
	assert_eq(frame.scanned_collision_count, 32)
	assert_eq(frame.reported_collision_count, 8)
	assert_eq(frame.query_count, 5)
	assert_eq(frame.rejected_candidate_count, 1)

	var copied_candidates := frame.candidates
	copied_candidates.clear()
	var copied_rejections := frame.rejections
	copied_rejections.clear()
	assert_eq(frame.candidates.size(), 1)
	assert_eq(frame.rejections.size(), 1)
	assert_true(frame.wall_normal.is_finite())
	assert_true(frame.is_value_only())


func test_profiles_validate_named_matrix_and_lock_authored_values() -> void:
	var ground := _valid_ground_probe()
	var wall := _valid_wall_probe()

	assert_eq(ground.validate(), PhysicsQueryProfile.ValidationStatus.SUCCESS)
	assert_eq(wall.validate(), PhysicsQueryProfile.ValidationStatus.SUCCESS)
	assert_true(ground.is_locked())
	assert_true(wall.is_locked())
	assert_eq(ground.get_collision_mask(), 1)
	assert_eq(wall.get_collision_mask(), 1)

	ground.collision_mask_names = PackedStringArray(["player_body"])
	wall.probe_distance_m = 99.0
	assert_eq(ground.get_collision_mask(), 1)
	assert_almost_eq(wall.probe_distance_m, 0.8, 0.000001)

	var invalid_distance := _valid_ground_probe()
	invalid_distance.probe_distance_m = INF
	assert_eq(
		invalid_distance.validate(),
		PhysicsQueryProfile.ValidationStatus.INVALID_TOLERANCE
	)


func test_normal_classification_rejects_floor_and_ceiling_consistently() -> void:
	var ground := _valid_ground_probe()
	var wall := _valid_wall_probe()

	assert_eq(
		PlayerContactProvider.classify_normal(Vector3.UP, ground, wall),
		ContactCandidate.Classification.GROUND
	)
	assert_eq(
		PlayerContactProvider.classify_normal(Vector3.DOWN, ground, wall),
		ContactCandidate.Classification.CEILING_LIKE
	)
	assert_eq(
		PlayerContactProvider.classify_normal(Vector3.RIGHT, ground, wall),
		ContactCandidate.Classification.WALL
	)
	assert_eq(
		PlayerContactProvider.classify_normal(Vector3(0.0, 0.35, 0.93675), ground, wall),
		ContactCandidate.Classification.FLOOR_LIKE
	)


func test_wall_selection_is_deterministic_for_permuted_candidates_and_exact_ties() -> void:
	var wall := _valid_wall_probe()
	var first := ContactCandidate.new(
		1,
		ContactCandidate.Source.SWEEP_PREDICTION,
		ContactCandidate.Classification.WALL,
		Vector3.RIGHT,
		Vector3(2.0, 1.0, 0.0),
		&"surface.wall_b",
		2,
		0,
		0.4,
		0.4,
		0.7
	)
	var stronger := ContactCandidate.new(
		1,
		ContactCandidate.Source.COMMITTED_COLLISION,
		ContactCandidate.Classification.WALL,
		Vector3.RIGHT,
		Vector3(2.0, 1.0, 0.0),
		&"surface.wall_a",
		1,
		0,
		0.4,
		0.4,
		0.7
	)
	var tie_a := ContactCandidate.new(
		1,
		ContactCandidate.Source.SWEEP_PREDICTION,
		ContactCandidate.Classification.WALL,
		Vector3.FORWARD,
		Vector3(0.0, 1.0, 2.0),
		&"",
		3,
		0,
		0.5,
		0.5,
		0.5
	)
	var tie_b := ContactCandidate.new(
		1,
		ContactCandidate.Source.SWEEP_PREDICTION,
		ContactCandidate.Classification.WALL,
		Vector3.FORWARD,
		Vector3(0.0, 1.0, 2.0),
		&"",
		4,
		0,
		0.5,
		0.5,
		0.5
	)

	var selected_forward := PlayerContactProvider.select_wall_candidate(
		[first, stronger, tie_a, tie_b],
		wall,
		null
	)
	var selected_reverse := PlayerContactProvider.select_wall_candidate(
		[tie_b, tie_a, stronger, first],
		wall,
		null
	)

	assert_eq(selected_forward.surface_identity, &"surface.wall_a")
	assert_eq(selected_reverse.surface_identity, selected_forward.surface_identity)
	assert_eq(selected_reverse.normal, selected_forward.normal)
	var tie_forward := PlayerContactProvider.select_wall_candidate([tie_a, tie_b], wall, null)
	var tie_reverse := PlayerContactProvider.select_wall_candidate([tie_b, tie_a], wall, null)
	assert_eq(tie_forward.shape_index, 3)
	assert_eq(tie_reverse.shape_index, tie_forward.shape_index)
	assert_eq(
		PlayerContactProvider.deduplicate_candidates([tie_a, tie_b], wall).size(),
		1
	)


func test_ground_selection_is_deterministic_for_permuted_equal_distance_candidates() -> void:
	var ground := _valid_ground_probe()
	var first := ContactCandidate.new(
		1,
		ContactCandidate.Source.COMMITTED_COLLISION,
		ContactCandidate.Classification.GROUND,
		Vector3.UP,
		Vector3(0.0, 0.0, 0.0),
		&"surface.ground_b",
		2,
		0,
		0.2,
		0.0,
		0.0
	)
	var canonical := ContactCandidate.new(
		1,
		ContactCandidate.Source.COMMITTED_COLLISION,
		ContactCandidate.Classification.GROUND,
		Vector3.UP,
		Vector3(0.0, 0.0, 0.0),
		&"surface.ground_a",
		1,
		1,
		0.2,
		0.0,
		0.0
	)

	var selected_forward := PlayerContactProvider._select_ground_candidate([first, canonical], ground)
	var selected_reverse := PlayerContactProvider._select_ground_candidate([canonical, first], ground)

	assert_eq(selected_forward.surface_identity, &"surface.ground_a")
	assert_eq(selected_reverse.surface_identity, selected_forward.surface_identity)
	assert_eq(selected_reverse.shape_index, selected_forward.shape_index)


func test_retagged_continuity_candidate_uses_current_physics_step() -> void:
	var candidate := ContactCandidate.new(
		10,
		ContactCandidate.Source.COMMITTED_COLLISION,
		ContactCandidate.Classification.WALL,
		Vector3.RIGHT,
		Vector3(1.0, 1.0, 0.0),
		&"surface.wall",
		4,
		2,
		0.1,
		0.0,
		0.5
	)
	var retained := PlayerContactProvider._retag_candidate(candidate, 11)

	assert_eq(retained.physics_step, 11)
	assert_eq(retained.source, candidate.source)
	assert_eq(retained.normal, candidate.normal)
	assert_eq(retained.surface_identity, candidate.surface_identity)


func test_query_profiles_reject_hard_contact_budget_limits() -> void:
	var over_probe_distance := _valid_ground_probe()
	over_probe_distance.probe_distance_m = PhysicsQueryProfile.MAX_PROBE_DISTANCE_M + 0.01
	assert_eq(over_probe_distance.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_TOLERANCE)

	var over_sweep_distance := _valid_ground_probe()
	over_sweep_distance.sweep_distance_cap_m = PhysicsQueryProfile.MAX_SWEEP_DISTANCE_M + 0.01
	assert_eq(over_sweep_distance.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_TOLERANCE)

	var over_loss_window := _valid_ground_probe()
	over_loss_window.continuity_loss_steps = PhysicsQueryProfile.MAX_CONTINUITY_LOSS_STEPS + 1
	assert_eq(over_loss_window.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_TOLERANCE)

	var over_candidate_limit := _valid_ground_probe()
	over_candidate_limit.candidate_limit = PhysicsQueryProfile.MAX_CANDIDATE_LIMIT + 1
	assert_eq(over_candidate_limit.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_LIMITS)

	var over_report_limit := _valid_ground_probe()
	over_report_limit.report_limit = PhysicsQueryProfile.MAX_REPORT_LIMIT + 1
	assert_eq(over_report_limit.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_LIMITS)

	var over_scan_limit := _valid_ground_probe()
	over_scan_limit.scan_limit = PhysicsQueryProfile.MAX_SCAN_LIMIT + 1
	assert_eq(over_scan_limit.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_LIMITS)


func test_ground_normal_classification_is_applied_to_authoritative_candidates() -> void:
	var ground := _valid_ground_probe()
	var wall := _valid_wall_probe()
	var disallowed_slope := Vector3(0.0, 0.5, 0.8660254).normalized()

	assert_eq(
		PlayerContactProvider.classify_normal(disallowed_slope, ground, wall),
		ContactCandidate.Classification.FLOOR_LIKE
	)


func test_provider_bootstrap_publishes_frame_zero_and_rejects_bad_step_handoffs() -> void:
	var fixture := _new_provider_fixture()
	var provider: PlayerContactProvider = fixture[2]

	var bootstrap := provider.bootstrap()
	assert_eq(bootstrap.physics_step, 0)
	assert_eq(bootstrap.origin, ContactFrame.Origin.BOOTSTRAP)
	assert_true(bootstrap.success)
	assert_false(bootstrap.committed_evidence_available)

	var first := provider.publish_committed_frame(1, 1.0 / 60.0, Vector3.ZERO)
	assert_true(first.success)
	assert_eq(first.physics_step, 1)

	var duplicate := provider.publish_committed_frame(1, 1.0 / 60.0, Vector3.ZERO)
	assert_eq(duplicate.status, ContactFrame.Status.DUPLICATE_STEP)
	var skipped := provider.publish_committed_frame(3, 1.0 / 60.0, Vector3.ZERO)
	assert_eq(skipped.status, ContactFrame.Status.SKIPPED_STEP)
	var stale := provider.publish_committed_frame(0, 1.0 / 60.0, Vector3.ZERO)
	assert_eq(stale.status, ContactFrame.Status.STALE_STEP)


func test_required_ground_configuration_fails_closed_and_invalid_wall_is_unavailable() -> void:
	var fixture := _new_provider_fixture()
	var body: CharacterBody3D = fixture[1]
	var invalid_ground := GroundProbe.new()
	var required_provider := PlayerContactProvider.new()
	assert_eq(
		required_provider.initialize(body, invalid_ground, _valid_wall_probe()),
		PlayerContactProvider.InitializationStatus.INVALID_GROUND_PROFILE
	)

	var invalid_wall := WallProbe.new()
	var wall_optional_provider := PlayerContactProvider.new()
	assert_eq(
		wall_optional_provider.initialize(body, _valid_ground_probe(), invalid_wall),
		PlayerContactProvider.InitializationStatus.SUCCESS
	)
	assert_false(wall_optional_provider.is_wall_available())
	var bootstrap := wall_optional_provider.bootstrap()
	assert_true(bootstrap.success)
	assert_eq(bootstrap.continuity_action, ContactFrame.ContinuityAction.UNAVAILABLE)
	assert_false(bootstrap.wall_probe_query_succeeded)


func test_player_surface_reads_only_the_shared_contact_frame() -> void:
	var surface_paths: Array[String] = [
		"res://scripts/player_controller.gd",
		"res://scripts/player_grounded_state.gd",
		"res://scripts/player_airborne_state.gd",
		"res://scripts/player_grappling_state.gd",
		"res://scripts/player_wall_run_state.gd",
		"res://scripts/player_wall_stick_state.gd",
		"res://scripts/player_dead_state.gd",
	]
	for path in surface_paths:
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("is_on_floor()"), path)
		assert_false(source.contains("is_on_wall()"), path)
		assert_false(source.contains("get_slide_collision"), path)
		if path == "res://scripts/player_controller.gd":
			assert_false(source.contains("_find_wall_with_velocity_rays"), path)
			assert_false(source.contains("_try_start_wall_stick_from_collisions"), path)
			var grapple_boundary := source.find("func _get_grapple_ray_hit")
			var locomotion_surface := source.substr(0, grapple_boundary) if grapple_boundary >= 0 else source
			assert_false(locomotion_surface.contains("PhysicsRayQueryParameters3D"), path)
			assert_false(locomotion_surface.contains("PhysicsShapeQueryParameters3D"), path)
			assert_false(locomotion_surface.contains("intersect_ray"), path)


func _valid_ground_probe() -> GroundProbe:
	var probe := GroundProbe.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.08
	probe.shape = shape
	probe.collision_mask_names = PackedStringArray(["world_geometry"])
	return probe


func _valid_wall_probe() -> WallProbe:
	var probe := WallProbe.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.12
	probe.shape = shape
	probe.collision_mask_names = PackedStringArray(["world_geometry"])
	return probe


func _new_provider_fixture() -> Array:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var body := CharacterBody3D.new()
	world.add_child(body)

	var provider := PlayerContactProvider.new()
	assert_eq(
		provider.initialize(body, _valid_ground_probe(), _valid_wall_probe()),
		PlayerContactProvider.InitializationStatus.SUCCESS
	)
	return [world, body, provider]
