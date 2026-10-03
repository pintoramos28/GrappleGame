extends "res://tests/fixtures/traversal_route_driver.gd"
## Isolated constraint probe, NOT a production-tuned completion run. The test
## duplicates the grapple definition with pull disabled, and zeros gravity,
## before tree entry so input can exercise the boundary without the zip pull.
## Authored geometry, motion, 35 m boundary, input and motor remain real.

const BOUNDARY_SOURCE := &"player.grapple.maximum_distance"
const MAXIMUM_DISTANCE_M := 35.0
const TAUT_DISTANCE_M := 34.95

var anchor_name := "BoundaryAnchor"
var _previous_anchor_transform := Transform3D.IDENTITY
var _previous_anchor_step := -1
var _motion_origin := Vector3.INF
var _local_hit := Vector3.INF
var _slack_seen := false
var _taut_seen := false
var _carry_seen := false


func configure(host: Node3D, scenario: String = "boundary") -> void:
	super.configure(host, scenario)
	anchor_name = "MovingAnchor" if scenario == "moving_boundary" else "BoundaryAnchor"
	report["probe"] = {"initial_distance": 0.0, "maximum_distance": 0.0,
		"maximum_resolution_distance": 0.0, "constraint_samples": 0, "creation_samples": 0,
		"slack_samples": 0, "taut_samples": 0, "carry_samples": 0, "maximum_carry": 0.0,
		"maximum_motion": 0.0, "maximum_velocity_error": 0.0,
		"maximum_local_error": 0.0, "maximum_local_hit_error": 0.0,
		"maximum_distance_error": 0.0, "maximum_constraint_error": 0.0,
		"maximum_carry_error": 0.0, "maximum_carry_vector_error": 0.0,
		"maximum_static_inward_kick": 0.0, "maximum_refused_carry": 0.0,
		"maximum_tangent_error": 0.0, "inward_samples": 0, "tangent_samples": 0,
		"taut_inward_samples": 0, "taut_tangent_samples": 0,
		"taut_tangent_corrected_samples": 0, "taut_tangent_step": {},
		"taut_inward_step": {}, "carry_step": {},
		"short_attachment_grew": false, "outward_clipped": false, "slack_unchanged": true}


func _drive(commit: PlayerMotorCommitResult) -> void:
	var anchor := route.get_node("Course/%s" % anchor_name) as Node3D
	_sample(commit, anchor)
	_previous_anchor_transform = anchor.global_transform
	_previous_anchor_step = commit.physics_step
	if done:
		return
	match stage:
		"settle":
			if _stage_seconds >= 0.20:
				aim_at(anchor.global_position)
				_set_stage("probe_fire")
		"probe_fire":
			var target: GrappleTargetingResult = player.call("get_latest_grapple_targeting_result")
			if target == null or not target.is_accepted() or target.accepted_seed.get_target() != anchor:
				_fail_probe(commit, "probe failed acquisition")
				return
			grapple(true)
			_set_stage("stretch")
		"stretch":
			move_world(Vector3.LEFT)
			# Reach the actual boundary before switching commands, not merely a
			# near-boundary pre-resolution record that may still be stretching.
			var distance := commit.position_after.distance_to(anchor.global_transform * _local_hit)
			if _taut_seen and distance >= MAXIMUM_DISTANCE_M - 0.001 and (_carry_seen or anchor_name == "BoundaryAnchor"):
				_drive_tangent(anchor)
				_set_stage("tangent")
		"tangent":
			# A small outward input keeps the static tether taut while the other
			# axis builds tangential motion. Only ordinary next-step inputs change.
			_drive_tangent(anchor)
			if _stage_seconds > (0.20 if anchor_name == "BoundaryAnchor" else 0.8):
				move_world(Vector3.RIGHT)
				_set_stage("inward")
		"inward":
			if _stage_seconds > 1.5:
				finish(_slack_seen and _taut_seen and (anchor_name == "BoundaryAnchor" or _carry_seen))


func _drive_tangent(anchor: Node3D) -> void:
	var outward := player.global_position - anchor.global_transform * _local_hit
	outward.y = 0.0
	outward = outward.normalized()
	var tangent := Vector3(outward.z, 0.0, -outward.x)
	move_world((outward * 0.35 + tangent * 0.65).normalized())


