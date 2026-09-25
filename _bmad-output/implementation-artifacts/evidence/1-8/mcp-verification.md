# Godot AI MCP verification (Task 9.2)

Every Godot-side operation used the same active session:

`testgame@e362124f09f388c2` (Godot `4.7.2-stable (official)`, plugin/server
4.0.4, protocol 2, project `testgame`). MCP-observed results are reported
separately from CLI results throughout this evidence set; no visual or runtime
claim is made that was not observed through this session.

## Preflight (before editing)

- `session_manage(list)` -> one active session, `readiness: ready`,
  `play_state: stopped`, current scene `res://scenes/player.tscn`.
- `editor_state` -> `ready` / `stopped`, `game_status.status = stopped`.
- `logs_read(source="editor")` triage: the ring buffer holds the stale history
  documented in the story's authoring evidence (`player_contact_provider.gd`
  "Expected statement, found Indent" cascade and
  `test_player_contact_contract.gd` follow-on errors, plus
  `test_grapple_targeting_mcp.gd` placeholder-instance load churn). Fresh
  `script_manage(find_symbols)` of `player_contact_provider.gd` parses cleanly
  (43 functions) and every Story 1.8 file parses cleanly - these entries are
  stale mid-edit/ring-buffer history, not current defects (same conclusion as
  Story 1.7).
- `script_manage(find_symbols)` of the affected surface confirmed the story's
  Current-State Update Map before editing: `grappleable_3d.gd` (7 exports, 5
  functions), `grapple_attachment.gd` (12 functions), `grapple_controller.gd`
  (11 functions, signals `attachment_committed`/`attachment_ended`).

## Implementation-time operations

- `filesystem_manage(op="scan")` after every write batch -> `scan_completed:
  true`, `global_classes_registered_delta: 0` on re-scan (the new
  `GrappleAnchorState` class registered on the first post-write scan).
- `filesystem_manage(op="reimport")` of the touched paths -> script/tres
  entries refreshed; the harness notes these are not imported resources and
  that this is not parse evidence - parse evidence came from
  `script_manage(find_symbols)` per file.
- MCP-native `test_run` after the adapters landed -> 15/15 passing across
  `grapple_boundary`, `grapple_moving_target`, `grapple_targeting`
  (`mcp-native-discovery.md`).
- `editor_state` / `logs_read` after rescans: readiness stayed `ready`.

## Post-edit validation

- Rescan + reload: `filesystem_manage(op="scan")` -> settled; `script_manage
  (find_symbols)` of `grapple_anchor_state.gd` (7 functions),
  `grappleable_3d.gd` (11 functions, 8 exports), `grapple_controller.gd`
  (21 functions), `player_motor.gd` (57 functions), and
  `test_grapple_moving_target_mcp.gd` (extends `McpTestSuite`) all parse with
  no diagnostics.
- MCP-native `test_run` (final): 15/15, `new_errors_since_last_call: 0`.
- Runtime smoke of `res://main.tscn`: `project_run(mode="main")` -> `status:
  live`, `helper_live: true`, `current_run_errors: []`
  (`traversal-smoke.md`); two live screenshots captured (`attached-rope`,
  `moving-target-attached`).
- Final `project_manage(op="stop")` -> `stopped: true`, `readiness: ready`,
  `play_state: stopped`; the final game run's log contains only the
  game-helper registration line (zero errors).

## Recorded harness limitations

- The live editor's preloaded-GDScript cache can be stale after source edits
  (the `test_run` `cache_warning`); this surfaced once as a missing newly
  added `GrappleDefinition` property on the loaded resource inside tool scope.
  The adapter reads the authored `.tres` value in that case and the GUT suite
  validates the same values in a fresh process. Two earlier smoke evals raised
  harness-side errors (a wrong node path and an auto-named child lookup) which
  tripped the editor debugger's break state; the game was relaunched cleanly
  both times and the final run's logs are clean. See `limitations.md`.
