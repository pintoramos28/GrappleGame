# Wall-stick grapple re-anchor evidence

Implementation is complete for [the approved spec](../../spec-wall-stick-grapple-reanchor.md),
which remains **in-review for the parent's independent review**. No review,
commit, push, remote operation or baseline-failure repair was performed.
The approved pre-feature snapshot was not replaced; prior feature evidence was
not edited. The full regression gate is **not green**.

## Implementation

- Successful post-commit stick entry copies the proven shape-local **contact**
  into an independent `GrappleSurfaceBinding`, not the player's stand-off point
  and not a reference to the released carry object.
- Typed preparation validates current geometry, fresh wall policy, range and
  scope before the motor arms its zero baseline. The synchronous commit changes
  the target/sample/response and anchor revision on the **same occurrence**.
  Time, scope, authored definition, range/cap and actual entry velocity remain.
  Old geometric pull/boundary caches are cleared, not retroactively attributed
  to the new point. The first zero-baseline hold is distinguished from later
  actual committed carry velocities.
- Anchor, active marker and actual rope geometry consume the same value-only
  sampled state. Reveal/revision resets are intentional; continuous following
  does not reset interpolation. Terminal cleanup synchronously clears cached
  aiming data, marker and rope. The hidden rope detaches its mesh instead of
  generating a zero-height cylinder with non-finite normals.
- Ordinary non-stick static grapples retain frozen acquisition-point behavior;
  ordinary active markers now correctly consume their live attachment sample.

## Canonical CLI/GUT gate

```powershell
rtk proxy "C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe" --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

The focused command uses `-gdir=res://tests/player` with the same other flags.
PowerShell stdout/stderr logs are UTF-16; exit-code files are separate. For
example, read a log with `rtk proxy python -c "from pathlib import Path; print(Path('_bmad-output/implementation-artifacts/evidence/wall-stick-grapple-reanchor/final-gut.stdout.log').read_text(encoding='utf-16'))"`.

| Run | Passing / total | Failing | Exit | Duration |
|---|---:|---:|---:|---:|
| Fresh pre-feature full baseline (`baseline-gut.*`) | 251 / 260 | 9 | 1 | 77.841 s |
| Latest recursive player run (`focused-gut-attempt3.*`) | 260 / 266 | 6 | 1 | 48.397 s |
| Final recursive full run (`final-gut.*`) | 267 / 276 | 9 | 1 | 88.615 s |

All **16 new tests pass** in the final full run: 12 in
`tests/player/grapple/test_wall_stick_reanchor.gd`, four in
`tests/player/grapple/test_grapple_active_visuals.gd`. They cover actual contact
placement, both physics rates and three policies, released tracking, entry
velocity/order, old/new lifetime, geometry/motion terminals, rejected entry
with positive controls, scope/range/stale/motor atomicity, response/cache
isolation, listener cleanup, ordinary-grapple preservation, actual visual
transforms, revision resets and synchronous terminal clearing.

Final failing identities match the fresh baseline exactly; no new failing
identity was found. This is not a claim that the overall suite passes. The
shallow-corner assertion details varied between runs. Unrelated assertions
and authored tuning were not weakened to obtain these results.

| Suite | Existing failing test names |
|---|---|
| `tests/levels/test_traversal_validation_route.gd` | `test_jump_into_real_zip_pull_reaches_the_next_upper_deck`; `test_real_oblique_wall_run_stick_and_jump_reach_the_physical_finish`; `test_one_unbroken_command_route_completes_every_traversal_stage_at_both_rates` |
| `tests/player/grapple/test_grapple_targeting_contract.gd` | `test_definition_validation_locks_authored_values_and_bounds_acquisition_tolerance` |
| `tests/player/grapple/test_grapple_targeting_integration.gd` | `test_same_step_activation_seeds_state_and_keeps_pull_playable`; `test_moving_scene_origin_does_not_change_camera_target_or_acquisition_range`; `test_grapple_pull_decay_reaches_the_floor_and_commits_the_speed_cap` |
| `tests/player/locomotion/test_wall_traversal_integration.gd` | `test_wall_run_direction_never_reverses_across_a_shallow_corner` |
| `tests/player/motor/test_player_motor_integration.gd` | `test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band` |

Final stderr contains negative-path diagnostics, including the new expected
`baseline_active_frame` rejection. Like the baseline it ends with eight leaked
ObjectDB instances and one resource still in use. No final script parse/load
or cylinder/non-finite-normal error was found. Initial unsuccessful focused
logs remain: a missing fixture-seed argument, zero-height rope cleanup and a
first-hold outward-cancellation defect were corrected before attempt 3.

### Intentional expectation migrations

- `tests/player/locomotion/test_wall_stick_attachment.gd`: the replaced anchor
  follows the supporting wall; former moving-target motion no longer drives it.
- `tests/player/locomotion/test_wall_traversal_integration.gd`: destruction of
  the re-anchored physical target is `TARGET_DESTROYED`; invalidation fixtures
  operate on the current target rather than the historical acquisition body.
