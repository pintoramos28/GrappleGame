# Story 1.4 semantic phase contract

Implementation and fix-pass evidence captured after the final source/test edits on 2026-09-17.

## Canonical order

`MotorPhase.canonical_order()` is the only resolver iteration order and contains exactly these seven phases:

1. `terminal_commands`
2. `state_gating_and_interrupts`
3. `base_locomotion_and_gravity`
4. `sustained_influences`
5. `one_shot_impulses`
6. `constraints_and_redirections`
7. `caps_and_final_commit`

The phase enum is used for typed binding and diagnostics. `PlayerMotorSubmission.has_valid_kind_and_phase()` enforces the one-to-one kind/phase mapping, so gameplay callers cannot submit an arbitrary phase or numeric priority.

## Typed bindings and deterministic rules

| API | Bound phase | Resolution rule |
|---|---|---|
| `select_terminal_policy` | terminal | zero or one terminal authority |
| `select_state_policy` | state gating | exactly one locomotion state |
| `submit_base_motion`, gravity | base/gravity | base target/rate first, then gravity at `acceleration * delta_seconds` |
| `submit_sustained_acceleration` | sustained | stable source-ID sort, then one rate fold |
| `submit_one_shot_impulse` | one-shot | stable `(source_id, occurrence_id)` sort and per-step deduplication |
| `submit_wall_run_constraint`, `submit_wall_stick_hold` | constraints | redirect horizontal velocity onto the supplied wall-relative direction, then remove outward wall-normal velocity; or apply the exclusive zero-velocity hold |
| `submit_total_speed_cap` | caps | the only active cap scope is `total_speed`; compatible submissions resolve to the most restrictive positive limit |

The controller owns stable dotted IDs such as `player.locomotion.grounded.base`, `player.gravity.default`, `player.grapple.pull`, `player.grapple.speed_cap`, `player.jump.ground`, `player.jump.wall`, `player.wall_run.constraint`, and `player.wall_stick.hold`. Stable IDs require at least two lowercase dot-separated segments, with lowercase-letter starts and lowercase/digit/underscore continuation. Jump occurrences use the immutable command-edge identity `player.command.jump_pressed`; occurrence guards are cleared by the next accepted frame.

Structural conflicts (multiple state/base/hold authorities, missing required policy, or incompatible hold/base composition) reject the complete frame before body mutation. Malformed, stale, non-finite, duplicate, or overflow submissions are isolated and recorded without erasing valid accepted submissions.

Accepted diagnostic facts retain the `source_id`, typed `kind`, and `occurrence_id` for each phase entry. The dead-state terminal marker is a terminal-policy record only; it does not suppress the required dead-state base/gravity submission or create a second body commit. Degenerate wall normals/directions and unsupported cap scopes are rejected with typed reasons rather than silently ignored.

## Intentional bounds

The maximum current valid contribution path remains six submissions (grappling state, base, gravity, pull, jump edge, and cap); the dead-state path is terminal marker, state, base, and gravity. `MAX_ACCEPTED_SUBMISSIONS = 16` provides bounded diagnostic headroom; `MAX_REJECTED_CONTRIBUTIONS = 16` bounds rejected facts. The resolver retains exactly seven phase-intermediate records. Existing collision bounds remain `MAX_SCANNED_COLLISIONS = 32` and `MAX_REPORTED_COLLISIONS = 8`.

The motor stores only per-step submissions, occurrence keys, rejection facts, phase intermediates, cap/constraint traces, and temporary folds. Grapple elapsed state, wall state, HSM ownership, and authored tuning remain in their existing owners.

## Contract coverage

The fix-pass lifecycle additions cover kind/phase mismatches, the unsupported-cap-scope rejection, stable-ID validation, degenerate wall vectors, duplicate-before-overflow ordering, controller isolated-rejection classification, and wall-relative redirection. The real-Jolt dead-state integration now also asserts the terminal marker's accepted identity.
`test_player_motor_semantic_contract.gd` proves exact phase order, stable insertion-order aggregation, one-shot deduplication, isolated invalid contributions, fatal structural conflict, next-step clearing, 60/120 Hz integration, and authored 30/20 m/s² first-step deltas. The real-Jolt integration suite proves the single-commit and traversal-state paths.
