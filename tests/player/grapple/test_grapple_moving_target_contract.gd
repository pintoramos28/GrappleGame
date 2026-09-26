extends GutTest


## Story 1.8 contract tests: target-relative attachment state, the
## `GrappleAnchorState` value record, the query-only sampling API, one sampled
## state consumed per physics step, relative-motion maximum-distance math (pure
## cases on a real motor fixture), typed invalidation/scope termination,
## discontinuity tolerances, and read-only diagnostics exposure.
##
## Real-Jolt player-scene scenarios live in
## `test_grapple_moving_target_integration.gd`; Story 1.7 static-boundary
## contracts stay in `test_grapple_boundary_contract.gd`.


const TOLERANCE := 0.0001
const POSITION_TOLERANCE := 0.001


## ---- Task 2.1: value-only anchor state ---------------------------------


func test_anchor_state_is_a_value_only_record_with_typed_fields() -> void:
	var response := GrappleTargetResponse.new(
		true,
		GrappleTargetResponse.AnchorMode.MOVING,
		2.0,
		Vector3.ZERO,
		0.25,
		GrappleTargetResponse.HazardResponse.NONE
	)
	var state := GrappleAnchorState.new(
		Vector3(1.0, 2.0, 3.0),
		Vector3(0.0, 0.0, -4.0),
		true,
		GrappleAnchorState.InvalidationReason.NONE,
		&"encounter.run_a",
		response
	)
	assert_true(state.is_value_only(), "GrappleAnchorState must stay value-only")
	assert_eq(state.anchor_world_position, Vector3(1.0, 2.0, 3.0))
	assert_eq(state.target_velocity, Vector3(0.0, 0.0, -4.0))
	assert_true(state.is_valid)
	assert_eq(state.invalidation_reason, GrappleAnchorState.InvalidationReason.NONE)
	assert_eq(state.scope_identity, &"encounter.run_a")
	assert_not_null(state.response)
	assert_eq(int(state.response.anchor_mode), int(GrappleTargetResponse.AnchorMode.MOVING))
	assert_almost_eq(state.response.pull_multiplier, 2.0, TOLERANCE)
	assert_almost_eq(state.response.instability, 0.25, TOLERANCE)


func test_anchor_state_invalidation_reason_is_a_closed_typed_set() -> void:
	var reason_names := GrappleAnchorState.InvalidationReason.keys()
	assert_eq(reason_names.size(), 4, "the invalidation set stays closed")
	assert_eq(reason_names[0], "NONE")
	assert_eq(reason_names[1], "TARGET_INVALIDATED")
	assert_eq(reason_names[2], "TARGET_DESTROYED")
	assert_eq(reason_names[3], "SCOPE_MISMATCH")


## ---- Task 2.2: query-only sampling API ---------------------------------


func test_ordinary_geometry_sampling_keeps_the_static_default_response() -> void:
	var hit_position := Vector3(1.5, 2.0, -3.0)
	var state := GrappleAnchorState.static_default(hit_position)
	assert_true(state.is_value_only())
	assert_true(state.is_valid)
	assert_eq(state.anchor_world_position, hit_position)
	assert_eq(state.target_velocity, Vector3.ZERO)
	assert_eq(int(state.response.anchor_mode), int(GrappleTargetResponse.AnchorMode.STATIC))
	assert_same(state.response, GrappleTargetResponse.static_default())
	assert_eq(state.scope_identity, &"")
	# The static default is the same record every step (frozen world anchor).
	var second := GrappleAnchorState.static_default(hit_position)
	assert_eq(second.anchor_world_position, state.anchor_world_position)


func test_static_component_sampling_returns_a_frozen_anchor_and_zero_velocity() -> void:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.STATIC)
	var component: Grappleable3D = fixture[0]
	var body: StaticBody3D = fixture[1]
	var hit_position := body.global_transform * Vector3(1.0, 0.5, -0.2)
	var offset := body.global_transform.affine_inverse() * hit_position

	var first := component.sample_anchor_state(offset, 1.0 / 60.0, hit_position)
	assert_true(first.is_valid)
	assert_eq(first.anchor_world_position, hit_position, "the frozen anchor is the initial sample")
	assert_eq(first.target_velocity, Vector3.ZERO)

	body.global_position += Vector3(5.0, 0.0, 0.0)
	var second := component.sample_anchor_state(offset, 1.0 / 60.0, hit_position)
	assert_eq(
		second.anchor_world_position,
		first.anchor_world_position,
		"a static anchor is frozen in world space"
	)
	assert_eq(second.target_velocity, Vector3.ZERO)


func test_moving_component_sampling_follows_translation_and_rotation() -> void:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.MOVING)
	var component: Grappleable3D = fixture[0]
	var body: StaticBody3D = fixture[1]
	var hit_position := body.global_transform * Vector3(1.0, 0.5, -0.2)
	var offset := body.global_transform.affine_inverse() * hit_position

	var first := component.sample_anchor_state(offset, 1.0 / 60.0, hit_position)
	assert_true(first.is_valid)
	assert_almost_eq(
		first.anchor_world_position.distance_to(hit_position),
		0.0,
		POSITION_TOLERANCE
	)

	# Translation carries the attachment point.
	body.global_position += Vector3(2.0, 1.0, -3.0)
	var translated := component.sample_anchor_state(offset, 1.0 / 60.0, hit_position)
	assert_almost_eq(
		translated.anchor_world_position.distance_to(hit_position + Vector3(2.0, 1.0, -3.0)),
		0.0,
		POSITION_TOLERANCE
	)

	# Rotation carries the stored local hit point with the body.
	var previous := translated.anchor_world_position
	body.rotate(Vector3.UP, PI * 0.5)
	var rotated := component.sample_anchor_state(offset, 1.0 / 60.0, hit_position)
	var expected_after_rotation := (
		body.global_position + body.global_transform.basis * Vector3(1.0, 0.5, -0.2)
	)
	assert_almost_eq(
		rotated.anchor_world_position.x,
		expected_after_rotation.x,
		0.001,
		"rotation moves the anchor with the body"
	)
	assert_almost_eq(rotated.anchor_world_position.y, expected_after_rotation.y, 0.001)
	assert_almost_eq(rotated.anchor_world_position.z, expected_after_rotation.z, 0.001)
	assert_almost_eq(
		rotated.anchor_world_position.distance_to(body.global_position),
		Vector3(1.0, 0.5, -0.2).length(),
		0.001,
		"rotation preserves the offset radius"
	)
	assert_false(
		rotated.anchor_world_position.is_equal_approx(previous),
		"rotation moves the anchor with the body"
	)


