# Wall-stick fixture correction — implementation / Dev Agent Record

Status: fixture implementation, review patches and final validation complete; parent marked the spec **done** after final checks. No story key or sprint edits. No commit/push. Broader failing gates and diagnostics remain disclosed below.

The initial sections below are historical observations: initial synchronized source SHA-256 `027cd443b6f6bfec8ca208b84050161d86b6c6a32b5408368e57361bd4f7b94f`, with the distinct initial no-barrier hash documented separately. Their original logs/manifests are retained, not rewritten or relabeled as follow-up results.

## Initial scope and correction (historical)

Only source edited: `tests/player/locomotion/test_wall_traversal_integration.gd`.

- `_wall_stick_report` selects the requested rate and awaits `process_frame` then `physics_frame` before `_new_world`. Original automatic player callbacks, settling, geometry, tuning, input seam, and synchronous entry/18-hold/jump bursts remain intact.
- Read-only post-commit readiness uses current step N, `_is_runnable_wall_frame(contact,N)`, valid `WallStickAttachment.matches_contact`, a successful single unblocked hold/source, active stick/grapple and held current command. It does not use the public pre-commit N−1 gate or sample/mutate support.
- First-hold and first-loss snapshots include engine frame, player/contact/result steps, configured rate, actual cached/requested delta, hold/block/support/command state and velocities. Maintenance stops immediately on its earliest invalid hold.
- Supported jump preparation explicitly asserts readiness and all 18 maintained holds before velocity/input changes. A failed guard returns the failing report without another manual transaction, launch preparation or JUMP injection.
- Added genuine inherited opposite-rate callbacks requesting 60/120/60 for both supported modes, checking cached delta alignment, 18 valid holds, positive reference, one authored `(0,5.5,8)` launch, terminal/airborne/cleanup and one commit.
- Added a real-fixture readiness-negative case: maintain 18 supported holds, execute an actual grapple release, then exercise both guarded preparation modes. A separate ordinary `GutTest` instance with `gut=null` retains the expected explicit assertion failure locally; the enclosing test asserts one failure, no velocity/step/command mutation, no later jump edge or jump source. No production test seams/doubles/overrides.

## Initial pre-barrier attempts / MCP red evidence (historical)

The guard/evidence/regression version had SHA-256 `f9a222ec1dd8a99f9ed0886439d12f1311e91a728adefe70f4b839d15febe22b`, without synchronization.

- **Canonical GUT attempt:** three fresh processes, each 1/1 test and 243 assertions passing. Raw `red-regression-01.log`–`03.log` and manifest retained. This is **not** a CLI red reproduction; expectations were not weakened and failures were not manufactured.
- The initial capture document's summary delimiter missed the red run summaries; raw logs are complete and unchanged. The later results index derives their actual totals directly from the retained raw logs rather than rewriting the red manifest.
- **Complementary live MCP red:** token 72, original fresh fixture and known opposite-rate continuation; 4/6 helpers failed at first hold step 4 with cached/requested 1/120 vs 1/60 (or inverse), `hold_carry_blocked=true`, active stick/binding cleared, one terminal at step 4. Each stopped after one hold, explicitly failed readiness, and retained prepared/launch step −1, jump count/reference zero, without overwriting velocity or injecting JUMP. Two aligned cases launched normally. `mcp-red.json` retains individual frame/delta/step tuples and the common first-failure snapshot.

## Initial canonical CLI/GUT gate (historical)

Pinned engine `4.7.2.stable.official.ed1daf0bf`, GUT 9.7.1. `rtk proxy python capture-validation.py.txt run ...` invokes the pinned console, all arguments/timestamps/source hashes/exits retained per manifest. No FPS/paint/seed overrides. Editor stopped for these batches.

Corrected source SHA-256: `027cd443b6f6bfec8ca208b84050161d86b6c6a32b5408368e57361bd4f7b94f`.

| Selection | Fresh processes | Test / assertion result each | Exit |
| --- | ---: | --- | --- |
| Original exact target | 10 | 1/1, 38 assertions (34 original + added readiness/guard checks) | 0 |
| New opposite-rate regression | 5 | 1/1, 243 assertions | 0 |
| New readiness-negative test | 3 | 1/1, 24 assertions | 0 |
| `wall_stick_` group | 3 | 11/11, 515 assertions | 0 |
| Complete file | 3 | 22/23 (856/860), 21/23 (851/860), 22/23 (859/860) | 1 |
| Recursive `res://tests/player/**` | 3 | 280/281, 12670/12671 assertions, 21 scripts | 1 |

