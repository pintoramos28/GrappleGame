---
title: 'Independent, collision-safe wall sticking'
type: 'bugfix'
created: '2026-10-01'
status: 'done'
baseline_commit: '89ead0989f319a80007cb9835fea056c5ca8bf04'
context:
  - 'AGENTS.md'
  - '_bmad-output/project-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Wall sticking shares wall-running entry tuning and direction policy, injects horizontal along-wall jump velocity, and pins the player to an obsolete world position on moving walls.

**Approach:** Give grapple-assisted sticking independent forward-held input/tuning and a wall-local attachment. Resolve carry through the sole player motor; jump launches upward and outward only.

## Boundaries & Constraints

**Always:** Preserve existing uncommitted work. Initial stick maximum is 100 m/s. Releasing forward resumes a still-held, valid grapple. Use immutable command facts, immutable authored definitions, value-only contact snapshots, and private weak supporting-body references. Keep one motor commit per physics step. Validate through pinned recursive GUT and live Godot AI MCP separately.

**Ask First:** Retuning wall running; changing production mover types or route geometry; discarding dirty editor state; changing the approved input, release, or jump policy.

**Never:** Infer the contacted wall from the grapple anchor; poll hardware in states; directly snap the player to a hold position; globally relax wall-run contact continuity; silently repair unrelated baseline failures; claim MCP-native tests execute GUT.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|---|---|---|---|
| Entry | Held move_forward and grapple, active grapple, airborne supported wall | Stick without along-wall input alignment | Reject unsupported contact |
| Speed | Finite incoming total velocity relative to wall | Inclusive independent 100 m/s maximum; no minimum | Reject over-limit/nonfinite values |
| Hold | Same valid wall, forward and grapple held | Maintain zero relative movement while wall translates | Collision-safe carry, not world-position pinning |
| Forward release | Grapple remains held and valid | Detach stick, preserve movement, resume grappling | No grapple terminal |
| Jump | Fresh jump and valid support, including simultaneous input release | Cancel stick/grapple once; upward plus horizontal outward launch | No retained/injected/inherited horizontal tangent |
| Support interruption | Destroyed/invalid support, incompatible geometry or blocked carry | Explicit safe detachment; never penetrate to preserve hold | Idempotent cleanup |
| Motion discontinuity | Nonfinite or teleport-like support motion | Reject unsafe attachment motion | Never treat teleport as continuous carry |
| Camera turn | Same attachment with held actions | Keep sticking | Do not substitute another wall |

</frozen-after-approval>

## Code Map

- `game/player/input/player_command_frame.gd`, `player_input_source.gd` -- immutable forward-action fact and test seam.
- `scripts/player_controller.gd`, `player_wall_stick_state.gd` -- stick entry, HSM transition, attachment lifecycle and jump.
- `game/player/locomotion/contact/player_contact_provider.gd`, `game/shared/physics/contact_frame.gd` -- trustworthy selected physical support.
- `game/player/motor/player_motor.gd`, `player_motor_submission.gd`, `player_motor_commit_result.gd` -- exclusive hold solve and committed evidence.
- `scenes/player.tscn` -- compose stick-only definition without changing run overrides.
- `tests/player/{input,contact,motor,locomotion}/` -- affected regression suites; `tests/levels/test_traversal_validation_route.gd` -- route compatibility.

## Tasks & Acceptance

**Execution:**
- [x] `game/player/input/player_command_frame.gd`, `player_input_source.gd` -- capture literal move_forward hold separately from net axis, including injected/opposing inputs and focus reset.
- [x] `game/player/locomotion/wall_stick/definitions/wall_stick_definition.gd`, `wall_stick_definition.tres`, `scenes/player.tscn` -- compose validated immutable 100 m/s stick maximum and independent 5.5 up/8 away jump speeds.
- [x] `game/player/locomotion/contact/player_contact_provider.gd`, `game/shared/physics/contact_frame.gd` -- expose selected support facts and a narrow binding seam; preserve legacy run selection/continuity.
- [x] `game/player/locomotion/wall_stick/wall_stick_attachment.gd` -- bind actual collider/shape, local contact/normal/player stand-off; sample fresh motion and validate lifetime/discontinuity.
- [x] `game/player/motor/player_motor_submission.gd`, `player_motor.gd`, `player_motor_commit_result.gd` -- replace unsafe hold position assignment with collision-resolved carry; report blocked movement and prevent double carry.
- [x] `scripts/player_controller.gd`, `player_wall_stick_state.gd` -- apply forward-held independent entry/hold policy; add explicit return-to-grapple transition; cancel jump carry and remove tangent launch.
- [x] `tests/player/input/`, `tests/player/contact/`, `tests/player/motor/`, `tests/player/locomotion/` -- test the matrix, independence, real moving-wall collision and one commit; replace superseded stick assertions only.
- [x] `tests/levels/test_traversal_validation_route.gd`, traversal guide -- migrate intended stick input/jump expectations; report geometry incompatibilities rather than retune running.
- [x] `tests/test_wall_stick_mcp.gd`, story evidence -- add useful editor-schema adapter, run both gates, record diagnostics and limitations separately.

