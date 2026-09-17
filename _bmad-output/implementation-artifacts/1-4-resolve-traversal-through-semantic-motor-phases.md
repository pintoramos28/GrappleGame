---
baseline_commit: 7f0e5cd3a53b5dc202a2cd2a84d0966aaa1d08cc
---

# Story 1.4: Resolve Traversal Through Semantic Motor Phases

Status: review

<!-- Story 1.4 evolves Story 1.3's single-request PlayerMotor seam into the fixed semantic phase pipeline. It preserves the current traversal baseline and explicitly defers ContactFrame, grapple-target, and true maximum-distance work. -->

## Story

As a player,
I want grappling, jumping, wall movement, gravity, and ordinary locomotion resolved in a stable order,
so that combined traversal actions behave predictably without competing systems overwriting my movement.

## Acceptance Criteria

1. **Resolve one motor frame through the exact semantic phase order**
   - **Given** Story 1.3's initialized `PlayerMotor` begins a valid physics step
   - **When** submitted movement is resolved
   - **Then** the motor processes exactly: terminal commands; state gating and interrupts; base locomotion and gravity; sustained influences; one-shot impulses; constraints and redirections; caps and final movement commit
   - **And** the player still receives exactly one final `CharacterBody3D.velocity` assignment and one `move_and_slide()` call for that step.

2. **Submit movement only through typed semantic methods**
   - **Given** a locomotion state or current traversal ability affects movement
   - **When** it contributes to the active motor frame
   - **Then** it uses a typed method for the correct semantic phase and a stable source identity wherever identity is required
   - **And** it cannot select arbitrary numeric priority, depend on scene-tree or signal order, or mutate final body velocity directly.

3. **Preserve current ground and air behavior without retuning**
   - **Given** grounded or airborne locomotion is active
   - **When** input acceleration, input-free deceleration, gravity, and current target-speed limits resolve through the base/cap semantics
   - **Then** observable velocity, collision behavior, and per-scene authored tuning remain equivalent to the approved baseline within the documented physics tolerances
   - **And** this story does not normalize the distinct values intentionally authored by each retained scene.

4. **Classify only the current grapple pull and cap**
   - **Given** the current pre-redesign grapple is active
   - **When** its movement is submitted
   - **Then** its existing pull acceleration is a sustained influence and its existing total-velocity cap is applied in the cap phase
   - **And** this story does not add the true maximum-distance active-connection boundary assigned to Story 1.7.

5. **Resolve existing wall behavior through appropriate phases**
   - **Given** wall-run or wall-stick behavior is active
   - **When** the motor resolves the step
   - **Then** wall-run target acceleration, wall-relative redirection, outward-velocity removal, and wall-stick holding use typed base/constraint policies with a documented internal order
   - **And** current ray/collision detection and concrete target checks remain unchanged until Story 1.5 introduces shared contact classification.

6. **Apply each ground or wall jump exactly once**
   - **Given** a ground-jump or wall-jump edge is accepted for the active physics step
   - **When** the motor resolves one-shot impulses
   - **Then** the impulse occurs after sustained influences and before constraints/caps
   - **And** a stable `(physics_step, source_id, occurrence_id)` identity prevents the same jump occurrence from being applied more than once.

7. **Aggregate compatible same-phase contributions deterministically**
   - **Given** more than one compatible contribution exists in a semantic phase
   - **When** that phase resolves
   - **Then** the motor applies the documented phase-specific rule after sorting any order-sensitive fold by stable source identity and, for one-shots, occurrence identity
   - **And** changing insertion order, node order, or signal connection order cannot change the committed velocity.

8. **Reject mutually exclusive policies before body mutation**
   - **Given** one step contains incompatible terminal, state/base, hold, or constraint policies
   - **When** the motor validates the frame
   - **Then** the coordinator must select one policy before submission, and any unresolved ambiguity that reaches the motor rejects the whole frame with a stable typed reason before final commit
   - **And** the motor never chooses the last writer, applies a partial policy to the body, or leaves an earlier partial result commit-capable.

9. **Isolate invalid contributions while preserving a safe valid frame**
   - **Given** a duplicate one-shot, stale step, non-finite value, invalid source, or invalid phase submission is attempted
   - **When** the typed boundary validates it
   - **Then** that contribution is rejected with a stable reason and one development-visible diagnostic while already accepted valid current-step contributions remain intact
   - **And** the step either resolves once from a complete valid policy set or fails closed without a commit; it can never perform a second commit.

10. **Clear only per-step motor data**
    - **Given** a later valid physics step opens
    - **When** `PlayerMotor` advances its frame lifecycle
    - **Then** prior submissions, occurrence guards, rejections, intermediate values, and temporary resolution data are cleared or advanced deterministically
    - **And** long-lived grapple, wall, locomotion, and state-machine ownership remains with the originating component rather than mutable shared motor data.

11. **Use physics delta in seconds at 60 Hz and 120 Hz**
    - **Given** acceleration, deceleration, gravity, grapple pull, or another rate-based influence is evaluated
    - **When** shipping 60 Hz and diagnostic 120 Hz sequences cover the same real-time duration
    - **Then** each rate integrates from physics delta in seconds and produces equivalent behavior within the recorded tolerances
    - **And** no resolver path multiplies rates by rendered-frame time or raw tick count.

12. **Expose bounded observational phase diagnostics**
    - **Given** development diagnostics are enabled
    - **When** the current motor snapshot is inspected
    - **Then** it identifies bounded submitted sources by phase, rejected contributions, phase intermediates, applied constraints/caps, and the final commit
    - **And** the snapshot is copied/read-only, retains no live scene/collision references, and reuses the actual resolution facts without calculating movement again.

13. **Protect the semantic contract with focused tests**
    - **Given** the focused player-motor contract and real-Jolt integration suites run
    - **When** they permute otherwise identical insertion/node orders and exercise all validation branches
    - **Then** they prove identical committed results within tolerance, the exact phase order, one-shot deduplication, stale-step rejection, conflict handling, per-step clearing, one final commit, and 60/120 Hz equivalence
    - **And** the recursive GUT result is reported separately from Godot AI MCP test discovery and live runtime evidence.

