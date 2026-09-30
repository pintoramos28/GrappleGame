# Grapple-specific ground/air deceleration — verification

## Change

- `scripts/player_controller.gd` exports `grapple_ground_deceleration` and
  `grapple_air_deceleration`, independently tunable per player instance alongside
  `grapple_gravity_scale`. Both default to zero. The grappling locomotion policy
  selects these only with neutral movement input, according to the previous
  ground contact; grounded/airborne locomotion still selects its original
  `ground_deceleration` / `air_deceleration`. Movement-input acceleration, gravity,
  motor commit, target acquisition and the grapple pull profile are unchanged.
- Added a motor policy test for both contact modes and ordinary states, a
  real-motor GUT test checking tunable grapple-air damping and the ordinary-air
  policy after release, and a grounded-from-rest, angled-wall, zero-gravity
  GUT reproduction checking that flight stays on the pull line before contact.
- Pre-existing local changes in player scene, main scene, wall logic, grapple
  origin and their tests were not reverted or rewritten.

## Godot AI MCP (live editor / game; not GUT)

- Session `grapplegame@cc9f18a8fee838ac`, Godot 4.7.2-stable, plugin 4.2.3.
  Preflight listed the project session, inspected stopped/ready editor state,
  current player-scene hierarchy, controller source and editor diagnostics.
- Applied the controller script through MCP `script_patch`; the intermediate
  partially-edited signature produced a transient parse diagnostic, which
  cleared after the immediately following matching function patch (`diagnostics:
  []`, `reloaded: true`). Rescanned after test-source edits. Final editor
  `node_get_properties(/Player)` confirmed both new float exports at 0,
  independent of ordinary air deceleration 5 and ground deceleration 20.
  Editor stopped on `res://scenes/player.tscn`, `readiness=ready` after testing.
- MCP `test_run`: 15/15 passed across three top-level MCP-native suites, with a
  preload-cache warning; this is not GUT coverage of the changed script.
- Fresh MCP custom launch of `res://main.tscn` with `autosave=false`, run
  `r48908438-18`: the actual player had ordinary ground/air deceleration 30/5,
  grapple ground/air deceleration 0/0 and grapple gravity 0. From a stationary
  root with zero movement input, the existing input seam aimed at the angled
  `LowBlockA` hit `(-8.5, 3.1254, -17.0703)`. At sampled frame 60 of the
  held grapple the player was active, root `(-6.7172, 1.7794, -13.4899)` and
  cross-track deviation from the initial pull line was < 0.000001 m, compared
  with ~1.05 m by frame 61 in the prior unchanged scene. First wall contact
  was near `(-8.0491, 2.1451, -16.4258)` and closest root-to-hit distance was
  1.005 m near `(-8.0491, 2.2270, -17.0831)`. This fixes the pre-contact
  deceleration-induced off-axis launch; it does **not** implement arrival
  braking or prevent later wall sliding.
- Game log for that run contained only the MCP helper registration. The editor
  still reported the pre-existing `res://` autoload failure and script warnings;
  the helper became live and the smoke completed. No visual-frame claim is made.

## Pinned CLI / GUT (separate gate)

- `rtk` was not on PATH. Used the pinned
  `C:\Users\pin81845\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe`
  with `--headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=<suite>
  -ginclude_subdirs -gexit`. Local logs are under
  `C:\Users\pin81845\AppData\Local\Temp\opencode\grapple-deceleration-*.log`.
- Grapple suite: 111/112 passing, 6700/6701 assertions. Both newly added
  grapple integration tests passed. Existing targeting test
  `test_moving_scene_origin_does_not_change_camera_target_or_acquisition_range`
  expects local `(0.48, 1.2, -0.32)` but the pre-existing edited player scene
  has `(0, 0.9, 0)`.
- Motor suite: 38/39 passing, 2425/2427 assertions. New policy test passed;
  existing `test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band`
  still expects earlier gravity/main-scene tuning (1.0/default and an explicit
  override) rather than the pre-existing edited player/main scenes.
- Recursive `res://tests/player`: 220/223 passing, 10586/10593 assertions.
  Apart from those scene-tuning failures, the previously dirty shallow-corner
  wall-run test failed. Recursive `res://tests`: 228/233 passing,
  11224/11236 assertions; same failures plus two existing traversal-route
  failures. Full-suite pass is **not** claimed. These failures were already
  present in the previous grapple-origin verification and/or earlier
  investigation; no scene or wall-run changes were made for this task.
- `git diff --check` passed. The existing unresolved autoload diagnostic and
  ObjectDB cleanup warnings persist; neither is attributed to this change.
