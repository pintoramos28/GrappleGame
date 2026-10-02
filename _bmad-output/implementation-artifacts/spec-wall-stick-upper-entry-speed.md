---
title: 'Use only the upper entry-speed gate for wall sticking'
type: 'feature'
created: '2026-09-30'
status: 'done'
baseline_commit: '89ead0989f319a80007cb9835fea056c5ca8bf04'
context:
  - '{project-root}/_bmad-output/project-context.md'
  - '{project-root}/AGENTS.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Grapple-assisted wall sticking currently shares wall-run entry's minimum horizontal speed requirement. The user wants wall sticking to use only the upper speed gate, with wall-run behavior unaffected.

**Approach:** Give wall-stick entry an independent upper-total-speed predicate and use the same predicate for its read-only telemetry. Preserve the existing configured upper threshold, grapple/contact/input requirements, hold, release, and jump behavior; leave wall-run eligibility unchanged.

## Boundaries & Constraints

**Always:** Check committed total 3D velocity against the existing upper threshold inclusively. Preserve wall-run minimum/maximum gating, relationship/maintenance, direction/outward/input helpers, ContactFrame ownership, one motor commit, zero hold baseline, grapple lifecycle, and UIDs. Use Godot MCP preflight/scan/runtime validation and separate pinned recursive GUT through `rtk`. Preserve the existing user scene edit and investigation note.

**Ask First:** Changes to tuning, alignment, direction selection, jumps, hold mechanics, unrelated resources, or fixes for existing failures.

**Never:** Alter `_can_start_wall_run` or its minimum export; add airborne-to-stick entry; bypass other entry guards; reset user changes; change project/add-on configuration; claim MCP tests execute GUT.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|---------------|----------------------------|----------------|
| LOW_OR_ZERO_SPEED | Otherwise eligible stick; zero/sub-minimum horizontal speed; total below upper | Entry allowed; baseline/hold preserved | Other guards still apply |
| UPPER_BOUNDARY | Total magnitude equals upper threshold, including vertical motion | Stick speed gate passes | Inclusive boundary |
| ABOVE_UPPER | Total magnitude exceeds upper, including vertical motion | Stick speed gate fails | No new hold |
| WALL_RUN_REGRESSION | Below run horizontal minimum or above total maximum | Run entry still fails; accepted boundaries unchanged | Existing behavior |
| OTHER_STICK_GUARDS | Missing held grapple/contact, outward motion, or zero/opposed input | No stick entry | Existing rejection behavior |
| TELEMETRY | Any tested committed velocity | Gate/reason agree: `pass` or `total_speed_high` | No obsolete low-horizontal-speed reason |

</frozen-after-approval>

## Code Map

- `scripts/player_controller.gd` — stick entry and telemetry; shared run predicate remains unchanged.
- `tests/player/locomotion/test_wall_traversal_contract.gd` — configured boundaries, guard and motor-policy cases.
- `tests/player/locomotion/test_wall_traversal_integration.gd` — production-player/Jolt fixture and grapple/hold/release regressions.
- `scripts/debug_grapple_telemetry.gd` — consumes views; no change expected.
- `_bmad-output/implementation-artifacts/1-9-integrate-wall-traversal-and-mistake-recovery.md` and `investigations/wall-run-criteria-investigation.md` — append policy amendment/evidence, preserve history.

## Tasks & Acceptance

**Execution:**
- [x] `scripts/player_controller.gd` — add a stick upper-only predicate; wire entry/telemetry, remove low-speed reason, clarify comments; leave run predicate/states intact.
- [x] `tests/player/locomotion/test_wall_traversal_contract.gd` — cover the matrix, telemetry using real motor commits, and retained run boundaries.
- [x] `tests/player/locomotion/test_wall_traversal_integration.gd` — prove sub-minimum grapple-assisted entry, one transition, zero baseline, hold/release at 60/120 Hz; retain guard/jump regressions.
- [x] Spec, Story 1.9, and investigation note — append approved policy, separate GUT/MCP results and existing blockers.

