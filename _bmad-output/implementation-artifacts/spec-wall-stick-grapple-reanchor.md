---
title: 'Re-anchor grapple to the stuck wall and synchronize its visual'
type: 'bugfix'
created: '2026-10-01'
status: 'in-review'
baseline_commit: '89ead0989f319a80007cb9835fea056c5ca8bf04'
context:
  - 'AGENTS.md'
  - '_bmad-output/project-context.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Wall sticking retains the previous grapple point; ordinary moving geometry leaves that point frozen. The attachment marker independently reads the historical acquisition hit, even when the rope follows a live anchor.

**Approach:** Successful stick entry re-anchors the same grapple occurrence at the physically contacted wall point. Capture that material point in shape-local coordinates and drive anchor, marker and rope endpoint from one authoritative sampled state.

## Boundaries & Constraints

**Always:** Preserve current uncommitted work, wall-running policy, 100 m/s stick maximum, collision-safe carry and pure up/out stick jump. Forward release resumes the same valid grapple at the new wall point. Re-anchor once per successful entry; preserve occurrence ID, originating scope, elapsed pull policy and immutable range/cap/definition. Respect fresh wall eligibility/response. Keep one motor commit and separate GUT/MCP evidence.

**Ask First:** Resetting the pull timer, creating a new grapple occurrence, changing tuning/range, production mover types/route geometry, or discarding dirty editor state.

**Never:** Use player center/hold destination as wall anchor; derive physical support from the old grapple; mutate historical ray results/shared definitions; fabricate Grappleable IDs; add an acquisition raycast for re-anchoring; globally change ordinary grapple tracking.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|---|---|---|---|
| Stick entry | Valid grapple and corroborated physical wall | Replace old point with current placement of captured wall contact | Same occurrence; no extra begin/end |
| Moving wall | Translation, yaw or supported owner-local motion | Anchor, marker and rope endpoint follow the same local point | Fresh contact-point velocity, not player stand-off velocity |
| Forward release | Grapple remains held/valid | Resume grappling to new wall point; continue tracking | No reversion to old target |
| Former target changes | Old target moves, dies or invalidates after replacement | New attachment unaffected | Remove old validity dependencies |
| Re-anchor rejected | Ineligible/invalid wall, range/scope mismatch | Keep original valid grapple; do not enter stick or arm zero baseline | Typed failure; atomic transition |
| New target invalid | Destroyed wall, invalid geometry/contract, scope or severe motion | Exactly-one terminal; clear rope and marker | Existing typed reason funnel |
| Intentional point jump | Successful re-anchor revision | Reset visual interpolation once | No resets during continuous following |

</frozen-after-approval>

## Code Map

- `scripts/player_controller.gd` -- post-commit stick entry, feedback, rope/marker and termination.
- `game/player/locomotion/wall_stick/wall_stick_attachment.gd` -- private proven shape-local contact, not player destination.
- `game/player/abilities/grapple/{grapple_controller.gd,grapple_attachment.gd}` -- occurrence, sampling/cache and lifecycle owner.
- `game/player/abilities/grapple/{grapple_surface_binding.gd,grapple_target_resolver.gd,grapple_attachment_diagnostic_snapshot.gd}` -- independent contact-local binding, pure policy reuse and value-only revision.
- `game/shared/contracts/{grappleable_3d.gd,grapple_anchor_state.gd}` -- typed wall policy and value-only sample.
- `game/player/abilities/grapple/presentation/grapple_target_marker.gd` -- stale aiming-hit presentation path.
- `tests/player/grapple/{test_wall_stick_reanchor.gd,test_grapple_active_visuals.gd}`, `tests/fixtures/wall_stick_reanchor_fixture.{gd,tscn}` -- engine-driven re-anchor and actual endpoint checks.

## Tasks & Acceptance

