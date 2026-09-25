# MCP-native discovery (Task 9.2)

MCP `test_run` discovers only direct `res://tests/test_*.gd` `McpTestSuite`
files. It does not recurse and never executes the GUT `GutTest` suites.
**There is no parity claim between the two result sets** - they are reported
separately throughout this evidence set.

Final MCP-native run (session `testgame@e362124f09f388c2`): 15/15 passing,
0 failures, `new_errors_since_last_call: 0`.

| Suite | Tests | Purpose |
|---|---|---|
| `grapple_boundary` | 5 | Story 1.7 authored-data + schema checks (end-reason test updated to the append-only 9-value set) |
| `grapple_moving_target` | 6 | Story 1.8 authored tolerances, `GrappleAnchorState` value-only schema, closed invalidation set, append-only end reasons, query-only sampling declarations, boundary payload schema |
| `grapple_targeting` | 4 | Story 1.6 targeting schema (untouched) |

Harness boundary (as in Story 1.6/1.7): gameplay classes are deliberately not
`@tool` scripts, so tool scope receives placeholder instances and cannot
execute their methods. The adapters therefore check authored values and
declarations; behavioral coverage stays in GUT plus the live game smoke.

The `grapple_moving_target` adapter reads newly added definition properties
from the authored `.tres` text when the live editor's preloaded-GDScript cache
does not yet expose them (the harness's own `cache_warning` documents this
staleness); the GUT suite validates the same values through loaded resources
in a fresh process. See `limitations.md`.