14. **Keep the traversal slice playable and the migration scoped**
    - **Given** implementation and validation are complete
    - **When** the retained traversal smoke and complete working-tree diff are reviewed
    - **Then** ground, air, jump, current grapple, wall-run, wall-stick, wall-jump, death, landing, release, and transition behavior remain playable through the semantic pipeline
    - **And** the diff has not introduced shared `ContactFrame` queries, a typed grapple-target contract, a true maximum grapple boundary, moving-target attachment, combat-pressure effects, traversal retuning, tutorial migration, dependency changes, or unrelated hierarchy/domain migration.

## Tasks / Subtasks

- [x] 1. Freeze the current traversal oracle and repeat the mandatory Godot AI MCP preflight before runtime edits (AC: 1-6, 10-14)
  - [x] Confirm the implementation-start commit and full working-tree status; preserve the bounded Story 1.4 context pack and all unrelated/user-owned changes. Record the pinned Godot build, physics backend/tick rate, interpolation setting, main scene, player-scene UID, current plugin versions, and every active-player body writer/`move_and_slide()` call.
  - [x] Through Godot AI MCP, list sessions, activate the exact `testgame` session, and inspect editor readiness, current scene, play state, editor diagnostics, `main.tscn`, `scenes/player.tscn`, `/Player/PlayerMotor`, both HSMs, controller/state scripts, and current motor symbols. If an active ready session cannot be established, stop before source edits and report the blocker; do not silently replace this preflight with CLI or generic UI automation.
  - [x] Characterize representative pre-change velocity/position/state results for ground acceleration and deceleration, air steering/gravity, ground jump, current grapple pull/release/cap, wall run/stick/jump, dead movement, landing, and transition frames. Include the relevant phase input and output, not only a subjective smoke note.
  - [x] Characterize all three resolved tuning contexts explicitly: (1) direct `player.tscn`/unconfigured controller uses `ground_deceleration = 20.0` and `grapple_gravity_scale = 1.0`; (2) the canonical `main.tscn` player overrides them to `30.0` and `0.0`; (3) `scripts/levels/tree_grapple_tutorial.gd` instantiates the reusable player and assigns `grapple_length = 35.0` and `grapple_gravity_scale = 0.65` after adding it. Preserve the tutorial's existing out-of-band reset teleport. Fixtures must not present the `20.0` fallback as production-equivalent or normalize any context.
  - [x] Reuse the predecessor tolerances unless evidence requires a tighter one: no more than `0.05 m/s` representative velocity drift, `0.10 m` position drift over a 60-step/one-second comparison, and at most one 60 Hz physics-step of transition alignment. Record any evidence-backed exception before changing implementation to satisfy it.
  - [x] Capture a source-level ownership oracle that classifies permitted local `Vector3` calculations separately from the sole final `CharacterBody3D.velocity` assignment, motor-owned wall-stick position correction, and sole `move_and_slide()` call. Do not turn this into a repository-wide ban on enemy, presentation, or out-of-band reset movement.

- [x] 2. Replace the complete provisional request with the smallest typed semantic phase contract (AC: 1, 2, 6-10, 12)
  - [x] Add `game/player/motor/motor_phase.gd` using named phases in the exact acceptance order. Do not expose numeric priority as gameplay policy. Phase values may be used for typed validation/diagnostics only; iteration must use one explicit canonical sequence.
  - [x] Evolve `PlayerMotionRequest` into phase-specific immutable submissions or replace it with the smallest set of typed records/methods justified by current behavior. Retire the Story 1.3 complete-velocity submission as a gameplay bypass after all callers/tests migrate; do not leave a second legacy path capable of committing a final velocity.
  - [x] Keep the existing outer lifecycle recognizable: initialization, one active step, begin, typed submissions, validate/resolve, one commit or fail-closed abort, and a typed result. Begin the frame with the monotonically increasing coordinator step and physics delta in seconds; snapshot committed body state once.
  - [x] Use narrow domain methods rather than a generic public `submit(phase, payload)`. Current needs include one active locomotion/state policy, base target/rate and gravity data, sustained acceleration, one-shot impulse, wall constraint/redirection or hold, and typed cap declarations. A public method must bind its contribution kind to its legal phase so a caller cannot select an arbitrary phase.
  - [x] Define stable dotted lowercase `StringName` source IDs in the owning controller/domain, not node paths, instance IDs, resource load order, array indices, or signal order. Use stable IDs equivalent to `player.locomotion.grounded.base`, `player.gravity.default`, `player.grapple.pull`, `player.grapple.speed_cap`, `player.jump.ground`, `player.wall_run.constraint`, `player.wall_stick.hold`, and `player.jump.wall`.
  - [x] Define `occurrence_id` as a stable `StringName` owned by the component translating a committed command edge or state event into an impulse. For the current jump edge, use a semantic constant equivalent to `&"player.command.jump_pressed"` derived from the immutable `PlayerCommandFrame`; do not use an incrementing motor counter, object identity, or node path. Key deduplication by `(active_physics_step, source_id, occurrence_id)`. The original accepted jump remains; the same source/edge submitted twice is rejected without removing it, while a genuinely distinct stable source/occurrence key remains independently valid if its surrounding policy is compatible. Guards clear on the next accepted frame, and held-input suppression remains the command-frame owner's responsibility.
  - [x] Define typed rejection reasons at least for no active frame, stale/wrong step, illegal phase/kind, empty/unstable source ID, non-finite value, duplicate source where uniqueness is required, duplicate occurrence, missing required policy, exclusive-policy conflict, already resolved, and duplicate commit. Assertions may aid debug but cannot be the release-build safety mechanism.
  - [x] Bound current-step storage with named constants and deterministic overflow handling. Before choosing the limits, enumerate the maximum contributions/rejections produced by every current locomotion path, add small documented diagnostic headroom, and record the resulting intentional Story 1.4 budget in the phase contract/evidence. Retain exactly seven phase-intermediate records and preserve the existing collision scan/report bounds of 32/8. Overflow is a typed rejection/count/flag, not silent unbounded growth.