func test_sampling_reports_explicit_invalidation_and_eligibility_changes() -> void:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.MOVING)
	var component: Grappleable3D = fixture[0]
	assert_true(component.is_grapple_anchor_valid())
	var live := component.sample_anchor_state(Vector3.ZERO, 1.0 / 60.0, Vector3.ZERO)
	assert_true(live.is_valid)
	assert_eq(live.invalidation_reason, GrappleAnchorState.InvalidationReason.NONE)

	component.invalidate_grapple_anchor()
	assert_false(component.is_grapple_anchor_valid())
	var invalidated := component.sample_anchor_state(Vector3.ZERO, 1.0 / 60.0, Vector3.ZERO)
	assert_false(invalidated.is_valid)
	assert_eq(
		invalidated.invalidation_reason,
		GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED
	)


func test_sampling_reports_the_target_scope_identity() -> void:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.MOVING)
	var component: Grappleable3D = fixture[0]
	component.encounter_scope_identity = &"encounter.run_b"
	var state := component.sample_anchor_state(Vector3.ZERO, 1.0 / 60.0, Vector3.ZERO)
	assert_eq(state.scope_identity, &"encounter.run_b")
	assert_true(state.is_valid, "scope mismatch is decided player-side, not by the target")


func test_sampling_api_is_query_only_and_cannot_touch_player_state() -> void:
	# Structural contract (source scan over non-comment code): the cross-domain
	# target contract never references motor/player writers and never moves a
	# body.
	for path in [
		"res://game/shared/contracts/grappleable_3d.gd",
		"res://game/shared/contracts/grapple_anchor_state.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		for line in source.split("\n"):
			if line.strip_edges().begins_with("#"):
				continue
			assert_false(line.contains("move_and_slide"), "%s never moves a body" % path)
			assert_false(line.contains("PlayerMotor"), "%s never touches the motor" % path)
			assert_false(line.contains("submit_"), "%s never submits influences" % path)
			assert_false(line.contains("get_tree"), "%s holds no scene access" % path)


## ---- Task 2.3: target-velocity reporting -------------------------------


func test_supplied_anchor_velocity_is_reported_when_the_target_authors_one() -> void:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.MOVING)
	var component: Grappleable3D = fixture[0]
	component.supply_anchor_velocity(Vector3(0.0, 0.0, -6.0))
	var first := component.sample_anchor_state(Vector3.ZERO, 1.0 / 60.0, Vector3.ZERO)
	assert_eq(first.target_velocity, Vector3(0.0, 0.0, -6.0))
	var second := component.sample_anchor_state(Vector3.ZERO, 1.0 / 60.0, Vector3.ZERO)
	assert_eq(second.target_velocity, Vector3(0.0, 0.0, -6.0))
	component.clear_supplied_anchor_velocity()
	var third := component.sample_anchor_state(Vector3.ZERO, 1.0 / 60.0, Vector3.ZERO)
	assert_eq(third.target_velocity, Vector3.ZERO)


func test_anchor_velocity_finite_difference_is_rate_equivalent() -> void:
	# A 12 m/s translation must report the same velocity at 60 Hz and 120 Hz
	# (NFR4): the derivation is displacement / delta_seconds.
	var at_sixty := _sample_translation_speed(60.0, 12.0)
	var at_one_twenty := _sample_translation_speed(120.0, 12.0)
	assert_almost_eq(at_sixty, 12.0, 0.05)
	assert_almost_eq(at_one_twenty, 12.0, 0.05)
	assert_almost_eq(at_sixty, at_one_twenty, 0.05)


func _sample_translation_speed(tick_rate: float, speed_mps: float) -> float:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.MOVING)
	var component: Grappleable3D = fixture[0]
	var body: StaticBody3D = fixture[1]
	var offset := body.global_transform.affine_inverse() * body.global_position
	var delta := 1.0 / tick_rate
	component.sample_anchor_state(offset, delta, body.global_position)
	body.global_position += Vector3(0.0, 0.0, -speed_mps * delta)
	var second := component.sample_anchor_state(offset, delta, body.global_position)
	return second.target_velocity.length()


## ---- Task 1: target-relative attachment state ---------------------------


func test_attachment_stores_target_relative_state_and_initial_sample_only() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	var hit_position := Vector3(2.0, 3.0, -8.0)
	var local_offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, local_offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_eq(attachment.target_identity, &"target.moving_case")
	assert_true(attachment.has_live_target())
	assert_same(attachment.get_target(), target)
	assert_eq(attachment.target_local_hit_offset, local_offset)
	# The frozen world hit position is the initial sample only; the ongoing
	# anchor is whatever the sampling phase records.
	assert_eq(attachment.anchor_world_position, hit_position)
	var moved := GrappleAnchorState.new(
		hit_position + Vector3(4.0, 0.0, 0.0),
		Vector3(60.0, 0.0, 0.0),
		true,
		GrappleAnchorState.InvalidationReason.NONE,
		&"",
		GrappleTargetResponse.static_default()
	)
	attachment.record_sampled_anchor_state(moved, 8)
	assert_eq(attachment.anchor_world_position, hit_position + Vector3(4.0, 0.0, 0.0))
	assert_same(attachment.get_sampled_anchor_state(), moved)


