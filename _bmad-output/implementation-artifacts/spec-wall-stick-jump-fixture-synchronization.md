---
title: 'Synchronize the wall-stick jump test fixture'
type: 'bugfix'
created: '2026-10-06'
status: 'done'
baseline_commit: '5d128486cf695f92dd4a370a6ee4ca6fb594b10f'
context:
  - '{project-root}/AGENTS.md'
  - '{project-root}/_bmad-output/project-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/investigations/wall-stick-jump-intermittent-investigation.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Manual fixture steps can request a new timestep inside an old-rate physics callback. The motor correctly cancels the unsafe hold, but the helper then prepares a jump from cleared stick vectors and mislabels ordinary airborne motion as a failed launch.

**Approach:** Synchronize the helper's rate before fixture creation, validate maintained support before jump preparation, and add rate-transition regression coverage. Test infrastructure only.

## Boundaries & Constraints

**Always:** Edit only the test source below and new implementation/evidence documents. Retain the real player, SubViewport/World3D, geometry, input seam, automatic settling, synchronous manual transactions, both jump branches, and rate restoration. Preserve every existing assertion/tolerance, user change and investigation artifact. Use MCP plus pinned recursive GUT.

**Ask First:** Production/geometry/tuning edits, wider hook synchronization, unrelated fixes, or an MCP exception.

**Never:** Bypass the motor guard; permit stale/airborne wall jumps; accept zero reference; weaken expectations; disable automatic player callbacks; commit, push or discard changes.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
| --- | --- | --- | --- |
| Inherited callback | Opposite-rate callback, request 60/120/60 Hz | Aligned deltas; 18 valid holds | Retain first-loss evidence |
| Supported jump | Held grapple and current support | One impulse, `(0, 5.5, 8)`, one terminal/airborne transition | Original assertions |
| Simultaneous release | Supported JUMP plus grapple release | Same launch | Original release expectations |
| Premature hold loss | Inactive/blocked/stale/unsupported hold | Fail before velocity overwrite/JUMP injection | Explicit GUT failure and failure report |

</frozen-after-approval>

## Code Map

- `tests/player/locomotion/test_wall_traversal_integration.gd` — target at baseline 480; helper 1101; settling 1564; construction 1575. Sole source edit.
- `game/player/motor/player_motor.gd:796–798` — read-only delta safety guard.
- `scripts/player_controller.gd:954–969,1181–1187` — read-only support gates. Production pre-commit support expects N−1; fixture readiness must inspect just-committed N.
- `game/player/locomotion/wall_stick/wall_stick_attachment.gd` — read-only binding `status`/`matches_contact`.
- `_bmad-output/implementation-artifacts/evidence/wall-stick-jump-fixture-2026-10-06/` — new verification artifacts.

## Tasks & Acceptance

**Execution:**
- [x] `tests/player/locomotion/test_wall_traversal_integration.gd` — add first-hold/first-loss/readiness/launch-step evidence, a read-only readiness guard, and opposite-rate regression for both jump modes; establish pre-barrier red evidence.
- [x] Same test — select requested rate, await process then physics before `_new_world`; no waits inside manual bursts.
- [x] New evidence directory above — retain focused repetitions, complete-file/recursive GUT, MCP and preservation results.
- [x] This spec — record separate harness outcomes, diagnostics and remaining failures.

**Acceptance Criteria:**
- Given inherited opposite-rate callbacks, when both jump modes run at 60/120/60, then deltas align, 18 holds persist, readiness passes and each authored launch occurs once.
- Given premature hold failure, when preparing JUMP, then fail before velocity/input mutation and retain earliest evidence.
- Given the existing target/group, when GUT and MCP execute, then original launch, terminal, cleanup and one-commit expectations hold.
- Given the dirty baseline, when finishing, then protected production/user/investigation hashes are unchanged.
- Given recursive GUT, when reporting results, then distinguish unrelated failures and do not claim finite passes eliminate historical intermittency.

## Spec Change Log