- [x] 3. Implement deterministic phase resolution and an atomic single commit (AC: 1, 3-11)
  - [x] Validate all structural policy requirements and conflicts before mutating the body. Build phase results in local motor-owned values; a fatal conflict, missing required base/hold policy, invalid body, or invalid lifecycle state aborts the frame before position/velocity assignment and `move_and_slide()`.
  - [x] Process phase 1, terminal commands, as an exclusive typed policy/gate outcome. Current death/deactivation behavior may select the dead locomotion policy, but this story must not create attack/effect terminal infrastructure. No terminal contribution is a valid pass-through for states without one; two distinct terminal authorities are a fatal conflict.
  - [x] Process phase 2, state gating and interrupts, from one stable locomotion/state authority selected by the existing movement coordinator. State transitions and interrupts decide which policy submits for the step before base motion; two distinct active state/base authorities are a fatal conflict rather than last-writer selection.
  - [x] Process phase 3, base locomotion and gravity, in a fixed documented sub-order: the single state-owned base target/deceleration policy first, then compatible gravity acceleration. Ground, air, dead, and wall base calculations keep their present `move_toward`/gravity formulas and integrate rates with `delta_seconds`. A configured locomotion maximum bounds the generated target; it must not become a new unconditional clamp that destroys inherited external momentum.
  - [x] Process phase 4, sustained influences, as rate-based velocity changes. Sort accepted sources by their stable source ID before any floating-point fold, apply each `acceleration_mps2 * delta_seconds` exactly once, and preserve the current grapple initial/minimum acceleration and jerk-decay formula in its existing owner. Do not copy elapsed grapple state into the motor.
  - [x] Process phase 5, one-shot impulses, as velocity deltas sorted by `(source_id, occurrence_id)` after deduplication. Ground and wall jump apply here exactly once; they do not smuggle rate-based gravity, steering, or a complete final velocity into the impulse payload.
  - [x] Process phase 6, constraints and redirections, only through typed policies. Preserve a fixed wall-run sequence of wall-relative redirection followed by outward-component removal. Keep motor-owned wall-stick hold as an explicit exclusive hold/constraint policy with the existing next-frame zero-baseline behavior; hold cannot coexist with an ordinary movement/base policy. Do not silently reinterpret hold as ordinary zero velocity or add a second teleport/commit.
  - [x] Process phase 7, caps and commit, using typed cap scope rather than one generic clamp. Preserve the current grapple cap as a `total_speed` maximum applied after the earlier phases. Preserve ground/air maximum speed as the bound for their generated base target, not a new clamp on previously inherited momentum. Compatible `total_speed` maxima resolve deterministically to the most restrictive positive limit; unsupported future scopes reject with a typed unsupported-scope status rather than being silently ignored or resolved by insertion order.
  - [x] Assign the resolved pre-slide velocity to the body exactly once and call `move_and_slide()` exactly once. Keep pre-slide resolved velocity distinct from Godot's post-slide committed velocity because `move_and_slide()` may modify `CharacterBody3D.velocity`; then capture the existing bounded collision/position/floor/wall result without another physics query or move.
  - [x] Distinguish isolated contribution rejection from fatal frame rejection. Stale, malformed, duplicate one-shot, or overflow contributions are not stored and do not erase accepted current-step contributions. A complete valid policy set may still commit once. A mutually exclusive structural conflict or incomplete required policy aborts the whole frame with no body mutation.
  - [x] On the next accepted `begin_motion_frame`, clear accepted submissions, occurrence keys, rejected records, intermediates, caps/constraint traces, result flags, and temporary folds only. Preserve long-lived state in controller/HSM owners and preserve the next-frame wall-stick baseline contract intentionally.

- [x] 4. Route the controller and all six movement states through semantic submissions (AC: 2-6, 8-11, 14)
  - [x] Preserve the Story 1.3 coordinator transaction: capture exactly one immutable `PlayerCommandFrame`; open one motor frame; update the manually driven movement HSM once; resolve/commit once; process bounded post-commit transitions/collisions; then update the manually driven attack HSM once with the same command frame. Both LimboAI HSMs remain self-processing-disabled; attack receives no motor handle or movement authority.
  - [x] Replace `submit_motion_velocity`, `submit_wall_stick_hold`, and the complete `PlayerMotionRequest` flow in `scripts/player_controller.gd` with narrow semantic submission methods. Keep calculation helpers owner-local where they hold state, but pass rates/targets/impulses/constraints rather than a pre-resolved final body velocity.
  - [x] `player_grounded_state.gd`: select the grounded base policy, submit input target and ground acceleration/deceleration, submit the ground-jump edge as one stable occurrence when present, and preserve left-floor/grapple/death/pass-through transitions.
  - [x] `player_airborne_state.gd`: select the airborne base policy, submit gravity and air steering, and preserve landing/grapple/wall-run transition decisions without introducing `ContactFrame` or direct movement.
  - [x] `player_grappling_state.gd`: select the applicable ground/air base policy, submit current gravity/steering, submit current grapple pull as sustained acceleration, submit the current `22 m/s` total-speed cap, and preserve release/invalid-target/landing behavior. Do not add active maximum-distance enforcement, moving-target tracking, or typed grapple-target redesign.
  - [x] `player_wall_run_state.gd`: select the wall-run base policy, submit its current target acceleration/gravity behavior, then the typed wall-relative redirect/outward-removal constraint; submit wall jump as one stable impulse. Preserve the current rays, thresholds, normals, collision source, transitions, and authored scalars.
  - [x] `player_wall_stick_state.gd`: submit the exclusive motor-owned hold policy while sticking; on release or grapple transition, preserve the zero next-frame baseline/pass-through behavior; on jump, submit the stable wall-jump impulse through a non-hold policy. Prove no stale grapple velocity, positional drift, or second commit is introduced.
  - [x] `player_dead_state.gd`: preserve dead gating and the current ground-deceleration/gravity behavior through the dead base policy. Do not broaden this into fall/reset/death-system redesign.
  - [x] Audit every early return and transition path so an initialized active frame produces either one complete valid policy set and one commit or one explicit fail-closed abort. Preserve the Story 1.3 grapple-landing stale-velocity fix and all existing transition event IDs.

