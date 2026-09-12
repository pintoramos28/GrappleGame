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
	assert_eq(motor.initialize(body), PlayerMotor.InitializationStatus.SUCCESS)
	var duplicate_status := motor.initialize(body)
	assert_push_error("player.motor.already_initialized")
	assert_eq(duplicate_status, PlayerMotor.InitializationStatus.ALREADY_INITIALIZED)
	assert_true(motor.is_initialized())


func test_begin_snapshots_committed_body_state_without_moving() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	body.global_transform = Transform3D(Basis.IDENTITY, Vector3(2.0, 1.5, -3.0))
	body.velocity = Vector3(1.0, -2.0, 3.0)
	var before := body.global_transform

	motor.set_diagnostics_enabled(true)
	assert_eq(motor.begin_motion_frame(7), PlayerMotor.FrameStatus.SUCCESS)
	var snapshot := motor.get_diagnostic_snapshot()

	assert_eq(body.global_transform, before)
	assert_eq(snapshot.physics_step, 7)
	assert_eq(snapshot.initial_velocity, Vector3(1.0, -2.0, 3.0))
	assert_eq(snapshot.commit_count, 0)
	assert_eq(snapshot.locomotion_state_id, StringName())


func test_valid_request_commits_once_and_exposes_post_commit_result() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	var request := PlayerMotionRequest.movement(1, &"player.grounded", Vector3(2.0, 0.0, 0.0))
	assert_eq(motor.submit_motion_request(request), PlayerMotor.SubmissionStatus.SUCCESS)

	var result := motor.resolve_and_commit()

	assert_true(result.success)
	assert_eq(result.physics_step, 1)
	assert_eq(result.submitted_velocity, Vector3(2.0, 0.0, 0.0))
	assert_eq(result.commit_count, 1)
	assert_eq(motor.get_commit_count(), 1)
	assert_eq(motor.get_accepted_submission_count(), 1)
	assert_eq(motor.get_last_commit_result(), result)


func test_duplicate_begin_preserves_request_and_duplicate_commit_cannot_move_body_again() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	assert_eq(motor.begin_motion_frame(3), PlayerMotor.FrameStatus.SUCCESS)
	var request := PlayerMotionRequest.movement(3, &"player.airborne", Vector3(1.0, 0.0, 0.0))
	assert_eq(motor.submit_motion_request(request), PlayerMotor.SubmissionStatus.SUCCESS)

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


func test_rejected_followup_aborts_the_accepted_request_without_a_commit() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	var before := body.global_transform
	body.velocity = Vector3(3.0, 0.0, 0.0)

	assert_eq(motor.begin_motion_frame(6), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.submit_motion_request(
			PlayerMotionRequest.movement(6, &"player.grounded", Vector3(6.0, 0.0, 0.0))
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_motion_request(
			PlayerMotionRequest.movement(6, &"player.airborne", Vector3(9.0, 0.0, 0.0))
		),
		PlayerMotor.SubmissionStatus.DUPLICATE_SUBMISSION
	)
	assert_push_error("player.motor.duplicate_motion_submission")

	var aborted := motor.abort_motion_frame()

	assert_false(aborted.success)
	assert_eq(aborted.rejection_reason, PlayerMotorCommitResult.RejectionReason.FRAME_ABORTED)
	assert_eq(motor.get_commit_count(), 0)
	assert_false(motor.has_active_motion_frame())
	assert_null(motor.get_last_commit_result())
	assert_eq(body.global_transform, before)
	assert_eq(body.velocity, Vector3(3.0, 0.0, 0.0))

	var no_commit := motor.resolve_and_commit()
	assert_push_error("player.motor.no_active_frame_at_commit")
	assert_false(no_commit.success)


func test_duplicate_commit_diagnostic_is_stable_and_consecutive_calls_are_deduplicated() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	var diagnostic_codes: Array[StringName] = []
	motor.diagnostic_recorded.connect(func(event: DiagnosticEvent) -> void: diagnostic_codes.append(event.code))

	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.submit_motion_request(PlayerMotionRequest.movement(1, &"player.airborne", Vector3.ZERO)),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)

	var first_duplicate := motor.resolve_and_commit()
	assert_push_error("player.motor.duplicate_commit")
	var second_duplicate := motor.resolve_and_commit()

	assert_false(first_duplicate.success)
	assert_false(second_duplicate.success)
	assert_eq(diagnostic_codes, [&"player.motor.duplicate_commit"])

	assert_eq(motor.begin_motion_frame(2), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.submit_motion_request(PlayerMotionRequest.movement(2, &"player.airborne", Vector3.ZERO)),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)
	var cross_step_duplicate := motor.resolve_and_commit()
	assert_false(cross_step_duplicate.success)
	assert_eq(diagnostic_codes, [&"player.motor.duplicate_commit"])


