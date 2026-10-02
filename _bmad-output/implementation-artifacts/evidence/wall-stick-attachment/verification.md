# Wall-stick attachment implementation evidence

2026-10-01. Implementation complete; spec remains `in-progress` for parent-owned review. No review, commit, push, additional delegation, reset, or remote operation was performed.

## Canonical GUT gate (CLI, not MCP)

Pinned executable: `C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe`.

```powershell
rtk proxy "C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Focused variant replaces `-gdir` with `res://tests/player/input,res://tests/player/contact,res://tests/player/motor,res://tests/player/locomotion`. Logs were captured using `2>&1 | Out-File -Encoding utf8 <log-path>`.

| Gate | Passing / total | Assertions | Exit | Duration | Log |
|---|---:|---:|---:|---:|---|
| Fresh pre-implementation baseline | 229 / 238 | 11,749 / 11,769 | 1 | 64.098 s | [baseline](baseline-gut.log) |
| Final focused recursive suites | 131 / 133 | 4,623 / 4,630 | 1 | 11.523 s | [focused](focused-gut-complete.log) |
| Final full recursive suites | 246 / 255 | 11,985 / 12,005 | 1 | 72.288 s | [full](full-gut-complete.log) |

All 17 added tests pass. The attachment/motion suite is 12/12, wall-traversal contract 24/24, input-source suite 18/18, and contact suites pass. The final failures have the same nine test identities as the fresh baseline:

- `tests/levels/test_traversal_validation_route.gd`: zip-to-upper-deck, oblique-wall physical finish, and unbroken route completion.
- `tests/player/grapple/test_grapple_targeting_contract.gd`: authored-definition validation expects acceleration 48 instead of the current 60.
- `tests/player/grapple/test_grapple_targeting_integration.gd`: same-step activation expects 48; moving scene-origin expectation; pull-decay sampled window/floor expectation.
- `tests/player/locomotion/test_wall_traversal_integration.gd`: shallow-corner wall-run exit.
- `tests/player/motor/test_player_motor_integration.gd`: authored contexts expect deceleration 20/grapple gravity 1 instead of the current 50/0.

The focused failures are the final two entries above. No unrelated expectation or tuning was repaired. GUT reports four ignored non-GUT adapters (three at baseline plus the new wall-stick adapter); this is the expected separation between test frameworks. The final full run retains the baseline exit diagnostics: eight leaked ObjectDB instances and one resource still in use.

### Route compatibility limitation

The route enters wall run, grappling and wall stick, then commits the intended outward/up jump at both rates. Its oblique outward vector is approximately `(-1.389186, 5.5, 7.878462)`; the authored finish is not reached. Zip landing and the unbroken route fail before this wall challenge as they did at baseline. These results do **not** establish end-to-end route completion. Route geometry, production mover types and run tuning were not changed; only the stick guide and intended stick inputs were migrated.

## Complementary Godot AI MCP gate

Session: `testgame@17187ab35ae57813`; active project `testgame`; Godot 4.7.2-stable, Godot AI plugin/server 4.2.3. Preflight and resumed preflight observed ready/stopped state with `res://scenes/player.tscn`, five open scene tabs, ten retained warnings and no error rows. Operations included session listing, editor state/logs, hierarchy/root/property inspection, script reads/outlines and definition/capsule resource inspection.

Implementation/validation operations included `filesystem_manage(scan)`, `resource_manage(load/assign)`, `script_manage(read/find_symbols)`, `node_get_properties`, `test_run`, `project_run`, `game_manage(get_scene_tree/get_node_info/input_sequence)`, `editor_manage(game_eval)`, `logs_read`, and `project_manage(stop)`. Final scan settled with 131 registered global classes, delta zero. The editor's old empty stick-definition slot was updated with a targeted, undoable `resource_manage(assign)`; the other dirty scene state was not discarded. No force reload, scene save or autosave was used.

### Native adapter — schema only

