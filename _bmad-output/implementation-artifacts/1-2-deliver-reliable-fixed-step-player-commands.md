---
baseline_commit: e53d33ea7b088a38cdd8923eb3b24d6a01d5a32b
---

# Story 1.2: Deliver Reliable Fixed-Step Player Commands

Status: review

<!-- This story is implementation-ready. Keep Story 1.1's traversal baseline and current tuning intact while changing only the player-input boundary. -->

## Story

As a player,
I want my movement, actions, and mouse aim captured consistently at physics-step boundaries,
so that jumping, attacking, grappling, releasing, and aiming remain responsive regardless of render timing.

## Acceptance Criteria

1. **One immutable command frame per physics step**
   - **Given** the player input source initialized successfully
   - **When** the player begins an authoritative physics step
   - **Then** exactly one immutable `PlayerCommandFrame` is committed for that step
   - **And** it contains the physics-step number, movement axis, canonical view yaw and pitch, normalized authoritative world-space aim direction, and pressed/held/released facts for jump, grapple, and attack.

2. **Shared snapshot across both player HSMs**
   - **Given** a command frame has been committed for the current physics step
   - **When** the movement HSM and attack HSM update
   - **Then** both consume the same command-frame instance or identical immutable snapshot in that step
   - **And** neither HSM, its states, nor any gameplay helper resamples hardware input or mutates the frame.

3. **No gameplay-side hardware polling**
   - **Given** the input migration is complete
   - **When** the player gameplay surface is searched and exercised
   - **Then** gameplay states and controller helpers contain no direct `Input.is_action_*`, `Input.get_vector`, or equivalent hardware polling
   - **And** hardware access remains only inside the player input source and explicitly documented application/developer input boundaries.

4. **Movement semantics remain unchanged**
   - **Given** directional actions are pressed, held, combined, or released
   - **When** a command frame is committed
   - **Then** its movement axis preserves the existing InputMap direction, circular-deadzone, opposite-direction, and diagonal-normalization behavior
   - **And** Story 1.1 ground and air movement behavior remains equivalent.

5. **Short taps retain both edges**
   - **Given** jump, grapple, or attack is pressed and released between two physics steps
   - **When** the next command frame is committed
   - **Then** that frame reports both the pressed and released edges, with held reflecting the final semantic state
   - **And** each edge is present for exactly that frame and is cleared from the following frame.

6. **Held-action progression is deterministic**
   - **Given** an action remains down across multiple physics steps
   - **When** successive command frames are committed
   - **Then** the sequence contains one press edge, held on every applicable frame, and one release edge
   - **And** 60 Hz and 120 Hz diagnostic sequences contain no duplicated or missing command frames or edges.

7. **Focus changes cannot leave stuck input**
   - **Given** the game window loses focus while actions are held or edges/mouse motion are pending
   - **When** focus is lost and later restored
   - **Then** held state, pending action edges, and pending mouse motion are cleared before the next active command frame
   - **And** after refocus the source remains neutral until every tracked movement/action control has been observed neutral, then requires fresh post-rearm input
   - **And** refocusing produces no stuck or synthetic movement, attack, jump, or grapple input.

8. **Mouse aim is event-driven and rate independent**
   - **Given** the mouse is captured and motion events are received
   - **When** aim is accumulated and the next command frame is committed
   - **Then** every received mouse-motion contribution is applied exactly once, configured sensitivity and inversion are applied exactly once, pitch is clamped to configured limits, and no render or physics delta multiplier is applied
   - **And** the frame snapshots the resulting canonical yaw, pitch, and normalized world-space aim direction.

9. **Presentation cannot become gameplay authority**
   - **Given** a canonical orientation and aim have been committed
   - **When** the camera renders, collides, shakes, or smooths
   - **Then** presentation may update at render rate from the latest canonical orientation
   - **And** gameplay movement, attack, and grapple queries use the committed command-frame orientation/aim rather than deriving authority from the rendered camera transform.

10. **Owner gating does not corrupt input history**
    - **Given** the player is dead or gameplay input is explicitly gated
    - **When** a command is offered to the player
    - **Then** the owner rejects or ignores it without mutating the committed frame
    - **And** the input source does not own locomotion, ability, attack, grapple, or death decisions.

11. **Initialization fails explicitly**
    - **Given** the player input source, a required action, or another required dependency is missing or invalid
    - **When** the player initializes
    - **Then** development output identifies the failed dependency/action through a typed initialization result or assertion with a release-safe guard
    - **And** no global-input fallback or partially active player is allowed.

12. **Focused automated command-frame coverage**
    - **Given** the pinned Godot 4.7.2 and GUT 9.7.1 development environment
    - **When** the canonical recursive headless GUT command is run
    - **Then** focused tests cover movement-axis semantics, press/held/release progression, same-frame press-and-release, focus loss/refocus, one frame per numbered step, shared same-step identity, aim accumulation/clamping, and invalid initialization
    - **And** the exact command and test location are recorded in implementation evidence.

13. **Traversal baseline remains protected**
    - **Given** an accepted Story 1.1 baseline or equivalent validated Story 1.2 pre-change baseline exists
    - **When** Story 1.2 is complete
    - **Then** an equivalent pinned-engine smoke/diff check against that validated baseline confirms the same controls, mouse capture/release flow, launch path, and protected traversal behaviors
    - **And** this story adds no remapping UI, settings persistence, controller support, motor restructuring, traversal retuning, grapple redesign, tutorial-content changes, dependency upgrade, or unrelated migration.

## Tasks / Subtasks

