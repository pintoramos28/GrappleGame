## Deferred from: code review of 1-1-verify-and-protect-the-playable-traversal-baseline (2026-09-09)

- Separate pre-existing and unrelated changes from the Story 1.1 review scope. The baseline-to-HEAD range includes the pre-existing Godot AI 3.2.4-to-4.0.4 configuration change, planning import-sidecar changes, and the later reference-image commit `e53d33e`; review or split those changes separately rather than treating them as Story 1.1 output.

## Deferred from: code review of 1-5-share-authoritative-ground-and-wall-contact-facts (2026-09-18)

- Revisit grapple pull activation: `scripts/player_grappling_state.gd` still calls `submit_grapple_pull(delta)` only inside the jump-edge branch. The Story 1.5 diff changed the floor predicate from `is_on_floor()` to `has_ground_contact()` but did not introduce the jump-edge gating; address under the owning grapple/traversal story rather than coupling it to the contact-frame review.
  - **Reconciled (Story 1.6, 2026-09-24): verified stale.** `scripts/player_grappling_state.gd` calls `agent.submit_grapple_pull(delta)` unconditionally each grappling update (after base/gravity policy and outside the jump-edge branch). No jump-edge gating exists and none was introduced. Pull behavior stays as-is (preserved scope); nothing remains to "address" from this note, and no pull redesign is performed here (that is Story 1.7/1.8 territory).

## Deferred from: 1.6 review fixes (2026-09-24)

- The duplicated pull tuning — controller exports (`grapple_initial_acceleration`, `grapple_min_acceleration`, `grapple_acceleration_jerk`, `grapple_max_velocity`) and `GrappleDefinition` fields (`pull_initial_acceleration_mps2`, `pull_min_acceleration_mps2`, `pull_acceleration_jerk_mps3`, `maximum_speed_mps`) — converges to a single source in Story 1.7. Until then, the composition-time parity check (`&"player.grapple.pull_tuning_mismatch"` invariant plus the GUT parity test) detects drift at composition time only; it does not re-check afterwards.
  - **Reconciled (Story 1.7, 2026-09-24): done.** The four controller exports, `PULL_TUNING_PARITY_TOLERANCE`, `_pull_tuning_matches_definition()`, and the `&"player.grapple.pull_tuning_mismatch"` invariant are deleted. `GrappleDefinition` is the sole authored pull/cap/range source; the new `GrappleController`/`GrappleAttachment` resolve occurrence-local values from it, and `test_definition_is_the_sole_pull_cap_and_range_source` (source-scan guard plus runtime/immutability assertions) replaces the retired parity test. Nothing remains to converge.
- Wire `GrappleTargetingResult.matches_single_query_contract()` into a developer-visible signal (debug assert or a `GameLog` invariant on violation) so a shipped second query surfaces outside test runs. Today only the GUT contract tests consult the predicate.
- `try_start_grapple()` reports `MISSING_RESULT` for both "feature unavailable (init failure)" and "composed feature pressed before its first evaluation"; gate the per-press `player.grapple.activation_missing_result` invariant on an evaluation actually having run (e.g. `_last_evaluation_step >= 0`) so early presses stop producing false-positive invariant noise.

## Deferred from: code review of 1-8-grapple-moving-and-stateful-targets-safely (2026-09-25)

- `get_reference_position()` silently returns `Vector3.ZERO` when the owner body is invalid, so pull direction and distance math use the world origin [game/player/abilities/grapple/grapple_controller.gd:103-106] - deferred, pre-existing (Story 1.7 contract).
- `commit_terminal` refusal path (invalid/NONE reason) leaves the attachment active with assert-only observability; release builds show no signal [game/player/abilities/grapple/grapple_attachment.gd:332-338] - deferred, pre-existing (Story 1.7 fail-closed semantics, explicitly preserved).
- `pull_direction` is recorded even when the motor rejected the pull while `submitted_acceleration_mps2` reports accepted-only - mixed diagnostic basis in one snapshot [game/player/abilities/grapple/grapple_controller.gd:338,348] - deferred, pre-existing (Story 1.7 diagnostics basis).

## Deferred from: wall-stick upper-only entry-speed change (2026-09-30)

- Wall-stick entry receives the just-committed frame's `result.submitted_velocity` from `_coordinate_post_commit()` (`scripts/player_controller.gd:428-432`), while its speed-only telemetry reads collision-adjusted `get_committed_motion_velocity()`. A collision that reduces speed across the upper limit can therefore produce a passing telemetry value without eligible entry. This evaluation-point distinction exists at baseline `89ead098`; the user requested removal of only the horizontal minimum. Preserve upper-gate timing now. Any future alignment must explicitly decide whether to cap approach speed or collision-adjusted speed and add a colliding regression; do not silently widen high-speed wall-stick eligibility.

## Reconciled by: independent wall-stick attachment (2026-10-01)

- The preceding telemetry evaluation-point distinction is resolved under the separately approved wall-stick attachment spec. Entry and its speed-only telemetry now use submitted incoming velocity relative to the sampled wall point, not collision-reduced velocity. The original historical entry above is preserved; this does not authorize wall-run retuning. Regression evidence: [wall-stick verification](evidence/wall-stick-attachment/verification.md).

## Deferred from: wall-stick validation baseline (2026-10-01)

- The fresh pre-change recursive GUT baseline has nine failing test identities, which remain after this feature: three route-completion cases, grapple definition/activation tuning expectations, moving scene-origin and pull-decay expectations, shallow-corner wall-run exit, and authored motor-context expectations. Full regression/route completion is not green. See [exact baseline comparison](evidence/wall-stick-attachment/review-hardening-gut-comparison.json); investigate these in separately authorized work, without silently retuning scenes or changing production route geometry.
