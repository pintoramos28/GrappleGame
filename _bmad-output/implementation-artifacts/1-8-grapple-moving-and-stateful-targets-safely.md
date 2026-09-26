---
baseline_commit: db421eacac7e0d34a581202f6d7302e0b59fd72e
---

# Story 1.8: Grapple Moving and Stateful Targets Safely

Status: done

<!-- Note: Validation is optional. Run validate-create-story for quality check before dev-story. -->

## Story

As a player,
I want my grapple attachment to follow moving or stateful targets and end safely when they become invalid,
so that dynamic anchors behave predictably without stale references or violent snaps.

## Acceptance Criteria

1. **Store target-relative attachment state**

   **Given** a grapple hit is accepted on a moving or stateful `Grappleable3D`
   **When** the attachment is created
   **Then** the player-owned `GrappleAttachment` stores the target's stable identity, a weak target reference, and the hit position in target-local coordinates
   **And** it stores bounded response values and an optional originating encounter-scope identity
   **And** it does not mutate any shared Resource.

2. **Sample authoritative anchor state**

   **Given** the attachment target remains valid
   **When** each physics step reaches the grapple-sampling phase
   **Then** the target supplies a `GrappleAnchorState` containing its world-space attachment position, target velocity, validity, effective response values, and any typed invalidation reason
   **And** the motor and grapple presentation consume the same sampled state for that physics step
   **And** the target cannot directly move the player or change player state.

3. **Follow continuous target movement**

   **Given** an attached target translates or rotates normally
   **When** its transform changes
   **Then** the attachment point follows the stored target-local hit position through both translation and rotation
   **And** target motion is reflected in the sampled anchor velocity
   **And** the system does not repeat target-selection raycasts to find the attachment point.

4. **Resolve a taut tether using relative motion**

   **Given** the player is inside the maximum grapple distance
   **When** the attached target moves away
   **Then** the player is not pulled until the grapple reaches its maximum length.

   **Given** the grapple is at maximum length
   **When** continuous target motion would increase the player-to-anchor distance
   **Then** the player receives only the target's separating radial motion required to keep the grapple within its maximum length
   **And** inward and tangential player motion remain available
   **And** target motion toward the player does not push the player
   **And** any required correction exceeding the configured discontinuity tolerance terminates the grapple instead of snapping the player.

5. **Preserve static-target behavior**

   **Given** the accepted target does not provide exceptional moving or stateful behavior
   **When** it is grappled
   **Then** the default static-target response from Story 1.7 remains in effect
   **And** existing zip-pull and maximum-boundary behavior does not regress.

6. **Handle invalid targets safely**

   **Given** an attached target is freed, explicitly invalidated, or reports an incompatible encounter-scope identity
   **When** the attachment is next sampled
   **Then** the grapple ends exactly once with the corresponding typed termination reason
   **And** no stale reference is dereferenced
   **And** no residual constraint impulse or player velocity spike is introduced.

7. **Reject severe transform discontinuities**

   **Given** the attached target moves within the configured continuous-motion tolerance
   **When** its anchor state is sampled
   **Then** the grapple follows it normally
   **But given** the anchor crosses the configured severe-discontinuity threshold
   **When** that state is sampled
   **Then** the grapple terminates with a typed discontinuity reason instead of snapping or teleporting the player.

8. **Make termination idempotent**

   **Given** release input, player death, target invalidation, or source removal overlap during the same physics step
   **When** more than one termination path is requested
   **Then** attachment cleanup and its termination event occur only once
   **And** the player returns to a valid traversal state.

9. **Expose state without transferring authority**

   **Given** grapple presentation or diagnostics need the active attachment position and status
   **When** they query the grapple system
   **Then** they receive read-only data derived from the authoritative sampled anchor state
   **And** they cannot modify attachment, motor, or target state.

10. **Verify moving-target behavior**

    **Given** focused automated tests running against real Godot/Jolt physics
    **When** translation, rotation about the local hit point, target velocity, relative maximum-distance resolution, target removal, explicit invalidation, scope mismatch, severe discontinuity, duplicate termination, and static-target regression scenarios are exercised
    **Then** every scenario passes at both 60 Hz and 120 Hz physics rates
    **And** the story introduces only an injectable scope-identity contract—not the full encounter lifecycle, anchor-modification mechanics, rope wrapping, elasticity, or reeling.

### Review Ratifications (code review 2026-09-25)

Two acceptance-criteria wordings were amended by explicit review decision (see
`Review Findings` below); the implementations and tests now match:

- **AC 4 (one-step pre-boundary carry).** RATIFIED EXCEPTION: at the boundary
  approach, one physics step may carry the pair before the measured distance
  reaches the maximum ("one step may not carry the pair past the maximum").
  Before that step a separating anchor does not drag the player at all. The
  exception is bounded by one step of anchor separation plus the measurement
  tolerance, and the separation test now measures the drag band instead of
  masking it (`evidence/1-8/limitations.md` records it as ratified).
- **AC 10 (rate matrix).** AMENDED COVERAGE: the five termination-path
  scenarios (freed, explicit invalidation, scope mismatch, severe
  discontinuity, duplicate termination) and the static-target regression run at
  BOTH 60 Hz and 120 Hz; translation/rotation follow and sampled-velocity
  scenarios run at 60 Hz with the two rate-sensitive scenarios additionally
  verified at 120 Hz (NFR4 evidence in `evidence/1-8/60-120-comparison.md`).
- **AC 9 (read-only exposure).** The mutable `GrappleAttachment` accessor
  (`GrappleController.get_attachment` / `player_controller.get_grapple_attachment`)
  is documented INTERNAL/TEST-ONLY and guarded by a source-scan contract test;
  presentation, diagnostics, and state consumers read value-only snapshots.

## Tasks / Subtasks

- [x] Task 1: Target-relative attachment state (AC 1, 3, 5)
  - [x] 1.1 Extend `GrappleAttachment` so the committed occurrence carries the stable target identity, weak target reference (existing documented `WeakRef` exception), and the hit position strictly as a **target-local offset** (already stored as `target_local_hit_offset`; ensure the frozen world `hit_position` is treated only as the initial sample, never as the ongoing anchor).
  - [x] 1.2 Store bounded effective response values on the attachment (full `GrappleTargetResponse` value-only record or documented scalar copy - not just `pull_multiplier`) and an optional originating encounter-scope identity (the injectable scope contract, Task 5).
  - [x] 1.3 Keep definition immutability: all resolved values stay occurrence-local (`is_definition_unmodified()` discipline); no shared Resource is mutated (NFR13).
- [x] Task 2: `GrappleAnchorState` contract and target sampling (AC 2, 3)
  - [x] 2.1 Add `game/shared/contracts/grapple_anchor_state.gd` (`GrappleAnchorState`, value-only record beside `grappleable_3d.gd` per the architecture contract table): world-space attachment position, target velocity, validity, effective response values, typed invalidation reason. Follow the `GrappleTargetSeed`/`GrappleTargetResponse` value-only purity pattern (no object references except the existing documented weak-reference exception).
  - [x] 2.2 Extend `Grappleable3D` with a query-only sampling API (e.g. `sample_anchor_state(local_hit_offset, ...) -> GrappleAnchorState`) that resolves `global_transform * target_local_hit_offset`, reports target velocity, and returns typed invalidation/scope reasons. Ordinary geometry keeps the built-in static response (`GrappleTargetResponse.static_default()`): frozen world anchor, zero velocity. Sampling must remain read-only - the target can never move the player or change player state (AC 2).
  - [x] 2.3 Define target-velocity reporting: an explicit supplied velocity when the target authors one, otherwise the finite difference of sampled anchor positions across physics steps (`delta_seconds`-based). The chosen method must be rate-equivalent at 60 Hz and 120 Hz (NFR4); document the choice in Completion Notes.
- [x] Task 3: One grapple-sampling phase, one consumed sample (AC 2, 3, 9)
  - [x] 3.1 In the active-attachment update (`player_grappling_state.gd` / `GrappleController`), sample exactly one `GrappleAnchorState` per physics step **before** any motor submission, store it as that step's authoritative sample on the attachment/controller, and derive pull direction, boundary data, and diagnostics from it (no recomputation).
  - [x] 3.2 Motor submissions (`submit_motor_influences`, `submit_speed_cap`) consume the sampled state; presentation and diagnostics read the same stored sample read-only. No per-step signals for anchor data (1.7 rule: per-step data flows through snapshots).
  - [x] 3.3 Anchor following uses transform math only: **no target-selection raycast is repeated while attached** (AC 3; keep the 1.6 one-query-per-evaluated-step discipline).
- [x] Task 4: Relative-motion maximum-distance resolution (AC 4, 5)
  - [x] 4.1 Extend the typed `MAXIMUM_ANCHOR_DISTANCE` submission and `_resolve_maximum_anchor_distance()` to carry the sampled anchor velocity and resolve against **player motion relative to anchor motion**. Preserve: outward-radial-only clipping, inward/tangential freedom, resolution last within `CONSTRAINTS_AND_REDIRECTIONS`, velocity-space overshoot prevention only (no position writes), `ANCHOR_DISTANCE_POSITIONAL_TOLERANCE_M = 0.05 m` semantics.
  - [x] 4.2 Implement the AC 4 rules: constraint inactive while `d < resolved_maximum_length_m` (target moving away does not drag the player before the boundary); at the boundary the player receives only the anchor's separating radial component required to stay within the maximum; an approaching anchor transfers no motion ("target motion toward the player does not push the player").
  - [x] 4.3 A required correction exceeding the configured discontinuity tolerance (Task 6) terminates the grapple with a typed reason instead of snapping; never zero momentum, never snap to anchor, never a second movement commit.
  - [x] 4.4 Static targets reduce exactly to the Story 1.7 behavior (zero anchor velocity = prior math) - cover with the static regression scenario (AC 5).
