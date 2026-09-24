@tool
extends McpTestSuite


## Godot AI MCP live-gate adapter for grapple targeting (Story 1.6).
##
## This suite is intentionally small and editor-scope: it verifies the authored
## grapple assets and the typed targeting schema inside the live editor VM. It is
## NOT GUT parity - the canonical regression gate remains the recursive GUT
## suites under `res://tests/player/**`, and the two result sets are reported
## separately.
##
## Harness boundary (established by probe during Story 1.6): gameplay classes are
## deliberately not `@tool` scripts, so tool scope receives placeholder instances
## and cannot execute their methods. This suite therefore checks authored data and
## script constants only, and the behavioral gate stays GUT plus the live game
## smoke, where gameplay code runs normally.

const DEFINITION_PATH := "res://game/player/abilities/grapple/definitions/grapple_definition.tres"
const CANDIDATE_PATH := "res://game/shared/physics/grapple_candidate.tres"
const OCCLUSION_PATH := "res://game/shared/physics/grapple_occlusion.tres"
const REJECTION_SCRIPT_PATH := "res://game/shared/contracts/grapple_rejection.gd"
const RESULT_SCRIPT_PATH := "res://game/shared/contracts/grapple_targeting_result.gd"


func suite_name() -> String:
	return "grapple_targeting"


func test_authored_definition_carries_the_single_authoritative_range() -> void:
	var text := FileAccess.get_file_as_string(DEFINITION_PATH)
	assert_true(text.contains("definition_id = &\"player.grapple.default\""))
	assert_true(text.contains("max_grapple_length_m = 35.0"), "one authored acquisition range")
	assert_true(text.contains("acquisition_tolerance_m = 0.005"))
	assert_true(text.contains("pull_initial_acceleration_mps2 = 48.0"))
	assert_true(text.contains("pull_min_acceleration_mps2 = 8.0"))
	assert_true(text.contains("pull_acceleration_jerk_mps3 = 53.333333"))
	assert_true(text.contains("maximum_speed_mps = 22.0"))
	assert_true(text.contains("target_query_profile = ExtResource("))

	var definition = load(DEFINITION_PATH)
	assert_true(definition != null, "grapple_definition.tres must load")
	assert_true(definition.get_script() != null, "definition must carry its typed script")


func test_grapple_profiles_are_named_mask_ray_profiles_without_shapes() -> void:
	var candidate_text := FileAccess.get_file_as_string(CANDIDATE_PATH)
	assert_true(candidate_text.contains("query_kind = 1"), "candidate profile must be a RAY profile")
	assert_true(candidate_text.contains("profile_id = &\"player.grapple.candidate\""))
	assert_true(
		candidate_text.contains("collision_mask_names = PackedStringArray(\"world_geometry\")"),
		"candidate candidacy comes from named layers only"
	)
	assert_false(candidate_text.contains("shape ="), "ray profiles are shape-exempt")

	var occlusion_text := FileAccess.get_file_as_string(OCCLUSION_PATH)
	assert_true(occlusion_text.contains("query_kind = 1"), "occlusion profile must be a RAY profile")
	assert_true(occlusion_text.contains("profile_id = &\"player.grapple.occlusion\""))
	assert_true(
		occlusion_text.contains(
			"collision_mask_names = PackedStringArray(\"world_geometry\", \"enemy_body\")"
		),
		"occlusion marks named blocking-but-unacquirable layers"
	)
	assert_false(occlusion_text.contains("shape ="), "ray profiles are shape-exempt")

	assert_true(load(CANDIDATE_PATH) != null)
	assert_true(load(OCCLUSION_PATH) != null)


func test_rejection_value_set_is_closed_and_expected_gameplay_is_not_an_error() -> void:
	var rejection_script = load(REJECTION_SCRIPT_PATH)
	assert_true(rejection_script != null, "grapple_rejection.gd must load")
	var constants: Dictionary = rejection_script.get_script_constant_map()
	assert_true(constants.has("Reason"), "GrappleRejection must publish its Reason enum")
	var reasons: Dictionary = constants["Reason"]
	assert_eq(reasons.size(), 10, "GrappleRejection must stay a closed 10-value set")
	assert_eq(reasons.keys()[0], "NONE")
	assert_eq(reasons.keys()[5], "POLICY_REJECTED")
	assert_eq(reasons.keys()[7], "MALFORMED_TARGET_DATA")
	assert_eq(reasons.keys()[8], "MISSING_RESULT")
	assert_eq(reasons.keys()[9], "STALE_RESULT")


func test_targeting_result_schema_is_single_query_bounded() -> void:
	# Tool scope cannot reload typed gameplay scripts (their typed dependencies
	# are non-tool classes), so the schema bound is verified from source here and
	# behaviorally in the GUT contract suite.
	var text := FileAccess.get_file_as_string(RESULT_SCRIPT_PATH)
	assert_true(text.contains("extends RefCounted"), "result records stay value-only")
	assert_true(
		text.contains("const MAX_QUERY_COUNT := 1"),
		"exactly one authoritative query per evaluated physics step"
	)
	assert_true(text.contains("func is_value_only() -> bool:"))
