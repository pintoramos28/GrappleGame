# Investigation: intermittent wall-stick jump integration failure

## Hand-off Brief

1. **What happened.** The historical missed launch is real in retained GUT logs; the same unmodified fixture reproduced its exact velocity signature through MCP after a 120→60 Hz scheduling transition.
2. **Where the case stands.** The live probe confirmed a cached engine-delta mismatch cancelling the first hold before jump input; all 67 fresh CLI target executions passed, so attribution of the historical GUT failures to that mechanism remains deduced rather than directly traced.
3. **What's needed next.** Approve a fixture-only rate/frame synchronization correction and immediate pre-jump validity guard; preserve the production motor guard, movement tuning, geometry and existing launch assertions.

## Case Info

| Field | Value |
| --- | --- |
| Ticket | N/A; wall-stick-jump-intermittent |
| Date opened | 2026-10-06 (session date; actual execution timestamps recorded below) |
| Status | Concluded investigation; correction awaiting approval; intermittent failure not resolved |
| System | Windows; pinned Godot 4.7.2-stable; live MCP plugin/server 4.2.3 |
| Scope | `tests/player/locomotion/test_wall_traversal_integration.gd`, `test_wall_stick_jump_uses_only_authored_up_and_horizontal_away_motion` and its fixture/input/physics/movement/motor dependencies |
| Authorization | Investigate only. No code, assertion, movement tuning, or geometry edits. User approved completing the full investigation and saving this report. |
| HEAD | `5d128486cf695f92dd4a370a6ee4ca6fb594b10f` (2026-10-02T22:38:46-04:00), `test: harden Story 1.10 traversal validation` |
| Console | `C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe`; observed version `4.7.2.stable.official.ed1daf0bf` |
| Raw evidence directory | `C:\Users\pinto\AppData\Local\Temp\opencode\wall-stick-jump-investigation-20261006-2236` |
| Persistent evidence | `_bmad-output/implementation-artifacts/evidence/wall-stick-jump-intermittent-2026-10-06/` (fresh logs/manifests, byte-preserved copies of two historical logs, MCP observations and preservation hashes) |
| Target identity | Git blob `ab8703b0b22e40086b5afb8d33e5369d43d0ed4d`; SHA-256 `d9a041423616c73e10ca9cbb6b40fb8e2e55d1fa8300337e51607b43d298b83c`; unchanged from commit `2f56b7d39883762c96430d7389fdfb2b4fca02cb` |

## Problem Statement

Historical evidence supplied by the user: an earlier authored-launch observation failed; a focused wall-stick run passed 8/8 tests (168 assertions); the latest recursive player run passed this jump test and failed only a separate shallow-corner continuity assertion. The intermittent jump failure is not considered resolved. **Confirmed** means directly observed source or execution; **Deduced** means a stated chain from those facts; **Hypothesized** means a remaining unobserved alternative. No correction was applied.

## Evidence Inventory