**Acceptance Criteria:**
- Given different run/stick maxima, when either changes, then only that mode's entry eligibility changes.
- Given continuous approaching/receding/reversing support motion, when sticking is held, then the player remains on the same wall side without penetration at 60/120 Hz.
- Given a distinct grapple anchor and wall, when either moves, then stick carry follows the wall only.
- Given a supported stick jump, when committed, then horizontal tangent velocity is zero and both attachments end exactly once.
- Given forward release with a live held grapple, when processed, then grappling resumes without termination or immediate relatch.
- Given existing run cases, when the new feature is exercised, then run tuning, momentum, continuity and jump behaviour remain unchanged.

## Spec Change Log

- 2026-10-01: Implemented the approved scope; no frozen intent changes. Superseded stick input, world-pin/teleport and tangent-jump assertions were migrated. Existing baseline and route-geometry failures remain identified, not repaired.

## Design Notes

Entry uses incoming submitted velocity, not collision-reduced committed velocity. Wall-point motion supplies the relative frame. Active attachment validation is separate from legacy world-point continuity: wall translation alone is not a contact switch. Jump uses desired-minus-reference through the existing impulse mechanism to remove tangent momentum. Collision wins over attachment; mover teleports are not guaranteed-safe continuous motion.

Jolt's transform-moved StaticBody query pose can lag the node pose during physics callbacks. Bound support exclusion is transaction-local; carry preserves the selected shape's local face/stand-off and sweeps against other bodies, with platform settings/exceptions restored after the sole commit. Settled and obsolete-pose overlap observations are reported separately. Live verification uses a fresh process; the editor-schema adapter is not behavioral/GUT coverage.

## Verification

- Canonical full regression: `rtk proxy "C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`. Establish fresh baseline first; identify unrelated failures.
- MCP: inspect, rescan/reload affected resources, native adapter tests with cache caveats, live engine-driven moving-wall/input/jump smoke, game/editor logs and final readiness. Never conflate adapter results with GUT.
- Preservation: `rtk git diff --check`; compare against pre-existing edits and unchanged wall-run tuning.

## Dev Agent Record