Full-file failures: corner in all three runs (original lines 116–119 in first two; line 118 in third), plus landing in run 2 (original lines 202–206). Landing executes before the changed wall-stick fixture/new tests in source order; no landing or corner code/expectations were changed. These are separate failing tests, not supported-stick-jump failures; no unrelated fix attempted. Do not infer that finite passes eliminate historical intermittency.

All three normal recursive runs failed only the existing corner line 118 (`LOST=2` vs expected `SWITCHED=3`). Original target, both new tests, required-wall-loss and all other recursive tests passed in those runs. Each recursive shutdown reported 8 leaked ObjectDB instances / 1 resource still in use; retained as a separate diagnostic, not a new jump assertion failure or a clean-shutdown claim. Baseline investigation also retained this shutdown signature. Historical GUT failure attribution remains deduced because the historical executions lack per-step cached-delta measurements.

## Initial Godot AI MCP gate (historical)

Session `testgame@17187ab35ae57813`, Godot 4.7.2-stable, plugin/server 4.2.3.

- Fresh read-only preflight: session list; ready/stopped route/editor state; editor diagnostics; route hierarchy including real Player; affected suite, controller support gates, immutable motor delta guard, binding source; project 60 Hz. `mcp-preflight.json` records baseline cursor 6 / 6 historical error rows / 12 warning rows.
- After both source phases: `filesystem_manage(scan)` completed/settled, 135 global classes, delta 0; `script_manage(read)` verified the actual source. Corrected suite reported 1,936 lines / 92,933 bytes.
- Corrected `filesystem_manage(reimport)` refreshed the script entry but returned `skipped_non_imported` (not a script parse/reload proof). Token 74 separately verified freshly loaded runtime source/behavior; no noop script edits were used to claim reload.
- Red current-route launches used `autosave=false`, tokens 71 and 72; token 72 helper live, no launch-window errors. Temporary existing Gut/suite instances used `suite.gut=Gut`, attached to the tree; `gut.get_autofree().free_all()` is the inspected actual API, not obsolete `_autofree`.
- Token 71 transient eval compile/liveness limitations and token 72 game-log timeout are recorded in `mcp-red.json`. Editor cursor stayed 6→6 with zero new logger entries. No clean-game-log or visual/screenshot claim.
- Corrected live matrix: token **74**, frames **37–116**, loaded source confirms the internal barrier and 1,936 lines. **6/6** original-helper observations across inherited opposite callbacks and both modes: cached/requested delta aligned, all 18 holds valid, readiness step 21, prepared/launch/terminal step 22, reference 0.5, one `(0,5.5,8)` launch, one terminal, airborne/hold cleanup, idempotence and one commit. `mcp-green.json` contains the individual rate/frame/delta tuples and common observed facts.
- Negative smoke: frames **116–124**, both preparation modes reject the real released fixture with one explicit local GUT failure apiece, preserving body velocity/current step/current immutable command and injecting no jump edge/source. The second guard retained ordinary airborne `(0.033333335,-0.163333341,0)` rather than overwriting it with cleared vectors. Enclosing suite helper assertion failures: **0**.
- Runtime nodes: seven real `CharacterBody3D` fixture players inspected through `game_eval`, all automatic physics enabled and private worlds distinct from the route. `game_manage(get_node_info)` successfully inspected the route Player (16 children, player group).
- Editor nodes/resources rechecked: unchanged Player script, inherited process mode/priority 0, layer/mask 2/1, safe margin ~0.001, capsule radius ~0.45 / height ~1.8.
- Cleanup observed: seven viewports plus negative-case probe freed via actual `get_autofree().free_all()`, tracked count 8→0; temporary suite/Gut freed and absent after process boundary; runtime rate restored to 60. MCP stop succeeded; final editor ready/stopped on original route, project setting 60.
- Green attempt token 73 hit a 250ms eval liveness probe timeout after runtime-tree inspection. Stop/relaunch plus immediate eval token 74 succeeded. Final game log read timed out after 5 seconds again: **two implementation-phase game-log timeouts total**, no clean-game-log claim. Final editor logger cursor **6→6**, zero new entries, same six historical errors / twelve warning rows; affected seed warning moved to line 1924. No screenshot/visual verification claimed.

MCP native `test_run` does not discover this recursive `GutTest` file. No new native adapter is permitted by this fixture-only scope, and no native suite coverage/parity is claimed.

## Initial preservation (historical)

`implementation-start.json`: all 1,334 baseline hashes matched before source edits. `baseline-source.gd.txt` and `approved-spec.txt` preserve the starting texts.

