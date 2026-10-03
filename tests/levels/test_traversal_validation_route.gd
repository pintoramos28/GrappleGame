extends GutTest


const ROUTE_PATH := "res://game/levels/content/traversal_validation/traversal_validation_route.tscn"
const Driver := preload("res://tests/fixtures/traversal_route_driver.gd")
const BoundaryProbe := preload("res://tests/fixtures/traversal_boundary_probe.gd")
var _saved_rate := 60
var _saved_mouse_mode := Input.MOUSE_MODE_VISIBLE
var _fixtures: Array[SubViewport] = []


func before_each() -> void:
	_saved_rate = Engine.physics_ticks_per_second
	_saved_mouse_mode = Input.mouse_mode


func after_each() -> void:
	for viewport in _fixtures:
		if is_instance_valid(viewport):
			viewport.free()
	_fixtures.clear()
	Engine.physics_ticks_per_second = _saved_rate
	Input.mouse_mode = _saved_mouse_mode


func test_route_loads_with_the_production_player_and_independent_main_scene() -> void:
	var packed := load(ROUTE_PATH) as PackedScene
	assert_not_null(packed)
	if packed == null:
		return
	var route := packed.instantiate()
	route.get_node(^"Player").set("capture_mouse_on_start", false)
	add_child_autofree(route)
	var player := route.get_node(^"Player") as CharacterBody3D
	assert_eq(player.scene_file_path, "res://scenes/player.tscn")
	assert_eq(player.get_node(^"PlayerInputSource").get_script().resource_path, "res://game/player/input/player_input_source.gd")
	assert_eq(player.get_node(^"PlayerMotor").get_script().resource_path, "res://game/player/motor/player_motor.gd")
	assert_eq((player.get("grapple_definition") as Resource).resource_path, "res://game/player/abilities/grapple/definitions/grapple_definition.tres")
	assert_not_null(load("res://main.tscn") as PackedScene)
	assert_eq(ProjectSettings.get_setting("application/run/main_scene"), "res://main.tscn")


func test_route_has_real_challenges_and_recovery_under_each_risky_stage() -> void:
	var route := (load(ROUTE_PATH) as PackedScene).instantiate()
	route.get_node(^"Player").set("capture_mouse_on_start", false)
	add_child_autofree(route)
	for body_name in ["JumpDeck", "NearAnchor", "BoundaryAnchor", "BeyondAnchor", "MovingAnchor", "FirstWall", "ObliqueWall", "WallStickAnchor", "WallJumpLanding", "FinishTrigger", "UnsupportedSlope", "JumpCatch", "GrappleCatch", "MovingCatch", "WallCatch", "WallJumpCatch", "ReturnRamp"]:
		assert_not_null(route.get_node_or_null("Course/%s" % body_name), body_name)
	var moving := route.get_node(^"Course/MovingAnchor/Grappleable") as Grappleable3D
	assert_eq(moving.anchor_mode, GrappleTargetResponse.AnchorMode.MOVING)
	assert_eq(moving.target_id, &"route.validation.moving_anchor")
	assert_false(bool(route.get_node(^"Course/FinishTrigger").get("is_complete")))


func test_authored_near_boundary_and_beyond_targets_use_the_real_query_origin() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route(Vector3(-7.0, 0.2, 0.0))
		var driver = fixture["driver"]
		await _wait_seconds(driver, 0.15)
		for station in ["NearAnchor", "BoundaryAnchor", "BeyondAnchor"]:
			var body := fixture["route"].get_node("Course/%s" % station) as Node3D
			# Converge after rotating the spring-arm origin without capturing any
			# future command. Each attempt uses the next real production query.
			for _attempt in range(3):
				driver.aim_at(body.global_position)
				await _wait_seconds(driver, 2.0 / rate)
			var result: GrappleTargetingResult = fixture["player"].call("get_latest_grapple_targeting_result")
			assert_not_null(result)
			if result == null:
				continue
			assert_eq(result.query_count, 1)
			assert_eq(result.max_grapple_length_m, 35.0)
			assert_eq(result.source_physics_step, int(driver.report["last_step"]))
			assert_eq(result.command_frame_step, result.source_physics_step)
			if station == "BeyondAnchor":
				assert_false(result.is_accepted(), "beyond-range acquisition rejects")
				assert_eq(result.rejection, GrappleRejection.Reason.NO_CANDIDATE, "bounded ray has no nearer blocker")
				assert_gt(Driver.box_ray_entry_distance(body, result.query_origin, result.query_direction), 35.005, "canonical ray aims at BeyondAnchor outside the queried segment")
			else:
				assert_true(result.is_accepted(), "%s at %d Hz" % [station, rate])
				if result.is_accepted():
					assert_eq(result.accepted_seed.get_target(), body)
				assert_lte(result.hit_distance_m, 35.005)
				if station == "BoundaryAnchor":
					assert_gt(result.hit_distance_m, 34.0)
		_dispose(fixture)