- [x] Task 5: Typed invalidation and idempotent termination (AC 6, 8)
  - [x] 5.1 Extend the closed `GrappleEndReason.Reason` set for the AC 6/7 paths. Recommended schema (append only - existing order is locked): keep `NONE, RELEASE, TARGET_INVALIDATED, OWNER_DEATH, STATE_CANCELLATION, GROUND_CONTACT` and append `TARGET_DESTROYED` (target freed), `SCOPE_MISMATCH` (incompatible encounter-scope identity), `ANCHOR_DISCONTINUITY` (AC 7); explicit target invalidation keeps `TARGET_INVALIDATED`. Any alternative partition must be documented with rationale and stable reason ids (`reason_id()` bounds checks preserved).
  - [x] 5.2 On the next sample after the target is freed, explicitly invalidated, or scope-mismatched, terminate exactly once through the existing single funnel (`GrappleController.terminate` -> `GrappleAttachment.commit_terminal`); gate every weak-reference dereference with `is_instance_valid`/`has_live_target()` (NFR14) so no stale reference is dereferenced.
  - [x] 5.3 Guarantee no residual constraint impulse or velocity spike: an invalid sample submits nothing for the step (pull, cap, and constraint submissions are skipped on termination) and the terminal records - never re-applies - the release velocity (AC 6).
  - [x] 5.4 Overlapping same-step terminations (release edge + death + invalidation + source removal): first committed terminal wins; `attachment_ended` emits once; `_clear_wall_stick()`/rope-hide cleanup runs exactly once (1.7 review fix preserved); the player returns to a valid traversal state through the existing locomotion dispatch.
- [x] Task 6: Severe-discontinuity rejection (AC 7)
  - [x] 6.1 Configure two immutable tolerances - continuous-motion tolerance and severe-discontinuity threshold - from authored definitions (no scattered constants). Recommended: new read-only `GrappleDefinition` fields documented in `completion notes`, optionally scaled per target by the bounded `GrappleTargetResponse.instability` (0..1). These values are tolerances, never ranges (1.7 lesson).
  - [x] 6.2 Per sample, compare the sampled anchor position against the previous step's sampled position: within the continuous tolerance follows normally; crossing the severe-discontinuity threshold terminates with `ANCHOR_DISCONTINUITY` **before** any submission for that step (no snap, no teleport). The band between the two thresholds must be handled and its behavior documented.
- [x] Task 7: Read-only state exposure (AC 9)
  - [x] 7.1 Extend `GrappleAttachmentDiagnosticSnapshot` (and the dev overlay consumption) with the sampled anchor facts: anchor position, target velocity, validity/status, typed terminal reason, plus the existing attachment fields. Consumers may read only; no mutation paths; no duplicate computation (NFR19, FR58).
  - [x] 7.2 Presentation (rope endpoint, marker) follows the sampled anchor state; the frozen rope spec behavior (single `reset_physics_interpolation()` call site) is preserved byte-for-byte.
- [x] Task 8: Focused verification matrix (AC 10)
  - [x] 8.1 Real-Jolt integration scenarios at 60 Hz and 120 Hz: translation follow, rotation about the local hit point, sampled target velocity, relative maximum-distance resolution (separating drag at boundary; inward/tangential free; approaching anchor no push), target removal (freed), explicit invalidation, scope mismatch, severe discontinuity, duplicate termination, static-target regression.
  - [x] 8.2 Contract tests for the value-only anchor state, end-reason schema, definition immutability, sampling-once-per-step, and no-raycast-while-attached (query-count assertion idiom from 1.6).
  - [x] 8.3 Scope guard (AC 10): no encounter lifecycle/registry, no anchor-modification mechanics, no rope wrapping/elasticity/reeling/rope-segment simulation; the scope-identity contract is injectable only.
- [x] Task 9: Dual-harness verification and evidence (AGENTS.md)
  - [x] 9.1 GUT: focused `tests/player/grapple` + `tests/player/motor` runs, then the canonical recursive `res://tests/player/**` gate (baseline 119/119 tests, 4,821 asserts, exit 0) plus pinned `--import`/load and `rtk git diff --check`.
  - [x] 9.2 Godot AI MCP: full preflight, rescan/reload after every write batch, MCP-native `test_run`, live `res://main.tscn` smoke with a moving/stateful grapple target via `game_eval`/input seam, MCP log review; record session ID and operations under `evidence/1-8/`.
  - [x] 9.3 Evidence set under `_bmad-output/implementation-artifacts/evidence/1-8/` mirroring the 1-7 layout (oracle, contract, integration, 60/120 comparison, pinned import/load, MCP verification, traversal smoke, limitations).

### Review Findings

Code review of Story 1.8 (gds-code-review workflow, 2026-09-25). Diff range `db421ea..9335764` ("story 1.7 complete and 1.8 implemenged"; Stories 1.7 + 1.8 stacked in one commit — findings scoped to the 1.8 delta, 1.7 decisions treated as locked constraints). Three adversarial layers (blind hunter, edge-case path tracer, acceptance auditor). Godot AI MCP preflight session `testgame@e362124f09f388c2` (ready/stopped, current scene `res://main.tscn`); no gameplay state mutated during review. Result: 3 decision_needed, 18 patch, 3 defer, 1 dismissed.

**decision_needed** — all three resolved during the review walkthrough (2026-09-25); each converted to a patch item below (marked `[Review][Patch][from Decision]`).

- [x] [Review][Decision] AC 10 60/120 Hz matrix scope — **resolved: "termination scenarios at both rates"**. Run the 5 termination-path scenarios (freed, explicit invalidation, scope mismatch, severe discontinuity, duplicate termination) plus the static-target regression at both 60 Hz and 120 Hz; keep pure follow/velocity scenarios at 60 Hz; amend the AC 10 wording to match the agreed coverage.
- [x] [Review][Decision] Pre-boundary carry contradicts locked AC 4 — **resolved: "ratify the one-step exception + fix the test"**. Amend the spec/AC wording so the documented one-step pre-boundary carry exception is explicit (it stays in `limitations.md`), and widen `_separation_scenario`'s measurement window so the drag band is observable and bounded instead of masked.
- [x] [Review][Decision] AC 9 read-only exposure vs mutable attachment accessor — **resolved: "internal/test-only + guard"**. Mark `get_grapple_attachment()`/`get_attachment()` as internal test-only, assert no presentation/diagnostic consumer reaches the mutable attachment (source-scan guard), and document the boundary.

**patch**

- [x] [Review][Patch][from Decision] Extend the 60/120 Hz matrix to the 5 termination-path scenarios + static regression and amend AC 10 wording [tests/player/grapple/test_grapple_moving_target_integration.gd:100,141]
- [x] [Review][Patch][from Decision] Ratify the one-step pre-boundary carry exception in spec/AC wording and widen the separation test window so the drag band is observable and bounded [game/player/motor/player_motor.gd:1184,1194; tests/player/grapple/test_grapple_moving_target_integration.gd:199]
- [x] [Review][Patch][from Decision] Make the mutable attachment accessor internal/test-only with a no-consumer source-scan guard and documented boundary [scripts/player_controller.gd:1091; game/player/abilities/grapple/grapple_controller.gd]

- [x] [Review][Patch] UTF-8 BOM prepended to `player_motor.gd` line 1 (`class_name PlayerMotor`) — baseline `db421ea` is clean, current bytes start `EF BB BF`; re-save UTF-8 without BOM and guard source scanners [game/player/motor/player_motor.gd:1]
- [x] [Review][Patch] Anchor sample-history staleness: per-target `_last_sample_anchor_position` cache survives attachment occurrences and sampling gaps; finite-difference velocity and `_is_severe_anchor_discontinuity` implied speed divide a multi-step displacement by one `delta_seconds` → inflated velocity → false carry refusal / spurious `ANCHOR_DISCONTINUITY` on re-attach and after wall-stick; breaks 60/120 rate equivalence — reset the baseline at attachment commit and divide by true elapsed/gap [game/shared/contracts/grappleable_3d.gd:118-130; game/player/abilities/grapple/grapple_controller.gd:296-308]
- [x] [Review][Patch] Wall-stick update samples the anchor only in the `not has_valid_grapple()` branch — no sample while wall-sticking with a valid grapple (stale anchor, unenforced maximum, resume spike); falsifies the "sampling every active step" claim — sample unconditionally per step or document suspension and repair the baseline on resume [scripts/player_wall_stick_state.gd:21-30]
- [x] [Review][Patch] `submit_motor_influences` consumes the stored sample without verifying it belongs to the current physics step — pass the step and refuse stale samples [game/player/abilities/grapple/grapple_controller.gd:331]
- [x] [Review][Patch] `carry_refused` → `ANCHOR_DISCONTINUITY` termination wiring (AC 4 "never snap") is never exercised end-to-end — `test_required_carry_above_the_discontinuity_tolerance_is_refused` drives the motor without a controller; add a controller-level test asserting one `attachment_ended` with `ANCHOR_DISCONTINUITY` and `carry_refused_mps` on the snapshot [game/player/abilities/grapple/grapple_controller.gd:420-425]
- [x] [Review][Patch] `record_committed_facts` inspects only the first `MAXIMUM_ANCHOR_DISTANCE` record (`break`) though the motor allows up to 4 — a refused carry from a later record never terminates and never appears in diagnostics; scan all records (or reject duplicate boundary submissions) [game/player/abilities/grapple/grapple_controller.gd:416-419]
- [x] [Review][Patch] Commit-step short-circuit: `GrappleAttachment._init` stamps `_sampled_anchor_step` with the seed sample, so `sample_anchor_state` on the commit step returns "valid" without running scope/discontinuity checks — init to an unsampled sentinel or document and test the one-step latency [game/player/abilities/grapple/grapple_controller.gd:181]
- [x] [Review][Patch] Sampling-once-per-step idempotence branch (Task 8.2 contract) is never asserted — no test double-calls `sample_anchor_state` on the same step [tests/player/grapple/test_grapple_moving_target_contract.gd]
- [x] [Review][Patch] AC 10 "rotation about the local hit point" scenario rotates about the body origin and asserts the anchor moves — the specified case (rotation centered on the hit point leaves the anchor stationary) is unasserted while `integration-matrix.md` claims coverage [tests/player/grapple/test_grapple_moving_target_integration.gd:135]
- [x] [Review][Patch] `carry_tolerance_mps` payload lacks bounds validation (negative tolerance pathological) despite the "finite/bounds-validated like the existing fields" claim, and no test asserts it equals `resolved_continuous_motion_tolerance_mps` — validate the payload and assert the wiring [game/player/motor/player_motor_submission.gd; tests/player/grapple/test_grapple_moving_target_contract.gd:403-415]
- [x] [Review][Patch] Tautological idempotency assertion `assert_same(attachment.get_terminal(), attachment.get_terminal())` cannot fail — capture the terminal first, then re-read and compare [tests/player/grapple/test_grapple_moving_target_contract.gd:480]
- [x] [Review][Patch] `test_severe_anchor_discontinuity_terminates_before_any_submission` never asserts that the failing step submitted nothing — assert `NO_ACTIVE_ATTACHMENT` and zero accepted submissions for that step [tests/player/grapple/test_grapple_moving_target_contract.gd:577-593]
- [x] [Review][Patch] Non-finite sampled anchor position coerces to `Vector3.ZERO` while `is_valid` stays true — a degenerate target transform silently anchors the rope at the world origin; fail closed with a typed invalidation [game/shared/contracts/grapple_anchor_state.gd:81]
- [x] [Review][Patch] `get_originating_scope_identity` has a tautological ternary and `StringName()`-coerces any Variant from the scope provider — validate `is String`/`is StringName` and fail closed on malformed providers [game/player/abilities/grapple/grapple_controller.gd:92-99]
- [x] [Review][Patch] `Terminal` claims value-only purity but has no `is_value_only()` check or test (unlike `GrappleAnchorState` and the diagnostic snapshot) — add the checker and one contract assertion [game/player/abilities/grapple/grapple_attachment.gd:25-55]
- [x] [Review][Patch] New `seed` identifiers introduced at `var seed := GrappleTargetSeed.new(` — violates the naming guardrail "do not introduce new `seed` identifiers (pre-existing shadowing warnings must not grow)"; rename [tests/player/grapple/test_grapple_moving_target_contract.gd:279,317]
- [x] [Review][Patch] `supply_anchor_velocity` has no expiry — a supplied velocity is reported until an explicit clear that a dying/invalidated target may never call; tie it to the sample step or clear on invalidation/exit-tree and document the lifetime [game/shared/contracts/grappleable_3d.gd]
- [x] [Review][Patch] `distance_at_resolution_m` falls back to a live `current_distance_m` read when no boundary record exists, conflating two fields the docs insist are distinct (and `from_attachment` double-maps the same key) — use an explicit "unresolved" sentinel and one documented key [game/player/abilities/grapple/grapple_controller.gd:449-456; game/player/abilities/grapple/grapple_attachment_diagnostic_snapshot.gd:310-311]