- [x] 5. Extend results, diagnostics, and logging without changing retained scene/resource ownership (AC: 7-10, 12, 14)
  - [x] Extend `PlayerMotorCommitResult` only with bounded current-step facts required by coordination/evidence. Preserve existing step, success/rejection, resolved/pre-slide velocity, committed/post-slide velocity, position delta, floor/wall, hold, commit count, and bounded collision facts used by post-commit transitions.
  - [x] Extend `PlayerMotorDiagnosticSnapshot` with copied immutable records for each of the seven phases, accepted source IDs/kinds, rejected source/reason records, intermediate velocities, applied constraint/cap identities, final resolved/committed velocities, overflow counters/flags, and commit count. Never retain `Node`, `PhysicsBody3D`, `KinematicCollision3D`, or mutable owner state.
  - [x] Reuse already-computed resolver facts; enabling or reading diagnostics cannot rerun a phase, query physics, change ordering, allocate unbounded history, or commit movement. Keep diagnostics opt-in and development-only in cost, while release correctness never depends on them.
  - [x] Route invariant/rejection visibility through the existing typed `GameLog` facade with stable dotted codes and scalar/ID context. Preserve its 32-key bounded dedupe/FIFO behavior. Do not expand this story into cleanup of unrelated pre-existing `print`/`push_error`, a readable gameplay log, autoload, overlay, file sink, telemetry, or live-tuning system.
  - [x] Preserve `scenes/player.tscn`, `main.tscn`, tutorial instantiation, node names/paths, UIDs, `PlayerInputSource`, `PlayerMotor`, both HSMs, collision setup, Resources, and authored overrides. Change a scene only if a new dependency is proven necessary; do not relocate the legacy controller/states into the target directory in this story.
  - [x] Keep `project.godot`, Forward+, Jolt, 60 Hz shipping tick, interpolation `false`, input map, launch scene, LimboAI, GUT, Terrain3D, Phantom Camera, and Godot AI dependency files unchanged.

- [x] 6. Add focused GUT contracts and real-Jolt regression coverage (AC: 1-14)
  - [x] Adapt `tests/player/motor/test_player_motor.gd` to the new phase contract while retaining Story 1.3 lifecycle, initialization, abort, body-detachment, duplicate-begin/commit, collision bounds, wall-stick baseline, logging, and diagnostic-copy coverage.
  - [x] Add table-driven phase tests proving the exact seven-phase sequence, legal contribution-to-phase mapping, stable source validation, phase-specific deterministic aggregation, and identical resolved results across reversed/randomized insertion orders. Explicitly permute inputs rather than relying on one dictionary iteration.
  - [x] Prove the same `(step, source_id, &"player.command.jump_pressed")` edge submitted twice applies once and rejects the duplicate. Also prove a distinct stable source/occurrence key is independently accepted when policy-compatible, while incompatible ground/wall authorities still trigger the structural conflict rule. A stale/wrong-step, non-finite, invalid-source/phase, or overflow contribution is rejected without erasing valid accepted submissions; a fatal exclusive-policy conflict produces no velocity/position write and no `move_and_slide()`.
  - [x] Prove opening step N+1 clears step N submissions, occurrence guards, rejection/intermediate data, and temporary cap/constraint facts, while owner-held grapple elapsed time and HSM state remain outside the motor.
  - [x] Adapt `tests/player/motor/test_player_motor_integration.gd` and its real-Jolt fixtures for ground, air, jump, grapple pull/release/cap, wall run/jump, wall stick hold/release, dead movement, landing, early transitions, and the prior grapple-landing regression. Assert one successful commit per valid active step and no commit on a fatal frame. Add scene/static preservation coverage for all three tuning contexts, including the tutorial's late `35.0` grapple length, `0.65` gravity scale, and its still out-of-band reset teleport; a fixture claiming production behavior must load `main.tscn` or explicitly use its effective `30.0` deceleration.
  - [x] Compare equivalent one-second 60 Hz and 120 Hz rate sequences using `delta = 1.0 / tick_rate`, restoring any temporary engine tick configuration. Use tolerant velocity/position/transition assertions, not exact floating-point equality or raw tick-count equivalence. For a cardinal `10 m/s` release, explicitly characterize the main-scene `30 m/s²` reduction (`0.5 m/s` at 60 Hz, `0.25 m/s` at 120 Hz) and the direct-player compatibility `20 m/s²` reduction (approximately `0.3333 m/s` and `0.1667 m/s`). Record the measured result against the `0.05 m/s`, `0.10 m`, and one-60-Hz-step baseline tolerances.
  - [x] Update the narrow source audit so only `game/player/motor/player_motor.gd` owns the final body assignment, hold correction, and `move_and_slide()`. Assert states/controllers cannot use the retired complete-request bypass, numeric priority, direct `Input` polling, or a second HSM-driven commit; avoid brittle assertions against incidental local variable spelling.
  - [x] Re-run the unchanged input/command-frame suite plus focused motor and recursive player suites with the pinned console, serially from repository root:

    ```powershell
    $env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/motor -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
    ```

  - [x] Report scripts/tests/assertions, exit codes, expected invariant diagnostics, unexpected errors, and known teardown noise separately. GUT is the canonical recursive suite; a Godot AI MCP `test_run` result cannot substitute for it.