func test_jump_into_real_zip_pull_reaches_the_named_upper_deck() -> void:
	for rate in [60, 120]:
		var report := await _run_scenario(rate, "zip", Vector3(-7.0, 0.2, 0.0))
		_assert_success(report, rate)
		assert_eq(_landing_names(report), ["NearLanding"])
		_assert_releases(report, ["near"])


func test_moving_anchor_zip_and_release_reach_the_named_wall_approach_deck() -> void:
	for rate in [60, 120]:
		var report := await _run_scenario(rate, "moving", Vector3(19.0, 0.2, 0.0))
		_assert_success(report, rate)
		assert_eq(_landing_names(report), ["MovingLanding"])
		_assert_releases(report, ["moving"])


func test_real_oblique_wall_run_stick_and_accepted_jump_reach_the_physical_finish() -> void:
	for rate in [60, 120]:
		var report := await _run_scenario(rate, "wall", Vector3(38.0, 0.2, 0.2))
		_assert_success(report, rate)
		_assert_walls(report)
		assert_eq(int(report["wall_jump_impulses"]), 1)
		assert_eq(_landing_names(report), ["WallJumpLanding"])
		_assert_finish(report)


func test_one_unbroken_command_route_completes_every_traversal_stage_at_both_rates() -> void:
	var at_sixty := {}
	for rate in [60, 120]:
		var report := await _run_scenario(rate, "full")
		_assert_success(report, rate)
		for state in [&"player.locomotion.grounded", &"player.locomotion.airborne", &"player.locomotion.grappling", &"player.locomotion.wall_run", &"player.locomotion.wall_stick"]:
			assert_has(report["trace"], state)
		assert_eq(_landing_names(report), ["JumpDeck", "NearLanding", "MovingLanding", "WallJumpLanding"])
		assert_eq(int(report["jump_impulses"]), 4)
		assert_eq(int(report["wall_jump_impulses"]), 1)
		assert_lte(float(report["maximum_attachment_distance_m"]), 35.05)
		_assert_releases(report, ["near", "moving"])
		_assert_walls(report)
		_assert_finish(report)
		if rate == 60:
			at_sixty = report
		else:
			assert_almost_eq(float(report["elapsed_seconds"]), float(at_sixty["elapsed_seconds"]), 0.25, "completion seconds, not frames")
			if report["releases"].size() == 2 and at_sixty["releases"].size() == 2:
				for index in range(2):
					assert_almost_eq((report["releases"][index]["after"] as Vector3).length(), (at_sixty["releases"][index]["after"] as Vector3).length(), 0.75)
			for window in [["near_zip", "near_land"], ["moving_zip", "moving_land"], ["wall_stick", "wall_jump"]]:
				assert_almost_eq(_action_seconds(report, window[0], window[1]), _action_seconds(at_sixty, window[0], window[1]), 0.05, "measured %s → %s window" % window)
			assert_eq(report["trace"], at_sixty["trace"])


func test_changed_air_input_physically_steers_and_lands_on_jump_deck() -> void:
	var at_sixty := {}
	for rate in [60, 120]:
		var report := await _run_scenario(rate, "air")
		_assert_success(report, rate)
		assert_eq(_landing_names(report), ["JumpDeck"])
		assert_eq(int(report["jump_impulses"]), 1)
		assert_lt(float(report["elapsed_seconds"]), 3.0)
		assert_true(bool(report.get("steered_airborne", false)))
		assert_true(bool(report.get("air_start_airborne", false)), "input change begins after committed takeoff")
		assert_gt(int(report.get("air_end_step", -1)), int(report.get("air_start_step", -1)))
		if report.has("air_after"):
			var delta_z: float = (report["air_after"] as Vector3).z - (report["air_before"] as Vector3).z
			assert_gt(delta_z, 0.25, "lateral input changes committed flight velocity")
			if rate == 60:
				at_sixty = report
			else:
				assert_almost_eq(float(report["elapsed_seconds"]), float(at_sixty["elapsed_seconds"]), 0.10)
				assert_almost_eq((report["position"] as Vector3).x, (at_sixty["position"] as Vector3).x, 0.5)
				assert_almost_eq((report["position"] as Vector3).z, (at_sixty["position"] as Vector3).z, 0.15)


