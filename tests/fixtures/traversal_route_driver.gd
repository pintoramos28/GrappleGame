extends Node
## Test-only command driver/observer. Runs AFTER the production player once per
## physics step, unlike idle coroutines which can skip commits at 120 Hz.
## Never writes body motion, calls physics manually, or performs physics queries.

var route: Node3D
var player: CharacterBody3D
var source: PlayerInputSource
var motor: PlayerMotor
var mode := "full"
var stage := "settle"
var done := false
var watchdog_limit_seconds := 24.0
var report: Dictionary = {
	"finished": false, "trace": [], "errors": [], "events": [],
	"elapsed_seconds": 0.0, "jump_impulses": 0, "wall_jump_impulses": 0,
	"maximum_commits": 0, "maximum_attachment_distance_m": 0.0,
	"landings": [], "releases": [], "wall_faces": [], "corner_actions": [],
	"wall_normals": {}, "expected_wall_normals": {}, "jump_step": {}, "same_instance": true,
	"corner_interruptions": 0, "corner_transition": {}, "finish_event": {},
}
var _last_step := -1
var _stage_seconds := 0.0
var _identity := 0
var _route_identity := 0
var _ground_jump_requested := false
var _release_before := Vector3.INF
var _release_label := ""
var _release_request_step := -1
var _last_commit: PlayerMotorCommitResult
var _recovering := false
var _watchdog_seconds := 0.0
var _corner_pending := false
var _previous_wall_frame: ContactFrame
var _moving_origin := Vector3.INF
var _previous_moving := Vector3.INF
var _moving_local_hit := Vector3.INF
var _invalidated_attachment: GrappleAttachment


func configure(host: Node3D, scenario: String = "full") -> void:
	route = host
	player = route.get_node(^"Player") as CharacterBody3D
	source = player.get_node(^"PlayerInputSource") as PlayerInputSource
	motor = player.get_node(^"PlayerMotor") as PlayerMotor
	mode = scenario
	_identity = player.get_instance_id()
	_route_identity = route.get_instance_id()
	process_physics_priority = 10
	source.enable_test_input_seam()
	for body_name in ["FirstWall", "ObliqueWall"]:
		report["expected_wall_normals"][body_name] = (route.get_node("Course/%s" % body_name) as Node3D).global_basis.z.normalized()
	var trigger := route.get_node(^"Course/FinishTrigger") as Area3D
	trigger.connect("route_completed", _on_route_completed)
	if bool(trigger.get("is_complete")):
		report["errors"].append("finish already latched before driver entry")


func _physics_process(delta: float) -> void:
	if done:
		return
	# Independent of motor diagnostics: a missing/repeated commit cannot hang
	# a test coroutine forever. Measured outcome seconds still use commit deltas.
	_watchdog_seconds += delta
	if _watchdog_seconds > watchdog_limit_seconds:
		report["errors"].append("fixture watchdog expired at %s" % stage)
		finish(false)
		return
	var commit := motor.get_last_commit_result()
	if commit == null or commit.physics_step == _last_step:
		return
	if _last_step >= 0 and commit.physics_step != _last_step + 1:
		report["errors"].append("skipped commit %d -> %d" % [_last_step, commit.physics_step])
	_last_step = commit.physics_step
	_last_commit = commit
	if not is_finite(commit.physics_delta_seconds) or commit.physics_delta_seconds <= 0.0 or absf(commit.physics_delta_seconds - delta) > 0.000001:
		report["errors"].append("invalid/mismatched commit delta at %d" % commit.physics_step)
		finish(false)
		return
	_observe(commit)
	if not commit.success or commit.commit_count != 1 or commit.contact_frame == null:
		finish(false)
		return
	_stage_seconds += commit.physics_delta_seconds
	if float(report["elapsed_seconds"]) > 24.0:
		finish(false)
		return
	_drive(commit)


