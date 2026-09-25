extends GutTest


## Story 1.7 contract tests: attachment occurrence, resolved-value immutability,
## the closed end-reason set, idempotent termination, the typed diagnostics
## snapshot, and the outward-only maximum-boundary clipping math (pure cases on a
## real motor fixture). Real-Jolt player-scene scenarios live in
## `test_grapple_boundary_integration.gd`.


const TOLERANCE := 0.0001
const POSITION_TOLERANCE := 0.001


func test_attachment_commits_once_with_stable_identity_and_seed_facts() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	var definition: GrappleDefinition = fixture[2]
	var anchor := Vector3(2.0, 3.0, -8.0)

	assert_eq(
		controller.commit_attachment(_seed(target, anchor, 1.0), 7),
		GrappleController.CommitStatus.SUCCESS
	)
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_not_null(attachment)
	assert_true(controller.has_active_attachment())
	assert_eq(attachment.attachment_id, &"player.grapple.attachment_1")
	assert_eq(attachment.creation_physics_step, 7)
	assert_eq(attachment.anchor_world_position, anchor)
	assert_eq(attachment.target_identity, &"target.contract")
	assert_true(attachment.has_live_target())
	assert_same(attachment.get_target(), target)
	assert_almost_eq(attachment.elapsed_seconds, 0.0, TOLERANCE)
	# The acceleration currently in effect is the profile value at the commit
	# step (Story 1.6 semantics), while the profile clock is still zero and the
	# decay formula agrees.
	assert_almost_eq(
		attachment.applied_acceleration_mps2,
		definition.pull_initial_acceleration_mps2,
		TOLERANCE
	)
	assert_almost_eq(
		attachment.current_pull_acceleration_mps2(),
		definition.pull_initial_acceleration_mps2,
		TOLERANCE
	)
	assert_true(attachment.is_active())
	assert_null(attachment.get_terminal())

	# Exactly one active attachment at a time (AC 1).
	assert_eq(
		controller.commit_attachment(_seed(target, anchor, 1.0), 8),
		GrappleController.CommitStatus.ATTACHMENT_ALREADY_ACTIVE
	)
	assert_eq(controller.get_attachment(), attachment)

	# Attachment distance is never rope length (AC 4): the resolved maximum is
	# the authored definition value no matter where the anchor sits.
	assert_almost_eq(
		attachment.resolved_maximum_length_m,
		definition.max_grapple_length_m,
		TOLERANCE
	)

	# A live weak reference dies with its target (NFR14) instead of retaining it.
	target.queue_free()
	await get_tree().process_frame
	assert_false(attachment.has_live_target())