func test_ordinary_misses_return_to_upper_route_and_resume_without_reloading() -> void:
	var starts := {"missed_jump": Vector3.INF, "missed_grapple": Vector3(-7.0, 0.2, 0.0),
		"early_release": Vector3(-7.0, 0.2, 0.0), "invalidated": Vector3(19.0, 0.2, 0.0),
		"lost_run": Vector3(38.0, 0.2, 0.2), "short_wall_jump": Vector3(38.0, 0.2, 0.2)}
	for rate in [60, 120]:
		for mistake in starts:
			var report := await _run_scenario(rate, mistake, starts[mistake])
			_assert_success(report, rate)
			assert_eq(report.get("failure_observed", ""), mistake)
			assert_false(report.get("catch_bodies", []).is_empty(), "actual authored catch contact")
			assert_true(bool(report.get("ramp_contact", false)), "actual authored return-ramp support")
			assert_eq(_landing_names(report), ["StartDeck"])
			assert_true(bool(report.get("recovered", false)))
			assert_true(bool(report.get("resumed", false)))
			var support: Dictionary = report.get("resume_support", {})
			assert_eq(support.get("deck", ""), "StartDeck", "resume request still on the upper route")
			assert_eq(int(report.get("resume_step", -1)), int(support.get("step", -2)) + 1)
			if mistake == "missed_grapple":
				assert_true(bool(report.get("miss_rejected", false)))
				assert_eq(report.get("miss_rejection", -1), GrappleRejection.Reason.NO_CANDIDATE)
				assert_gt(float(report.get("miss_ray_distance", -1.0)), 35.005)
				assert_eq(report.get("miss_observed_step", -1), report.get("miss_request_step", -2))
			if mistake == "invalidated":
				assert_eq(report.get("invalidated_reason", -1), GrappleEndReason.Reason.TARGET_INVALIDATED)
			if mistake == "short_wall_jump":
				assert_eq(int(report["wall_jump_impulses"]), 1)


func test_moving_route_anchor_really_moves_follows_local_hit_and_ends_once() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route(Vector3(19.0, 3.5, 0.0))
		var driver = fixture["driver"]
		await _wait_seconds(driver, 0.15)
		driver.aim_at((fixture["route"].get_node(^"Course/MovingAnchor") as Node3D).global_position)
		await _wait_seconds(driver, 2.0 / rate)
		var acquisition: GrappleTargetingResult = fixture["player"].call("get_latest_grapple_targeting_result")
		assert_not_null(acquisition)
		if acquisition != null:
			assert_true(acquisition.is_accepted())
			if acquisition.is_accepted():
				assert_eq(acquisition.accepted_seed.get_target(), fixture["route"].get_node(^"Course/MovingAnchor"))
		driver.grapple(true)
		await _wait_seconds(driver, 2.0 / rate)
		var attachment: GrappleAttachment = fixture["player"].call("get_grapple_attachment")
		assert_not_null(attachment)
		if attachment == null:
			_dispose(fixture)
			continue
		var events := [0]
		var controller: GrappleController = fixture["player"].get("_grapple_controller")
		controller.attachment_ended.connect(func(_id: StringName, _reason: GrappleEndReason.Reason) -> void: events[0] += 1)
		await _wait_seconds(driver, 0.30)
		assert_gt(float(driver.report.get("moving_displacement", 0.0)), 0.20)
		assert_lt(float(driver.report.get("moving_velocity_error", INF)), 0.01)
		assert_lt(float(driver.report.get("moving_local_error", INF)), 0.03)
		assert_lt(float(driver.report.get("moving_local_hit_error", INF)), 0.0001, "fixed initial local hit, not a self-comparison")
		assert_true(bool(fixture["player"].get("is_grappling")), "attachment stayed active throughout observation")
		assert_lte(float(driver.report["maximum_attachment_distance_m"]), 35.05)
		assert_eq(driver.report["errors"], [])
		assert_gt((fixture["route"].get_node(^"Course/MovingAnchor/Grappleable") as Grappleable3D).build_response().pull_multiplier, 0.0)
		fixture["route"].get_node(^"Course/MovingAnchor").call("request_anchor_invalidation")
		await _wait_seconds(driver, 3.0 / rate)
		assert_false(bool(fixture["player"].get("is_grappling")))
		assert_true(attachment.has_committed_terminal())
		if attachment.has_committed_terminal():
			assert_eq(attachment.get_terminal().reason, GrappleEndReason.Reason.TARGET_INVALIDATED)
		assert_eq(events[0], 1)
		await _wait_seconds(driver, 2.0 / rate)
		assert_eq(events[0], 1)
		assert_eq(driver.report["errors"], [])
		assert_eq(int(driver.report["maximum_commits"]), 1)
		_dispose(fixture)


