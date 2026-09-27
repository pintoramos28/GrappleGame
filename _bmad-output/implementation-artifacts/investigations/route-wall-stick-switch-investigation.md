# Investigation: Route wall stick loses its selected contact

## Hand-off Brief

1. **What happened.** The Story 1.10 uninterrupted route enters wall stick on a `SWITCHED` contact, then cancels the next-step jump without an impulse.
2. **What the evidence shows.** At both rates the selected contact changes from an `ObliqueWall` sweep hit to an unlabelled `BODY_FACT` located at the player's origin; its unchanged normal but ~1 m representative-point jump exceeds the 0.2 m continuity limit.
3. **What's next.** Diagnose a comparable point/provenance policy in a separate implementation task and re-run the route and broader gates; this case closes the cause investigation, not Story 1.10 or M0 acceptance.

## Case Info

| Field | Value |
| --- | --- |
| Ticket | Story 1.10 |
| Date opened | 2026-09-26 |
| Status | Concluded (diagnosis only; Story 1.10 remains in progress) |
| System | Windows, Godot 4.7.2/Jolt, GUT 9.7.1; MCP `testgame@e362124f09f388c2` (plugin 4.0.4), editor ready/stopped on the route |
| Evidence sources | Story 1.10 CLI/GUT candidate trace and restored failure, contact provider/controller/state code, authored geometry, focused wall regressions, MCP editor/scene/runtime inspection |

## Problem Statement

Investigate the failed uninterrupted start-to-finish Story 1.10 validation route, specifically why the wall-stick jump is cancelled after a real wall-stick entry. The prior interpretation that overlapping authored walls alone caused the switch is a hypothesis, not an established cause.

## Evidence Inventory

| Source | Status | Notes |
| --- | --- | --- |
| GUT route result | Available | Pinned CLI/GUT trace at `C:\Users\pinto\AppData\Local\Temp\opencode\wall-stick-candidate-trace.log:24-27,416-419` captures consecutive candidates at both rates; restored focused run at `C:\Users\pinto\AppData\Local\Temp\opencode\wall-stick-restored-focused.log:10-45` fails 0/1 at 60 Hz. The temporary trace code was removed; `tests/levels/test_traversal_validation_route.gd:340-501` is restored to its original `[60]` loop. |
| Editor/scene | Available | Godot AI MCP session `testgame@e362124f09f388c2`: route loaded, ready/stopped, both authored walls and the 0.2 m `WallProbe` inspected; editor cursor 119→119 (no new entries). Route launch/runtime node inspection occurred, but MCP did not capture contact transitions or a completed playthrough. |
| Source and geometry | Available | `game/player/locomotion/contact/player_contact_provider.gd:224-272,366-450,532-555`; `scripts/player_controller.gd:402-424,995-1021,1077-1094`; `scripts/player_wall_stick_state.gd:35-54`; `game/levels/content/traversal_validation/traversal_validation_route.tscn:266-283`. |
| Focused predecessor regressions | Partial | Pinned CLI/GUT full wall integration file: 17/18, 363/364 assertions; shallow-corner failure varied by run/rate. Isolated corner rerun: 0/1, 14/18 assertions. Focused `wall_stick_` selection: 8/8, 168 assertions. These are CLI observations, not MCP tests or the recursive player gate. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --- | --- | --- | --- |
| 1 | Trace `SWITCHED` selection and wall-stick entry/next-step gate | High | Done | `BODY_FACT` selected on the entry commit; the next-step gate reads that frame before its new commit. |
| 2 | Reproduce with bounded read-only per-step diagnostics at both rates | High | Done | 60/120 Hz consecutive candidate/step/velocity traces retained in the external log and summarized below. |
| 3 | Compare authored collision geometry and predecessor wall tests | Medium | Done | Same-step identified collision and sweep evidence stays on `ObliqueWall`; focused stick tests pass. No production contract edited. |
| 4 | Triage variable shallow-corner regression failure | Medium | Open | Full wall integration 17/18; isolated corner still fails, at a different rate/condition. Not explained by this wall-stick diagnosis. |