- 2026-10-07: Implemented the approved fixture-only correction on dirty `main`. Pre-barrier GUT attempts passed (CLI red not reproduced); complementary live MCP reproduced four first-hold cached-delta failures, which the new guard reported before velocity/JUMP preparation. Frozen intent/boundaries unchanged. Execution evidence: `evidence/wall-stick-jump-fixture-2026-10-06/implementation-record.md`.
- 2026-10-07: Applied the parent step-04 fixture review patches, added a distinct genuine pre-spawn sensitivity control (barrier-only removal red, restored green), and reran final-source GUT/MCP gates. Original evidence remains historical/source-hash identified, frozen intent unchanged and status stays **in-review**; no broader fix or status advancement.

## Design Notes

`physics_frame` precedes node callbacks. Cross process then physics boundaries before spawning, avoiding extra falling ticks. This scheduling control yielded 10/10 investigation launches. Readiness checks the successful, unblocked current hold/contact against its binding, without support resampling.

## Verification

All commands use `rtk` and the pinned 4.7.2 console executable recorded in the investigation.
- GUT base: `--headless --path <checkout> -s res://addons/gut/gut_cmdln.gd -gexit`.
- Add `-gtest=res://tests/player/locomotion/test_wall_traversal_integration.gd` and exact target/regression filter: red before barrier, green afterward. Also run `wall_stick_` filter and complete file.
- Recursive: `-gdir=res://tests/player -ginclude_subdirs`; document unrelated failures.
- `rtk git diff --check` plus SHA-256 preservation comparison.

MCP session `testgame@17187ab35ae57813`: preflight, scan/source verification, current-route launch without autosave, same-helper transitions/readiness in temporary GUT context, runtime/log inspection, cleanup, restore 60 Hz and stop. MCP-native tests do not cover recursive GUT; timed-out logs are not clean-log evidence.

## Implementation / Dev Agent Record

Execution evidence: `evidence/wall-stick-jump-fixture-2026-10-06/implementation-record.md`, raw logs/manifests, `mcp-preflight.json`, `mcp-red.json`, `mcp-green.json`, preservation results and reproducible command/eval documents.

### Initial implementation evidence (historical)

The following initial observations refer to synchronized source SHA-256 `027cd443b6f6bfec8ca208b84050161d86b6c6a32b5408368e57361bd4f7b94f` (and the separately recorded initial no-barrier source). Original logs remain unchanged; follow-up evidence is distinct below.

- Source: only the approved integration test changed. All 278 existing assertion blocks/tolerances remain literally intact; production delta guard, geometry, rates/tuning, dirty user files and investigation artifacts preserved. SHA-256 comparison confirms the other 1,333 protected files unchanged; frozen block unchanged; `rtk git diff --check` passed. No commit/push/sprint edits.
- Pre-barrier: focused GUT **3/3 passing** (1/1 test, 243 assertions each), so CLI red was not reproduced. Live MCP token **72** reproduced **4/6** cached-delta first-hold cancellations at step 4; new explicit guard returned before velocity/JUMP preparation. No fabricated production failure or weaker expectations.
- Corrected GUT: exact target **10/10** fresh-process passes (38 assertions each); opposite-rate regression **5/5** (243 each); negative readiness **3/3** (24 each); `wall_stick_` group **3/3**, **11/11** tests and 515 assertions each. Complete file **22/23, 21/23, 22/23**; corner failed each run and landing also failed run 2. Normal recursive player gate **280/281** / **12670/12671** assertions in each of **3** runs, only existing corner line 118 failing. Recursive shutdown retains 8 ObjectDB / 1-resource leak diagnostics. No unrelated fix attempted.
- Corrected MCP: mandatory session **`testgame@17187ab35ae57813`**; editor filesystem scans/source verification, script-entry refresh (non-imported, not parse proof), and fresh route launch `autosave=false`. Token **74**, frames **37–116**: **6/6** same-helper launches, 18 valid/aligned holds, readiness/prepared/launch/terminal steps **21/22/22/22**, reference **0.5**, impulse count **1**, submitted **`(0,5.5,8)`**, one terminal/commit and airborne cleanup. Negative smoke frames **116–124** rejects both modes with explicit failures and no input/velocity/step mutation. Seven fixture players inspected with automatic physics/private worlds intact; route runtime Player inspected successfully.
- MCP diagnostics/cleanup: two game-log reads timed out after 5 seconds; log cleanliness unknown. Transient eval compile/liveness failures were corrected/relaunched and recorded separately; no visual claim or native-test coverage claim. Editor logger cursor **6→6**, zero new entries; six historical errors/twelve warning rows retained (seed warning now line 1924). Eight tracked fixture/probe objects and temporary GUT/suite freed, runtime 60 restored, stop observed and final editor **ready/stopped** on original route.
- Initial handoff: review/status advancement belonged to the parent; the spec was then **in-progress** and has since been advanced by the parent to **in-review**. Whole-file/recursive corner failure, isolated landing observation and incomplete game logs remain disclosed. Passing finite samples do not eliminate historical intermittency or prove the historical CLI cause.

