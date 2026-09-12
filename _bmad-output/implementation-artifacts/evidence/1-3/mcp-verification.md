# Story 1.3 Godot AI MCP Verification

Date: 2026-09-11

## MCP session and editor preflight

- Session: `testgame@9865908531831e60`
- Project: `C:/Users/pinto/Documents/Godot Projects/testgame/`
- Godot: `4.7.2-stable (official)`
- Godot AI MCP plugin/server: `4.0.4`
- Current editor scene: `res://main.tscn`
- Session readiness: `ready`
- Filesystem scan: completed and settled; global class count 105; registered-class delta 0.
- The MCP-launched game helper reported `live` and `ready` on fresh main-scene launches with no launch-window recent errors.

## Scene and resource verification

- MCP opened and inspected `res://scenes/player.tscn`; the retained `Player` hierarchy contains `PlayerMotor` at `/Player/PlayerMotor`.
- MCP node properties resolved the motor script as `res://game/player/motor/player_motor.gd`.
- MCP runtime scene inspection resolved `/Main/World/Player/PlayerMotor` as a live `Node` with the same script attached.
- MCP script symbol inspection resolved `PlayerMotor` as a `class_name` extending `Node`, including `initialize`, `begin_motion_frame`, `submit_motion_request`, and `resolve_and_commit`.
- MCP filesystem inspection confirmed `res://main.tscn` remains the main scene, Jolt Physics remains configured, and the retained input actions are present.

## MCP source audit

MCP `script_manage(read)` was used for the controller and all six locomotion states. The result was:

| Source | `move_and_slide()` calls | Direct body velocity assignments | Direct body global-position assignments |
| --- | ---: | ---: | ---: |
| `game/player/motor/player_motor.gd` | 1 | motor-owned | motor-owned |
| `scripts/player_controller.gd` | 0 | 0 | 0 |
| `scripts/player_grounded_state.gd` | 0 | 0 | 0 |
| `scripts/player_airborne_state.gd` | 0 | 0 | 0 |
| `scripts/player_grappling_state.gd` | 0 | 0 | 0 |
| `scripts/player_wall_run_state.gd` | 0 | 0 | 0 |
| `scripts/player_wall_stick_state.gd` | 0 | 0 | 0 |
| `scripts/player_dead_state.gd` | 0 | 0 | 0 |

The motor source contains exactly one `move_and_slide()` call.

## MCP test-run result

MCP `test_run` was invoked from `res://main.tscn`. It returned:

```text
No test suites found in res://tests/
```

This project uses GUT through `res://addons/gut/gut_cmdln.gd`; the MCP test runner does not discover that GUT setup. The earlier pinned CLI/GUT totals remain separate evidence and are not presented as MCP test results.

## MCP runtime verification

The project was launched through MCP `project_run(mode="main", autosave=false)` and reported `helper_live=true`, `session_active=true`, `status="live"`, and `recent_errors=[]`.

For an isolated smoke sequence, enemy processing was disabled in memory through `game_eval`; no scene or project file was saved. MCP then applied a 30-frame `move_forward` action sequence and inspected the live player and motor through `game_eval`:

- Initial player position: `(0.0, 0.0993, 0.0)`.
- Post-sequence position: `(0.0, 0.1004, -7.8744)`.
- Last locomotion state: `player.locomotion.grounded`.
- Last commit: successful.
- Accepted submissions for the inspected frame: `1`.
- Commits for the inspected frame: `1`.
- Post-commit floor result: `true`.
- Motor initialization: `true`.

This is a fixture-style MCP runtime observation. The MCP jump-input attempts did not expose an airborne transition in this run, so no MCP jump result is claimed; the earlier GUT/CLI jump coverage remains distinct.

## Diagnostics and limitations

- The editor log initially contained 43 historical class-resolution entries from before the new `class_name` scripts were registered. After the MCP filesystem scan/reload, `logs_read(source="editor", since_cursor=43)` returned no newly appended entries.
- MCP `logs_clear(clear_debugger_errors=true)` was used before the final editor check. The final editor state was `ready`, with the game stopped and no active break.
- One exploratory MCP eval used an incorrect `PlayerCommandFrame` property and caused a probe-only runtime break; it was stopped and cleared. This was a validation-script error, not a project script error.
- No human visual smoke, full grapple/wall traversal replay, or 60/120 Hz quantitative pre/post replay was observed through MCP in this run.

## Hardening follow-up

