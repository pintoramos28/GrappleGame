extends GutTest


## Story 1.7 real-Jolt integration scenarios (AC 13): the grapple behaves as an
## acceleration-based zip-pull with a maximum-only boundary and preserves valid
## momentum. All scenarios run through the real player scene (real `PlayerMotor`,
## real Jolt, real command frames) and step on engine-driven physics frames, so
## `move_and_slide()` integrates with the physics delta exactly as in the running
## game. Contract-level clipping math lives in `test_grapple_boundary_contract.gd`.
##
## These legacy central-force fixtures deliberately leave the optional origin
## unassigned; the authored pull then starts at the body root, so it
## preserves angular momentum (`|r x v|`) while the tangential speed varies as
## `1 / r` - the player is faster along the tangent when closer. The boundary
## removes only the outward radial component, so it preserves angular momentum
## too. Tests therefore assert angular-momentum conservation plus tangential
## stability while the radius is held at the boundary.
##
## Trajectory control uses documented context-tuning knobs the production scene
## already uses (`grapple_gravity_scale` is 0.0 in `main.tscn`). The optional
## origin is unassigned and grapple deceleration defaults to zero, so seeded
## momentum, the authored pull profile, and the boundary are the only influences
## under test. The fixture also sets ordinary air deceleration to zero for its
## pre-attachment setup.


const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const BOUNDARY_TOLERANCE := 0.05


var _saved_physics_ticks_per_second := 0


func before_each() -> void:
	_saved_physics_ticks_per_second = Engine.physics_ticks_per_second


func after_each() -> void:
	# Restore unconditionally (Task 6.3). GUT asserts do not abort a test, but a
	# runtime error between a tick-rate change and its restore would otherwise
	# leak the mutated global rate into every later test and produce cascading
	# timing failures far from their cause.
	Engine.physics_ticks_per_second = _saved_physics_ticks_per_second


func test_well_inside_attachment_pulls_without_boundary_corrections() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	_add_grappleable_target(player.get_parent(), Vector3(0.0, 6.0, -20.0), Vector3(20.0, 30.0, 0.4), 1.0)
	await _settle_airborne(player, motor)
	await _start_grapple(player)

	for _step in range(20):
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active)
		assert_false(snapshot.boundary_correction_applied, "no correction inside the boundary")
		assert_lt(snapshot.distance_at_resolution_m, snapshot.maximum_distance_m)
		assert_gt(snapshot.submitted_acceleration_mps2, 0.0)

	var final_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	assert_true(final_snapshot.is_active)
	assert_almost_eq(
		final_snapshot.range_fraction,
		final_snapshot.distance_at_resolution_m / final_snapshot.maximum_distance_m,
		0.0001
	)
	assert_lte(final_snapshot.maximum_distance_m, 35.0 + 0.0001)
	assert_true(player.call("get_grapple_attachment").is_definition_unmodified())


func test_grapple_air_deceleration_is_independent_of_airborne_deceleration() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	player.air_deceleration = 5.0
	player.grapple_air_deceleration = 0.0
	_add_grappleable_target(player.get_parent(), Vector3(0.0, 6.0, -20.0), Vector3(20.0, 30.0, 0.4), 1.0)
	await _settle_airborne(player, motor)
	await _start_grapple(player)
	motor.set_diagnostics_enabled(true)
	player.velocity = Vector3(-4.0, 0.0, -6.0)
	await get_tree().physics_frame
	var phase: Dictionary = motor.get_diagnostic_snapshot().phase_intermediates[
		MotorPhase.Phase.BASE_LOCOMOTION_AND_GRAVITY
	]
	assert_eq(phase["id"], &"base_locomotion_and_gravity")
	assert_almost_eq(phase["after_velocity"].x, phase["before_velocity"].x, 0.00001)
	assert_almost_eq(phase["after_velocity"].z, phase["before_velocity"].z, 0.00001)

	# Changing only grapple tuning affects the active grapple on the next frame.
	player.grapple_air_deceleration = 3.0
	await get_tree().physics_frame
	phase = motor.get_diagnostic_snapshot().phase_intermediates[
		MotorPhase.Phase.BASE_LOCOMOTION_AND_GRAVITY
	]
	assert_almost_eq(
		phase["after_velocity"].x - phase["before_velocity"].x,
		3.0 / float(Engine.physics_ticks_per_second), 0.00001
	)
	assert_almost_eq(
		phase["after_velocity"].z - phase["before_velocity"].z,
		3.0 / float(Engine.physics_ticks_per_second), 0.00001
	)

	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var diagnostic := motor.get_diagnostic_snapshot()
	assert_eq(diagnostic.locomotion_state_id, &"player.locomotion.airborne")
	phase = diagnostic.phase_intermediates[MotorPhase.Phase.BASE_LOCOMOTION_AND_GRAVITY]
	assert_almost_eq(
		phase["after_velocity"].x - phase["before_velocity"].x,
		5.0 / float(Engine.physics_ticks_per_second), 0.00001
	)
	assert_almost_eq(
		phase["after_velocity"].z - phase["before_velocity"].z,
		5.0 / float(Engine.physics_ticks_per_second), 0.00001
	)