**Acceptance Criteria:**
- Given eligible sub-minimum grapple-assisted contact, when post-commit entry evaluates, then sticking begins without changing run eligibility.
- Given boundary/over-limit total speed, when stick entry evaluates, then equality passes and greater speed fails regardless of vertical split.
- Given committed velocity, when telemetry queries it, then gate/reason agree without mutating gameplay.
- Given low-speed stick entry, when grapple is held/released, then motor hold/baseline and exactly-once airborne cleanup remain intact.

## Spec Change Log

## Design Notes

The loaded player scene has a 3.0 m/s run minimum (script default 1.0) and 18.0 upper speed; tests use configured values. Zero-speed eligibility still needs aligned nonzero input. Keep tangent direction and shared upper export, not a new tuning knob.

Preserved transaction detail: entry still consumes `result.submitted_velocity` from the just-committed motor step, exactly as the baseline coordinator supplies it; telemetry consumes the motor's collision-adjusted committed velocity. The frozen wording about committed entry speed refers to that committed-step submission snapshot, not a change to the pre-/post-collision evaluation point. Their collision-induced difference predates this change and is deferred, not silently changed with the minimum gate.

## Verification

**Commands:**
- `rtk proxy "C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/locomotion -ginclude_subdirs -gexit` — expected: all focused suites pass; observed baseline failure is recorded below.
- Same invocation with `-gdir=res://tests -ginclude_subdirs -gexit` — recursive suites including player; report existing failures separately.
- `rtk git diff --check` — clean whitespace; inspect run/scene preservation.

**MCP:** Scan scripts; run applicable native tests separately; launch player scene without autosave; inspect runtime node, boundaries and isolated real-player/Jolt low-speed entry/hold/release with `game_eval`/input seams. Inspect logs, stop, confirm ready editor. No human feel/visual judgment claimed.

## Dev Agent Record

Preflight `testgame@17187ab35ae57813`: ready/stopped on player scene. MCP session/editor/logs, controller/stick scripts, hierarchy, and player properties inspected; ten existing warnings, no errors returned. User authorized the dirty scene to be preserved. Validation results appended during implementation.

### Implementation evidence — 2026-09-30

- **Model:** GPT-6.1 Sol (OpenCode). Baseline HEAD reconfirmed as `89ead0989f319a80007cb9835fea056c5ca8bf04`. At implementation hand-off, spec status was `in-progress`; frozen intent, sprint status, and historical Story 1.9 acceptance/evidence were unchanged. The implementation subagent ran no additional agents, reviews, commits, or pushes; the parent subsequently advanced to review.
- **Policy amendment implemented:** `_can_start_wall_stick()` accepts finite total 3D speed inclusively up to `wall_run_max_entry_speed`; `_try_start_wall_stick_from_contact()` and both speed-only telemetry views use it. Reasons are `pass` / `total_speed_high`, with defensive `non_finite_speed` for nonfinite velocity. Removed the obsolete horizontal-low reason and misleading contact/alignment comment. There is no new tuning export or airborne-to-stick path.
- **Contract coverage:** three added tests exercise actual stick entry (not just the predicate), eleven configured velocity cases, real motor-committed telemetry including deliberately different uncommitted body velocity, repeat-query purity, retained run boundaries, and nine other-entry-guard cases. Exact-zero and pure-vertical policy cases use synthetic authoritative wall frames with the production player and real motor commits; the physical contact/hold gate is tested separately below.
- **Real-Jolt coverage:** one added integration test runs initial 0 and half the scene-configured run minimum at both 60/120 Hz. The existing fixture keeps its original 6 m/s default for all old cases. It records actual entry submissions, first hold initial velocity, hold drift/speed, transitions, terminal idempotency, and cleanup. Existing guard and jump assertions remain intact.

#### GUT / CLI gate (not MCP coverage)

