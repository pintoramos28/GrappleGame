extends GutTest


class DirtyTargetingResult extends GrappleTargetingResult:
	var bad_node: Node = null


class DirtySeed extends GrappleTargetSeed:
	var bad_node: Node = null


class DirtyResponse extends GrappleTargetResponse:
	var bad_node: Node = null


class DirtySnapshot extends GrappleTargetingDiagnosticSnapshot:
	var bad_node: Node = null


func test_targeting_result_is_value_only_bounded_and_sanitizes_malformed_payloads() -> void:
	var seed := GrappleTargetSeed.new(
		&"target.wall_a",
		Vector3(1.0, 2.0, 3.0),
		Vector3.BACK,
		GrappleTargetResponse.static_default(),
		weakref(_new_target()),
		Vector3(0.25, 0.0, 0.0)
	)
	var result := GrappleTargetingResult.new(
		7,
		7,
		Vector3(0.0, 1.6, 0.0),
		Vector3(0.0, 0.0, -1.0),
		35.0,
		GrappleRejection.Reason.NONE,
		Vector3(1.0, 2.0, 3.0),
		Vector3.BACK,
		12.5,
		0.357142,
		&"target.wall_a",
		seed,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)

	assert_eq(result.source_physics_step, 7)
	assert_eq(result.command_frame_step, 7)
	assert_eq(result.rejection, GrappleRejection.Reason.NONE)
	assert_true(result.is_accepted())
	assert_true(result.has_accepted_seed())
	assert_same(result.accepted_seed, seed)
	assert_eq(result.target_identity, &"target.wall_a")
	assert_eq(result.candidate_profile_id, &"player.grapple.candidate")
	assert_eq(result.occlusion_profile_id, &"player.grapple.occlusion")
	assert_eq(result.query_count, 1)
	assert_true(result.matches_single_query_contract())
	assert_true(result.is_value_only())
	assert_true(result.is_finite())

	var bounded := GrappleTargetingResult.new(
		1,
		1,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.NO_CANDIDATE,
		Vector3.ZERO,
		Vector3.ZERO,
		0.0,
		0.0,
		&"",
		null,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		9
	)
	assert_eq(bounded.query_count, 9)
	assert_false(bounded.matches_single_query_contract())

	var double_query := GrappleTargetingResult.new(
		1,
		1,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.NO_CANDIDATE,
		Vector3.ZERO,
		Vector3.ZERO,
		0.0,
		0.0,
		&"",
		null,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		2
	)
	assert_eq(double_query.query_count, 2)
	assert_false(double_query.matches_single_query_contract())

	var malformed := GrappleTargetingResult.new(
		2,
		2,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.NONE,
		Vector3(NAN, 0.0, 0.0),
		Vector3.BACK,
		1.0,
		0.5,
		&"target.wall_a",
		seed,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)
	assert_eq(malformed.rejection, GrappleRejection.Reason.MALFORMED_TARGET_DATA)
	assert_false(malformed.is_accepted())
	assert_null(malformed.accepted_seed)
	assert_eq(malformed.hit_position, Vector3.ZERO)


func test_value_only_introspection_detects_dirty_records() -> void:
	var clean := GrappleTargetingResult.new(
		3,
		3,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.NONE,
		Vector3(1.0, 2.0, 3.0),
		Vector3.BACK,
		4.0,
		0.5,
		&"target.wall_a",
		GrappleTargetSeed.new(
			&"target.wall_a",
			Vector3(1.0, 2.0, 3.0),
			Vector3.BACK,
			GrappleTargetResponse.static_default(),
			weakref(_new_target()),
			Vector3.ZERO
		),
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)
	assert_true(clean.is_value_only())
	assert_true(clean.accepted_seed.is_value_only())
	assert_true(clean.accepted_seed.response.is_value_only())

	var dirty := DirtyTargetingResult.new(
		4,
		4,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.NONE,
		Vector3(1.0, 2.0, 3.0),
		Vector3.BACK,
		4.0,
		0.5,
		&"target.wall_a",
		null,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)
	assert_false(dirty.is_value_only())

	var dirty_seed := DirtySeed.new(
		&"target.wall_a",
		Vector3(1.0, 2.0, 3.0),
		Vector3.BACK,
		GrappleTargetResponse.static_default(),
		weakref(_new_target()),
		Vector3.ZERO
	)
	assert_false(dirty_seed.is_value_only())
	assert_false(GrappleTargetSeed.value_is_value_only(dirty_seed))

	var dirty_response := DirtyResponse.new()
	assert_false(dirty_response.is_value_only())
	assert_false(GrappleTargetResponse.value_is_value_only(dirty_response))

	var dirty_snapshot := DirtySnapshot.new(
		1,
		1,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		Vector3.ZERO,
		Vector3.BACK,
		4.0,
		&"target.wall_a",
		false,
		GrappleRejection.Reason.NO_CANDIDATE,
		0.5,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)
	assert_false(dirty_snapshot.is_value_only())
	assert_false(GrappleTargetingDiagnosticSnapshot.value_is_value_only(dirty_snapshot))

	# A dirty record smuggled into an otherwise clean parent must be detected
	# through the parent's own purity check.
	var smuggler := GrappleTargetingResult.new(
		5,
		5,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.NONE,
		Vector3(1.0, 2.0, 3.0),
		Vector3.BACK,
		4.0,
		0.5,
		&"target.wall_a",
		dirty_seed,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)
	assert_false(smuggler.is_value_only())
	assert_false(GrappleTargetingResult.value_is_value_only(smuggler))
	assert_true(GrappleTargetingResult.value_is_value_only(clean))