func test_short_attachment_reaches_35m_with_outward_only_constraint_and_moving_carry() -> void:
	var at_sixty := {}
	for mode in ["boundary", "moving_boundary"]:
		for rate in [60, 120]:
			Engine.physics_ticks_per_second = rate
			var start := Vector3(5.0, 8.0, 2.0) if mode == "moving_boundary" else Vector3(-5.0, 8.0, 7.0)
			var fixture := _spawn_route(start, mode, true)
			var driver = fixture["driver"]
			await _wait_driver(driver)
			var report: Dictionary = driver.report
			_assert_success(report, rate)
			var probe: Dictionary = report["probe"]
			assert_eq(int(probe["creation_samples"]), 1, "one explicit acquisition-only commit")
			assert_gt(int(probe["constraint_samples"]), 0, "current record and unique matching phase/source required")
			assert_lt(float(probe["initial_distance"]), 32.0)
			assert_true(bool(probe["short_attachment_grew"]))
			assert_true(bool(probe["outward_clipped"]))
			assert_gt(int(probe["slack_samples"]), 0)
			assert_gt(int(probe["taut_samples"]), 0)
			assert_true(bool(probe["slack_unchanged"]))
			assert_lte(float(probe["maximum_distance"]), 35.05, "same-step committed player to resolved local hit")
			assert_lte(float(probe["maximum_resolution_distance"]), 35.05)
			assert_lt(float(probe["maximum_distance_error"]), 0.001, "published distances match measured geometry")
			assert_lt(float(probe["maximum_local_error"]), 0.03)
			assert_lt(float(probe["maximum_local_hit_error"]), 0.0001, "attachment local hit remains fixed")
			assert_lt(float(probe["maximum_velocity_error"]), 0.01, "anchor velocity matches observed finite difference")
			assert_lt(float(probe["maximum_constraint_error"]), 0.001, "radial-only geometric/motion oracle each step")
			assert_lt(float(probe["maximum_carry_error"]), 0.001, "reported carry matches independently expected carry")
			assert_lt(float(probe["maximum_carry_vector_error"]), 0.001, "reported carry actually changes phase vector")
			assert_lt(float(probe["maximum_refused_carry"]), 0.0001)
			assert_lt(float(probe["maximum_tangent_error"]), 0.001)
			assert_gt(int(probe["tangent_samples"]), 0)
			assert_gt(int(probe["inward_samples"]), 0)
			if mode == "moving_boundary":
				assert_gt(int(probe["carry_samples"]), 0)
				assert_gt(float(probe["maximum_motion"]), 0.5)
				assert_lt(float(probe["maximum_velocity_error"]), 0.01)
				assert_false(probe["carry_step"].is_empty(), "actual measured carry step retained")
			else:
				assert_gt(int(probe["taut_tangent_samples"]), 0, "tangential freedom near 35 m, not only slack")
				assert_gt(int(probe["taut_tangent_corrected_samples"]), 0, "taut outward clipping preserves nonzero tangent")
				assert_gt(int(probe["taut_inward_samples"]), 0, "inward freedom near 35 m, not only slack")
				assert_false(probe["taut_tangent_step"].is_empty())
				assert_false(probe["taut_inward_step"].is_empty())
				assert_lt(float(probe["maximum_static_inward_kick"]), 0.001, "static boundary cannot add unjustified inward motion")
				assert_lt(float(probe["maximum_carry"]), 0.0001, "stationary anchor never carries")
			if rate == 60:
				at_sixty = probe.duplicate()
			else:
				assert_almost_eq(float(probe["maximum_distance"]), float(at_sixty["maximum_distance"]), 0.05)
				assert_almost_eq(float(probe["maximum_carry"]), float(at_sixty["maximum_carry"]), 0.15)
			print("[1-10-isolated-%s] %d Hz: %s" % [mode, rate, probe])
			_dispose(fixture)
	# The probe uses a private duplicate; the approved shipped definition is intact.
	assert_eq((load("res://game/player/abilities/grapple/definitions/grapple_definition.tres") as GrappleDefinition).pull_initial_acceleration_mps2, 60.0)


