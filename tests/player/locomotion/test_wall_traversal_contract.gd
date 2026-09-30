extends GutTest
## Story 1.9 wall traversal policy contract.
##
## Covers the wall-run / wall-stick policy layer: authoritative `ContactFrame`
## fact consumption, establish-once wall relationships, continuity stability,
## the fail-closed stale / lost / unavailable guards, the authored entry gates,
## the wall-jump impulse contract, the retained-momentum disclosure (Task 2.2),
## the wall-stick hold contract, and the source-scan rules.
##
## Policy decisions are driven against synthetic `ContactFrame` values where no
## physics is needed. Anything that touches wall contact or movement runs
## against real Godot/Jolt physics in `test_wall_traversal_integration.gd`.

const PLAYER_SCENE := preload("res://scenes/player.tscn")

const SOURCE_JUMP_WALL := &"player.jump.wall"
const COMMAND_JUMP_PRESSED := &"player.command.jump_pressed"
const SOURCE_WALL_RUN_BASE := &"player.locomotion.wall_run.base"
const SOURCE_WALL_RUN_CONSTRAINT := &"player.wall_run.constraint"
const SOURCE_WALL_STICK_BASE := &"player.locomotion.wall_stick.base"
const SOURCE_WALL_STICK_HOLD := &"player.wall_stick.hold"


# --- Wall relationship and continuity (AC 1, 3; Tasks 1.3, 3.1, 3.2) ---------


func test_wall_relationship_is_established_once_and_held_across_preserved_continuity() -> void:
	var player := _new_policy_controller()
	var entry := _wall_frame(1, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.INITIAL)

	assert_true(bool(player.call("_update_wall_run_relationship", entry, Vector3(6.0, 0.0, 0.0))))
	var established_direction: Vector3 = player.get("wall_run_direction")
	var established_normal: Vector3 = player.get("wall_normal")
	assert_true(bool(player.get("is_wall_running")))
	assert_eq(player.get("wall_surface_identity"), &"wall.a")
	assert_true(bool(player.get("wall_identity_persistent")))
	assert_eq(established_direction, Vector3(1.0, 0.0, 0.0))

	# Normal noise inside the authored 25-degree `WallProbe` continuity
	# tolerance must keep the established identity, normal, and run direction.
	# Re-deriving them every step is exactly the AC 3 reversal hazard.
	var noisy_normal := Vector3(0.0, 0.0, 1.0).rotated(Vector3.UP, deg_to_rad(20.0))
	for step in range(2, 8):
		var preserved := _wall_frame(
			step,
			noisy_normal,
			&"wall.a",
			ContactFrame.ContinuityAction.PRESERVED
		)
		assert_true(bool(player.call("_update_wall_run_relationship", preserved, Vector3(6.0, 0.0, 0.0))))
		assert_eq(
			player.get("wall_run_direction"),
			established_direction,
			"run direction was re-derived or reversed at step %d" % step
		)
		assert_eq(
			player.get("wall_normal"),
			established_normal,
			"wall normal was re-derived at step %d" % step
		)
		assert_eq(player.get("wall_surface_identity"), &"wall.a")


func test_switched_continuity_re_derives_the_relationship_once_and_deliberately() -> void:
	var player := _new_policy_controller()
	player.call(
		"_update_wall_run_relationship",
		_wall_frame(1, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.INITIAL),
		Vector3(6.0, 0.0, 0.0)
	)
	var first_direction: Vector3 = player.get("wall_run_direction")

	var switched := _wall_frame(2, Vector3(1.0, 0.0, 0.0), &"wall.b", ContactFrame.ContinuityAction.SWITCHED)
	assert_true(bool(player.call("_update_wall_run_relationship", switched, Vector3(0.0, 0.0, 6.0))))
	assert_eq(player.get("wall_surface_identity"), &"wall.b")
	assert_ne(player.get("wall_run_direction"), first_direction)
	assert_eq(player.get("wall_run_direction"), Vector3(0.0, 0.0, 1.0))

	# After the deliberate single re-derivation, continuity holds it again.
	var preserved := _wall_frame(3, Vector3(1.0, 0.0, 0.0), &"wall.b", ContactFrame.ContinuityAction.PRESERVED)
	assert_true(bool(player.call("_update_wall_run_relationship", preserved, Vector3(0.0, 0.0, 6.0))))
	assert_eq(player.get("wall_run_direction"), Vector3(0.0, 0.0, 1.0))
	assert_eq(player.get("wall_surface_identity"), &"wall.b")