func test_stationary_zero_gravity_angled_wall_pull_stays_on_aim_line_before_contact() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 0.1, 0.0))
	var player: CharacterBody3D = fixture[0]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	player.grapple_origin = player.get_node(^"GrappleOrigin")
	player.ground_deceleration = 30.0
	player.air_deceleration = 5.0
	assert_eq(player.grapple_ground_deceleration, 0.0)
	assert_eq(player.grapple_air_deceleration, 0.0)
	# A broad X-facing wall: the camera ray hits its X face diagonally, not a
	# head-on Z face. Ordinary locomotion damping would bend this pull off-axis.
	_add_box_target(
		player.get_parent(), Vector3(-8.7, 3.0, -23.5), Vector3(0.4, 8.0, 23.0)
	)
	input_source.inject_mouse_motion(Vector2(-154.0, 0.0))
	for _frame in range(4):
		await get_tree().physics_frame
	var targeting = player.call("get_latest_grapple_targeting_result")
	assert_true(targeting.is_accepted())
	var start: Vector3 = player.global_position
	assert_lt(player.velocity.length(), 0.001)
	var direction: Vector3 = (
		targeting.hit_position - player.get_node(^"GrappleOrigin").global_position
	).normalized()
	await _start_grapple(player)
	for _frame in range(60):
		await get_tree().physics_frame
	assert_true(player.is_grappling)
	assert_false(player.is_on_wall(), "check the path before any wall collision")
	assert_gt(player.velocity.length(), 10.0, "pull must actually move the player")
	assert_lt(
		(player.global_position - start).cross(direction).length(), 0.03,
		"zero-input grapple deceleration must not bend the diagonal pull"
	)


func test_near_boundary_attachment_stays_inside_without_corrections() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	await _settle_airborne(player, motor)
	# Acquisition range is measured from the crosshair ray origin (Story 1.6,
	# locked); place the anchor just inside it and confirm the active boundary
	# makes no correction while the player stays inside the shared maximum.
	_place_target_at_aim_distance(player, 34.5)
	await _start_grapple(player)

	var start_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	assert_gt(start_snapshot.distance_at_resolution_m, 25.0, "attachment lands near the boundary")
	assert_lte(start_snapshot.distance_at_resolution_m, 35.0)

	for _step in range(10):
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active)
		assert_false(snapshot.boundary_correction_applied, "no correction while inside")
		assert_lte(snapshot.range_fraction, 1.0)


func test_outward_travel_from_a_short_attachment_reaches_only_the_maximum_boundary() -> void:
	var outcome := await _reach_maximum_boundary(60, 8.0, 20.0)

	# AC 4: the ~10 m attachment distance is not a rope length - the player
	# travels well past it and only the authored 35 m maximum stops it.
	assert_gt(
		float(outcome["attachment_distance_m"]),
		5.0,
		"attachment lands at a short distance"
	)
	assert_lt(float(outcome["attachment_distance_m"]), 15.0)
	assert_gt(
		float(outcome["max_distance_m"]),
		20.0,
		"the player must travel well beyond the attachment distance"
	)
	assert_lte(
		float(outcome["max_distance_m"]),
		35.0 + BOUNDARY_TOLERANCE,
		"the authored maximum boundary is never exceeded"
	)
	assert_gt(int(outcome["correction_steps"]), 0, "the boundary must actually engage")
	assert_gt(float(outcome["boundary_hit_seconds"]), 0.0)
	assert_lte(
		absf(float(outcome["final_radial_mps"])),
		2.0,
		"outward motion is clipped at the boundary"
	)
	assert_true(bool(outcome["still_active"]), "the attachment survives the boundary")
	assert_true(bool(outcome["definition_unmodified"]))

	# Momentum: the central pull and the radial-only boundary preserve angular
	# momentum exactly (AC 2/4/5); only the radial component is ever touched.
	assert_gt(int(outcome["momentum_samples"]), 10)
	var momentum_mean := (
		float(outcome["min_angular_momentum"]) + float(outcome["max_angular_momentum"])
	) * 0.5
	assert_lte(
		float(outcome["max_angular_momentum"]) - float(outcome["min_angular_momentum"]),
		momentum_mean * 0.02 + 0.01,
		"angular momentum is preserved across pull and boundary clipping"
	)


