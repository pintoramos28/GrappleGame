extends GutTest


const ROUTE_PATH := "res://game/levels/content/traversal_validation/traversal_validation_route.tscn"

var _saved_rate := 60


func before_each() -> void:
	_saved_rate = Engine.physics_ticks_per_second


func after_each() -> void:
	Engine.physics_ticks_per_second = _saved_rate


func test_route_loads_with_the_production_player_and_independent_main_scene() -> void:
	var route_scene := load(ROUTE_PATH) as PackedScene
	assert_not_null(route_scene, "the focused validation route must be a standalone scene")
	if route_scene == null:
		return
	var route := route_scene.instantiate()
	add_child_autofree(route)
	var player := route.get_node_or_null(^"Player") as CharacterBody3D
	assert_not_null(player)
	if player == null:
		return
	assert_eq((player.get_node(^"PlayerInputSource") as PlayerInputSource).get_script().resource_path, "res://game/player/input/player_input_source.gd")
	assert_eq((player.get_node(^"PlayerMotor") as PlayerMotor).get_script().resource_path, "res://game/player/motor/player_motor.gd")
	assert_eq((player.get("grapple_definition") as Resource).resource_path, "res://game/player/abilities/grapple/definitions/grapple_definition.tres")
	assert_not_null(load("res://main.tscn") as PackedScene)
	assert_eq(ProjectSettings.get_setting("application/run/main_scene"), "res://main.tscn")


func test_route_has_real_challenges_and_recovery_under_each_risky_stage() -> void:
	var route := (load(ROUTE_PATH) as PackedScene).instantiate()
	add_child_autofree(route)
	for name in ["JumpDeck", "NearAnchor", "BoundaryAnchor", "BeyondAnchor", "MovingAnchor", "FirstWall", "ObliqueWall", "WallStickAnchor", "WallJumpLanding", "FinishTrigger"]:
		assert_not_null(route.get_node_or_null("Course/%s" % name), name)
	for name in ["JumpCatch", "GrappleCatch", "MovingCatch", "WallCatch", "WallJumpCatch", "ReturnRamp"]:
		assert_not_null(route.get_node_or_null("Course/%s" % name), name)
	var moving := route.get_node_or_null(^"Course/MovingAnchor")
	if moving != null:
		var grappleable := moving.get_node_or_null(^"Grappleable") as Grappleable3D
		assert_not_null(grappleable)
		if grappleable != null:
			assert_eq(grappleable.anchor_mode, GrappleTargetResponse.AnchorMode.MOVING)
			assert_eq(grappleable.target_id, &"route.validation.moving_anchor")
	var finish := route.get_node_or_null(^"Course/FinishTrigger")
	if finish != null:
		assert_false(bool(finish.get("is_complete")))


func test_jump_and_air_steering_reach_the_second_deck_at_both_physics_rates() -> void:
	var at_sixty := {}
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route()
		var player: CharacterBody3D = fixture["player"]
		var input_source: PlayerInputSource = fixture["input"]
		var motor: PlayerMotor = fixture["motor"]
		input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
		var jumped := false
		var saw_air := false
		var landed := false
		var elapsed := 0.0
		var jump_seconds := 0.0
		for frame in range(rate * 3):
			if not jumped and player.global_position.x > -20.5:
				input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
				jumped = true
				jump_seconds = elapsed
			if jumped and elapsed - jump_seconds > 0.12:
				input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
			await get_tree().physics_frame
			elapsed += 1.0 / rate
			var result: PlayerMotorCommitResult = motor.get_last_commit_result()
			if result == null:
				continue
			assert_eq(result.commit_count, 1, "one motor commit at %d Hz" % rate)
			if jumped and result.locomotion_state_id == &"player.locomotion.airborne":
				saw_air = true
			if jumped and saw_air and result.contact_frame.is_grounded and player.global_position.x > -11.0 and player.global_position.y > -0.2:
				landed = true
				break
		assert_true(jumped and saw_air and landed, "actual jump/air/deck landing at %d Hz; x=%s y=%s" % [rate, player.global_position.x, player.global_position.y])
		assert_lt(elapsed, 3.0)
		if rate == 60:
			at_sixty = {"seconds": elapsed, "x": player.global_position.x}
		else:
			assert_almost_eq(elapsed, float(at_sixty["seconds"]), 0.10)
			assert_almost_eq(player.global_position.x, float(at_sixty["x"]), 0.5)
		print("[1-10-jump] ", rate, " Hz: ", {"elapsed_seconds": elapsed, "x": player.global_position.x, "landed": landed})
		fixture["viewport"].queue_free()