func test_occurrence_local_resolution_scales_pull_only_and_never_mutates_definition() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	var definition: GrappleDefinition = fixture[2]
	var authored_initial := definition.pull_initial_acceleration_mps2
	var authored_min := definition.pull_min_acceleration_mps2
	var authored_jerk := definition.pull_acceleration_jerk_mps3
	var authored_cap := definition.maximum_speed_mps
	var authored_length := definition.max_grapple_length_m

	assert_eq(
		controller.commit_attachment(_seed(target, Vector3.ZERO, 2.0), 3),
		GrappleController.CommitStatus.SUCCESS
	)
	var attachment: GrappleAttachment = controller.get_attachment()
	assert_almost_eq(attachment.response_pull_multiplier, 2.0, TOLERANCE)
	assert_almost_eq(
		attachment.resolved_pull_initial_acceleration_mps2,
		authored_initial * 2.0,
		TOLERANCE
	)
	assert_almost_eq(
		attachment.resolved_pull_min_acceleration_mps2,
		authored_min * 2.0,
		TOLERANCE
	)
	assert_almost_eq(
		attachment.resolved_pull_acceleration_jerk_mps3,
		authored_jerk * 2.0,
		TOLERANCE
	)
	# The cap and the range resolve 1:1 from the authored definition.
	assert_almost_eq(attachment.resolved_maximum_speed_mps, authored_cap, TOLERANCE)
	assert_almost_eq(attachment.resolved_maximum_length_m, authored_length, TOLERANCE)
	assert_true(attachment.is_definition_unmodified())

	# The profile formula is the authored one (Task 2.5): pre-increment read.
	assert_almost_eq(
		attachment.current_pull_acceleration_mps2(),
		authored_initial * 2.0,
		TOLERANCE
	)
	attachment.record_applied_acceleration(attachment.current_pull_acceleration_mps2())
	attachment.advance_elapsed(0.05)
	assert_almost_eq(
		attachment.current_pull_acceleration_mps2(),
		maxf(authored_min * 2.0, authored_initial * 2.0 - authored_jerk * 2.0 * 0.05),
		TOLERANCE
	)
	assert_true(attachment.is_definition_unmodified())

	# A later occurrence starts from the unchanged authored definition (AC 10).
	controller.terminate(GrappleEndReason.Reason.RELEASE, 9)
	assert_eq(
		controller.commit_attachment(_seed(target, Vector3.ZERO, 1.0), 10),
		GrappleController.CommitStatus.SUCCESS
	)
	var second: GrappleAttachment = controller.get_attachment()
	assert_eq(second.attachment_id, &"player.grapple.attachment_2")
	assert_almost_eq(
		second.resolved_pull_initial_acceleration_mps2,
		authored_initial,
		TOLERANCE
	)
	assert_ne(second, attachment)

	assert_almost_eq(definition.pull_initial_acceleration_mps2, authored_initial, TOLERANCE)
	assert_almost_eq(definition.pull_min_acceleration_mps2, authored_min, TOLERANCE)
	assert_almost_eq(definition.pull_acceleration_jerk_mps3, authored_jerk, TOLERANCE)
	assert_almost_eq(definition.maximum_speed_mps, authored_cap, TOLERANCE)
	assert_almost_eq(definition.max_grapple_length_m, authored_length, TOLERANCE)
	assert_true(definition.is_locked())


func test_end_reason_set_is_closed_with_stable_ids() -> void:
	var reasons: Dictionary = GrappleEndReason.Reason
	# Story 1.8 Task 5.1 appends `TARGET_DESTROYED`, `SCOPE_MISMATCH`, and
	# `ANCHOR_DISCONTINUITY` to the closed set; the Story 1.7 prefix order and
	# ids below stay locked (append-only schema).
	assert_eq(reasons.size(), 9, "GrappleEndReason stays a closed 9-value set")
	assert_eq(reasons.keys()[0], "NONE")
	assert_eq(reasons.keys()[1], "RELEASE")
	assert_eq(reasons.keys()[2], "TARGET_INVALIDATED")
	assert_eq(reasons.keys()[3], "OWNER_DEATH")
	assert_eq(reasons.keys()[4], "STATE_CANCELLATION")
	assert_eq(reasons.keys()[5], "GROUND_CONTACT")
	assert_eq(reasons.keys()[6], "TARGET_DESTROYED")
	assert_eq(reasons.keys()[7], "SCOPE_MISMATCH")
	assert_eq(reasons.keys()[8], "ANCHOR_DISCONTINUITY")
	assert_eq(GrappleEndReason.reason_id(GrappleEndReason.Reason.NONE), &"none")
	assert_eq(GrappleEndReason.reason_id(GrappleEndReason.Reason.RELEASE), &"release")
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.TARGET_INVALIDATED),
		&"target_invalidated"
	)
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.OWNER_DEATH),
		&"owner_death"
	)
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.STATE_CANCELLATION),
		&"state_cancellation"
	)
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.GROUND_CONTACT),
		&"ground_contact"
	)
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.TARGET_DESTROYED),
		&"target_destroyed"
	)
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.SCOPE_MISMATCH),
		&"scope_mismatch"
	)
	assert_eq(
		GrappleEndReason.reason_id(GrappleEndReason.Reason.ANCHOR_DISCONTINUITY),
		&"anchor_discontinuity"
	)
	assert_false(GrappleEndReason.is_valid_reason(int(GrappleEndReason.Reason.NONE)))
	assert_true(GrappleEndReason.is_valid_reason(int(GrappleEndReason.Reason.RELEASE)))
	assert_false(GrappleEndReason.is_valid_reason(int(GrappleEndReason.Reason.size())))


