---
baseline_commit: 1e8f81bfe34a6dd2bd602b3d48d772e63d648cc2
---

# Story 1.3: Centralize the Player's Physics-Step Movement Commit

Status: done

<!-- This story introduces the single-commit PlayerMotor seam while preserving the Story 1.1 traversal baseline and the Story 1.2 command-frame boundary. Story 1.4 owns semantic influence phases. -->

## Story

As a player,
I want every traversal state to resolve through one authoritative movement commit,
so that state transitions cannot move me twice, skip collision movement, or produce order-dependent velocity.

## Acceptance Criteria

1. **Open exactly one motor frame from committed body state**
   - **Given** a successfully initialized player enters an active physics step
   - **When** player movement processing begins
   - **Then** the player motor opens one motion frame identified by the current physics-step number
   - **And** that frame begins from the player body's previously committed velocity and current transform without allowing a movement commit yet.

2. **Movement states submit through the typed motor boundary**
   - **Given** the movement state machine evaluates grounded, airborne, grappling, wall-running, wall-sticking, or dead behavior
   - **When** the active state calculates its existing motion result
   - **Then** it submits that result through the typed player-motor boundary
   - **And** the state does not assign the `CharacterBody3D`'s final velocity, change its authoritative global position, or call `move_and_slide()` directly.

3. **Commit exactly once despite transitions and early returns**
   - **Given** movement-state evaluation completes or dispatches a state transition during a physics step
   - **When** the player movement coordinator reaches its commit phase
   - **Then** the player motor assigns final body velocity and calls `move_and_slide()` exactly once for that active physics step
   - **And** early returns, state changes, grapple start or release, landing, jumping, wall transitions, and death cannot create either a second commit or a missing commit.

4. **Attack processing cannot move the player**
   - **Given** both movement and attack state machines are active
   - **When** they evaluate the same command frame
   - **Then** only the movement coordination path can request and commit player displacement
   - **And** attack-state processing cannot call movement methods or cause an additional body commit.

5. **Ground and air traversal remain equivalent**
   - **Given** grounded or airborne locomotion is active
   - **When** movement, gravity, jumping, landing, and deceleration are exercised
   - **Then** their observable velocity and collision behavior remain equivalent to the approved Story 1.1 baseline within documented physics tolerances
   - **And** the new motor boundary does not retune any traversal scalar.

6. **Complex traversal submits a complete provisional result without semantic decomposition**
   - **Given** grappling, wall running, wall jumping, wall sticking, or dead movement is active
   - **When** that state requests its current movement behavior
   - **Then** its complete provisional velocity or hold request is resolved by the motor before the single commit
   - **And** this story preserves the current behavior without yet decomposing it into the semantic influence phases reserved for Story 1.4.

7. **Post-commit collision facts are bounded and cannot trigger another move**
   - **Given** wall-stick entry or another transition depends on collisions produced by movement
   - **When** the single motor commit completes
   - **Then** the resulting slide collisions are exposed through a bounded post-commit result for state coordination
   - **And** inspecting or reacting to those results does not call `move_and_slide()` again in the same physics step.

8. **Wall stick requests a motor-owned hold**
   - **Given** wall sticking needs to hold the player at its committed location
   - **When** the wall-stick state remains active
   - **Then** it requests the hold through the motor boundary
   - **And** the wall-stick script does not write `global_position` or authoritative velocity directly.

9. **Duplicate commits fail visibly and safely**
   - **Given** a second commit is requested using the same physics-step number
   - **When** the player motor validates the request
   - **Then** a debug assertion and stable diagnostic event identify the duplicate request, the second movement operation is rejected, and release execution remains safely guarded
   - **And** the player body is not moved a second time.

10. **Initialization and request failures fail closed**
    - **Given** the player motor is missing, initialized twice, or receives an invalid motion request
    - **When** player initialization or movement processing occurs
    - **Then** the failure is exposed through a typed development-visible result or invariant diagnostic without falling back to state-owned movement
    - **And** the partially configured player does not continue active traversal.

11. **Motor diagnostics are read-only, bounded, and opt-in**
    - **Given** the player motor exposes development diagnostics
    - **When** the motor snapshot is inspected
    - **Then** it reports the physics-step number, initial velocity, submitted provisional result, committed velocity, commit count, active locomotion state identifier, and any rejection reason
    - **And** diagnostics remain read-only, bounded, and disabled when not requested.

12. **Real-Jolt integration coverage protects every movement state**
    - **Given** the focused real-Jolt player-motor integration tests run
    - **When** they exercise grounded, airborne, jump, grapple, wall-run, wall-jump, wall-stick, dead, and state-transition steps
    - **Then** every active physics step records exactly one player movement commit and duplicate requests are rejected
    - **And** the test uses physics tolerances rather than exact floating-point equality or a deeply mocked physics body.

13. **The finished migration remains scoped and runnable**
    - **Given** Story 1.3 is complete
    - **When** the player gameplay scripts, scene references, baseline smoke procedure, and working-tree diff are reviewed
    - **Then** `move_and_slide()` and final player-body velocity assignment occur only through the player motor, retained scenes and Resources preserve their UIDs, and `res://main.tscn` remains runnable
    - **And** the story has not introduced semantic influence ordering, shared `ContactFrame` classification, grapple-contract redesign, traversal retuning, tutorial preservation, application-root migration, or unrelated domain changes.

## Tasks / Subtasks

- [x] 1. Pin the pre-change movement oracle and classify every current writer before editing runtime code (AC: 3-8, 12, 13)
  - [x] Re-read the completed Story 1.1 and Story 1.2 records, including Story 1.1's accepted `PASS WITH LIMITATIONS`, `BASE-002`, `BASE-004` through `BASE-007`, and Story 1.2's dismissed review findings. Do not silently promote a fixture-only or headless observation into a stronger baseline claim.
  - [x] Capture the implementation-start commit, full working-tree status, pinned Godot build, player scene UID, gameplay tuning overrides, and all player-active-physics call sites that write velocity/position or call `move_and_slide()`. Preserve unrelated/user-owned changes.
  - [x] Record a quantitative pre-change oracle for representative ground acceleration/deceleration, airborne gravity/steering, jump launch/apex/airtime, grapple pull/release, wall run/jump/stick, dead movement, landing, and transition frames. State the numeric/vector tolerances and any permitted one-physics-step phase alignment before using them in post-change claims; do not retune to make a comparison pass.
  - [x] Classify non-player or non-active-physics matches instead of deleting them: enemy movement, projectile/visual transforms, `GrappleCursor`, and the tutorial's out-of-band reset teleport are not Story 1.3 player-motor writers.
  - [x] Re-run the Story 1.2 focused input suite before implementation. If the baseline or required local GUT/Godot tooling cannot be reproduced, record the limitation or blocker before runtime edits.