## Timeline of Events

| Time | Event | Source | Confidence |
| --- | --- | --- | --- |
| 2026-09-26 | Unbroken route GUT failed at the wall-stick jump at 60/120 Hz during prior implementation attempts; experimental timing/geometry edits were restored. | Story 1.10 Dev Agent Record, lines 202–204 | Confirmed |
| 2026-09-26 | MCP session remained ready/stopped on route; no newly appended editor diagnostic since cursor 119. | MCP `editor_state`, `scene_get_hierarchy`, `logs_read` | Confirmed |
| 2026-09-26 | Temporary CLI/GUT trace captured selected candidates around entry at 60 and 120 Hz; diagnostic test failed 0/1, 20/25 assertions. | Candidate trace lines 24–27, 416–419, 1178–1182 | Confirmed |
| 2026-09-26 | Instrumentation removed; restored route still fails at 60 Hz, 0/1, 9/11 assertions. Focused wall suite 17/18; `wall_stick_` tests 8/8. | Restored focused log lines 10–45; predecessor regression logs (see follow-up) | Confirmed |

## Confirmed Findings

### Finding 1: The wall-stick gate rejects a switched relationship

**Evidence:** `scripts/player_controller.gd:1077-1094`, `scripts/player_wall_stick_state.gd:40-50`, `_bmad-output/implementation-artifacts/1-10-complete-the-focused-traversal-validation-route.md:203-204`.

**Detail:** The reported entry contact has a wall but is `SWITCHED`. While sticking, `has_supported_wall_contact()` returns false for `SWITCHED`; the wall-stick state then commits `STATE_CANCELLATION` before the jump request is processed. The cause of this classification is established in the follow-up below.

## Deduced Conclusions

### Deduction 1: Valid-looking contact alone is insufficient for this jump

**Based on:** Finding 1.

**Reasoning:** The supported-contact gate checks continuity and cached stick relationship in addition to `has_wall_contact`.

**Conclusion:** The absence of a jump impulse follows the current state machine's fail-closed behavior. The follow-up traces why this frame is marked `SWITCHED`; deciding how to make cross-source contact points comparable belongs to a separate implementation task.

## Hypothesized Paths

### Hypothesis 1: Authored wall overlap forces an actual face change at entry

**Status:** Refuted for the traced entry

**Theory:** `FirstWall` and `ObliqueWall` intersect or compete at the stick position.

**Supporting indicators:** Both walls exist in the scene; changing their overlap changed the route outcome but did not fix it.

**Would confirm:** Successive selected candidates have different collision bodies or normals at entry.

**Would refute:** Both candidates belong to the same face with nearly identical normals.

**Resolution:** Both rates retain `(-0.173648, 0, 0.984808)` through the switch; the preceding sweep and same-step committed-collision/sweep candidates map to `ObliqueWall`. `BODY_FACT` itself has no collider RID, so its exact body is inferred from accompanying evidence rather than observed directly. No actual face change was observed at the entry transition.

### Hypothesis 2: Same-wall motion exceeds contact-point continuity distance

**Status:** Refuted for the traced entry

**Theory:** A fast player traverses more than the authored continuity distance during one physics step, so the same unlabelled wall appears `SWITCHED`.

**Supporting indicators:** Prior route traces reported high grapple-release speeds and `SWITCHED` with an apparently unchanged wall normal. `game/player/locomotion/contact/player_contact_provider.gd:259-272` compares world-space points.

**Would confirm:** Successive candidates have the same body and normal but their hit points are farther apart than the profile's continuity distance.

**Would refute:** Points are close enough or belong to different walls.

