# GrappleGame — Game Design Document
**Status:** Current prototype implementation
**Engine:** Godot 4.7, Forward+ renderer, Jolt Physics
**Primary experience:** Third-person traversal, combat, and RPG progression across instanced vertical 3D levels

**Planning companion:** [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md)

## Table of Contents

- [1. Game Overview](#1-game-overview)
  - [Design pillars](#design-pillars)
  - [Pillar interaction: the intended combat-traversal relationship](#pillar-interaction-the-intended-combat-traversal-relationship)
- [2. Core Gameplay Loop](#2-core-gameplay-loop)
- [3. Player Controls and Camera](#3-player-controls-and-camera)
- [4. System Reference Map](#4-system-reference-map)
- [5. World and Level Structure](#5-world-and-level-structure)
- [6. Presentation and Feedback](#6-presentation-and-feedback)
- [7. Current Prototype Boundaries and Future System Hooks](#7-current-prototype-boundaries-and-future-system-hooks)
- [8. Related Documents](#8-related-documents)

## 1. Game Overview

GrappleGame is a momentum-driven traversal and combat RPG prototype built around authored, instanced 3D levels. The player navigates each level using camera-directed movement, jumping, grappling, wall running, and wall sticking. Enemies detect the player, reposition using simple behavior trees, and attack with melee or projectile attacks.

The intended structure is a sequence of self-contained levels rather than one continuous open world. A level combines traversal, enemy encounters, exploration, drops, and a boss encounter whose defeat completes the level. The long-term RPG layer may add weapons, armor, abilities, and persistent progression. The current prototype uses health and coins as drops while the core traversal-combat loop is being defined.

The current build is primarily a systems testbed. It demonstrates the feel of traversal, the interaction between movement and combat, enemy perception, and reusable combat data. It does not yet contain a complete progression loop, user interface, save system, formal level completion, or a complete win/lose flow.

### Design pillars

The game is a deliberate mix of high-freedom traversal, high-risk combat, and pattern-based enemy encounters. Traversal is not a way to skip combat, and combat is not a pause from traversal. They are intended to be one connected skill expression: the player moves to create an attack opportunity, attacks while exposed to danger, and uses movement to survive the consequences.

#### Pillar 1 — Freedom through momentum and spatial traversal

Movement is the game’s primary differentiator. The player should feel able to move through the entire space rather than being limited to traditional ground movement, small isolated jumps, slow climbing, or slow gliding. Height, distance, walls, surfaces, and grapple points should create a large number of possible routes.

The core movement fantasy is:

- **Basic movement is quick to learn:** move, jump, aim, grapple, hold to pull, and release to carry momentum.
- **Movement feels freeing immediately:** the player should gain meaningful vertical and horizontal mobility early rather than spending the opening hours unlocking basic traversal.
- **Momentum is earned and preserved:** good timing, clean direction changes, and well-chosen releases should produce more useful movement than simply holding a button.
- **The environment is part of the moveset:** walls, buildings, branches, corners, gaps, and enemy positions should all change what routes are possible.
- **Advanced movement remains expressive:** fluid grapple chains, changing direction without losing speed, increasing acceleration, wall interactions, and momentum-preserving releases should provide a long skill curve.

The game should avoid turning the grapple into an automatic climb or teleport. The player must still aim, choose a target, manage the pull, read the environment, and decide when to release. The goal is not unrestricted movement without consequence; it is a large movement vocabulary that rewards execution and decision-making.

#### Pillar 2 — High-risk, high-reward combat powered by movement

Combat is the second primary pillar. The player’s mobility exists to create offensive and defensive opportunities, not to enable simple kiting or effortless escapes. Combat should be fast-paced, but entering an attack position should expose the player to meaningful risk.

At lower levels of mastery, movement should let players:

- Blindside enemies from unexpected directions.
- Approach from above, behind, or around environmental cover.
- Reach positions where an enemy has difficulty gaining an advantage.
- Adjust an approach when a direct ground attack is unsafe.
- Create flexibility without requiring perfect execution.

At higher levels of mastery, movement should become an active part of the attack itself. Expert players should be able to:

- Perform advanced maneuvers to avoid fast or complex enemy attacks.
- Attack enemies that are difficult to reach or that move quickly.
- Build and preserve momentum to increase the power or effectiveness of melee attacks.
- Reposition during an encounter to target exposed weaknesses.
- Choose when to commit to a dangerous attack rather than always retreating.

Combat should therefore create a tension between **speed, position, commitment, and safety**. A fast approach may produce a stronger opening but leave the player exposed. A safe position may reduce immediate danger but give the enemy time to recover or reposition. The strongest play should come from turning traversal skill into a deliberate offensive advantage.

#### Pillar 3 — Enemies are movement and combat problems

Enemies should exist to make the player use the movement system intelligently. They are not only targets to defeat; they are forces that shape the space and test the player’s ability to move under pressure.

The enemy roster should range from simple mobs to bosses, drawing from the encounter readability and spatial problem-solving of 3D Zelda games such as *Breath of the Wild* and *Tears of the Kingdom*, combined with the pattern learning and punishment of Souls-like encounters.

Enemy roles should have clear movement-focused purposes:

| Enemy role | Primary purpose | Movement question it creates |
|---|---|---|
| Ranged mob | Environmental awareness and movement discipline | Where can I move so I can keep momentum without crossing an unsafe line of fire? |
| Melee mob | Punishing stagnation and passive ground play | How do I keep changing position instead of simply walking around the enemy? |
| Elite enemy | Combining pressure types and testing execution | Can I maintain a useful route while responding to faster attacks or stronger defenses? |
| Boss | Pattern mastery, spatial control, and weakness exploitation | Can I learn the encounter, move through its threats, and create a high-value opening? |

Ranged mobs should prevent the player from treating the air or ground as completely safe. Their attacks, firing positions, and environmental relationships should encourage the player to read cover, height, timing, and available surfaces while moving. The goal is not to remove freedom, but to make movement require skill.

Melee mobs should punish players who remain stagnant, walk everywhere, or ignore grappling. They should create close-range pressure that makes vertical movement, rapid repositioning, wall interaction, and momentum management valuable.

Bosses should combine these pressures rather than simply having more health. A boss may use melee patterns to punish stillness, ranged patterns to restrict easy movement, and defensive states or weak points that require the player to approach from a particular angle or with a particular amount of momentum.

#### Pillar 4 — Readable danger, fast onboarding, deep mastery

The game should be approachable at the basic level while remaining difficult to master. Players should understand what they can do and why they were hit, even when the optimal response is challenging.

This requires:

- Clear audiovisual telegraphs for enemy attacks.
- Distinct attack timing and readable active windows.
- Obvious grapple target feedback and consistent grapple behavior.
- Environments that teach routes and mechanics through layout before demanding precision.
- Early enemies that teach one movement lesson at a time.
- Later encounters that combine previously learned lessons instead of introducing arbitrary rules.

The intended mastery curve is:

1. **Beginner:** The player can move, grapple to reach places, and survive simple encounters.
2. **Developing player:** The player chains grapples, uses walls, chooses better approaches, and avoids obvious enemy threats.
3. **Advanced player:** The player maintains flow through direction changes, preserves or builds momentum, attacks from advantageous vectors, and uses the environment deliberately.
4. **Expert player:** The player routes through complex spaces while reading enemy patterns, converts traversal momentum into offensive power, and handles boss attacks without abandoning the movement flow.

#### Supporting pillar — Systems should reinforce the game’s identity

The implementation should remain modular so that new movement states, enemy roles, attack patterns, traversal spaces, and boss mechanics can be added without weakening the core interaction between movement and combat. Reusable scenes, data-driven definitions, state machines, and behavior trees support this goal.

### Pillar interaction: the intended combat-traversal relationship

The intended relationship between the main pillars is:

1. The environment creates possible routes and movement options.
2. Enemy attacks make some routes unsafe and others valuable.
3. The player chooses a route, builds momentum, and commits to an attack angle.
4. The attack creates reward but also creates exposure or a new positional problem.
5. The player reads the enemy response and continues moving rather than returning to passive ground play.

At the lowest skill level, movement provides access and escape options. At higher skill levels, movement determines attack quality, damage potential, and survival. The desired end state is a player who feels they are fighting *through* the space, not moving to a separate combat arena inside it.

## 2. Core Gameplay Loop

The game has two nested loops.

The short-form encounter loop is:

1. Read the space and identify useful surfaces, grapple targets, threats, and routes.
2. Build momentum through movement, jumps, grapples, wall runs, and releases.
3. Commit to an attack or defensive maneuver while exposed to enemy pressure.
4. Read the enemy response and continue moving rather than returning to passive ground play.
5. Defeat the encounter, collect available drops, and continue toward the next route or position.

The level loop is:

1. Enter an instanced level with the current player loadout.
2. Traverse authored spaces, resolve required encounters, and collect health, coins, and future rewards.
3. Reach the boss encounter.
4. Defeat the boss. Boss death is the standard level-completion condition.
5. Collect or reveal the level reward and exit the level.

Optional enemies may be bypassable when a level explicitly supports that choice, but bypassing should trade away reward, safety, information, or another advantage. The player should not be able to bypass the level's required boss encounter.

The separate tree tutorial is a non-combat onboarding exception: reaching and activating its summit goal completes the tutorial. The default arena currently does not contain a boss or a connected completion condition.

## 3. Player Controls and Camera

| Action | Input | Current behavior |
|---|---|---|
| Move | `WASD` | Camera-relative horizontal movement |
| Jump | `Space` | Ground jump, wall-run jump, or wall-stick jump depending on state |
| Grapple | Hold right mouse | Use the camera crosshair to attach to the first grappleable surface or target under the ray and pull toward the hit point |
| Attack | Left mouse or `F` | Start the player melee attack sequence |
| Release cursor | `Esc` | Makes the mouse visible and releases capture |

The player uses a third-person `SpringArm3D` and `Camera3D`. Mouse movement rotates the player horizontally and controls camera pitch vertically. The player scene clamps pitch between -45 and 70 degrees in the current setup, and the mouse is captured on startup until `Esc` is pressed.

Grapple targeting is intentionally crosshair-directed. The game does not plan to use target priority or aim snapping. Target feedback should communicate whether the surface or target under the crosshair is grappleable without selecting a different target for the player.

## 4. System Reference Map

The detailed system specifications have been split into focused documents:

| System | Detailed document |
|---|---|
| Movement, grappling, combat, enemies and projectiles | [GAMEPLAY_SYSTEMS.md](GAMEPLAY_SYSTEMS.md) |
| Level flow, tutorials, objectives and encounters | [LEVEL_AND_ENCOUNTER_DESIGN.md](LEVEL_AND_ENCOUNTER_DESIGN.md) |
| Scenes, resources, state machines and contracts | [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md) |
| Setting, narrative and world-specific content | [WORLD_BUILDING.md](WORLD_BUILDING.md) and its linked references |

The summaries in this document describe the intended player experience. The focused documents own the detailed rules and implementation-facing definitions.

## 5. World and Level Structure

The game uses authored, self-contained vertical levels rather than one continuous open world. Each level combines traversal, exploration, enemy encounters, optional rewards and a completion condition. The default completion condition is boss death, while the tree grapple tutorial uses a summit objective.

Level-specific routes, encounter composition and tutorial stages are defined in [LEVEL_AND_ENCOUNTER_DESIGN.md](LEVEL_AND_ENCOUNTER_DESIGN.md).

## 6. Presentation and Feedback

Current feedback is intentionally lightweight and mostly 3D:

- Emissive grapple cursor, rope, anchors, and projectiles.
- Animated player and enemy attack arcs.
- Tutorial signs using `Label3D`.
- Simple colored materials for player, enemies, buildings, floor, branches, and goals.
- Debug damage/death information printed to the output.

There is currently no HUD, health bar, crosshair UI, audio, music, particle system, animation controller, hit-stop, camera shake, or damage-number presentation.

The prototype can continue using simple meshes and basic animations. Feedback requirements are gameplay requirements rather than an art-quality requirement: players must be able to identify grapple validity, enemy danger, attack timing, damage, and level state even when the presentation uses primitive geometry and simple effects.

## 7. Current Prototype Boundaries and Future System Hooks

The current prototype boundaries are organized into the dependency-aware roadmap in [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md). The first complete level does not require every future system; it requires a minimal traversal-combat loop, readable enemies, drops, a boss, boss-death completion, and restart/reward flow.

Near-term core-slice systems include:

- HUD or equivalent player/enemy health and level-state feedback.
- Respawn, restart, checkpoints, and game-over flow.
- Tutorial objective detection and level completion.
- Scene transitions or a level-entry/exit shell.
- Grappleable surface and moving-target support. The grapple remains a crosshair-directed zip-pull; a physical rope constraint is not planned.
- Minimal movement-aware combat resolution, enemy behavior, projectiles, and attack telegraphs.
- Health and coin drops, encounter management, and a boss-death objective.

Systems that can follow the first complete level include:

- Navigation meshes, obstacle-aware enemy movement, and coordinated group behavior.
- Active poise/stagger, knockback behavior, status effects, weak points, and concrete combat modifiers.
- Animation, audio, particles, camera shake, hit-stop, and other presentation expansion.
- Scene selection, save/load, persistent progression, inventory, weapons, armor, abilities, and expanded RPG rewards.

These boundaries should be treated as the current scope of the prototype rather than unfinished behavior hidden behind the existing systems.

## 8. Related Documents

- [GAMEPLAY_SYSTEMS.md](GAMEPLAY_SYSTEMS.md)
- [LEVEL_AND_ENCOUNTER_DESIGN.md](LEVEL_AND_ENCOUNTER_DESIGN.md)
- [TECHNICAL_ARCHITECTURE.md](TECHNICAL_ARCHITECTURE.md)
- [WORLD_BUILDING.md](WORLD_BUILDING.md)
- [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md)
