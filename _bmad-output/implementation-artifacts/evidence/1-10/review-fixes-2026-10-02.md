# Story 1.10 — Review fixes, 2026-10-02

**Outcome:** R1–R11 repaired in test/diagnostic code. Final normal-speed focused GUT is **13/13**, **818 assertions**, exit **0**; live MCP observes full completion at both rates and all six recovery returns. Approved production movement, geometry and tuning are unchanged. The broader regression gate and formal M0/OD-009 acceptance remain red/deferred, not included in this fix-completion claim.

## Authorization and preservation

Pinto selected **“Apply all”** after the R1–R11 walkthrough. Implement only the eleven test/diagnostic repairs. The user's manual confirmation that the route and movement are good remains valid human evidence. R12 (unrelated regression failures) and R13 (formal M0/OD-009 gates) remain deferred.

Baseline: `2f56b7d39883762c96430d7389fdfb2b4fca02cb`; initial dirty files were solely the prior review's story, deferred-work ledger and report. Those edits were preserved. No production controller, locomotion policy, scene, target script, geometry, definition or movement tuning is changed.

## Implementation

- `tests/fixtures/traversal_route_driver.gd`: test-only production-input driver and post-player (+10 priority) observer, unique physics-step sampling, seconds from actual commit deltas, accepted impulse counts, named physical landing evidence, current stamped wall diagnostics, release-vector latching and same-instance recovery scenarios. No body-motion writes, manual physics calls or extra physics queries.
- `tests/fixtures/traversal_boundary_probe.gd`: framework-neutral isolated constraint probe, usable by GUT and MCP runtime inspection. Uses the real authored anchors/35 m maximum but private pre-tree zero-pull/zero-gravity setup to isolate the motor's constraint phase. Tests actual tether growth, unchanged slack/tangential motion, inward freedom, outward clipping and moving retreat carry. It is **not** production-tuned route completion evidence.
- `tests/levels/test_traversal_validation_route.gd`: recursive-GUT route gate runs both 60/120 Hz, uses the observer rather than idle-coroutine timing, requires actual authored destination support and accepted wall jump, and restores the global physics rate/disposes worlds between cases. All original concerns remain represented; the new air test changes input during flight.
- Recovery commands now brake on the corresponding catch, walk south and west, jump onto the authored return ramp's low lip, climb onto `StartDeck`, brake on that named upper deck, and request another accepted ground jump. Catch support, ramp support, upper-deck support at the resume request, and the next-step impulse are separate required observations. No catch, anchor roof, lower-deck jump or scene reload counts as a successful return.
- Each accepted jump record is counted individually and checked for `ONE_SHOT_IMPULSES` / `ONE_SHOT_IMPULSE`; duplicate occurrences fail. Exact near/moving release labels, one-step request/observation pairing, a physical `route_completed` signal plus player overlap, uninterrupted current corner frames, and unsupported activation throughout the approach are required. Missing constraint phases/sources, attachment diagnostics, vectors or records fail rather than becoming zero-valued evidence.
- A fixture watchdog advances on physics `delta` independently of motor reports; all GUT waits have separate bounds. A negative-control test disables the player callback and proves a repeated/missing commit cannot leave the test hanging. Test players disable startup mouse capture before tree entry; `after_each` restores the caller's physics rate and mouse mode.
- The late-written [review-fix spec](../../spec-1-10-review-fixes.md) records the already approved intent and explicitly admits it was not a pre-edit artifact. It is not retroactive approval or a new production-work scope.

## MCP preflight and implementation observations

Mandatory active session: **`testgame@17187ab35ae57813`**, Godot **4.7.2-stable (official)**, plugin/server **4.2.3**. `session_manage(list)` confirmed the current project; readiness/current route/play state and retained editor diagnostics were inspected before editing. Original editor logger cursor **5**. Read-only affected route hierarchy, script and production player/definition reads confirmed the production composition, 35 m maximum and current 60 m/s² pull.