func test_duplicate_termination_commits_one_terminal_and_repeats_nothing() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	assert_eq(
		controller.commit_attachment(_seed(target, Vector3.ZERO, 1.0), 4),
		GrappleController.CommitStatus.SUCCESS
	)
	var attachment: GrappleAttachment = controller.get_attachment()
	var ended_events: Array = []
	controller.attachment_ended.connect(
		func(ended_attachment_id: StringName, reason: GrappleEndReason.Reason) -> void:
			ended_events.append([ended_attachment_id, reason])
	)

	var first := controller.terminate(GrappleEndReason.Reason.RELEASE, 12)
	assert_not_null(first)
	assert_eq(first.reason, GrappleEndReason.Reason.RELEASE)
	assert_eq(first.reason_id, &"release")
	assert_eq(first.physics_step, 12)
	assert_eq(first.attachment_id, attachment.attachment_id)
	assert_false(attachment.is_active())
	assert_eq(ended_events.size(), 1)
	assert_eq(ended_events[0][0], attachment.attachment_id)
	assert_eq(ended_events[0][1], GrappleEndReason.Reason.RELEASE)

	# NFR15: repeated termination returns the already-committed record and
	# repeats no transition, presentation effect, signal, or cleanup.
	var second := controller.terminate(GrappleEndReason.Reason.OWNER_DEATH, 99)
	assert_same(second, first)
	assert_eq(second.reason, GrappleEndReason.Reason.RELEASE)
	assert_eq(second.physics_step, 12)
	assert_eq(ended_events.size(), 1)

	# Submissions stop once the attachment is terminated (AC 9).
	var motor_fixture := _new_motor_fixture()
	var motor: PlayerMotor = motor_fixture[1]
	assert_eq(motor.begin_motion_frame(1), PlayerMotor.FrameStatus.SUCCESS)
	assert_eq(
		controller.submit_motor_influences(motor, 1.0 / 60.0),
		PlayerMotor.SubmissionStatus.NO_ACTIVE_ATTACHMENT
	)
	assert_eq(
		controller.submit_speed_cap(motor),
		PlayerMotor.SubmissionStatus.NO_ACTIVE_ATTACHMENT
	)
	assert_eq(motor.get_accepted_submission_count(), 0)


func test_attachment_snapshot_is_value_only_and_reports_documented_fields() -> void:
	var fixture := _new_controller_fixture()
	var controller: GrappleController = fixture[0]
	var target: StaticBody3D = fixture[1]
	var definition: GrappleDefinition = fixture[2]
	var anchor := Vector3(0.0, 0.0, -10.0)
	assert_null(controller.get_diagnostic_snapshot())
	assert_eq(
		controller.commit_attachment(_seed(target, anchor, 1.0), 5),
		GrappleController.CommitStatus.SUCCESS
	)

	var snapshot: GrappleAttachmentDiagnosticSnapshot = controller.get_diagnostic_snapshot()
	assert_not_null(snapshot)
	assert_true(snapshot.is_value_only())
	assert_eq(snapshot.attachment_identity, &"player.grapple.attachment_1")
	assert_eq(snapshot.target_identity, &"target.contract")
	assert_true(snapshot.is_active)
	assert_eq(snapshot.creation_physics_step, 5)
	assert_eq(snapshot.anchor_world_position, anchor)
	assert_almost_eq(snapshot.maximum_distance_m, definition.max_grapple_length_m, TOLERANCE)
	assert_almost_eq(
		snapshot.current_distance_m,
		controller.get_reference_position().distance_to(anchor),
		POSITION_TOLERANCE
	)
	assert_almost_eq(
		snapshot.range_fraction,
		snapshot.distance_at_resolution_m / snapshot.maximum_distance_m,
		TOLERANCE
	)
	assert_eq(snapshot.terminal_reason, GrappleEndReason.Reason.NONE)
	assert_eq(snapshot.terminal_reason_id, &"none")
	assert_false(snapshot.boundary_correction_applied)

	controller.terminate(GrappleEndReason.Reason.OWNER_DEATH, 11)
	var terminated: GrappleAttachmentDiagnosticSnapshot = controller.get_diagnostic_snapshot()
	assert_not_null(terminated)
	assert_false(terminated.is_active)
	assert_eq(terminated.terminal_reason, GrappleEndReason.Reason.OWNER_DEATH)
	assert_eq(terminated.terminal_reason_id, &"owner_death")

	# Snapshot providers hold scalar copies and stable IDs only (Task 5.2).
	assert_true(GrappleAttachmentDiagnosticSnapshot.value_is_value_only(terminated))
	assert_false(GrappleAttachmentDiagnosticSnapshot.value_is_value_only(GrappleTargetSeed.new(
		&"target.contract",
		anchor,
		Vector3.ZERO,
		null,
		null,
		Vector3.ZERO
	)))


