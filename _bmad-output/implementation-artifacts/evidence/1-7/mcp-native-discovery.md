# MCP-native discovery (dual-harness record)

The MCP runner (`test_run`) discovers only direct `res://tests/test_*.gd` files
extending `McpTestSuite`; it never recurses into `res://tests/player/**` and
never executes the GUT `GutTest` suites. **There is no parity claim between the
two harnesses.** GUT remains the canonical comprehensive regression gate
(`recursive-gut.log`); the MCP-native suites are a small editor-scope live gate.

## Story 1.7 adapter

`res://tests/test_grapple_boundary_mcp.gd` (suite `grapple_boundary`, 4 tests)
checks authored data and script schemas only, because gameplay classes are
deliberately not `@tool` scripts and tool scope receives placeholder instances
(harness boundary established by probe in Story 1.6):

1. `test_authored_definition_is_the_one_range_and_pull_authority` - the authored
   `grapple_definition.tres` values (35 m range, 48/8/53.333333 pull profile,
   22 m/s cap) load and match.
2. `test_end_reason_set_is_closed_and_schema_locked` - `GrappleEndReason.Reason`
   is a closed 6-value set in the locked order via `get_script_constant_map()`.
3. `test_attachment_and_snapshot_schema_stays_value_typed` - the attachment and
   snapshot scripts keep their documented schema (resolved maximum length,
   AC 4 documentation, `is_value_only()`, boundary/radial/tangential fields,
   no node references).
4. `test_boundary_constraint_is_a_typed_motor_submission` - the
   `MAXIMUM_ANCHOR_DISTANCE` kind resolves in `CONSTRAINTS_AND_REDIRECTIONS`,
   `GrappleController.submit_motor_influences()` submits
   `submit_maximum_anchor_distance()` under one stable source id, and the
   controller never writes velocity or moves the body.

## Result (live editor VM, session `testgame@e362124f09f388c2`)

| Suite | Tests | Passed | Failed |
|---|---|---|---|
| `grapple_boundary` (Story 1.7) | 4 | 4 | 0 |
| `grapple_targeting` (Story 1.6) | 4 | 4 | 0 |

Two known tool-scope quirks encountered and worked around (both documented, no
production impact): `McpTestSuite` has no `assert_almost_eq` (plain tolerance
asserts used), and a failed snippet compile parks the running game in a debugger
break (`project_manage(op="stop")` + relaunch clears it).

Behavioral coverage of the same contracts lives in the GUT suites
(`focused-gut.md`, `recursive-gut.md`); the live runtime smoke is recorded in
`traversal-smoke.md`.