func test_grapple_rejection_value_set_is_closed_and_expected_rejections_are_not_errors() -> void:
	var expected_keys := [
		"NONE",
		"NO_CANDIDATE",
		"OUT_OF_RANGE",
		"OCCLUDED",
		"INVALID_SURFACE",
		"POLICY_REJECTED",
		"TARGET_INVALID",
		"MALFORMED_TARGET_DATA",
		"MISSING_RESULT",
		"STALE_RESULT",
	]
	assert_eq(GrappleRejection.Reason.keys(), expected_keys)

	var expected_gameplay: Array[GrappleRejection.Reason] = [
		GrappleRejection.Reason.NO_CANDIDATE,
		GrappleRejection.Reason.OUT_OF_RANGE,
		GrappleRejection.Reason.OCCLUDED,
		GrappleRejection.Reason.INVALID_SURFACE,
		GrappleRejection.Reason.POLICY_REJECTED,
		GrappleRejection.Reason.TARGET_INVALID,
		GrappleRejection.Reason.MALFORMED_TARGET_DATA,
	]
	for reason in expected_gameplay:
		assert_true(
			GrappleRejection.is_expected_gameplay_rejection(reason),
			GrappleRejection.reason_id(reason)
		)
	assert_false(GrappleRejection.is_expected_gameplay_rejection(GrappleRejection.Reason.NONE))
	assert_false(
		GrappleRejection.is_expected_gameplay_rejection(GrappleRejection.Reason.MISSING_RESULT)
	)
	assert_false(
		GrappleRejection.is_expected_gameplay_rejection(GrappleRejection.Reason.STALE_RESULT)
	)
	assert_eq(
		GrappleRejection.reason_id(GrappleRejection.Reason.MALFORMED_TARGET_DATA),
		&"malformed_target_data"
	)


