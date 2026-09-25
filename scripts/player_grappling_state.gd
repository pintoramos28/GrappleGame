extends LimboState


func _enter() -> void:
	agent._clear_wall_run()


func _update(delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_GRAPPLING)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		return

	# Declared release phase (AC 8): the release edge and the target-invalidation
	# check run before any grapple motor submission of this step, so the
	# attachment's pull, boundary, and cap submissions stop for the same
	# simulation step. Termination is reason-coded and exactly-once (AC 9).
	if command_frame.was_released(PlayerCommandFrame.Action.GRAPPLE):
		agent.terminate_grapple(GrappleEndReason.Reason.RELEASE)
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_after_grapple_clear()
		return
	if not agent.is_grappling:
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_after_grapple_clear()
		return

	# Grapple-sampling phase (Story 1.8 Task 3.1): exactly ONE sampled
	# `GrappleAnchorState` per physics step, stored as this step's authoritative
	# anchor state BEFORE any grapple submission. An invalid sample commits one
	# typed terminal (freed -> TARGET_DESTROYED, invalidated ->
	# TARGET_INVALIDATED, scope -> SCOPE_MISMATCH, discontinuity ->
	# ANCHOR_DISCONTINUITY) and submits nothing for this step (AC 6).
	if not agent.sample_grapple_anchor(delta):
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_after_grapple_clear()
		return

	var input_dir: Vector2 = command_frame.movement_axis
	agent.submit_base_policy(agent.LOCOMOTION_GRAPPLING, input_dir)
	agent.submit_gravity_policy()
	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP) and agent.has_ground_contact():
		agent.submit_ground_jump(reference_velocity)
	agent.submit_grapple_pull(delta)
	if not agent.has_valid_grapple():
		agent.submit_base_passthrough(agent.LOCOMOTION_GRAPPLING)
		agent.dispatch_locomotion_after_grapple_clear()
		return
	agent.submit_grapple_speed_cap()
