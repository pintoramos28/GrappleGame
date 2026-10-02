class_name WallStickReanchorFixture
extends WallStickMotionFixture
## Engine-driven production player + actual marker/rope geometry measurements.
## The expected material point is derived independently from physical evidence,
## not from the production binding's private local offset.

var wall_component: Grappleable3D
var wall_policy := "ordinary"
var initial_wall_instability := 0.0
var initial_scope: StringName = &""
var wall_scope: StringName = &""
var start_forward := true
var initial_elapsed_seconds := 0.4
var original_attachment: GrappleAttachment
var entry_commit: PlayerMotorCommitResult
var expected_local_contact := Vector3.ZERO
var _captured_contact := false
var anchor_samples := 0
var maximum_anchor_error_m := 0.0
var maximum_marker_error_m := 0.0
var maximum_rope_end_error_m := 0.0
var maximum_point_velocity_error_mps := 0.0
var terminal_visuals_clear := true
var visible_visual_samples := 0
var missing_visual_sample_count := 0
var maximum_native_point_speed_mps := 0.0
var maximum_old_static_velocity_error_mps := 0.0
var release_request_step := -1
var elapsed_at_release_request := -1.0
var release_physics_step := -1
var elapsed_at_detachment := -1.0
var _previous_sticking_for_clock := false
var _last_visual_step := -1
var _previous_expected_point := Vector3.ZERO
var _previous_sample_step := -1
var last_sample_velocity := Vector3.ZERO

func _ready() -> void:
	super()
	var controller: GrappleController = player.get("_grapple_controller")
	original_attachment = controller.get_attachment()
	original_attachment.advance_elapsed(initial_elapsed_seconds)
	if initial_scope != &"":
		# Scope is occurrence-local. Recreate the fixture seed before ANY physics
		# tick, not during stick entry; production re-anchor must preserve it.
		controller.terminate(GrappleEndReason.Reason.RELEASE, 0)
		controller.set_scope_identity_provider(func() -> StringName: return initial_scope)
		var old_component := anchor.get_node_or_null(^"Grappleable") as Grappleable3D
		if old_component != null:
			old_component.encounter_scope_identity = initial_scope
		controller.commit_attachment(GrappleTargetSeed.new(old_component.target_id if old_component != null else &"", anchor.global_position, Vector3.BACK, old_component.build_response() if old_component != null else GrappleTargetResponse.static_default(), weakref(anchor), Vector3.ZERO), 0)
		original_attachment = controller.get_attachment()
		original_attachment.advance_elapsed(initial_elapsed_seconds)
		terminal_count = 0
	if wall_policy != "ordinary":
		wall_component = Grappleable3D.new()
		wall_component.name = "Grappleable"
		wall_component.target_id = &"fixture.reanchor.wall"
		wall_component.encounter_scope_identity = wall_scope
		wall_component.eligible = wall_policy != "ineligible"
		wall_component.instability = initial_wall_instability
		wall_component.anchor_mode = GrappleTargetResponse.AnchorMode.MOVING if wall_policy == "moving" else GrappleTargetResponse.AnchorMode.STATIC
		wall.add_child(wall_component)
		if wall_policy == "invalidated":
			wall_component.invalidate_grapple_anchor()
		elif wall_policy == "missing_id":
			wall_component.target_id = &""
		elif wall_policy == "malformed":
			wall_component.directional_adjustment.x = INF
	if not start_forward:
		input_source.inject_movement_strengths(0.0, 0.0, 0.0, 0.0)
	controller.attachment_ended.connect(_observe_terminal_visuals)
	# Visible geometry and an overview camera make the standalone live fixture
	# usable for viewport evidence; GUT still uses a small isolated viewport.
	var wall_mesh := MeshInstance3D.new()
	wall_mesh.name = "WallMesh"
	var box := BoxMesh.new()
	box.size = Vector3(16.0, 16.0, 0.4)
	wall_mesh.mesh = box
	wall.get_node(^"WallShape").add_child(wall_mesh)
	var material := StandardMaterial3D.new()
	material.albedo_color = Color(0.16, 0.25, 0.4)
	wall_mesh.material_override = material
	var light := DirectionalLight3D.new()
	light.rotation_degrees = Vector3(-35.0, -30.0, 0.0)
	add_child(light)
	var overview := Camera3D.new()
	overview.position = Vector3(5.0, 6.0, 7.0)
	add_child(overview)
	overview.look_at(Vector3(0.0, 4.0, -0.3))
	overview.current = true

