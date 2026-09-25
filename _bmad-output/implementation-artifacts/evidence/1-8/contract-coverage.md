# Contract coverage (Task 8.2)

`tests/player/grapple/test_grapple_moving_target_contract.gd` - 30 tests, all
passing (focused run `task1-7-green2.log`, final `recursive-gut-final.log`).
Real-Jolt player-scene scenarios live in `integration-matrix.md`; the Story 1.7
static-boundary contracts stay green in `test_grapple_boundary_contract.gd`
(10/10, with its end-reason schema test updated for the append-only extension).

## Value records and schema

- `GrappleAnchorState` is value-only (value types + the documented nested
  value-only `GrappleTargetResponse`), with the closed 4-value
  `InvalidationReason { NONE, TARGET_INVALIDATED, TARGET_DESTROYED,
  SCOPE_MISMATCH }`.
- `GrappleEndReason.Reason` extends append-only: the Story 1.7 prefix
  `NONE, RELEASE, TARGET_INVALIDATED, OWNER_DEATH, STATE_CANCELLATION,
  GROUND_CONTACT` keeps its order and ids; `TARGET_DESTROYED`,
  `SCOPE_MISMATCH`, `ANCHOR_DISCONTINUITY` are appended. `reason_id()` bounds
  checks and `is_valid_reason()` semantics are preserved (garbage -> `invalid`).
- `GrappleDefinition` gains `anchor_continuous_motion_tolerance_mps = 50.0` and
  `anchor_severe_discontinuity_threshold_mps = 250.0`, validated (finite,
  positive, strictly ordered) with the existing `INVALID_TOLERANCE` status and
  the existing lock semantics.

## Target-relative attachment state (Tasks 1.1-1.3)

- The attachment stores the stable target identity, the weak target reference
  (the documented `WeakRef` exception), and the hit position strictly as
  `target_local_hit_offset`; the frozen world `hit_position` is only the initial
  sample (`anchor_world_position` reads the latest sampled state).
- Full bounded response values (`GrappleTargetResponse` value-only record) and
  the optional originating encounter-scope identity are stored at commit.
- `is_definition_unmodified()` covers the new authored tolerance scalars;
  shared records (`GrappleTargetResponse.static_default()`) are never mutated.

## Sampling (Tasks 2.2, 2.3, 3.1)

- Ordinary geometry keeps `GrappleTargetResponse.static_default()`: frozen
  world anchor, zero velocity.
- `STATIC` components report the frozen initial anchor and zero velocity;
  `MOVING` components follow `parent.global_transform * target_local_hit_offset`
  through translation and rotation.
- Target velocity: explicit supplied velocity when the target authors one
  (`supply_anchor_velocity` / `clear_supplied_anchor_velocity`), otherwise the
  finite difference of sampled anchor positions over `delta_seconds` - measured
  identical at 60 Hz and 120 Hz (`test_anchor_velocity_finite_difference_is_rate_equivalent`).
- Sampling is query-only (source scan: no `move_and_slide`, `PlayerMotor`,
  `submit_`, `get_tree` in the shared contracts) and one sample per physics
  step is consumed by pull direction, boundary submission, and diagnostics
  (asserted on one shared controller/motor body fixture).
- Anchor following repeats no target-selection raycast (source scan over
  `grappleable_3d.gd`, `grapple_anchor_state.gd`, `grapple_attachment.gd`,
  `grapple_controller.gd`: no `intersect_ray` / `PhysicsRayQueryParameters3D`).

## Relative-motion boundary math (Task 4, pure motor fixture)

Geometry: anchor at the origin, player at `+z * distance` (outward = `+z`).

| Case | Player velocity | Anchor velocity | Expected | Result |
|---|---|---|---|---|
| static clip (1.7) | (0,0,12) | 0 | clip to 0, correction 12, carry 0 | pass |
| separating carry | 0 | (0,0,-5) | resolved z = -5, carry 5 | pass |
| inward free | (0,0,-8) | (0,0,-5) | resolved z = -8, no correction | pass |
| tangential free | (14,0,-2) | (0,0,-5) | x stays 14, radial = -5 | pass |
| approaching push | 0 | (0,0,+6) | resolved z = 0, carry 0 | pass |
| approaching slack | (0,0,10) | (0,0,+6) | resolved z = +6 (relative rule) | pass |
| refused carry | 0 | (0,0,-200), tol 50 | resolved z = 0, `carry_refused_mps` 200 | pass |

Record schema adds `anchor_velocity`, `anchor_radial_velocity_mps`,
`carry_applied_mps`, `carry_refused_mps`, `carry_refused` beside every Story
1.7 key (`correction_applied`, `correction_mps`, `radial_velocity_mps`,
`tangential_velocity_mps`, `positional_tolerance_m`, ...).

## Typed invalidation / scope / idempotency (Tasks 5.2-5.4)

- Freed target -> `TARGET_DESTROYED`; explicit invalidation ->
  `TARGET_INVALIDATED`; incompatible scope identity (both sides non-empty and
  different) -> `SCOPE_MISMATCH`; severe anchor jump ->
  `ANCHOR_DISCONTINUITY`. Each terminates exactly once through
  `GrappleController.terminate` -> `GrappleAttachment.commit_terminal`, and
  duplicate requests return the committed `Terminal` unchanged with one
  `attachment_ended` emission.
- A refused boundary carry terminates `ANCHOR_DISCONTINUITY` post-commit
  through the same funnel (record_committed_facts routing).

## Discontinuity tolerances (Task 6)

- Continuous motion (implied speed <= 50 m/s) follows normally.
- A 10 m one-step jump (600 m/s implied at 60 Hz) terminates
  `ANCHOR_DISCONTINUITY` before any submission; the player is never snapped.
- Instability scaling: `instability` (0..1) scales both tolerances down by at
  most half, occurrence-locally (asserted at `instability = 1.0` -> 50%).

## Diagnostics (Task 7)

The snapshot exposes `target_velocity_mps`, `anchor_valid`,
`anchor_status_id`, `boundary_carry_applied_mps`, `boundary_carry_refused_mps`
beside the Story 1.7 fields; all fields stay value-typed (source scan: no
`func set_` mutators).
