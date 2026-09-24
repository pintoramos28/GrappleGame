# MCP-native test discovery (separate result set)

The Godot AI MCP runner discovers only direct `res://tests/test_*.gd` scripts
extending `McpTestSuite`; it never recurses into or replaces the GUT suites.
Story 1.6 added the optional adapter `res://tests/test_grapple_targeting_mcp.gd`.

## Final MCP-native result (reported separately from GUT)

`test_run(verbose=true)`: suite `grapple_targeting`, `total=4`, `passed=4`,
`failed=0`, 31 assertions, `load_errors=[]`:

1. `test_authored_definition_carries_the_single_authoritative_range` (10)
2. `test_grapple_profiles_are_named_mask_ray_profiles_without_shapes` (10)
3. `test_rejection_value_set_is_closed_and_expected_gameplay_is_not_an_error` (8)
4. `test_targeting_result_schema_is_single_query_bounded` (3)

This is NOT GUT parity and not coverage of the 92-test recursive GUT run; it is
live-editor verification of authored assets and schema constants.

## Harness boundary established by probe (recorded honestly)

Three temporary probes (`tests/test_probe_*.gd`, since deleted) isolated what
tool scope can and cannot do:

- `@tool extends McpTestSuite` with engine-only assertions loads and passes.
- Referencing gameplay `class_name` types (`GrappleTargetResolver`,
  `GrappleRejection`, `GrappleDefinition`, ...) from a `@tool` suite fails to
  compile in tool scope (`cannot instantiate - abstract or broken;
  reload=Parse error, base=none`): gameplay classes are deliberately not
  `@tool` (architecture), so the editor hands out placeholder instances -
  "Attempt to call a method on a placeholder instance. Check if the script is in
  tool mode."
- Loading typed gameplay scripts through the tool-scope reload path fails for
  the same reason (their typed dependencies are non-tool classes).

Consequence: the adapter verifies authored data (`.tres` text/values, named
masks, no shapes) and standalone script constants (`GrappleRejection.Reason`,
`MAX_QUERY_COUNT`) only; all behavioral verification lives in the GUT suites and
the live game smoke (where gameplay code runs normally). The adapter documents
this boundary in its header. The runner also prints its standard stale-preload
cache warning (see Story 1-4 evidence for the same documented harness caveat).