- [x] 1. Establish a valid pre-change regression oracle before any runtime edit (AC: 13)
  - [x] Confirm Story 1.1 remains `done` and read its completed `Review Findings`, accepted dismissals, `PASS WITH LIMITATIONS` repeatability result, and `BASE-006`/`BASE-007` classifications before using it.
  - [x] Before changing a runtime file, identify the accepted Story 1.1 evidence or, if that artifact has become unavailable/invalid, capture an equivalent validated Story 1.2 pre-change baseline.
  - [x] Record the exact pre-change revision/worktree, pinned runtime, scene, controls, cursor flow, and applicable traversal observations. Preserve concurrent/user changes; distinguish ordinary player-observed behavior from `BASE-007` fixture-only wall-state observations and active-play results from `BASE-006` shutdown diagnostics.
  - [x] If neither valid oracle exists, stop before runtime implementation and record the blocker. `ready-for-dev` means the story specification is ready; it does not waive this implementation prerequisite or permit AC 13 to be claimed.

- [x] 2. Establish the immutable command-frame contract and scoped file layout (AC: 1, 2, 5, 6, 10, 11)
  - [x] Add `game/player/input/player_command_frame.gd` as typed `class_name PlayerCommandFrame extends RefCounted`. Use constructor-only/private backing data with read-only query access; expose no mutator and do not use a mutable `Dictionary` or `Resource` as the hot-path command payload.
  - [x] Define a fixed typed action enum and compact flags for jump, grapple, and attack. Provide typed `was_pressed(action)`, `is_held(action)`, and `was_released(action)` queries.
  - [x] Include `physics_step: int`, `movement_axis: Vector2`, `view_yaw_radians: float`, `view_pitch_radians: float`, and normalized `aim_world_direction: Vector3`.
  - [x] Make each new numbered step return a distinct frame, while repeated capture for the same step returns the cached same instance without consuming latches twice. Reject non-monotonic/conflicting step requests explicitly.
  - [x] Keep this contract local to the player input boundary; do not create an input autoload, global command store, event bus, or cross-system singleton.

- [x] 3. Implement the event-latching player input source (AC: 1, 3-8, 10, 11)
  - [x] Add `game/player/input/player_input_source.gd` as a typed node with one bounded, O(1) accumulator. It may access Godot's `Input`/`InputEvent` APIs; gameplay consumers may not.
  - [x] Validate the required InputMap actions `move_left`, `move_right`, `move_forward`, `move_back`, `jump`, `fire_grapple`, `attack`, and `ui_cancel`. Return/report a typed initialization failure and remain safely inactive if validation fails.
  - [x] Aggregate action state semantically across all bindings. Releasing one attack binding must not report attack released while another attack binding remains held; key echo must not create repeated press edges.
  - [x] Latch presses and releases arriving between physics steps so a short tap can expose both edges in the next frame. After a commit, clear only the consumed edge latches, never the returned frame.
  - [x] Preserve `Input.get_vector("move_left", "move_right", "move_forward", "move_back")` semantics inside this boundary, including opposite cancellation and circularly normalized diagonals. The source may use an injected/test seam, but production behavior must match the existing InputMap.
  - [x] Accumulate captured mouse motion from unscaled `InputEventMouseMotion.screen_relative` with no delta multiplication. Inject sensitivity, inversion, and pitch bounds from the owner/scene; do not read `ConfigFile` or invent settings persistence.
  - [x] Initialize canonical orientation from the current player/camera-pivot orientation so entering play does not snap. Derive a normalized authoritative world-space forward vector from canonical yaw/pitch without camera collision, shake, or smoothing feedback.
  - [x] Connect once to the main window's focus-loss signal. On focus loss, clear held state, pending edges, and pending mouse motion while retaining canonical orientation; emit neutral frames while unfocused.
  - [x] On focus restoration, enter an explicit rearm state. Continue emitting neutral movement/action facts until all tracked gameplay controls are observed released/neutral, then accept only fresh post-rearm presses. This must handle a key or mouse button that remains globally or physically held across the focus transition.
  - [x] Preserve `InputEventPanGesture` aim with the existing net `trackpad_pan_sensitivity` behavior. Apply each `event.delta` contribution once, without physics/render delta and without routing it through mouse sensitivity a second time.
  - [x] Preserve cursor behavior: `ui_cancel` releases capture; a mouse press may recapture it; the recapture click must be consumed as application context and must not also become an attack/grapple command.
  - [x] Provide an explicit enable/gate operation that clears future pending input when disabled. Keep already committed frames immutable and keep death/gameplay decisions in `PlayerController` and its HSMs.
  - [x] Retain no unbounded event list, per-frame dictionary, or history collection.

- [x] 4. Commit once and sequence both HSMs explicitly from the player controller (AC: 1-3, 8-11)
  - [x] Add a `PlayerInputSource` child to `scenes/player.tscn` and wire it explicitly to `PlayerController` while preserving the scene UID, all existing node unique IDs, resource references, node names/paths used elsewhere, HSM hierarchy, and every gameplay tuning override.
  - [x] Move the current gameplay mouse/action capture responsibility out of `PlayerController._input` and into the source. The controller may retain only a clearly documented application boundary if required; it must not resample gameplay actions.
  - [x] In `PlayerController._physics_process(delta)`, identify/increment the authoritative step, commit exactly one frame, store it as the current frame, then manually update movement and attack HSMs in a documented stable order so both see that frame.
  - [x] Follow the repository's existing enemy-HSM precedent: after initialization/activation, disable both HSMs' automatic process and physics-process callbacks and call `update(delta)` exactly once per player physics step. Do not allow automatic plus manual double updates.
  - [x] Add a typed `get_player_command_frame() -> PlayerCommandFrame` accessor that returns the committed frame and fails visibly if requested before valid initialization/commit. Do not expose frame mutation.
  - [x] Change `get_movement_input()`, the wall-stick collision helper, and other input-dependent controller helpers to read the current frame rather than `Input`.
  - [x] Keep view-relative movement authoritative to the committed yaw: derive its basis from the frame (or an authoritative transform synchronized to that frame before either HSM updates), never from a render-rate camera/body transform that may already reflect later mouse input.
  - [x] Apply canonical yaw/pitch to the player and camera pivot for presentation without feeding spring-arm collision or other presentation transforms back into gameplay authority.
  - [x] Change grapple ray direction to use the committed `aim_world_direction` while preserving the current ray length, collision mask/filtering, static-target rule, stored attachment point, cursor feedback, and all other Story 1.1 grapple behavior. Grapple resolver redesign remains Story 1.6.
  - [x] If input initialization is invalid, do not activate/update either player HSM or run a partially live controller. Produce a development-visible diagnostic and a release-safe inactive state.
  - [x] Keep dead/gated-state checks in the controller/states. When death occurs, reject the current command without changing it and disable/clear only future source input.