Implementation used settled filesystem scans, script reads and same-content `script_create` reload/diagnostic checks through MCP after repository patches. Three test scripts parsed successfully. Fresh launches always used `autosave=false`. Runtime command drivers were attached only in fresh game processes, never saved to authored scenes.

Development diagnostics were not hidden: one invalid enum name was corrected; a mistaken snapshot property (`target_id` instead of `target_identity`) was corrected; one long `game_eval` exceeded the server's 8 s budget and its cancelled coroutine entered a debugger break. Subsequent long drivers run independently of eval, with separate bounded result reads. One development GUT process stuck on that property error was identified by its exact headless command/PID and stopped. These are intermediate failures, not acceptance results. Final fresh-run diagnostics and canonical gates are recorded below.

## Live uninterrupted route — MCP-observed

Both runs used the actual current route, authored player spawn, production tuning, production input seam and no body-position/velocity writes. One player/route instance per run. World-state resets were new runs, never within a completion attempt.

| Rate | Completed | Simulation seconds | Ground / wall impulses | Named landings | Errors |
|---|---|---:|---:|---|---|
| 60 Hz | Yes | **12.916667** | **4 / 1** | JumpDeck → NearLanding → MovingLanding → WallJumpLanding | `[]` |
| 120 Hz | Yes | **12.900000** | **4 / 1** | Same four decks | `[]` |

Difference **0.016667 s**, below the original **0.25 s** full-route tolerance. Both observed the same condensed locomotion-state sequence. Release vectors were latched on the first inactive committed step; pre/post vectors matched in these runs, not merely their magnitudes. Finish positions were approximately **(61.3718, 1.5009, 6.0001)** / **(61.2279, 1.5009, 6.0000)**. Original runtime rate was restored to **60 Hz**.

An actually viewed MCP game screenshot after the 120 Hz completion was **960×540**, `stale_frame=false`, showing the green physical finish deck, player and existing grapple telemetry. No repository screenshot file was saved. This is visual finish evidence, not evidence for unseen recovery cases.

## Focused command outcomes and tolerances

The final-source normal-speed route run passed **13/13**, **818 assertions**, exit **0**, in **248.846 s**, including all final independent-review corrections below. It retains original opening-jump bounds (`<3 s`, `0.10 s`, `0.5 m`), the lateral `0.15 m` comparison, and explicit moving acquisition/active-snapshot/positive-response/35 m checks. Pre-final-review runs passed **13/13**, **796 assertions**, in **248.827 s**, and **13/13**, **773 assertions**, in **248.821 s**. No final command uses `--fixed-fps`.

| Observable | 60 Hz | 120 Hz | Enforced comparison |
|---|---:|---:|---|
| GUT full-route elapsed seconds | 12.916667 | 12.916667 | ≤0.25 s difference |
| Near fire-to-release request window | 0.200000 s | 0.191667 s | ≤0.05 s difference |
| Moving fire-to-release request window | 0.700000 s | 0.675000 s | ≤0.05 s difference |
| Stick-entry-to-jump request window | 0.033333 s | 0.016667 s | ≤0.05 s difference |
| Near first released-commit speed | 20.359100 m/s | 20.356940 m/s | ≤0.75 m/s difference |
| Moving first released-commit speed | 22.000005 m/s | 22.000000 m/s | ≤0.75 m/s difference |

These are GUT measurements, not substituted MCP measurements. Both full-route traces require the same named states, four ground impulses, exactly one accepted wall impulse and the exact four destination decks. Every release compares **vectors**: change ≤`15 m/s² × commit delta + 0.02 m/s`, direction dot >0.99, post-release speed ≥5 m/s. Both observed releases retained identical pre/post vectors within each run. Cross-rate action windows refer to event stages, not guessed coroutine frame counts. The first normal-speed run without the last added assertions passed 13/13 with 757 assertions; development `--fixed-fps 240` runs are not the canonical gate.