- [x] 7. Validate through Godot AI MCP and preserve honest completion evidence (AC: 3-5, 11-14)
  - [x] After edits, use the same active Godot AI MCP project session to scan/reload changed GDScript/resources, inspect script/editor diagnostics, reopen the retained player/main scenes, and verify readiness before running. If the required session becomes unavailable, stop validation and report the blocker instead of claiming a CLI-only completion.
  - [x] Run Godot AI MCP test discovery and record its result separately. The current repository has no direct top-level `res://tests/test_*.gd` `McpTestSuite`, so `total=0` is expected unless this story deliberately adds a small top-level adapter. Add an adapter only if it reuses focused framework-neutral phase fixtures and provides material MCP-native value; never present it as recursive GUT parity.
  - [x] Launch `res://main.tscn` through Godot AI MCP and use live scene-tree/node inspection plus `game_eval`/input/capture capabilities to exercise ground, air, jump, current grapple acquire/hold/release and cap, wall run, wall stick, wall jump, landing, death, and reachable transitions. Inspect motor diagnostics/commit counts during the run and prove no second commit. Clearly distinguish automated MCP observations from any still-required human feel/visual judgment.
  - [x] Read editor, game, and plugin logs after the live run; classify expected test/invariant messages, known host/audio or teardown noise, and any new parse/runtime diagnostic. Stop the run and leave the editor ready/stopped on a retained project scene.
  - [x] Run the pinned import/load checks serially and report them separately from MCP and GUT:

    ```powershell
    $env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --import --quit-after 120
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --quit-after 120
    ```

  - [x] Record evidence under `_bmad-output/implementation-artifacts/evidence/1-4/`: pre-change oracle, phase/conflict contract, writer audit, focused/recursive GUT, 60/120 comparison, pinned import/load, Godot AI MCP verification, traversal smoke, complete status/diff, and retained limitations. Do not copy live nodes, absolute personal paths, secrets, or unbounded raw logs into evidence.
  - [x] Run `rtk git diff --check`, inspect complete scoped/unscoped status, and verify no tuning, UID, scene topology, dependency, project setting, ContactFrame/grapple-target contract, tutorial content, attack behavior, or unrelated migration slipped into the diff. Preserve and report relevant prior limitations (`BASE-002`, `BASE-004` through `BASE-007`) unless new evidence explicitly supersedes them.
  - [x] Update this Dev Agent Record with the actual implementation files, tests/results, Godot AI MCP session ID and operations, diagnostics, evidence paths, and any honest limitations. Move the story to `review` only when every checked task has corresponding evidence; do not mark `done` without the project's review/manual-smoke policy.

## Dev Notes

### Developer Context

Story 1.3 established one authoritative physics transaction:

```text
capture one immutable PlayerCommandFrame for step N
  -> PlayerMotor.begin_motion_frame(N)
  -> movement HSM evaluates once and submits one complete MOVE or HOLD request
  -> PlayerMotor.resolve_and_commit() once
  -> bounded post-commit transition/collision handling
  -> attack HSM evaluates once with the same command frame
```

Story 1.4 changes the middle of that transaction, not its outer ownership. The complete provisional request becomes typed semantic contributions. `PlayerMotor` remains a child/wrapper around the retained root `CharacterBody3D` and the only owner of final active-player body mutation/commit.

Required target choreography:

```text
capture command frame + open motor frame(step N, physics delta seconds)
  -> coordinator selects terminal/state policy and current locomotion owner
  -> owners submit typed phase contributions with stable IDs
  -> motor validates the complete policy set without touching the body
  -> terminal
  -> state gate / interrupts
  -> base locomotion, then gravity
  -> sustained influences (stable source order)
  -> one-shot impulses (stable source + occurrence order, deduplicated)
  -> typed constraints/redirections
  -> typed caps
  -> one final body velocity assignment + one move_and_slide()
  -> bounded committed result / post-commit coordination
  -> attack HSM with no motor authority
```

Intermediate local `Vector3` values are expected and safe. The invariant concerns the authoritative player body's final `velocity` property and movement call, not ordinary calculations.

### Binding Phase and Conflict Decisions

| Phase | Current Story 1.4 responsibility | Deterministic rule |
|---|---|---|
| Terminal commands | Current death/deactivation gate only; no new attack/effect policy system | Coordinator submits zero or one selected authority; multiple authorities reaching the motor are a fatal frame conflict |
| State gating and interrupts | Existing movement HSM selects one stable locomotion policy before motion math | Coordinator selects exactly one active locomotion/base authority; motor rejects unresolved ambiguity with no scene/signal-order fallback |
| Base locomotion and gravity | Ground/air/dead/wall target movement and current gravity scale | One base policy, then compatible gravity; rates integrate with physics delta seconds |
| Sustained influences | Current grapple pull acceleration | Sort stable source IDs before the fold; each rate applies once as `rate * delta` |
| One-shot impulses | Ground jump and wall jump | Deduplicate `(step, source, occurrence)`, then sort `(source, occurrence)` before adding velocity deltas |
| Constraints and redirections | Wall tangent redirection, outward removal, exclusive wall-stick hold | Typed fixed internal policy order; incompatible policies fail the frame before body mutation |
| Caps and final commit | Current grapple `total_speed` cap, then sole commit | `total_speed` is the only active cap scope; compatible submissions choose the strictest positive bound. Ground/air maximums remain base-target bounds, not cap submissions. Unsupported future scopes reject explicitly; never introduce an unconditional locomotion clamp that erases inherited momentum |

Contribution-local invalidity rejects only that attempted contribution. Structural ambiguity rejects the whole frame. These outcomes must use different typed reasons and tests. Resolution is performed in local motor data, so even a late-discovered structural conflict cannot leak partial body state.

### Baseline and Tuning Decision

The GDD is `needs-decisions` and its movement table is a validation baseline, not final balance. For Story 1.4, the effective `main.tscn` player values (`ground_deceleration = 30.0`, `grapple_gravity_scale = 0.0`) are the normative playable/GDD oracle. A directly instantiated `player.tscn`/controller retains `20.0` and `1.0` as compatibility fallbacks, not a second product-tuning target. The tutorial instantiates that reusable scene and then assigns `grapple_length = 35.0` and `grapple_gravity_scale = 0.65`; its reset teleport remains an explicitly out-of-band level operation. The motor must consume resolved instance values and hard-code none of them. Preserve and test all three contexts, label fixtures honestly, and do not normalize them without a separate recorded design/playtest decision.