func test_definition_validation_locks_authored_values_and_bounds_acquisition_tolerance() -> void:
	var definition := _valid_definition()
	assert_eq(definition.validate(), GrappleDefinition.ValidationStatus.SUCCESS)
	assert_true(definition.is_locked())

	definition.max_grapple_length_m = 999.0
	definition.acquisition_tolerance_m = 5.0
	definition.pull_initial_acceleration_mps2 = 1.0
	assert_almost_eq(definition.max_grapple_length_m, 35.0, 0.000001)
	assert_almost_eq(definition.acquisition_tolerance_m, 0.005, 0.000001)
	assert_almost_eq(definition.pull_initial_acceleration_mps2, 48.0, 0.000001)

	var unstable_id := _valid_definition()
	unstable_id.unlock_for_editor()
	unstable_id.definition_id = &"Player"
	assert_eq(unstable_id.validate(), GrappleDefinition.ValidationStatus.INVALID_ID)

	var over_tolerance := _valid_definition()
	over_tolerance.unlock_for_editor()
	over_tolerance.acquisition_tolerance_m = 0.5
	assert_eq(over_tolerance.validate(), GrappleDefinition.ValidationStatus.INVALID_TOLERANCE)

	var zero_tolerance := _valid_definition()
	zero_tolerance.unlock_for_editor()
	zero_tolerance.acquisition_tolerance_m = 0.0
	assert_eq(zero_tolerance.validate(), GrappleDefinition.ValidationStatus.INVALID_TOLERANCE)

	var bad_range := _valid_definition()
	bad_range.unlock_for_editor()
	bad_range.max_grapple_length_m = INF
	assert_eq(bad_range.validate(), GrappleDefinition.ValidationStatus.INVALID_RANGE)

	var missing_profile := _valid_definition()
	missing_profile.unlock_for_editor()
	missing_profile.target_query_profile = null
	assert_eq(missing_profile.validate(), GrappleDefinition.ValidationStatus.INVALID_PROFILE)

	var contact_profile := _valid_definition()
	contact_profile.unlock_for_editor()
	contact_profile.target_query_profile = _valid_ground_probe()
	assert_eq(contact_profile.validate(), GrappleDefinition.ValidationStatus.INVALID_PROFILE)

	var bad_pull := _valid_definition()
	bad_pull.unlock_for_editor()
	bad_pull.pull_min_acceleration_mps2 = 90.0
	assert_eq(bad_pull.validate(), GrappleDefinition.ValidationStatus.INVALID_PULL_TUNING)

	var bad_cap := _valid_definition()
	bad_cap.unlock_for_editor()
	bad_cap.maximum_speed_mps = 0.0
	assert_eq(bad_cap.validate(), GrappleDefinition.ValidationStatus.INVALID_SPEED_CAP)

	var authored := load("res://game/player/abilities/grapple/definitions/grapple_definition.tres")
	assert_not_null(authored)
	assert_true(authored is GrappleDefinition)
	assert_eq(authored.validate(), GrappleDefinition.ValidationStatus.SUCCESS)
	assert_eq(authored.definition_id, &"player.grapple.default")
	assert_almost_eq(authored.max_grapple_length_m, 35.0, 0.000001)
	assert_almost_eq(authored.pull_initial_acceleration_mps2, 60.0, 0.000001)
	assert_almost_eq(authored.pull_min_acceleration_mps2, 8.0, 0.000001)
	assert_almost_eq(authored.pull_acceleration_jerk_mps3, 53.333333, 0.000001)
	assert_almost_eq(authored.maximum_speed_mps, 22.0, 0.000001)


func test_ray_profiles_are_shape_exempt_while_contact_probe_bounds_stay_intact() -> void:
	var ray := _valid_ray_profile()
	assert_eq(ray.validate(), PhysicsQueryProfile.ValidationStatus.SUCCESS)
	assert_true(ray.is_ray_profile())
	assert_true(ray.is_locked())

	var shapeless_contact := GroundProbe.new()
	assert_eq(shapeless_contact.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_SHAPE)

	var over_probe := _valid_ground_probe()
	over_probe.probe_distance_m = PhysicsQueryProfile.MAX_PROBE_DISTANCE_M + 0.01
	assert_eq(over_probe.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_TOLERANCE)

	var over_sweep := _valid_ground_probe()
	over_sweep.sweep_distance_cap_m = PhysicsQueryProfile.MAX_SWEEP_DISTANCE_M + 0.01
	assert_eq(over_sweep.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_TOLERANCE)

	var bad_quantization := _valid_ray_profile()
	bad_quantization.unlock_for_editor()
	bad_quantization.point_quantization_m = 0.0
	assert_eq(bad_quantization.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_TOLERANCE)

	var bad_mask := _valid_ray_profile()
	bad_mask.unlock_for_editor()
	bad_mask.collision_mask_names = PackedStringArray(["not_a_layer"])
	assert_eq(bad_mask.validate(), PhysicsQueryProfile.ValidationStatus.INVALID_MASK)

	var authored_candidate := load("res://game/shared/physics/grapple_candidate.tres")
	assert_not_null(authored_candidate)
	assert_true(authored_candidate is PhysicsQueryProfile)
	assert_eq(
		authored_candidate.validate(),
		PhysicsQueryProfile.ValidationStatus.SUCCESS
	)
	assert_eq(authored_candidate.profile_id, &"player.grapple.candidate")

	var authored_occlusion := load("res://game/shared/physics/grapple_occlusion.tres")
	assert_not_null(authored_occlusion)
	assert_eq(
		authored_occlusion.validate(),
		PhysicsQueryProfile.ValidationStatus.SUCCESS
	)
	assert_eq(authored_occlusion.profile_id, &"player.grapple.occlusion")


