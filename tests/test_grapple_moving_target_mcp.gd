@tool
extends McpTestSuite


## Godot AI MCP live-gate adapter for moving and stateful grapple targets
## (Story 1.8).
##
## This suite is intentionally small and editor-scope: it verifies the authored
## discontinuity tolerances and the typed moving-target schema inside the live
## editor VM. It is NOT GUT parity - the canonical regression gate remains the
## recursive GUT suites under `res://tests/player/**`, and the two result sets
## are reported separately.
##
## Harness boundary (established by probe during Story 1.6): gameplay classes are
## deliberately not `@tool` scripts, so tool scope receives placeholder instances
## and cannot execute their methods. This suite therefore checks authored data
## and script declarations, and the behavioral gate stays GUT plus the live game
## smoke, where gameplay code runs normally.
##
## Assertions target VALUES and DECLARATIONS, never prose in source text.
## Comment lines are excluded before every structural source check.

const DEFINITION_PATH := "res://game/player/abilities/grapple/definitions/grapple_definition.tres"
const ANCHOR_STATE_SCRIPT_PATH := "res://game/shared/contracts/grapple_anchor_state.gd"
const GRAPPLEABLE_SCRIPT_PATH := "res://game/shared/contracts/grappleable_3d.gd"
const END_REASON_SCRIPT_PATH := "res://game/player/abilities/grapple/grapple_end_reason.gd"
const SUBMISSION_SCRIPT_PATH := "res://game/player/motor/player_motor_submission.gd"

## Types a value-only anchor state may declare (Task 2.1): value types plus the
## one documented nested value-only `GrappleTargetResponse`. Nested enum
## declarations read as their bare name.
const ANCHOR_STATE_TYPE_NAMES: Array[String] = [
	"int",
	"float",
	"bool",
	"String",
	"StringName",
	"Vector3",
	"InvalidationReason",
	"GrappleAnchorState.InvalidationReason",
	"GrappleTargetResponse",
]


func suite_name() -> String:
	return "grapple_moving_target"


func test_authored_definition_carries_the_anchor_motion_tolerances() -> void:
	var definition = load(DEFINITION_PATH)
	assert_true(definition != null, "grapple_definition.tres must load")
	if definition == null:
		return
	# Values read from the loaded resource where the live editor's script cache
	# knows the property; a stale preloaded-GDScript cache (the harness warns
	# about this) reports null for newly added properties, so the authored
	# `.tres` value is read directly instead. Either path checks the authored
	# value, never prose (NFR6).
	var continuous = definition.get("anchor_continuous_motion_tolerance_mps")
	if continuous == null:
		continuous = _tres_float(DEFINITION_PATH, "anchor_continuous_motion_tolerance_mps")
	var severe = definition.get("anchor_severe_discontinuity_threshold_mps")
	if severe == null:
		severe = _tres_float(DEFINITION_PATH, "anchor_severe_discontinuity_threshold_mps")
	assert_true(_near(float(continuous), 50.0))
	assert_true(_near(float(severe), 250.0))
	# Tolerances only - never a range: they never duplicate the authored
	# acquisition range.
	assert_true(_near(float(definition.get("max_grapple_length_m")), 35.0))
	assert_true(
		float(severe) > float(continuous),
		"severe threshold stays above the continuous tolerance"
	)


func test_anchor_state_schema_stays_value_typed() -> void:
	var declared_types := _typed_declarations(ANCHOR_STATE_SCRIPT_PATH)
	assert_true(declared_types.size() > 0, "the anchor state must declare typed fields")
	for type_name in declared_types:
		assert_true(
			ANCHOR_STATE_TYPE_NAMES.has(type_name),
			"anchor-state field type %s must be a value type or the documented nested response (Task 2.1)"
				% type_name
		)
	assert_true(_has_declaration(ANCHOR_STATE_SCRIPT_PATH, "anchor_world_position"))
	assert_true(_has_declaration(ANCHOR_STATE_SCRIPT_PATH, "target_velocity"))
	assert_true(_has_declaration(ANCHOR_STATE_SCRIPT_PATH, "is_valid"))
	assert_true(_has_declaration(ANCHOR_STATE_SCRIPT_PATH, "invalidation_reason"))
	assert_true(_has_declaration(ANCHOR_STATE_SCRIPT_PATH, "scope_identity"))


func test_anchor_state_invalidation_set_is_closed() -> void:
	var reason_names := _enum_members(ANCHOR_STATE_SCRIPT_PATH, "InvalidationReason")
	assert_true(reason_names.size() == 4, "the invalidation set stays closed")
	assert_true(reason_names[0] == "NONE")
	assert_true(reason_names[1] == "TARGET_INVALIDATED")
	assert_true(reason_names[2] == "TARGET_DESTROYED")
	assert_true(reason_names[3] == "SCOPE_MISMATCH")