### Parent step-04 follow-up — 2026-10-07

- Approved review patches stay within the sole test source and new evidence; frozen section untouched, status remains **in-review**. Added pre-spawn requested/cached oracle and report, first-hold = entry+1 assertion, delta/commit alignment in readiness, and explicit non-jump failure finish before scripted exit mutation. Added shared real-fixture guard capture for mismatched delta, incomplete/prior-loss history, and both destroyed-support preparation modes in one still-active pre-transaction window; retained inactive-after-release scenario. Existing original assertion blocks stay literal; optional speed/drift and nonzero-tangent strengthening uses the existing tolerances. Removed one new unused local after MCP warning; no production fields/contact/result/tuning overrides.
- Genuine additional sensitivity control: patch removed **only the helper's two barrier awaits**, keeping the new oracle. MCP scan/read confirmed the control. Pinned fresh `follow-up-red-regression-*` runs were **3/3 expected red**, **279/297 assertions** each, exit 1; all six pre-spawn observations measured actual old cached delta vs the new requested rate. Control source hash **`48b479de08ed49e6126b2d60713c9cd8bf62a72f2397a7b1e11cc3e865f94198`**. Restored barrier via patch, MCP verified source/scan/cursor, and matched intact source **`dd3928ffd6f877e5fd9ebcccaefecd32b9e65fadacd58d596255f29778ac1b5b`** passed focused regression **5/5**, **297 assertions** each. Initial no-CLI-red attempts remain explicitly historical and unchanged.
- Final source SHA-256 **`1ca5f4c37e7dd3f7da20b6b9b5175b507da30f49c737855be72db293a1934e04`**. MCP session **`testgame@17187ab35ae57813`**, token **77**, loaded hash matches disk, barrier present, 2,083 lines. Same-helper live matrix frames **29–106**: **6/6**, pre-spawn aligned/in-physics, entry/first-hold **3/4**, 18 valid/aligned holds, readiness/prepared/launch/terminal **21/22/22/22**, references **0.5/3**, one **`(0,5.5,8)`** launch/terminal/commit and airborne cleanup. Actual-release guards **2/2** (frames 106–116); supported delta/history/destruction guards **8/8** (frames 116–124), all reject explicitly before velocity/step/command/pending-input mutation. Both destroyed-wall guards run at step **21**, active=true but supported=false, grapple remains held and no jump is injected.
- Final MCP cleanup: eight automatic-physics/private-world fixture players inspected; **10→0** tracked objects, temporary contexts absent, runtime **60 / 1/60** restored, stop observed and original route editor **ready/stopped**. Cursor **6→6**, zero new logger entries; six historical errors/twelve warning rows retained, new unused-local warning removed, seed warning now line 2071. **Two additional follow-up game-log timeouts**, distinct from the initial two; log cleanliness stays unknown. Token 75 liveness probe failure recovered through stop/relaunch; token 76 intermediate observations and final token 77 evidence retained separately. No visual/native suite coverage claim.
- Final-source pinned GUT under **`follow-up-final-source-*`**: original target **10/10** fresh-process passes (**40** assertions each), transition **5/5** (**297**), both readiness tests **2/2 × 3** (**151**), full `wall_stick_` group **12/12 × 3** (**710**). Whole-file **23/24 (1058/1059), 22/24 (1050/1059), 23/24 (1058/1059)**: corner in all runs, plus unchanged landing in run 2. Normal recursive gate **281/282**, **12869/12870** assertions, 21 scripts in each of **3** runs, only unchanged corner line 118; shutdown retains **8 ObjectDB / 1-resource** diagnostics. No unrelated fix attempted. Intermediate partial 120-second recursive timeout is retained and not counted as a complete gate; the separate final batch completed with a 600-second wrapper allowance.
- Follow-up evidence stays under **`follow-up-*`** prefixes in the same new directory: complete raw final MCP response/recipe, separate red/green/final GUT logs/manifests and exact commands, source snapshots, hash-verified two-line-only control, delta and preservation. Final preservation confirms **1,333/1,333** other protected files unchanged, zero missing files, **278/278 original** and **329/329 reviewed-initial** assertion blocks literal/ordered, frozen block unchanged and HEAD unchanged. **+170/−23** source-line delta versus the reviewed snapshot is retained in `follow-up-source-diff.patch.txt`; `rtk git diff --check` passes. Retained MCP evidence consistency verification passes **67/67**, not native suite coverage. No further delegation/workflow activation/deferred-work/production/hooks/sprint/commit/push changes.
- Current handoff: requested review patches and validation complete; parent owns further review/status advancement and spec remains **in-review**. Separate corner/landing failures, shutdown leaks, game-log timeouts and historical intermittency limitations remain explicit; no global-green or historical-cause proof claim, and broader fixes need separate approval.
- Post-GUT final MCP recheck recorded in `follow-up-mcp-final-editor.json`: filesystem scan settled (135 classes, delta 0), final script read and unchanged original route hierarchy, configured rate 60, editor **ready/stopped**, cursor **6→6** with zero new entries. No additional game-log or visual claim.

