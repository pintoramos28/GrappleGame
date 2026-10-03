# Story 1.10 — Code review, 2026-10-02

## Outcome and scope

**Original review outcome: not a clean automated acceptance gate.** All three review layers completed: Blind Hunter, Edge Case Hunter and Acceptance Auditor. Triage: **0 decision_needed, 11 patch, 2 defer, 3 dismissed**. Action items are written in the [story](../../1-10-complete-the-focused-traversal-validation-route.md#review-findings--2026-10-02). No gameplay, scene, resource, input or tuning changes were made during that review; patch authorization came afterwards. The original baseline evidence below is preserved; see the authorized-fix update at the end.

- Reviewed current route assets/scripts and `tests/levels/test_traversal_validation_route.gd` plus UID sidecars: **13 files, +1116/-0 lines** against the story's recorded baseline `dbd3289349636b41e9a69d75e146e4ea8b27b273`.
- Current production traversal is context, not an independent review target. The entire old baseline diff includes unrelated Story 1.9 and later movement changes and was deliberately excluded.
- Actual revision: **`2f56b7d39883762c96430d7389fdfb2b4fca02cb`**, branch `main`. Working tree was clean before review documentation; source stayed unchanged throughout validation.
- Review diff: `C:/Users/pinto/AppData/Local/Temp/opencode/story-1-10-review.diff`, 1194 unified-diff lines, SHA-256 `ed44b66b61209335e967e58632ee41e4c571a6cf50cd4b2c2cdc7d2783cfe606`.
- Model: GPT-6.1 Sol. Review layers used fresh child contexts; Blind Hunter received only the diff, Edge Case Hunter traced referenced code, Acceptance Auditor received the story and project rules.

## Human evidence — user-reported, not automation

Pinto stated during this review: **“I have manually confirmed the traversal route is good and player movement is good.”** This is valid qualitative human playtest evidence. It is not dismissed because the scripted fixtures fail. It does not specify a 120 Hz sample, all recovery classes, measured tuning values, or formal OD-009 approval. No movement retuning or route-layout replacement is recommended on the basis of the failed automation.

## Actionable findings

All `patch` findings are test/diagnostic repairs; retain the approved gameplay and its production authority.

| ID | Priority | Sources | Finding and required correction |
|---|---|---|---|
| R1 | High | Fresh CLI gate | Current command fixtures fail three route cases. Update input/aim/release schedules to prove the approved route, without weakening real arrival/state assertions or changing movement tuning. `tests/levels/test_traversal_validation_route.gd:184-503`. |
| R2 | High | blind+edge+auditor | Full-route loop is `[60]`; 120 Hz and all comparison assertions are unreachable. Run both rates and retain seconds-based comparisons. `:341-360`. |
| R3 | High | blind+auditor | Catch-node existence and a missed-jump landing do not prove return to the route. Exercise missed grapple, early release, lost run, short wall jump and target termination, then actually return in the same instance. `:35-51,97-114,172-181`. |
| R4 | Medium | blind+auditor | No short attachment is driven to the active 35 m boundary. Verify outward-only constraint and inward/tangential freedom through published targeting/attachment/motor facts, not duplicate rays. Current full-route maximum was only **21.3706 m**. `:117-140,460-463`. |
| R5 | Medium | blind+auditor | Moving-local-hit equality does not establish actual motion or slack-versus-taut carry. Assert nonzero motion, consistent published velocity and relative retreat/carry at both rates. `:144-179`. |
| R6 | Medium | blind+auditor | Release speed is recorded before release. A release that discards or reverses momentum could still satisfy the current >=5 m/s assertion. Compare committed pre/post-release vectors and measured action windows with documented tolerances. `:403-408`. |
| R7 | Medium | blind+auditor | Run/stick flags do not prove oblique/corner classification; normals/traces are collected but geometry behavior is not asserted. Add oblique/corner continuity and unsupported-surface rejection oracles. `:275-337`. |
| R8 | Medium | blind | The air-steering test holds one input from takeoff to landing. Preserved takeoff velocity could pass with air steering disabled. Change input in flight and observe the committed effect. `:54-94`. |
| R9 | Medium | blind | Zip destinations are accepted by broad grounded/x/y predicates. Landing on a raised anchor or later body could count as the named deck. Verify actual destination contact/physical bounds. `:218-221,268-271`. |
| R10 | Medium | blind | `wall_jumped` records a button press, not an accepted wall-jump impulse. Observe `player.jump.wall` in the committed accepted-source trace and the launch facts. `:306-309,329-337`. |
| R11 | Medium | edge | `jump_step.wall_valid` calls `has_supported_wall_contact()` after commit. That API expects frame N-1 while the current contact is N; it can falsely report invalidity. Derive the diagnostic from the correct committed-frame contract. `:453-456`; confirmed against `scripts/player_controller.gd:950-969,1181-1187` through MCP. |

### Deferred — not repaired or accepted

- **R12:** Seven player-suite failures outside the scoped route diff remain a separate gate. Relevant prior baseline/intermittency records exist; this review does not establish their root causes or authorize changing production tuning. See [deferred work](../../deferred-work.md).
- **R13:** Canonical GDD `needs-decisions` / OD-009 and sibling Story 1.4/1.5 review gates already prevent formal M0/Epic 1 closure. The user's qualitative confirmation is preserved, but explicit measured decision approval is not invented. GDD lines 45/454; sprint ledger lines 58-64.

### Dismissed standalone findings — three

1. Local/world velocity mismatch under a future rotated/scaled parent: the actual standalone route and `Course` transforms are identity, so the hypothesized error is not present in this reviewed composition. No generic reuse requirement justifies a production change here.
2. A mandatory continuously walkable return ramp: AC 7 explicitly permits grapple/remaining-movement recovery, not only a connected footpath. The ramp geometry observation and unsuccessful scripted return attempts reinforce R3's missing return proof; they do not independently establish that the manually approved route is unrecoverable or authorize reshaping it.
3. A separate maximum-commit aggregate defect: the aggregate does not independently prove every step, but the permanent motor contract suite and complementary single-writer checks own that invariant, and no route-side movement writer was introduced. Do not inflate this into a new gameplay defect.

## Pinned CLI/GUT — canonical, separate from MCP

Godot **4.7.2-stable**, GUT **9.7.1**, Jolt selected by the project. Commands ran through `rtk proxy` from the project root:

```powershell
rtk proxy "C:/Users/pinto/Documents/Godot Projects/Godot 4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gtest=res://tests/levels/test_traversal_validation_route.gd -gexit
rtk proxy "C:/Users/pinto/Documents/Godot Projects/Godot 4.7.2/Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
```

| Gate | Passed / total | Assertions | Exit |
|---|---:|---:|---:|
| Focused route GUT | **7 / 10** | **656 / 664** | **1** |
| Recursive player GUT, including nested locomotion suites | **272 / 279** | **12375 / 12388** | **1** |

### Route failures and measurements

- `test_jump_into_real_zip_pull_reaches_the_next_upper_deck`: attached/released at both rates, but missed the named upper deck; ended on the lower floor at x **38.0640 / 40.4305**, y approximately **-2.9991** (60/120 Hz).
- `test_real_oblique_wall_run_stick_and_jump_reach_the_physical_finish`: run/stick/jump command observed at both rates, but no finish; recorded launch velocity approximately **(-1.38919, 5.5, 7.87846)**, and lower-floor final positions. Do not repeat the old story's wall-stick cancellation as the current failure cause.
- `test_one_unbroken_command_route_completes_every_traversal_stage_at_both_rates`: actually runs **60 Hz only**; stopped in `near_land`, no finish, two ground-jump impulses and zero wall-jump impulses. Reported elapsed **12.0 s**, maximum commit count **1**, pre-release speed **22.0 m/s**, maximum attachment distance **21.3706 m**.
- Positive jump gate: 60/120 Hz elapsed **2.23333 / 2.20833 s**, x **-10.96278 / -10.96867**; existing tolerances **0.10 s / 0.5 m** passed.
- Boundary acquisition examples: accepted NearAnchor and BoundaryAnchor at both rates; BoundaryAnchor hit distances **34.70403 / 34.70275 m**. BeyondAnchor rejected. This does **not** prove active-boundary or moving-retreat carry.
- Moving-local-hit and invalidation case passed at both rates: typed termination **TARGET_INVALIDATED (2)** and exactly **one** ended event. Invalidation-to-return was not tested.

### Player failure identities — external to this route review

- `test_grapple_targeting_contract.gd::test_definition_validation_locks_authored_values_and_bounds_acquisition_tolerance`
- `test_grapple_targeting_integration.gd::test_same_step_activation_seeds_state_and_keeps_pull_playable`
- `test_grapple_targeting_integration.gd::test_moving_scene_origin_does_not_change_camera_target_or_acquisition_range`
- `test_grapple_targeting_integration.gd::test_grapple_pull_decay_reaches_the_floor_and_commits_the_speed_cap`
- `test_wall_traversal_integration.gd::test_wall_run_direction_never_reverses_across_a_shallow_corner`
- `test_wall_traversal_integration.gd::test_wall_stick_jump_uses_only_authored_up_and_horizontal_away_motion`
- `test_player_motor_integration.gd::test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band`

Shutdown also reported **8 leaked ObjectDB instances / 1 resource in use**. The prior re-anchor [handoff](../wall-stick-grapple-reanchor/parent-final-results.md) records a red comprehensive baseline and intermittent wall outcomes. Matching totals alone do not establish matching failure identities or causation.

Raw PowerShell captures are UTF-16 in the approved temporary directory:

- `C:/Users/pinto/AppData/Local/Temp/opencode/story-1-10-review-route-gut.log`; SHA-256 `958500dcf9504594591a1a33a590a944a308a37b056170819b273ab7a13a630c`.
- `C:/Users/pinto/AppData/Local/Temp/opencode/story-1-10-review-player-gut.log`; SHA-256 `0990e9a05e37682f2f79a4d7800591d9b60407285b083801cd911e0a8ea7e3cd`.
- Read with `Path(...).read_text(encoding='utf-16')`; these temporary raw files are not claimed to be repository-retained artifacts.

## Godot AI MCP — complementary live-session evidence

Session **`testgame@17187ab35ae57813`**; Godot **4.7.2-stable (official)**, plugin/server **4.2.3** (different from older planning/story version records). Active editor started ready/stopped on `res://game/levels/content/traversal_validation/traversal_validation_route.tscn`.

Meaningful operations and observations:

1. `session_manage(list)`, `editor_state`, `logs_read(editor)`: active project identified; baseline cursor **5**, five retained historical error rows and eleven warning rows. These were not cleared or represented as fresh failures.
2. `scene_get_hierarchy`, `script_manage(read)` for the moving anchor and finish, `resource_manage(load)` for `grapple_definition.tres` and `wall_probe.tres`, and player property inspection: production composition present; shared grapple maximum **35 m**, acceptance tolerance **0.005 m**, current approved pull initial acceleration **60 m/s²**. Wall probe resource retained.
3. `filesystem_manage(scan)`: settled, **135** global classes, delta **0**. No gameplay resource/script edits occurred during review.
4. `project_run(custom, autosave=false)` launched the actual route; runtime hierarchy/node inspection and bounded `game_eval` observed the player, moving target, oblique wall and physical finish. Run IDs: **r218661956-44**, **r218832895-45**, **r219052040-47**, **r219687860-48**.
5. Production `PlayerInputSource` test seam drove the opening jump in the actual current scene at **60 and 120 Hz**, without player-position/velocity writes. Both landed on the second upper deck with **grounded → airborne → grounded**, maximum commit count **1**, same player per run, elapsed **2.11667 s**. Final x **-10.95392 / -10.96785 m**; difference **0.01394 m**, within the route test's **0.5 m** tolerance. Runtime rate restored to **60 Hz** after the diagnostic sample. These are opening-jump smoke results, not full-route rate equivalence.
6. At 60 Hz, walking off the second deck without grappling reached the lower catch using the same player (x **5.34559**, y **-2.90255**, **1.91667 s**). A fresh run also caught a missed opening jump at x **-11.61662**, y **-2.93280**, **2.01667 s**. No reload was required to catch either miss.
7. A bounded recovery attempt retained route ID **64021857906** / player ID **65632470939** throughout. The first ramp approach was misaligned; a second centered grounded approach also did not ascend. A jump/grapple attempt acquired the start-deck upper edge but did **not** return to the upper route. These are unsuccessful scripted strategies, not a proof that no production-input recovery exists. **No successful full return is claimed by MCP**; R3 requires a demonstrated intended strategy and regression coverage. User-reported manual approval remains separate.
8. `editor_screenshot(source="game")` returned an actually observed **960×540**, non-stale frame of the lower teal recovery deck, primitive targets/walls and existing grapple telemetry. It was not a finish screenshot and no repository screenshot file was saved.
9. `project_run(main, autosave=false)` separately launched **`res://main.tscn`** at **60 Hz**; live hierarchy and game eval confirmed the launch scene. Run **r218896932-46**. No current-run launch errors were returned.
10. MCP runtime `ResourceLoader`/`ResourceUID` readback loaded player, main and route as `PackedScene`; UIDs resolved to the expected paths. Player **uid://u1u36ceuo8uj**, main **uid://dgei3sdvi5j3i**, route **uid://djubh0hpim1s8**; live player source **res://scenes/player.tscn**.
11. `test_run(suite="wall_stick", verbose=true)`: **4/4**, **26 assertions**, **7 ms**. This existing top-level `McpTestSuite` checks source/schema only; it is **not route gameplay coverage or recursive GUT parity**. The standard preload-cache warning was retained.
12. Current-run game logs contained only helper registration, no errors or dropped lines. Editor logger cursor remained **5→5**, no new entries. Actions were released, **60 Hz** retained, playback stopped, original five open scenes preserved, editor ready on the route. Historical debugger rows remain.

## Preservation and remaining gate

`rtk git diff --check` passed before and after the review documentation edits. Final `git status --short` contained only the story, deferred-work ledger and new `evidence/1-10/` report. A post-documentation MCP scan settled with **135** global classes, delta **0**; the editor was ready/stopped on the route and cursor **5** still had no new log entries. No commit, staging, push, scene save, plugin upgrade, production HUD/checkpoint work or unrelated baseline repair occurred.

At review completion, Story 1.10 remained **in-progress** and patch handling awaited the user's workflow choice. Human feel approval was accepted; automatic route completion, all recovery returns, full 60/120 equivalence, external regression closure and formal M0/Epic 1 acceptance were not claimed by that review.

## Authorized-fix update — 2026-10-02

Pinto selected **“Apply all”** after the walkthrough. **All eleven patch findings are resolved in test/diagnostic code**, with the approved production movement, route geometry and tuning unchanged. Final normal-speed focused route GUT: **13/13 tests, 818 assertions, exit 0** at actual 60/120 Hz, including the final independent-review oracle corrections; live MCP separately observes full route and all six recovery returns. The hardening pass's concrete watchdog/oracle gaps were addressed without reducing outcome assertions. [Full fix evidence and R1–R11 resolution map](review-fixes-2026-10-02.md).

R12/R13 remain deferred, not accepted: latest recursive player **272/279**, the same seven named failures and shutdown leakage; native boundary schema **4/5** on its untouched authored-value expectation; formal human-rate/recovery evidence, OD-009 and sibling-story gates still pending. Story/sprint remain **in-progress**. No production patch, staging, commit or push occurred.
