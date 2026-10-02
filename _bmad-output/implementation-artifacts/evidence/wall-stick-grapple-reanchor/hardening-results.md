# R1–R12 hardening results — 2026-10-02

**All twelve localized findings are patched and verified.** The approved spec
remains **in-review**, and all work remains uncommitted. No further independent
review, agent dispatch, commit, push, remote operation, production mover/tuning
change, or unrelated baseline repair was performed.

The comprehensive regression gate is **still red**. Its latest full run has
the exact same nine failing identities as the preserved fresh baseline, not
zero failures. Read-only [comparison results](hardening-test-comparison.json)
pass all 16 checks and identify both result sets separately.

## CLI/GUT results

Pinned engine and recursive command are unchanged from the original README.
Use `-gdir=res://tests/player` for the player gate and `-gdir=res://tests` for
the full gate, always with `-ginclude_subdirs -gexit` through `rtk proxy`.

| Accepted final run | Passing / total | Failing | Assertions | Exit | Duration |
|---|---:|---:|---:|---:|---:|
| `hardening-player-gut-settled.*` | 273 / 279 | Same six player baseline identities | 12379 / 12388 | 1 | 61.726 s |
| `hardening-gut-settled.*` | 280 / 289 | Same nine full baseline identities | 13035 / 13052 | 1 | 101.956 s |

- All **13** new GUT test groups in
  `tests/player/grapple/test_wall_stick_reanchor_hardening.gd` pass. They execute
  **100 unique scenario/rate pairs**, all passing in both final gates. The
  earlier 12 re-anchor and four active-visual tests also remain passing.
- Final logs contain no script parse/load/compile errors. The existing active
  motor-frame rejection still reaches `baseline_active_frame`; ownership checks
  do not replace that guard. Negative-path motor diagnostics are intentional.
- Both teardowns observe configured **60 Hz** and actual physics delta
  **0.01666666666667 s** before later manual-step suites run. The new suite
  restores input/rate and waits for a real physics/idle frame; legacy assertions
  and wall-running code were not modified.
- The full shutdown still reports eight leaked ObjectDB instances and one
  resource in use, as in the preserved baseline. This is not a clean-shutdown
  or green-regression claim.

## Complementary MCP results

Session: **`testgame@17187ab35ae57813`**, Godot **4.7.2-stable**.

Read-only preflight observed the original traversal route, ready/stopped,
with no new editor entries since cursor **5**. Implementation/validation used
MCP script reads, class/API inspection, dependency scans/reload checks,
`project_run(custom, autosave=false)`, runtime scene-tree inspection,
`editor_manage(game_eval)`, input cleanup simulation and game/editor logs.

| MCP observation | Result | Capture |
|---|---:|---|
| Fresh final shared hardening cases, 60/120 Hz | **100 / 100** | [`r184426936-37`](mcp-hardening-final-live-cases.json) |
| Original ordinary / STATIC / MOVING live matrix with stronger visuals/clock | **6 / 6** | [Same fresh run](mcp-hardening-final-existing-live.json) |
| Native support entry: owner-local/static/Animatable/Character/Rigid, 60/120 Hz | **10 / 10** | [Same fresh run](mcp-hardening-native-entry.json) |
| Additional fresh native continuation/release closeout, three body types × two rates | **6 / 6** | [`r185847395-38`](mcp-hardening-closeout.json) |
| Editor-native `wall_stick` adapter | **4 / 4, schema/source only** | [Reload/adapter record](mcp-hardening-validation.json) |

The adapter does not recurse into GUT and its preload-cache warning remains.
The 100 live cases share the framework-neutral harness with GUT; the comparator
confirms identical case identifiers actually executed, not independent-oracle
or full-suite parity. Frozen transaction/sample probes are identified as such;
continuation/release cases advance real engine physics with the production
player, motor, HSM and presentation nodes. Their controls use the fixture input
injection seam, not a new claim of standalone production-input acceptance.

### Native/visual/clock measurements

- Actual Animatable, Character and Rigid supports translate; Animatable/Rigid
  also yaw. Owner-local shape motion is added separately. Native point velocity
  is authoritative; no body-pose displacement is added a second time.
- Across final native cases: anchor/actual marker/point-velocity maximum error
  **0**; assigned-cylinder rope endpoint error at most **2.8493575428e-6 m**;
  **one motor commit**, **zero sampled overlaps**, and **zero missing active
  visual samples**. Continuation displaces the anchor over 0.1 m, forward release
  keeps the same occurrence/revision, old-target deletion has no effect, and
  new-target deletion terminates exactly once with cleared endpoints.
- The Animatable counterexample to the old static branch differs by about
  **1.04480 m/s**, rather than trivially agreeing because the support is still.
  The test-only physics-callback mover disables `sync_to_physics` so its
  authored motion is not restored away; no production mover was changed.