| Source | Status | Notes |
| --- | --- | --- |
| Live Godot AI MCP | Available | Active project session `testgame@17187ab35ae57813`; project path matches this checkout. |
| Editor preflight | Available | Godot 4.7.2-stable (official), ready/stopped; current scene `res://game/levels/content/traversal_validation/traversal_validation_route.tscn`. |
| Target through MCP | Available | `script_manage(find_symbols)` identifies target at line 480; `script_manage(read)` confirms 1,650 lines / 78,737 bytes. Extends `GutTest`, not `McpTestSuite`. |
| Live physics setting | Available | MCP `settings_get`: 60 physics ticks/s. |
| Editor diagnostics baseline/final | Available | 6 retained logger error entries, cursor 6, plus 11 visible warning rows at preflight. Cursor-scoped later/final reads: zero new logger entries, cursor 6→6. Not cleared. |
| Game log baseline | Partial | Stopped previous run `r244362717-69`; only helper registration retained. Not evidence of this test scenario. |
| Last MCP-native result (read-only retrieval) | Historical / separate harness | `test_manage(results_get)` returned prior `grapple_targeting` 3/4, with `test_authored_definition_carries_the_single_authoritative_range` failing and a generic stale-preload `cache_warning`. No native suite was executed for this investigation; this is not target/GUT coverage. |
| Historical GUT failures | Available | Two October 2 recursive raw logs independently inspected; exact target source unchanged since then. See historical timeline and copied logs. |
| Historical 8/8 pass and October 6 R12 gate | Partial | Narrative records found; original raw captures not found. The 8/8 predecessor predates current rename/zero-tangent oracle. Do not claim unchanged coverage. |
| Fresh isolated GUT results | Available | 12 sequential fresh processes, 12/12 target passes, 34 assertions each, exit 0. `isolated-manifest.json`, `isolated-01.log` through `isolated-12.log` in raw evidence directory. |
| Fresh contextual/cadence GUT results | Available | 67 sequential fresh CLI processes total; target present and passing in every one. Normal and diagnostic gate totals are separated below. Editor stopped during CLI batches. |
| Same-fixture MCP runtime | Available | Unmodified `_wall_stick_report` in its original fresh SubViewport/World3D; four helper observations, six passive-terminal observations, ten barrier-control observations. Not a CLI GUT or MCP-native suite result. |
| Preservation baseline | Available | 245 existing protected source/scene/test/user-artifact files SHA-256 captured at 2026-10-06T22:35:15.7333566-04:00; `baseline-hashes.json`, `baseline-status.txt`. |
| Preservation final | Available | All 245 hashes unchanged; `preservation-result.json`. Only this report and its new evidence artifacts were created. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| --- | --- | --- | --- | --- |
| 1 | Fixture setup, cleanup, scheduling, input seam | High | Done | Source trace through MCP; no source instrumentation. |
| 2 | Entry/exit precedence and jump request/commit | High | Done | Passive terminal listener captured pre-jump cancellation. |
| 3 | CLI repetition and rates/order | High | Done | 67 target passes; normal recursive gate still has separate failures. |
| 4 | Same-fixture MCP probe and synchronization control | High | Done | Matching signature; guard→cancellation trace; 10/10 control launches. |
| 5 | Preservation and diagnostics | High | Done | 245 unchanged hashes; final editor ready/stopped, 60 Hz, cursor 6. |
| 6 | Fixture-only correction and deterministic regression | High | Awaiting approval | No code/test changes authorized by this investigation. |
| 7 | Actual failing CLI per-step trace | Medium | Open | Necessary to make historical GUT attribution Confirmed; finite passes do not supply it. |

## Timeline of Events

| Time | Event | Source | Confidence |
| --- | --- | --- | --- |
| 2026-10-02, raw file created 16:05:37.137173Z / modified 16:06:41.694621Z | Recursive GUT target failed four primary-branch assertions: source lines 489/491/492/493; held steps 1, jump count 0, reference 0, submitted `(0.033333,-0.163333,0)` | `historical-story-1-10-review-player-gut.log:630-639`; baseline `2f56b7d` | Confirmed raw log; filesystem times, not exact process boundaries |
| 2026-10-02, raw file created 22:17:00.516731Z / modified 22:18:05.485809Z | Same four target failures; recursive 272/279, 12375/12388 assertions, exit 1, 62.218 s; simultaneous-release branch did not fail | `historical-1-10-fixes-final-player-gut.log:630-639,1280-1285` | Confirmed raw log; target unchanged |
| Historical September 26 / October 6 records | 8/8 predecessor wall-stick pass (168 assertions); later R12 recursive 278/279 (12413/12414, 62.584 s), target passed, corner only failed | `investigations/route-wall-stick-switch-investigation.md:174`; `evidence/1-10/review-fixes-2026-10-02.md:213-217` | Retained narrative; original raw captures missing |
| Preflight | Active MCP session, editor state, scene hierarchy, target symbols/source, editor/game logs, and 60 Hz setting inspected | MCP operations recorded above | Confirmed |
| 2026-10-06T22:35:33.6584821-04:00–22:35:56.2761162-04:00 | 12 exact-target isolated GUT processes all passed | `isolated-manifest.json` | Confirmed |
| 2026-10-06T22:36:16.9113468-04:00–22:36:29.0273502-04:00 | Five wall-stick filtered processes all passed (9/9, 244 assertions each) | `context-manifest.json`, `wall-stick-01.log`–`wall-stick-05.log` | Confirmed |
| 2026-10-06T22:36:29.0343656-04:00–22:36:39.9462404-04:00 | Three complete-file processes passed target, failed only shallow corner (20/21, 585/589 each) | `full-file-01.log`–`full-file-03.log` | Confirmed |
| 2026-10-06T22:36:39.9595011-04:00–22:39:53.3040102-04:00 | Three normal recursive processes: target passed all; 277/279, 278/279, 277/279 | `context-manifest.json`; `recursive-01.log`–`recursive-03.log` | Confirmed |
| 2026-10-06T22:40:34.5243631-04:00–22:41:13.9174171-04:00 | 25 isolated cadence variants all passed | `cadence-manifest.json` | Confirmed |
| MCP editor run token 69, engine frames 1208–1217 | Unmodified helper: 60 Hz modes 2/9 launch; first 120 Hz mode 2 misses launch; next mode 9 launches | `mcp-runtime-observations.json` | Confirmed MCP, not GUT counts |
| Same MCP run, frames 16763–16776 | Passive listener confirms first-hold delta mismatch/cancellation at player step 4; 120→60 reproduces exact historical submitted velocity | `mcp-runtime-observations.json`, cases `2:60:mode2` / `mode9` | Confirmed MCP; historical attribution Deduced |
| 2026-10-06T22:52:02.6929535-04:00–22:53:24.1784066-04:00 | 19 full-file/recursive cadence/paint diagnostics; target passed all; other assertions varied | `order-cadence-manifest.json` | Confirmed; diagnostic-only timing |
| MCP editor run token 70, engine frames 32–64 | External process→physics frame barrier after rate selections; 10/10 same-fixture launches at 60/120/60/120/60 | `mcp-barrier-control.json` | Confirmed control, not the original timing |