func test_inward_travel_at_the_boundary_is_unrestricted() -> void:
	var outcome := await _reach_boundary_with_owner(60, 8.0, 20.0)
	var player: CharacterBody3D = outcome["player"]

	var at_boundary: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	var boundary_distance := at_boundary.distance_at_resolution_m
	assert_gte(boundary_distance, 35.0 - 0.1)

	player.velocity = Vector3(0.0, 0.0, -12.0)
	for _step in range(20):
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_false(snapshot.boundary_correction_applied, "inward motion is never clipped")

	var final_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	assert_lt(final_snapshot.distance_at_resolution_m, boundary_distance, "inward travel is free")
	assert_true(final_snapshot.is_active)


func test_tangential_travel_at_the_boundary_is_unrestricted() -> void:
	var outcome := await _reach_boundary_with_owner(60, 8.0, 20.0)
	var player: CharacterBody3D = outcome["player"]

	# Hold the radius at the boundary with a fast tangential slide (the outward
	# regeneration from the curved path balances the weak authored pull).
	player.velocity = Vector3(20.0, 0.0, 0.0)
	await get_tree().physics_frame
	var at_boundary: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	var tangential_at_boundary := at_boundary.resolved_tangential_velocity_mps
	assert_gt(tangential_at_boundary, 15.0, "the slide arrives with tangential momentum")

	var correction_steps := 0
	var max_distance := at_boundary.distance_at_resolution_m
	var min_tangential := tangential_at_boundary
	var max_tangential := tangential_at_boundary
	for _step in range(20):
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		max_distance = maxf(max_distance, snapshot.distance_at_resolution_m)
		if snapshot.boundary_correction_applied:
			correction_steps += 1
		min_tangential = minf(min_tangential, snapshot.resolved_tangential_velocity_mps)
		max_tangential = maxf(max_tangential, snapshot.resolved_tangential_velocity_mps)

	assert_gt(correction_steps, 0, "the slide rides the boundary")
	assert_lte(max_distance, 35.0 + BOUNDARY_TOLERANCE)
	assert_lte(
		max_tangential - min_tangential,
		0.3,
		"tangential speed is stable while the boundary holds the radius (AC 5)"
	)
	var final_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	assert_true(final_snapshot.is_active)


func test_high_speed_overshoot_is_prevented_without_snapping_or_zeroing() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	_add_grappleable_target(player.get_parent(), Vector3(0.0, 6.0, -10.0), Vector3(12.0, 30.0, 0.4), 0.1)
	await _settle_airborne(player, motor)
	await _start_grapple(player)

	player.velocity = Vector3(8.0, 0.0, 20.0)
	await get_tree().physics_frame
	var max_distance := 0.0
	var previous_distance := 1000.0
	var largest_inward_jump := 0.0
	var correction_steps := 0
	var min_angular_momentum := 0.0
	var max_angular_momentum := 0.0
	var momentum_samples := 0
	for step in range(120):
		await get_tree().physics_frame
		var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
		assert_not_null(commit)
		assert_eq(commit.commit_count, 1, "the boundary never adds a second commit")
		assert_false(commit.is_hold_request, "the boundary never snaps or teleports")
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		max_distance = maxf(max_distance, snapshot.distance_at_resolution_m)
		if previous_distance < 900.0:
			largest_inward_jump = maxf(
				largest_inward_jump,
				previous_distance - snapshot.distance_at_resolution_m
			)
		previous_distance = snapshot.distance_at_resolution_m
		if step >= 1:
			var angular_momentum := _angular_momentum(player, snapshot)
			if momentum_samples == 0:
				min_angular_momentum = angular_momentum
				max_angular_momentum = angular_momentum
			else:
				min_angular_momentum = minf(min_angular_momentum, angular_momentum)
				max_angular_momentum = maxf(max_angular_momentum, angular_momentum)
			momentum_samples += 1
		if snapshot.boundary_correction_applied:
			correction_steps += 1

	assert_gt(correction_steps, 0)
	assert_lte(
		max_distance,
		35.0 + BOUNDARY_TOLERANCE,
		"the high-speed step is prevented within the documented positional tolerance"
	)
	assert_lte(
		largest_inward_jump,
		0.5,
		"no step may teleport the player (the fastest authored speed moves 0.37 m per step)"
	)
	var momentum_mean := (min_angular_momentum + max_angular_momentum) * 0.5
	assert_lte(
		max_angular_momentum - min_angular_momentum,
		momentum_mean * 0.02 + 0.01,
		"momentum is preserved through the overshoot correction"
	)
	var final_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	assert_gt(final_snapshot.resolved_tangential_velocity_mps, 0.5, "real momentum is left")
	assert_true(final_snapshot.is_active)


