# Godot AI MCP verification

Every Godot-side operation used the same active session:
`testgame@e362124f09f388c2` (Godot `4.7.2-stable (official)`, plugin/server
`4.0.4`, protocol 2). MCP-observed results are labeled as such and kept separate
from the CLI/GUT gates.

## Preflight (before editing)

- `session_manage(list)` identified the active `testgame` project session;
  `editor_state` reported readiness `ready`, play state `stopped`, current scene
  `res://main.tscn`.
- `logs_read(source=editor, include_details=true)` returned 27 historical
  entries (Story 1.5 mid-edit reload diagnostics whose line numbers do not match
  current sources) and `logs_read(source=plugin)` showed the previous session's
  grapple-visual probes. Recorded as historical; current health established by
  the pre-change GUT baseline.
- `script_manage(read)` on `res://scripts/player_controller.gd` and
  `resource_manage` reads of the probe profiles inspected the affected surface
  before edits.

## Post-edit editor gate

- `filesystem_manage(scan)` settled with 114 registered global classes
  (`global_classes_registered_delta: 0` after the CLI import had registered the
  new types).
- `test_run(verbose=true)` (MCP-native discovery/execution): suite
  `grapple_targeting`, `total=4`, `passed=4`, `failed=0`, 31 assertions, no load
  errors. Details and the tool-scope harness boundary: `mcp-native-discovery.md`.
- Editor log after the final scan: no new entries past cursor 27 beyond the
  transient reload diagnostics generated while probing the MCP-native suite
  (documented in `mcp-native-discovery.md`).

## Live runtime gate (`res://main.tscn`)

`project_run(mode=main, autosave=false)` launched `res://main.tscn` repeatedly
(run tokens 21-25) with live game helper and `current_run_errors: []` on every
launch. Token 25 (complete smoke) observed, through `editor_manage(game_eval)`
and simulated input:

- **Targeting (AC 1/2/11/14):** the authoritative result advanced every physics
  step with `query_count = 1`, `source_physics_step == command_frame_step`. With
  the crosshair on `LowBlockA` (ordinary `StaticBody3D` geometry, no authored
  component) it reported `reason=none`, `valid=true`, hit
  `(-9.31591, 3.028045, -14.0)`, `range_fraction 0.561`, `max_grapple_length_m
  35`, profile ids `player.grapple.candidate` / `player.grapple.occlusion`.
- **Activation (AC 4/8):** a real mouse-button press edge (fire_grapple binding)
  consumed that same-step result: `is_grappling=true`,
  `grapple_point == ` the accepted hit exactly,
  `grapple_target == accepted_seed.get_target()` (weak target live),
  `has_valid_grapple()=true`, `activation_rejection=none`,
  `seed.target_local_hit_offset=(2.68409, 2.928045, 3.999998)`, step/frame
  identity matched the current motion step.
- **Pull playability (AC 15):** held grapple accelerated toward the anchor:
  speed `15.31 -> 16.47 m/s`, `pull_speed 15.26 -> 16.27 m/s`, applied
  acceleration decaying `33.78 -> 17.78 -> 8.0 m/s^2` (the preserved
  `48 -> 8` at `53.333333 m/s^3` formula) under the preserved `22 m/s` cap
  (`cap_reached=false` at 16.5 m/s).
- **Presentation agreement (AC 10):** `GrappleTargetMarker` reported
  `marker_visible == result.is_accepted()` and its presented position equaled
  the result hit position (`agree_visible=true`, `agree_position=true`).
- **Diagnostics agreement (AC 13):** `get_grapple_targeting_diagnostic_snapshot()`
  mirrored the authoritative result (same step, hit, `query_count=1`), and
  `get_grapple_telemetry()` reported `targeting_valid`, rejection id,
  `targeting_query_count=1`, `max_grapple_length_m=35` from that result.
- **Release (AC 15):** releasing the button cleared the grapple
  (`is_grappling=false`, `has_valid_grapple()=false`, `grapple_point` zeroed)
  with committed velocity preserved `(3.341615, -0.128238, -6.285498)`.
- **Logs:** `logs_read(source=game)` for run `r571217142-26` contained only the
  helper registration and one ordinary `Player took 6.6 physical damage` info
  line. No `GameLog` invariants, no errors - expected targeting rejection stayed
  out of error paths (AC 6).
- **Shutdown:** `project_manage(op=stop)` ended the run; final `editor_state` is
  `res://main.tscn`, readiness `ready`, play state `stopped`.

These are automated MCP observations of live runtime behavior, not human
visual/feel approval.