func test_run_direction_is_deterministic_and_sign_aligned_with_horizontal_travel() -> void:
	var player := _new_policy_controller()
	var normal := Vector3(0.0, 0.0, 1.0)

	var forward_first: Vector3 = player.call("_get_wall_run_direction", normal, Vector3(6.0, 0.0, 0.0))
	var forward_second: Vector3 = player.call("_get_wall_run_direction", normal, Vector3(6.0, 0.0, 0.0))
	assert_eq(forward_first, forward_second)
	assert_eq(forward_first, Vector3(1.0, 0.0, 0.0))

	# The sign follows horizontal reference velocity: opposite travel on the
	# same wall yields the opposite run direction.
	var reversed: Vector3 = player.call("_get_wall_run_direction", normal, Vector3(-6.0, 0.0, 0.0))
	assert_eq(reversed, -forward_first)

	# Pure vertical travel can never produce a degenerate run direction.
	var vertical: Vector3 = player.call("_get_wall_run_direction", normal, Vector3(0.0, -12.0, 0.0))
	assert_almost_eq(vertical.length(), 1.0, 0.00001)


func test_wall_fact_gate_fails_toward_exit_for_lost_unavailable_and_missing_walls() -> void:
	var player := _new_policy_controller()
	var step := 5

	for continuity in [
		ContactFrame.ContinuityAction.INITIAL,
		ContactFrame.ContinuityAction.PRESERVED,
		ContactFrame.ContinuityAction.SWITCHED,
	]:
		assert_true(
			bool(player.call("_is_runnable_wall_frame", _wall_frame(step, Vector3(0.0, 0.0, 1.0), &"wall.a", continuity), step)),
			"continuity %d must be runnable" % continuity
		)

	# Exhausted loss window (no wall at all).
	assert_false(bool(player.call("_is_runnable_wall_frame", _wall_frame(step, Vector3.ZERO, &"", ContactFrame.ContinuityAction.LOST, ContactFrame.WallProvenance.NONE, false, true, false), step)))
	# Explicitly flagged loss.
	assert_false(bool(player.call("_is_runnable_wall_frame", _wall_frame(step, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.PRESERVED, ContactFrame.WallProvenance.CONTINUITY, true), step)))
	# Unavailable wall profile (fail closed).
	assert_false(bool(player.call("_is_runnable_wall_frame", _wall_frame(step, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.UNAVAILABLE), step)))
	# No wall relationship at all.
	assert_false(bool(player.call("_is_runnable_wall_frame", _wall_frame(step, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.NONE, ContactFrame.WallProvenance.NONE, false, true, false), step)))
	# Failed wall probe.
	assert_false(bool(player.call("_is_runnable_wall_frame", _wall_frame(step, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.PRESERVED, ContactFrame.WallProvenance.CONTINUITY, false, false), step)))
	# Missing frame.
	assert_false(bool(player.call("_is_runnable_wall_frame", null, step)))


func test_carried_previous_step_frame_is_rejected_by_the_wall_fact_gate() -> void:
	var player := _new_policy_controller()
	var runnable := _wall_frame(9, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.PRESERVED)

	assert_true(bool(player.call("_is_runnable_wall_frame", runnable, 9)))
	# A frame carried from an older step is a stale fact: fail toward exit.
	assert_false(bool(player.call("_is_runnable_wall_frame", runnable, 10)))
	assert_false(bool(player.call("_is_runnable_wall_frame", runnable, 8)))


