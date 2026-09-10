---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 1
---

# Story 6.1: Turn a Growing Wall into a Lane-Shot Decision

As a player,
I want growing obstacles and direct lane shots to remain distinguishable and exploitable when they overlap,
So that I can choose between crossing early, taking another route, or turning the completed wall into cover.

**Acceptance Criteria:**

1. **Declare the combined gameplay question**

   **Given** the lane-shot-and-obstacle scenario is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player distinguishes the two warnings and decides whether to cross the future wall, remain behind it, move around it, or move above it while responding to the lane shot
   **And** its overlap schedule, spatial relationship, viable responses, deliberate failure, recovery, source-death behavior, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one focused two-ability scenario rather than an encounter, enemy squad, or reusable orchestration system.

2. **Compose the approved mechanics without redesigning them**

   **Given** Stories 3.4 and 3.6 established the direct lane shot and temporary obstacle
   **When** Story 6.1 is implemented
   **Then** it references their existing immutable definitions, action owners, lifecycle timing, spatial snapshots, projectile delivery, obstacle spawning, collision, damage, grapple, wall, source-death, and cleanup behavior
   **And** neither mechanic receives combination-specific targeting, damage, collision, movement, cancellation, or lifecycle logic
   **And** the combination fixture owns only authored setup, bounded sequencing, result observation, reset, and evidence.

3. **Author one immutable combination manifest**

   **Given** the baseline combination profile is inspected
   **When** its values and references are resolved
   **Then** it declares one production player, one primitive lane-shot source, one primitive obstacle source, the approved component definitions, stable fixture geometry, starting transforms, synchronized-opening plan, active-cover check, maximum occurrence counts, minimum readability interval, manual steps, and evidence rules
   **And** the baseline starts each source with no unresolved action, permits one obstacle occurrence, and permits only the lane-shot executions required by the documented checks
   **And** component timing, dimensions, projectile speed, damage, cooldown, and source-death policies remain referenced from their owning definitions rather than copied into the combination manifest.

4. **Provide one bounded approach-and-cover layout**

   **Given** the baseline fixture is opened
   **When** its authored geometry is inspected
   **Then** the player begins 18 metres from the lane-shot source along a clear forward firing axis
   **And** the wall's frozen base footprint is centered seven metres from the player along that axis with its broad face perpendicular to the lane
   **And** the obstacle source occupies a non-blocking lateral platform from which the approved placement request remains valid
   **And** the layout retains clear routes around both wall edges, open altitude above it, a usable wall face and top, at least one grapple approach, and one recovery space on each side.

5. **Validate the combined arrangement before activation**

   **Given** a combination attempt is requested
   **When** the pressure lab validates the scenario
   **Then** it confirms compatible definition versions, source and player identities, action readiness, placement range, support geometry, effect bounds, route-safety volumes, lane range, line of sight, collision profiles, wall orientation, starting occupancy, and current run identity
   **And** the synchronized opening provides at least the manifest's baseline 0.50-second player-facing interval between both warnings becoming observable and the earliest possible accepted player damage
   **And** an incompatible timing or spatial relationship returns a typed validation failure instead of silently retiming, moving, resizing, or weakening either mechanic
   **And** validation failure creates no partial action, warning, projectile, obstacle, or evidence attempt.

6. **Start every attempt from fresh scoped state**

   **Given** all prerequisites are valid
   **When** a new attempt begins
   **Then** the player and both sources receive typed initialization under one fresh fixture-run identity
   **And** transforms, health, velocity, traversal state, source readiness, targeting, active occurrences, and evidence match the authored starting state
   **And** no projectile, obstacle, cooldown, damage result, source state, or callback from an earlier attempt remains eligible.

7. **Keep the two sources and lifecycles independent**

   **Given** the coordinated sequence begins
   **When** both sources request their assigned abilities
   **Then** each request passes independently through its existing action owner and validation boundary
   **And** the lane source cannot create, place, activate, or remove the wall
   **And** the obstacle source cannot aim, lock, deliver, block, or terminate the lane shot
   **And** rejection, interruption, or completion of one request does not automatically cancel or advance the other.

8. **Begin one synchronized opening through normal requests**

   **Given** the fresh baseline attempt is ready
   **When** the fixture invokes its synchronized-opening command
   **Then** one lane-shot request and one obstacle-growth request are submitted during the same authoritative simulation step with distinct stable request identities
   **And** both owners independently accept or reject their request using existing rules
   **And** the fixture does not skip windup, bypass cooldown, pre-create collision, force a lane lock, or mutate either execution after submission
   **And** a partial acceptance remains observable and causes the combined attempt to be incomplete rather than manufacturing the missing pressure.

9. **Preserve independent phase timing during overlap**

   **Given** both opening requests are accepted
   **When** simulation time advances
   **Then** lane tracking, lane lock, projectile spawn and travel progress through Story 3.4's lifecycle
   **And** wall preview, final occupancy validation, activation, warning, and expiry progress through Story 3.6's lifecycle
   **And** neither lifecycle pauses, stretches, accelerates, or synchronizes itself to the other after request acceptance
   **And** render timing and presentation animation cannot change their relative phases.

