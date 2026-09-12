# Story 1.3 pre-change movement oracle

Captured before the first Story 1.3 runtime edit on 2026-09-11 at `2026-09-11T07:11:02.2302464-04:00`.

## Implementation-start identity

- Baseline commit: `1e8f81bfe34a6dd2bd602b3d48d772e63d648cc2` on branch `main`.
- Pinned console build: Godot `4.7.2.stable.official.ed1daf0bf`.
- Launch scene: `res://main.tscn`.
- Player scene UID: `uid://u1u36ceuo8uj`.
- Effective physics baseline carried from Story 1.1: 60 physics ticks per second, interpolation `false` (`BASE-002`), Jolt Physics, Forward+.
- Story 1.2 focused regression: exit `0`; 3 scripts, 21 tests, 21 passing tests, 677 assertions. Expected `push_error` output for invalid-step and invalid-initialization cases was classified by GUT as expected.
- Pre-existing working-tree status captured before Story 1.3 metadata edits:

  ```text
   M .codex/config.toml
   M _bmad-output/implementation-artifacts/sprint-status.yaml
  ?? _bmad-output/.artifact-index/context-1-3.json
  ?? _bmad-output/implementation-artifacts/1-3-centralize-the-players-physics-step-movement-commit.md
  ```

  The runtime surface (`project.godot`, `main.tscn`, `scenes/`, `scripts/`, `game/`, and `tests/`) was otherwise clean. The story and sprint metadata are the scoped files being updated for this run; `.codex/config.toml` and the context-pack index are pre-existing user/planning changes.

## Tuning and comparison tolerances

The player instance in `res://main.tscn` overrides `ground_deceleration = 30.0` and `grapple_gravity_scale = 0.0`. The retained player scene supplies `max_ground_speed = 10.0`, `max_air_speed = 10.0`, `ground_acceleration = 16.0`, `air_acceleration = 5.0`, `air_deceleration = 5.0`, `jump_velocity = 4.5`, `wall_run_acceleration = 4.0`, `wall_run_gravity_scale = 0.0`, and `pitch_max = 70.0`. The tutorial's late assignments (`grapple_length = 35.0`, `grapple_gravity_scale = 0.65`) remain outside this main-scene oracle.

For post-migration comparisons, use the same scene, start transform, input sequence, and 60 Hz rate. Accept a maximum vector-velocity difference of `0.05 m/s` at an equivalent sampled step, a maximum position difference of `0.10 m` over a 60-step sample, and a maximum one-physics-step transition alignment difference. These are comparison tolerances, not new tuning targets. Preserve the Story 1.1 limitation that wall rows are fixture-only (`BASE-007`) and that fall/death recovery are unavailable (`BASE-004`/`BASE-005`).

## Quantitative observed oracle

These values are the accepted Story 1.1 observations, re-read before implementation. They are the pre-change reference; they are not new post-change claims.

