# Traversal smoke (Task 7.4, MCP-observed)

Session `testgame@e362124f09f388c2`, `project_run(mode="main")` ->
`res://main.tscn`, `game_status: live`, `helper_live: true`,
`recent_errors: []`. All facts below were read through `editor_manage(game_eval)`
/ `game_manage` on the running game; nothing is claimed that was not observed.

## Staging (recorded honestly)

The prototype level spawns three enemies that attack the idle player (observed
pre-existing combat behavior: repeated `Player took 6.6 physical damage` ->
`Player died`; combat/enemy code is untouched by Story 1.7). For a controlled
smoke the run staged: enemies freed, player teleported to open air
(`(0, 6, 12)`), aim driven through the input source's typed injection seam
(`inject_mouse_motion`), and - for the boundary phase - sustained outward
velocity re-seeded per sample to emulate outward pressure. The gameplay path
under test (command frame -> targeting -> attachment -> motor submissions ->
boundary constraint -> termination) is the real one throughout.

## Observed

1. **Grapple well inside (AC 1, 2, 11, 12).** Press edge committed
   `player.grapple.attachment_1` (`attachment_12` in a later run) with anchor
   `(2.66, 3.13, 22)` / `(9.13, 8.7, -17.5)`, `maximum_distance_m = 35`, rope
   visible. The pull accelerated toward the anchor with the authored profile:
   `submitted_acceleration_mps2 = 36.44` at `elapsed_seconds = 0.233`
   (= `48 - 53.333333 * 0.217`, the pre-increment clock), speed capped at 22.
   The typed attachment snapshot reported distance, range fraction, radial and
   tangential velocity live (see the game screenshot: overlay rows
   `Distance: 30.1 / 35.0 m range 0.86`, `Radial: -8.22 m/s Tangential: 2.47 m/s`).
2. **Outward travel to the boundary (AC 4, 5, 6).** From an attachment distance
   of `30.94` m the player travelled outward to `max_distance = 34.991` m -
   far beyond the attachment distance, never past the authored 35 m - and the
   live boundary correction engaged: at `d = 34.74` the constraint clipped
   `2.06 m/s` of outward speed (recorded `boundary_correction_mps`), leaving
   tangential motion free. One earlier pass peaked at `34.991` m with the
   correction not yet needed (the authored pull + `air_deceleration = 5.0`
   stopped the coast first) - consistent with "no correction inside the
   boundary".
3. **Tangential slide (AC 5, partial).** With a tangential drive at the
   boundary the player held `35.01 -> 35.40` m while the tangential velocity
   stayed flat (`0.46-0.48 m/s` in the sampled window). The staged velocity
   re-seed did not fully take effect in that pass (see `limitations.md`), so
   the exact tangential-preservation claim rests on the GUT real-Jolt suite
   (`60-120-comparison.md`: tangential 2.914 m/s preserved to 0.0008 m/s across
   the release).
4. **Release with momentum (AC 8).** Grappling at `30.82` m with committed
   velocity `(1.0554, -1.9072, -4.5258)`; on the release edge the terminal
   committed `release` and the velocity after the release steps was
   **exactly identical** (`drift = (0, 0, 0)`) - no stop, snap, or replacement
   launch velocity.
5. **Typed terminals (AC 9).** `release` and `ground_contact` both observed as
   committed terminal reasons in the running game (the latter when a staged run
   landed mid-grapple), and death was observed through the pre-existing combat
   path (`Player died` -> dead state).

## Visual evidence

`editor_screenshot(source="game")` while attached (`stale_frame: false`, live
capture) shows the cyan rope from the player capsule to the anchor and the
migrated typed debug overlay (attachment id/terminal, anchor, distance/max,
acceleration, speed cap, pull direction, radial/tangential, boundary row with
the 0.05 m tolerance, traversal states, targeting row with `queries 1`).

## Runtime cleanliness

The final run's game log contains only the game-helper registration line (zero
errors); `project_manage(op="stop")` -> `stopped: true`, editor `ready`.
