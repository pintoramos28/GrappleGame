---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 6
---

# Story 6.6: Navigate an Aerial Mine Lattice in Directional Wind

As a player,
I want wind and aerial mines to remain readable and counterable when they occupy the same route,
So that I can compensate for the force, exploit it as momentum, or choose another path without being pushed into unavoidable damage.

**Acceptance Criteria:**

1. **Declare the combined gameplay question**

   **Given** the aerial-mine-lattice-and-directional-wind scenario is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player can read a persistent aerial hazard and a separate directional influence on their trajectory while preserving deliberate route choices
   **And** its spatial relationship, synchronized timing, supported orientations, viable routes, deliberate failures, damage recovery, source-death behavior, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one four-mine lattice and one directional field rather than a general hazard-field encounter or production orchestration system.

2. **Compose the approved mechanics without redesigning them**

   **Given** Stories 4.6 and 5.3 established the directional wind field and aerial mine lattice
   **When** Story 6.6 is implemented
   **Then** it references their existing immutable definitions, action owners, lifecycles, spatial snapshots, spawn and field-membership rules, motor integration, swept mine trigger, damage, recovery, grapple, wall, source-death, and cleanup behavior
   **And** neither mechanic receives combination-specific movement, trigger, damage, recovery, lifecycle, placement, or terminal logic
   **And** the fixture owns only authored setup, bounded activation, result observation, reset, and evidence.

3. **Use two independent pressure sources**

   **Given** the combination participants are inspected
   **When** their roles are resolved
   **Then** one primitive wind source may request the approved directional field and one primitive mine source may request the approved four-mine lattice
   **And** the wind source cannot move, arm, trigger, detonate, expire, or otherwise alter a mine
   **And** the mine source cannot establish field membership, submit a motor influence, change the wind direction, or alter player velocity
   **And** both sources retain their original action, unresolved-occurrence, cadence, and source-death policies.

4. **Author one immutable combination manifest**

   **Given** a combination profile is inspected
   **When** its values and references are resolved
   **Then** it declares one production player, one wind source, one mine source, both approved component definitions, participant transforms, bounded geometry, synchronized activation plan, a through-gap baseline orientation, a crosswind alternate orientation, occurrence limits, route references, manual checks, and evidence rules
   **And** it permits no more than one unresolved directional field and one unresolved four-mine lattice
   **And** all component tuning remains referenced from the original immutable definitions
   **And** only combination positions, relative orientation, route geometry, sequencing, and observation rules are authored by this manifest.

5. **Provide one bounded three-dimensional layout**

   **Given** the baseline combination fixture is opened
   **When** its authored geometry is inspected
   **Then** the player begins near a shared targeting center, the wind source is positioned behind the player relative to the intended crossing, and the mine source faces the same bounded route region
   **And** the approved 12-by-6-by-5-metre wind field covers the approach to the lattice without covering the complete fixture
   **And** the four mines leave their approved central gap, routes around both horizontal sides, and routes above and below within the authored traversal space
   **And** readable upwind and crosswind grapple anchors, an elevated wall route, lateral exits, eligible cover, and a lower nonterminal recovery area remain available.

6. **Align the baseline wind through the central gap**

   **Given** the through-gap baseline profile is selected
   **When** the complete frozen field and lattice snapshots are compared
   **Then** the wind's horizontal direction is aligned with the lattice plane normal within the documented angular tolerance
   **And** its centerline pushes through the intended central opening rather than through a mine center
   **And** the complete swept body volume of the authored central reference route remains outside every mine trigger sphere after declared spatial tolerances are applied
   **And** invalid or unsafe alignment rejects the combination profile rather than moving a mine, widening the gap, or steering the player.

7. **Provide one explicit crosswind profile**

   **Given** the alternate profile is selected
   **When** its relative orientation is resolved
   **Then** the field direction lies generally along the lattice's right axis and pushes the player toward one authored mine column
   **And** the fixture retains at least one manually reachable compensating route using steering, timing, altitude, wall traversal, or a crosswind grapple
   **And** the wind and lattice keep their approved component definitions and frozen-world behavior
   **And** the fixture does not move the mines, rotate the gap after lock, weaken the field, or provide hidden steering assistance.

