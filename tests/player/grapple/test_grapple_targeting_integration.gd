extends GutTest


const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const PLAYER_CONTROLLER_SCRIPT := preload("res://scripts/player_controller.gd")


func test_default_world_geometry_is_grappleable_without_authored_components() -> void:
	var fixture := _new_targeting_fixture()
	var world: Node3D = fixture[0]
	var resolver: GrappleTargetResolver = fixture[2]
	var wall := _add_box_target(world, Vector3(0.0, 1.0, -8.0), Vector3(4.0, 4.0, 0.4))

	var result := _evaluate(resolver, 1, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))

	assert_true(result.is_accepted(), GrappleRejection.reason_id(result.rejection))
	assert_eq(result.rejection, GrappleRejection.Reason.NONE)
	assert_eq(result.query_count, 1)
	assert_eq(result.target_identity, &"")
	assert_not_null(result.accepted_seed)
	assert_same(result.accepted_seed.response, GrappleTargetResponse.static_default())
	assert_same(result.accepted_seed.get_target(), wall)
	assert_gt(result.hit_position.z, -8.0)
	assert_lte(result.range_fraction, 1.0)


func test_exceptional_grappleable_target_returns_bounded_typed_response() -> void:
	var fixture := _new_targeting_fixture()
	var world: Node3D = fixture[0]
	var resolver: GrappleTargetResolver = fixture[2]
	var platform := _add_box_target(world, Vector3(0.0, 1.0, -8.0), Vector3(4.0, 4.0, 0.4))
	var component := Grappleable3D.new()
	component.name = "Grappleable"
	component.target_id = &"target.moving_platform"
	component.anchor_mode = GrappleTargetResponse.AnchorMode.MOVING
	component.pull_multiplier = 1.5
	component.directional_adjustment = Vector3(0.25, 0.0, 0.0)
	component.instability = 0.4
	component.hazard_response = GrappleTargetResponse.HazardResponse.DAMAGE_ON_ATTACH
	platform.add_child(component)

	var accepted := _evaluate(resolver, 1, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))

	assert_true(accepted.is_accepted(), GrappleRejection.reason_id(accepted.rejection))
	assert_eq(accepted.target_identity, &"target.moving_platform")
	var response: GrappleTargetResponse = accepted.accepted_seed.response
	assert_eq(response.anchor_mode, GrappleTargetResponse.AnchorMode.MOVING)
	assert_almost_eq(response.pull_multiplier, 1.5, 0.000001)
	assert_eq(response.directional_adjustment, Vector3(0.25, 0.0, 0.0))
	assert_almost_eq(response.instability, 0.4, 0.000001)
	assert_eq(
		response.hazard_response,
		GrappleTargetResponse.HazardResponse.DAMAGE_ON_ATTACH
	)
	assert_same(accepted.accepted_seed.get_target(), platform)

	component.eligible = false
	var rejected := _evaluate(resolver, 2, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))
	assert_eq(rejected.rejection, GrappleRejection.Reason.POLICY_REJECTED)
	assert_null(rejected.accepted_seed)

	var source := FileAccess.get_file_as_string("res://game/shared/contracts/grappleable_3d.gd")
	assert_false(source.contains("move_and_slide"), "grappleable_3d.gd must not move bodies")
	assert_false(source.contains("submit_"), "grappleable_3d.gd must not submit motor policy")
	assert_false(source.contains("dispatch_locomotion"), "grappleable_3d.gd must not touch locomotion")
	assert_false(source.contains(".velocity"), "grappleable_3d.gd must not write velocity")