All fresh CLI manifests contain individual ISO-8601 start/end times, executable, full arguments, log path and exit code. MCP frame counters/run tokens identify observation order; wall-clock timestamps were not separately captured for individual evals.

## Confirmed Findings

### 1. The historical failure already shows premature maintenance termination

The October 2 logs record **one** hold rather than 18, zero wall impulses, reference zero, terminal reason 4 (`STATE_CANCELLATION`) and the supplied negative-Y signature. These are not merely three unexplained velocity numbers. The target file has no current staged/unstaged edits and is unchanged from the October 2 failure revision. Earlier in-progress re-anchor logs also contain similar numbers, but have zero holds and different corrected defects; they are not proof of this later cause.

### 2. MCP directly observed the sufficient cancellation condition

For `2:60:mode2` and `2:60:mode9`, the passive `attachment_ended` listener observed:

| Fact | Observed value |
| --- | --- |
| Engine configured rate | 60 Hz |
| Requested manual delta | 0.0166666666666667 s |
| Actual cached engine delta | 0.00833333333333333 s |
| `Engine.is_in_physics_frame()` | true |
| First hold / terminal player step | 4 / 4 |
| Jump edge at terminal | false (jump input has not yet been injected) |
| Hold applied / carry blocked | true / true |
| Hold position error | approximately 0.000000123 m, far below 0.02 m tolerance |
| Hold submitted / committed velocity | `(0,0,0)` / `(0,0,0)` |
| Normal after synchronous cleanup | `(0,0,0)` |
| Later helper jump reference / impulse count | 0 / 0 |
| Later exit submitted velocity | `(0.033333335,-0.163333341,0)` |

The motor's explicit mismatch guard is `game/player/motor/player_motor.gd:793-798`; the coordinator terminates a blocked hold at `scripts/player_controller.gd:442-448`. The 60→120 case observed the inverse mismatch and the corresponding half-gravity signature. The listener only read values; it did not override scripts, alter motion or insert an await into the manual burst.

### 3. Synchronization changes the observation without changing source or geometry

After rate selection, waiting for `process_frame` then `physics_frame` **outside the unmodified helper** produced 10/10 launches: all 18 holds, reference 0.5, one wall impulse, submitted `(0,5.5,8)`, one commit. This is a separate scheduling control, not a claim of unchanged original execution timing or an applied fix.

### 4. Current CLI reproduction is negative, not resolution

All 67 fresh CLI executions included and passed the exact target. Normal recursive runs still fail separate corner/wall-loss assertions. The live cached-delta failure remains reproducible under rate-transition conditions; passing CLI repetitions do not refute it or establish that historical failures were fixed.

## Deduced Conclusions