- `tests/fixtures/wall_stick_review_cases.gd`: terminal cleanup removes two
  independent weak listeners; manual commit fixtures record actual committed
  facts before a guarded post-commit entry attempt.
- `tests/player/grapple/test_grapple_targeting_integration.gd`: the obsolete
  hidden-only source assertion permits revision resets; the ordinary-grapple
  reveal-count and single reset-call-site assertions remain.

## Complementary Godot AI MCP gate

Session: **`testgame@17187ab35ae57813`**, Godot **4.7.2-stable**.
Preflight and implementation used session/state/logs, scene hierarchy/player
properties, script inspection, filesystem scans and script reload validation.
Final recheck used `filesystem_manage(scan)`, `test_run(wall_stick)`, fresh
`project_run(custom, autosave=false)`, runtime tree/input inspection, `game_eval`,
input simulation, detailed logs, stop and final editor/resource inspection.
See [the final MCP record](mcp-final-validation.json).

- **Native adapter: 4/4**, explicitly schema/source checks only. The runner's
  preload-cache warning is retained. This neither discovers recursive GUT nor
  establishes dependency/gameplay validation.
- **Live cases: 6/6**, ordinary/explicit STATIC/explicit MOVING at **60/120 Hz**.
  [Reproducible live code](live-cases.gd.txt) uses isolated real-Jolt viewports
  with the production player/controller/motor and the fixture's explicit input
  seam. [First detailed measurements](mcp-live-cases.json) were repeated in the
  fresh final game run **`r166780006-32`**. Translation, yaw and shape-owner-local
  motion run while stuck, then after forward release and old-target destruction.
  New-target destruction/ineligibility/scope change each terminate once with
  their typed reason and synchronous endpoint clearing.
- Every final case observed maximum anchor/actual marker/point-velocity error
  **0**, rope endpoint error **4.8054801027e-7 m**, one motor commit and zero
  sampled overlaps. The physical contact velocity at 60 Hz was approximately
  **(1.33931, 0.15000, -0.22452) m/s**, distinct from the player's stand-off
  velocity **(1.42942, 0.15000, -0.22798) m/s**. The released occurrence stayed at
  revision 1, one entry and zero terminals until the new target was invalidated.
- A separate standalone smoke used MCP right-mouse **events** through the
  production grapple input boundary plus movement-action simulation. Action
  simulation alone did not latch grapple; launch-focus neutral rearm was
  necessary. It followed after release/old-target destruction with revision 1,
  one entry, unchanged continuous-follow reset counts, and maximum rope error
  about **4.91e-6 m** at the last long-run observation.
- [Actual viewport proof](mcp-contact-visual-proof.png) shows the green active
  marker and cyan rope at the contact. Only the fixture's opaque capsule
  presentation mesh was hidden because normal views occluded the endpoints.
  No collision or endpoint geometry was altered. This is diagnostic visual
  evidence, **not shipping readability or movement-feel acceptance**.

### Diagnostics and cleanup limitations

Some no-op MCP `script_patch` reload validations returned fallback error **43**;
the player controller reload succeeded. Fresh CLI parsing and fresh MCP game
processes, rather than the native adapter's cached preloads, validate behavior.
The editor retains **two pre-feature historical errors plus three corrected
weak-reference-source error rows and ten warning rows** (cursor 5). Logs were
not cleared. The final fresh launch reported no launch errors; its game log
contains only helper registration, with no dropped lines or new editor entries
since cursor 5.

Two transient eval mistakes were tooling-only: earlier mixed indentation, and
the optional final standalone cleanup eval's nonexistent `GrappleTerminal`
type. The latter parked the old smoke in a parser break before any mutations;
it was stopped and relaunched. A fresh standalone attempt had not re-entered
stick after focus neutralization, so its ordinary terminal cleanup is **not**
counted as re-anchor verification. The subsequent controlled six-case recheck
in the fresh process passed. Full details are in `mcp-final-validation.json`.

Final state: right mouse and all simulated movement/grapple/jump actions
released, physics restored to **60 Hz**, game stopped, editor **ready** on the
original traversal route. Player script and both scene-referenced authored
definitions were inspected through MCP (100 m/s stick entry, 5.5 up/8 out jump,
35 m grapple range, 60 m/s² initial pull, 22 m/s grapple cap). No user scene was
saved, force-reloaded or discarded. Synchronous terminal hiding does not
prohibit a later valid ordinary aiming preview.

## Preservation and handoff

Read-only gates passed; see [preservation results](preservation-final.json):

- Existing `evidence/wall-stick-attachment/verify-preservation.py`: **27/27**
  checks, including byte-equivalent wall-running policy/functions, legacy wall
  selection, recorded scene/tuning values and the earlier frozen approval.
- The 437-file approved snapshot remains at
  `C:/Users/pinto/AppData/Local/Temp/opencode/wall-stick-reanchor-baseline.json`.
  HEAD remains `89ead0989f319a80007cb9835fea056c5ca8bf04`; none of its files were
  deleted. All **39** prior evidence/spec files and **27** protected
  scene/resource/project files equal their captured bytes.
