---
project_name: 'testgame'
user_name: 'Pinto'
date: '2026-09-09'
sections_completed: ['technology_stack', 'engine_rules', 'performance_rules', 'organization_rules', 'testing_rules', 'platform_rules', 'anti_patterns']
existing_patterns_found: 9
status: 'complete'
rule_count: 91
optimized_for_llm: true
artifact_schema: 1
artifact_id: 'grapplegame.project-context'
document_type: 'project-context'
artifact_role: 'derived-implementation-guidance'
authority: 'implementation-guidance'
path_base: 'project-root'
updated: '2026-09-09'
architecture_path: '_bmad-output/planning-artifacts/architecture.md'
architecture_sha256: '77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080'
decision_log: '_bmad-output/planning-artifacts/decision-log.md'
decision_log_sha256: '01454eb5eadbeb60cffe4508fcae8336cfb4bc8dd14c19230964c28a5fb72a00'
---

# Project Context for AI Agents

_Critical, project-specific rules for agents implementing game code. The completed `_bmad-output/planning-artifacts/architecture.md` is the source of truth for rationale and edge cases._

---


## Artifact Authority and Usage

- Read this file before implementation, but use `_bmad-output/planning-artifacts/gdd.md` for design intent and `_bmad-output/planning-artifacts/architecture.md` for target technical decisions.
- Use `_bmad-output/planning-artifacts/epics/manifest.json` for backlog inventory and load only the selected story shard.
- Consult `_bmad-output/planning-artifacts/decision-log.md` for history; accepted requirements must also appear in their owning canonical artifact.
- Supporting documents under `_bmad-output/planning-artifacts/sources/design-library/` are evidence, not competing planning authorities.

## Technology Stack & Versions

- **Engine:** Godot 4.7.2-stable, project configuration version 5, Forward+ renderer, and Jolt Physics. Keep gameplay compatible with the pinned 4.7.2 build; do not opportunistically upgrade the engine or add-ons.
- **Platform:** Windows PC first, keyboard and mouse only. The gameplay target is 1920x1080 at a stable 60 FPS on eventual minimum-spec hardware, with high-refresh presentation as best effort.
- **Simulation:** Fixed 60 Hz physics with interpolation. Gameplay durations are authored and accumulated in seconds; changing the diagnostic physics rate must not change real-time behavior.
- **Language:** Project-owned gameplay code is typed GDScript. Existing add-on C# files and the project's .NET setting do not authorize new C# gameplay code.
- **LimboAI:** Repository-vendored build 1.8.1. It is a required gameplay dependency for HSM and behavior-tree assets; preserve the exact local build until a deliberate compatibility upgrade is approved.
- **Development MCPs:** Godot AI 3.2.4 is enabled for project-aware editor work and its local service uses `uv`; Context7 supplies version-specific documentation. Personal configuration and credentials stay outside the repository.
- **GUT:** Version 9.7.1, vendored as the selected test framework. No `res://tests` suite or established automated run exists yet.
- **Terrain3D:** Version 1.0.2, currently installed and enabled but optional. Gameplay code must not depend on Terrain3D types.
- **Phantom Camera:** Version 0.11.0.2 is installed but deferred. Production camera work uses built-in `Camera3D` and `SpringArm3D`.
- **Current checkout:** `res://main.tscn` remains the prototype launch scene. The approved `AppRoot`/replaceable `LevelRoot` structure is a target migration, not existing implementation.

## Critical Implementation Rules

### Engine-Specific Rules

