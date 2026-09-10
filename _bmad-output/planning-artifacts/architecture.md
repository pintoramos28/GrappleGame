---
artifact_schema: 1
artifact_id: 'grapplegame.architecture'
document_type: 'game-architecture'
artifact_role: 'canonical'
authority: 'target-implementation'
path_base: 'project-root'
title: 'Game Architecture'
project: 'testgame'
date: '2026-08-31'
updated: '2026-09-09'
author: 'Pinto'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'
engine: 'Godot 4.7.2-stable'
platform: 'Windows PC'
gdd: '_bmad-output/planning-artifacts/gdd.md'
gdd_sha256: 'd630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156'
decision_log: '_bmad-output/planning-artifacts/decision-log.md'
source_documents:
  - '_bmad-output/planning-artifacts/sources/design-library/GAME_DESIGN_DOCUMENT.md'
  - '_bmad-output/planning-artifacts/sources/design-library/GAMEPLAY_SYSTEMS.md'
  - '_bmad-output/planning-artifacts/sources/design-library/LEVEL_AND_ENCOUNTER_DESIGN.md'
  - '_bmad-output/planning-artifacts/sources/design-library/TECHNICAL_ARCHITECTURE.md'
  - '_bmad-output/planning-artifacts/sources/design-library/DEVELOPMENT_ROADMAP.md'
downstream_documents:
  epics: '_bmad-output/planning-artifacts/epics/index.md'
  project_context: '_bmad-output/project-context.md'
decision_log_sha256: '01454eb5eadbeb60cffe4508fcae8336cfb4bc8dd14c19230964c28a5fb72a00'
---

## Executive Summary

**GrappleGame** is a Windows-PC-first third-person traversal-combat action RPG built in Godot 4.7.2-stable. Its M0-M4 architecture is organized around one fixed-step movement authority, simulation-authored ability lifecycles, universal grappleable geometry, scoped encounter ownership, and observational presentation. The result protects movement feel and combat correctness while giving AI agents explicit contracts, deterministic seams, and bounded verification targets.

**Key architectural decisions:**

- A single kinematic `PlayerMotor` performs one movement commit per 60 Hz Jolt physics step. Gameplay durations are authored in seconds, and high-refresh rendering uses interpolation rather than faster simulation.
- Immutable typed Resource definitions configure abilities, attacks, enemies, queries, cues, and encounters; mutable execution state remains local to its owning runtime object.
- Direct typed commands flow down ownership boundaries and committed typed signals flow up. There is no global gameplay event bus or mutable global gameplay store.
- Replaceable level and encounter runtime roots own scoped spawns, run identity, cancellation, and cleanup. Detached projectiles and effects carry immutable source and damage snapshots rather than depending on a surviving source node.
- Enemy climbing and flight use runtime geometry discovery plus reusable tactical policies, minimizing required designer-authored anchors while retaining deterministic choices and explicit fallbacks.
- Gameplay simulation owns ability phases, hit windows, motion, and outcomes. Animation, audio, VFX, camera, UI, and diagnostics consume committed state without becoming gameplay authorities.

**Project structure:** The approved target is a domain-oriented `game/` hierarchy spanning player, combat, enemies, encounters, levels, presentation, data, shared contracts, and tests. Existing prototype directories remain migration inputs, not competing target conventions.

**Implementation patterns:** Nine core implementation patterns define creation, communication, ownership, lifecycle, data, failure, diagnostics, presentation, and verification. Six M2 composition families cover all 17 planned reusable combat-pressure mechanics without requiring a bespoke framework for every enemy ability.

**Ready for:** Epic and story decomposition followed by M0 Traversal Foundation implementation. Save systems, persistent RPG progression, networking, narrative implementation, and final presentation remain intentionally deferred beyond the validated M0-M4 slice.

# Game Architecture

## Document Status

This architecture document is complete and validated for implementation planning.

**Steps Completed:** 9 of 9 (Complete)

---

## Project Context

### Game Overview

**GrappleGame** is a third-person traversal-combat action RPG in which the player fights through authored vertical environments using momentum-preserving movement, crosshair-directed grappling, wall running, wall sticking, and movement-derived attack opportunities.

The immediate production boundary is a complete core-gameplay validation slice:

1. M0 — Traversal Foundation
2. M1 — Movement-Combat Contract
3. M2 — Combat Pressure and Ability Vocabulary
4. M3 — Encounter and Level Shell
5. M4 — Boss and Complete Gameplay Slice

Narrative implementation, persistent RPG progression, the complete world and enemy rosters, and final presentation remain deferred.

### Technical Scope

**Platform:** Windows PC first; keyboard and mouse only  
**Genre:** 3D traversal-combat action RPG  
**Project Level:** High complexity  
**Networking:** Single-player through M4; networking is explicitly deferred  
**Current Engine Baseline:** Godot 4.7.2-stable, Forward+ renderer, Jolt Physics, repository-vendored LimboAI 1.8.1 build  
**Level Model:** Authored, self-contained, instanced vertical levels  
**Current Slice:** The Last Garden, culminating in the Garden Heart boss candidate

### Core Systems

| System | Complexity | Source |
|---|---|---|
| Player movement and traversal state machine | High | Gameplay Systems §1; Roadmap M0 |
| Crosshair-directed grappling and target responses | High | Gameplay Systems §2 and §7; Roadmap M0 |
| Wall-relative movement on non-flat surfaces | High | Gameplay Systems §1.4; Roadmap M0 |
| Movement-combat context and attack abilities | High | Gameplay Systems §3–4; Roadmap M1 |
| Health, hitboxes, hurtboxes, damage, and death | Medium | Gameplay Systems §4; Roadmap M1 |
| Enemy perception, behavior, and attack states | High | Gameplay Systems §5; Roadmap M1–M2 |
| Reusable threat and enemy-ability framework | High | Gameplay Systems §8–9; Roadmap M2 |
| Dynamic surface, route, and anchor effects | High | Gameplay Systems §7 and §9; Roadmap M2C |
| Telegraphing and counterplay feedback | High | GDD Pillar 4; Roadmap M1–M2 |
| Encounter activation, completion, and reset | High | Level and Encounter Design; Roadmap M3 |
| Objectives, checkpoints, rewards, and level flow | Medium | Level and Encounter Design §3; Roadmap M3–M4 |
| Boss phases, vulnerabilities, and completion | High | GDD M4; World Atlas, The Last Garden |
| HUD, gameplay feedback, and debugging | Medium | GDD §6; Roadmap M1 and M3 |
| Data-driven scene/resource authoring | Medium | Technical Architecture §1 |
| Automated tests, test scenes, and playtest evidence | High | Adapter M2 contract; Roadmap exit gates |
| Save data and persistent RPG progression | Deferred / High later | Roadmap M6 |

### Technical Requirements

- Preserve useful velocity through grappling, release, wall contact, direction changes, attacks, knockback, and recovery.
- Keep movement and attack state machines independently operable while defining explicit cancellation, death, and invalid-state rules.
- Replace concrete-body checks with a reusable `Grappleable` contract supporting eligibility, static and moving grapple points, target response behavior, state changes, destruction, and invalidation.
- Treat most geometry and created obstacles as grappleable by default. Hazards should normally modify the value or response of a target rather than silently invalidate it.
- Capture movement-derived combat information in a bounded `MovementCombatContext` instead of coupling the damage resolver to the player controller.
- Separate attack behavior (`AttackDefinition`) from damage and combat metadata (`DamageDefinition`), and carry resolved source-side values in immutable `DamageSnapshot` instances.
- Keep windup as a simulation-owned ability phase, define affected geometry through a shared ability-space contract, and let telegraph presentation communicate those facts without owning timing or collision.
- Support all 17 documented reusable enemy mechanics as minimal M2 prototypes while promoting only a validated subset into the first production level.
- Preserve at least one viable player response and recovery route when abilities are combined.
- Keep levels responsible for encounter activation, objectives, rewards, restart, and completion rather than embedding those responsibilities in enemies or bosses.
- Ensure source death, encounter restart, checkpoint reload, and scene exit remove every spawned effect, timer, tether, surface mutation, telegraph, and temporary obstacle.
- Preserve low, high, lateral, and—where needed—recovery routes in major combat spaces.
- Use resources, reusable scenes, components, and signals to express cross-system contracts without reaching into another system’s internal implementation.
- Keep gameplay tuning data-driven through shared immutable definitions; deliberate challenge variants reference alternate typed Resources rather than duplicating scalar scene overrides.
- Maintain prototype readability using simple geometry and effects before requiring final art, animation, audio, or VFX.
- Keep future save, inventory, loadout, and persistent progression concerns outside the M0–M4 core unless an interface is required to avoid rework.

### Platform and Performance Requirements

The approved platform gates are:

- Windows PC is the first shipping target.
- Keyboard and mouse are the only supported gameplay devices; controller support is outside the target architecture.
- The baseline presentation target is 1920x1080 at a stable 60 FPS on the eventual minimum-spec Windows PC.
- Uncapped and high-refresh presentation is best effort, while gameplay remains independent of render rate.
- Physics runs at a fixed 60 Hz with interpolation; 120 Hz is a diagnostic configuration rather than a second shipping target.

Minimum hardware, numeric memory and loading-time budgets, and representative production content density remain empirical M3-M4 profiling decisions. Until those measurements exist, first-time synchronous combat loading is prohibited and performance acceptance uses representative release-like encounters rather than guessed hardware budgets.

### Networking Requirements

No local or online multiplayer requirement is documented. The current architecture should therefore remain single-player and avoid networking abstractions that do not support the validation slice.

Gameplay events and state ownership should still be explicit for testability and reliable reset, but they should not be designed as network replication systems unless multiplayer enters scope through a recorded decision.

### Complexity Drivers

**High-complexity areas:**

1. **Traversal physics:** Wall-relative velocity, changing surface normals, high-speed contact, moving targets, and momentum preservation must feel coherent across frame rates and level geometry.
2. **Concurrent player capabilities:** Movement and attacks can operate simultaneously, creating ownership and cancellation risks across grappling, wall states, damage, and death.
3. **Universal grapple ecology:** Static, moving, temporary, hazardous, and modified targets need one stable contract without turning the player controller into a target-type switchboard.
4. **Composable enemy pressure:** Seventeen reusable mechanics and representative cross-family combinations require shared effect, telegraph, cleanup, and interaction rules.
5. **Dynamic routes:** Temporary walls, adhesive surfaces, anchor changes, wind, gas, and other effects alter navigation while preserving understandable counterplay.
6. **Encounter lifecycle:** Every encounter and boss must restart without stale effects, duplicate signals, leaked runtime resource state, or accumulated scene state.
7. **Vertical enemy behavior:** Current direct steering has no navigation mesh, obstacle avoidance, or coordinated behavior; authored vertical spaces will expose those limitations.
8. **Readability under overlap:** Ability combinations must remain distinguishable while the player and camera are moving quickly through three dimensions.
9. **Validation breadth:** M2 is capability-complete, creating a large prototype and interaction test surface even though production content remains deliberately small.

**Novel concepts requiring custom patterns:**

- Movement-derived combat context as an explicit cross-system snapshot.
- A grapple-target response contract covering almost all world geometry.
- Hazardous-but-still-grappleable surfaces and created obstacles.
- Route mutation as a reusable enemy-ability family.
- Interaction rules that preserve movement agency across overlapping pressures.
- Encounter reset and source-death cleanup as first-class ability requirements.

### Technical Risks

- A monolithic player controller could become the owner of traversal, targeting, attacks, effects, and combat rules.
- Independent movement and attack state machines could issue conflicting velocity or cancellation commands.
- Shared Godot resources could accidentally hold mutable runtime state and leak changes between enemies, encounters, or retries.
- Duplicated per-level traversal scalars or casual alternate definitions could cause the player to relearn core movement behavior.
- Surface-normal noise and frame-step variation could make wall running or wall sticking unreliable.
- Moving grapple targets could produce invalid local hit points, stale references, or abrupt velocity changes.
- Effect combinations could create unreadable telegraphs or unavoidable control chains.
- Temporary obstacles, tethers, surface states, and hazards could survive source death or encounter reset.
- Direct enemy steering may fail in authored vertical arenas before a navigation strategy is selected.
- Implementing all 17 M2 mechanics as bespoke enemy scripts would multiply behavior and cleanup inconsistencies.
- Premature RPG, narrative, or final-presentation systems could obscure whether the traversal-combat contract actually works.
- Unmeasured minimum-spec hardware and production content density could invalidate asset, rendering, memory, or encounter-overlap assumptions if representative profiling is delayed.
- LimboAI and Jolt are meaningful dependencies whose versions and responsibility boundaries must be recorded and validated.

### Architecture Decision Priorities

The next architecture stages must resolve these decision clusters:

1. Validate the engine, renderer, physics backend, and plugin baseline.
2. Define system ownership and communication boundaries.
3. Define traversal-state and velocity-authority rules.
4. Define `Grappleable` behavior and lifetime contracts.
5. Define movement-combat context and attack execution boundaries.
6. Define reusable ability, effect, telegraph, and surface-state composition.
7. Define encounter lifecycle, reset, cancellation, and cleanup guarantees.
8. Define enemy navigation and behavior scope for the validation slice.
9. Establish platform, performance, debugging, automated-test, and playtest decision gates.

## Engine & Framework

### Selected Engine

**Godot Engine 4.7.2-stable**