func _physics_process(delta: float) -> void:
	super(delta)
	var result := motor.get_last_commit_result()
	if result == null or result.physics_step == _last_visual_step:
		return
	_last_visual_step = result.physics_step
	var sticking := bool(player.get("is_wall_sticking"))
	if _previous_sticking_for_clock and not sticking and release_physics_step < 0:
		release_physics_step = result.physics_step
		elapsed_at_detachment = original_attachment.elapsed_seconds
	_previous_sticking_for_clock = sticking
	var snapshot: GrappleAttachmentDiagnosticSnapshot = player.call("get_grapple_attachment_diagnostic_snapshot")
	if snapshot == null or not snapshot.is_active or snapshot.anchor_revision == 0 or not is_instance_valid(wall):
		return
	var owner_id := WallStickAttachment.single_active_shape_owner(wall)
	if owner_id < 0:
		return
	var owner_transform := wall.shape_owner_get_transform(owner_id)
	var authored_pose := wall.global_transform * owner_transform
	if not _captured_contact:
		entry_commit = result
		expected_local_contact = (WallStickAttachment.physical_body_transform(wall) * owner_transform).affine_inverse() * result.contact_frame.wall_support.point
		_captured_contact = true
	var expected_point := authored_pose * expected_local_contact
	anchor_samples += 1
	maximum_anchor_error_m = maxf(maximum_anchor_error_m, snapshot.anchor_world_position.distance_to(expected_point))
	measure_active_visuals(snapshot)
	if _previous_sample_step >= 0:
		var elapsed := delta * float(result.physics_step - _previous_sample_step)
		var expected_velocity := (expected_point - _previous_expected_point) / elapsed
		if wall is AnimatableBody3D or wall is CharacterBody3D or wall is RigidBody3D:
			var state := PhysicsServer3D.body_get_direct_state(wall.get_rid())
			var physical_point := state.transform * owner_transform * expected_local_contact
			expected_velocity = state.get_velocity_at_local_position(physical_point - state.transform.origin)
			maximum_native_point_speed_mps = maxf(maximum_native_point_speed_mps, expected_velocity.length())
			expected_velocity += wall.global_basis * (owner_transform * expected_local_contact - _previous_expected_owner_transform * expected_local_contact) / elapsed
			if wall is AnimatableBody3D:
				var old_static_velocity: Vector3 = (expected_point - _previous_expected_point) / elapsed + wall.constant_linear_velocity + wall.constant_angular_velocity.cross(expected_point - wall.global_position)
				maximum_old_static_velocity_error_mps = maxf(maximum_old_static_velocity_error_mps, old_static_velocity.distance_to(expected_velocity))
		elif wall is StaticBody3D:
			expected_velocity += wall.constant_linear_velocity + wall.constant_angular_velocity.cross(expected_point - wall.global_position)
		maximum_point_velocity_error_mps = maxf(maximum_point_velocity_error_mps, snapshot.target_velocity_mps.distance_to(expected_velocity))
	_previous_expected_point = expected_point
	_previous_expected_owner_transform = owner_transform
	_previous_sample_step = result.physics_step
	last_sample_velocity = snapshot.target_velocity_mps

var _previous_expected_owner_transform := Transform3D.IDENTITY

## Raw measurement seam for negative controls: no presentation update here.
## Inspect the ASSIGNED mesh, not the separate intended CylinderMesh resource.
func measure_active_visuals(snapshot: GrappleAttachmentDiagnosticSnapshot) -> bool:
	var marker := player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	var marker_mesh := marker.get_node(^"GrappleCursor") as MeshInstance3D
	var rope: MeshInstance3D = player.get("grapple_visual")
	var mesh := rope.mesh as CylinderMesh
	var marker_geometry := marker_mesh.mesh as SphereMesh
	if not marker.is_marker_visible() or not marker_mesh.is_visible_in_tree() or marker_geometry == null or not is_finite(marker_geometry.radius) or marker_geometry.radius <= 0.0 or not rope.is_visible_in_tree() or mesh == null or not is_finite(mesh.height) or mesh.height <= 0.0 or not is_finite(mesh.top_radius) or mesh.top_radius <= 0.0 or not is_finite(mesh.bottom_radius) or mesh.bottom_radius <= 0.0:
		missing_visual_sample_count = mini(missing_visual_sample_count + 1, MAX_OBSERVATION_IDS)
		return false
	visible_visual_samples += 1
	maximum_marker_error_m = maxf(maximum_marker_error_m, marker_mesh.global_position.distance_to(snapshot.anchor_world_position))
	var endpoint := rope.global_position + rope.global_basis.y.normalized() * mesh.height * 0.5
	maximum_rope_end_error_m = maxf(maximum_rope_end_error_m, endpoint.distance_to(snapshot.anchor_world_position))
	return true