- [x] 2. Add the smallest typed `PlayerMotor` frame/request/result boundary under `game/player/motor/` (AC: 1-3, 6-11)
  - [x] Create `game/player/motor/player_motor.gd` as a child/wrapper initialized with the retained player-root `CharacterBody3D`, not as a replacement body/root script. It is the sole owner of active-physics final `CharacterBody3D.velocity`, authoritative wall-stick hold correction, and `move_and_slide()`. Initialize it once with the player body through a typed status/result; reject missing, wrong-type, or repeated initialization without activating traversal.
  - [x] Use a small typed representation for one complete per-step request: ordinary movement supplies a complete provisional velocity, while wall stick supplies an explicit hold request and hold position. Include the request's physics-step number and stable locomotion-state identifier. Do not use a mutable `Dictionary`, a generic influence list, numeric priority, or Story 1.4 phase/channel types.
  - [x] Use one explicit public lifecycle consistently: `initialize(body)`, `begin_motion_frame(step)`, one typed movement-or-hold submission method, and `resolve_and_commit()`. Do not add a second `begin_step` alias merely to mirror architecture pseudocode.
  - [x] On `begin_motion_frame`, validate the proposed step before clearing any state, then snapshot the body transform and previously committed velocity and clear only per-frame submission/result state. Explicitly reject an equal-step duplicate, a lower/non-monotonic step, or a conflicting active frame; a rejected duplicate begin cannot erase an accepted request/result. Reuse one coordinator-owned monotonically increasing step ID for command capture and the motor; do not create two counters that can drift.
  - [x] Accept exactly one complete movement-or-hold request on a valid active frame. Reject no-frame, wrong-step, duplicate, non-finite, or otherwise invalid submissions through a compact typed reason; never fall back to direct state-owned movement.
  - [x] In the successful commit, apply any motor-owned hold correction, assign the submitted provisional velocity once, call `move_and_slide()` once, then capture the post-slide body velocity as committed velocity. Keep pre-slide provisional and post-slide committed velocity distinct because Godot collision response can modify `CharacterBody3D.velocity`.
  - [x] Return a typed synchronous post-commit result containing only bounded current-step facts needed by coordination: step, success/rejection, pre/post velocity, position delta or transform facts, floor/wall flags as needed, and at most the slide collisions reported by that one call. Collision objects may be consumed synchronously during that step but must not be retained as diagnostic history or become `ContactFrame`.
  - [x] Guard duplicate commit with an explicit release-safe rejection branch as well as a side-effect-free debug assertion. Record a stable typed/dotted diagnostic code and rejection reason before returning; assertions alone are insufficient because Godot removes them from non-debug builds.
  - [x] Because the current checkout has no `GameLog`, add the smallest architecture-shaped typed one-way facade under `game/app/logging/` needed to escalate motor invariant/initialization failures. Route engine console/debugger output from that facade only, use stable event codes plus scalar/ID context, deduplicate repeated records, and keep gameplay unable to read logs. Do not add an autoload, AppRoot migration, overlay, custom Godot `Logger`, synchronous file writer, remote telemetry, or general logging cleanup; pre-existing untouched diagnostics remain staged migration debt.
  - [x] Provide an opt-in read-only diagnostic snapshot for step ID, initial velocity, submitted request, committed velocity, per-step commit count, locomotion ID, and last rejection. Reuse already-computed values, retain no unbounded history/live node references, and perform no extra move or physics query for diagnostics.

- [x] 3. Make `PlayerController` the explicit begin -> movement -> commit -> post-commit -> attack coordinator (AC: 1, 3, 4, 7, 9-11)
  - [x] Resolve and initialize both `PlayerInputSource` and `PlayerMotor` before activating either HSM. A missing/invalid motor leaves the player safely inactive and development-visible; do not broaden this task into relitigating Story 1.2's dismissed input/dependency findings.
  - [x] For every active `_physics_process`, advance one player physics-step ID, capture the immutable `PlayerCommandFrame`, open the matching motor frame, update the movement HSM exactly once, commit exactly once, coordinate post-commit transitions from the returned result, then update the attack HSM exactly once with the same immutable command frame.
  - [x] Treat movement -> commit -> post-commit -> attack as a deliberate Story 1.3 transitional order because current attack states have no movement authority. Story 1.4/M1 must place any future ability-sourced movement before the single commit instead of adding a second commit after attack evaluation.
  - [x] Advance/capture a fresh neutral command frame while the initialized player is dead rather than reusing the last live frame; `PlayerInputSource` is already disabled by death gating. The dead movement state still opens, submits, and commits one motor frame per active physics step.
  - [x] If begin, submission, or commit fails, stop active traversal safely and surface the typed reason. Do not call a legacy state movement method as recovery and do not let the attack HSM create or repair a motor request.
  - [x] Move once-per-step grapple presentation refresh out of movement-state early-return paths if needed so presentation observes the committed result without causing movement or duplicate queries. Preserve canonical aim and all Story 1.2 command-frame semantics.
  - [x] Expose only narrow controller methods needed by states to submit a complete request and by post-commit coordination to inspect its result. Attack states receive no motor authority.

