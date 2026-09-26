class_name PlayerContactProvider
extends RefCounted


enum InitializationStatus {
	NOT_INITIALIZED,
	SUCCESS,
	MISSING_BODY,
	WRONG_BODY,
	BODY_NOT_IN_TREE,
	INVALID_GROUND_PROFILE,
	INVALID_WALL_PROFILE,
	INVALID_MASK,
	INVALID_COMPOSITION,
}


const MAX_REJECTIONS := 32


var _body: CharacterBody3D
var _ground_probe: GroundProbe
var _wall_probe: WallProbe
var _initialized := false
var _wall_available := false
var _bootstrapped := false
var _last_published_step := -1
var _last_frame: ContactFrame
var _last_wall_candidate: ContactCandidate
var _last_wall_step := -1
var _wall_loss_steps := 0
var _strict_lifecycle := true
var _last_diagnostic_snapshot: ContactDiagnosticSnapshot


func initialize(
	body: Node,
	ground_probe: PhysicsQueryProfile,
	wall_probe: PhysicsQueryProfile
) -> InitializationStatus:
	if not is_instance_valid(body):
		return InitializationStatus.MISSING_BODY
	if not body is CharacterBody3D:
		return InitializationStatus.WRONG_BODY
	var character_body := body as CharacterBody3D
	if not character_body.is_inside_tree():
		return InitializationStatus.BODY_NOT_IN_TREE
	if not ground_probe is GroundProbe:
		return InitializationStatus.INVALID_GROUND_PROFILE
	var typed_ground := ground_probe as GroundProbe
	if typed_ground.validate() != PhysicsQueryProfile.ValidationStatus.SUCCESS:
		return InitializationStatus.INVALID_GROUND_PROFILE

	_body = character_body
	_ground_probe = typed_ground
	_wall_probe = null
	_wall_available = false
	if wall_probe != null and wall_probe is WallProbe:
		var typed_wall := wall_probe as WallProbe
		if typed_wall.validate() == PhysicsQueryProfile.ValidationStatus.SUCCESS:
			_wall_probe = typed_wall
			_wall_available = true

	_initialized = true
	_bootstrapped = false
	_last_published_step = -1
	_last_frame = null
	_last_diagnostic_snapshot = null
	_last_wall_candidate = null
	_last_wall_step = -1
	_wall_loss_steps = 0
	return InitializationStatus.SUCCESS


func is_initialized() -> bool:
	return _initialized


func is_wall_available() -> bool:
	return _wall_available


func get_last_frame() -> ContactFrame:
	return _last_frame


func get_diagnostic_snapshot() -> ContactDiagnosticSnapshot:
	return _last_diagnostic_snapshot


func get_ground_probe() -> GroundProbe:
	return _ground_probe


func get_wall_probe() -> WallProbe:
	return _wall_probe


func set_strict_lifecycle(enabled: bool) -> void:
	_strict_lifecycle = enabled


func bootstrap() -> ContactFrame:
	if not _initialized:
		return ContactFrame.failure(0, ContactFrame.Status.NOT_INITIALIZED, ContactFrame.Origin.BOOTSTRAP)
	if not _has_usable_body():
		return ContactFrame.failure(0, ContactFrame.Status.INVALID_BODY, ContactFrame.Origin.BOOTSTRAP)
	if _bootstrapped:
		return ContactFrame.failure(0, ContactFrame.Status.DUPLICATE_STEP, ContactFrame.Origin.BOOTSTRAP, 0)

	var frame := _build_frame(
		0,
		ContactFrame.Origin.BOOTSTRAP,
		0.0,
		Vector3.ZERO,
		false
	)
	_bootstrapped = frame.success
	if _bootstrapped:
		_last_published_step = 0
		_last_frame = frame
	return frame


func publish_committed_frame(
	physics_step: int,
	delta_seconds: float,
	pre_commit_velocity: Vector3
) -> ContactFrame:
	if not _initialized:
		return ContactFrame.failure(physics_step, ContactFrame.Status.NOT_INITIALIZED)
	if not _has_usable_body():
		return ContactFrame.failure(physics_step, ContactFrame.Status.INVALID_BODY, ContactFrame.Origin.POST_COMMIT, physics_step)
	if not _bootstrapped:
		return ContactFrame.failure(physics_step, ContactFrame.Status.INVALID_STEP, ContactFrame.Origin.POST_COMMIT, physics_step)
	if physics_step <= _last_published_step:
		var duplicate_status := ContactFrame.Status.DUPLICATE_STEP if physics_step == _last_published_step else ContactFrame.Status.STALE_STEP
		return ContactFrame.failure(physics_step, duplicate_status, ContactFrame.Origin.POST_COMMIT, physics_step)
	if _strict_lifecycle and physics_step != _last_published_step + 1:
		return ContactFrame.failure(physics_step, ContactFrame.Status.SKIPPED_STEP, ContactFrame.Origin.POST_COMMIT, physics_step)
	if delta_seconds <= 0.0 or is_nan(delta_seconds) or is_inf(delta_seconds) or not pre_commit_velocity.is_finite():
		return ContactFrame.failure(physics_step, ContactFrame.Status.INVALID_DATA, ContactFrame.Origin.POST_COMMIT, physics_step)

	var frame := _build_frame(
		physics_step,
		ContactFrame.Origin.POST_COMMIT,
		delta_seconds,
		pre_commit_velocity,
		true
	)
	if frame.success:
		_last_published_step = physics_step
		_last_frame = frame
	return frame


