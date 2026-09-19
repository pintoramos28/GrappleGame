extends GutTest


func test_initialization_is_typed_and_fails_closed() -> void:
	var missing_motor: PlayerMotor = autofree(PlayerMotor.new())
	var missing_status := missing_motor.initialize(null)
	assert_push_error("player.motor.missing_body")
	assert_eq(missing_status, PlayerMotor.InitializationStatus.MISSING_BODY)
	assert_false(missing_motor.is_initialized())

	var wrong_motor: PlayerMotor = autofree(PlayerMotor.new())
	var wrong_body: Node3D = autofree(Node3D.new())
	var wrong_status := wrong_motor.initialize(wrong_body)
	assert_push_error("player.motor.wrong_body")
	assert_eq(wrong_status, PlayerMotor.InitializationStatus.WRONG_BODY)
	assert_false(wrong_motor.is_initialized())

	var detached_motor: PlayerMotor = autofree(PlayerMotor.new())
	var detached_body: CharacterBody3D = autofree(CharacterBody3D.new())
	var detached_status := detached_motor.initialize(detached_body)
	assert_push_error("player.motor.body_not_in_tree")
	assert_eq(detached_status, PlayerMotor.InitializationStatus.BODY_NOT_IN_TREE)
	assert_false(detached_motor.is_initialized())
	detached_body.free()

	var motor: PlayerMotor = autofree(PlayerMotor.new())
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body := CharacterBody3D.new()
	root.add_child(body)
	_configure_contact_profiles(motor)
	assert_eq(motor.initialize(body), PlayerMotor.InitializationStatus.SUCCESS)
	var duplicate_status := motor.initialize(body)
	assert_push_error("player.motor.already_initialized")
	assert_eq(duplicate_status, PlayerMotor.InitializationStatus.ALREADY_INITIALIZED)
	assert_true(motor.is_initialized())


func test_begin_snapshots_body_state_and_delta_without_moving() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	body.global_transform = Transform3D(Basis.IDENTITY, Vector3(2.0, 1.5, -3.0))
	body.velocity = Vector3(1.0, -2.0, 3.0)
	var before := body.global_transform

	motor.set_diagnostics_enabled(true)
	assert_eq(motor.begin_motion_frame(7, 1.0 / 120.0), PlayerMotor.FrameStatus.SUCCESS)
	var snapshot := motor.get_diagnostic_snapshot()

	assert_eq(body.global_transform, before)
	assert_eq(snapshot.physics_step, 7)
	assert_almost_eq(snapshot.delta_seconds, 1.0 / 120.0, 0.0000001)
	assert_eq(snapshot.initial_velocity, Vector3(1.0, -2.0, 3.0))
	assert_eq(snapshot.commit_count, 0)
	assert_eq(snapshot.locomotion_state_id, StringName())
	assert_eq(snapshot.phase_order, MotorPhase.canonical_phase_ids())