func test_presentation_surfaces_are_consumption_only() -> void:
	# AC 11 / Task 5.4: the rope lifecycle, the target marker, and the dev
	# overlay consume authoritative facts only. No presentation path may apply
	# pull, enforce distance, release the grapple, or decide the terminal result.
	var presentation_paths: Array[String] = [
		"res://scripts/debug_grapple_telemetry.gd",
		"res://game/player/abilities/grapple/presentation/grapple_target_marker.gd",
	]
	for path in presentation_paths:
		var source := FileAccess.get_file_as_string(path)
		assert_gt(source.length(), 0, "%s must exist to be scanned" % path)
		assert_false(source.contains("submit_"), "%s must not submit motor policy" % path)
		assert_false(source.contains("move_and_slide"), "%s must not move bodies" % path)
		assert_false(source.contains("terminate_grapple"), "%s must not decide terminals" % path)
		assert_false(source.contains("commit_terminal"), "%s must not decide terminals" % path)
		assert_false(source.contains(".velocity"), "%s must not write velocity" % path)
		assert_false(
			source.contains("player.global_position ="),
			"%s must not write the player transform" % path
		)
		assert_false(
			source.contains("player.position ="),
			"%s must not write the player transform" % path
		)

	# The frozen rope lifecycle (spec-grapple-visual-interpolation-reset.md)
	# keeps exactly one interpolation reset at the hidden-to-visible edge.
	var controller_source := FileAccess.get_file_as_string("res://scripts/player_controller.gd")
	assert_eq(
		controller_source.count("grapple_visual.reset_physics_interpolation()"),
		1,
		"rope reset must remain exactly one call site (frozen spec)"
	)


func test_maximum_boundary_is_inactive_inside_the_range() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var anchor := Vector3.ZERO

	# AC 3: well inside, no correction for outward, inward, or tangential motion.
	var step := 10
	for velocity in [
		Vector3(3.0, 0.0, 5.0),
		Vector3(3.0, 0.0, -5.0),
		Vector3(0.0, 0.0, -20.0),
	]:
		step += 1
		var result := _resolve_boundary_frame(
			motor,
			body,
			step,
			Vector3(0.0, 0.0, 10.0),
			velocity,
			anchor,
			35.0
		)
		assert_almost_eq(result.submitted_velocity.x, velocity.x, TOLERANCE)
		assert_almost_eq(result.submitted_velocity.y, velocity.y, TOLERANCE)
		assert_almost_eq(result.submitted_velocity.z, velocity.z, TOLERANCE)
		var record := _boundary_record(result)
		assert_eq(record.size(), 1)
		assert_false(record[0]["correction_applied"])
		assert_almost_eq(float(record[0]["correction_mps"]), 0.0, TOLERANCE)
		assert_almost_eq(float(record[0]["distance_m"]), 10.0, POSITION_TOLERANCE)
		assert_almost_eq(
			float(record[0]["range_fraction"]),
			10.0 / 35.0,
			0.001
		)


