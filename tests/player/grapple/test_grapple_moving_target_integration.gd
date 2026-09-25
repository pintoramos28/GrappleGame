extends GutTest


## Story 1.8 real-Jolt integration matrix (AC 10, Task 8.1): moving and stateful
## grapple targets behave predictably and end safely, at both 60 Hz and the
## diagnostic 120 Hz rate. Scenarios run through the real player scene (real
## `PlayerMotor`, real Jolt, real command frames) on engine-driven physics
## frames. Contract-level sampling/boundary math lives in
## `test_grapple_moving_target_contract.gd`; Story 1.7 static-boundary behavior
## is the `static-target regression` scenario below plus the untouched
## `test_grapple_boundary_integration.gd` suite.
##
## Trajectory control uses the documented context-tuning knobs the production
## scene already uses (`grapple_gravity_scale = 0.0` in `main.tscn`) plus
## `air_deceleration = 0`. Separation scenarios use `pull_multiplier = 0.0` so
## ONLY the boundary rule under test can move the player.


const PLAYER_SCENE: PackedScene = preload("res://scenes/player.tscn")
const BOUNDARY_TOLERANCE := 0.05


var _saved_physics_ticks_per_second := 0


func before_each() -> void:
	_saved_physics_ticks_per_second = Engine.physics_ticks_per_second


func after_each() -> void:
	# Restore unconditionally (Story 1.7 review fix): a runtime error between a
	# tick-rate change and its restore must not leak the mutated global rate.
	Engine.physics_ticks_per_second = _saved_physics_ticks_per_second


## ---- AC 3: follow continuous target movement ---------------------------


func test_translation_follow_tracks_the_target_local_hit_point() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		0.1
	)
	await _settle_airborne(player)
	await _start_grapple(player)

	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	var offset: Vector3 = attachment.target_local_hit_offset
	for _step in range(20):
		target.global_position += Vector3(0.08, 0.02, -0.12)
		await get_tree().physics_frame
		var expected := (target as Node3D).global_transform * offset
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active)
		assert_almost_eq(snapshot.anchor_world_position.x, expected.x, 0.001)
		assert_almost_eq(snapshot.anchor_world_position.y, expected.y, 0.001)
		assert_almost_eq(snapshot.anchor_world_position.z, expected.z, 0.001)
		# Presentation agrees with the authoritative sampled anchor (AC 9).
		assert_almost_eq(
			(player.get("grapple_point") as Vector3).distance_to(expected),
			0.0,
			0.001
		)


func test_rotation_follow_tracks_the_target_local_hit_point() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -12.0),
		Vector3(6.0, 30.0, 0.4),
		0.1
	)
	await _settle_airborne(player)
	await _start_grapple(player)

	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	var offset: Vector3 = attachment.target_local_hit_offset
	for _step in range(12):
		target.rotate(Vector3.UP, 0.05)
		await get_tree().physics_frame
		var expected := (target as Node3D).global_transform * offset
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active, "rotation about the hit point never ends the grapple")
		assert_almost_eq(snapshot.anchor_world_position.distance_to(expected), 0.0, 0.001)


func test_sampled_target_velocity_reflects_target_motion_at_both_rates() -> void:
	Engine.physics_ticks_per_second = 60
	var at_sixty := await _sampled_velocity_scenario(60, 8.0)
	Engine.physics_ticks_per_second = 120
	var at_one_twenty := await _sampled_velocity_scenario(120, 8.0)
	Engine.physics_ticks_per_second = _saved_physics_ticks_per_second

	# NFR4: the finite-difference derivation is displacement / delta_seconds and
	# is rate-equivalent (Task 2.3).
	assert_almost_eq(at_sixty, 8.0, 0.35)
	assert_almost_eq(at_one_twenty, 8.0, 0.35)
	assert_almost_eq(at_sixty, at_one_twenty, 0.35)


func _sampled_velocity_scenario(tick_rate: int, target_speed_mps: float) -> float:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -15.0),
		Vector3(20.0, 30.0, 0.4),
		0.1
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	var delta := 1.0 / float(tick_rate)
	var measured := 0.0
	for _step in range(8):
		target.global_position += Vector3(target_speed_mps * delta, 0.0, 0.0)
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		measured = snapshot.target_velocity_mps.x
	assert_true(bool(player.get("is_grappling")))
	return measured