func test_attachment_stores_full_response_values_and_optional_scope_identity() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	var response := GrappleTargetResponse.new(
		true,
		GrappleTargetResponse.AnchorMode.MOVING,
		1.5,
		Vector3.ZERO,
		0.5
	)
	var target_seed := GrappleTargetSeed.new(
		&"target.moving_case",
		Vector3.ZERO,
		Vector3(0.0, 0.0, 1.0),
		response,
		weakref(target),
		Vector3.ZERO
	)
	controller.set_scope_identity_provider(_constant_scope(&"encounter.run_a"))
	assert_eq(controller.get_originating_scope_identity(), &"encounter.run_a")
	assert_eq(
		controller.commit_attachment(target_seed, 3),
		GrappleController.CommitStatus.SUCCESS
	)
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_not_null(attachment.response)
	assert_true(attachment.response.is_value_only(), "the stored response stays value-only")
	assert_almost_eq(attachment.response.pull_multiplier, 1.5, TOLERANCE)
	assert_almost_eq(attachment.response.instability, 0.5, TOLERANCE)
	assert_eq(
		int(attachment.response.anchor_mode),
		int(GrappleTargetResponse.AnchorMode.MOVING)
	)
	assert_eq(attachment.originating_scope_identity, &"encounter.run_a")


func test_attachment_resolution_stays_occurrence_local_and_never_mutates_definitions() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	var definition: GrappleDefinition = fixture[2]
	var response := GrappleTargetResponse.new(
		true,
		GrappleTargetResponse.AnchorMode.MOVING,
		1.0,
		Vector3.ZERO,
		1.0
	)
	var target_seed := GrappleTargetSeed.new(
		&"target.moving_case",
		Vector3.ZERO,
		Vector3(0.0, 0.0, 1.0),
		response,
		weakref(target),
		Vector3.ZERO
	)
	assert_eq(controller.commit_attachment(target_seed, 3), GrappleController.CommitStatus.SUCCESS)
	var attachment: GrappleAttachment = controller.get_attachment()
	# Instability (0..1) scales the discontinuity tolerances down by at most
	# half, occurrence-locally (Task 6.1).
	assert_almost_eq(
		attachment.resolved_continuous_motion_tolerance_mps,
		definition.anchor_continuous_motion_tolerance_mps * 0.5,
		TOLERANCE
	)
	assert_almost_eq(
		attachment.resolved_severe_discontinuity_threshold_mps,
		definition.anchor_severe_discontinuity_threshold_mps * 0.5,
		TOLERANCE
	)
	assert_true(attachment.is_definition_unmodified())
	assert_almost_eq(definition.anchor_continuous_motion_tolerance_mps, 50.0, TOLERANCE)
	assert_almost_eq(definition.anchor_severe_discontinuity_threshold_mps, 250.0, TOLERANCE)
	# A shared value record is never mutated by sampling or resolution.
	var shared_key := GrappleTargetResponse.static_default().get_stable_content_key()
	attachment.record_sampled_anchor_state(
		GrappleAnchorState.static_default(Vector3.ZERO),
		4
	)
	assert_eq(GrappleTargetResponse.static_default().get_stable_content_key(), shared_key)


## ---- Task 3: one sample per physics step, one consumed sample -----------


func test_sampling_phase_runs_once_per_step_and_submissions_consume_the_sample() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var body: CharacterBody3D = scene[2]
	var motor: PlayerMotor = scene[3]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)

	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	var sample: GrappleAnchorState = controller.get_sampled_anchor_state()
	assert_not_null(sample)
	assert_eq(sample.anchor_world_position, hit_position)
	target.global_position += Vector3(3.0, 0.0, 0.0)
	assert_true(controller.sample_anchor_state(9, 1.0 / 60.0))
	var second_sample: GrappleAnchorState = controller.get_sampled_anchor_state()
	assert_false(is_same(second_sample, sample), "each step stores one fresh sample")
	assert_almost_eq(
		second_sample.anchor_world_position.x,
		hit_position.x + 3.0,
		POSITION_TOLERANCE
	)

	assert_eq(motor.begin_motion_frame(9, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.locomotion.grappling"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grappling.base",
			Vector3.ZERO,
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		controller.submit_motor_influences(motor, 1.0 / 60.0, 9),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	controller.record_committed_facts(result)

	# Pull direction and boundary data come from the SAME stored sample.
	var records := result.anchor_constraint_records
	assert_eq(records.size(), 1)
	assert_eq(
		records[0]["anchor_position"],
		second_sample.anchor_world_position,
		"the boundary consumes the sampled anchor position"
	)
	assert_eq(
		records[0]["anchor_velocity"],
		second_sample.target_velocity,
		"the boundary consumes the sampled anchor velocity"
	)
	assert_almost_eq(
		float(records[0]["carry_tolerance_mps"]),
		controller.get_attachment().resolved_continuous_motion_tolerance_mps,
		TOLERANCE,
		"the boundary payload carries the resolved carry tolerance (review fix)"
	)
	var snapshot: GrappleAttachmentDiagnosticSnapshot = controller.get_diagnostic_snapshot()
	assert_eq(snapshot.anchor_world_position, second_sample.anchor_world_position)
	assert_eq(snapshot.target_velocity_mps, second_sample.target_velocity)
	var expected_pull := body.global_position.direction_to(second_sample.anchor_world_position)
	assert_almost_eq(snapshot.pull_direction.x, expected_pull.x, TOLERANCE)


## ---- Task 5: end-reason schema, typed invalidation, idempotency ---------


func test_end_reason_schema_extends_the_locked_prefix_append_only() -> void:
	var names := GrappleEndReason.Reason.keys()
	assert_eq(names.size(), 9, "GrappleEndReason is a closed 9-value set")
	assert_eq(names[0], "NONE")
	assert_eq(names[1], "RELEASE")
	assert_eq(names[2], "TARGET_INVALIDATED")
	assert_eq(names[3], "OWNER_DEATH")
	assert_eq(names[4], "STATE_CANCELLATION")
	assert_eq(names[5], "GROUND_CONTACT")
	assert_eq(names[6], "TARGET_DESTROYED")
	assert_eq(names[7], "SCOPE_MISMATCH")
	assert_eq(names[8], "ANCHOR_DISCONTINUITY")
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.TARGET_DESTROYED),
		&"target_destroyed"
	)
	assert_eq(GrappleEndReason.reason_id(GrappleEndReason.Reason.SCOPE_MISMATCH), &"scope_mismatch")
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.ANCHOR_DISCONTINUITY),
		&"anchor_discontinuity"
	)
	assert_false(GrappleEndReason.is_valid_reason(int(GrappleEndReason.Reason.NONE)))
	assert_true(
		GrappleEndReason.is_valid_reason(int(GrappleEndReason.Reason.ANCHOR_DISCONTINUITY))
	)
	assert_eq(GrappleEndReason.reason_id(-5), &"invalid")
	assert_eq(GrappleEndReason.reason_id(4096), &"invalid")


