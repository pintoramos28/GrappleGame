# Tuning unification (Task 1)

`GrappleDefinition` is the sole authored pull / speed-cap / range authority.

## Removed (the Story 1.6 duplication)

- `scripts/player_controller.gd` exports `grapple_initial_acceleration`,
  `grapple_min_acceleration`, `grapple_acceleration_jerk`, `grapple_max_velocity`
  (the scene never serialized them; `scenes/player.tscn` is byte-unchanged in
  that region).
- `PULL_TUNING_PARITY_TOLERANCE`, `_pull_tuning_matches_definition()`, and the
  `&"player.grapple.pull_tuning_mismatch"` composition-time invariant.

`grapple_gravity_scale` is preserved exactly as context tuning (not definition
tuning): `player.tscn` default 1.0, `main.tscn` override 0.0, tutorial override
0.65 (guarded by
`test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band`).

## New authority chain

`grapple_definition.tres` -> `GrappleController.initialize(body, definition)` ->
`GrappleAttachment` occurrence-local resolved values:

| Authored (immutable) | Resolved (occurrence-local) |
|---|---|
| `pull_initial_acceleration_mps2 = 48.0` | `resolved_pull_initial_acceleration_mps2 = 48 * pull_multiplier` |
| `pull_min_acceleration_mps2 = 8.0` | `resolved_pull_min_acceleration_mps2 = 8 * pull_multiplier` |
| `pull_acceleration_jerk_mps3 = 53.333333` | `resolved_pull_acceleration_jerk_mps3 = 53.333333 * pull_multiplier` |
| `maximum_speed_mps = 22.0` | `resolved_maximum_speed_mps = 22.0` (no current modifier) |
| `max_grapple_length_m = 35.0` | `resolved_maximum_length_m = 35.0` (never from attachment distance) |

`pull_multiplier` (default 1.0) scales the pull profile uniformly, so the
authored shape (`48 -> 8 m/s^2` at `53.333333 m/s^3`, floor at ~0.75 s) is
byte-identical for default geometry and never mutates the shared definition
(`GrappleAttachment.is_definition_unmodified()` asserts it after every scenario).

## Guards

- `tests/player/grapple/test_grapple_targeting_integration.gd` ->
  `test_definition_is_the_sole_pull_cap_and_range_source`: source-scan guard
  (no competing `grapple_initial_acceleration|min_acceleration|acceleration_jerk|max_velocity`
  token in the controller, state, grapple domain, presenter, telemetry overlay,
  `player.tscn`, or `main.tscn`) plus runtime checks (activation applies the
  authored 48.0; the decay matches `min, initial - jerk * elapsed`; the cap
  source `&"player.grapple.speed_cap"` is applied; the definition is unchanged
  after the whole occurrence) plus the retired-machinery checks.
- `tests/player/motor/test_player_motor_integration.gd` ->
  `test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band`
  extended (Task 6.6) to scan the new attachment/controller/snapshot/end-reason
  surfaces for competing `grapple_length` tokens or `35.0` literals.
- `deferred-work.md` "1.6 review fixes" pull-tuning convergence item reconciled.

Raw runs: `focused-gut-grapple.log`, `focused-gut-motor.log`,
`recursive-gut.log` (all green).