`test_run(suite="wall_stick", verbose=true)` passed **3/3**, 15 assertions, 3 ms. It inspects authored definition/composition and source schema for immutable command/contact facts and one motor writer/commit. It does not execute recursive GUT or validate runtime dependencies. The MCP preload-cache warning remains applicable; the editor was not restarted to discard user state. Behavioral evidence below comes from a **fresh game process**, not this adapter or a cached editor preload.

### Fresh live engine smoke

Final launch: custom `res://tests/fixtures/wall_stick_motion_fixture.tscn`, `autosave=false`, helper live, no launch errors. Final game-log run ID: `r105520293-20` (editor run token 19). The startup fixture was replaced after launch with fixtures in isolated `SubViewport` worlds. Production player/HSM/input/contact/motor code advances on real physics ticks; the fixture moves actual `StaticBody3D` supports before the player. It never manually calls the controller's physics method for these motion checks.

Reproduction: pass [mcp-motion-smoke.gd.txt](mcp-motion-smoke.gd.txt) to `editor_manage(game_eval)`, inspect `/root/WallStickSmoke120`, then pass [mcp-interruption-smoke.gd.txt](mcp-interruption-smoke.gd.txt). Results are summarized in [mcp-results.json](mcp-results.json).

| Motion observation | 60 Hz | 120 Hz |
|---|---:|---:|
| Held commits observed during motion sequence | 115 | 224 |
| Entries / terminals / blocked carries | 1 / 0 / 0 | 1 / 0 / 0 |
| Maximum target-position error | 2.462184056e-8 m | 1.298030838e-8 m |
| Minimum center-to-wall-face stand-off | 0.450933384895325 m | 0.450887191295624 m |
| Sampled settled capsule overlaps | 0 | 0 |
| Maximum native recovery / commits per step | 0 m / 1 | 0 m / 1 |
| Player motion with only the grapple anchor moving | 0 m | 0 m |
| Actual moving grapple-anchor displacement | 0.300000041723251 m | 0.300000041723251 m |
| Obsolete-query-pose overlaps (reported separately) | 36 | 72 |

Both motion cases passed approaching/receding/reversing/stopped translations, continuous yaw at 0.2 rad/s, and a 180-degree camera turn. Forward remained held with opposing inputs and zero net movement axis. Fresh runtime composition observed the independent stick maximum of 100 m/s. Live tree/node inspection confirmed a real `CharacterBody3D` player and distinct `StaticBody3D` wall/anchor.

Seven interruption scenarios ran at **both rates: 14/14 passed**. Forward release preserved the exact previous committed velocity (0 m/s error), used a non-hold release commit, resumed `player.locomotion.grappling`, and caused no terminal or relatch. Jump won simultaneous forward/grapple releases and removed injected player tangent plus 3 m/s wall tangent: submitted velocity `(0, 5.5, 8)`, one terminal and one commit. A ceiling blocked upward carry once, safely detached once, and produced no sampled settled overlap. Destroyed support, disabled collision shape, four-meter teleport and shape-resource replacement each detached once without following the unsafe movement. All cases observed maximum one commit per step.

The direct MCP `input_sequence` gate also pressed `move_forward` and `move_back` together, with the movement test seam disabled: immutable forward fact true, axis `(0,0)`, grapple held, stick active. Releasing both actions returned to grappling with forward false, entry count one and zero terminals. The grapple occurrence/held flag was seeded through the fixture; this is not evidence of a physical right-mouse-button event. Jump/interruption cases used the injected command seam inside the live engine.

### Diagnostics and limitations