1. **Historical attribution: Medium confidence, Deduced.** The historical one-hold/terminal-4/zero-reference signature matches the directly traced live failure, and immediately preceding tests change 60/120 rates without a frame barrier. Missing historical per-step delta measurements prevent upgrading this attribution to Confirmed.
2. **The failure precedes the jump request.** A valid supported horizontal normal gives reference projection 0.5. The helper computes this projection *before* jump processing. A zero reference therefore points to stick fields already being cleared, not jump cleanup erasing a correctly prepared reference.
3. **The negative Y is ordinary airborne gravity, not a weak jump.** At 60 Hz, `-9.8/60=-0.163333`; at 120 Hz, `-9.8/120=-0.081667`. Following first-hold cancellation, 17 ordinary airborne transactions explain pre-exit `(17*2/60,17*-9.8/60,0)=(0.566667,-2.776667,0)`. Jump preparation then overwrites that velocity with zero because both stick vectors were cleared; the next airborne transaction creates the exact reported signature.
4. **This is not evidence to retune production movement.** The production motor deliberately rejects mismatched bound-support physics steps. The inconsistent requested/actual timestep comes from manual fixture calls inside an inherited outer physics callback window.

## Hypothesized Paths

### Hypothesis 1: an intermittent failure remains despite later passes

**Status:** Confirmed for the same-fixture MCP scenario; historical GUT cause remains Deduced.

**Theory:** Supplied earlier failure and later passing runs may indicate a timing/order-dependent failure, not resolution.

**Would confirm:** Repeated fresh execution reproduces the same missed-launch signature, or same-fixture observations expose a matching ordering path.

**Would refute:** A proven difference in earlier source/runtime conditions explains the historical failure; finite passing repeats alone do not refute intermittency.

**Resolution:** Historical raw failure verified; exact signature reproduced live with passive terminal evidence. 67 passing CLI target runs do not resolve the case.

### Hypothesis 2: cached physics delta survives an integer rate restoration

**Status:** Confirmed mechanism in MCP; Deduced historical attribution.

**Theory:** A 120→60 setter does not end the currently executing outer physics iteration. `_settle` can return on a pre-node `physics_frame` signal while its cached delta is still 1/120; manual calls request 1/60, triggering the bound-support guard.

**Evidence:** Actual mismatch, blocked first hold and same-step terminal captured together; inverse 60→120 mismatch also observed. Guard/cleanup references: `game/player/motor/player_motor.gd:796-798`, `scripts/player_controller.gd:442-448,1161-1174`. Existing repository warning describes precisely this hazard at `tests/player/grapple/test_wall_stick_reanchor_hardening.gd:13-17` and `_bmad-output/implementation-artifacts/evidence/wall-stick-grapple-reanchor/hardening-results.md:31-34`.

**Would confirm historical attribution:** The same tuple from an actually failing normal GUT run, or a deterministic GUT regression reproducing the inherited callback-window condition.

**Would refute historical attribution:** A historical/fresh failing GUT hold with aligned cached/requested deltas and a different first termination cause.

**Resolution:** Synchronization control succeeded; no assertion or production guard was weakened.

### Hypothesis 3: genuine support loss or carry-position error

**Status:** Open as an alternative historical cause; not required to explain the traced MCP failures.

**Would confirm:** First failing GUT hold has aligned deltas but missing/mismatched bound support, invalid shape owner, or position error above tolerance. **Would refute for that run:** Valid support and the observed mismatch guard firing with negligible position error. The tiny measured MCP error rules out excessive post-slide error as the necessary cause there.

### Hypothesis 4: jump edge consumed early / release wins / normal cleared too early in jump code

**Status:** Refuted as explanations of the traced failure under current source.

**Resolution:** Cancellation is observed before injection; injection→manual transaction has no await and increments a fresh player step. Supported jump precedes release in `scripts/player_wall_stick_state.gd:12-24`; desired velocity is calculated before termination at `scripts/player_controller.gd:783-787`. Literal forward remains held despite forward/back axis cancellation (`game/player/input/player_input_source.gd:135-229`).

### Hypothesis 5: collision response or later result reset erased a correct launch

**Status:** Refuted as a sufficient explanation.

**Resolution:** The test records `result.submitted_velocity`, before `move_and_slide`, into a Vector3 value (`tests/player/locomotion/test_wall_traversal_integration.gd:1287`; `game/player/motor/player_motor.gd:935-946`). Later frame resets/extra airborne observation cannot rewrite that stored value.

### Hypothesis 6: stale editor preload or different historical target source

**Status:** Different target-source claim Refuted for the two October 2 captures; stale loaded dependency graph remains Open historically, unsupported as a necessary cause.

