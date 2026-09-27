---
story_id: '1.10'
story_key: '1-10-complete-the-focused-traversal-validation-route'
baseline_commit: 'dbd3289349636b41e9a69d75e146e4ea8b27b273'
created: '2026-09-26'
---

# Story 1.10: Complete the Focused Traversal Validation Route

Status: in-progress

## Story

As a player,
I want a short, readable route that asks me to use the complete traversal vocabulary and provides recovery opportunities,
so that I can demonstrate movement mastery without ordinary mistakes forcing a full restart.

## Acceptance Criteria

1. **Create a focused route from primitive content**

   **Given** the current tree-grapple tutorial is disposable prototype content
   **When** the M0 validation route is created
   **Then** it may be recreated from scratch using simple geometry, lightweight markers, and the production player and traversal systems
   **And** no existing tutorial layout, lesson sequence, script, identifier, or scene dependency must be preserved
   **And** `res://main.tscn` remains a runnable launch path.

2. **Exercise the complete traversal vocabulary**

   **Given** the player starts the route
   **When** they progress from its start to its finish
   **Then** the route provides deliberate opportunities requiring ground movement, air steering, jumping, grapple acquisition, zip-pull, momentum-preserving grapple release, wall running, grapple-assisted wall sticking, wall jumping, and mistake recovery
   **And** completion does not depend on combat, damage, enemies, an encounter controller, rewards, or checkpoint infrastructure.

3. **Use production traversal contracts**

   **Given** the route needs a player, walls, grapple surfaces, and exceptional grapple targets
   **When** those elements are composed
   **Then** they use the production `PlayerCommandFrame`, motor, `ContactFrame`, grapple targeting, `GrappleAttachment`, and locomotion-state contracts from Stories 1.2–1.9
   **And** the route does not contain private movement calculations, duplicate physics queries, direct player-velocity writes, or route-specific copies of core traversal tuning.

4. **Demonstrate the true grapple boundary**

   **Given** the route includes near-range, boundary-range, and out-of-range grapple opportunities
   **When** the player aims, attaches, moves inward or tangentially, and attempts to move beyond the active boundary
   **Then** acquisition and attachment use the same validation `GrappleDefinition` with a 35-metre maximum
   **And** the route demonstrates that attachment distance does not become tether length, movement remains free inside the boundary, and only excess outward separation is constrained.

5. **Demonstrate a moving grapple target**

   **Given** the route includes one primitive moving or rotating `Grappleable3D` target
   **When** the player attaches to it
   **Then** the attachment follows the target-local hit position, responds to continuous target motion, and pulls the player only when its retreat makes the tether taut
   **And** the route provides a safe way to observe or recover from target invalidation or a configured severe discontinuity.

6. **Demonstrate wall traversal on representative geometry**

   **Given** the route includes supported non-flat walls, an oblique wall, and a stable corner or adjacent-face transition
   **When** the player uses wall running, wall sticking, and wall jumping
   **Then** authoritative wall classification and movement transitions remain stable
   **And** floor-like, ceiling-like, and otherwise unsupported surfaces do not behave as valid walls.

7. **Provide local mistake recovery**

   **Given** the player misses an intended grapple, releases early, loses a wall run, or undershoots a wall jump
   **When** they fall into the corresponding recovery area
   **Then** a lower route, reachable surface, grapple opportunity, or remaining movement option lets them return to the route without reloading the level
   **And** only leaving the deliberately bounded playable area may use the existing safe restart behavior
   **And** this does not introduce the production checkpoint or level-restart systems assigned to Epic 7.

8. **Communicate route affordances with minimal presentation**

   **Given** the player approaches a route challenge
   **When** the intended surface, target, movement direction, success state, or rejection state needs clarification
   **Then** primitive geometry, high-contrast materials, concise in-world labels or markers, and the existing authoritative grapple feedback make the relevant fact understandable
   **And** presentation observes production simulation results rather than defining success, target validity, or movement timing
   **And** this story does not define the production HUD reserved for Epic 7.

9. **Verify end-to-end traversal at both physics rates**

   **Given** the route's deterministic validation command source or automated scene test drives representative traversal sequences through real Godot/Jolt physics
   **When** the same scenarios run at shipping 60 Hz and diagnostic 120 Hz
   **Then** action durations, state-transition order, grapple-release velocity, maximum attachment distance, moving-anchor behavior, wall transitions, and final route outcomes remain equivalent within documented tolerances
   **And** assertions use elapsed seconds and tolerant physical comparisons rather than raw tick counts or exact floating-point equality.

10. **Capture repeatable M0 evidence**

    **Given** automated validation has passed
    **When** the route is manually completed at 60 Hz and sampled again at diagnostic 120 Hz
    **Then** the evidence records the engine version, repository revision and working-tree state, launch and test commands, route scene, physics rates, actions exercised, observed recovery attempts, results, tolerances, and relevant logs
    **And** no new parse, missing-resource, scene-load, runtime error, or gameplay-critical warning remains unexplained.