static func classify_normal(
	normal: Vector3,
	ground_probe: PhysicsQueryProfile,
	wall_probe: PhysicsQueryProfile
) -> ContactCandidate.Classification:
	if not normal.is_finite() or normal.length_squared() <= 0.000001:
		return ContactCandidate.Classification.INVALID
	var normalized := normal.normalized()
	var ground_min := ground_probe.ground_min_normal_y if ground_probe != null else 0.7
	var wall_max := wall_probe.wall_max_abs_normal_y if wall_probe != null else 0.2
	if normalized.y >= ground_min:
		return ContactCandidate.Classification.GROUND
	if normalized.y <= -ground_min:
		return ContactCandidate.Classification.CEILING_LIKE
	if absf(normalized.y) <= wall_max:
		return ContactCandidate.Classification.WALL
	if normalized.y > 0.0:
		return ContactCandidate.Classification.FLOOR_LIKE
	return ContactCandidate.Classification.CEILING_LIKE


static func deduplicate_candidates(
	candidates: Array[ContactCandidate],
	profile: PhysicsQueryProfile
) -> Array[ContactCandidate]:
	var result: Array[ContactCandidate] = []
	var seen: Dictionary = {}
	for candidate in candidates:
		if candidate == null:
			continue
		var key := _deduplication_key(candidate, profile)
		if seen.has(key):
			var existing_index: int = seen[key]
			if _candidate_precedes(candidate, result[existing_index], profile, null):
				result[existing_index] = candidate
			continue
		seen[key] = result.size()
		result.append(candidate)
	return result


static func select_wall_candidate(
	candidates: Array[ContactCandidate],
	profile: WallProbe,
	continuity_candidate: ContactCandidate
) -> ContactCandidate:
	var deduplicated := deduplicate_candidates(candidates, profile)
	var selected: ContactCandidate = null
	for candidate in deduplicated:
		if candidate.classification != ContactCandidate.Classification.WALL:
			continue
		if selected == null or _candidate_precedes(candidate, selected, profile, continuity_candidate):
			selected = candidate
	return selected


static func _candidate_precedes(
	left: ContactCandidate,
	right: ContactCandidate,
	profile: PhysicsQueryProfile,
	continuity_candidate: ContactCandidate
) -> bool:
	var left_key := _selection_key(left, profile, continuity_candidate)
	var right_key := _selection_key(right, profile, continuity_candidate)
	return _compare_lexicographic(left_key, right_key) < 0


static func _selection_key(
	candidate: ContactCandidate,
	profile: PhysicsQueryProfile,
	continuity_candidate: ContactCandidate
) -> Array:
	var continuity_penalty := 1
	if continuity_candidate != null and _same_contact(candidate, continuity_candidate, profile):
		continuity_penalty = 0
	return [
		-_quantize(candidate.approach_opposition, profile.normal_quantization),
		_quantize(candidate.time_of_impact, profile.time_quantization),
		_quantize(candidate.distance, profile.point_quantization_m),
		continuity_penalty,
		_evidence_rank(candidate.source),
		_quantize(candidate.normal.x, profile.normal_quantization),
		_quantize(candidate.normal.y, profile.normal_quantization),
		_quantize(candidate.normal.z, profile.normal_quantization),
		_quantize(candidate.point.x, profile.point_quantization_m),
		_quantize(candidate.point.y, profile.point_quantization_m),
		_quantize(candidate.point.z, profile.point_quantization_m),
		_surface_identity_key(candidate.surface_identity),
		candidate.shape_index,
	]


static func _compare_lexicographic(left: Array, right: Array) -> int:
	for index in range(mini(left.size(), right.size())):
		if left[index] == right[index]:
			continue
		if left[index] < right[index]:
			return -1
		return 1
	return 0


static func _same_contact(
	left: ContactCandidate,
	right: ContactCandidate,
	profile: PhysicsQueryProfile
) -> bool:
	if left == null or right == null:
		return false
	var geometry_matches := (
		left.normal.angle_to(right.normal) <= deg_to_rad(profile.continuity_angle_degrees)
		and left.point.distance_to(right.point) <= profile.continuity_distance_m
	)
	if left.surface_identity != &"" and right.surface_identity != &"":
		return left.surface_identity == right.surface_identity and geometry_matches
	return geometry_matches