## ---- AC 4: relative-motion maximum-distance resolution -----------------


func test_separating_target_carries_the_player_only_at_the_maximum() -> void:
	Engine.physics_ticks_per_second = 60
	var at_sixty := await _separation_scenario(60, 5.0)
	Engine.physics_ticks_per_second = 120
	var at_one_twenty := await _separation_scenario(120, 5.0)
	Engine.physics_ticks_per_second = _saved_physics_ticks_per_second

	# Before the boundary a separating anchor does not drag the player at all
	# (AC 4 first Given).
	assert_lte(float(at_sixty["max_pre_boundary_drift_m"]), 0.05)
	assert_lte(float(at_one_twenty["max_pre_boundary_drift_m"]), 0.05)
	# At the boundary the player receives exactly the anchor's separating
	# radial motion - no more (AC 4).
	assert_almost_eq(float(at_sixty["boundary_carry_mps"]), 5.0, 0.35)
	assert_almost_eq(float(at_one_twenty["boundary_carry_mps"]), 5.0, 0.35)
	assert_lte(float(at_sixty["max_distance_m"]), 35.0 + BOUNDARY_TOLERANCE)
	assert_lte(float(at_one_twenty["max_distance_m"]), 35.0 + BOUNDARY_TOLERANCE)
	# NFR4: the same real-time scenario agrees across rates.
	assert_almost_eq(
		float(at_sixty["boundary_hit_seconds"]),
		float(at_one_twenty["boundary_hit_seconds"]),
		0.1
	)
	assert_almost_eq(
		float(at_sixty["boundary_carry_mps"]),
		float(at_one_twenty["boundary_carry_mps"]),
		0.35
	)
	assert_eq(bool(at_sixty["still_active"]), bool(at_one_twenty["still_active"]))
	print("[1-8-60-120-separation] 60Hz: ", at_sixty)
	print("[1-8-60-120-separation] 120Hz: ", at_one_twenty)


func _separation_scenario(tick_rate: int, separation_mps: float) -> Dictionary:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	await _settle_airborne(player)
	# Placement happens after settling: the aim distance is measured from the
	# settled crosshair camera (Story 1.6 acquisition basis).
	var target := _add_moving_target_at_aim_distance(player, 32.0, Vector3(12.0, 30.0, 0.4), 0.0)
	await _start_grapple(player)
	# Seed the motion state (Story 1.7 idiom): residual free-fall from settling
	# must not be mistaken for anchor-induced movement.
	player.velocity = Vector3.ZERO
	await get_tree().physics_frame
	var delta := 1.0 / float(tick_rate)
	var start_position: Vector3 = player.global_position
	var max_drift := 0.0
	var boundary_hit_seconds := -1.0
	var boundary_carry := 0.0
	var elapsed := 0.0
	var max_distance := 0.0
	var max_steps := int(ceil(4.0 * tick_rate))
	for step in range(max_steps):
		target.global_position += Vector3(0.0, 0.0, -separation_mps * delta)
		await get_tree().physics_frame
		elapsed += delta
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		max_distance = maxf(max_distance, snapshot.distance_at_resolution_m)
		var boundary_engaged := (
			snapshot.distance_at_resolution_m >= 35.0 - 0.1
			or snapshot.boundary_carry_applied_mps > 0.0
		)
		if boundary_engaged and boundary_hit_seconds < 0.0:
			boundary_hit_seconds = elapsed
		if boundary_hit_seconds < 0.0:
			# Not yet at the maximum: the player must not be dragged.
			max_drift = maxf(max_drift, player.global_position.distance_to(start_position))
		else:
			boundary_carry = maxf(
				boundary_carry,
				absf(minf(snapshot.resolved_radial_velocity_mps, 0.0))
			)
		if step > int(ceil(1.5 * tick_rate)) and boundary_hit_seconds >= 0.0:
			break
	var final_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	return {
		"tick_rate": tick_rate,
		"max_pre_boundary_drift_m": max_drift,
		"boundary_hit_seconds": boundary_hit_seconds,
		"boundary_carry_mps": boundary_carry,
		"max_distance_m": max_distance,
		"still_active": final_snapshot.is_active,
	}