func _observe(commit: PlayerMotorCommitResult) -> void:
	report["elapsed_seconds"] += commit.physics_delta_seconds
	report["last_step"] = commit.physics_step
	report["maximum_commits"] = maxi(int(report["maximum_commits"]), commit.commit_count)
	if not commit.success or commit.commit_count != 1:
		report["errors"].append("invalid commit at %d" % commit.physics_step)
	var frame := commit.contact_frame
	if frame == null or frame.physics_step != commit.physics_step:
		report["errors"].append("missing/current contact at %d" % commit.physics_step)
		return
	if report["trace"].is_empty() or report["trace"][-1] != commit.locomotion_state_id:
		report["trace"].append(commit.locomotion_state_id)
	var ground_count := _count_jump_sources(commit, &"player.jump.ground")
	var wall_count := _count_jump_sources(commit, &"player.jump.wall")
	report["jump_impulses"] += ground_count
	report["wall_jump_impulses"] += wall_count
	if wall_count > 0:
		report["jump_step"] = {
			"position": commit.position_after, "velocity": commit.submitted_velocity,
			"committed_velocity": commit.committed_velocity,
			"step": commit.physics_step, "contact_step": frame.physics_step,
			"has_wall": frame.has_wall_contact,
			"wall_query_success": frame.wall_probe_query_succeeded,
			"wall_lost": frame.wall_contact_lost,
			"wall_support_step": frame.wall_support.physics_step if frame.wall_support != null else -1,
			"wall_valid": frame.wall_probe_query_succeeded and frame.has_wall_contact
				and not frame.wall_contact_lost and frame.wall_support != null,
		}
	if _release_before != Vector3.INF and not bool(player.get("is_grappling")):
		report["releases"].append({"label": _release_label, "before": _release_before,
			"after": commit.committed_velocity, "delta": commit.physics_delta_seconds,
			"step": commit.physics_step, "request_step": _release_request_step})
		_release_before = Vector3.INF
	if bool(player.get("is_grappling")):
		var snapshot: GrappleAttachmentDiagnosticSnapshot = player.call("get_grapple_attachment_diagnostic_snapshot")
		if snapshot == null or not snapshot.is_active:
			report["errors"].append("active grapple missing attachment diagnostic at %d" % commit.physics_step)
			return
		if snapshot != null and snapshot.is_active:
			var active_attachment: GrappleAttachment = player.call("get_grapple_attachment")
			if active_attachment == null or active_attachment.get_target() == null:
				report["errors"].append("active diagnostic without target")
				return
			var active_target := active_attachment.get_target() as Node3D
			var committed_distance := commit.position_after.distance_to(active_target.global_transform * active_attachment.target_local_hit_offset)
			report["maximum_attachment_distance_m"] = maxf(float(report["maximum_attachment_distance_m"]), committed_distance)
			if snapshot.last_physics_step != commit.physics_step:
				report["errors"].append("stale attachment snapshot at %d" % commit.physics_step)
			if snapshot.target_identity == &"route.validation.moving_anchor":
				var moving := route.get_node(^"Course/MovingAnchor") as Node3D
				if _moving_origin == Vector3.INF:
					_moving_origin = moving.global_position
					report["moving_displacement"] = 0.0
					report["moving_velocity_error"] = 0.0
					report["moving_local_error"] = 0.0
					_moving_local_hit = active_attachment.target_local_hit_offset
					report["moving_local_hit_error"] = 0.0
				else:
					report["moving_displacement"] = maxf(float(report["moving_displacement"]), _moving_origin.distance_to(moving.global_position))
					var measured := (moving.global_position - _previous_moving) / commit.physics_delta_seconds
					report["moving_velocity_error"] = maxf(float(report["moving_velocity_error"]), measured.distance_to(snapshot.target_velocity_mps))
				report["moving_local_error"] = maxf(float(report["moving_local_error"]), snapshot.anchor_world_position.distance_to(moving.global_transform * _moving_local_hit))
				report["moving_local_hit_error"] = maxf(float(report["moving_local_hit_error"]), _moving_local_hit.distance_to(active_attachment.target_local_hit_offset))
				_previous_moving = moving.global_position
	if mode == "missed_grapple" and commit.physics_step == int(report.get("miss_request_step", -1)):
		var targeting: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
		if targeting == null or targeting.source_physics_step != commit.physics_step or targeting.command_frame_step != commit.physics_step or targeting.is_accepted() or bool(player.get("is_grappling")):
			report["errors"].append("missed grapple was not rejected on the actual request commit")
		else:
			report["miss_rejected"] = true
			report["miss_rejection"] = targeting.rejection
			report["miss_observed_step"] = commit.physics_step
			report["miss_ray_distance"] = box_ray_entry_distance(route.get_node(^"Course/BeyondAnchor") as StaticBody3D, targeting.query_origin, targeting.query_direction)
			report["failure_observed"] = "missed_grapple"
	if _invalidated_attachment != null and _invalidated_attachment.has_committed_terminal():
		report["invalidated_reason"] = _invalidated_attachment.get_terminal().reason
	if mode == "unsupported":
		# Observe the entire approach, including proximity-only activation before
		# the first slide collision with the unsupported face.
		if bool(player.get("is_wall_running")) or bool(player.get("is_wall_sticking")):
			report["unsupported_active"] = true
		for index in range(player.get_slide_collision_count()):
			var collision := player.get_slide_collision(index)
			if collision.get_collider() == route.get_node(^"Course/UnsupportedSlope"):
				# The box has legitimate vertical side/bevel normals too. Require
				# the authored 30-degree front face (within ~14 degrees of its
				# normal), not merely this body's name. That cone remains above
				# the unchanged wall profile's 0.2 normal-Y limit under Jolt rounding.
				var face_normal := -(route.get_node(^"Course/UnsupportedSlope") as Node3D).global_basis.z.normalized()
				var face_dot := collision.get_normal().dot(face_normal)
				if face_dot < 0.97:
					continue
				report["unsupported_contact"] = true
				report["unsupported_face_dot"] = face_dot
				report["unsupported_forward"] = (player.call("get_player_command_frame") as PlayerCommandFrame).move_forward_held
				var rejected := false
				for rejection in frame.rejections:
					if rejection.physics_step == commit.physics_step and rejection.source == ContactCandidate.Source.COMMITTED_COLLISION and rejection.normal.distance_to(collision.get_normal()) < 0.001 and rejection.reason in [ContactRejection.Reason.FLOOR_LIKE, ContactRejection.Reason.CEILING_LIKE]:
						rejected = true
						report["unsupported_rejection"] = {"step": commit.physics_step, "source": rejection.source, "reason": rejection.reason, "normal": rejection.normal}
				if not rejected:
					report["errors"].append("unsupported collided face lacks current committed rejection")
				for candidate in frame.candidates:
					if matches_body(candidate, "UnsupportedSlope") and candidate.normal.distance_to(collision.get_normal()) < 0.001 and candidate.classification == ContactCandidate.Classification.WALL:
						report["errors"].append("unsupported collided face classified as wall")
				if frame.wall_support != null and matches_body(frame.wall_support, "UnsupportedSlope") and frame.wall_support.normal.distance_to(collision.get_normal()) < 0.001:
					report["errors"].append("unsupported collided face selected as wall support")
	var supported_wall := frame.wall_probe_query_succeeded and frame.has_wall_contact and not frame.wall_contact_lost and frame.wall_support != null and frame.wall_support.physics_step == commit.physics_step
	if _corner_pending and (not bool(player.get("is_wall_running")) or not supported_wall):
		report["corner_interruptions"] += 1
	if bool(player.get("is_wall_running")) and frame != null and frame.wall_support != null:
		for wall in ["FirstWall", "ObliqueWall"]:
			if matches_body(frame.wall_support, wall):
				if not supported_wall or frame.wall_support.normal.dot(report["expected_wall_normals"][wall]) < 0.99:
					report["errors"].append("invalid/reversed current authored wall sample")
				if not report["wall_faces"].has(wall):
					report["wall_faces"].append(wall)
					if wall == "FirstWall" and mode in ["full", "wall"]:
						_corner_pending = true
					elif _corner_pending:
						if _previous_wall_frame == null or _previous_wall_frame.wall_support == null:
							report["errors"].append("corner lacks previous supported frame")
						else:
							report["corner_transition"] = {"step": commit.physics_step,
								"previous_step": _previous_wall_frame.physics_step,
								"previous_normal": _previous_wall_frame.wall_support.normal,
								"normal": frame.wall_support.normal, "action": frame.continuity_action}
						_corner_pending = false
				report["wall_normals"][wall] = frame.wall_support.normal
				if wall == "ObliqueWall":
					report["corner_actions"].append(frame.continuity_action)
	_previous_wall_frame = frame