func test_maximum_boundary_clips_only_the_outward_radial_component() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var anchor := Vector3.ZERO

	# AC 5: at the boundary the outward component is clipped; the tangential and
	# inward components are preserved exactly.
	var at_boundary := _resolve_boundary_frame(
		motor,
		body,
		21,
		Vector3(0.0, 0.0, 35.0),
		Vector3(3.0, 1.0, 5.0),
		anchor,
		35.0
	)
	assert_almost_eq(at_boundary.submitted_velocity.x, 3.0, TOLERANCE)
	assert_almost_eq(at_boundary.submitted_velocity.y, 1.0, TOLERANCE)
	assert_almost_eq(at_boundary.submitted_velocity.z, 0.0, TOLERANCE)
	var clipped := _boundary_record(at_boundary)[0]
	assert_true(clipped["correction_applied"])
	assert_almost_eq(float(clipped["correction_mps"]), 5.0, TOLERANCE)
	assert_almost_eq(float(clipped["radial_velocity_mps"]), 0.0, TOLERANCE)
	assert_almost_eq(float(clipped["tangential_velocity_mps"]), Vector3(3.0, 1.0, 0.0).length(), TOLERANCE)

	# Inward motion is unrestricted at and beyond the boundary.
	var step := 22
	for entry in [
		[Vector3(0.0, 0.0, 35.0), Vector3(3.0, 0.0, -5.0)],
		[Vector3(0.0, 0.0, 36.5), Vector3(0.0, 0.0, -20.0)],
	]:
		step += 1
		var inward := _resolve_boundary_frame(
			motor,
			body,
			step,
			entry[0],
			entry[1],
			anchor,
			35.0
		)
		assert_almost_eq(inward.submitted_velocity.x, entry[1].x, TOLERANCE)
		assert_almost_eq(inward.submitted_velocity.y, entry[1].y, TOLERANCE)
		assert_almost_eq(inward.submitted_velocity.z, entry[1].z, TOLERANCE)
		assert_false(_boundary_record(inward)[0]["correction_applied"])

	# Pure tangential motion at the boundary is untouched.
	var tangential := _resolve_boundary_frame(
		motor,
		body,
		25,
		Vector3(0.0, 0.0, 35.0),
		Vector3(7.0, 0.0, 0.0),
		anchor,
		35.0
	)
	assert_almost_eq(tangential.submitted_velocity.x, 7.0, TOLERANCE)
	assert_almost_eq(tangential.submitted_velocity.z, 0.0, TOLERANCE)
	assert_false(_boundary_record(tangential)[0]["correction_applied"])

	# Beyond the boundary, further outward motion is fully clipped.
	var beyond := _resolve_boundary_frame(
		motor,
		body,
		26,
		Vector3(0.0, 0.0, 36.5),
		Vector3(0.0, 0.0, 12.0),
		anchor,
		35.0
	)
	assert_almost_eq(beyond.submitted_velocity.z, 0.0, TOLERANCE)
	assert_true(_boundary_record(beyond)[0]["correction_applied"])