func test_rejected_first_hit_is_never_pierced_to_a_valid_target_behind_it() -> void:
	var fixture := _new_targeting_fixture()
	var world: Node3D = fixture[0]
	var resolver: GrappleTargetResolver = fixture[2]
	var blocker := _add_box_target(world, Vector3(0.0, 1.0, -6.0), Vector3(4.0, 4.0, 0.4))
	var deny := Grappleable3D.new()
	deny.name = "Grappleable"
	deny.target_id = &"target.glass"
	deny.eligible = false
	blocker.add_child(deny)
	_add_box_target(world, Vector3(0.0, 1.0, -12.0), Vector3(4.0, 4.0, 0.4))

	var policy_result := _evaluate(resolver, 1, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))

	assert_eq(policy_result.rejection, GrappleRejection.Reason.POLICY_REJECTED)
	assert_null(policy_result.accepted_seed)
	assert_almost_eq(policy_result.hit_position.z, -5.8, 0.01)

	var occluder := _add_box_target(world, Vector3(0.0, 1.0, -4.0), Vector3(4.0, 4.0, 0.4), 4)
	var occluded_result := _evaluate(resolver, 2, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))

	assert_eq(occluded_result.rejection, GrappleRejection.Reason.OCCLUDED)
	assert_null(occluded_result.accepted_seed)
	assert_almost_eq(occluded_result.hit_position.z, -3.8, 0.01)
	assert_ne(occluded_result.target_identity, &"target.glass")


func test_empty_aim_and_occlusion_only_blocker_report_stable_rejections() -> void:
	var fixture := _new_targeting_fixture()
	var world: Node3D = fixture[0]
	var resolver: GrappleTargetResolver = fixture[2]

	var empty := _evaluate(resolver, 1, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 1.0, 0.0))
	assert_eq(empty.rejection, GrappleRejection.Reason.NO_CANDIDATE)
	assert_eq(empty.query_count, 1)
	assert_null(empty.accepted_seed)

	_add_box_target(world, Vector3(0.0, 1.0, -6.0), Vector3(4.0, 4.0, 0.4), 4)
	var occluded := _evaluate(resolver, 2, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))
	assert_eq(occluded.rejection, GrappleRejection.Reason.OCCLUDED)
	assert_null(occluded.accepted_seed)

	var unexpected_kind := GrappleTargetResolver.resolve_hit_result(
		3,
		3,
		Vector3(0.0, 1.6, 0.0),
		Vector3(0.0, 0.0, -1.0),
		35.0,
		0.005,
		0.001,
		true,
		Vector3(0.0, 1.0, -5.0),
		Vector3.BACK,
		5.0,
		GrappleTargetResolver.HitKind.INELIGIBLE,
		_add_box_target(world, Vector3(9.0, 1.0, -9.0), Vector3(1.0, 1.0, 1.0)),
		null,
		&"player.grapple.candidate",
		&"player.grapple.occlusion",
		1
	)
	assert_eq(unexpected_kind.rejection, GrappleRejection.Reason.INVALID_SURFACE)


func test_maximum_range_boundary_cases_use_one_authoritative_range() -> void:
	var fixture := _new_targeting_fixture()
	var world: Node3D = fixture[0]
	var resolver: GrappleTargetResolver = fixture[2]
	var origin := Vector3(0.0, 1.6, 0.0)
	var aim := Vector3(0.0, 0.0, -1.0)

	var near_max := _add_box_target(world, Vector3(0.0, 1.0, -35.19), Vector3(4.0, 4.0, 0.4))
	var accepted := _evaluate(resolver, 1, origin, aim)
	assert_true(accepted.is_accepted(), GrappleRejection.reason_id(accepted.rejection))
	assert_lte(accepted.range_fraction, 1.0)
	assert_almost_eq(accepted.max_grapple_length_m, 35.0, 0.000001)
	assert_same(accepted.accepted_seed.get_target(), near_max)

	near_max.queue_free()
	await get_tree().physics_frame
	var band_target := _add_box_target(world, Vector3(0.0, 1.0, -35.20375), Vector3(4.0, 4.0, 0.4))
	var out_of_range := _evaluate(resolver, 2, origin, aim)
	assert_eq(out_of_range.rejection, GrappleRejection.Reason.OUT_OF_RANGE)
	assert_gt(out_of_range.range_fraction, 1.0)
	assert_null(out_of_range.accepted_seed)

	band_target.queue_free()
	await get_tree().physics_frame
	_add_box_target(world, Vector3(0.0, 1.0, -37.2), Vector3(4.0, 4.0, 0.4))
	var beyond := _evaluate(resolver, 3, origin, aim)
	assert_eq(beyond.rejection, GrappleRejection.Reason.NO_CANDIDATE)
	assert_eq(beyond.query_count, 1)