- [x] 5. Migrate every current gameplay consumer to the committed frame (AC: 2-5, 9, 10)
  - [x] Update `scripts/player_grounded_state.gd` for grapple press, jump press, and movement-axis consumption.
  - [x] Update `scripts/player_airborne_state.gd` for grapple press and movement-axis consumption.
  - [x] Update `scripts/player_grappling_state.gd` for grapple release, jump press, and movement-axis consumption.
  - [x] Update `scripts/player_wall_run_state.gd` for grapple press, jump press, and movement-axis consumption.
  - [x] Update `scripts/player_wall_stick_state.gd` for grapple-held and jump-press consumption.
  - [x] Update `scripts/player_attack_ready_state.gd` for attack-press consumption.
  - [x] At each HSM update, fetch the controller's committed frame and use its typed queries; do not cache mutable action state in states or add a fallback to the global `Input` singleton.
  - [x] Search the migrated runtime surface for direct polling and classify each remaining match. `game/player/input/player_input_source.gd` is the player hardware boundary; `scripts/debug_grapple_telemetry.gd` remains an explicit developer-only F3 boundary.
  - [x] Preserve transition events, state ordering, movement/grapple formulas, `move_and_slide()` locations, attack phase timing, death handling, and tuning. Story 1.3 owns movement-commit centralization.

- [x] 6. Add deterministic GUT coverage for the command boundary (AC: 1, 2, 4-12)
  - [x] Add `tests/player/input/test_player_command_frame.gd` for immutable values/query behavior, neutral fields, one distinct frame per new step, and cached object identity for repeated same-step capture.
  - [x] Add `tests/player/input/test_player_input_source.gd` using a narrow input seam or synthetic events. Avoid real sleeps, rendered-frame timing assumptions, deep physics mocks, exact comparison of derived floats, and private scene-tree paths.
  - [x] Cover movement cardinal directions, opposing inputs, normalized diagonals, and release to zero.
  - [x] Cover press -> held -> release -> neutral progression, press plus release within one interval, edge clearing, multiple bindings for attack, and ignored key echo.
  - [x] Cover focus loss with pending edges/motion, held clearing, neutral unfocused output, refocus without synthetic input, and recapture-click suppression.
  - [x] Hold movement and each semantic action across focus loss/restoration; assert neutral output until all tracked controls become neutral and assert that only a fresh post-rearm press creates a new edge.
  - [x] Cover mouse contribution exactly once, sensitivity/inversion once, yaw progression, pitch clamping, normalized aim, and independence from presentation camera transforms.
  - [x] Cover `InputEventPanGesture` once-only accumulation with the existing net trackpad sensitivity and no mouse-sensitivity or delta double application.
  - [x] Run numbered 60-step and 120-step diagnostic sequences and assert exactly one distinct frame per step, same-step cache identity, monotonic step IDs, and no duplicate/missing edges.
  - [x] In `tests/player/input/test_player_controller_command_sequence.gd`, use a lightweight controller/HSM spy seam to prove movement and attack each update once in the chosen order and observe the same frame object for a step. Keep this focused; do not mock the full LimboAI or physics stack.
  - [x] Cover missing required actions/dependencies and disabled/dead-owner gating without global-poll fallback or committed-frame mutation.
  - [x] Add a shared fixture only if multiple tests reuse it; keep the focused suite under `tests/player/input/`.
  - [x] Run and record the canonical recursive command from the repository root with the operator-resolved pinned console executable:

    ```powershell
    $env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
    ```

  - [x] Confirm the locally present GUT command-line script's help accepts these pinned 9.7.1 flags before treating the command as canonical. Do not install, upgrade, or vendor an add-on in this story.

- [x] 7. Prove integration and protect the baseline (AC: 3-6, 8, 12, 13)
  - [x] Run a pinned Godot 4.7.2 import/load check and retain fresh output sufficient to classify parse, resource, scene-load, and runtime errors. Put concise results in the Dev Agent Record and any sanitized raw evidence under `_bmad-output/implementation-artifacts/evidence/1-2/`. Serialize these runs so Godot processes do not contend for the same import cache.
  - [x] Repeat Story 1.1's `res://main.tscn` smoke flow: `W/A/S/D` ground movement and air steering, `Space` jump, right-mouse grapple acquisition/hold/release and post-release momentum, wall run/stick/jump, left mouse or `F` attack, `Esc` cursor release, mouse-click recapture, ordinary landing recovery, and launch from the unchanged main scene.
  - [x] Treat fall/death recovery as the existing non-blocking `BASE-004`/`BASE-005` limitations unless the reviewed Story 1.1 baseline changes; do not implement recovery here.
  - [x] Exercise aim and quick-tap behavior at ordinary operation and through a 60/120 command diagnostic. Restore any temporary runtime override in teardown; do not serialize a different tick rate or interpolation setting.
  - [x] Compare the runtime diff against Story 1.1 evidence and record any behavior change as a regression or separately scoped change. Do not retune around a failed migration.
  - [x] Verify `project.godot`, `main.tscn`, traversal tuning, tutorial content, dependencies, and unrelated runtime files are unchanged.
  - [x] Once the focused suite is real and passing, update `_bmad-output/project-context.md` narrowly: replace the stale “no established automated suite” fact and record the canonical command/location as a stable project contract.
  - [x] Complete the Dev Agent Record, exact test/smoke evidence references, completion notes, and actual file list.