static func _deduplication_key(candidate: ContactCandidate, profile: PhysicsQueryProfile) -> String:
	var identity := _surface_identity_key(candidate.surface_identity)
	return "%s|%d|%d|%d|%d|%d|%d" % [
		identity,
		_quantize(candidate.normal.x, profile.normal_quantization),
		_quantize(candidate.normal.y, profile.normal_quantization),
		_quantize(candidate.normal.z, profile.normal_quantization),
		_quantize(candidate.point.x, profile.point_quantization_m),
		_quantize(candidate.point.y, profile.point_quantization_m),
		_quantize(candidate.point.z, profile.point_quantization_m),
	]


static func _quantize(value: float, step: float) -> int:
	if is_nan(value) or is_inf(value):
		return 0
	return roundi(value / maxf(step, 0.000001))


static func _surface_identity_key(identity: StringName) -> String:
	return "0:%s" % String(identity) if identity != &"" else "1:"


static func _evidence_rank(source: ContactCandidate.Source) -> int:
	match source:
		ContactCandidate.Source.COMMITTED_COLLISION, ContactCandidate.Source.BODY_FACT:
			return 0
		ContactCandidate.Source.CURRENT_OVERLAP:
			return 1
		ContactCandidate.Source.SWEEP_PREDICTION:
			return 2
	return 3


static func _ground_candidate_precedes(
	left: ContactCandidate,
	right: ContactCandidate,
	profile: GroundProbe
) -> bool:
	var left_key := [
		_quantize(left.distance, profile.point_quantization_m),
		_evidence_rank(left.source),
		_quantize(left.normal.x, profile.normal_quantization),
		_quantize(left.normal.y, profile.normal_quantization),
		_quantize(left.normal.z, profile.normal_quantization),
		_quantize(left.point.x, profile.point_quantization_m),
		_quantize(left.point.y, profile.point_quantization_m),
		_quantize(left.point.z, profile.point_quantization_m),
		_surface_identity_key(left.surface_identity),
		left.shape_index,
	]
	var right_key := [
		_quantize(right.distance, profile.point_quantization_m),
		_evidence_rank(right.source),
		_quantize(right.normal.x, profile.normal_quantization),
		_quantize(right.normal.y, profile.normal_quantization),
		_quantize(right.normal.z, profile.normal_quantization),
		_quantize(right.point.x, profile.point_quantization_m),
		_quantize(right.point.y, profile.point_quantization_m),
		_quantize(right.point.z, profile.point_quantization_m),
		_surface_identity_key(right.surface_identity),
		right.shape_index,
	]
	return _compare_lexicographic(left_key, right_key) < 0


