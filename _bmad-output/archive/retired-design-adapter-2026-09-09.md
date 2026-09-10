---
title: "GrappleGame — Core Gameplay GDD Adapter"
project: "testgame"
document_type: "bmad-gdd-adapter"
status: 'superseded'
scope: "core-gameplay-validation"
game_type: "3D traversal-combat action RPG"
engine: "Godot 4.7.2-stable"
platforms:
  - "Windows PC"
created: "2026-08-31"
updated: '2026-09-09'
canonical_sources:
  game_design: "../project context/GAME_DESIGN_DOCUMENT.md"
  gameplay_systems: "../project context/GAMEPLAY_SYSTEMS.md"
  level_design: "../project context/LEVEL_AND_ENCOUNTER_DESIGN.md"
  architecture: "game-architecture.md"
  prototype_technical_baseline: "../project context/TECHNICAL_ARCHITECTURE.md"
  roadmap: "../project context/DEVELOPMENT_ROADMAP.md"
decision_log: "decision-log.md"
superseded_by: '_bmad-output/planning-artifacts/gdd.md'
---

# GrappleGame — Core Gameplay GDD Adapter

## 1. Document Role

This document is the BMad planning entry point for GrappleGame. It gives downstream architecture, epic, story, readiness and playtest workflows a concise statement of the current design intent and production boundary.

It does not replace the project's detailed documentation. Authority is divided as follows:

- [GAME_DESIGN_DOCUMENT.md](<../project context/GAME_DESIGN_DOCUMENT.md>) owns the game vision, pillars and core loop.
- [GAMEPLAY_SYSTEMS.md](<../project context/GAMEPLAY_SYSTEMS.md>) owns detailed traversal, combat, enemy and ability rules.
- [LEVEL_AND_ENCOUNTER_DESIGN.md](<../project context/LEVEL_AND_ENCOUNTER_DESIGN.md>) owns route, encounter, objective and tutorial rules.
- [TECHNICAL_ARCHITECTURE.md](<../project context/TECHNICAL_ARCHITECTURE.md>) records the current prototype baseline and the design contracts that motivated the target architecture.
- [game-architecture.md](game-architecture.md) owns approved target implementation decisions, system boundaries, patterns and feature mapping.
- [DEVELOPMENT_ROADMAP.md](<../project context/DEVELOPMENT_ROADMAP.md>) owns milestone sequencing and validation gates.
- This adapter owns the concise BMad handoff and current core-gameplay scope.

If two documents conflict, surface the conflict and resolve it in [decision-log.md](decision-log.md) rather than silently choosing one.

## 2. Executive Summary

GrappleGame is a third-person traversal-combat RPG built around authored, instanced vertical levels. The player uses jumping, grappling, wall running, wall sticking and momentum preservation to navigate levels and create combat opportunities.

Enemies do more than inflict damage. Their abilities change the value of routes, positions, surfaces, grapple targets, movement vectors and target priorities. The first development objective is a replayable gameplay slice proving that traversal, combat pressure, encounter structure and boss design form one coherent experience.

## 3. Core Fantasy and Pillars

The player fights through the environment rather than moving to a separate combat space. Expert play converts route knowledge, momentum, timing and spatial awareness into offensive advantage while preserving enough danger that committing to an attack remains meaningful.

### Pillar 1 — Freedom through momentum and spatial traversal

The whole three-dimensional environment is a movement space. Good aiming, timing, route choice and grapple release preserve or build useful momentum.

### Pillar 2 — High-risk combat powered by movement

Traversal creates attack opportunities, but committing to an attack exposes the player to retaliation, displacement, route denial or positional danger.

### Pillar 3 — Enemies are movement and combat problems

Every enemy ability asks a readable spatial or tactical question. Enemy pressure changes routes and decisions without routinely disabling the movement system.

### Pillar 4 — Readable danger, quick onboarding and deep mastery

Threats have visible or audible telegraphs, understandable active windows, consistent effects and learnable counterplay. Difficulty comes from executing a response under pressure rather than guessing what happened.

## 4. Core Gameplay Loop

### Encounter loop

1. Read the environment, available routes, grapple targets and enemy threats.
2. Build or preserve momentum through traversal.
3. Choose an approach, defensive maneuver or attack opportunity.
4. Commit while exposed to enemy pressure.
5. Read the response and continue moving.
6. Defeat or bypass the encounter under its authored rules.
7. Collect the available reward and continue.

### Level loop

1. Enter an authored instanced level.
2. Traverse spaces and resolve required encounters.
3. Discover optional routes, threats and rewards.
4. Reach the boss.
5. Defeat the boss by applying learned traversal-combat skills.
6. Receive the level reward and exit.