func test_unexpected_continuity_action_clears_the_relationship() -> void:
	var player := _new_policy_controller()
	var entry := _wall_frame(1, Vector3(0.0, 0.0, 1.0), &"wall.a", ContactFrame.ContinuityAction.INITIAL)

	for continuity in [
		ContactFrame.ContinuityAction.LOST,
		ContactFrame.ContinuityAction.UNAVAILABLE,
		ContactFrame.ContinuityAction.NONE,
	]:
		assert_true(bool(player.call("_update_wall_run_relationship", entry, Vector3(6.0, 0.0, 0.0))))
		assert_true(bool(player.get("is_wall_running")))
		var lost := _wall_frame(2, Vector3(0.0, 0.0, 1.0), &"wall.a", continuity)
		assert_false(bool(player.call("_update_wall_run_relationship", lost, Vector3(6.0, 0.0, 0.0))))
		assert_false(bool(player.get("is_wall_running")))
		assert_eq(player.get("wall_surface_identity"), &"")
		assert_eq(player.get("wall_run_direction"), Vector3.ZERO)


# --- Entry policy and exactly-once entry (AC 1; Tasks 1.2, 1.4) ---------------


func test_wall_run_entry_policy_keeps_the_authored_speed_gates() -> void:
	var player := _new_policy_controller()
	var minimum_horizontal_speed := float(player.get("wall_run_min_horizontal_speed"))
	var maximum_entry_speed := float(player.get("wall_run_max_entry_speed"))

	# Check the configured boundaries instead of duplicating script defaults;
	# scenes may intentionally override these authored controller exports.
	assert_false(
		bool(player.call("_can_start_wall_run", Vector3(minimum_horizontal_speed - 0.5, 0.0, 0.0)))
	)
	assert_true(
		bool(player.call("_can_start_wall_run", Vector3(minimum_horizontal_speed, 0.0, 0.0)))
	)
	assert_true(bool(player.call("_can_start_wall_run", Vector3(maximum_entry_speed, 0.0, 0.0))))
	assert_false(bool(player.call("_can_start_wall_run", Vector3(maximum_entry_speed + 0.5, 0.0, 0.0))))
	# Vertical speed alone never satisfies the horizontal gate.
	assert_false(bool(player.call("_can_start_wall_run", Vector3(0.0, 12.0, 0.0))))


func test_outward_wall_speed_uses_horizontal_projection_and_filters_float_roundoff() -> void:
	var player := _new_policy_controller()
	# A sloped authoritative wall normal whose horizontal unit component is
	# (0.6, 0, 0.8). Vertical velocity must not affect the projection.
	var wall_normal := Vector3(3.0, 8.0, 4.0).normalized()
	var horizontal_normal := Vector3(wall_normal.x, 0.0, wall_normal.z).normalized()
	var tangent := Vector3(horizontal_normal.z, 0.0, -horizontal_normal.x)

	# Positive (separating) projection remains positive despite strong downward
	# speed. A full 3D dot would incorrectly make this inward.
	assert_true(
		bool(player.call("_has_outward_wall_speed", tangent + horizontal_normal * 2.0 + Vector3.DOWN * 100.0, wall_normal))
	)
	# The horizontal tangent is exactly orthogonal; upward velocity must not turn
	# it into a positive projection on the sloped normal.
	assert_false(
		bool(player.call("_has_outward_wall_speed", tangent + Vector3.UP * 100.0, wall_normal))
	)
	# Fast tangential components can leave a tiny positive residual after
	# single-precision rounding; this is numerical zero, not separating motion.
	var rounded_tangent := Vector3(8.000001, 0.0, -5.999999)
	assert_gt(rounded_tangent.dot(horizontal_normal), 0.0)
	assert_false(bool(player.call("_has_outward_wall_speed", rounded_tangent, wall_normal)))
	# A small direct outward vector has no large cancelling tangent terms, so it
	# remains distinguishable and must still be rejected.
	assert_true(bool(player.call("_has_outward_wall_speed", horizontal_normal * 0.000001, wall_normal)))
	# Negative (toward-wall) projection remains inward despite strong upward
	# speed, again proving that Y is excluded before the dot product.
	assert_false(
		bool(player.call("_has_outward_wall_speed", tangent - horizontal_normal * 2.0 + Vector3.UP * 100.0, wall_normal))
	)
	# A degenerate horizontal normal has no outward direction to reject against.
	assert_false(
		bool(player.call("_has_outward_wall_speed", Vector3(0.0, 0.0, 1.0), Vector3.UP))
	)


