# Focused GUT runs (canonical regression gate, per domain)

All runs: pinned Godot 4.7.2 console (operator-local),
`<godot-4.7.2>/Godot_v4.7.2-stable_win64_console.exe --headless --path . -s
res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/<domain> -ginclude_subdirs
-gexit`, GUT 9.7.1. Raw logs: `focused-gut-<domain>.log` beside this file.

## RED phase (before implementation, recorded honestly)

`task1-red.log`: the migrated sole-source guard failed exactly as intended
against the still-duplicated controller (`player_controller.gd must not carry a
competing pull/cap scalar`, `parity machinery retired` x2, the retired
composition invariant still present, `grapple_controller.gd` /
`grapple_attachment.gd` do not exist yet, and the runtime 48.0 assertion failed
because the seeded value came from the stale export). This validates that the
guard actually detects the duplication Story 1.7 removes.

## GREEN phase (final)

| Domain | Scripts | Tests | Passing | Asserts | Exit |
|---|---|---|---|---|---|
| `tests/player/input` | 3 | 21 | 21 | 677 | 0 |
| `tests/player/motor` | 3 | 37 | 37 | 2,397 | 0 |
| `tests/player/contact` | 1 | 11 | 11 | 90 | 0 |
| `tests/player/grapple` | 4 | 48 | 48 | 1,614 | 0 |

Expected `GameLog` invariant diagnostics (`player.motor.*` motor invariants and
the Story 1.6 activation invariants `player.grapple.activation_stale_result` /
`player.grapple.activation_missing_result`) were asserted in-test via
`assert_push_error` and are not unexpected errors.

## Suite contents added in Story 1.7

- `tests/player/grapple/test_grapple_boundary_contract.gd` (9 tests):
  attachment single-commit/identity/seed facts/weak-ref death, occurrence-local
  resolution + definition immutability + later-occurrence reset, closed
  end-reason set + stable ids, idempotent duplicate termination (same terminal
  record, one signal, submissions stop), attachment snapshot schema/purity
  (including a value-only negative control), presentation-surface consumption
  purity (AC 11), and the outward-only boundary clipping math (inside
  no-correction, at-boundary radial-only clip with exact tangential/inward
  preservation, beyond-boundary full outward clip, overshoot prevention with one
  commit and no teleport, degenerate anchor).
- `tests/player/grapple/test_grapple_boundary_integration.gd` (10 tests, real
  Jolt, engine-driven physics frames): well-inside attach, near-boundary attach,
  outward travel from a ~10 m attach to the 35 m maximum (AC 4), inward travel
  at the boundary, tangential slide at the boundary, high-speed overshoot
  prevention, momentum-preserving release, death cancellation, duplicate
  termination, and the 60/120 Hz equivalence gate.
- `tests/player/motor/test_player_motor.gd` gained
  `test_maximum_anchor_distance_kind_is_typed_ordered_and_exclusive`.
- Migrated: `test_definition_pull_tuning_matches_controller_exports` ->
  `test_definition_is_the_sole_pull_cap_and_range_source`; the landing test in
  `test_player_motor_integration.gd` now seeds through the real attachment
  commit (the controller fields became read-through views); the diagnostics
  test now asserts the typed snapshots instead of the retired telemetry
  Dictionary.

## Intermediate regressions caught and fixed during the run

1. `assert_le` / `assert_ge` are not GUT 9.7.1 methods (parse failure of the new
   contract suite) -> `assert_lte` / `assert_gte`.
2. The manual `player.call("_physics_process", delta)` stepping idiom moves
   `CharacterBody3D`s by `velocity * process_delta` because `move_and_slide()`
   detects a non-engine physics callback and integrates with the frame delta
   (measured: 1.35 m for `10 m/s` at `process_dt 0.135 s`). Engine-driven
   physics frames integrate with the physics delta (measured: `10 m/s *
   1/60` per frame). The integration suite was rewritten to step on
   `await get_tree().physics_frame`, matching the running game.
3. The tangential speed "decay" observed in early scenario drafts is angular
   momentum conservation under a central pull (`v_t ~ 1/r`), not boundary
   clipping; the tests now assert angular-momentum conservation (measured
   spread ~1e-6 relative) and tangential stability while the boundary holds the
   radius.

Raw logs: `focused-gut-input.log`, `focused-gut-motor.log`,
`focused-gut-contact.log`, `focused-gut-grapple.log`, `task1-red.log`.