func test_physically_contacted_unsupported_slope_rejects_wall_traversal() -> void:
	for rate in [60, 120]:
		var report := await _run_scenario(rate, "unsupported", Vector3(48.0, 3.0, 13.7))
		_assert_success(report, rate)
		assert_true(bool(report.get("unsupported_contact", false)))
		assert_true(bool(report.get("unsupported_forward", false)), "forward-held precondition exercised")
		assert_false(bool(report.get("unsupported_active", false)))
		var rejection: Dictionary = report.get("unsupported_rejection", {})
		assert_false(rejection.is_empty(), "contacted face has an authoritative committed rejection")
		if not rejection.is_empty():
			assert_eq(rejection["source"], ContactCandidate.Source.COMMITTED_COLLISION)
			assert_true(rejection["reason"] in [ContactRejection.Reason.FLOOR_LIKE, ContactRejection.Reason.CEILING_LIKE])


func _assert_success(report: Dictionary, rate: int) -> void:
	assert_true(bool(report["finished"]), "%d Hz: %s" % [rate, report])
	assert_true(bool(report["same_instance"]))
	assert_eq(report["errors"], [])
	assert_eq(int(report["maximum_commits"]), 1)


func _assert_releases(report: Dictionary, expected_labels: Array) -> void:
	var labels := []
	for release in report["releases"]:
		labels.append(release["label"])
	assert_eq(labels, expected_labels, "exact expected release coverage")
	for release in report["releases"]:
		assert_eq(int(release["step"]), int(release["request_step"]) + 1, "first inactive committed step")
		var before: Vector3 = release["before"]
		var after: Vector3 = release["after"]
		assert_gte(after.length(), 5.0)
		# One release step may integrate air drag/gravity; tolerate at most the
		# authored 5 m/s² drag + 9.8 m/s² gravity over that exact physics delta.
		assert_lte(before.distance_to(after), 15.0 * float(release["delta"]) + 0.02, "release preserves vector: %s" % release)
		assert_gt(before.normalized().dot(after.normalized()), 0.99)


func _assert_walls(report: Dictionary) -> void:
	assert_eq(report["wall_faces"], ["FirstWall", "ObliqueWall"])
	assert_has(report["trace"], &"player.locomotion.wall_stick")
	if report["wall_normals"].has("ObliqueWall"):
		var normal: Vector3 = report["wall_normals"]["ObliqueWall"]
		assert_gt(normal.dot(report["expected_wall_normals"]["ObliqueWall"]), 0.99)
	assert_false(report["corner_actions"].is_empty())
	assert_eq(int(report["corner_interruptions"]), 0, "no loss/deactivation between authored faces")
	var corner: Dictionary = report["corner_transition"]
	assert_false(corner.is_empty(), "current and immediately previous supported corner frames")
	if not corner.is_empty():
		assert_eq(int(corner["step"]), int(corner["previous_step"]) + 1)
	for action in report["corner_actions"]:
		assert_true(action in [ContactFrame.ContinuityAction.PRESERVED, ContactFrame.ContinuityAction.SWITCHED], "continuous authored corner")
	var launch: Dictionary = report["jump_step"]
	assert_false(launch.is_empty(), "observe accepted wall-jump, not button request")
	if not launch.is_empty():
		assert_eq(launch["step"], launch["contact_step"])
		var expected_valid: bool = bool(launch["wall_query_success"]) and bool(launch["has_wall"]) and not bool(launch["wall_lost"]) and int(launch["wall_support_step"]) == int(launch["step"])
		assert_eq(bool(launch["wall_valid"]), expected_valid, "post-commit diagnostic uses frame N, never pre-commit N-1 API")
		assert_gt((launch["velocity"] as Vector3).y, 5.0)
		assert_gt((launch["velocity"] as Vector3).z, 7.0)
		assert_gt((launch["committed_velocity"] as Vector3).y, 5.0)
		assert_gt((launch["committed_velocity"] as Vector3).z, 7.0)


