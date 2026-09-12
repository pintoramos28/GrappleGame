@C:\Users\pinto\.codex\RTK.md

# Godot AI MCP requirement

For every Godot story, the Godot AI MCP server is mandatory during both implementation and validation. Do not silently substitute headless CLI commands, filesystem inspection, or generic UI automation for Godot AI MCP.

## Required story workflow

1. Before editing, run a read-only Godot AI MCP preflight:
   - list sessions and identify the active project session;
   - inspect editor readiness, current scene, play state, and editor diagnostics;
   - inspect the affected scene, nodes, scripts, or resources through the appropriate Godot AI MCP read tools.
2. During implementation, use Godot AI MCP for Godot-side operations whenever an applicable tool exists, including scene/resource inspection or mutation, script reload/scan, editor state, and runtime/editor interaction. Use repository editing tools for source changes when required by the agent environment, but still verify the loaded Godot state through MCP.
3. After editing, use Godot AI MCP for meaningful validation of the story:
   - rescan/reload affected resources;
   - run the relevant test suite through the MCP test tools when the project test setup supports it;
   - inspect editor/game logs and, for gameplay stories, perform an MCP-backed runtime or visual smoke check when the server supports one;
   - re-check the affected scene/resources and confirm the editor is ready.
4. Record the MCP session ID, the meaningful MCP operations performed, their results, and any diagnostics in the story evidence/Dev Agent Record. Distinguish MCP-observed results from CLI-only results and never claim visual or runtime verification that was not observed.

## Availability rule

If the Godot AI MCP server or an active session is unavailable, stop before implementing the Godot story and report the connection blocker. Do not proceed with a CLI-only implementation unless the user explicitly authorizes that exception; if authorized, record the exception and the missing MCP checks in the story artifact.

The Godot AI MCP requirement supplements - not replaces - the repository's testing, preservation, and `rtk` command requirements.

## Dual test-harness rule

Use both test paths when the story changes gameplay, scenes, resources, editor integration, or runtime behavior:

- Keep GUT through the pinned Godot CLI as the canonical comprehensive regression gate. Run the existing recursive suites, including `res://tests/player/**`, for deterministic unit/integration coverage and CI-compatible results.
- Use Godot AI MCP as the complementary live-session gate. Inspect the affected editor scene/resources, launch the relevant scene through MCP, and use runtime node inspection, `game_eval`, simulated input, and MCP logs for story-relevant smoke/integration checks.
- Do not treat an MCP `test_run` result as coverage of the GUT suite. The current MCP runner only discovers direct `res://tests/test_*.gd` files whose scripts extend `McpTestSuite`; it does not recurse or execute GUT `GutTest` suites.
- If MCP-native tests are useful, add a small top-level adapter such as `res://tests/test_<feature>_mcp.gd` extending `McpTestSuite`. Share framework-neutral fixtures/cases with GUT where practical, but keep the two result sets identifiable and do not claim parity unless the same cases are actually exercised.
- Record GUT/CLI results and MCP results separately in the story evidence. A pure unit change may rely primarily on GUT; an editor/runtime/story acceptance change requires both gates unless an explicit exception is authorized and documented.