`preservation-result.json` and post-MCP/spec `final-preservation-result.json`: all **1,333 other protected files unchanged**, sole approved source difference, zero missing files; **278/278 original assertion blocks literally intact and ordered**, including tolerances; frozen-after-approval bytes unchanged. This includes dirty user files, production code/guard, original investigation report/evidence, scenes/resources and rate/tuning definitions. `git-final.json` records `rtk git diff --check` exit 0 and unchanged HEAD `5d128486cf695f92dd4a370a6ee4ca6fb594b10f`. New artifacts remain only in this evidence directory; no production runners, overrides, or script files created.

## Initial remaining / handoff (historical)

- No implementation execution tasks remain. Full-file/recursive gates are not globally green: corner remains and one full-file landing failure was observed; outside this approved correction. Game-log completeness remains unavailable. Finite passing jump runs do not eliminate every historical intermittent possibility.
- At the initial handoff the spec was `in-progress`. The parent subsequently advanced it to `in-review`; that current status is preserved.

## Parent step-04 follow-up — 2026-10-07

Only `tests/player/locomotion/test_wall_traversal_integration.gd` changed as source. No further delegation, skills/workflow activation, deferred-work, production, hooks, tuning, sprint, commit or push changes.

### Source delta

- Capture requested/cached delta, alignment, configured rate, engine frame and physics-callback state immediately after the helper's internal process→physics barrier, **before `_new_world`**. Assert pre-spawn alignment there; retain the snapshot in the report. The transition regression additionally asserts the snapshot and first-hold step = entry step + 1.
- Include requested/cached alignment and successful commit delta agreement in readiness. The real supported negative fixture supplies a mismatched delta only to the preparation guard; it does not change production rate/commit/contact fields.
- An earliest failed hold in non-jump modes now explicitly fails and finishes the failure report before the planned exit mutation. Valid-hold exit semantics and synchronous transactions remain unchanged; no broader rate synchronization added.
- Reuse a concise real guard fixture and read-only case capture. Both modes reject mismatched delta, 17-hold history, prior-loss history, and destroyed bound wall. Both destroyed-wall checks execute at the same still-active pre-transaction step; JUMP remains absent and grapple remains held, making either accidental jump/release injection observable. The original actual-release inactive scenario remains, strengthened with pending/binding input equality.
- Transition checks reuse the existing speed/drift tolerances and assert nonzero tangential reference (observed 3) before the existing x=0 launch oracle. All original assertion blocks remain literal, including their tolerances.
- Post-runtime MCP surfaced a newly unused local `input_source` in the new supported-negative report. Removed that unused declaration only, then reran the final-source gates. Initial follow-up intermediate hash: `dd3928ffd6f877e5fd9ebcccaefecd32b9e65fadacd58d596255f29778ac1b5b`; final source: `1ca5f4c37e7dd3f7da20b6b9b5175b507da30f49c737855be72db293a1934e04` (2,083 lines / 101,054 bytes).

### Additional genuine GUT sensitivity control

`follow-up-barrier-intact.gd.txt` retains the intermediate oracle source (`dd3928…`). Patch removed **only the two awaits in `_wall_stick_report`**, retaining all new checks, geometry, settling, and production behavior. The actual red source hash was `48b479de08ed49e6126b2d60713c9cd8bf62a72f2397a7b1e11cc3e865f94198`. MCP scan/source read confirmed the absent barrier and retained pre-spawn oracle before the fresh pinned GUT runs.

- `follow-up-red-regression-01.log`–`03.log`: **3/3 expected red**, exit 1, 0/1 tests, **279/297 passing assertions** each. Every matrix case retained the old callback's cached delta **at pre-spawn**: requested 1/60 vs cached 1/120, or requested 1/120 vs cached 1/60. Six failed helper oracle checks plus their two transition assertions per case = 18 expected failures per process. Failure locations are the new pre-spawn assertions only; no movement failure was manufactured.
- Patch restored both awaits. `follow-up-mcp-restored-source.json` records settled MCP scan, actual restored source and editor cursor 6 with zero new logger entries. `follow-up-green-regression-01.log`–`05.log`: **5/5 green**, 1/1 test and **297 assertions** each on the identical barrier-intact intermediate source.
- The original initial `red-regression-*.log` remain historical **passing attempts**, not CLI red. This additional control demonstrates the new oracle's scheduling sensitivity; it does not prove a previously unmeasured historical movement failure cause or eliminate all intermittency.
- `follow-up-validation.py.txt index` independently reconstructs the two-line-only control from the retained intact snapshot and compares its hash with the actual red manifest. Original logs are never overwritten.