- Jolt's transform-moved StaticBody query pose lags its node pose inside physics callbacks. Attachment carry temporarily excludes only its bound supporting body during the motor transaction, preserves the bound local face/stand-off, and still sweeps against other geometry. Platform configuration and collision exceptions are restored immediately; corresponding GUT assertions pass. This does not guarantee safety for arbitrary mover teleports, which are rejected.
- Settled capsule queries run after queued transforms settle, once per observed idle frame/latest hold commit. They are sampled physics overlap observations, not screenshots or per-physics-step visual proof. The obsolete-pose overlap counts above are deliberately retained rather than hidden. No visual/art/feel acceptance is claimed.
- Continuous yaw is supported; pitch/roll incompatibility, excessive displacement/rotation, invalid/nonfinite samples, changed shape/lifetime and incompatible tether range fail closed. Unsafe carry is not repaired by writing player position.
- Earlier tooling attempts included a mixed-tab/space eval parse error, an incorrect command-frame method name, and an invalid `current_scene` assignment to a nested node. They were stopped/corrected and rerun in fresh processes. A 120 Hz release probe initially sampled subsequent grapple acceleration (0.496296 m/s difference); the fixture now latches the first detachment commit on the physics tick, and both final GUT/live release checks pass.
- Final game logs: 17 informational entries, no warning/error entries, zero dropped lines. Final editor logs: ten warnings, no errors; warning categories/subjects match preflight (one incompatible ternary, five shadowed motor parameters, four shadowed built-in identifiers), with source-line shifts from edits. No warning cleanup was attempted.
- Cleanup observed physics rate restored to 60, all smoke actions released, all fixture viewports freed, only `PhantomCameraManager`/`_mcp_game_helper` remaining, then stopped playback. Final editor readiness is `ready`, current scene `res://scenes/player.tscn`; the new definition slot and recorded run/user tuning were rechecked.

## Preservation / handoff

`rtk git diff --check` passes. [verify-preservation.py](verify-preservation.py) provides 26 read-only checks: eleven legacy run-related controller bodies, both wall-run/airborne state scripts, and legacy wall selection equal HEAD; route equals HEAD except its stick guide; ten recorded scene overrides and grapple acceleration 60 remain intact. Run maximum/minimum/speed/acceleration/gravity remain 100/3/10/4/0, run jump remains 5.5 up/8 away, ground deceleration 50, grapple gravity 0 and wall platform layers 0.

The frozen approval block's LF-normalized SHA-256 is `a5f7213f35fd07e64e5582ba99b73139432ecc5e51a55f54d9e9bea1c6324c27`, unchanged through task/evidence updates. Unrelated existing story/deferred-work documents, grapple tuning, investigation and previous spec were not edited by this implementation. All work remains uncommitted over HEAD `89ead0989f319a80007cb9835fea056c5ca8bf04`. Parent owns review; remaining baseline and route failures are explicitly not a green full-regression claim.

## Append-only parent review hardening — 2026-10-01

This section supersedes the earlier implementation's status and final counters, not its historical evidence. The spec is **`in-review`**, unchanged during hardening. All nine localized findings were patched/tested; no new agents, review, workflow approval, commit, remote operation, production mover-type change, route-geometry edit, run retuning, dirty scene discard, scene save or autosave occurred.

### Finding dispositions and reproduction

Shared engine repro: `tests/fixtures/wall_stick_review_cases.gd`, `WallStickReviewCases.run(tree, scenario, rate)`; support-velocity repro: `run_support_velocity(tree, scenario, rate)`. Both use isolated real `World3D` fixtures at 60/120 Hz. Motion cases advance production HSM/contact/motor on engine physics ticks. Velocity cases explicitly drive a real motor publication for focused entry policy; they are not synthetic-delta swept-collision proof.