All log basenames below are under `C:\Users\pinto\AppData\Local\Temp\opencode\`. Commands use the pinned executable and `rtk proxy`; final captures used `wall-stick-upper-gut-capture.py` to preserve raw output and the subprocess exit code without PowerShell's stderr error-record wrapping.

| Run | Scripts | Passing / total tests | Passing / total assertions | Exit | Log |
| --- | ---: | ---: | ---: | ---: | --- |
| Pre-edit recursive `res://tests`, `-ginclude_subdirs -gexit` | 16 | 228 / 233 | 11,224 / 11,236 | 1 | `wall-stick-upper-baseline-gut.log` |
| Final focused `res://tests/player/locomotion`, `-ginclude_subdirs -gexit` | 2 | 43 / 44 | 1,198 / 1,202 | 1 | `wall-stick-upper-focused-gut-verified.log` |
| Final selected stick regressions: same focused command plus `-gunit_test_name=stick` | 2 | 16 / 16 | 774 / 774 | 0 | `wall-stick-upper-stick-gut-verified.log` |
| Final full recursive `res://tests`, including `tests/player/**` | 16 | 232 / 237 | 11,728 / 11,740 | 1 | `wall-stick-upper-recursive-gut-verified.log` |

The four new tests pass. Final comprehensive failures are the **same five tests observed before edits**:

1. `tests/levels/test_traversal_validation_route.gd::test_real_oblique_wall_run_stick_and_jump_reach_the_physical_finish`.
2. Same suite: `test_one_unbroken_command_route_completes_every_traversal_stage_at_both_rates`.
3. `tests/player/grapple/test_grapple_targeting_integration.gd::test_moving_scene_origin_does_not_change_camera_target_or_acquisition_range`.
4. `tests/player/locomotion/test_wall_traversal_integration.gd::test_wall_run_direction_never_reverses_across_a_shallow_corner` (unchanged 120 Hz exit assertions; this is also the sole focused failure).
5. `tests/player/motor/test_player_motor_integration.gd::test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band`.

No unrelated fixes or weakened assertions were made. One intermediate full run passed the unchanged corner test (233/237, four failures, `wall-stick-upper-recursive-gut-final.log`); final repeated runs reproduced the baseline corner failure. This variability is not a claimed fix. Existing negative-test invariant errors are expected; full runs also retain three GUT warnings and exit-time ObjectDB/resource leak diagnostics. The comprehensive gate is **not green**, despite the scoped stick gate passing.

#### Godot AI MCP gate (separate live evidence)

- **Session:** `testgame@17187ab35ae57813`; Godot 4.7.2-stable, plugin/server 4.2.3. Fresh read-only preflight repeated `session_manage(list)`, `editor_state`, controller/stick `script_manage(read)`, `node_get_properties`, and editor logs. Editor ready/stopped on `res://scenes/player.tscn`; scene values minimum 3, upper 18, alignment 0.2, user-edited `wall_check_distance` 0.2. Ten pre-existing warnings, no product errors returned.
- **Implementation operations:** `filesystem_manage(scan)` settled after edits and again before/following live validation (128 global classes, delta 0). MCP controller reads confirmed the new predicate and absence of `horizontal_speed_low`; affected test `find_symbols` confirmed the added tests. A filesystem scan alone is not claimed as parse validation: fresh game launches and GUT supplied executable validation.
- **Applicable native tests:** `test_run` ran the three existing top-level grapple adapters: **15/15, zero failed/skipped**, 16 ms. `test_manage(results_get)` reconfirmed the result. The runner warned about stale preloaded GDScript dependencies; these unchanged data/schema adapters are not wall behavior verification, do not run GUT, and establish no coverage parity. The editor was not restarted or saved to clear the cache.
- **Fresh runtime:** `project_run(mode="custom", scene="res://scenes/player.tscn", autosave=false)` launched a live helper. `game_manage(get_scene_tree/get_node_info)` inspected the real player, motor, HSM states, controller, and configured values. No scene save was performed. A corrected fresh live run was `r43653115-5`.
- **Low-speed live smoke:** `editor_manage(game_eval)` created isolated `SubViewport`/`World3D` fixtures, production player at `(-3,2,-0.25)`, floor, wall box center `(0,4,-1)` size `(40,8,0.2)`, separate collision-less anchor `(0,2,-2)`, and the existing seed hit `(0,0.1,-1)`. After settling to airborne, it seeded the real grapple controller, dispatched `grapple_started`, held the injected grapple command and +X tangent movement, and manually drove the production physics transaction at each diagnostic rate. Backend returned **Jolt Physics**. Initial speeds were 0 and 1.5, not retuned exports.