func test_release_preserves_the_resolved_velocity_and_commits_release() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	_add_grappleable_target(player.get_parent(), Vector3(0.0, 6.0, -20.0), Vector3(20.0, 30.0, 0.4), 1.0)
	await _settle_airborne(player, motor)
	await _start_grapple(player)

	for _step in range(5):
		await get_tree().physics_frame
	var before := motor.get_committed_velocity()
	assert_gt(before.length(), 0.5, "the zip-pull built real momentum")

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	await get_tree().physics_frame
	var after := motor.get_committed_velocity()

	# AC 8: release stops the grapple submissions for the same step and keeps
	# the resolved velocity - no stop, snap, or replacement launch velocity.
	assert_false(bool(player.get("is_grappling")))
	assert_almost_eq(after.x, before.x, 0.05)
	assert_almost_eq(after.y, before.y, 0.05)
	assert_almost_eq(after.z, before.z, 0.05)
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_true(attachment.has_committed_terminal())
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.RELEASE)
	assert_almost_eq(attachment.get_terminal().release_velocity.z, before.z, 0.05)
	var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_false(commit.applied_caps.has(&"player.grapple.speed_cap"))
	assert_false(commit.applied_constraints.has(&"player.grapple.maximum_distance"))
	assert_eq(commit.commit_count, 1)


func test_death_cancels_the_attachment_once_and_stops_submissions() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	_add_grappleable_target(player.get_parent(), Vector3(0.0, 6.0, -20.0), Vector3(20.0, 30.0, 0.4), 1.0)
	await _settle_airborne(player, motor)
	await _start_grapple(player)
	await get_tree().physics_frame
	assert_true(bool(player.get("is_grappling")))

	player.call("_set_dead")
	assert_false(bool(player.get("is_grappling")))
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_true(attachment.has_committed_terminal())
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.OWNER_DEATH)

	await get_tree().physics_frame
	var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_not_null(commit)
	assert_eq(commit.locomotion_state_id, &"player.locomotion.dead")
	assert_false(commit.applied_caps.has(&"player.grapple.speed_cap"))
	assert_false(commit.applied_constraints.has(&"player.grapple.maximum_distance"))
	assert_eq(commit.commit_count, 1)

	# Death cancellation is idempotent (NFR15).
	var terminal := attachment.get_terminal()
	player.call("_set_dead")
	assert_same(attachment.get_terminal(), terminal)


func test_duplicate_termination_requests_repeat_no_cleanup() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	_add_grappleable_target(player.get_parent(), Vector3(0.0, 6.0, -20.0), Vector3(20.0, 30.0, 0.4), 1.0)
	await _settle_airborne(player, motor)
	await _start_grapple(player)
	await get_tree().physics_frame

	var controller: GrappleController = player.get("_grapple_controller")
	var ended_events: Array = []
	controller.attachment_ended.connect(
		func(attachment_id: StringName, reason: GrappleEndReason.Reason) -> void:
			ended_events.append([attachment_id, reason])
	)
	var rope: MeshInstance3D = player.get("grapple_visual")
	assert_true(rope.visible)

	assert_true(player.call("terminate_grapple", GrappleEndReason.Reason.STATE_CANCELLATION))
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	var terminal := attachment.get_terminal()
	assert_eq(terminal.reason, GrappleEndReason.Reason.STATE_CANCELLATION)
	assert_eq(ended_events.size(), 1)
	assert_false(rope.visible)

	assert_false(player.call("terminate_grapple", GrappleEndReason.Reason.OWNER_DEATH))
	assert_same(attachment.get_terminal(), terminal)
	assert_eq(terminal.reason, GrappleEndReason.Reason.STATE_CANCELLATION)
	assert_eq(ended_events.size(), 1)
	assert_false(rope.visible)

	await get_tree().physics_frame
	var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_false(commit.applied_caps.has(&"player.grapple.speed_cap"))
	assert_false(commit.applied_constraints.has(&"player.grapple.maximum_distance"))