| Finding | Localized disposition | Tested reproduction/result |
|---|---|---|
| 1. Same-resource shape mutation | Weak `Shape3D.changed` closure marks only pending geometry dirty. Next physics sample rejects `INVALID_SUPPORT` before another support exception. Explicit release/pre-delete disconnection; independent listeners do not retain attachments or collide with each other. | `same_resource_growth`: in-place `BoxShape3D.size.z += 0.2`, both rates: idle status unchanged, **0 additional holds**, **1 terminal**, listener removed. The resize itself creates **1 observed overlap of the previous pose** at each rate; no impossible retroactive-zero-overlap claim. Separate GUT listener lifetime/multiple-binding tests pass. |
| 2. Whole-body exclusion | Bind and every sample require **one enabled shape owner containing one shape**; motor rechecks before exclusion. | `compound`: selected wall shape translates locally toward a ceiling on the same body; **0 entries/holds**. `added_owner` and `added_shape_same_owner`: **0 further holds, 1 terminal**. All pass at both rates. |
| 3. Bound support vs run winner | Provider-private weak active-attachment seam selects corroborating physical evidence from **all collected physical wall candidates**, independently of legacy selection; clears with zero stick probe normal/lifecycle. No neighbor substitution or synthetic support. | `two_walls`: camera turns 180 degrees; legacy winner becomes `fixture.wall.neighbor`, physical support remains `fixture.wall.stick`; **1 entry, 0 terminals while supported**. Removing the original face then detaches once. **12 queries**, value-only frames, both rates. |
| 4. First motion baseline | Physical pose binds contact geometry; author pose starts motion history. Already elapsed tangent query lag is not replayed. Query/author catch-up and actual first target displacement are separately safety-checked; unsafe displacement remains rejected. | `already_moving`: motion enabled **before entry**; first hold travels **0.200000018 m at 12 m/s/60 Hz**, **0.166666672 m at 20 m/s/120 Hz**, target error **0 m**, stand-off at least **0.450887 m**. `entry_teleport`: 4 m on the entry tick, **0 entries/holds**. |
| 5. Support point velocity | Samples keyed by body plus owner, with finite/invertible owner/body pose. Native rigid/character/animatable point velocity plus **owner-relative motion only**; no native-plus-body-delta double counting. Static transform motion plus additional linear/angular surface velocity. Unavailable native state refuses entry instead of reporting a stationary body. No grapple-anchor velocity. | `owner_local`: stationary body, owner translation gives **(12,0,0)** rather than native zero. `rigid_first`, `animatable_first`, `character_first`: first native sample and adjacent sample approximately **(12,0,0)**, not zero or 24. `static_surface`: adjacent samples preserve approximately **(12.4,0,0)** including angular surface velocity. Each has a physical positive entry at relative 99 m/s and rejection at relative 100.1 m/s, both rates. Connected-editor `api_manage` metadata and Godot `PhysicsDirectBodyState3D` docs establish the point offset is from body origin in global axes. |
| 6. Cumulative pitch/roll | Compare orientation against the **binding basis**, not just the previous tick; world yaw remains supported. | `slow_roll`/`slow_pitch`: **0.00009 rad/tick**, at most one additional hold before rejection/one terminal; rejection on the second illegal increment, before meaningful overlap. Later sampled accumulated tilt is below 0.001 rad. Both rates pass. |
| 7. Invalid definition | Entry starts with null/validated-lock guards. Invalid `_ready` composition calls existing deactivation; deactivation avoids uninitialized-HSM calls. | `missing_definition`/`invalid_definition`: physical positive entry succeeds immediately before removing only the definition; invalid entry is refused at both rates. GUT `_ready` cases confirm disabled input/HSMs, uninitialized player and no advancing motion step, with only the expected composition error. |
| 8. Vacuous negative guards | Every existing low-speed negative case now first **enters with a real bindable physical publication**, clears stick, then changes one guard. Loss-flag fixture retains the same physical support/token; freshness changes the consuming step. Tests were not deleted or weakened. | `test_low_speed_wall_stick_entry_still_requires_grapple_input_and_contact_guards`: no active grapple, missing command, released grapple, missing forward, absent wall, stale frame, lost wall, outward motion all reject after their positive controls. Wall-traversal contract **24/24**. |
| 9. Approval hash | `approval_hash_matches` participates in `all_checks_passed` and process exit against the constant approved SHA. Frozen block unchanged. | Actual preservation **27/27**, exit 0. An **in-memory-only** altered expected hash produces false `approval_hash_matches`/aggregate and exit **1**; no spec/source tampering. [negative control](review-hardening-sha-negative-control.json). |