func _build_frame(
	physics_step: int,
	frame_origin: ContactFrame.Origin,
	delta_seconds: float,
	pre_commit_velocity: Vector3,
	include_committed_evidence: bool
) -> ContactFrame:
	var candidates: Array[ContactCandidate] = []
	var rejections: Array[ContactRejection] = []
	var scanned_collision_count := 0
	var scan_overflow_count := 0
	var query_count := 0
	var body_reports_floor := false
	var body_floor_normal := Vector3.ZERO
	var body_floor_normal_valid := true
	var body_reports_wall := false
	var body_wall_normal := Vector3.ZERO
	var body_wall_normal_valid := true
	if include_committed_evidence:
		body_reports_floor = _body.is_on_floor()
		if body_reports_floor:
			body_floor_normal = _body.get_floor_normal()
			body_floor_normal_valid = body_floor_normal.is_finite() and body_floor_normal.length_squared() > 0.000001
			if body_floor_normal_valid:
				body_floor_normal_valid = classify_normal(body_floor_normal, _ground_probe, _wall_probe) == ContactCandidate.Classification.GROUND
		body_reports_wall = _body.is_on_wall()
		if body_reports_wall:
			body_wall_normal = _body.get_wall_normal()
			body_wall_normal_valid = body_wall_normal.is_finite() and body_wall_normal.length_squared() > 0.000001

	if include_committed_evidence:
		var total_collision_count := _body.get_slide_collision_count()
		var committed_scan_limit := mini(_ground_probe.scan_limit, PhysicsQueryProfile.MAX_SCAN_LIMIT)
		scan_overflow_count = maxi(0, total_collision_count - committed_scan_limit)
		if scan_overflow_count > 0:
			_append_rejection(rejections, ContactRejection.new(
				physics_step,
				ContactCandidate.Source.COMMITTED_COLLISION,
				ContactRejection.Reason.OVERFLOW
			))
		scanned_collision_count = mini(total_collision_count, committed_scan_limit)
		for collision_index in range(scanned_collision_count):
			var collision := _body.get_slide_collision(collision_index)
			if collision == null:
				continue
			var normal := collision.get_normal()
			var classification := classify_normal(normal, _ground_probe, _wall_probe)
			if classification == ContactCandidate.Classification.INVALID:
				_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.COMMITTED_COLLISION, ContactRejection.Reason.INVALID_NORMAL, normal))
				continue
			if classification == ContactCandidate.Classification.FLOOR_LIKE:
				_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.COMMITTED_COLLISION, ContactRejection.Reason.FLOOR_LIKE, normal))
				continue
			if classification == ContactCandidate.Classification.CEILING_LIKE:
				_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.COMMITTED_COLLISION, ContactRejection.Reason.CEILING_LIKE, normal))
				continue
			var collision_point := collision.get_position()
			var collider := collision.get_collider()
			candidates.append(_make_candidate(
				physics_step,
				ContactCandidate.Source.COMMITTED_COLLISION,
				classification,
				normal,
				collision_point,
				_surface_identity(collider),
				collision.get_collider_shape_index(),
				collision_index,
				_body.global_position.distance_to(collision_point),
				0.0,
				_approach_opposition(pre_commit_velocity, normal),
				_transient_surface_identity(collider)
			))

		if body_reports_floor:
			if body_floor_normal_valid:
				candidates.append(_make_candidate(
					physics_step,
					ContactCandidate.Source.BODY_FACT,
					ContactCandidate.Classification.GROUND,
					body_floor_normal,
					_body.global_position,
					&"",
					-1,
					-1,
					0.0,
					0.0,
					_approach_opposition(pre_commit_velocity, body_floor_normal)
				))
			elif not body_floor_normal_valid:
				_append_rejection(rejections, ContactRejection.new(
					physics_step,
					ContactCandidate.Source.BODY_FACT,
					ContactRejection.Reason.INVALID_NORMAL,
					body_floor_normal
				))
		if body_reports_wall and body_wall_normal_valid:
			var wall_classification := classify_normal(body_wall_normal, _ground_probe, _wall_probe)
			if wall_classification == ContactCandidate.Classification.WALL:
				candidates.append(_make_candidate(
					physics_step,
					ContactCandidate.Source.BODY_FACT,
					wall_classification,
					body_wall_normal,
					_body.global_position,
					&"",
					-1,
					-1,
					0.0,
					0.0,
					_approach_opposition(pre_commit_velocity, body_wall_normal)
				))
		elif body_reports_wall and not body_wall_normal_valid:
			_append_rejection(rejections, ContactRejection.new(
				physics_step,
				ContactCandidate.Source.BODY_FACT,
				ContactRejection.Reason.INVALID_NORMAL,
				body_wall_normal
			))

	var ground_query_start_count := query_count
	var ground_query := _query_ground_probe(
		physics_step,
		pre_commit_velocity,
		delta_seconds,
		query_count
	)
	var ground_query_count: int = ground_query.get("query_count", 0) - ground_query_start_count
	query_count = ground_query.query_count
	candidates.append_array(ground_query.candidates)
	_append_rejections_from(rejections, ground_query.rejections)

	var wall_query_start_count := query_count
	var wall_query := _query_wall_probe(
		physics_step,
		pre_commit_velocity,
		delta_seconds,
		query_count
	)
	var wall_query_count: int = wall_query.get("query_count", 0) - wall_query_start_count
	query_count = wall_query.query_count
	candidates.append_array(wall_query.candidates)
	_append_rejections_from(rejections, wall_query.rejections)

	var ground_candidates: Array[ContactCandidate] = []
	var wall_candidates: Array[ContactCandidate] = []
	for candidate in candidates:
		if candidate.classification == ContactCandidate.Classification.GROUND:
			ground_candidates.append(candidate)
		elif candidate.classification == ContactCandidate.Classification.WALL:
			wall_candidates.append(candidate)

	var body_grounded := body_reports_floor and body_floor_normal_valid
	var invalid_authoritative_contact := (
		(body_reports_floor and not body_floor_normal_valid)
		or (body_reports_wall and not body_wall_normal_valid)
	)
	var best_ground: ContactCandidate = _select_ground_candidate(ground_candidates, _ground_probe)
	var has_ground_surface := best_ground != null
	var grounded := false
	var ground_provenance := ContactFrame.GroundProvenance.NONE
	var ground_normal := Vector3.ZERO
	var ground_identity: StringName = &""
	var ground_identity_persistent := false
	if body_grounded:
		grounded = true
		has_ground_surface = true
		ground_provenance = ContactFrame.GroundProvenance.BODY
		ground_normal = body_floor_normal
		if best_ground != null:
			if best_ground.source != ContactCandidate.Source.BODY_FACT:
				ground_identity = best_ground.surface_identity
				ground_identity_persistent = best_ground.has_authored_identity()
				ground_provenance = ContactFrame.GroundProvenance.BODY_AND_PROBE
	elif not body_reports_floor:
		if best_ground != null:
			has_ground_surface = true
			ground_normal = best_ground.normal
			ground_identity = best_ground.surface_identity
			ground_identity_persistent = best_ground.has_authored_identity()
			var is_supporting := best_ground.distance <= _ground_probe.support_max_distance_m + _ground_probe.support_separation_epsilon_m
			var is_non_separating := pre_commit_velocity.y <= _ground_probe.non_separating_velocity_epsilon_m
			if is_supporting and is_non_separating:
				grounded = true
				ground_provenance = ContactFrame.GroundProvenance.GROUND_PROBE
			else:
				ground_provenance = ContactFrame.GroundProvenance.PROXIMITY_ONLY

	var body_probe_disagreement := include_committed_evidence and body_reports_floor != grounded
	if body_probe_disagreement:
		_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.BODY_FACT, ContactRejection.Reason.BODY_PROBE_DISAGREEMENT))

	var selected_wall: ContactCandidate = null
	var wall_provenance := ContactFrame.WallProvenance.NONE
	var wall_relation := ContactFrame.WallRelation.NONE
	var continuity_action := ContactFrame.ContinuityAction.NONE
	var wall_identity_persistent := false
	var wall_contact_lost := false
	if not _wall_available:
		_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.CURRENT_OVERLAP, ContactRejection.Reason.WALL_UNAVAILABLE))
		continuity_action = ContactFrame.ContinuityAction.UNAVAILABLE
	else:
		var deduplicated_walls := deduplicate_candidates(wall_candidates, _wall_probe)
		selected_wall = select_wall_candidate(deduplicated_walls, _wall_probe, _last_wall_candidate)
		if selected_wall != null:
			if _last_wall_candidate == null:
				continuity_action = ContactFrame.ContinuityAction.INITIAL
				wall_provenance = _wall_provenance_for_source(selected_wall.source)
			elif _last_wall_step == physics_step - 1 and _same_contact(selected_wall, _last_wall_candidate, _wall_probe):
				continuity_action = ContactFrame.ContinuityAction.PRESERVED
				wall_provenance = ContactFrame.WallProvenance.CONTINUITY
			else:
				continuity_action = ContactFrame.ContinuityAction.SWITCHED
				wall_provenance = _wall_provenance_for_source(selected_wall.source)
			wall_identity_persistent = selected_wall.has_authored_identity()
			_last_wall_candidate = selected_wall
			_last_wall_step = physics_step
			_wall_loss_steps = 0
		else:
			if _last_wall_candidate != null and _last_wall_step == physics_step - 1 and _wall_loss_steps < _wall_probe.continuity_loss_steps:
				_wall_loss_steps += 1
				selected_wall = _retag_candidate(_last_wall_candidate, physics_step)
				_last_wall_candidate = selected_wall
				_last_wall_step = physics_step
				wall_provenance = ContactFrame.WallProvenance.CONTINUITY
				continuity_action = ContactFrame.ContinuityAction.PRESERVED
				wall_identity_persistent = selected_wall.has_authored_identity()
			else:
				if _last_wall_candidate != null:
					continuity_action = ContactFrame.ContinuityAction.LOST
					wall_contact_lost = true
				_last_wall_candidate = null
				_last_wall_step = physics_step
				_wall_loss_steps = 0

	var bounded_candidates := _bound_candidates(candidates, _wall_probe if _wall_available else _ground_probe, rejections, physics_step)
	var overflow_count := scan_overflow_count + maxi(0, candidates.size() - bounded_candidates.size())
	var status := ContactFrame.Status.INVALID_DATA if invalid_authoritative_contact else ContactFrame.Status.SUCCESS
	var frame := ContactFrame.new(
		physics_step,
		frame_origin,
		status,
		physics_step,
		include_committed_evidence,
		grounded,
		has_ground_surface,
		ground_normal.normalized() if ground_normal.length_squared() > 0.000001 else Vector3.ZERO,
		ground_identity,
		ground_provenance,
		selected_wall != null,
		selected_wall.normal if selected_wall != null else Vector3.ZERO,
		selected_wall.surface_identity if selected_wall != null else &"",
		wall_provenance,
		_get_wall_relation(selected_wall, pre_commit_velocity) if selected_wall != null else wall_relation,
		continuity_action,
		bounded_candidates,
		rejections,
		scanned_collision_count,
		bounded_candidates.size(),
		query_count,
		rejections.size(),
		overflow_count,
		ground_identity_persistent,
		wall_identity_persistent,
		wall_contact_lost,
		body_probe_disagreement,
		ground_query.success,
		wall_query.success
	)
	_last_diagnostic_snapshot = ContactDiagnosticSnapshot.new(
		frame,
		_provider_status_id(frame),
		_ground_probe,
		_wall_probe if _wall_available else null,
		ground_query.get("directions", []),
		wall_query.get("directions", []),
		ground_query.get("sweep_distance_m", 0.0),
		wall_query.get("sweep_distance_m", 0.0),
		ground_query_count,
		wall_query_count
	)
	return frame


