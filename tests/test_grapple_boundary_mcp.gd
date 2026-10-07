@tool
extends McpTestSuite


## Godot AI MCP live-gate adapter for the grapple maximum boundary (Story 1.7).
##
## This suite is intentionally small and editor-scope: it verifies the authored
## grapple data and the typed boundary schema inside the live editor VM. It is
## NOT GUT parity - the canonical regression gate remains the recursive GUT
## suites under `res://tests/player/**`, and the two result sets are reported
## separately.
##
## Harness boundary (established by probe during Story 1.6): gameplay classes are
## deliberately not `@tool` scripts, so tool scope receives placeholder instances
## and cannot execute their methods. This suite therefore checks authored data
## and script constants, and the behavioral gate stays GUT plus the live game
## smoke, where gameplay code runs normally.
##
## Assertions target VALUES and DECLARATIONS, never prose in source text. A
## `contains()` check on raw source passes for commented-out code and breaks on a
## harmless `.tres` resave or a reworded comment, so neither failure mode
## corresponds to the contract being guarded. Comment lines are excluded before
## every structural source check.

const DEFINITION_PATH := "res://game/player/abilities/grapple/definitions/grapple_definition.tres"
const END_REASON_SCRIPT_PATH := "res://game/player/abilities/grapple/grapple_end_reason.gd"
const ATTACHMENT_SCRIPT_PATH := "res://game/player/abilities/grapple/grapple_attachment.gd"
const SNAPSHOT_SCRIPT_PATH := "res://game/player/abilities/grapple/grapple_attachment_diagnostic_snapshot.gd"
const CONTROLLER_SCRIPT_PATH := "res://game/player/abilities/grapple/grapple_controller.gd"
const SUBMISSION_SCRIPT_PATH := "res://game/player/motor/player_motor_submission.gd"

## Types a value-only record may declare (Task 5.2). Enums read as their
## underlying type in the declaration text, so the one enum used here is listed
## explicitly.
const VALUE_TYPE_NAMES: Array[String] = [
	"int",
	"float",
	"bool",
	"String",
	"StringName",
	"Vector3",
	"GrappleEndReason.Reason",
]


func suite_name() -> String:
	return "grapple_boundary"


func test_authored_definition_is_the_one_range_and_pull_authority() -> void:
	var definition = load(DEFINITION_PATH)
	assert_true(definition != null, "grapple_definition.tres must load")
	if definition == null:
		return
	# Values read from the loaded resource. A resave with different float
	# serialization cannot pass or fail these.
	assert_true(definition.get("definition_id") == &"player.grapple.default")
	assert_true(_near(float(definition.get("max_grapple_length_m")), 35.0))
	assert_true(_near(float(definition.get("acquisition_tolerance_m")), 0.005, 0.000001))
	assert_true(_near(float(definition.get("pull_initial_acceleration_mps2")), 60.0))
	assert_true(_near(float(definition.get("pull_min_acceleration_mps2")), 8.0))
	assert_true(_near(float(definition.get("pull_acceleration_jerk_mps3")), 53.333333, 0.00001))
	assert_true(_near(float(definition.get("maximum_speed_mps")), 22.0))


func test_end_reason_set_is_closed_and_schema_locked() -> void:
	var end_reason_script = load(END_REASON_SCRIPT_PATH)
	assert_true(end_reason_script != null, "grapple_end_reason.gd must load")
	if end_reason_script == null:
		return
	# Schema is read from the file's `enum` declaration rather than
	# `get_script_constant_map()`. The live editor serves a preloaded GDScript
	# cache that ResourceLoader modes do not invalidate, so a constant map can
	# report a stale enum and pass or fail for the wrong reason.
	var reason_names := _enum_members(END_REASON_SCRIPT_PATH, "Reason")
	# Story 1.8 Task 5.1 appended TARGET_DESTROYED / SCOPE_MISMATCH /
	# ANCHOR_DISCONTINUITY after the locked Story 1.7 prefix (append-only).
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


func test_attachment_and_snapshot_schema_stays_value_typed() -> void:
	# The occurrence record resolves its maximum from the definition and never
	# derives it from the attachment distance (AC 4).
	assert_true(
		_has_declaration(ATTACHMENT_SCRIPT_PATH, "resolved_maximum_length_m"),
		"the attachment carries a resolved maximum length"
	)
	assert_true(
		_not_has_declaration(ATTACHMENT_SCRIPT_PATH, "rope_length_m"),
		"no rope length is ever stored (AC 4)"
	)

	# Every snapshot field is a value type (Task 5.2). This is a declaration
	# scan of non-comment code, so the word "Node" in a comment cannot trip it
	# and a real object-typed field cannot slip through.
	var declared_types := _typed_declarations(SNAPSHOT_SCRIPT_PATH)
	assert_true(declared_types.size() > 0, "the snapshot must declare typed fields")
	for type_name in declared_types:
		assert_true(
			VALUE_TYPE_NAMES.has(type_name),
			"snapshot field type %s must be a value type (Task 5.2)" % type_name
		)
	assert_true(_has_declaration(SNAPSHOT_SCRIPT_PATH, "boundary_correction_applied"))
	assert_true(_has_declaration(SNAPSHOT_SCRIPT_PATH, "resolved_radial_velocity_mps"))
	assert_true(_has_declaration(SNAPSHOT_SCRIPT_PATH, "resolved_tangential_velocity_mps"))
	assert_true(_has_declaration(SNAPSHOT_SCRIPT_PATH, "distance_at_resolution_m"))
	assert_true(_has_declaration(SNAPSHOT_SCRIPT_PATH, "committed_velocity_mps"))