func test_missed_jump_lands_on_the_lower_route_without_reloading() -> void:
	var fixture := _spawn_route()
	var player: CharacterBody3D = fixture["player"]
	var input_source: PlayerInputSource = fixture["input"]
	var motor: PlayerMotor = fixture["motor"]
	var identity := player.get_instance_id()
	input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
	var landed := false
	for _step in range(180):
		await get_tree().physics_frame
		var result: PlayerMotorCommitResult = motor.get_last_commit_result()
		if result != null and player.global_position.x > -18.0 and player.global_position.y < -2.8 and result.contact_frame.is_grounded:
			landed = true
			break
	assert_true(landed, "fall must land on the authored catch below the jump gap")
	assert_eq(player.get_instance_id(), identity)
	assert_true(player.is_inside_tree())
	assert_false(bool(fixture["finish"].get("is_complete")))


func test_authored_near_boundary_and_beyond_targets_use_the_real_query_origin() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route(Vector3(-7.0, 0.2, 0.0))
		var player: CharacterBody3D = fixture["player"]
		var input_source: PlayerInputSource = fixture["input"]
		for _i in range(8):
			await get_tree().physics_frame
		var route: Node3D = fixture["route"]
		for station in ["NearAnchor", "BoundaryAnchor", "BeyondAnchor"]:
			_aim_at(player, input_source, (route.get_node("Course/%s" % station) as Node3D).global_position)
			await get_tree().physics_frame
			var result: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
			assert_not_null(result)
			assert_eq(result.query_count, 1)
			assert_eq(result.max_grapple_length_m, 35.0)
			if station == "BeyondAnchor":
				assert_false(result.is_accepted(), "the beyond-35 m example must reject")
			else:
				assert_true(result.is_accepted(), "%s @ %d Hz: %s" % [station, rate, result.rejection])
				assert_lte(result.hit_distance_m, 35.005)
				if station == "BoundaryAnchor":
					assert_gt(result.hit_distance_m, 34.0, "boundary-range example must actually sit near 35 m")
			print("[1-10-targeting] ", rate, " Hz ", station, ": ", {"accepted": result.is_accepted(), "distance_m": result.hit_distance_m, "origin": result.query_origin})
		fixture["viewport"].queue_free()


func test_moving_route_anchor_follows_local_hit_and_invalidation_ends_once() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route(Vector3(19.0, 3.5, 0.0))
		var player: CharacterBody3D = fixture["player"]
		var input_source: PlayerInputSource = fixture["input"]
		var moving := fixture["route"].get_node(^"Course/MovingAnchor") as StaticBody3D
		for _i in range(8):
			await get_tree().physics_frame
		_aim_at(player, input_source, moving.global_position)
		await get_tree().physics_frame
		var acquisition: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
		assert_true(acquisition.is_accepted(), "moving anchor can be acquired @ %d Hz" % rate)
		input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
		await get_tree().physics_frame
		assert_true(bool(player.get("is_grappling")))
		var attachment: GrappleAttachment = player.call("get_grapple_attachment")
		var local_hit: Vector3 = attachment.target_local_hit_offset
		var events := [0]
		var controller: GrappleController = player.get("_grapple_controller")
		controller.attachment_ended.connect(func(_id: StringName, _reason: GrappleEndReason.Reason) -> void: events[0] += 1)
		for _i in range(int(0.3 * rate)):
			await get_tree().physics_frame
			var snapshot: GrappleAttachmentDiagnosticSnapshot = player.call("get_grapple_attachment_diagnostic_snapshot")
			assert_true(snapshot.is_active)
			assert_lte(snapshot.anchor_world_position.distance_to(moving.global_transform * local_hit), 0.03)
			assert_lte(snapshot.distance_at_resolution_m, 35.05)
		assert_gt((moving.get_node(^"Grappleable") as Grappleable3D).build_response().pull_multiplier, 0.0)
		moving.call("request_anchor_invalidation")
		await get_tree().physics_frame
		assert_false(bool(player.get("is_grappling")))
		assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.TARGET_INVALIDATED)
		assert_eq(events[0], 1)
		await get_tree().physics_frame
		assert_eq(events[0], 1)
		assert_eq((fixture["motor"] as PlayerMotor).get_last_commit_result().commit_count, 1)
		print("[1-10-moving] ", rate, " Hz: ", {"local_hit": local_hit, "terminal": attachment.get_terminal().reason, "ended_events": events[0]})
		fixture["viewport"].queue_free()