func test_freed_target_terminates_exactly_once_with_target_destroyed() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	assert_eq(
		controller.commit_attachment(_static_seed(target, Vector3.ZERO), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	var ended_events: Array = []
	controller.attachment_ended.connect(
		func(attachment_id: StringName, reason: GrappleEndReason.Reason) -> void:
			ended_events.append([attachment_id, reason])
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))

	target.queue_free()
	await get_tree().process_frame
	assert_false(controller.sample_anchor_state(9, 1.0 / 60.0))
	assert_false(controller.has_active_attachment())
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_true(attachment.has_committed_terminal())
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.TARGET_DESTROYED)
	assert_eq(ended_events.size(), 1, "the terminal commits exactly once")
	assert_false(controller.sample_anchor_state(10, 1.0 / 60.0))
	assert_eq(ended_events.size(), 1)
	var terminal := attachment.get_terminal()
	assert_not_null(terminal)
	# Idempotency: a later read returns the SAME committed record (review fix:
	# the previous assertion compared one getter with itself and could not fail).
	assert_same(attachment.get_terminal(), terminal)


func test_explicit_invalidation_terminates_with_target_invalidated() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var component: Grappleable3D = Grappleable3D.find_explicit_grappleables(target)[0]
	assert_eq(
		controller.commit_attachment(
			_moving_seed(target, target.global_position, Vector3.ZERO),
			7
		),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))

	component.invalidate_grapple_anchor()
	assert_false(controller.sample_anchor_state(9, 1.0 / 60.0))
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.TARGET_INVALIDATED)


func test_scope_mismatch_terminates_with_scope_mismatch() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var component: Grappleable3D = Grappleable3D.find_explicit_grappleables(target)[0]
	component.encounter_scope_identity = &"encounter.run_b"
	controller.set_scope_identity_provider(_constant_scope(&"encounter.run_a"))
	assert_eq(
		controller.commit_attachment(
			_moving_seed(target, target.global_position, Vector3.ZERO),
			7
		),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_false(controller.sample_anchor_state(8, 1.0 / 60.0))
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.SCOPE_MISMATCH)