The changed-air-input case accepts exactly one jump and lands on `JumpDeck` in **2.283333 / 2.291667 s**. Input now changes only after committed airborne/non-grounded steps **84 / 164**; final steering samples are **97 / 189**. Its lateral committed velocity changes from **0** to **0.433333 / 0.416667 m/s** while still airborne; final lateral positions **0.093889 / 0.086806 m** meet the 0.15 m comparison. Unsupported-slope smoke requires actual unsupported-front-face collision and a matching current-step committed `FLOOR_LIKE` rejection, not merely inactive flags. Observed face-normal dots are **0.988164 / 0.978720**, rejection steps **46 / 91**, with no matching wall candidate/support and no run/stick activation anywhere in either approach.

## Recovery — real same-instance returns

All six cases run at both rates, require `errors=[]`, and return through actual `ReturnRamp` support to **`StartDeck`** before the resume jump. In the normal-speed GUT report:

| Intended mistake | Observed catch body | 60 Hz return/resume seconds | 120 Hz return/resume seconds |
|---|---|---:|---:|
| Missed opening jump | JumpCatch | 10.966667 | 10.708333 |
| Rejected beyond-range grapple | GrappleCatch | 12.000000 | 12.058333 |
| Early grapple release | GrappleCatch | 12.366667 | 12.050000 |
| Moving-target invalidation | MovingCatch | 14.583333 | 14.358333 |
| Lost wall run | WallCatch | 16.766667 | 16.808333 |
| Short accepted wall jump | WallCatch | 17.766667 | 17.833333 |

The short jump genuinely commits one wall-jump impulse but misses `WallJumpLanding`; its actual catch is `WallCatch`, not an invented `WallJumpCatch` landing. The invalidated attachment records `TARGET_INVALIDATED (2)` and the separate invalidation event test requires exactly one terminal event. Beyond-range rejection is `NO_CANDIDATE` from the bounded production ray; analytical authored-box intersection confirms its canonical aim extends to `BeyondAnchor` beyond 35.005 m. No extra physics ray is issued.

Live MCP runs **r240806012-60** / **r240930136-61** independently observed all six returns, all same-instance checks, named catches/ramp/StartDeck support and `resume_step = support_step + 1`, with every driver `errors=[]`. The 120 Hz durations were **10.708333, 12.058333, 12.050000, 14.358333, 16.808333, 17.833333 s** in the table order. These are runtime inspection results, not manual playtests or claims of identical recovery durations.

## Isolated 35 m/carry probe — not production-tuned completion

| Probe | Initial / maximum committed separation | Slack / taut samples | Carry samples / max | Taut tangent / inward samples |
|---|---|---|---|---|
| Static, 60 Hz | 29.602205 / 35.000008 m | 134 / 27 | 0 / 0 m/s | 13 / 9 |
| Static, 120 Hz | 29.602205 / 35.000008 m | 267 / 55 | 0 / 0 m/s | 25 / 20 |
| Moving, 60 Hz | 29.492584 / 35.020454 m | 101 / 228 | 49 / 0.049846 m/s | 48 / 19 |
| Moving, 120 Hz | 29.482370 / 35.010239 m | 201 / 456 | 98 / 0.025324 m/s | 97 / 37 |

The probe measures same-step **committed** body separation against the transformed fixed local hit, separately from the pre-resolution constraint record. All maxima remain ≤**35.05 m**; cross-rate distance difference ≤**0.05 m**, carry difference ≤**0.15 m/s**. Moving displacement is **1.788197 / 1.768543 m**; measured anchor velocity error is zero in these runs. The independently derived radial oracle, carry-vector oracle and tangential difference each stay below **0.001 m/s**; static unjustified inward kick stays below **0.001 m/s**. Slack requires unchanged constraint-phase velocity and zero carry. Actual taut tangent/inward examples are retained in each report.