**Resolution:** Target unchanged since `2f56b7d`; live reproduction did not edit/reload dependencies. Fresh CLI processes do not share the editor's preload cache. The historical 8/8 predecessor *does* differ in name/tangent oracle, so that pass is not identical current-target coverage.

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | --- | --- |
| Actual cached delta/first terminal snapshot in historical normal GUT failures | Historical attribution remains Deduced | Approval-scoped passive/in-memory GUT tracing or deterministic regression; preserve original assertions. |
| Original 8/8 and 62.584-second R12 raw logs | Cannot independently verify exact conditions or timestamps | Recover original capture if available; do not substitute this investigation's new logs. |
| Complete game-log stream after live probes | Cannot claim a clean game log | MCP game log reads repeatedly timed out; editor cursor and successful eval data are separate evidence. |

## Source Code Trace

### Fixture and input seam

- `tests/player/locomotion/test_wall_traversal_integration.gd:1575-1600`: fresh 256×256 SubViewport/World3D, real `scenes/player.tscn`, automatic player physics **left enabled**, test input seam enabled. Autofree disposes fixtures after the whole test; both mode fixtures coexist until then (`addons/gut/gut.gd:608-644`).
- `tests/player/locomotion/test_wall_traversal_integration.gd:1101-1133`: spawn `(-3,2,-0.25)`; floor `(0,-0.1,0)`, size `(60,0.2,60)`; wall `(0,4,-1)`, size `(40,8,0.2)`; collision-less anchor `(0,2,-2)`. No scene geometry was edited.
- Capsule radius 0.45/height 1.8, offset `(0,0.9,0)`; shared wall sphere radius 0.12/reach 0.8, world-geometry mask 1. The seeded grapple point `(0,0.1,-1)` is not the acquisition anchor's transform (`tests/player/locomotion/test_wall_traversal_integration.gd:1631-1649`). Entry reanchors the same occurrence to the real physical wall.
- Held bindings and strengths `(0,1,1,1)` retain literal forward while cancelling forward/back axis; initial horizontal velocity `(6,0,0)`. `game/player/input/player_input_source.gd:62-112,135-229,310-356` latches edges and returns one immutable frame per unique player step. Manual controller calls advance that step; same-step caching does not consume the injected jump.

### Scheduling and rate/order exposure

- `_settle` at `tests/player/locomotion/test_wall_traversal_integration.gd:1564-1572` awaits **pre-node** `physics_frame`, then checks the previous commit for an airborne label. It does not validate requested/actual delta or current wall support. Godot's [SceneTree signal contract](https://docs.godotengine.org/en/stable/classes/class_scenetree.html#class-scenetree-signal-physics-frame) confirms this signal precedes node callbacks.
- After settle, entry (up to 30), 18 hold, jump and extra observation calls are synchronous; player counters advance many times while the engine physics frame stays fixed (`tests/player/locomotion/test_wall_traversal_integration.gd:1135-1162,1235-1293`).
- Hooks save/restore only the rate integer at lines 45–50. Immediately preceding camera-turn and switched-wall tests set 60/120 and restore at lines 451/461 and 466/477. No restoration frame barrier exists. A suite-wide leaked **integer** rate was not observed; the confirmed issue is cached callback delta, even with integer 60.
- GUT awaits hooks/test/teardown sequentially but has no mandatory physics barrier; optional painting changes yield points (`addons/gut/gut.gd:608-644,846-853`). Its supported `wait_physics_frames` counts pre-node signals and completes on the following signal (`addons/gut/awaiter.gd:56-78`), unlike the target's direct one-signal wait. No supported shuffle/seed/repeat flag exists in this vendored runner (`addons/gut/cli/gut_cli.gd:114-147,258-273`). Recursive file discovery is sorted (`addons/gut/gut.gd:957-995`).

### Production transaction and precedence

`scripts/player_controller.gd:343-398` performs command capture → begin motion frame → one manual HSM update → one resolve/commit → committed grapple facts → post-commit coordination. Motor begin consumes one-use re-anchor ZERO baseline, clears current results/submissions/occurrences, but retains previous contacts (`game/player/motor/player_motor.gd:335-350,1518-1536`). Entry ZERO is intentional and cannot erase a reference injected 18 valid holds later.

Entry requires active/held grapple, literal forward, current runnable airborne physical wall, eligible normal, non-outward relative velocity, speed ≤100 and successful support bind/reanchor (`scripts/player_controller.gd:1086-1147`). Maintenance checks the privately bound shape/RID/local face, current query/support and safe transform (`game/player/locomotion/wall_stick/wall_stick_attachment.gd:92-178`; `scripts/player_controller.gd:1181`; `game/player/locomotion/contact/player_contact_provider.gd:707,996`).

