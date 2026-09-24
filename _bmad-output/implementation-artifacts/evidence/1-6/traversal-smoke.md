# Traversal smoke (AC 15 playable baseline)

## What was observed live (MCP, `res://main.tscn`, run token 25)

- `res://main.tscn` launches and runs with the live helper and zero current-run
  errors (tokens 21-25).
- The player can identify and start grappling a valid current target through the
  typed targeting boundary: `LowBlockA` ordinary geometry accepted at
  `range_fraction 0.561` with no authored component (default static response),
  same-step activation seeded all five state fields, and the reticle marker
  agreed with the authoritative result.
- Current grapple pull remains playable: acceleration-based pull toward the
  anchor built speed 0 -> 16.5 m/s across ~0.9 s under the preserved decay
  (`48 -> 8 m/s^2` at `53.333333 m/s^3`) and `22 m/s` cap; release preserved
  committed velocity and cleared grapple state exactly as before.
- Game log showed no invariants/errors during the smoke (one ordinary enemy
  damage info line).

## What is covered by tests rather than this smoke

- Wall-stick-from-grapple (held GRAPPLE + contact + speed/alignment gates) and
  wall-run/wall-jump routing: preserved unchanged and covered by the existing
  real-Jolt motor integration tests (36/36), including the prior
  grapple-landing regression test that exercises `is_grappling` /
  `grapple_target` / `grapple_point` seeding through the new result path.
- Release-velocity preservation across many steps and the full boundary matrix:
  covered by the new grapple suites (24/24).

## Scope confirmation (AC 15 second clause)

The working-tree diff (`complete-status-diff.md`) shows the story did not
implement the active maximum-distance constraint (Story 1.7), redesigned pull
acceleration, moving-target sampling (Story 1.8), disposable-tutorial
preservation, or final presentation assets, and migrated no unrelated systems.
The tutorial's `grapple_length` assignment was removed as the single-range-source
requirement demands; tutorial survival was explicitly not required.

## Honest limits

- The live smoke is automated MCP observation (game_eval + simulated input), not
  human visual or feel approval; no screenshot or pixel claims are made.
- The `main.tscn` enemies damage a stationary player, so each smoke pass was run
  as one scripted sequence; earlier loose probing allowed enemy damage to reach
  death (which disables the input source by design) and is recorded in
  `limitations.md`.