func _assert_finish(report: Dictionary) -> void:
	var event: Dictionary = report["finish_event"]
	assert_false(event.is_empty(), "actual route_completed event, not a pre-latched flag")
	if not event.is_empty():
		assert_eq(event["stage"], "finish_walk")
		assert_true(bool(event["overlaps_player"]))
		assert_gt(int(event["player_id"]), 0)


func _landing_names(report: Dictionary) -> Array:
	var names := []
	for landing in report["landings"]:
		names.append(landing["deck"])
	return names


func _action_seconds(report: Dictionary, start: String, end: String) -> float:
	var start_seconds := -1.0
	var end_seconds := -1.0
	for event in report["events"]:
		if event["stage"] == start:
			start_seconds = float(event["seconds"])
		if event["stage"] == end:
			end_seconds = float(event["seconds"])
	assert_gte(start_seconds, 0.0, "required action window start")
	assert_gte(end_seconds, start_seconds, "required ordered action window end")
	return end_seconds - start_seconds


func _run_scenario(rate: int, mode: String, start: Vector3 = Vector3.INF) -> Dictionary:
	Engine.physics_ticks_per_second = rate
	var fixture := _spawn_route(start, mode)
	var driver = fixture["driver"]
	await _wait_driver(driver)
	var report: Dictionary = driver.report.duplicate(true)
	print("[1-10-%s] %d Hz: %s" % [mode, rate, report])
	_dispose(fixture)
	return report


func _wait_seconds(driver: Node, seconds: float) -> void:
	var until: float = float(driver.report["elapsed_seconds"]) + seconds
	for _wake in range(Engine.physics_ticks_per_second * ceili(seconds + 1.0)):
		if float(driver.report["elapsed_seconds"]) >= until:
			return
		if driver.done:
			assert_true(false, "observer ended before requested interval: %s" % driver.report["errors"])
			return
		await get_tree().physics_frame
	assert_true(false, "observer failed to advance requested simulation seconds")
	driver.finish(false)


func _wait_driver(driver: Node) -> void:
	for _wake in range(Engine.physics_ticks_per_second * 30):
		if driver.done:
			return
		await get_tree().physics_frame
	assert_true(false, "test-side watchdog: observer never finished")
	driver.finish(false)


func test_observer_watchdog_does_not_depend_on_new_motor_commits() -> void:
	for rate in [60, 120]:
		Engine.physics_ticks_per_second = rate
		var fixture := _spawn_route()
		fixture["player"].set_physics_process(false)
		var driver = fixture["driver"]
		driver.watchdog_limit_seconds = 0.10
		await _wait_driver(driver)
		assert_true(driver.done)
		assert_false(bool(driver.report["finished"]))
		assert_eq(driver.report["errors"], ["fixture watchdog expired at settle"])
		_dispose(fixture)


func _spawn_route(start: Vector3 = Vector3.INF, mode: String = "observe", isolate_boundary: bool = false) -> Dictionary:
	var viewport := SubViewport.new()
	viewport.size = Vector2i(256, 256)
	viewport.world_3d = World3D.new()
	get_tree().root.add_child(viewport)
	_fixtures.append(viewport)
	var route := (load(ROUTE_PATH) as PackedScene).instantiate() as Node3D
	var player := route.get_node(^"Player") as CharacterBody3D
	player.set("capture_mouse_on_start", false)
	if start != Vector3.INF:
		player.position = start # Isolated initial placement only; full route uses authored spawn.
	if isolate_boundary:
		var private_definition := (player.get("grapple_definition") as GrappleDefinition).duplicate(true) as GrappleDefinition
		private_definition.pull_initial_acceleration_mps2 = 0.0
		private_definition.pull_min_acceleration_mps2 = 0.0
		player.set("grapple_definition", private_definition)
		player.set("gravity", 0.0) # Keep this isolated no-pull probe above terrain.
	viewport.add_child(route)
	var driver = BoundaryProbe.new() if isolate_boundary else Driver.new()
	driver.configure(route, mode)
	route.add_child(driver)
	return {"viewport": viewport, "route": route, "player": player, "driver": driver}


func _dispose(fixture: Dictionary) -> void:
	var viewport: SubViewport = fixture["viewport"]
	_fixtures.erase(viewport)
	viewport.free() # Drain the fixture before switching the global tick rate.