Live MCP observed the same static/moving endpoint maxima and phase evidence at both rates; the 120 Hz probe had **98** real carry samples and constraint-vector error **1.78814e-7 m/s**. The fixture's private pre-tree zero-pull/zero-gravity setup isolates the constraint and does not mutate the shared authored definition. Slack does not disable production sustained zip pull; no such gameplay claim is made.

Pre-final-review single-probe readback in **r241902949-66** also passed without the earlier many-world warning: **960** complete matching constraint samples, **201** slack / **456** taut, **98** carry, maximum committed **35.010239 m**, maximum local/velocity/distance error **0**, carry-vector error **1.19209e-7 m/s**. At step **709**, independently measured anchor radial retreat changed constraint radial velocity **+0.011805 → −0.013185 m/s**, expected/reported carry **0.013185 m/s**; the retained full vectors distinguish outward clipping from real carry. The fixture was freed before restoring **60 Hz**. The final canonical suite re-exercised both isolated probes after the shared observer hardening.

## Hardening triage

The completed static hardening pass identified fourteen concerns. Thirteen concrete oracle/watchdog gaps were addressed within R1–R11; the mouse-leak hypothesis was not reproduced as an established defect, but inexpensive isolation guards were added.

1. Independent fixture watchdog and independently bounded GUT waits, including the stalled-motor negative control.
2. Exact impulse-record counting, duplicate rejection, correct accepted phase/kind.
3. Named upper-deck support still present when requesting the resume command.
4. Exact release coverage and first inactive-step/request pairing; pending-release overwrite/unobserved finish fails.
5. Beyond-range rejection provenance from the production aim plus authored geometry.
6. Actual finish signal, initially false latch and player overlap, not a flag alone.
7. Unsupported activation monitored before as well as during physical slope contact.
8. No wall-run/support loss between the authored faces; adjacent current/previous corner frames required.
9. Exactly one complete matching constraint phase, source, applied source and record; no zero defaults.
10. Tangent/inward freedom demonstrated while near 35 m, not only after becoming slack.
11. Static constraint cannot add an unjustified inward kick.
12. Reported moving carry must produce the independently expected radial phase-vector change.
13. Independent same-step physical separation, distinct from published pre-resolution distance.
14. Mouse leakage: unproven as a bug; explicit pre-tree capture disable and caller-mode restoration retained preventatively.

### Final independent quick-dev check

All three fresh review roles completed on the tracked/untracked diff from `2f56b7d39883762c96430d7389fdfb2b4fca02cb`: Blind Hunter (12 concerns), Edge Case Hunter (no unhandled paths), Acceptance Auditor (one concern, duplicate of the unsupported-face oracle). Review snapshot: **2234 lines**, SHA-256 **`4f3c85604fd05093b46f54f0999379b2faad0935c719d31c2ff7664c848dd890`**, raw `C:/Users/pinto/AppData/Local/Temp/opencode/1-10-fixes-final-review.diff`. Reviewers were read-only and had no conversation history; static findings are not runtime observations.

That original shell-generated snapshot contains CP437-decoded Unicode punctuation; its raw hash is retained, not replaced. Comparing the approved frozen block after reversing that code-page conversion confirms it is unchanged. Final delivery diff generation uses explicit UTF-8 console decoding; source files and the original review artifact are not rewritten to hide the capture issue.

Concrete follow-up hardening stays within the approved test/diagnostic intent:

- Accepted jump counts must also match exactly one **applied** occurrence; submitted and actual committed launch vectors are both retained/asserted.
- Lateral air input begins only after a committed airborne, non-grounded frame, and every steering sample stays airborne. This removes a possible takeoff-phase false positive.
- The actual grapple-request commit—not its prior targeting preview—must have matching target/command stamps, rejection and no active attachment. Catching a fall no longer overwrites an unobserved failure label.
- Every wall sample must have current supported/query/loss facts and the authored normal direction, not merely a final-value normal overwrite.
- Production-pull local-hit checks latch the **initial** moving-target offset; they no longer compare two values derived from the same potentially changing offset.
- Commit deltas must be finite, positive and equal to the supplied callback delta; early observer termination makes timed sampling fail rather than silently use cached results.
- The retained trace/vector excerpt below supplements ephemeral raw captures.

