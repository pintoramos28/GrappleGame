# GrappleGame — Technical Architecture
**Purpose:** Scene, resource, component, state-machine and cross-system ownership rules for the Godot implementation.

This document records the current prototype baseline and the design contracts that motivated architecture work. The approved target implementation authority is [`architecture.md`](../../architecture.md); when this baseline and the generated architecture differ, implementation follows the generated architecture and this document is synchronized rather than treated as a competing specification.

## Table of Contents

- [1. Data and Architecture](#1-data-and-architecture)
  - [1.1 Planned cross-system contracts](#11-planned-cross-system-contracts)
- [2. Technical Ownership](#2-technical-ownership)
- [3. Cross-Document Integration](#3-cross-document-integration)
- [4. Implementation Review Checklist](#4-implementation-review-checklist)

## 1. Data and Architecture

The prototype is organized around reusable scenes and resources:

- `player.tscn` and `player_controller.gd` — player body and traversal.
- Player movement and attack state scripts — state-specific behavior.
- `enemy.tscn` and `enemy_controller.gd` — reusable enemy body and orchestration.
- `EnemyDefinition` resources — enemy-specific tuning.
- `AttackData` resources — attack damage and metadata.
- `CombatStatsData` resources — attack power, defense, crits, and resistances.
- Combat hitbox/hurtbox/health scripts — shared combat infrastructure.
- `enemy_behavior.tres` and AI task scripts — behavior-tree logic.
- `building.tscn` — resizable static traversal geometry.
- `projectile.tscn` — reusable ranged attack projectile.

### 1.1 Planned cross-system contracts

The following abstractions are intended to connect the systems without making the player controller, enemies, levels, and combat resolver depend directly on one another:

- **PlayerTraversalTuning:** An immutable shared Resource for baseline movement, jump, grapple, wall-run, and wall-stick values. A deliberate challenge variant references an alternate typed Resource; scenes do not duplicate scalar overrides.
- **Grappleable3D:** An optional typed component for moving, stateful, hazardous, resistant, modified, or invalid targets. Ordinary eligible collision geometry receives a built-in static response without per-surface authoring. The contract exposes validation and a sampled anchor position, velocity, response, and invalidation reason without controlling player motion.
- **MovementCombatContext:** An immutable source-motion snapshot captured at an attack's declared commit, active-start, or delivery-spawn phase. Target-relative collision, height, velocity, and weak-point facts are captured separately in `ImpactContext`, keeping combat resolution independent of player-controller internals.
- **AttackDefinition and DamageDefinition:** `AttackDefinition` owns lifecycle timing, allowed movement states, targeting, delivery, grapple and velocity policies, context capture, and source-death behavior. `DamageDefinition` owns damage values and combat metadata. Detached delivery objects carry a launch-time `DamageSnapshot`; the current `AttackData` and `CombatStatsData` types migrate to `DamageDefinition` and `CombatStatsDefinition` without parallel authorities.
- **Ability space and telegraph presentation:** Windup is the simulation-owned pre-active phase; `AbilitySpatialDefinition` and its execution-local binding own affected targets and shapes; a telegraph is visual or audible presentation of those facts. Telegraphs read committed windup progress and the same spatial snapshot used by active delivery, and never own gameplay timers or collision.
- **EncounterDefinition:** A data resource describing encounter participants, spawn points, activation rules, completion conditions, and available drops.
- **LevelObjective:** A scoped fact consumer that emits completion exactly once without hard-coding progression into a boss or trigger. Boss death and tutorial summit arrival are adapters; `LevelController` alone commits level completion.
- **CheckpointDefinition and CheckpointRuntimeState:** An authored checkpoint plus its in-memory session restart state; these do not imply a persistent save system.
- **RewardTableDefinition:** A data Resource that resolves current health and coin entries into immutable `RewardGrant` occurrences. RPG rewards remain an M6 decision rather than a current abstraction.
- **WeakPoint:** A future specialized hurtbox or combat component that can define an exposed location, movement requirement, attack-angle rule, or damage response for elites and bosses.

LimboAI is used for both hierarchical state machines and enemy behavior trees. The separation between state machines and data resources is intended to make new movement modes, attacks, enemy definitions, and levels easy to add without rewriting the core systems.

## 2. Technical Ownership

The player movement HSM owns locomotion state, while one `PlayerMotor` owns authoritative velocity and the single movement commit. Ability executions own attack phase timing; enemy definitions and LimboAI own enemy-specific policy and action selection without applying damage directly. The combat resolver owns source-snapshot and target-impact damage calculation. Levels own encounter activation, objective state, rewards and completion. Portal and fungal systems own resonance, infection and compatibility state.

No system should reach into another system's internal implementation when a resource, signal or contract can express the dependency.

## 3. Cross-Document Integration

- Gameplay rules are defined in [GAMEPLAY_SYSTEMS.md](GAMEPLAY_SYSTEMS.md).
- Level and encounter assembly is defined in [LEVEL_AND_ENCOUNTER_DESIGN.md](LEVEL_AND_ENCOUNTER_DESIGN.md).
- Portal and fungal rules are defined in [PORTAL_AND_FUNGAL_ECOLOGY.md](PORTAL_AND_FUNGAL_ECOLOGY.md).
- World-specific content is defined in [WORLD_ATLAS.md](WORLD_ATLAS.md).
- Prototype sequencing remains in [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md).
- Approved target implementation decisions and feature-to-architecture mapping are defined in [`architecture.md`](../../architecture.md).

## 4. Implementation Review Checklist

When adding a system, identify its owning scene/resource, its public data contract, its signals, its cancellation/death behavior, its test surface and the design document that defines its intended player-facing behavior.