**defer**

- [x] [Review][Defer] `get_reference_position()` silently returns `Vector3.ZERO` when the owner body is invalid — pull/distance basis becomes the world origin [game/player/abilities/grapple/grapple_controller.gd:103-106] — deferred, pre-existing (Story 1.7 contract)
- [x] [Review][Defer] `commit_terminal` refusal path (invalid/NONE reason) leaves the attachment active with assert-only observability — soft-lock with zero signal in release builds [game/player/abilities/grapple/grapple_attachment.gd:332-338] — deferred, pre-existing (Story 1.7 fail-closed semantics, explicitly preserved)
- [x] [Review][Defer] `pull_direction` is recorded even when the motor rejected the pull while `submitted_acceleration_mps2` reports accepted-only — mixed diagnostic basis in one snapshot [game/player/abilities/grapple/grapple_controller.gd:338,348] — deferred, pre-existing (Story 1.7 diagnostics basis)

Dismissed (1): `_delta_seconds` division in `_resolve_maximum_anchor_distance` without an explicit positive guard — `PlayerMotor.begin_motion_frame` rejects non-positive deltas (verified against the callee), so the path is unreachable.

### Review Fixes — Implementation Notes (2026-09-25)

All 21 patch items (18 + 3 resolved decisions) applied and verified. Key
implementation facts and honest deviations:

- **Sample lifecycle (P2/P3/P4/P7).** `Grappleable3D.reset_anchor_sampling()`
  starts a fresh finite-difference baseline per attachment occurrence
  (called from `GrappleController.commit_attachment`); `sample_anchor_state`
  computes gap-aware `elapsed_seconds` (`delta * (step - previous_sampled_step)`)
  for both the derived velocity and the discontinuity classification;
  `player_wall_stick_state.gd` samples every wall-stick step with a live
  command frame (release edge still wins the same-step priority);
  `submit_motor_influences`/`submit_speed_cap` take the physics step and refuse
  stale samples with the new appended `SubmissionStatus.STALE_ANCHOR_SAMPLE`
  (append-only, `is_isolated_submission_status` grouped with
  `NO_ACTIVE_ATTACHMENT`); `GrappleAttachment._init` leaves
  `_sampled_anchor_step = -1` so the commit step is genuinely sampled.
- **Termination wiring (P5/P6).** `record_committed_facts` aggregates
  `carry_refused` across ALL resolved boundary records (a refused carry from
  any source terminates) and caches the controller's own record for
  diagnostics; a controller-level end-to-end regression test drives
  refusal -> `ANCHOR_DISCONTINUITY` -> exactly one `attachment_ended`.
- **Validation/purity (P13/P17/P18/P19/P21).** Motor rejects
  `carry_tolerance_mps < 0` (`player.motor.invalid_carry_tolerance`);
  non-finite sampled anchors fail closed typed `TARGET_INVALIDATED`;
  `get_originating_scope_identity` accepts only String/StringName; `Terminal`
  gains `is_value_only()`; supplied anchor velocity expires on explicit
  invalidation / `_exit_tree`.
- **Hygiene (P1/P20).** UTF-8 BOM stripped from `player_motor.gd` line 1
  (byte-verified: baseline had none); `seed` locals renamed `target_seed`.
- **DEVIATION (P22).** The proposed `-1.0` "unresolved" sentinel for
  `distance_at_resolution_m` was NOT kept: applying it broke the established
  contract encoded by the 1.7 boundary suites and the targeting diagnostics
  test (they read the field before the first boundary record). Re-implemented
  as the reviewer's alternative: the `from_attachment` double-map is gone (one
  documented key), and the pre-resolution live-read fallback is now an
  explicitly documented convention on `get_diagnostic_snapshot` and the
  snapshot field docs. Evidence: `gut-grapple-run1.log` failures at
  `test_grapple_boundary_integration.gd` (`attachment_distance_m: -1.0`) and
  `test_grapple_targeting_integration.gd:389`, all green after the change.
- **Test-fixture alignments (recorded, not hidden).** Two synthetic fixtures
  seeded explicit target identities without the `Grappleable3D` anchor contract
  (impossible in production: the 1.6 resolver emits `&""` for ordinary
  geometry and non-empty identities only from components). Commit-step
  sampling now correctly exposes that: `test_grapple_boundary_contract.gd`'s
  reference-point target gained a STATIC `Grappleable3D` (`target.contract`),
  and `test_player_motor_integration.gd`'s landing-transition seed now uses the
  production `&""` ordinary-geometry identity.
- **Dual-harness evidence (AGENTS.md, both gates run).**
  - GUT (canonical, pinned Godot 4.7.2 CLI): focused
    `res://tests/player/grapple` **107/107 (6,538 asserts)**, then the
    recursive `res://tests/player` gate **177/177 tests, 9,738 asserts, 13
    scripts** (story baseline 163/163, 8,629 — no regressions, +14 tests from
    review-fix and dual-rate scenarios). Pinned `--import` exit 0 (only the
    known benign RID-leak warning recorded in `final-import.log`);
    `git diff --check` clean.
  - Godot AI MCP (session `testgame@e362124f09f388c2`): preflight
    ready/stopped; `filesystem_manage(scan)` + `script_manage(find_symbols)`
    parse verification after every write batch (all changed runtime/test files
    parse clean); MCP-native `test_run` **15/15** across `grapple_boundary`,
    `grapple_moving_target`, `grapple_targeting` (`new_errors: 0`); live
    `res://main.tscn` smoke with a staged moving/stateful anchor
    (`target.review_smoke`, MOVING, `pull_multiplier 0.5`, `instability 0.25`):
    commit `player.grapple.attachment_1` with `sampled_step == motion_step`
    (621/1378/637 across observations), exact translation follow
    (`anchor == target.transform * offset` after the move), no false
    termination while the target moved, explicit invalidation ->
    `target_invalidated` committed once and identical on re-read (idempotent),
    live debug-overlay screenshot showing the typed `Anchor status:
    target_invalidated`, and a final game log containing only the helper
    registration line (zero errors). GUT and MCP results are reported
    separately; no parity claimed.
  - MCP harness noise (recorded honestly): two live-smoke evals raised
    harness-side errors (a null node access and a dynamically compiled staging
    script parse error) which tripped the editor debugger break — the same
    known harness behavior `limitations.md` documents; each run was relaunched
    cleanly and the final run's logs are clean. `logs_read(editor)` retains the
    pre-existing `player_contact_provider.gd` ring-buffer history
    (`recent_errors_may_predate_run: true`) — stale, not current defects.

## Dev Notes

### Developer Context

Per-step choreography after Story 1.7 (binding); Story 1.8 adds the grapple-sampling phase and anchor-relative math:

```text
pre-commit step N:
  capture immutable PlayerCommandFrame(N)            (player input boundary)
  grapple targeting runs ONLY for acquisition/on the activation frame
    (GrappleTargetResolver; the only gameplay raycast; never while attached)
  movement HSM update:
    grapple-sampling phase (NEW):
      attachment active -> sample exactly ONE GrappleAnchorState(N)
        anchor_world_position = target.global_transform * stored target-local hit offset
        target_velocity       = supplied or finite-difference of sampled anchor positions
        validity + typed invalidation/scope reason; effective response values
        invalid sample -> exactly-one typed terminal (Task 5); NO submissions this step
      store the sample as this step's authoritative anchor state
    active attachment submits per step FROM THAT SAMPLE:
      sustained pull acceleration toward sampled anchor      (SUSTAINED_INFLUENCES)
      total-speed cap                                        (CAPS_AND_FINAL_COMMIT)
      maximum-anchor-distance constraint, anchor velocity    (CONSTRAINTS_AND_REDIRECTIONS)
    release/termination removes grapple submissions for THIS step (declared release phase)
  PlayerMotor resolves semantic phases -> one velocity assignment + one move_and_slide()

post-commit step N:
  contact provider publishes ContactFrame(N)          (unchanged Story 1.5 ownership)
  presentation (rope, marker, telemetry) reads the SAME sampled anchor state read-only
  diagnostics read the same snapshots (no recompute, no extra query)
```

Only `PlayerMotor` writes final velocity or calls `move_and_slide()`, exactly once per physics step. The grapple controller remains an influence submitter. Targets return bounded data only; they can never move the player, write velocity, change locomotion state, or call player abilities.

### Anchor Sampling and Target-Relative Semantics (locked)

- **Anchor position is derived, never re-acquired.** `anchor_world_position = target.global_transform * target_local_hit_offset` each sampling phase. Translation and rotation both carry the attachment point; a target rotating about the local hit point leaves the anchor at that point (AC 3). No raycast, no re-resolution of the target.
- **`GrappleAnchorState` is the single per-step source.** Pull direction, boundary math, presentation, and diagnostics all read the same stored sample for step N (AC 2). Recomputing any of it from live transforms later in the frame is the AC 2 violation.
- **Target velocity is target-supplied or finite-differenced** (Task 2.3); the static default response supplies zero velocity and a frozen world anchor, which must reproduce Story 1.7 behavior exactly (AC 5).
- **Value-only discipline.** `GrappleAnchorState` follows the `GrappleTargetSeed`/`GrappleTargetResponse` purity pattern (value types + documented exceptions only); it carries typed enums/ids, not live object graphs. Weak target references stay at the seed/attachment level with `is_instance_valid` gating.
- **Query-only target boundary.** The sampled state may report invalidation/scope reasons but the target cannot touch player state (AC 2; `grappleable_3d.gd` header contract is preserved).

### Relative-Motion Boundary Semantics (locked)

- **One range, two consumers (unchanged).** `GrappleDefinition.max_grapple_length_m = 35.0` governs acquisition and the active tether boundary; `acquisition_tolerance_m = 0.005` is classification tolerance only; attachment distance is never rope length.
- **Pull profile (unchanged, static-regression baseline).** `pull_initial_acceleration_mps2 = 48`, `pull_min_acceleration_mps2 = 8`, `pull_acceleration_jerk_mps3 = 53.333333`, `maximum_speed_mps = 22` (from `grapple_definition.tres`, sole authored source). Do not redesign the profile; moving-target work changes only which anchor position/velocity it resolves against.
- **Relative motion.** Boundary resolution evaluates player motion **relative to anchor motion**. Only the outward radial component of relative velocity that would cross the boundary is clipped or redirected; inward and tangential player motion stay unrestricted (AC 4).
- **Carry rule.** When the anchor separates at the boundary, the player receives exactly the anchor's separating radial motion required to stay within the maximum - no more (no extra pull, no yank). Before the boundary, a separating anchor does not drag the player at all (AC 4 first Given).
- **No push from approach.** An approaching anchor transfers zero motion to the player.
- **Correction tolerance.** Overshoot prevention stays in velocity space only (no position writes, no second movement commit); the documented positional bound remains `PlayerMotor.ANCHOR_DISTANCE_POSITIONAL_TOLERANCE_M = 0.05 m` and never functions as range. A required correction exceeding the configured discontinuity tolerance terminates instead of snapping (AC 4).
- **Reference point.** The single player reference point stays the owner `CharacterBody3D` origin (Story 1.7 Task 4.4 decision); distance, pull direction, boundary math, and diagnostics all use it. Do not reintroduce `_get_player_mesh_center()`.

### Termination, Invalidation, and Idempotency Contract (AC 6, 8)

- Closed reason set extension per Task 5.1. Enum order is schema: append values only; keep `reason_id()` bounds checks and stable lowercase ids (`target_destroyed`, `scope_mismatch`, `anchor_discontinuity`, ...). `NONE` is never a committed terminal.
- Lifecycle unchanged: accepted seed -> committed attachment (active) -> exactly one reason-coded terminal -> submissions removed. Termination is idempotent: duplicate requests return the committed `Terminal` unchanged and repeat no transition, signal, presentation effect, or cleanup (NFR15).
- Invalid targets are detected at the sampling phase; the weak reference is dereferenced only behind `is_instance_valid`/`has_live_target()`; no stale node access (NFR14).
- Same-step overlaps (release edge, `OWNER_DEATH`, target invalidation, source removal) funnel through `GrappleController.terminate(reason, step)`; the first committed terminal wins, `attachment_ended` fires once, and the preserved cleanup (`_clear_wall_stick()`, rope hide) runs exactly once before consumers observe "ended" (1.7 review fix ordering).
- An invalid/terminated step submits nothing to the motor, so no residual constraint impulse or velocity spike can occur (AC 6). The terminal records the release velocity; it never applies one.

### Discontinuity Contract (AC 7)

- Two configured immutable tolerances: continuous-motion tolerance (follow normally) and severe-discontinuity threshold (terminate `ANCHOR_DISCONTINUITY`). Optional per-target scaling via bounded `response.instability` (0..1). Document the exact placement and values in Completion Notes; tolerances never act as range (1.7 lesson).
- Detection happens on the sampled anchor position delta before submissions for the step. A severe jump terminates instead of snapping or teleporting the player; the player keeps their current velocity.

### Scope-Identity Contract (AC 1, 6, 10)

- The attachment stores an optional originating encounter-scope identity supplied by an **injectable** provider at commit time (typed value or stable `StringName`/run id - document the chosen type). `Grappleable3D`/`GrappleAnchorState` may report an incompatible scope identity, producing a `SCOPE_MISMATCH` terminal at the next sample.
- **Do not build the encounter lifecycle**: no run registry, no reset transaction, no run-ID rejection machinery beyond this injectable identity check. Anchor-modification mechanics (FR34/Epic 4) are out of scope; `GrappleTargetResponse` stays immutable authored data with only occurrence-local resolution on the attachment.

### Requirement Traceability

- **FR10** (primary): track target-local hit point and current target velocity; end once with a typed reason on destruction, invalidation, stale encounter run/scope, or discontinuous motion -> AC 1, 2, 3, 6, 7, 8, 10.
- **FR7** (supporting): moving/stateful targets communicate exceptional typed responses consistently -> AC 1, 2, 5.
- **FR9** (preserve): one maximum length governs acquisition and active boundary; only outward movement constrained -> AC 4, 5.
- **FR8 / FR4** (preserve): acceleration-based zip-pull and momentum preservation; relative-motion boundary must not regress either -> AC 4, 5.
- **FR6** (consume, do not change): Story 1.6 authoritative targeting, seeds, typed responses -> AC 1, 3.
- **FR3** (supporting): immutable per-step command frame drives release edges -> AC 8.
- **FR58 / NFR19** (partial): bounded read-only attachment/anchor diagnostics -> AC 9.
- **NFR4** (60/120 Hz equivalence), **NFR5** (seconds-authored timing), **NFR6** (tolerant physics assertions, no tunnelling assumptions), **NFR10** (exactly-once/idempotent cleanup), **NFR13** (definition immutability), **NFR14** (no retained destroyed sources), **NFR15** (idempotent terminal), **NFR20** (contract suite: motor commit, influence order, single terminal, run/scope rejection, grapple/presentation agreement), **NFR21** (risk-appropriate real-Jolt evidence) -> AC 4, 6, 8, 10.

### Architecture and Scope Guardrails

- File placement: `GrappleAnchorState` in `game/shared/contracts/grapple_anchor_state.gd` (cross-domain grapple target types live beside `grappleable_3d.gd`); grapple runtime stays in `game/player/abilities/grapple/`; motor changes in `game/player/motor/`. Tests mirror domains under `tests/player/grapple/` and `tests/player/motor/`.
- Naming: `snake_case` files/functions/variables/signals; `PascalCase` classes/enums; `UPPER_SNAKE_CASE` enum values; units in names (`target_velocity`, `anchor_world_position`, `_m`/`_mps`/`_mps2` suffixes); stable lowercase dotted `StringName` ids (`player.grapple.attachment_<n>`, `player.grapple.maximum_distance`, `player.grapple.terminal_*`). Do not introduce new `seed` identifiers (pre-existing shadowing warnings must not grow).
- Motor additions follow the typed-submission discipline (stable `source_id`, kind/phase coherence, finite payloads, duplicate rejection, `MAX_ACCEPTED_SUBMISSIONS` bounds). No new velocity writers, no numeric priorities, no scene-tree-order precedence. If the boundary submission payload grows (anchor velocity), extend `player_motor_submission.gd` with the same validation discipline and keep existing kinds/phase order/exclusivity intact.
- **Frozen-spec discipline.** `spec-grapple-visual-interpolation-reset.md` (human-owned intent) is preserved exactly: rope hidden-to-visible `reset_physics_interpolation()`, world-space rope geometry, release/clear behavior. Anything altering project-wide `physics/common/physics_interpolation`, existing motor/contact behavior, grapple targeting, or the rope visual lifecycle is **stop and ask the user first**. Anchor following itself is transform math inside the physics step - no direct transform writes, so no new interpolation resets.
- Preserve exactly: seven-phase resolution and single commit; `ContactFrame` ownership; movement/attack HSM separation and `EVENT_*` transitions; press-edge activation; pull formula and cap; `grapple_gravity_scale` context overrides (`main.tscn` 0.0, tutorial 0.65); velocity-preserving release; wall-stick-from-grapple conditions and `_clear_wall_stick()` coupling; `PhysicsQueryProfile` contact bounds; `res://main.tscn` launch scene; UIDs (`scenes/player.tscn` `uid://u1u36ceuo8uj`, `player_grappling_state.gd` `uid://cjlui8t4vv7ha`, all `.gd.uid` sidecars); `PlayerCommandFrame` immutability and `Action` enum.
- Story 1.6 locks that must not be re-litigated: the 10-value `GrappleRejection` set (do **not** extend it; `try_start_grapple` commit-status mapping records true status separately), the quantized inclusive acquisition predicate, `GrappleTargetSeed` fields and its single `WeakRef` exception, one authoritative raycast per evaluated step, `GrappleDefinition` as the sole range authority.
- Story 1.7 locks that must not be re-litigated: `GrappleEndReason` existing order and ids; occurrence-local resolution; `SubmissionStatus.NO_ACTIVE_ATTACHMENT` meaning; boundary resolves last in the constraint phase; body-origin reference point; velocity-space overshoot prevention; `Terminal` record semantics; typed diagnostics snapshots (the untyped telemetry Dictionary stays gone).
- Known migration debt to not expand: prototype `move_and_slide()` call sites (Story 1.3-era), legacy `print`/`push_error` diagnostics, `scripts/player_controller.gd` retained as the controller (no bulk moves).
- Dependency pins: Godot 4.7.2-stable, Forward+, Jolt Physics, GUT 9.7.1, LimboAI 1.8.1 (vendored), Terrain3D optional (no grapple dependency), Phantom Camera deferred. Recorded discrepancy (do not act on): planning lists Godot AI 3.2.4 while the live MCP plugin/server reports 4.0.4.