func test_duplicate_candidate_shapes_on_one_collider_resolve_to_one_stable_target() -> void:
	var fixture := _new_targeting_fixture()
	var world: Node3D = fixture[0]
	var resolver: GrappleTargetResolver = fixture[2]
	var body := StaticBody3D.new()
	body.position = Vector3(0.0, 1.0, -8.0)
	world.add_child(body)
	for _shape_index in range(2):
		var collision := CollisionShape3D.new()
		var box := BoxShape3D.new()
		box.size = Vector3(4.0, 4.0, 0.4)
		collision.shape = box
		body.add_child(collision)
	var component := Grappleable3D.new()
	component.name = "Grappleable"
	component.target_id = &"target.doubled"
	body.add_child(component)

	var first := _evaluate(resolver, 1, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))
	var second := _evaluate(resolver, 2, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))

	assert_true(first.is_accepted(), GrappleRejection.reason_id(first.rejection))
	assert_true(second.is_accepted(), GrappleRejection.reason_id(second.rejection))
	assert_eq(first.target_identity, &"target.doubled")
	assert_eq(second.target_identity, first.target_identity)
	assert_eq(second.hit_normal, first.hit_normal)
	assert_almost_eq(second.hit_position.x, first.hit_position.x, 0.001)
	assert_almost_eq(second.hit_position.y, first.hit_position.y, 0.001)
	assert_almost_eq(second.hit_position.z, first.hit_position.z, 0.001)
	assert_almost_eq(second.hit_distance_m, first.hit_distance_m, 0.001)
	assert_almost_eq(second.range_fraction, first.range_fraction, 0.001)
	assert_eq(second.query_count, 1)


func test_same_step_activation_seeds_state_and_keeps_pull_playable() -> void:
	var fixture := _new_player_scene_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	_add_box_target(player.get_parent(), Vector3(0.0, 5.0, -20.0), Vector3(20.0, 30.0, 0.4))
	input_source.enable_test_input_seam()

	var found_airborne := false
	for _frame in range(8):
		await get_tree().physics_frame
		var current: PlayerMotorCommitResult = motor.get_last_commit_result()
		if current != null and current.locomotion_state_id == &"player.locomotion.airborne":
			found_airborne = true
			break
	assert_true(found_airborne)

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	player.call("_physics_process", 1.0 / 60.0)

	var result = player.call("get_latest_grapple_targeting_result")
	assert_not_null(result)
	assert_true(result.is_accepted(), GrappleRejection.reason_id(result.rejection))
	assert_eq(result.query_count, 1)
	assert_eq(result.source_physics_step, result.command_frame_step)
	assert_eq(result.source_physics_step, int(player.call("get_motion_step")))
	assert_true(bool(player.get("is_grappling")))
	assert_eq(player.get("grapple_point"), result.accepted_seed.hit_position)
	assert_eq(player.get("grapple_target"), result.accepted_seed.get_target())
	assert_almost_eq(float(player.get("grapple_elapsed")), 0.0, 0.0001)
	assert_almost_eq(float(player.get("grapple_applied_acceleration")), 48.0, 0.0001)
	assert_eq(player.call("get_last_activation_rejection"), GrappleRejection.Reason.NONE)

	for _frame in range(10):
		player.call("_physics_process", 1.0 / 60.0)

	assert_true(bool(player.get("is_grappling")))
	var committed: Vector3 = motor.get_committed_velocity()
	assert_gt(committed.length(), 0.5)
	assert_lte(committed.length(), 22.05)
	var latest = player.call("get_latest_grapple_targeting_result")
	assert_eq(latest.query_count, 1)