11. **Close the Epic 1 completion gate**

    **Given** Stories 1.1–1.10 are complete
    **When** the permanent contract suite, focused real-Jolt tests, route validation, launch-scene smoke test, retained UID/reference check, and working-tree review are performed
    **Then** the player can complete the focused route using the full traversal vocabulary, understand relevant success and failure states, and recover from ordinary mistakes
    **And** traversal is equivalent in real time at 60 Hz and 120 Hz within documented tolerances
    **And** the story has not added combat, hostile surface mechanics, the production encounter or checkpoint shell, final HUD, final art, final audio, or unrelated migration.

## Tasks / Subtasks

- [ ] **1. Establish the route baseline and protect existing work** (AC: 1, 3, 11)
  - [ ] Inspect the current Git diff/untracked files, active Godot scene, route candidates, reusable player scene, grapple definition, wall query profile, and editor diagnostics through Godot AI MCP before changing Godot content. Story 1.9 is marked done but its code/tests/evidence are still uncommitted; treat them as the implementation baseline, never reset or overwrite them.
  - [ ] Create a **separate** runnable `res://game/levels/content/traversal_validation/traversal_validation_route.tscn` with an instance of `res://scenes/player.tscn` (preserve UID `uid://u1u36ceuo8uj`). Keep `res://main.tscn` a working launch path and smoke it independently; do not confuse its enemy arena with this non-combat route. The generated `res://scenes/tree_grapple_tutorial.tscn` has no layout/lesson preservation obligation.
  - [ ] Record the route's launch instruction and bounded playable-space behavior. Do not require an AppRoot, LevelController, production goal/checkpoint, or a new global input action to play it.

- [ ] **2. Build a short, physically navigable challenge sequence** (AC: 2, 6, 7, 8)
  - [ ] Author start, finish, ground/jump-and-air-steering, near/far grapple-and-release, moving-anchor, supported oblique/corner wall-run, grapple-assisted wall-stick, and wall-jump spaces with primitive collision and readable silhouettes. Use actual dimensions, approach angles, camera sight lines, and reachable distances proved in Godot/Jolt; a successful intended path must genuinely exercise the complete vocabulary rather than walking around labeled demo objects. Record its action/state trace as proof.
  - [ ] Under **each** risky transition, provide an inspectable catch surface or lower return path with a reachable grapple/ground route. Test missed grapple, early release, lost run, short wall jump, and moving-target termination from the same live route without scene reload. Bound only true out-of-play falls for existing safe restart behavior; do not reset on ordinary misses or teleport over a challenge.
  - [ ] Place simple in-world labels/materials for valid targets, intended travel, invalid/out-of-range examples, recovery, and finish; use existing authoritative grapple targeting/rejection feedback for live validity. A route-local finish trigger may consume actual player arrival once and expose an observable success fact, but a sign, timer, debug command, or presentation node must not author completion.

- [ ] **3. Compose the existing traversal authority without route-specific movement** (AC: 3, 4, 5, 6)
  - [ ] Reuse `scenes/player.tscn`, its `PlayerInputSource`/`PlayerCommandFrame`, `PlayerMotor`, `PlayerContactProvider`/`ContactFrame`, LimboAI movement HSM, and `GrappleTargetResolver`/`GrappleController`/`GrappleAttachment`. Static eligible world geometry needs no `Grappleable3D`; collision eligibility uses `world_geometry` and existing query profiles. Do not add player-velocity/position writers, duplicate aim/wall rays, scene-specific grapple numbers, or scene-script state transitions.
  - [ ] Share the player's immutable `game/player/abilities/grapple/definitions/grapple_definition.tres` (`player.grapple.default`, 35 m) for acquisition and active boundary. Arrange a station with independently aimable near, around-35 m, and beyond-35 m examples **from the canonical query origin**, accounting for collision thickness, the first blocking ray hit, and the existing 0.005 m acceptance tolerance; observe distance in the published targeting/attachment snapshots, not from an editor gizmo alone. Exercise inside, inward, tangential, and outward attempts from a short attachment; preserve the existing movement-only-outward boundary resolution.
  - [ ] Give the moving collision body a **direct child named `Grappleable`** typed `Grappleable3D`, an explicit unique dotted `target_id`, and `AnchorMode.MOVING`. Advance its bounded transform in physics seconds (or Godot physics-aware animation), and supply target velocity consistently or use the existing per-step finite-difference sample. Keep the mandatory path continuous below the configured 50/250 m/s tolerance/threshold; stage an **optional**, clearly recoverable invalidation/discontinuity demonstration via the target's own API, with typed termination and no repeated terminal event. The target never moves or commands the player.
  - [ ] Use the authored `WallProbe` and shared wall relationship for non-flat/oblique/corner surfaces; physically separate unsupported sloped/floor/ceiling examples. Wall-run entry still needs along-wall speed and input alignment; wall-stick still needs a held valid grapple and supported contact. No silent tolerance retuning to make a bad layout pass.

