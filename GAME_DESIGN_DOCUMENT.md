# GrappleGame — Game Design Document

**Status:** Current prototype implementation  
**Engine:** Godot 4.7, Forward+ renderer, Jolt Physics  
**Primary experience:** Third-person traversal, combat, and RPG progression across instanced vertical 3D levels

**Planning companion:** [DEVELOPMENT_ROADMAP.md](DEVELOPMENT_ROADMAP.md)

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

## 4. Player Movement System

### 4.1 Movement model

Movement is implemented by a `CharacterBody3D` using `move_and_slide()`. Input is transformed through the player’s current horizontal basis, so `WASD` moves relative to the player/camera orientation.

The movement controller uses acceleration rather than directly assigning speed:

- Ground movement approaches a target speed using ground acceleration.
- Air movement approaches a separate target speed using lower air acceleration.
- Releasing movement applies ground or air deceleration.
- Horizontal speed targets are different for grounded and airborne movement.
- Gravity is applied when the player is not on the floor.

The current implementation represents momentum directly through the physics velocity rather than through a separate momentum meter. When movement input is held, the controller calculates an input direction multiplied by the grounded or airborne maximum speed, then moves the current horizontal velocity toward that target using acceleration. This preserves some existing velocity during a direction change but gradually replaces velocity that is perpendicular to the new input direction.

The current player instance in `main.tscn` uses a 10 m/s ground speed, 10 m/s air speed, 30 m/s² ground deceleration, and 5 m/s² air deceleration. The base player scene exposes these values for tuning.

There is currently no coyote time, jump buffering, stamina, crouch, slide, air dash, or explicit momentum meter. The player’s momentum is represented directly by the physics velocity.

Coyote time and jump buffering are planned input-forgiveness options for the traversal system. Coyote time permits a jump shortly after leaving a ledge; jump buffering remembers a jump pressed shortly before landing and executes it when the landing occurs. These should make basic traversal more reliable without changing the advanced movement vocabulary.

### 4.2 Movement state machine

Movement is controlled by a LimboAI hierarchical state machine with these states:

- **Grounded:** Normal movement, jump input, and grapple initiation.
- **Airborne:** Gravity, air control, wall-run detection, and grapple initiation.
- **Grappling:** Pull physics, air control, grapple release, and wall-stick detection.
- **WallRun:** Movement along a runnable wall, reduced gravity, and wall jumping.
- **WallStick:** Temporarily holds the player against a wall while the grapple remains active.
- **Dead:** Cancels traversal systems and applies limited dead-body physics.

Movement and attack are separate state machines. This allows the player to move or grapple while the attack machine independently handles attack timing, subject to the current death/cancellation rules.

### 4.3 Jumping

The normal ground jump applies an upward velocity of 4.5 m/s. Jump behavior changes according to the active movement state:

- From the floor, `Space` transitions the player to airborne movement.
- During a wall run, `Space` launches the player away from the wall and upward.
- During a wall stick, `Space` launches the player away from the wall, along the wall-run direction, and upward. It also releases the grapple.
- While grappling and grounded, jump input can apply the normal jump velocity without immediately detaching.

### 4.4 Wall running

Wall running is a velocity- and raycast-driven traversal mode rather than a special animation or navigation system.

A wall can be used when:

- The player is airborne.
- The player is moving horizontally at least 1 m/s.
- A side or forward-side ray finds a `StaticBody3D` within 0.8 m.
- The surface normal is sufficiently vertical: `abs(normal.y) <= 0.2`.
- Movement input is aligned with the selected wall-running direction.
- The approach has enough along-wall motion to appear horizontally fluid. A near-perpendicular impact against the wall, with little useful travel along the wall, should not transition into a wall run.

While wall running:

- The player is steered toward a configured target speed along the wall.
- The current scene uses 4 m/s² wall-run acceleration.
- Vertical velocity is reset and wall-run gravity is set to zero in the current player scene.
- Velocity directed away from the wall is removed to keep the player attached.
- Releasing directional alignment, losing the wall, landing, or dropping below the movement conditions ends the wall run.

The wall-run entry limit is a stable-transition threshold rather than a hard maximum for all wall contact. A valid high-speed wall contact may enter a braking phase that preserves useful wall-relative travel while reducing the relevant velocity component until the stable entry threshold is reached. Stable wall running can then continue at the resulting speed. Wall sticking is only available when the player is at a valid wall-running angle and below the wall-stick speed threshold.

Wall-relative velocity is conceptually divided into a component normal to the wall and a component tangent to the wall surface. The normal component is used to evaluate contact, impact, and braking behavior; tangential velocity is preserved as much as possible so that wall running feels like a continuation of horizontal movement rather than a reset.

