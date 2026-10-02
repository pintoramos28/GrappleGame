extends GutTest

const CASES := preload("res://tests/fixtures/wall_stick_reanchor_hardening_cases.gd")
var _saved_rate: int

func before_all() -> void:
	_saved_rate = Engine.physics_ticks_per_second

func after_each() -> void:
	Engine.physics_ticks_per_second = _saved_rate
	for action in [&"move_forward", &"move_back", &"fire_grapple", &"jump"]:
		Input.action_release(action)
	# Restore the engine's ACTUAL physics delta as well as its configured rate.
	# Later legacy manual-step suites can otherwise start in the last 120 Hz
	# callback window while assuming 60 Hz; do not modify those assertions.
	await get_tree().physics_frame
	await get_tree().process_frame

func after_all() -> void:
	print("[reanchor-hardening-teardown] saved_rate=", _saved_rate, " restored_rate=", Engine.physics_ticks_per_second, " actual_delta_seconds=", get_physics_process_delta_time())

func test_incoming_surface_response_tightens_and_relaxes_the_same_actual_sample() -> void:
	await _check(["response_tighten", "response_relax"])

func test_skipped_surface_samples_keep_gap_displacement_and_rate_limits() -> void:
	await _check(["gap_safe", "gap_oversized", "gap_speed", "gap_rotation", "gap_scale", "gap_tilt"])

func test_legacy_explicit_malformed_policy_fails_closed_without_clock_or_cache_mutation() -> void:
	await _check(["malformed_pull_nan", "malformed_pull_inf", "malformed_instability_nan", "malformed_instability_inf", "malformed_direction_nan", "malformed_direction_inf", "malformed_anchor_negative", "malformed_anchor_overflow", "malformed_hazard_negative", "malformed_hazard_overflow"])

func test_installed_binding_alias_is_rejected_in_prepare_and_mutated_commit() -> void:
	await _check(["alias", "mutated_alias"])

func test_null_binding_and_null_or_stale_preparations_fail_typed() -> void:
	await _check(["null_binding", "null_preparation", "stale_preparation"])

func test_detached_live_original_is_rejected_at_both_boundaries_with_reattach_control() -> void:
	await _check(["detached_original"])

func test_original_contract_is_fresh_before_prepare_and_commit_with_pure_cache_guards() -> void:
	for timing in ["before", "after"]:
		var scenarios: Array[String] = []
		for change in ["invalidated", "removed", "ineligible", "malformed", "scope", "identity"]:
			scenarios.append("original_" + timing + "_" + change)
		await _check(scenarios)

func test_installed_original_surface_geometry_is_checked_without_releasing_it() -> void:
	await _check(["original_surface_geometry", "original_surface_pose"])

func test_foreign_and_wrong_completed_step_motors_cannot_arm_baseline() -> void:
	await _check(["foreign_motor", "wrong_completed_step"])

func test_released_carry_cannot_copy_contact_even_after_unobserved_resize() -> void:
	await _check(["released_carry"])

func test_real_native_body_continuation_and_release_use_native_point_velocity_and_visible_visuals() -> void:
	await _check(["native_animatable", "native_character", "native_rigid"])

func test_visual_measurement_detects_hidden_detached_replaced_and_wrong_actual_meshes() -> void:
	await _check(["visual_marker", "visual_rope", "visual_detached", "visual_replaced", "visual_wrong_cylinder"])

func test_release_clock_and_curve_match_physics_steps_and_detect_a_forced_reset() -> void:
	await _check(["clock"])

func _check(scenarios: Array[String]) -> void:
	for rate in [60, 120]:
		for scenario in scenarios:
			var report: Dictionary = await CASES.run_case(get_tree(), scenario, rate)
			assert_true(report.passed, str(report))
			print("[reanchor-hardening] ", report)