`scripts/player_wall_stick_state.gd:7-59` precedence: death → supported fresh jump (held grapple also requires valid sampled anchor) → grapple release → anchor invalidation → unsupported wall → forward release → outward cancellation → hold. Supported simultaneous-release jump therefore wins; unsupported contact cannot launch from stale facts.

`scripts/player_controller.gd:783-787,1450-1479` calculates desired `(0,5.5,8)` before cleanup, submits desired-minus-reference impulse and transitions. Reference `(-3,0,0.5)` gives impulse `(3,5.5,7.5)`. No tangent momentum is retained. Jump submits passthrough+impulse, not hold/gravity/pull/cap. Motor resolves base/gravity → sustained → impulse → constraints → caps, stores submitted velocity, then performs its sole move (`game/player/motor/player_motor.gd:828-946`).

### Step-by-step outcome timeline (observed failing 60 Hz helper)

| Player step / phase | Outcome |
| --- | --- |
| Setup / settle, through step 2 | New fixture reaches previous airborne commit; callback resumes within an outer 120 Hz delta window after integer rate became 60. |
| Entry, step 3 | Grapple reanchors physical wall; wall stick enters; next-frame ZERO baseline armed. |
| First hold, step 4 | Requested 1/60 vs cached 1/120; hold constraint applies but carry is blocked. Coordinator terminates at this same step, before any jump edge. Normal/tangent cleared synchronously. |
| Remaining hold-loop calls, steps 5–21 | Actually 17 ordinary airborne transactions; helper does not stop on lost stick. `hold_request_seen=true` still passes because step 4 counted. |
| Jump preparation, after step 21 | Helper reads cleared normal/tangent and overwrites body velocity with zero; outward reference becomes zero. Injects JUMP; mode 9 also releases grapple. |
| Exit loop, step 22 | Already airborne, so no wall-stick jump branch/impulse. Air acceleration+gravity submit `(0.033333,-0.163333,0)`. Helper counts this as exit latency 1, although stick ended much earlier. |
| Extra observation, step 23 | Ordinary airborne label/no hold; cannot repair or overwrite recorded exit velocity. |

The passing path instead maintains holds at steps 4–21, prepares reference 0.5, then submits `(0,5.5,8)` at step 22. Successful jump termination occurs **pre-commit** with the jump edge true and last motor result null; failing hold termination occurs **post-commit** with the hold result available and jump edge false. Both use terminal reason 4, so that enum alone cannot distinguish them. This difference was observed by the passive listener.

## Conclusion

**Confidence:** High for the MCP-observed mechanism and numerical timeline; Medium for attribution to the historical GUT failure. **No fresh CLI target failure reproduced; no fix applied; not resolved.**

The best-supported diagnosis is fixture scheduling across a rate transition, not authored jump strength, wall geometry, release precedence or lost hardware input. Restoring `Engine.physics_ticks_per_second` is not proof that the current callback's actual physics delta has changed. The fixture's missing pre-jump validity check obscures the earlier first-hold cancellation and mislabels its later ordinary airborne result as a failed launch.

## Recommended Next Steps

### Minimal correction proposed for approval — not applied

**Scope:** `_wall_stick_report` fixture synchronization only; no production movement/geometry changes, no weaker assertion or motor guard.

1. Before creating its fixture at `tests/player/locomotion/test_wall_traversal_integration.gd:1102`, explicitly select its requested `tick_rate`, then cross a `process_frame` followed by `physics_frame` boundary before automatic settling/manual stepping. Existing teardown restores the saved rate. This is the synchronization shape that succeeded in the external MCP control; placing it before fixture creation avoids adding extra falling ticks to the fixture setup.
2. Immediately before preparing JUMP at lines 1164–1181, require the hold still active/currently supported; record the first hold cancellation/result rather than letting “ever entered/one hold seen” substitute for maintained readiness. Keep all authored velocity/impulse expectations unchanged. A focused guard assertion may be added **only after approval**.
3. Add a small regression for 60→120→60 cached-delta transitions, including held/released grapple branches; verify actual delta alignment and first-hold/launch step evidence. Re-run normal pinned recursive GUT plus same-fixture MCP. Broader helper/hook synchronization is a separately scoped follow-up if evidence warrants it.

**Do not:** remove `game/player/motor/player_motor.gd:796`'s safety check, retune 5.5/8 speeds, allow airborne wall jumps, accept zero reference, relax assertions or change geometry. Passing the diagnostic control is not an implementation or regression pass for a correction.