8. **Validate combined routes before activation**

   **Given** a paired attempt is requested
   **When** the pressure lab validates its participants and layout
   **Then** it confirms stable identities, current run, source readiness, component definitions, placement bounds, field orientation and basis, lattice basis and offsets, mine trigger and blast clearance, grapple anchors, wall route, cover, exits, and recovery areas
   **And** each supported orientation has at least one reference response whose complete swept player volume remains outside every mine trigger sphere under the expected wind contribution
   **And** an invalid profile returns a typed failure without partially requesting either action
   **And** validation cannot silently modify a component definition or install a corrective movement influence.

9. **Start every attempt from fresh scoped state**

   **Given** all prerequisites are valid
   **When** a new combined attempt begins
   **Then** the player and both sources receive typed initialization under one fresh fixture-run identity
   **And** the player begins at the authored transform, stationary, without injected velocity, active grapple, damage recovery, or prior field membership
   **And** each source begins ready and without an unresolved execution, occurrence, cadence artifact, snapshot, field, lattice, mine, or terminal state
   **And** no movement, trigger, damage, presentation, diagnostic, or evidence state survives from an earlier attempt.

10. **Begin both mechanics through their normal action boundaries**

    **Given** the fresh combination attempt is ready
    **When** the fixture starts the synchronized activation plan
    **Then** it submits one ordinary directional-field request and one ordinary aerial-lattice request during the same authoritative simulation step with stable request identities
    **And** each action owner independently accepts or rejects its request under the existing validation and lifecycle rules
    **And** the fixture cannot place or lock either snapshot, create a field or mine, grant velocity, arm or trigger a mine, or bypass a component windup
    **And** rejection of either request makes the combined attempt incomplete without disguising the surviving mechanic as a successful pair.

11. **Preserve the declared relative lifecycle**

    **Given** both same-step requests are accepted at attempt time zero
    **When** their existing action lifecycles advance
    **Then** the lattice tracks until 0.40 seconds and then locks its complete four-position snapshot
    **And** the directional field becomes active after its 0.75-second windup
    **And** the four mines are created atomically when the lattice's 1.0-second windup completes and arm for their existing 0.75-second interval
    **And** the mines become armed at 1.75 seconds while the directional field remains active
    **And** the field ends after its five active seconds while any surviving mine continues independently through its own armed lifetime and expiry.

12. **Keep both mechanics visually distinguishable**

    **Given** the field and lattice are previewing, active, arming, armed, triggered, or expiring
    **When** primitive player-facing presentation observes their committed facts
    **Then** the field communicates its oriented volume, flow direction, activation state, and lateral exits
    **And** the lattice communicates four distinct mine centers, trigger and blast boundaries, phase state, countdown, and safe gaps
    **And** geometry, motion, direction markers, spatial repetition, and countdown cues keep the mechanics distinguishable without relying on color alone
    **And** neither presentation layer hides the other's central route, mine warning, field boundary, or escape information.

13. **Keep wind from affecting mine state**

    **Given** the field overlaps one or more mines during any mine phase
    **When** field membership, sustained influence, physics collision, trigger, and lifecycle systems resolve
    **Then** each mine retains its frozen world position and independent lifecycle
    **And** wind cannot translate, rotate, drift, arm, trigger, detonate, refresh, expire, or otherwise submit state to a mine
    **And** field particles, flow markers, spatial-query helpers, and presentation objects are never eligible mine-trigger recipients
    **And** only the eligible player's authoritative swept hurt-volume motion can trigger a mine in this combination.

14. **Route wind through the player motor once**

    **Given** the eligible player is inside the active directional field
    **When** the sustained-influence phase resolves
    **Then** the field submits its approved acceleration influence through the existing player-motor boundary
    **And** mines, mine presentation, sources, and fixture controls do not write player velocity or add another wind adjustment
    **And** the existing deterministic motor phase ordering combines locomotion, grapple, attack, wind, constraints, and collision response
    **And** the motor performs exactly one final velocity assignment and movement commit for the physics step.