**Resolution:** The selected points are >1 m apart, but they use different *representative locations*: sweep wall hit versus `BODY_FACT` player origin. The player's per-step displacement is only ~0.168 m at 60 Hz and ~0.085 m at 120 Hz; same-wall successive sweep hits remain within 0.2 m. Speed across the wall face is not the cause of this particular switch.

### Hypothesis 3: A source/provenance change makes comparable wall contact appear discontinuous

**Status:** Confirmed for this entry

**Theory:** A zero-distance `BODY_FACT` with the player's origin as its point is selected over same-face geometric hits; the continuity test treats the origin as if it were a surface hit point.

**Supporting indicators:** Candidate trace at both rates, provider candidate construction/ranking and `_same_contact()`, 0.2 m wall profile, and step-order trace in the follow-up.

**Would refute:** A different selected point/source at entry or an unchanged representative-point separation within 0.2 m.

**Resolution:** Neither refutation appears in the captured 60/120 Hz entries. The exact policy change and its broader regressions require a separate implementation/verification task.

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | --- | --- |
| Direct collider identity of the selected `BODY_FACT` | Prevents directly asserting that fact came from `ObliqueWall`; it contains neither RID nor authored identity | Instrument the underlying engine wall-collision owner or derive an identified geometric representative in a future implementation test; same-step identified collision/sweep hits currently support only a deduction. |
| MCP live candidate/command trace | MCP route launch and runtime node inspection do not independently reproduce the GUT candidate sequence | Retry `game_eval`/input smoke in a responsive live game when implementing a fix; prior evals returned `EVAL_COMPILE_ERROR` and then `EVAL_GAME_NOT_READY`. |
| Shallow-corner test variability | A separate focused wall integration gate is not fully green | Triage the corner fixture/rate-dependent transition independently; full integration 17/18 and isolated corner 0/1 on this checkout. |

## Source Code Trace

| Element | Detail |
| --- | --- |
| Error origin | `scripts/player_controller.gd:1077-1094`, `scripts/player_wall_stick_state.gd:40-50` |
| Trigger | Wall stick entered post-commit, followed by a jump command on the next step. |
| Condition | A selected `BODY_FACT` player-origin point is >0.2 m from the preceding same-normal wall sweep hit, so the entry frame is `SWITCHED`; pre-commit supported-contact gate reads that frame and fails before jump dispatch. |
| Related files | `game/player/locomotion/contact/player_contact_provider.gd`, `game/shared/physics/contact_frame.gd`, `tests/levels/test_traversal_validation_route.gd` |

## Conclusion

**Confidence:** High for the `SWITCHED` mechanism and cancellation order; only deduced for the unlabelled body's association with `ObliqueWall`.

The source/representative-point discontinuity is reproduced at both rates and traced through candidate construction, ranking and `_same_contact()`. The stick's fail-closed response is consistent with its existing contract. Diagnosis is concluded; the uninterrupted route, full story regression gates, human playtest and M0 decision gate have not passed.

## Recommended Next Steps

### Fix direction

In a separate implementation task, make wall-contact representative points/provenance comparable across sweep and body evidence, then test source handoffs on one unlabelled face and genuine switched/lost faces without weakening the fail-closed stick gate. No production traversal contract or route fixture was changed in this investigation.

### Diagnostic

Retain the existing 60/120 Hz trace as a repro; establish directly whether a future `BODY_FACT` can be associated with the same collision body before selecting a fix. Triage the separate shallow-corner regression failure.

## Reproduction Plan

Run `rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/levels/test_traversal_validation_route.gd -gunit_test_name=one_unbroken -gexit`. The restored fixture currently exercises 60 Hz; it enters wall stick and cancels the next-step jump without an impulse. The temporary diagnostic run exercised both 60 and 120 Hz, failed at both, and was removed from the fixture afterward.

## Side Findings

- The user-facing manual playtest and OD-009 gate remain outstanding in Story 1.10; this investigation does not establish M0 acceptance.

## Follow-up: 2026-09-26