## Dev Notes

### Scope and Completion Boundary

- This story directly delivers FR3 and materially contributes to FR2. It establishes only the fixed-step input/aim boundary required by FR4-FR12; it does not implement those later traversal, grapple, combat, enemy, or pressure-system behaviors.
- The outcome is one player-owned, physics-step command frame shared by the existing movement and attack HSMs. The frame is an immutable fact; states decide what it means.
- Preserve the existing playable controller and migrate incrementally. Do not replace LimboAI, introduce a new motor, centralize `move_and_slide()`, redesign grapple acquisition, or change ability lifecycles.
- Windows keyboard/mouse is the only required device scope. Controller input, rebinding UI, settings persistence, accessibility menus, replay/rollback/network serialization, and deterministic multiplayer are out of scope.
- Do not alter `project.godot` to meet future architecture targets. Story 1.1 observed the current effective 60 Hz baseline and disabled interpolation; the latter is `BASE-002` and must be reported, not silently corrected here.
- No dependency upgrade is authorized. Use the pinned Godot 4.7.2 stable environment and locally present GUT 9.7.1.
- GDD decision `OD-009` still leaves jump apex/airtime, coyote time, jump buffering, wall-entry tolerance, and grapple gravity behavior unresolved for M0 acceptance. Preserve current values and behavior; this input-seam story must not silently decide or retune them.
- AC 13 interprets the planning shard's ambiguous “tutorial preservation” non-goal as “no tutorial-content changes.” Keeping current tutorial files untouched is a regression guard, not authorization to redesign or establish a permanent tutorial-preservation requirement.

### Authoritative Command Contract

| Concern | Required contract |
| --- | --- |
| Ownership | A `PlayerInputSource` attached to the player is the only gameplay hardware boundary. No autoload/global input store. |
| Lifetime | One new `PlayerCommandFrame` per authoritative numbered physics step; repeated request for the same step returns the same object. |
| Mutability | Constructor/private backing data only, typed read access, no public mutators, no mutable dictionary/resource payload. |
| Movement | `Vector2` with the existing InputMap axes and circular normalization. |
| Actions | Fixed typed identifiers for jump, grapple, attack with independent pressed/held/released facts. |
| Orientation | Canonical yaw/pitch accumulated from mouse events; sensitivity/inversion once, pitch clamped. |
| Aim | Normalized world-space direction derived from canonical orientation and stored in the frame. |
| Consumption | Controller commits; movement HSM updates; attack HSM updates. Both use the same stored frame. |
| Gating | Player owner accepts/ignores commands; source can clear future input but never decides gameplay or mutates a committed frame. |
| Failure | Missing source/action/dependency is explicit and leaves the player safely inactive; no global fallback. |
| Cost | Bounded O(1) data and work per event/physics step; no retained event arrays or growing history. |

### Edge, Focus, and Context Semantics

- Pressed/released facts are interval latches, not “current render frame” queries. A press and release between commits yields `pressed=true`, `released=true`, and `held=false` for the next command.
- A semantic action can have several physical bindings. Transition its held/edge state from aggregate action state, not from an individual released key/button in isolation. This protects attack's left-mouse and `F` bindings.
- Ignore echo for edge creation. Repeated operating-system key events cannot manufacture additional presses.
- Focus loss is a hard input boundary: clear held actions, pending edges, pending motion, and movement state before any further active frame. Preserve canonical orientation so focus recovery does not snap.
- Focus restoration starts disarmed. While any tracked gameplay action or movement direction remains globally held, publish neutral movement/action facts; arm only after all are observed neutral, and require a subsequent fresh input transition.
- Input contexts resolve in this order: rebinding capture (future/out of scope), UI/pause or mouse-release handling, gameplay, then developer/debug. In this story, ensure `ui_cancel` and recapture suppression win over gameplay actions.
- The click that changes mouse mode from visible to captured is an application-context click. Consume it; a later captured click can become attack/grapple according to InputMap.

### Fixed-Step Sequencing

The implementation must make this order observable and testable:

1. Receive/latch events asynchronously between physics steps.
2. Enter `PlayerController._physics_process(delta)` and obtain the authoritative step ID.
3. Commit or retrieve exactly one `PlayerCommandFrame` for that step.
4. Store the frame as the controller's current immutable snapshot.
5. Update the movement HSM exactly once with `delta`.
6. Update the attack HSM exactly once with the same `delta` and frame.
7. Allow render-rate presentation to read the latest canonical orientation without changing gameplay aim.

The repository already contains the safe manual-HSM pattern in `scripts/enemy_controller.gd`: initialize, activate, disable automatic process/physics-process callbacks, and invoke `update(delta)` from the owner's physics callback. Apply that pattern to both player HSMs. Document the chosen movement-before-attack order and keep it stable; do not infer a second command frame after a movement transition.

### Current Runtime Surface and Required Changes