15. **Preserve the wind contribution rule without a player speed cap**

    **Given** a field-eligible sustained-influence phase begins
    **When** its wind contribution is calculated
    **Then** the permitted downwind velocity change is the smaller of 12.0 metres per second squared multiplied by effective active time and the positive difference between 10.0 metres per second and the authoritative phase-entry downwind component
    **And** a phase-entry downwind component at or above 10.0 metres per second receives zero contribution from this field
    **And** wind never reduces existing speed above 10.0 metres per second and never applies a hard cap to total player velocity
    **And** grapple, attack movement, retained momentum, or another approved influence may still produce a total downwind component greater than 10.0 metres per second.

16. **Let the player ride the baseline wind through the gap**

    **Given** the baseline field is active and the lattice is arming or armed
    **When** the player enters the field on the authored central reference route and maintains a valid line through the gap
    **Then** the player's complete swept hurt volume remains outside all four mine trigger spheres
    **And** the field may accelerate the player through the lattice without speed alone counting as a mine trigger
    **And** momentum gained from the field persists after leaving it under the existing motor rules
    **And** the successful gap and resulting boost are understandable with player-facing cues while diagnostics are disabled.

17. **Preserve a lateral exit around the combination**

    **Given** the player is inside the active field before reaching the lattice
    **When** they steer through an authored lateral field exit and route around the mine pattern
    **Then** that occurrence stops submitting wind influence as soon as ordinary field membership ends
    **And** velocity already gained remains available for the escape under normal movement and collision rules
    **And** the player can continue around the lattice without intersecting a trigger sphere
    **And** the stationary armed mines remain present rather than following, rotating toward, or despawning for the exiting player.

18. **Require deliberate compensation in crosswind**

    **Given** the crosswind profile is active
    **When** the player approaches the lattice
    **Then** uncorrected movement visibly drifts toward the authored mine column under the ordinary field contribution
    **And** steering upwind, taking the upwind side, changing timing or altitude, or using the crosswind grapple provides at least one reproducible safe response
    **And** no fixture script corrects the player's position, heading, or velocity
    **And** the field direction and mine positions remain unchanged throughout the attempt
    **And** the profile fails validation if no safe compensating response remains reachable.

19. **Preserve altitude counterplay**

    **Given** the combination occupies its approved five-metre-high field and four-mine lattice plane
    **When** the player uses jumping, wall traversal, or grapple movement to pass above the field and all mine trigger spheres
    **Then** field membership clears through the ordinary oriented-box query and no mine triggers
    **And** at least one lower route also remains available when the fixture geometry and mine clearances validate it
    **And** neither field nor lattice stretches vertically, follows the player, or shifts its center to erase the altitude response.

20. **Preserve grapple and maximum-distance behavior**

    **Given** the player grapples an eligible upwind or crosswind anchor while exposed to the field
    **When** the complete movement step resolves
    **Then** grapple pull and wind combine before the existing maximum-grapple-length constraint
    **And** wind directed away from the anchor cannot pull the player beyond the maximum connection distance
    **And** the constraint removes or redirects only invalid outward movement while preserving valid inward and tangential motion
    **And** mines remain non-grappleable and do not occlude the eligible anchor
    **And** releasing the grapple preserves the velocity already resolved by the motor.

21. **Allow the player to wait out the wind**

    **Given** the player remains in a safe location outside the mine trigger spheres
    **When** the directional field reaches the end of its five-second active duration
    **Then** the field terminates and submits no further movement influence
    **And** surviving mines remain stationary and continue their independent armed lifetime until triggered or expired
    **And** the player can then navigate the stationary lattice without wind
    **And** this valid response trades time for simpler movement rather than weakening, removing, or resetting the mines.