## 5. Current Development Objective

Build a complete core-gameplay validation slice before expanding narrative implementation, persistent RPG progression or the full world roster.

The approved technical boundary is Windows PC first with keyboard-and-mouse-only gameplay, a 1920x1080/60 FPS baseline, high-refresh presentation as best effort, and fixed-step gameplay independent of render rate.

The validation sequence is:

1. **M0 — Traversal Foundation**
2. **M1 — Movement-Combat Contract**
3. **M2 — Combat Pressure and Ability Vocabulary**
4. **M3 — Encounter and Level Shell**
5. **M4 — Boss and Complete Gameplay Slice**

M5 tutorial validation and M6 RPG expansion remain downstream milestones.

## 6. Milestone Summary

### M0 — Traversal Foundation

Prove that ground movement, air movement, jumping, grappling, momentum-preserving release, wall running, wall sticking, wall jumping and mistake recovery form a controllable and expressive movement vocabulary. Grapple remains an acceleration-based direct zip-pull with only the authored maximum grapple length enforced as its active connection boundary; attachment distance does not become a fixed rope length.

**Exit gate:** A player can complete a short route using the full movement vocabulary, understands why attempts succeed or fail and can recover from ordinary mistakes.

### M1 — Movement-Combat Contract

Prove that traversal creates offensive opportunities and that attacking creates meaningful exposure. The minimum slice contains one player melee attack, one readable melee enemy, health, damage, hit reaction, death, reset and one measurable movement-derived combat advantage.

**Exit gate:** A moving approach creates a deliberate advantage or opportunity that a stationary attack does not provide, and the player understands when attacks are dangerous and why damage occurred.

### M2 — Combat Pressure and Ability Vocabulary

Prove that the combat system can express the complete documented enemy-pressure vocabulary while preserving movement, readability, counterplay and recovery.

M2 is **capability-complete rather than content-complete**. Every documented mechanic receives a minimal playable prototype and counterplay test. M2 does not require a production-ready enemy, final presentation or world-specific variant for every mechanic.

#### M2A — Direct and spatial threats

- Direct lane shot
- Arcing bombardment
- Rotating plane or line sweep
- Damage gas or drifting hazard
- Airburst and aerial mine lattice

These mechanics test line crossing, cover, predicted position, altitude choice, movement timing and persistent spatial danger.

#### M2B — Displacement and movement disruption

- Harpoon or tether
- Knockback and displacement
- Wind, suction and directional vectors
- Anti-wall reach

These mechanics test recovery when velocity, position, grapple timing or an assumed safe position changes. They create movement problems rather than unavoidable control chains.

#### M2C — Route, surface and anchor manipulation

- Adhesive surfaces
- Temporary obstacle growth
- Anchor modification
- Surface state changes

These mechanics change the value or behavior of routes without routinely removing the player's movement vocabulary. Created obstacles and modified surfaces remain avoidable, readable, temporary, destructible or grapple-compatible as defined by the detailed system rules.

#### M2D — Prediction, visibility and deception

- Predictive mark
- Visibility obstruction
- Decoy or echo

These mechanics test observation, route variation and response to incomplete information. Deception has a consistent tell, and visibility effects preserve enough silhouettes, sound, geometry and grapple feedback for informed play.

#### M2E — Support and target-priority pressure

- Support tether
- Healing, armor, recovery or resistance support behavior
- Interruption and line-breaking counterplay
- Multi-enemy target-priority problems

The player can identify which enemy or connection must be interrupted and has more than one viable way to break the support relationship.

#### M2F — Ability interaction tests

Representative combinations are tested across pressure families, including combinations such as:

- Direct lane shot plus temporary obstacle growth
- Predictive mark plus knockback
- Visibility obstruction plus melee pursuit
- Support tether plus artillery
- Surface-state change plus anti-wall pressure
- Air mines plus directional wind

Combination tests determine whether telegraphs remain distinguishable, at least one viable response remains, recovery is possible after a mistake and the combination creates a decision rather than unavoidable damage.

#### Per-ability design contract

Every M2 prototype defines:

- The movement or combat question it asks
- Simulation-owned windup timing plus player-facing telegraph cues driven by the shared authoritative ability space
- Active effect and affected space or target
- Duration and player-facing feedback
- At least one primary counter
- At least one recovery option
- Grapple interaction
- Wall-run and wall-stick interaction
- Cancellation and source-death behavior
- Reset and replay behavior
- Invalid combinations or overlap rules
- Tunable values requiring playtest evidence