func test_boundary_scenario_matches_between_sixty_and_one_twenty_hz() -> void:
	# The happy path restores explicitly; `after_each` is the safety net for any
	# exit path that leaves this method early.
	Engine.physics_ticks_per_second = 60
	var at_sixty := await _run_release_scenario(60, 8.0, 20.0)
	Engine.physics_ticks_per_second = 120
	var at_one_twenty := await _run_release_scenario(120, 8.0, 20.0)
	Engine.physics_ticks_per_second = _saved_physics_ticks_per_second

	# NFR4: equivalent real-time scenarios agree on attachment duration,
	# acceleration, boundary behavior, and release velocity within documented
	# tolerances (see evidence/1-7/60-120-comparison.md).
	assert_almost_eq(
		float(at_sixty["boundary_hit_seconds"]),
		float(at_one_twenty["boundary_hit_seconds"]),
		0.05
	)
	assert_almost_eq(
		float(at_sixty["max_distance_m"]),
		float(at_one_twenty["max_distance_m"]),
		0.25
	)
	assert_almost_eq(
		float(at_sixty["final_acceleration_mps2"]),
		float(at_one_twenty["final_acceleration_mps2"]),
		0.05
	)
	assert_almost_eq(
		float(at_sixty["release_speed_mps"]),
		float(at_one_twenty["release_speed_mps"]),
		0.5
	)
	assert_almost_eq(
		float(at_sixty["attachment_duration_seconds"]),
		float(at_one_twenty["attachment_duration_seconds"]),
		0.05
	)
	assert_eq(bool(at_sixty["still_active"]), bool(at_one_twenty["still_active"]))
	assert_gt(int(at_sixty["correction_steps"]), 0)
	assert_gt(int(at_one_twenty["correction_steps"]), 0)

	# Diagnostic trace for evidence/1-7/60-120-comparison.md (numbers only).
	print("[1-7-60-120] 60Hz: ", at_sixty)
	print("[1-7-60-120] 120Hz: ", at_one_twenty)


## Outward-travel scenario up to (and settled at) the maximum boundary: attach at
## ~10 m with outward momentum and a weak authored pull (`pull_multiplier`), then
## let the player coast outward until the boundary engages.
func _reach_maximum_boundary(
	tick_rate: int,
	tangential_speed: float,
	outward_speed: float
) -> Dictionary:
	var outcome := await _reach_boundary_with_owner(tick_rate, tangential_speed, outward_speed)
	return outcome["facts"]


func _reach_boundary_with_owner(
	tick_rate: int,
	tangential_speed: float,
	outward_speed: float
) -> Dictionary:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	_add_grappleable_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -10.0),
		Vector3(12.0, 30.0, 0.4),
		0.1
	)
	await _settle_airborne(player, motor)
	await _start_grapple(player)

	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	var start_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	var attachment_distance := start_snapshot.distance_at_resolution_m
	assert_gt(attachment_distance, 5.0)
	assert_lt(attachment_distance, 15.0)

	player.velocity = Vector3(tangential_speed, 0.0, outward_speed)
	await get_tree().physics_frame

	var max_distance := attachment_distance
	var correction_steps := 0
	var boundary_hit_seconds := -1.0
	var elapsed_seconds := 0.0
	var min_angular_momentum := 0.0
	var max_angular_momentum := 0.0
	var momentum_samples := 0
	var max_steps := int(ceil(4.0 * tick_rate))
	for step in range(max_steps):
		await get_tree().physics_frame
		elapsed_seconds += 1.0 / float(tick_rate)
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		max_distance = maxf(max_distance, snapshot.distance_at_resolution_m)
		# Skip the first sampled frame: the seeded velocity may only be in
		# effect from the second engine-driven step, so momentum tracking starts
		# once the seeded state is definitely live.
		if step >= 1:
			var angular_momentum := _angular_momentum(player, snapshot)
			if momentum_samples == 0:
				min_angular_momentum = angular_momentum
				max_angular_momentum = angular_momentum
			else:
				min_angular_momentum = minf(min_angular_momentum, angular_momentum)
				max_angular_momentum = maxf(max_angular_momentum, angular_momentum)
			momentum_samples += 1
		if snapshot.boundary_correction_applied:
			correction_steps += 1
			if boundary_hit_seconds < 0.0:
				boundary_hit_seconds = snapshot.elapsed_seconds
		if boundary_hit_seconds >= 0.0 and snapshot.distance_at_resolution_m >= 35.0 - 0.02:
			break

	var final_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	var facts := {
		"tick_rate": tick_rate,
		"attachment_distance_m": attachment_distance,
		"max_distance_m": max_distance,
		"correction_steps": correction_steps,
		"boundary_hit_seconds": boundary_hit_seconds,
		"elapsed_seconds": elapsed_seconds,
		"final_radial_mps": final_snapshot.resolved_radial_velocity_mps,
		"final_tangential_mps": final_snapshot.resolved_tangential_velocity_mps,
		"final_acceleration_mps2": final_snapshot.submitted_acceleration_mps2,
		"min_angular_momentum": min_angular_momentum,
		"max_angular_momentum": max_angular_momentum,
		"momentum_samples": momentum_samples,
		"still_active": final_snapshot.is_active,
		"definition_unmodified": attachment.is_definition_unmodified(),
	}
	return {"player": player, "motor": motor, "facts": facts}