func _sample(commit: PlayerMotorCommitResult, anchor: Node3D) -> void:
	var snapshot: GrappleAttachmentDiagnosticSnapshot = player.call("get_grapple_attachment_diagnostic_snapshot")
	var probe: Dictionary = report["probe"]
	if snapshot == null or not snapshot.is_active:
		if _motion_origin != Vector3.INF:
			_fail_probe(commit, "attachment ended during boundary probe")
		return
	var attachment: GrappleAttachment = player.call("get_grapple_attachment")
	if attachment == null or attachment.get_target() != anchor or snapshot.last_physics_step != commit.physics_step:
		_fail_probe(commit, "missing target or current attachment snapshot")
		return
	if _previous_anchor_step != commit.physics_step - 1 or commit.physics_delta_seconds <= 0.0:
		_fail_probe(commit, "missing same-step anchor finite-difference baseline")
		return
	if _local_hit == Vector3.INF:
		_local_hit = attachment.target_local_hit_offset
		_motion_origin = anchor.global_position
	probe["maximum_local_hit_error"] = maxf(float(probe["maximum_local_hit_error"]), _local_hit.distance_to(attachment.target_local_hit_offset))
	var resolved_hit := anchor.global_transform * _local_hit
	var measured_velocity := (resolved_hit - _previous_anchor_transform * _local_hit) / commit.physics_delta_seconds
	var measured_target_velocity := (anchor.global_position - _previous_anchor_transform.origin) / commit.physics_delta_seconds
	var distance_before := commit.position_before.distance_to(resolved_hit)
	var distance_after := commit.position_after.distance_to(resolved_hit)
	if not resolved_hit.is_finite() or not measured_velocity.is_finite() or not is_finite(distance_after) or player.global_position.distance_to(commit.position_after) > 0.0001:
		_fail_probe(commit, "non-finite geometry or player not at this committed endpoint")
		return
	if not snapshot.anchor_world_position.is_finite() or not snapshot.target_velocity_mps.is_finite() or not is_finite(snapshot.current_distance_m) or not is_finite(snapshot.maximum_distance_m):
		_fail_probe(commit, "non-finite attachment snapshot")
		return
	probe["maximum_local_error"] = maxf(float(probe["maximum_local_error"]), resolved_hit.distance_to(snapshot.anchor_world_position))
	probe["maximum_motion"] = maxf(float(probe["maximum_motion"]), _motion_origin.distance_to(anchor.global_position))
	# This is measured AFTER the sole motor commit, against the target's local
	# hit transformed in this same step; it is not the record's earlier radius.
	probe["maximum_distance"] = maxf(float(probe["maximum_distance"]), distance_after)
	probe["maximum_distance_error"] = maxf(float(probe["maximum_distance_error"]), absf(snapshot.current_distance_m - distance_after))
	if distance_after > float(probe["initial_distance"]) + 2.0 and int(probe["creation_samples"]) > 0:
		probe["short_attachment_grew"] = true
	# The accepted acquisition commit transitions from airborne, with no pull
	# or boundary submission until the next grappling update. This single,
	# explicit creation step is not counted as constraint coverage.
	if commit.physics_step == attachment.creation_physics_step:
		if not commit.anchor_constraint_records.is_empty() or commit.locomotion_state_id != &"player.locomotion.airborne":
			_fail_probe(commit, "unexpected acquisition-step constraint contract")
			return
		probe["creation_samples"] += 1
		probe["initial_distance"] = distance_after
		return
	if attachment.get_sampled_anchor_step() != commit.physics_step or not snapshot.anchor_valid or absf(snapshot.maximum_distance_m - MAXIMUM_DISTANCE_M) > 0.0001:
		_fail_probe(commit, "stale/invalid sampled anchor or non-35 m maximum")
		return
	var phase := _constraint_phase(commit)
	if done:
		return
	var records := commit.anchor_constraint_records
	if records.size() != 1 or commit.anchor_constraint_records_truncated or commit.anchor_constraint_record_overflow_count != 0:
		_fail_probe(commit, "require exactly one complete boundary record")
		return
	var record: Dictionary = records[0]
	if not record.has_all(["source_id", "physics_step", "anchor_position", "anchor_velocity", "distance_m", "maximum_distance_m", "velocity", "carry_applied_mps", "carry_refused_mps"]):
		_fail_probe(commit, "incomplete boundary record")
		return
	if record["source_id"] != BOUNDARY_SOURCE or int(record["physics_step"]) != commit.physics_step:
		_fail_probe(commit, "boundary record source/step mismatch")
		return
	for key in ["anchor_position", "anchor_velocity", "velocity"]:
		if not record[key] is Vector3 or not (record[key] as Vector3).is_finite():
			_fail_probe(commit, "invalid boundary vector: %s" % key)
			return
	for key in ["distance_m", "maximum_distance_m", "carry_applied_mps", "carry_refused_mps"]:
		if not typeof(record[key]) in [TYPE_FLOAT, TYPE_INT] or not is_finite(float(record[key])):
			_fail_probe(commit, "invalid boundary scalar: %s" % key)
			return
	if absf(float(record["maximum_distance_m"]) - MAXIMUM_DISTANCE_M) > 0.0001 or float(record["carry_applied_mps"]) < 0.0:
		_fail_probe(commit, "invalid maximum distance or negative carry")
		return
	var before: Vector3 = phase["before_velocity"]
	var after: Vector3 = phase["after_velocity"]
	var radial := (commit.position_before - resolved_hit).normalized()
	var before_radial := before.dot(radial)
	var after_radial := after.dot(radial)
	var before_tangent := before - radial * before_radial
	var after_tangent := after - radial * after_radial
	# Independent geometry/motion oracle: available radial travel in this
	# timestep plus the observed local hit's radial velocity. No record radius,
	# anchor velocity, correction or carry is used to compute the expectation.
	var available_speed := maxf(MAXIMUM_DISTANCE_M - distance_before, 0.0) / commit.physics_delta_seconds
	var expected_radial := minf(before_radial, available_speed + measured_velocity.dot(radial))
	var expected_velocity := before_tangent + radial * expected_radial
	var expected_carry := maxf(minf(before_radial, 0.0) - expected_radial, 0.0)
	var observed_carry := maxf(minf(before_radial, 0.0) - after_radial, 0.0)
	var reported_carry := float(record["carry_applied_mps"])
	probe["constraint_samples"] += 1
	probe["maximum_resolution_distance"] = maxf(float(probe["maximum_resolution_distance"]), distance_before)
	probe["maximum_distance_error"] = maxf(float(probe["maximum_distance_error"]), absf(float(record["distance_m"]) - distance_before))
	probe["maximum_local_error"] = maxf(float(probe["maximum_local_error"]), resolved_hit.distance_to(record["anchor_position"]))
	probe["maximum_velocity_error"] = maxf(float(probe["maximum_velocity_error"]), maxf(measured_target_velocity.distance_to(snapshot.target_velocity_mps), measured_velocity.distance_to(record["anchor_velocity"])))
	probe["maximum_constraint_error"] = maxf(float(probe["maximum_constraint_error"]), maxf(expected_velocity.distance_to(after), after.distance_to(record["velocity"])))
	probe["maximum_carry_error"] = maxf(float(probe["maximum_carry_error"]), absf(reported_carry - expected_carry))
	probe["maximum_carry_vector_error"] = maxf(float(probe["maximum_carry_vector_error"]), absf(reported_carry - observed_carry))
	probe["maximum_refused_carry"] = maxf(float(probe["maximum_refused_carry"]), absf(float(record["carry_refused_mps"])))
	probe["maximum_carry"] = maxf(float(probe["maximum_carry"]), reported_carry)
	probe["maximum_tangent_error"] = maxf(float(probe["maximum_tangent_error"]), before_tangent.distance_to(after_tangent))
	if anchor_name == "BoundaryAnchor":
		probe["maximum_static_inward_kick"] = maxf(float(probe["maximum_static_inward_kick"]), maxf(minf(before_radial, 0.0) - after_radial, 0.0))
	if distance_before < 33.0:
		_slack_seen = true
		probe["slack_samples"] += 1
		if before.distance_to(after) > 0.0001 or reported_carry > 0.0001 or expected_carry > 0.0001:
			probe["slack_unchanged"] = false
	if distance_before >= TAUT_DISTANCE_M:
		_taut_seen = true
		probe["taut_samples"] += 1
		if before_radial > 0.001 and before_radial > after_radial + 0.001:
			probe["outward_clipped"] = true
	var evidence := {"step": commit.physics_step, "delta_seconds": commit.physics_delta_seconds,
		"player_before": commit.position_before, "player_after": commit.position_after,
		"anchor_hit": resolved_hit, "local_hit": _local_hit, "radial": radial,
		"target_displacement": anchor.global_position - _motion_origin, "distance_before": distance_before,
		"distance_after": distance_after, "before": before, "after": after,
		"anchor_velocity": measured_velocity, "target_velocity": measured_target_velocity,
		"before_radial": before_radial, "after_radial": after_radial,
		"expected_radial": expected_radial, "expected_carry": expected_carry,
		"reported_carry": reported_carry, "observed_carry": observed_carry}
	if reported_carry > 0.01:
		if expected_carry <= 0.01 or observed_carry <= 0.01 or measured_velocity.dot(radial) >= -0.01:
			_fail_probe(commit, "reported carry lacks measured separating motion/vector change: %s" % evidence)
			return
		_carry_seen = true
		probe["carry_samples"] += 1
		if probe["carry_step"].is_empty():
			probe["carry_step"] = evidence
	var near_taut := minf(distance_before, distance_after) >= TAUT_DISTANCE_M
	if stage == "tangent" and before_tangent.length() > 0.1 and after_tangent.length() > 0.1:
		probe["tangent_samples"] += 1
		if near_taut:
			probe["taut_tangent_samples"] += 1
			if before_radial > after_radial + 0.001:
				probe["taut_tangent_corrected_samples"] += 1
				if probe["taut_tangent_step"].is_empty():
					probe["taut_tangent_step"] = evidence
	if stage == "inward" and before_radial < -0.1 and before.distance_to(after) < 0.001:
		probe["inward_samples"] += 1
		if near_taut:
			probe["taut_inward_samples"] += 1
			if probe["taut_inward_step"].is_empty():
				probe["taut_inward_step"] = evidence