| File | Current input responsibility | Story 1.2 change | Must preserve |
| --- | --- | --- | --- |
| `scripts/player_controller.gd` | Mouse capture/aim in `_input`; global movement poll; global grapple-held helper; live-camera grapple ray; auto HSM activation | Own one committed frame, manual fixed-step HSM updates, typed accessor, frame-backed helpers/aim | Motor formulas, transition graph, grapple limits/filtering, attack/death rules, all exported tuning |
| `scenes/player.tscn` | Player, built-in pivot/spring-arm/camera, separate MovementHSM and AttackHSM | Add/wire the input-source child and its configuration | Scene UID, node IDs/names/paths, HSM layout, resources, all tuning values |
| `scripts/player_grounded_state.gd` | Polls grapple, jump, movement | Read committed frame | Transition order and movement calls |
| `scripts/player_airborne_state.gd` | Polls grapple and movement | Read committed frame | Wall-run checks, gravity, movement behavior |
| `scripts/player_grappling_state.gd` | Polls grapple release, jump, movement | Read committed frame | Pull/release/momentum and wall-stick flow |
| `scripts/player_wall_run_state.gd` | Polls grapple, jump, movement | Read committed frame | Wall tests and wall-jump behavior |
| `scripts/player_wall_stick_state.gd` | Polls grapple held and jump | Read committed frame | Freeze/release/jump flow |
| `scripts/player_attack_ready_state.gd` | Polls attack press | Read committed frame | Dead gate and attack transition |
| `_bmad-output/project-context.md` | Says no suite is established | Update only after focused GUT suite passes | Existing stable rules and unrelated facts |

### File Structure Requirements

Expected new runtime/test files:

- `game/player/input/player_command_frame.gd`
- `game/player/input/player_input_source.gd`
- `tests/player/input/test_player_command_frame.gd`
- `tests/player/input/test_player_input_source.gd`
- `tests/player/input/test_player_controller_command_sequence.gd`

Add `tests/player/input/fixtures/` only if a typed helper is genuinely shared by multiple test files. Do not pre-create empty directories or speculative abstractions. Any Godot-generated `.gd.uid` sidecars for new scripts are legitimate outputs and must be included in the implementation's actual file list if emitted.

Record concise commands/results directly in the Dev Agent Record. If raw logs, a smoke matrix, or preservation hashes are needed, `_bmad-output/implementation-artifacts/evidence/1-2/` is the only new evidence-artifact location authorized by this story; include every created evidence file in the actual file list. Do not commit unsanitized machine-specific executable, editor-settings, or user-profile paths.

Expected updated runtime files are exactly the controller, player scene, and six polling state scripts listed above. Update project context only after the test contract exists. The implementation story itself will also receive evidence and its Dev Agent Record.

Expected unchanged files include:

- `project.godot` and `main.tscn`
- `scripts/debug_grapple_telemetry.gd` (documented developer-only F3 input boundary)
- `scripts/player_dead_state.gd`
- `scripts/player_attack_windup_state.gd`
- `scripts/player_attack_active_state.gd`
- `scripts/player_attack_recovery_state.gd`
- Tutorial scenes/content, existing UIDs, input bindings, dependency files, and all traversal tuning

The architecture's directory sketch used the illustrative name `player_command.gd`, while the canonical project type is `PlayerCommandFrame` and the project naming rule maps class names to snake-case filenames. Use `player_command_frame.gd`; this is an intentional naming clarification, not an architecture deviation.

### Architecture Compliance and Guardrails

- Use typed GDScript compatible with Godot 4.7.2, Forward+, and Jolt. Treat warnings as defects when they indicate an unsafe type or lifecycle assumption.
- Prefer typed enums/result objects to stringly typed status or raw dictionaries. A compact integer bitmask behind typed action-query methods is acceptable.
- Preserve scene/resource UID continuity. Add only the new external-resource and child-node entries needed for the source; do not resave unrelated scene data.
- The command frame is the sole gameplay input fact for its step. A convenience method such as `get_movement_input()` may remain temporarily to protect Story 1.1, but it must delegate to the current frame.
- Do not make the rendered camera transform authoritative. Existing grapple hit resolution may remain otherwise unchanged, but its ray direction must originate from the command's committed aim.
- Do not change current grapple target eligibility (`StaticBody3D`), max range, acceleration/decay, velocity cap, stored point, wall rules, movement acceleration/deceleration, jump values, or attack timing.
- Do not centralize movement commits. Existing state-owned `move_and_slide()` calls are protected debt for Story 1.3.
- Keep `debug_grapple_telemetry.gd` isolated as a development input boundary. Do not route F3 into player commands.
- Do not add silent fallback logic. A safe inactive player with a precise development error is preferable to a partially initialized player polling globals.

### Aim and Camera Guidance

- Use `InputEventMouseMotion.screen_relative` for captured aim because it is unscaled by content scaling; do not multiply it by `delta`. Keep Godot's default accumulated-input behavior unless measured evidence justifies a separately reviewed high-polling change.
- Feed every received motion contribution into one bounded accumulator and consume it once when producing canonical orientation. Do not retain `InputEvent` objects.
- Preserve trackpad pan as a supported aim path. Its current net contribution is `event.delta * trackpad_pan_sensitivity` before yaw/pitch signs and clamping; apply that value exactly once rather than multiplying and dividing through mouse sensitivity.
- Preserve the current pitch bounds from the player scene/controller (including its effective `pitch_max = 70` override) and current sensitivity behavior. Inject them into the source rather than duplicating hard-coded alternatives.
- Initialize yaw from the player body's current orientation and pitch from `CameraPivot`. Use the same canonical values for presentation and command aim, but do not reconstruct aim from the collision-adjusted `Camera3D` transform.
- Test orientation with tolerances and invariants: sign/direction, once-only contribution, clamped range, and normalized aim. Avoid brittle exact-float expectations.