The wall-run direction is selected from the wall normal and the player’s current horizontal velocity, so the system attempts to preserve the player’s travel direction around the surface. The fluidity check should use the local wall-relative velocity rather than only total speed: a player moving mostly toward the wall should collide with it, while a player carrying meaningful along-wall velocity should be able to transition.

Non-flat walls are evaluated from the current contact normal rather than assuming one infinite flat plane. At each contact, the wall defines a local tangent plane. The player’s velocity can be projected onto that plane to preserve travel along the current surface while the normal component is damped or removed as required. Small changes in surface normal should be smoothed to prevent jitter on faceted or curved geometry. A sharp normal discontinuity may end the run or require a deliberately authored corner transition; it should not silently produce an abrupt direction change.

The exact speed threshold must specify which measure it uses: total velocity, inward normal speed, absolute normal speed, or another wall-relative value. The current prototype checks total velocity for wall-run and wall-stick entry; the intended system should use the selected wall-relative measure consistently.

**Current prototype note:** The current implementation still requires total velocity to be at or below the configured wall-run entry limit before wall running or wall sticking begins. It does not yet contain the intended high-speed braking phase, non-flat surface smoothing, or an explicit along-wall fluidity threshold.

### 4.5 Wall jumping

Wall jumps combine an outward impulse, along-wall momentum, and an upward impulse:

- Away-from-wall velocity: 8 m/s.
- Upward velocity: 5.5 m/s.
- Along-wall velocity: the positive component of current travel during a wall run, or the configured wall-run speed during a wall stick.

This makes the wall system a way to redirect momentum rather than simply reset the player’s position.

### 4.6 Wall sticking

Wall sticking is a grapple-assisted state intended for deliberate tactical pauses, aiming, observation, and setup opportunities. It is not an invulnerability or safety state. Ranged enemies can target a sticking player, and future melee enemies may be able to climb or otherwise reach walls.

It can begin only when:

- The player is currently grappling.
- Right mouse is still held.
- The player is airborne and not already wall-sticking.
- A slide collision hits a valid static wall.
- The relevant wall-relative speed is below the wall-stick threshold.
- Directional input is aligned with the wall-run direction.

When wall sticking begins, the current position is stored, velocity is set to zero, and the player is held at that position each frame. Releasing the grapple detaches the player. Jumping performs a wall-stick jump and clears both the stick and grapple state. The tactical value comes from position and information, not guaranteed safety.

## 5. Grappling System

### 5.1 Target acquisition

The design rule is broader than the current prototype implementation: any surface or target may be grappleable when its grappleable property allows it. Buildings, floors, branches, platforms, enemies, and other moving targets can participate without requiring a special anchor-only target class. The first eligible hit under the crosshair wins; no target priority or aim snapping is planned.

The current prototype still accepts any `StaticBody3D` hit. It will need a reusable grappleable target contract so that eligibility, target response, moving hit points, and invalidation are handled by the target rather than hard-coded in the player controller.
The grapple uses a ray from the active camera forward up to 35 m. The player’s own physics body is excluded from the query. Any `StaticBody3D` hit is currently considered grapple-valid.

This means the grapple can target:

- Buildings and towers.
- The floor.
- Tutorial branches, trunks, platforms, and grapple knots.
- Other static geometry that may be added later.

There is currently no grapple-specific target tag, anchor component, minimum distance, obstruction filtering beyond the raycast, or target priority system. The tutorial visually presents amber knots as intended targets, but the runtime grapple logic accepts all static bodies.

### 5.2 Grappleable target contract

Every grappleable surface or target should provide a small reusable contract. At minimum, the contract should define:

- Whether the target can currently be grappled.
- The response to being grappled, such as pulling the player toward a static point, pulling the player toward a moving enemy, or resisting player movement because the target is heavy.
- The grapple point or hit-point behavior.
- What happens when the target moves, becomes invalid, is destroyed, or changes state.

For moving targets, the hit point should be stored relative to the target or represented by a child grapple point so that the pull follows the target. A dead or invalid target clears the grapple.

### 5.3 Activation and release

Grappling starts on a valid right-mouse press from the grounded, airborne, or wall-running states. The hit position is stored as the grapple point and the hit static body is stored as the grapple target.

The grapple remains active while:

- Right mouse remains held.
- The target instance is still valid.

Releasing the button or losing the target clears the grapple. The player’s current velocity is preserved, so releasing is the primary way to convert pull speed into a launch or continued zip-pull movement.

### 5.4 Grapple physics

The current implementation is an acceleration-based pull, not a physical rope constraint. Grapple acceleration starts high and decreases linearly over time using a configured jerk value until it reaches a minimum floor:

1. Apply gravity using the scene’s grapple gravity scale.
2. Apply normal ground/air movement input.
3. Add acceleration toward the stored grapple point.
4. Clamp total velocity to the grapple maximum speed.
5. Move with `move_and_slide()` and check for wall-stick collisions.