- [x] 4. Convert existing movement calculations and all six locomotion states to provisional results (AC: 2-8, 12, 13)
  - [x] Refactor `scripts/player_controller.gd` movement helpers to calculate from explicit provisional velocity/transform inputs and return values or submit one complete result. During state evaluation they must not mutate the inherited body `velocity`/`global_position` or call movement directly. Reading last committed body/contact facts remains allowed where required by current behavior.
  - [x] `player_grounded_state.gd`: submit exactly one request for ordinary locomotion and every early transition, including left-ground, grapple-start, and jump paths; preserve current acceleration, deceleration, jump scalar, and transition events.
  - [x] `player_airborne_state.gd`: submit exactly one request for landing, grapple-start, wall-run-entry, and ordinary gravity/air-steering paths; preserve current ray checks, thresholds, and event behavior.
  - [x] `player_grappling_state.gd`: calculate the same gravity, horizontal steering, pull acceleration/jerk, and velocity cap into one provisional result. Grapple release/invalid-target branches still submit a valid pass-through result before transition. Remove the call to the current `slide_and_check_wall_stick()` commit helper; the grappling state submits only, and the coordinator inspects the motor's bounded post-commit slide collisions before dispatching any wall-stick transition.
  - [x] `player_wall_run_state.gd`: submit one complete request for landing, grapple start, wall-run exit, ordinary run, and wall-jump paths. Remove both state-owned `move_and_slide()` calls without changing wall vectors, speed gates, acceleration, gravity scale, or transition events.
  - [x] `player_wall_stick_state.gd`: replace direct hold-position/zero-velocity writes and the wall-jump move call with explicit motor hold or movement requests. Preserve grapple-held, valid-target, jump, and release conditions.
  - [x] `player_dead_state.gd`: submit the same deceleration/gravity provisional velocity each active dead step; remove controller/state-owned movement commit while preserving attack/grapple/wall cleanup and death gating.
  - [x] Audit every transition/return branch so valid initialized movement produces exactly one submission. Do not decompose base, gravity, grapple, impulse, constraint, or cap channels yet; the complete provisional result is intentionally a temporary Story 1.3 seam.
  - [x] Keep attack ready/windup/active/recovery timing and behavior unchanged. Add only the audit/test coverage needed to prove these states cannot call movement or submit to the motor.

- [x] 5. Wire the motor into the retained player scene without broad migration (AC: 10, 13)
  - [x] Add the explicit `PlayerMotor` dependency/child to `scenes/player.tscn` and update script resources as required. Preserve `uid://u1u36ceuo8uj`, every retained ext-resource UID, unique node ID, node name/path, HSM topology, collision layer/shape, and gameplay tuning override.
  - [x] Keep traversal tuning on its current controller/scene owners; do not snapshot or duplicate it into the motor during `_ready()`. In particular, preserve `main.tscn`'s `ground_deceleration = 30.0` and `grapple_gravity_scale = 0.0` overrides, plus the tutorial-instantiated player's inherited `ground_deceleration = 20.0` default and post-`add_child()` assignments (`grapple_length = 35.0`, `grapple_gravity_scale = 0.65`).
  - [x] Keep `res://main.tscn` as the launch scene. Do not move the player scene/controller/states into their final target directories in this story; only new motor-owned code starts in `game/player/motor/`.
  - [x] Let the pinned editor/importer create any new `.gd.uid` sidecars; do not hand-invent or replace UIDs, and inspect the scene/resource diff after import.

- [ ] 6. Add focused contract and real-Jolt integration coverage (AC: 3-13)
  - [x] Add tests under `tests/player/motor/`, mirroring the runtime domain. Use small real `CharacterBody3D`/Jolt scenes or programmatic fixtures for physics-dependent behavior; use a narrow fake only for pure rejection/diagnostic branches.
  - [x] Prove begin snapshots prior committed velocity/transform and cannot move; a second `begin_motion_frame()` for the same step is rejected before it can clear the first frame's request/result; one valid request produces one commit; a second commit for the same step is rejected and does not change transform, velocity, collision count, or commit count; missing, duplicate, wrong-step, non-finite, and double-initialization cases fail closed.
  - [x] Exercise the production coordinator/state path for grounded, airborne, jump, grapple, grapple release/invalid target, wall-run, wall-jump, wall-stick hold/release, dead, landing, and state-transition frames. Assert one submission and one commit for every valid active step, including branches that currently return before movement.
  - [x] Verify post-commit wall-stick inspection consumes only the returned bounded collisions and cannot commit again. Do not introduce shared ground/wall classification or deeply mock `move_and_slide()`.
  - [x] Verify motor failures produce one owner-emitted typed `GameLog` record with the stable event/context, repeated records are deduplicated, gameplay never reads the log, and no new raw engine logging call exists outside `game/app/logging/`. Keep this distinct from the opt-in diagnostic snapshot.
  - [ ] Compare representative pre/post velocity, position, floor/wall collision behavior, jump apex/airtime, grapple momentum, and wall behavior using the predeclared tolerances. Run 60 Hz shipping and 120 Hz diagnostic sequences without persisting a project-setting change. The headless run verifies the contract and representative real-Jolt paths, but does not claim a full interactive pre/post replay or 120 Hz sequence.
  - [x] Add a scoped source audit proving player `move_and_slide()` and active-physics final body-velocity assignment exist only in `game/player/motor/player_motor.gd`. Classify allowed reads, local provisional variables, enemy code, visual transforms, and out-of-band level reset teleports rather than using a brittle repository-wide ban.
  - [x] Re-run Story 1.2's 21-test input suite unchanged unless a directly required compatibility update is evidence-backed. Do not rewrite its tests merely to revisit dismissed review findings.
  - [x] Run from the repository root with the operator-resolved pinned console executable, first the established input regression suite and then the recursive player suite once motor tests exist:

    ```powershell
    $env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
    ```

- [ ] 7. Prove the retained project still works and record honest evidence (AC: 5, 6, 12, 13)
  - [x] Serialize pinned Godot import/load/test runs so processes do not contend for `.godot` import state. Record version, command, exit code, test scripts/tests/assertions, expected diagnostics, and sanitized evidence under `_bmad-output/implementation-artifacts/evidence/1-3/`.
  - [ ] Run a pinned import scan and `res://main.tscn` load, then repeat the accepted traversal smoke: `W/A/S/D`, `Space`, right-mouse grapple acquire/hold/release and momentum, wall run/stick/jump, left mouse or `F` attack, `Esc` release, click recapture, landing, and available recovery behavior. Distinguish automated, headless, fixture-only, and human-observed evidence. The available evidence is headless/fixture-only; no human visual smoke is claimed.
  - [x] Use the same resolved pinned executable as the test tasks and record both serialized commands: `rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --import --quit-after 120`, then `rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --quit-after 120`.
  - [x] Confirm no traversal scalar, `project.godot` physics/interpolation setting, grapple contract, tutorial content, attack timing, input behavior, dependency version, or unrelated path changed. Preserve and report `BASE-002`, fall/death limitations `BASE-004`/`BASE-005`, shutdown-noise classification `BASE-006`, and fixture-only wall evidence `BASE-007`; do not enable interpolation or overstate evidence in this story.
  - [x] Run `rtk git diff --check`, inspect complete scoped/unscoped status, verify retained UIDs/references, and repeat the writer audit. Do not clean or reset unrelated changes.
  - [x] Update `_bmad-output/project-context.md` only if implementation establishes a new stable motor API/test location or reproducible command that downstream stories need. No update was required because the existing context already covers the motor seam, domain test location, and pinned validation workflow. Record actual results in this story's Dev Agent Record and move status to `review` only when every checked item is evidenced.