### Testing and Verification Requirements

- Required framework: the locally present, pinned GUT 9.7.1 under `addons/gut`. This story establishes a focused suite; it does not install GUT, upgrade it, create CI, or claim a project-wide coverage percentage.
- Run focused tests recursively under `tests/player/input/`. Record the exact resolved Godot version, GUT version, command, exit code, test count, and pass/fail result in the Dev Agent Record or linked evidence.
- For same-step sharing, assert object identity where possible, not just equal values. Also prove each subsequent step returns a different immutable object with the correct step number.
- Use deterministic numbered-step tests rather than sleeps or real frame scheduling. The 60/120 diagnostic is about capture cadence and cardinality; it must not persistently change project settings.
- Test semantic action aggregation, not merely one key. Attack must cover both left mouse and `F` behavior; grapple remains right mouse; jump remains `Space`.
- Keep input-source tests narrow. Use synthetic events or a small injected adapter; do not instantiate the full level or mock deep physics/camera internals to test edge latching.
- After unit tests, use the pinned engine for a parse/load smoke and an interactive `main.tscn` traversal check. Automated source tests do not replace Story 1.1's behavior comparison.
- Run a scoped search such as:

  ```powershell
  rtk rg -n "Input\.(is_action_|get_vector|get_axis|get_action_)|event\.is_action_" scripts/player_controller.gd scripts/player_*_state.gd game/player
  ```

  Classify rather than blindly delete matches. Production gameplay polling must be gone; the designated source and explicit developer/application boundaries are allowed.
- Run `git diff --check` and inspect the complete scoped and unscoped status. Preserve concurrent/user changes and do not clean/reset the worktree.

### Previous Story Intelligence

Story 1.1 reached `done` on 2026-09-10 after every review finding received a patch, explicit user-approved dismissal, or defer disposition. It is the accepted AC 13 baseline, with the recorded limitations below.

- Pinned Godot `4.7.2.stable.official.ed1daf0bf` successfully imported, loaded headlessly, launched interactively, and exercised the build.
- Active-play telemetry passed, while process exit emitted pre-existing node-path/resource/RID/ObjectDB/texture diagnostics now classified as non-blocking `BASE-006`. Compare active-play and shutdown output separately so this story neither hides baseline noise nor reports it as a new regression without evidence.
- `res://main.tscn` passed `W/A/S/D` ground/air behavior, `Space` jump, right-mouse grapple acquire/hold/release, post-release momentum, wall run/stick/jump, and landing recovery under the accepted evidence procedure.
- Wall-run, wall-stick, and related wall-jump rows are specifically `BASE-007` fixture-only state-machine observations; they do not prove reliable normal player-controlled wall entry. Preserve the observed state behavior, but retain this limitation in comparisons.
- Left mouse or `F` attacks; `Esc` releases the cursor; a mouse press recaptures it.
- Fall/death recovery were not currently exercisable and are tracked as `BASE-004`/`BASE-005`; they are not Story 1.2 defects unless the accepted baseline changes.
- The project effectively runs at 60 physics ticks but interpolation is currently false (`BASE-002`). Preserve and report this; do not edit `project.godot`.
- `addons/` is ignored/untracked. GUT 9.7.1 exists locally but is not reproducible from Git (`BASE-001`). Do not disguise this issue by vendoring/upgrading the dependency here.
- There was no automated suite before Story 1.2. Only update that statement after the focused tests have actually been added and passed.
- Serialize Godot import/headless/interactive runs; concurrent processes can contend for the same import cache.
- Story 1.1 repeatability is accepted as `PASS WITH LIMITATIONS` because the exact runtime wall fixture is not fully retained. Story 1.2 must record a precise pre/post procedure for every new claim rather than overstate deterministic replay.
- Refresh this intelligence if Story 1.1 changes again after this story's authoring cut.

### Git Intelligence

- Story authoring inspected recent history through `e53d33e`, `9de5c82`, `317590f`, `c8e7c0c`, and `5a1ffeb`. Story 1.1 and its evidence were introduced by `9de5c82`.
- Commit `f6a51f8` split the player into movement and attack HSMs and distributed input polling into states. Migrate the polling while preserving that two-HSM structure.
- Commit `7b1675a` carries grapple jerk/tuning/telemetry work. Do not regress its limits, momentum, cursor, or telemetry behavior.
- Commit `24b0246` carries player-scene identity/tuning details, including the effective pitch maximum. Preserve UIDs, node IDs, and overrides.
- Commit `aded08a` established left-click/`F` attack behavior and dead gating. Preserve both bindings and owner-side gating.
- Recent documentation commits bundled multiple artifact changes, so implementation must keep a precise scoped file list and must not treat unrelated working-tree changes as part of this story.
- The authoring worktree contained only the generated bounded context-pack index before this story/sprint update. Re-capture start status at implementation time; do not assume a clean checkout.
- Story 1.1's completed review disposition and `_bmad-output/implementation-artifacts/deferred-work.md` appeared concurrently after Story 1.2 drafting began. They are user-owned/outside this story's edits; preserve them. The final `done` baseline and its limitations are reflected above.

### Latest Technical Information