func test_wall_run_input_alignment_gate_uses_the_established_run_direction() -> void:
	var player := _new_policy_controller()
	var run_direction := Vector3(1.0, 0.0, 0.0)

	# Zero input never satisfies the alignment policy.
	assert_false(bool(player.call("_has_wall_run_input_for_direction", Vector2.ZERO, run_direction)))
	# Aligned input clears the authored 0.2 alignment threshold.
	assert_true(bool(player.call("_has_wall_run_input_for_direction", Vector2(1.0, 0.0), run_direction)))
	# Opposed input does not.
	assert_false(bool(player.call("_has_wall_run_input_for_direction", Vector2(-1.0, 0.0), run_direction)))


# --- Wall-jump impulse contract (AC 5; Tasks 5.1, 5.2, 5.4) ------------------


func test_wall_jump_desired_motion_retains_along_wall_and_drops_outward() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	# The reference carries 6 m/s along the run direction, 2 m/s of outward
	# normal speed that must not survive the launch, and 3 m/s of fall.
	body.velocity = Vector3(6.0, -3.0, 2.0)
	assert_eq(motor.begin_motion_frame(11), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_run"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(SOURCE_WALL_RUN_BASE, body.velocity, 0.0, false),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var reference_velocity := body.velocity
	# Authored motion (Task 5.2): away = wall_normal * 8.0, up = 5.5, and the
	# positive projected along-wall component is retained.
	var away := Vector3(0.0, 0.0, 1.0) * 8.0
	var along_wall := Vector3(1.0, 0.0, 0.0) * maxf(Vector3(6.0, 0.0, 0.0).dot(Vector3(1.0, 0.0, 0.0)), 0.0)
	var desired := away + along_wall
	desired.y = 5.5
	assert_eq(
		motor.submit_one_shot_impulse(SOURCE_JUMP_WALL, COMMAND_JUMP_PRESSED, desired - reference_velocity),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	# Impulse = desired - reference, so the launch lands exactly on the
	# authored motion: 5.5 m/s up, 8.0 m/s away, 6.0 m/s retained along-wall.
	assert_almost_eq(result.submitted_velocity.y, 5.5, 0.00001)
	assert_almost_eq(result.submitted_velocity.x, 6.0, 0.00001)
	assert_almost_eq(result.submitted_velocity.z, 8.0, 0.00001)


func test_wall_jump_impulse_is_occurrence_identified_and_rejects_the_double_apply() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(6.0, 0.0, 0.0)
	assert_eq(motor.begin_motion_frame(12), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_run"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(SOURCE_WALL_RUN_BASE, body.velocity, 0.0, false),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_one_shot_impulse(SOURCE_JUMP_WALL, COMMAND_JUMP_PRESSED, Vector3(0.0, 5.5, 8.0)),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	# The same occurrence submitted again in the same step is the double-apply
	# the motor rejects: `DUPLICATE_OCCURRENCE` is the guard (Task 5.1).
	assert_eq(
		motor.submit_one_shot_impulse(SOURCE_JUMP_WALL, COMMAND_JUMP_PRESSED, Vector3(0.0, 5.5, 8.0)),
		PlayerMotor.SubmissionStatus.DUPLICATE_OCCURRENCE
	)
	assert_push_error("player.motor.duplicate_occurrence")

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_almost_eq(result.submitted_velocity.y, 5.5, 0.00001)
	assert_eq(result.commit_count, 1)


# --- Retained-momentum disclosure (AC 2; Task 2.2) ---------------------------


func test_wall_run_base_motion_retains_above_target_along_wall_momentum() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	# Entering the wall run at 16 m/s along the run direction against an
	# authored target of 10 m/s and an authored acceleration of 4 m/s^2.
	body.velocity = Vector3(16.0, 0.0, 0.0)
	var delta := 1.0 / 60.0
	assert_eq(motor.begin_motion_frame(21, delta), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_run"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(SOURCE_WALL_RUN_BASE, Vector3(10.0, 0.0, 0.0), 4.0, true, true),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	assert_eq(
		motor.submit_wall_run_constraint(SOURCE_WALL_RUN_CONSTRAINT, Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0)),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	# Momentum is NOT snapped to the target: it converges at the authored
	# acceleration (4 m/s^2 over one 60 Hz step = 0.0667 m/s).
	assert_almost_eq(result.submitted_velocity.x, 16.0 - 4.0 * delta, 0.0001)
	assert_gt(result.submitted_velocity.x, 10.0)
	# The constraint keeps the along-wall component and only removes the
	# outward normal component, so tangential travel survives intact.
	assert_almost_eq(result.submitted_velocity.z, 0.0, 0.00001)


func test_wall_run_entry_velocity_survives_the_entry_step_unmodified() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(14.0, -2.0, 0.5)
	assert_eq(motor.begin_motion_frame(22, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_run"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(SOURCE_WALL_RUN_BASE, body.velocity, 0.0, false),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_almost_eq(result.submitted_velocity.x, 14.0, 0.00001)
	assert_almost_eq(result.submitted_velocity.y, -2.0, 0.00001)
	assert_almost_eq(result.submitted_velocity.z, 0.5, 0.00001)


# --- Wall-stick hold and release policy (AC 6, 7; Tasks 6.2, 7.4) ------------


func test_wall_stick_hold_is_expressed_only_as_a_motor_constraint_submission() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3.ZERO
	assert_eq(motor.begin_motion_frame(31), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_stick"), PlayerMotor.SubmissionStatus.SUCCESS)
	# The exclusive-hold frame rule (Story 1.4/1.5, locked) admits exactly
	# `STATE_POLICY` + `WALL_STICK_HOLD`: the hold is the whole motion policy.
	assert_eq(
		motor.submit_wall_stick_hold(SOURCE_WALL_STICK_HOLD, Vector3(1.0, 2.0, 3.0)),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_true(result.is_hold_request)
	assert_eq(result.hold_position, Vector3(1.0, 2.0, 3.0))
	assert_eq(result.commit_count, 1)
	assert_true(result.applied_constraints.has(SOURCE_WALL_STICK_HOLD))


func test_wall_stick_non_jump_exit_preserves_the_reference_velocity() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3(3.0, -1.0, 2.0)
	assert_eq(motor.begin_motion_frame(32), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_stick"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_base_motion(SOURCE_WALL_STICK_BASE, body.velocity, 0.0, false),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var result := motor.resolve_and_commit()
	assert_true(result.success)
	assert_false(result.is_hold_request)
	assert_almost_eq(result.submitted_velocity.x, 3.0, 0.00001)
	assert_almost_eq(result.submitted_velocity.y, -1.0, 0.00001)
	assert_almost_eq(result.submitted_velocity.z, 2.0, 0.00001)
	assert_eq(result.commit_count, 1)


func test_wall_stick_and_wall_run_hold_frame_rules_stay_exclusive() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	body.velocity = Vector3.ZERO
	assert_eq(motor.begin_motion_frame(33), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(motor.select_state_policy(&"player.locomotion.wall_stick"), PlayerMotor.SubmissionStatus.SUCCESS)
	assert_eq(
		motor.submit_wall_stick_hold(SOURCE_WALL_STICK_HOLD, Vector3.ZERO),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	# The exclusive-hold frame rule (Story 1.4/1.5) is a locked contract:
	# `STATE_POLICY` + `WALL_STICK_HOLD` only.
	assert_eq(
		motor.submit_wall_run_constraint(SOURCE_WALL_RUN_CONSTRAINT, Vector3(0.0, 0.0, 1.0), Vector3(1.0, 0.0, 0.0)),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_false(result.success)
	assert_eq(result.rejection_reason, PlayerMotorCommitResult.RejectionReason.EXCLUSIVE_POLICY_CONFLICT)
	assert_push_error("player.motor.exclusive_policy_conflict")


# --- Source scans (Tasks 1.5, 2.3, 8.2, 9.2) ---------------------------------


func test_wall_policy_reads_only_shared_contact_facts_and_command_frames() -> void:
	for path in _wall_policy_paths():
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("is_on_wall("), path)
		assert_false(source.contains("get_wall_normal("), path)
		assert_false(source.contains("get_slide_collision"), path)
		assert_false(source.contains("is_on_floor("), path)
		assert_false(source.contains("PhysicsRayQueryParameters3D"), path)
		assert_false(source.contains("PhysicsShapeQueryParameters3D"), path)
		assert_false(source.contains("intersect_ray("), path)
		assert_false(source.contains("intersect_shape("), path)
		assert_false(source.contains("cast_motion("), path)


func test_wall_policy_has_no_hardware_input_reads() -> void:
	for path in _wall_policy_paths():
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("Input.is_action_"), path)
		assert_false(source.contains("Input.get_vector"), path)
		assert_false(source.contains("Input.get_axis"), path)


func test_wall_policy_keeps_the_single_commit_and_never_restarts_the_level() -> void:
	for path in _wall_policy_paths():
		var source := FileAccess.get_file_as_string(path)
		assert_false(source.contains("move_and_slide("), path)
		assert_false(source.contains("\n\tvelocity"), path)
		assert_false(source.contains("\n\tglobal_position"), path)
		# AC 9 / Task 9.2: no path may restart or reload the level.
		assert_false(source.contains("reload_current_scene"), path)
		assert_false(source.contains("change_scene_to_file"), path)
		assert_false(source.contains("change_scene_to_packed"), path)
		assert_false(source.contains("get_tree().quit"), path)
		assert_false(source.contains("tree_grapple_tutorial"), path)

	var motor_source := FileAccess.get_file_as_string("res://game/player/motor/player_motor.gd")
	assert_eq(
		motor_source.count("_body.move_and_slide()"),
		1,
		"the motor owns the only movement commit"
	)


func test_wall_traversal_states_read_only_the_immutable_command_frame_and_agent_views() -> void:
	for path in [
		"res://scripts/player_wall_run_state.gd",
		"res://scripts/player_wall_stick_state.gd",
	]:
		var source := FileAccess.get_file_as_string(path)
		assert_true(source.contains("get_player_command_frame()"), path)
		assert_false(source.contains("get_grapple_attachment("), path)
		assert_false(source.contains("global_position"), path)
		assert_false(source.contains("submit_motion"), path)


# --- Helpers -----------------------------------------------------------------


func _wall_policy_paths() -> Array[String]:
	return [
		"res://scripts/player_controller.gd",
		"res://scripts/player_wall_run_state.gd",
		"res://scripts/player_wall_stick_state.gd",
		"res://scripts/player_airborne_state.gd",
	]


func _wall_frame(
	step: int,
	normal: Vector3,
	identity: StringName,
	continuity: ContactFrame.ContinuityAction,
	provenance: ContactFrame.WallProvenance = ContactFrame.WallProvenance.CONTINUITY,
	wall_contact_lost: bool = false,
	probe_succeeded: bool = true,
	has_wall: bool = true,
	identity_persistent: bool = true
) -> ContactFrame:
	var candidates: Array[ContactCandidate] = []
	var rejections: Array[ContactRejection] = []
	return ContactFrame.new(
		step,
		ContactFrame.Origin.POST_COMMIT,
		ContactFrame.Status.SUCCESS,
		step,
		true,
		false,
		false,
		Vector3.UP,
		&"",
		ContactFrame.GroundProvenance.NONE,
		has_wall,
		normal,
		identity,
		provenance,
		ContactFrame.WallRelation.FRONT,
		continuity,
		candidates,
		rejections,
		0,
		0,
		1,
		0,
		0,
		false,
		identity_persistent,
		wall_contact_lost,
		false,
		true,
		probe_succeeded
	)


## A real `scenes/player.tscn` controller in a real `World3D`, with processing
## disabled so the engine never drives the HSM while the test calls the policy
## layer directly.
func _new_policy_controller() -> CharacterBody3D:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(64, 64)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)

	var world := Node3D.new()
	viewport.add_child(world)
	var player: CharacterBody3D = PLAYER_SCENE.instantiate()
	player.set("capture_mouse_on_start", false)
	world.add_child(player)
	player.set_physics_process(false)
	player.set_process(false)
	return player


func _new_motor_fixture() -> Array[Node]:
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body: CharacterBody3D = CharacterBody3D.new()
	root.add_child(body)
	var body_shape := CollisionShape3D.new()
	var body_capsule := CapsuleShape3D.new()
	body_capsule.radius = 0.45
	body_capsule.height = 1.8
	body_shape.shape = body_capsule
	body_shape.position.y = 0.9
	body.add_child(body_shape)

	var motor := PlayerMotor.new()
	root.add_child(motor)
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
	motor.contact_lifecycle_strict = false
	assert_eq(motor.initialize(body, false), PlayerMotor.InitializationStatus.SUCCESS)
	return [body, motor]
