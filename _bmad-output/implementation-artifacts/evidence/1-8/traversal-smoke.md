# Moving-target traversal smoke (Task 9.2, MCP-observed)

Session `testgame@e362124f09f388c2`, `project_run(mode="main")` ->
`res://main.tscn`, `game_status: live`, `helper_live: true`,
`current_run_errors: []`. All facts below were read through
`editor_manage(game_eval)` / `game_manage` / `editor_screenshot(source="game")`
on the running game; nothing is claimed that was not observed.

## Staging (recorded honestly)

The prototype level spawns three enemies (observed pre-existing combat
behavior in Story 1.7; combat/enemy code is untouched by Story 1.8). For a
controlled smoke the run staged: the three enemy `CharacterBody3D` nodes
freed, a moving/stateful anchor spawned 20 m ahead (`StaticBody3D` +
`Grappleable3D` with `anchor_mode = MOVING`, `target_id = target.smoke_moving`,
`pull_multiplier = 0.5`, `instability = 0.25`), the player teleported into open
air (`(0, 20, 12)`), and press/release edges driven through the input source's
typed injection seam (`inject_action_binding(PlayerCommandFrame.Action.GRAPPLE,
0, true/false)`). The gameplay path under test (command frame -> targeting ->
attachment -> sampling phase -> motor submissions -> boundary constraint ->
typed termination) is the real one throughout.

Two smoke passes used live-scene staging aids that are recorded here rather
than hidden: the target box was resized to `Vector3(8, 40, 1)` so the
horizontal crosshair ray intersects it from the staged heights, and earlier
passes observed the preserved `ground_contact` terminal when the staged player
landed while attached (a Story 1.7 flow, not a Story 1.8 path).

## Observed

1. **Commit and sampled anchor (AC 1, 2).** The press edge committed
   `player.grapple.attachment_1` with the sampled anchor `(0.0, 2.834, -7.5)` -
   the accepted hit point on the target's near face - `anchor_valid = true`,
   `anchor status = valid`, distance `19.68 m`, `carry = 0`.
2. **Translation follow and target velocity (AC 3).** While the target
   translated `(0.1, 0, -0.05)` m per physics step (6 m/s x, -3 m/s z), the
   sampled anchor tracked it exactly: `(1.5, 2.834, -8.25)` ->
   `(2.0, 2.834, -8.5)` -> `(3.0, 2.834, -9.0)`, and the sampled
   `target_velocity` read `(6.000001, 0, -3.000011)` at every sample - the
   finite-difference derivation matching the staged motion to ~1e-5 m/s.
3. **Presentation and diagnostics (AC 9, Task 7.1).** The live debug overlay
   (game screenshot `attached-rope`, `stale_frame: false`) shows the typed rows
   including the new Story 1.8 facts: `Anchor status: valid` and
   `Target velocity: (0.0, 0.0, 0.0) m/s`, the boundary row with the 0.05 m
   tolerance, `Targeting: accepted step ... queries 1`, and the decaying pull
   (`Acceleration: 4.90 m/s^2`, `Speed cap: 22.0 m/s`). The earlier screenshot
   (`moving-target-attached`) captured the ENDED state after a preserved
   `ground_contact` terminal with the rope hidden - the exactly-once cleanup.
4. **Explicit invalidation (AC 6).** `invalidate_grapple_anchor()` on the
   component -> `grappling=false`, committed terminal `target_invalidated`,
   and the terminal record is identical on repeated reads (idempotent).
5. **Freed target (AC 6, NFR14).** After `queue_free()` of the target body:
   committed terminal `target_destroyed`, `grappling=false`, `idempotent=true`,
   the sampled anchor status reports `target_destroyed`, and the committed
   velocity changed only by ordinary physics over the following steps
   (`(0, 0.110, -0.702)` -> `(0, 0.0002, -0.916)`; no constraint impulse or
   spike).

## Runtime cleanliness

The final run's game log contains only the game-helper registration line (zero
errors); `project_manage(op="stop")` -> `stopped: true`, editor `readiness:
ready`, `play_state: stopped`.