### Current-State Update Map

Definite UPDATE (current state verified at authoring via MCP + file reads):

- `game/shared/contracts/grappleable_3d.gd` - today: optional direct-child `Grappleable` component (68 lines, `Node3D`), exports `target_id`, `eligible`, `anchor_mode` (`STATIC`/`MOVING`), `pull_multiplier`, `directional_adjustment`, `instability`, `hazard_response`; `build_response()` builds a bounded `GrappleTargetResponse`; `find_explicit_grappleables()` is the resolver's discovery helper; query-only by construction. This story: add the anchor-sampling API (Task 2.2) and optional scope-identity reporting. Preserve: the query-only boundary, `COMPONENT_NODE_NAME`, discovery semantics, and the bounded-response assertion.
- `game/shared/contracts/grapple_target_response.gd` - today: immutable value-only record (`AnchorMode`, `HazardResponse`, `MAX_PULL_MULTIPLIER = 4.0`, `MAX_INSTABILITY = 1.0`, quantized/bounded construction, `static_default()`, `is_value_only()` purity). This story: consumed as "effective response values" in `GrappleAnchorState`; `instability` may scale discontinuity thresholds (Task 6.1). Schema is otherwise locked - no new fields without documented rationale.
- `game/player/abilities/grapple/grapple_attachment.gd` - today: occurrence-local record (`player.grapple.attachment_<n>`, immutable definition reference, seed facts incl. `target_local_hit_offset` and the `WeakRef` exception, resolved pull profile/length/cap, pull-clock, `Terminal` with fail-closed commit). Its `anchor_world_position` is today a frozen world value from the seed. This story: per-step sampled anchor state + full bounded response values + optional scope identity (Tasks 1, 3); keep `is_definition_unmodified()` and `commit_terminal` semantics.
- `game/player/abilities/grapple/grapple_controller.gd` - today: `initialize`, `commit_attachment`, `submit_motor_influences` (pull + `submit_maximum_anchor_distance(SOURCE_MAXIMUM_DISTANCE, anchor_world_position, resolved_maximum_length_m)`), `submit_speed_cap`, idempotent `terminate`, `record_committed_facts`, `get_diagnostic_snapshot`; signals `attachment_committed`/`attachment_ended` (once). This story: sampling phase (Task 3), sampled-state-driven submissions, anchor-velocity-aware boundary submission (Task 4), invalidation routing (Task 5). Preserve: source ids, termination funnel, accepted-only acceleration recording, elapsed-clock semantics, boundary-record hygiene.
- `game/player/abilities/grapple/grapple_end_reason.gd` - today: closed `Reason { NONE, RELEASE, TARGET_INVALIDATED, OWNER_DEATH, STATE_CANCELLATION, GROUND_CONTACT }`, bounds-checked `reason_id()`, `is_valid_reason()`. This story: append typed values (Task 5.1). Preserve: existing order, ids, bounds checks.
- `game/player/abilities/grapple/grapple_attachment_diagnostic_snapshot.gd` - today: value-only attachment snapshot (identity, anchor, distance/maximum/range fraction, pull direction, submitted acceleration, resolved cap, committed velocity, resolved radial/tangential decomposition, boundary correction + tolerance, terminal reason; resolved/pre-commit basis names fixed by 1.7 review). This story: extend with sampled anchor facts (Task 7.1). Preserve: value-only purity, no-recompute rule, naming basis.
- `game/player/motor/player_motor.gd` - today: sole commit authority, seven `MotorPhase` steps, typed submissions with duplicate/finiteness/bounds validation (`MAX_ACCEPTED_SUBMISSIONS = 16`), `submit_sustained_acceleration`, `submit_total_speed_cap`, `submit_maximum_anchor_distance` resolved in `CONSTRAINTS_AND_REDIRECTIONS` (outward-radial-only, resolves last in the phase), `ANCHOR_DISTANCE_POSITIONAL_TOLERANCE_M = 0.05`, `SubmissionStatus` incl. `NO_ACTIVE_ATTACHMENT`, anchor-constraint records with truncation flag. This story: relative-motion resolution and anchor-velocity payload (Task 4). Preserve: every existing kind, phase order, exclusivity (`WALL_STICK_HOLD`), commit guard, truncation flags, and all motor tests.
- `game/player/motor/player_motor_submission.gd` - today: `Kind` enum incl. `MAXIMUM_ANCHOR_DISTANCE`, factories, `has_valid_kind_and_phase`, finite-payload checks. This story: extend the anchor-distance payload with anchor velocity (same validation discipline).
- `game/player/motor/player_motor_commit_result.gd` / `player_motor_diagnostic_snapshot.gd` - today: `anchor_constraint_records` (copy-on-read, truncation flagged). This story: record relative-motion/boundary facts needed by AC 4/9 without recomputation.
- `scripts/player_controller.gd` - today: composes `GrappleController`, `try_start_grapple` seeds from the accepted seed and records true commit status (1.7 review fix), reason-coded `terminate_grapple()` running preserved cleanup exactly once, read-through grapple views (zeroed post-termination per review fix), `get_grapple_targeting_diagnostic_snapshot`/attachment snapshot accessors. This story: supply the optional scope identity at commit, route new termination reasons, keep view zeroing. Preserve: activation validation flow, rope lifecycle, wall-stick coupling, death flow.
- `scripts/player_grappling_state.gd` - today: per-update `submit_state_policy(LOCOMOTION_GRAPPLING)`, reason-declared release/invalid termination, base policy + gravity + ground jump, `submit_grapple_pull` path, same-step submission stop on release. This story: place the sampling phase before submissions and terminate on invalid samples (Tasks 3, 5). Preserve: exact submission ordering and the same-step stop.
- `scripts/debug_grapple_telemetry.gd` - today: dev-only overlay consuming typed targeting + attachment snapshots, consumption-only guarded. This story: read sampled anchor facts (Task 7.1); remain bounded/read-only.
- Tests (extend): `tests/player/grapple/test_grapple_boundary_contract.gd`, `test_grapple_boundary_integration.gd`, `test_grapple_targeting_integration.gd`; `tests/player/motor/test_player_motor.gd`, `test_player_motor_integration.gd` (token-guard + constraint-kind coverage).

Expected NEW:

- `game/shared/contracts/grapple_anchor_state.gd` (+ `.gd.uid`) - `GrappleAnchorState` value record (Task 2.1).
- `tests/player/grapple/test_grapple_moving_target_contract.gd` and `test_grapple_moving_target_integration.gd` (or documented additions to the existing boundary pair) (+ `.gd.uid`).
- Optional MCP adapter `tests/test_grapple_moving_target_mcp.gd` (schema/data checks only - never GUT parity).
- Evidence set `_bmad-output/implementation-artifacts/evidence/1-8/`.

Inspect if needed (no changes expected): `grapple_target_seed.gd` (its header already defers moving-target tracking to this story; update comments only), `grapple_target_resolver.gd` (acquisition predicate - do not change), `grapple_definition.gd`/`.tres` (may gain the documented tolerance fields of Task 6.1; `validate()`/lock semantics preserved), `player_command_frame.gd`/`player_input_source.gd`, `game/app/logging/*`, `tests/player/motor/test_player_motor_semantic_contract.gd`, `tests/player/input/*`, `tests/player/contact/*` (60/120 idioms to mirror).

Preserve unchanged: `scenes/player.tscn`, `main.tscn`, `project.godot`, `scripts/player_wall_run_state.gd`, `player_grounded_state.gd`, `player_airborne_state.gd`, `game/player/locomotion/contact/*`, `game/shared/physics/*`, `demo/**`, `addons/**`, `ai/**`, `materials/**`, `scripts/levels/tree_grapple_tutorial.gd` (compiles only).

### Predecessor and Git Intelligence (Story 1.7 and earlier)

