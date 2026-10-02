extends LimboState


func _update(delta: float) -> void:
	var reference_velocity: Vector3 = agent.get_motion_start_velocity()
	agent.submit_state_policy(agent.LOCOMOTION_WALL_STICK)
	if agent.is_dead:
		agent.submit_base_passthrough(agent.LOCOMOTION_WALL_STICK)
		agent.dispatch_locomotion_event(agent.EVENT_DIED)
		return
	var command_frame: PlayerCommandFrame = agent.get_player_command_frame()
	var supported: bool = agent.sample_wall_stick_support(delta) and agent.has_supported_wall_contact()
	# A supported fresh jump wins simultaneous forward/grapple release and
	# outward cancellation; it never inherits platform or player tangent speed.
	if command_frame != null and supported and command_frame.was_pressed(PlayerCommandFrame.Action.JUMP):
		if command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE) and (not agent.sample_grapple_anchor(delta) or not agent.has_valid_grapple()):
			agent.terminate_grapple(GrappleEndReason.Reason.TARGET_INVALIDATED)
			agent.submit_wall_stick_release(reference_velocity)
			agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)
			return
		_dispatch_wall_stick_jump(reference_velocity)
		return

	if command_frame == null or not command_frame.is_held(PlayerCommandFrame.Action.GRAPPLE):
		if supported and agent.has_outward_wall_stick_motion(reference_velocity):
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

	# Physical support lifetime and local-face validation supplement the shared
	# frame. World-point SWITCHED alone is not a switch of the attached shape.
	if not supported:
		agent.terminate_grapple(GrappleEndReason.Reason.STATE_CANCELLATION)
		agent.submit_wall_stick_release(reference_velocity)
		agent.dispatch_locomotion_event(agent.EVENT_GRAPPLE_RELEASED)
		return

	if not command_frame.move_forward_held:
		agent.release_wall_stick_to_grapple(reference_velocity)
		return

	# Ignore native carry/recovery when detecting new outward player motion.
	if agent.has_outward_wall_stick_motion(reference_velocity):
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