func _drive(commit: PlayerMotorCommitResult) -> void:
	if mode == "observe":
		return
	if _recovering:
		_drive_recovery(commit)
		return
	match stage:
		"settle":
			if mode == "unsupported":
				aim_at(player.global_position + Vector3(0.0, 0.0, 50.0))
				_set_stage("unsupported_approach")
				return
			if _stage_seconds >= 0.30:
				_set_stage({"zip": "near_start", "moving": "moving_start", "wall": "wall_start",
					"missed_grapple": "near_start", "early_release": "near_start",
					"invalidated": "moving_start", "lost_run": "wall_start", "short_wall_jump": "wall_start"}.get(mode, "jump"))
				move_world(Vector3.RIGHT)
		"jump":
			if mode == "missed_jump":
				if _caught(commit):
					report["failure_observed"] = "missed_jump"
					_begin_recovery(commit)
				return
			if mode == "air" and has_source(commit, &"player.jump.ground"):
				jump(false)
				_set_stage("air_wait")
				return
			if not _ground_jump_requested and player.global_position.x > -20.5:
				jump(true)
				_ground_jump_requested = true
			if _ground_jump_requested and player.global_position.x > -18.0:
				jump(false)
			if _ground_jump_requested and on_deck(commit, "JumpDeck"):
				_land("JumpDeck", commit)
				if mode == "air":
					finish(true)
					return
				_set_stage("near_start")
		"near_start", "moving_start":
			var near_stage := stage == "near_start"
			move_world(Vector3.RIGHT)
			if player.global_position.x > (-4.8 if near_stage else 20.5):
				jump(true)
				_set_stage("near_aim" if near_stage else "moving_aim")
		"near_aim", "moving_aim":
			jump(false)
			aim_at((route.get_node("Course/%s" % ("BeyondAnchor" if mode == "missed_grapple" else ("NearAnchor" if stage == "near_aim" else "MovingAnchor"))) as Node3D).global_position)
			_set_stage("near_fire" if stage == "near_aim" else "moving_fire")
		"near_fire", "moving_fire":
			var near_stage := stage == "near_fire"
			var target: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
			var body := route.get_node("Course/%s" % ("NearAnchor" if near_stage else "MovingAnchor"))
			if mode != "missed_grapple" and (target == null or not target.is_accepted() or target.accepted_seed.get_target() != body):
				report["errors"].append("incorrect target in %s" % stage)
			grapple(true)
			if mode == "missed_grapple":
				report["miss_request_step"] = commit.physics_step + 1
				_set_stage("miss_fall")
				return
			_set_stage("near_zip" if near_stage else "moving_zip")
		"near_zip", "moving_zip":
			var near_stage := stage == "near_zip"
			if bool(player.get("is_grappling")) and mode in ["early_release", "invalidated"]:
				report["failure_observed"] = mode
				if mode == "invalidated":
					_invalidated_attachment = player.call("get_grapple_attachment")
					(route.get_node(^"Course/MovingAnchor") as Node).call("request_anchor_invalidation")
				else:
					release_grapple("early")
				move_world(Vector3.RIGHT)
				_set_stage("miss_fall")
				return
			if bool(player.get("is_grappling")) and (motor.get_committed_velocity().length() >= 20.0 if near_stage else player.global_position.x > 31.0):
				release_grapple("near" if near_stage else "moving")
				move_world(Vector3.ZERO)
				_set_stage("near_land" if near_stage else "moving_land")
		"near_land", "moving_land":
			var near_stage := stage == "near_land"
			var deck := "NearLanding" if near_stage else "MovingLanding"
			if on_deck(commit, deck):
				_land(deck, commit)
				if mode == ("zip" if near_stage else "moving"):
					finish(true)
				else:
					_set_stage("near_brake" if near_stage else "moving_brake")
		"near_brake":
			move_world(Vector3.ZERO)
			if motor.get_committed_velocity().length() < 0.5:
				_set_stage("moving_start")
		"moving_brake":
			move_world(Vector3.ZERO)
			if motor.get_committed_velocity().length() < 0.5:
				_set_stage("wall_position")
		"wall_position":
			# Brake then walk to the same wall launch point as the isolated case.
			var goal := Vector3(39.0, player.global_position.y, 0.2)
			move_world((goal - player.global_position).normalized() if player.global_position.distance_to(goal) > 0.25 else Vector3.ZERO)
			if on_deck(commit, "MovingLanding") and absf(player.global_position.x - 39.0) < 0.3 and absf(player.global_position.z - 0.2) < 0.15:
				_set_stage("wall_start")
		"wall_start":
			move_world(Vector3.RIGHT)
			if player.global_position.x > 40.0:
				jump(true)
				_set_stage("wall_run")
		"wall_run":
			if mode == "lost_run" and bool(player.get("is_wall_running")) and player.global_position.x > 46.0:
				report["failure_observed"] = "lost_run"
				move_world(Vector3(0.0, 0.0, 1.0))
				_set_stage("miss_fall")
				return
			if _stage_seconds > 0.15 and not bool(player.get("is_wall_running")):
				move_world(Vector3(1.0, 0.0, -1.0).normalized())
			elif bool(player.get("is_wall_running")):
				move_world(Vector3.RIGHT)
			if player.global_position.x > 41.0:
				jump(false)
			if bool(player.get("is_wall_running")) and player.global_position.x > (52.0 if mode == "short_wall_jump" else 57.5):
				var wall := route.get_node(^"Course/ObliqueWall") as Node3D
				var local := wall.to_local(player.global_position)
				aim_at(wall.to_global(Vector3(local.x + 0.3, local.y + 1.0, 0.0)))
				_set_stage("wall_fire")
		"wall_fire":
			source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
			grapple(true)
			_set_stage("wall_stick")
		"wall_stick":
			if bool(player.get("is_wall_sticking")):
				report["stick_at"] = player.global_position
				jump(true)
				move_world(Vector3.ZERO)
				_set_stage("wall_jump")
		"wall_jump":
			jump(false)
			grapple(false)
			if mode == "short_wall_jump" and has_source(commit, &"player.jump.wall"):
				report["failure_observed"] = "short_wall_jump"
				_set_stage("miss_fall")
				return
			if on_deck(commit, "WallJumpLanding"):
				_land("WallJumpLanding", commit)
				_set_stage("finish_walk")
		"finish_walk":
			move_world((Vector3(61.0, player.global_position.y, 6.0) - player.global_position).normalized())
			if not report["finish_event"].is_empty() and bool(route.get_node(^"Course/FinishTrigger").get("is_complete")) and (route.get_node(^"Course/FinishTrigger") as Area3D).overlaps_body(player):
				finish(true)
		"miss_fall":
			jump(false)
			grapple(false)
			if _caught(commit):
				_begin_recovery(commit)
		"air_wait":
			if commit.locomotion_state_id == &"player.locomotion.airborne" and not commit.contact_frame.is_grounded:
				report["air_before"] = commit.committed_velocity
				report["air_start_step"] = commit.physics_step
				report["air_start_airborne"] = true
				move_world(Vector3(0.0, 0.0, 1.0))
				_set_stage("air_steer")
		"air_steer":
			if commit.locomotion_state_id != &"player.locomotion.airborne" or commit.contact_frame.is_grounded:
				report["errors"].append("air steering sampled a grounded commit")
			if _stage_seconds >= 0.20:
				report["air_after"] = commit.committed_velocity
				report["air_end_step"] = commit.physics_step
				report["steered_airborne"] = commit.locomotion_state_id == &"player.locomotion.airborne"
				move_world(Vector3.RIGHT)
				_set_stage("jump")
		"unsupported_approach":
			source.inject_movement_strengths(0.0, 0.0, 1.0, 0.0)
			if _stage_seconds > 1.0:
				finish(bool(report.get("unsupported_contact", false)))