**Conservative geometry limitation:** even a stationary compound `StaticBody3D` cannot enter sticking. Adding/enabling any additional active owner/shape invalidates an existing stick. Empty/disabled unrelated owners may exist. This limitation applies to the attachment's full-body collision exception, not legacy wall-running selection. Legacy picker/run bodies and tuning compare unchanged against HEAD; no separate claim of arbitrary compound-stick support or compound-wall-run runtime acceptance is made.

### Additional review dispositions

- **Shape-index renumbering — fixed/tested.** Stable owner/local shape is authoritative; refresh the current public global index after validation. `disabled_owner_removed` removes an unrelated disabled owner, changes index **1 -> 0**, and preserves **one entry/zero terminals** at both rates. Compounds are disallowed, but disabled-owner renumbering remains reachable and is covered.
- **Motor timestep mismatch — narrowly hardened/tested.** Production already passes engine physics delta. A bound-support hold committed inside physics now fails closed if its submitted delta differs from `get_physics_process_delta_time()`. `delta_mismatch` submits 2x engine delta: blocked, **0 m motion**, one commit, both rates. General `begin_motion_frame`/pure idle algebraic unit samples remain supported; no synthetic delta is claimed as collision proof.
- **Overlap sampling — evidence limitation made explicit.** Fixture reports `hold_step_ids`, `settled_overlap_step_ids`, `missed_overlap_step_count`, bounded-ID overflow and `blocked_overlap_step_ids`. Blocked detachment captures its capsule pose on the physics commit, then queries it against the next settled world; this is a **follow-up observation**, not a historical world reconstruction. Final live blocked commit IDs **20/32** at 60/120 Hz both received a settled observation with zero overlap; GUT asserts this coverage. Forced growth overlap observations are retained separately from successful carry observations.
- **Stale deferred telemetry note — resolved in implementation, backlog untouched.** `is_wall_stick_speed_gate_open()` and its reason use the same **submitted incoming velocity and wall-point velocity** as entry. The old `deferred-work.md` evaluation-point note is stale; parent owns append-only backlog reconciliation. That user-owned document was not edited.

### Final canonical GUT results (CLI only)

Same pinned recursive commands documented above; final logs use the `-verified` suffix. Earlier `review-hardening-*-iteration*`, `*-final.log` and contact probes are intermediate captures, not the final acceptance counters.

| Final gate | Passing / total | Assertions | Exit | Duration | Log |
|---|---:|---:|---:|---:|---|
| Focused input/contact/motor/locomotion | **136 / 138** | **4,718 / 4,722** | **1** | **17.229 s** | [focused](review-hardening-focused-verified.log) |
| Full recursive `res://tests` | **251 / 260** | **12,066 / 12,083** | **1** | **77.872 s** | [full](review-hardening-full-verified.log) |

**Five added tests all pass**: engine review repro matrix, missing/invalid ready composition, weak-listener lifetime, support-velocity/relative controller entry, independent multiple listeners. All 17 initial implementation tests still pass (22 added since the fresh 238-test baseline). Original passing test identities survive; the same two focused/nine full baseline failing identities remain. [Read-only comparison](review-hardening-gut-comparison.json), reproduced with `rtk proxy python "_bmad-output/implementation-artifacts/evidence/wall-stick-attachment/compare-gut-results.py"`, asserts this identity equality and five added passes. Assertion-failure counts can differ within those same baseline tests; no baseline expectations were weakened. Full-run exit retains the baseline **8 ObjectDB leaks / 1 resource in use**. Route completion remains unestablished; its intended outward/up jump still has zero along-wall tangent.

### Final complementary MCP results