**Execution:**
- [x] `wall_stick_attachment.gd`, new `game/player/abilities/grapple/grapple_surface_binding.gd` -- create independent weak-body/shape-local point binding with safe geometry/lifetime cleanup; survives carry release.
- [x] `game/player/abilities/grapple/grapple_target_resolver.gd`, `game/shared/contracts/grappleable_3d.gd` -- reuse pure eligibility/range/response checks for physical contact without extra ray or legacy sampling-cache contamination.
- [x] `grapple_controller.gd`, `grapple_attachment.gd` -- typed guarded re-anchor transaction; replace target/response/sample on same occurrence, increment revision, reset geometric caches only, sample contact-local bindings before static fallback.
- [x] `scripts/player_controller.gd` -- prepare before arming stick baseline; commit both without yielding; preserve committed movement and old/new revision ordering.
- [x] `grapple_attachment_diagnostic_snapshot.gd`, `presentation/grapple_target_marker.gd`, `scripts/player_controller.gd` -- share value-only active anchor/revision for both visuals; attached sample beats cached aiming result; clear stale endpoints and reset interpolation only on visibility/revision changes.
- [x] `tests/player/{grapple,locomotion,contact}/`, `tests/fixtures/` -- add re-anchor, policy, atomicity, lifetime and geometry tests; intentionally migrate old-anchor and hidden-only reset expectations without weakening unrelated cases.
- [x] `tests/test_wall_stick_mcp.gd`, feature evidence -- retain schema-only adapter distinction; verify production runtime anchor, marker and rope transforms at 60/120 Hz through MCP and full recursive GUT.

**Acceptance Criteria:**
- Given successful stick entry, when committed, then the actual wall contact replaces the old point without replacing the occurrence or restarting pull timing.
- Given moving support, when held then released forward, then anchor and both visual endpoints follow its captured material point at 60/120 Hz.
- Given a rejected replacement, when attempted, then old attachment and motor baseline remain unchanged.
- Given former target destruction, when already re-anchored, then the new grapple remains valid; destroying the new target terminates once.
- Given ordinary non-stick grappling, when sampling/presenting, then acquisition/range/query and existing motion behaviour remain intact, except the active marker now follows its live anchor.

## Spec Change Log

- 2026-10-01: Frozen goal unchanged. Implemented contact-local re-anchor and revision-aware visuals. Migrated only superseded old-target lifecycle/tracking and hidden-only reset expectations; unrelated baseline failures remain. Execution checks completed after validation; status intentionally retained as in-progress for the parent's independent review.

## Design Notes

Bind local contact using physical body pose times owner transform; publish its current authored-world placement. Do not confuse this point's velocity with the capsule stand-off point. Re-anchor is a post-commit revision change: step N movement used old anchor; feedback may display the new validated anchor, and next-step influence uses it. Preserve actual committed velocity; invalidate old boundary/pull caches rather than retroactively claiming new-point forces. Ordinary and explicit STATIC targets follow local contact only in this new tracking mode. Binding must not depend on the released carry object or manufacture historical ray hits.

## Verification

- Establish fresh baseline and run affected suites, then canonical full gate: `rtk proxy "C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit`.
- MCP: preflight, inspect/rescan loaded scripts/resources, fresh `autosave=false` runtime; inspect actual anchor/marker/rope transforms, simulated inputs, logs and final readiness. Native adapter is not GUT/runtime coverage. Capture viewport evidence if supported; never claim unseen visuals.
- Preserve existing edits; `rtk git diff --check`; no unrequested commit/push or unrelated baseline repairs.

## Dev Agent Record