func test_maximum_boundary_prevents_high_speed_overshoot_without_snapping() -> void:
	var fixture := _new_motor_fixture()
	var body: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var anchor := Vector3.ZERO

	# AC 6: one high-speed step may not carry the player past the boundary. The
	# prevention is velocity space only - no snap to the anchor, no momentum
	# zeroing, one commit.
	var delta := 1.0 / 60.0
	var result := _resolve_boundary_frame(
		motor,
		body,
		31,
		Vector3(0.0, 0.0, 34.9),
		Vector3(4.0, 0.0, 30.0),
		anchor,
		35.0,
		delta
	)
	var allowed_outward := (35.0 - 34.9) / delta
	assert_almost_eq(result.submitted_velocity.z, allowed_outward, 0.001)
	assert_almost_eq(result.submitted_velocity.x, 4.0, TOLERANCE)
	var record := _boundary_record(result)[0]
	assert_true(record["correction_applied"])
	assert_almost_eq(float(record["correction_mps"]), 30.0 - allowed_outward, 0.001)
	assert_eq(result.commit_count, 1)
	assert_false(result.is_hold_request)
	# The prevention is velocity space only. A magnitude bound cannot be expressed
	# against `delta` in this fixture: `move_and_slide()` is called outside the
	# engine's physics callback and integrates with the engine's own frame delta,
	# not the `delta` handed to `begin_motion_frame` (measured here: the body
	# travels exactly parallel to the committed velocity but ~8x the nominal step).
	# So assert the properties a snap or positional correction would actually
	# break, both delta-free:
	#   * the displacement is PARALLEL to the committed velocity - a positional
	#     correction or a snap toward the anchor makes it non-parallel;
	#   * the body never crosses inward past its start (the adjacent distance
	#     assertion below) and exactly one commit happens.
	assert_lte(
		result.position_delta.cross(result.committed_velocity).length(),
		0.01,
		"displacement is parallel to the committed velocity: no positional correction, no snap"
	)
	assert_gte(result.position_delta.dot(result.committed_velocity), 0.0)
	assert_gte(result.position_after.distance_to(anchor), 34.9 - POSITION_TOLERANCE)
	assert_almost_eq(
		float(record["positional_tolerance_m"]),
		PlayerMotor.ANCHOR_DISTANCE_POSITIONAL_TOLERANCE_M,
		TOLERANCE
	)

	# The degenerate anchor case resolves without corrupting the velocity.
	var degenerate := _resolve_boundary_frame(
		motor,
		body,
		32,
		anchor,
		Vector3(1.0, 2.0, 3.0),
		anchor,
		35.0
	)
	assert_almost_eq(degenerate.submitted_velocity.x, 1.0, TOLERANCE)
	assert_almost_eq(degenerate.submitted_velocity.y, 2.0, TOLERANCE)
	assert_almost_eq(degenerate.submitted_velocity.z, 3.0, TOLERANCE)


## Story 1.7 review patch (finding 20): Task 4.4 requires the single documented
## player reference point to be consistent across pull, constraint and the
## diagnostics snapshot AND covered by tests. Only the diagnostics-distance leg
## was pinned; this covers the pull leg and the pull-vs-boundary agreement - the
## exact "hidden trap" the spec warns silently breaks the 10 m -> 35 m scenario
## and the 60/120 equivalence gate. The controller and motor share one body here
## on purpose, so the assertion is about one reference point, not two fixtures.
func test_pull_and_boundary_share_one_documented_reference_point() -> void:
	var motor_fixture := _new_motor_fixture()
	var body: CharacterBody3D = motor_fixture[0]
	var motor: PlayerMotor = motor_fixture[1]
	var target := StaticBody3D.new()
	target.name = "ReferencePointTarget"
	body.get_parent().add_child(target)
	var definition := GrappleDefinition.new()
	definition.definition_id = &"player.grapple.default"
	definition.max_grapple_length_m = 35.0
	definition.acquisition_tolerance_m = 0.005
	definition.target_query_profile = _ray_profile()
	assert_eq(definition.validate(), GrappleDefinition.ValidationStatus.SUCCESS)
	var controller := GrappleController.new()
	autofree(controller)
	assert_eq(
		controller.initialize(body, definition),
		GrappleController.InitializationStatus.SUCCESS
	)

	body.global_position = Vector3(4.0, -1.0, 6.0)
	var anchor := Vector3(4.0, -1.0, -6.0)
	# The documented reference point is the owner body origin - not the rope's
	# mesh-centre start point, which stays presentation-only.
	assert_eq(controller.get_reference_position(), body.global_position)
	assert_eq(
		controller.commit_attachment(_seed(target, anchor, 1.0), 41),
		GrappleController.CommitStatus.SUCCESS
	)
	assert_eq(motor.begin_motion_frame(42, 1.0 / 60.0), PlayerMotor.FrameStatus.SUCCESS)
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
		controller.submit_motor_influences(motor, 1.0 / 60.0),
		PlayerMotor.SubmissionStatus.SUCCESS
	)

	var expected_pull := body.global_position.direction_to(anchor)
	var resolution_position := body.global_position
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	controller.record_committed_facts(result)

	# The boundary measured its distance from the same origin the pull used.
	var records := _boundary_record(result)
	assert_almost_eq(
		float(records[0]["distance_m"]),
		resolution_position.distance_to(anchor),
		POSITION_TOLERANCE
	)
	# The pull direction is measured from that origin too.
	var snapshot: GrappleAttachmentDiagnosticSnapshot = controller.get_diagnostic_snapshot()
	assert_not_null(snapshot)
	assert_almost_eq(snapshot.pull_direction.x, expected_pull.x, TOLERANCE)
	assert_almost_eq(snapshot.pull_direction.y, expected_pull.y, TOLERANCE)
	assert_almost_eq(snapshot.pull_direction.z, expected_pull.z, TOLERANCE)
	assert_almost_eq(
		snapshot.distance_at_resolution_m,
		float(records[0]["distance_m"]),
		POSITION_TOLERANCE
	)


