# Godot AI MCP verification

Every Godot-side operation used the same active session:

`testgame@e362124f09f388c2` (Godot `4.7.2-stable (official)`, plugin/server
4.0.4, protocol 2, project `testgame`).

## Preflight (before editing)

- `session_manage(list)` -> one active session, `readiness: ready`,
  `play_state: stopped`, current scene `res://scenes/player.tscn`.
- `editor_state` -> `ready` / `stopped`, `game_status.status = stopped`.
- `resource_manage(load)` of
  `res://game/player/abilities/grapple/definitions/grapple_definition.tres` ->
  `definition_id = player.grapple.default`, `max_grapple_length_m = 35`,
  `acquisition_tolerance_m = 0.005`, `pull_initial_acceleration_mps2 = 48`,
  `pull_min_acceleration_mps2 = 8`, `pull_acceleration_jerk_mps3 = 53.333333`,
  `maximum_speed_mps = 22` - matches the Task 1 source of truth.
- `logs_read(source="editor")` triage: the ring buffer still holds the stale
  mid-edit parse-error history documented in the story's authoring evidence
  (`player_contact_provider.gd` / `test_player_contact_contract.gd`,
  `test_grapple_targeting_mcp.gd` load churn) plus the pre-existing `seed`
  shadowing warnings in Story 1.6 files. Not current defects; not Story 1.7
  regressions.

## Implementation-time operations

- `filesystem_manage(op="scan")` after each write batch -> `scan_completed:
  true`, `global_classes_registered_delta: 0` on re-scan (the four new global
  classes registered on the first post-write scan).
- `test_run` (MCP-native) after the adapter landed -> 8/8 passing
  (`mcp-native-discovery.md`).
- `editor_state` / `logs_read` after each rescan: readiness returned to `ready`.

## Post-edit validation

- Rescan + reload: `filesystem_manage(op="scan")` -> settled; no new parse
  errors. Editor-log entries produced by Story 1.7 code: none. The only
  `seed`-shadowing warnings are the pre-existing Story 1.6 identifiers
  (`grapple_targeting_result.gd`, `grapple_target_resolver.gd`,
  `player_controller.gd:954`); the Story 1.7 files were written with
  `target_seed` naming specifically to add no new shadowing.
- Editor diagnostics: clean for all touched files (the pre-existing
  `player_contact_provider.gd:575` ternary warning is unchanged and out of
  scope).
- Runtime smoke of `res://main.tscn`: `project_run(mode="main")` -> `status:
  live`, `helper_live: true`, `recent_errors: []` (`traversal-smoke.md`).
- Final `project_manage(op="stop")` -> `stopped: true`, `readiness_after:
  ready`; the final game run's log contains only the game-helper registration
  line (zero errors).

MCP-observed results are reported separately from CLI results throughout this
evidence set; no visual or runtime claim is made that was not observed through
this session.