func test_typed_submissions_resolve_in_canonical_order_and_commit_once() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(2.0, 0.0, 0.0)
	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_state_policy(&"player.locomotion.grounded"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grounded.base",
			Vector3(2.0, 0.0, 0.0),
			0.0
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()

	assert_true(result.success)
	assert_eq(result.physics_step, 1)
	assert_eq(result.submitted_velocity, Vector3(2.0, 0.0, 0.0))
	assert_eq(result.phase_order, MotorPhase.canonical_phase_ids())
	assert_eq(result.phase_intermediates.size(), MotorPhase.PHASE_COUNT)
	assert_eq(result.commit_count, 1)
	assert_eq(motor.get_commit_count(), 1)
	assert_eq(motor.get_accepted_submission_count(), 2)
	assert_eq(motor.get_last_commit_result(), result)
	assert_eq(body.velocity, Vector3(2.0, 0.0, 0.0))


func test_duplicate_begin_and_commit_cannot_move_body_again() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	assert_eq(motor.begin_motion_frame(3), PlayerMotor.FrameStatus.SUCCESS)
	_submit_passthrough(motor, &"player.locomotion.airborne")

	var duplicate_begin := motor.begin_motion_frame(3)
	assert_push_error("player.motor.duplicate_active_frame")
	assert_eq(duplicate_begin, PlayerMotor.FrameStatus.DUPLICATE_ACTIVE_FRAME)

	var first_result := motor.resolve_and_commit()
	assert_true(first_result.success)
	var transform_after_first := body.global_transform
	var velocity_after_first := body.velocity
	var collision_count_after_first := body.get_slide_collision_count()

	var duplicate_result := motor.resolve_and_commit()
	assert_push_error("player.motor.duplicate_commit")
	assert_false(duplicate_result.success)
	assert_eq(duplicate_result.rejection_reason, PlayerMotorCommitResult.RejectionReason.DUPLICATE_COMMIT)
	assert_eq(body.global_transform, transform_after_first)
	assert_eq(body.velocity, velocity_after_first)
	assert_eq(body.get_slide_collision_count(), collision_count_after_first)
	assert_eq(motor.get_commit_count(), 1)


func test_structural_policy_conflict_aborts_without_body_mutation() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	body.velocity = Vector3(3.0, 0.0, 0.0)
	var before := body.global_transform
	assert_eq(motor.begin_motion_frame(6), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.grounded"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.airborne"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(&"player.locomotion.grounded.base", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()

	assert_push_error("player.motor.exclusive_policy_conflict")
	assert_false(result.success)
	assert_eq(result.rejection_reason, PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT)
	assert_eq(result.commit_count, 0)
	assert_false(motor.has_active_motion_frame())
	assert_null(motor.get_last_commit_result())
	assert_eq(body.global_transform, before)
	assert_eq(body.velocity, Vector3(3.0, 0.0, 0.0))


func test_invalid_values_duplicate_sources_and_occurrences_fail_closed() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	var no_frame_status := motor.submit_gravity(&"player.gravity.default", Vector3.ZERO)
	assert_push_error("player.motor.no_active_motion_frame")
	assert_eq(no_frame_status, PlayerMotor.SubmissionStatus.NO_ACTIVE_FRAME)

	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	var stale := PlayerMotorSubmission.gravity(0, &"player.gravity.stale", Vector3.ZERO)
	assert_eq(motor.call("_submit_submission", stale), PlayerMotor.SubmissionStatus.STALE_STEP)
	assert_push_error("player.motor.stale_physics_step")
	assert_eq(
		motor.submit_gravity(&"player.gravity.invalid", Vector3(INF, 0.0, 0.0)),
		PlayerMotor.SubmissionStatus.NON_FINITE_VALUE
	)
	assert_push_error("player.motor.non_finite_value")
	assert_eq(
		motor.submit_sustained_acceleration(&"", Vector3.ZERO),
		PlayerMotor.SubmissionStatus.INVALID_SOURCE
	)
	assert_push_error("player.motor.empty_source_id")
	assert_eq(
		motor.submit_base_motion(&"player.base.duplicate", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(&"player.base.duplicate", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.DUPLICATE_SOURCE
	)
	assert_push_error("player.motor.duplicate_source")
	assert_eq(motor.select_state_policy(&"player.locomotion.test"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_one_shot_impulse(
			&"player.jump.ground",
			&"player.command.jump_pressed",
			Vector3.UP
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_one_shot_impulse(
			&"player.jump.ground",
			&"player.command.jump_pressed",
			Vector3.UP
		),
		PlayerMotor.SubmissionStatus.DUPLICATE_OCCURRENCE
	)
	assert_push_error("player.motor.duplicate_occurrence")
	assert_eq(
		motor.submit_one_shot_impulse(
			&"player.jump.ground",
			&"player.command.jump_pressed.second",
			Vector3.UP
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)


func test_typed_submission_contract_rejects_mismatched_kinds_scopes_sources_and_vectors() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)

	var mismatched_submission := PlayerMotorSubmission.new(
		PlayerMotorSubmission.Kind.SPEED_CAP,
		MotorPhase.Phase.SUSTAINED_INFLUENCES,
		1,
		&"player.cap.invalid"
	)
	assert_false(mismatched_submission.has_valid_kind_and_phase())
	assert_eq(
		motor.call("_submit_submission", mismatched_submission),
		PlayerMotor.SubmissionStatus.ILLEGAL_PHASE_OR_KIND
	)
	assert_push_error("player.motor.illegal_phase_or_kind")

	assert_eq(
		motor.submit_sustained_acceleration(&"player", Vector3.ZERO),
		PlayerMotor.SubmissionStatus.INVALID_SOURCE
	)
	assert_push_error("player.motor.unstable_source_id")
	assert_eq(
		motor.submit_sustained_acceleration(&"Player.invalid", Vector3.ZERO),
		PlayerMotor.SubmissionStatus.INVALID_SOURCE
	)
	assert_push_error("player.motor.unstable_source_id")
	assert_eq(
		motor.submit_total_speed_cap(
			&"player.cap.horizontal",
			12.0,
			&"horizontal_speed"
		),
		PlayerMotor.SubmissionStatus.UNSUPPORTED_CAP_SCOPE
	)
	assert_push_error("player.motor.unsupported_cap_scope")
	assert_eq(
		motor.submit_wall_run_constraint(
			&"player.wall_run.invalid",
			Vector3.ZERO,
			Vector3.FORWARD
		),
		PlayerMotor.SubmissionStatus.INVALID_WALL_CONSTRAINT
	)
	assert_push_error("player.motor.invalid_wall_constraint")

	assert_eq(
		motor.select_state_policy(&"player.locomotion.grounded"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_base_motion(&"player.locomotion.grounded.base", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)


func test_submission_failure_classification_preserves_valid_frames() -> void:
	assert_true(
		PlayerMotor.is_isolated_submission_status(
			PlayerMotor.SubmissionStatus.INVALID_WALL_CONSTRAINT
		)
	)
	assert_true(
		PlayerMotor.is_isolated_submission_status(
			PlayerMotor.SubmissionStatus.UNSUPPORTED_CAP_SCOPE
		)
	)
	assert_true(
		PlayerMotor.is_isolated_submission_status(
			PlayerMotor.SubmissionStatus.DUPLICATE_OCCURRENCE
		)
	)
	assert_false(
		PlayerMotor.is_isolated_submission_status(
			PlayerMotor.SubmissionStatus.NO_ACTIVE_FRAME
		)
	)
	assert_false(
		PlayerMotor.is_isolated_submission_status(
			PlayerMotor.SubmissionStatus.NOT_INITIALIZED
		)
	)


func test_duplicate_is_reported_before_current_step_capacity_overflow() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.grounded"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(&"player.locomotion.grounded.base", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	for index in range(PlayerMotor.MAX_ACCEPTED_SUBMISSIONS - 2):
		assert_eq(
			motor.submit_sustained_acceleration(
				StringName("player.test.influence_%d" % index),
				Vector3.ZERO
			),
			PlayerMotor.SubmissionStatus.SUCCESS
		)

	assert_eq(
		motor.submit_sustained_acceleration(&"player.test.influence_0", Vector3.ZERO),
		PlayerMotor.SubmissionStatus.DUPLICATE_SOURCE
	)
	assert_push_error("player.motor.duplicate_source")
	assert_eq(
		motor.submit_sustained_acceleration(&"player.test.influence_overflow", Vector3.ZERO),
		PlayerMotor.SubmissionStatus.OVERFLOW
	)
	assert_push_error("player.motor.submission_overflow")
	assert_true(motor.resolve_and_commit().success)


func test_wall_constraint_redirects_relative_velocity_before_outward_removal() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(-5.0, 0.0, 2.0)
	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_run"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.wall_run.base",
			body.velocity,
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_wall_run_constraint(
			&"player.wall_run.constraint",
			Vector3.RIGHT,
			Vector3.FORWARD
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_eq(result.submitted_velocity, Vector3(0.0, 0.0, 2.0))


func test_missing_policy_and_non_monotonic_frames_fail_closed() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_eq(motor.begin_motion_frame(4), PlayerMotor.FrameStatus.SUCCESS)
	var missing_policy_result := motor.resolve_and_commit()
	assert_push_error("player.motor.missing_required_policy")
	assert_false(missing_policy_result.success)
	assert_eq(
		missing_policy_result.rejection_reason,
		PlayerMotorCommitResult.RejectionReason.MISSING_REQUIRED_POLICY
	)

	assert_eq(motor.begin_motion_frame(3), PlayerMotor.FrameStatus.NON_MONOTONIC_STEP)
	assert_push_error("player.motor.non_monotonic_step")
	assert_eq(motor.begin_motion_frame(4), PlayerMotor.FrameStatus.DUPLICATE_STEP)
	assert_push_error("player.motor.duplicate_step")


func test_wall_stick_hold_is_motor_owned_and_exclusive() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	body.global_position = Vector3(1.0, 2.0, 3.0)
	assert_eq(motor.begin_motion_frame(5), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_stick"), PlayerMotor.SubmissionStatus.SUCCESS)
	var hold_position := Vector3(8.0, 4.0, -2.0)
	assert_eq(
		motor.submit_wall_stick_hold(&"player.wall_stick.hold", hold_position),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()

	assert_true(result.success)
	assert_true(result.is_hold_request)
	assert_eq(result.hold_position, hold_position)
	assert_eq(body.global_position, hold_position)
	assert_eq(body.velocity, Vector3.ZERO)
	assert_eq(result.commit_count, 1)
	assert_eq(result.applied_constraints, [&"player.wall_stick.hold"])


func test_wall_stick_entry_arms_a_motor_owned_zero_velocity_baseline() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(8.0, 1.0, 0.0)

	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	_submit_passthrough(motor, &"player.locomotion.grappling")
	assert_true(motor.resolve_and_commit().success)
	assert_eq(motor.set_next_frame_velocity_baseline(Vector3.ZERO), PlayerMotor.BaselineStatus.SUCCESS)
	assert_eq(motor.begin_motion_frame(2), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.get_frame_initial_velocity(), Vector3.ZERO)
	_submit_passthrough(motor, &"player.locomotion.wall_stick")
	var release_result := motor.resolve_and_commit()
	assert_true(release_result.success)
	assert_eq(release_result.submitted_velocity, Vector3.ZERO)
	assert_eq(body.velocity, Vector3.ZERO)


func test_collision_priority_is_bounded_and_prefers_wall_normals_deterministically() -> void:
	var normals: Array[Vector3] = [
		Vector3.UP,
		Vector3.RIGHT,
		Vector3.FORWARD,
		Vector3(0.0, 0.25, 0.9682458),
		Vector3.DOWN,
		Vector3(0.0, 0.5, 0.8660254),
		Vector3(0.0, 0.75, 0.6614378),
		Vector3(0.0, 0.9, 0.4358899),
		Vector3(0.0, 0.95, 0.3122499),
		Vector3(0.0, 1.0, 0.0),
	]

	var prioritized := PlayerMotor.prioritize_collision_indices(normals, 8)

	assert_eq(prioritized.size(), 8)
	assert_eq(prioritized.slice(0, 4), [1, 2, 3, 5])
	assert_eq(PlayerMotor.prioritize_collision_indices(normals, 0), [])


func test_invalid_body_lifecycle_fails_closed_without_body_operations() -> void:
	var detached_fixture := _new_fixture()
	var detached_body: CharacterBody3D = detached_fixture[0]
	var detached_motor: PlayerMotor = detached_fixture[1]
	detached_body.get_parent().remove_child(detached_body)

	var detached_frame_status := detached_motor.begin_motion_frame(1)
	assert_push_error("player.motor.begin_invalid_body")
	assert_eq(detached_frame_status, PlayerMotor.FrameStatus.INVALID_BODY)
	assert_false(detached_motor.has_active_motion_frame())
	detached_body.free()

	var freed_fixture := _new_fixture()
	var freed_body: CharacterBody3D = freed_fixture[0]
	var freed_motor: PlayerMotor = freed_fixture[1]
	freed_body.free()

	var freed_frame_status := freed_motor.begin_motion_frame(1)
	assert_push_error("player.motor.begin_invalid_body")
	assert_eq(freed_frame_status, PlayerMotor.FrameStatus.INVALID_BODY)
	var freed_commit := freed_motor.resolve_and_commit()
	assert_push_error("player.motor.commit_invalid_body")
	assert_false(freed_commit.success)
	assert_eq(freed_commit.rejection_reason, PlayerMotorCommitResult.RejectionReason.INVALID_BODY)


func test_diagnostic_snapshot_is_opt_in_and_copies_bounded_facts() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_null(motor.get_diagnostic_snapshot())

	motor.set_diagnostics_enabled(true)
	assert_eq(motor.begin_motion_frame(9), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.dead"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.dead.base",
			Vector3(0.0, -1.0, 0.0),
			60.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)

	var snapshot := motor.get_diagnostic_snapshot()
	assert_eq(snapshot.physics_step, 9)
	assert_eq(snapshot.submitted_provisional_velocity, Vector3(0.0, -1.0, 0.0))
	assert_eq(snapshot.final_resolved_velocity, Vector3(0.0, -1.0, 0.0))
	assert_eq(snapshot.locomotion_state_id, &"player.locomotion.dead")
	assert_eq(snapshot.commit_count, 1)
	assert_eq(snapshot.phase_intermediates.size(), MotorPhase.PHASE_COUNT)
	assert_eq(snapshot.last_rejection_reason, PlayerMotorCommitResult.RejectionReason.NONE)
	assert_not_null(snapshot.contact_diagnostics)
	assert_eq(snapshot.contact_diagnostics.physics_step, 9)
	assert_eq(snapshot.contact_diagnostics.provider_status, &"ready")
	assert_eq(snapshot.contact_diagnostics.ground_profile_id, &"player.contact.ground_probe")
	assert_gte(snapshot.contact_diagnostics.ground_query_count, 1)
	assert_gte(snapshot.contact_diagnostics.wall_query_count, 1)
	assert_true(snapshot.contact_diagnostics.is_value_only())

	var copied_phases := snapshot.phase_intermediates
	copied_phases.clear()
	assert_eq(snapshot.phase_intermediates.size(), MotorPhase.PHASE_COUNT)


func _submit_passthrough(motor: PlayerMotor, locomotion_id: StringName) -> void:
	assert_eq(motor.select_state_policy(locomotion_id), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(
			StringName("%s.base" % String(locomotion_id)),
			Vector3.ZERO,
			0.0
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)


func _new_fixture() -> Array[Node]:
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