The player traversal tuning should provide shared defaults for all levels. Level-specific overrides remain available for experimentation or deliberately authored challenges, but they should not be required for the player to relearn the basic grapple behavior.

Current prototype tuning values use a shared acceleration profile with context-specific gravity:

| Context | Grapple length | Initial acceleration | Minimum acceleration | Jerk | Gravity scale | Max velocity |
|---|---:|---:|---:|---:|---:|---:|
| Base player scene | 35 m | 48 m/s² | 8 m/s² | 53.33 m/s³ | 1.0 | 22 m/s |
| Default arena | 35 m | 48 m/s² | 8 m/s² | 53.33 m/s³ | 0.0 | 22 m/s |
| Tree tutorial | 35 m | 48 m/s² | 8 m/s² | 53.33 m/s³ | 0.65 | 22 m/s |

The zero-gravity grapple tuning in the default arena makes the system feel more like a direct traversal pull. The tutorial’s 0.65 gravity scale leaves more vertical fall during longer climbs and releases.

The acceleration profile reaches its minimum after approximately 0.75 seconds. The total velocity cap is still applied after gravity, movement input, and grapple pull. Releasing the grapple clears the acceleration timer but preserves the current velocity.

The in-game grapple debug overlay is enabled by default during development and can be toggled with `F3`. It displays grapple time, current acceleration, profile parameters, target distance, pull speed, total velocity, cap status, movement state, and the existing wall-stick speed gate. The overlay does not change wall-stick behavior.

### 5.5 Grapple feedback

The player receives immediate 3D feedback:

- A yellow emissive cursor appears at a valid grapple point.
- The cursor turns green while actively grappling.
- A cyan emissive cylinder is drawn between the player mesh center and the grapple point.
- The rope and cursor disappear when grappling is cleared or the player dies.

The cursor communicates the result of the crosshair ray. It does not select or pull the player’s aim toward another target. The grapple is a direct zip-pull and is not intended to become a physical rope or automatic swing constraint.

## 6. Player Combat System

The player attack is controlled by a separate LimboAI state machine:

1. **Ready:** Accepts attack input.
2. **Windup:** 0.08 s delay before the hit becomes active.
3. **Active:** Hitbox is enabled for 0.18 s and the attack arc plays.
4. **Recovery:** Remaining cooldown time before another attack can start.

The full player attack cycle is tuned to approximately 0.45 s. The attack uses a forward box hitbox and an animated 135-degree arc visual. Its current attack resource is a physical “Basic Strike” with 16 base damage, attack-power scaling, poise damage, and a small critical-hit bonus.

The initial attack system may allow melee and ranged attacks in every movement state, including grounded, airborne, grappling, wall-running, and wall-sticking states. This is a configurable capability rather than a permanent rule. Future attack abilities should be able to restrict movement states, preserve or modify velocity, release the grapple, choose a targeting mode, and use either hitboxes or projectiles.

Movement should eventually provide an attack context containing the player’s movement state, approach direction, height, and relevant speed. Attacks may use that context to affect damage, poise, stagger, knockback, reach, or access to an exposed weakness. The first combat slice should validate this movement-to-attack relationship before adding a large attack roster.

## 7. Combat Resolution and Health

Combatants use separate health, stats, hurtbox, and hitbox components.

### Resolution flow

Damage is resolved in this general order:

1. Read the attack’s damage map and tags.
2. Add attacker attack power according to the attack’s scaling.
3. Roll critical-hit chance and apply critical multiplier if successful.
4. Apply outgoing and incoming damage multipliers.
5. Run optional `CombatModifier` hooks.
6. Apply physical defense and armor penetration.
7. Apply per-type resistances.
8. Produce a final damage total and damage metadata.
9. Apply the result to the target’s health.

Hitboxes prevent friendly fire by comparing team names and prevent the same hurtbox from being hit repeatedly during a single activation. The current active attack resources are physical damage only, although the framework supports fire, ice, lightning, poison, arcane, true damage, tags, poise, and modifiers.

The combat-resolution design still needs to be fleshed out. In particular, the eventual resolution context should be able to carry movement-derived information from the attack, while keeping basic physical damage understandable in the first playable slice. Active poise, stagger, knockback, weak points, status effects, and damage modifiers should be introduced only when they reinforce readable movement and encounter decisions.

The player has 100 default health. Enemies currently have 60 health. When an enemy dies, it is removed from the scene. When the player dies, traversal and attacks are cancelled and a dead physics state remains active; there is no respawn or restart flow yet.

## 8. Enemy System

Enemies are reusable `CharacterBody3D` scenes configured by `EnemyDefinition` resources. The definition controls identity, vision, movement, attack timing, range, and projectile settings.

### 8.1 Vision and targeting