| Rate | Initial speed | Observed entry horizontal / total speed | Stick speed gate / reason | Run speed gate |
| --- | ---: | ---: | --- | --- |
| 60 Hz | 0 | 0.674429 / 0.861900 | true / `pass` | false |
| 60 Hz | 1.5 | 2.163690 / 2.229254 | true / `pass` | false |
| 120 Hz | 0 | 0.337117 / 0.430941 | true / `pass` | false |
| 120 Hz | 1.5 | 1.830769 / 1.850345 | true / `pass` | false |

All four MCP cases observed supported wall contact, one stick transition, `(0,0,0)` first-hold initial velocity, 18 applied holds with zero speed/drift, no hold on/after release, one airborne transition, preserved release velocity, one `RELEASE` terminal, clear-before-terminal signal, duplicate-terminal identity, and one motor commit per step. Fixtures were freed and the physics rate restored to 60.

- **Boundary/telemetry live smoke:** a second `game_eval` used production players and real motor commits with synthetic authoritative contact frames to exercise actual `_try_start_wall_stick_from_contact()`. Zero, 1.5 horizontal, the run minimum 3, horizontal 18, vertical ±18, and mixed `(10.8,14.4,0)` all entered with `pass`; vertical 18.5 and mixed `(3,18,0)` (total 18.248287) rejected with `total_speed_high`. Telemetry did not alter position/velocity, stick state, or the committed result. Run eligibility stayed false below its horizontal minimum/for pure vertical/above total upper, and true at its accepted boundaries.
- **MCP diagnostics and recovery:** the first scratch eval failed compilation because its harness used nonexistent `GrappleEndResult`; `editor_state` observed that parser break. No successful fixture result was claimed from that call. MCP stop/relaunch recovered it; the corrected eval used the existing attachment terminal. Final live game log contained one helper-registration info line and **zero warnings/errors**, with no editor-error hint; editor cursor reads had no new entries. Final regular editor diagnostics remained the ten pre-existing warnings. No startup autoload UID errors were observed in these fresh launches and none were repaired.
- **Closeout:** `project_manage(stop)`, settled rescan, affected-node properties, controller/test reads, and `editor_state` confirmed ready/stopped on the unchanged player scene. No visual or human-feel verification is claimed. Condensed MCP evidence is in `wall-stick-upper-mcp-evidence.md` under the log directory.

#### Preservation and completion

`wall-stick-upper-preservation.py` / `wall-stick-upper-preservation.json` compare against the approved baseline: the run predicate, entry/maintenance/relationship/state code, shared direction/input/outward helpers, post-commit coordinator, stick lifecycle/hold/jump functions, motor, and contact provider are unchanged. The player scene equals the baseline plus **only the original user edit** (`wall_check_distance` 0.0 → 0.2); its raw SHA-256 is `db899dec943d1d1697256373c906618a20a0e722051b2848b4529e0babcc8453`. No UIDs, tuning resources, grapple behavior, project configuration, or state scripts changed. `rtk git diff --check` passed.

Implementation tasks are complete; existing focused/comprehensive regression failures remain disclosed blockers to a fully green gate. The implementation subagent made no spec/sprint status transition. Story 1.9 and the investigation received append-only policy amendments, not rewritten historical requirements or evidence.