- Authoritative gameplay advances in `_physics_process(delta)`. Use the supplied physics `delta` as elapsed seconds; `_process(delta)` is limited to presentation, smoothing, and non-authoritative UI work.
- Only `PlayerMotor` may write the player's final `CharacterBody3D.velocity` or call `move_and_slide()`, exactly once per physics step. Movement states, grapple, attacks, knockback, wind, tethers, and later root motion submit typed influences instead.
- Resolve player motion through the fixed phases: terminal commands; state gating and interrupts; base locomotion and gravity; sustained influences; one-shot impulses; constraints and redirections; caps and final commit. Never use scene-tree order or numeric priorities to settle gameplay precedence.
- The current prototype still contains multiple player `move_and_slide()` call sites. Treat them as migration debt: do not add another writer, and remove superseded paths when introducing `PlayerMotor`.
- Player movement and attack remain separate LimboAI HSMs coordinated through typed policies and commands. One state machine must not transition or mutate the other directly.
- Enemy behavior trees select tactical intent; an enemy action HSM owns windup, active, recovery, cancellation, and completion. Tasks must not manipulate gameplay internals directly. The existing HSM is manually updated by `enemy_controller.gd` while its own processing is disabled; preserve exactly one update path until migration.
- Ability phases, hit windows, cooldowns, invulnerability, and cancellation are simulation-authored. `AnimationTree` state and animation markers may drive cosmetic presentation but never advance gameplay or apply damage.
- Godot Resources are immutable authored definitions during play. Cooldowns, health, ability execution, target memory, modifiers, projectile travel, and encounter state belong in owner-local runtime objects.
- Commands and queries use direct typed methods. Typed signals report committed past-tense facts upward and are synchronous by default; gameplay must not depend on subscriber connection order.
- The coordinator composing a scene scope owns its signal connections. Rebinding must prevent duplicates, and replacing a runtime root must destroy its scoped emitters and connections together.
- Autoloads are reserved for genuinely application-wide services such as settings and application flow. Do not place mutable combat, player, enemy, encounter, or level state in an autoload or use `AppRoot` as a service locator.
- Instantiate gameplay scenes through their domain spawner, supply a typed context before scene-tree activation, and attach them to an explicit scope. External systems use narrow typed contracts, stable IDs, and immutable snapshots rather than another scene's private child paths.
- Use `call_deferred()` only for engine-required scene-tree mutations, presentation refreshes, input/window edges, or development tooling. Deferred idle callbacks cannot determine authoritative movement, hits, ability phases, or encounter timing.
- Broad collision eligibility belongs to the named matrix in `project.godot`; gameplay query meaning belongs to immutable `PhysicsQueryProfile` Resources. Movement states consume the shared authoritative `ContactFrame` instead of performing competing ground and wall interpretations.

### Performance Rules

- Target 1920x1080 at a stable 60 FPS on eventual minimum-spec Windows hardware. The total frame interval is approximately 16.67 ms, but do not invent subsystem budgets until representative hardware and production-like content are available.
- High-refresh presentation is best effort and gameplay must remain render-rate independent. Keep production physics at 60 Hz with interpolation; 120 Hz is only a diagnostic for tunnelling and hidden per-step assumptions.
- Treat grapple/contact queries, collision sweeps, perception, geometry candidates, projectiles, and encounter overlap as potential hot paths. Share authoritative snapshots instead of repeating equivalent work, and measure representative scale before optimizing.
- Replan geometry-based AI approximately 4-6 times per second or after meaningful events, with hysteresis and bounded candidate sets. Do not regenerate full tactical candidates every render or physics frame.
- Use swept shapes, velocity-aware probes, deliberate collision thickness, and stable tolerances for high-speed traversal. Raising the physics rate is not a substitute for correct high-speed collision handling.
- Use compact typed enums or value records for frequent rejection and result paths. Avoid unbounded allocations, scene-tree searches, generic dictionaries, and per-entity work hidden inside monitors or presentation.
- Load level dependencies through the threaded `ResourceLoader` path at explicit boundaries. Combat-critical scenes, Resources, animations, and audio must be resident before encounter activation; no first-time synchronous combat loading.
- Pooling is not a default requirement. Add it only for a measured high-churn type and hide it behind the existing domain-spawner contract so callers do not change.
- Diagnostics remain development-only, opt-in, read-only, and bounded. Profile release-like encounters with overlays and verbose logging disabled; do not add speculative caching, batching, telemetry, or optimization infrastructure before evidence identifies a bottleneck.

### Code Organization Rules

