# Story 1.5 pre-change oracle

Capture date: 2026-09-17 (America/Toronto)

The implementation started from the existing Story 1.4 working tree. The
implementation-start `HEAD` was `216e935e8e55822b87f675be0eb213f8c511f372`
on branch `main`; the working tree was clean at that point. The story's
planning `baseline_commit` remains `2c9f8af3d151bebaf72e513e938c1407ad660ec0`.
Story 1.4 was in `review`, with human feel/visual approval still pending.
No Story 1.4 files were reset, cleaned, reconstructed, or overwritten.

## MCP preflight

Active session: `testgame@e362124f09f388c2`

- Godot: `4.7.2-stable (official)`; Godot AI plugin/server: `4.0.4`.
- Editor readiness: ready; initial current scene `res://scenes/player.tscn`;
  play state stopped; editor log buffer had no lines at the initial read.
- Main scene: `res://main.tscn`; the player root UID remained
  `uid://u1u36ceuo8uj`.
- Physics backend: Jolt Physics; effective tick rate: 60 Hz.
- Pre-change interpolation: `physics/common/physics_interpolation=false`.
- Pre-change 3D layer names 1-8 were blank. The player retained collision
  layer 2 and mask 1.
- Pre-change scene inspection found `PlayerMotor`, the movement HSM and its
  grounded/airborne/grappling/wall-run/wall-stick/dead states, plus attack
  HSM. The controller still owned the old local floor/wall interpretation.

## Live baseline observation

The pre-edit MCP main-scene run launched with the helper live and no current
run errors. At the observed sample (step 771), the player was active and
grounded, `PlayerMotor` had a successful commit, and the authored main-scene
overrides were still visible: ground deceleration `30`, grapple gravity scale
`0.0`, grapple length `35.0`, and player collision layer/mask `2/1`.

The pre-change oracle is a migration reference, not a claim of human feel
approval. Historical Story 1.4 evidence remains at
`_bmad-output/implementation-artifacts/evidence/1-4/`.
