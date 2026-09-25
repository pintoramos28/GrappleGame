# Boundary contract (Tasks 4.1-4.6)

## Motor addition

`PlayerMotorSubmission.Kind.MAXIMUM_ANCHOR_DISTANCE` (appended to the closed
`Kind` enum, existing ordinals untouched) resolves in
`MotorPhase.Phase.CONSTRAINTS_AND_REDIRECTIONS` through
`PlayerMotor.submit_maximum_anchor_distance(source_id, anchor_position, maximum_distance_m)`.
Source id `&"player.grapple.maximum_distance"`. Payload validation: finite
anchor, `maximum_distance_m > 0`, `INVALID_REQUEST` / `NON_FINITE_VALUE`
otherwise; `(kind, source_id)` duplicate rejection unchanged.

## Resolution (outward-radial-only, velocity space)

Reference point: the owner `CharacterBody3D` origin (the motor's own commit
transform) for pull direction, distance measurement, constraint resolution, and
the diagnostics snapshot - Task 4.4's single documented reference point. The
rope's mesh-center start stays presentation-only.

- `d < max`: no correction (AC 3), except one-step overshoot prevention:
  the outward component is limited to `(max - d) / delta_seconds`.
- `d >= max`: only the outward radial component is clipped; inward and
  tangential components are untouched (AC 5).
- The correction is velocity-only: no position write, no second
  `move_and_slide()`, no snap to the anchor, no momentum zeroing (AC 6).
- Documented positional tolerance
  `PlayerMotor.ANCHOR_DISTANCE_POSITIONAL_TOLERANCE_M = 0.05 m`: the bound on
  post-commit distance drift from collision resolution. It is a tolerance, never
  a range, and it is never used as one.

## Record (AC 12, no recomputation)

Each resolved boundary submission records one bounded dictionary
(`source_id, anchor_position, maximum_distance_m, distance_m, range_fraction,
radial_velocity_mps, tangential_velocity_mps, correction_applied, correction_mps,
positional_tolerance_m, physics_step`) copied onto
`PlayerMotorCommitResult.anchor_constraint_records` and
`PlayerMotorDiagnosticSnapshot.anchor_constraint_records` (copy-on-read). The
diagnostics snapshot copies these facts; it never re-runs the constraint.

## Preserved motor guarantees (Task 4.5)

Single commit per step, canonical phase order, per-step submission clearing,
stable-source and duplicate-kind validation, `MAX_ACCEPTED_SUBMISSIONS = 16`,
and all `SubmissionStatus`/`RejectionReason` values are unchanged (the new kind
reuses `INVALID_REQUEST`/`NON_FINITE_VALUE`); the only surface addition is the
new kind + record. `WALL_STICK_HOLD` exclusivity is unchanged: a frame mixing a
hold with any other submission still fails closed with
`EXCLUSIVE_POLICY_CONFLICT`, and while wall-sticking the movement HSM is in the
wall-stick state so the grapple controller submits nothing for those steps.

## Verification

- `tests/player/grapple/test_grapple_boundary_contract.gd` (pure cases on the
  real motor fixture): inside-no-correction; at-boundary outward clip with exact
  tangential/inward preservation; inward free at and beyond the boundary; pure
  tangential untouched; beyond-boundary outward fully clipped; overshoot
  prevention (`allowed = (35 - d) / delta`) with one commit, no hold request,
  no teleport; degenerate anchor distance.
- `tests/player/motor/test_player_motor.gd` ->
  `test_maximum_anchor_distance_kind_is_typed_ordered_and_exclusive`: kind/phase
  coherence, invalid payload and duplicate rejection (with expected
  `push_error` invariants), phase ordering (constraints after sustained
  influences, before caps), `WALL_STICK_HOLD` exclusivity fail-closed.
- Real-Jolt scenario coverage: `tests/player/grapple/test_grapple_boundary_integration.gd`
  (see `traversal-smoke.md` / `60-120-comparison.md`).

Raw runs: `focused-gut-grapple.log`, `focused-gut-motor.log`, `recursive-gut.log`.