func test_duplicate_grappleable_records_normalize_and_select_deterministically() -> void:
	var profile := _valid_ray_profile()
	assert_eq(profile.validate(), PhysicsQueryProfile.ValidationStatus.SUCCESS)

	var wall_b := _make_grappleable(&"target.wall_b", GrappleTargetResponse.AnchorMode.MOVING, 1.5)
	var wall_a := _make_grappleable(&"target.wall_a", GrappleTargetResponse.AnchorMode.STATIC, 1.0)
	var tie_a := _make_grappleable(&"target.tie", GrappleTargetResponse.AnchorMode.STATIC, 1.0)
	var tie_b := _make_grappleable(&"target.tie", GrappleTargetResponse.AnchorMode.STATIC, 1.0)

	var forward := GrappleTargetResolver.select_grappleable(
		[wall_b, wall_a, tie_a, tie_b],
		profile,
		2.0,
		Vector3(0.0, 1.0, -2.0),
		Vector3.BACK
	)
	var reverse := GrappleTargetResolver.select_grappleable(
		[tie_b, tie_a, wall_a, wall_b],
		profile,
		2.0,
		Vector3(0.0, 1.0, -2.0),
		Vector3.BACK
	)

	assert_not_null(forward)
	assert_not_null(reverse)
	assert_eq(forward.get_target_id(), reverse.get_target_id())
	assert_eq(forward.get_target_id(), &"target.tie")

	var normalized_forward := GrappleTargetResolver.normalize_grappleables(
		[wall_b, wall_a, tie_a, tie_b],
		profile,
		2.0,
		Vector3(0.0, 1.0, -2.0),
		Vector3.BACK
	)
	var normalized_reverse := GrappleTargetResolver.normalize_grappleables(
		[tie_b, tie_a, wall_a, wall_b],
		profile,
		2.0,
		Vector3(0.0, 1.0, -2.0),
		Vector3.BACK
	)
	assert_eq(normalized_forward.size(), 3)
	assert_eq(normalized_reverse.size(), 3)

	var tie_forward := GrappleTargetResolver.select_grappleable([tie_a, tie_b], profile)
	var tie_reverse := GrappleTargetResolver.select_grappleable([tie_b, tie_a], profile)
	assert_eq(tie_forward.get_target_id(), &"target.tie")
	assert_eq(tie_reverse.get_target_id(), tie_forward.get_target_id())
	assert_eq(
		GrappleTargetResolver.normalize_grappleables([tie_a, tie_b], profile).size(),
		1
	)