- The approved target is a domain-driven `game/` hierarchy. The existing root-level `scripts/`, `scenes/`, `resources/`, `ai/`, and `materials/` directories are prototype migration sources, not locations for new target-architecture systems.
- A gameplay domain owns its scripts, scenes, immutable definitions, and feature-specific presentation adapters together. Do not fragment one feature across global script, scene, Resource, and AI trees.
- Put player input, motor, locomotion, and player-specific ability composition under `game/player/`. Grapple, melee, and ranged attacks belong under `game/player/abilities/grapple/`, `melee/`, and `ranged/`.
- Put actor-neutral ability lifecycle, attack, damage, effect, health, hit-query, projectile, and telegraph mechanics under their corresponding `game/combat/` directories.
- Put enemy composition under `game/enemies/common/`, reusable perception and traversal under `game/enemies/ai/`, and archetype-specific content under `game/enemies/archetypes/<archetype>/`. LimboAI itself remains under `addons/limboai/`; project trees and tasks stay with their archetype until proven reusable.
- Put persistent application composition and loading under `game/app/`, encounter lifetime and spawning under `game/encounters/`, and level runtime, catalog, objectives, checkpoints, rewards, geometry, and authored content under `game/levels/`.
- Put shared camera, UI, audio, and VFX infrastructure under `game/presentation/`. Presentation specific to one feature stays in that feature's `presentation/` directory.
- Admit code to `game/shared/` only when multiple domains depend on the same stable contract, identifier, result, timing primitive, or physics type. It may not become a generic helpers folder, manager layer, service locator, or mutable state store.
- Keep third-party code under `addons/`, first-party editor and validation utilities under `tools/`, Godot-importable media under `assets/`, editable DCC masters under Godot-ignored `assets/source/`, and non-runtime documentation under Godot-ignored `docs/`.
- Tests mirror runtime domains under `tests/`; cross-domain fixtures and integration coverage use `tests/fixtures/` and `tests/integration/`.
- Perform migration incrementally with Godot-aware moves. Preserve UIDs, update `.tscn` and `.tres` dependencies, verify affected scenes, and remove an old path only after its replacement works. Do not perform a blind bulk filesystem move.
- Use `snake_case` for directories, files, functions, variables, signals, and input actions; `PascalCase` for registered classes, enum types, and scene nodes; and `UPPER_SNAKE_CASE` for constants and enum values.
- A script declaring `class_name` uses that class's snake-case filename. Avoid contextless names such as `manager.gd`, `data.gd`, `state.gd`, `utils.gd`, and `helper.gd`.
- Commands begin with verbs such as `request_`, `apply_`, or `cancel_`; queries use `can_`, `has_`, `is_`, `find_`, or `get_`; signals use past-tense committed facts.
- Immutable Resource classes use explicit suffixes such as `Definition`, `Manifest`, `Profile`, or `CueDefinition`. Mutable classes describe their runtime role, such as `AbilityExecution`, `DamageSnapshot`, or `EncounterRuntime`.
- Expose units and coordinate spaces in names, such as `windup_seconds`, `target_world_position`, and `grapple_local_offset`. Author stable IDs explicitly as lowercase dotted namespaces; never derive identity from names or paths.
- Do not create speculative folders or abstractions for deferred save, inventory, RPG progression, networking, narrative, or open-world streaming systems.

### Testing Rules

- GUT 9.7.1 is the selected framework. The target suite mirrors runtime domains under `res://tests/`, but no test directory or working automated suite exists yet; do not report automated tests as run until that infrastructure is created.
- Layered verification is a toolbox, not a requirement that every feature receive unit, integration, scene, performance, and manual tests. Choose the smallest set that protects the risks introduced by the change.
- Maintain a small mandatory contract suite covering motor commit and influence ordering, 60/120 Hz equivalence, one terminal ability result, idempotent cancellation, run-ID rejection, scoped cleanup, damage attribution, definition immutability, input-edge latching, and grapple/presentation agreement.
- Use focused unit tests for pure timing, scoring, policy, and data logic. Use small real-Jolt integration scenes for movement, grapple, collision, and other physics-dependent behavior.
- Use integration tests with explicit leakage assertions for encounter spawning, cancellation, death, reset, and runtime-root replacement. Use reusable validators for authored definitions, manifests, query profiles, and levels.
- Test AI scoring deterministically and supplement it with representative navigation scenes. Use contract or smoke checks plus human review for presentation; playtests remain necessary for movement feel, aiming precision, readability, counterplay, recovery, and tuning.
- Every implemented change must provide reproducible verification evidence: command or scene, setup and inputs, expected result, and relevant death, cancellation, reset, or reload behavior.
- Use deterministic seeds, stable IDs, controlled physics stepping, and tolerant numeric assertions. Avoid real-time sleeps, exact float equality, private node paths, pixel-perfect gameplay screenshots, large tree snapshots, and deep physics mocks.
- Add a focused regression test when fixing a reproducible contract defect. Do not create redundant tests merely to increase a coverage percentage; this project has no percentage-based coverage target.
- Add benchmarks only for performance-sensitive behavior at representative scale. Run performance acceptance with release-like settings and development overlays, world drawing, verbose traces, and capture tooling disabled.
- Create reusable fixtures and helpers only when multiple tests need them; test infrastructure must not grow into a parallel gameplay framework.

### Platform & Build Rules

- Windows x86-64 is the only shipping platform through M4. Do not add secondary-platform abstractions, compatibility branches, controller support, controller glyphs, deadzones, rumble, or device-switching logic.
- Preserve Forward+ with the current Windows Direct3D 12 path and Jolt Physics unless minimum-spec evidence justifies a deliberate renderer or backend change.
- Validate representative Windows debug and release exports at milestone gates. The current checkout has no established `export_presets.cfg`, CI pipeline, or automated build command; do not claim those capabilities until they are created and verified.
- Godot `InputMap` owns factory keyboard and mouse-button bindings in `project.godot`. Only `SettingsService` applies user remaps through a versioned `ConfigFile` under `user://`.
- Input contexts resolve in this order: rebinding capture, UI and pause, gameplay, then debug shortcuts. Losing window focus clears held and latched input so actions cannot remain stuck.
- A player-owned input source produces one immutable `PlayerCommandFrame` per physics step and latches button edges. Gameplay HSMs and abilities consume it instead of polling hardware directly.
- Process aiming through an event-driven mouse accumulator using unscaled screen-relative motion, not an InputMap axis. Never multiply accumulated delta per physics tick; smoothing and acceleration default off, while sensitivity, axis scaling, and inversion are settings.
- Disabling Godot's accumulated-input mode is permitted only after validating CPU behavior with high-polling-rate mice.
- Gameplay snapshots canonical unshaken aim on the physics step. Camera smoothing, collision, FOV, and shake are presentation-only and cannot rotate or delay the gameplay aim basis.
- Keep engine integration values in `project.godot`. Bootstrap owners read `ProjectSettings` and supply typed dependencies; use feature overrides for Windows-specific values and do not add a platform-profile framework for one target.

