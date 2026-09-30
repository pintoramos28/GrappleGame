extends LimboState


func _update(delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_WALL_STICK)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_STICK)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	if command_frame == null:
		agent.submit_wall_stick_hold()
		return

	if not command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE):
		if (
			command_frame.was_pressed(PlayerCommandFrame.Action.JUMP)
			# While sticking, this also validates the selected wall continuity and
			# persistent identity; another supported wall cannot authorize the jump.
			and agent.has_supported_wall_contact()
		):
			_dispatch_wall_stick_jump(reference_velocity)
		elif (
			not command_frame.was_pressed(PlayerCommandFrame.Action.JUMP)
			and agent._has_outward_wall_speed(reference_velocity, agent.wall_stick_normal)
		):
			_cancel_for_outward_wall_motion(reference_velocity)
		else:
			agent.terminate_grapple(GrappleEndReason.Reason.RELEASE)
			agent.submit_wall_stick_release(reference_velocity)
			agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)
		return
	# Grapple-sampling phase (Story 1.8 Task 3.1, review fix): every wall-stick
	# step with a live command frame samples the anchor exactly once - also
	# while the grapple is valid, so the stored sample never goes stale during a
	# wall-stick hold and the maximum-distance rule stays enforced.
	if not agent.sample_grapple_anchor(delta) or not agent.has_valid_grapple():
		# Story 1.8 AC 6: the sampling phase above already classified a stale
		# anchor (freed -> TARGET_DESTROYED, invalidated -> TARGET_INVALIDATED),
		# then keep the preserved fallback for anything the sampler could not
		# commit (idempotent: it commits nothing when a terminal exists).
		agent.terminate_grapple(GrappleEndReason.Reason.TARGET_INVALIDATED)
		agent.submit_wall_stick_release(reference_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)
		return

	# Story 1.9 Task 7.1: the required-wall-contact-loss exit. The hold needs a
	# supported wall, and the shared `ContactFrame` continuity facts (loss
	# window, `wall_contact_lost`, unavailable profile) are the only authority
	# for that. A lost or unsupported wall ends the hold exactly once - the
	# preserved `GrappleController.terminate(reason, step)` funnel runs
	# `_clear_wall_stick()` before consumers observe "ended" - and the
	# non-jump exit preserves the recoverable reference velocity.
	if not agent.has_supported_wall_contact():
		agent.terminate_grapple(GrappleEndReason.Reason.STATE_CANCELLATION)
		agent.submit_wall_stick_release(reference_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)
		return

	# Jump may use the cached normal only while it is still the selected wall.
	# Lost contact and a switched relationship take the ordinary release exit.
	if command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		_dispatch_wall_stick_jump(reference_velocity)
		return

	# `wall_stick_normal` is the normalized authoritative ContactFrame normal
	# captured when this wall was selected. Keep measuring against that stable
	# relationship across preserved-contact normal noise; a fresh jump
	# intentionally launches outward, so the gate applies only to a continuing
	# hold after the jump branch.
	if agent._has_outward_wall_speed(reference_velocity, agent.wall_stick_normal):
		_cancel_for_outward_wall_motion(reference_velocity)
		return

	agent.submit_wall_stick_hold()


func _cancel_for_outward_wall_motion(reference_velocity: Vector3) -> void:
	agent.terminate_grapple(GrappleEndReason.Reason.STATE_CANCELLATION)
	agent.submit_wall_stick_release(reference_velocity)
	agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)


func _dispatch_wall_stick_jump(reference_velocity: Vector3) -> void:
	agent.submit_base_passthrough(agent.LOCOMOTION_WALL_STICK)
	agent.submit_wall_stick_jump(reference_velocity)
	agent.dispatch_locomotion_event(agent.EVENT_WALL_STICK_JUMPED)