## Dev Notes

### Developer Context

Story 1.2 now commits one immutable `PlayerCommandFrame` and manually updates movement before attack. Story 1.3 inserts the first target-architecture motor seam into that existing coordinator. It centralizes the *complete provisional movement result* and the single body commit; it does not implement the seven-phase influence pipeline.

Required per-step choreography:

```text
capture one PlayerCommandFrame for step N
  -> PlayerMotor.begin_motion_frame(N)
  -> movement HSM evaluates once and submits one complete MOVE or HOLD request
  -> PlayerMotor commits once and returns bounded post-commit facts
  -> movement coordinator handles collision-dependent transitions without moving again
  -> attack HSM evaluates once from the same immutable command frame and has no motor authority
  -> presentation reads committed state
```

The successful path has exactly one begin, one accepted request, and one commit. Failure paths are typed and fail closed; they do not restore a legacy writer. A transition may change which state is active for the next evaluation, but it may not omit the current step's complete request.

A player whose required motor/input/HSM composition fails initialization never enters an active physics step: fail before frame opening and keep both HSMs inactive. A runtime request/commit invariant failure ends the currently active traversal path safely and cannot be converted into a neutral fallback commit that hides the defect.

For this staged migration, `PlayerMotor` is a child/wrapper holding a typed reference to the retained player-root `CharacterBody3D`; architecture examples that show body properties directly on the motor are shorthand, not authorization to replace the root or move its controller script. The public lifecycle names for this story are `initialize(body)`, `begin_motion_frame(step)`, one typed movement-or-hold submission operation, and `resolve_and_commit()`.

### Requirement Traceability

| Requirement | Acceptance criteria | Story 1.3 disposition |
| --- | --- | --- |
| FR2-FR3 | AC1, AC4, AC5, AC12, AC13 | Preserve Story 1.2 keyboard/mouse command-frame behavior and consume one shared fixed-step frame; no input redesign. |
| FR4 | AC2, AC3, AC5, AC6, AC8, AC9, AC12, AC13 | Primary delivery: preserve useful velocity behind one movement authority. |
| FR5 | AC5, AC12, AC13 | Preserve existing recovery behavior and baseline limitations; no route authoring. |
| FR6-FR10 | AC6, AC12, AC13 | Preserve current grapple acquisition/pull/release behavior through the new commit boundary; later stories own redesign. |
| FR11 | AC2, AC3, AC6-AC8, AC12, AC13 | Route wall-run, wall-jump, and wall-stick through the motor and bounded post-commit facts. |
| FR12 | AC5, AC12, AC13 | Protect the focused traversal vocabulary and runnable route as regression evidence. |
| FR13 | AC4 | Cross-epic guardrail only: attack observes the frame but cannot move the player. |
| NFR1, NFR3-NFR4, NFR6 | AC1, AC3, AC5, AC7, AC12 | Pinned Windows/Jolt fixed-step behavior, 60/120 diagnostic equivalence, and tolerant collision evidence. |
| NFR12, NFR15 | AC3, AC9, AC10 | Typed fail-closed initialization/request handling and idempotent duplicate rejection. |
| NFR19, NFR21 | AC9-AC12 | Bounded observational diagnostics and risk-appropriate single-commit tests. |
| NFR20 | AC3, AC9, AC12 | Protect single commit and 60/120 Hz equivalence here; semantic motion-influence order remains explicitly deferred to Story 1.4. |
| NFR22-NFR24 | AC5, AC13 | Keep the prototype runnable, preserve UIDs via staged migration, and add no speculative infrastructure. |

### Technical Requirements and Guardrails

- `PlayerMotor` owns only current/last committed motion-frame state, the body dependency, request validation, the hold operation, the final velocity assignment, one `move_and_slide()` call, current-step collision result, commit guard, and bounded diagnostics. Locomotion/grapple/death state remains with existing owners.
- Use stable producer IDs independent of scene paths: `player.locomotion.grounded`, `player.locomotion.airborne`, `player.locomotion.grappling`, `player.locomotion.wall_run`, `player.locomotion.wall_stick`, and `player.locomotion.dead`. Transition/jump branches retain the ID of the state that produced the current step's request.
- Keep pre-slide submitted velocity separate from post-slide committed velocity. Godot's `move_and_slide()` can change `CharacterBody3D.velocity` during collision response; baseline and diagnostics must use the correct side of that boundary.
- The current `PlayerCommandFrame.physics_step`/controller step is the established player-local monotonic identifier. Pass the same value into the motor frame; if implementation deliberately uses `Engine.get_physics_frames()`, use it consistently at both boundaries and test the mapping rather than retaining two independent authorities.
- Use compact typed enums/results for hot-path rejection. A stable event code should follow the project's dotted-ID convention (for example, `player.motor.duplicate_commit`) and represent a committed diagnostic fact, not an error string parsed by gameplay.
- Emit no global event bus and create no general diagnostic framework just for this story. Typed motor-local results and the opt-in snapshot remain the authoritative inspectable facts. For development-visible escalation, introduce only the missing architecture-required typed one-way `GameLog` facade and motor-related stable event/context definitions under `game/app/logging/`; only the owner that handles/rejects the failure logs it, gameplay never reads logs, and no raw `print()`, `printerr()`, `push_warning()`, or `push_error()` call is added outside that facade.
- Put the release guard in ordinary control flow. `assert()` is supplementary and side-effect-free because Godot strips assertions from release builds.
- A bounded synchronous commit result may expose the current call's `KinematicCollision3D` values for immediate state coordination. The diagnostic snapshot must copy bounded scalar/vector/ID facts and retain no live collision/node references.
- Do not allocate an unbounded history or perform extra physics queries for inspection. One small per-step request/result is acceptable only when bounded; avoid generic dictionaries and speculative reusable influence infrastructure.
- Wall-stick HOLD is an explicit request. Only the motor may apply any required authoritative transform correction and zero/final velocity before its one commit. Wall-stick state must not restore position after commit.
- Preserve current collision filters, `StaticBody3D` grapple target rule, grapple point, pull formula, velocity cap, wall rays, wall-normal tests, state events, and all tuning. Stories 1.5-1.8 replace those contracts later.
- Preserve separate movement and attack LimboHSMs, their manual-update configuration, and movement-before-attack ordering from Story 1.2. Do not give attack states a motor handle in this story. This is a staged order, not a precedent for committing before future ability influences in Story 1.4/M1.
- The locomotion ID in the request/snapshot identifies the state that produced that step's provisional result; do not derive it from a mutable node path after a transition has already changed the active state.
- Existing engine-wide player resets/teleports are outside ordinary active-physics movement. Preserve and classify the tutorial reset rather than routing it through this frame API or expanding into level/application ownership.