22. **Detect high-speed mine crossings under wind**

    **Given** wind or combined movement produces a high-speed player trajectory near an armed mine
    **When** the player's previous and current authoritative hurt-volume states form the step's motion interval
    **Then** the approved swept mine-trigger query evaluates the complete interval
    **And** a real intersection triggers the mine exactly once even when neither endpoint lies inside the trigger sphere
    **And** a swept route that truly clears the sphere remains a miss despite high speed
    **And** supported equivalent trajectories produce the same trigger result at shipping 60 Hz and diagnostic 120 Hz.

23. **Preserve escape after a mine triggers in wind**

    **Given** one armed mine accepts an eligible trigger while the player remains in or near the active field
    **When** its 0.35-second triggered warning begins
    **Then** the mine stays at its frozen center and displays the complete fixed blast region and remaining warning time
    **And** steering, grappling, leaving the field, moving laterally, or changing altitude can remain viable according to the authored route
    **And** neither the mine nor field homes, enlarges, shortens the warning, holds the player, or adds an undeclared control effect
    **And** the fixture can demonstrate at least one reproducible triggered escape before detonation.

24. **Preserve damage recovery and bounded burst**

    **Given** an eligible uncovered player remains in a triggered mine's two-metre blast at detonation
    **When** mine delivery resolves
    **Then** that mine applies its existing single 10-damage result without adding knockback, wind, tether, stun, or another movement effect
    **And** a second mine in the same lattice is rejected by lattice recovery when it attempts damage less than 0.75 seconds after the accepted hit
    **And** every detonating mine still reaches its own terminal state exactly once
    **And** ordinary nonlethal damage leaves the player able to steer, grapple, leave the field, change altitude, or continue through the fixture.

25. **Prevent an unavoidable control chain**

    **Given** directional wind and one or more armed mines overlap the route
    **When** the player's available responses are evaluated before impact and after ordinary nonlethal damage
    **Then** bounded wind applies no input suppression, forced facing, entry impulse, stun, or lingering status
    **And** every triggered mine keeps its visible fixed warning, single detonation, and lattice recovery policy
    **And** at least one immediate response and one recovery route remain reachable
    **And** the pair cannot repeatedly propel the player through unavoidable blasts without another player-controlled movement, route, timing, or grapple decision.

26. **Apply each source-death policy independently**

    **Given** the mine source dies before atomic mine creation
    **When** its existing `CANCEL_WITH_SOURCE` policy resolves
    **Then** lattice windup terminates and no mine becomes active.

    **Given** the mine source dies after the four-mine batch commits
    **When** its existing `PERSIST_AFTER_SOURCE` policy resolves
    **Then** every mine continues its independent lifecycle without changing the directional field.

    **Given** the wind source dies during windup or active use
    **When** its existing `CANCEL_WITH_SOURCE` policy resolves
    **Then** the preview or active field terminates, future wind submissions stop, and velocity already gained remains
    **And** no source-death path cancels, advances, retargets, or otherwise changes the other source's mechanic.

27. **Record one bounded attempt result**

    **Given** a combined attempt reaches its authored endpoint, both mechanics become terminal, the player dies, reset occurs, or the fixture aborts
    **When** the result recorder closes the attempt
    **Then** it emits exactly one typed result such as clean central crossing, lateral exit, altitude route, compensated crosswind, triggered escape, damage recovery, waited-out wind, player death, partial activation, invalid setup, or abort
    **And** retained evidence links that result to component lifecycles, player movement, field membership, mine triggers and detonations, damage, source outcomes, and cleanup
    **And** the fixture awards no progression, reward, objective completion, encounter score, or production allocation from that result.

28. **Restore the complete combination on reset**

    **Given** reset, checkpoint reload, or scene exit occurs during any combined phase
    **When** the old run is invalidated
    **Then** both executions, spatial snapshots, field and membership state, motor submissions, lattice coordinator, all mines, triggers, detonations, damage deliveries, recovery records, sources, presentation, result state, and late work are removed or rejected exactly once
    **And** player transform, health, velocity, grapple, locomotion, and fixture participants return to their declared initial state
    **And** no stale field, mine, movement influence, damage, recovery, source action, diagnostic, or evidence event enters the fresh run.