func test_inward_and_tangential_motion_stay_free_at_a_moving_boundary() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	await _settle_airborne(player)
	var target := _add_moving_target_at_aim_distance(
		player,
		34.5,
		Vector3(12.0, 30.0, 0.4),
		0.0
	)
	await _start_grapple(player)
	# Ride the separating target up to the maximum boundary first.
	await _ride_to_boundary(player, target)

	player.velocity = Vector3(12.0, 0.0, -8.0)
	for _step in range(6):
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active)
		assert_gt(snapshot.resolved_tangential_velocity_mps, 8.0, "tangential stays free")
	assert_lt(
		float(
			(
				player.call("get_grapple_attachment_diagnostic_snapshot")
				as GrappleAttachmentDiagnosticSnapshot
			).distance_at_resolution_m
		),
		35.0,
		"inward motion is free and shrinks the tether"
	)


func test_approaching_target_never_pushes_the_player() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	await _settle_airborne(player)
	var target := _add_moving_target_at_aim_distance(
		player,
		34.5,
		Vector3(12.0, 30.0, 0.4),
		0.0
	)
	await _start_grapple(player)
	# Ride to the boundary first (the separating target carries the player).
	await _ride_to_boundary(player, target)
	var before: Vector3 = motor_velocity(player)
	# The anchor now approaches the player at 10 m/s.
	for _step in range(6):
		target.global_position += Vector3(0.0, 0.0, 10.0 / 60.0)
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active)
		assert_almost_eq(float(snapshot.boundary_carry_applied_mps), 0.0, 0.001)
	var after: Vector3 = motor_velocity(player)
	assert_lte(
		after.distance_to(before),
		1.0,
		"an approaching anchor transfers no motion to the player"
	)


## ---- AC 6/7/8: invalid targets, discontinuity, idempotent termination ---


func test_freed_target_terminates_once_without_a_velocity_spike() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		0.0
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	for _step in range(5):
		await get_tree().physics_frame
	var before: Vector3 = motor.get_committed_velocity()
	var events := _count_ended_events(player)

	# `queue_free` deletes at the end of the frame: two steps cover the deletion
	# and the sampling phase that observes it.
	target.queue_free()
	await get_tree().physics_frame
	await get_tree().physics_frame
	assert_false(bool(player.get("is_grappling")))
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_true(attachment.has_committed_terminal())
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.TARGET_DESTROYED)
	assert_eq(events[0], 1, "attachment_ended fires exactly once")
	var after: Vector3 = motor.get_committed_velocity()
	assert_lte(after.distance_to(before), 1.0, "no residual constraint impulse or velocity spike")
	var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_false(commit.applied_constraints.has(&"player.grapple.maximum_distance"))
	assert_false(commit.applied_caps.has(&"player.grapple.speed_cap"))
	assert_eq(commit.commit_count, 1)
	# The player returns to a valid traversal state through the existing
	# locomotion dispatch (AC 8).
	await get_tree().physics_frame
	var resumed: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_ne(resumed.locomotion_state_id, &"player.locomotion.grappling")


func test_explicit_invalidation_terminates_once_with_target_invalidated() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		1.0
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	await get_tree().physics_frame
	assert_true(bool(player.get("is_grappling")))
	var events := _count_ended_events(player)

	Grappleable3D.find_explicit_grappleables(target)[0].invalidate_grapple_anchor()
	await get_tree().physics_frame
	assert_false(bool(player.get("is_grappling")))
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.TARGET_INVALIDATED)
	assert_eq(events[0], 1)


func test_scope_mismatch_terminates_once_with_scope_mismatch() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		1.0
	)
	Grappleable3D.find_explicit_grappleables(target)[0].encounter_scope_identity = (
		&"encounter.run_b"
	)
	player.set(
		"grapple_encounter_scope_provider",
		func() -> StringName:
			return &"encounter.run_a"
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	await get_tree().physics_frame
	assert_false(bool(player.get("is_grappling")), "the incompatible scope ends the grapple")
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.SCOPE_MISMATCH)
	assert_eq(attachment.originating_scope_identity, &"encounter.run_a")