func _begin_recovery(commit: PlayerMotorCommitResult) -> void:
	_recovering = true
	if report.get("failure_observed", "") != mode:
		report["errors"].append("recovery began without the intended failure observation")
	report["catch_position"] = commit.position_after
	report["catch_bodies"] = []
	for body_name in ["JumpCatch", "GrappleCatch", "MovingCatch", "WallCatch", "WallJumpCatch"]:
		if on_deck(commit, body_name):
			report["catch_bodies"].append(body_name)
	# Use the authored return route, not a grapple to a deck's underside.
	# All motion remains ordinary input in the original player/route instance.
	move_world(Vector3.ZERO)
	_set_stage("recover_brake")


func _drive_recovery(commit: PlayerMotorCommitResult) -> void:
	if on_deck(commit, "ReturnRamp"):
		report["ramp_contact"] = true
	match stage:
		"recover_brake":
			move_world(Vector3.ZERO)
			if motor.get_committed_velocity().length() < 0.5:
				_set_stage("recover_south")
		"recover_south":
			move_world(Vector3(0.0, 0.0, 1.0))
			if player.global_position.z > 15.2:
				move_world(Vector3.ZERO)
				_set_stage("recover_west")
		"recover_west":
			var goal := Vector3(-29.0, player.global_position.y, 16.0)
			var offset := goal - player.global_position
			move_world(offset.normalized() if offset.length() > 0.2 else Vector3.ZERO)
			if offset.length() < 0.3 and motor.get_committed_velocity().length() < 1.0:
				_set_stage("recover_ramp")
		"recover_ramp":
			move_world(Vector3(0.0, 0.0, -1.0))
			# Jump onto the low lip, then climb with normal locomotion. The ramp
			# is unchanged; starting below it without a jump can hit its underside.
			if not bool(report.get("ramp_jump_requested", false)) and player.global_position.z < 15.75:
				jump(true)
				report["ramp_jump_requested"] = true
			elif has_source(commit, &"player.jump.ground"):
				jump(false)
			if player.global_position.z < 2.0 and on_deck(commit, "StartDeck"):
				_land("StartDeck", commit)
				report["recovered"] = true
				move_world(Vector3.ZERO)
				_set_stage("recover_ready")
		"recover_ready":
			if _stage_seconds >= 0.1 and commit.locomotion_state_id == &"player.locomotion.grounded" and on_deck(commit, "StartDeck"):
				report["resume_support"] = {"deck": "StartDeck", "step": commit.physics_step, "position": commit.position_after}
				jump(true)
				_set_stage("recover_resume")
		"recover_resume":
			jump(false)
			if has_source(commit, &"player.jump.ground"):
				report["resumed"] = true
				report["resume_step"] = commit.physics_step
				finish(true)