### Requirement Traceability

- `FR2`: direct support for deterministic ground/air movement and ground/wall jumps; keyboard/mouse and view/aim remain behind Story 1.2 command frames.
- `FR3`: dependency only; retain one immutable `PlayerCommandFrame` per fixed step and never reintroduce gameplay `Input` polling.
- `FR4`: direct support for momentum continuity across locomotion, grapple, wall behavior, impulses, constraints, and caps.
- `FR5`: traversal/recovery continuity is a regression and smoke obligation, not new route design.
- `FR6` and `FR7`: current grapple acquisition is preserved; typed target eligibility/contracts are later work.
- `FR8`: current pull is the direct sustained influence and current `22 m/s` cap is the direct cap-phase obligation.
- `FR9`: explicitly deferred true active maximum-length boundary; Story 1.7 owns it despite the broader architecture example.
- `FR10`: explicitly deferred moving-target attachment and typed invalidation.
- `FR11`: direct wall-run/stick/jump phase integration, retaining current detection until Story 1.5.
- `FR12`: retained M0 traversal route/smoke remains the playable proof.
- Direct NFRs: `NFR3`, `NFR4`, `NFR5`, `NFR6`, `NFR9`, `NFR13`, `NFR15`, `NFR19`, `NFR20`, `NFR21`, `NFR22`, `NFR23`, `NFR24`. Supporting constraints include `NFR1`, `NFR7`, `NFR10`, and `NFR12`.

### Architecture and Scope Guardrails

- Use Godot `4.7.2-stable`, typed GDScript, Forward+, and Jolt. Preserve 60 Hz shipping physics and use 120 Hz only as a restored diagnostic test configuration.
- Preserve vendored LimboAI `1.8.1`; movement and attack remain separate manually updated HSMs.
- Preserve GUT `9.7.1`, `res://main.tscn`, current input actions, current player/root scene structure, and existing immutable Resource ownership.
- Do not introduce numeric movement priority, a global event bus/store, service locator, mutable shared Resource state, a second player controller, speculative pooling, telemetry, or live tuning.
- Do not move current `scripts/player_*_state.gd` or `scripts/player_controller.gd` merely to match the future target tree. New motor-owned code belongs under `game/player/motor/`; migration remains incremental.
- The architecture's future `ContactFrame` and maximum-anchor-distance examples do not override this shard's explicit Story 1.5/1.7 deferrals.
- Preserve current concrete wall and grapple detection, even though it is transitional. Do not deepen the coupling while phase-routing movement.
- Preserve current wall-stick motor-owned position hold and zero next-frame baseline. An ordinary constraint may not gain arbitrary teleport authority.
- Preserve `scripts/levels/tree_grapple_tutorial.gd` as a level-owned compatibility seam: its late grapple overrides and reset teleport remain outside semantic motor tuning/active-player commit migration.
- Preserve post-commit collision facts and the distinction between resolved pre-slide velocity and post-slide committed velocity.

### Current-State Update Map

Definite `UPDATE` files:

- `game/player/motor/player_motor.gd`
- `game/player/motor/player_motion_request.gd` (evolve or retire without leaving a bypass)
- `game/player/motor/player_motor_commit_result.gd`
- `game/player/motor/player_motor_diagnostic_snapshot.gd`
- `scripts/player_controller.gd`
- `scripts/player_grounded_state.gd`
- `scripts/player_airborne_state.gd`
- `scripts/player_grappling_state.gd`
- `scripts/player_wall_run_state.gd`
- `scripts/player_wall_stick_state.gd`
- `scripts/player_dead_state.gd`
- `tests/player/motor/test_player_motor.gd`
- `tests/player/motor/test_player_motor_integration.gd`

Architecture-supported `NEW` file:

- `game/player/motor/motor_phase.gd`

Inspect/reuse and change only if proven necessary:

- `scenes/player.tscn`
- `main.tscn`
- `tests/player/input/test_player_controller_command_sequence.gd`
- `game/app/logging/game_log.gd`
- `game/app/logging/diagnostic_event.gd`
- `game/app/logging/diagnostic_context.gd`
- `scripts/levels/tree_grapple_tutorial.gd`

An additional immutable phase/contribution record is allowed under `game/player/motor/` if the typed API cannot remain clear without it. Name it for its domain purpose and record the decision; do not build a generic effect framework. A top-level `tests/test_*_mcp.gd` adapter is optional, never a substitute for the recursive GUT suite.

### Predecessor and Git Intelligence

- Story 1.3 is `done`. Runtime implementation commit `c200a18` introduced and hardened the current transaction; `f9db971` only marked the story/sprint complete. Current story-authoring baseline is `7f0e5cd`.
- Story 1.3's verified GUT baselines were input `21/21` tests and `677` assertions, focused motor `24/24` and `290`, and recursive player `45/45` and `967`. Its MCP observation was narrower than a full traversal replay; do not inherit a stronger claim.
- Preserve Story 1.3 hardening: invalid initialization/body/frame/step rejection, duplicate begin/commit guards, rejected-follow-up safety, wall-stick baseline, detached/freed-body handling, bounded collision reporting, bounded diagnostic dedupe, and real-Jolt fixtures.
- Preserve its fixed stale-grapple-velocity-on-landing regression. Do not reopen Story 1.2 review findings that the user explicitly dismissed.
- Relevant earlier behavior commits include `0585848` (command frames), `f6a51f8` (split HSMs), `7e13ad6` (wall stick), `7b1675a` (grapple acceleration/cap), and `aded08a` (death behavior).

### Testing Requirements

The gates are intentionally separate:

1. **GUT:** focused input, focused motor, and recursive `tests/player` suites through the pinned Godot console. This is the canonical automated contract/regression result.
2. **Godot AI MCP native discovery:** report suites/tests/load errors exactly. The current direct top-level discovery finds zero because nested GUT `GutTest` scripts are not `McpTestSuite` suites.
3. **Godot AI MCP live validation:** required editor scan/readiness plus a running main-scene traversal check using live tree, evaluation, input/capture, diagnostics, and logs.
4. **Pinned import/load:** separate process/load integrity checks.
5. **Human observation:** record only if actually performed; do not relabel fixture/headless/MCP facts as human feel approval.