func test_invalid_and_duplicate_submissions_fail_closed() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	var no_frame_request := PlayerMotionRequest.movement(1, &"player.test", Vector3.ZERO)
	assert_eq(motor.submit_motion_request(no_frame_request), PlayerMotor.SubmissionStatus.NO_ACTIVE_FRAME)
	assert_push_error("player.motor.no_active_motion_frame")

	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	var wrong_step := PlayerMotionRequest.movement(2, &"player.test", Vector3.ZERO)
	assert_eq(motor.submit_motion_request(wrong_step), PlayerMotor.SubmissionStatus.WRONG_STEP)
	assert_push_error("player.motor.wrong_physics_step")

	var invalid_velocity := PlayerMotionRequest.movement(1, &"player.test", Vector3(INF, 0.0, 0.0))
	assert_eq(motor.submit_motion_request(invalid_velocity), PlayerMotor.SubmissionStatus.INVALID_REQUEST)
	assert_push_error("player.motor.invalid_motion_request")

	var valid_request := PlayerMotionRequest.movement(1, &"player.test", Vector3.ZERO)
	assert_eq(motor.submit_motion_request(valid_request), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(motor.submit_motion_request(valid_request), PlayerMotor.SubmissionStatus.DUPLICATE_SUBMISSION)
	assert_push_error("player.motor.duplicate_motion_submission")
	assert_true(motor.resolve_and_commit().success)


func test_missing_request_and_non_monotonic_frames_fail_closed() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_eq(motor.begin_motion_frame(4), PlayerMotor.FrameStatus.SUCCESS)
	var missing_request_result := motor.resolve_and_commit()
	assert_push_error("player.motor.no_motion_request")
	assert_false(missing_request_result.success)
	assert_eq(missing_request_result.rejection_reason, PlayerMotorCommitResult.RejectionReason.NO_MOTION_REQUEST)

	assert_eq(motor.begin_motion_frame(3), PlayerMotor.FrameStatus.NON_MONOTONIC_STEP)
	assert_push_error("player.motor.non_monotonic_step")
	assert_eq(motor.begin_motion_frame(4), PlayerMotor.FrameStatus.DUPLICATE_STEP)
	assert_push_error("player.motor.duplicate_step")


func test_wall_stick_hold_is_motor_owned() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	motor.set_debug_assertions_enabled(false)
	body.global_position = Vector3(1.0, 2.0, 3.0)
	assert_eq(motor.begin_motion_frame(5), PlayerMotor.FrameStatus.SUCCESS)
	var hold_position := Vector3(8.0, 4.0, -2.0)
	var request := PlayerMotionRequest.hold(5, &"player.wall_stick", hold_position)
	assert_eq(motor.submit_motion_request(request), PlayerMotor.SubmissionStatus.SUCCESS)

	var result := motor.resolve_and_commit()

	assert_true(result.success)
	assert_true(result.is_hold_request)
	assert_eq(result.hold_position, hold_position)
	assert_eq(body.global_position, hold_position)
	assert_eq(body.velocity, Vector3.ZERO)
	assert_eq(result.commit_count, 1)


func test_wall_stick_entry_arms_a_motor_owned_zero_velocity_baseline() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(8.0, 1.0, 0.0)

	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.submit_motion_request(
			PlayerMotionRequest.movement(1, &"player.locomotion.grappling", body.velocity)
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)
	assert_eq(motor.set_next_frame_velocity_baseline(Vector3.ZERO), PlayerMotor.BaselineStatus.SUCCESS)
	assert_eq(motor.begin_motion_frame(2), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.get_frame_initial_velocity(), Vector3.ZERO)
	assert_eq(
		motor.submit_motion_request(
			PlayerMotionRequest.movement(2, &"player.locomotion.wall_stick", motor.get_frame_initial_velocity())
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
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
	var request := PlayerMotionRequest.movement(9, &"player.dead", Vector3(0.0, -1.0, 0.0))
	assert_eq(motor.submit_motion_request(request), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_true(motor.resolve_and_commit().success)

	var snapshot := motor.get_diagnostic_snapshot()
	assert_eq(snapshot.physics_step, 9)
	assert_eq(snapshot.submitted_provisional_velocity, Vector3(0.0, -1.0, 0.0))
	assert_eq(snapshot.locomotion_state_id, &"player.dead")
	assert_eq(snapshot.commit_count, 1)
	assert_eq(snapshot.last_rejection_reason, PlayerMotorCommitResult.RejectionReason.NONE)


func _new_fixture() -> Array[Node]:
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body: CharacterBody3D = CharacterBody3D.new()
	root.add_child(body)
	var motor: PlayerMotor = PlayerMotor.new()
	root.add_child(motor)
	assert_eq(motor.initialize(body), PlayerMotor.InitializationStatus.SUCCESS)
	return [body, motor]