func _query_ground_probe(
	physics_step: int,
	sample_velocity: Vector3,
	delta_seconds: float,
	initial_query_count: int
) -> Dictionary:
	var directions: Array[Vector3] = [
		_ground_probe.probe_direction.normalized()
	]
	return _query_profile(
		physics_step,
		_ground_probe,
		directions,
		sample_velocity,
		delta_seconds,
		initial_query_count
	)


func _query_wall_probe(
	physics_step: int,
	pre_commit_velocity: Vector3,
	delta_seconds: float,
	initial_query_count: int
) -> Dictionary:
	if not _wall_available:
		return {"success": false, "query_count": initial_query_count, "candidates": [], "rejections": []}
	var horizontal := Vector3(pre_commit_velocity.x, 0.0, pre_commit_velocity.z)
	var forward := horizontal.normalized() if horizontal.length_squared() > 0.000001 else -_body.global_transform.basis.z.normalized()
	var right := forward.cross(Vector3.UP).normalized()
	if right.length_squared() <= 0.000001:
		right = _body.global_transform.basis.x.normalized()
	var directions: Array[Vector3] = [
		right,
		-right,
		(right + forward).normalized(),
		(-right + forward).normalized(),
	]
	# A wall-stick hold has no horizontal velocity. Facing-based side/forward
	# probes can then all point away from the wall when the player looks around.
	# Keep one of the same four queries aimed at the last selected wall so its
	# contact remains observable without extending the continuity loss window or
	# increasing the query budget. A truly removed wall still fails the probe.
	if _last_wall_candidate != null and horizontal.length_squared() <= 0.000001:
		var toward_last_wall := -_last_wall_candidate.normal
		toward_last_wall.y = 0.0
		if toward_last_wall.length_squared() > 0.000001:
			directions[3] = toward_last_wall.normalized()
	return _query_profile(
		physics_step,
		_wall_probe,
		directions,
		pre_commit_velocity,
		delta_seconds,
		initial_query_count
	)