- User approved working over the dirty checkout, preserving existing changes. Confirmed 100 m/s maximum and forward release resuming a valid held grapple.
- User approved the full written spec and keeping its 1,695-token cohesive scope together; the frozen intent is locked.
- MCP preflight: `testgame@17187ab35ae57813`, Godot 4.7.2, ready/stopped, `res://scenes/player.tscn`. Operations: session list, editor state/logs, root list, player properties, stick script symbols; prior read-only investigation inspected hierarchy, script, capsule and WallProbe. Ten retained warning rows; no error rows reported. No gameplay validation yet.
- Implementation complete, left `in-progress` for parent-owned review. Added immutable forward-held facts and independent locked definition, shape-bound weak attachment/provider facts, collision-resolved exclusive hold, explicit forward-release return to grapple, and outward/up-only stick jump. No additional agents, review, commits or remote operations.
- CLI/GUT: fresh baseline 229/238 (9 failures, 11,749/11,769 assertions); final focused 131/133 (2 baseline failures, 4,623/4,630 assertions); final full 246/255 (same 9 failing test identities, 11,985/12,005 assertions). Both final commands exit 1 due to the documented baseline failures. All 17 added tests pass; attachment 12/12, contract 24/24 and input-source 18/18.
- MCP final session `testgame@17187ab35ae57813`: scans settled (131 classes); resource/script/property inspections; targeted undoable in-memory definition assignment without scene save/reload; native `wall_stick` schema adapter 3/3, 15 assertions, with preload-cache warning retained. Fresh custom launch with `autosave=false`; live tree/node inspection, `game_eval` real-engine motion/interruption checks and simulated opposing directional inputs; final game-log run `r105520293-20`.
- Live motion at 60/120 Hz passed translation/reversal/stop/yaw/camera turn with one entry, zero terminals/blocked carry, one commit, zero sampled settled capsule overlaps, maximum errors 2.462184056e-8/1.298030838e-8 m, and minimum stand-off 0.450933/0.450887 m. A distinct moving grapple anchor displaced 0.30000004 m while the player stayed still. Obsolete-query-pose overlap counts 36/72 are explicitly separate.
- Live interruptions 14/14: release preserves exact commit velocity and resumes grapple without terminal/relatch; simultaneous jump/releases launch `(0,5.5,8)` with one terminal; obstruction, destruction, disabled/replaced shape and teleport safely detach. Final game logs contain 17 info entries, no warnings/errors or drops. Final editor has ten retained warnings, no errors; rate restored to 60, inputs/fixtures cleaned, playback stopped and editor ready. No visual/feel acceptance claimed.
- Preservation: `rtk git diff --check` clean; 26 read-only checks confirm legacy run-related source/selection and recorded user tuning remain intact, and route differs only in stick guide text. Frozen approval block LF-normalized SHA-256 remains `a5f7213f35fd07e64e5582ba99b73139432ecc5e51a55f54d9e9bea1c6324c27`. Route finish remains incompatible in the existing failing challenge; geometry/run tuning were not adjusted.
- Reproducible results, commands, MCP operations, diagnostics, tooling iterations and limitations: [verification evidence](evidence/wall-stick-attachment/verification.md), [live result summary](evidence/wall-stick-attachment/mcp-results.json), [full GUT log](evidence/wall-stick-attachment/full-gut-complete.log), [focused GUT log](evidence/wall-stick-attachment/focused-gut-complete.log).
- Parent review hardening (2026-10-01, append-only): completed all nine localized findings while leaving the spec **`in-review`** and frozen scope unchanged. Added weak dirty-only geometry listeners with deterministic cleanup; one-active-owner/one-shape full-body-exclusion contract; provider-owned original-support corroboration independent of the run winner; author motion baseline with separately checked physical query catch-up; owner-local/native/static surface point velocity; binding-relative cumulative tilt checks; fail-closed null/invalid composition/entry; physical positive controls for existing negative guards; and an actual approval-hash pass/exit assertion. No run retuning, production mover/route-geometry changes, new agents/review, commits, remote operations or dirty scene discard/save/reload.
- Hardening geometry limitation: compound bodies, including stationary compound StaticBody3D supports, cannot enter sticking. Adding active sibling owners/shapes invalidates existing stick before another hold/exclusion. Disabled unrelated owners remain allowed; global shape-index **1 -> 0** renumbering preserves attachment at both rates. Legacy run source/picker/tuning remain unchanged. Narrow physics-frame bound-hold delta mismatch guard rejects 2x engine delta with zero movement/one commit; pure idle unit algebra is not claimed as collision proof.
- Final hardening CLI/GUT supersedes the earlier final counters: focused **136/138**, **4,718/4,722 assertions**, **17.229 s**, exit **1**; full recursive **251/260**, **12,066/12,083 assertions**, **77.872 s**, exit **1**. Five hardening tests and all 17 initial added tests pass. Read-only comparison asserts the same two focused/nine full baseline failing test identities, with no unrelated repairs; full exit retains eight ObjectDB leaks/one resource in use. Logs: [focused verified](evidence/wall-stick-attachment/review-hardening-focused-verified.log), [full verified](evidence/wall-stick-attachment/review-hardening-full-verified.log), [baseline identity comparison](evidence/wall-stick-attachment/review-hardening-gut-comparison.json).
- Final hardening MCP session **`testgame@17187ab35ae57813`**, fresh game run **`r125129029-25`** (editor token 24), mandatory preflight/scan/script/resource/property/API inspection, runtime tree/node inspection, `game_eval`, action `input_sequence`, logs and stop. **36/36 new cases** at 60/120 Hz, **2/2 prior motion**, **14/14 prior interruptions** pass. Schema adapter separately **3/3**, 15 assertions/3 ms, preload-cache warning retained; not GUT/runtime coverage. In-place growth: zero further holds/one detach, with externally-created overlap honestly recorded. Two walls: neighbor wins legacy selection while original physical support persists with one entry/zero terminals until original support is removed; 12 queries/value-only frames. Pre-entry 20 m/s at 120 Hz: first carry **0.166666672 m**, zero target error; 4 m entry teleport refused. Native/owner velocity cases are 12 m/s, Static surface approximately 12.4 m/s, adjacent native motion not double counted. Null/invalid entries fail after physical positive controls.
- Final live motion stand-off >= **0.4508871317 m**, target error <= **2.462184056e-8 m**, zero sampled settled overlaps/native recovery, one commit; release velocity error **0**, resumed grapple/no terminal/relatch; jump **(0,5.5,8)** with one terminal. Settled observations cover **114/115** and **139/224** holds, explicitly missing **1/85** steps; full IDs are captured. Blocked detachment commit IDs **20/32** receive latched-pose settled-space follow-up observations, zero overlap. This is sampling, not every-step/historical-world or visual proof. [Full hardening MCP capture](evidence/wall-stick-attachment/review-hardening-mcp-results.json).
- Hardening diagnostics: corrected earlier line-49 inferred-Variant source; MCP no-op reload of that test is diagnostic-clean and final fresh file-path scripts instantiate. Investigated attachment diagnostic fallback 43 as pathless `class_name` global-class conflict, stopped that tooling probe, and verified proper file-path code in final GUT/fresh runtime without editor restart/discard. Final game: **17 info, 0 warnings/errors/drops**; editor retains ten prior warning subjects plus two historical corrected-source error rows, **zero new entries since cursor 2**. Cleanup observed 60 Hz, actions released/fixtures freed, playback stopped, editor ready/current player scene and five tabs preserved.
- Hardening preservation: **27/27** including approval SHA, exit 0; in-memory altered-expected-hash negative control correctly exits 1 without touching frozen content. `rtk git diff --check` clean; approved SHA remains `a5f7213f35fd07e64e5582ba99b73139432ecc5e51a55f54d9e9bea1c6324c27`. Existing deferred telemetry note is stale because current methods use submitted velocity/wall-point frame; parent owns backlog reconciliation, user-owned `deferred-work.md` was not edited. No implementation blocker remains; baseline/route completion limitations remain. All per-finding dispositions/repro cases and evidence limits are appended in [verification evidence](evidence/wall-stick-attachment/verification.md).
- Parent closeout (2026-10-01): localized review safeguards accepted after inspecting final source/repro results; [triage](evidence/wall-stick-attachment/review-triage.md) records every disposition and limitation. Independently reran read-only GUT identity comparison (all checks true), preservation (27/27), and whitespace checks. MCP recheck observed ready/stopped editor, current player scene, unchanged run 100/3/10/4/0, assigned stick definition, and no new editor entries since cursor 2. Reconciled the stale telemetry backlog append-only and recorded remaining baseline failures without changing prior text. All tasks complete; feature status `done` does not mean the full regression gate or authored route passes. No commit/push was created because the approved task includes existing user edits and does not authorize committing them.