- Hidden marker/rope, detached or replaced assigned mesh, and wrong cylinder
  height all trigger negative controls at both rates. A wrong assigned cylinder
  produces **0.6344–0.6365 m** endpoint error despite retained node transforms.
  Restoring actual geometry/visibility supplies a positive control.
- Release-clock cases preserve elapsed **0.6 s** exactly to tolerance and use
  the expected pull curve at that clock. With test-only pull multiplier 0.5,
  actual/expected acceleration is **14.0000001 m/s²** at both rates; resetting
  the timer would produce approximately **25.1111 / 24.8889 m/s²** instead.
  Native cases also assert clock/curve agreement and the forced-reset contrast.
- Visibility/assigned-geometry measurements are not a new framebuffer capture
  or acceptance of normal-view readability, movement feel or route completion.
  Earlier diagnostic captures and their occlusion limitations remain intact.

## Verified dispositions

All case names below refer to the shared harness
`tests/fixtures/wall_stick_reanchor_hardening_cases.gd` and were observed in both
the accepted GUT gates and the fresh MCP result set at **60 and 120 Hz**.

| Finding | Verified localized safeguard / regression |
|---|---|
| R1 — closed | Incoming response severity is queried against occurrence-captured tuning without overwriting the previous sample. At actual 7.5 m/s, `response_tighten` changes threshold 10→5 and terminates once; `response_relax` changes 5→10 and stays active. Valid test-only tolerances 3/10; production 250 unchanged. |
| R2 — closed | Gap steps scale only surface displacement allowance. `gap_safe` accepts 0.4 m over four samples with velocity 6/12 m/s; `gap_oversized` rejects 1.2 m. Independent speed, rotation-rate, scale and tilt controls still reject; default one-step carry bound is unchanged. |
| R3 — closed | Animatable is excluded from the Static conveyor branch and uses native point velocity plus owner-local motion. All `native_animatable` cases and the old-formula counterexample pass. |
| R4 — closed | Legacy explicit sampling rejects null/malformed fresh responses before cache or elapsed mutation. Ten NaN/Inf/invalid-enum controls, with valid moving-tracking positives, terminate once and clear visuals. |
| R5 — closed | Installed-binding alias is refused during prepare and mutated commit. `alias` / `mutated_alias` preserve sample, revision, clock, scope and motor baseline, and explicitly verify the original binding is still live and unreleased. Null/stale controls also fail typed. |
| R6 — closed | Detached live original is rejected at both boundaries. `detached_original` preserves atomic state; reattaching the same target permits the owned positive commit. |
| R7 — closed | Fresh original contract and installed geometry/pose validity are queried without mutating legacy sampling caches or installed status. Twelve before/after invalidation/removal/eligibility/malformed/scope/identity cases plus installed resize/scale controls pass; restored-valid originals can commit. |
| R8 — closed | Own-body/motor and last successfully completed step are required before baseline arming. `foreign_motor` matches the completed step yet leaves both baselines intact; the owned positive succeeds. `wrong_completed_step` uses a real later physics commit and is refused. |
| R9 — closed | Released carry cannot copy its contact, before or after unobserved shape resize. Historical status remains unchanged; released lifetime is explicit. |
| R10 — closed | Six real Animatable/Character/Rigid continuation/release cases pass in both gates and repeat in a separate fresh MCP process. Test-only movers use real engine native velocity; production types stay intact. |
| R11 — closed | Active marker and rope must be visible in-tree with valid actual assigned sphere/cylinder geometry; endpoint measurements use that assigned cylinder. Ten negative-control cases detect hidden, detached, replaced and wrong-height meshes with restored positives. |
| R12 — closed | Release-step clock and independently calculated resolved curve are checked exactly to tolerances, including the first detachment step. Forced timer reset produces distinguishable elapsed/acceleration values at both rates. |

R7 correctly rejected an older native-entry fixture that disabled its wall while
retaining a grapple bound to that wall. Only that focused fixture setup now
starts from a valid separate ordinary tether. Its native-velocity, relative
**99 m/s** positive and **over-100 m/s** negative assertions remain intact.
Ordinary resolution, explicit-component acquisition precedence and production
mask policy were not broadened or replaced.

## Retained unsuccessful attempts and diagnostics

- `hardening-focused-attempt1.*` is an argument-token failure, not an executed
  regression. Other focused attempts retain the transient fixture type/setup
  errors and the missing original-scale rejection corrected before final runs.
- `hardening-player-gut.*` has source-load errors while MCP no-op reload writes
  overlapped it; it is not accepted validation. Subsequent gates had no source
  writes/reload overlap. No definitive root cause is claimed from that overlap.