func _query_profile(
	physics_step: int,
	profile: PhysicsQueryProfile,
	directions: Array[Vector3],
	sample_velocity: Vector3,
	delta_seconds: float,
	initial_query_count: int
) -> Dictionary:
	var candidates: Array[ContactCandidate] = []
	var rejections: Array[ContactRejection] = []
	var query_count := initial_query_count
	var query_success := false
	var max_sweep_distance := 0.0
	var space_state: PhysicsDirectSpaceState3D = _body.get_world_3d().direct_space_state if _body.get_world_3d() != null else null
	if space_state == null:
		return {"success": false, "query_count": query_count, "candidates": candidates, "rejections": rejections}

	var query_index := 0
	for raw_direction in directions:
		var direction := raw_direction.normalized()
		if direction.length_squared() <= 0.000001:
			_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.SWEEP_PREDICTION, ContactRejection.Reason.INVALID_NORMAL))
			continue
		var origin := _body.global_transform * profile.probe_offset
		var params := PhysicsShapeQueryParameters3D.new()
		params.shape = profile.shape
		params.transform = Transform3D(Basis.IDENTITY, origin)
		params.collision_mask = profile.get_collision_mask()
		params.collide_with_bodies = profile.collide_with_bodies
		params.collide_with_areas = profile.collide_with_areas
		params.margin = profile.margin_m
		if profile.exclude_body:
			params.exclude = [_body.get_rid()]

		if profile.overlap_check_enabled:
			params.motion = Vector3.ZERO
			var overlaps := space_state.intersect_shape(params, mini(profile.scan_limit, PhysicsQueryProfile.MAX_SCAN_LIMIT))
			query_count += 1
			query_success = true
			if not overlaps.is_empty():
				var overlap_rest := space_state.get_rest_info(params)
				query_count += 1
				for overlap_index in range(overlaps.size()):
					var overlap_hit: Dictionary = overlaps[overlap_index].duplicate(true)
					if _rest_info_matches_overlap(overlap_rest, overlap_hit):
						overlap_hit.merge(overlap_rest, true)
					overlap_hit = _dictionary_with_fallback({}, overlap_hit, origin, -direction)
					var overlap_candidate := _candidate_from_hit(
						physics_step,
						ContactCandidate.Source.CURRENT_OVERLAP,
						overlap_hit,
						direction,
						0.0,
						0.0,
						query_index + overlap_index,
						sample_velocity
					)
					if overlap_candidate != null:
						if overlap_candidate.classification == ContactCandidate.Classification.FLOOR_LIKE or overlap_candidate.classification == ContactCandidate.Classification.CEILING_LIKE:
							_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.CURRENT_OVERLAP, ContactRejection.Reason.FLOOR_LIKE if overlap_candidate.classification == ContactCandidate.Classification.FLOOR_LIKE else ContactRejection.Reason.CEILING_LIKE, overlap_candidate.normal, overlap_candidate.point))
						else:
							candidates.append(overlap_candidate)

		var velocity_distance := maxf(sample_velocity.dot(direction), 0.0) * delta_seconds
		var sweep_distance := minf(
			profile.sweep_distance_cap_m,
			maxf(
				profile.probe_distance_m,
				velocity_distance + profile.thickness_m + profile.margin_m
			)
		)
		max_sweep_distance = maxf(max_sweep_distance, sweep_distance)
		params.motion = direction * sweep_distance
		var cast_result := space_state.cast_motion(params)
		query_count += 1
		query_success = true
		var safe_fraction := 1.0
		if cast_result.size() >= 2:
			safe_fraction = clampf(float(cast_result[0]), 0.0, 1.0)
		if safe_fraction < 0.999999:
			var unsafe_fraction := safe_fraction
			if cast_result.size() >= 2:
				unsafe_fraction = clampf(float(cast_result[1]), safe_fraction, 1.0)
			params.transform = Transform3D(params.transform.basis, origin + direction * sweep_distance * unsafe_fraction)
			params.motion = Vector3.ZERO
			var sweep_rest := space_state.get_rest_info(params)
			query_count += 1
			var sweep_hit := _dictionary_with_fallback(sweep_rest, {}, origin + direction * sweep_distance * safe_fraction, -direction)
			var sweep_candidate := _candidate_from_hit(
				physics_step,
				ContactCandidate.Source.SWEEP_PREDICTION,
				sweep_hit,
				direction,
				distance_to(sweep_hit, origin),
				safe_fraction,
				query_index,
				sample_velocity
			)
			if sweep_candidate != null:
				if sweep_candidate.classification == ContactCandidate.Classification.FLOOR_LIKE or sweep_candidate.classification == ContactCandidate.Classification.CEILING_LIKE:
					_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.SWEEP_PREDICTION, ContactRejection.Reason.FLOOR_LIKE if sweep_candidate.classification == ContactCandidate.Classification.FLOOR_LIKE else ContactRejection.Reason.CEILING_LIKE, sweep_candidate.normal, sweep_candidate.point))
				else:
					candidates.append(sweep_candidate)
		query_index += 1

	return {
		"success": query_success,
		"query_count": query_count,
		"candidates": candidates,
		"rejections": rejections,
		"directions": directions.duplicate(),
		"sweep_distance_m": max_sweep_distance,
	}