- Frozen approval SHA-256 remains
  **`14e2d5fa5986b4f9dbebacd48b0e20c444724e582d8d3cc871f48d426a58504f`**.
- `rtk git diff --check`: exit **0**. The approved worktree helper was run in
  **`diff` mode only**, producing incremental full/code and HEAD-tracked diffs
  in the approved temporary directory. Its only warning was Git's existing
  CRLF-to-LF notice for `game/player/motor/player_motor.gd`; that file is unchanged
  relative to the approved pre-feature snapshot.

The parent owns independent review and any later commit. Existing baseline
failures, editor reload limitations and normal-view readability/feel remain
explicitly visible rather than being treated as acceptance passes.

## Parent verification before review triage

- Independently reran the pinned full recursive GUT gate: **267/276 passing**, assertions **12871/12888**, exit **1**, 88.583 s. Read-only [identity comparison](compare-gut-results.py) against the fresh 251/260 baseline passed all four checks; the same nine failures remain. Logs: `parent-gut.stdout.log`, `parent-gut.stderr.log`, `parent-gut.exitcode.txt`.
- Fresh MCP run **`r167646100-33`**, same editor session and `autosave=false`, repeated **6/6** controlled live cases. Ordinary/STATIC/MOVING walls at 60/120 Hz each retained the same occurrence and revision after forward release and former-target destruction, then terminated exactly once for the new target. Measured maximum anchor/actual marker/point-velocity error **0**, actual rope endpoint error **4.8054801027e-7 m**. [Observed record](parent-mcp-recheck.json) identifies the exact operations and shared-fixture limitation.
- Game log: only helper registration, no dropped lines. No editor entries since cursor **5**. Six simulated actions released, 60 Hz restored, task runtime stopped; MCP readback observed original route ready/stopped and player run values **100/3/10/4/0**, with assigned stick/grapple definitions.
- Independently reran preservation **27/27**, whitespace check and snapshot readback: **437** captured files still exist, **39** prior feature evidence/spec files and **27** protected scene/resource/project files unchanged; frozen SHA unchanged. A read-only Python one-liner initially failed on PowerShell quoting; the dedicated comparator subsequently passed. This tooling error is not a test failure or validation pass.
- Three fresh read-only review agents were launched with blind, edge-case and acceptance roles. The obsolete named BMAD review skills are represented by their installed consolidated adversarial/edge-case lens instructions. The full HEAD tracked/untracked diff was constructed without staging; primary incremental source diff prevents attributing earlier dirty work to this feature. Review results and dispositions follow separately.
- Supplemental actual-framebuffer [before](parent-visual-before.png) / [after](parent-visual-after.png) captures in MCP run **`r168128726-34`** visibly show the green marker and cyan rope shifting together with wall translation. World anchor moved **1.983332 m** on X over the bounded physics-frame sequence, one occurrence/revision/entry, zero terminals or extra interpolation resets. [Observation and limitations](parent-visual-tracking.json) distinguish sampled transform agreement from render interpolation and disclose the hidden opaque capsule and inert background telemetry canvas. This is diagnostic visual proof, not normal-view readability/feel acceptance. Cleanup again observed 60 Hz, released actions, ready/stopped editor and no new log entries.

## Post-review localized hardening — 2026-10-02

**R1–R12 are patched and verified**; approved status stays **in-review**, with
no further independent review or commit. [Hardening results and dispositions](hardening-results.md)
append to, rather than replace, the original captures above.

- Final recursive player GUT: **273/279**, same six baseline failures, exit 1.
- Final recursive full GUT: **280/289**, same nine baseline identities, exit 1.
  All 13 hardening groups / **100 scenario-rate pairs** pass in both gates.
- Fresh MCP: **100/100** hardening, **6/6** stronger original live cases,
  **10/10** native entry probes; a separate fresh process repeats **6/6** native
  continuation/release cases. [16-check comparison](hardening-test-comparison.json)
  distinguishes GUT, MCP live results and the schema-only adapter.
- Preservation: previous gate **27/27**, both immutable snapshots retained,
  all prior captures/protected bytes and frozen intent unchanged; original
  README/triage/spec prefixes remain append-only. [Final preservation](hardening-preservation.json).

## Latest parent handoff — 2026-10-02

[Superseding final results](parent-final-results.md): the foreign-motor fixture
now advances its strict contact sequence with real physics commits. Focused GUT
**13/13**, fresh MCP **100/100** hardening cases and **6/6** original live cases.
Full GUT **280/289** matches nine baseline failures; player GUT **272/279** also
hits the previously recorded intermittent landing failure. Both remain red;
the latter comparison is disclosed as failed, not retried into baseline parity.
All older captures above remain historical and intact. Status stays in-review;
no commit, push or unrelated gameplay/tuning/route repair occurred.
- Final MCP cleanup: ready/stopped on the original route, 60 Hz, released
  actions/right mouse, no new editor entries. [Observed closeout](mcp-hardening-closeout.json).

Intermediate source-load/test-setup failures and the intermittent landing failure
are retained and disclosed in the hardening report. The comprehensive gate is
**not green**; no route-completion or new normal-view readability/feel claim is made.