### Consecutive selected-contact trace — CLI/GUT, not MCP runtime evidence

The temporary, read-only diagnostic in `tests/levels/test_traversal_validation_route.gd` sampled the provider's selected candidate on each post-commit step and mapped candidate RIDs against route bodies. Raw trace: `C:\Users\pinto\AppData\Local\Temp\opencode\wall-stick-candidate-trace.log:24-27,416-419`. Each row below is a **Confirmed** trace observation; `none` for `BODY_FACT` means no collider RID was published, not that the body was identified as anything else. All selected candidates have empty authored `surface_identity`.

| Rate / physics step | Selected source; body mapped from RID | World-space point | Wall normal | Continuity | Committed player velocity (m/s) |
| --- | --- | --- | --- | --- | --- |
| 60 / 362 | `SWEEP_PREDICTION`; `ObliqueWall` | `(55.02620, 1.050894, -0.493066)` | `(-0.173648, 0, 0.984808)` | `PRESERVED` | `(9.585591, 0, 1.690199)` |
| 60 / 363 (stick entry) | `BODY_FACT`; none (RID absent) | `(55.11373, 0.160365, -0.019821)` | `(-0.173648, 0, 0.984808)` | `SWITCHED` | `(9.949011, 0.568253, 1.754279)` |
| 60 / 364 (jump command step) | `BODY_FACT`; none (RID absent) | `(55.11373, 0.160365, -0.019821)` | `(-0.173648, 0, 0.984808)` | `PRESERVED` | `(0, 0, 0)` |
| 120 / 721 | `SWEEP_PREDICTION`; `ObliqueWall` | `(54.82361, 0.975894, -0.528788)` | `(-0.173648, 0, 0.984808)` | `PRESERVED` | `(9.848078, 0, 1.736482)` |
| 120 / 722 (stick entry) | `BODY_FACT`; none (RID absent) | `(54.82905, 0.078229, -0.070906)` | `(-0.173648, 0, 0.984808)` | `SWITCHED` | `(10.04798, 0.280269, 1.665099)` |
| 120 / 723 (jump command step) | `BODY_FACT`; none (RID absent) | `(54.82905, 0.078229, -0.070906)` | `(-0.173648, 0, 0.984808)` | `PRESERVED` | `(0, 0, 0)` |

**Confirmed producer and comparison.** `game/player/locomotion/contact/player_contact_provider.gd:366-369,436-451` constructs the wall `BODY_FACT` from `CharacterBody3D.is_on_wall()`/`get_wall_normal()` with `point = _body.global_position`, no collider/shape/identity and zero distance. `game/player/locomotion/contact/player_contact_provider.gd:224-246` ranks candidates first by approach opposition (entry `BODY_FACT` 0.2145/0.1050 versus sweep approximately zero), then time/distance, so this fact can win over same-step identified geometric hits. `_same_contact()` compares world-space normals and **points**, using a 25° angle and 0.2 m point threshold (`game/player/locomotion/contact/player_contact_provider.gd:259-272`; `game/shared/physics/wall_probe.gd:14-16`); `game/player/locomotion/contact/player_contact_provider.gd:532-555` labels a consecutive selected candidate `SWITCHED` when that comparison fails. Here the two selected points separate by **1.0123 m at 60 Hz** and **1.0077 m at 120 Hz**, despite near-zero normal-angle difference; steps are consecutive, not skipped.

**Refutation of face-change and excessive-travel explanations.** The entry-step `COMMITTED_COLLISION` and `SWEEP_PREDICTION` candidates each map by RID to `ObliqueWall` and have the same normal at both rates (`wall-stick-candidate-trace.log:25,417`). At 60 Hz the player's step-362→363 displacement is ~0.168 m and the same-wall sweep point shifts ~0.162 m; at 120 Hz the respective shifts are ~0.085 m and ~0.081 m — all below the 0.2 m limit. `FirstWall` and `ObliqueWall` are both authored (`game/levels/content/traversal_validation/traversal_validation_route.tscn:266-283`), but the entry evidence does not show a new face or high-speed point drift. **Deduced, not directly body-identified:** the selected `BODY_FACT` describes the same `ObliqueWall` contact, on the strength of its matching normal and the identified same-step committed/sweep evidence; the fact itself has no RID.