func test_severe_anchor_discontinuity_terminates_instead_of_snapping() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		0.1
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	for _step in range(5):
		await get_tree().physics_frame
	var before: Vector3 = player.global_position

	# A 10 m one-step jump: far above the severe threshold at either rate.
	target.global_position += Vector3(10.0, 0.0, -10.0)
	await get_tree().physics_frame
	assert_false(bool(player.get("is_grappling")))
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.ANCHOR_DISCONTINUITY)
	# The player is never snapped or teleported to the jumped anchor.
	assert_lte(player.global_position.distance_to(before), 1.0)
	var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_eq(commit.commit_count, 1)
	assert_false(commit.is_hold_request)


func test_overlapping_termination_paths_commit_exactly_once() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		1.0
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	await get_tree().physics_frame
	var events := _count_ended_events(player)

	# Release edge + death + target removal requested for the same step.
	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	player.call("_set_dead")
	target.queue_free()
	await get_tree().physics_frame
	assert_false(bool(player.get("is_grappling")))
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_true(attachment.has_committed_terminal())
	assert_eq(events[0], 1, "cleanup and the terminal event happen exactly once")
	var terminal := attachment.get_terminal()
	player.call("_set_dead")
	assert_same(attachment.get_terminal(), terminal)
	assert_eq(events[0], 1)
	var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_eq(commit.commit_count, 1)
	assert_ne(commit.locomotion_state_id, &"player.locomotion.grappling")


## ---- AC 5: static-target regression ------------------------------------


func test_static_target_regression_keeps_the_story_1_7_response() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var motor: PlayerMotor = fixture[1]
	_add_box_target(player.get_parent(), Vector3(0.0, 6.0, -20.0), Vector3(20.0, 30.0, 0.4))
	await _settle_airborne(player)
	await _start_grapple(player)

	var start_snapshot: GrappleAttachmentDiagnosticSnapshot = (
		player.call("get_grapple_attachment_diagnostic_snapshot")
	)
	var frozen_anchor: Vector3 = start_snapshot.anchor_world_position
	for _step in range(20):
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active)
		assert_eq(snapshot.anchor_world_position, frozen_anchor, "frozen world anchor")
		assert_eq(snapshot.target_velocity_mps, Vector3.ZERO)
		assert_true(snapshot.anchor_valid)
		assert_eq(snapshot.anchor_status_id, &"valid")
		assert_gt(snapshot.submitted_acceleration_mps2, 0.0)
	var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
	assert_eq(commit.commit_count, 1)
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	assert_true(attachment.is_definition_unmodified())


## ---- AC 3 / Task 3.3: no target-selection raycast while attached -------


func test_anchor_follow_repeats_no_target_selection_raycast_while_attached() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		1.0
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	var acquisition = player.call("get_latest_grapple_targeting_result")
	assert_not_null(acquisition)
	var acquisition_step: int = acquisition.source_physics_step

	for _step in range(15):
		target.global_position += Vector3(0.05, 0.0, -0.05)
		await get_tree().physics_frame
		var latest = player.call("get_latest_grapple_targeting_result")
		assert_not_null(latest)
		assert_eq(
			latest.source_physics_step,
			acquisition_step,
			"no target-selection query runs while attached (AC 3)"
		)
		assert_eq(latest.query_count, 1, "the 1.6 one-query-per-evaluated-step discipline holds")
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_true(snapshot.is_active, "the anchor still follows by transform math")

	# After release the next evaluated step queries exactly once again.
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
	await get_tree().physics_frame
	await get_tree().physics_frame
	var refreshed = player.call("get_latest_grapple_targeting_result")
	assert_not_null(refreshed)
	assert_gt(refreshed.source_physics_step, acquisition_step)


## ---- Task 7.2: presentation follows the sampled anchor -----------------