Serialize Godot processes to avoid `.godot` import/cache contention. Preserve the prior teardown-warning classification until evidence changes it. Every test that temporarily changes `Engine.physics_ticks_per_second` or diagnostic state must restore it even on failure.

### Latest Technical Information

- The official Godot archive lists `4.7.2-stable` as the current pinned stable release for this project; do not upgrade to a 4.8 development build in this story: <https://godotengine.org/download/archive/>.
- Godot 4.7 `CharacterBody3D` documentation states that `move_and_slide()` uses and may modify `velocity`, and it should be called from physics processing. This supports retaining distinct resolved/pre-slide and committed/post-slide values plus one authoritative call: <https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html>.
- Godot 4.7 `Engine` exposes physics-frame/tick information, but movement rates still use physics delta in seconds; a raw frame count is only an identity/diagnostic input: <https://docs.godotengine.org/en/4.7/classes/class_engine.html>.
- No dependency upgrade or replacement is required. Planning artifacts record Godot AI `3.2.4`, while the active local MCP plugin/server reports `4.0.4`; implementation must record the actual session/tooling version and must not install, downgrade, or rewrite dependency files as part of Story 1.4.

### Story-Authoring Godot AI MCP Evidence

- Mandatory read-only preflight session: `testgame@d3ecac167a39b179`.
- Observed engine/project: Godot `4.7.2-stable (official)`, `C:/Users/pinto/Documents/Godot Projects/testgame/`.
- Observed editor state: ready, stopped, no live helper, retained project session active. The inspection ended on `res://scenes/player.tscn`; `res://main.tscn` was also inspected.
- Successful operations included session listing/activation, editor-state inspection, main/player scene hierarchy reads, player/motor/HSM node-property reads, controller/motor/state script and symbol inspection, project/resource reads, and editor/plugin log inspection.
- MCP observed the retained `PlayerMotor` child, six-state movement HSM, four-state attack HSM, current scene overrides, and the one-complete-request motor API. No editor parse/runtime diagnostic was present in successful reads.
- MCP native `test_run` reported no suites (`total=0`, no load errors) because this repository currently contains nested GUT suites rather than direct top-level `McpTestSuite` scripts. This is a discovery result, not a GUT pass.
- One attempted logs call used an unsupported parameter and was rejected by MCP input validation; it was a tooling-call error, not a project diagnostic. Successful log reads showed no current editor error.
- Post-authoring MCP verification on the same session completed a settled editor-filesystem scan (`global_classes_registered_delta = 0`), re-read editor state as ready/stopped, confirmed the retained 28-node player hierarchy with `PlayerMotor`, both HSMs, and all states, and returned zero current editor diagnostic lines.
- Story authoring changed planning Markdown only. No runtime source, scene, or Resource was modified and no gameplay smoke/test result is claimed by this authoring preflight. The implementing developer must repeat the mandatory preflight and post-edit MCP validation.

### Project Structure Notes

- Runtime motor domain stays under `game/player/motor/`; tests mirror it under `tests/player/motor/`.
- Existing controller/state paths remain wired during this incremental story. Do not create parallel authorities under the future target hierarchy.
- Evidence belongs under `_bmad-output/implementation-artifacts/evidence/1-4/`; keep generated output out of runtime domains.
- Keep `res://main.tscn` as the launch scene and retain all scene/resource UIDs.

### Source References and Artifact Ledger

- [Source: `_bmad-output/.artifact-index/context-1-4.json`] — deterministic bounded context pack; `inventory_valid: true`, no errors; permitted warning that the GDD is `needs-decisions`.
- [Source: `_bmad-output/planning-artifacts/epics/epic-01-story-04.md`] — `artifact_id: grapplegame.story.1.4`; source revision `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`; pack SHA-256 `150fb00691abbed6b34d33c7509eb5f797391cc6c62f5d40ca63156f6b7549a3`.
- [Source: `_bmad-output/planning-artifacts/epic-01-overview.md`] — `artifact_id: grapplegame.epics.1`; source revision `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`; pack SHA-256 `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168`.
- [Source: `_bmad-output/planning-artifacts/epics/requirements.md`] — `artifact_id: grapplegame.epics.requirements`; source revision `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`; pack SHA-256 `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b`.
- [Source: `_bmad-output/planning-artifacts/gdd.md`] — `artifact_id: grapplegame.gdd`; version `1.2.0`; status `needs-decisions`; pack SHA-256 `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156`.
- [Source: `_bmad-output/planning-artifacts/architecture.md`] — `artifact_id: grapplegame.architecture`; version `1.0`; pack SHA-256 `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080`.
- [Source: `_bmad-output/project-context.md`] — `artifact_id: grapplegame.project-context`; implementation-guidance revision updated `2026-09-09`; pack SHA-256 `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97`.
- [Source: `_bmad-output/implementation-artifacts/1-3-centralize-the-players-physics-step-movement-commit.md`] — exact predecessor story, status `done`; runtime implementation `c200a18`.
- [Source: `_bmad-output/implementation-artifacts/evidence/1-3/`] — predecessor oracle, motor contract, focused GUT, writer audit, pinned-load, and MCP evidence.
- [Source: `game/player/motor/player_motor.gd`, `player_motion_request.gd`, `player_motor_commit_result.gd`, `player_motor_diagnostic_snapshot.gd`] — current transaction and typed lifecycle seam.
- [Source: `scripts/player_controller.gd` and six `scripts/player_*_state.gd` movement states] — currently wired traversal formulas, state decisions, and complete-velocity submission owners.
- [Source: `scripts/levels/tree_grapple_tutorial.gd`] — reusable-player instantiation, late `grapple_length = 35.0` / `grapple_gravity_scale = 0.65` compatibility overrides, and retained out-of-band reset teleport.
- [Source: `tests/player/motor/test_player_motor.gd`, `test_player_motor_integration.gd`, and `tests/player/input/`] — existing GUT contract/integration conventions.
- [Source: commits `7f0e5cd`, `f9db971`, `c200a18`, `0585848`, `f6a51f8`, `7e13ad6`, `7b1675a`, `aded08a`] — process and implementation continuity.

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Debug Log References