func _caught(commit: PlayerMotorCommitResult) -> bool:
	for body_name in ["JumpCatch", "GrappleCatch", "MovingCatch", "WallCatch", "WallJumpCatch"]:
		if on_deck(commit, body_name):
			return true
	return false


func on_deck(commit: PlayerMotorCommitResult, body_name: String) -> bool:
	if commit.contact_frame == null or not commit.contact_frame.is_grounded:
		return false
	var body := route.get_node("Course/%s" % body_name) as StaticBody3D
	var shape_node := body.get_node(^"CollisionShape3D") as CollisionShape3D
	var box := shape_node.shape as BoxShape3D
	var point := shape_node.to_local(commit.position_after)
	# Player root is the capsule feet; reject raised anchors / catch floors.
	if box == null or absf(point.y - box.size.y / 2.0) > 0.12:
		return false
	if absf(point.x) > box.size.x / 2.0 + 0.05 or absf(point.z) > box.size.z / 2.0 + 0.05:
		return false
	for candidate in commit.contact_frame.candidates:
		if matches_body(candidate, body_name) and candidate.classification == ContactCandidate.Classification.GROUND:
			return true
	# Bounded candidate reporting can omit the ground RID when wall contacts
	# dominate. The engine's already-committed slide collisions are also facts,
	# not a new floor query. The +10 observer reads them in this same commit.
	for index in range(player.get_slide_collision_count()):
		var collision := player.get_slide_collision(index)
		if collision.get_collider() == body and collision.get_normal().dot(Vector3.UP) > 0.7:
			return true
	return false