func test_locked_predicate_maps_every_ac6_condition_to_stable_typed_rejections() -> void:
	var target := _new_target()
	var default_geometry := _resolve(
		true,
		Vector3(0.0, 1.0, -8.0),
		Vector3.BACK,
		8.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		null
	)
	assert_true(default_geometry.is_accepted())
	assert_eq(default_geometry.rejection, GrappleRejection.Reason.NONE)

	var empty_aim := _resolve(false, Vector3.ZERO, Vector3.ZERO, 0.0, GrappleTargetResolver.HitKind.CANDIDATE, null, null)
	assert_eq(empty_aim.rejection, GrappleRejection.Reason.NO_CANDIDATE)
	assert_null(empty_aim.accepted_seed)

	var out_of_range := _resolve(
		true,
		Vector3(0.0, 1.0, -35.0025),
		Vector3.BACK,
		35.0025,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		null
	)
	assert_eq(out_of_range.rejection, GrappleRejection.Reason.OUT_OF_RANGE)
	assert_gt(out_of_range.range_fraction, 1.0)
	assert_null(out_of_range.accepted_seed)

	var occluded := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.BACK,
		4.0,
		GrappleTargetResolver.HitKind.OCCLUSION_ONLY,
		target,
		null
	)
	assert_eq(occluded.rejection, GrappleRejection.Reason.OCCLUDED)
	assert_null(occluded.accepted_seed)

	var ineligible := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.BACK,
		4.0,
		GrappleTargetResolver.HitKind.INELIGIBLE,
		target,
		null
	)
	assert_eq(ineligible.rejection, GrappleRejection.Reason.INVALID_SURFACE)

	var degenerate_normal := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.ZERO,
		4.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		null
	)
	assert_eq(degenerate_normal.rejection, GrappleRejection.Reason.MALFORMED_TARGET_DATA)
	assert_null(degenerate_normal.accepted_seed)

	# Degenerate normals are malformed hit data and outrank kind and range.
	var degenerate_occluded_kind := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.ZERO,
		4.0,
		GrappleTargetResolver.HitKind.OCCLUSION_ONLY,
		target,
		null
	)
	assert_eq(
		degenerate_occluded_kind.rejection,
		GrappleRejection.Reason.MALFORMED_TARGET_DATA
	)
	var degenerate_out_of_range := _resolve(
		true,
		Vector3(0.0, 1.0, -35.0025),
		Vector3.ZERO,
		35.0025,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		null
	)
	assert_eq(
		degenerate_out_of_range.rejection,
		GrappleRejection.Reason.MALFORMED_TARGET_DATA
	)

	var malformed_hit := _resolve(
		true,
		Vector3(NAN, 1.0, -4.0),
		Vector3.BACK,
		4.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		null
	)
	assert_eq(malformed_hit.rejection, GrappleRejection.Reason.MALFORMED_TARGET_DATA)
	assert_null(malformed_hit.accepted_seed)

	var missing_target := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.BACK,
		4.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		null,
		_make_grappleable(&"target.wall_a")
	)
	assert_eq(missing_target.rejection, GrappleRejection.Reason.TARGET_INVALID)

	var identity_less := _make_grappleable(&"")
	var malformed_identity := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.BACK,
		4.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		identity_less
	)
	assert_eq(malformed_identity.rejection, GrappleRejection.Reason.MALFORMED_TARGET_DATA)

	var ineligible_response := _make_grappleable(&"target.wall_a")
	ineligible_response.eligible = false
	var policy_rejected := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.BACK,
		4.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		ineligible_response
	)
	assert_eq(policy_rejected.rejection, GrappleRejection.Reason.POLICY_REJECTED)
	assert_null(policy_rejected.accepted_seed)

	# Precedence pins: malformed outranks an explicit policy rejection, and
	# the range band outranks policy (kind -> range -> policy order).
	var degenerate_policy_target := _resolve(
		true,
		Vector3(0.0, 1.0, -4.0),
		Vector3.ZERO,
		4.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		ineligible_response
	)
	assert_eq(
		degenerate_policy_target.rejection,
		GrappleRejection.Reason.MALFORMED_TARGET_DATA
	)
	var out_of_range_policy_target := _resolve(
		true,
		Vector3(0.0, 1.0, -35.0025),
		Vector3.BACK,
		35.0025,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		ineligible_response
	)
	assert_eq(
		out_of_range_policy_target.rejection,
		GrappleRejection.Reason.OUT_OF_RANGE
	)