#### M2 exit gate

M2 passes when:

- Every documented ability mechanic has a runnable minimal prototype.
- Every mechanic creates a distinct movement, positioning, route, observation or target-priority question.
- Every mechanic has readable telegraphing and demonstrated counterplay.
- No common ability arbitrarily removes the entire movement vocabulary.
- Grappling, wall running and wall sticking remain useful but not universally safe.
- Ability effects reset reliably when their source dies or the encounter restarts.
- Representative two-ability combinations remain readable and survivable.
- The first-level production subset has been selected from the validated vocabulary.

M2 does not require final presentation, final numerical balance, a unique production enemy for every mechanic, all world variants, coordinated group AI, final bosses or the full player RPG ability roster.

### M3 — Encounter and Level Shell

Turn the validated movement and combat vocabulary into a repeatable instanced-level loop with level entry and exit, encounter activation and completion, required and optional encounter rules, death and restart, checkpoints, initial rewards, minimal HUD feedback and authored low, high, lateral and recovery routes.

**Exit gate:** A player can enter a level, traverse, fight, collect rewards, die, restart and complete a non-boss encounter sequence. Enemy compositions create meaningful route and target-priority decisions without unreadable overlap.

### M4 — Boss and Complete Gameplay Slice

Prove the complete traversal-combat level loop through a replayable boss slice. The Last Garden is the first candidate slice, using a playtest-selected subset of the validated M2 vocabulary.

Candidate functions include:

- Rootstalker: melee pursuit and recovery openings
- Spore Kite: arcing or predicted-position pressure
- Mycelial Weaver: route modification and support pressure
- Garden Heart: combined spatial, surface and aerial pressure

These are candidate implementations rather than permanent commitments.

**Exit gate:** The player defeats the boss by applying traversal and combat skills together. The encounter has a readable attack-response cycle, produces a reward and exit and can be replayed without accumulating invalid state.

## 7. Combat Ability Design Rules

Every combat ability must satisfy at least one of these purposes:

- Change the value of a route
- Change the value of a position or altitude
- Change the player's velocity or recovery problem
- Create a timing decision
- Create a target-priority decision
- Test observation or prediction
- Create an attack opening
- Combine with another pressure in a readable way

An ability that only deals damage without creating one of these decisions does not yet satisfy the game's combat pillars.

Enemy abilities normally preserve player agency. Hard movement cancellation, complete anchor denial, unavoidable control chains and full-screen blindness are exceptional mechanics requiring explicit design justification.

## 8. Playtest Questions

### M0

- Can players understand and execute the movement vocabulary?
- Can they preserve momentum and recover from mistakes?

### M1

- Does movement improve attack opportunity or outcome?
- Is combat commitment meaningfully risky?

### M2

- Can players identify what each ability is asking them to do?
- Is the counter understandable before or shortly after the first failure?
- Do combined abilities create decisions rather than confusion?
- Does movement remain expressive under pressure?
- Do players vary their routes and responses?

### M3

- Can players understand encounter state, rewards, death and restart?
- Do enemy compositions create meaningful route and target decisions?

### M4

- Does the boss test learned traversal-combat behavior?
- Is victory based on readable mastery rather than health attrition?

## 9. Deferred Scope

- Full narrative implementation
- Dialogue and cutscene systems
- Complete faction and mission content
- All ten production worlds
- Persistent RPG progression
- Final inventory and loadout systems
- Full weapon, armor and player-ability roster
- Final art, animation, audio and effects
- Complete enemy roster
- Final balance

Existing narrative and world documentation may inform names, themes, spaces and enemy concepts without becoming production dependencies.

## 10. Open Decisions

- Which M2 mechanics form the Last Garden production subset
- Which enemy effects may later be reused by player abilities
- Acceptable limits for hard control and movement cancellation
- Maximum readable ability overlap in ordinary and boss encounters
- Which tuning values require telemetry
- Which prototypes require automated tests versus playtest-only validation

## 11. Source Documents

- [Game Design Document](<../project context/GAME_DESIGN_DOCUMENT.md>)
- [Gameplay Systems](<../project context/GAMEPLAY_SYSTEMS.md>)
- [Level and Encounter Design](<../project context/LEVEL_AND_ENCOUNTER_DESIGN.md>)
- [Technical Architecture](<../project context/TECHNICAL_ARCHITECTURE.md>)
- [Development Roadmap](<../project context/DEVELOPMENT_ROADMAP.md>)
- [World Atlas](<../project context/WORLD_ATLAS.md>)