### Critical Don't-Miss Rules

- Treat current tutorial, player, enemy, combat, and level code as prototype evidence, not architectural authority. When prototype behavior conflicts with `_bmad-output/planning-artifacts/architecture.md`, implement the approved architecture and migrate affected dependencies together.
- Grapple acquisition uses the canonical crosshair aim and authoritative first valid physics hit, without aim snapping or target-priority assistance. Presentation consumes that result rather than selecting independently.
- Replace the prototype's `StaticBody3D` check with the typed `Grappleable3D` contract supporting eligibility, static or moving attachment points, response values, state changes, destruction, and invalidation. Most geometry and created obstacles are grappleable by default.
- Grapple pull is acceleration-based and preserves existing momentum. The same `max_grapple_length_m` value - initially 35 m - governs acquisition and the active tether boundary; it is not the attachment distance. At maximum range, constrain only outward relative motion while preserving inward and tangential motion.
- Grapple release preserves current velocity. Wall sticking remains grapple-assisted and requires active grapple, held input, valid contact, and its speed/alignment conditions; it is not invulnerability.
- Capture bounded movement-derived combat facts in `MovementCombatContext` and resolved collision facts in `ImpactContext`. Damage calculation must not inspect the player controller or infer combat meaning from arbitrary velocity.
- Windup answers **when** an attack becomes dangerous; ability space defines **where or what** it affects; telegraph presentation communicates those authoritative facts. Telegraphs never own a second timer, collision shape, targeting solution, or gameplay phase.
- Keep `AttackDefinition` behavior separate from `DamageDefinition`. Snapshot source-side offense and modifiers when an attack or projectile launches; evaluate target defense, resistance, vulnerability, and incoming modifiers on impact.
- A detached projectile, hazard, status, tether, or delayed request is created through a typed domain spawner and carries stable source identity, execution ID, damage snapshot, scope, and run ID. It must not depend on its source node remaining alive; scene parentage controls lifetime, not combat credit.
- Encounter reset invalidates the old run ID, rejects late requests, cancels executions, removes scoped presentation, replaces the runtime root, recreates mutable state, and restores the player through `LevelController`.
- Implement M2 mechanics by composing the six approved families rather than creating unrelated per-enemy frameworks. Every threat defines readable warning, affected space, primary counter, recovery opportunity, grapple/wall interaction, source-death policy, and reset behavior.
- Climbing and flying AI discover bounded candidates from runtime geometry, navigation, player state, obstacles, and encounter bounds. Do not require authored climb routes, climb-entry anchors, flight anchors, flight connections, or separate flight volumes; rare override volumes remain optional.
- Only `LevelController` commits level completion, checkpoint restoration, and reward collection. Through M4, rewards are current health/coin grants and must not introduce inventory or persistent-RPG infrastructure.
- Put tunable movement, grapple, attack, enemy, AI, encounter, query, and cue values in immutable typed `.tres` definitions. Tune those Resources through gameplay iteration; do not scatter constants, mutate shared definitions during play, or introduce a live-tuning framework.
- Expected rejection uses compact typed reason enums; fallible operations return typed domain results that direct callers handle or propagate. Debug assertions protect programmer invariants, while release guards prevent unsafe continuation.
- Missing bespoke animation, audio, VFX, UI, or telegraph art may use a defined fallback or degrade presentation, but it cannot prevent otherwise valid gameplay simulation from running.

---

## Usage Guidelines

**For AI Agents:**

- Read this file before implementing game code and apply every rule relevant to the change.
- Treat current prototype behavior as evidence, not authority; use `_bmad-output/planning-artifacts/architecture.md` for rationale, edge cases, and conflict resolution.
- Consult the linked design documents before changing design-sensitive behavior.
- Update this file only when an approved dependency, architecture decision, or stable implementation contract changes.

**For Humans:**

- Keep this file lean and focused on unobvious agent guidance.
- Update it when the technology stack or approved architecture changes.
- Review it at milestone boundaries and remove rules superseded by an intentional redesign.

Last Updated: 2026-09-09