**Next action:** approval-scoped `gds-quick-dev` for the fixture-only change, or continued diagnosis to obtain a failing CLI per-step trace. Approval has not been requested through a tool that would silently start implementation.

## Reproduction Plan

Use the pinned console build and GUT 9.7.1. Run sequential fresh processes for the exact target, wall-stick filter, complete file, and recursive player tree. Compare 60/120 Hz and order settings where supported without editing project settings or source. Keep raw logs and a run manifest. MCP-native results, if any, are not GUT coverage.

### Executed isolated command

Invoked inside `rtk proxy powershell -NoProfile -EncodedCommand ...`, sequentially 12 times from this checkout:

```powershell
& 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' `
  --headless --path 'C:\Users\pinto\Documents\Godot Projects\testgame' `
  -s res://addons/gut/gut_cmdln.gd `
  -gtest=res://tests/player/locomotion/test_wall_traversal_integration.gd `
  -gunit_test_name=test_wall_stick_jump_uses_only_authored_up_and_horizontal_away_motion -gexit
```

For the normal isolated gate there was no frame-rate/seed override, hardware injection, import/reload or source instrumentation. Editor remained stopped. Startup reports GUT 9.7.1 and pinned Godot. Individual GUT durations 0.365–0.383 s; process wall times approximately 1.757–2.042 s. No root `.gutconfig` exists; default `-glog=1`, paint interval 0.1 s and headless ignore-pause remain in effect unless listed below.

### Complete CLI run matrix

Every row uses the same executable/base arguments above. `file` replaces exact-name filtering with just `-gtest`; `recursive` replaces it with `-gdir=res://tests/player -ginclude_subdirs -gexit`. The wall-stick group uses `-gunit_test_name=wall_stick_`. All repetitions are separate sequential processes, not duplicate script entries inside GUT.

| Selection / extra arguments | Runs | Target failures | Suite result per run | Exit |
| --- | ---: | ---: | --- | --- |
| Exact target, normal speed | 12 | 0 | 1/1; 34 assertions | 0 |
| Wall-stick group, normal speed | 5 | 0 | 9/9; 244 assertions | 0 |
| File, normal speed | 3 | 0 | 20/21; 585/589; corner only | 1 |
| Recursive player, normal speed | 3 | 0 | 277/279, 278/279, 277/279; assertions 12411/12414, 12413/12414, 12411/12414 | 1 |
| Exact target, `--fixed-fps 30 / 60 / 120 / 240` | 5 each (20) | 0 | 1/1; 34 each | 0 |
| Exact target, `--max-fps 30` | 5 | 0 | 1/1; 34 each | 0 |
| File, `--fixed-fps 30 -gpaint_after=100000` | 5 | 0 | 17/21; 574/589 | 1 |
| File, `--fixed-fps 15 -gpaint_after=100000` | 5 | 0 | 14/21; 566/589 | 1 |
| File, `--fixed-fps 30`, default painting | 3 | 0 | 18/21, 17/21, 17/21; 578/589, 575/589, 575/589 | 1 |
| File, `--fixed-fps 30 -gpaint_after=0` | 3 | 0 | 17/21; 574/589 | 1 |
| Recursive, `--fixed-fps 30 -gpaint_after=100000` | 3 | 0 | 275/279; 12399/12414 | 1 |
| **Total** | **67** | **0** | Target found and passed in every log | Mixed, due to other tests |

`--fixed-fps` disables real-time synchronization; these are diagnostic schedules, **not** normal regression acceptance. Neither FPS option sets physics tick rate. The exact target's helper defaults to manual 60 Hz; 120 Hz same-helper launch cases were exercised through MCP. CLI flags were verified from pinned help and vendored GUT registration; no invented seed/shuffle/repeat option was used. Painting thresholds were varied, not asserted to be an exact CPU/callback order.

Normal recursive runs 1 and 3 failed the required-wall-loss test at lines 438/443 in addition to corner line 118; run 2 failed corner only. These failures are not this target. Diagnostic whole-file/recursive totals reflect additional scheduling-sensitive assertions, not a target reproduction. `all-cli-target-observations.json` records each target header, launch signature and zero failure count.

### MCP reproduction/control recipe

Launch the current route through MCP with `autosave=false`; instantiate temporary existing Gut/integration-suite objects and use the existing `_wall_stick_report(mode,tick_rate)`. Its private World3D prevents route geometry from participating. Keep modes 2/9 paired and their fixtures alive until pair teardown; do not add awaits or disable automatic player callbacks inside the helper.