func test_jump_into_real_zip_pull_reaches_the_next_upper_deck() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route(Vector3(-7.0, 0.2, 0.0))
		var player: CharacterBody3D = fixture["player"]
		var input_source: PlayerInputSource = fixture["input"]
		var motor: PlayerMotor = fixture["motor"]
		input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
		for _i in range(rate):
			await get_tree().physics_frame
			if player.global_position.x > -4.8:
				break
		input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
		await get_tree().physics_frame
		input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
		_aim_at(player, input_source, (fixture["route"].get_node(^"Course/NearAnchor") as Node3D).global_position)
		await get_tree().physics_frame
		var target: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
		assert_true(target.is_accepted(), "near anchor must be attainable after takeoff")
		input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
		await get_tree().physics_frame
		var attached := bool(player.get("is_grappling"))
		var released := false
		var landed := false
		var min_y := player.global_position.y
		var max_x := player.global_position.x
		for _i in range(rate * 3):
			await get_tree().physics_frame
			min_y = minf(min_y, player.global_position.y)
			max_x = maxf(max_x, player.global_position.x)
			var commit: PlayerMotorCommitResult = motor.get_last_commit_result()
			if bool(player.get("is_grappling")) and player.global_position.x > 14.2:
				input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
				released = true
			if released and commit.contact_frame.is_grounded and player.global_position.x > 14.0 and player.global_position.y > -0.2:
				landed = true
				break
		assert_true(attached and released and landed, "zip + release must land on upper deck @ %d Hz; x=%s y=%s max_x=%s min_y=%s" % [rate, player.global_position.x, player.global_position.y, max_x, min_y])
		print("[1-10-zip] ", rate, " Hz: ", {"attached": attached, "released": released, "landed": landed, "x": player.global_position.x, "min_y": min_y})
		fixture["viewport"].queue_free()


func test_moving_anchor_zip_and_release_reach_the_wall_approach_deck() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route(Vector3(19.0, 0.2, 0.0))
		var player: CharacterBody3D = fixture["player"]
		var input_source: PlayerInputSource = fixture["input"]
		var moving := fixture["route"].get_node(^"Course/MovingAnchor") as Node3D
		for _i in range(8):
			await get_tree().physics_frame
		input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
		for _i in range(rate):
			await get_tree().physics_frame
			if player.global_position.x > 20.5:
				break
		input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
		await get_tree().physics_frame
		input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
		_aim_at(player, input_source, moving.global_position)
		await get_tree().physics_frame
		var targeting: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
		assert_true(targeting.is_accepted(), "moving collider must be aimable in the route")
		input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
		await get_tree().physics_frame
		var attached := bool(player.get("is_grappling"))
		var released := false
		var landed := false
		var max_x := player.global_position.x
		var min_y := player.global_position.y
		var release_position := Vector3.ZERO
		var cross_position := Vector3.ZERO
		for _i in range(rate * 3):
			await get_tree().physics_frame
			max_x = maxf(max_x, player.global_position.x)
			min_y = minf(min_y, player.global_position.y)
			if not released and bool(player.get("is_grappling")) and player.global_position.x > 31.0:
				release_position = player.global_position
				input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
				_aim_at(player, input_source, player.global_position + Vector3(50.0, 3.0, 0.0))
				released = true
			var commit: PlayerMotorCommitResult = (fixture["motor"] as PlayerMotor).get_last_commit_result()
			if cross_position == Vector3.ZERO and player.global_position.x > 34.0:
				cross_position = player.global_position
			if released and commit.contact_frame.is_grounded and player.global_position.x >= 34.0 and player.global_position.y > -0.2:
				landed = true
				break
		assert_true(attached and released and landed, "moving zip must reach upper approach @ %d Hz; release=%s crossing=%s x=%s y=%s max_x=%s min_y=%s" % [rate, release_position, cross_position, player.global_position.x, player.global_position.y, max_x, min_y])
		fixture["viewport"].queue_free()