- **Git state at authoring (important):** HEAD is `db421ea` ("chore: mark story 1.6 completed"); the **entire Story 1.7 change set is uncommitted working-tree state** (14 modified files + `game/player/abilities/grapple/{grapple_attachment,grapple_controller,grapple_end_reason,grapple_attachment_diagnostic_snapshot}.gd`, boundary tests, `tests/test_grapple_boundary_mcp.gd`, `evidence/1-7/`, and the 1-7 story file). Story 1.8 stacks on that working tree - never reset/revert it; expect `git status` to show 1.7 files.
- Story 1.7 (implemented, `done`, review fixes applied) delivered: `GrappleDefinition` as sole pull/cap/range source; `GrappleController`/`GrappleAttachment`/`GrappleEndReason`/`GrappleAttachmentDiagnosticSnapshot`; typed `MAXIMUM_ANCHOR_DISTANCE` motor constraint (outward-radial-only, velocity-space overshoot prevention, 0.05 m tolerance, body-origin reference point); exactly-once reason-coded termination; typed diagnostics. Review locked: boundary resolves last in `CONSTRAINTS_AND_REDIRECTIONS`; `SubmissionStatus.NO_ACTIVE_ATTACHMENT`; snapshot field names state the resolved/pre-commit basis; boundary-record hygiene; fail-closed `commit_terminal`; guard-strengthened tests; cleanup ordering before `attachment_ended` consumers observe "ended". Carry these forward verbatim.
- Story 1.7 explicitly deferred **this story**: moving-anchor sampling, target discontinuity handling, moving-target invalidation (its Task 8.3 scope guard). Story 1.6 deferred: "attachment commit + per-step `GrappleAnchorState`-style sampling" (architecture activation steps 5-6) and named 1.8 as owner of moving-anchor sampling and discontinuity/invalidation.
- Test idioms established (mirror them): small real-Jolt scenes with typed inline fixtures, `autofree`, engine-driven physics frames (the manual `_physics_process` idiom integrates `move_and_slide()` with the frame delta - 1.7 regression lesson), input injection via `input_source.enable_test_input_seam()` + `inject_action_binding(PlayerCommandFrame.Action.GRAPPLE, 0, true)`, tolerant assertions (velocity drift `<= 0.05 m/s`, position drift `<= 0.10 m` over 60 steps), `delta_seconds = 1.0 / tick_rate`, **always restore `Engine.physics_ticks_per_second` on every exit path** (`before_each`/`after_each` - 1.7 review fix), separate accepted vs duplicate-rejected counters, query-count assertions, physically-possible displacement bounds for no-snap guards (not 0.25 s travel bounds).
- Open risks not to widen (1.5 P2s): lossy overflow accounting in the motor, profile runtime immutability not fully closed (`unlock_for_editor()` callable at runtime), init `SUCCESS` on invalid optional wall profile; 1.5 AC13 evidence gaps (120 Hz live comparison, wall-loss smoke) remain elsewhere's debt. Other `deferred-work.md` items stay out of scope.
- Sprint bookkeeping: `1-4`/`1-5` sit at `review`; never infer predecessor completion from automated checks alone (manual smoke sign-off precedent).

### Testing Requirements

- **Dual test harness is mandatory (AGENTS.md):**
  - **GUT (canonical comprehensive regression gate):** pinned Godot CLI recursive runs under `res://tests/player/**` (baseline 119/119 tests, 4,821 asserts, exit 0 - not a substitute for a Story 1.8 run), plus focused per-domain runs. Canonical recursive command (Story 1.2 pin, as used by 1.7): `Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit` (focused: swap `-gdir=res://tests/player/grapple` or `.../motor`). Report scripts/tests/assertions, exit codes, expected invariant diagnostics, unexpected errors, and import/teardown noise separately.
  - **Godot AI MCP (live-session gate):** preflight before editing; MCP-backed Godot-side operations during implementation; post-edit rescan/reload + editor diagnostics; launch `res://main.tscn` and smoke moving/stateful anchor behavior with `game_eval`/simulated input; inspect MCP logs; record session ID, operations, and results. MCP `test_run` discovers only direct `res://tests/test_*.gd` `McpTestSuite` files and never covers GUT suites - report both separately, claim no parity.
- Real-Jolt integration is required for all anchor/boundary behavior. No fake `move_and_slide()`, no arbitrary sleeps, no exact float equality, no rendered-frame timing, no private node-path coupling, no deep physics mocks, no large tree snapshots, no pixel-perfect screenshot assertions.
- Determinism and equivalence: identical scenarios must produce equivalent follow behavior, boundary correction, and terminal timing at 60 Hz and diagnostic 120 Hz within documented tolerances (NFR4); anchor-velocity derivation must be rate-independent (Task 2.3).
- Every runtime/visual claim needs reproducible evidence: command or scene, setup and inputs, expected result, plus relevant death/cancellation/reset behavior (NFR21). Claim visual verification only when observed through Godot AI MCP.
- Fix defects with reproduction-focused regression tests; no redundant coverage tests (no percentage targets exist).

### Latest Technical Information