**Confirmed step-order consequence.** Post-commit entry accepts `SWITCHED` as runnable and starts stick from that frame (`scripts/player_controller.gd:402-424,903-918,995-1021`). On the following movement update, `has_supported_wall_contact()` reads the **previous** `SWITCHED` frame before a new commit (`scripts/player_controller.gd:1077-1094`), so `scripts/player_wall_stick_state.gd:35-54` cancels with `STATE_CANCELLATION` (reason 4) before the jump branch. The new step-364/723 frame is already `PRESERVED` but arrives too late for that gate. The restored GUT log records 0 wall-jump impulses, no finish and 0/1 at 60 Hz (`wall-stick-restored-focused.log:10-45`). The temporary diagnostic run failed the same uninterrupted route at both rates (0/1, 20/25 assertions; `wall-stick-candidate-trace.log:1144-1186`).

### Distinct verification paths and diagnostics

- **CLI/GUT:** Pinned 4.7.2 console via `rtk`. Restored route `-gtest=res://tests/levels/test_traversal_validation_route.gd -gunit_test_name=one_unbroken -gexit`: exit 1, 0/1 tests, 9/11 assertions, 60 Hz. Full `-gtest=res://tests/player/locomotion/test_wall_traversal_integration.gd -gexit`: exit 1, 17/18 tests, 363/364 assertions; shallow-corner test missed the second face at 60 Hz. Isolated corner `-gunit_test_name=never_reverses`: exit 1, 0/1, 14/18 assertions; it crossed at 60 Hz but lost running at 120 Hz. `-gunit_test_name=wall_stick_`: exit 0, **8/8**, 168 assertions, including switched-wall exit and real wall-stick jump. Logs: `C:\Users\pinto\AppData\Local\Temp\opencode\wall-stick-restored-focused.log`, `wall-stick-existing-regression.log`, `wall-stick-only-regression.log`. No recursive player suite was run in this investigation; the story gate remains open. The corner variability's cause is unestablished.
- **Godot AI MCP:** Active session `testgame@e362124f09f388c2` (Godot 4.7.2, plugin/server 4.0.4). `session_manage(list)`, `editor_state`, `scene_get_hierarchy`, `node_get_properties` (both walls), `resource_manage(load, wall_probe.tres)` and `script_manage(find_symbols, player_contact_provider.gd)` showed a ready/stopped route scene, authored walls and live 0.2 m probe setting; editor `logs_read(since_cursor=119)` returned zero new entries. Earlier MCP `filesystem_manage(scan)` reloaded the restored test, the route was launched and runtime player/wall nodes inspected, then stopped. A final `filesystem_manage(scan)` settled with 128 global classes (delta 0); `script_manage(find_symbols, test_traversal_validation_route.gd)` still found the restored test; `editor_state` was ready/stopped on the route and editor cursor remained 119. The current-run MCP game log contains only helper registration. `game_eval` returned `EVAL_COMPILE_ERROR` and later `EVAL_GAME_NOT_READY`, so it furnished **no** live candidate sequence or manual/visual completion. MCP-native `test_run` does not run recursive GUT suites and was not used as coverage evidence.
- **Preservation:** The temporary diagnostic was removed and the route test's `[60]` loop restored (`tests/levels/test_traversal_validation_route.gd:340-501`). Production traversal contracts and route geometry were not changed for this diagnosis. Story 1.10 stays in progress; route completion, full GUT/MCP gates, human playtest and OD-009/M0 acceptance remain outstanding.