### Final-source Godot AI MCP gate

Mandatory session **`testgame@17187ab35ae57813`**, Godot 4.7.2-stable, plugin/server 4.2.3. Evidence: `follow-up-mcp-preflight.json`, `follow-up-mcp-restored-source.json`, `follow-up-mcp-launch.json`, `follow-up-intermediate-observations.json`, `follow-up-mcp-stop.json`, `follow-up-mcp-editor-recheck.json`, `follow-up-mcp-green-recipe.gd.txt`, and complete final raw response **`follow-up-mcp-final-green.json`**.

- Read-only preflight: session list, ready/stopped editor/route state, editor logs, actual affected suite, binding/input scripts and route hierarchy. Scans after control removal/restoration/final cleanup settled with **135** global classes, registration delta **0**; actual source reads confirmed the correct phase. Runtime fresh load—not a filesystem scan alone—proves the final source parsed/loaded.
- Final run token **77**, current route launched with **`autosave=false`**, helper live, no launch-window errors. Loaded script SHA-256 equals final disk hash `1ca5f4…`; barrier confirmed; 2,083 lines. Same existing `_wall_stick_report` in a temporary ordinary GUT context, no adapter or altered runner.
- Matrix frames **29–106**, **6/6** observations, requested 60/120/60 for modes 2 and 9 from opposite-rate callbacks. Pre-spawn engine frames **30/48/64/75/88/104** all aligned and in physics; entry/first-hold steps **3/4**; **18** valid/aligned holds; readiness/prepared/launch/terminal steps **21/22/22/22**; outward/tangent references **0.5/3**; one authored **`(0,5.5,8)`** launch, one terminal/commit, airborne/no further hold and idempotent terminal. Speed/drift remain within original tolerances.
- Inactive real-release checks: frames **106–116**, both modes explicitly rejected at steps **22/23**, one local expected assertion each, no velocity/step/immutable-command/pending-input changes and no later jump edge/source.
- Supported negative checks: frames **116–124**, **8/8** checks at step **21** (four conditions × both modes). Mismatched requested **1/120** vs cached/committed **1/60** yields alignment=false, commit-alignment=false and ready=false while actual result remains successful and support=true. History-only reports retain support/ready=true but reject 17 holds or a recorded first loss. After real wall destruction, active=true, supported=false, ready=false for **both modes before any additional transaction**, unchanged step 21, velocity, command and input; grapple remains held, no JUMP binding/edge/source. Expected failures stay local to ordinary probe instances (`gut=null`), one per check; enclosing helper failure count **0**.
- Eight real fixture `CharacterBody3D` players observed with automatic physics enabled and separate private worlds. Runtime route Player inspected successfully (16 children, `player` group). Editor recheck confirms unchanged player script/process settings, layers/masks 2/1, safe margin ~0.001 and capsule ~0.45 radius / ~1.8 height; project configured rate remains 60.
- Cleanup observed: **10→0** tracked objects (eight viewports, two guard probes); temporary suite/GUT freed and absent; runtime rate and cached delta restored to **60 / 1/60** across process→physics. MCP stop succeeded; final editor **ready/stopped** on original route.
- Incremental editor cursor remains **6→6**, zero new logger entries. Final full diagnostic read retains **six historical error rows and twelve warning rows**; transient unused-local warning gone, original seed warning now line **2071**. Logs were not cleared. Final and intermediate follow-up game-log reads each timed out after **5 seconds**: **two additional follow-up timeouts**, separately from the original **two initial implementation-phase timeouts**. Game-log cleanliness remains **unknown**.
- Token 75 eval liveness probe failed within 250ms; stop/relaunch plus immediate eval succeeded (intermediate token 76 and final token 77). A launch-evidence write attempted while playing was refused without writing; evidence was subsequently recorded after stop. All limitations remain explicit; no screenshot/visual or MCP-native suite/parity claim. Native MCP discovery still cannot run this recursive GUT file, and adding an adapter remains outside scope.

### Final-source canonical GUT gate and preservation

Final-source fresh pinned GUT batches are complete under the distinct `follow-up-final-source-*` prefixes. Pinned executable/version and exact arguments, timestamps, source hashes and per-process exits are retained in each manifest. `follow-up-cli-results-index.json` derives totals and failure identities from complete raw logs and confirms the actual control hash equals removal of only the two helper awaits. Every final process used source `1ca5f4…`; no FPS/paint/seed override or altered runner.