func test_rope_endpoint_follows_the_sampled_anchor_without_new_resets() -> void:
	var fixture := _new_traversal_fixture(Vector3(0.0, 6.0, 0.0))
	var player: CharacterBody3D = fixture[0]
	var target := _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, -20.0),
		Vector3(20.0, 30.0, 0.4),
		1.0
	)
	await _settle_airborne(player)
	await _start_grapple(player)
	var rope: MeshInstance3D = player.get("grapple_visual")
	assert_true(rope.visible)
	var resets_after_reveal: int = player.get("grapple_visual_reset_count")
	assert_eq(resets_after_reveal, 1, "the frozen rope spec resets once on reveal")

	for _step in range(15):
		target.global_position += Vector3(0.05, 0.0, -0.05)
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		assert_almost_eq(
			(player.get("grapple_point") as Vector3).distance_to(snapshot.anchor_world_position),
			0.0,
			0.001
		)
		assert_eq(
			int(player.get("grapple_visual_reset_count")),
			resets_after_reveal,
			"no new interpolation reset while the rope stays visible"
		)
	# A frozen rope spec guard: exactly one reset call site exists in the owner.
	var source := FileAccess.get_file_as_string("res://scripts/player_controller.gd")
	var reset_sites := 0
	for line in source.split("\n"):
		if line.strip_edges().begins_with("#"):
			continue
		reset_sites += line.count("reset_physics_interpolation()")
	assert_eq(reset_sites, 1, "the single reset_physics_interpolation() call site is preserved")


## ---- Fixtures ----------------------------------------------------------


## Separates the target at 5 m/s until the tether reaches its maximum length
## (the boundary engages), so the caller can assert boundary behavior.
func _ride_to_boundary(
	player: CharacterBody3D,
	target: StaticBody3D,
	max_steps: int = 180
) -> void:
	var reached := false
	for _step in range(max_steps):
		target.global_position += Vector3(0.0, 0.0, -5.0 / 60.0)
		await get_tree().physics_frame
		var snapshot: GrappleAttachmentDiagnosticSnapshot = (
			player.call("get_grapple_attachment_diagnostic_snapshot")
		)
		if snapshot != null and snapshot.distance_at_resolution_m >= 35.0 - 0.05:
			reached = true
			break
	assert_true(reached, "the separating target must reach the maximum boundary")


func _count_ended_events(player: CharacterBody3D) -> Array:
	var controller: GrappleController = player.get("_grapple_controller")
	var events: Array = [0]
	controller.attachment_ended.connect(
		func(_attachment_id: StringName, _reason: GrappleEndReason.Reason) -> void:
			events[0] = int(events[0]) + 1
	)
	return events


func motor_velocity(player: CharacterBody3D) -> Vector3:
	return (player.get_node(^"PlayerMotor") as PlayerMotor).get_committed_velocity()


func _add_moving_target(
	world: Node3D,
	target_position: Vector3,
	size: Vector3,
	pull_multiplier: float
) -> StaticBody3D:
	var body := _add_box_target(world, target_position, size)
	var component := Grappleable3D.new()
	component.name = "Grappleable"
	component.target_id = &"target.moving_case"
	component.anchor_mode = GrappleTargetResponse.AnchorMode.MOVING
	component.pull_multiplier = pull_multiplier
	body.add_child(component)
	return body


## Places the target's near face at `aim_distance_m` from the crosshair ray
## origin (Story 1.6 acquisition is measured from the camera), mirroring the
## Story 1.7 `_place_target_at_aim_distance` idiom.
func _add_moving_target_at_aim_distance(
	player: CharacterBody3D,
	aim_distance_m: float,
	size: Vector3,
	pull_multiplier: float
) -> StaticBody3D:
	var camera: Camera3D = player.get_node(^"CameraPivot/SpringArm3D/Camera3D")
	var anchor_z := camera.global_position.z - aim_distance_m
	return _add_moving_target(
		player.get_parent(),
		Vector3(0.0, 6.0, anchor_z - 0.2),
		size,
		pull_multiplier
	)


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


func _settle_airborne(player: CharacterBody3D) -> void:
	var motor: PlayerMotor = player.get_node(^"PlayerMotor")
	var found_airborne := false
	for _frame in range(8):
		await get_tree().physics_frame
		var current: PlayerMotorCommitResult = motor.get_last_commit_result()
		if current != null and current.locomotion_state_id == &"player.locomotion.airborne":
			found_airborne = true
			break
	assert_true(found_airborne)


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
	player.position = player_position
	world.add_child(player)
	# Context tuning used by the production launch scene plus a zero horizontal
	# drag so only the pull profile, seeded momentum, and boundary act.
	player.set("grapple_gravity_scale", 0.0)
	player.set("air_deceleration", 0.0)
	var input_source: PlayerInputSource = player.get_node(^"PlayerInputSource")
	input_source.enable_test_input_seam()
	return [player, player.get_node(^"PlayerMotor")]