The acceptance auditor's genuine R7 gap was fixed by requiring current `COMMITTED_COLLISION` rejection facts for the contacted authored unsupported **face**, plus no matching wall candidate/support. The first overly broad version failed both GUT and live inspection because the same thin box also has legitimate near-vertical side/bevel normals. The corrected test identifies the 30-degree front-face cone (`normal dot ≥0.97`); its minimum absolute normal-Y is approximately **0.274**, above the unchanged wall limit **0.2**. It does not weaken classification or ignore activation: actual face contact/rejection is mandatory, and activation remains monitored throughout the entire approach, including side/bevel contacts. The normal-speed focused face test passes at both rates, and the acceptance auditor rechecked this closure statically without running tests.

Blind findings **1–6 and 9–12** are resolved; **7–8** are dismissed with the reasons below. Finding 3's vacuous stick-precondition concern is addressed at the underlying authoritative face-rejection contract, rather than claiming a held-grapple stick attempt that was not made. The auditor's duplicate is closed by that same correction. No final-review finding requires new human intent or unrelated production work.

Two blind hypotheses were rejected as current-scope defects: a future production player with physics priority greater than 10 (the actual approved player is priority 0), and requiring a persistent world-direction lock across injected yaw epochs (the driver submits actual camera-relative input axes and tests observed physical outcomes; no such independent lock contract is claimed). Neither authorizes production/input redesign.

### Retained full-route trace/vector excerpt

For both recorded successful full-route rates, prefix each state below with `player.locomotion.`:

`grounded → airborne → grounded → airborne → grappling → airborne → grounded → airborne → grappling → airborne → grounded → airborne → wall_run → grappling → wall_stick → airborne → grounded`

