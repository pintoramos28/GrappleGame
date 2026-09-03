# GrappleGame — Gameplay Systems
**Purpose:** Generic player, combat, enemy and traversal rules that can be reused across worlds.

**Design relationship:** World-specific fiction changes how these systems are expressed, but does not redefine their generic contracts.

## Table of Contents

- [1. Player Movement System](#1-player-movement-system)
  - [1.1 Movement model](#11-movement-model)
  - [1.2 Movement state machine](#12-movement-state-machine)
  - [1.3 Jumping](#13-jumping)
  - [1.4 Wall running](#14-wall-running)
  - [1.5 Wall jumping](#15-wall-jumping)
  - [1.6 Wall sticking](#16-wall-sticking)
- [2. Grappling System](#2-grappling-system)
  - [2.1 Target acquisition](#21-target-acquisition)
  - [2.2 Grappleable target contract](#22-grappleable-target-contract)
  - [2.3 Activation and release](#23-activation-and-release)
  - [2.4 Grapple physics](#24-grapple-physics)
  - [2.5 Grapple feedback](#25-grapple-feedback)
- [3. Player Combat System](#3-player-combat-system)
- [4. Combat Resolution and Health](#4-combat-resolution-and-health)
  - [Resolution flow](#resolution-flow)
- [5. Enemy System](#5-enemy-system)
  - [5.1 Vision and targeting](#51-vision-and-targeting)
  - [5.2 Behavior tree](#52-behavior-tree)
  - [5.3 Enemy attack state machine](#53-enemy-attack-state-machine)
- [6. Projectile System](#6-projectile-system)
- [7. Universal Grapple Ecology](#7-universal-grapple-ecology)
  - [Default grapple behavior](#default-grapple-behavior)
  - [Explicit exceptions](#explicit-exceptions)
  - [Anchor ecology](#anchor-ecology)
- [8. Combat Role Framework](#8-combat-role-framework)
- [9. Reusable Enemy Ability Mechanics](#9-reusable-enemy-ability-mechanics)
  - [9.1 Adhesive surfaces](#91-adhesive-surfaces)
  - [9.2 Temporary obstacle growth](#92-temporary-obstacle-growth)
  - [9.3 Harpoon or tether](#93-harpoon-or-tether)
  - [9.4 Knockback and displacement](#94-knockback-and-displacement)
  - [9.5 Predictive mark](#95-predictive-mark)
  - [9.6 Direct lane shot](#96-direct-lane-shot)
  - [9.7 Arcing bombardment](#97-arcing-bombardment)
  - [9.8 Rotating plane or line sweep](#98-rotating-plane-or-line-sweep)
  - [9.9 Visibility obstruction](#99-visibility-obstruction)
  - [9.10 Damage gas or drifting hazard](#910-damage-gas-or-drifting-hazard)
  - [9.11 Airburst and aerial mine lattice](#911-airburst-and-aerial-mine-lattice)
  - [9.12 Anti-wall reach](#912-anti-wall-reach)
  - [9.13 Anchor modification](#913-anchor-modification)
  - [9.14 Support tether](#914-support-tether)
  - [9.15 Decoy or echo](#915-decoy-or-echo)
  - [9.16 Wind, suction and directional vectors](#916-wind-suction-and-directional-vectors)
  - [9.17 Surface state changes](#917-surface-state-changes)
- [10. Cross-Document Integration](#10-cross-document-integration)

## 1. Player Movement System

### 1.1 Movement model

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

### 1.2 Movement state machine

Movement is controlled by a LimboAI hierarchical state machine with these states:

- **Grounded:** Normal movement, jump input, and grapple initiation.
- **Airborne:** Gravity, air control, wall-run detection, and grapple initiation.
- **Grappling:** Pull physics, air control, grapple release, and wall-stick detection.
- **WallRun:** Movement along a runnable wall, reduced gravity, and wall jumping.
- **WallStick:** Temporarily holds the player against a wall while the grapple remains active.
- **Dead:** Cancels traversal systems and applies limited dead-body physics.

Movement and attack are separate state machines. This allows the player to move or grapple while the attack machine independently handles attack timing, subject to the current death/cancellation rules.

### 1.3 Jumping

The normal ground jump applies an upward velocity of 4.5 m/s. Jump behavior changes according to the active movement state:

- From the floor, `Space` transitions the player to airborne movement.
- During a wall run, `Space` launches the player away from the wall and upward.
- During a wall stick, `Space` launches the player away from the wall, along the wall-run direction, and upward. It also releases the grapple.
- While grappling and grounded, jump input can apply the normal jump velocity without immediately detaching.

### 1.4 Wall running

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

### 1.5 Wall jumping

Wall jumps combine an outward impulse, along-wall momentum, and an upward impulse:

- Away-from-wall velocity: 8 m/s.
- Upward velocity: 5.5 m/s.
- Along-wall velocity: the positive component of current travel during a wall run, or the configured wall-run speed during a wall stick.

This makes the wall system a way to redirect momentum rather than simply reset the player’s position.

### 1.6 Wall sticking

Wall sticking is a grapple-assisted state intended for deliberate tactical pauses, aiming, observation, and setup opportunities. It is not an invulnerability or safety state. Ranged enemies can target a sticking player, and future melee enemies may be able to climb or otherwise reach walls.

It can begin only when:

- The player is currently grappling.
- Right mouse is still held.
- The player is airborne and not already wall-sticking.
- A slide collision hits a valid static wall.
- The relevant wall-relative speed is below the wall-stick threshold.
- Directional input is aligned with the wall-run direction.

When wall sticking begins, the current position is stored, velocity is set to zero, and the player is held at that position each frame. Releasing the grapple detaches the player. Jumping performs a wall-stick jump and clears both the stick and grapple state. The tactical value comes from position and information, not guaranteed safety.

## 2. Grappling System

### 2.1 Target acquisition

The design rule is broader than the current prototype implementation: any surface or target may be grappleable when its grappleable property allows it. Buildings, floors, branches, platforms, enemies, and other moving targets can participate without requiring a special anchor-only target class. The first eligible hit under the crosshair wins; no target priority or aim snapping is planned.

The current prototype still accepts any `StaticBody3D` hit. It will need a reusable grappleable target contract so that eligibility, target response, moving hit points, and invalidation are handled by the target rather than hard-coded in the player controller.
The grapple uses a ray from the active camera forward up to 35 m. The player’s own physics body is excluded from the query. Any `StaticBody3D` hit is currently considered grapple-valid.

This means the grapple can target:

- Buildings and towers.
- The floor.
- Tutorial branches, trunks, platforms, and grapple knots.
- Other static geometry that may be added later.

There is currently no grapple-specific target tag, anchor component, minimum distance, obstruction filtering beyond the raycast, or target priority system. The tutorial visually presents amber knots as intended targets, but the runtime grapple logic accepts all static bodies.

### 2.2 Grappleable target contract

Every grappleable surface or target should provide a small reusable contract. At minimum, the contract should define:

- Whether the target can currently be grappled.
- The response to being grappled, such as pulling the player toward a static point, pulling the player toward a moving enemy, or resisting player movement because the target is heavy.
- The grapple point or hit-point behavior.
- What happens when the target moves, becomes invalid, is destroyed, or changes state.

For moving targets, the hit point should be stored relative to the target or represented by a child grapple point so that the pull follows the target. A dead or invalid target clears the grapple.

### 2.3 Activation and release

Grappling starts on a valid right-mouse press from the grounded, airborne, or wall-running states. The hit position is stored as the grapple point and the hit static body is stored as the grapple target.

The grapple remains active while:

- Right mouse remains held.
- The target instance is still valid.

Releasing the button or losing the target clears the grapple. The player’s current velocity is preserved, so releasing is the primary way to convert pull speed into a launch or continued zip-pull movement.

### 2.4 Grapple physics

The current implementation is an acceleration-based pull and does not yet enforce an active connection boundary. The target architecture retains the direct zip-pull and adds only a maximum-range constraint using the same authored 35 m value as target acquisition. It does not create a fixed rope at the initial attachment distance or an automatic general-purpose swing system. Grapple acceleration starts high and decreases linearly over time using a configured jerk value until it reaches a minimum floor:

1. Apply gravity using the scene’s grapple gravity scale.
2. Apply normal ground/air movement input.
3. Add acceleration toward the stored grapple point.
4. Clamp total velocity to the grapple maximum speed.
5. Move with `move_and_slide()` and check for wall-stick collisions.

The player traversal tuning should provide shared immutable defaults for all levels. A deliberately authored challenge may reference an alternate tuning Resource, but levels do not duplicate scalar overrides and should not require the player to relearn the basic grapple behavior.

Current prototype tuning values use a shared acceleration profile with context-specific gravity:

| Context | Grapple length | Initial acceleration | Minimum acceleration | Jerk | Gravity scale | Max velocity |
|---|---:|---:|---:|---:|---:|---:|
| Base player scene | 35 m | 48 m/s² | 8 m/s² | 53.33 m/s³ | 1.0 | 22 m/s |
| Default arena | 35 m | 48 m/s² | 8 m/s² | 53.33 m/s³ | 0.0 | 22 m/s |
| Tree tutorial | 35 m | 48 m/s² | 8 m/s² | 53.33 m/s³ | 0.65 | 22 m/s |

The zero-gravity grapple tuning in the default arena makes the system feel more like a direct traversal pull. The tutorial’s 0.65 gravity scale leaves more vertical fall during longer climbs and releases.

The acceleration profile reaches its minimum after approximately 0.75 seconds. The total velocity cap is still applied after gravity, movement input, and grapple pull. Releasing the grapple clears the acceleration timer but preserves the current velocity.

The in-game grapple debug overlay is enabled by default during development and can be toggled with `F3`. It displays grapple time, current acceleration, profile parameters, target distance, pull speed, total velocity, cap status, movement state, and the existing wall-stick speed gate. The overlay does not change wall-stick behavior.

### 2.5 Grapple feedback

The player receives immediate 3D feedback:

- A yellow emissive cursor appears at a valid grapple point.
- The cursor turns green while actively grappling.
- A cyan emissive cylinder is drawn between the player mesh center and the grapple point.
- The rope and cursor disappear when grappling is cleared or the player dies.

The cursor communicates the result of the crosshair ray. It does not select or pull the player’s aim toward another target. The grapple remains an acceleration-based direct zip-pull. It does not create a fixed rope at the initial attachment distance or an automatic general-purpose swing system; while active, it enforces only the authored maximum grapple length as its connection boundary.

## 3. Player Combat System

The player attack is controlled by a separate LimboAI state machine:

1. **Ready:** Accepts attack input.
2. **Windup:** 0.08 s delay before the hit becomes active.
3. **Active:** Hitbox is enabled for 0.18 s and the attack arc plays.
4. **Recovery:** Remaining cooldown time before another attack can start.

The full player attack cycle is tuned to approximately 0.45 s. The attack uses a forward box hitbox and an animated 135-degree arc visual. Its current attack resource is a physical “Basic Strike” with 16 base damage, attack-power scaling, poise damage, and a small critical-hit bonus.

The initial attack system may allow melee and ranged attacks in every movement state, including grounded, airborne, grappling, wall-running, and wall-sticking states. This is a configurable capability rather than a permanent rule. Future attack abilities should be able to restrict movement states, preserve or modify velocity, release the grapple, choose a targeting mode, and use either hitboxes or projectiles.

Movement should eventually provide an attack context containing the player’s movement state, approach direction, height, and relevant speed. Attacks may use that context to affect damage, poise, stagger, knockback, reach, or access to an exposed weakness. The first combat slice should validate this movement-to-attack relationship before adding a large attack roster.

## 4. Combat Resolution and Health

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

## 5. Enemy System

Enemies are reusable `CharacterBody3D` scenes configured by `EnemyDefinition` resources. The definition controls identity, vision, movement, attack timing, range, and projectile settings.

### 5.1 Vision and targeting

Each enemy has an `EnemyVision3D` area and a line-of-sight check. It supports:

- Configurable vision range.
- Configurable horizontal field of view.
- Optional line-of-sight requirement.
- Target acquisition from the `player` group.
- Closest visible target selection.
- Last-seen position tracking.
- Delayed target loss after the configured grace period.

### 5.2 Behavior tree

The current behavior tree has two main branches:

- **Melee behavior:** Face the player, attack within range, otherwise move toward the player.
- **Ranged behavior:** Face the player, retreat when too close, approach when too far away, and attack only when in range with line of sight.

Enemy locomotion is direct horizontal velocity steering with acceleration and deceleration. There is no navigation mesh, pathfinding, obstacle avoidance, or coordinated group behavior in the current build.

The movement-focused enemy roster requires a separate design document. Each enemy definition should specify the movement problem it creates, its pressure tools, telegraphs, player responses, punishments, counterplay, variants, and intended level usage. Future enemies may include abilities that reach wall-sticking players or climb walls, so wall sticking remains tactical rather than automatically safe.

### 5.3 Enemy attack state machine

Enemy attacks use a separate state machine with ready, windup, active, recovery, and dead states. Attack speed is used to ensure the configured recovery time does not allow attacks to exceed the intended rate.

The current main arena contains:

- **Melee enemy:** Chases the player and uses a forward claw hitbox.
- **Arc ranged enemy:** Fires a projectile with an arcing path.
- **Direct ranged enemy:** Maintains a longer distance and fires a direct projectile.

The current enemies are prototype implementations rather than the final encounter roster. Enemy behavior should be expanded through authored movement problems before adding large numbers of enemy types.

## 6. Projectile System

Projectiles are reusable `Area3D` scenes configured at runtime by the enemy that fires them. A projectile stores its source, owner team, attack data, speed, lifetime, path type, and target position.

Supported paths:

- **Direct:** Travels in a straight line from the spawn point.
- **Arc:** Interpolates toward the target while adding a sine-wave vertical arc.

Projectiles damage the first valid opposing hurtbox they enter and then are removed. They are also removed when their lifetime expires or an arc reaches its target position.

The intended ranged-threat system should also define whether projectiles collide with world geometry, how cover interacts with them, how much reaction time they provide, and how their trajectory or impact is telegraphed. These rules should be consistent with the movement question created by the enemy that fires them.

## 7. Universal Grapple Ecology

Almost all surfaces and targets are grapple-able by default.

The player should not normally search for a small set of approved anchor points. Buildings, floors, walls, branches, fungal growths, ice, machinery, debris, platforms, enemy bodies and moving targets can all be grapple-able when their target contract permits it.

The important distinction is:

> **A surface can remain grapple-able while being dangerous, obstructed, slow, moving or contested.**

An enemy or world feature should usually change the value or behavior of a grapple target rather than remove access to it entirely.

### Default grapple behavior

* Ordinary world geometry is grapple-able unless explicitly marked otherwise.
* Enemy-created roots, crystals, walls, webs, pillars and barricades are grapple-able by default.
* Moving enemies can be grapple-able when their `Grappleable` contract supports a moving hit point and target invalidation.
* A grapple-able target may be heavy, elastic, unstable, adhesive, hazardous or resistant without becoming invalid.
* Glowing knots, relay nodes and other visual markers should communicate especially useful routes, not basic eligibility.
* Floors and other broad surfaces may remain grapple-able, but hazards should make the player consider whether pulling toward them is worthwhile.

### Explicit exceptions

Truly invalid surfaces should be rare, intentional and readable. Possible exceptions include:

* a portal surface that has collapsed;
* a temporary Severance device that suppresses resonance;
* a world substance that actively rejects the harness;
* a destructible surface that cannot support the player;
* a story-specific transition where the target is disappearing.

An invalid target should visibly change state, produce a clear audio cue and update the grapple cursor. It should not silently fail.

### Anchor ecology

Each level should contain an ecology of grapple targets rather than a collection of isolated anchor points:

* **Permanent structural targets:** walls, trunks, cliffs, towers and large ruins that remain available throughout the encounter.
* **Modified targets:** surfaces that enemies make sticky, burning, electrified, unstable or difficult to approach.
* **Temporary targets:** obstacles or growths created during combat that can also become useful routes.
* **Moving targets:** enemies, creatures, platforms or vehicles that provide advanced, optional routes.
* **Recovery targets:** nearby surfaces that allow the player to recover from a missed jump, knockback or poor release.

Every major combat space should preserve a low route, a high route and a lateral route. An enemy may make one route dangerous or inefficient, but the fight should not normally remove the entire movement vocabulary.

## 8. Combat Role Framework

The existing game design defines melee mobs, ranged mobs, elite enemies and bosses. The following sub-roles make those categories more useful during encounter design.

| Role | Movement question | Typical tools |
|---|---|---|
| Melee pursuer | Can I keep changing position instead of fighting passively on the ground? | Pounces, charges, sweeps, grabs and short-range cones |
| Bruiser | Can I preserve momentum while avoiding a high-impact attack? | Armor, knockback, large melee attacks and destructible cover |
| Direct ranged | Where can I cross the enemy's line of sight safely? | Bolts, beams, spears and rail shots |
| Artillery / lobber | Where will I be when the delayed attack lands? | Arcing shots, ground circles and falling debris |
| Space controller | Which route is still available? | Sticky surfaces, gas, temporary walls and surface states |
| Disruptor | Can I recover when my velocity or position changes? | Tethers, pulls, knockback and anchor modification |
| Anti-wall / aerial | Is my wall or high position actually safe? | Wall climbing, dive attacks, air mines and vertical beams |
| Support / network | Which enemy must I interrupt before attacking the damage dealer? | Healing links, shields, buffs and target marks |
| Scout / marker | Can I break the enemy's planned attack before it begins? | Tracking, alarms and predicted-position marks |
| Elite hybrid | Can I answer two kinds of pressure without losing flow? | Combined melee, ranged, control and defensive tools |
| Boss | Can I learn the arena's pattern and create a high-value opening? | Phase changes, route changes, weak points and large AOE |

Intelligent species should not be enemies by default. An uncorrupted species can be neutral or friendly, while a factional combatant, territorial guardian, corrupted individual or defensive construct can use the same species silhouette as an enemy. This distinction is important to the setting's argument that hostile behavior is not proof that an entire species is evil.

## 9. Reusable Enemy Ability Mechanics

The following mechanics can be reused across worlds with different visual, biological and cultural explanations.

### 9.1 Adhesive surfaces

Resin, webs, frost, sap, fungal mucus or mineral sludge can reduce acceleration and air control, prevent wall-running or make landings slide.

The surface remains grapple-able by default. Its danger comes from how it changes the player's movement after contact. The player can grapple to it as an emergency choice, escape to a clean surface or attack the creature producing it.

### 9.2 Temporary obstacle growth

Roots, crystal ridges, ice walls, obsidian columns and fungal barricades rise from visibly marked locations.

The obstacle should usually be destructible, avoidable, climbable or grapple-able once it forms. Its purpose is to block a line of sight, split one route into two, force a different attack angle or create a new vertical surface.

### 9.3 Harpoon or tether

A projectile or melee attack attaches a line to the player. It can slow horizontal movement, pull the player toward the enemy, disturb a release or force the player to move around an obstacle to break line of sight.

The player should be able to escape by grappling behind cover, attacking the tether head, breaking the line or using a wall jump. A tether should not automatically cancel an active grapple without warning.

### 9.4 Knockback and displacement

Large melee attacks, shockwaves, charges and explosions alter the player's velocity.

Displacement should create a new movement problem rather than a stun-lock sequence. Nearby recovery surfaces and preserved player control make the resulting scramble part of the game's skill expression.

### 9.5 Predictive mark

An enemy marks the player's current position, intended landing position or likely grapple release point. After a delay, the marked location receives an attack.

This punishes predictable movement without punishing movement itself. Changing direction, releasing early, crossing to another surface or using a different altitude should defeat the prediction.

### 9.6 Direct lane shot

A bolt, beam, spear or rail shot travels in a straight line. The attack requires line of sight and has a visible aiming line, charging sound or emissive weapon state.

The player can cross the lane, use cover, grapple around the enemy or attack during the firing recovery.

### 9.7 Arcing bombardment

An enemy fires over cover or toward a future position. The projectile creates a ground or surface AOE when it lands.

Arcing attacks prevent the player from treating the nearest wall as a complete solution. The player must continue moving, change altitude or leave the predicted landing area.

### 9.8 Rotating plane or line sweep

A beam, wind blade, fungal wave or electrical plane sweeps through part of the arena.

The player can move with the sweep, cross behind it, grapple around it or use a wall-stick pause to wait for an opening. This is especially effective for bosses because the danger remains spatially understandable in a large arena.

### 9.9 Visibility obstruction

Smoke, spores, snow, dust, ash or mist reduces long-range visibility.

This should not become a full-screen blind effect. Silhouettes, attack flashes, sound direction, nearby geometry and grapple feedback should remain readable. The purpose is to make route reading harder, not to hide the answer from the player.

### 9.10 Damage gas or drifting hazard

A gas cloud, spore field, volcanic vapor or corrosive mist deals damage over time and drifts according to wind or enemy movement.

The cloud should have a readable boundary and a ramp-up period. The player can cross briefly to preserve momentum, grapple over it or eliminate the source before proceeding.

### 9.11 Airburst and aerial mine lattice

Floating spores, lightning seeds, crystal mines, expanding airburst rings and rotating projectile clusters place danger above the floor.

This prevents grappling upward from becoming a universal answer. The player must choose another altitude, move sideways or use a wall as cover.

### 9.12 Anti-wall reach

Some enemies can challenge a wall-sticking player by climbing, leaping to the wall, throwing a short-range harpoon, firing a vertical attack or changing the wall's movement response.

Anti-wall attacks should be highly readable and committed. If every enemy can instantly reach any wall, wall interaction stops being useful.

### 9.13 Anchor modification

An enemy can change the response of one or more grapple targets without necessarily making them invalid. A surface may pull toward a dangerous point, create sideways drag, conduct electricity or become unstable after prolonged contact.

Full anchor blackout should be rare and reserved for explicit technology or ecology, such as a Severance device or a portal guardian. It should affect a small local area, be telegraphed and leave other routes available.

### 9.14 Support tether

A support enemy links itself to another enemy, providing healing, armor, faster recovery, stagger resistance or shared damage reduction.

The player can break the link by moving behind cover, attacking the support enemy, destroying an intermediate relay or forcing the linked enemy away.

### 9.15 Decoy or echo

The enemy creates false bodies, false grapple targets, delayed afterimages or copies of the player's previous position.

The deception should have a consistent tell: a different color, sound, shadow, outline or movement response. The mechanic should reward observation rather than make targeting arbitrary.

### 9.16 Wind, suction and directional vectors

An enemy changes the direction of the player's velocity instead of simply slowing it. A storm creature may create crosswinds, a giant may inhale toward a cavern and a fungal bloom may push the player away from its core.

The player can counter with a lateral grapple, wall-run, angled jump or early release that preserves the desired vector.

### 9.17 Surface state changes

A surface can temporarily become burning, freezing, electrified, brittle, slippery or resonant.

The player should be able to recognize the state and choose whether to cross quickly, grapple over it, use it briefly for momentum or wait for it to expire. Surface states should change the value of a route without permanently removing the route.

## 10. Cross-Document Integration

The generic mechanics in this document are intentionally independent of the setting. World-specific surfaces, enemy names, hazards and bosses belong in [WORLD_ATLAS.md](WORLD_ATLAS.md). Portal causes, fungal biology and corruption canon belong in [PORTAL_AND_FUNGAL_ECOLOGY.md](PORTAL_AND_FUNGAL_ECOLOGY.md). Encounter assembly belongs in [LEVEL_AND_ENCOUNTER_DESIGN.md](LEVEL_AND_ENCOUNTER_DESIGN.md).