func _candidate_from_hit(
	physics_step: int,
	source: ContactCandidate.Source,
	hit: Dictionary,
	direction: Vector3,
	distance: float,
	time_of_impact: float,
	query_index: int,
	sample_velocity: Vector3
) -> ContactCandidate:
	if hit.is_empty():
		return null
	var normal: Vector3 = hit.get("normal", -direction)
	var point: Vector3 = hit.get("point", hit.get("position", _body.global_position))
	if not normal.is_finite() or normal.length_squared() <= 0.000001 or not point.is_finite():
		return null
	var collider: Object = hit.get("collider", null)
	if collider == null and hit.has("collider_id"):
		collider = instance_from_id(int(hit["collider_id"]))
	var classification := classify_normal(normal, _ground_probe, _wall_probe)
	var shape_index := int(hit.get("shape", -1))
	var actual_distance := distance if not is_nan(distance) and not is_inf(distance) else _body.global_position.distance_to(point)
	return _make_candidate(
		physics_step,
		source,
		classification,
		normal,
		point,
		_surface_identity(collider),
		shape_index,
		query_index,
		actual_distance,
		time_of_impact,
		_approach_opposition(sample_velocity, normal),
		_transient_surface_identity(collider)
	)


func _make_candidate(
	physics_step: int,
	source: ContactCandidate.Source,
	classification: ContactCandidate.Classification,
	normal: Vector3,
	point: Vector3,
		surface_identity: StringName,
		shape_index: int,
		query_index: int,
		distance: float,
		time_of_impact: float,
		approach_opposition: float,
		transient_identity: StringName = &""
) -> ContactCandidate:
	var normalized := normal.normalized()
	return ContactCandidate.new(
		physics_step,
		source,
		classification,
		normalized,
		point,
		surface_identity,
		shape_index,
		query_index,
		maxf(distance, 0.0),
		clampf(time_of_impact, 0.0, 1.0),
		maxf(approach_opposition, 0.0),
		transient_identity
	)


static func _select_ground_candidate(candidates: Array[ContactCandidate], profile: GroundProbe) -> ContactCandidate:
	var selected: ContactCandidate = null
	for candidate in candidates:
		if selected == null or _ground_candidate_precedes(candidate, selected, profile):
			selected = candidate
	return selected


static func _retag_candidate(candidate: ContactCandidate, physics_step: int) -> ContactCandidate:
	if candidate == null:
		return null
	return ContactCandidate.new(
		physics_step,
		candidate.source,
		candidate.classification,
		candidate.normal,
		candidate.point,
		candidate.surface_identity,
		candidate.shape_index,
		candidate.query_index,
		candidate.distance,
		candidate.time_of_impact,
		candidate.approach_opposition,
		candidate.transient_identity
	)


func _bound_candidates(
	candidates: Array[ContactCandidate],
	profile: PhysicsQueryProfile,
	rejections: Array[ContactRejection],
	physics_step: int
) -> Array[ContactCandidate]:
	var deduplicated := deduplicate_candidates(candidates, profile)
	deduplicated.sort_custom(func(left: ContactCandidate, right: ContactCandidate) -> bool:
		return _candidate_precedes(left, right, profile, _last_wall_candidate)
	)
	var candidate_limit := mini(profile.candidate_limit, PhysicsQueryProfile.MAX_CANDIDATE_LIMIT)
	var report_limit := mini(profile.report_limit, PhysicsQueryProfile.MAX_REPORT_LIMIT)
	if deduplicated.size() > candidate_limit:
		for _index in range(deduplicated.size() - candidate_limit):
			_append_rejection(rejections, ContactRejection.new(physics_step, ContactCandidate.Source.SWEEP_PREDICTION, ContactRejection.Reason.OVERFLOW))
		deduplicated.resize(candidate_limit)
	var reported := deduplicated.slice(0, mini(report_limit, deduplicated.size()))
	var result: Array[ContactCandidate] = []
	for candidate in reported:
		result.append(candidate)
	return result