func test_stale_or_missing_results_reject_activation_without_partial_state() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	_add_box_target(player.get_parent(), Vector3(0.0, 2.0, -8.0), Vector3(4.0, 4.0, 0.4))
	input_source.enable_test_input_seam()
	await get_tree().physics_frame
	player.call("_physics_process", 1.0 / 60.0)

	var step := int(player.call("get_motion_step"))
	var stale := GrappleTargetResolver.no_query_failure(
		step - 1,
		step - 1,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.STALE_RESULT,
		&"player.grapple.candidate",
		&"player.grapple.occlusion"
	)
	player.set("_current_targeting_result", stale)
	var stale_activation: bool = player.call("try_start_grapple")
	assert_push_error("player.grapple.activation_stale_result")
	assert_false(stale_activation)
	assert_eq(
		player.call("get_last_activation_rejection"),
		GrappleRejection.Reason.STALE_RESULT
	)
	assert_false(bool(player.get("is_grappling")))
	assert_eq(player.get("grapple_point"), Vector3.ZERO)
	assert_null(player.get("grapple_target"))

	player.set("_current_targeting_result", null)
	var missing_activation: bool = player.call("try_start_grapple")
	assert_push_error("player.grapple.activation_missing_result")
	assert_false(missing_activation)
	assert_eq(
		player.call("get_last_activation_rejection"),
		GrappleRejection.Reason.MISSING_RESULT
	)
	assert_false(bool(player.get("is_grappling")))
	assert_null(player.get("grapple_target"))

	var rejected := GrappleTargetResolver.no_query_failure(
		step,
		step,
		Vector3.ZERO,
		Vector3.FORWARD,
		35.0,
		GrappleRejection.Reason.NO_CANDIDATE,
		&"player.grapple.candidate",
		&"player.grapple.occlusion"
	)
	player.set("_current_targeting_result", rejected)
	var rejected_activation: bool = player.call("try_start_grapple")
	assert_false(rejected_activation)
	assert_eq(
		player.call("get_last_activation_rejection"),
		GrappleRejection.Reason.NO_CANDIDATE
	)
	assert_false(bool(player.get("is_grappling")))
	assert_null(player.get("grapple_target"))
	assert_almost_eq(float(player.get("grapple_elapsed")), 0.0, 0.0001)


func test_presentation_consumes_authoritative_result_without_changing_validity() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var marker: GrappleTargetMarker = player.get_node(^"GrappleTargetMarker")
	_add_box_target(player.get_parent(), Vector3(0.0, 2.0, -8.0), Vector3(4.0, 4.0, 0.4))
	await get_tree().physics_frame
	player.call("_physics_process", 1.0 / 60.0)

	var result = player.call("get_latest_grapple_targeting_result")
	assert_not_null(result)
	marker.call("_process", 0.0)
	assert_eq(marker.is_marker_visible(), result.is_accepted())
	assert_eq(marker.get_presented_world_position(), result.hit_position)
	assert_eq(marker.get_presented_target_identity(), result.target_identity)

	marker.grapple_cursor_radius = 5.0
	marker.clear_targeting()
	marker.call("_process", 0.0)
	assert_false(marker.is_marker_visible())

	var unchanged = player.call("get_latest_grapple_targeting_result")
	assert_same(unchanged, result)
	assert_true(unchanged.is_accepted())
	assert_eq(unchanged.query_count, 1)

	player.call("_set_dead")
	marker.call("_process", 0.0)
	assert_false(marker.is_marker_visible())
	assert_null(player.call("get_latest_grapple_targeting_result"))


func test_diagnostics_agree_with_the_authoritative_result() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	_add_box_target(player.get_parent(), Vector3(0.0, 2.0, -8.0), Vector3(4.0, 4.0, 0.4))
	await get_tree().physics_frame
	player.call("_physics_process", 1.0 / 60.0)

	var result = player.call("get_latest_grapple_targeting_result")
	assert_not_null(result)
	var snapshot = player.call("get_grapple_targeting_diagnostic_snapshot")
	assert_not_null(snapshot)
	assert_eq(snapshot.source_physics_step, result.source_physics_step)
	assert_eq(snapshot.query_origin, result.query_origin)
	assert_eq(snapshot.query_direction, result.query_direction)
	assert_almost_eq(snapshot.max_grapple_length_m, result.max_grapple_length_m, 0.000001)
	assert_eq(snapshot.hit_position, result.hit_position)
	assert_eq(snapshot.hit_normal, result.hit_normal)
	assert_eq(snapshot.target_identity, result.target_identity)
	assert_eq(snapshot.is_accepted, result.is_accepted())
	assert_eq(snapshot.rejection, result.rejection)
	assert_almost_eq(snapshot.range_fraction, result.range_fraction, 0.000001)
	assert_eq(snapshot.candidate_profile_id, result.candidate_profile_id)
	assert_eq(snapshot.occlusion_profile_id, result.occlusion_profile_id)
	assert_eq(snapshot.query_count, 1)

	var telemetry: Dictionary = player.call("get_grapple_telemetry")
	assert_eq(telemetry["targeting_valid"], result.is_accepted())
	assert_eq(telemetry["targeting_rejection_id"], GrappleRejection.reason_id(result.rejection))
	assert_almost_eq(float(telemetry["max_grapple_length_m"]), 35.0, 0.000001)
	assert_eq(telemetry["targeting_query_count"], 1)