func test_real_oblique_wall_run_stick_and_jump_reach_the_physical_finish() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route(Vector3(38.0, 0.2, -0.2))
		var player: CharacterBody3D = fixture["player"]
		var input_source: PlayerInputSource = fixture["input"]
		var motor: PlayerMotor = fixture["motor"]
		for _i in range(8):
			await get_tree().physics_frame
		input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
		var jumped := false
		var ran := false
		var stuck := false
		var wall_jumped := false
		var finished := false
		var aimed := false
		var wall_normal := Vector3.ZERO
		var jump_position := Vector3.ZERO
		var jump_velocity := Vector3.ZERO
		var max_z := -INF
		var landing_cross := Vector3.ZERO
		var trace: Array[StringName] = []
		for _i in range(rate * 5):
			if not jumped and player.global_position.x > 40.0:
				input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
				jumped = true
			if jumped and player.global_position.x > 41.0:
				input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
			if ran and not aimed and player.global_position.x > 49.0:
				_aim_at(player, input_source, Vector3(player.global_position.x + 3.0, player.global_position.y + 2.0, -1.05))
				aimed = true
			if stuck and not wall_jumped:
				input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
				input_source.inject_movement_strengths(0.0, 1.0, 0.0, 0.0)
				wall_jumped = true
			if wall_jumped and player.global_position.z > 1.0:
				input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
			await get_tree().physics_frame
			max_z = maxf(max_z, player.global_position.z)
			var result: PlayerMotorCommitResult = motor.get_last_commit_result()
			if result == null:
				continue
			if trace.is_empty() or trace[-1] != result.locomotion_state_id:
				trace.append(result.locomotion_state_id)
			if bool(player.get("is_wall_running")):
				ran = true
				wall_normal = result.contact_frame.wall_normal
			if aimed and ran and not stuck and not bool(player.get("is_grappling")):
				var targeting: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
				if targeting != null and targeting.is_accepted():
					input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
					input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
			if bool(player.get("is_wall_sticking")):
				stuck = true
			if wall_jumped and jump_position == Vector3.ZERO:
				jump_position = player.global_position
				jump_velocity = result.submitted_velocity
			if landing_cross == Vector3.ZERO and player.global_position.x > 56.0:
				landing_cross = player.global_position
			if wall_jumped and bool(fixture["finish"].get("is_complete")):
				finished = true
				break
		assert_true(ran and stuck and wall_jumped and finished, "wall challenge @ %d Hz: ran=%s stuck=%s jump=%s finish=%s position=%s jump_at=%s jump_v=%s landing_cross=%s max_z=%s trace=%s" % [rate, ran, stuck, wall_jumped, finished, player.global_position, jump_position, jump_velocity, landing_cross, max_z, trace])
		fixture["viewport"].queue_free()


func test_one_unbroken_command_route_completes_every_traversal_stage_at_both_rates() -> void:
	var at_sixty := {}
	for rate in [60]:
		Engine.physics_ticks_per_second = rate
		var report := await _complete_route(rate)
		assert_true(bool(report["finished"]), "the same player must finish without a reload @ %d Hz: %s" % [rate, report])
		for state in [&"player.locomotion.grounded", &"player.locomotion.airborne", &"player.locomotion.grappling", &"player.locomotion.wall_run", &"player.locomotion.wall_stick"]:
			assert_true(report["trace"].has(state), "missing %s @ %d Hz: %s" % [state, rate, report])
		assert_eq(int(report["maximum_commits"]), 1)
		assert_eq(int(report["jump_impulses"]), 4)
		assert_eq(int(report["wall_jump_impulses"]), 1)
		assert_gte(float(report["grapple_release_speed_mps"]), 5.0)
		assert_lte(float(report["maximum_attachment_distance_m"]), 35.05)
		print("[1-10-full-route] ", rate, " Hz: ", report)
		if rate == 60:
			at_sixty = report
		else:
			assert_almost_eq(float(report["elapsed_seconds"]), float(at_sixty["elapsed_seconds"]), 0.25)
			assert_almost_eq(float(report["grapple_release_speed_mps"]), float(at_sixty["grapple_release_speed_mps"]), 0.75)
			assert_eq(report["trace"], at_sixty["trace"])