### Current-State Update Map

| Path | Current state | Story 1.3 change | Must preserve |
| --- | --- | --- | --- |
| `scripts/player_controller.gd` | `CharacterBody3D` coordinator captures the command frame, manually updates movement then attack, owns all traversal math, mutates `velocity`, writes wall-stick `global_position`, commits dead/grapple movement, and reads body slide collisions. | Initialize/use `PlayerMotor`; convert helpers to explicit provisional calculations; run begin/movement/commit/post-commit/attack; consume typed results; remove final body writes and commits. | Command-frame identity/aim, HSM topology/order, transition events, grapple/wall/death formulas, telemetry values, attack behavior, tuning. |
| `scripts/player_grounded_state.gd` | Mutates through controller helpers and calls `agent.move_and_slide()` only on the ordinary branch; transitions return early. | Submit one complete request on every branch and remove direct commit. | Floor checks, grapple/jump precedence, events, acceleration/deceleration. |
| `scripts/player_airborne_state.gd` | Applies gravity/steering and commits only on the ordinary branch; landing/grapple/wall-run branches return early. | Submit one request on all branches and remove direct commit. | Landing/grapple/wall-run precedence, wall query behavior, gravity/air tuning. |
| `scripts/player_grappling_state.gd` | Applies gravity, steering, pull/cap, calls controller `slide_and_check_wall_stick()`, then transitions from body collisions. | Remove that commit-helper call; submit one provisional result, then let coordinator-owned post-commit handling inspect the motor's bounded collisions before wall-stick transition. | Release/invalid target, jump, momentum, pull jerk/cap, wall-stick conditions, events. |
| `scripts/player_wall_run_state.gd` | Calls `move_and_slide()` in both jump and normal-run paths; other transitions return without movement. | Submit one complete request for every branch and remove both commits. | Wall-run tests/direction, jump vector, speed/gravity/acceleration, event order. |
| `scripts/player_wall_stick_state.gd` | Rewrites saved `global_position` and zero velocity every step; jump directly commits. | Request HOLD or wall-jump movement from the motor; remove direct position/velocity/move calls. | Saved hold point, grapple-held/validity gates, jump vector, release events. |
| `scripts/player_dead_state.gd` | Calls controller dead physics, which decelerates, applies gravity, and commits directly. | Submit dead provisional velocity for the coordinator's one commit. | Death cleanup/gating and current dead movement. |
| `scenes/player.tscn` | Retained player scene contains `PlayerInputSource` plus both LimboHSMs; UID `uid://u1u36ceuo8uj`. | Add the explicit motor child/dependency while retaining the player-root `CharacterBody3D` and scene identity. | All retained UIDs, unique IDs, node paths, collision setup, HSM topology, player-scene tuning, `main.tscn`'s ground/grapple overrides, and tutorial late overrides. |

Files that should remain behaviorally unchanged include `game/player/input/player_command_frame.gd`, `game/player/input/player_input_source.gd`, the four attack-state scripts, `project.godot`, `main.tscn`, grapple target selection, and tutorial content. Touch one only with direct evidence that the new motor seam requires it, and document why. The motor consumes requests built from current values; it must not cache controller tuning in `_ready()` because the tutorial applies valid tuning after instantiation.

### Expected File Structure

New motor runtime code belongs under `game/player/motor/`; the narrowly required logging boundary belongs under the architecture-approved `game/app/logging/`; tests belong under `tests/player/motor/`. The expected minimal shape is:

```text
game/player/motor/
  player_motor.gd
  player_motion_request.gd              # if a separate immutable request type is used
  player_motor_commit_result.gd         # bounded synchronous result
  player_motor_diagnostic_snapshot.gd   # only if not kept as a narrow nested type

game/app/logging/
  game_log.gd                           # minimal typed one-way facade; no AppRoot/autoload work
  diagnostic_event.gd                   # motor event codes, unless narrowly nested
  diagnostic_context.gd                 # bounded scalar/ID context, unless narrowly nested

tests/player/motor/
  test_player_motor.gd
  test_player_motor_integration.gd
```

Use fewer support files if the typed contract remains clear; do not add `motor_phase.gd`, influence channels, definitions, a generic result framework, or speculative folders in Story 1.3. Do not migrate legacy controller/state paths wholesale while introducing the seam.

### Testing Requirements

- GUT 9.7.1 and the pinned Godot 4.7.2 console build remain the toolchain. Use the smallest mix of pure contract tests and real-Jolt integration that protects the new risks.
- The current checkout's three `tests/player/input/` scripts and Story 1.2 evidence supersede the architecture document's older statement that no test directory/suite existed. Extend the actual checkout; do not recreate or rename that suite.
- Vendored add-ons are locally present but ignored by Git, Godot is not on the current shell `PATH`, and no export preset, CI command, or project-wide coverage command is established. Reuse the operator-local pinned console path and do not claim repository-only reproducibility or export/CI validation.
- Physics assertions use controlled stepping and explicit tolerances. Avoid arbitrary sleeps, exact floating-point equality, rendered-frame timing, private node paths, large scene-tree snapshots, and a fake implementation of `move_and_slide()` for the acceptance path.
- Count accepted submissions, actual commits, and duplicate rejections separately. A method invocation count alone is insufficient if the second invocation can still move the body.
- Keep invariant logging and the opt-in motor snapshot separate: ERROR escalation remains available in release through `GameLog`, while verbose snapshot inspection remains development-only and disabled by default.
- Exercise each current early-return/transition branch explicitly. Its request must preserve that branch's baseline provisional velocity or hold semantics; do not apply one generic pass-through or HOLD fallback across branches merely to satisfy the one-request count.
- For duplicate commit, snapshot transform/velocity/collision data after the first commit, issue the duplicate, and prove the body did not change again.
- For wall-stick post-commit behavior, prove the same result supplies collisions and the transition does not call the motor commit a second time.
- Baseline equivalence must state setup, inputs, start transform/velocity, physics rate, expected/observed result, tolerance, and transition alignment. Do not infer unchanged feel from a clean source diff alone.
- Run focused input regression, motor tests, pinned import/load, and the accepted traversal smoke. Do not claim project-wide automated coverage or a manual visual pass that was not actually observed.