- Pinned engine Godot 4.7.2-stable; no upgrades. Use the 4.7 doc tree for version-specific behavior.
- Engine moving-platform carry (`CharacterBody3D.velocity` addition from `AnimatableBody3D` with `sync_to_physics`) applies only to platform contact inside `move_and_slide()`; it is **not** a source for grapple anchor velocity. Known engine issues: characters slide off rotating `AnimatableBody3D` (godotengine/godot#102763) and lag one frame on code-moved `AnimatableBody3D` (#101253). Therefore the anchor position must come from `target.global_transform * target_local_hit_offset` and the anchor velocity from the explicit/finite-difference contract (Task 2.3) - never from engine platform-velocity APIs.
- `CharacterBody3D` semantics (unchanged from 1.7): `velocity` is m/s modified by `move_and_slide()`; call it from `_physics_process()`; `get_real_velocity()` is post-slide while `velocity` is requested motion - keep diagnostics explicit about which basis they report (resolved/pre-commit naming discipline).
- Physics interpolation (project-wide, enabled): direct transform writes outside the physics step cause jitter. Anchor following reads transforms and derives influence submissions inside the physics step - do not write the player transform for anchor corrections; velocity-space corrections only (1.7 discipline), and keep the frozen rope `reset_physics_interpolation()` discipline untouched.
- Jolt Physics: tolerant numeric assertions; stable tolerances over exact equality; swept/velocity-aware reasoning for high-speed traversal (NFR6).

### Story-Authoring Godot AI MCP Evidence

- **Run (read-only) for this authoring pass.** MCP session `testgame@e362124f09f388c2` (project `testgame`, Godot 4.7.2-stable official, plugin/server 4.0.4, protocol 2): `session_manage(list)` -> one active session, readiness `ready`, play state `stopped`, current scene `res://scenes/player.tscn`; `editor_state` -> ready/stopped, `game_status.status = stopped`; `script_manage(find_symbols)` of `game/shared/contracts/grappleable_3d.gd` (`Grappleable3D`, 7 exports, 5 functions incl. `build_response`/`find_explicit_grappleables`), `grapple_target_seed.gd` (7 functions, `WeakRef` exception purity), `grapple_target_response.gd` (`AnchorMode{STATIC,MOVING}`, `HazardResponse`, `MAX_INSTABILITY = 1.0`), `grapple_controller.gd` (11 functions, signals `attachment_committed`/`attachment_ended`) - confirming the Current-State Update Map above. Repo-wide class scan: `GrappleAnchorState` does **not** exist yet (it is genuinely NEW in this story).
- **Editor-log triage (MCP-observed):** `logs_read(source="editor")` shows the same historical parse-error ring-buffer entries Story 1.7 recorded (`player_contact_provider.gd` "Expected statement, found Indent" cascade into `test_player_contact_contract.gd`) plus `test_grapple_targeting_mcp.gd` placeholder-instance errors from prior MCP test runs ("Attempt to call a method on a placeholder instance"). Fresh parsing of the flagged scripts succeeds and1.7 verification is green, so these are stale mid-edit/ring-buffer history and MCP-runner artifacts - not current defects. Do not mistake them for damage caused by this story's work.
- No gameplay state was mutated and no scene/resources were edited during authoring. The dev-story agent must run its own full MCP preflight/implementation/validation cycle per AGENTS.md and record results separately from CLI evidence.

### Project Structure Notes

- `GrappleAnchorState` belongs in `game/shared/contracts/` because it crosses the player/target boundary (architecture contract table: "grapple result/snapshot types beside `grappleable_3d.gd`"). `GrappleAttachment`/`GrappleController`/end-reason/snapshot types stay player-ability-domain; promote only if a second domain demonstrably needs them (do not pre-abstract).
- Naming variance precedent (Story 1.6/1.7): architecture's directory row lists `player_grappling_state.gd` under `game/player/abilities/grapple/` while it lives in `scripts/` as a legacy LimboState - leave it in place and record any further variance in Completion Notes instead of wrapper duplicates.
- Tests mirror runtime domains; shared fixtures stay out of `tests/fixtures/` unless multiple suites need them. Incremental, Godot-aware migration only: preserve UIDs, update `.tscn`/`.tres` dependencies, verify affected scenes, remove superseded code only after its replacement works.

### Project Context Rules

Extracted from `_bmad-output/project-context.md` (91 rules; the following bind this story):

- **Engine/authority:** authoritative gameplay advances in `_physics_process(delta)`; only `PlayerMotor` writes final velocity or calls `move_and_slide()`, exactly once per physics step; fixed semantic phases (terminal commands -> state gating -> base locomotion/gravity -> sustained influences -> one-shot impulses -> constraints and redirections -> caps and commit); never settle precedence by scene-tree order or numeric priorities.
- **Definitions:** Godot Resources are immutable authored definitions during play; per-occurrence state is owner-local; tunable movement/grapple values live in immutable typed `.tres` definitions (no scattered constants, no runtime mutation, no live-tuning framework). Discontinuity tolerances follow this rule (Task 6.1).
- **Contracts:** commands/queries are direct typed methods; typed signals report committed past-tense facts synchronously; external systems use narrow typed contracts, stable IDs, immutable snapshots; expected rejection uses compact typed reason enums and is never logged as errors; targets cannot write player state.
- **Layout:** grapple under `game/player/abilities/grapple/`; motor under `game/player/motor/`; cross-domain grapple contracts under `game/shared/contracts/`; tests mirror domains under `tests/`. `snake_case`/`PascalCase`/`UPPER_SNAKE_CASE` conventions; units in names; stable lowercase dotted IDs.
- **Testing:** GUT 9.7.1 with the pinned recursive headless command; mandatory contract suite coverage includes motor commit and influence ordering, 60/120 Hz equivalence, one terminal result, idempotent termination, run/scope rejection, definition immutability, and grapple/presentation agreement; small real-Jolt integration scenes; reproducible evidence; deterministic stepping and tolerant numeric assertions.
- **Platform/build:** Windows x86-64, Forward+, D3D12, Jolt; Godot 4.7.2-stable pinned; no secondary-platform or controller work.
- **Presentation:** `_process` is presentation/smoothing/UI only; presentation consumes read-only snapshots and committed signals; missing presentation degrades but never blocks valid simulation.
- **MCP/tooling:** Godot AI MCP is mandatory for Godot work (preflight, implementation operations, validation) per repository AGENTS.md, with GUT as the canonical regression gate and MCP as the complementary live gate; record both separately.

### References

- Story source of truth: `_bmad-output/planning-artifacts/epics/epic-01-story-08.md` (all 10 acceptance criteria transcribed above).
- Architecture sections: "Motion Authority and Effect Precedence"; "Semantic Motor Influence Pipeline" (phases, submission API, "Active-grapple maximum-range constraint" incl. "Moving anchors are evaluated using player motion relative to anchor motion" and "An invalid anchor or severe discontinuity cancels the grapple rather than snapping the player"); "Cross-System Contract Specifications" -> "Grapple target contract" (four-type boundary, activation order, `GrappleAnchorState` responsibility); "Definition and Runtime State" (attachment state is owner-local); "Collision Matrix and Query Profiles"; "Grapple presentation"; "Error Handling"; "Debug and Development Tools"; "Lean AI-First Verification and Instrumentation"; "Setup and Verification Commands"; "Consistency Rules" (grapple range/tether rows); "Naming Conventions". [Source: `_bmad-output/planning-artifacts/architecture.md`]
- GDD: Pillar 1; Movement Feel Table ("Grapple acquisition / boundary | 35 m | ... initial attachment distance never becomes rope length | Accepted D-005"; "Grapple pull | 48 m/s² initial, 8 m/s² minimum, 53.33 m/s³ decay, 22 m/s cap"); FR4/FR6/FR7/FR8/FR9/FR10/FR12 rows. [Source: `_bmad-output/planning-artifacts/gdd.md`]
- Requirements: FR3, FR4, FR6, FR7, FR8, FR9, FR10, FR58; NFR4, NFR5, NFR6, NFR10, NFR13, NFR14, NFR15, NFR19, NFR20, NFR21. [Source: `_bmad-output/planning-artifacts/epics/requirements.md`]
- Frozen intent: `_bmad-output/implementation-artifacts/spec-grapple-visual-interpolation-reset.md` (preserve; ask-first boundaries above).
- Deferred items: `_bmad-output/implementation-artifacts/deferred-work.md`.
- Predecessor record: `_bmad-output/implementation-artifacts/1-7-zip-pull-within-a-true-maximum-grapple-boundary.md` (locked decisions, review fixes, test idioms, evidence layout), with `1-6-acquire-grapple-targets-consistently.md` (targeting locks) and `1-5`/`1-4`/`1-3` as pattern references.
- Current-state sources read at authoring: `game/shared/contracts/grappleable_3d.gd`, `grapple_target_seed.gd`, `grapple_target_response.gd`, `game/player/abilities/grapple/{grapple_attachment,grapple_controller,grapple_end_reason}.gd`, motor API surface, MCP-observed editor state/logs (see Story-Authoring Godot AI MCP Evidence).
- Engine docs: CharacterBody3D / AnimatableBody3D moving-platform guidance and known rotating-platform issues (Latest Technical Information).

### Source References and Artifact Ledger

Bounded resolver context pack: `_bmad-output/.artifact-index/context-1-8.json` (6 files; `inventory_valid: true`; warning: GDD `status: 'needs-decisions'` is permitted for scoped story 1.8 - never present any milestone as acceptance-ready). Artifact IDs and revisions (SHA-256) used to create this story:

| Artifact ID | Path | SHA-256 (revision) |
|---|---|---|
| `grapplegame.epics.requirements` | `_bmad-output/planning-artifacts/epics/requirements.md` | `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b` |
| `grapplegame.epics.1` | `_bmad-output/planning-artifacts/epics/epic-01-overview.md` | `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168` |
| `grapplegame.story.1.8` | `_bmad-output/planning-artifacts/epics/epic-01-story-08.md` | `c6e849e29667c5f4c97d7bd920e7024b96ae7d2b57ff4c603c78ecd817f0707c` |
| `grapplegame.gdd` | `_bmad-output/planning-artifacts/gdd.md` | `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156` |
| `grapplegame.architecture` | `_bmad-output/planning-artifacts/architecture.md` | `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080` |
| `grapplegame.project-context` | `_bmad-output/project-context.md` | `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97` |

- Epics manifest revision: `epics_manifest_sha256 = 8a0a51a1d4915b4aa75a7f96a427d03200a2fe0b4538ac061c9ab19afe045d15` (source `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`).
- `grapplegame.decision-log` (`_bmad-output/planning-artifacts/decision-log.md`, digest `01454eb5...72a00` per project-context frontmatter) is an optional input and was referenced by digest only, not loaded into this bounded pack.
- GDD scope note (resolver warning, permitted): GDD `status: 'needs-decisions'` with `implementation_scope_ready: 'M0 implementation-start only; no milestone is acceptance-ready'` - allowed for epic-1 story scopes.
- Continuity references: `1-7-zip-pull-within-a-true-maximum-grapple-boundary.md` (uncommitted working tree), `1-6-acquire-grapple-targets-consistently.md`, `1-5-...`, `1-4-...`, `1-3-...`, `deferred-work.md`, `spec-grapple-visual-interpolation-reset.md` (frozen), `evidence/1-3..1-7/`.
- Godot AI MCP authoring session: `testgame@e362124f09f388c2` (read-only evidence above).

### Story Completion Status

- Status: `done` - implementation complete (2026-09-25) and code review passed (2026-09-25). All 9 tasks / 27 subtasks checked; 10 acceptance criteria satisfied (see Completion Notes, the Review Ratifications under AC 10, and `evidence/1-8/`). Review outcome: 3 decisions resolved, 18 patches + 3 decision-derived patches applied and verified (GUT recursive 177/177 tests, 9,738 asserts; MCP-native 15/15; live `main.tscn` smoke + screenshot), 3 pre-existing findings deferred to `deferred-work.md`, 1 dismissed. Original implementation gate: GUT 163/163 (8,629 asserts), MCP-native 15/15, live moving/stateful smoke green. Story key `1-8-grapple-moving-and-stateful-targets-safely`.

## Dev Agent Record

### Agent Model Used

MiMo-V2.6-Pro (OpenCode), executing the gds-dev-story workflow.

### Debug Log References

- `_bmad-output/implementation-artifacts/evidence/1-8/pre-change-oracle.log` / `-raw.log` (baseline 119/119, 4,821 asserts, exit 0)
- `evidence/1-8/task1-7-green.log`, `task1-7-green2.log` (contract RED->GREEN iterations)
- `evidence/1-8/integration-pass1..4.log` (integration matrix iterations; final `integration-pass4.log` 14/14)
- `evidence/1-8/recursive-gut-pass1.log`, `recursive-gut.log`, `recursive-gut-final.log` (final: 13 scripts, 163/163 tests, 8,629 asserts, exit 0)
- `evidence/1-8/final-import.log` (pinned import, exit 0)
- Evidence notes: `pre-change-oracle.md`, `contract-coverage.md`, `integration-matrix.md`, `60-120-comparison.md`, `pinned-import.md`, `mcp-verification.md`, `mcp-native-discovery.md`, `traversal-smoke.md`, `limitations.md`

### Completion Notes List

- **Task 1 (target-relative attachment state).** `GrappleAttachment` stores the stable target identity, the weak target reference (documented `WeakRef` exception, NFR14-gated), and the hit position strictly as `target_local_hit_offset`; the frozen world `hit_position` is now only the INITIAL sample (`anchor_world_position` reads the latest stored `GrappleAnchorState`). It stores the full bounded `GrappleTargetResponse` value-only record (not just `pull_multiplier`) and the optional originating encounter-scope identity. `is_definition_unmodified()` covers the new authored tolerance scalars; nothing mutates a shared Resource (NFR13).
- **Task 2 (`GrappleAnchorState` + sampling).** New `game/shared/contracts/grapple_anchor_state.gd` (value-only record beside `grappleable_3d.gd`): `anchor_world_position`, `target_velocity`, `is_valid`, `invalidation_reason` (closed `NONE/TARGET_INVALIDATED/TARGET_DESTROYED/SCOPE_MISMATCH`), `scope_identity`, and the nested value-only effective response. `Grappleable3D.sample_anchor_state(target_local_hit_offset, delta_seconds, initial_anchor_world_position)` is query-only transform math against the anchor body's global transform; ordinary geometry keeps `GrappleTargetResponse.static_default()` (frozen world anchor, zero velocity). **Target-velocity reporting (Task 2.3, documented choice):** an explicitly supplied velocity when the target authors one (`supply_anchor_velocity` / `clear_supplied_anchor_velocity`, target-owned runtime state), otherwise the finite difference of sampled anchor positions divided by `delta_seconds`; the derived speed is identical at 60 Hz and 120 Hz (contract + integration measurements).
- **Task 3 (one sample per step).** The grapple-sampling phase lives in `player_grappling_state.gd` (before any grapple submission) calling `GrappleController.sample_anchor_state(step, delta)`, which stores exactly one authoritative sample per physics step (idempotent within a step) and is consumed by the pull direction, the boundary submission, and diagnostics - no recomputation, no per-step signals, and no target-selection raycast while attached (Task 3.3: attached steps are not evaluated steps; the 1.6 one-query-per-evaluated-step discipline holds - behavioral test + source scan).
- **Task 4 (relative-motion boundary).** `PlayerMotor._resolve_maximum_anchor_distance` resolves player motion relative to anchor motion with one formula: at/over the boundary the player's resolved outward radial speed is `min(player_outward, anchor_radial_speed)` (separating anchors carry the player with exactly their separating radial motion; approaching anchors transfer nothing; inward/tangential untouched); inside, relative overshoot prevention reduces byte-for-byte to Story 1.7 for zero anchor velocity. The `MAXIMUM_ANCHOR_DISTANCE` payload carries `anchor_velocity` and `carry_tolerance_mps` (finite/bounds-validated like the existing fields); record schema adds `anchor_velocity`, `anchor_radial_velocity_mps`, `carry_applied_mps`, `carry_refused_mps`, `carry_refused`.
- **Task 4 carry guard (AC 4 rule 4).** The anchor-separating carry is bounded by the configured continuous-motion tolerance; a required carry above it is refused (the player keeps the unchanged Story 1.7 outward clipping only) and `record_committed_facts` terminates `ANCHOR_DISCONTINUITY` through the single funnel within the same step - never a snap, never a second commit.
- **Task 5 (typed invalidation, idempotency).** `GrappleEndReason.Reason` extends append-only to 9 values (`TARGET_DESTROYED`, `SCOPE_MISMATCH`, `ANCHOR_DISCONTINUITY` after the locked Story 1.7 prefix; `reason_id()` bounds checks and ids preserved). The sampling phase routes freed targets -> `TARGET_DESTROYED` (no stale dereference), explicit invalidation -> `TARGET_INVALIDATED`, scope mismatch -> `SCOPE_MISMATCH`; every path commits exactly one terminal and emits `attachment_ended` once with the preserved cleanup ordering. Invalid samples record their typed state for diagnostics and submit nothing for the step.
- **Task 6 (discontinuity tolerances).** `GrappleDefinition` gains `anchor_continuous_motion_tolerance_mps = 50.0` and `anchor_severe_discontinuity_threshold_mps = 250.0` (authored in `grapple_definition.tres`, validated with the existing `INVALID_TOLERANCE` status and lock semantics; tolerances, never ranges). Occurrence-locally the bounded `instability` (0..1) scales both down by at most half. Classification uses implied speed (displacement / `delta_seconds`); the band behavior and the one rate-sensitive edge are documented in `evidence/1-8/limitations.md`.
- **Task 7 (read-only exposure).** `GrappleAttachmentDiagnosticSnapshot` adds `target_velocity_mps`, `anchor_valid`, `anchor_status_id`, `boundary_carry_applied_mps`, `boundary_carry_refused_mps` (value-typed, no mutators, no recomputation); the dev overlay consumes them (live screenshot shows `Anchor status` / `Target velocity` rows). Presentation follows the sampled anchor; the frozen rope spec is preserved byte-for-byte (single `reset_physics_interpolation()` call site, asserted; `grapple_visual_reset_count` stays 1 while visible).
- **Task 8 (verification matrix).** 14 real-Jolt integration scenarios (all 10 AC 10 scenarios + no-raycast-while-attached + presentation agreement) and 30 contract tests; the two rate-sensitive scenarios run at 60 Hz and 120 Hz inside the test (`evidence/1-8/60-120-comparison.md`: drift 0.0 m both rates, boundary hit 1.133/1.125 s, carry 4.9832/4.9834 m/s). Scope guard verified: no encounter lifecycle, no anchor modification, no rope wrapping/elasticity/reeling.
- **Task 9 (dual harness).** GUT canonical gate: 13 scripts, 163/163 tests, 8,629 asserts, exit 0 (baseline 119/119, 4,821 - no regressions; +44 tests). Pinned `--import` exit 0 with new UIDs additive only; `rtk git diff --check` clean. Godot AI MCP (session `testgame@e362124f09f388c2`): preflight, per-batch rescans, per-file parse verification, MCP-native `test_run` 15/15 (`new_errors_since_last_call: 0`), and a live `res://main.tscn` smoke with a moving/stateful anchor (commit, exact translation follow, sampled velocity (6, 0, -3) matching staged motion, explicit invalidation -> `target_invalidated`, freed target -> `target_destroyed` idempotent, clean game log) plus two live screenshots. GUT and MCP results are reported separately; no parity claimed.
- **Static-target regression (AC 5).** Story 1.7 behavior is preserved exactly for zero anchor velocity (byte-compatible boundary math, frozen anchor, zip-pull profile, maximum boundary); the full Story 1.7 suite (10 contract + 10 integration + 16 targeting + motor suites) stays green, and the static regression scenario is part of the 1.8 matrix.
- **Harness/tooling notes.** The MCP `test_run` preloaded-GDScript cache can be stale for newly added resource properties (harness `cache_warning`); the MCP adapter reads the authored `.tres` value in that case and GUT validates the same values in fresh processes (`limitations.md`). Two live-smoke evals raised harness-side errors (wrong node path / auto-named child) which tripped the editor debugger break; the game was relaunched cleanly and the final run's logs are clean.
- **Naming variance (recorded, not changed):** `scripts/player_grappling_state.gd` and `scripts/player_controller.gd` remain in the legacy `scripts/` locations per the Story 1.6/1.7 precedent; no wrapper duplicates were introduced.

### File List

- `game/shared/contracts/grapple_anchor_state.gd` (NEW, + `.gd.uid`)
- `game/shared/contracts/grappleable_3d.gd` (sampling API, scope identity, explicit invalidation, supplied velocity)
- `game/shared/contracts/grapple_target_seed.gd` (header comment only)
- `game/player/abilities/grapple/grapple_attachment.gd` (sampled anchor state, full response record, scope identity, tolerance resolution)
- `game/player/abilities/grapple/grapple_controller.gd` (sampling phase, scope provider, sampled-state submissions, carry-refusal routing)
- `game/player/abilities/grapple/grapple_end_reason.gd` (append-only 3 typed reasons)
- `game/player/abilities/grapple/grapple_attachment_diagnostic_snapshot.gd` (sampled anchor + carry facts)
- `game/player/abilities/grapple/definitions/grapple_definition.gd` (anchor-motion tolerance fields + validation)
- `game/player/abilities/grapple/definitions/grapple_definition.tres` (authored tolerance values)
- `game/player/motor/player_motor.gd` (relative-motion boundary resolution, carry guard, record fields)
- `game/player/motor/player_motor_submission.gd` (`anchor_velocity`, `carry_tolerance_mps` payload)
- `scripts/player_controller.gd` (sampling entry point, injectable scope provider, targeting gating while attached)
- `scripts/player_grappling_state.gd` (grapple-sampling phase + typed invalid-sample termination)
- `scripts/player_wall_stick_state.gd` (typed classification before the preserved fallback)
- `scripts/debug_grapple_telemetry.gd` (read-only sampled anchor facts rows)
- `tests/player/grapple/test_grapple_moving_target_contract.gd` (NEW, + `.gd.uid`) - 30 tests
- `tests/player/grapple/test_grapple_moving_target_integration.gd` (NEW, + `.gd.uid`) - 14 tests
- `tests/player/grapple/test_grapple_boundary_contract.gd` (end-reason schema test updated for the append-only extension)
- `tests/test_grapple_moving_target_mcp.gd` (NEW, + `.gd.uid`) - MCP adapter
- `tests/test_grapple_boundary_mcp.gd` (end-reason schema expectation updated 6 -> 9)
- `_bmad-output/implementation-artifacts/evidence/1-8/**` (evidence set, 10 notes + raw logs; `review-fixes.md` records the 2026-09-25 code-review gates)
- `_bmad-output/implementation-artifacts/1-8-grapple-moving-and-stateful-targets-safely.md` (this story file)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (status transitions)

### Change Log

- 2026-09-25: Code review (gds-code-review) completed and review fixes applied. 3 decision-needed findings resolved (60/120 Hz matrix scope: termination scenarios + static regression at both rates; pre-boundary one-step carry ratified and its test window unmasked; mutable attachment accessor documented internal/test-only with a source-scan guard), 18 + 3 patches applied (sample-lifecycle staleness, wall-stick sampling, stale-sample guard, commit-step sampling, carry-refusal termination wiring and multi-record aggregation, payload bounds, non-finite fail-closed, scope-provider validation, Terminal purity, supplied-velocity expiry, BOM strip, `seed` rename, dual-rate matrix, rotation-about-hit-point scenario, test fixes), 3 pre-existing findings deferred, 1 dismissed. AC 4/AC 10/AC 9 wordings amended under "Review Ratifications". GUT 177/177 (9,738 asserts); MCP-native 15/15; live `main.tscn` smoke + screenshot; `evidence/1-8/review-fixes.md`. Status: done.

- 2026-09-25: Story 1.8 "Grapple Moving and Stateful Targets Safely" implemented. Target-relative attachment state with per-step `GrappleAnchorState` sampling (query-only transform math, supplied-or-finite-difference target velocity), relative-motion maximum-distance resolution with the anchor-separating carry and its discontinuity-tolerance guard, append-only typed termination (`TARGET_DESTROYED`/`SCOPE_MISMATCH`/`ANCHOR_DISCONTINUITY`) with exactly-once idempotency, immutable anchor-motion tolerances (50/250 m/s, instability-scaled), read-only sampled-anchor diagnostics, and the real-Jolt 60/120 Hz verification matrix. GUT 163/163 (8,629 asserts, exit 0); MCP-native 15/15; live `main.tscn` moving/stateful smoke green. Status: review.

- 2026-09-25: Story 1.8 "Grapple Moving and Stateful Targets Safely" context created from the bounded resolver pack (6 artifacts, digests recorded above). Comprehensive dev guide: 10 acceptance criteria, 9 task groups, locked target-relative anchor sampling (`GrappleAnchorState` via `Grappleable3D`, no re-raycasts), relative-motion maximum-boundary resolution with carry/no-push rules, typed invalidation/discontinuity/scope termination with exactly-once idempotency, injectable scope-identity-only scope guard, read-only state exposure, real-Jolt 60/120 Hz verification matrix, current-state update map, and frozen-spec/MCP/AGENTS.md guardrails. Status: ready-for-dev.