- The project pins Godot 4.7.2; newer-version availability is not an upgrade signal. Implement and verify against the pinned runtime.
- Godot 4.7 documents `InputEventMouseMotion.screen_relative` as the unscaled captured-mouse value and notes that input events are accumulated by default. This supports event accumulation without delta scaling and retaining the default accumulation mode.
- Godot 4.7 action-event APIs ignore key echo by default unless `allow_echo` is requested; preserve that behavior explicitly in the input boundary.
- Godot 4.7's `Input.get_vector` contract limits the vector length to one and uses a circular deadzone; preserve those semantics instead of reconstructing a square diagonal from four booleans.
- Godot 4.7 exposes window focus signals such as `focus_exited`; use the owning window's lifecycle rather than polling focus ad hoc.
- GUT 9.7.x is the Godot 4.7 compatibility line: 9.7.0 introduced the compatibility update and the locally pinned 9.7.1 added follow-up parser/double fixes. Verify the checked-out 9.7.1 CLI help and do not upgrade.

Primary references:

- [Godot 4.7 InputEventMouseMotion](https://docs.godotengine.org/en/4.7/classes/class_inputeventmousemotion.html)
- [Godot 4.7 InputEvent](https://docs.godotengine.org/en/4.7/classes/class_inputevent.html)
- [Godot 4.7 Input](https://docs.godotengine.org/en/4.7/classes/class_input.html)
- [Godot 4.7 Window](https://docs.godotengine.org/en/4.7/classes/class_window.html)
- [GUT 9.7.0 release](https://github.com/bitwes/Gut/releases/tag/v9.7.0)
- [GUT 9.7.1 release](https://github.com/bitwes/Gut/releases/tag/v9.7.1)

### Project Context Rules

- Respect `_bmad-output/project-context.md` as the project-wide implementation contract: Godot 4.7.2, typed GDScript, Forward+, Jolt, fixed-step authoritative gameplay, deterministic tests, preserved UIDs, and no speculative infrastructure.
- Follow snake_case files/functions/variables, PascalCase `class_name` types, and `&"StringName"` identifiers where the surrounding API uses StringNames.
- Prefer explicit node dependencies and typed initialization results. Never add a broad `get_node()` search, silent default, untyped dictionary contract, or input singleton.
- Keep simulation/gameplay state out of render callbacks. Render code may read the latest canonical orientation; only the physics-step frame is authoritative to gameplay.
- Preserve existing public APIs where practical. Where a compatibility helper remains, make it a thin frame-backed adapter and identify it for later cleanup rather than duplicating state.
- Keep tests deterministic, independent, and focused; avoid sleeps, exact derived floats, private paths, and deeply mocked physics.
- Update project context only when implementation has established and verified the new stable GUT command/location. Do not rewrite unrelated context.

### References

Bounded authoring context pack:

- `_bmad-output/.artifact-index/context-1-2.json` - resolver output for Story 1.2; six authoritative inputs, inventory valid, no resolver errors. The GDD's `needs-decisions` status is an acknowledged warning and does not block this already-scoped story.

Source artifact revision ledger used to author this story:

| Artifact ID | Path | SHA-256 | Used for |
| --- | --- | --- | --- |
| `grapplegame.epics.requirements` | `_bmad-output/planning-artifacts/epics/requirements.md` | `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b` | FR2-FR12 traceability and cross-cutting acceptance constraints |
| `grapplegame.epics.1` | `_bmad-output/planning-artifacts/epics/epic-01-overview.md` | `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168` | Epic objective, sequencing, and scope |
| `grapplegame.story.1.2` | `_bmad-output/planning-artifacts/epics/epic-01-story-02.md` | `74e5509f09323c99a22b4b58599a1e67efd9cad55e21e4bac28c1dfaa6579fd7` | Canonical Story 1.2 statement and acceptance criteria |
| `grapplegame.gdd` | `_bmad-output/planning-artifacts/gdd.md` | `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156` | Player experience, controls, feel, and out-of-scope boundaries |
| `grapplegame.architecture` | `_bmad-output/planning-artifacts/architecture.md` | `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080` | Command-frame, timing, aim, scene, testing, and migration contracts |
| `grapplegame.project-context` | `_bmad-output/project-context.md` | `924f967d83ac664c1352f27bb89ef91cef4d4ae765746d379c77cfe91eb608d9` | Repository-wide engine, coding, testing, and workflow rules |

The epic shards in this pack derive from canonical source SHA-256 `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`.

Additional implementation intelligence:

- [Source: `_bmad-output/implementation-artifacts/1-1-verify-and-protect-the-playable-traversal-baseline.md` - Status, Baseline Evidence Record, issues, smoke matrix, and Dev Agent Record]
- [Source: `scripts/player_controller.gd` - current input, HSM, movement, grapple, camera, attack, and death behavior]
- [Source: `scenes/player.tscn` - player node/resource identity, HSM topology, and effective tuning]
- [Source: `scripts/enemy_controller.gd` - manual LimboHSM fixed-step update precedent]
- [Source: `project.godot` - InputMap, launch path, engine features, renderer, and physics backend]
- [Source: `scripts/debug_grapple_telemetry.gd` - explicit developer-only input boundary]
- [Source: repository history for `f6a51f8`, `7b1675a`, `24b0246`, and `aded08a`]

### Story Completion Status

- Status set to `ready-for-dev`.
- Story key: `1-2-deliver-reliable-fixed-step-player-commands`.
- Epic 1 was already `in-progress`; no epic transition is required.
- Story 1.1 is `done` and supplies the accepted baseline; Task 1 still requires the implementation agent to pin the exact pre-change revision and limitations before touching runtime files.
- Ultimate context engine analysis completed - comprehensive developer guide created.

## Dev Agent Record

### Agent Model Used

OpenAI Codex (GPT-5)

### Implementation Plan

- RED: define deterministic command-frame and input-source tests for the immutable payload, semantic edge latching, focus/rearm behavior, aim accumulation, and initialization failures before changing the runtime controller.
- GREEN: add the bounded player input boundary, commit one frame per numbered physics step, route both player HSMs through the same snapshot, and migrate all current gameplay polling without changing traversal formulas or tuning.
- REFACTOR: preserve the existing scene identity and HSM transition graph, keep presentation orientation separate from authoritative aim, document the input boundary, and verify with the focused GUT suite plus pinned-engine load and traversal smoke evidence.

### Debug Log References

- `_bmad-output/implementation-artifacts/evidence/1-2/pre-change-oracle.md` — accepted Story 1.1 oracle, pre-change revision, controls, limitations, and planning revision check.
- `_bmad-output/implementation-artifacts/evidence/1-2/focused-gut.md` — canonical recursive GUT command, pinned versions, 21-test/677-assert result, and expected diagnostic classification.
- `_bmad-output/implementation-artifacts/evidence/1-2/pinned-load.md` — serialized pinned import scan and `res://main.tscn` load results, including shutdown-noise classification and the UI-surface limitation.
- `_bmad-output/implementation-artifacts/evidence/1-2/input-boundary-search.md` — direct-polling search and remaining-boundary classification.
- `_bmad-output/implementation-artifacts/evidence/1-2/preservation-audit.md` — diff check and protected-scene/tuning/concurrent-change audit.
- Focused test command: `rtk <operator-local path to Godot_v4.7.2-stable_win64_console.exe> --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit`.
- Pinned integration commands: `rtk <operator-local path to Godot_v4.7.2-stable_win64_console.exe> --headless --path . --import --quit-after 120` followed by `rtk <operator-local path to Godot_v4.7.2-stable_win64_console.exe> --headless --path . --quit-after 120`.

### Completion Notes List

- Task 1 complete before runtime edits: Story 1.1 is `done`; its accepted review dispositions, `PASS WITH LIMITATIONS` repeatability result, `BASE-006` shutdown classification, and `BASE-007` wall-fixture limitation were reviewed. The accepted evidence is under `_bmad-output/implementation-artifacts/evidence/1-1/`.
- Pre-change revision is `e53d33ea7b088a38cdd8923eb3b24d6a01d5a32b` on `main`; the complete starting worktree contains only the pre-existing planning/evidence paths recorded by `git status --short --untracked-files=all`, and no protected runtime file is dirty. The accepted pinned runtime is Godot `4.7.2.stable.official.ed1daf0bf`, with launch scene `res://main.tscn`, controls `W/A/S/D`, `Space`, right mouse grapple, left mouse/`F` attack, `Esc` release, and mouse-click recapture.
- Planning revision check passed: all six Story 1.2 context-pack SHA-256 values match the story ledger and `_bmad-output/.artifact-index/context-1-2.json`; inventory is valid with only the acknowledged scoped GDD warning.
- Implemented the immutable typed `PlayerCommandFrame`, bounded event-latching `PlayerInputSource`, canonical yaw/pitch and world-space aim, focus-loss/rearm semantics, cursor recapture suppression, and explicit per-step movement-before-attack HSM updates. All current gameplay consumers now read the committed frame; traversal formulas, tuning, and state transition structure remain intact.
- Added focused GUT coverage under `tests/player/input/`: the final pinned run passed 21/21 tests with 677 asserts. Expected invalid-step and invalid-initialization `push_error` messages were asserted by the suite.
- Pinned import/load verification passed with exit `0` for both the import scan and the main-scene run. The main scene loaded the new source and existing runtime scripts without active parse/resource/scene-load errors. Known editor/GUT shutdown leaks remain classified as non-blocking teardown diagnostics.
- Updated `_bmad-output/project-context.md` narrowly after the focused suite became real and passing, recording the stable test location and canonical command without asserting project-wide coverage.
- The current environment did not expose an interactive Godot GUI for a post-change replay. The accepted Story 1.1 smoke oracle, deterministic control/cursor tests, unchanged traversal audit, and pinned main-scene load were used for the equivalent baseline check; no manual visual smoke result is claimed.

### File List

- `_bmad-output/implementation-artifacts/1-2-deliver-reliable-fixed-step-player-commands.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `_bmad-output/project-context.md`
- `_bmad-output/implementation-artifacts/evidence/1-2/pre-change-oracle.md`
- `_bmad-output/implementation-artifacts/evidence/1-2/focused-gut.md`
- `_bmad-output/implementation-artifacts/evidence/1-2/pinned-load.md`
- `_bmad-output/implementation-artifacts/evidence/1-2/input-boundary-search.md`
- `_bmad-output/implementation-artifacts/evidence/1-2/preservation-audit.md`
- `game/player/input/player_command_frame.gd`
- `game/player/input/player_command_frame.gd.uid`
- `game/player/input/player_input_source.gd`
- `game/player/input/player_input_source.gd.uid`
- `scenes/player.tscn`
- `scripts/player_controller.gd`
- `scripts/player_grounded_state.gd`
- `scripts/player_airborne_state.gd`
- `scripts/player_grappling_state.gd`
- `scripts/player_wall_run_state.gd`
- `scripts/player_wall_stick_state.gd`
- `scripts/player_attack_ready_state.gd`
- `tests/player/input/test_player_command_frame.gd`
- `tests/player/input/test_player_command_frame.gd.uid`
- `tests/player/input/test_player_input_source.gd`
- `tests/player/input/test_player_input_source.gd.uid`
- `tests/player/input/test_player_controller_command_sequence.gd`
- `tests/player/input/test_player_controller_command_sequence.gd.uid`

### Change Log

- 2026-09-10 — Implemented the player-owned fixed-step command boundary and migrated the existing player HSM consumers.
- 2026-09-10 — Added deterministic command-frame/input-source tests and recorded pinned GUT and Godot load evidence.
- 2026-09-10 — Completed the Dev Agent Record and moved the story to `review`; no project commit was created.