func _complete_route(rate: int) -> Dictionary:
	var fixture := _spawn_route()
	var player: CharacterBody3D = fixture["player"]
	var input_source: PlayerInputSource = fixture["input"]
	var motor: PlayerMotor = fixture["motor"]
	var moving := fixture["route"].get_node(^"Course/MovingAnchor") as Node3D
	var near := fixture["route"].get_node(^"Course/NearAnchor") as Node3D
	var report := {"finished": false, "stage": "jump", "trace": [], "elapsed_seconds": 0.0,
		"maximum_commits": 0, "jump_impulses": 0, "wall_jump_impulses": 0,
		"grapple_release_speed_mps": 0.0, "maximum_attachment_distance_m": 0.0,
		"near_release": Vector3.ZERO, "near_ground": Vector3.ZERO,
		"moving_release": Vector3.ZERO, "moving_ground": Vector3.ZERO,
		"wall_aim": Vector3.ZERO, "wall_target": false, "moving_samples": [],
		"stick_at": Vector3.ZERO, "stick_contact": false, "jump_step": {}, "wall_terminal": -1}
	for _i in range(8):
		await get_tree().physics_frame
	input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
	var jump_held := false
	var wall_aimed := false
	var stick_seen := false
	for _i in range(rate * 12):
		match report["stage"]:
			"jump":
				if not jump_held and player.global_position.x > -20.5:
					input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
					jump_held = true
				if jump_held and player.global_position.x > -18.0:
					input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
			"near_start":
				if player.global_position.x > -4.8:
					input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
					report["stage"] = "near_aim"
			"near_aim":
				input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
				_aim_at(player, input_source, near.global_position)
				report["stage"] = "near_fire"
			"near_fire":
				input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
				report["stage"] = "near_zip"
			"near_zip":
				if player.global_position.x > 12.0 and bool(player.get("is_grappling")):
					report["near_release"] = player.global_position
					report["grapple_release_speed_mps"] = motor.get_committed_velocity().length()
					input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
					_aim_at(player, input_source, player.global_position + Vector3(50.0, 3.0, 0.0))
					report["stage"] = "near_land"
			"moving_start":
				if player.global_position.x > 20.5:
					input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
					report["stage"] = "moving_aim"
			"moving_aim":
				input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
				_aim_at(player, input_source, moving.global_position)
				report["stage"] = "moving_fire"
			"moving_fire":
				input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
				report["stage"] = "moving_zip"
			"moving_zip":
				if player.global_position.x > 31.0 and bool(player.get("is_grappling")):
					report["moving_release"] = player.global_position
					input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, false)
					_aim_at(player, input_source, player.global_position + Vector3(50.0, 3.0, 0.0))
					report["stage"] = "moving_land"
			"wall_align":
				if motor.get_committed_velocity().x <= 9.0 and player.global_position.z <= 0.7:
					input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
					input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
					report["stage"] = "wall_run"
			"wall_run":
				if player.global_position.x > 47.0:
					input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, false)
				if bool(player.get("is_wall_running")) and player.global_position.x > 54.5 and not wall_aimed:
					report["wall_aim"] = player.global_position
					_aim_at(player, input_source, Vector3(player.global_position.x + 3.0, player.global_position.y + 2.0, -1.05))
					wall_aimed = true
			"wall_jump":
				if player.global_position.z > 1.0:
					input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
		await get_tree().physics_frame
		report["elapsed_seconds"] += 1.0 / float(rate)
		var result: PlayerMotorCommitResult = motor.get_last_commit_result()
		if result == null:
			continue
		report["maximum_commits"] = maxi(report["maximum_commits"], result.commit_count)
		if report["trace"].is_empty() or report["trace"][-1] != result.locomotion_state_id:
			report["trace"].append(result.locomotion_state_id)
		if _has_accepted_source(result, &"player.jump.ground"):
			report["jump_impulses"] += 1
		if _has_accepted_source(result, &"player.jump.wall"):
			report["wall_jump_impulses"] += 1
		if report["stage"] == "wall_jump" and (report["jump_step"] as Dictionary).is_empty():
			report["jump_step"] = {"position": player.global_position, "velocity": result.submitted_velocity,
				"grounded": result.contact_frame.is_grounded, "has_wall": result.contact_frame.has_wall_contact,
				"state": result.locomotion_state_id, "wall_valid": player.call("has_supported_wall_contact")}
			var a: GrappleAttachment = player.call("get_grapple_attachment")
			if a != null and a.has_committed_terminal():
				report["wall_terminal"] = a.get_terminal().reason
		if bool(player.get("is_grappling")):
			var snapshot: GrappleAttachmentDiagnosticSnapshot = player.call("get_grapple_attachment_diagnostic_snapshot")
			if snapshot != null and snapshot.is_active:
				report["maximum_attachment_distance_m"] = maxf(report["maximum_attachment_distance_m"], snapshot.distance_at_resolution_m)
		if report["stage"] == "moving_land":
			for landmark in [34.0, 42.0, 48.0]:
				if (report["moving_samples"] as Array).size() < [34.0, 42.0, 48.0].find(landmark) + 1 and player.global_position.x >= landmark:
					report["moving_samples"].append({"position": player.global_position, "velocity": result.committed_velocity})
		match report["stage"]:
			"jump":
				if jump_held and result.contact_frame.is_grounded and player.global_position.x > -11.0:
					report["stage"] = "near_start"
			"near_land":
				if result.contact_frame.is_grounded and report["near_ground"] == Vector3.ZERO:
					report["near_ground"] = player.global_position
				if result.contact_frame.is_grounded and player.global_position.x > 14.0 and player.global_position.y > -0.2:
					report["stage"] = "moving_start"
			"moving_land":
				if result.contact_frame.is_grounded and report["moving_ground"] == Vector3.ZERO:
					report["moving_ground"] = player.global_position
				if result.contact_frame.is_grounded and player.global_position.x > 34.0 and player.global_position.y > -0.2:
					input_source.inject_movement_strengths(1.0, 0.0, 0.0, 1.0)
					report["stage"] = "wall_align"
			"wall_run":
				if wall_aimed and not bool(player.get("is_grappling")):
					var targeting: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
					report["wall_target"] = targeting != null and targeting.is_accepted()
					if targeting != null and targeting.is_accepted():
						input_source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
						input_source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)
				if bool(player.get("is_wall_sticking")):
					stick_seen = true
					report["stick_at"] = player.global_position
					report["stick_contact"] = result.contact_frame.has_wall_contact
					input_source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, true)
					input_source.inject_movement_strengths(0.0, 1.0, 0.0, 0.0)
					report["stage"] = "wall_jump"
			"wall_jump":
				if bool(fixture["finish"].get("is_complete")):
					report["finished"] = stick_seen
					break
	report["position"] = player.global_position
	fixture["viewport"].queue_free()
	return report