Each enemy has an `EnemyVision3D` area and a line-of-sight check. It supports:

- Configurable vision range.
- Configurable horizontal field of view.
- Optional line-of-sight requirement.
- Target acquisition from the `player` group.
- Closest visible target selection.
- Last-seen position tracking.
- Delayed target loss after the configured grace period.

### 8.2 Behavior tree

The current behavior tree has two main branches:

- **Melee behavior:** Face the player, attack within range, otherwise move toward the player.
- **Ranged behavior:** Face the player, retreat when too close, approach when too far away, and attack only when in range with line of sight.

Enemy locomotion is direct horizontal velocity steering with acceleration and deceleration. There is no navigation mesh, pathfinding, obstacle avoidance, or coordinated group behavior in the current build.

The movement-focused enemy roster requires a separate design document. Each enemy definition should specify the movement problem it creates, its pressure tools, telegraphs, player responses, punishments, counterplay, variants, and intended level usage. Future enemies may include abilities that reach wall-sticking players or climb walls, so wall sticking remains tactical rather than automatically safe.

### 8.3 Enemy attack state machine

Enemy attacks use a separate state machine with ready, windup, active, recovery, and dead states. Attack speed is used to ensure the configured recovery time does not allow attacks to exceed the intended rate.

The current main arena contains:

- **Melee enemy:** Chases the player and uses a forward claw hitbox.
- **Arc ranged enemy:** Fires a projectile with an arcing path.
- **Direct ranged enemy:** Maintains a longer distance and fires a direct projectile.

The current enemies are prototype implementations rather than the final encounter roster. Enemy behavior should be expanded through authored movement problems before adding large numbers of enemy types.

## 9. Projectile System

Projectiles are reusable `Area3D` scenes configured at runtime by the enemy that fires them. A projectile stores its source, owner team, attack data, speed, lifetime, path type, and target position.

Supported paths:

- **Direct:** Travels in a straight line from the spawn point.
- **Arc:** Interpolates toward the target while adding a sine-wave vertical arc.

Projectiles damage the first valid opposing hurtbox they enter and then are removed. They are also removed when their lifetime expires or an arc reaches its target position.

The intended ranged-threat system should also define whether projectiles collide with world geometry, how cover interacts with them, how much reaction time they provide, and how their trajectory or impact is telegraphed. These rules should be consistent with the movement question created by the enemy that fires them.

## 10. World and Level Systems

### 10.1 Default arena

`main.tscn` is the default launch scene. It contains:

- A large static floor.
- Nine configurable static building blocks and towers.
- One player.
- One melee enemy.
- One arcing ranged enemy.
- One direct ranged enemy.
- Directional lighting, procedural sky, and world environment.

Buildings use a reusable scene with an exported size. The mesh and collision shape are refreshed together, allowing rapid blockout of traversal spaces.

The default arena is currently a traversal and combat sandbox, not a complete level. A complete instanced level should define entry, authored route and encounter progression, required encounters, drops, a boss encounter, boss-death completion, and a reward or exit state. Buildings should be arranged to create multiple meaningful routes rather than merely providing grappleable geometry.

### 10.2 Tree grapple tutorial

`scenes/tree_grapple_tutorial.tscn` is a separate procedural level. At runtime/editor load it generates:

- A large forest floor.
- A tall central tree trunk and canopy.
- Root ramps, branches, landing pads, and glowing grapple knots.
- Seven instructional stages covering pulling, releasing, steering, catching, wall sticking, long gaps, and chaining grapples.
- 3D instructional signs.
- A summit platform and visual goal ring.

The tutorial uses the same player scene but applies different grapple tuning. It is not currently wired into the default launch flow or a completion trigger.

Tutorial stages should be expanded into authored teaching units. Each stage should define the mechanic being taught, the required player action, the success condition, the failure or recovery behavior, the next skill it prepares, and whether enemy pressure is introduced. The summit trigger is a tutorial completion condition even though it is not a boss encounter.

## 11. Presentation and Feedback

Current feedback is intentionally lightweight and mostly 3D:

- Emissive grapple cursor, rope, anchors, and projectiles.
- Animated player and enemy attack arcs.
- Tutorial signs using `Label3D`.
- Simple colored materials for player, enemies, buildings, floor, branches, and goals.
- Debug damage/death information printed to the output.

There is currently no HUD, health bar, crosshair UI, audio, music, particle system, animation controller, hit-stop, camera shake, or damage-number presentation.

The prototype can continue using simple meshes and basic animations. Feedback requirements are gameplay requirements rather than an art-quality requirement: players must be able to identify grapple validity, enemy danger, attack timing, damage, and level state even when the presentation uses primitive geometry and simple effects.

## 12. Data and Architecture

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

### 12.1 Planned cross-system contracts

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

## 13. Current Prototype Boundaries and Future System Hooks

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