func _constraint_phase(commit: PlayerMotorCommitResult) -> Dictionary:
	var phases: Array[Dictionary] = []
	for phase in commit.phase_intermediates:
		if phase.get("phase", -1) == MotorPhase.Phase.CONSTRAINTS_AND_REDIRECTIONS:
			phases.append(phase)
	if phases.size() != 1:
		_fail_probe(commit, "require exactly one constraint-phase intermediate, found %d" % phases.size())
		return {}
	var phase: Dictionary = phases[0]
	if not phase.has_all(["before_velocity", "after_velocity", "accepted_sources", "applied_sources"]):
		_fail_probe(commit, "incomplete constraint-phase intermediate")
		return {}
	for key in ["before_velocity", "after_velocity"]:
		if not phase[key] is Vector3 or not (phase[key] as Vector3).is_finite():
			_fail_probe(commit, "invalid constraint-phase velocity: %s" % key)
			return {}
	if not phase["accepted_sources"] is Array or not phase["applied_sources"] is Array:
		_fail_probe(commit, "missing constraint-phase source arrays")
		return {}
	var accepted: Array = phase["accepted_sources"]
	var applied: Array = phase["applied_sources"]
	if accepted.size() != 1 or applied.size() != 1 or applied[0] != BOUNDARY_SOURCE:
		_fail_probe(commit, "require only the boundary as accepted/applied constraint")
		return {}
	if not accepted[0] is Dictionary or not accepted[0].has_all(["source_id", "kind"]) or accepted[0]["source_id"] != BOUNDARY_SOURCE or accepted[0]["kind"] != PlayerMotorSubmission.Kind.MAXIMUM_ANCHOR_DISTANCE:
		_fail_probe(commit, "accepted constraint does not match boundary source/kind")
		return {}
	return phase


func _fail_probe(commit: PlayerMotorCommitResult, message: String) -> void:
	report["errors"].append("boundary step %d/%s: %s" % [commit.physics_step, stage, message])
	finish(false)