func matches_body(candidate: ContactCandidate, body_name: String) -> bool:
	var body := route.get_node("Course/%s" % body_name) as CollisionObject3D
	return candidate != null and candidate.transient_identity == StringName("physics_rid:%d" % body.get_rid().get_id())


func aim_at(target: Vector3) -> void:
	var frame: PlayerCommandFrame = player.call("get_player_command_frame")
	if frame == null:
		return
	var camera := player.get_node(^"CameraPivot/SpringArm3D/Camera3D") as Camera3D
	var direction := (target - camera.global_position).normalized()
	var yaw := atan2(-direction.x, -direction.z)
	var pitch := clampf(asin(direction.y), source.pitch_min_radians, source.pitch_max_radians)
	var motion := Vector2(-wrapf(yaw - frame.view_yaw_radians, -PI, PI), -(pitch - frame.view_pitch_radians)) / source.mouse_sensitivity
	if source.invert_mouse_y:
		motion.y = -motion.y
	source.inject_mouse_motion(motion)


func move_world(direction: Vector3) -> void:
	var frame: PlayerCommandFrame = player.call("get_player_command_frame")
	if frame == null:
		return
	var axis := Basis(Vector3.UP, frame.view_yaw_radians).inverse() * direction
	source.inject_movement_strengths(maxf(-axis.x, 0.0), maxf(axis.x, 0.0), maxf(-axis.z, 0.0), maxf(axis.z, 0.0))