func test_overlapping_same_step_termination_requests_commit_once() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	assert_eq(
		controller.commit_attachment(_static_seed(target, Vector3.ZERO), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	var ended_events: Array = []
	controller.attachment_ended.connect(
		func(attachment_id: StringName, reason: GrappleEndReason.Reason) -> void:
			ended_events.append([attachment_id, reason])
	)
	var first := controller.terminate(GrappleEndReason.Reason.RELEASE, 8)
	assert_not_null(first)
	assert_eq(
		controller.terminate(GrappleEndReason.Reason.OWNER_DEATH, 8),
		first,
		"duplicate requests return the committed terminal unchanged"
	)
	assert_eq(controller.terminate(GrappleEndReason.Reason.TARGET_DESTROYED, 8), first)
	assert_eq(first.reason, GrappleEndReason.Reason.RELEASE)
	assert_eq(ended_events.size(), 1, "attachment_ended fires exactly once")


## ---- Task 6: discontinuity tolerances ----------------------------------


func test_definition_gains_immutable_anchor_motion_tolerances() -> void:
	var definition := GrappleDefinition.new()
	definition.definition_id = &"player.grapple.default"
	definition.max_grapple_length_m = 35.0
	definition.acquisition_tolerance_m = 0.005
	definition.target_query_profile = _ray_profile()
	assert_eq(definition.validate(), GrappleDefinition.ValidationStatus.SUCCESS)
	assert_true(definition.is_locked())

	var broken := GrappleDefinition.new()
	broken.definition_id = &"player.grapple.default"
	broken.max_grapple_length_m = 35.0
	broken.acquisition_tolerance_m = 0.005
	broken.target_query_profile = _ray_profile()
	broken.anchor_continuous_motion_tolerance_mps = 300.0
	broken.anchor_severe_discontinuity_threshold_mps = 250.0
	assert_eq(broken.validate(), GrappleDefinition.ValidationStatus.INVALID_TOLERANCE)

	var non_finite := GrappleDefinition.new()
	non_finite.definition_id = &"player.grapple.default"
	non_finite.max_grapple_length_m = 35.0
	non_finite.acquisition_tolerance_m = 0.005
	non_finite.target_query_profile = _ray_profile()
	non_finite.anchor_severe_discontinuity_threshold_mps = 0.0
	assert_eq(non_finite.validate(), GrappleDefinition.ValidationStatus.INVALID_TOLERANCE)


func test_severe_anchor_discontinuity_terminates_before_any_submission() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var motor: PlayerMotor = scene[3]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	# A 10 m one-step jump implies 600 m/s at 60 Hz: far above the severe
	# threshold at either diagnostic rate.
	target.global_position += Vector3(10.0, 0.0, 0.0)
	assert_false(controller.sample_anchor_state(9, 1.0 / 60.0))
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.ANCHOR_DISCONTINUITY)
	# "Terminates BEFORE any submission" (AC 7, review fix): the terminated step
	# must refuse every grapple submission and the commit carries none of them.
	assert_eq(motor.begin_motion_frame(9, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.locomotion.grappling"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grappling.base",
			Vector3.ZERO,
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		controller.submit_motor_influences(motor, 1.0 / 60.0, 9),
		PlayerMotor.SubmissionStatus.NO_ACTIVE_ATTACHMENT
	)
	assert_eq(
		controller.submit_speed_cap(motor, 9),
		PlayerMotor.SubmissionStatus.NO_ACTIVE_ATTACHMENT
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_false(result.applied_constraints.has(&"player.grapple.maximum_distance"))
	assert_false(result.applied_caps.has(&"player.grapple.speed_cap"))


func test_continuous_anchor_motion_follows_normally() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	target.global_position += Vector3(12.0 / 60.0, 0.0, 0.0)
	assert_true(controller.sample_anchor_state(9, 1.0 / 60.0))
	assert_true(controller.has_active_attachment())
	var sample: GrappleAnchorState = controller.get_sampled_anchor_state()
	assert_almost_eq(sample.target_velocity.x, 12.0, 0.05)


## ---- Task 4: relative-motion boundary resolution -----------------------
##
## Geometry: the anchor sits at the world origin and the player at
## `+z * distance`, so the outward radial axis is `+z`. A separating anchor
## moves along `-z`; an approaching anchor along `+z`.


func test_static_anchor_boundary_reduces_to_story_1_7_math() -> void:
	var outcome := _resolve_boundary(
		Vector3(0.0, 0.0, 12.0),
		Vector3.ZERO,
		Vector3.ZERO,
		35.0
	)
	var resolved: Vector3 = outcome[0]
	var record: Dictionary = outcome[1]
	# Outward radial motion is clipped exactly as Story 1.7 did.
	assert_true(bool(record["correction_applied"]))
	assert_almost_eq(float(record["correction_mps"]), 12.0, TOLERANCE)
	assert_almost_eq(float(record["carry_applied_mps"]), 0.0, TOLERANCE)
	assert_almost_eq(resolved.z, 0.0, TOLERANCE)


func test_separating_anchor_carry_matches_the_anchor_radial_speed() -> void:
	# Player idle at the boundary while the anchor separates at 5 m/s along the
	# radial axis: the player receives exactly the anchor's separating radial
	# motion - no more (AC 4).
	var outcome := _resolve_boundary(
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3(0.0, 0.0, -5.0),
		35.0
	)
	var resolved: Vector3 = outcome[0]
	var record: Dictionary = outcome[1]
	assert_almost_eq(resolved.z, -5.0, TOLERANCE)
	assert_almost_eq(float(record["carry_applied_mps"]), 5.0, TOLERANCE)
	assert_false(bool(record["carry_refused"]))
	assert_almost_eq(float(record["radial_velocity_mps"]), -5.0, TOLERANCE)


func test_inward_motion_is_never_clipped_or_carried_past_the_anchor_speed() -> void:
	var outcome := _resolve_boundary(
		Vector3(0.0, 0.0, -8.0),
		Vector3.ZERO,
		Vector3(0.0, 0.0, -5.0),
		35.0
	)
	var resolved: Vector3 = outcome[0]
	var record: Dictionary = outcome[1]
	# Inward faster than the anchor separates: free inward motion stays.
	assert_almost_eq(resolved.z, -8.0, TOLERANCE)
	assert_almost_eq(float(record["correction_mps"]), 0.0, TOLERANCE)
	assert_almost_eq(float(record["carry_applied_mps"]), 0.0, TOLERANCE)


func test_tangential_motion_is_untouched_at_the_boundary() -> void:
	var outcome := _resolve_boundary(
		Vector3(14.0, 0.0, -2.0),
		Vector3.ZERO,
		Vector3(0.0, 0.0, -5.0),
		35.0
	)
	var resolved: Vector3 = outcome[0]
	assert_almost_eq(resolved.x, 14.0, TOLERANCE)
	# The radial component is exactly the anchor's separating radial motion.
	assert_almost_eq(resolved.z, -5.0, TOLERANCE)


func test_approaching_anchor_never_pushes_the_player() -> void:
	var outcome := _resolve_boundary(
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3(0.0, 0.0, 6.0),
		35.0
	)
	var resolved: Vector3 = outcome[0]
	var record: Dictionary = outcome[1]
	assert_almost_eq(resolved.z, 0.0, TOLERANCE, "an approaching anchor transfers no motion")
	assert_almost_eq(float(record["carry_applied_mps"]), 0.0, TOLERANCE)

	# An approaching anchor only lets the player keep the relative-slack motion:
	# the outward radial speed relative to the anchor still cannot grow the
	# distance past the maximum.
	var outward := _resolve_boundary(
		Vector3(0.0, 0.0, 10.0),
		Vector3.ZERO,
		Vector3(0.0, 0.0, 6.0),
		35.0
	)
	assert_almost_eq((outward[0] as Vector3).z, 6.0, TOLERANCE)


func test_required_carry_above_the_discontinuity_tolerance_is_refused() -> void:
	# A supplied target velocity of 200 m/s separates the anchor without any
	# position motion: the required carry exceeds the 50 m/s continuous
	# tolerance, so the constraint refuses it and records the refusal (AC 4).
	var outcome := _resolve_boundary(
		Vector3.ZERO,
		Vector3.ZERO,
		Vector3(0.0, 0.0, -200.0),
		35.0,
		50.0
	)
	var resolved: Vector3 = outcome[0]
	var record: Dictionary = outcome[1]
	assert_almost_eq(resolved.z, 0.0, TOLERANCE, "the refused carry snaps nothing")
	assert_true(bool(record["carry_refused"]))
	assert_almost_eq(float(record["carry_refused_mps"]), 200.0, TOLERANCE)
	assert_almost_eq(float(record["carry_applied_mps"]), 0.0, TOLERANCE)


## ---- Task 7: read-only diagnostics exposure ----------------------------


func test_snapshot_exposes_sampled_anchor_facts_without_mutation_paths() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	target.global_position += Vector3(1.0, 0.0, 0.0)
	assert_true(controller.sample_anchor_state(9, 1.0 / 60.0))
	var snapshot: GrappleAttachmentDiagnosticSnapshot = controller.get_diagnostic_snapshot()
	assert_true(snapshot.is_value_only())
	assert_true(snapshot.anchor_valid)
	assert_eq(snapshot.anchor_status_id, &"valid")
	assert_eq(
		snapshot.anchor_world_position,
		controller.get_sampled_anchor_state().anchor_world_position
	)
	assert_almost_eq(snapshot.target_velocity_mps.x, 60.0, 0.05)
	assert_eq(snapshot.terminal_reason, GrappleEndReason.Reason.NONE)

	# Read-only: the snapshot type declares no mutators.
	var source := FileAccess.get_file_as_string(
		"res://game/player/abilities/grapple/grapple_attachment_diagnostic_snapshot.gd"
	)
	for line in source.split("\n"):
		if line.strip_edges().begins_with("#"):
			continue
		assert_false(line.contains("func set_"), "diagnostics stay read-only")


## ---- Sampling cadence and targeting discipline -------------------------


func test_moving_anchor_follow_repeats_no_target_selection_raycast() -> void:
	# Source-scan contract (Task 3.3): the sampling/follow path is transform
	# math in the shared contract and the grapple runtime - neither file issues
	# a physics query.
	for path in [
		"res://game/shared/contracts/grappleable_3d.gd",
		"res://game/shared/contracts/grapple_anchor_state.gd",
		"res://game/player/abilities/grapple/grapple_attachment.gd",
		"res://game/player/abilities/grapple/grapple_controller.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		for line in source.split("\n"):
			if line.strip_edges().begins_with("#"):
				continue
			assert_false(line.contains("intersect_ray"), "%s must not raycast" % path)
			assert_false(
				line.contains("PhysicsRayQueryParameters3D"),
				"%s must not raycast" % path
			)


## ---- Story 1.8 review fixes (2026-09-25) -------------------------------
##
## Regression coverage for the code-review findings: stale-sample guards,
## per-occurrence sampling baselines, commit-step sampling, carry-refusal
## termination wiring, payload bounds, value-only purity, and read-only
## consumer boundaries.


func test_sampling_is_idempotent_within_one_step_and_never_re_samples() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	var first_sample: GrappleAnchorState = controller.get_sampled_anchor_state()
	target.global_position += Vector3(5.0, 0.0, 0.0)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	assert_same(
		controller.get_sampled_anchor_state(),
		first_sample,
		"one sample per step: the second call returns the earlier verdict"
	)
	assert_eq(controller.get_attachment().get_sampled_anchor_step(), 8)


func test_submissions_refuse_a_sample_from_another_step() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var body: CharacterBody3D = scene[2]
	var motor: PlayerMotor = scene[3]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	# Step 9 submits WITHOUT sampling step 9: nothing may be consumed from step
	# 8's sample, and the motor receives no grapple submission at all.
	assert_eq(motor.begin_motion_frame(9, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		controller.submit_motor_influences(motor, 1.0 / 60.0, 9),
		PlayerMotor.SubmissionStatus.STALE_ANCHOR_SAMPLE
	)
	assert_eq(
		controller.submit_speed_cap(motor, 9),
		PlayerMotor.SubmissionStatus.STALE_ANCHOR_SAMPLE
	)
	assert_eq(motor.get_accepted_submission_count(), 0)
	# The same step sampled for real then submits normally.
	assert_true(controller.sample_anchor_state(9, 1.0 / 60.0))
	assert_eq(
		controller.submit_motor_influences(motor, 1.0 / 60.0, 9),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_gt(motor.get_accepted_submission_count(), 0)


func test_the_commit_step_is_genuinely_sampled() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var component: Grappleable3D = Grappleable3D.find_explicit_grappleables(target)[0]
	component.encounter_scope_identity = &"encounter.run_b"
	controller.set_scope_identity_provider(_constant_scope(&"encounter.run_a"))
	assert_eq(
		controller.commit_attachment(
			_moving_seed(target, target.global_position, Vector3.ZERO),
			7
		),
		GrappleController.CommitStatus.SUCCESS
	)
	# The commit step's sampling phase runs for real: the seed sample no longer
	# short-circuits the scope/discontinuity checks for that step.
	assert_false(controller.sample_anchor_state(7, 1.0 / 60.0))
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.SCOPE_MISMATCH)


func test_re_attachment_starts_a_fresh_sampling_baseline() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	assert_not_null(controller.terminate(GrappleEndReason.Reason.RELEASE, 8))
	# Release, move the target far away while unattached, re-grapple.
	target.global_position += Vector3(30.0, 0.0, 0.0)
	hit_position = target.global_position
	offset = target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 9),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(10, 1.0 / 60.0))
	var sample: GrappleAnchorState = controller.get_sampled_anchor_state()
	assert_almost_eq(
		sample.target_velocity.length(),
		0.0,
		0.001,
		"the first sample of a new occurrence derives no stale-span velocity"
	)


func test_a_gap_between_samples_never_inflates_the_implied_speed() -> void:
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	# Sampling is skipped for 5 steps (e.g. a state that suspends the phase)
	# while the target moves a total of 5 m: 1 m per step is continuous motion
	# and must never classify as a severe discontinuity when sampling resumes.
	target.global_position += Vector3(5.0, 0.0, 0.0)
	assert_true(controller.sample_anchor_state(14, 1.0 / 60.0))
	assert_true(controller.has_active_attachment())
	var sample: GrappleAnchorState = controller.get_sampled_anchor_state()
	# 5 m over the 6 elapsed steps is 50 m/s of continuous motion: gap-corrected.
	# The stale one-step division would have reported 300 m/s and terminated.
	assert_almost_eq(sample.target_velocity.x, 50.0, 0.5, "gap-corrected derived speed")


func test_a_non_finite_sampled_anchor_fails_closed_with_a_typed_reason() -> void:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.MOVING)
	var component: Grappleable3D = fixture[0]
	# Degenerate local offset (review fix): never a coerced world-origin anchor
	# that still reports valid.
	var from_offset := component.sample_anchor_state(
		Vector3(INF, 0.0, 0.0),
		1.0 / 60.0,
		Vector3.ZERO
	)
	assert_false(from_offset.is_valid)
	assert_eq(
		from_offset.invalidation_reason,
		GrappleAnchorState.InvalidationReason.TARGET_INVALIDATED
	)
	# Degenerate frozen anchor on the static path (review fix).
	var static_component: Grappleable3D = (
		_new_component_target(GrappleTargetResponse.AnchorMode.STATIC)[0]
	)
	var from_anchor := static_component.sample_anchor_state(
		Vector3.ZERO,
		1.0 / 60.0,
		Vector3(INF, 0.0, 0.0)
	)
	assert_false(from_anchor.is_valid)


func test_supplied_anchor_velocity_expires_with_invalidation() -> void:
	var fixture := _new_component_target(GrappleTargetResponse.AnchorMode.MOVING)
	var component: Grappleable3D = fixture[0]
	component.supply_anchor_velocity(Vector3(0.0, 0.0, -6.0))
	component.invalidate_grapple_anchor()
	# Reviewed lifetime rule: explicit invalidation expires the supplied
	# velocity (observed directly because an invalidated anchor no longer
	# samples).
	assert_false(component._has_supplied_anchor_velocity)
	assert_eq(component._supplied_anchor_velocity_mps, Vector3.ZERO)


func test_a_malformed_scope_provider_fails_closed_to_unscoped() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	controller.set_scope_identity_provider(
		func() -> Variant:
			return 42
	)
	assert_eq(
		controller.get_originating_scope_identity(),
		&"",
		"only String/StringName is a stable identity"
	)
	controller.set_scope_identity_provider(
		func() -> Variant:
			return Vector3.ONE
	)
	assert_eq(controller.get_originating_scope_identity(), &"")


func test_terminal_record_stays_value_only() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	assert_eq(
		controller.commit_attachment(_static_seed(target, Vector3.ZERO), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	var terminal := controller.terminate(GrappleEndReason.Reason.RELEASE, 8)
	assert_not_null(terminal)
	assert_true(terminal.is_value_only(), "Terminal must stay value-only")


func test_refused_boundary_carry_terminates_the_attachment_end_to_end() -> void:
	# AC 4 "never snap" wiring (review fix): the motor's carry refusal reaches
	# the single termination funnel in the SAME step, exactly once.
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var body: CharacterBody3D = scene[2]
	var motor: PlayerMotor = scene[3]
	var component: Grappleable3D = Grappleable3D.find_explicit_grappleables(target)[0]
	# Player idle exactly at the maximum boundary; the anchor separates at
	# 200 m/s - far above the 50 m/s continuous tolerance.
	body.global_position = target.global_position + Vector3(0.0, 0.0, 35.0)
	component.supply_anchor_velocity(Vector3(0.0, 0.0, -200.0))
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	var ended_events: Array = []
	controller.attachment_ended.connect(
		func(attachment_id: StringName, reason: GrappleEndReason.Reason) -> void:
			ended_events.append([attachment_id, reason])
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	assert_eq(motor.begin_motion_frame(8, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.locomotion.grappling"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grappling.base",
			Vector3.ZERO,
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		controller.submit_motor_influences(motor, 1.0 / 60.0, 8),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_eq(result.anchor_constraint_records.size(), 1)
	var record: Dictionary = result.anchor_constraint_records[0]
	assert_true(bool(record["carry_refused"]))
	assert_almost_eq(float(record["carry_applied_mps"]), 0.0, TOLERANCE)
	assert_gt(float(record["carry_refused_mps"]), 50.0)
	controller.record_committed_facts(result)
	assert_eq(ended_events.size(), 1, "the refused carry terminates exactly once")
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.ANCHOR_DISCONTINUITY)
	var snapshot: GrappleAttachmentDiagnosticSnapshot = controller.get_diagnostic_snapshot()
	assert_gt(snapshot.boundary_carry_refused_mps, 50.0)
	assert_almost_eq(snapshot.boundary_carry_applied_mps, 0.0, TOLERANCE)


func test_a_refused_carry_in_any_boundary_record_terminates_the_attachment() -> void:
	# Review fix: the motor may resolve several boundary records per frame from
	# distinct source ids; a refused carry in ANY of them must reach the funnel.
	var scene := _new_controller_motor_fixture()
	var controller: GrappleController = scene[0]
	var target: StaticBody3D = scene[1]
	var body: CharacterBody3D = scene[2]
	var motor: PlayerMotor = scene[3]
	body.global_position = target.global_position + Vector3(0.0, 0.0, 35.0)
	var hit_position := target.global_position
	var offset := target.global_transform.affine_inverse() * hit_position
	assert_eq(
		controller.commit_attachment(_moving_seed(target, hit_position, offset), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	var ended_events: Array = []
	controller.attachment_ended.connect(
		func(attachment_id: StringName, reason: GrappleEndReason.Reason) -> void:
			ended_events.append([attachment_id, reason])
	)
	assert_true(controller.sample_anchor_state(8, 1.0 / 60.0))
	assert_eq(motor.begin_motion_frame(8, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.locomotion.grappling"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grappling.base",
			Vector3.ZERO,
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	# A boundary record from ANOTHER source refuses its carry this step.
	assert_eq(
		motor.submit_maximum_anchor_distance(
			&"test.secondary_boundary",
			target.global_position,
			35.0,
			Vector3(0.0, 0.0, -200.0),
			50.0
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_eq(result.anchor_constraint_records.size(), 1)
	assert_true(bool(result.anchor_constraint_records[0]["carry_refused"]))
	controller.record_committed_facts(result)
	assert_eq(ended_events.size(), 1, "a refused carry from any source terminates once")
	assert_eq(
		controller.get_attachment().get_terminal().reason,
		GrappleEndReason.Reason.ANCHOR_DISCONTINUITY
	)


func test_negative_carry_tolerance_is_rejected_like_any_out_of_bound_value() -> void:
	var motor_fixture := _new_motor_fixture()
	var body: CharacterBody3D = motor_fixture[0]
	var motor: PlayerMotor = motor_fixture[1]
	body.global_position = Vector3(0.0, 0.0, 35.0)
	assert_eq(motor.begin_motion_frame(1, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.submit_maximum_anchor_distance(
			&"player.grapple.maximum_distance",
			Vector3.ZERO,
			35.0,
			Vector3.ZERO,
			-1.0
		),
		PlayerMotor.SubmissionStatus.INVALID_REQUEST,
		"a negative carry tolerance is never a valid bound"
	)
	assert_push_error("player.motor.invalid_carry_tolerance")
	assert_eq(motor.get_accepted_submission_count(), 0)


func test_presentation_and_state_consumers_read_snapshots_only() -> void:
	# AC 9 / Task 7.1 (review fix): the mutable attachment accessor is
	# internal/test-only; external consumers read the value-only snapshots.
	for path in [
		"res://scripts/debug_grapple_telemetry.gd",
		"res://scripts/player_grappling_state.gd",
		"res://scripts/player_wall_stick_state.gd",
		"res://scripts/player_dead_state.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		for line in source.split("\n"):
			if line.strip_edges().begins_with("#"):
				continue
			assert_false(
				line.contains("get_grapple_attachment("),
				"%s reads snapshots only" % path
			)
			assert_false(line.contains(".get_attachment("), "%s reads snapshots only" % path)


## ---- Fixtures ----------------------------------------------------------


func _resolve_boundary(
	player_velocity: Vector3,
	anchor_position: Vector3,
	anchor_velocity: Vector3,
	maximum_distance_m: float,
	carry_tolerance_mps: float = 50.0,
	delta: float = 1.0 / 60.0
) -> Array:
	var motor_fixture := _new_motor_fixture()
	var body: CharacterBody3D = motor_fixture[0]
	var motor: PlayerMotor = motor_fixture[1]
	body.global_position = anchor_position + Vector3(0.0, 0.0, maximum_distance_m)
	body.velocity = player_velocity
	assert_eq(motor.begin_motion_frame(1, delta), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.locomotion.grappling"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grappling.base",
			Vector3.ZERO,
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_maximum_anchor_distance(
			&"player.grapple.maximum_distance",
			anchor_position,
			maximum_distance_m,
			anchor_velocity,
			carry_tolerance_mps
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_eq(result.anchor_constraint_records.size(), 1)
	return [result.submitted_velocity, result.anchor_constraint_records[0]]


func _constant_scope(scope_identity: StringName) -> Callable:
	return func() -> StringName:
		return scope_identity


func _static_seed(target: StaticBody3D, hit_position: Vector3) -> GrappleTargetSeed:
	return GrappleTargetSeed.new(
		&"",
		hit_position,
		Vector3(0.0, 0.0, 1.0),
		GrappleTargetResponse.static_default(),
		weakref(target),
		Vector3.ZERO
	)


func _moving_seed(
	target: StaticBody3D,
	hit_position: Vector3,
	local_offset: Vector3
) -> GrappleTargetSeed:
	var response := GrappleTargetResponse.new(
		true,
		GrappleTargetResponse.AnchorMode.MOVING,
		1.0
	)
	return GrappleTargetSeed.new(
		&"target.moving_case",
		hit_position,
		Vector3(0.0, 0.0, 1.0),
		response,
		weakref(target),
		local_offset
	)


func _new_component_target(anchor_mode: GrappleTargetResponse.AnchorMode) -> Array:
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body := StaticBody3D.new()
	body.name = "MovingTarget"
	root.add_child(body)
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.0, 2.0, 2.0)
	collision.shape = box
	body.add_child(collision)
	var component := Grappleable3D.new()
	component.name = "Grappleable"
	component.target_id = &"target.moving_case"
	component.anchor_mode = anchor_mode
	body.add_child(component)
	return [component, body]


func _new_controller_fixture() -> Array:
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body := CharacterBody3D.new()
	root.add_child(body)
	var target := StaticBody3D.new()
	target.name = "MovingContractTarget"
	root.add_child(target)
	var definition := _validated_definition()
	var controller := GrappleController.new()
	autofree(controller)
	assert_eq(
		controller.initialize(body, definition),
		GrappleController.InitializationStatus.SUCCESS
	)
	return [controller, target, definition, body]


## Controller + motor sharing one body on purpose, with a component target:
## one reference point, one sampled anchor consumed by real submissions.
func _new_controller_motor_fixture() -> Array:
	var motor_fixture := _new_motor_fixture()
	var body: CharacterBody3D = motor_fixture[0]
	var motor: PlayerMotor = motor_fixture[1]
	var target := StaticBody3D.new()
	target.name = "SampledTarget"
	body.get_parent().add_child(target)
	target.global_position = Vector3(0.0, 0.0, -12.0)
	var collision := CollisionShape3D.new()
	var box := BoxShape3D.new()
	box.size = Vector3(2.0, 2.0, 2.0)
	collision.shape = box
	target.add_child(collision)
	var component := Grappleable3D.new()
	component.name = "Grappleable"
	component.target_id = &"target.moving_case"
	component.anchor_mode = GrappleTargetResponse.AnchorMode.MOVING
	target.add_child(component)
	var definition := _validated_definition()
	var controller := GrappleController.new()
	autofree(controller)
	assert_eq(
		controller.initialize(body, definition),
		GrappleController.InitializationStatus.SUCCESS
	)
	return [controller, target, body, motor, definition]


func _validated_definition() -> GrappleDefinition:
	var definition := GrappleDefinition.new()
	definition.definition_id = &"player.grapple.default"
	definition.max_grapple_length_m = 35.0
	definition.acquisition_tolerance_m = 0.005
	definition.target_query_profile = _ray_profile()
	assert_eq(definition.validate(), GrappleDefinition.ValidationStatus.SUCCESS)
	return definition


func _ray_profile() -> PhysicsQueryProfile:
	var profile := PhysicsQueryProfile.new()
	profile.query_kind = PhysicsQueryProfile.QueryKind.RAY
	profile.profile_id = &"player.grapple.candidate"
	profile.collision_mask_names = PackedStringArray(["world_geometry"])
	return profile


func _new_motor_fixture() -> Array[Node]:
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body: CharacterBody3D = CharacterBody3D.new()
	root.add_child(body)
	var motor: PlayerMotor = PlayerMotor.new()
	root.add_child(motor)
	_configure_contact_profiles(motor)
	motor.contact_lifecycle_strict = false
	assert_eq(motor.initialize(body, false), PlayerMotor.InitializationStatus.SUCCESS)
	return [body, motor]


func _configure_contact_profiles(motor: PlayerMotor) -> void:
	var ground := GroundProbe.new()
	var ground_shape := SphereShape3D.new()
	ground_shape.radius = 0.08
	ground.shape = ground_shape
	ground.collision_mask_names = PackedStringArray(["world_geometry"])
	var wall := WallProbe.new()
	var wall_shape := SphereShape3D.new()
	wall_shape.radius = 0.12
	wall.shape = wall_shape
	wall.collision_mask_names = PackedStringArray(["world_geometry"])
	motor.ground_probe = ground
	motor.wall_probe = wall