29. **Keep combination geometry and orientation configurable**

    **Given** an alternate valid combination manifest changes source positions, shared target, relative orientation, lattice offset placement, route anchors, wall, cover, exits, or recovery geometry
    **When** the same fixture and approved component implementations consume it
    **Then** setup, validation, activation, observation, reset, and evidence use the authored values without code changes
    **And** the through-gap and crosswind profiles prove relative geometry and orientation are not hard-coded
    **And** changing combination configuration does not mutate field strength, mine spacing, lifecycle timing, damage, or another component definition
    **And** invalid geometry fails explicitly without hidden route, steering, or safety assistance.

30. **Provide replaceable presentation and complete diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** combined setup, preview, activation, movement, field exit, lattice creation, arming, triggering, detonation, damage, recovery, source death, expiry, result, or reset occurs
    **Then** primitive sources, volumes, arrows, lattice lines, mine spheres, countdowns, route markers, and typed state displays communicate the interaction
    **And** future models, animation, particles, trails, audio, camera feedback, and VFX can consume committed facts without controlling placement, lifecycle, field membership, movement, mine triggering, damage, or results
    **And** diagnostics expose stable identities, profile and orientation, geometry, lifecycle times, field membership, phase-entry and resulting velocity, wind contribution, grapple constraint, swept mine results, warnings, detonations, damage and recovery, source policies, terminal results, cleanup, and run identity.

31. **Make combined counterplay manually reproducible**

    **Given** the named aerial-lattice-and-directional-wind fixture is launched through the Story 3.1 pressure lab
    **When** another developer first follows its documented procedure with diagnostics disabled
    **Then** they can ride the baseline field through the central gap, exit laterally, pass above or below, grapple upwind and crosswind, test the maximum grapple constraint, wait for wind expiry, and navigate the remaining lattice
    **And** in the crosswind profile they can observe uncorrected drift and reproduce at least one safe compensated route
    **And** they can trigger a mine and escape during warning, accept one hit and recover, and cross a trigger at wind-assisted high speed
    **And** with diagnostics enabled they can enter with a downwind component above 10.0 metres per second, verify that wind adds no further component and does not brake, and verify that other approved influences can still produce a total component above 10.0 metres per second
    **And** they can kill each source before and after its relevant commitment boundary, reset during every combined phase, restore all state, and repeat both profiles
    **And** retained evidence distinguishes objective timing, geometry, movement, field, trigger, damage, recovery, source-loss, cleanup, and repeatability results from subjective observations about cue clarity, drift, route value, escape difficulty, pressure, and movement feel.

32. **Verify deterministic combined behavior**

    **Given** the permanent combination suite and focused real-Jolt fixture run
    **When** they exercise both orientations, same-step requests, wind and lattice lock boundaries, atomic mine creation, field membership, the 10.0-metres-per-second contribution boundary, central, lateral and altitude routes, crosswind compensation, high-speed trigger crossings, warning escape, damage recovery, grapple constraints, both source-death phases, independent expiry, stale runs, randomized callback order, and repeated reset
    **Then** no occurrence submits more than one wind influence per eligible step, no mine triggers more than once, and no mine damage is accepted more than once per eligible recipient outside the declared recovery rule
    **And** each profile preserves distinguishable component behavior plus at least one pre-impact response and one post-damage recovery without a control chain
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time lifecycle timing, field membership within tolerance, movement contribution, route clearance, mine trigger and blast results, damage, recovery, terminal results, and cleanup within documented tolerances.

33. **Keep the story bounded to one approved pair**

    **Given** Story 6.6 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it contains only the existing directional field, existing stationary four-mine lattice, two primitive sources, one bounded fixture, two authored relative orientations, finite activation, observational evaluation, reset, and focused verification
    **And** it has not added wind-driven mines, mine chains, rigid-body wind, overlapping fields or lattices, turbulence, moving or homing mines, production AI, encounter orchestration, rewards, objectives, difficulty scaling, final presentation, or Last Garden allocation
    **And** the complete 17-mechanic vocabulary gate and production-subset decision remain assigned to later Epic 6 stories.
