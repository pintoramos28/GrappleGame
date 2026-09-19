# Godot AI MCP verification

All Godot-side validation used the same active session:
`testgame@e362124f09f388c2` (Godot `4.7.2-stable (official)`, plugin/server
`4.0.4`, protocol 2).

## Operations and results

- `session_manage(list)` identified one active `testgame` project session;
  `editor_state` confirmed the editor was ready before implementation and is
  ready/stopped afterward.
- The preflight inspected `res://scenes/player.tscn`, `res://main.tscn`, the
  player hierarchy, `/Player/PlayerMotor`, movement HSM/state nodes, scripts,
  Jolt, tick rate, interpolation, and layer names.
- Post-edit `filesystem_manage(scan)` settled successfully with 114 global
  classes. `script_manage(find_symbols)` succeeded for the provider,
  `ContactDiagnosticSnapshot`, motor, controller, and affected state scripts.
- `scene_open(main.tscn, force_reload=true)` reloaded the retained main scene.
  Runtime tree inspection found the main player, motor, movement/attack HSMs,
  all locomotion states, and the dynamic grapple visual/cursor.
- `resource_manage(load)` succeeded for both scene-wired probe resources and
  returned the expected profile IDs, named `world_geometry` mask, sphere
  geometry, offsets, sweep caps, and 16/8/32 limits.
- `project_manage(settings_get)` confirmed main scene `res://main.tscn`, Jolt,
  60 Hz, interpolation `true`, and the five named layers.
- The final editor-log cursor was 27. A `logs_read(source=editor,
  since_cursor=27)` read returned zero new editor lines after the clean scan.
  Earlier in the edit cycle the buffer contained transient reload diagnostics
  from an intermediate provider version; current symbols, GUT, and subsequent
  MCP launches were clean. Those historical rows are not silently presented
  as current errors.

## MCP-native test gate

`test_run(verbose=false)` returned `total=0`, `load_errors=[]`, and
`No test suites found in res://tests/`. This project uses recursive GUT
`GutTest` suites under `res://tests/player`; the MCP runner's direct
`McpTestSuite` discovery did not execute or replace those suites.

## Live runtime gate

The same session launched `res://main.tscn` through `project_run(mode=main)`
with live helper and no current-run errors. Relevant MCP run tokens were:

- Token 3: matching contact/motor frame at step 8687, success status,
  committed evidence, grounded true, wall false, scan 0/report 2, total
  query count 11, no rejections/overflow; diagnostics reported provider
  `ready`, ground/wall profiles, ground queries 3, wall queries 8, and sweep
  distances 0.30/0.80.
- Token 3 W smoke: after `move_forward`, the player moved from z 0 to about
  -15.46, remained grounded, and retained one commit.
- Token 9: grapple-held contact near `ThinTowerB` produced `WallStickState`,
  wall contact, a valid wall normal, zero velocity, and a valid grapple
  target. A wall-stick jump then reached `AirborneState` with grapple and
  stick cleared.
- Token 10: the same main scene produced `WallRunState` with wall contact at
  step 83, then a wall jump reached `AirborneState` with positive upward and
  away velocity; a later sample landed in `GroundedState`.

Game logs contained only the helper registration and normal player damage
info. The run was stopped with `project_manage(op=stop)`, and the final
editor state is `res://main.tscn`, ready, stopped. The runtime observations
are automated MCP observations, not human feel/visual approval.