func test_boundary_constraint_is_a_typed_motor_submission() -> void:
	var submission_script = load(SUBMISSION_SCRIPT_PATH)
	assert_true(submission_script != null, "player_motor_submission.gd must load")
	if submission_script == null:
		return
	var kind_names := _enum_members(SUBMISSION_SCRIPT_PATH, "Kind")
	assert_true(kind_names.size() == 10, "PlayerMotorSubmission.Kind must stay a closed 10-value set")
	assert_true(
		kind_names.has("MAXIMUM_ANCHOR_DISTANCE"),
		"the boundary is a typed motor submission kind (schema: %s)" % [str(kind_names)]
	)
	assert_true(kind_names.has("WALL_RUN_CONSTRAINT"))
	assert_true(kind_names.has("WALL_STICK_HOLD"))
	assert_true(kind_names.has("SUSTAINED_ACCELERATION"))
	assert_true(kind_names.has("SPEED_CAP"))
	# The boundary resolves in the constraint phase, not after commit.
	assert_true(
		"\n".join(_code_lines(SUBMISSION_SCRIPT_PATH)).contains(
			"MotorPhase.Phase.CONSTRAINTS_AND_REDIRECTIONS"
		),
		"the boundary resolves in CONSTRAINTS_AND_REDIRECTIONS"
	)


func test_controller_submits_influences_and_never_moves_the_body() -> void:
	var controller_script = load(CONTROLLER_SCRIPT_PATH)
	assert_true(controller_script != null, "grapple_controller.gd must load")
	if controller_script == null:
		return
	# Stable dotted source ids read from their `const` declarations, not from
	# their spelling anywhere in the file.
	assert_true(
		_constant_string(CONTROLLER_SCRIPT_PATH, "SOURCE_MAXIMUM_DISTANCE") ==
			"player.grapple.maximum_distance",
		"one stable source id for the boundary submission"
	)
	assert_true(
		_constant_string(CONTROLLER_SCRIPT_PATH, "SOURCE_PULL") == "player.grapple.pull"
	)
	assert_true(
		_constant_string(CONTROLLER_SCRIPT_PATH, "SOURCE_SPEED_CAP") ==
			"player.grapple.speed_cap"
	)

	# Purity (AC 2): the controller is an influence submitter and never a
	# movement writer. Checked over non-comment code only.
	var code := "\n".join(_code_lines(CONTROLLER_SCRIPT_PATH))
	assert_true(
		not code.contains("move_and_slide("),
		"the grapple controller submits influences and never moves the body"
	)
	assert_true(
		not code.contains(".velocity ="),
		"the grapple controller never writes body velocity"
	)


## Members of `enum <name> { ... }` read from non-comment source. Used instead of
## `get_script_constant_map()`: the live editor serves a preloaded GDScript cache
## that ResourceLoader modes do not invalidate, so a constant map can report a
## stale enum (observed while wiring this suite: the `Kind` map still lacked
## `MAXIMUM_ANCHOR_DISTANCE` after it existed in the file). Behavioral
## verification of these values stays in the GUT contract suite.
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


## Value of a `const <name> = "..."` or `&"..."` declaration in non-comment code.
func _constant_string(path: String, name: String) -> String:
	var regex := RegEx.new()
	regex.compile("^\\s*const\\s+" + name + "\\b[^=]*=\\s*&?\"([^\"]*)\"")
	for line in _code_lines(path):
		var found := regex.search(line)
		if found != null:
			return found.get_string(1)
	return ""


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


## True when non-comment code declares `var <name>` (with or without a type).
func _has_declaration(path: String, name: String) -> bool:
	return _match_declaration(path, name) != ""


func _not_has_declaration(path: String, name: String) -> bool:
	return _match_declaration(path, name) == ""


func _match_declaration(path: String, name: String) -> String:
	var regex := RegEx.new()
	regex.compile("^\\s*var\\s+" + name + "\\b")
	for line in _code_lines(path):
		if regex.search(line) != null:
			return line
	return ""


## Declared type annotations of every `var name: Type` in non-comment code.
func _typed_declarations(path: String) -> Array[String]:
	var out: Array[String] = []
	var regex := RegEx.new()
	regex.compile("^\\s*var\\s+[A-Za-z0-9_]+\\s*:\\s*([A-Za-z0-9_.]+)")
	for line in _code_lines(path):
		var found := regex.search(line)
		if found != null:
			out.append(found.get_string(1))
	return out