10. **Keep the two telegraphs distinguishable**

    **Given** lane windup and obstacle preview overlap while the player and camera may be moving
    **When** the tester observes them without diagnostics
    **Then** the lane is communicated as a directional damaging corridor with its tracking or locked state
    **And** the obstacle is communicated as a volumetric future solid with its complete footprint, height, growth progress, and activation boundary
    **And** their non-color-only shape and motion cues remain distinguishable where the lane crosses the future wall
    **And** the player can identify which space will cause damage and which space will become collision.

11. **Keep the wall preview non-solid and non-protective**

    **Given** the obstacle is still in windup
    **When** the lane warning or projectile intersects its preview
    **Then** the preview does not block targeting, line of sight, the projectile, movement, grapple queries, or damage
    **And** a player standing behind the visual preview is still exposed until the approved obstacle activation commits
    **And** the visible preview cannot be mistaken by gameplay systems for active cover
    **And** presentation clearly distinguishes this non-solid state from the active wall.

12. **Permit an aggressive early crossing**

    **Given** both warnings are active and the future wall footprint remains non-solid
    **When** the player crosses completely to the source-facing side before wall activation and leaves the locked lane before projectile delivery
    **Then** the lane shot misses according to its frozen path
    **And** the wall may activate behind the player if its final occupancy and route-safety checks remain valid
    **And** the player retains ordinary movement, attack, grapple, and wall options on the source-facing side
    **And** this response creates proximity at the cost of giving up the completed wall as immediate cover from the source.

13. **Permit a defensive cover choice**

    **Given** the player remains on the starting side while leaving or otherwise surviving the opening lane
    **When** the obstacle completes its final validation and activates
    **Then** its ordinary full-size collider lies between the player and lane source
    **And** the completed wall can provide physical and line-of-sight cover according to existing collision profiles
    **And** the wall blocks the direct approach without removing the side, altitude, grapple, wall, and recovery routes
    **And** remaining behind it is a tactical choice rather than forced player positioning.

14. **Honor safe activation cancellation when occupied**

    **Given** the player deliberately or accidentally occupies the protected wall volume at its activation boundary
    **When** Story 3.6 performs final occupancy validation
    **Then** the obstacle occurrence cancels without creating collision, pushing, teleporting, trapping, or damaging the player
    **And** cancellation does not cancel, redirect, delay, or weaken the lane shot
    **And** the player must still use an ordinary lane-shot response or accept its ordinary consequence
    **And** the cancellation cue clearly communicates why the expected wall did not become cover.

15. **Let the completed wall block a committed shot naturally**

    **Given** the obstacle is active and the player temporarily exposes themselves with a valid line of sight to the lane source
    **When** a normal lane shot locks and the player moves behind the active wall before projectile arrival
    **Then** the projectile's existing swept query encounters the wall before the player and commits one blocked impact
    **And** the player receives no damage from that projectile
    **And** the interaction requires no fixture-owned projectile interception, damage rejection, target change, or special combination rule
    **And** warning geometry, wall collision, projectile path, and blocked-impact feedback remain spatially consistent.

16. **Resolve wall appearance and removal through current world state**

    **Given** a lane projectile is travelling near the obstacle's activation or removal time
    **When** its next swept query resolves
    **Then** the query uses the authoritative collision state established by the project's fixed-step phase ordering
    **And** a wall that is not yet active or has already been invalidated cannot produce a ghost block
    **And** a projectile already terminated against the active wall cannot resume if the wall later expires
    **And** boundary-case outcomes are deterministic and recorded rather than dependent on node, callback, or signal order.

17. **Preserve side, altitude, grapple, and wall responses**

    **Given** the wall preview or active wall intersects the direct approach
    **When** the player chooses another response
    **Then** they can leave the lane around either wall edge, change altitude above the damaging path, grapple toward or across the wall, or use an active face or top through ordinary wall traversal
    **And** the wall and shot retain their existing grappleable and non-grappleable responses respectively
    **And** neither ability cancels grapple, suppresses jumping, forces a locomotion state, or writes player velocity
    **And** expiry while the player is supported by or attached to the wall follows Story 3.6's normal invalidation behavior.

18. **Preserve a response throughout the overlap**

    **Given** both abilities are active in any valid relative phase
    **When** the authored layout and timing are evaluated
    **Then** at least one observable lateral, altitude, cover, grapple, wall, or timing response remains physically achievable from the expected player region
    **And** the wall cannot close every exit or create a forced intersection with the locked lane
    **And** the lane cannot cover every route around or above the wall
    **And** a configuration that removes all responses fails scenario validation or playtest evidence rather than being accepted as intended difficulty.

19. **Allow recovery after an ordinary mistake**

    **Given** the player misreads the overlap, crosses too late, loses the expected wall through occupancy cancellation, or receives one ordinary lane-shot hit
    **When** the player remains alive
    **Then** at least one authored recovery space or traversal route remains reachable
    **And** the player can reassess whether the wall is previewing, active, cancelled, or expiring and choose a different response
    **And** the lane hit adds no combination-specific knockback, stun, repeated damage, input loss, or route lock
    **And** the obstacle does not amplify damage or convert the mistake into an unavoidable control chain.