Within one awaited eval continuation, run rate pairs 60→120→60 without a process-boundary barrier. Optional passive ready/terminal listeners capture configured rate, `get_physics_process_delta_time`, `Engine.is_in_physics_frame`, player/terminal step and hold result. Preserve original input injection and all manual calls. For the separate control, add only external `await process_frame; await physics_frame` after rate selection. Restore rate 60, autofree original viewports, free temporary suite/Gut objects and stop play. Retained JSON contains exact modes, engine frame boundaries, failure tuple and control results.

## Godot AI MCP operations and limitations

- Session preflight: `session_manage(list)`, `editor_state`, scene hierarchy/open roots, editor/game logs, target `script_manage(read/find_symbols)`; matching active project identified.
- Source trace: MCP `script_manage(read/find_symbols)` for controller, states, input, motor/result, contact/support, grapple/definitions, GUT/awaiter-related source; `filesystem_manage(read_text/search)` for fixture/scene/resource text. Read source is not a promise of stale preload invalidation.
- Loaded editor inspection: Player properties and capsule resource graph; effective Jolt/60 Hz/interpolation/jitter/max-step settings. No resource assignments, script patches, saves, scans or reloads were performed because no runtime source was edited.
- Runtime: fresh `project_run(current,autosave=false)` for editor tokens 69/70, bounded `game_eval` using the actual fixture; passive terminal capture; separate synchronized control; `game_manage(resume)` after one liveness failure; `project_manage(stop)` after each owned run. **No visual/screenshot verification claimed.**
- Diagnostics: preflight old game run only retained helper registration. Subsequent game log reads timed out four times, including once while stopped; therefore game-log cleanliness is unknown. One eval liveness probe failed, resume then verified an unsuspended/live loop and the trace succeeded. Editor cursor-scoped reads stayed 6→6 with zero new logger errors. Launch responses reported no current-run errors.
- Final MCP state: ready/stopped on the original route, project setting 60 Hz, loaded Player script/resource/process priority/safe margin unchanged. Temporary probes explicitly restored runtime rate 60 and freed fixtures. MCP-native `test_run` was not used because it cannot discover/execute this recursive `GutTest` suite; last native result retrieval is historical evidence only.

## Side Findings

- Historical editor rows include warning-as-error parses in a wall-stick review test and grapple binding, a dependent compile error, and a missing `SHALLOW_CORNER` member in a route test. These are baseline diagnostics, not newly observed test failures.
- Existing user changes were present in `tests/player/grapple/test_grapple_targeting_contract.gd`, `tests/player/grapple/test_grapple_targeting_integration.gd`, `tests/player/motor/test_player_motor_integration.gd`, `tests/test_grapple_boundary_mcp.gd`, `tests/test_grapple_targeting_mcp.gd`, deferred-work and review-fixes documents, plus an untracked regression follow-up spec. They are not reverted or overwritten. Initial `rtk git diff --check` passed.
- The native runner's cache warning is advisory evidence about editor-loaded GDScript preloads, not a demonstrated cause of the historical GUT failure. Fresh CLI processes do not reuse the live editor's GDScript preload cache. Per-process shared-resource behavior remains a separate hypothesis to inspect.
- Two host-side evidence commands initially had PowerShell quoting/wildcard-extraction errors; corrected versions completed. These did not change source or run the gameplay test and are not Godot/GUT diagnostics.
- `recursive-01.log:1168-1171` records shutdown leakage (8 ObjectDB instances; 1 resource still in use). This is separate from stale-preload warnings and target assertions. Numerous earlier `ERROR: GameLog ...` entries originate in intentionally invalid-request coverage; final GUT failing-test identities are tracked separately rather than inferred from an error-string grep.
- Effective settings were observed, not retuned: Jolt, interpolation true, jitter fix 0.5, max physics steps/frame 8. Player process priority 0, collision layer 2/mask 1, safe margin approximately 0.001.
- Final preservation comparison: **245/245 existing protected files unchanged**. Historical evidence snapshots were copied, never rewritten. This report/evidence are the only agent-created repository files; no code, tests, assertions, scenes, definitions or project settings changed.
- Final `rtk git diff --check` passed; tracked dirty paths are the same pre-existing seven user changes as at baseline. New report/evidence artifacts are intentionally untracked. All ten retained JSON evidence files parsed successfully; all 67 CLI reports share held steps 18, jump count 1, reference 0.5 and submitted `(0,5.5,8)`.
