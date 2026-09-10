---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 4
---

# Story 3.4: Prototype a Telegraph-Aligned Direct Lane Shot

As a player,
I want a straight-line attack whose warning and damaging path agree,
So that I can deliberately cross its lane or use cover instead of guessing where I am in danger.

**Acceptance Criteria:**

1. **Declare the direct-lane gameplay question**

   **Given** the lane-shot prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player crosses the committed lane, reaches cover, or remains exposed before delivery
   **And** its primary counters, recovery option, grapple and wall interactions, source-death policy, reset behavior, overlap restrictions, provisional tuning questions, manual procedure, and required evidence are explicit
   **And** the scenario manifest references authoritative gameplay definitions instead of duplicating their values.

2. **Compose the attack from immutable definitions**

   **Given** the direct lane shot is authored
   **When** its composition is inspected
   **Then** one `AttackDefinition` references the simulation lifecycle, lane-shaped `AbilitySpatialDefinition`, swept `ProjectileDefinition`, `DamageDefinition`, `TelegraphCueDefinition`, targeting policy, source-death policy, hit policy, and named query profiles
   **And** timing, width, length, projectile speed, damage, cooldown, collision eligibility, and presentation values each have one authoritative owner
   **And** occurrence-specific windup, spatial binding, projectile, hit, and terminal state remains outside shared Resources
   **And** provisional numerical values are recorded for playtesting rather than represented as final balance.

3. **Use one concrete delivery mode**

   **Given** the architecture permits projectile, ray, or shape delivery for a lane shot
   **When** this representative prototype is implemented
   **Then** it uses one simulation-driven swept projectile travelling along the committed lane
   **And** ray and instantaneous full-lane delivery remain outside this story
   **And** the selected implementation demonstrates the Spatial Threat Delivery family without creating a universal projectile or ability base class.

4. **Preserve the existing projectile seam during migration**

   **Given** the repository already contains a reusable projectile scene seam
   **When** it is reused or migrated for typed delivery
   **Then** existing Godot UIDs and valid scene or Resource references are preserved where applicable
   **And** the projectile is configured through a typed spawn context before it enters active gameplay
   **And** legacy scene-local timing, damage, targeting, speed, and collision values are removed or adapted so they cannot compete with the authoritative definitions
   **And** the project remains runnable throughout the staged change.

5. **Request the shot through an action owner**

   **Given** the primitive pressure source has a valid player target and the scenario requests a lane shot
   **When** the request reaches its action owner
   **Then** the owner validates definition, target, range, line of sight, action state, cooldown, scope, and run identity before committing one `AbilityExecution`
   **And** an enemy behavior policy or fixture trigger may submit intent but cannot activate the telegraph, spawn the projectile, apply damage, or advance lifecycle timing
   **And** rejected, duplicate, stale, and busy requests return typed reasons without partially starting the attack.

6. **Track only until the authored lock boundary**

   **Given** the lane shot is in windup and its definition permits pre-lock tracking
   **When** the target or source moves before the lock boundary
   **Then** the authoritative spatial binding updates the lane origin and direction according to that policy
   **And** the telegraph consumes each newly committed snapshot
   **And** presentation does not perform its own aiming or target prediction.

7. **Freeze one authoritative lane**

   **Given** the execution reaches its declared lock boundary at or before active start
   **When** the lane is committed
   **Then** one immutable spatial snapshot records the execution and physics-step identities, origin, direction, length, width, orientation, blocking policy, and locked state
   **And** later player or source movement cannot rotate, widen, lengthen, home, or retarget that lane
   **And** losing the original target after lock follows the authored continuation policy rather than silently rebuilding the shot.

8. **Make the warning match the damaging path**

   **Given** a locked lane snapshot exists
   **When** the primitive warning is displayed and the projectile is delivered
   **Then** both consume the same lane origin, centerline, direction, length, and width
   **And** the mapping between displayed lane width and the projectile's swept damaging cross-section is explicit and equal within documented visual and physics tolerances
   **And** camera angle, source animation, interpolation, or rendered-frame timing cannot cause the warning and collision path to diverge.

9. **Spawn exactly one attributed projectile**

   **Given** the execution reaches active delivery
   **When** the action owner submits its typed spawn request
   **Then** exactly one projectile is created with the current run identity, stable source reference, execution identity, committed lane snapshot, immutable `DamageSnapshot`, spawn transform, velocity, and projectile definition
   **And** the required projectile scene and definitions were resident before scenario activation
   **And** spawn rejection produces a typed terminal or delivery result without a hidden retry or partially active hit window.

10. **Advance projectile motion through fixed-step simulation**

    **Given** the projectile has spawned successfully
    **When** physics advances
    **Then** its position and travel distance derive from the immutable speed policy and physics delta expressed in seconds
    **And** a swept query covers the complete movement segment between committed positions using the named collision profile
    **And** the first eligible blocking contact determines impact or obstruction according to stable rules
    **And** high speed cannot allow the projectile to tunnel through the player or ordinary cover.