20. **Apply source-death policies independently**

    **Given** either source dies during the combination
    **When** its approved source-death policy resolves
    **Then** killing the lane source before projectile spawn cancels only its pending shot while killing it after spawn permits that projectile to continue
    **And** killing the obstacle source during preview cancels only the preview while killing it during the active phase invalidates only the wall through its existing cleanup path
    **And** killing one source does not kill, interrupt, retarget, or reset the other source
    **And** removal of an active wall while a projectile travels produces either an ordinary prior block or continued flight according to authoritative collision timing, never a ghost collision.

21. **Record one bounded attempt result**

    **Given** the paired opening has begun
    **When** the player dies, the run is reset, or both opening occurrences reach terminal states and any required cover check completes
    **Then** the fixture records one terminal attempt result without changing gameplay state to manufacture that result
    **And** it distinguishes a clean response, recovery after an accepted hit, player defeat, partial ability rejection, invalid setup, and manual abort
    **And** the record includes chosen side or route, wall outcome, lane outcome, accepted damage, recovery observation, source outcomes, and terminal times
    **And** completing the fixture grants no reward, objective progress, checkpoint, or production encounter state.

22. **Reset both mechanics and their interaction completely**

    **Given** reset is requested during request submission, overlapping windup, lane lock, wall cancellation, projectile travel, wall activation, blocked impact, player damage, source death, wall expiry, or evidence finalization
    **When** the old run is invalidated
    **Then** both executions, warnings, snapshots, projectiles, obstacle occurrences, collision, target references, damage records, source states, timers, presentations, attempt state, and late callbacks are removed or rejected exactly once
    **And** player transform, velocity, health, traversal state, and both sources return to their authored starting values
    **And** the next attempt reproduces the same initial relationship without restarting the editor.

23. **Keep combination tuning configurable and isolated**

    **Given** an alternate valid combination profile changes starting transforms, wall placement, source placement, request offset, minimum readability interval, allowed attempt count, or route markers
    **When** the same fixture consumes it
    **Then** sequencing, validation, presentation, evaluation, and evidence use those authored scenario values without code changes
    **And** changing combination layout or timing never mutates the lane-shot, obstacle, projectile, damage, collision, or movement definitions
    **And** at least one alternate-profile test proves that synchronized timing and spatial arrangement are not hard-coded
    **And** tuning remains provisional and traceable rather than represented as final encounter balance.

24. **Provide replaceable combined feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** requests, warnings, lock, growth, cancellation, activation, travel, block, hit, recovery, expiry, source death, or reset occurs
    **Then** primitive lane geometry, wall volume, phase cues, projectile geometry, impact markers, route markers, health feedback, and typed result displays make the interaction testable
    **And** future presentation can observe committed component and combination facts without controlling either mechanic or the attempt result
    **And** diagnostics expose scenario and run identities, request ordering, independent lifecycle phases, lane snapshot, wall transform and collision state, player side and route, projectile query result, damage result, source state, terminal outcomes, and cleanup.

25. **Make the combination manually reproducible**

    **Given** the named lane-and-obstacle fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they first evaluate both warnings with diagnostics disabled and demonstrate an aggressive early crossing, a defensive starting-side response, a side or altitude response, and ordinary grapple or wall traversal
    **And** they occupy the preview at activation to verify safe cancellation, expose and retreat behind an active wall to verify projectile blocking, and deliberately receive one lane hit before recovering
    **And** they kill each source before and after its relevant commitment boundary, reset during each combined phase, and repeat the scenario
    **And** every check has observable pass or fail criteria and retained evidence distinguishes contract results from subjective timing, readability, route-value, and difficulty observations.

26. **Verify deterministic combined behavior**

    **Given** the permanent lane-and-obstacle suite and focused real-Jolt fixture run
    **When** they exercise synchronized requests, independent rejection, tracking and lock, preview intersection, final occupancy cancellation, wall activation, lateral and altitude escapes, active-wall blocking, wall invalidation during projectile travel, both source-death policies, duplicate callbacks, stale runs, randomized notification order, and repeated reset
    **Then** each accepted ability retains one valid independent lifecycle, the projectile damages the player no more than once, and the obstacle activates or cancels no more than once
    **And** warnings and gameplay spaces remain aligned while at least one response and one post-mistake recovery remain demonstrable
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time lifecycle timing, relative phase order, collision outcomes, damage results, terminal counts, and cleanup within documented tolerances.

27. **Keep the story bounded to one approved pair**

    **Given** Story 6.1 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it contains only the existing direct lane shot, existing temporary obstacle, two primitive sources, one bounded fixture, finite sequencing, observational evaluation, reset, and focused verification
    **And** it has not added another pressure mechanic, production enemy AI, encounter orchestration, waves, rewards, objectives, difficulty scaling, final HUD, final animation, final audio, final VFX, or Last Garden content allocation
    **And** the remaining five combinations, full 17-mechanic gate, and production-subset decision remain assigned to later Epic 6 stories.