func jump(held: bool) -> void:
	source.inject_action_binding(PlayerCommandFrame.Action.JUMP, 0, held)


func grapple(held: bool) -> void:
	source.inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, held)


func release_grapple(label: String) -> void:
	if _release_before != Vector3.INF:
		report["errors"].append("pending release overwritten")
	_release_before = motor.get_committed_velocity()
	_release_label = label
	_release_request_step = _last_step
	grapple(false)


func _land(body_name: String, commit: PlayerMotorCommitResult) -> void:
	report["landings"].append({"deck": body_name, "position": commit.position_after, "seconds": report["elapsed_seconds"]})


func _set_stage(next: String) -> void:
	stage = next
	_stage_seconds = 0.0
	report["events"].append({"stage": stage, "seconds": report["elapsed_seconds"], "position": player.global_position})


func finish(success: bool) -> void:
	report["finished"] = success
	report["stage"] = stage
	report["position"] = player.global_position
	report["same_instance"] = player.get_instance_id() == _identity and route.get_instance_id() == _route_identity
	if _release_before != Vector3.INF:
		report["errors"].append("unobserved pending release at finish")
	jump(false)
	grapple(false)
	source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	done = true
	set_physics_process(false)


func _exit_tree() -> void:
	if is_instance_valid(source):
		jump(false)
		grapple(false)
		source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	if is_instance_valid(route):
		var trigger := route.get_node(^"Course/FinishTrigger")
		if trigger.is_connected("route_completed", _on_route_completed):
			trigger.disconnect("route_completed", _on_route_completed)


func _on_route_completed() -> void:
	var trigger := route.get_node(^"Course/FinishTrigger") as Area3D
	report["finish_event"] = {"stage": stage, "step": _last_step,
		"player_id": player.get_instance_id(), "overlaps_player": trigger.overlaps_body(player)}
	if stage != "finish_walk" or not trigger.overlaps_body(player):
		report["errors"].append("finish event outside intended physical arrival")


func _count_jump_sources(commit: PlayerMotorCommitResult, id: StringName) -> int:
	var count := 0
	for phase in commit.phase_intermediates:
		var phase_count := 0
		for accepted in phase.get("accepted_sources", []):
			if accepted.get("source_id", &"") == id:
				count += 1
				phase_count += 1
				if phase.get("phase", -1) != MotorPhase.Phase.ONE_SHOT_IMPULSES or accepted.get("kind", -1) != PlayerMotorSubmission.Kind.ONE_SHOT_IMPULSE:
					report["errors"].append("jump source in wrong phase/kind")
		if (phase.get("applied_sources", []) as Array).count(id) != phase_count:
			report["errors"].append("accepted/applied jump source mismatch")
	if count > 1:
		report["errors"].append("duplicate jump impulse at %d" % commit.physics_step)
	return count


static func has_source(commit: PlayerMotorCommitResult, id: StringName) -> bool:
	for phase in commit.phase_intermediates:
		for accepted in phase.get("accepted_sources", []):
			if accepted.get("source_id", &"") == id:
				return true
	return false


static func box_ray_entry_distance(body: StaticBody3D, origin: Vector3, direction: Vector3) -> float:
	# Pure authored-box geometry, not an additional physics query. Extend the
	# published canonical aim only to establish that a NO_CANDIDATE rejection
	# is looking at the intended body beyond the actual 35 m query segment.
	var shape_node := body.get_node(^"CollisionShape3D") as CollisionShape3D
	var box := shape_node.shape as BoxShape3D
	var hit: Variant = AABB(-box.size / 2.0, box.size).intersects_ray(shape_node.to_local(origin), shape_node.global_basis.inverse() * direction)
	return origin.distance_to(shape_node.to_global(hit as Vector3)) if hit is Vector3 else -1.0