| Behavior | Setup and input | Observed pre-change result |
|---|---|---|
| Ground acceleration | `main.tscn`, isolated player on the floor at `(0, 0.1, 40)`, hold one cardinal movement direction for 30 physics frames | Player moved `7.874 m` in each tested cardinal direction and remained grounded/alive. The scalar target is `10 m/s`; one 60 Hz acceleration increment is `16 / 60 = 0.2667 m/s` until the target is reached. |
| Ground deceleration | Same floor setup, release from the moving state and sample the existing stop behavior | Main-scene deceleration scalar is `30 m/s²`, or `0.5 m/s` per 60 Hz step toward zero. No tuning change is permitted. |
| Air steering and gravity | Same isolated setup, `Space` pulse then hold `W` for 22 frames | At the recorded sample the player was airborne at `y = 1.137`, `z = 39.555`, with `z` velocity `-1.767 m/s`. Air steering uses `5 m/s²`; the retained player scene air deceleration is `5 m/s²`. |
| Jump launch | Same setup, one-frame `Space` pulse | After 10 frames the player was airborne at `y = 0.625` with vertical velocity `3.357 m/s`. Launch scalar is `4.5 m/s`; ordinary gravity is the engine default `9.8 m/s²` when not in a special traversal state. |
| Grapple pull | `main.tscn`, camera-forward ray to `TallTowerA` at `(8.75, 2.10, -17.5)`, hold right mouse for 20 frames | Target distance decreased `19.596 -> 17.479 m`; pull speed reached `11.059 m/s`. The unchanged profile is `48 m/s²` initial acceleration, `8 m/s²` minimum, `53.333333 m/s³` decay, and `22 m/s` total-speed cap. |
| Grapple release/momentum | Release the same 20-frame grapple | Grapple and target validity cleared within 2 frames; retained velocity was `(4.468, 0.764, -10.546) m/s`, speed `11.480 m/s`. |
| Wall run | `main.tscn`, runtime-only fixture beside `WideBlockA` at `(6, 0, 0)`, hold `D` | Fixture entered wall run with running `true`, normal `+Z`, direction `+X`, and vertical velocity `0`. This is not a normal player-entry proof (`BASE-007`). |
| Wall stick | Same fixture with a horizontal grapple ray, hold `D` and right mouse | By frame 12, grapple/stick were `true`, held inputs were true, and velocity was frozen to zero. This is fixture-only (`BASE-007`). |
| Wall jump | Active run and separately active stick fixture, pulse `Space` while holding `D` | Run exit vector `(6.467, 5.5, 8)`; stick exit vector `(10, 5.5, 8)`, with grapple/stick cleared. The entry limitation remains `BASE-007`. |
| Dead movement/recovery | Fresh unisolated launch with natural enemy damage, then movement/jump/grapple input | Health reached `0`, dead state persisted, and position/velocity remained unchanged; no current recovery path exists (`BASE-005`). |
| Landing/ordinary recovery | Isolated jump, wait 60 frames, then hold `D` for 15 frames | Player was grounded/alive and follow-up movement changed `x = 0 -> 0.642`. |

The 60/120-step command-frame cardinality checks belong to Story 1.2's input oracle and passed as a regression; they do not authorize changing the physics tick or interpolation settings.

## Current writer classification before migration

The pre-edit source audit found these active player movement writers:

- `scripts/player_grounded_state.gd:31` — ordinary grounded `agent.move_and_slide()`.
- `scripts/player_airborne_state.gd:28` — ordinary airborne `agent.move_and_slide()`.
- `scripts/player_wall_run_state.gd:24,37` — wall-jump and ordinary wall-run `agent.move_and_slide()`.
- `scripts/player_wall_stick_state.gd:19` — wall-jump `agent.move_and_slide()`.
- `scripts/player_controller.gd:436,443` — wall-run/wall-stick jump velocity writes; `488` — dead-state velocity reset; `493-494` — wall-stick position and velocity writes; `530` — `move_and_slide()` in `slide_and_check_wall_stick()`; `692` — grapple velocity cap; `712` — dead-state `move_and_slide()`.

The controller's `scripts/player_controller.gd:645` `global_position` write is the top-level `GrappleCursor` presentation object, not the player body. The tutorial's player start assignment and other `global_position` writes are out-of-band setup/presentation and are not active physics movement writers. Enemy movement, projectile/visual transforms, `GrappleCursor`, and the tutorial reset/start teleport remain classified and are not removed by Story 1.3.

Attack states contain no movement calls or final-body velocity writes. `game/player/input/player_input_source.gd` remains the only player hardware boundary, and `scripts/debug_grapple_telemetry.gd` remains an explicit developer-only F3 boundary.

## Planning-revision check

The six Story 1.3 ledger fingerprints in `context-1-3.json` match the current authoritative planning files, including project-context SHA-256 `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97`. The separate `all.json` inventory contains an older project-context fingerprint and is not the selected Story 1.3 resolver pack. The resolver pack reports `inventory_valid: true`, no errors, and only the acknowledged scoped GDD `needs-decisions` warning.

Story 1.1 remains `done` with accepted `PASS WITH LIMITATIONS`, `BASE-002`, `BASE-004` through `BASE-007`, and its completed review dispositions. Story 1.2 remains `done`; its dismissed review findings are preserved and are not reopened by this migration.