## Suggested Review Order

**Entry and interruption policy**

- Start here: independent forward-held, grapple-assisted wall-relative entry.
  [`player_controller.gd:1075`](../../scripts/player_controller.gd#L1075)
- Supported jump wins releases; forward release resumes the valid grapple.
  [`player_wall_stick_state.gd:4`](../../scripts/player_wall_stick_state.gd#L4)
- Replace launch momentum with upward and outward velocity, never horizontal tangent.
  [`player_controller.gd:778`](../../scripts/player_controller.gd#L778)

**Physical attachment and safe carry**

- Bind the actual shape with weak lifetime and separately validated motion baselines.
  [`wall_stick_attachment.gd:43`](../../game/player/locomotion/wall_stick/wall_stick_attachment.gd#L43)
- Reject geometry changes, invalid support and unsafe motion before another hold.
  [`wall_stick_attachment.gd:91`](../../game/player/locomotion/wall_stick/wall_stick_attachment.gd#L91)
- Corroborate the bound wall without changing legacy wall-run selection.
  [`player_contact_provider.gd:996`](../../game/player/locomotion/contact/player_contact_provider.gd#L996)
- Resolve collision-safe carry in the sole motor commit, without position snapping.
  [`player_motor.gd:1198`](../../game/player/motor/player_motor.gd#L1198)

**Input, tuning and regression evidence**

- Capture literal forward hold independently of opposing movement cancellation.
  [`player_input_source.gd:135`](../../game/player/input/player_input_source.gd#L135)
- Independent immutable stick maximum starts at the approved 100 m/s.
  [`wall_stick_definition.gd:12`](../../game/player/locomotion/wall_stick/definitions/wall_stick_definition.gd#L12)
- Real-engine movement, release and pure-jump regressions run at both rates.
  [`test_wall_stick_attachment.gd:47`](../../tests/player/locomotion/test_wall_stick_attachment.gd#L47)
- Targeted safety reproductions share fixtures across GUT and live MCP checks.
  [`test_wall_stick_review_hardening.gd:11`](../../tests/player/locomotion/test_wall_stick_review_hardening.gd#L11)
- Separate baseline-failing GUT results, live MCP observations and sampling limits.
  [`verification.md:113`](evidence/wall-stick-attachment/verification.md#L113)