func test_exactly_one_query_is_counted_for_each_evaluated_step_in_full_flows() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	_add_box_target(player.get_parent(), Vector3(0.0, 2.0, -8.0), Vector3(4.0, 4.0, 0.4))
	input_source.enable_test_input_seam()
	await get_tree().physics_frame

	for _frame in range(6):
		player.call("_physics_process", 1.0 / 60.0)
		var result = player.call("get_latest_grapple_targeting_result")
		assert_not_null(result)
		assert_eq(result.query_count, 1)
		assert_eq(result.source_physics_step, int(player.call("get_motion_step")))
		assert_eq(result.command_frame_step, result.source_physics_step)
		var snapshot = player.call("get_grapple_targeting_diagnostic_snapshot")
		assert_eq(snapshot.query_count, 1)


func test_targeting_acceptance_matches_between_sixty_and_one_twenty_hz() -> void:
	var fixture := _new_targeting_fixture()
	var world: Node3D = fixture[0]
	var resolver: GrappleTargetResolver = fixture[2]
	_add_box_target(world, Vector3(0.0, 1.0, -35.2), Vector3(4.0, 4.0, 0.4))
	var previous_rate := Engine.physics_ticks_per_second

	Engine.physics_ticks_per_second = 60
	var at_sixty := _evaluate(resolver, 1, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))
	Engine.physics_ticks_per_second = 120
	var at_one_twenty := _evaluate(resolver, 2, Vector3(0.0, 1.6, 0.0), Vector3(0.0, 0.0, -1.0))
	Engine.physics_ticks_per_second = previous_rate

	assert_eq(at_sixty.rejection, GrappleRejection.Reason.NONE)
	assert_eq(at_one_twenty.rejection, at_sixty.rejection)
	assert_eq(at_sixty.query_count, at_one_twenty.query_count)
	assert_almost_eq(at_one_twenty.range_fraction, at_sixty.range_fraction, 0.001)
	assert_eq(at_one_twenty.hit_normal, at_sixty.hit_normal)
	assert_almost_eq(
		at_one_twenty.hit_position.z,
		at_sixty.hit_position.z,
		0.01
	)
	assert_eq(at_one_twenty.is_accepted(), at_sixty.is_accepted())