func test_boundary_predicate_is_inclusive_quantized_and_never_flips() -> void:
	var target := _new_target()
	var quantization := 0.001

	var inside := _resolve(true, Vector3(0.0, 0.0, -34.9995), Vector3.BACK, 34.9995, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
	assert_true(inside.is_accepted())
	assert_lte(inside.range_fraction, 1.0)

	var exactly_max := _resolve(true, Vector3(0.0, 0.0, -35.0), Vector3.BACK, 35.0, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
	assert_true(exactly_max.is_accepted())
	assert_almost_eq(exactly_max.range_fraction, 1.0, 0.0001)

	var band := _resolve(true, Vector3(0.0, 0.0, -35.0025), Vector3.BACK, 35.0025, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
	assert_eq(band.rejection, GrappleRejection.Reason.OUT_OF_RANGE)
	assert_gt(band.range_fraction, 1.0)

	var band_top := _resolve(true, Vector3(0.0, 0.0, -35.005), Vector3.BACK, 35.005, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
	assert_eq(band_top.rejection, GrappleRejection.Reason.OUT_OF_RANGE)

	var beyond := _resolve(true, Vector3(0.0, 0.0, -37.0), Vector3.BACK, 37.0, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
	assert_eq(beyond.rejection, GrappleRejection.Reason.NO_CANDIDATE)

	var beyond_ray := _resolve(false, Vector3.ZERO, Vector3.ZERO, 0.0, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
	assert_eq(beyond_ray.rejection, GrappleRejection.Reason.NO_CANDIDATE)

	for _repeat in range(3):
		var again := _resolve(true, Vector3(0.0, 0.0, -35.0025), Vector3.BACK, 35.0025, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
		assert_eq(again.rejection, band.rejection)
		assert_almost_eq(again.range_fraction, band.range_fraction, quantization)

	var repeated_max := _resolve(true, Vector3(0.0, 0.0, -35.0), Vector3.BACK, 35.0, GrappleTargetResolver.HitKind.CANDIDATE, target, null)
	assert_true(repeated_max.is_accepted())


func test_accepted_seed_carries_attachment_payload_with_documented_weak_reference() -> void:
	var target := _new_target()
	target.transform = Transform3D(Basis.from_euler(Vector3(0.0, 0.5, 0.0)), Vector3(4.0, 2.0, -6.0))
	var component := _make_grappleable(
		&"target.moving_platform",
		GrappleTargetResponse.AnchorMode.MOVING,
		1.25,
		Vector3(0.5, 0.0, 0.0),
		0.25
	)
	var hit_position := Vector3(4.5, 2.5, -6.25)
	var result := _resolve(
		true,
		hit_position,
		Vector3.BACK,
		7.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		component
	)

	assert_true(result.is_accepted())
	var seed: GrappleTargetSeed = result.accepted_seed
	assert_not_null(seed)
	assert_eq(seed.target_identity, &"target.moving_platform")
	assert_eq(seed.hit_position, hit_position)
	assert_eq(seed.hit_normal, Vector3.BACK)
	assert_eq(seed.response.anchor_mode, GrappleTargetResponse.AnchorMode.MOVING)
	assert_almost_eq(seed.response.pull_multiplier, 1.25, 0.000001)
	assert_almost_eq(seed.response.instability, 0.25, 0.000001)
	assert_eq(seed.response.directional_adjustment, Vector3(0.5, 0.0, 0.0))
	assert_true(seed.get_target_reference() is WeakRef)
	assert_true(seed.has_live_target())
	assert_same(seed.get_target(), target)
	# The target is detached here, so acquisition falls back to its local transform.
	var expected_offset := target.transform.affine_inverse() * hit_position
	assert_almost_eq(
		seed.target_local_hit_offset.x,
		expected_offset.x,
		0.0001
	)
	assert_almost_eq(
		seed.target_local_hit_offset.z,
		expected_offset.z,
		0.0001
	)

	target.free()
	assert_false(seed.has_live_target())
	assert_null(seed.get_target())

	var default_seed := GrappleTargetResolver.resolve_hit_result(
		1,
		1,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		0.005,
		0.001,
		true,
		Vector3(0.0, 1.0, -3.0),
		Vector3.BACK,
		3.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		_new_target(),
		null,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)
	assert_true(default_seed.is_accepted())
	assert_eq(default_seed.target_identity, &"")
	assert_eq(default_seed.accepted_seed.response, GrappleTargetResponse.static_default())
	assert_almost_eq(default_seed.accepted_seed.response.pull_multiplier, 1.0, 0.000001)
	assert_eq(
		default_seed.accepted_seed.response.anchor_mode,
		GrappleTargetResponse.AnchorMode.STATIC
	)


func test_missing_and_stale_activation_inputs_reject_without_accepted_seeds() -> void:
	var missing := GrappleTargetResolver.no_query_failure(
		9,
		9,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.MISSING_RESULT,
		&"player.grapple.candidate",
		&"player.grapple.occlusion"
	)
	assert_eq(missing.rejection, GrappleRejection.Reason.MISSING_RESULT)
	assert_eq(missing.query_count, 0)
	assert_null(missing.accepted_seed)
	assert_false(missing.is_accepted())

	var stale := GrappleTargetResolver.no_query_failure(
		8,
		8,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.STALE_RESULT,
		&"player.grapple.candidate",
		&"player.grapple.occlusion"
	)
	assert_eq(stale.rejection, GrappleRejection.Reason.STALE_RESULT)
	assert_null(stale.accepted_seed)

	var fixture := _new_resolver_fixture()
	var resolver: GrappleTargetResolver = fixture[1]
	var frame := PlayerCommandFrame.new(3, Vector2.ZERO, 0.0, 0.0, Vector3(0.0, 0.0, -1.0))

	var result := resolver.evaluate(3, frame, Vector3(0.0, 1.0, 0.0))
	assert_eq(result.source_physics_step, 3)
	assert_eq(result.command_frame_step, 3)
	assert_eq(result.query_count, 1)
	assert_eq(result.rejection, GrappleRejection.Reason.NO_CANDIDATE)

	var repeated := resolver.evaluate(3, frame, Vector3(0.0, 1.0, 0.0))
	assert_same(repeated, result)
	assert_eq(repeated.query_count, 1)

	var stale_request := resolver.evaluate(2, frame, Vector3(0.0, 1.0, 0.0))
	assert_eq(stale_request.query_count, 0)
	assert_eq(stale_request.rejection, GrappleRejection.Reason.STALE_RESULT)
	assert_null(stale_request.accepted_seed)


func test_uninitialized_resolver_reports_missing_results_without_queries() -> void:
	var resolver := GrappleTargetResolver.new()
	autofree(resolver)
	assert_false(resolver.is_initialized())
	var frame := PlayerCommandFrame.new(1, Vector2.ZERO, 0.0, 0.0, Vector3.FORWARD)

	var result := resolver.evaluate(1, frame, Vector3.ZERO)

	assert_eq(result.rejection, GrappleRejection.Reason.MISSING_RESULT)
	assert_eq(result.query_count, 0)
	assert_null(result.accepted_seed)


func test_resolver_initialization_is_typed_and_fails_closed() -> void:
	var fixture := _new_resolver_fixture()
	var body: CharacterBody3D = fixture[0]

	var missing_body := GrappleTargetResolver.new()
	autofree(missing_body)
	var wrong_body := Node3D.new()
	autofree(wrong_body)
	assert_eq(
		missing_body.initialize(null, _valid_definition(), _valid_ray_profile()),
		GrappleTargetResolver.InitializationStatus.MISSING_BODY
	)
	assert_eq(
		missing_body.initialize(wrong_body, _valid_definition(), _valid_ray_profile()),
		GrappleTargetResolver.InitializationStatus.WRONG_BODY
	)

	var missing_definition := GrappleTargetResolver.new()
	autofree(missing_definition)
	assert_eq(
		missing_definition.initialize(body, null, _valid_ray_profile()),
		GrappleTargetResolver.InitializationStatus.MISSING_DEFINITION
	)

	var invalid_definition := GrappleTargetResolver.new()
	autofree(invalid_definition)
	var broken_definition := GrappleDefinition.new()
	assert_eq(
		invalid_definition.initialize(body, broken_definition, _valid_ray_profile()),
		GrappleTargetResolver.InitializationStatus.INVALID_DEFINITION
	)

	var missing_occlusion := GrappleTargetResolver.new()
	autofree(missing_occlusion)
	assert_eq(
		missing_occlusion.initialize(body, _valid_definition(), null),
		GrappleTargetResolver.InitializationStatus.MISSING_OCCLUSION_PROFILE
	)

	var invalid_occlusion := GrappleTargetResolver.new()
	autofree(invalid_occlusion)
	var broken_occlusion := PhysicsQueryProfile.new()
	assert_eq(
		invalid_occlusion.initialize(body, _valid_definition(), broken_occlusion),
		GrappleTargetResolver.InitializationStatus.INVALID_OCCLUSION_PROFILE
	)

	var bad_composition := GrappleTargetResolver.new()
	autofree(bad_composition)
	var definition := _valid_definition()
	assert_eq(definition.validate(), GrappleDefinition.ValidationStatus.SUCCESS)
	assert_eq(
		bad_composition.initialize(body, definition, definition.target_query_profile),
		GrappleTargetResolver.InitializationStatus.INVALID_COMPOSITION
	)

	var success := GrappleTargetResolver.new()
	autofree(success)
	assert_eq(
		success.initialize(body, _valid_definition(), _occlusion_profile()),
		GrappleTargetResolver.InitializationStatus.SUCCESS
	)
	assert_true(success.is_initialized())


func test_diagnostic_snapshot_is_derived_from_the_authoritative_result_only() -> void:
	var target := _new_target()
	var result := _resolve(
		true,
		Vector3(1.0, 2.0, -12.0),
		Vector3.BACK,
		12.0,
		GrappleTargetResolver.HitKind.CANDIDATE,
		target,
		_make_grappleable(&"target.wall_a")
	)
	var snapshot := GrappleTargetingDiagnosticSnapshot.from_result(result)

	assert_not_null(snapshot)
	assert_true(snapshot.is_value_only())
	assert_eq(snapshot.source_physics_step, result.source_physics_step)
	assert_eq(snapshot.command_frame_step, result.command_frame_step)
	assert_eq(snapshot.query_origin, result.query_origin)
	assert_eq(snapshot.query_direction, result.query_direction)
	assert_almost_eq(snapshot.max_grapple_length_m, result.max_grapple_length_m, 0.000001)
	assert_eq(snapshot.hit_position, result.hit_position)
	assert_eq(snapshot.hit_normal, result.hit_normal)
	assert_almost_eq(snapshot.hit_distance_m, result.hit_distance_m, 0.000001)
	assert_eq(snapshot.target_identity, result.target_identity)
	assert_eq(snapshot.is_accepted, result.is_accepted())
	assert_eq(snapshot.rejection, result.rejection)
	assert_eq(
		snapshot.rejection_id,
		GrappleRejection.reason_id(result.rejection)
	)
	assert_almost_eq(snapshot.range_fraction, result.range_fraction, 0.000001)
	assert_eq(snapshot.candidate_profile_id, result.candidate_profile_id)
	assert_eq(snapshot.occlusion_profile_id, result.occlusion_profile_id)
	assert_eq(snapshot.query_count, result.query_count)

	var rejected := _resolve(false, Vector3.ZERO, Vector3.ZERO, 0.0, GrappleTargetResolver.HitKind.CANDIDATE, null, null)
	var rejected_snapshot := GrappleTargetingDiagnosticSnapshot.from_result(rejected)
	assert_false(rejected_snapshot.is_accepted)
	assert_eq(rejected_snapshot.rejection, GrappleRejection.Reason.NO_CANDIDATE)
	assert_eq(rejected_snapshot.rejection_id, &"no_candidate")


func _resolve(
	has_blocking_hit: bool,
	hit_position: Vector3,
	hit_normal: Vector3,
	hit_distance_m: float,
	hit_kind: GrappleTargetResolver.HitKind,
	target: Object,
	explicit_grappleable: Grappleable3D
) -> GrappleTargetingResult:
	return GrappleTargetResolver.resolve_hit_result(
		5,
		5,
		Vector3(0.0, 1.6, 0.0),
		Vector3(0.0, 0.0, -1.0),
		35.0,
		0.005,
		0.001,
		has_blocking_hit,
		hit_position,
		hit_normal,
		hit_distance_m,
		hit_kind,
		target,
		explicit_grappleable,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)


func _valid_definition() -> GrappleDefinition:
	var definition := GrappleDefinition.new()
	definition.definition_id = &"player.grapple.default"
	definition.max_grapple_length_m = 35.0
	definition.acquisition_tolerance_m = 0.005
	definition.target_query_profile = _valid_ray_profile()
	return definition


func _valid_ray_profile() -> PhysicsQueryProfile:
	var profile := PhysicsQueryProfile.new()
	profile.query_kind = PhysicsQueryProfile.QueryKind.RAY
	profile.profile_id = &"player.grapple.candidate"
	profile.collision_mask_names = PackedStringArray(["world_geometry"])
	return profile


func _occlusion_profile() -> PhysicsQueryProfile:
	var profile := PhysicsQueryProfile.new()
	profile.query_kind = PhysicsQueryProfile.QueryKind.RAY
	profile.profile_id = &"player.grapple.occlusion"
	profile.collision_mask_names = PackedStringArray(["world_geometry", "enemy_body"])
	return profile


func _valid_ground_probe() -> GroundProbe:
	var probe := GroundProbe.new()
	var shape := SphereShape3D.new()
	shape.radius = 0.08
	probe.shape = shape
	probe.collision_mask_names = PackedStringArray(["world_geometry"])
	return probe


func _make_grappleable(
	target_id: StringName,
	anchor_mode: GrappleTargetResponse.AnchorMode = GrappleTargetResponse.AnchorMode.STATIC,
	pull_multiplier: float = 1.0,
	directional_adjustment: Vector3 = Vector3.ZERO,
	instability: float = 0.0
) -> Grappleable3D:
	var component := Grappleable3D.new()
	component.name = "Grappleable"
	component.target_id = target_id
	component.anchor_mode = anchor_mode
	component.pull_multiplier = pull_multiplier
	component.directional_adjustment = directional_adjustment
	component.instability = instability
	autofree(component)
	return component


func _new_target() -> StaticBody3D:
	var target := StaticBody3D.new()
	autofree(target)
	return target


func _new_resolver_fixture() -> Array:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var body := CharacterBody3D.new()
	world.add_child(body)

	var resolver := GrappleTargetResolver.new()
	assert_eq(
		resolver.initialize(body, _valid_definition(), _occlusion_profile()),
		GrappleTargetResolver.InitializationStatus.SUCCESS
	)
	return [body, resolver]