| Final selection | Fresh processes | Test / assertion result each | Exit |
| --- | ---: | --- | --- |
| Original exact jump target | 10 | 1/1, **40** assertions | 0 |
| Opposite-rate transition regression | 5 | 1/1, **297** assertions | 0 |
| Both readiness tests (`wall_stick_jump_readiness`) | 3 | **2/2**, **151** assertions | 0 |
| Full `wall_stick_` group | 3 | **12/12**, **710** assertions | 0 |
| Complete integration file | 3 | **23/24 (1058/1059)**, **22/24 (1050/1059)**, **23/24 (1058/1059)** | 1 |
| Normal recursive `res://tests/player/**` | 3 | **281/282**, **12869/12870** assertions, **21** scripts | 1 |

Whole-file failures remain separate unchanged tests: `test_wall_run_direction_never_reverses_across_a_shallow_corner` in all three runs (line 118 in runs 1/3; lines 116–119 in run 2), plus `test_landing_from_a_wall_run_routes_exactly_one_landed_transition` in run 2 (lines 202–206). All three normal recursive runs failed only corner line 118 (`LOST=2`, expected `SWITCHED=3`); the original target, both guard tests, transition regression, and all other recursive tests passed. No corner/landing expectation, geometry, code or related fixture was changed; no broader cause/fix is asserted. Recursive shutdown still reports **8 ObjectDB instances / 1 resource in use**; no clean-shutdown claim.

Intermediate follow-up (`dd3928…`) also passed exact target **10/10 (40 assertions)**, focused transition **5/5 (297)**, both guards **2/2 × 3 (151)**, and group **12/12 × 3 (710)**. Its first recursive process completed **281/282 / 12869/12870**, corner only; the second process was interrupted by the **120-second wrapper batch timeout** and is not counted as a complete gate. Both `follow-up-final-recursive-01.log` and the incomplete `-02.log` are retained without overwrite; no manifest was reached for that interrupted batch. Final-source batch used a **600-second** wrapper allowance and completed normally. Collector success is not a passing-test claim; the per-GUT-process exits above remain authoritative.

Final preservation (`follow-up-final-preservation.json`): **1,333/1,333 other protected baseline files unchanged**, zero missing files, only approved test-source difference. **278/278 original assertion blocks** and **329/329 reviewed-initial assertion blocks** remain literally intact and ordered. Frozen approved block unchanged; spec **in-review**. HEAD remains **`5d128486cf695f92dd4a370a6ee4ca6fb594b10f`**; `rtk git diff --check` passes. Source delta versus `follow-up-reviewed-source.gd.txt`: **+170 / −23 lines**, net **+147**, retained as `follow-up-source-diff.patch.txt`. Initial source diff/logs/investigation artifacts and dirty user files remain intact.

`follow-up-mcp-evidence-verification.json`: **67/67** checks of the retained final MCP response passed (source/hash/barrier, observed matrix/guards, cleanup, 60 Hz and editor diagnostics). This is consistency verification of observed MCP evidence, **not** additional native-suite coverage or proof of clean game logs.

Post-GUT final MCP recheck (`follow-up-mcp-final-editor.json`): settled filesystem scan (135 classes, delta 0), actual final script read (2,083 lines / 101,054 bytes), retained barrier/pre-spawn/readiness/destruction guards, original route hierarchy, project rate 60 and editor **ready/stopped**. Incremental logger cursor **6→6**, no new entries. No additional game-log claim.

### Current handoff

- All four requested fixture review patches and bounded validation are complete. No scope/status advancement or commit/push; parent owns the next review/status decision. Spec stays **in-review**.
- Whole-file and recursive gates remain non-green due to the unchanged corner test and one whole-file landing failure. Shutdown leaks and unknown game logs remain disclosed. Further fixes require separate approval; finite passing samples do not eliminate historical intermittency or prove the original historical CLI cause.

### Parent completion

Parent source/state/diagnostic checks confirm the final barrier/oracle, ready/stopped original route, configured 60 Hz and editor cursor 6→6 without new entries. Relevant review findings are resolved in `review-triage.md`; the spec now contains clickable Suggested Review Order links and is **done for the approved fixture-only correction**. No commit/push was made, per its frozen boundaries. Historical handoff statuses and source-specific test captures above are retained as evidence, not current workflow status.

`parent-completion.json` independently confirms the final source hash, sole approved source difference, 1,333 other protected hashes unchanged, frozen block unchanged, 42 retained JSON files parsing successfully and diff-check exit 0. One host-only Python evidence command initially failed PowerShell quoting before executing; the corrected command completed without source/runtime changes. The resolved workflow completion customization was empty. The completed spec was opened in OpenChamber's file panel using its dedicated file-open tool; editor launch/local-commit defaults were not used.
