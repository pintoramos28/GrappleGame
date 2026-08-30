# GrappleGame — Technical Architecture
**Purpose:** Scene, resource, component, state-machine and cross-system ownership rules for the Godot implementation.

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

- **PlayerTraversalTuning:** A shared resource for baseline movement, jump, grapple, wall-run, and wall-stick values. Exported scene variables remain useful for rapid prototyping and can override or inspect these defaults when a level deliberately needs different tuning.
- **Grappleable:** A component or resource on any eligible surface or target. It exposes grapple eligibility, response behavior, grapple-point behavior, and invalidation rules. It supports static surfaces and moving enemies without requiring the player to check for a concrete body type.
- **MovementCombatContext:** Temporary data captured when an attack begins or lands, including movement state, approach direction, height, and relevant speed. It allows combat resolution to reward movement without turning the player controller into a damage calculator.
- **AttackAbility:** A resource describing how an attack behaves: allowed movement states, timing, targeting, velocity policy, hitbox or projectile, and movement-context rules. `AttackData` remains focused on damage values and combat metadata.
- **Telegraph:** A shared attack-warning contract containing warning duration, active window, affected shape, and feedback identifiers. Presentation can initially use simple meshes, colors, and timers while the gameplay timing remains stable.
- **EncounterDefinition:** A data resource describing encounter participants, spawn points, activation rules, completion conditions, and available drops.
- **LevelObjective:** A signal-driven objective that can complete a level when a condition such as boss death is met, without hard-coding level progression into the boss controller. The tutorial can use a summit trigger as a different objective type.
- **RewardTable:** A data resource that supports current health and coin drops and can later provide weapons, armor, abilities, and other RPG rewards.
- **WeakPoint:** A future specialized hurtbox or combat component that can define an exposed location, movement requirement, attack-angle rule, or damage response for elites and bosses.

LimboAI is used for both hierarchical state machines and enemy behavior trees. The separation between state machines and data resources is intended to make new movement modes, attacks, enemy definitions, and levels easy to add without rewriting the core systems.

## 2. Technical Ownership

The player controller owns movement state and traversal physics. Enemy definitions own enemy-specific tuning and attack selection. The combat resolver owns damage calculation. Levels own encounter activation, objective state, rewards and completion. Portal and fungal systems own resonance, infection and compatibility state.

No system should reach into another system's internal implementation when a resource, signal or contract can express the dependency.

## 3. Cross-Document Integration

- Gameplay rules are defined in [GAMEPLAY_SYSTEMS.md](GAMEPLAY_SYSTEMS.md).
- Level and encounter assembly is defined in [LEVEL_AND_ENCOUNTER_DESIGN.md](LEVEL_AND_ENCOUNTER_DESIGN.md).
- Portal and fungal rules are defined in [PORTAL_AND_FUNGAL_ECOLOGY.md](PORTAL_AND_FUNGAL_ECOLOGY.md).
- World-specific content is defined in [WORLD_ATLAS.md](WORLD_ATLAS.md).
- Prototype sequencing remains in [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md).

## 4. Implementation Review Checklist

When adding a system, identify its owning scene/resource, its public data contract, its signals, its cancellation/death behavior, its test surface and the design document that defines its intended player-facing behavior.