- Read-only preflight: `testgame@17187ab35ae57813`, ready/stopped on traversal validation route. Inspected session/state/logs/hierarchy, instanced player properties and attachment/controller scripts. Ten prior warnings and two historical corrected-source error rows, cursor 2. No tests or runtime launch yet. Continuing over the previously approved dirty checkout; no unknown-path changes observed.
- User approved the full 1,610-token scope, anchor-only reset with the same occurrence/pull timer, continued tracking after forward release, and implementation over the existing uncommitted work. Frozen intent is locked.
- Continuation preflight: same active MCP session ready/stopped, route/player inspected; diagnostics unchanged (two retained historical corrected-source errors, ten warning rows; cursor 2). Incremental pre-feature worktree snapshot captures 437 files at `C:/Users/pinto/AppData/Local/Temp/opencode/wall-stick-reanchor-baseline.json`; frozen approval SHA-256 `14e2d5fa5986b4f9dbebacd48b0e20c444724e582d8d3cc871f48d426a58504f`. Sprint synchronization skipped: this standalone feature has no story key.
- Implementation: independent weak-body/shape-local contact binding; fresh pure wall policy and response sampling isolated from legacy acquisition caches; typed prepare/commit before zero-baseline arming; same occurrence/time/scope/definition/range/cap; geometric-cache invalidation only. Entry movement retains its actual old-revision commit, with a separate first-hold baseline flag. Both visuals consume the same value-only revision/sample. Terminal cleanup clears old aiming state and detaches rope geometry rather than creating a zero-height cylinder.
- CLI/GUT (pinned 4.7.2, recursive): fresh full baseline 251/260 passing, nine failures, exit 1; latest player gate 260/266 passing, six existing failures, exit 1; final full gate **267/276 passing, the same nine baseline failing identities, exit 1**. All 16 new tests pass (12 re-anchor, four active visuals). No new failing identity; overall regression remains red. Unsuccessful focused attempts retained. Existing leaked-object/resource shutdown warnings and expected negative-path diagnostics are separately noted in [feature evidence](evidence/wall-stick-grapple-reanchor/README.md).
- MCP implementation/validation session `testgame@17187ab35ae57813`: inspected scripts/scenes/resources, scanned classes and attempted script reloads; final scan settled (134 classes). Native `wall_stick` adapter **4/4**, schema/source-only with preload-cache warning. Fresh `autosave=false` run **`r166780006-32`** repeated **6/6 live cases** at 60/120 Hz for ordinary/STATIC/MOVING policies, translation+yaw+owner-local motion, forward release, former-target destruction and new-target typed terminals. Measured maximum anchor/actual marker/point-velocity error 0, rope endpoint error 4.8054801027e-7 m, one motor commit, zero sampled overlaps. Contact-point and player stand-off velocities were observably distinct; no carry dependency remained after release.
- MCP standalone production-input smoke additionally used right-mouse events and movement actions after launch-focus neutral rearm; observed same occurrence/revision after forward release and old-target destruction. [Viewport proof](evidence/wall-stick-grapple-reanchor/mcp-contact-visual-proof.png) is an actual diagnostic capture with only the fixture's opaque presentation capsule hidden; normal-view readability/feel is not accepted by that image. Long-run rope endpoint error was approximately 4.91e-6 m. Synchronous terminal clearing does not forbid later ordinary aiming previews.
- MCP diagnostics: some no-op reload checks returned fallback error 43; player controller reload succeeded, and fresh CLI/MCP game processes validated final dependencies. Editor retains two pre-feature errors, three corrected-source weakref errors and ten warnings (cursor 5); logs were not cleared. Temporary eval indentation/type errors and an unlatched fresh standalone attempt are disclosed, not counted as re-anchor passes. Final fresh launch/game log had no new runtime/launch errors or dropped lines; editor cursor remained 5. See [MCP evidence](evidence/wall-stick-grapple-reanchor/mcp-final-validation.json).
- Preservation: existing read-only gate **27/27**; all 39 captured prior evidence/spec files and 27 protected scene/resource/project files byte-identical to the approved snapshot; all 437 snapshot files remain. HEAD and frozen SHA-256 unchanged. `rtk git diff --check` exit 0; approved helper ran in `diff` mode only. No baseline snapshot replacement, unrequested source repair, review, commit, push or remote operation. [Preservation evidence](evidence/wall-stick-grapple-reanchor/preservation-final.json).
- Final MCP cleanup/readback: all simulated actions/right mouse released, 60 Hz restored, playback stopped, editor ready on the original traversal route. Inspected player script and both scene-referenced definitions through MCP; authored stick/jump/grapple tuning unchanged. No user scene saved, discarded or force-reloaded. Tasks complete; status remains **in-progress** for the parent-owned independent review.
- Parent entered independent review after checking all execution tasks and the recorded GUT/live measurements. Review separates the incremental re-anchor diff from the larger dirty HEAD range, including prior approved work. Fresh editor readback remains ready/stopped; three transient, now-corrected weakref parse/compile rows are retained at cursor 5 and are not hidden.
- Parent pre-triage verification: fresh full GUT **267/276**, same nine failing identities, all four comparator checks passed; preservation **27/27**, captured-file and whitespace checks passed. Fresh MCP run **`r167646100-33`** repeated **6/6** moving/released/terminal cases with anchor/marker/velocity error 0 and rope endpoint error 4.8054801027e-7 m; no new editor entries or game errors. Original route ready/stopped and run tuning 100/3/10/4/0 confirmed. [Parent MCP record](evidence/wall-stick-grapple-reanchor/parent-mcp-recheck.json).
- 2026-10-02 review triage: all three independent passes returned; [localized patch findings](evidence/wall-stick-grapple-reanchor/review-triage.md) concern fresh response ordering, sampling gaps/native bodies, atomic validity/ownership and stronger visual/clock assertions. No intent gap or non-frozen design change requires re-derivation. MCP before-fix response repro observed both incorrect threshold verdicts under valid test-only tuning; production tuning was not changed. Same session remains ready/stopped, no editor additions since cursor 5. Hardening and fresh dual-gate results are pending; status stays in-review.
- 2026-10-02 hardening closeout: **R1–R12 patched and verified**, with [superseding dispositions](evidence/wall-stick-grapple-reanchor/review-triage.md#verified-dispositions--2026-10-02) and [hardening evidence](evidence/wall-stick-grapple-reanchor/hardening-results.md). Incoming response severity is pure/current; skipped-sample displacement scales only for surface tracking; Animatable uses native velocity. Alias/null/stale, detached/freshly invalid original, motor ownership/completed-step and released-carry guards reject before baseline arming. Ordinary resolution, explicit acquisition precedence, definitions, production mover types, wall-running and jump/carry policy are preserved. No further independent review, agents, commits, pushes or remote operations were performed.
- Hardening GUT/CLI (pinned 4.7.2, recursive, no source/reload write overlap): final player **273/279**, same six baseline identities, assertions **12379/12388**, exit **1**; final full **280/289**, exact same nine baseline identities, assertions **13035/13052**, exit **1**. All **13** new hardening groups / **100** scenario-rate pairs pass in both, along with the earlier 16 feature tests. New-suite teardown observes restored 60 Hz and actual delta 0.01666666666667 s. The comprehensive gate is **not green**; expected negative-path diagnostics and eight leaked objects/one resource remain. [16-check comparison](evidence/wall-stick-grapple-reanchor/hardening-test-comparison.json).
- Hardening MCP session **`testgame@17187ab35ae57813`**: ready/stopped preflight on original route, source/API/resource inspection, settled scans (135 classes), reload checks, schema adapter **4/4** with preload warning, and fresh `autosave=false` games. **`r184426936-37`** observes **100/100** current shared hardening cases at 60/120 Hz, **6/6** stronger original policy cases and **10/10** native-entry probes. **`r185847395-38`** repeats **6/6** real Animatable/Character/Rigid continuation/release cases. Native maximum anchor/marker/velocity error **0**, assigned rope endpoint error **2.8493575428e-6 m**, one commit, zero sampled overlaps and no missing active visual samples. Actual hidden/detached/replaced/wrong-cylinder negative controls and exact clock/curve forced-reset contrasts pass. These are MCP-observed real-physics/geometry results using fixture input injection, not new framebuffer/readability/feel or full-route acceptance.
- Hardening diagnostics: unsuccessful focused/recursive attempts remain separate. An earlier CLI attempt had source-load errors during concurrent MCP no-op writes and is not accepted validation; fallback reload **error 43** is not claimed as parsing success. Intermediate gates also observed the unchanged landing test failure present in older captures; new-suite physics-rate settling precedes final baseline-parity runs, without repairing that test or asserting its root cause. Existing native-entry fixture setup now uses a valid separate tether instead of disabling its grapple-bound wall; 99 m/s positive and over-100 m/s negative assertions remain. An evidence-only MCP write was refused while playing and saved after stop. [Detailed limitations](evidence/wall-stick-grapple-reanchor/hardening-results.md#retained-unsuccessful-attempts-and-diagnostics).
- Hardening preservation: previous gate **27/27**; original **437-file** snapshot hash unchanged, all files retained; **480-file** hardening-start hash set retained. Expanded comparison verifies all **195** captured prior evidence/spec files and **28** scene/resource/project files byte-identical, including the previously checked 39/27 subsets. Only ten listed existing localized source files differ from hardening start; original README/triage/spec prefixes remain append-only. HEAD and frozen approval SHA-256 **`14e2d5fa5986b4f9dbebacd48b0e20c444724e582d8d3cc871f48d426a58504f`** unchanged. [Reproducible preservation checks](evidence/wall-stick-grapple-reanchor/verify-hardening-preservation.py).
- Final hardening MCP cleanup/readback: simulated and injected fixture inputs/right mouse released, **60 Hz** restored, task playback stopped, original traversal route **ready**, no new editor entries since cursor **5**, game log only helper registration without dropped lines. Original player resource assignments and stick/grapple tuning inspected through MCP; no user scene saved, discarded or force-reloaded. [Observed closeout](evidence/wall-stick-grapple-reanchor/mcp-hardening-closeout.json). Work remains uncommitted and approved status stays **in-review**.
- Final hardening preservation command exits: [nine preservation checks](evidence/wall-stick-grapple-reanchor/hardening-preservation.json) **all pass**, including the original 27/27 gate and append-only prefix checks; `rtk git diff --check` **0**. Approved worktree helper ran in **diff mode only**, exit **0**, retaining the existing CRLF-conversion notice for the localized motor file. No staging, normalization command or snapshot recapture was performed.

## Suggested Review Order

Parent/human navigation only; no additional independent review was run.

**Transaction boundaries**

- Start here: prepare validates current originals; commit rejects unsafe replacements before baseline arming.
  [`grapple_controller.gd:192`](../../game/player/abilities/grapple/grapple_controller.gd#L192)
- Require the owned body and an actual successful completed physics step.
  [`player_motor.gd:1107`](../../game/player/motor/player_motor.gd#L1107)
- Query fresh original validity without touching legacy sampling caches or installed binding status.
  [`grapple_controller.gd:258`](../../game/player/abilities/grapple/grapple_controller.gd#L258)

**Sampling and lifetime safeguards**

- Incoming response resolves severity against captured tuning, retaining the previous displacement sample.
  [`grapple_controller.gd:444`](../../game/player/abilities/grapple/grapple_controller.gd#L444)
- Surface gap displacement scales; native point velocity excludes duplicate body-pose motion.
  [`grapple_surface_binding.gd:114`](../../game/player/abilities/grapple/grapple_surface_binding.gd#L114)
- Malformed legacy responses fail closed before finite-difference cache mutation.
  [`grappleable_3d.gd:123`](../../game/shared/contracts/grappleable_3d.gd#L123)
- Released carry cannot manufacture a later independent binding from stale contact.
  [`wall_stick_attachment.gd:175`](../../game/player/locomotion/wall_stick/wall_stick_attachment.gd#L175)

**Runtime measurements and regressions**

- Test-only native movers exercise real engine support types without production mover changes.
  [`wall_stick_native_reanchor_fixture.gd:8`](../../tests/fixtures/wall_stick_native_reanchor_fixture.gd#L8)
- Measure visible assigned meshes and exact release clock/curve with negative controls.
  [`wall_stick_reanchor_fixture.gd:142`](../../tests/fixtures/wall_stick_reanchor_fixture.gd#L142)
- Thirteen GUT groups execute the same hundred identified hardening cases observed through MCP.
   [`test_wall_stick_reanchor_hardening.gd:22`](../../tests/player/grapple/test_wall_stick_reanchor_hardening.gd#L22)

## Final Parent Dev Agent Record — 2026-10-02

- Parent live readback exposed an unreliable foreign-motor matching-step fixture control. Its attempted exact-stamp setup skipped strict contact history and failed; the final test-only probe now advances all steps 1..N through real physics callbacks, with no gameplay or assertion weakening. Fixed probes **12/12** in `r187663530-41`. Earlier unsuccessful controls and oversized MCP eval are retained/disclosed in [final parent evidence](evidence/wall-stick-grapple-reanchor/parent-final-results.md).
- Final-source pinned GUT: focused **13/13 groups / 100/100 case-rate pairs**, assertions **100**, exit **0**; recursive player **272/279**, assertions **12374/12388**, exit **1**; full **280/289**, assertions **13035/13052**, exit **1**. All hundred hardening pairs and earlier sixteen feature tests pass; no fresh parse/load/compile error. Full failures equal the original nine; player additionally hits the previously recorded intermittent landing failure. [Comparator](evidence/wall-stick-grapple-reanchor/parent-final-gut-comparison.json) honestly reports **6/7 checks**, player parity failed. No repeated acceptance run erased this failure; comprehensive/route acceptance remains blocked and unrelated repair is not authorized.
- Fresh MCP **`testgame@17187ab35ae57813`**, **`r188028225-43`**: bounded `game_eval` batches observe **100/100** current shared cases plus **6/6** original policy scenarios. Six actual native continuation/release cases preserve the occurrence, clock and visible assigned geometry; maximum anchor/marker/velocity error **0**, rope endpoint **2.8493575428e-6 m**, no missing active visual samples. Fresh adapter **4/4**, schema-only with preload warning. [Complete live record](evidence/wall-stick-grapple-reanchor/mcp-parent-final-validation.json).
- Final MCP source/scene/resource readback confirms original route ready/stopped, player assignments and 100 m/s stick, 5.5 up/8 out jump, 35 m range/60 initial pull/22 cap/250 severe tuning unchanged. All six simulated actions and right mouse released; 60 Hz restored. Fresh game log only helper registration, no errors/dropped lines; editor logger unchanged at cursor 5. Regular read retains five corrected-source errors and eleven warnings, not a clean debugger claim. [Readback and unsuccessful-attempt accounting](evidence/wall-stick-grapple-reanchor/mcp-parent-final-readback.json).
- Preservation readback: nine checks pass including previous 27/27 gate; 437-file snapshot, 480-file hardening-start hashes, 195 prior artifacts and 28 protected scene/resource/project files unchanged; HEAD/frozen hash intact. Whitespace exit 0. No source or reload writes overlapped these GUT gates; generated evidence-only writes are separate. No user scene save/discard/reload, additional independent review/agent, staging, commit or push. Approved status stays **in-review**; default completion/commit automation is not applied over preserved user work with unresolved comprehensive gates.

## Suggested Review Order — final handoff

**Entry and atomic replacement**

- Follow successful physical stick entry into the guarded same-occurrence replacement.
  [`player_controller.gd:1080`](../../scripts/player_controller.gd#L1080)
- Validate originals and owned completed motor steps before any baseline mutation.
  [`grapple_controller.gd:192`](../../game/player/abilities/grapple/grapple_controller.gd#L192)

**Material-point sampling and visuals**

- Track independent contact geometry, gap-correct motion and authoritative native point velocity.
  [`grapple_surface_binding.gd:114`](../../game/player/abilities/grapple/grapple_surface_binding.gd#L114)
- Classify incoming response severity while preserving the previous displacement sample.
  [`grapple_controller.gd:444`](../../game/player/abilities/grapple/grapple_controller.gd#L444)
- Give rope and marker the same active anchor and revision.
  [`player_controller.gd:1388`](../../scripts/player_controller.gd#L1388)

**Final regression evidence**

- Require contiguous real commits for the foreign matching-step motor control.
  [`wall_stick_reanchor_hardening_cases.gd:171`](../../tests/fixtures/wall_stick_reanchor_hardening_cases.gd#L171)
- Separate targeted success from remaining comprehensive failures and visual limits.
  [`parent-final-results.md:1`](evidence/wall-stick-grapple-reanchor/parent-final-results.md#L1)

Final read-only evidence verifier confirms **11/11** targeted cleanup/preservation checks and identical hundred case-rate IDs in three GUT gates and MCP. Its exit remains **1** solely to preserve the failed player-parity comparison; this is not a green regression claim. Snapshot/frozen intent preserved; diff/head-diff helper exits **0** without capture. Completion customization is empty. The report and review trail are ready for human inspection; no commit or push was made.