Session **`testgame@17187ab35ae57813`** remained mandatory/available; no CLI exception. Fresh read-only preflight/re-entry inspection covered session list, readiness/play state, editor logs, open player scene/properties, attachment/provider scripts and definition/API metadata. Implementation/validation used scans, script/property/resource inspection, diagnostic reload attempts, native test results, fresh custom launches with **`autosave=false`**, runtime tree/node inspection, `game_eval`, `input_sequence`, logs and stop. No user editor scene was saved/reloaded/discarded.

Final fresh game run **`r125129029-25`**, editor run token 24: **36/36 new hardening cases**, **2/2 prior motion cases**, **14/14 prior interruption cases**. Repro [new smoke](mcp-review-hardening-smoke.gd.txt), then the original motion/interruption smoke scripts. Full structured results, IDs/coverage and logs: [hardening MCP capture](review-hardening-mcp-results.json). Native schema adapter separately passed **3/3**, **15 assertions**, **3 ms**; its preload-cache warning remains. It is not GUT or behavioral dependency validation.

| Final live motion measurement | 60 Hz | 120 Hz |
|---|---:|---:|
| Held commits / settled observations / missed steps | **115 / 114 / 1** | **224 / 139 / 85** |
| Entry / terminal / blocked carry | 1 / 0 / 0 | 1 / 0 / 0 |
| Maximum target error | 2.462184056e-8 m | 1.298030838e-8 m |
| Minimum face stand-off | 0.450933384895325 m | 0.450887131690979 m |
| Sampled settled overlaps / ID overflow | 0 / 0 | 0 / 0 |
| Maximum native recovery / commits per step | 0 m / 1 | 0 m / 1 |
| Anchor-only player movement | 0 m | 0 m |
| Distinct moving grapple-anchor displacement | 0.300000041723251 m | 0.308333367109299 m |
| Obsolete-query-pose overlaps (separate) | 36 | 72 |

Release again preserved exact committed velocity (**0 m/s error**), resumed grappling with zero terminal/relatch; jump again submitted **(0,5.5,8)** with one terminal/commit. Direct `input_sequence` pressed opposing forward/back with the movement seam disabled: literal forward true, axis zero, held grapple, one entry/zero terminals; release returned to grappling with forward false. Action states are real; grapple occurrence/held flag and jump were fixture-seeded, not physical mouse-button verification.

**Diagnostics investigated, not erased:** the two retained editor line-49 errors were from the earlier inferred-Variant test source; it is now explicitly `WeakRef`. A no-op MCP diagnostic reload of that file reported **no diagnostics/reloaded**; the final fresh game confirmed it, the attachment and shared cases can instantiate. MCP `script_patch`'s pathless temporary validation of the `class_name WallStickAttachment` script returned fallback 43; a separate isolated probe established **"Class WallStickAttachment hides a global script class"**. That tooling probe run was stopped. Proper file-path compilation succeeds in final GUT and fresh MCP runtime; no addon/dirty-editor restart was attempted to suppress history. Intermediate callback-identity and uninitialized-HSM failures were fixed and rerun. Final game logs: **17 informational entries, 0 warnings/errors, 0 dropped**. Editor retains the same **10 warning categories plus 2 historical corrected-source error rows**; **0 new logger entries since cursor 2**. No visual/feel acceptance or every-physics-tick overlap proof is claimed.

Cleanup was MCP-observed: **60 Hz**, all used actions released, only `PhantomCameraManager`/`_mcp_game_helper` remaining before stop; playback stopped, editor **ready**, `res://scenes/player.tscn`, same five open tabs. Final properties preserve stick max 100; run 100/3/10/4/0 and user 50 ground deceleration/0 grapple gravity. `rtk git diff --check` and [27 preservation checks](review-hardening-preservation.json) pass. Frozen approved SHA remains `a5f7213f35fd07e64e5582ba99b73139432ecc5e51a55f54d9e9bea1c6324c27`. No implementation blocker remains; unrelated baseline/route failures prevent a green regression/route-completion claim. Parent owns subsequent review; all work remains uncommitted.