func test_grapple_pull_decay_reaches_the_floor_and_commits_the_speed_cap() -> void:
	var fixture := _new_player_scene_fixture(Vector3(0.0, 12.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	_add_box_target(player.get_parent(), Vector3(0.0, 5.0, -28.0), Vector3(20.0, 30.0, 0.4))
	input_source.enable_test_input_seam()

	var found_airborne := false
	for _frame in range(8):
		await get_tree().physics_frame
		var current: PlayerMotorCommitResult = motor.get_last_commit_result()
		if current != null and current.locomotion_state_id == &"player.locomotion.airborne":
			found_airborne = true
			break
	assert_true(found_airborne)

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	player.call("_physics_process", 1.0 / 60.0)
	assert_true(bool(player.get("is_grappling")))

	var step_delta := 1.0 / 60.0
	var initial_accel := float(player.get("grapple_initial_acceleration"))
	var min_accel := float(player.get("grapple_min_acceleration"))
	var jerk := float(player.get("grapple_acceleration_jerk"))
	var previous_acceleration := float(player.get("grapple_applied_acceleration"))
	var observed_floor := false
	for _step in range(56):
		# Mirror submit_grapple_pull(): the acceleration is computed from the
		# pre-increment elapsed time, then grapple_elapsed advances by delta.
		var elapsed_before := float(player.get("grapple_elapsed"))
		player.call("_physics_process", step_delta)
		if not bool(player.get("is_grappling")):
			break
		var applied := float(player.get("grapple_applied_acceleration"))
		var expected := maxf(min_accel, initial_accel - jerk * elapsed_before)
		observed_floor = observed_floor or absf(applied - min_accel) <= 0.0001
		assert_almost_eq(applied, expected, 0.0001)
		assert_lte(applied, previous_acceleration + 0.0001)
		previous_acceleration = applied
		assert_almost_eq(float(player.get("grapple_elapsed")), elapsed_before + step_delta, 0.000001)
		var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
		assert_not_null(commit)
		assert_true(commit.applied_caps.has(&"player.grapple.speed_cap"))

	assert_true(
		bool(player.get("is_grappling")),
		"pull must not arrive at the target inside the sampled window"
	)
	assert_true(observed_floor, "decay floor reached inside the sampled window")
	assert_almost_eq(
		float(player.get("grapple_applied_acceleration")),
		min_accel,
		0.0001
	)


func test_rope_physics_interpolation_resets_once_per_hidden_to_visible() -> void:
	var fixture := _new_player_scene_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	var rope: MeshInstance3D = player.get("grapple_visual")
	_add_box_target(player.get_parent(), Vector3(0.0, 5.0, -20.0), Vector3(20.0, 30.0, 0.4))
	input_source.enable_test_input_seam()

	var found_airborne := false
	for _frame in range(8):
		await get_tree().physics_frame
		var current: PlayerMotorCommitResult = motor.get_last_commit_result()
		if current != null and current.locomotion_state_id == &"player.locomotion.airborne":
			found_airborne = true
			break
	assert_true(found_airborne)

	assert_eq(int(player.get("grapple_visual_reset_count")), 0)
	assert_false(rope.visible)

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	player.call("_physics_process", 1.0 / 60.0)
	assert_true(bool(player.get("is_grappling")))
	assert_eq(rope.visible, bool(player.get("is_grappling")))
	assert_eq(int(player.get("grapple_visual_reset_count")), 1)

	for _step in range(4):
		player.call("_physics_process", 1.0 / 60.0)
		assert_true(bool(player.get("is_grappling")))
		assert_eq(rope.visible, bool(player.get("is_grappling")))
		assert_eq(int(player.get("grapple_visual_reset_count")), 1)

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	player.call("_physics_process", 1.0 / 60.0)
	assert_false(bool(player.get("is_grappling")))
	assert_eq(rope.visible, bool(player.get("is_grappling")))
	assert_eq(int(player.get("grapple_visual_reset_count")), 1)

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	player.call("_physics_process", 1.0 / 60.0)
	assert_true(bool(player.get("is_grappling")))
	assert_eq(rope.visible, bool(player.get("is_grappling")))
	assert_eq(int(player.get("grapple_visual_reset_count")), 2)

	# The counter is a measurement seam; pin that the frozen behavior it
	# counts still exists: exactly one interpolation reset call site in the
	# controller, at the hidden-to-visible edge.
	var controller_source := FileAccess.get_file_as_string("res://scripts/player_controller.gd")
	assert_eq(
		controller_source.count("grapple_visual.reset_physics_interpolation()"),
		1,
		"rope reset must remain exactly one call site (frozen spec)"
	)
	assert_true(controller_source.contains("if was_hidden:"))


func test_definition_pull_tuning_matches_controller_exports() -> void:
	var fixture := _new_player_scene_fixture()
	var player: CharacterBody3D = fixture[0]
	var definition: GrappleDefinition = player.get("grapple_definition")
	assert_not_null(definition)
	var tolerance: float = PLAYER_CONTROLLER_SCRIPT.PULL_TUNING_PARITY_TOLERANCE
	assert_almost_eq(
		definition.pull_initial_acceleration_mps2,
		float(player.get("grapple_initial_acceleration")),
		tolerance
	)
	assert_almost_eq(
		definition.pull_min_acceleration_mps2,
		float(player.get("grapple_min_acceleration")),
		tolerance
	)
	assert_almost_eq(
		definition.pull_acceleration_jerk_mps3,
		float(player.get("grapple_acceleration_jerk")),
		tolerance
	)
	assert_almost_eq(
		definition.maximum_speed_mps,
		float(player.get("grapple_max_velocity")),
		tolerance
	)

	# Divergence is a composition-time contract violation: the check must fire.
	player.set("grapple_initial_acceleration", 999.0)
	assert_false(bool(player.call("_pull_tuning_matches_definition")))
	player.call("_compose_grapple_targeting")
	assert_push_error("player.grapple.pull_tuning_mismatch")


func test_unavailable_feature_rejects_activation_quietly_without_per_press_invariants() -> void:
	var controller := PLAYER_CONTROLLER_SCRIPT.new()
	autofree(controller)
	assert_false(controller.try_start_grapple())
	assert_eq(
		controller.get_last_activation_rejection(),
		GrappleRejection.Reason.MISSING_RESULT
	)
	assert_false(controller.is_grappling)
	assert_push_error_count(0, "init-failure activation must stay quiet per press")


func _evaluate(
	resolver: GrappleTargetResolver,
	physics_step: int,
	origin: Vector3,
	aim: Vector3
) -> GrappleTargetingResult:
	var frame := PlayerCommandFrame.new(physics_step, Vector2.ZERO, 0.0, 0.0, aim)
	var result := resolver.evaluate(physics_step, frame, origin)
	assert_not_null(result)
	return result


func _definition_with_max(max_grapple_length_m: float) -> GrappleDefinition:
	var definition := GrappleDefinition.new()
	definition.definition_id = &"player.grapple.default"
	definition.max_grapple_length_m = max_grapple_length_m
	definition.acquisition_tolerance_m = 0.005
	definition.target_query_profile = _ray_profile(&"player.grapple.candidate", ["world_geometry"])
	return definition


func _ray_profile(profile_id: StringName, mask_names: Array) -> PhysicsQueryProfile:
	var profile := PhysicsQueryProfile.new()
	profile.query_kind = PhysicsQueryProfile.QueryKind.RAY
	profile.profile_id = profile_id
	profile.collision_mask_names = PackedStringArray(mask_names)
	return profile


func _add_box_target(
	world: Node3D,
	target_position: Vector3,
	size: Vector3,
	layer: int = 1
) -> StaticBody3D:
	var body := StaticBody3D.new()
	body.position = target_position
	body.collision_layer = layer
	world.add_child(body)
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = size
	collision.shape = box
	body.add_child(collision)
	return body


func _new_targeting_fixture() -> Array:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var body := CharacterBody3D.new()
	var body_shape := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.45
	capsule.height = 1.8
	body_shape.shape = capsule
	body_shape.position.y = 0.9
	body.add_child(body_shape)
	world.add_child(body)
	body.global_position = Vector3(0.0, 1.0, 0.0)

	var resolver := GrappleTargetResolver.new()
	var occlusion := _ray_profile(
		&"player.grapple.occlusion",
		["world_geometry", "enemy_body"]
	)
	assert_eq(
		resolver.initialize(body, _definition_with_max(35.0), occlusion),
		GrappleTargetResolver.InitializationStatus.SUCCESS
	)
	return [world, body, resolver]


func _new_player_scene_fixture(
	player_position: Vector3 = Vector3(0.0, 0.1, 0.0)
) -> Array[Node]:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var floor := StaticBody3D.new()
	world.add_child(floor)
	var floor_shape := CollisionShape3D.new()
	var floor_box := BoxShape3D.new()
	floor_box.size = Vector3(40.0, 0.2, 40.0)
	floor_shape.shape = floor_box
	floor.add_child(floor_shape)

	var player: CharacterBody3D = PLAYER_SCENE.instantiate()
	player.set("capture_mouse_on_start", false)
	player.position = player_position
	world.add_child(player)
	return [player]