func capture_release_clock_baseline() -> void:
	elapsed_at_release_request = original_attachment.elapsed_seconds
	release_request_step = motor.get_last_commit_result().physics_step

func release_clock_report() -> Dictionary:
	var result := motor.get_last_commit_result()
	var ticks_after_detachment := result.physics_step - release_physics_step if release_physics_step >= 0 else -1
	var resumed_seconds := float(ticks_after_detachment) * result.physics_delta_seconds
	var expected_elapsed := elapsed_at_release_request + resumed_seconds
	var expected_pull := _pull_curve(expected_elapsed)
	var reset_pull := _pull_curve(resumed_seconds)
	var clock_matches := release_request_step >= 0 and release_physics_step == release_request_step + 1 and absf(elapsed_at_detachment - elapsed_at_release_request) < 0.000001 and absf(original_attachment.elapsed_seconds - expected_elapsed) < 0.000001
	return {"release_request_step": release_request_step, "release_physics_step": release_physics_step, "ticks_after_detachment": ticks_after_detachment, "elapsed_before_release": elapsed_at_release_request, "elapsed_at_detachment": elapsed_at_detachment, "actual_elapsed": original_attachment.elapsed_seconds, "expected_elapsed": expected_elapsed, "expected_pull_mps2": expected_pull, "actual_pull_mps2": original_attachment.current_pull_acceleration_mps2(), "reset_pull_mps2": reset_pull, "clock_matches": clock_matches, "curve_matches": absf(original_attachment.current_pull_acceleration_mps2() - expected_pull) < 0.0001, "forced_reset_would_fail": absf(original_attachment.elapsed_seconds - resumed_seconds) > 0.1 and absf(expected_pull - reset_pull) > 1.0}

func _pull_curve(elapsed: float) -> float:
	return maxf(original_attachment.resolved_pull_min_acceleration_mps2, original_attachment.resolved_pull_initial_acceleration_mps2 - original_attachment.resolved_pull_acceleration_jerk_mps3 * elapsed)

func reanchor_report() -> Dictionary:
	var snapshot: GrappleAttachmentDiagnosticSnapshot = player.call("get_grapple_attachment_diagnostic_snapshot")
	var marker := player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	return {"rate": Engine.physics_ticks_per_second, "anchor_samples": anchor_samples, "maximum_anchor_error_m": maximum_anchor_error_m,
		"maximum_marker_error_m": maximum_marker_error_m, "maximum_rope_end_error_m": maximum_rope_end_error_m,
		"maximum_point_velocity_error_mps": maximum_point_velocity_error_mps, "last_point_velocity": last_sample_velocity,
		"revision": snapshot.anchor_revision if snapshot != null else -1, "attachment_id": snapshot.attachment_identity if snapshot != null else &"",
		"same_occurrence": player.call("get_grapple_attachment") == original_attachment,
		"elapsed_seconds": snapshot.elapsed_seconds if snapshot != null else -1.0, "sticking": player.get("is_wall_sticking"), "grappling": player.get("is_grappling"),
		"entry_count": entry_count, "terminal_count": terminal_count, "maximum_commits": maximum_commits,
		"rope_resets": player.get("grapple_visual_reset_count"), "marker_resets": marker.interpolation_reset_count,
		"terminal_visuals_clear": terminal_visuals_clear, "overlap_count": overlap_count, "maximum_carry_error_m": maximum_error_m,
		"visible_visual_samples": visible_visual_samples, "missing_visual_sample_count": missing_visual_sample_count, "maximum_native_point_speed_mps": maximum_native_point_speed_mps, "maximum_old_static_velocity_error_mps": maximum_old_static_velocity_error_mps}

func _observe_terminal_visuals(_id: StringName, _reason: GrappleEndReason.Reason) -> void:
	var marker := player.get_node(^"GrappleTargetMarker") as GrappleTargetMarker
	var rope: MeshInstance3D = player.get("grapple_visual")
	terminal_visuals_clear = terminal_visuals_clear and not marker.is_marker_visible() and marker.get_presented_world_position() == Vector3.ZERO and not rope.visible and rope.mesh == null
