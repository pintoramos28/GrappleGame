# Story 1.4 pre-change oracle

Captured before runtime source edits on 2026-09-12.

## Repository and planning state

- Implementation-start checkout: `2c9f8af3d151bebaf72e513e938c1407ad660ec0`.
- Story frontmatter baseline preserved as `7f0e5cd3a53b5dc202a2cd2a84d0966aaa1d08cc`.
- Working tree was clean (`git status --short --branch`: `## main...origin/main [ahead 20]`).
- Story planning revision inventory matched all six recorded SHA-256 values in `context-1-4.json`; `inventory_valid=true`, with only the permitted `gdd: needs-decisions` warning.

## Pinned runtime/editor facts

- Godot: `4.7.2-stable (official)`, build `4.7.2.stable.official.ed1daf0bf`.
- Physics backend: Jolt Physics.
- Shipping tick: 60 Hz; project interpolation setting observed as `false`.
- Renderer: Forward+ (`forward_plus`); Windows driver `d3d12`.
- Main scene: `res://main.tscn`.
- Player scene UID: `uid://u1u36ceuo8uj`.
- LimboAI: vendored `1.8.1`; GUT: `9.7.1`; Terrain3D: `1.0.2`; Phantom Camera: `0.11.0.2`.
- Godot AI MCP session: `testgame@d3ecac167a39b179`; plugin/server `4.0.4`; editor ready and stopped at the end of the preflight reads; editor diagnostic buffer empty.

## Tuning contexts retained

| Context | Ground deceleration | Grapple gravity scale | Other preservation |
|---|---:|---:|---|
| Direct `res://scenes/player.tscn` | `20.0` | `1.0` | Compatibility fallback, not production-equivalent main tuning |
| Canonical `res://main.tscn` player | `30.0` | `0.0` | Normative playable/GDD oracle |
| `scripts/levels/tree_grapple_tutorial.gd` player | inherited reusable scene, then `30.0` in effective late override context | `0.65` late override | `grapple_length = 35.0`; existing level-owned start/reset teleport remains out-of-band |

The direct scene and canonical main scene both expose `grapple_length = 35.0`; the tutorial explicitly assigns `35.0` and `0.65` after instantiation.

## Existing ownership oracle

The only runtime active-player final body writer and `move_and_slide()` caller was `game/player/motor/player_motor.gd` (`_body.velocity = request.provisional_velocity`, `_body.move_and_slide()`). The same motor owned the wall-stick position correction (`_body.global_position = hold_position`). Local `Vector3` calculations remained in the controller/state owners, while enemy movement and the tutorial's level-owned player placement are separate scopes and were not treated as active-player final-commit writers.

## Automated baseline

All commands used the pinned operator-local `Godot_v4.7.2-stable_win64_console.exe` through `rtk`, serialized to avoid import/cache contention.

| Suite | Result | Assertions | Notes |
|---|---:|---:|---|
| `res://tests/player/input` | 21/21 pass | 677 | Expected input rejection diagnostics were classified by GUT |
| `res://tests/player/motor` | 24/24 pass | 290 | Expected lifecycle/rejection diagnostics were classified by GUT |
| recursive `res://tests/player` | 45/45 pass | 967 | Includes both suites; same expected diagnostics |

Known teardown noise: the input run reported 8 leaked ObjectDB instances and 1 resource in use at exit; this was retained as predecessor noise. No unexpected test failure occurred.

## MCP baseline observation

The active main-scene run launched successfully with a live helper and no current-run errors. A canonical player snapshot observed grounded motion through the existing complete-request motor path, with one successful commit and `player.motor.commit_succeeded`. The MCP native test discovery returned `total=0`, `load_errors=[]`, and `No test suites found in res://tests/`; nested GUT suites are not MCP-native `McpTestSuite` files, so this is recorded as discovery only and is not a GUT result.

The live baseline was stopped before source edits. No runtime source, scene, Resource, or dependency was changed by the preflight.