Godot 4.7.2 is the current stable patch release as verified on September 2, 2026. Godot 4.8 remains on the development track and is not the project baseline. [Godot 4.7.2 release archive](https://godotengine.org/download/archive/4.7.2-stable/)

**Rationale:** Godot already powers the playable prototype and directly supports the project’s scene/resource/component model, high-speed `CharacterBody3D` movement, Jolt physics, crosshair-directed queries, data-driven gameplay, and reusable level composition. Remaining with Godot preserves the existing traversal and combat knowledge embedded in the project while avoiding an engine migration before the core gameplay contract has been validated.

### Version Policy

- Pin development to **Godot 4.7.2-stable**.
- Retain the project’s `4.7` feature tag; the project file records the feature line rather than the patch number.
- Evaluate later 4.7 maintenance releases on an isolated upgrade branch with traversal, combat, scene-loading, plug-in, and test-suite verification.
- Do not move to Godot 4.8 development builds.
- Consider Godot 4.8 only after a stable release and verified compatibility with LimboAI, Terrain3D, Godot AI, GUT, and any production-critical camera tooling.
- Record engine and plug-in upgrades as explicit dependency decisions rather than allowing silent editor upgrades.

### Project Initialization

No external starter template will be used.

The existing GrappleGame repository is the project’s custom starter and remains the architectural foundation. It already provides:

- A Godot 4.7 Forward+ project
- Jolt Physics
- `main.tscn` as the launch scene
- Custom momentum-based traversal
- Grappling, wall running, wall sticking, and wall jumping
- Independent movement and attack state machines
- Reusable player, enemy, projectile, hitbox, hurtbox, and health scenes
- Data-driven attack, combat-stat, and enemy definitions
- Initial arena and traversal tutorial scenes
- Existing testing and AI-development tooling

Official demos and community templates may be inspected as isolated references. Their controllers, folder layouts, and input systems must not be merged wholesale into the project. The [official Godot TPS demo](https://github.com/godotengine/tps-demo) is a reference for presentation, input, and camera techniques—not a replacement foundation.

### Engine-Provided Architecture

| Component | Solution | Notes |
|---|---|---|
| Rendering | Forward+ through Godot’s RenderingDevice | Windows PC baseline; current driver is Direct3D 12 and alternatives require minimum-spec evidence |
| 3D physics | Built-in Jolt Physics | Explicitly selected in `project.godot`; fixed 60 Hz with interpolation |
| Character movement | `CharacterBody3D`, `move_and_slide()`, collision recovery | Traversal behavior remains custom project code |
| Spatial queries | Physics direct-space state, ray casts, shape casts, and collision results | Supports crosshair grappling, wall detection, perception, and threat queries |
| Scene composition | Nodes, reusable scenes, `PackedScene`, `SceneTree`, and signals | Ownership and lifecycle conventions remain project decisions |
| Gameplay data | Custom `Resource` classes using `.tres` or `.res` assets | Runtime mutable state must remain separate from shared definitions |
| Input | Input Map actions plus high-resolution mouse motion | Keyboard and mouse only; keyboard/mouse remapping is supported and controller paths are excluded |
| Audio | Audio buses, stream players, positional audio, and effects | Presentation implementation is deferred, but gameplay cues need stable identifiers |
| Navigation | `NavigationServer3D`, maps, regions, links, and agents | Ground reachability uses navigation; climbers and flyers supplement it with geometry probes and encounter bounds |
| Scripting | GDScript baseline, with C# and GDExtension available | New languages or native extensions require an explicit justification |
| Serialization | Scenes, resources, project settings, and custom save representations | Persistent RPG save design is deferred |
| Plug-ins | Editor plug-ins, GDExtension, import plug-ins, and autoloads | Dependency pinning and runtime/editor-only boundaries must be documented |
| Build and export | Export presets and platform-specific templates | Windows x86-64 is first; representative debug and release exports are validation gates |

Godot’s Forward+ renderer targets modern Vulkan, Direct3D 12, or Metal-capable hardware. If low-end desktop, mobile, or web becomes a target, renderer and performance assumptions must be revisited. [Godot renderer comparison](https://docs.godotengine.org/en/stable/tutorials/rendering/renderers.html)

Godot 4.7 provides built-in Jolt as the default 3D physics engine for new projects. GrappleGame explicitly selects it, but Jolt-specific collision, query, contact, and joint behavior must still be covered by traversal tests. [Godot Jolt documentation](https://docs.godotengine.org/en/4.7/tutorials/physics/using_jolt_physics.html)

### Existing Engine Extensions

| Extension | Local version | Current role | Architectural status |
|---|---:|---|---|
| LimboAI | Local vendored build 1.8.1 | Player hierarchical state machines and enemy behavior trees | Required gameplay dependency; preserve the repository build until compatibility validation approves replacement |
| Godot AI | 3.2.4 | MCP editor/runtime integration | Development-only dependency |
| Terrain3D | 1.0.2 | Editable 3D terrain | Optional; gameplay cannot depend on Terrain3D types |
| GUT | 9.7.1 | GDScript automated testing | Development/test dependency |
| Phantom Camera | 0.11.0.2 | Installed camera tooling and stale manager autoload | Deferred; built-in `Camera3D` and `SpringArm3D` own the production camera path |
| GDQuest GDScript Formatter | 0.1.0 | Editor formatting | Optional editor-only tool |

The repository reports LimboAI `v1.8.1` in its vendored `version.txt`. The public release page listed v1.8.0 when versions were verified on September 2, 2026, so this architecture treats 1.8.1 as the exact local vendored build rather than assuming it is an interchangeable public release. It must remain pinned because behavior-tree and state-machine resources are runtime gameplay assets, not merely editor conveniences. [LimboAI releases](https://github.com/limbonaut/limboai/releases)

### AI-Assisted Development

#### Godot AI MCP

**Selected:** Godot AI 3.2.4  
**Repository:** [hi-godot/godot-ai](https://github.com/hi-godot/godot-ai)  
**Install type:** Godot editor plug-in plus local Python/FastMCP service  
**Requirements:** Godot 4.5 or newer, Godot 4.7 recommended, and `uv`

The plug-in is already installed and enabled. It provides live scene and resource inspection, node and script operations, signal wiring, materials, UI, animation, test execution, logs, and runtime diagnostics.

Configuration policy:

- Prefer project-local MCP client scope where supported.
- Let the Godot AI dock generate the client configuration, particularly on Windows.
- Bind the service to loopback only.
- Keep the default editor and MCP ports local.
- Do not commit credentials, tokens, machine-specific executable paths, or personal MCP configuration.
- Begin with read-only inspection when diagnosing.
- Verify scene and resource mutations through version-control diffs, editor inspection, and relevant tests.
- Do not add another Godot editor-control MCP unless a documented capability gap justifies the duplicate privileged surface.

#### Context7

**Selected:** Context7  
**Repository:** [upstash/context7](https://github.com/upstash/context7)  
**Install type:** Hosted MCP endpoint or local Node.js MCP package  
**Purpose:** Retrieve current, version-specific API documentation and examples

Configuration policy:

- Prefer the hosted MCP connection unless offline or self-hosted documentation is required.
- Store API credentials outside the repository.
- Request the relevant Godot or dependency version explicitly.
- Treat retrieved community-indexed documentation as reference material and confirm critical engine behavior against official Godot documentation.
- Use Context7 for API lookup; use Godot AI for live project and editor state.

### Project-Owned Architectural Decisions

Godot and the selected tooling do not determine the following project policies. The decisions adopted for each category are specified in the remainder of this document:

1. Target platforms and supported input devices
2. Frame-rate, resolution, memory, loading, and content-density budgets
3. Physics tick, interpolation, and traversal consistency policy
4. System ownership, dependency direction, and signal boundaries
5. Velocity authority across traversal, attacks, knockback, wind, tethers, and surface effects
6. Grappleable target behavior and lifetime contracts
7. Resource-definition versus mutable runtime-state boundaries
8. Attack, telegraph, effect, and surface-state composition
9. Encounter activation, cancellation, reset, checkpoint, and cleanup guarantees
10. Enemy navigation strategy for authored vertical spaces
11. Level loading, transition, reward, and objective architecture
12. Test-scene, automated-test, playtest, telemetry, and debugging requirements
13. Built-in camera ownership and the dependency boundary around deferred Phantom Camera
14. Optional Terrain3D isolation from gameplay contracts
15. Future save, inventory, loadout, and persistent RPG architecture

## Architectural Decisions

### Decision Summary

| Category | Decision | Version / Scope | Rationale |
|---|---|---|---|
| Platform | Windows PC first; keyboard and mouse only | M0-M4 | Focus optimization, testing, and input design on one shipping environment |
| Performance | 1920x1080 at 60 FPS on eventual minimum-spec hardware; high-refresh best effort | Render-rate independent gameplay | Preserve consistent traversal while allowing uncapped presentation |
| Simulation timing | Fixed 60 Hz Jolt physics with interpolation; authored gameplay durations in seconds | Godot 4.7.2-stable | Preserve clear, real-time-stable timing without introducing a second tick vocabulary |
| State ownership | Scoped scene composition with LimboAI HSMs and behavior trees | Local vendored LimboAI build 1.8.1 | Explicit ownership without a global gameplay store or universal event bus |
| Motion authority | One kinematic motor and one movement commit per physics step | Project contract | Prevent traversal, attack, knockback, and hazard systems from fighting over velocity |
| Definitions and runtime | Immutable Resource definitions with owner-local mutable runtime instances | Godot Resources | Prevent shared-state leakage between entities, encounters, and retries |
| Ability lifecycle | Explicit simulation-authored phases advanced from physics delta; animation, audio, and effects follow gameplay | Project contract | Preserve authoritative, rate-independent timing and reliable cancellation |
| Encounter lifecycle | Replaceable encounter RuntimeRoot, run IDs, scope-aware spawning, and transactional reset | Project contract | Eliminate stale effects, projectiles, signals, and delayed events |
| Physics queries | Named collision matrix plus immutable typed query profiles | Jolt / Godot physics | Separate broad collision eligibility from gameplay meaning |
| Enemy AI | Geometry-discovered climb and flight positions with reusable tactical policies | Local vendored LimboAI build 1.8.1 | Preserve intelligent vertical behavior while minimizing designer-authored anchors |
| Scene and asset loading | Persistent AppRoot, replaceable LevelRoot, manifests, and threaded level-boundary loading | Godot 4.7.2 | Avoid combat hitches and clarify scene lifetime |
| Input | InputMap for keys/buttons, dedicated high-resolution mouse aiming, immutable fixed-step command frames | Keyboard and mouse only | Preserve precision and prevent gameplay states from reading hardware directly |
| HUD and UI | Persistent UI shell, session-bound HUD, typed read-only presentation sources | Godot Control | Keep UI observational rather than authoritative |
| Audio | Built-in Godot audio, typed cue definitions, scoped emitters, semantic voice limits | Godot 4.7.2 | Make audible telegraphs reliable without allowing audio to control gameplay |
| Verification | Lean AI-first layered verification with a small mandatory contract suite | GUT 9.7.1 | Give AI agents objective feedback without exhaustive testing overhead |
| Add-ons and deferred scope | Built-in camera; Phantom Camera deferred; Terrain3D optional; future systems explicitly deferred | See dependency table | Keep the prototype focused and prevent speculative infrastructure |

### Platform and Performance

**Primary platform:** Windows PC

**Input target:** Keyboard and mouse only. Controller support is excluded rather than retained as a future requirement.

**Performance target:**

- 1920x1080 at a stable 60 FPS on the eventual minimum-spec Windows PC.
- Uncapped and high-refresh presentation as a best-effort enhancement.
- Gameplay behavior must not vary with render rate.
- Physics, ability phases, animation playback, input sensitivity, AI decisions, and cooldowns must not be multiplied by rendered-frame count; gameplay windows are owned by ability simulation rather than animation.
- Representative performance budgets will be tightened after minimum hardware and production content density are known.
- Secondary platforms are not considered until after M4.

### Simulation Timing and Physics

**Physics backend:** Godot Jolt

**Runtime physics rate:** Fixed 60 Hz with physics interpolation enabled.

A 120 Hz mode may be used diagnostically to expose tunnelling, hidden per-step assumptions, or inconsistent timing. It is not the production baseline.

High-speed traversal requires:

- Swept queries where point or ray sampling may tunnel.
- Velocity-aware probes.
- Deliberate collision thickness.
- Stable contact classification.
- Reusable query profiles.
- Tolerant physics assertions rather than exact floating-point equality.

#### Simulation-authored timing

Authored gameplay durations use seconds. Serialized timing fields include an explicit `_seconds` suffix, for example `windup_seconds`, `active_seconds`, `recovery_seconds`, and `cooldown_seconds`.

Runtime owners advance gameplay timing from the `delta` supplied by the fixed physics update:

    phase_elapsed_seconds += delta_seconds
    phase_complete = phase_elapsed_seconds >= definition.windup_seconds

They do not use rendered-frame counts, raw physics-step counts, operating-system wall-clock time, or animation callbacks as gameplay clocks. Phase advancement carries excess elapsed time across boundaries so a hitch does not silently lengthen an ability.

For example, a `0.2`-second phase spans approximately 12 physics updates at 60 Hz and 24 physics updates at 120 Hz while remaining `0.2` seconds in both cases.

Changing the runtime physics rate therefore does not double animation speed, ability speed, cooldown rate, or movement duration. The physics rate remains fixed for the duration of a session.

### Gameplay State Ownership

The project uses scoped scene composition with typed commands flowing downward and typed signals flowing upward.

    AppRoot
        |
        v
    LevelController
        |
        v
    EncounterController
        |
        v
    Entity coordinators
        |
        v
    Local components and state machines

Ownership rules:

- Local components own narrow state.
- Entity coordinators compose components and expose typed entity contracts.
- EncounterController owns encounter activation, waves, participant registration, completion, and encounter reset.
- LevelController owns checkpoints, player restoration, objectives, reward commitment, and level progression.
- Autoloads are reserved for genuinely application-wide services such as settings and application flow.
- There is no global mutable gameplay store.
- There is no universal gameplay event bus.
- Systems may not reach into another scene's private child paths.
- Scene initialization uses typed contexts or explicit public initialization methods.

#### Player state

Player movement and attack remain separate hierarchical state machines.

- The movement HSM owns grounded, airborne, grappling, wall-running, wall-sticking, dead, and related locomotion transitions.
- The attack HSM owns attack readiness, windup, active, recovery, cancellation, and related action transitions.
- Their coordination occurs through explicit typed policies and commands rather than direct cross-transition calls.

#### Enemy state

- A LimboAI behavior tree selects tactical intent.
- An enemy action HSM owns the selected action's windup, active, recovery, cancellation, and completion lifecycle.
- The behavior tree does not directly manipulate hitboxes, velocity, animation timing, or spawned effects.
- Action results return typed success, failure, cancellation, or fallback reasons.

### Motion Authority and Effect Precedence

The player uses one kinematic motion controller.

Only that controller may:

- Write final CharacterBody3D.velocity.
- Call move_and_slide().
- Commit movement for the physics step.

It does so exactly once per physics step.

Grapple, attacks, knockback, wind, tethers, adhesive surfaces, wall behavior, jump, root motion, and other mechanics submit typed motion influences instead of writing velocity directly.

#### Fixed semantic phases

Influences resolve in fixed semantic phases:

1. Terminal commands
2. State gating and interrupts
3. Base locomotion and gravity
4. Sustained influences
5. One-shot impulses
6. Constraints and redirections
7. Caps and final movement commit

The project does not use arbitrary numeric priorities or scene-tree order to decide which movement effect wins.

Attack definitions declare an explicit movement policy such as:

- Preserve
- Add
- Cap
- Redirect
- Lock

Root motion, when used, is extracted by presentation code and submitted as a typed motor influence. An animation never moves the authoritative body directly.

### Definition and Runtime State

Godot Resources are immutable authored definitions during play.

Examples include:

- Ability definitions
- Attack definitions
- Enemy definitions
- Combat-stat definitions
- Audio cue definitions
- Physics query profiles
- Encounter definitions
- Tactical AI policies
- Level manifests

Mutable runtime data lives in separate owner-local instances.

Examples include:

- Ability cooldowns and current execution phases
- Health and status instances
- AI action state
- Projectile travel state
- Encounter run state
- Grapple attachment state
- Per-owner stat modifier state

Rules:

- Runtime systems may read shared definitions but never write to them.
- Encounter reset recreates mutable runtime state rather than attempting to scrub shared Resources.
- Durable definitions receive stable IDs for attribution, diagnostics, and any later persistence design.
- Development validation detects accidental runtime mutation of definition Resources.

### Ability, Telegraph, Animation, and Effect Lifecycle

Every executable ability follows an explicit lifecycle:

    requested
        |
        v
    validated and committed
        |
        v
    windup
        |
        v
    active
        |
        v
    recovery
        |
        v
    completed

Any non-terminal phase may instead enter a reason-coded cancelled result where allowed.

Rules:

- Phase timing is simulation-authored in seconds and advanced only by the owning fixed-step simulation update.
- Damage windows, invulnerability, cooldowns, hitboxes, movement policies, and cancellation windows never depend on animation callbacks.
- Telegraphs and active effects share the same authoritative target and shape specification.
- Cancellation and completion are idempotent.
- Each execution has a stable execution ID.
- Spawned effects register with an execution or encounter cleanup scope.
- Cleanup remains safe if called more than once.

#### Windup, ability space, and telegraph presentation

These are three separate responsibilities:

| Concern | Answers | Authority |
|---|---|---|
| Windup | When may the attack become dangerous? | `AbilityExecution` advances the simulation-owned phase in seconds |
| Ability space | Where or what will the attack affect? | `AbilitySpatialDefinition` and the execution-local spatial binding |
| Telegraph | How does the player learn the timing, target, and affected space? | Presentation adapters observing committed phase and spatial snapshots |

A telegraph is not an additional gameplay phase and never runs an independent gameplay timer. It begins, updates, locks, and ends from committed ability phase state. An enemy animation may be part of the telegraph, but animation playback does not decide when windup completes.

```text
AttackDefinition
    |-- windup_seconds ------------> AbilityExecution
    +-- AbilitySpatialDefinition --> AbilitySpatialBinding
                                             |
                                             v
                                AbilitySpatialSnapshot
                                      /           \
                                     v             v
                          Telegraph presenter   Active delivery
                                                or hit query
```

The spatial contract uses:

- `AbilitySpatialDefinition`: immutable target, origin, shape, orientation, tracking, lock, and query rules.
- `AbilitySpatialBinding`: execution-local binding to a source, socket, target, predicted point, or frozen world transform.
- `AbilitySpatialSnapshot`: authoritative world-space shape for one physics step.
- `TelegraphCueDefinition`: presentation identifiers and styling only.

Supported typed shapes include lanes or capsules, spheres or ground circles, boxes, sectors, planes or sweeps, trajectories with impact areas, and surface patches. A tracking rule declares whether the binding freezes at commit, follows the source, follows a target until a named phase boundary, or remains attached throughout active execution.

Examples:

- A melee attack may use a 0.30-second windup and an arc-shaped hit query. Its raised weapon, body pose, glow, and sound are the telegraph; the animation does not enable the hit query.
- A lane shot may track during the early part of a 0.65-second windup and then lock. Its aiming line renders the same frozen direction and width used when the projectile or ray activates.
- A predictive mark freezes a future world point, displays a circle at the same center and radius during windup, and strikes that stored space when active begins.
- A temporary obstacle displays a non-colliding preview during windup and enables or spawns collision at the same transform only when active begins.
- A rotating sweep shows emitter charge and intended direction during windup. During active, its visible beam is an active danger indicator driven by the same rotating spatial binding as the hit query.
- A gas attack may show its future boundary during windup; once active, the visible cloud and boundary communicate current danger while simulation-owned pulses apply damage.

Attacks do not all require a floor marker. Pose, silhouette, sound, weapon glow, projectile travel, directional UI, and spatial previews are valid telegraph channels when they communicate the threat clearly. Prototype fallback presenters provide simple Godot-native lines, rings, translucent volumes, wedges, planes, trajectory lines, and surface overlays so final art or animation is not required for readable testing.

#### Animation integration

    AbilityExecution
        |
        v
    AnimationPresenter
        |
        v
    AnimationTree

The animation presenter:

- Selects animation states.
- Sets blend values.
- Applies cosmetic timing adjustment.
- Emits cosmetic particles and sounds.
- May submit extracted root motion through the motor.

Animation markers are cosmetic only. They may trigger footsteps, particles, or secondary presentation but cannot apply damage or advance gameplay phases.

### Encounter Lifetime, Spawning, and Attribution

Each encounter owns a replaceable RuntimeRoot.

    EncounterController
    |-- authored static configuration
    +-- RuntimeRoot
        |-- participants
        |-- projectiles
        |-- telegraphs
        |-- temporary hazards
        |-- spawned obstacles
        |-- encounter audio
        +-- other transients

Encounter reset is a transaction:

1. Invalidate the current encounter run ID.
2. Stop accepting new requests from that run.
3. Cancel active executions.
4. Remove or fade scoped presentation.
5. Free the old RuntimeRoot at a safe scene-tree boundary.
6. Create a fresh runtime root.
7. Recreate encounter runtime state.
8. Restore the player through LevelController.
9. Activate the new run.

Every delayed gameplay request carries the encounter run ID. Requests from an invalidated run are ignored.

#### Scene lifetime versus combat attribution

Scene-tree ownership controls lifetime. It does not determine who receives combat credit.

A projectile separated from its enemy carries:

    ProjectileDefinition
    DamageSnapshot
    CombatSourceRef
    ability_execution_id
    encounter_scope
    encounter_run_id
    ProjectileRuntime

Default damage policy:

- Source offense is snapshotted when the attack or projectile launches.
- Target defense, resistance, vulnerability, and incoming modifiers are evaluated on impact.

Additional rules:

- Child effects inherit their parent scope unless explicitly transferred.
- Scope transfer is explicit and validated.
- Reflections update source attribution and damage policy deliberately.
- A status-effect instance is owned by its recipient but retains its origin encounter and run.
- Runtime validation detects objects that escape their permitted scope.
- Gameplay spawning uses typed scope-aware APIs rather than arbitrary add_child() calls.

### Collision Matrix and Query Profiles

The project uses a named collision matrix combined with immutable PhysicsQueryProfile Resources.

Responsibilities:

- Layers and masks express broad physics eligibility.
- Typed components and Resources express gameplay meaning.
- Groups are limited to tooling, diagnostics, and non-critical orchestration.
- Metadata is limited to non-critical annotations.
- Gameplay scripts contain no magic bitmask literals.

Initial query profiles include:

- GroundProbe
- WallProbe
- GrappleCandidate
- GrappleOcclusion
- MeleeHit
- ProjectileHit
- LineOfSight
- InteractionProbe

Each physics step produces one shared ContactFrame containing the authoritative contact interpretation needed by movement states. States do not independently repeat competing ground and wall queries.

Additional rules:

- Authoritative grapple validation occurs on a physics step.
- High-speed checks use swept shapes where necessary.
- Multiple hits are deduplicated.
- Query results are sorted through explicit stable criteria.
- A visual reticle consumes the authoritative result rather than performing a second gameplay query.

### Cross-System Contract Specifications

These contracts are stable boundaries shared by multiple domains. They define the data exchanged between owners without turning `game/shared/` into a manager layer or allowing one system to mutate another system's internal state.

| Contract area | Canonical location |
|---|---|
| Cross-domain grapple target types | `game/shared/contracts/grappleable_3d.gd` and grapple result/snapshot types beside it |
| Player grapple resolution and attachment runtime | `game/player/abilities/grapple/` |
| Movement-to-combat and impact contexts | `game/combat/attacks/` |
| Actor-neutral ability execution and ability space | `game/combat/abilities/` |
| Attack and projectile definitions | `game/combat/attacks/` and `game/combat/projectiles/` |
| Damage definitions, snapshots, and resolution | `game/combat/damage/` |
| Telegraph presenters and fallback shapes | `game/combat/telegraphs/` |
| Objectives, checkpoints, and current rewards | Their named subdirectories under `game/levels/` |

#### Grapple target contract

The target boundary uses four types:

| Type | Owner | Responsibility |
|---|---|---|
| `GrappleTargetResolver` | Player grapple domain | Convert the authoritative ray hit into an accepted attachment seed or typed rejection |
| `Grappleable3D` | Exceptional target scene | Optional component for moving, stateful, hazardous, resistant, modified, or invalid targets |
| `GrappleAttachment` | `GrappleController` | Store occurrence-local connection state, stable target identity, weak target reference, target-local hit offset, response, and originating run ID |
| `GrappleAnchorState` | Sampled through the target contract | Report current world position, target velocity, validity, response values, and typed invalidation reason for one physics step |

Ordinary collision geometry that passes the named grapple query profile receives the built-in static response and requires no component authoring. A non-default collision body exposes a direct child named `Grappleable` typed as `Grappleable3D`; reusable enemy and spawned-obstacle base scenes add that component once rather than requiring placement-by-placement setup.

Activation follows this order:

1. Perform the authoritative physics query using the immutable grapple query profile.
2. Resolve the first blocking collision through the default policy or its explicit `Grappleable3D` component.
3. Return a typed acceptance or `GrappleRejection`; a rejected blocking hit is not pierced to select an object behind it.
4. Convert the hit point to target-local coordinates when the target can move.
5. Commit a player-owned `GrappleAttachment` only after ability coordination succeeds.
6. Sample a fresh `GrappleAnchorState` each physics step and submit pull plus the maximum-range constraint to `PlayerMotor`.

The target returns bounded data and cannot write player velocity, move the player, change locomotion state, or call player abilities. The same resolved `GrappleDefinition.max_grapple_length_m` controls acquisition and the active connection boundary. Attachment distance never becomes a rope length. Destruction, state invalidation, encounter-run mismatch, or severe transform discontinuity ends the grapple once with a typed reason.

Target response definitions use typed fields for eligibility, anchor mode, pull multiplier, directional adjustment, instability, and hazard response. Temporary anchor modification creates target-owned runtime response state; it never mutates the shared definition or the player's grapple definition.

#### Movement and impact context

`MovementCombatContext` is an immutable source-motion snapshot produced through the player movement boundary and consumed by an attack execution. It contains:

| Field | Meaning |
|---|---|
| `capture_physics_step` | Simulation step on which the snapshot was created |
| `source_entity_id` | Stable actor identity without requiring a retained node |
| `source_world_position` | Actor position at capture |
| `locomotion_state_id` | Grounded, airborne, grappling, wall-running, wall-sticking, or another defined state |
| `world_velocity` | Full authoritative velocity at capture |
| `facing_direction` | Authoritative facing direction |
| `is_grounded` | Ground fact from the shared `ContactFrame` |
| `wall_contact_normal` | Valid wall relationship when applicable |
| `is_grapple_active` | Whether grapple execution was active |
| `grapple_pull_direction` | Current pull direction when applicable |

Planar speed, vertical speed, travel direction, and similar values are derived from the snapshot rather than stored as competing facts. Target-relative facts belong to a separate immutable `ImpactContext`, including hit point and normal, target position and velocity, relative velocity, relative height, approach alignment, and hurtbox or weak-point identity.

Each `AttackDefinition` declares one source-motion capture phase: `COMMIT`, `ACTIVE_START`, or `DELIVERY_SPAWN`. `COMMIT` is the default. Impact facts are always captured at the actual collision or accepted hit. Combat code receives these bounded contexts and never queries `PlayerController` internals.

#### Attack behavior, damage, and detached delivery

| Type | Responsibility |
|---|---|
| `AbilityDefinition` | Shared lifecycle, gating, cancellation, and phase structure |
| `AttackDefinition` | Timing, allowed locomotion states, grapple policy, targeting, spatial rules, delivery, motor policy, context capture, and source-death policy |
| `DamageDefinition` | Base damage, scaling, types, tags, critical modifiers, armor penetration, poise pressure, and minimum damage |
| `DamageSnapshot` | Immutable source-side values resolved for one delivery occurrence |
| `ImpactContext` | Current collision and target relationship at impact |
| `DamageInstance` | Final committed result after target-side resolution |

At delivery creation, the attack combines its saved movement context with current source attack power, outgoing multipliers, source modifiers, per-delivery critical result, and stable source, execution, and run identities. That produces a `DamageSnapshot`. At impact, the resolver combines the snapshot with current target defense, resistance, vulnerability, weak-point state, and incoming modifiers.

Consequently, a projectile that outlives its firing enemy retains the appropriate launch-time offense and attribution without retaining the enemy node as damage authority. Ordinary projectiles default to `PERSIST_AFTER_SOURCE`; links such as support tethers normally use `CANCEL_WITH_SOURCE`; encounter reset invalidates every policy through the run ID. A repeating beam or hazard creates a new delivery snapshot per authored pulse when its design requires source values to be sampled again.

The current `AttackData` type migrates to `DamageDefinition`, and `CombatStatsData` migrates to `CombatStatsDefinition`. Enemy attack timing and projectile-delivery fields move from `EnemyDefinition` into referenced `AttackDefinition` and `ProjectileDefinition` resources. Migration preserves Godot UIDs and updates scene and resource references before old paths are removed; old and new types cannot coexist as competing authorities.

#### Ability space and telegraph presentation

The detailed windup, ability-space, and telegraph rules are defined in the ability lifecycle section. The binding contract is:

- Windup determines **when** active execution may begin.
- `AbilitySpatialDefinition`, `AbilitySpatialBinding`, and `AbilitySpatialSnapshot` determine **where or what** the execution affects.
- `TelegraphCueDefinition` and presentation adapters determine **how the player learns** those facts.

Telegraph presentation and active delivery consume the same spatial binding. Warning duration is not duplicated in a presentation timer: the presenter reads committed windup state, elapsed seconds, normalized progress, and lock state. A missing bespoke cue uses the shape-family fallback presenter; animation, VFX, and audio remain replaceable without altering the attack window or geometry.

#### Level objective, checkpoint, and reward contracts

- `LevelObjective` consumes scoped committed facts and emits completion exactly once. Boss death and tutorial summit arrival are objective adapters; only `LevelController` commits level completion.
- `CheckpointDefinition` describes an authored checkpoint, while `CheckpointRuntimeState` holds the active in-memory restart snapshot for the current session.
- `RewardTableDefinition` resolves current health and coin entries into immutable `RewardGrant` occurrences. `LevelController` commits collection; no inventory or persistent-RPG abstraction is introduced through M4.

### Enemy AI and Vertical Navigation

Enemy AI minimizes designer-authored navigation elements.

The default workflow does not require:

- Authored climb routes.
- Climb-entry anchors.
- Flight anchors.
- Hand-authored flight connections.
- A separate flight volume.
- Per-arena tactical waypoint networks.

Designers author reusable archetype policies once. Runtime systems discover useful positions from geometry, encounter bounds, the player, obstacles, and current tactical state.

#### Rootstalker and climbing enemies

The initial climbing model is bounded climb-and-pounce behavior rather than unrestricted arbitrary-surface navigation.

The enemy:

1. Detects that the player is exploiting a wall position.
2. Finds a reachable climb-entry point from nearby navigable geometry and surface probes.
3. Performs a short probe-driven surface pursuit.
4. Generates a pounce solution from current geometry.
5. Aborts safely when contact or route confidence is lost.
6. Returns to standard navigation or another tactical fallback.

No designer-authored climb-entry anchor is required.

#### Spore Kite and flying enemies

The flying unit generates candidates at runtime from:

- Player position and velocity.
- Encounter bounds.
- Preferred distance and altitude.
- Line of sight.
- Nearby obstacles.
- Recent selections.
- Attack requirements.
- Recovery safety.

Candidates are scored through a reusable utility policy. Movement uses direct swept steering. If obstacle complexity eventually requires it, a sparse free-space graph may be generated automatically rather than hand-authored.

The encounter's existing bounds serve as flight bounds. Recovery uses exposed drift and fallback policy rather than a designer-authored recovery anchor.

#### Runtime policy

- Replan approximately 4-6 times per second or in response to meaningful events.
- Use hysteresis to prevent destination thrashing.
- Use deterministic encounter seeds for reproducible diagnostics.
- Visualize candidate generation, rejection reasons, scores, and selected positions in development builds.
- Fail safely when no candidate is valid.

Typical arena-specific AI authoring is:

- Zero climb routes.
- Zero climb anchors.
- Zero flight anchors.
- Zero flight connections.
- Zero separate flight volumes.
- One existing encounter bounds definition.
- Zero to three rare override volumes such as NoEnemyClimb, NoFly, NoPounce, or NoAttackPosition.

### Scene Boundaries and Asset Loading

The target scene structure is:

    AppRoot
    |-- GameFlowController
    |-- LoadingCoordinator
    |-- LevelHost
    |-- UIRoot
    +-- application services

    LevelHost
    +-- LevelRoot
        |-- static world
        |-- navigation
        |-- player
        |-- encounters
        |-- level audio
        +-- level presentation

The existing reusable scene seams remain:

- scenes/player.tscn
- scenes/enemy.tscn
- scenes/projectile.tscn

The current main.tscn responsibilities will be separated into application, level, and encounter ownership.

Rules:

- AppRoot persists across level transitions.
- LevelRoot is replaceable.
- The player is recreated per level.
- Session state, where currently required, remains outside the replaceable player node.
- Encounter reset replaces only the encounter runtime subtree.
- External systems initialize scenes through typed contexts.
- External systems do not reach into internal scene paths.

#### Level loading

A lightweight LevelCatalog maps stable level IDs to LevelManifest assets.

A manifest identifies:

- The level scene.
- Required dependency groups.
- Loading-screen presentation.
- Optional validation metadata.

Dependency information should be generated or validated from normal Resource references rather than manually duplicated.

Loading policy:

- Request level dependencies at level boundaries using Godot's threaded ResourceLoader path.
- Poll loading status without blocking the main thread.
- Instantiate and attach scenes on the main thread only after loading completes.
- Do not perform a first-time synchronous load() during combat.
- Preload only small, genuinely always-resident content.
- Ensure combat-critical scenes, definitions, animations, and audio are resident before encounter activation.
- Return to safe UI if loading fails; never activate a partially loaded level.
- Do not introduce open-world streaming through M4.
- Introduce pooling only if profiling proves it necessary.

### Keyboard and Mouse Input

Godot InputMap remains the binding authority for keys and mouse buttons.

- Factory defaults live in project.godot.
- User remaps live in a versioned ConfigFile under user://.
- Actions support a primary and optional alternate keyboard/mouse binding.
- Bindings support keyboard keys, mouse buttons, and wheel actions.
- Conflicts are surfaced clearly.
- Reset-to-default recovery remains available.

There is no controller profile, glyph set, deadzone configuration, rumble, device switching, or controller menu-navigation requirement.

#### Input contexts

Input context priority is:

1. Rebinding capture
2. UI and pause
3. Gameplay
4. Debug shortcuts

Losing window focus clears held and latched input to prevent stuck actions.

#### Command frames

A player-owned input source converts hardware state into an immutable PlayerCommandFrame for each physics step.

It contains:

- Physics-step number.
- Movement axis.
- Canonical view yaw and pitch.
- Authoritative aim direction.
- Pressed, held, and released states for semantic gameplay actions.

Gameplay HSMs consume command frames and never query global hardware state directly.

Button edges are latched so a short press and release between physics steps is not lost.

#### Precision mouse aiming

Mouse movement uses a dedicated event-driven aim accumulator rather than an InputMap action.

- Captured aiming uses unscaled screen-relative mouse motion.
- Every received motion event contributes to the canonical aim state.
- Mouse delta is not multiplied once per physics tick.
- Camera presentation reads the latest canonical orientation at render rate.
- Gameplay snapshots that orientation on the physics step.
- Disabling Godot's accumulated-input mode during captured gameplay is permitted after high-polling-rate mouse CPU validation.
- Sensitivity, horizontal/vertical scaling, and inversion are user settings.
- Mouse smoothing and acceleration are disabled by default.

### HUD and UI

UIRoot is persistent and presentation-only.

    UIRoot
    |-- SystemScreenLayer
    |-- GameplayHudHost
    |-- PauseMenuLayer
    |-- TransitionLayer
    +-- DebugOverlayLayer

The gameplay HUD is bound to the active level session and disconnected when that session ends.

The level supplies a typed GameplayHudContext containing presentation sources such as:

- Player health.
- Grapple targeting.
- Ability phases and cooldowns.
- Encounter state.
- Keyboard/mouse prompts.

Sources expose typed change signals and read-only current state. The HUD cannot mutate gameplay.

UI commands use narrow outputs:

    PauseRequested
    SettingsChanged
    ResumeRequested
    ReturnToMenuRequested

Application controllers decide how those requests affect state.

#### Grapple presentation

The targeting system exposes an authoritative grapple state containing:

- Candidate identity.
- Hit position and surface normal.
- Validity and rejection reason.
- Range fraction.
- Attachment state.
- Physics step of the result.

Reticles and world markers translate that state into presentation. They never raycast independently or decide whether a grapple is valid.

Discrete UI values are signal-driven. Continuous presentation may visually interpolate the most recent authoritative state. Visual easing never delays or changes underlying gameplay.

The current player-owned grapple telemetry moves to DebugOverlayLayer. The player-created grapple cursor becomes a dedicated presentation component rather than player-controller responsibility.

#### UI implementation

- Use Godot Control scenes.
- Use shared Theme Resources.
- Author against 1920x1080 with anchors and containers supporting 16:10 and ultrawide Windows displays.
- Support UI scale, reticle size, reticle color, and high-contrast settings.
- Detailed HUD composition remains a separate UX-design task.

### Audio Architecture

Godot's built-in audio system is used. No external audio middleware is introduced.

Audio follows gameplay and never controls it.

    AbilityExecution
        |
        v
    AbilityAudioPresenter
        |
        v
    AudioCueRequest
        |
        v
    scoped playback

An immutable AudioCueDefinition contains:

- Stable cue ID.
- One or more streams.
- Target bus.
- Spatial mode.
- Volume and pitch variation.
- Attenuation and maximum distance.
- Concurrency group and voice limit.
- Retrigger policy.
- Priority.
- Looping and fade policy.

A runtime AudioCueRequest contains occurrence-specific data:

- Cue definition.
- Position or follow target.
- Source reference.
- Ability execution ID.
- Encounter scope and run ID.
- Semantic reason or gameplay phase.
- Optional presentation parameters.

Common cue slots may be inherited from reusable actor or ability presentation profiles. Individual abilities override only distinctive cues.

#### Audio ownership

    AppRoot
    +-- AppAudio
        |-- AudioSettingsService
        +-- MusicDirector

    LevelRoot
    +-- LevelAudioRoot

    Encounter RuntimeRoot
    +-- EncounterAudioRoot

- Music and UI sounds may persist when appropriate.
- Level ambience ends with its level.
- Encounter audio carries the run ID.
- Reset cancels or fades invalidated encounter audio.
- A short one-shot may snapshot its position.
- A following or looping sound remains explicitly source-bound.

#### Bus layout

    Master
    |-- Music
    |-- SFX
    |   |-- Player
    |   |   +-- Grapple
    |   |-- Enemy
    |   |   +-- Telegraph
    |   +-- World
    |-- Ambience
    +-- UI

User settings expose Master, Music, SFX, Ambience, and UI levels.

Voice policy preserves local-player feedback and imminent enemy telegraphs before distant, repetitive, or ambient sounds. Missing buses and cue references are development validation failures.

The MusicDirector accepts high-level menu, exploration, combat, boss, and victory states from existing application, level, and encounter owners. Enemies never control music directly.

Combat-critical audio is loaded before encounter activation. First-time synchronous audio loading during combat is prohibited.

### Lean AI-First Verification and Instrumentation

GUT 9.7.1 is the pinned automated-test framework.

Layered verification is a toolbox, not a requirement that every feature receive every form of test.

#### Mandatory architectural contract suite

The compact permanent suite protects:

- Exactly one motor commit per physics step.
- Fixed motion influence ordering.
- Canonical timing across 60 and 120 Hz physics.
- Exactly one terminal result per ability execution.
- Idempotent cancellation and completion.
- Encounter run-ID rejection.
- Encounter cleanup without scoped transient leakage.
- Damage snapshot attribution and modifier timing.
- Shared definition immutability.
- Input edge latching.
- Agreement between authoritative grapple targeting and presentation.

#### Risk-based verification

| Change type | Expected verification |
|---|---|
| Pure timing, scoring, or policy logic | Focused unit tests |
| Player movement, grapple, collision, or physics | Small real-Jolt integration test |
| Encounter lifetime, spawning, or reset | Integration test with cleanup assertions |
| Designer-authored definitions and levels | Reusable content validators |
| AI positioning behavior | Unit-tested scoring plus representative scene tests |
| UI, audio, and animation presentation | Contract and smoke checks plus human quality review |
| Fixed defect | Reproduction-focused regression test |
| Performance-sensitive feature | Dedicated benchmark when representative scale exists |
| Simple visual or data-only change | Usually no bespoke automated test |

Reusable helpers may include:

- CommandFrameBuilder
- PhysicsStepper
- EncounterHarness
- TestWorldBuilder
- ResourceFactory
- ScopeAssertions

AI agents add and maintain relevant tests alongside implementation. There is no percentage-based coverage target.

Tests must avoid:

- Arbitrary real-time sleeps.
- Exact physics floating-point equality.
- Private node-path dependencies.
- Pixel-perfect gameplay screenshots.
- Deep mocking of Godot physics.
- Large scene-tree snapshots.
- Redundant tests written only to increase coverage.

#### Diagnostics

Development-only diagnostic providers may expose:

- Motor channels and resolved velocity.
- HSM and ability phase.
- ContactFrame classifications.
- Grapple queries and rejection reasons.
- Projectile source, snapshot, and scope.
- Encounter run and transient counts.
- AI candidates and utility scores.
- Audio requests and rejected voices.
- Frame, physics, navigation, and query timing.

Debug overlays consume typed read-only diagnostic providers and use the low-priority debug input context.

Local playtest traces use a bounded ring buffer and stable IDs. They may be dumped on death, invariant failure, performance spike, manual diagnostic capture, or test failure. There is no remote analytics backend.

Debug overlays, verbose traces, and test infrastructure are excluded from or disabled in release exports.

### Camera and Terrain Add-on Policy

#### Camera

Production camera behavior uses built-in Godot nodes behind a small CameraDirector.

    PlayerInputSource
        |
        v
    AimController
        |-- authoritative unshaken aim
        +-- base camera orientation
                  |
                  v
    CameraDirector
        |-- follow offset
        |-- collision
        |-- transitions
        |-- FOV effects
        +-- additive visual shake
                  |
                  v
    SpringArm3D / Camera3D

Camera presentation cannot alter authoritative aim.

- Shake is visual.
- FOV does not change targeting.
- Camera collision does not rotate the gameplay aim basis.
- Smoothing runs at render rate.
- Gameplay consumes the physics-step aim snapshot.

Phantom Camera is deferred and is not an approved production dependency. Its stale manager autoload and unused active configuration should be removed during implementation cleanup. If later reconsidered, it must remain behind CameraDirector and receive a dedicated precision-aim, reload, and Windows-export compatibility pass.

#### Terrain3D

Terrain3D 1.0.2 remains an optional static level-authoring implementation.

Gameplay may not branch on Terrain3D types. It interacts with:

- Named world collision.
- Physics query profiles.
- Navigation.
- ContactFrame.
- Typed grapple-surface policies.

A terrain object receives one broad grapple policy. Special targets remain separate typed scenes. Rare override volumes may adjust broad regional behavior without per-triangle authoring.

Through M4:

- No runtime terrain sculpting or deformation.
- Dynamic walls and hazards are separate scoped scenes.
- Terrain assets load through the level manifest.
- AI uses ordinary physics and encounter bounds.
- Exact Godot 4.7.2, Jolt, Windows debug-export, release-export, collision, and performance compatibility must be validated before Terrain3D enters a production level.

#### Dependency classification

| Dependency | Status |
|---|---|
| Godot 4.7.2-stable | Required engine baseline |
| Godot Jolt | Required physics backend |
| LimboAI local vendored build 1.8.1 | Required gameplay dependency |
| GUT 9.7.1 | Required development/test dependency |
| Terrain3D 1.0.2 | Optional level implementation |
| Phantom Camera 0.11.0.2 | Deferred; not approved for production use |
| Godot AI 3.2.4 | Development-only tooling |
| GDQuest GDScript Formatter 0.1.0 | Optional editor-only tooling |

Versions were verified on September 2, 2026 and remain pinned. Agents may not opportunistically upgrade dependencies. Upgrades require explicit compatibility work and relevant Windows export, scene-load, traversal, and test verification.

Version sources were verified through the [Godot release archive](https://godotengine.org/download/archive/), [LimboAI releases](https://github.com/limbonaut/limboai/releases), [GUT releases](https://github.com/bitwes/Gut/releases), [Terrain3D releases](https://github.com/TokisanGames/Terrain3D/releases), and [Phantom Camera releases](https://github.com/ramokz/phantom-camera/releases).

### Data Persistence and Explicit Deferrals

Current persistence is limited to:

- Versioned local settings.
- Keyboard and mouse remaps.
- In-memory session and checkpoint state needed by the prototype.

Through M4 there is no:

- Persistent campaign save system.
- Save-slot system.
- Persistent RPG progression.
- Inventory or equipment architecture.
- Final loadout or skill-tree system.
- Cloud synchronization.
- Networking, RPC, replication, rollback, or multiplayer ownership.
- Dialogue, quest, or branching narrative framework.
- Remote content or live-balance service.
- Mod loader or user-generated-content system.
- Seamless open-world streaming.
- Controller support.
- Secondary-platform commitment.

Stable IDs and current ownership contracts remain because they serve attribution, diagnostics, reset, and current level flow. No speculative future service is introduced.

AI agents may not add future-facing managers, providers, registries, serialization fields, or framework abstractions unless a current approved story or architectural decision requires them.

### Architecture Decision Records

| ADR | Decision | Binding consequence |
|---|---|---|
| ADR-001 | Fixed 60 Hz Jolt simulation with gameplay durations authored in seconds | Gameplay timing advances from simulation delta and remains independent of runtime physics frequency and render rate |
| ADR-002 | Single kinematic motor with semantic influence phases | No external system writes player velocity or commits movement |
| ADR-003 | Immutable definitions and owner-local runtime state | Shared Resources cannot carry cooldowns, health, AI state, or mutable execution data |
| ADR-004 | Simulation-authored ability phases | Animation, audio, VFX, and UI follow gameplay and cannot create gameplay windows |
| ADR-005 | Replaceable encounter runtime roots with run IDs | Reset invalidates late events and destroys scoped mutable state |
| ADR-006 | Scene lifetime separated from combat attribution | Projectiles and status effects carry explicit source, execution, snapshot, and scope data |
| ADR-007 | Named collision matrix and immutable query profiles | Broad physics eligibility stays separate from typed gameplay meaning |
| ADR-008 | Geometry-discovered vertical AI | Default arenas require no climb or flight anchor networks |
| ADR-009 | Persistent app shell and manifest-loaded replaceable levels | Level loading occurs at explicit boundaries and combat content is resident before activation |
| ADR-010 | Keyboard/mouse command-frame input | Gameplay states never poll hardware and precision mouse motion remains high-resolution |
| ADR-011 | Typed presentation sources | HUD, camera, audio, animation, and debug presentation cannot own gameplay state |
| ADR-012 | Lean AI-first verification | Core invariants are executable while feature-specific testing remains risk-based |
| ADR-013 | Built-in camera; Phantom Camera deferred | Canonical aim remains independent of third-party camera behavior |
| ADR-014 | Terrain3D optional and physics-isolated | Levels may use terrain without introducing Terrain3D dependencies into gameplay |
| ADR-015 | Future systems explicitly deferred | AI agents may not introduce speculative save, RPG, networking, narrative, or streaming frameworks |

## Cross-cutting Concerns

These patterns apply to all systems and are mandatory for every implementation. They define how AI agents must handle failures, diagnostics, configuration, communication, and development tooling.

| Concern | Binding strategy |
|---|---|
| Error handling | Typed domain results, compact rejection enums, explicit owner escalation, debug assertions plus release guards |
| Logging | Structured human-readable records through one typed facade and Godot-native destinations |
| Configuration | `project.godot` for engine settings, immutable Resources for gameplay definitions, `ConfigFile` for user preferences |
| Events | Direct typed commands and queries downward; scoped typed signals for committed facts upward |
| Debugging | Incremental development-only diagnostics using typed read-only snapshots and bounded tooling |

### Error Handling

**Strategy:** Domain-specific typed results with explicit handling or propagation by the direct caller. Expected gameplay rejection uses compact typed enums. Assertions protect programmer invariants in debug builds, while equivalent release guards prevent unsafe continuation.

#### Failure categories

| Category | Example | Required handling |
|---|---|---|
| Expected gameplay rejection | No grapple candidate, cooldown active, target out of range | Return a typed reason; continue normally; do not log as an error |
| Recoverable degradation | Optional visual or audio dependency missing | Apply a defined fallback and warn once |
| Operation failure | Projectile initialization or encounter spawn fails | Return a typed result to the responsible owner |
| Encounter-critical failure | Required participant or execution cannot initialize | Cancel or reset through `EncounterController` |
| Level-critical failure | Manifest dependency or level instantiation fails | Abort activation and return to safe loading UI |
| Application initialization failure | Required core service cannot initialize | Prevent gameplay entry and show a safe player-facing message |
| Invariant violation | Motor commits twice in one physics step | Assert in debug, report, guard, and stop the invalid operation in release |

#### Mandatory rules

- The direct caller must handle a failure or explicitly return it to its owner.
- A global handler may record a failure but may not choose gameplay recovery.
- Godot `Error` values must be checked and converted into the appropriate domain result at the engine boundary.
- Meaningful failures may not be represented only by `false`, `null`, magic integers, or error-message strings.
- Player-facing failure messages must not expose raw paths, stack traces, or internal implementation details.
- Required content failures must not leave a partially active level or encounter.
- Cancellation and recovery operations must be reason-coded and idempotent.
- Expected gameplay outcomes are not errors and must not produce warning or error logs.
- Result objects are limited to infrequent operation boundaries such as loading, initialization, and spawning setup.
- Physics-tick and other hot-path checks use enums or existing typed state rather than allocating result objects.

#### Example

```gdscript
class_name LevelLoadResult
extends RefCounted

enum Code {
    OK,
    MANIFEST_INVALID,
    DEPENDENCY_FAILED,
    INSTANTIATION_FAILED,
}

var code: Code = Code.OK
var level_id: StringName
var technical_detail := ""

func is_success() -> bool:
    return code == Code.OK

static func failure(
    failure_code: Code,
    failed_level_id: StringName,
    detail: String
) -> LevelLoadResult:
    var result := LevelLoadResult.new()
    result.code = failure_code
    result.level_id = failed_level_id
    result.technical_detail = detail
    return result
```

```gdscript
var result: LevelLoadResult = await loading_coordinator.load_level(manifest)

if not result.is_success():
    GameLog.error(
        DiagnosticEvent.LEVEL_LOAD_FAILED,
        DiagnosticContext.for_level(result.level_id),
        {
            &"code": result.code,
            &"detail": result.technical_detail,
        }
    )
    game_flow_controller.show_level_load_failure(result.level_id)
    return
```

A hot-path gameplay rejection uses an allocation-free enum:

```gdscript
enum GrappleRejection {
    NONE,
    NO_CANDIDATE,
    OUT_OF_RANGE,
    OCCLUDED,
    INVALID_SURFACE,
}
```

An invariant uses both a debug assertion and a release guard:

```gdscript
if _last_commit_step == physics_step:
    assert(false, "The kinematic motor committed twice in one physics step.")
    GameLog.error(
        DiagnosticEvent.MOTOR_DUPLICATE_COMMIT,
        DiagnosticContext.for_entity(entity_id, physics_step)
    )
    return
```

### Logging

**Format:** Human-readable structured records with stable levels, subsystem names, event codes, and correlation fields.

**Destinations:** Godot debugger and console, Godot-native rotating desktop logs under `user://logs/godot.log`, and a bounded development-only in-memory diagnostic history. No remote logging or analytics service.

Example output:

```text
[WARN][Projectile][PROJECTILE_SOURCE_INVALID] step=18420 level=arena_01 encounter=trial_02 run=7 entity=seed_11 execution=302 recovery=despawn
```

#### Standard context

Records include the relevant subset of:

- Physics step.
- Level ID.
- Encounter ID.
- Encounter run ID.
- Entity ID.
- Ability or execution ID.
- Subsystem.
- Stable event code.
- Reason or recovery code.

Stable event codes are constants rather than arbitrary prose. Optional detail fields are diagnostic-only and may never be parsed to control gameplay.

#### Log levels

| Level | Usage | Availability |
|---|---|---|
| `ERROR` | Operation failed, invariant violated, or safe progression cannot continue | Development and release |
| `WARN` | Unexpected condition occurred but recovered or degraded safely | Development and release |
| `INFO` | Sparse application, level, encounter, and checkpoint milestones | Development and release |
| `DEBUG` | Owner-boundary transitions, spawn decisions, and selected AI decisions | Debug builds and category-filtered |
| `TRACE` | Damage events, probes, candidate scores, and other potentially frequent detail | Debug builds only and disabled by default |

#### Mandatory rules

- Gameplay code uses one typed, one-way `GameLog` facade.
- Gameplay may write diagnostics but may never read logs or derive behavior from them.
- Only the owner that handles or escalates a failure emits its primary error record.
- Intermediate functions must not both log and propagate the same failure.
- Raw `print()`, `printerr()`, `push_warning()`, and `push_error()` calls are prohibited in gameplay code outside the logging facade.
- `DEBUG` and `TRACE` availability must be checked before constructing strings, dictionaries, or diagnostic context objects.
- Systems log state transitions, not unchanged state every process or physics tick.
- Repeated warnings and errors are deduplicated or rate-limited using stable scoped keys.
- Suppressed repetitions may produce a later summary count.
- Diagnostic records contain scalar snapshots and stable IDs, not references that retain Nodes or Resources.
- The in-memory history is bounded.
- No custom Godot `Logger`, custom synchronous file writer, or external service is introduced initially.
- Performance runs disable the overlay, world drawing, `DEBUG`, and `TRACE`.

#### Example

```gdscript
func _on_health_damaged(instance: DamageInstance) -> void:
    if not GameLog.is_enabled(
        GameLog.Level.TRACE,
        DiagnosticSystem.COMBAT
    ):
        return

    GameLog.write(
        GameLog.Level.TRACE,
        DiagnosticEvent.DAMAGE_APPLIED,
        DiagnosticContext.for_execution(
            entity_id,
            encounter_run_id,
            instance.execution_id
        ),
        {
            &"amount": instance.final_damage,
            &"health_after": health.current_health,
        }
    )
```

With `TRACE` disabled, the context and detail dictionary are not created.

### Configuration

**Approach:** Each category of configuration has one storage mechanism and one owner.

#### Configuration structure

| Configuration category | Authoritative storage | Examples |
|---|---|---|
| Engine and application settings | `project.godot` and `ProjectSettings` | Physics rate, Jolt, renderer, display defaults, InputMap defaults, named layers |
| Authored gameplay tuning | Immutable typed Resources in `res://` | Movement, grapple, attacks, enemies, AI policies, encounters, query profiles, audio cues |
| User preferences | Versioned `ConfigFile` at `user://settings.cfg`, owned by `SettingsService` | Mouse sensitivity, inversion, keyboard/mouse bindings, volume, display preferences |
| Runtime state | Owner-local runtime objects | Health, cooldowns, velocity, AI target, active execution, encounter participants |

#### Gameplay definitions

- One typed Resource is authored per reusable archetype, ability, policy, or profile, not per spawned instance.
- Definitions carry stable IDs and must pass content validation.
- Runtime code treats loaded definitions as read-only.
- Runtime health, cooldowns, AI state, execution state, and temporary modifiers may never be written into a shared Resource.
- Scenes export references to authoritative definitions rather than duplicating their tuning values.
- Derived data is resolved during initialization rather than through repeated configuration-layer lookups.
- Required invalid definitions block entity, encounter, or level activation through typed failures.
- Optional invalid presentation configuration uses a defined fallback and warns once.
- Generic dictionary-based override cascades are prohibited.
- Rare variants use explicit typed definition assets.
- There is no JSON/YAML gameplay registry, remote configuration, or live-balance service.
- Tuning uses the normal edit-play-reset loop: edit the version-controlled `.tres` asset, replay or reset the relevant scenario, evaluate it, and commit the successful definition.
- There is no live-tuning service or runtime mutation of production definitions.

#### Example

```gdscript
class_name EnemyDefinition
extends Resource

@export_group("Identity")
@export var definition_id: StringName

@export_group("Movement")
@export_range(0.0, 30.0, 0.1) var move_speed := 4.0
@export_range(0.0, 100.0, 0.1) var acceleration := 14.0
@export_range(0.0, 100.0, 0.1) var deceleration := 18.0

@export_group("Perception")
@export_range(0.0, 100.0, 0.1) var vision_range := 12.0
@export_range(1.0, 360.0, 1.0) var vision_angle_degrees := 110.0

@export_group("Behavior")
@export var ai_policy: AiPolicyDefinition

@export_group("Combat")
@export var attack_definition: AttackDefinition
```

```gdscript
class_name EnemyCoordinator
extends CharacterBody3D

@export var definition: EnemyDefinition

func initialize(context: EnemySpawnContext) -> EnemyInitializeResult:
    var validation := EnemyDefinitionValidator.validate(definition)

    if not validation.is_valid:
        return EnemyInitializeResult.invalid_definition(
            definition.definition_id,
            validation
        )

    movement.initialize(definition)
    perception.initialize(definition)
    combat.initialize(definition.attack_definition)
    ai.initialize(definition.ai_policy, context)
    return EnemyInitializeResult.success()
```

Values such as movement speed and vision range may not also remain as competing exports on the movement and perception components.

#### User settings

- Only `SettingsService` reads or writes `ConfigFile`.
- Other systems receive typed values or typed settings snapshots.
- ConfigFile keys and sections are private implementation details of `SettingsService`.
- Settings loading applies schema-version checks, defaults, validation, range clamping, and controlled migration.
- InputMap remains authoritative for factory bindings; user overrides are applied through `SettingsService`.
- Invalid user preferences fall back safely and warn once.
- Filesystem load and save errors use the agreed typed error-handling strategy.

#### Project settings

- Engine integration values remain in `project.godot`.
- Gameplay components may not make scattered global `ProjectSettings` queries.
- Application, input, physics, or level bootstrap owners read required engine values and supply typed dependencies.
- Windows-specific engine overrides use Godot project-setting feature overrides.
- No separate platform-profile system is introduced while Windows is the only target.
- Code constants are reserved for implementation invariants, not gameplay tuning.

### Event System

**Pattern:** Scoped, typed Godot signals for committed facts; direct typed methods for commands and queries. Synchronous delivery is the gameplay default. There is no global gameplay event bus or general message queue.

```text
LevelController
    ^ typed facts        | typed commands
EncounterController
    ^ typed facts        | typed commands
Entity coordinator
    ^ typed facts        | typed commands
Components and state machines
```

#### Communication rules

- Commands use direct imperative methods such as `request_attack()`, `apply_damage()`, `cancel_execution()`, and `request_despawn()`.
- Commands that can fail return typed domain results.
- Queries use direct typed methods or read-only snapshots.
- Signals report facts only after the emitter has committed its authoritative state.
- Signal names use past-tense facts such as `damaged`, `died`, `target_spotted`, `phase_changed`, and `execution_completed`.
- Callback names use `_on_<source>_<fact>()`.
- Signals remain within the smallest ownership scope that needs them.
- Low-level components emit to their entity coordinator.
- Entity coordinators emit participant facts to `EncounterController`.
- Encounters emit completion and reset facts to `LevelController`.
- Level and application services expose narrow facts to UI or application flow.
- Expected errors and request responses are not delivered through signals.

#### Payload and lifetime rules

- Signal arguments are statically typed.
- Payloads use primitives, enums, stable IDs, immutable snapshots, or narrow domain records.
- Same-lifetime local signals may carry a typed Node or component reference.
- Signals crossing entity, encounter, or level boundaries use stable IDs and relevant run or execution IDs.
- Late cross-boundary events are rejected using their encounter run ID.
- Generic dictionaries, string event names, arbitrary metadata, and large mutable object graphs are prohibited.
- Signals do not mirror state every frame or physics step.
- High-frequency consumers read typed presentation or diagnostic snapshots instead.

#### Ordering and deferral

- Gameplay signals are synchronous by default.
- Subscribers may not depend on their connection order.
- Operations that require ordering are coordinated through direct calls by the responsible owner.
- Signals are not used for veto, validation, request/response, or recovery selection.
- `CONNECT_DEFERRED` and `call_deferred()` are limited to engine-required scene-tree operations, presentation refreshes, window/input edges, and development tooling.
- Deferred idle-time callbacks may not define authoritative hit, movement, ability, or encounter timing.
- Gameplay-critical work runs in its declared simulation phase.
- Selected boundary facts may be copied into the diagnostic ring buffer, but there is no gameplay event replay or event-sourcing system.

#### Connection ownership

- The coordinator composing a scope owns its gameplay connections.
- Connections are created once during explicit initialization or scene readiness.
- Direct typed signal connections are preferred over string signal names.
- Long-lived anonymous lambdas are avoided.
- Rebinding code prevents duplicate connections and disconnects old sources explicitly.
- Replacing an encounter `RuntimeRoot` destroys its scoped emitters and connections together.

#### Example

```gdscript
class_name CombatHealth
extends Node

signal damaged(instance: DamageInstance)
signal health_changed(
    previous_health: float,
    current_health: float,
    maximum_health: float
)
signal died(instance: DamageInstance)

func apply_damage(request: DamageRequest) -> DamageApplyResult:
    var result := _resolve_damage(request)

    if not result.was_applied:
        return result

    var previous_health := current_health
    current_health = maxf(0.0, current_health - result.final_damage)

    damaged.emit(result.damage_instance)
    health_changed.emit(
        previous_health,
        current_health,
        maximum_health
    )

    if current_health <= 0.0:
        died.emit(result.damage_instance)

    return result
```

```gdscript
func initialize(health: CombatHealth) -> void:
    assert(not health.died.is_connected(_on_health_died))
    health.died.connect(_on_health_died)

func _on_health_died(instance: DamageInstance) -> void:
    action_coordinator.cancel_all(AttackCancelReason.OWNER_DIED)
    participant_died.emit(
        entity_id,
        encounter_run_id,
        instance.source
    )
```

### Debug and Development Tools

**Strategy:** A lean, modular, development-only diagnostics layer. It is incremental, demand-driven, observational, and dormant unless explicitly activated.

The tool list is a capability envelope rather than an upfront implementation checklist. A diagnostic module is added alongside its gameplay system only when it materially assists verification or investigation.

#### Core debug spine

- `DebugToolsController` composed only in debug builds.
- Persistent `DebugOverlayLayer` under `UIRoot`.
- Named `debug_overlay_toggle` InputMap action, initially bound to F3.
- Typed read-only diagnostic snapshot convention.
- Existing grapple telemetry migrated into that convention.
- Bounded diagnostic/log history.
- Manual local diagnostic capture.
- A small finite command surface routed through normal owners.
- Godot profiler and custom-monitor integration.

#### Diagnostic modules

Modules are added only as their corresponding systems exist:

- Session and performance.
- Player motor and semantic channels.
- ContactFrame and physics queries.
- Grapple targeting and rejection.
- Ability and combat execution.
- Encounter lifecycle and participants.
- Selected AI intent, candidates, and utility scores.
- Audio cue and concurrency state.

Hidden panels do not request snapshots or format text. Visible panels refresh at a throttled presentation rate, approximately 20 Hz where appropriate.

#### No duplicate computation

Diagnostics expose results already calculated by gameplay.

- Grapple diagnostics read the authoritative targeting result; they do not issue another query.
- Motor diagnostics expose the committed semantic-channel results; they do not recalculate motion.
- AI diagnostics retain the last normal planning result; they do not rerun planning for display.
- Encounter diagnostics read the owner's participant registry; they do not scan groups or reconstruct ownership.
- Performance monitor callbacks return maintained counters; they do not scan the scene tree.
- Snapshot providers contain scalar copies and stable IDs, not live references that retain gameplay objects.

#### World-space diagnostics

Optional, bounded categories may draw:

- Contact normals.
- Ground and wall sweeps.
- Grapple candidate and occlusion rays.
- Authoritative grapple target.
- Hit and projectile query shapes.
- Selected AI probes, candidates, and paths.
- Encounter bounds.

World drawing is disabled by default, category-filtered, selected-entity-focused, primitive-capped, and disabled during performance measurement. It may not perform additional physics or AI work.

#### Development commands

The initial finite command set may include:

- Reset current encounter.
- Respawn at current checkpoint.
- Reload current level.
- Toggle player invulnerability.
- Pause or resume AI decisions.
- Select a diagnostic entity.
- Capture diagnostics.

Commands call `LevelController`, `EncounterController`, or another normal owner. They may not mutate private component fields or use arbitrary reflection. A command that changes gameplay marks the diagnostic context as debug-modified.

There is no:

- General text console.
- Arbitrary command language.
- Runtime script evaluation.
- Universal reflection inspector.
- Custom full editor suite.
- Live gameplay tuning.
- Remote telemetry backend.
- Gameplay event replay system.

#### Diagnostic capture

Manual capture writes a bounded machine-readable report under `user://diagnostics/`. It may include:

- Build, level, encounter, run, and seed identifiers.
- Physics step.
- Relevant definition and query-profile IDs.
- Selected player, motor, grapple, ability, encounter, or AI snapshots.
- Recent structured log records.
- Recent command frames when tracing is explicitly enabled.
- Aggregated performance counters.
- Whether debug commands modified the run.

Diagnostic JSON is output only; it is not gameplay configuration and is never loaded to drive gameplay. Nothing is uploaded automatically.

#### Performance monitors

Custom Godot monitors expose maintained O(1) counters such as:

```text
Game/ActiveEnemies
Game/ActiveProjectiles
Game/PhysicsQueriesPerStep
Game/AIReplansPerSecond
Game/EncounterSpawnFailures
```

Monitor callbacks may not perform scene-tree searches, physics queries, allocations proportional to entity count, or other hidden work.

#### Activation and release rules

```gdscript
func compose_debug_tools() -> void:
    if not OS.has_feature("debug"):
        return

    var debug_tools := DEBUG_TOOLS_SCENE.instantiate()
    app_root.add_child(debug_tools)
    debug_tools.initialize(game_flow_controller, ui_root)
```

- Debug/release composition is decided at the application root.
- Release builds do not instantiate the overlay, world drawing, debug commands, diagnostic history, or debug snapshot consumers.
- Development-only assets and tests are excluded from release exports where practical.
- `DEBUG` and `TRACE` logging are disabled in release.
- Performance acceptance runs use a release-like build with overlays, world drawing, captures, and verbose logging disabled.
- Debug tooling may add deliberate overhead only when explicitly enabled for investigation.

## Project Structure

### Organization Pattern

**Pattern:** Domain-driven hybrid

Runtime code, scenes, gameplay definitions, and behavior resources are organized by owning game domain. Raw art, audio, fonts, materials, shaders, and UI media are organized by asset type and then by subject. Tests mirror runtime domains, third-party dependencies remain isolated under `addons/`, and shared infrastructure is admitted only when multiple domains depend on the same stable contract.

This structure prevents the project from fragmenting each feature across global `scripts/`, `scenes/`, `resources/`, and `ai/` trees. A feature's implementation can be understood and changed from one domain directory.

### Directory Structure

This is the approved target structure. The current prototype continues to use legacy `scripts/`, `scenes/`, `resources/`, and `ai/` roots until each domain is migrated with its Godot UIDs and dependencies intact.

```text
testgame/
├── addons/
│   ├── godot_ai/                         # Development-only Godot integration
│   ├── gut/                              # Automated test framework
│   ├── limboai/                          # LimboAI extension and editor integration
│   └── terrain_3d/                       # Optional terrain dependency
│
├── game/
│   ├── app/
│   │   ├── app_root.tscn
│   │   ├── app_root.gd
│   │   ├── flow/                         # Boot and application-state transitions
│   │   ├── loading/                      # Threaded boundary loading
│   │   ├── settings/                     # User settings and ConfigFile persistence
│   │   ├── logging/                      # GameLog facade and event codes
│   │   └── debug/                        # Development-only diagnostics
│   │
│   ├── player/
│   │   ├── player.tscn
│   │   ├── player.gd
│   │   ├── input/
│   │   │   ├── player_command.gd
│   │   │   └── player_input_source.gd
│   │   ├── motor/
│   │   │   ├── player_motor.gd
│   │   │   ├── motor_phase.gd
│   │   │   └── definitions/
│   │   ├── locomotion/
│   │   │   └── states/
│   │   ├── abilities/
│   │   │   ├── ability_coordinator.gd
│   │   │   ├── attack_lifecycle/
│   │   │   │   ├── player_attack_ready_state.gd
│   │   │   │   ├── player_attack_windup_state.gd
│   │   │   │   ├── player_attack_active_state.gd
│   │   │   │   └── player_attack_recovery_state.gd
│   │   │   ├── grapple/
│   │   │   │   ├── grapple_controller.gd
│   │   │   │   ├── grapple_query.gd
│   │   │   │   ├── player_grappling_state.gd
│   │   │   │   ├── definitions/
│   │   │   │   └── presentation/
│   │   │   ├── melee/
│   │   │   │   ├── player_melee_attack.gd
│   │   │   │   ├── melee_hitbox.tscn
│   │   │   │   ├── definitions/
│   │   │   │   └── presentation/
│   │   │   └── ranged/
│   │   │       ├── player_ranged_attack.gd
│   │   │       ├── aiming/
│   │   │       ├── definitions/
│   │   │       └── presentation/
│   │   └── presentation/
│   │
│   ├── combat/
│   │   ├── abilities/                    # Actor-neutral lifecycle contracts
│   │   ├── attacks/                      # Attack schemas and execution mechanics
│   │   ├── damage/                       # Snapshots, modifiers, and resolution
│   │   ├── effects/                      # Scoped hazards, fields, links, statuses, and surface effects
│   │   ├── health/                       # Health and death components
│   │   ├── hit_queries/                  # Hitboxes, hurtboxes, and attack queries
│   │   ├── projectiles/                  # Projectile runtime and attribution
│   │   └── telegraphs/                   # Ability-space presenters and reusable fallback warnings
│   │
│   ├── enemies/
│   │   ├── common/
│   │   │   └── action_lifecycle/         # Shared enemy action-HSM states
│   │   ├── ai/
│   │   │   ├── perception/
│   │   │   ├── traversal/
│   │   │   └── shared_tasks/
│   │   └── archetypes/
│   │       ├── climber/
│   │       │   ├── climber.tscn
│   │       │   ├── climber.gd
│   │       │   ├── behavior/
│   │       │   ├── definitions/
│   │       │   └── presentation/
│   │       └── flyer/
│   │           ├── flyer.tscn
│   │           ├── flyer.gd
│   │           ├── behavior/
│   │           ├── definitions/
│   │           └── presentation/
│   │
│   ├── encounters/
│   │   ├── encounter_runtime_root.tscn
│   │   ├── encounter_runtime_root.gd
│   │   ├── spawning/
│   │   ├── ownership/
│   │   └── definitions/
│   │
│   ├── levels/
│   │   ├── level_runtime_root.tscn
│   │   ├── level_runtime_root.gd
│   │   ├── catalog/
│   │   ├── checkpoints/                  # In-memory restart definitions and runtime state
│   │   ├── geometry/
│   │   ├── objectives/                   # Typed level-completion conditions
│   │   ├── rewards/                      # Health/coin tables, grants, and pickups
│   │   └── content/
│   │       └── grapple_tutorial/
│   │
│   ├── presentation/
│   │   ├── camera/
│   │   ├── ui/
│   │   │   ├── ui_root.tscn
│   │   │   ├── hud/
│   │   │   ├── menus/
│   │   │   └── transitions/
│   │   ├── audio/
│   │   └── vfx/
│   │
│   └── shared/
│       ├── contracts/
│       ├── identifiers/
│       ├── results/
│       ├── timing/
│       └── physics/
│
├── assets/
│   ├── source/
│   │   ├── .gdignore
│   │   ├── art/
│   │   │   ├── characters/
│   │   │   ├── environments/
│   │   │   ├── ui/
│   │   │   └── vfx/
│   │   └── audio/
│   │       ├── music/
│   │       └── sfx/
│   │
│   ├── art/
│   │   ├── characters/
│   │   │   ├── shared/
│   │   │   │   ├── rigs/
│   │   │   │   └── animations/
│   │   │   ├── player/
│   │   │   │   ├── models/
│   │   │   │   ├── rigs/
│   │   │   │   ├── animations/
│   │   │   │   └── textures/
│   │   │   └── enemies/
│   │   │       ├── shared/
│   │   │       ├── climber/
│   │   │       │   ├── models/
│   │   │       │   ├── rigs/
│   │   │       │   ├── animations/
│   │   │       │   └── textures/
│   │   │       └── flyer/
│   │   │           ├── models/
│   │   │           ├── rigs/
│   │   │           ├── animations/
│   │   │           └── textures/
│   │   ├── environments/
│   │   │   ├── shared/
│   │   │   │   ├── modular_geometry/
│   │   │   │   ├── props/
│   │   │   │   └── textures/
│   │   │   └── worlds/
│   │   └── vfx/
│   │       ├── meshes/
│   │       ├── textures/
│   │       └── flipbooks/
│   │
│   ├── audio/
│   │   ├── music/
│   │   ├── ambience/
│   │   │   └── worlds/
│   │   └── sfx/
│   │       ├── player/
│   │       ├── combat/
│   │       ├── enemies/
│   │       │   ├── climber/
│   │       │   └── flyer/
│   │       ├── environment/
│   │       └── ui/
│   ├── fonts/
│   ├── materials/
│   │   ├── characters/
│   │   ├── environments/
│   │   ├── vfx/
│   │   └── ui/
│   ├── shaders/
│   │   ├── characters/
│   │   ├── environments/
│   │   ├── vfx/
│   │   └── ui/
│   └── ui/
│       ├── cursors/
│       ├── icons/
│       ├── hud/
│       ├── menus/
│       └── themes/
│
├── tests/
│   ├── app/
│   ├── player/
│   ├── combat/
│   ├── enemies/
│   ├── encounters/
│   ├── levels/
│   ├── presentation/
│   ├── shared/
│   ├── integration/
│   ├── fixtures/
│   └── performance/
│
├── tools/
│   ├── editor/
│   ├── validators/
│   └── build/
│
├── docs/
│   ├── .gdignore
│   └── concept_art/
│
├── .agents/                            # Project AI-agent configuration
├── .codex/                             # Codex project configuration
├── .godot/                             # Generated and ignored engine state
├── _bmad/                              # BMad workflow infrastructure
├── _bmad-output/                       # Generated design and planning artifacts
├── project.godot
├── icon.svg
├── LICENSE
├── .editorconfig
├── .gitattributes
└── .gitignore
```

The current project still launches `res://main.tscn`. The target bootstrap change points `project.godot` to `game/app/app_root.tscn` after AppRoot exists and its loading/restart tests pass; target architecture has no permanent root-level `main.tscn`.

### System Location Mapping

| System | Location | Responsibility |
|---|---|---|
| Application lifetime | `game/app/` | Compose persistent systems and own replacement of level roots |
| Application and level flow | `game/app/flow/` | Boot, menu, load, play, restart, and exit transitions |
| Threaded loading | `game/app/loading/` | Boundary loading, status polling, activation, and failure recovery |
| User settings | `game/app/settings/` | Versioned `ConfigFile` persistence |
| Logging | `game/app/logging/` | Typed `GameLog` facade and stable log codes |
| Diagnostics | `game/app/debug/` | Development-only snapshots, overlay, drawing, and finite commands |
| Input capture | `game/player/input/` | Convert keyboard and mouse input into typed command frames |
| Player motor | `game/player/motor/` | Sole player motion authority and semantic motor phases |
| Player locomotion | `game/player/locomotion/` | Movement HSM states other than feature-owned grapple behavior |
| Player ability coordination | `game/player/abilities/` | Arbitrate grapple, melee, ranged, and cancellation policies |
| Grapple | `game/player/abilities/grapple/` | Targeting, simulation, grapple state, definitions, and presentation |
| Player attack lifecycle | `game/player/abilities/attack_lifecycle/` | Ready, windup, active, recovery, and cancellation states |
| Player melee | `game/player/abilities/melee/` | Melee intent, hitbox composition, definitions, and presentation |
| Player ranged | `game/player/abilities/ranged/` | Aim resolution, firing intent, definitions, and presentation |
| Ability contracts | `game/combat/abilities/` | Actor-neutral phases, execution IDs, cancellation, and completion |
| Attacks | `game/combat/attacks/` | Reusable attack schemas and execution mechanics |
| Damage | `game/combat/damage/` | Damage snapshots, modifiers, types, and resolved results |
| Effects | `game/combat/effects/` | Scoped hazards, directional fields, target-owned links/statuses, and surface effects |
| Health | `game/combat/health/` | Health state, accepted damage, committed death, and signals |
| Hit detection | `game/combat/hit_queries/` | Hitboxes, hurtboxes, overlaps, shape casts, and profiles |
| Projectiles | `game/combat/projectiles/` | Movement, collision, source snapshots, attribution, and termination |
| Telegraphs | `game/combat/telegraphs/` | Present authoritative ability space with reusable prototype fallbacks |
| Shared enemy actor | `game/enemies/common/` | Reusable enemy composition and action interfaces |
| Enemy action HSM | `game/enemies/common/action_lifecycle/` | Shared action phase states used across archetypes |
| Enemy perception | `game/enemies/ai/perception/` | Vision, target memory, and line-of-sight inputs |
| Enemy traversal discovery | `game/enemies/ai/traversal/` | Geometry-derived climb, landing, and flight positions |
| Shared LimboAI tasks | `game/enemies/ai/shared_tasks/` | Tasks proven reusable across multiple archetypes |
| Archetype AI | Archetype `behavior/` directory | Archetype-specific behavior trees and custom tasks |
| Climber | `game/enemies/archetypes/climber/` | Climber scene, policy, definitions, behavior, and presentation |
| Flyer | `game/enemies/archetypes/flyer/` | Flyer scene, policy, definitions, behavior, and presentation |
| Encounter lifetime | `game/encounters/` | Replaceable encounter root and run identity |
| Scoped spawning | `game/encounters/spawning/` | Validate and attach spawns to explicit cleanup scopes |
| Spawn ownership | `game/encounters/ownership/` | Track spawned objects without owning their behavior |
| Level runtime | `game/levels/` | Own the active level and connect it to application flow |
| Level catalog | `game/levels/catalog/` | Stable level IDs, manifests, and dependencies |
| Checkpoints | `game/levels/checkpoints/` | Authored checkpoint definitions and in-memory restart state |
| Geometry semantics | `game/levels/geometry/` | Shared traversal interpretation of authored geometry |
| Objectives | `game/levels/objectives/` | Consume scoped facts and report typed level-completion conditions |
| Rewards | `game/levels/rewards/` | Resolve and commit current health/coin reward grants and pickups |
| Level content | `game/levels/content/` | Level scenes, navigation, terrain, and local authored data |
| Camera | `game/presentation/camera/` | Built-in camera and spring-arm presentation |
| UI and HUD | `game/presentation/ui/` | Persistent UI shell and read-only presentation of gameplay state |
| Audio | `game/presentation/audio/` | Semantic cues, buses, emitters, and voice limits |
| Shared VFX | `game/presentation/vfx/` | Cross-domain presentation-only effects |
| Domain presentation | Owning feature's `presentation/` | Animation, VFX, and audio adapters for that feature |
| Timing | `game/shared/timing/` | Shared simulation-time primitives used across domains; gameplay durations remain seconds |
| Stable IDs | `game/shared/identifiers/` | Entity, execution, run, definition, and source identities |
| Shared results | `game/shared/results/` | Small typed results used across domains |
| Shared contracts | `game/shared/contracts/` | Stable interfaces required by multiple domains |
| Collision matrix | `project.godot` | Named broad collision eligibility |
| Query profiles | `game/shared/physics/` | Immutable typed physics-query Resources |
| Engine plug-ins | `addons/` | Third-party implementation only |
| Runtime assets | `assets/` excluding `source/` | Godot-importable presentation content |
| Editable asset masters | `assets/source/` | Godot-ignored DCC source files |
| Tests | `tests/` | Domain-mirrored verification, fixtures, integration, and benchmarks |
| First-party tools | `tools/` | Editor helpers, validators, and build utilities |
| Human documentation | `docs/` | Non-runtime reference material and concept art |
| Save/RPG/networking | No reserved directory | Explicitly deferred until deliberately introduced |

### Feature and Milestone Mapping

No epic artifact currently exists, so `DEVELOPMENT_ROADMAP.md` is the authoritative feature-sequencing source. A feature is architecturally mapped only when its owner, reusable patterns, and implementation evidence are explicit.

| Milestone | Primary location | Required patterns and contracts | Implementation evidence | Status |
|---|---|---|---|---|
| M0 - Traversal sandbox | `game/player/input/`, `motor/`, `locomotion/`, `abilities/grapple/`, `game/shared/physics/` | Command frames, Semantic Motor Influence Pipeline, `Grappleable3D`, `ContactFrame`, named collision/query profiles | Complete traversal route; moving target; non-flat wall cases; 35 m active boundary; equivalent real-time behavior at 60 Hz and diagnostic 120 Hz | Current prototype, target refactor required |
| M1 - Combat contract | Player melee plus `game/combat/abilities/`, `attacks/`, `damage/`, `health/`, and `hit_queries/` | Simulation-Authored Ability Lifecycle, `MovementCombatContext`, `ImpactContext`, attack/damage separation, shared ability space | Moving approach produces an intentional outcome; warnings align with hits; allowed movement states work; death/reset is reliable | Current prototype, contracts incomplete |
| M2 - Combat pressure and ability vocabulary | `game/combat/effects/`, `telegraphs/`, `projectiles/`, hit queries, and enemy action/AI domains | Six composable implementation families, all four novel patterns, scoped spawns, typed motor influences, cancellation policy | All 17 mechanics run independently; representative combinations remain readable and survivable; source death and reset clean up correctly | Target capability milestone |
| M3 - Encounter and level shell | `game/encounters/`, `game/levels/objectives/`, `checkpoints/`, `rewards/`, application loading, and HUD | Encounter run identity, domain spawners, `LevelObjective`, checkpoint runtime, reward grants, manifests | Enter, fight, collect, die, restart, and complete without scene-specific progression or stale runtime state | Target slice milestone |
| M4 - Boss slice | Boss archetype, common enemy action lifecycle, weak-point hit queries, objectives, and rewards | Ability lifecycle, vertical tactics, scoped spawning, ability space, `ImpactContext` weak-point facts | Readable attack-response loop; movement-derived opening; boss death, reward, exit, and replay reset correctly | Target slice milestone |
| M5 - Tutorial validation | `game/levels/content/grapple_tutorial/`, objectives, and checkpoints | Production traversal contracts plus a typed tutorial-stage objective | Every lesson detects its intended action; recovery is local; tutorial uses production traversal behavior | Existing prototype, later validation pass |
| M6 - RPG expansion | No current directory | Explicitly deferred; current stable IDs and reward grants are not an inventory or save framework | Reconsider only after the traversal-combat-level loop is proven | Deferred |

#### M2 implementation families

The six families are composable implementation recipes, not six universal base classes and not mutually exclusive categories. Every family reuses simulation-authored lifecycle, immutable definitions, shared ability-space snapshots, named query profiles, run-scoped attribution, and one-way presentation.

| Family | Owns | Primary mechanics |
|---|---|---|
| Spatial Threat Delivery | Targeting or prediction, authoritative affected space, hit query/projectile/hazard delivery, and damage snapshot | Predictive mark, direct lane, arcing bombardment, rotating sweep, airburst and aerial mines |
| Motor Influence | Sustained acceleration, one-shot impulse, constraint/redirection, or locomotion gating submitted to `PlayerMotor` | Adhesive surfaces, harpoon pull, knockback, wind and suction |
| Scoped World Effect | A runtime object, volume, obstacle, or surface occurrence with placement, run identity, duration, collision, and cleanup | Temporary obstacles, visibility volumes, gas, surface states, some adhesive patches and mines |
| Target-Owned Status or Link | A recipient-owned effect with source attribution, stacking, break, duration, source-death, and reset rules | Harpoon tether after impact, anchor modification, support tether and support buffs |
| Targetability and Deception | Explicit target, damage, and grapple eligibility for scoped nonstandard candidates | Decoy or echo |
| Contextual AI Action | Read a bounded tactical snapshot, select a normal ability, and request it through the ability coordinator | Anti-wall reach and other condition-selected attacks |

Families combine rather than duplicate behavior. A harpoon uses Spatial Threat Delivery, then creates a Target-Owned Status or Link, which submits a Motor Influence. An adhesive patch combines Scoped World Effect with Motor Influence. A damage-gas cloud combines Scoped World Effect with periodic Spatial Threat Delivery. An anti-wall harpoon adds Contextual AI Action to the ordinary harpoon composition.

#### M2 mechanic mapping

| Mechanic | Implementation mapping | Required evidence |
|---|---|---|
| 1. Adhesive surfaces | Scoped surface effect submits typed acceleration, air-control, slide, or wall-access influences through the motor | Entering and leaving restores state exactly; the surface remains grappleable by default |
| 2. Temporary obstacle growth | Telegraph followed by a run-scoped collision entity from a typed effect spawner; default grapple response unless explicitly modified | Cannot appear silently inside the player; is avoidable, destructible, or usable as a route; reset removes it |
| 3. Harpoon or tether | Projectile or melee delivery creates a recipient-owned tether effect that submits sustained or constraint influences | Cover or link break works; source-death policy works; active grapple is not silently cancelled |
| 4. Knockback and displacement | Accepted impact creates a stable-execution-ID one-shot motor impulse | Applies exactly once; preserves a recovery opportunity; representative combinations do not create control chains |
| 5. Predictive mark | Predictor locks a frozen `AbilitySpatialSnapshot` at the declared phase | Direction or altitude change can defeat it; displayed and affected positions match |
| 6. Direct lane shot | Lane snapshot plus line-of-sight query and projectile, ray, or shape delivery | Cover and lane crossing work; warning width and collision width match |
| 7. Arcing bombardment | Typed trajectory plus locked impact point and impact-area snapshot | Landing indicator matches impact; delivery remains valid without its source node |
| 8. Rotating plane or line sweep | Source-following spatial binding whose rotation is derived from simulation phase progress | Duration and angular motion remain equivalent at 60/120 Hz; readable crossing options exist |
| 9. Visibility obstruction | Run-scoped visibility volume; presentation limits sight while typed query policy owns any real line-of-sight change | Never becomes an unreadable full-screen blind; nearby geometry, grapple feedback, and threat cues remain readable |
| 10. Damage gas or drifting hazard | Scoped hazard volume with simulation-timed delivery pulses and source snapshot | Boundary and ramp-up are readable; pulse cadence is rate-independent; no damage survives reset |
| 11. Airburst and aerial mine lattice | Scoped projectile or hazard entities using authoritative aerial shapes | Lateral or altitude response remains available; every mine expires or resets cleanly |
| 12. Anti-wall reach | AI reads locomotion context and requests a normal committed `AttackDefinition`; it never mutates player state directly | Highly readable, limited to intended enemies, and wall use remains tactically valuable |
| 13. Anchor modification | Target-owned runtime effect changes typed `Grappleable3D` response values through fixed precedence | Local, temporary, telegraphed, and restores the original response without mutating shared Resources |
| 14. Support tether | Source-attributed link applies typed healing, armor, recovery, resistance, or stagger support to its recipient | Attacking support, breaking line of sight, relay destruction, or source death removes it according to policy |
| 15. Decoy or echo | Run-scoped target candidate with explicit targetability, damage, and grapple-response contracts | Has a consistent tell; selection is deterministic; cleanup leaves no stale candidate |
| 16. Wind, suction, and directional vectors | Directional field submits a sustained semantic motor influence | Never writes velocity directly; lateral grapple, jump, release, or wall movement provides counterplay |
| 17. Surface state changes | Surface-owned runtime state exposes typed movement, damage, query, and presentation responses | Stacking is deterministic; expiry/reset restores the surface; route value changes without permanent removal |

Every M2 prototype also declares its movement or combat question, windup and telegraph, affected space or target, primary counter, recovery option, grapple/wall interactions, source-death policy, encounter-reset policy, immutable tuning definition, focused automated contract test, and short manual counterplay/readability test.

The Last Garden roster is a provisional consumer map rather than a binding content allocation: Rootstalker may consume climber and anti-wall pressure; Spore Kite may consume aerial, arcing, predictive, or gas threats; Mycelial Weaver may consume route, surface, anchor, and support effects; Bloombound Hunter may consume mixed direct and melee pressure; Garden Heart may combine sweep, growth, airburst, and weak-point mechanics. Playtests select the production subset without changing the shared family contracts.

### Naming Conventions

#### Files and Directories

- Directories use `snake_case`.
- GDScript files use `snake_case.gd`.
- Scene files use `snake_case.tscn`.
- Resource instances use `snake_case.tres`.
- Shader files use `snake_case.gdshader`.
- Test scripts use `test_<subject>.gd`.
- Test scenes use `<subject>_fixture.tscn`.
- A script declaring `class_name` uses the snake-case form of that class as its filename.
- Filenames remain globally understandable even when their directory is not visible.
- Ambiguous names such as `manager.gd`, `data.gd`, `state.gd`, `utils.gd`, and `helper.gd` are prohibited.

#### Code Elements

| Element | Convention | Example |
|---|---|---|
| Registered classes | `PascalCase` | `PlayerMotorDefinition` |
| Functions | `snake_case` | `request_attack()` |
| Variables | `snake_case` | `current_execution` |
| Private members | Leading underscore | `_active_projectiles` |
| Constants | `UPPER_SNAKE_CASE` | `MAX_GRAPPLE_DISTANCE` |
| Enum types | `PascalCase` | `AbilityPhase` |
| Enum values | `UPPER_SNAKE_CASE` | `AbilityPhase.WINDUP` |
| Signals | Past-tense `snake_case` facts | `damage_applied` |
| Signal handlers | `_on_<source>_<signal>()` | `_on_health_damage_applied()` |
| Booleans | `is_`, `has_`, `can_`, or `should_` | `can_grapple` |
| Scene nodes | `PascalCase` | `EncounterRuntimeRoot` |
| Stable IDs | Lowercase dotted namespaces | `ability.player.basic_melee` |
| Log event codes | Lowercase dotted namespaces | `combat.damage.rejected` |
| Input actions | Semantic `snake_case` | `attack_melee` |
| Collision names | Singular semantic `snake_case` | `grapple_target` |

Commands begin with verbs such as `request_`, `apply_`, or `cancel_`. Queries use `can_`, `has_`, `is_`, `find_`, or `get_`. Signals describe committed facts rather than requests.

Authored immutable Resource classes use descriptive suffixes such as `Definition`, `Manifest`, `Profile`, or `CueDefinition`. Mutable runtime classes describe their role explicitly, such as `AbilityExecution`, `DamageSnapshot`, `EncounterRuntime`, or `TargetMemory`.

Timing and coordinate names expose their semantics:

```text
windup_seconds
active_seconds
recovery_seconds
cooldown_seconds
elapsed_seconds
animation_blend_seconds
target_world_position
grapple_local_offset
aim_world_direction
```

Ambiguous names such as `windup_time`, `position`, or `direction` are not used across system boundaries. Serialized duration fields identify seconds explicitly with the `_seconds` suffix.

Stable IDs are authored explicitly and never derived from filenames, display names, scene paths, or node paths.

LimboAI custom tasks use action or condition names such as:

```text
move_toward_target.gd
select_flight_position.gd
has_valid_target.gd
is_target_in_attack_range.gd
```

Behavior-tree resources include the owning archetype and purpose:

```text
climber_combat_behavior.tres
flyer_combat_behavior.tres
climber_retreat_subtree.tres
```

#### Game Assets

| Asset | Convention | Example |
|---|---|---|
| Models | `<subject>[_<variant>].glb` | `climber_body.glb` |
| Animations | `<actor>_<action>[_<variant>]` | `player_melee_light_01` |
| Looping animations | Add `_loop` | `climber_climb_up_loop` |
| Textures | `<subject>_<channel>` | `climber_body_normal.png` |
| Materials | `<subject>_<purpose>_material.tres` | `grapple_rope_material.tres` |
| Shaders | `<effect>_<purpose>.gdshader` | `grapple_rope_unlit.gdshader` |
| Sound effects | `<owner>_<action>[_<variant>]` | `player_grapple_attach_01.wav` |
| Music | `<context>_<purpose>[_loop]` | `last_garden_exploration_loop.ogg` |
| UI media | `<feature>_<element>_<state>` | `grapple_cursor_available.svg` |

Texture channels use the standard suffixes `_base_color`, `_normal`, `_orm`, `_emission`, and `_mask`.

Rig-bound animations remain with their owning character or shared rig. Animation names use lowercase `snake_case` without spaces. Runtime-ready models use `.glb`; editable Blender and other DCC source files remain under `assets/source/` and are ignored by Godot.

### Architectural Boundaries

- Every behavior has one explicit domain owner.
- A domain owns its scripts, scenes, immutable definitions, and domain-specific presentation adapters.
- The node that instantiates a system does not automatically own that system's files.
- `AppRoot` is a composition owner, not a global service locator or collection of unrestricted managers.
- Commands and queries use typed direct calls. Scoped signals report committed facts upward.
- No global gameplay event bus, generic event queue, or root `events/` directory is permitted.
- Only the player motor may commit player movement.
- Grapple, melee, and ranged attacks are explicit player abilities under `game/player/abilities/`.
- Actor-neutral attack, damage, health, hit-query, and projectile mechanics belong under `game/combat/`.
- Player and enemy live action state remains owner-local even when it implements shared phase contracts.
- LimboAI binaries remain under `addons/limboai/`; project behavior trees and tasks stay with their enemy domain or archetype.
- Shared enemy tasks move into `game/enemies/ai/shared_tasks/` only after more than one archetype uses them.
- Gameplay Resources are immutable definitions during play and stay beside the behavior they configure.
- Mutable health, cooldown, target memory, ability execution, and encounter state never live in shared Resources.
- `game/shared/` accepts only stable contracts used by multiple domains and cannot contain generic helpers, managers, or mutable global state.
- Broad collision eligibility belongs to the named matrix in `project.godot`; gameplay query meaning belongs to immutable typed profiles.
- Level scenes, navigation, Terrain3D data, encounter placement, and gameplay collision geometry remain with the owning level.
- Raw presentation media belongs in `assets/`; gameplay definitions never move into an `assets/data/` directory.
- Editable DCC masters remain in Godot-ignored `assets/source/`; runtime scenes reference exported assets only.
- Concept art and human documentation remain outside runtime content under Godot-ignored `docs/`.
- Animation, audio, VFX, camera, UI, and debug code may observe gameplay but cannot author authoritative gameplay phases or results.
- Combat-critical content is loaded at explicit boundaries and cannot be synchronously loaded for the first time during combat.
- Tests mirror runtime domains, while cross-domain integration fixtures remain explicit under `tests/integration/` and `tests/fixtures/`.
- First-party editor and validation code belongs under `tools/`; first-party gameplay code never enters `addons/`.
- Deferred save, RPG, inventory, networking, narrative, and open-world streaming systems receive no speculative directories or abstractions.
- The existing `scripts/`, `scenes/`, `resources/`, `ai/`, and `materials/` roots are retired through staged Godot-aware migration rather than a blind bulk move.
- Resource moves must preserve Godot UIDs and update `.tscn` and `.tres` dependencies before the old paths are removed.
- The third-party root `demo/` content is not production content and cannot be referenced by shipped scenes.

## Implementation Patterns

These patterns ensure that AI agents implement gameplay systems consistently, preserve established ownership boundaries, and do not introduce competing sources of truth.

### Novel Patterns

#### Semantic Motor Influence Pipeline

**Purpose:** Allow locomotion, grapple pull, attacks, knockback, wind, surface effects, and connection constraints to affect player movement without allowing multiple systems to write velocity or move the player independently.

**Components:**

- `PlayerMotor`: Sole authority for final `CharacterBody3D.velocity` and the single `move_and_slide()` call.
- `PlayerCommandFrame`: Immutable player command input for the current physics step.
- Locomotion state: Supplies base movement and gravity intent.
- Ability controllers: Submit grapple pull, attack movement, or other ability influences.
- External-effect components: Submit knockback, wind, launch, and environmental influences.
- Constraint providers: Submit restrictions such as the active-grapple maximum-range constraint.
- `ContactFrame`: Shared authoritative interpretation of ground, walls, and other movement contacts.
- Motor diagnostics: Expose submitted channels and resolved velocity in development builds.

**Semantic phases:**

1. Terminal commands
2. State gating and interrupts
3. Base locomotion and gravity
4. Sustained influences
5. One-shot impulses
6. Constraints and redirections
7. Caps and final movement commit

Systems submit through typed phase-specific methods. They do not assign arbitrary numeric priorities.

**Data flow:**

```text
PlayerCommandFrame + ContactFrame
                |
                v
       Locomotion calculation
                |
                v
      Base velocity and gravity
                |
        +-------+--------+
        |                |
        v                v
 Grapple pull       Attack movement
 Wind / surfaces    External impulses
        |                |
        +-------+--------+
                |
                v
   Constraints and redirections
                |
                v
       Speed and safety caps
                |
                v
  One velocity assignment and move
```

**State management:**

- The motor owns only the current velocity, per-step submissions, contact interpretation, and commit guard.
- Each source owns its longer-lived state. The grapple controller owns its anchor; a knockback component owns pending impulses.
- Per-step submissions are cleared at the start of the next physics step.
- A one-shot influence carries a stable source or execution identity so it cannot be applied twice accidentally.
- The motor records the last committed physics-step number and rejects a second commit.
- Within a semantic phase, aggregation and tie-breaking follow fixed rules and stable source identity rather than scene-tree order.

**Active-grapple maximum-range constraint:**

The grapple uses one authored `max_grapple_length_m` value for both acquisition and the active connection boundary.

- Attachment distance does not become the tether length.
- The constraint remains inactive while player-to-anchor distance is below the maximum.
- Movement toward the anchor remains unrestricted.
- Tangential movement remains unrestricted.
- Only movement that would cross the maximum boundary is clipped or redirected.
- Moving anchors are evaluated using player motion relative to anchor motion.
- Release removes the constraint and preserves the resolved velocity.
- Small numerical overshoot is corrected within tolerance.
- An invalid anchor or severe discontinuity cancels the grapple rather than snapping the player.
- The constraint does not implement rope wrapping, elasticity, reeling, or rope-segment simulation.

For example, attaching at 10 m does not create a 10 m rope. The player can move outward until reaching the authored 35 m maximum; only further outward movement is constrained.

**Implementation guide:**

```gdscript
func physics_step(
    command: PlayerCommandFrame,
    delta_seconds: float
) -> void:
    var physics_step := Engine.get_physics_frames()

    motor.begin_step(physics_step, contact_frame)

    locomotion.submit_base_motion(
        motor,
        command,
        delta_seconds
    )

    grapple_controller.submit_motor_influences(
        motor,
        delta_seconds
    )

    ability_coordinator.submit_motor_influences(
        motor,
        delta_seconds
    )

    external_effects.submit_motor_influences(
        motor,
        delta_seconds
    )

    motor.resolve_and_commit(delta_seconds)
```

```gdscript
func submit_motor_influences(
    motor: PlayerMotor,
    delta_seconds: float
) -> void:
    if not is_grapple_active():
        return

    var anchor_state := _anchor.get_world_state()
    var to_anchor := (
        anchor_state.world_position
        - motor.global_position
    )

    motor.submit_sustained_acceleration(
        definition.definition_id,
        to_anchor.normalized()
            * definition.pull_acceleration_mps2
    )

    motor.submit_maximum_anchor_distance(
        definition.definition_id,
        anchor_state,
        definition.max_grapple_length_m
    )
```

```gdscript
func resolve_and_commit(delta_seconds: float) -> void:
    if _last_commit_step == _current_step:
        assert(false, "Motor committed twice in one physics step.")
        GameLog.error(
            DiagnosticEvent.MOTOR_DUPLICATE_COMMIT,
            DiagnosticContext.for_entity(
                entity_id,
                _current_step
            )
        )
        return

    _resolve_terminal_commands()
    _resolve_state_gating()
    _resolve_base_motion(delta_seconds)
    _resolve_sustained_influences(delta_seconds)
    _resolve_one_shot_impulses()
    _resolve_constraints(delta_seconds)
    _apply_caps()

    velocity = _resolved_velocity
    move_and_slide()

    _last_commit_step = _current_step
    _publish_contact_frame()
```

**Edge cases:**

- Conflicting terminal commands are resolved by the owning coordinator before movement.
- Multiple additive influences aggregate within their declared channel.
- Mutually exclusive movement policies must be resolved before submission or rejected as an invariant violation.
- An encounter reset invalidates scoped influences from the previous run.
- A missing grapple anchor cancels the grapple with a typed reason.
- Teleports reset physics interpolation and do not pass through ordinary constraint resolution.
- Approved future root-motion use must submit a motor influence; animation may never move the authoritative player body directly.

**Usage:** All code capable of changing player displacement or velocity must use this pattern.

---

#### Simulation-Authored Ability Lifecycle

**Purpose:** Ensure that attack timing, grapple state, hit windows, movement policies, interruption, cancellation, and cooldown behavior remain stable across frame rates, physics rates, and animation changes.

**Components:**

- Immutable `AbilityDefinition` or `AttackDefinition`.
- Ability coordinator responsible for cross-ability arbitration.
- Owner-local `AbilityExecution`.
- Stable ability execution ID.
- Typed validation and start result.
- Hit-query and damage systems.
- Motor-influence submission.
- Animation, audio, VFX, UI, and camera presenters.
- Encounter cleanup scope.

**Data flow:**

```text
Input or AI intent
        |
        v
Typed ability request
        |
        v
Validation and coordination
        |
        v
Execution committed with stable ID
        |
        v
Windup -> Active -> Recovery -> Completed
   \         |          /
    \--------+---------/
          Cancelled
        |
        v
Committed facts to presentation
```

**State management:**

- Phase timing is authored in seconds.
- The owning simulation advances elapsed time from physics `delta`.
- Excess elapsed time carries across phase boundaries.
- Phase-transition loops are bounded to protect against malformed zero-duration definitions.
- Each execution produces exactly one terminal result.
- Completion and cancellation are idempotent.
- Animation state and animation completion are not gameplay authority.
- Gameplay signals are emitted only after phase state has been committed.
- Reentrant transition requests are rejected or deferred to the owner’s next evaluation phase.

A held grapple may remain in its simulation-owned active phase until release, invalidation, or cancellation rather than requiring a fixed active duration. Its continuation is still determined by simulation state, not animation playback.

**Implementation guide:**

```gdscript
class_name AbilityExecution
extends RefCounted

signal phase_changed(
    execution_id: int,
    previous: AbilityPhase,
    current: AbilityPhase
)

signal terminated(
    execution_id: int,
    result: AbilityTerminalResult
)

var execution_id: int
var phase: AbilityPhase = AbilityPhase.WINDUP
var phase_elapsed_seconds: float = 0.0
var is_terminal: bool = false
```

```gdscript
func advance(delta_seconds: float) -> void:
    if is_terminal:
        return

    var remaining_seconds := delta_seconds
    var transition_count := 0

    while remaining_seconds > 0.0 and not is_terminal:
        var duration_seconds := _get_phase_duration_seconds()
        var phase_remaining_seconds := maxf(
            duration_seconds - phase_elapsed_seconds,
            0.0
        )
        var consumed_seconds := minf(
            remaining_seconds,
            phase_remaining_seconds
        )

        phase_elapsed_seconds += consumed_seconds
        remaining_seconds -= consumed_seconds

        if phase_elapsed_seconds < duration_seconds:
            break

        _advance_phase()
        transition_count += 1

        if transition_count >= MAX_TRANSITIONS_PER_STEP:
            _cancel(
                AbilityCancelReason.INVALID_DEFINITION
            )
            break
```

```gdscript
func _enter_phase(next_phase: AbilityPhase) -> void:
    var previous := phase
    phase = next_phase
    phase_elapsed_seconds = 0.0

    match phase:
        AbilityPhase.ACTIVE:
            hit_query.activate(execution_id)
        AbilityPhase.RECOVERY:
            hit_query.deactivate(execution_id)
        AbilityPhase.COMPLETED:
            _complete_once()

    phase_changed.emit(
        execution_id,
        previous,
        phase
    )
```

A presentation adapter observes the committed phase:

```gdscript
func _on_ability_phase_changed(
    _execution_id: int,
    _previous: AbilityPhase,
    current: AbilityPhase
) -> void:
    match current:
        AbilityPhase.WINDUP:
            animation_playback.travel(&"melee_attack")
        AbilityPhase.RECOVERY:
            animation_playback.travel(&"melee_recovery")
        AbilityPhase.COMPLETED:
            animation_playback.travel(&"locomotion")
```

**Edge cases:**

- Requests during an incompatible phase return a typed rejection.
- Cancellation during windup never enters the active damage window.
- Actor death and encounter reset cancel owned executions with explicit reasons.
- Target invalidation follows the ability’s authored policy.
- A large physics delta may cross multiple phases without silently lengthening the ability.
- A change from 60 Hz to 120 Hz increases update count but does not change real-time duration.
- Animation may be missing, interrupted, blended, or replaced without changing the execution.
- Animation method tracks may produce cosmetic effects but never activate damage or advance phases.
- Duplicate completion and cancellation calls return the already-committed terminal result without repeating side effects.

**Usage:** Every player or enemy action with timing, interruption, effects, movement, damage, or cooldown consequences uses this lifecycle.

---

#### Run-Scoped Spawn and Attribution

**Purpose:** Allow projectiles, hazards, effects, status instances, and other spawned objects to outlive their source entity safely while preventing stale objects and delayed callbacks from surviving encounter reset.

**Components:**

- `EncounterController`.
- Replaceable `EncounterRuntimeRoot`.
- Stable encounter run ID.
- Typed domain spawners.
- Typed spawn requests and results.
- Runtime containers for participants, projectiles, hazards, telegraphs, audio, and effects.
- `CombatSourceRef`.
- `DamageSnapshot`.
- Ability execution ID.
- Immutable entity and projectile definitions.
- Owner-local projectile or effect runtime state.

**Data flow:**

```text
Ability execution
        |
        v
Resolve source offense and modifiers
        |
        v
Create DamageSnapshot + CombatSourceRef
        |
        v
Typed SpawnRequest with run and scope
        |
        v
Domain spawner validates active run
        |
        v
Instantiate -> configure -> attach to RuntimeRoot
        |
        v
Projectile travels independently of source node
        |
        v
Impact evaluates target's current defenses
```

**State management:**

- Scene-tree parentage determines cleanup lifetime.
- Stable source and execution data determine combat attribution.
- These two concepts never rely on one another.
- Each encounter activation creates a new run ID.
- Every delayed gameplay request carries that run ID.
- Invalidated runs stop accepting spawns, hits, and delayed callbacks.
- Projectile damage uses source offense snapshotted at launch.
- Target defense and incoming modifiers are evaluated at impact.
- Spawned nodes own only occurrence-specific mutable state.
- Shared definition Resources remain immutable.

**Implementation guide:**

```gdscript
class_name ProjectileSpawnRequest
extends RefCounted

var encounter_run_id: int
var projectile_definition: ProjectileDefinition
var source_ref: CombatSourceRef
var ability_execution_id: int
var damage_snapshot: DamageSnapshot
var spawn_world_transform: Transform3D
var initial_velocity: Vector3
```

```gdscript
func spawn_projectile(
    request: ProjectileSpawnRequest
) -> ProjectileSpawnResult:
    if request.encounter_run_id != _active_run_id:
        return ProjectileSpawnResult.failure(
            SpawnError.STALE_RUN
        )

    if request.projectile_definition == null:
        return ProjectileSpawnResult.failure(
            SpawnError.INVALID_DEFINITION
        )

    var instance := (
        request.projectile_definition.scene.instantiate()
    )
    var projectile := instance as Projectile

    if projectile == null:
        instance.free()
        return ProjectileSpawnResult.failure(
            SpawnError.INVALID_SCENE_ROOT
        )

    projectile.configure(request)
    _runtime_root.projectile_container.add_child(projectile)

    projectile_spawned.emit(
        projectile.entity_id,
        request.encounter_run_id
    )

    return ProjectileSpawnResult.success(projectile)
```

The projectile remains valid if its firing enemy is removed because it carries stable attribution and a damage snapshot rather than depending on the enemy node:

```gdscript
func resolve_impact(target: DamageReceiver) -> void:
    if encounter_run_id != encounter_scope.active_run_id:
        request_despawn(DespawnReason.STALE_RUN)
        return

    target.apply_damage(
        damage_snapshot,
        source_ref,
        ability_execution_id
    )

    request_despawn(DespawnReason.IMPACT)
```

**Edge cases:**

- Removing the source enemy does not invalidate an already-launched projectile.
- Encounter reset invalidates the run before freeing its runtime root.
- Late callbacks carrying an old run ID are ignored.
- Reflection deliberately creates updated source attribution and damage policy.
- Recipient-owned status effects retain their source and originating run information.
- Child effects inherit scope unless explicitly transferred.
- Scope transfer requires validation by the responsible owner.
- Gameplay attribution fields avoid the name `owner` because `Node.owner` has Godot scene-ownership semantics.
- Pooling, if later introduced for a measured high-churn type, remains behind the same spawner and must completely reinitialize run, source, execution, and runtime state.
- Failed required spawns return typed errors to the encounter owner; they do not leave partially initialized nodes active.

**Usage:** All encounter-owned runtime spawning and all combat objects that can become separated from their source use this pattern.

---

#### Geometry-Discovered Vertical Tactics

**Purpose:** Give climbing and flying enemies intelligent vertical behavior without requiring designers to author climb routes, climb-entry anchors, flight anchors, flight connections, or tactical waypoint networks for every arena.

**Components:**

- Enemy perception.
- Existing encounter bounds.
- Named collision layers and immutable query profiles.
- Navigation reachability queries.
- Geometry-probe services.
- Runtime candidate generators.
- Immutable `AiPolicyDefinition`.
- Utility scorer and deterministic tie-breaking.
- Candidate hysteresis and replan policy.
- LimboAI behavior-tree tasks and action HSM.
- Enemy-owned movement controller.
- Development-only tactical diagnostics.

**Data flow:**

```text
Player and encounter state
            |
            v
Candidate generation from geometry
            |
            v
Collision, clearance, bounds, and reachability rejection
            |
            v
Utility scoring
            |
            v
Hysteresis and deterministic selection
            |
            v
LimboAI action request
            |
            v
Enemy-owned movement execution
            |
            v
Observe result and replan when required
```

**State management:**

- Reusable tactical policy is immutable authored data.
- Generated candidates are short-lived runtime data.
- The currently selected position, selection age, and recent selections live in enemy-local tactical memory.
- The LimboAI blackboard may hold current candidates and plans, but it does not own health, cooldown, damage, or ability state.
- Replanning occurs approximately four to six times per second or in response to meaningful events.
- Hysteresis prevents minor score changes from constantly replacing a usable destination.
- Deterministic encounter seeds and stable tie-break rules make failures reproducible.

**Climber behavior:**

A climb-entry point is generated rather than authored. It is a temporary world-space candidate near the base of a suitable surface where the enemy can transition from normal navigation into its bounded climb action.

The candidate must satisfy:

- Reachability from ordinary navigation.
- A valid climbable surface ahead.
- Suitable surface orientation.
- Body clearance.
- Valid contact and probe confidence.
- A plausible climb or pounce continuation.
- Encounter bounds and override-volume rules.

The climber performs a bounded surface pursuit and pounce. It is not a universal arbitrary-surface navigation system. Loss of surface confidence causes a safe abort and fallback to ordinary navigation.

**Flyer behavior:**

The flyer generates temporary positions with tactical roles rather than consuming authored anchors:

- Attack positions satisfy range, line-of-sight, and attack-shape requirements.
- Strafe or orbit positions preserve lateral pressure while avoiding immediate repetition.
- Staging positions establish a useful distance and altitude before an attack.
- Recovery positions favor temporary safety and space after commitment.
- Avoidance positions route around a blocking obstacle when direct swept steering is insufficient.

These are computed from the player, encounter bounds, preferred altitude and distance, nearby obstacles, recent selections, and the current action.

**Implementation guide:**

```gdscript
func select_flight_position(
    context: FlightTacticalContext,
    policy: FlightPolicyDefinition
) -> FlightSelectionResult:
    var candidates := candidate_generator.generate(
        context,
        policy
    )

    var best_candidate: FlightCandidate
    var best_score := -INF

    for candidate in candidates:
        if not encounter_bounds.has_point(
            candidate.world_position
        ):
            continue

        if not clearance_query.is_clear(
            candidate.world_position,
            policy.clearance_profile
        ):
            continue

        var score := 0.0
        score += policy.score_distance(
            candidate.distance_to_target
        )
        score += policy.score_altitude(
            candidate.altitude_over_target
        )
        score += policy.line_of_sight_weight \
            if candidate.has_line_of_sight else \
            policy.occluded_penalty
        score += policy.role_weight(candidate.role)
        score -= policy.repetition_penalty(
            candidate,
            tactical_memory
        )

        if tactical_memory.should_keep_current(
            candidate,
            score
        ):
            score += policy.hysteresis_bonus

        if best_candidate == null or score > best_score or (
            is_equal_approx(score, best_score)
            and candidate.stable_id < best_candidate.stable_id
        ):
            best_candidate = candidate
            best_score = score

    if best_candidate == null:
        return FlightSelectionResult.no_valid_candidate()

    return FlightSelectionResult.success(
        best_candidate,
        best_score
    )
```

A LimboAI task requests the resulting action rather than moving the enemy directly:

```gdscript
func _tick(_delta: float) -> Status:
    var selection := tactical_selector.select_position()

    if not selection.succeeded:
        return FAILURE

    var result := movement_controller.request_move_to(
        selection.world_position,
        selection.movement_policy
    )

    return SUCCESS if result.accepted else FAILURE
```

**Edge cases:**

- If no candidate is valid, the enemy uses a safe archetype fallback rather than teleporting or stalling indefinitely.
- Loss of target invalidates attack-position scoring.
- Navigation not being ready produces a typed temporary failure.
- Moving targets trigger event-driven replanning only when displacement is meaningful.
- Hysteresis prevents oscillation between nearly equal candidates.
- Rare `NoEnemyClimb`, `NoFly`, `NoPounce`, or `NoAttackPosition` volumes may reject generated candidates.
- A generated route that loses collision confidence aborts safely.
- Diagnostic drawing shows generated candidates, rejection reasons, scores, and the selected position only when explicitly enabled.

**Usage:** Climbing and flying archetypes use this pattern by default. Normal arena authoring requires only existing encounter bounds; rare override volumes remain optional.

### Communication Patterns

**Pattern:** Scoped direct commands and queries with typed past-tense signals.

Known recipients communicate through direct typed calls. Signals report facts only after authoritative state has been committed. Entity coordinators mediate sibling interactions. Dependencies are supplied explicitly; gameplay systems do not use absolute node paths, global service lookup, or a universal event bus.

| Interaction | Required form |
|---|---|
| Request an action | Direct typed method |
| Ask for current state | Direct typed query or read-only snapshot |
| Report a committed fact | Typed past-tense signal |
| Coordinate sibling components | Entity or scope coordinator |
| Supply a dependency | Exported typed reference or initialization context |
| Cross encounter or level boundary | Stable IDs plus run/execution identity |
| Broadcast arbitrary gameplay commands | Prohibited |

**Example:**

```gdscript
class_name AbilityCoordinator
extends Node

signal grapple_started(execution_id: int)
signal grapple_ended(
    execution_id: int,
    reason: GrappleEndReason
)

func request_grapple(
    command: GrappleCommand
) -> AbilityStartResult:
    var plan := _plan_grapple_request(command)

    if not plan.succeeded:
        return plan.failure_result

    # The plan validates the target and every required sibling
    # transition before either ability mutates authoritative state.
    var result := _commit_grapple_plan(plan)

    if not result.succeeded:
        return result

    grapple_started.emit(result.execution_id)
    return result
```

`_commit_grapple_plan()` is the coordinator-owned atomic boundary. Target validation, attack cancellation permission, and exclusivity checks occur while building the plan; an implementation may not start grapple first and discover afterward that the conflicting attack could not be cancelled.

Presentation may observe the committed fact:

```gdscript
func _on_ability_coordinator_grapple_started(
    execution_id: int
) -> void:
    grapple_presenter.begin_visuals(execution_id)
```

Presentation cannot emit an equivalent signal to authorize gameplay.

**Rules:**

- Commands begin with verbs such as `request_`, `apply_`, or `cancel_`.
- Queries use `can_`, `has_`, `is_`, `find_`, or `get_`.
- Signals use past-tense facts.
- Expected request results return directly rather than through signals.
- Subscribers may not depend on signal connection order.
- Ordering-sensitive work is performed by the owning coordinator.
- Cross-lifetime signals carry stable IDs rather than retaining arbitrary nodes.
- Continuous presentation data uses read-only snapshots instead of per-frame signals.

### Entity Patterns

**Creation:** Godot `PackedScene` composition behind typed domain spawners.

Scenes remain the reusable entity templates. Domain spawners control definition resolution, initialization order, runtime parentage, scope registration, failure handling, and optional future pooling. Callers do not instantiate gameplay entities or choose runtime parents directly.

**Creation sequence:**

1. Receive a typed spawn request.
2. Validate the active run and requested definition.
3. Resolve an already-loaded `PackedScene`.
4. Instantiate and validate the expected root type.
5. Supply immutable definition and runtime context.
6. Add the entity to its designated scoped container.
7. Emit a committed spawn fact.
8. Return a typed spawn result.

`configure()` may store pre-tree context but may not depend on `@onready` references. `_ready()` may assume that required configuration has already been supplied.

**Example:**

```gdscript
func spawn_enemy(
    request: EnemySpawnRequest
) -> EnemySpawnResult:
    if request.encounter_run_id != _active_run_id:
        return EnemySpawnResult.failure(
            SpawnError.STALE_RUN
        )

    var definition := enemy_catalog.find_definition(
        request.enemy_definition_id
    )

    if definition == null:
        return EnemySpawnResult.failure(
            SpawnError.UNKNOWN_DEFINITION
        )

    var instance := definition.scene.instantiate()
    var enemy := instance as EnemyCoordinator

    if enemy == null:
        instance.free()
        return EnemySpawnResult.failure(
            SpawnError.INVALID_SCENE_ROOT
        )

    var initialize_result := enemy.initialize(
        definition,
        request.spawn_context
    )

    if not initialize_result.succeeded:
        enemy.free()
        return EnemySpawnResult.failure(
            SpawnError.INITIALIZATION_FAILED
        )

    _runtime_root.participant_container.add_child(enemy)
    enemy_spawned.emit(
        enemy.entity_id,
        request.encounter_run_id
    )

    return EnemySpawnResult.success(enemy)
```

**Rules:**

- Use domain spawners rather than one universal entity factory.
- Runtime entities never choose their own cleanup parent.
- Scene parentage expresses lifetime, not combat credit.
- Despawn requests go to the responsible runtime owner.
- Pooling is not the default.
- A measured high-churn type may adopt pooling behind its existing domain spawner without changing callers.
- Builders are reserved for genuinely complex staged construction and are not the normal entity path.
- First-time synchronous resource loading during combat is prohibited.

### State Patterns

**Pattern:** Small component-owned authoritative state machines, LimboAI for enemy decision state, blackboards for working memory, and presentation state derived from simulation.

There is no universal entity state machine. Orthogonal concerns retain separate owners.

| State | Owner |
|---|---|
| Grounded, airborne, grappling, or wall interaction | Player movement HSM |
| Attack windup, active, recovery, or cancellation | Attack lifecycle |
| Health, damage acceptance, and death | Health component |
| Enemy tactical intent | LimboAI behavior tree and HSM |
| Perception and tactical candidates | Enemy-local blackboard |
| Animation playback and blending | Presentation adapter and `AnimationTree` |

Only the owner may mutate its state. External systems issue typed requests.

**Transition order:**

1. Validate the request and transition guard.
2. Exit the previous state.
3. Commit the next state.
4. Enter the next state.
5. Emit a past-tense transition fact.
6. Return a typed result.

**Example:**

```gdscript
func request_transition(
    next_phase: AttackPhase,
    cause: TransitionCause
) -> TransitionResult:
    if _is_transitioning:
        return TransitionResult.failure(
            TransitionError.REENTRANT_REQUEST
        )

    if not _can_transition(phase, next_phase):
        return TransitionResult.failure(
            TransitionError.ILLEGAL_TRANSITION
        )

    _is_transitioning = true

    var previous := phase
    _exit_phase(previous)

    phase = next_phase
    phase_elapsed_seconds = 0.0

    _enter_phase(next_phase)
    _is_transitioning = false

    phase_changed.emit(previous, next_phase, cause)
    return TransitionResult.success(previous, next_phase)
```

A LimboAI task requests gameplay behavior through its component contract:

```gdscript
func _tick(_delta: float) -> Status:
    var attack_result := attack_controller.request_attack(
        blackboard.get_var(&"attack_command")
    )

    if attack_result.succeeded:
        return SUCCESS

    if attack_result.error == AbilityStartError.TEMPORARILY_BUSY:
        return RUNNING

    return FAILURE
```

**Rules:**

- Behavior trees choose intent but do not activate hitboxes, apply damage, or write velocity.
- Blackboards store perception and planning data, not duplicate authoritative gameplay state.
- Mutually exclusive lifecycles use an enum or explicit state rather than combinations of booleans.
- Independent facts may use clearly named booleans.
- Reentrant transition requests do not mutate state recursively.
- Animation state machines may blend or lag visually but cannot control simulation state.
- Gameplay transitions occur only in their declared simulation phase.

### Data Patterns

**Access:** Immutable typed Resources, owner-local runtime state, scoped domain catalogs, and explicit dependency injection.

| Data category | Authority |
|---|---|
| Gameplay definitions and tuning | Typed `.tres` Resources |
| Mutable entity and execution state | Owner-local runtime objects |
| Stable definition lookup | Domain catalogs and manifests |
| Engine integration settings | `project.godot` and bootstrap-owned `ProjectSettings` access |
| User preferences | Versioned `ConfigFile` through `SettingsService` |
| Level content dependencies | `LevelManifest` and controlled boundary loading |

**Example:**

```gdscript
class_name GrappleDefinition
extends Resource

@export var definition_id: StringName
@export var max_grapple_length_m: float = 35.0
@export var pull_acceleration_mps2: float = 45.0
@export var maximum_speed_mps: float = 30.0
@export var target_query_profile: PhysicsQueryProfile
```

```gdscript
class_name GrappleController
extends Node

@export var definition: GrappleDefinition

var _anchor: GrappleAnchor
var _phase: GrapplePhase = GrapplePhase.READY
var _phase_elapsed_seconds: float = 0.0

func initialize(context: PlayerAbilityContext) -> void:
    _motor = context.motor
    _targeting = context.grapple_targeting
```

Shared definitions are never modified during play:

```gdscript
# Prohibited:
definition.max_grapple_length_m *= range_modifier

# Required:
var resolved_maximum_length_m := (
    definition.max_grapple_length_m
    * runtime_modifiers.grapple_range_multiplier
)
```

Domain spawners receive the catalog they require:

```gdscript
func initialize(
    catalog: ProjectileCatalog,
    runtime_root: EncounterRuntimeRoot,
    active_run_id: int
) -> void:
    _catalog = catalog
    _runtime_root = runtime_root
    _active_run_id = active_run_id
```

**Rules:**

- Definitions use descriptive types ending in `Definition`, `Profile`, `Manifest`, or `CueDefinition`.
- Stable IDs are authored and never inferred from filenames or node paths.
- Scenes export references to authoritative definitions rather than duplicating tuning values.
- Runtime modifiers produce local resolved values or immutable snapshots.
- Gameplay code does not construct resource paths dynamically.
- Combat code does not perform first-time synchronous loads.
- App and level loaders resolve dependencies at controlled boundaries.
- A top-level manifest may reference domain catalogs, but gameplay systems receive only their required dependencies.
- Autoloads are limited to genuinely application-wide infrastructure and cannot serve as a global gameplay data locator.
- Only `SettingsService` reads and writes the user `ConfigFile`.
- Gameplay components do not make scattered `ProjectSettings` queries.
- Persistent save and RPG data access remain outside the current architecture.

### Presentation Boundary

**Pattern:** Godot-native presentation nodes driven one-way by authoritative simulation.

The presentation boundary is an architectural responsibility, not a special Godot layer type.

```text
Fixed-step simulation
        |
        | committed signals
        | read-only snapshots
        v
Presentation adapter
        |
        +-- AnimationTree / AnimationPlayer
        +-- model and Skeleton3D
        +-- audio
        +-- particles and trails
        +-- grapple line and reticle
        +-- camera effects
        +-- HUD
```

**Example:**

```gdscript
func _process(_delta_seconds: float) -> void:
    var snapshot := motor.get_presentation_snapshot()

    animation_tree.set(
        "parameters/locomotion/blend_position",
        snapshot.planar_speed_normalized
    )
```

**Rules:**

- Discrete facts use scoped signals.
- Continuous visual values use read-only snapshots.
- Purely visual skeletal animation may update at render rate.
- Authoritative transforms and collision movement remain in physics processing.
- Physics interpolation smooths fixed-step motion for high-refresh presentation.
- Animation markers may produce cosmetic sound or VFX.
- Animation markers cannot create hit windows, apply damage, move the authoritative body, or terminate abilities.
- Current player gameplay motion uses the single motor and in-place animation.
- Any later approved root-motion integration must convert motion into a typed motor influence rather than move the body from presentation.
- Missing presentation may degrade visuals but cannot prevent otherwise valid simulation from running.

### Consistency Rules

| Pattern | Convention | Enforcement |
|---|---|---|
| Player movement | Only `PlayerMotor` writes final velocity or calls `move_and_slide()` | Motor commit assertion and integration test |
| Movement ordering | Use fixed semantic phases | Typed submission API; no numeric priorities |
| Grapple range | One `max_grapple_length_m` governs acquisition and active boundary | Definition validation and grapple integration test |
| Grapple tether | Maximum-range boundary, not initial attachment length | Motor-constraint contract test |
| Gameplay timing | Seconds advanced from physics `delta` | 60/120 Hz equivalence tests |
| Ability phases | Simulation-authored lifecycle | No gameplay animation callbacks |
| Terminal execution | Exactly one idempotent completion or cancellation | Execution contract test |
| Commands | Direct typed imperative methods | Code review and API naming |
| Queries | Direct typed methods or read-only snapshots | Code review |
| Facts | Past-tense typed signals after commit | Signal contract tests |
| Ordering | Coordinator-owned direct calls | Subscribers cannot depend on connection order |
| Entity creation | Domain spawner plus `PackedScene` | Direct runtime instantiation prohibited |
| Initialization | Configure before scene-tree activation | Typed initialization result |
| Runtime lifetime | Explicit encounter or level scope | Scope registry and cleanup test |
| Combat attribution | Stable source, execution, snapshot, and run identity | Projectile and status-effect tests |
| Scene ownership naming | Do not use `owner` for combat attribution | Naming validation |
| Pooling | Optional per measured high-churn domain | Hidden behind existing spawner API |
| State mutation | Only the owning component transitions state | Private state and typed request methods |
| Enemy decisions | LimboAI requests actions through gameplay contracts | Behavior tasks cannot mutate gameplay internals |
| Blackboard use | Perception and planning memory only | No duplicated authoritative state |
| Animation | Presentation follows simulation | Animation callbacks remain cosmetic |
| Definitions | Typed Resources treated as immutable during play | Validation and immutability tests |
| Runtime state | Owner-local nodes or runtime objects | No mutable execution data in Resources |
| Data lookup | Narrow domain catalogs with stable IDs | No global gameplay data manager |
| Resource loading | Controlled level or encounter boundary | No first-time synchronous combat loads |
| Collision eligibility | Named collision matrix | No magic layer literals |
| Query meaning | Immutable `PhysicsQueryProfile` | Typed query APIs |
| Vertical AI | Runtime geometry candidates and reusable policy | No required anchor networks |
| Failure handling | Typed results and reason enums | Direct caller handles or propagates |
| Diagnostics | Development-only, bounded, and read-only | Release composition excludes debug tooling |
| Presentation failure | Defined cosmetic fallback | Simulation remains authoritative |
| Naming | Godot-native casing and explicit semantic units | Formatter, validators, and review |

### Step 7 Review

**Patterns defined:**

- Four standard implementation patterns.
- Four novel gameplay architecture patterns.
- One explicit cross-cutting presentation boundary.

**Validation check:**

- Each pattern defines ownership and communication.
- Each novel pattern includes components, data flow, state management, implementation examples, usage, and edge cases.
- The maximum grapple length is the tether boundary rather than the initial attachment length.
- Simulation, presentation, scene lifetime, and combat attribution remain distinct.
- The examples follow the accepted Godot project organization and naming rules.
- No new global manager, event bus, live-tuning framework, pooling requirement, or designer-authored vertical anchor network has been introduced.

## Architecture Validation

### Validation Summary

| Check | Result | Notes |
|---|---|---|
| Decision Compatibility | Pass | Engine, platform, timing, ownership, dependency, and deferral decisions work together and linked sources are synchronized |
| GDD Coverage | Pass | All 16 core system areas and all 17 reusable M2 mechanics have explicit architectural support |
| Pattern Completeness | Pass | Creation, communication, state, error, data, event, lifecycle, and presentation scenarios are defined |
| Epic Mapping | Pass | `DEVELOPMENT_ROADMAP.md` is the sequencing authority and M0-M6 are mapped to locations, contracts, status, and implementation evidence |
| Document Completeness | Pass | Required summary, versions, decision table, target structure, cross-cutting concerns, contracts, examples, naming, and verification rules are present with no placeholders |

### Coverage Report

**Systems Covered:** 16/16  
**Patterns Defined:** 9 core implementation patterns plus 6 M2 composition families  
**Decisions Made:** 16 decision categories represented by 15 binding architecture ADRs  
**M2 Mechanics Mapped:** 17/17

### Issues Resolved

- Replaced stale platform, input, frame-target, physics-rate, camera, and terrain uncertainty with approved decisions.
- Reconciled all linked grapple descriptions with the acceleration-based zip-pull and maximum-range-only connection boundary.
- Defined grapple target, movement/impact context, attack/damage, detached delivery, ability-space/telegraph, objective, checkpoint, and reward contracts.
- Added current-scope locations for combat effects, telegraphs, objectives, checkpoints, and rewards.
- Mapped roadmap M0-M6 and all 17 M2 mechanics through six composable implementation families with required evidence.
- Recorded exact dependency versions and qualified LimboAI 1.8.1 as the repository-vendored local build.
- Corrected coordinated grapple arbitration and null-safe deterministic flight-candidate tie-breaking examples.
- Added an explicit executive summary and distinguished the current prototype layout from the approved target structure.

### Validation Date

September 2, 2026

**Overall Status:** PASS

## Development Environment

### Prerequisites

- Windows PC capable of running the Godot Forward+ renderer.
- **Godot 4.7.2-stable**, with the executable either available as `godot` on `PATH` or invoked directly from its installed location. Do not open and resave the project with a different engine version as an incidental setup step.
- Git for source control and diff-based review.
- `uv` for the selected Godot AI local MCP service.
- The repository checkout itself. LimboAI 1.8.1, Godot AI 3.2.4, GUT 9.7.1, Terrain3D 1.0.2, Phantom Camera 0.11.0.2, and the formatter are already vendored; do not reinstall or opportunistically upgrade them during setup.

At architecture finalization, the current shell could not resolve a `godot` command. Installing the pinned editor or exposing its exact executable to the shell is therefore a real prerequisite, not an assumed completed step.

### Selected Development MCP Servers

#### Godot AI 3.2.4

Godot AI is the project-aware MCP integration. Its editor plug-in is already installed and enabled in `project.godot`; the companion local Python/FastMCP service requires `uv`.

Setup policy:

1. Open this project in the pinned Godot editor and wait for initial imports to finish.
2. Use the Godot AI dock to generate the MCP client configuration, especially on Windows.
3. Keep the service bound to loopback and retain the default local ports unless a documented conflict requires a change.
4. Store personal client configuration, tokens, and executable paths outside the repository.
5. Begin diagnostic work with read-only inspection; verify any scene or Resource mutation through a version-control diff, editor inspection, and the relevant test or smoke scene.

#### Context7

Context7 is the documentation MCP. Prefer its hosted endpoint and request documentation for the exact Godot or add-on version being used. A local Node.js MCP package is an optional fallback for offline or self-hosted use; it is not a project runtime dependency. Keep any credentials outside the repository, and confirm gameplay-critical engine behavior against official Godot documentation.

### Existing-Checkout Setup

1. Open the existing repository root directly; do not create a new Godot project or apply a starter template over it.
2. Allow Godot to import the vendored assets and extensions, then confirm that the launch scene `res://main.tscn` opens without missing script or Resource classes.
3. Confirm that Jolt remains the 3D physics backend and Forward+ remains the renderer. Do not change the approved fixed 60 Hz simulation policy as part of local setup.
4. Confirm that the currently enabled Godot AI and Terrain3D editor plug-ins load. Terrain3D remains optional to gameplay even though its editor plug-in is presently enabled.
5. Confirm that the repository-vendored LimboAI build resolves the HSM and behavior-tree types used by existing scenes. Preserve the local 1.8.1 build until a deliberate compatibility upgrade is approved.
6. Treat Phantom Camera as installed but deferred. The current production architecture uses built-in `Camera3D` and `SpringArm3D`; do not make new gameplay depend on Phantom Camera while setting up the checkout.
7. Run the current prototype before restructuring it and record any pre-existing import, parse, scene-load, or runtime errors separately from new implementation work.

### Setup and Verification Commands

Run these PowerShell commands from the repository root after the pinned tools are available:

```powershell
git --version
godot --version
uv --version
godot --editor --path .
```

`godot --version` must report the 4.7.2-stable line before assets are intentionally resaved. To launch the current configured scene without the editor:

```powershell
godot --path .
```

GUT is vendored, but this checkout does not yet contain a `tests/` directory or an established automated suite. After the first architecture contract tests are added under `res://tests`, the canonical recursive headless invocation is:

```powershell
godot --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

Until that suite exists, verification must name and run the relevant prototype or focused test scene rather than claiming an automated pass.

### First Development Steps

1. Convert the validated M0-M4 roadmap into epics and implementation-ready stories, beginning with M0 Traversal Foundation.
2. Preserve a runnable prototype baseline while introducing the approved `game/` target hierarchy incrementally; do not perform an all-at-once directory migration.
3. Establish the shared identifiers, typed results, named collision matrix, immutable query profiles, command-frame input, and single-motor boundary before expanding feature breadth.
4. Add the small mandatory GUT contract suite alongside the first rewritten architectural seams, then record the working command and test locations in the AI project context.
5. Build the focused traversal test scene and verify 60 Hz behavior, 120 Hz diagnostic equivalence, grapple maximum-range behavior, cancellation, and reset before beginning M1 combat integration.
6. Profile representative gameplay at milestone gates; do not add pooling, broad telemetry, or speculative optimization infrastructure during environment setup.

## Requirement Disposition

The GDD owns player-facing design requirements. This architecture disposes all technical and quality obligations that the canonical epic package must implement. The preserved identifiers prevent drift across GDD, architecture, epics, stories, and readiness checks.

### Architecture-Derived Functional Requirements

- **FR3:** The input system converts hardware input into one immutable command frame per physics step containing movement, canonical view orientation, authoritative aim, and pressed, held, and released action states.
- **FR21:** Enemy behavior logic can perceive tactical context and request typed movement and ability actions without directly controlling hitboxes, damage, player velocity, or authoritative ability timing.
- **FR47:** Each encounter activation creates a distinct run identity and scoped runtime root for participants, projectiles, telegraphs, hazards, temporary obstacles, links, surface mutations, effects, and encounter audio.
- **FR58:** Development builds can present bounded, read-only diagnostics for motor resolution, contacts, grapple targeting, ability execution, encounter lifetime, selected AI tactics, audio requests, and performance, and can invoke a finite set of reset, reload, invulnerability, AI-pause, selection, and capture commands through normal system owners.

### Nonfunctional Requirement Dispositions

- **NFR1:** The M0-M4 validation slice targets Windows PC, uses the Godot Forward+ renderer and Jolt Physics, and supports keyboard and mouse as its only gameplay input devices.
- **NFR2:** Representative release-like gameplay must sustain 60 FPS at 1920x1080 on the eventual minimum-spec Windows PC once that hardware and representative content density are defined.
- **NFR3:** Authoritative gameplay physics runs at a fixed 60 Hz with interpolation; uncapped or high-refresh rendering is best effort and must not change gameplay outcomes.
- **NFR4:** Traversal, ability timing, cooldowns, hit windows, rotating effects, hazard pulses, and other simulation-owned behavior must remain equivalent in real time between the 60 Hz shipping configuration and the 120 Hz diagnostic configuration within documented physics tolerances.
- **NFR5:** Gameplay durations are authored in seconds and advanced from physics delta, with bounded carry-over across phase boundaries; rendered frames, raw tick counts, wall-clock time, and animation callbacks cannot be gameplay clocks.
- **NFR6:** High-speed traversal and combat queries must avoid tunnelling through appropriate swept queries, velocity-aware probes, deliberate collision thickness, stable contact classification, and tolerant rather than exact floating-point assertions.
- **NFR7:** High-resolution mouse aim must consume every received motion event without multiplying mouse delta per physics tick, while short press-and-release edges between physics steps must not be lost and focus loss must clear held or latched input.
- **NFR8:** Threats must provide visible or audible windup, affected-space, active-window, and outcome feedback that lets players understand why damage or displacement occurred and learn counterplay shortly before or after an initial failure.
- **NFR9:** Ordinary combat pressure must preserve player agency: no common ability may arbitrarily remove the complete movement vocabulary, create unavoidable control chains, or leave a representative combination without a viable response and recovery route.
- **NFR10:** Encounter restart, checkpoint reload, source death, and scene exit must reliably invalidate late work and remove every scoped projectile, timer, tether, status, telegraph, hazard, temporary obstacle, surface mutation, audio emitter, and other transient exactly once or idempotently.
- **NFR11:** Combat-critical scenes, definitions, animations, and audio must be resident before encounter activation; first-time synchronous resource loading during combat is prohibited.
- **NFR12:** A required loading, initialization, definition, or spawn failure must produce a typed failure, prevent partial activation, and recover through the responsible encounter, level, or application owner to a safe state.
- **NFR13:** Shared Resource definitions remain immutable during play, mutable state remains owner-local, and restarting an encounter recreates runtime state instead of attempting to scrub shared assets.
- **NFR14:** Cross-lifetime combat objects retain stable source, execution, scope, and encounter-run attribution without retaining a destroyed source node or relying on scene parentage for combat credit.
- **NFR15:** Ability completion and cancellation, objective completion, reward commitment, damage delivery identity, and reset cleanup are idempotent and cannot produce duplicate terminal outcomes.
- **NFR16:** Runtime tactical selection must be reproducible with deterministic encounter seeds, stable tie-breaking, bounded replanning, hysteresis, and safe fallbacks when navigation or valid candidates are unavailable.
- **NFR17:** The HUD must be authored for 1920x1080 while using anchors and containers that remain usable at 16:10 and ultrawide Windows aspect ratios, and it must support UI scale, reticle size, reticle color, and a high-contrast setting.
- **NFR18:** Audio voice limits and priority must preserve local-player feedback and imminent enemy telegraphs before distant, repetitive, or ambient sounds; missing optional presentation degrades through a defined fallback and cannot prevent valid simulation.
- **NFR19:** Development diagnostics, logs, world drawing, histories, and captures must be bounded and observational, perform no duplicate gameplay computation, upload nothing automatically, and be absent or disabled in release and representative performance runs.
- **NFR20:** The permanent automated contract suite must protect single motor commit, motion influence order, 60/120 Hz timing equivalence, single terminal ability results, idempotent termination, run-ID rejection, transient cleanup, damage attribution, definition immutability, input edge latching, and grapple presentation agreement.
- **NFR21:** Physics, movement, encounter lifetime, AI policy, UI, audio, and performance changes must receive the risk-appropriate unit, real-Jolt integration, scene, validator, smoke, human-review, regression, or benchmark evidence defined by the architecture; there is no percentage-based coverage target.
- **NFR22:** The prototype must remain playable and readable with simple geometry and fallback effects; final art, animation, audio, VFX, narrative, balance, and production content cannot be prerequisites for validating M0-M4 gameplay.
- **NFR23:** Existing Godot UIDs and scene/resource dependencies must survive staged migration into the target hierarchy, and the project must retain a runnable baseline rather than undergoing an all-at-once directory rewrite.
- **NFR24:** Pooling, broad telemetry, live tuning, networking, save/RPG frameworks, open-world streaming, and speculative optimization infrastructure may not be added without measured current-scope evidence and an explicit approved decision.