### Previous Story Intelligence

- Story 1.2 established `PlayerCommandFrame`, `PlayerInputSource`, one command frame per numbered step, manual movement-before-attack HSM updates, canonical aim, focus/rearm behavior, and the focused `tests/player/input/` suite. Reuse these boundaries; do not resample hardware or mutate the command frame.
- Its final evidence recorded Godot `4.7.2.stable.official.ed1daf0bf`, GUT `9.7.1`, 3 scripts, 21 passing tests, 677 assertions, and process exit `0`. Re-run this focused suite as a regression and report actual new counts separately.
- Story 1.1 remains the accepted traversal oracle with limitations. Wall-run/stick observations are partly fixture-only (`BASE-007`), active play must be distinguished from shutdown noise (`BASE-006`), fall/death recovery is limited (`BASE-004`/`BASE-005`), and project interpolation is still false (`BASE-002`) despite the target architecture. This story does not change those facts.
- Story 1.2 deliberately preserved all movement formulas, transitions, commit sites, UIDs, scene topology, and tuning so Story 1.3 could centralize them. Its review dismissals were user decisions; do not reopen them incidentally. Story 1.3 must still satisfy its own explicit motor initialization and production-path acceptance criteria.
- The current production controller stops capturing command frames after death while its dead state keeps moving. Story 1.3 must close that continuity gap by advancing the shared step/neutral frame and motor transaction during initialized dead-state physics without weakening input gating.
- Serialize Godot processes; prior evidence observed import-cache contention and expected add-on/editor teardown diagnostics.

### Git Intelligence

- Story authoring began at `1e8f81b` on `main`. The relevant implementation commit is `0585848` (`feat(player): add fixed-step command-frame input boundary`); Story 1.2's front-matter `e53d33ea7b088a38cdd8923eb3b24d6a01d5a32b` is its pre-change baseline, not the final implementation revision.
- Earlier runtime history matters at the migration seams: `f6a51f8` split the player into movement/attack HSMs, `7e13ad6` introduced wall-stick/post-slide handling, `7b1675a` established grapple jerk/cap behavior, and `aded08a` established attack/death behavior. Preserve those contracts unless Story 1.3 explicitly centralizes their movement commit.
- At authoring time, `.codex/config.toml` was already modified and `_bmad-output/.artifact-index/context-1-3.json` was newly generated. They are not Story 1.3 runtime implementation changes; preserve them and recapture status at implementation start.
- Review the Story 1.2 commit/diff for typed `RefCounted` payloads, input-source initialization, explicit HSM manual updates, scene wiring, focused GUT style, and evidence conventions. Do not assume a clean checkout or attribute unrelated planning/media work to this story.

### Latest Technical Information