- [ ] **4. Verify the actual route with real Jolt at both rates** (AC: 2–9, 11)
  - [ ] Add focused `GutTest` scene/integration coverage under `res://tests/levels/` or `res://tests/integration/` that loads the **new route**, uses the real player and injected production command frames through `PlayerInputSource`'s existing test seam, and verifies actual progress and return paths. Reuse relevant existing 1.6–1.9 fixture idioms rather than copying their entire contract matrices or writing a second player movement system.
  - [ ] At 60 and 120 Hz, assert a successful route action trace includes ground/air steering, jump, grapple acquisition/zip-pull/release, wall run/stick/jump and a real finish; verify the seconds-based action windows, retained grapple-release velocity, accepted/rejected targeting near the true 35 m edge, active-distance cap/inward/tangent freedom, moving target-local hit following/relative carry and typed invalidation, supported corner/oblique stability versus invalid surfaces, and recovery on an ordinary miss. Record measurable rate-pair tolerances in the evidence; verify no second motor commit and no route-specific query/velocity authority. Restore `Engine.physics_ticks_per_second` even on test failure; do not persist 120 Hz in `project.godot`.
  - [ ] Run focused new GUT suites and the pinned **recursive** `-gdir=res://tests/player -ginclude_subdirs -gexit` gate (which includes the 1.9 locomotion suites); run the new route suites separately if placed outside `tests/player`. Distinguish CLI GUT coverage from MCP-native `McpTestSuite` discovery, which only sees direct `res://tests/test_*.gd` scripts.

- [ ] **5. Perform MCP-backed play and record the M0 gate** (AC: 7–11)
  - [ ] Through Godot AI MCP, rescan/reload route resources and scripts, inspect the new scene, launch **that** scene, inspect runtime player/target/wall/finish nodes, and run representative command/input and read-only diagnostic smoke checks. Then launch `res://main.tscn` separately. Capture relevant editor and current-run game logs and a visual check when supported; distinguish scripted fixtures/input delivery from an observed manual route completion.
  - [ ] Manually complete the route at 60 Hz and sample it at 120 Hz; observe at least one actual recovery from each of the four ordinary-miss classes, target invalidation, and the success/failure cues. Record whether a human playtest was actually performed; MCP automation does not establish human comprehension or feel. Capture engine/plugin versions, commit + dirty-tree inventory, exact commands/scene/rate, trajectories or state traces, measured tolerances, screenshots only if actually observed, UID/reference checks, and triaged new versus historical diagnostics in `_bmad-output/implementation-artifacts/evidence/1-10/` and the Dev Agent Record.
  - [ ] Measure the unresolved **OD-009** jump apex/airtime, coyote/buffer behavior, wall entry tolerance, and grapple-gravity feel from this route and request/record the required design approval before declaring **M0 acceptance**. Story readiness is not milestone acceptance: the canonical GDD is `needs-decisions` and explicitly says no milestone is acceptance-ready. Close Epic 1 only when the story ACs, the sibling-story state, decision gate, GUT + MCP gates, launch smoke, retained references, and working-tree review are all evidenced; otherwise record which gate is pending, without inventing a pass.

## Dev Notes

### Developer Context and Implementation Boundaries