## Same outward scenario followed by a release, for the 60/120 equivalence gate.
func _run_release_scenario(
	tick_rate: int,
	tangential_speed: float,
	outward_speed: float
) -> Dictionary:
	var outcome := await _reach_boundary_with_owner(tick_rate, tangential_speed, outward_speed)
	var player: CharacterBody3D = outcome["player"]
	var motor: PlayerMotor = outcome["motor"]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var facts: Dictionary = outcome["facts"]
	var attachment_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	facts["attachment_duration_seconds"] = attachment_snapshot.elapsed_seconds
	facts["release_speed_mps"] = motor.get_committed_velocity().length()

	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	await get_tree().physics_frame
	assert_false(bool(player.get("is_grappling")))
	assert_eq(
		(player.call("get_grapple_attachment") as GrappleAttachment).get_terminal().reason,
		GrappleEndReason.Reason.RELEASE
	)
	return facts


func _angular_momentum(
	player: CharacterBody3D,
	snapshot: GrappleAttachmentDiagnosticSnapshot
) -> float:
	var radius := player.global_position - snapshot.anchor_world_position
	return radius.cross(snapshot.committed_velocity_mps).length()


func _place_target_at_aim_distance(player: CharacterBody3D, aim_distance_m: float) -> StaticBody3D:
	var camera: Camera3D = player.get_node(^"CameraPivot/SpringArm3D/Camera3D")
	var anchor_z := camera.global_position.z - aim_distance_m
	return _add_grappleable_target(
		player.get_parent(),
		Vector3(0.0, 6.0, anchor_z - 0.2),
		Vector3(12.0, 30.0, 0.4),
		0.1
	)


func _start_grapple(player: CharacterBody3D) -> void:
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
	await get_tree().physics_frame
	var rejection := GrappleRejection.Reason.MISSING_RESULT
	var latest = player.call("get_latest_grapple_targeting_result")
	if latest != null:
		rejection = latest.rejection
	assert_true(
		bool(player.get("is_grappling")),
		"the press edge must commit one attachment (targeting: %s)" % GrappleRejection.reason_id(rejection)
	)


func _settle_airborne(player: CharacterBody3D, motor: PlayerMotor) -> void:
	var found_airborne := false
	for _frame in range(8):
		await get_tree().physics_frame
		var current: PlayerMotorCommitResult = motor.get_last_commit_result()
		if current != null and current.locomotion_state_id == &"player.locomotion.airborne":
			found_airborne = true
			break
	assert_true(found_airborne)


func _add_grappleable_target(
	world: Node3D,
	target_position: Vector3,
	size: Vector3,
	pull_multiplier: float
) -> StaticBody3D:
	var body := _add_box_target(world, target_position, size)
	var component := Grappleable3D.new()
	component.name = "Grappleable"
	component.target_id = &"target.boundary_case"
	component.pull_multiplier = pull_multiplier
	body.add_child(component)
	return body


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


func _new_traversal_fixture(player_position: Vector3) -> Array[Node]:
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
	# Isolate the original root-based central-force/boundary momentum contract.
	# Other grapple integration tests cover the scene-assigned hand marker.
	player.set("grapple_origin", null)
	player.position = player_position
	world.add_child(player)
	# Context tuning used by the production launch scene plus a zero horizontal
	# drag so only the pull profile, seeded momentum, and boundary act.
	player.set("grapple_gravity_scale", 0.0)
	player.set("air_deceleration", 0.0)
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	input_source.enable_test_input_seam()
	return [player, player.get_node(^"PlayerMotor")]