11. **Allow the player to cross the committed lane**

    **Given** the warning direction has locked and the player has sufficient time and space to respond
    **When** the player moves laterally, changes altitude, or uses traversal to leave the damaging path before the projectile arrives
    **Then** the shot continues along its frozen lane and misses
    **And** it cannot steer toward the player after lock
    **And** the successful crossing is observable without consulting hidden implementation state.

12. **Let cover block the shot**

    **Given** eligible blocking geometry lies between the source and player
    **When** the projectile's swept query reaches that geometry first
    **Then** the projectile commits one blocked impact and terminates according to its definition
    **And** the player or another target behind that cover receives no damage from the occurrence
    **And** the warning still communicates the attempted lane while the impact feedback communicates why delivery stopped.

13. **Resolve an exposed hit exactly once**

    **Given** the player remains inside the projectile's damaging path without intervening cover
    **When** the swept delivery accepts the player's hurtbox
    **Then** one `ImpactContext` and one delivery occurrence resolve through the shared target-side damage and health contracts
    **And** stable source, execution, projectile, impact, and run attribution remain available
    **And** duplicate hurtboxes, repeated callbacks, or a later stale collision cannot apply the same projectile's damage more than once.

14. **Apply source-death and reset policies explicitly**

    **Given** the source dies during windup before the projectile is spawned
    **When** death cancellation reaches the execution
    **Then** the shot terminates without active delivery.

    **Given** the projectile has already spawned with the approved `PERSIST_AFTER_SOURCE` policy
    **When** its source dies before impact
    **Then** the projectile continues using its immutable attribution and damage snapshot without dereferencing the destroyed source.

    **Given** the fixture run is reset at any phase
    **When** the old run is invalidated
    **Then** its execution, telegraph, projectile, callbacks, and presentation are removed or rejected exactly once regardless of the source-death policy.

15. **Define grapple and wall interactions**

    **Given** the lane-shot scenario is active
    **When** the player uses grappling, wall running, wall sticking, jumping, or ordinary movement to cross or escape the lane
    **Then** those traversal systems remain available under their existing policies
    **And** solid cover blocks the projectile consistently whether the player is grounded or wall-relative
    **And** the pressure source retains its authored grapple eligibility while the projectile itself returns its explicit non-grappleable response
    **And** the attack does not directly cancel grapple or wall movement.

16. **Provide a recovery opportunity after failure**

    **Given** the player is struck by the lane shot
    **When** damage and hit feedback commit
    **Then** the player can identify the lane, impact, source, and health result through primitive feedback
    **And** the scenario preserves an authored route or movement option for recovering from the hit
    **And** the projectile does not create an unapproved control lock, repeated damage pulse, or lingering invisible danger.

17. **Provide replaceable presentation and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, tracking, lock, windup, spawn, travel, block, hit, miss, cancellation, or reset occurs
    **Then** primitive line geometry, projectile geometry, color or material changes, and impact markers communicate the required state
    **And** future animation, audio, and VFX adapters can consume committed lifecycle, lane, projectile, impact, and terminal facts without controlling them
    **And** bounded diagnostics expose request and execution identities, lock step, lane transform and dimensions, projectile radius and velocity, source/run attribution, query result, impact result, damage result, and terminal reason using already-computed data.

18. **Make lane-shot counterplay manually reproducible**

    **Given** the named direct-lane fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can remain exposed and be hit, cross the locked lane and avoid it, use cover to block it, and recover after the deliberate failure
    **And** they can repeat the counters using grapple or wall traversal, inspect the projectile's non-grappleable response, kill the source before lock, kill it after launch, reset during each phase, and rerun the scenario
    **And** the evidence records whether warning width, direction, timing, active travel, impact, and counters were understandable without final presentation assets.

19. **Verify the delivery contract**

    **Given** the permanent direct-lane suite and focused real-Jolt fixture run
    **When** they exercise tracking before lock, target movement after lock, lane-edge tolerances, high-speed projectile motion, multiple hurtboxes, cover, simultaneous target and cover candidates, source removal before and after spawn, invalid definitions, spawn failure, stale runs, repeated reset, and randomized notification order
    **Then** warning, delivery, blocking, damage, attribution, termination, and cleanup follow their declared contracts
    **And** the telegraph and damaging cross-section remain aligned within documented tolerances
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time windup, projectile travel, hit results, and outcomes.

20. **Contribute one bounded family representative**

    **Given** Story 3.4 is reviewed for completion
    **When** its manual and automated evidence is inspected
    **Then** one primitive direct lane shot demonstrates the Spatial Threat Delivery family through authoritative lifecycle, affected space, spawned delivery, swept impact, immutable damage, attribution, counterplay, and cleanup
    **And** the project and previous fixtures remain runnable with valid retained references
    **And** the story has not implemented arcing bombardment, predictive marking, rotating sweeps, aerial mines, damage gas, ability combinations, a production ranged enemy, final presentation, or the full six-family gate.
