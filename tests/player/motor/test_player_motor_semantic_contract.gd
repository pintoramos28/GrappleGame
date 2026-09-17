extends GutTest


func test_semantic_phase_order_and_typed_resolution_are_observable() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	motor.set_diagnostics_enabled(true)
	assert_eq(motor.begin_motion_frame(1, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		motor.select_terminal_policy(&"player.terminal.dead"),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(motor.select_state_policy(&"player.locomotion.test"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.test.base",
			Vector3(10.0, 0.0, 0.0),
			30.0
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_gravity(&"player.gravity.default", Vector3(0.0, -9.8, 0.0)),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_sustained_acceleration(
			&"player.grapple.pull",
			Vector3(1.0, 0.0, 0.0)
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_one_shot_impulse(
			&"player.jump.ground",
			&"player.command.jump_pressed",
			Vector3(0.0, 4.5, 0.0)
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_total_speed_cap(&"player.grapple.speed_cap", 22.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	var snapshot := motor.get_diagnostic_snapshot()
	assert_eq(snapshot.phase_order, MotorPhase.canonical_phase_ids())
	assert_eq(snapshot.phase_intermediates.size(), MotorPhase.PHASE_COUNT)
	assert_eq(snapshot.final_resolved_velocity, result.submitted_velocity)
	assert_eq(snapshot.final_committed_velocity, result.committed_velocity)
	assert_eq(snapshot.commit_count, 1)
	assert_eq(result.commit_count, 1)
	var terminal_record: Dictionary = snapshot.accepted_sources_by_phase[
		MotorPhase.Phase.TERMINAL_COMMANDS
	][0]
	assert_eq(terminal_record["source_id"], &"player.terminal.dead")
	assert_eq(
		terminal_record["kind"],
		int(PlayerMotorSubmission.Kind.TERMINAL_POLICY)
	)
	assert_eq(terminal_record["occurrence_id"], &"")


func test_same_step_sources_fold_deterministically_and_jump_occurrence_is_idempotent() -> void:
	var forward_result := _resolve_ordered_frame([
		&"player.sustained.b",
		&"player.sustained.a",
	])
	var reverse_result := _resolve_ordered_frame([
		&"player.sustained.a",
		&"player.sustained.b",
	])
	var third_result := _resolve_ordered_frame([
		&"player.sustained.b",
		&"player.sustained.c",
		&"player.sustained.a",
	])
	var fourth_result := _resolve_ordered_frame([
		&"player.sustained.c",
		&"player.sustained.a",
		&"player.sustained.b",
	])
	assert_almost_eq(forward_result.submitted_velocity.x, reverse_result.submitted_velocity.x, 0.000001)
	assert_almost_eq(forward_result.submitted_velocity.y, reverse_result.submitted_velocity.y, 0.000001)
	assert_almost_eq(third_result.submitted_velocity.x, fourth_result.submitted_velocity.x, 0.000001)
	assert_almost_eq(third_result.submitted_velocity.y, fourth_result.submitted_velocity.y, 0.000001)

	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_eq(motor.begin_motion_frame(1, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.grounded"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.grounded.base",
			Vector3.ZERO,
			0.0
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var occurrence := &"player.command.jump_pressed"
	assert_eq(
		motor.submit_one_shot_impulse(&"player.jump.ground", occurrence, Vector3.UP * 4.5),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_one_shot_impulse(&"player.jump.ground", occurrence, Vector3.UP * 4.5),
		PlayerMotor.SubmissionStatus.DUPLICATE_OCCURRENCE
	)
	assert_push_error("player.motor.duplicate_occurrence")
	assert_eq(
		motor.submit_one_shot_impulse(
			&"player.jump.ground",
			&"player.command.jump_pressed.second",
			Vector3.UP * 1.0
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_almost_eq(result.submitted_velocity.y, 5.5, 0.000001)


func test_same_scope_caps_choose_the_strictest_limit_for_any_submission_order() -> void:
	var forward := _resolve_cap_order([
		&"player.cap.z",
		&"player.cap.a",
		&"player.cap.m",
	])
	var reverse := _resolve_cap_order([
		&"player.cap.m",
		&"player.cap.z",
		&"player.cap.a",
	])
	assert_almost_eq(forward.submitted_velocity.length(), 12.0, 0.000001)
	assert_almost_eq(reverse.submitted_velocity.length(), 12.0, 0.000001)
	assert_eq(forward.applied_caps.size(), 3)
	assert_eq(reverse.applied_caps.size(), 3)


func test_invalid_contributions_are_isolated_but_structural_conflicts_fail_closed() -> void:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(3.0, 0.0, 0.0)
	var before := body.global_transform
	assert_eq(motor.begin_motion_frame(1, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.grounded"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(&"player.locomotion.grounded.base", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
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

	assert_eq(motor.select_state_policy(&"player.locomotion.airborne"), PlayerMotor.SubmissionStatus.SUCCESS)
	var result := motor.resolve_and_commit()
	assert_push_error("player.motor.exclusive_policy_conflict")
	assert_false(result.success)
	assert_eq(result.rejection_reason, PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT)
	assert_eq(result.commit_count, 0)
	assert_eq(body.global_transform, before)
	assert_eq(body.velocity, Vector3(3.0, 0.0, 0.0))


func test_begin_next_step_clears_per_step_facts_and_rejects_stale_submissions() -> void:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	motor.set_diagnostics_enabled(true)
	assert_eq(motor.begin_motion_frame(2, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.grounded"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(&"player.locomotion.grounded.base", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_one_shot_impulse(
			&"player.jump.ground",
			&"player.command.jump_pressed",
			Vector3.UP
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)
	assert_eq(
		motor.submit_gravity(&"player.gravity.stale", Vector3.ZERO),
		PlayerMotor.SubmissionStatus.NO_ACTIVE_FRAME
	)
	assert_push_error("player.motor.no_active_motion_frame")

	assert_eq(motor.begin_motion_frame(3, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	var snapshot := motor.get_diagnostic_snapshot()
	assert_eq(snapshot.physics_step, 3)
	assert_eq(snapshot.accepted_sources_by_phase.size(), MotorPhase.PHASE_COUNT)
	assert_eq(snapshot.rejected_contributions.size(), 0)
	assert_eq(snapshot.applied_constraints.size(), 0)
	assert_eq(snapshot.applied_caps.size(), 0)
	assert_eq(snapshot.commit_count, 0)


func test_rate_resolution_matches_between_sixty_and_one_twenty_hz() -> void:
	var sixty := _run_deceleration_sequence(60)
	var one_twenty := _run_deceleration_sequence(120)
	assert_almost_eq(sixty.x, one_twenty.x, 0.0001)
	assert_almost_eq(sixty.y, one_twenty.y, 0.0001)
	assert_almost_eq(sixty.z, one_twenty.z, 0.0001)


func test_authored_deceleration_step_scales_with_physics_delta() -> void:
	var main_sixty := _resolve_first_deceleration_step(30.0, 60)
	var main_one_twenty := _resolve_first_deceleration_step(30.0, 120)
	var direct_sixty := _resolve_first_deceleration_step(20.0, 60)
	var direct_one_twenty := _resolve_first_deceleration_step(20.0, 120)

	assert_almost_eq(main_sixty.x, 9.5, 0.000001)
	assert_almost_eq(main_one_twenty.x, 9.75, 0.000001)
	assert_almost_eq(direct_sixty.x, 9.666666, 0.000001)
	assert_almost_eq(direct_one_twenty.x, 9.833333, 0.000001)


func test_sustained_rate_sequence_matches_between_sixty_and_one_twenty_hz() -> void:
	var sixty := _run_sustained_sequence(60)
	var one_twenty := _run_sustained_sequence(120)
	assert_almost_eq(sixty.x, one_twenty.x, 0.0001)
	assert_almost_eq(sixty.y, one_twenty.y, 0.0001)
	assert_almost_eq(sixty.z, one_twenty.z, 0.0001)


func _resolve_ordered_frame(source_order: Array[StringName]) -> PlayerMotorCommitResult:
	var fixture := _new_fixture()
	var motor: PlayerMotor = fixture[1]
	assert_eq(motor.begin_motion_frame(1, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.test"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(&"player.locomotion.test.base", Vector3.ZERO, 0.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	for source_id in source_order:
		assert_eq(
			motor.submit_sustained_acceleration(source_id, Vector3(1.0, 0.0, 0.0)),
			PlayerMotor.SubmissionStatus.SUCCESS
		)
	return motor.resolve_and_commit()


func _resolve_cap_order(source_order: Array[StringName]) -> PlayerMotorCommitResult:
	var limits := {
		&"player.cap.a": 18.0,
		&"player.cap.m": 12.0,
		&"player.cap.z": 15.0,
	}
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(30.0, 0.0, 0.0)
	assert_eq(motor.begin_motion_frame(1, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.test"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(
			&"player.locomotion.test.base",
			body.velocity,
			0.0,
			false
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	for source_id in source_order:
		assert_eq(
			motor.submit_total_speed_cap(source_id, limits[source_id]),
			PlayerMotor.SubmissionStatus.SUCCESS
		)
	return motor.resolve_and_commit()


func _resolve_first_deceleration_step(rate_mps2: float, tick_rate: int) -> Vector3:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(10.0, 0.0, 0.0)
	var delta_seconds := 1.0 / float(tick_rate)
	assert_eq(motor.begin_motion_frame(1, delta_seconds), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.grounded"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(&"player.locomotion.grounded.base", Vector3.ZERO, rate_mps2),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_true(motor.resolve_and_commit().success)
	return body.velocity


func _run_deceleration_sequence(tick_rate: int) -> Vector3:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(10.0, 0.0, 0.0)
	var delta_seconds := 1.0 / float(tick_rate)
	for step in range(1, tick_rate + 1):
		assert_eq(motor.begin_motion_frame(step, delta_seconds), PlayerMotor.FrameStatus.SUCCESS)
		assert_eq(motor.select_state_policy(&"player.locomotion.grounded"), PlayerMotor.SubmissionStatus.SUCCESS)
		assert_eq(
			motor.submit_base_motion(&"player.locomotion.grounded.base", Vector3.ZERO, 30.0),
			PlayerMotor.SubmissionStatus.SUCCESS
		)
		assert_true(motor.resolve_and_commit().success)
	return body.velocity


func _run_sustained_sequence(tick_rate: int) -> Vector3:
	var fixture := _new_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var delta_seconds := 1.0 / float(tick_rate)
	for step in range(1, tick_rate + 1):
		assert_eq(motor.begin_motion_frame(step, delta_seconds), PlayerMotor.FrameStatus.SUCCESS)
		assert_eq(motor.select_state_policy(&"player.locomotion.test"), PlayerMotor.SubmissionStatus.SUCCESS)
		assert_eq(
			motor.submit_base_motion(&"player.locomotion.test.base", Vector3.ZERO, 0.0),
			PlayerMotor.SubmissionStatus.SUCCESS
		)
		assert_eq(
			motor.submit_sustained_acceleration(
				&"player.test.sustained",
				Vector3(6.0, 0.0, 0.0)
			),
			PlayerMotor.SubmissionStatus.SUCCESS
		)
		assert_true(motor.resolve_and_commit().success)
	return body.velocity


func _new_fixture() -> Array[Node]:
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body := CharacterBody3D.new()
	root.add_child(body)
	var motor := PlayerMotor.new()
	root.add_child(motor)
	assert_eq(motor.initialize(body), PlayerMotor.InitializationStatus.SUCCESS)
	return [body, motor]