CLI pre/post release vectors (m/s, rounded by Godot's report print; pre equals first inactive committed post in each row):

| Label / rate | Pre = post vector | Request → observed step |
|---|---|---|
| Near / 60 Hz | (19.670340, 5.135262, −1.095345) | 195 → 196 |
| Near / 120 Hz | (19.645730, 5.229570, −1.049711) | 388 → 389 |
| Moving / 60 Hz | (21.868510, 0.604466, 2.324459) | 330 → 331 |
| Moving / 120 Hz | (21.869190, 0.656080, 2.303930) | 662 → 663 |

The excerpt belongs to the canonical reports identified by hash below; live game steps differ because the observer starts after launch initialization. Live finish events, snapshot run IDs, all named destinations, exact impulse counts and the independent carry vectors are retained separately above. Temporary raw captures are not required to reproduce the checked-in command scenarios, but are needed to audit every unabridged sample from those particular runs.

## Final gates and external regressions

Preservation readback through MCP confirmed **Jolt Physics**, saved shipping **60 Hz**, main scene **`res://main.tscn`**, and the original shared definition still **60→8 m/s² / 35 m** despite isolated private probes. Player/main/route loaded as `PackedScene` and retained/resolved UIDs **`uid://u1u36ceuo8uj`**, **`uid://dgei3sdvi5j3i`**, **`uid://djubh0hpim1s8`**. Test fixtures received generated `.gd.uid` sidecars via the connected editor. `rtk git diff --check` passed during implementation.

Latest normal-speed recursive player GUT on the unchanged production source: **272/279 tests**, **12375/12388 assertions**, exit **1**, **62.218 s**, **21 scripts**. The exact seven identities match the original review: authored grapple-definition value, same-step pull value, camera/scene-origin expectation, pull-decay window/floor, shallow-corner continuity, wall-stick authored jump/precedence, and authored motor-context values. The earlier **273/279**, **12379/12388** fix-phase run did not reproduce the wall-stick jump failure; the latest rerun did. Neither result is hidden or counted as a repair. Shutdown retains **8 leaked ObjectDB instances / 1 resource in use**. R12 remains deferred.

Existing MCP-native schema suites, separately from gameplay/GUT: `wall_stick` **4/4**, **26 assertions**, **6 ms**; `grapple_moving_target` **6/6**, **48 assertions**, **6 ms**; `grapple_boundary` **4/5**, **102 executed assertions**, **8 ms** with `main.tscn` open. The failing boundary schema test still expects **48 m/s²** while the approved resource reads **60**. Opening main and rerunning removed the scene-warning ambiguity but did not repair the failure. All native results retain the standard preload-cache warning; no modified production dependency is validated through that cache and no GUT parity is claimed.

Independent MCP `main.tscn` launch at saved **60 Hz** passed with no current-run launch errors; runtime hierarchy/facts confirmed the actual scene. Run **`r228081151-58`** had only helper registration in the game log. Existing native `wall_stick` schema suite passed **4/4**, **26 assertions**, **8 ms**; its standard preload-cache warning was retained. This schema result is separate from route gameplay and recursive GUT coverage. `git diff --name-only HEAD -- game scripts scenes main.tscn project.godot` returned no changed production files.

Final independent main launch **r241525389-62** again confirmed **60 Hz**, **Jolt Physics**, the original main path, the **60→8 m/s² / 35 m** shared definition and all three retained UIDs; its current-run log contained only helper registration. Pre-final-review full-route replays also passed with signal/overlap evidence and no corner interruption: **r241543535-63**, **r241635304-64**, and **r241780805-65** / **r241902949-66** at **60/120 Hz**. The latter pair observed **12.916667 / 12.900000 s**, the identical 17-state condensed trace, exact four deck arrivals, four ground / one wall impulses, exact two first-commit releases, adjacent preserved corner frames and physical finish events with `overlaps_player=true`. Both game logs contained only helper registration, no dropped lines. The 120 Hz **960×540** screenshot was actually viewed and non-stale: player on the green upper finish deck, with the existing grapple telemetry. No repository screenshot is claimed.

### Post-review final-source MCP checks

Fresh runs **r244066428-68 / r244362717-69** at **60/120 Hz** again completed in **12.916667 / 12.900000 s**, `errors=[]`, **four ground / one wall impulses**. Submitted **and committed** wall-jump velocities were approximately **(−1.389186, 5.5, 7.878463) m/s**; adjacent corner frames **656→657 / 1297→1298** had no interruption; physical overlapping finish events occurred at **789 / 1560**.

Sequential additional runtime fixtures in those fresh runs verified the actual unsupported-face rejections and post-takeoff air steering described above, each with `errors=[]`. Live steering intervals were **84→97 / 165→190**, demonstrating airborne input changes rather than ground-phase acceleration. The missed-grapple recovery also re-ran: actual rejected request/observation steps **52=52 / 102=102**, analytical aim distances **42.057907 / 42.117184 m**, `GrappleCatch` then ramp then `StartDeck` support **719 / 1446**, next-step resume impulses **720 / 1447**, same instances, **12.000000 / 12.058333 s**. These targeted rechecks complement the earlier all-six live runs and the final canonical all-six suite; they are not relabeled as another all-six live replay.

Each final game log contained only helper registration, with **zero dropped lines**. Runtime fixtures were freed, runtime rate restored to **60 Hz**, and playback stopped. The final MCP readback again identified the active project, ready/stopped route and its four authored root children (no saved test driver); editor cursor **6→6**, zero new entries. Historical diagnostics were not cleared.

The new post-jump `wall_valid` diagnostic can legitimately be false when stamped frame N has no selected physical support; it is no longer a read of the pre-commit N−1 API, and it is not used to infer whether the already-recorded wall impulse occurred.

### Reproduction and raw logs

```powershell
rtk proxy "C:/Users/pinto/Documents/Godot Projects/Godot 4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/levels/test_traversal_validation_route.gd -gexit
rtk proxy "C:/Users/pinto/Documents/Godot Projects/Godot 4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
```

Raw captures are UTF-8 (`utf-8-sig` for the PowerShell BOM) in the approved temporary directory, not claimed as repository-retained logs:

- `C:/Users/pinto/AppData/Local/Temp/opencode/1-10-fixes-final-hardened-route-gut.log`: 13/13, 773 assertions; SHA-256 `fc8bffc18788db7b41e033444fc2369ecc3fb388f710e39d1914602f2ce46116`.
- `C:/Users/pinto/AppData/Local/Temp/opencode/1-10-fixes-final-player-gut.log`: 272/279, exit 1; SHA-256 `0ffbd92a2790412d2b7554cb3a345438e5eda93d1e430f222ec7a1db0df27fde`.
- `C:/Users/pinto/AppData/Local/Temp/opencode/1-10-fixes-final-verified-route-gut.log`: pre-final-review **13/13**, **796 assertions**, exit **0**, **248.827 s**; SHA-256 `1fa1c42d5d6b2fdfd1403a02ad001c63dbf41bc12994fe51dfb51c8c03383897`.
- `C:/Users/pinto/AppData/Local/Temp/opencode/1-10-fixes-final-accepted-route-gut.log`: **final source**, **13/13**, **818 assertions**, exit **0**, **248.846 s**; SHA-256 `de16b5c0ea9df78404b2935c59fbd0bf0cd480fb68fc2bfc39a7cbf50e178b10`. No failed assertions, script errors or engine warnings in this capture.
- `C:/Users/pinto/AppData/Local/Temp/opencode/1-10-final-review-oracles-dev-gut.log`: intermediate `--fixed-fps 240` development run **12/13**, **816/818 assertions**, exit **1**, **21.202 s**, from the overly broad all-face slope oracle. Not an acceptance gate. Its corrected focused normal-speed counterpart is `1-10-final-unsupported-face-gut.log`; both rates pass before the final full rerun.

### Diagnostic disposition

- Editor logger cursor advanced **5→6** during the corrected development enum error; final reloads report `diagnostics_status="checked"`, empty diagnostics and `reloaded=true` for all three test scripts. Historical error rows remain visible and were not cleared. Cursor-only reads and fresh-run game logs are recorded separately; an empty cursor read does not prove the Debugger warning table is empty.
- The simultaneous ten-world 120 Hz diagnostic smoke **r240930136-61** produced one Jolt maximum-jobs warning. This oversized ad-hoc validation setup is not a shipping route load and was not silently counted as clean. Subsequent single-route 60/120 Hz runs had only helper registration, with no such warning. No physics/backend/thread setting was changed.
- Fixture `Node.name` shadow warnings were corrected by renaming iterators/parameters. Temporary eval local-variable shadow warnings were not production source defects. Existing production `seed`, ternary and motor-parameter shadow warnings are outside this repair; fresh game logs have no gameplay errors, and no production warning is suppressed or altered.
- Canonical player-suite `GameLog` errors marked expected by its negative tests are distinct from the seven failed assertions and shutdown leakage. The route suite does not silently whitelist runtime errors.

Final MCP cleanup rechecked the authored route hierarchy (no saved driver or probe), read editor cursor **6→6** with zero new entries, stopped playback and confirmed **readiness=ready** on the original route. Final `rtk git diff --check` is clean, and the production-path diff (`game`, `scripts`, `scenes`, `resources`, `main.tscn`, `project.godot`, `addons`) is empty. The only changed runtime-adjacent files are test sources/UID sidecars; documentation remains uncommitted with them.

## R1–R11 resolution map

| ID | Resolved evidence |
|---|---|
| R1 | Final production-input route suite 13/13; named zip/wall/full outcomes now pass without production edits. |
| R2 | Both actual 60/120 loops execute; completion, state order, both releases and measured action-window comparisons pass. |
| R3 | Six actual same-instance catch → ramp → named upper deck → next-step accepted resume jumps at both rates; separately observed live. |
| R4 | Short static tether reaches the real 35 m limit; phase and independent endpoint oracles exercise outward, taut tangent and inward freedom. |
| R5 | Nonzero moving displacement, fixed local hit, measured velocity, zero slack carry and real taut radial carry pass separately from production completion. |
| R6 | Exact near/moving first inactive commits preserve pre/post vectors; documented per-step and cross-rate tolerances pass. |
| R7 | Authored normal/RID aliases, uninterrupted supported corner and physical unsupported-slope rejection pass at both rates. |
| R8 | Changed in-flight input measurably changes committed lateral velocity, followed by an actual named landing. |
| R9 | Landing checks require current grounded facts plus named body RID/classification or same-commit slide collision and authored physical bounds. |
| R10 | Actual accepted wall-jump occurrences are counted in the committed one-shot phase; exact counts and launch components pass. |
| R11 | Post-commit diagnostics use stamped frame N and current support/query/loss facts; tests check the matching phase/step contract. |

**Scoped fixes complete, story not closed.** R12 (seven external GUT failures, native authored-value expectation and shutdown leakage) and R13 (formal M0/OD-009, specified human-rate/recovery evidence and sibling-story gates) remain explicit in [deferred work](../../deferred-work.md). The user's qualitative movement/route approval remains valid; automated results are not relabeled as a human playtest. No staging, commit, push, dependency change or production source/scene save was performed.

## 2026-10-06 targeted R12 expectation follow-up

Only stale test expectations were updated: authored grapple pull is **60 m/s²** (including its GUT/MCP mirrors), the scene-origin marker is **(0, 0.9, 0)**, pull-decay sampling derives enough 60 Hz steps from the authored initial/floor/jerk values, and the player tuning test now checks the player scene's **50 m/s²** ground deceleration and **0** grapple-gravity scale while recognizing that `main.tscn` overrides deceleration to 30 and inherits gravity. Production definitions, movement, scenes and geometry were not changed.

The pinned recursive player GUT command (`Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit`) reports **278/279 tests**, **12,413/12,414 assertions**, exit **1**, **62.584 s**. Its only failure is `test_wall_run_direction_never_reverses_across_a_shallow_corner` at `tests/player/locomotion/test_wall_traversal_integration.gd:118`: latest 120 Hz outward-exit action was `PRESERVED` (2), while the unchanged assertion expects `SWITCHED` (3). Per Pinto's direction, this was noted without changing the expectation or production contact/wall-run behavior. The previously intermittent `test_wall_stick_jump_uses_only_authored_up_and_horizontal_away_motion` passed in this run; the earlier failure remains unexplained, not resolved. Shutdown still reports eight leaked ObjectDB instances and one resource in use.

Godot AI MCP session **`testgame@17187ab35ae57813`** was ready/stopped before validation and restored to the authored traversal route afterward. `script_patch` parse-checked all five changed GDScript tests with **empty diagnostics**; four already-loaded scripts reloaded in place, and the remaining script was not loaded. The editor remained ready. Native `grapple_boundary` passed **5/5 tests, 102 assertions**. Native `grapple_targeting` was **3/4** both with the route open and after opening `main.tscn`. Its unchanged text oracle expects default-valued definition/range/tuning fields (including `definition_id`) to be explicitly serialized in the `.tres`; those values come from `GrappleDefinition` defaults, while the resource serializes only the initial acceleration and target profile. This separate source-text oracle issue was not changed here. The MCP runner also returned its standard preload-cache warning; opening the main scene removed the scene warning but did not change the result. Editor log rows included unrelated existing script diagnostics; they were not cleared. The current scene was restored to `res://game/levels/content/traversal_validation/traversal_validation_route.tscn`, play state stopped, editor readiness ready.
