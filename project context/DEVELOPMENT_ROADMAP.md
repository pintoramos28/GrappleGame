# GrappleGame - Development Roadmap

**Purpose:** Define the high-level sequence for proving GrappleGame's traversal, combat, level, and RPG foundations.

**Source of truth:** [GAME_DESIGN_DOCUMENT.md](GAME_DESIGN_DOCUMENT.md)

This roadmap is intentionally higher-level than an implementation task list. Each milestone is a validation gate. After the relevant supporting design documents are written, the milestone will receive its own detailed implementation plan containing tasks, data contracts, tuning work, test scenes, and acceptance tests.

## Product shape

GrappleGame is planned as an RPG built from authored, instanced levels. A level combines traversal, enemy encounters, exploration, drops, and a boss encounter. Boss death is the standard level-completion condition. The current prototype uses health and coins as drops; future versions may add weapons, armor, abilities, and persistent progression.

The first complete level does not need the entire final RPG or enemy roster. It needs a small, coherent vertical slice that proves the following relationship:

```text
Choose a route -> build movement -> commit to an attack -> survive the response -> defeat the boss -> earn a reward
```

## How to use this roadmap

1. The GDD defines the player experience, pillars, and intended level loop.
2. Supporting system documents define the rules and contracts for individual systems.
3. A milestone plan turns those rules into implementation tasks and test cases.
4. The milestone is implemented as a deliberately small playable slice.
5. The exit criteria are reviewed before expanding the system or adding content.

The milestones form a dependency path, but they are not completely serial. Design documents, test scenes, tutorial planning, and enemy planning can proceed in parallel once their prerequisites are understood.

## Planned supporting documents

These documents should be created before detailed plans for the relevant milestones:

- `docs/MOVEMENT_AND_TRAVERSAL_SPEC.md` - Ground, air, jump, wall-run, wall-stick, momentum, surface-relative velocity, input forgiveness, and traversal tuning.
- `docs/GRAPPLEABLE_TARGET_SPEC.md` - Crosshair targeting, grappleable properties, static and moving targets, target responses, invalidation, and zip-pull behavior.
- `docs/PLAYER_ATTACK_AND_ABILITY_SPEC.md` - Attack abilities, allowed movement states, melee and ranged behavior, timing, targeting, velocity policy, and movement context.
- `docs/COMBAT_RESOLUTION_SPEC.md` - Damage, health, hit reactions, poise, stagger, knockback, weak points, resistances, and future modifiers.
- `docs/ENEMY_DESIGN_SPEC.md` - Enemy roles, movement problems, patterns, telegraphs, counters, variants, boss structure, and level usage.
- `docs/PROJECTILE_AND_THREAT_FEEDBACK_SPEC.md` - Projectile paths, world collision, reaction time, cover, threat readability, and impact feedback.
- `docs/LEVEL_ENCOUNTER_AND_TUTORIAL_SPEC.md` - Instanced level structure, encounter flow, route authoring, objectives, drops, tutorial stages, checkpoints, and completion.
- `docs/REWARDS_AND_RPG_PROGRESSION_SPEC.md` - Health and coin drops, reward tables, weapons, armor, abilities, loadouts, and persistence.
- `docs/PRESENTATION_AND_FEEDBACK_SPEC.md` - Gameplay-critical feedback using simple prototype visuals as well as future audio, animation, particles, HUD, and camera effects.

These files are planned supporting documents; they are not created by this roadmap pass.

## Milestones

### M0 - Traversal sandbox

**Purpose:** Prove that the core movement vocabulary is controllable, expressive, and reliable before combat complexity is introduced.

**Minimum scope:**

- Shared baseline traversal tuning through `PlayerTraversalTuning`, while retaining exported scene overrides for rapid prototyping.
- Ground movement, air movement, jumping, coyote time, and jump buffering where needed for reliable control.
- Crosshair-directed grapple targeting with first-hit behavior and no target priority or aim snapping.
- Grappleable surface and moving-target support using a reusable target contract.
- Zip-pull physics that preserves release velocity and does not use a physical rope constraint.
- Wall-run fluidity checks based on wall-relative velocity and approach angle.
- High-speed wall contact braking that preserves useful tangential travel while reducing the selected normal or thresholded component.
- Wall-run handling for curved, faceted, and changing-normal surfaces.
- Tactical wall sticking that pauses movement but does not grant invulnerability.
- A traversal test space with gaps, flat walls, corners, curved or faceted walls, grappleable surfaces, and recovery areas.