func _append_rejection(rejections: Array[ContactRejection], rejection: ContactRejection) -> void:
	if rejection == null or rejections.size() >= MAX_REJECTIONS:
		return
	rejections.append(rejection)


func _append_rejections_from(target: Array[ContactRejection], source: Array) -> void:
	for rejection in source:
		if rejection is ContactRejection:
			_append_rejection(target, rejection)


func _rest_info_matches_overlap(rest: Dictionary, overlap: Dictionary) -> bool:
	if rest.is_empty() or overlap.is_empty() or not rest.has("collider_id") or not overlap.has("collider_id"):
		return false
	if int(rest.get("collider_id", -1)) != int(overlap.get("collider_id", -2)):
		return false
	return int(rest.get("shape", -1)) == int(overlap.get("shape", -2))


func _dictionary_with_fallback(
	primary: Dictionary,
	secondary: Dictionary,
	fallback_point: Vector3,
	fallback_normal: Vector3
) -> Dictionary:
	var result := primary.duplicate(true) if not primary.is_empty() else secondary.duplicate(true)
	if not result.has("point") and not result.has("position"):
		result["point"] = fallback_point
	if not result.has("normal"):
		result["normal"] = fallback_normal
	return result


func _surface_identity(collider: Object) -> StringName:
	if collider == null or not is_instance_valid(collider):
		return &""
	for metadata_key in [&"physics_surface_id", &"surface_identity", &"contact_surface_id"]:
		if collider.has_meta(metadata_key):
			var value := String(collider.get_meta(metadata_key))
			if not value.is_empty():
				return StringName(value)
	return &""


func _transient_surface_identity(collider: Object) -> StringName:
	if collider == null or not is_instance_valid(collider) or not collider is CollisionObject3D:
		return &""
	var rid := (collider as CollisionObject3D).get_rid()
	if not rid.is_valid():
		return &""
	# RID identity is intentionally frame-local diagnostic data. It is never
	# promoted to the authored/persistent surface identity used for policy.
	return StringName("physics_rid:%d" % rid.get_id())


func _approach_opposition(velocity: Vector3, normal: Vector3) -> float:
	if not velocity.is_finite() or not normal.is_finite():
		return 0.0
	return maxf(-velocity.dot(normal.normalized()), 0.0)


func _wall_provenance_for_source(source: ContactCandidate.Source) -> ContactFrame.WallProvenance:
	match source:
		ContactCandidate.Source.COMMITTED_COLLISION, ContactCandidate.Source.BODY_FACT:
			return ContactFrame.WallProvenance.COMMITTED_COLLISION
		ContactCandidate.Source.CURRENT_OVERLAP:
			return ContactFrame.WallProvenance.CURRENT_OVERLAP
		ContactCandidate.Source.SWEEP_PREDICTION:
			return ContactFrame.WallProvenance.SWEEP_PREDICTION
	return ContactFrame.WallProvenance.NONE


func _get_wall_relation(candidate: ContactCandidate, velocity: Vector3) -> ContactFrame.WallRelation:
	if candidate == null:
		return ContactFrame.WallRelation.NONE
	var normal := candidate.normal
	var horizontal_velocity := Vector3(velocity.x, 0.0, velocity.z)
	if horizontal_velocity.length_squared() <= 0.000001:
		return ContactFrame.WallRelation.GENERIC
	var forward := -_body.global_transform.basis.z.normalized()
	var right := _body.global_transform.basis.x.normalized()
	var normal_horizontal := Vector3(normal.x, 0.0, normal.z).normalized()
	if absf(normal_horizontal.dot(right)) >= absf(normal_horizontal.dot(forward)):
		return ContactFrame.WallRelation.RIGHT if normal_horizontal.dot(right) < 0.0 else ContactFrame.WallRelation.LEFT
	return ContactFrame.WallRelation.FRONT if normal_horizontal.dot(forward) < 0.0 else ContactFrame.WallRelation.BACK


func distance_to(hit: Dictionary, origin: Vector3) -> float:
	var point: Vector3 = hit.get("point", hit.get("position", origin))
	return origin.distance_to(point)


func _has_usable_body() -> bool:
	return _initialized and is_instance_valid(_body) and _body.is_inside_tree()


func _provider_status_id(frame: ContactFrame) -> StringName:
	if frame == null:
		return &"no_frame"
	if not frame.success:
		return StringName(ContactFrame.Status.keys()[int(frame.status)].to_lower())
	if not _wall_available:
		return &"ready_wall_unavailable"
	return &"ready"