- Intermediate player/full runs show the wall-run landing failure as well as
  baseline failures. The same unchanged landing test also failed in preserved
  pre-hardening `focused-gut-attempt1.stdout.log` and prior attachment evidence
  `review-hardening-full-final.log`. Its cause was not repaired here. After
  new-suite rate settling, the final two gates match baseline identities; all
  intermediate logs remain, and intermittent behavior is not concealed.
- MCP no-op dependency reloads returned fallback **error 43**, not successful
  parsing. Fresh CLI and fresh MCP game processes validate current dependencies.
  An evidence-only write attempted after launch was refused `EDITOR_PLAYING`;
  evidence was saved after stop. No runtime/source failure is hidden by that.

## Preservation and final state

Read-only [preservation helper](verify-hardening-preservation.py) checks both
approved snapshots. The original **437-file** snapshot's SHA-256 remains
`675b800999be156f9f34b25a4749ad6ab981a5823d35782385f72872c5cfa14b`;
none of its files is missing. The **480-file** hardening-start hash set is not
replaced. Only the ten listed existing localized source files differ; original
README/triage/spec prefixes are preserved and new evidence is appended.

The expanded byte comparison covers **all 195** prior evidence/spec files and
**all 28** captured scene/resource/project files, beyond the previously recorded
39/27 subsets. All equal the approved snapshot. The unchanged earlier
preservation gate passes **27/27**. HEAD remains
`89ead0989f319a80007cb9835fea056c5ca8bf04`, and frozen intent SHA-256 remains
`14e2d5fa5986b4f9dbebacd48b0e20c444724e582d8d3cc871f48d426a58504f`.

Final MCP closeout observed original route **ready/stopped**, settled class scan
**135**, no new editor rows since cursor 5, and only helper registration in the
fresh game log, without dropped lines. Simulated actions, injected parent-fixture
input and right mouse are released; physics is **60 Hz**. Player assignments and
authored stick/grapple definitions were inspected through MCP: 100 m/s stick,
5.5 up/8 out jump, 35 m range, 60 m/s² initial pull, 22 m/s grapple cap, 250 m/s
severe threshold. No user scene was saved, discarded or force-reloaded.

Final whitespace, diff-only helper and preservation records are saved separately
in `hardening-preservation.json` and `hardening-worktree-diff.json`. Baseline
failures, intermittent landing behavior, reload limitations and readability/feel
remain disclosed rather than counted as acceptance passes.

## Parent readback and fixture timing correction

Parent source/read-only preservation checks passed, and the accepted `hardening-gut-settled` log comparison confirmed **280/289**, same nine baseline identities. The first comparison mistakenly selected the retained intermediate `hardening-gut` stem; its **279/289** result with the documented intermittent landing failure is retained and was not treated as the accepted final run.

Fresh parent MCP run **`r186878090-39`** passed **31/32** selected cases: both fresh-response verdicts, all six native continuation/release cases, clocks and other selected guards passed, but `foreign_motor@120` failed its matching-step **setup control**. A fixed six-trial diagnosis repeated that setup failure while observing correct foreign rejection, unchanged original/both baselines and successful owned commits every time. [Failed capture](parent-hardening-before-fixture-fix.json) is not an acceptance pass.

The fixture now commits a fresh production-player motor at the exact needed player-local stamp in a real physics callback. Equal await counts between independent fixtures are no longer assumed to mean equal stamps. No production guard or assertion was weakened. Superseding final dual-gate results follow after this localized test correction.

### Superseding parent final results

The first exact-stamp probe skipped the fresh motor's strict contact sequence and produced six setup errors in `r187355302-40`. The final probe advances **every stamp 1..N in real physics callbacks**, preserving the strict lifecycle and all ownership/atomicity assertions. Fixed twelve-probe run `r187663530-41`: **12/12**; fresh complete shared-harness run `r188028225-43`: **100/100**, plus **6/6** original live policy scenarios. Actual native anchor/marker/velocity errors remain zero, rope endpoint error at most **2.8493575428e-6 m**, with no missing active visual samples. Fresh schema adapter remains **4/4**, schema-only with its preload warning.

On final source, focused GUT is **13/13**, exit **0**; player is **272/279**, exit **1**; full is **280/289**, exit **1**. All three pass all hundred hardening case-rate pairs and have no fresh parse/load/compile errors. The full run matches the nine baseline failures; player also reproduces the previously captured intermittent wall-run landing failure. The new comparator therefore honestly fails the player-parity check (**6/7 pass**); no rerun was used to erase that result. Prior accepted captures above remain historical, not the latest player result.

[Final parent handoff](parent-final-results.md) records the failed setup and oversized-eval attempt, all fresh gates, retained diagnostics, preservation, cleanup and remaining boundaries. Work remains **uncommitted / in-review**; no further independent review, tuning, route or unrelated baseline repair occurred.