The same MCP session was reused after the hardening edits. A fresh filesystem scan completed with global-class delta `0`; script symbol reads exposed `set_next_frame_velocity_baseline`, `abort_motion_frame`, and `prioritize_collision_indices` on `PlayerMotor`, and the retained scene still resolved `/Main/World/Player/PlayerMotor`.

The MCP runtime helper reported `live` with `recent_errors=[]`. After disabling non-player `CharacterBody3D` processing in memory for an isolated probe, a grounded eval observed an initialized motor, successful result, accepted-submission count `1`, and commit count `1`. A 32-frame `move_forward` input sequence moved the live player to approximately `z=-17.3745`, remained grounded, and still reported one accepted request and one commit for the inspected frame. No scene/project file was saved. Grapple acquisition was not claimed because the selected runtime position did not acquire a target.

MCP suspend/resume and one `next_frame` tick were also exercised. Suspend was observed; eval while suspended correctly returned `EVAL_GAME_NOT_READY`; resume returned the helper to `live`. The editor was stopped afterward and returned `ready`/`stopped`. The MCP-native test runner still reported zero suites because it only discovers direct `McpTestSuite` scripts, while this repository's canonical suites are recursive GUT `GutTest` scripts; the pinned GUT results above remain a separate gate.

The editor log rows containing old global-class-resolution errors were historical rows from before registration and were cleared/rechecked; the post-edit project run and game logs had no current-run errors. The remaining evidence boundary is deliberate: no human visual smoke, full normal-play wall/grapple replay, or quantitative 120 Hz pre/post traversal replay is claimed. The existing Story 1.2 input test still covers the permitted 60/120 command-frame cardinality contract.

## Final post-review MCP session

The prior session rotated while the task was paused, so the required preflight and post-edit validation were repeated in the active project session `testgame@d3ecac167a39b179` on 2026-09-12.

### Fresh preflight and resource inspection

- `session_manage(list)` identified the active `testgame` project session; `session_activate` selected `testgame@d3ecac167a39b179`.
- `editor_state` reported `res://main.tscn`, `ready`, and `stopped` before and after validation.
- `filesystem_manage(scan)` completed and settled with global-class count `105` and registered-class delta `0`.
- `editor_manage(logs_clear, clear_debugger_errors=true)` cleared the prior debugger state before the final run and again after stopping.
- `scene_get_hierarchy(depth=2)` and `node_get_properties` confirmed `/Main/World/Player` remains a `CharacterBody3D` using `res://scripts/player_controller.gd` and its `/Main/World/Player/PlayerMotor` child uses `res://game/player/motor/player_motor.gd`.
- `script_manage(find_symbols)` resolved the hardened motor symbols `set_next_frame_velocity_baseline`, `abort_motion_frame`, and `prioritize_collision_indices`, plus the controller symbols, without a project parse failure.

### Fresh runtime smoke

- `project_run(mode="main", autosave=false)` reached the MCP helper's `live`/`ready` state. Non-player `CharacterBody3D` processing was disabled in memory for isolation; no scene or project file was saved.
- MCP held the valid `move_forward` action and evaluated the running scene. The player advanced from `z=0` to approximately `z=-19.2911`, remained active and grounded, and reported velocity `z=-10`.
- A follow-up typed evaluation reported a successful commit with `accepted=1`, `commits=1`, and result step `564`; the player remained active and grounded.
- `project_manage(stop)` stopped the game, and the final `editor_state` returned `ready`/`stopped` with no active game.

### MCP test and diagnostic result

- `test_run` returned `No test suites found in res://tests/`, with `total=0` and `load_errors=[]`. This is the expected harness boundary: the repository's canonical suites are recursive GUT `GutTest` scripts, while the MCP runner only discovers direct `McpTestSuite` scripts.
- `logs_read(game)` showed only the helper registration and an existing physical-damage information line. The host did emit WASAPI audio-device initialization errors and used a dummy audio driver; these are environment diagnostics and did not prevent the runtime smoke.
- Two exploratory eval issues were probe-only and were cleared: an untyped eval local caused a debugger compile break, and `move_backward` was not a project action (the valid action is `move_back`). No project source error was attributed to either probe.

This final session confirms the live editor/resource/runtime gate after the review fixes. It does not upgrade the deliberate evidence boundary: no human visual smoke, full normal-play wall/grapple traversal replay, or quantitative 120 Hz pre/post traversal replay was observed.
