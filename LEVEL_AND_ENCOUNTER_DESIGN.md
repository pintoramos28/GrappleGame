# GrappleGame — Level and Encounter Design
**Purpose:** Rules for assembling traversal systems, enemies, objectives and rewards into playable levels.

## Table of Contents

- [1. World and Level Systems](#1-world-and-level-systems)
  - [1.1 Default arena](#11-default-arena)
  - [1.2 Tree grapple tutorial](#12-tree-grapple-tutorial)
- [2. Encounter Progression and Implementation Notes](#2-encounter-progression-and-implementation-notes)
- [3. Route and Encounter Authoring Principles](#3-route-and-encounter-authoring-principles)
  - [Encounter composition](#encounter-composition)
  - [Boss and objective relationship](#boss-and-objective-relationship)
- [4. Tutorial and Mission Authoring](#4-tutorial-and-mission-authoring)
- [5. World-Specific Encounter References](#5-world-specific-encounter-references)

## 1. World and Level Systems

### 1.1 Default arena

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

### 1.2 Tree grapple tutorial

`scenes/tree_grapple_tutorial.tscn` is a separate procedural level. At runtime/editor load it generates:

- A large forest floor.
- A tall central tree trunk and canopy.
- Root ramps, branches, landing pads, and glowing grapple knots.
- Seven instructional stages covering pulling, releasing, steering, catching, wall sticking, long gaps, and chaining grapples.
- 3D instructional signs.
- A summit platform and visual goal ring.

The tutorial uses the same player scene but applies different grapple tuning. It is not currently wired into the default launch flow or a completion trigger.

Tutorial stages should be expanded into authored teaching units. Each stage should define the mechanic being taught, the required player action, the success condition, the failure or recovery behavior, the next skill it prepares, and whether enemy pressure is introduced. The summit trigger is a tutorial completion condition even though it is not a boss encounter.

## 2. Encounter Progression and Implementation Notes

Each world should introduce one primary movement pressure and then remix it with mechanics learned earlier.

A basic world progression can be:

1. A melee enemy teaches the world’s primary movement pressure.
2. A ranged enemy forces the player to read cover and altitude.
3. A controller changes the route without removing the grapple system.
4. A support enemy introduces target priority.
5. An elite combines two previously learned pressures.
6. The boss combines the world’s central mechanic with one earlier world mechanic.

The first gameplay slice should use The Last Garden with Rootstalker, Spore Kite, Mycelial Weaver and Garden Heart. This tests melee pursuit, direct and arcing ranged pressure, visibility reduction, sticky movement, temporary obstacle growth, support tethers, grapple-compatible arena reshaping and a boss with both ground and air AOE.

The initial enemy data should remain compatible with the planned architecture. An `EnemyDefinition` should eventually identify:

* role tags;
* preferred distance and altitude;
* allowed movement surfaces;
* attack abilities;
* telegraph duration and active window;
* hit shape or projectile path;
* status and movement effects;
* grapple interaction;
* weak-point or recovery conditions;
* corruption modifiers;
* intended encounter and world usage.

An `AttackAbility` should describe the behavior of the attack separately from its damage values. The ability may specify whether it is melee, close-range, direct ranged, arcing ranged, ground AOE or air AOE; how it affects player velocity; how it modifies surfaces; and how it responds to grappling.

The most important implementation rule is that enemy abilities should usually alter the player's decisions while preserving the movement system. The world is allowed to become dangerous, but it should remain interactive.

## 3. Route and Encounter Authoring Principles

Every major combat space should preserve a low route, a high route and a lateral route. A fourth recovery route is valuable when a missed jump, knockback or poor release would otherwise create an unrecoverable failure.

Enemies should make routes unsafe, inefficient or strategically valuable without normally deleting the entire movement vocabulary. Encounter design should ask what movement problem the player is solving, what information the enemy provides and what recovery options remain after a mistake.

### Encounter composition

A typical encounter can introduce one primary movement pressure, add a ranged or spatial pressure, reshape one route with a controller, introduce target priority through a support enemy, and then combine two previously learned pressures in an elite or boss.

### Boss and objective relationship

Boss death is the default level-completion condition. The tutorial is an explicit exception: its summit goal completes the level without a boss. Other objectives should be expressed through a reusable objective contract rather than hard-coded into individual enemy controllers.

## 4. Tutorial and Mission Authoring

A tutorial stage should define the mechanic being taught, the required player action, the success condition, the failure or recovery behavior, the next skill it prepares and whether enemy pressure is introduced.

A mission should normally combine:

1. a practical objective such as rescue, recovery, stabilization or containment; and
2. a local relationship or research objective involving the people and fungal life of that world.

The detailed narrative meaning of these objectives belongs in [STORY_AND_CHARACTER_ARCS.md](STORY_AND_CHARACTER_ARCS.md); their routes, encounters, rewards and completion conditions belong here.

## 5. World-Specific Encounter References

Named enemy rosters and boss designs are maintained in [WORLD_ATLAS.md](WORLD_ATLAS.md). This document owns the reusable level and encounter rules they use.