func _boundary_record(result: PlayerMotorCommitResult) -> Array[Dictionary]:
	var records := result.anchor_constraint_records
	assert_eq(records.size(), 1, "exactly one boundary record per resolved step")
	return records


func _seed(
	target: StaticBody3D,
	anchor: Vector3,
	pull_multiplier: float
) -> GrappleTargetSeed:
	var response := GrappleTargetResponse.new(
		true,
		GrappleTargetResponse.AnchorMode.STATIC,
		pull_multiplier
	)
	return GrappleTargetSeed.new(
		&"target.contract",
		anchor,
		Vector3(0.0, 0.0, 1.0),
		response,
		weakref(target),
		Vector3.ZERO
	)


func _new_controller_fixture() -> Array:
	var root: Node3D = autofree(Node3D.new())
	add_child(root)
	var body := CharacterBody3D.new()
	root.add_child(body)
	var target := StaticBody3D.new()
	target.name = "ContractTarget"
	root.add_child(target)
	var definition := GrappleDefinition.new()
	definition.definition_id = &"player.grapple.default"
	definition.max_grapple_length_m = 35.0
	definition.acquisition_tolerance_m = 0.005
	definition.target_query_profile = _ray_profile()
	assert_eq(definition.validate(), GrappleDefinition.ValidationStatus.SUCCESS)
	var controller := GrappleController.new()
	autofree(controller)
	assert_eq(
		controller.initialize(body, definition),
		GrappleController.InitializationStatus.SUCCESS
	)
	return [controller, target, definition, body]


func _ray_profile() -> PhysicsQueryProfile:
	var profile := PhysicsQueryProfile.new()
	profile.query_kind = PhysicsQueryProfile.QueryKind.RAY
	profile.profile_id = &"player.grapple.candidate"
	profile.collision_mask_names = PackedStringArray(["world_geometry"])
	return profile


func _resolve_boundary_frame(
	motor: PlayerMotor,
	body: CharacterBody3D,
	step: int,
	body_position: Vector3,
	velocity: Vector3,
	anchor: Vector3,
	maximum_distance_m: float,
	delta: float = 1.0 / 60.0
) -> PlayerMotorCommitResult:
	body.global_position = body_position
	body.velocity = velocity
	assert_eq(motor.begin_motion_frame(step, delta), PlayerMotor.FrameStatus.SUCCESS)
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
			anchor,
			maximum_distance_m
		),
		PlayerMotor.SubmissionStatus.SUCCESS
	)
	var result := motor.resolve_and_commit()
	assert_true(result.success)
	return result


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