**Dependencies:** Current player and grapple prototype.

**Exit criteria:**

- A player can complete a short route using ground movement, jump, grapple, release, wall-run, wall-stick, and wall-jump actions.
- Near-perpendicular impacts do not produce visually awkward wall-run transitions.
- A valid high-speed wall contact can brake into a stable wall run without erasing useful along-wall travel.
- Non-flat walls do not cause unacceptable jitter or unexplained direction changes.
- Grapple behavior is consistent across test surfaces and moving targets.

**Not required:** Combat, loot, final art, boss behavior, or persistent progression.

### M1 - Combat contract

**Purpose:** Prove that traversal creates offensive opportunities and that committing to an attack creates meaningful risk.

**Minimum scope:**

- An `AttackAbility` structure that can initially allow attacks in all movement states.
- One player melee attack using the existing state-machine timing.
- A movement-combat context containing movement state, approach direction, height, and relevant speed.
- Basic physical damage, health, hurtboxes, hitboxes, death, and a simple hit reaction.
- One melee enemy with a readable windup, active window, recovery, and pursuit behavior.
- Basic feedback using simple meshes, colors, timing, and debug HUD elements.
- A first pass at movement-derived attack outcomes, such as poise, stagger, knockback, reach, or capped damage changes.

**Dependencies:** M0 traversal state and velocity information.

**Exit criteria:**

- A moving approach produces a deliberate combat advantage or different combat outcome from a stationary attack.
- The player understands when the enemy can hit them and why damage occurred.
- The player can attack while moving, grappling, wall-running, or wall-sticking unless a specific attack rule says otherwise.
- Enemy death and player death can be reset reliably.

**Not required:** A complete damage-type system, a large attack roster, bosses, or RPG statistics.

### M2 - Ranged pressure

**Purpose:** Make enemy attacks shape traversal routes rather than simply adding damage to the existing melee loop.

**Minimum scope:**

- One readable direct or arcing projectile attack.
- Projectile timing, target-lock behavior, world collision, lifetime, and removal rules.
- Basic projectile trajectory and impact feedback.
- One ranged enemy that creates a meaningful line-of-fire or area-denial problem.
- Level geometry that supports cover, height changes, wall movement, and route crossing.
- Player ranged attack support through the same attack-ability structure when the player ranged design is ready.

**Dependencies:** M0 movement and M1 health, damage, attack, and telegraph contracts.

**Exit criteria:**

- The player can identify the threat, choose a movement response, and understand whether cover or speed was effective.
- Projectiles behave consistently against world geometry and player hurtboxes.
- Wall sticking remains targetable and does not become an unintended safe state.
- The ranged enemy changes the value of at least two traversal routes.

**Not required:** Multiple projectile families, coordinated groups, complex navigation, or final presentation.

### M3 - Encounter and level shell

**Purpose:** Turn the mechanics into a repeatable instanced-level loop with failure, recovery, and rewards.

**Minimum scope:**

- An instanced level entry and exit flow.
- Encounter definitions for enemy composition, spawn points, activation, and completion.
- Required and optional encounter rules.
- Health and coin drops using an initial reward table.
- Player death, restart, checkpoint, and game-over behavior.
- Minimal HUD or equivalent feedback for health, drops, encounter state, and level state.
- Authored route choices that include exposed, safe, fast, and movement-intensive options.
- A non-boss encounter sequence that can be completed from entry to reward.

**Dependencies:** M0 through M2 minimum system contracts.

**Exit criteria:**

- A player can enter a level, traverse, fight, collect drops, die, restart, and finish a non-boss encounter sequence.
- Encounter completion and reset do not depend on scene-specific hard-coded logic.
- Optional enemy bypassing has a clearly defined tradeoff.
- Level geometry and enemy pressure produce meaningful route decisions.