### Review completion

Three isolated reviews and their relevant fixture patches are complete. [Review resolution](evidence/wall-stick-jump-fixture-2026-10-06/review-triage.md) records the corrected coverage gaps and final parent checks. No unresolved implementation blocker remains; status is **done for this fixture correction**, not a claim that the broader recursive gate or historical intermittency is globally resolved. Source remains test-only, the frozen intent and original assertions remain intact, and existing dirty work is preserved. No local commit/push was made because the approved boundaries explicitly prohibit them.

## Suggested Review Order

**Fixture synchronization**

- Synchronize the requested rate before spawning, then verify the actual callback delta.
  [`test_wall_traversal_integration.gd:1220`](../../tests/player/locomotion/test_wall_traversal_integration.gd#L1220)

**Maintained support and fail-closed preparation**

- Inspect current successful hold, bound support, command and aligned delta without resampling gameplay.
  [`test_wall_traversal_integration.gd:1476`](../../tests/player/locomotion/test_wall_traversal_integration.gd#L1476)
- Reject invalid setup before velocity overwrite or input injection.
  [`test_wall_traversal_integration.gd:1547`](../../tests/player/locomotion/test_wall_traversal_integration.gd#L1547)
- Preserve earliest loss instead of letting scripted non-jump exits obscure it.
  [`test_wall_traversal_integration.gd:1318`](../../tests/player/locomotion/test_wall_traversal_integration.gd#L1318)

**Regression coverage and evidence**

- Exercise inherited opposite-rate callbacks with both authored jump branches.
  [`test_wall_traversal_integration.gd:513`](../../tests/player/locomotion/test_wall_traversal_integration.gd#L513)
- Reject invalid support and history while proving no gameplay or pending-input mutation.
  [`test_wall_traversal_integration.gd:573`](../../tests/player/locomotion/test_wall_traversal_integration.gd#L573)
- Compare genuine barrier-removal reds, corrected GUT gates and separately observed live MCP outcomes.
  [`implementation-record.md:87`](evidence/wall-stick-jump-fixture-2026-10-06/implementation-record.md#L87)