func test_end_reason_extension_is_append_only() -> void:
	var reason_names := _enum_members(END_REASON_SCRIPT_PATH, "Reason")
	assert_true(reason_names.size() == 9, "GrappleEndReason must stay a closed 9-value set")
	assert_true(reason_names[0] == "NONE")
	assert_true(reason_names[1] == "RELEASE")
	assert_true(reason_names[2] == "TARGET_INVALIDATED")
	assert_true(reason_names[3] == "OWNER_DEATH")
	assert_true(reason_names[4] == "STATE_CANCELLATION")
	assert_true(reason_names[5] == "GROUND_CONTACT")
	assert_true(reason_names[6] == "TARGET_DESTROYED")
	assert_true(reason_names[7] == "SCOPE_MISMATCH")
	assert_true(reason_names[8] == "ANCHOR_DISCONTINUITY")


func test_anchor_sampling_is_query_only_transform_math() -> void:
	var code := "\n".join(_code_lines(GRAPPLEABLE_SCRIPT_PATH))
	assert_true(
		code.contains("func sample_anchor_state("),
		"Grappleable3D owns the query-only sampling API (Task 2.2)"
	)
	assert_true(
		not code.contains("intersect_ray"),
		"anchor following is transform math, never a raycast (AC 3)"
	)
	assert_true(
		not code.contains("move_and_slide"),
		"the target can never move the player (AC 2)"
	)
	assert_true(
		not code.contains("PlayerMotor"),
		"the target can never touch player state (AC 2)"
	)
	assert_true(_has_declaration(GRAPPLEABLE_SCRIPT_PATH, "encounter_scope_identity"))
	assert_true(_has_declaration(GRAPPLEABLE_SCRIPT_PATH, "anchor_mode"))


func test_boundary_submission_carries_the_sampled_anchor_velocity() -> void:
	var kind_names := _enum_members(SUBMISSION_SCRIPT_PATH, "Kind")
	assert_true(kind_names.size() == 10, "PlayerMotorSubmission.Kind must stay a closed 10-value set")
	assert_true(kind_names.has("MAXIMUM_ANCHOR_DISTANCE"))
	assert_true(
		_has_declaration(SUBMISSION_SCRIPT_PATH, "anchor_velocity"),
		"the boundary payload carries the sampled anchor velocity (Task 4.1)"
	)
	assert_true(
		_has_declaration(SUBMISSION_SCRIPT_PATH, "carry_tolerance_mps"),
		"the boundary payload carries the discontinuity tolerance (AC 4)"
	)


## Members of `enum <name> { ... }` read from non-comment source. Used instead of
## `get_script_constant_map()`: the live editor serves a preloaded GDScript cache
## that ResourceLoader modes do not invalidate, so a constant map can report a
## stale enum. Behavioral verification of these values stays in the GUT contract
## suite.
func _enum_members(path: String, enum_name: String) -> Array[String]:
	var code := "\n".join(_code_lines(path))
	var regex := RegEx.new()
	regex.compile("enum\\s+" + enum_name + "\\s*\\{([^}]*)\\}")
	var found := regex.search(code)
	if found == null:
		return []
	var out: Array[String] = []
	for raw in found.get_string(1).split(","):
		var entry := raw.split("#")[0]
		entry = entry.split("=")[0].strip_edges()
		if not entry.is_empty():
			out.append(entry)
	return out


## Near-equality with an explicit tolerance, so no exact float comparison is
## used against serialized resource values (NFR6).
func _near(actual: float, expected: float, tolerance: float = 0.0001) -> bool:
	return absf(actual - expected) <= tolerance


## Non-comment source lines of a script, so prose in `#`/`##` comments can never
## satisfy or break a structural check.
func _code_lines(path: String) -> PackedStringArray:
	var out := PackedStringArray()
	var source := FileAccess.get_file_as_string(path)
	if source.is_empty():
		return out
	for line in source.split("\n"):
		if line.strip_edges().begins_with("#"):
			continue
		out.append(line)
	return out


## True when top-level (unindented) code declares `var <name>` - class fields
## only, so local variables can never satisfy a schema check.
func _has_declaration(path: String, name: String) -> bool:
	var regex := RegEx.new()
	regex.compile("^(@export[^\\n]*\\s)?var\\s+" + name + "\\b")
	for line in _code_lines(path):
		if regex.search(line) != null:
			return true
	return false


## Declared type annotations of every top-level `var name: Type` field.
func _typed_declarations(path: String) -> Array[String]:
	var out: Array[String] = []
	var regex := RegEx.new()
	regex.compile("^(@export[^\\n]*\\s)?var\\s+[A-Za-z0-9_]+\\s*:\\s*([A-Za-z0-9_.]+)")
	for line in _code_lines(path):
		var found := regex.search(line)
		if found != null:
			out.append(found.get_string(2))
	return out


## Float value authored in a `.tres` text (`name = value`), for the case where
## the live editor's preloaded-GDScript cache does not yet expose a newly added
## property on the loaded resource.
func _tres_float(path: String, name: String) -> float:
	var source := FileAccess.get_file_as_string(path)
	var regex := RegEx.new()
	regex.compile("^\\s*" + name + "\\s*=\\s*([-0-9.eE+]+)")
	for line in source.split("\n"):
		var found := regex.search(line)
		if found != null:
			return float(found.get_string(1))
	return NAN
