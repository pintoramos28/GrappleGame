# Re-anchor review triage — 2026-10-02

Three fresh read-only passes completed: blind adversarial, exhaustive edge-case, and acceptance. The latter two independently identified same-sample response ordering; blind/edge passes also identified Animatable inheritance. Findings were deduplicated into the localized safeguards below. None requires new intent or a frozen-spec change: all are code/test guards within the existing typed transaction, validity, motion, timing and presentation contracts. No broad re-derivation, rollback, production tuning or route edits are authorized.

| ID | Classification | Local safeguard | Initial evidence / status |
|---|---|---|---|
| R1 | patch | Classify discontinuity using the incoming surface response, while retaining the previous anchor for displacement | Confirmed in MCP run `r168513595-35`; tightening wrongly accepts and relaxing wrongly terminates at 7.5 m/s with valid test-only tolerances 3/10. [Before-fix repro](review-response-before-fix.json). Pending fix. |
| R2 | patch | Scale the surface-binding per-step displacement bound over skipped samples; retain velocity/rotation-rate bounds | Controller supplies gap-correct elapsed time; binding still uses one-step absolute bound. Pending fix/test. |
| R3 | patch | Route AnimatableBody3D through authoritative native point-velocity sampling before StaticBody3D conveyor handling | MCP ClassDB confirms Animatable inherits Static; source branch currently catches it as static. Pending native regression. |
| R4 | patch | Reject null/malformed fresh responses in legacy non-surface sampling | New `build_response` null outcome currently becomes an eligible static default. Pending guard/test. |
| R5 | patch | Reject aliasing an already-installed surface binding before arming the motor baseline | Existing replacement releases then installs the same binding. Pending atomic guard/test. |
| R6 | patch | Require original target tree membership during preparation and commit | Freed/queued guard does not cover detached live nodes. Pending guard/test. |
| R7 | patch | Query current original explicit contract validity without changing its legacy sampling cache | Cached original sample can outlive invalidation/removal between preparation and commit. Pending guard/test. |
| R8 | patch | Bind re-anchor transaction to its own motor/body and completed physics step | Another idle motor can currently receive the zero baseline. Pending guard/test. |
| R9 | patch | Reject copying physical contact from a released carry attachment | Listener was removed but status stays valid; later geometry mutation is no longer observed. Pending guard/test. |
| R10 | patch | Exercise actual Animatable/Character/Rigid supports during continuation and forward release | Existing policy matrix uses only StaticBody3D. Pending real-physics cases. |
| R11 | patch | Assert visible active marker/rope and assigned actual mesh along with endpoint transforms | Correct stored transforms alone cannot establish rendered geometry. Pending negative controls. |
| R12 | patch | Assert elapsed-clock/expected-curve preservation at release, not merely later acceleration below initial | Resetting then decaying for five ticks also satisfies the old assertion. Pending stronger control. |

Native-body velocity remains authoritative, consistent with `player_contact_provider.gd:1036-1049`; arbitrary external pose driving of native bodies is not new supported mover behavior and must not be “fixed” by double-counting pose displacement. Explicit Grappleable policy remains consistent with existing acquisition precedence (`grapple_target_resolver.gd:317-332`); this task does not silently replace that policy with a new universal candidate-mask gate. Normal query/type compatibility and genuine runtime invalidation remain required.

Current evidence predates these fixes: full GUT 267/276 with the same nine baseline failures, parent live 6/6 and diagnostic viewport captures. Fresh post-hardening GUT and MCP results are required before closeout. No green full-regression or route-completion claim is made.

## Verified dispositions — 2026-10-02

The initial evidence/status column above is retained as historical capture.
The following dispositions supersede its pending states after fresh dual-gate
verification. See [full hardening evidence](hardening-results.md) and
[16-check result comparison](hardening-test-comparison.json).

| ID | Disposition | Verified control at both 60/120 Hz |
|---|---|---|
| R1 | closed — patched/verified | Actual 7.5 m/s tightening terminates once under incoming threshold 5; relaxation remains active under incoming threshold 10. Previous sample and occurrence clock retained. |
| R2 | closed — patched/verified | Four-step 0.4 m movement accepted at 6/12 m/s, 1.2 m rejected; speed/rotation/scale/tilt negative controls and unchanged one-step carry bound pass. |
| R3 | closed — patched/verified | Actual Animatable native point velocity plus owner-local motion; old static formula disagrees by about 1.04480 m/s and the new sample agrees exactly. |
| R4 | closed — patched/verified | Ten malformed legacy response cases fail closed with valid tracking positives, unchanged cache/clock, exactly-one terminal and cleared visuals. |
| R5 | closed — patched/verified | Prepare/commit aliases and null/stale preparations fail typed; installed binding remains live/unreleased and original state/baseline unchanged. |
| R6 | closed — patched/verified | Detached live original refused at both boundaries; reattached owned positive commit succeeds. |
| R7 | closed — patched/verified | Twelve fresh before/after original-contract changes plus installed resize/scale guards reject atomically; pure cache/status and restored-positive controls pass. |
| R8 | closed — patched/verified | Foreign matching-step motor and own motor with a real later completed step refused without baseline mutation; owned positive and active-frame rejection retained. |
| R9 | closed — patched/verified | Released carry rejects contact copy before/after unobserved resize while retaining historical status. |
| R10 | closed — patched/verified | Six real Animatable/Character/Rigid continuation/release cases; repeated in a second fresh MCP process. No production mover change or native pose double-counting. |
| R11 | closed — patched/verified | Actual visible assigned mesh measurements; hidden/detached/replaced/wrong-height negative controls detect defects and restored positives pass. |
| R12 | closed — patched/verified | Exact release-step elapsed/curve expectations; forced reset gives distinguishably wrong clock/acceleration at both rates. |

Latest player/full GUT: **273/279** and **280/289**, exits **1**, same six/nine
baseline identities. All 13 new groups / 100 hardening scenario-rate pairs pass;
fresh MCP observes 100/100 shared cases, 6/6 original policy cases and 10/10
native-entry controls (`r184426936-37`), plus fresh 6/6 native closeout
(`r185847395-38`). No additional independent review was run. Status remains
**in-review**, and the overall gate remains red. Intermediate failures and
existing intermittent landing behavior are disclosed without unrelated repairs.

## Superseding parent closeout

R1–R12 remain closed under final-source focused GUT **13/13** / hundred cases,
and fresh MCP **100/100** plus six original scenarios (`r188028225-43`). R8's
foreign setup now commits every preceding stamp in actual physics callbacks;
matching-step success is observed without relaxing strict contact lifecycle.
Its first skipped-stamp setup failure is disclosed, not an acceptance pass.

Latest full GUT **280/289**, same nine baseline failures; latest player GUT
**272/279**, six baseline failures **plus the previously recorded intermittent
wall-run landing failure**. Player parity therefore remains a failed comparison;
the comprehensive gate is not green. No unrelated repair or acceptance retry.
See [the final results and limitations](parent-final-results.md).