- **Authoritative scope:** Epic 1 delivers FR2–FR12; this story integrates the previous contracts into the focused M0 route (FR12) and validates FR5 recovery, FR9 boundary, FR10 moving target, and FR11 wall traversal together. The 11 acceptance criteria above are copied from the canonical story shard. Design intent: short readable progression with one challenge at a time, recovery on ordinary failure, no combat gate. [Source: `_bmad-output/planning-artifacts/epics/epic-01-story-10.md`; `_bmad-output/planning-artifacts/epics/epic-01-overview.md`; `_bmad-output/planning-artifacts/gdd.md` §Action-Platformer Design, §Difficulty Curve]
- **Design measurements:** GDD validation baselines are 10 m/s ground/air, ground jump 4.5 m/s upward, wall-run ≥1 m/s horizontal with wall within 0.8 m and approximately 12° of vertical, wall-run acceleration 4 m/s², wall jump 8 m/s outward + 5.5 m/s upward, grapple 35 m / 48→8 m/s² pull / 22 m/s cap. These are **behavioral baselines**, not per-scene tuning knobs; build reachable geometry against the instantiated player and iterate with measured evidence. OD-009 remains the design approval gate for jump/forgiveness, wall tolerance, and grapple-gravity feel. [Source: `_bmad-output/planning-artifacts/gdd.md` §Movement Feel Table, §Open Decisions]
- **Traversal pipeline:** one immutable `PlayerCommandFrame` per step → one movement-HSM update → semantic motor phases → exactly one `PlayerMotor` velocity assignment and `move_and_slide()` → one committed `ContactFrame` → bounded post-commit routing; grapple samples the active moving anchor once per step. States use shared contact, canonical aim, and motor submissions. Wall-run continuity (`INITIAL`/`PRESERVED`/`SWITCHED`/`LOST`) and grapple-assisted wall-stick were hardened in 1.9; use them, do not create scene-specific alternate policy. [Source: `_bmad-output/planning-artifacts/architecture.md` §Motion Authority and Effect Precedence, §Collision Matrix and Query Profiles, §Cross-System Contract Specifications; prior story 1.9 §Dev Notes/Completion Notes]
- **Grapple constraints:** first blocking crosshair hit wins; a rejected hit cannot be pierced by a target behind it. A stationary eligible body uses the default response; exceptional moving bodies have the direct-child `Grappleable` component with explicit ID/anchor mode. `GrappleDefinition.max_grapple_length_m` is the sole acquisition and active boundary; attachment distance is not rope length. Moving attachment preserves the local hit, samples target motion continuously, and terminates once on invalidation/destruction/scope/severe discontinuity. Keep the shared Resource immutable. [Source: `_bmad-output/planning-artifacts/architecture.md` §Grapple target contract; `game/shared/contracts/grappleable_3d.gd`; `game/player/abilities/grapple/grapple_attachment.gd`]
- **Wall geometry:** existing `game/shared/physics/wall_probe.tres` uses `world_geometry`, 0.8 m probe/sweep reach and 0.12 m shape thickness; 1.9 recorded a 25°/0.2 m/two-step continuity policy in `WallProbe` and a 0.2 max absolute normal-Y. The provider retains its previous wall during camera rotation using the same query budget. Use substantial box/surface thickness and real Jolt tests across corners; don't classify walls from `is_on_wall()` in route code. Godot 4.7's built-in Jolt collision margins can round normals at small shapes, so test actual authored collision. [Source: `game/shared/physics/wall_probe.tres`; prior story 1.9 §Wall Relationship; https://docs.godotengine.org/en/4.7/tutorials/physics/using_jolt_physics.html]
- **Minimal result/presentation:** the route can report a once-only finish from a physical goal trigger; in-world signs and existing grapple marker/telemetry only present the state. Make recovery geometry physically accessible and keep the player in the same route instance. The separate production `LevelObjective`, checkpoints, level restart, HUD, and AppRoot are later work, not a prerequisite. [Source: `_bmad-output/planning-artifacts/epics/epic-01-story-10.md` AC 2, 7, 8; `_bmad-output/planning-artifacts/architecture.md` §Scene Boundaries and Asset Loading, §HUD and UI]

### Current-State Update Map / Project Structure Notes

- **NEW (recommended owning location):** `game/levels/content/traversal_validation/traversal_validation_route.tscn` and only the smallest route-owned target-motion/finish scripts or materials it actually needs, colocated there; simple static meshes/colliders can be authored directly in the scene. New `.gd` scripts get `.gd.uid` sidecars via Godot. Tests: `tests/levels/test_traversal_validation_route.gd` and, only if needed, a focused `tests/integration/` scene test; evidence: `_bmad-output/implementation-artifacts/evidence/1-10/`. The legacy target structure names `game/levels/content/grapple_tutorial/` for **M5 tutorial validation**; this is a distinct M0 validation route, not an M5 lesson controller. [Source: `_bmad-output/planning-artifacts/architecture.md` §Project Structure, §Feature and Milestone Mapping]
- **Current `main.tscn` (read completely, smoke-only):** 300×300 collision floor, nine building instances, production player, three enemies, sun/environment; no instance of the tutorial or route. `project.godot` sets `run/main_scene="res://main.tscn"`, Jolt, interpolation, and named `world_geometry` collision layer. Keep launch healthy while launching the route explicitly; changing the main arena is not needed to expose the validation scene. Do not silently change `project.godot` physics/interpolation or bootstrap ownership. [Source: `main.tscn`; `project.godot`]
- **Current `scenes/tree_grapple_tutorial.tscn` and `scripts/levels/tree_grapple_tutorial.gd` (read completely, legacy alternative):** the scene contains only an `@tool` script; on editor/runtime `_ready` it regenerates a `Generated` subtree (MCP observed 57 direct children) with a seven-stage tree route and its own player spawn/preview camera. It currently assigns a scene-specific `grapple_gravity_scale=0.65`. Its layout/IDs/lessons are disposable per AC 1; avoid using this scene as the validation oracle or carrying its scalar override into the new route. If repurposing it instead of the recommended new route, re-read the entire 453-line script, remove obsolete generated-content dependencies deliberately, and verify the resulting UIDs/references in Godot. [Source: `scenes/tree_grapple_tutorial.tscn`; `scripts/levels/tree_grapple_tutorial.gd`]
- **Current `scenes/player.tscn` (read completely, consume-only):** UID `uid://u1u36ceuo8uj`, production `PlayerInputSource`, `PlayerMotor` with ground/wall profiles, two LimboAI HSMs, existing grapple marker/telemetry, default `grapple_definition.tres` and occlusion profile. Instance this scene; do not duplicate controller/scalars into the level or change its scene UID. `scripts/player_controller.gd` is the established coordinator in legacy `scripts/`; Story 1.9 review changes to it and `player_wall_run_state.gd`/`player_wall_stick_state.gd` plus `player_contact_provider.gd` remain uncommitted. If a real route blocker necessitates a production change, first reproduce it in a focused regression test, inspect the full affected script through Godot AI MCP, preserve its established contracts, and document the exception. [Source: `scenes/player.tscn`; `_bmad-output/implementation-artifacts/1-9-integrate-wall-traversal-and-mistake-recovery.md` §Completion Notes]
- **Existing regression seams:** `tests/player/grapple/test_grapple_targeting_integration.gd` (first hit, exact range, feedback), `test_grapple_boundary_integration.gd` (35 m constraint/release/60–120 comparison), `test_grapple_moving_target_integration.gd` (local hit/retreat/invalidation), `tests/player/locomotion/test_wall_traversal_integration.gd` (corner, stick, missed recovery, dual rate) already test the individual mechanics with the real player and Jolt. New route tests must show **their composition in the authored route** rather than mirror those suites. [Source: named tests; 1.9 evidence/verification.md]
- **Preservation:** incremental Godot-aware scene/resource edits, retained UIDs and dependencies, no bulk migration. `_bmad-output/implementation-artifacts/spec-grapple-visual-interpolation-reset.md` is frozen human-approved intent: any proposed change to motor/contact/targeting or project-wide interpolation in that fix's scope requires asking first; the route should use existing presentation rather than changing its rope lifecycle. [Source: `_bmad-output/project-context.md` §Code Organization Rules; frozen spec]

### Previous Story / Git Intelligence

- Story 1.9 is marked `done`, although its story document, regression suites, evidence, and four modified traversal scripts were **uncommitted at authoring**. Its recorded final **CLI/GUT** gate was 214/214 player tests and 10,330 assertions at 60/120 representative rates; its **Godot AI MCP** gate separately observed real wall-run/stick, yaw preservation, wall-switch exit, and no stale lost-wall jump impulse. Those are **predecessor-reported results**, not tests rerun or runtime outcomes observed for 1.10. Its own scope explicitly deferred building the authored route to this story. [Source: prior story 1.9 §Dev Agent Record and `evidence/1-9/verification.md`; `git status --short` at authoring]
- The last five commits are `dbd3289` (1.8 review fixes), `9335764` (1.7 completion / 1.8 implementation), `db421ea` (1.6 status), `1bab424` (1.6 review fixes), and `5a3bfed` (1.6 implementation). Current HEAD remains `dbd3289349636b41e9a69d75e146e4ea8b27b273`; do not claim the uncommitted 1.9 files are part of that commit. Before implementing, recheck the tree and establish the precise baseline. [Source: `git log -5`, `git status --short`, prior story 1.9]
- 1.4/1.5 still appear `review` in the sprint ledger; do not infer the whole Epic is `done` from 1.9's status or from green tests alone. OD-009 currently blocks **M0 acceptance** even when a route passes locally. [Source: `_bmad-output/implementation-artifacts/sprint-status.yaml`; GDD §Document Status/§Open Decisions]

### Testing and Evidence Requirements

- **Canonical GUT/CLI gate:** pin `Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit`; run new route suites separately if outside `tests/player`, plus relevant focused Jolt suites. Also check pinned import/scene load, retained UID/reference integrity and `git diff --check`. Report exit codes, counts, step rate, baseline, and known versus new diagnostics; no manual or gameplay pass is implied by a doc-only story authoring pass. [Source: `AGENTS.md` §Dual test-harness rule; prior story 1.9 §Testing Requirements]
- **Live Godot AI MCP gate:** before implementation list session/editor state/logs and inspect affected scene/script/resource; during Godot operations use MCP scene/resource tooling, scan/reload scripts after edits; after edits run MCP scene + runtime smoke, read editor/game logs, and confirm ready. MCP `test_run` discovers only direct top-level `tests/test_*.gd` `McpTestSuite` scripts: its result is **not** the recursive GUT suite. A small route MCP adapter is optional; actual route gameplay observation is required. Record session ID and distinct MCP-observed versus CLI/GUT results in the Dev Agent Record. [Source: `AGENTS.md` §Godot AI MCP requirement/§Dual test-harness rule]
- **Rate and human evidence:** use delta seconds at both rates, identical authored inputs/geometry, documented tolerances for state order, elapsed action times, velocity, attachment distance and route outcome; no exact float/tick equality. A manual 60 Hz completion and diagnostic 120 Hz sample with recovery and comprehension notes is separate evidence from automated scripts. Official Godot 4.7 documents `Engine.physics_ticks_per_second` as fixed iterations/sec, default 60, and notes CPU cost/maximum steps per rendered frame at 120; keep 120 test-scoped. [Source: architecture §Simulation Timing and Physics, §Lean AI-First Verification; https://docs.godotengine.org/en/4.7/classes/class_engine.html#class-engine-property-physics-ticks-per-second]
- **Starting comparison thresholds from predecessor fixtures (confirm against this route's geometry before claiming equivalence):** identical named state/terminal sequence and finish outcome; maximum active grapple distance ≤ 35.05 m (`test_grapple_moving_target_integration.gd`); 60/120 grapple-release speed difference ≤ 0.5 m/s and corresponding action duration difference ≤ 0.05 s (`test_grapple_boundary_integration.gd`); moving-anchor carry-rate difference ≤ 0.35 m/s and first boundary arrival within 0.1 s (`test_grapple_moving_target_integration.gd`); wall-run tangential speed ≤ 0.05 m/s difference, wall-jump launch ≤ 0.10 m/s difference, corner-direction dot difference ≤ 0.05, and wall-loss timing within 0.04 s (`evidence/1-9/verification.md`). Record measured 1.10 route values and justify any relaxed threshold explicitly; these are comparison targets, not substitute assertions for route completion/recovery.
- **Version policy:** pinned live editor reports Godot 4.7.2-stable (official), Jolt is selected in `project.godot`, GUT 9.7.1 and vendored LimboAI 1.8.1 remain in use; Godot 4.7.2 stable is listed in the official release archive. Planning text records Godot AI 3.2.4 while the active MCP plugin/server reports **4.0.4**; use the connected tools as observed and record the discrepancy, not an incidental dependency upgrade. No new libraries are required. [Source: architecture §Version Policy/§Existing Engine Extensions; `project.godot`; https://godotengine.org/download/archive/4.7.2-stable/; MCP preflight]

### Project Context Rules

- Follow `_bmad-output/project-context.md`: typed GDScript, 60 Hz fixed physics + interpolation; simulation only in `_physics_process(delta)`; immutable typed Resource tuning with stable dotted IDs; one PlayerMotor commit; one shared `ContactFrame`; command frames as the only input boundary; physics profiles and named collision layers; owner-local transient state; bounded/read-only diagnostics; `snake_case` files and functions, `PascalCase` scene nodes/classes; no global gameplay store or universal event bus.
- Keep scene assets with the owning level under `game/levels/content/`; tests mirror the runtime domain. Use Jolt/swept or velocity-aware collision and tolerant comparisons; do not require final assets, audio, HUD, terrain, Phantom Camera, encounter/reward scaffolding, or a broad framework just to prove this route. Source: `_bmad-output/project-context.md` §§Critical Implementation Rules, Code Organization Rules, Testing Rules, Critical Don't-Miss Rules.

### Story-Authoring Godot AI MCP Evidence (read-only; not implementation validation)

- Session `testgame@e362124f09f388c2`: `session_manage(list)` found one active project session, Godot **4.7.2-stable**, plugin/server **4.0.4**, ready/stopped on `res://scenes/player.tscn`; `editor_state` confirmed stopped and ready. `scene_get_hierarchy` and `script_manage(find_symbols, player_controller.gd)` found player motor/input and both HSMs and the wall/grapple policy surface.
- `scene_open(main.tscn)` + `scene_get_hierarchy` confirmed the separate enemy arena and production player. `resource_manage(load, grapple_definition.tres)` confirmed `player.grapple.default`, `max_grapple_length_m=35`, `acquisition_tolerance_m=0.005`, immutable query profile and 50/250 m/s moving-anchor tolerances. `script_manage(find_symbols, tree_grapple_tutorial.gd)` + `scene_open(tree_grapple_tutorial.tscn)` + `scene_get_hierarchy`/`node_get_properties` confirmed `@tool`-generated tutorial layout and root script. No Godot source, scene, or resource was edited by this authoring pass.
- `logs_read(source="editor")` reported a retained 128-entry history including prior `player_contact_provider.gd` parser diagnostics and MCP grapple test placeholder errors; the previous story's final GUT/MCP evidence reports no new diagnostics after editor cursor 117. This pass has **not** rerun 1.9 tests, dated those log entries, or attributed them to 1.10. Fresh post-edit scan, cursor-based log check, route run, and current-run game log are required during implementation.
- **Post-authoring editor check (documentation edits only):** `filesystem_manage(scan)` settled with **128** global classes and delta **0**; `scene_open(res://scenes/player.tscn)` restored the original editor scene; `scene_get_hierarchy` again found `PlayerMotor`, `PlayerInputSource`, `MovementHSM`, and the grapple marker; `resource_manage(load)` still read `max_grapple_length_m=35`; `logs_read(source="editor", since_cursor=117)` returned **zero new entries**; `editor_state` reported ready/stopped on the player scene. No route was created or run during story authoring, and no GUT/CLI gameplay gate was run for this document/status change.

### References / Source References and Artifact Ledger

Resolver `_bmad-output/.artifact-index/context-1-10.json`: `inventory_valid=true`, six exact files; no optional UX or decision-log files in this bounded pack. GDD warning permits `needs-decisions` for this scoped Epic 1 story but does **not** approve M0 acceptance. Canonical requirement set: FR2–FR12; additional relevant NFR3–NFR7, NFR13, NFR19–NFR23. [Source: bounded context pack; `_bmad-output/planning-artifacts/epics/requirements.md`]

| Artifact ID | Canonical path | SHA-256 revision used |
|---|---|---|
| `grapplegame.epics.requirements` | `_bmad-output/planning-artifacts/epics/requirements.md` | `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b` |
| `grapplegame.epics.1` | `_bmad-output/planning-artifacts/epics/epic-01-overview.md` | `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168` |
| `grapplegame.story.1.10` | `_bmad-output/planning-artifacts/epics/epic-01-story-10.md` | `4b5bebc10cde280f1f8ee1daaed19f17cf50957dce37c4697bffc8d9c7895862` |
| `grapplegame.gdd` | `_bmad-output/planning-artifacts/gdd.md` | `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156` |
| `grapplegame.architecture` | `_bmad-output/planning-artifacts/architecture.md` | `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080` |
| `grapplegame.project-context` | `_bmad-output/project-context.md` | `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97` |

- Epic package manifest revision in sprint ledger: `8a0a51a1d4915b4aa75a7f96a427d03200a2fe0b4538ac061c9ab19afe045d15`; source digest `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`. Optional `grapplegame.decision-log` revision `01454eb5eadbeb60cffe4508fcae8336cfb4bc8dd14c19230964c28a5fb72a00` appears in canonical frontmatter but **was not loaded** by this bounded pack.

### Story Completion Status

Status: **ready-for-dev**. Ultimate context engine analysis completed - comprehensive developer guide created. Story 1.10 is specified for implementation; no route, GUT result, human completion, or M0 milestone approval is claimed by authoring this file.

## Dev Agent Record

### Agent Model Used

GPT-6 Sol (OpenCode) — story authoring only.

### Debug Log References

- Authoring MCP session `testgame@e362124f09f388c2`: preflight, live scene/resource/script reads, settled filesystem scan, player-scene recheck, editor cursor 117→117, ready/stopped; see §Story-Authoring Godot AI MCP Evidence. `rtk git diff --check` passed for the tracked working tree. Implementation agent fills in fresh MCP session/operations, CLI test results, gameplay traces, and diagnostics here.
- Implementation continuation (2026-09-26), same MCP session `testgame@e362124f09f388c2`: listed the active editor; observed Godot 4.7.2/plugin 4.0.4, route scene loaded, ready/stopped; inspected route hierarchy, `player_wall_stick_state.gd`, oblique wall properties, and editor diagnostics (historical parser entries; cursor 119→119, zero new). MCP changed the oblique wall and its collision/visual sizes to investigate the wall-switch failure, then restored the original position `(55, 3.8, -0.65)` and 24×7.6×0.3 dimensions and saved. No MCP runtime or visual completion was observed during this continuation.
- CLI/GUT (separate from MCP): pinned Godot 4.7.2 console via `rtk`, focused `-gtest=res://tests/levels/test_traversal_validation_route.gd -gunit_test_name=one_unbroken -gexit` remained **0/1 passed** across command-timing and geometry experiments. At 60 Hz, wall stick began on `ContactFrame.ContinuityAction.SWITCHED` (3), with `has_wall_contact=true` but `has_supported_wall_contact=false`, leading to `STATE_CANCELLATION` (4) and no wall-jump impulse. Shortening/repositioning the oblique wall did not resolve this and also lost stick at 120 Hz. The unsuccessful experimental edits were restored; the original uninterrupted test remains pending, and full GUT/MCP gates, human playtest and OD-009 approval are not claimed. Workflow halted after consecutive failed implementation attempts; story remains in progress.
- **Wall-stick cause investigation (2026-09-26; diagnosis only):** `_bmad-output/implementation-artifacts/investigations/route-wall-stick-switch-investigation.md` records graded 60/120 Hz evidence. A temporary read-only candidate trace in the CLI/GUT route fixture found consecutive 60 Hz steps 362→363 and 120 Hz steps 721→722: the selected `ObliqueWall` sweep hit changes to a `BODY_FACT` at the player origin; both selected normals remain `(-0.173648, 0, 0.984808)` with empty authored identity. Selected points move **1.0123/1.0077 m**, versus the production 0.2 m continuity limit, whereas player step travel is only ~0.168/~0.085 m. **Confirmed:** the fact has no collider RID, and `player_contact_provider.gd` constructs its point from `_body.global_position`, ranks it ahead of the sweep hit and calls the resulting comparison `SWITCHED`. **Deduced:** it belongs to the same `ObliqueWall` face because same-step committed-collision and sweep candidates with the identical normal map to that body; the `BODY_FACT` itself is not directly body-identified. The post-commit stick entry accepts this frame, but the next pre-commit supported-contact gate reads the previous `SWITCHED` frame and cancels before jump; that next step's `PRESERVED` commit is too late. The trace instrument and temporary `[60, 120]` loop were removed; `tests/levels/test_traversal_validation_route.gd:340-501` again uses `[60]`. No production traversal policy or route geometry was changed during this investigation.
- **Investigation CLI/GUT results (distinct from MCP):** pinned `rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . -s res://addons/gut/gut_cmdln.gd`. Instrumented `-gtest=res://tests/levels/test_traversal_validation_route.gd -gunit_test_name=one_unbroken -gexit` failed at **both 60/120 Hz** (exit 1; 0/1 tests, 20/25 assertions; raw `C:\Users\pinto\AppData\Local\Temp\opencode\wall-stick-candidate-trace.log:24-27,416-419`). Restored fixture with the same focused options failed at 60 Hz (exit 1; 0/1, 9/11; `wall-stick-restored-focused.log:10-45`): terminal reason 4, zero wall-jump impulses and no finish. Existing `-gtest=res://tests/player/locomotion/test_wall_traversal_integration.gd -gexit` gave **17/18**, 363/364 assertions, exit 1: shallow-corner crossing assertion failed at 60 Hz (`wall-stick-existing-regression.log`); isolated `-gunit_test_name=never_reverses` still failed (0/1, 14/18, exit 1), this time on a 120 Hz wall-run exit. Cause of this variable corner failure is unestablished. Focused `-gunit_test_name=wall_stick_` passed **8/8**, 168 assertions, exit 0 (`wall-stick-only-regression.log`), including real stick jump and genuine switched-wall exit. These focused runs are not the pending recursive `res://tests/player/**` gate.
- **Investigation MCP observations (not a GUT test or a completed route):** session `testgame@e362124f09f388c2` (Godot 4.7.2, plugin/server 4.0.4) listed as active; `editor_state` ready/stopped on `res://game/levels/content/traversal_validation/traversal_validation_route.tscn`; `scene_get_hierarchy`, `node_get_properties` on `FirstWall`, `ObliqueWall` and its collision shape, `resource_manage(load, wall_probe.tres)` and `script_manage(find_symbols, player_contact_provider.gd)` inspected affected editor data. The restored test was rescanned; the route was launched, runtime player/wall nodes inspected, then stopped. Final `filesystem_manage(scan)` settled with 128 global classes (delta 0); the restored route test's script outline remained discoverable and the editor was ready/stopped on the route. Editor `logs_read(since_cursor=119)` reported **zero new entries**; the current-run game log showed only helper registration. `game_eval` attempts returned `EVAL_COMPILE_ERROR` and `EVAL_GAME_NOT_READY`, so MCP did **not** observe the candidate sequence or a route completion. No MCP-native adapter suite was run. Route success, broader GUT/MCP live gates, human playtest and OD-009 approval remain pending; **Status: in-progress**, no M0 acceptance claim.

### Completion Notes List

- Story file created from bounded canonical context and predecessor intelligence; route implementation and gate evidence remain to be supplied by the implementing agent.
- Wall-stick `SWITCHED` entry cause documented as a candidate-source/representative-point discontinuity, with separate MCP and CLI evidence and a separate shallow-corner regression observation; no fix or acceptance gate completed in this investigation.

### File List

- `_bmad-output/implementation-artifacts/1-10-complete-the-focused-traversal-validation-route.md` (story authoring)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (story status update)
- `_bmad-output/.artifact-index/context-1-10.json` (bounded resolver output)
- `_bmad-output/implementation-artifacts/investigations/route-wall-stick-switch-investigation.md` (diagnosis and verification record)