- The project remains pinned to Godot 4.7.2-stable; do not upgrade the engine or add-ons in this story. The official 4.7 API documents `CharacterBody3D.move_and_slide()` as a physics-step operation that consumes and can modify `velocity`, and documents slide collision data as belonging to the latest call. Therefore snapshot submitted velocity before the call, committed velocity/collisions after it, and never run a diagnostic move. [Godot 4.7 `CharacterBody3D`](https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html)
- `Engine.get_physics_frames()` increases once per physics frame and is suitable as a step identity if used consistently. Story 1.2 already supplies a tested player-local monotonically numbered command step, so prefer one shared identifier over parallel counters. [Godot 4.7 `Engine`](https://docs.godotengine.org/en/4.7/classes/class_engine.html)
- GDScript assertions are ignored in non-debug builds and their expressions are not evaluated there. Duplicate-commit safety must live in ordinary control flow; the assertion only makes the invariant visible during development. [Godot 4.7 GDScript assertions](https://docs.godotengine.org/en/4.7/tutorials/scripting/gdscript/gdscript_basics.html#assert-keyword)
- The exact pinned release remains available from the official archive. [Godot 4.7.2-stable archive](https://godotengine.org/download/archive/4.7.2-stable/)

### Project Context Rules

- Use Godot 4.7.2-stable, typed GDScript, Forward+, Jolt, fixed 60 Hz shipping physics, and seconds-based authoritative simulation. The 120 Hz mode is diagnostic and temporary.
- New player-motor code goes under `game/player/motor/`; tests mirror it under `tests/player/motor/`. Existing prototype files are migrated incrementally with Godot-aware references and UIDs.
- Use `snake_case` files/functions/variables/signals, `PascalCase` registered classes, `UPPER_SNAKE_CASE` constants/enums, verb-led commands, query prefixes, past-tense fact signals, explicit units/spaces, and stable lowercase dotted IDs.
- Use direct typed methods for commands/queries and typed facts after commit. Do not add a global mutable store, universal event bus, service locator, generic message queue, or subscriber-order-dependent movement.
- Keep authored Resources immutable and runtime state owner-local. Story 1.3 needs no new tunable Resource and may not duplicate or change traversal values.
- Development diagnostics are opt-in, observational, bounded, and built from already-computed results. Gameplay cannot read diagnostics to decide movement.
- Preserve Windows keyboard/mouse-only scope, `res://main.tscn`, Story 1.2 input ownership, and all retained scene/resource UIDs. Do not introduce controller/platform abstractions, pooling, telemetry infrastructure, live tuning, networking, save/RPG, or AppRoot work.

### Project Structure Notes

- The architecture's final target places the player scene/controller and locomotion states under `game/player/`, but this story performs only the motor seam. Moving retained files now would mix behavior centralization with a broad UID/reference migration and violate the story boundary.
- `PlayerMotor` is player-domain code, not a shared helper or autoload. A future cross-domain abstraction requires proven consumers; do not place this in `game/shared/`.
- Raw collision facts in the commit result are a temporary bounded coordination surface. Story 1.5 owns shared `ContactFrame` classification, so do not name or shape the result as that future contract.
- No UX package was present in the resolver pack. This story changes no HUD or presentation design; current grapple feedback and prototype readability must continue to function.

### References

Bounded authoring context pack:

- `_bmad-output/.artifact-index/context-1-3.json` - resolver output for Story 1.3; six files, inventory valid, no errors. The sole warning permits the canonical GDD's `needs-decisions` status for scoped M0 Story 1.3.

Source artifact revision ledger used to author this story. The `SHA-256` column is the resolver pack's file fingerprint; it is not the epic shards' shared declared source revision.

| Artifact ID | Revision / status | Path | SHA-256 | Used for |
| --- | --- | --- | --- | --- |
| `grapplegame.epics.requirements` | updated 2026-09-09; complete | `_bmad-output/planning-artifacts/epics/requirements.md` | `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b` | FR2-FR12, NFR3-NFR6, NFR12, NFR19-NFR24, and cross-cutting constraints |
| `grapplegame.epics.1` | updated 2026-09-09; complete | `_bmad-output/planning-artifacts/epics/epic-01-overview.md` | `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168` | Epic 1 objective/value and M0 boundary |
| `grapplegame.story.1.3` | updated 2026-09-09; complete | `_bmad-output/planning-artifacts/epics/epic-01-story-03.md` | `ce35a846f86b2f7d55b490b5659ec905b180d7842ddc629636b720ef4c2e0a66` | Canonical story statement, acceptance criteria, scope exclusions |
| `grapplegame.gdd` | v1.2.0; updated 2026-09-09; needs-decisions with M0 start allowed | `_bmad-output/planning-artifacts/gdd.md` | `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156` | Traversal fantasy, controls, movement baselines, M0 scope, deferred work |
| `grapplegame.architecture` | v1.0; updated 2026-09-09; complete | `_bmad-output/planning-artifacts/architecture.md` | `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080` | Single motor authority, error/diagnostic rules, file structure, real-Jolt verification |
| `grapplegame.project-context` | updated 2026-09-09; complete | `_bmad-output/project-context.md` | `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97` | Project-wide engine, code, testing, migration, platform, and anti-pattern rules |

All three selected epic-package shards separately declare source revision SHA-256 `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`.

Additional implementation intelligence:

- [Source: `_bmad-output/implementation-artifacts/1-2-deliver-reliable-fixed-step-player-commands.md` - completed tasks, Dev Agent Record, evidence, file list, and review dispositions]
- [Source: `_bmad-output/implementation-artifacts/1-1-verify-and-protect-the-playable-traversal-baseline.md` - accepted traversal baseline and limitations]
- [Source: `_bmad-output/implementation-artifacts/evidence/1-2/focused-gut.md` - pinned command and 21-test/677-assert result]
- [Source: `_bmad-output/implementation-artifacts/evidence/1-2/pinned-load.md` - import/main-scene load and evidence limitations]
- [Source: `_bmad-output/implementation-artifacts/evidence/1-2/preservation-audit.md` - retained scene/tuning/transition contract]
- [Source: `scripts/player_controller.gd` - current coordinator, body writers, movement helpers, grapple/wall/dead behavior]
- [Source: `scripts/player_grounded_state.gd`, `scripts/player_airborne_state.gd`, `scripts/player_grappling_state.gd`, `scripts/player_wall_run_state.gd`, `scripts/player_wall_stick_state.gd`, `scripts/player_dead_state.gd` - current movement branches and commit sites]
- [Source: `scenes/player.tscn` - retained scene UID, HSM topology, dependencies, collision setup, and tuning overrides]
- [Source: `main.tscn` - launch scene and player overrides `ground_deceleration = 30.0`, `grapple_gravity_scale = 0.0`]
- [Source: `scripts/levels/tree_grapple_tutorial.gd` - out-of-band reset teleport and post-instantiation grapple assignments]
- [Source: `tests/player/input/` - established GUT style and command-frame regression surface]
- [Source: repository history at `1e8f81b`, `0585848`, and Story 1.2's recorded baseline `e53d33e`]

### Story Completion Status

- Status set to `review`.
- Story key: `1-3-centralize-the-players-physics-step-movement-commit`.
- Epic 1 is already `in-progress`; no epic transition is required.
- Story 1.2 is `done` and supplies the fixed-step command boundary plus the latest implementation learnings.
- Story completion does not close M0: GDD decision `OD-009` still blocks milestone acceptance and remains a later tuning/playtest gate.
- Ultimate context engine analysis completed - comprehensive developer guide created.

## Dev Agent Record

### Agent Model Used

GPT-5 Codex

### Implementation Plan

- Verified the Story 1.1/1.2 baselines, planning revisions, and pinned Godot executable before changing runtime code.
- Added typed `PlayerMotor`, request/result/snapshot contracts, and the `GameLog` diagnostic boundary.
- Migrated the controller and six locomotion states to capture -> begin -> submit -> commit -> post-commit choreography, then added focused and real-Jolt coverage.
- Ran ordered regressions, import/load validation, preservation checks, and the scoped player-writer audit.

### Debug Log References

- `_bmad-output/implementation-artifacts/evidence/1-3/pre-change-oracle.md` — implementation-start commit, status, pinned engine, input-suite baseline, and quantitative pre-change observations.
- `_bmad-output/implementation-artifacts/evidence/1-3/motor-contract.md` — lifecycle, typed contract, diagnostic, and integration coverage record.
- `_bmad-output/implementation-artifacts/evidence/1-3/focused-gut.md` — ordered pinned GUT commands, 21/21 input results, 38/38 recursive-player results, and expected diagnostics.
- `_bmad-output/implementation-artifacts/evidence/1-3/pinned-load.md` — serialized import/main-scene load results and evidence classification.
- `_bmad-output/implementation-artifacts/evidence/1-3/writer-audit.md` — scoped ownership audit and retained-scene/project preservation checks.
- `_bmad-output/implementation-artifacts/evidence/1-3/mcp-verification.md` — Godot AI MCP session, scene/resource inspection, source audit, runtime smoke, MCP test-run limitation, and diagnostics.
- Expected invalid-step/missing-action diagnostics and Godot teardown leaks are classified in the evidence; no new unclassified runtime error was observed.

### Completion Notes List

- `PlayerMotor` is the sole player active-physics owner of final body velocity, motor-owned hold-position correction, and `move_and_slide()`.
- The coordinator now performs one capture, one motor begin, one movement submission, one commit, one post-commit coordination pass, and one attack update per active physics step.
- Wall-stick inspection consumes bounded post-commit collision data and cannot trigger a second movement commit; attack states have no motor authority.
- Retained scene topology, UIDs, launch scene, traversal tuning, input contract, attack timing, dependency version, and project physics/interpolation settings were preserved. Story 1.4 influence/contact/AppRoot work remains out of scope.
- Verification used pinned Godot 4.7.2 and GUT 9.7.1: input suite 21/21 tests and 677 assertions; focused motor suite 24/24 tests and 290 assertions; recursive player suite 45/45 tests and 967 assertions; import/load exit code 0; `git diff --check` exit code 0.
- Godot AI MCP verification used session `testgame@9865908531831e60`: the editor and live main scene were ready, the runtime motor initialized and committed one grounded step, the player moved to `z=-7.8744` under MCP input, and MCP source reads found the sole `move_and_slide()` call in `game/player/motor/player_motor.gd`. MCP's own test runner did not discover the project's GUT suites; this is recorded separately.
- Limitations remain explicit: no human visual smoke or full quantitative pre/post replay was observed in this headless run; `BASE-002`, `BASE-004`, `BASE-005`, `BASE-006`, and `BASE-007` remain classified as documented.

### Hardening Follow-up (2026-09-11)

The approved Story 1.3 hardening spec was implemented against baseline `1e8f81bfe34a6dd2bd602b3d48d772e63d648cc2`. The coordinator now aborts an active motor frame on any rejected follow-up submission or begin/commit failure, so an earlier accepted request cannot commit or trigger post-commit traversal after the frame becomes invalid. Accepted locomotion IDs are updated only after a successful submission. Wall-stick acquisition arms a motor-owned zero-velocity baseline for the next frame before changing state, preventing immediate release/jump from inheriting grapple velocity.

The motor now rejects detached/freed body lifecycles with typed statuses without body reads/writes, clears stale success results on invalid commit, exposes bounded deterministic wall-prioritized contact facts with an overflow flag, and provides a bounded stable diagnostic identity across physics steps. New tests cover these contracts, production coordinator failure, real physics ticks, grapple-landing cleanup, and the existing state paths. The final recursive player GUT run passed 45/45 tests and 967 assertions; the focused motor run passed 24/24 tests and 290 assertions.

Godot AI MCP session `testgame@9865908531831e60` was used for the required post-edit scan, scene/resource inspection, script-symbol inspection, live main-scene run, runtime motor/input smoke, log check, suspend/resume probe, and final ready/stopped check. MCP and pinned GUT results are recorded separately in `_bmad-output/implementation-artifacts/evidence/1-3/mcp-verification.md` and `focused-gut.md`. MCP's native test runner found no suites because the project uses recursive GUT `GutTest` suites; this is recorded as a harness limitation, not a passing MCP test claim.

No human visual smoke, full normal-play grapple/wall traversal replay, or quantitative 120 Hz pre/post traversal replay was observed. The existing Story 1.2 60/120 command-frame cardinality regression remains green, and no physics/interpolation setting or traversal tuning was changed.

The Godot AI MCP session used for the final post-review validation was `testgame@d3ecac167a39b179` after the prior session rotated while the task was paused. The fresh scan settled with registered-class delta `0`; MCP re-inspected `main.tscn`, the retained player/motor nodes, and the motor/controller symbols. A live main-scene smoke held `move_forward` and observed the player advance to approximately `z=-19.2911` while remaining active and grounded; the inspected result reported `accepted=1` and `commits=1`. MCP also exercised suspend/resume, stopped the project, cleared the debugger state, and returned the editor to `ready`/`stopped`. The MCP-native test runner found zero suites because the repository's canonical tests are recursive GUT suites, so the pinned CLI/GUT results remain the comprehensive gate. Two probe-only issues were isolated and cleared: one untyped eval compile error and one invalid `move_backward` action name (the project action is `move_back`). The host emitted WASAPI audio-device initialization errors and fell back to a dummy driver; these are environment diagnostics, not project failures.

### File List

- `game/app/logging/diagnostic_context.gd`, `diagnostic_event.gd`, and `game_log.gd` plus importer-generated `.gd.uid` sidecars.
- `game/player/motor/player_motor.gd`, `player_motion_request.gd`, `player_motor_commit_result.gd`, and `player_motor_diagnostic_snapshot.gd` plus importer-generated `.gd.uid` sidecars.
- `scripts/player_controller.gd`, `player_grounded_state.gd`, `player_airborne_state.gd`, `player_grappling_state.gd`, `player_wall_run_state.gd`, `player_wall_stick_state.gd`, and `player_dead_state.gd`.
- `scenes/player.tscn`.
- `tests/player/motor/test_player_motor.gd`, `test_player_motor_integration.gd`, and importer-generated `.gd.uid` sidecars.
- `_bmad-output/implementation-artifacts/evidence/1-3/` evidence records, this story record, and sprint metadata.
- Existing unrelated `.codex/config.toml` and context-index changes were preserved.

### Change Log

- 2026-09-11: Added the typed single-commit `PlayerMotor` boundary, migrated player movement ownership, added diagnostics and real-Jolt tests, recorded evidence, and moved the story to `review` with headless verification limitations called out.
- 2026-09-11: Applied the approved hardening follow-up for transactional submission failure, wall-stick baseline isolation, lifecycle guards, bounded contact facts, and stable bounded diagnostics; refreshed GUT/MCP evidence and retained the documented headless/fixture-only limitations.
- 2026-09-12: Completed post-review hardening validation in rotated MCP session `testgame@d3ecac167a39b179`, fixed stale grapple state before landing, refreshed final GUT totals to 45/45 recursive and 24/24 focused motor, and recorded the remaining evidence boundaries.
- 2026-09-12: User completed the manual Story 1.3 smoke pass and confirmed the implemented behavior works; story status moved from `review` to `done`.