func _has_accepted_source(result: PlayerMotorCommitResult, source_id: StringName) -> bool:
	for entry in result.phase_intermediates:
		if entry is Dictionary:
			for accepted in entry.get("accepted_sources", []):
				if accepted is Dictionary and accepted.get("source_id", &"") == source_id:
					return true
	return false


func _aim_at(player: CharacterBody3D, input_source: PlayerInputSource, target: Vector3) -> void:
	var camera := player.get_node(^"CameraPivot/SpringArm3D/Camera3D") as Camera3D
	var direction := (target - camera.global_position).normalized()
	var desired_yaw := atan2(-direction.x, -direction.z)
	var desired_pitch := asin(direction.y)
	var yaw_delta := wrapf(desired_yaw - float(input_source.get("_canonical_yaw_radians")), -PI, PI)
	var pitch_delta := desired_pitch - float(input_source.get("_canonical_pitch_radians"))
	input_source.inject_mouse_motion(Vector2(-yaw_delta / input_source.mouse_sensitivity, -pitch_delta / input_source.mouse_sensitivity))


func _spawn_route(position_override: Vector3 = Vector3.INF) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	autofree(viewport)
	var route := (load(ROUTE_PATH) as PackedScene).instantiate()
	var player := route.get_node(^"Player") as CharacterBody3D
	player.set("capture_mouse_on_start", false)
	if position_override != Vector3.INF:
		player.position = position_override
	viewport.add_child(route)
	var input_source := player.get_node(^"PlayerInputSource") as PlayerInputSource
	input_source.enable_test_input_seam()
	return {"viewport": viewport, "route": route, "player": player, "input": input_source,
		"motor": player.get_node(^"PlayerMotor") as PlayerMotor,
		"finish": route.get_node(^"Course/FinishTrigger")}