**Not required:** Persistent RPG progression, a complete level-selection menu, or a final boss.

### M4 - Boss slice

**Purpose:** Prove the complete traversal-combat level loop with boss death as the completion condition.

**Minimum scope:**

- A dedicated boss design using the enemy design document.
- A small number of readable attack patterns with distinct movement responses.
- At least one defensive state, opening, weak point, or movement-specific vulnerability.
- Boss pressure that addresses height, route choice, wall movement, grapple use, or wall sticking.
- Boss health, death, reward, and level-completion signaling.
- A boss reward using the current health/coin system or a simple prototype reward.
- A complete restart and reward/exit flow.

**Dependencies:** M1 through M3, plus the first versions of the enemy, combat, projectile, and level specifications.

**Exit criteria:**

- The boss fight has a readable attack-response cycle rather than being only a health check.
- The player can defeat the boss by applying traversal and combat skills together.
- Boss death completes the instanced level and produces a reward or exit state.
- The encounter can be restarted and replayed without accumulating broken state.

**Not required:** The final boss roster, persistent RPG progression, or every planned combat modifier.

### M5 - Tutorial validation

**Purpose:** Convert the traversal sandbox into a reliable onboarding experience.

**Minimum scope:**

- A tutorial stage contract containing lesson, setup, required action, success condition, failure recovery, and next skill.
- Verification for pulling, releasing, steering, catching, wall running, wall sticking, long-gap movement, and grapple chaining.
- Shared baseline grapple and traversal tuning with deliberate exceptions documented.
- Quick reset or retry for failed stages.
- Summit completion trigger for the non-combat tutorial.
- Simple signs and prototype visuals that explain the action without requiring final art.

**Dependencies:** M0. Combat lessons can depend on M1 or M2 when they are added.

**Exit criteria:**

- Each stage can detect whether the player performed the intended action.
- Failure is recoverable without restarting the entire application or level unnecessarily.
- A new player can progress from basic grapple use to chaining and wall interaction.
- The tutorial teaches the same core behavior used in the instanced combat levels.

**Not required:** Final narrative, final environment art, or RPG rewards.

### M6 - RPG expansion

**Purpose:** Add the RPG layer after the traversal-combat loop is proven and balanceable.

**Minimum scope:**

- A reward-table and inventory foundation.
- Health and coins retained as simple immediate rewards.
- Weapons, armor, and abilities represented as data-driven items or loadout entries.
- A player loadout and ability-selection flow.
- Persistent progression only after level rewards and restart behavior are stable.
- A fixed test loadout or normalized balance mode so RPG stats do not hide movement-combat problems during development.

**Dependencies:** M3 level rewards and M4 boss completion, plus the rewards and RPG progression specification.

**Exit criteria:**

- Rewards can be earned, stored, equipped, and used in a later level.
- New equipment changes play without making the core traversal rules unreadable.
- Progression supports replaying instanced levels rather than replacing the movement-combat loop.

**Not required:** A large loot pool, procedural generation, or a continuous open world.

## Supporting work that can run in parallel

- Enemy design can be written before all enemy systems are implemented, but each enemy should not be added until its movement problem and counterplay are specified.
- Tutorial design can begin during M0 and be implemented once traversal behavior stabilizes.
- RPG reward design can begin during M3 using health and coins as the first concrete reward types.
- Presentation work can use simple prototype geometry while preserving the timing and feedback contracts needed by the pillars.
- Architecture work should follow the active milestone's needs rather than creating speculative systems for the entire final game.

## Detailed planning rule

Before starting a milestone, create or update the supporting documents it depends on. The detailed milestone plan should then contain:

- Design decisions and unresolved questions.
- Systems and scenes affected.
- Data resources and signals required.
- Tunable values and default baselines.
- Test scenes or test routes.
- Player-facing acceptance criteria.
- Failure, reset, and debugging behavior.
- Explicit out-of-scope features.

This keeps the roadmap stable while allowing each milestone's implementation plan to become more concrete as the underlying systems are designed.