### Review triage — 2026-09-30

- Three fresh review agents inspected the complete tracked/untracked diff: adversarial, edge-case, and acceptance audit. Edge-case hunt reported no reachable new failure.
- **Patch:** clarified expected versus observed focused-test outcome and historical workflow status. Added a nonfinite stick-speed regression. Hold assertions now check actual committed/body velocity and drift against an immutable entry latch position, including cached-position stability.
- **Defer:** the coordinator's submitted-speed entry check versus collision-adjusted telemetry discrepancy is present at baseline `89ead098`; changing the upper-gate evaluation point would exceed the user's lower-gate-only request. Preserved it, documented the snapshot distinction above, and recorded it in deferred work.
- Remaining proposed expansions of tests for unchanged direction/alignment/ground/jump mechanisms do not identify a new behavioral defect and are not blockers for this isolated gate change. No production wall-run code or upper-speed semantics were changed during review.

### Final closeout — 2026-09-30

- After the review patches, pinned GUT selected stick regressions passed **17/17, 782 assertions, exit 0** (`wall-stick-upper-stick-gut-closeout.log`). Full recursive `res://tests` passed **233/238, 11,736/11,748 assertions, exit 1**, across 16 scripts (`wall-stick-upper-recursive-gut-closeout.log`). All five added tests pass; the same five baseline failures listed above remain. The comprehensive gate is not claimed green.
- MCP session `testgame@17187ab35ae57813`: a settled resource scan and controller read reconfirmed the independent predicate and intact run predicate. Fresh custom player launch used `autosave=false`, run `r46021510-6`; runtime scene-tree inspection and `game_eval` confirmed stick acceptance at zero/1.5, both gates accepted run minimum 3 and horizontal upper 18, vertical 18 accepted only stick, vertical 18.5 rejected, and NaN/infinity rejected. Game logs contained only helper registration; editor cursor returned zero new diagnostics. Stop/readiness check ended ready/stopped on the player scene. Earlier real-Jolt hold/release evidence remains the gameplay smoke result; this final check adds gate/finite-boundary evidence, not visual/feel verification.
- Re-ran baseline preservation check: all run/shared-helper/hold/state/motor/contact functions and user-scene preservation checks passed. `rtk git diff --check` passed. No scene save, commit, push, unrelated test fixes, or sprint-state change. Implementation is complete with the pre-existing regression gate failures disclosed.

## Suggested Review Order

**Eligibility and preserved behavior**

- Post-commit sticking calls its isolated speed policy; all other entry guards remain.
  [`player_controller.gd:1052`](../../scripts/player_controller.gd#L1052)
- Inclusive total-speed upper limit without a horizontal minimum.
  [`player_controller.gd:1045`](../../scripts/player_controller.gd#L1045)
- Compare the untouched wall-run predicate and both original bounds.
  [`player_controller.gd:972`](../../scripts/player_controller.gd#L972)
- Speed-only telemetry uses the stick policy, not the run minimum.
  [`player_controller.gd:1294`](../../scripts/player_controller.gd#L1294)

**Regression evidence**

- Actual stick entry covers zero, vertical, mixed, boundary, and over-limit speeds.
  [`test_wall_traversal_contract.gd:185`](../../tests/player/locomotion/test_wall_traversal_contract.gd#L185)
- Defensive nonfinite rejection and read-only committed telemetry.
  [`test_wall_traversal_contract.gd:213`](../../tests/player/locomotion/test_wall_traversal_contract.gd#L213)
- Real-Jolt low-speed entry, immutable-position hold, zero velocity, and release at both rates.
  [`test_wall_traversal_integration.gd:275`](../../tests/player/locomotion/test_wall_traversal_integration.gd#L275)
- Approved policy amendment preserves historical Story 1.9 evidence.
  [`1-9-integrate-wall-traversal-and-mistake-recovery.md:449`](1-9-integrate-wall-traversal-and-mistake-recovery.md#L449)