- Story-authoring context resolver: `_bmad-output/.artifact-index/context-1-4.json`
- Story-authoring Godot AI MCP session: `testgame@d3ecac167a39b179`
- Fresh-context story validation: PASS after one blocker-correction recheck; no remaining blockers or required corrections
- Implementation MCP session: `testgame@d3ecac167a39b179`; final post-edit scan settled with 107 registered global classes and zero delta, final editor state ready/stopped, current editor log cursor 4 with zero new lines, and clean main-scene run token 15 with helper live and no current-run errors.
- Implementation evidence: `_bmad-output/implementation-artifacts/evidence/1-4/` (pre-change oracle, phase contract, writer audit, GUT, 60/120 Hz, pinned load, MCP, traversal smoke, status/diff, and limitations).

### Completion Notes List

- Ultimate context engine analysis completed; developer-ready semantic phase, deterministic aggregation, failure, scope, and dual-validation decisions are embedded above.
- Fresh-context checklist validation passed after explicitly adding all three tuning contexts/tutorial reset coverage, portable pinned-Godot commands, concrete `StringName` occurrence ownership, measured diagnostic bounds, and unambiguous conflict handling.
- No runtime implementation or gameplay validation was performed while creating this story; the implementation turn completed the runtime migration and recorded separate CLI GUT, pinned-load, Godot AI MCP, and teardown/diagnostic evidence below.
- Replaced the complete-velocity request seam with typed `MotorPhase`/`PlayerMotorSubmission` records and narrow motor methods. The motor now validates structural policy conflicts before local phase resolution, folds stable contributions through seven phases, applies the existing grapple cap/wall constraints, and owns the single final body write/slide.
- Routed the controller and all six movement states through semantic submissions while preserving the existing command-frame/HSM transaction, grapple pull formula, wall detection, wall-stick zero baseline, jump occurrence identity, scene tuning, tutorial placement seam, and attack-HSM isolation.
- Extended copied bounded result/snapshot facts and rejection logging; added semantic, lifecycle, real-Jolt integration, source-ownership, tuning-context, and 60/120 Hz coverage. Final fix-pass GUT results: input 21/21 (677 assertions), motor 36/36 (2,131), recursive player 57/57 (2,808).
- Mandatory MCP evidence: preflight/fix-pass session `testgame@d3ecac167a39b179` plus fresh final session `testgame@40d061afaea5bfeb`; scan/reload/readiness checks, scene/node/script inspection, native discovery (`total=0`, `load_errors=[]`), main-scene runtime/diagnostics smoke, plugin/editor/game logs, stop, and final ready/stopped verification all completed. The restarted editor cursor returned no diagnostics; live checks observed successful seven-phase single commits with no current-run errors. No human feel/visual approval was performed.
- An exploratory MCP eval snippet was rejected for mixed indentation in run token 14 and that temporary run was stopped; clean run token 15 then relaunched and completed the recorded smoke. The fix-pass runs 17–19 ended without current-run errors; the free-running scene eventually produced normal damage/death info. After the editor restart, run token 1 was stopped after a temporary eval referenced a nonexistent property; corrected run token 2 passed the live check and stopped cleanly. Four retained pre-fix editor reload entries, the intermediate parse/cache diagnostics, and the eval-snippet diagnostics are documented in `mcp-verification.md` / `limitations.md`, not hidden.

### File List

- Runtime motor: `game/player/motor/motor_phase.gd`, `player_motor_submission.gd`, `player_motor.gd`, `player_motor_commit_result.gd`, `player_motor_diagnostic_snapshot.gd`; retired `player_motion_request.gd` and UID sidecar removed.
- Runtime routing: `scripts/player_controller.gd`, `scripts/player_grounded_state.gd`, `scripts/player_airborne_state.gd`, `scripts/player_grappling_state.gd`, `scripts/player_wall_run_state.gd`, `scripts/player_wall_stick_state.gd`, `scripts/player_dead_state.gd`.
- Tests: `tests/player/motor/test_player_motor.gd`, `test_player_motor_integration.gd`, `test_player_motor_semantic_contract.gd`, plus their generated UID sidecars.
- Evidence: `_bmad-output/implementation-artifacts/evidence/1-4/` (including `pre-change-oracle.md`, `phase-contract.md`, `writer-audit.md`, `focused-gut.md`, `recursive-gut.md`, `60-120-comparison.md`, `pinned-load.md`, `mcp-verification.md`, `traversal-smoke.md`, `complete-status-diff.md`, and `limitations.md`).
- Records: this story file and `_bmad-output/implementation-artifacts/sprint-status.yaml`.

## Change Log

- 2026-09-12: Created Story 1.4 from the validated bounded context pack; resolved semantic phase ordering, deterministic aggregation, conflict/rejection behavior, baseline preservation, scope deferrals, and mandatory separate GUT/Godot AI MCP validation requirements. Fresh-context validation passed and sprint status was synchronized to `ready-for-dev`.
- 2026-09-12: Implemented the typed semantic motor phase pipeline, controller/state migration, bounded diagnostics/results, and regression coverage; completed serialized GUT, pinned import/load, and Godot AI MCP validation. Story moved to `review`; manual feel/visual approval remains outside this turn.
- 2026-09-17: Applied the Story 1.4 review fixes: enforced kind/phase and source contracts, made `total_speed` the explicit supported cap scope, rejected degenerate wall policies, corrected wall-relative redirection, preserved valid frames after isolated contribution failures, enriched accepted diagnostics, recorded the dead terminal marker, and expanded regression coverage. Re-ran focused/recursive GUT and mandatory Godot AI MCP validation; story remains in `review` pending manual feel/visual approval.
