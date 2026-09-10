---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 3
---

# Story 4.3: Cross a Rate-Independent Rotating Sweep

As a player,
I want a rotating attack to clearly show its starting position, direction, extent, and speed,
So that I can cross its path at the right time or use another route instead of being hit by an unpredictable moving volume.

**Acceptance Criteria:**

1. **Declare the rotating-sweep gameplay question**

   **Given** the rotating-sweep prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player reads the sweep direction and chooses when, where, or at what altitude to cross its path
   **And** its geometry, rotation, telegraph, counters, recovery, cover, grapple and wall interactions, source-death policy, overlap rule, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one rotating spatial delivery rather than a homing beam or persistent arena system.

2. **Author one immutable sweep definition**

   **Given** the baseline rotating-sweep profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 0.80-second windup, a 0.40-second tracking interval, a final 0.40-second locked interval, a 2.0-second active duration, a 180-degree clockwise sweep when viewed from above, and a 5.0-second start-to-next-start cadence
   **And** its vertical plane extends from a 2.0-metre inner radius to a 16.0-metre outer radius, rises 8.0 metres above its bound source origin, has 0.50-metre thickness, deals 8 base damage, and can hit each target once per execution
   **And** it declares origin binding, axis, angular progression, cover, hit, source-death, and presentation policies
   **And** these values remain authored configuration rather than literals in the execution, query, fixture, or presenter.

3. **Keep execution state outside the definition**

   **Given** a rotating-sweep execution is accepted
   **When** its runtime state is inspected
   **Then** it records stable source, target, execution, and run identities; authoritative phase times; source-anchor snapshots; tracking and locked bearings; sweep direction; prior and current active transforms; accepted-hit history; and terminal reason
   **And** it does not mutate the shared attack, spatial, damage, or presentation definitions
   **And** the action owner controls lifecycle while the spatial binding and delivery owner control authoritative geometry.

4. **Request the sweep through the action boundary**

   **Given** the source has a valid target and the fixture or AI requests a rotating sweep
   **When** the request reaches its action owner
   **Then** the owner validates source and target, range, current line of sight, action state, cadence, current run, unresolved-sweep limit, definitions, and required resident assets before committing one execution
   **And** AI and fixture controls cannot rotate the plane, perform hit queries, apply damage, or advance lifecycle time
   **And** rejected, duplicate, stale, and busy requests produce typed results without a partial sweep.

5. **Track and lock one horizontal target bearing**

   **Given** the sweep is within the first 0.40 seconds of windup
   **When** current source and target spatial facts are accepted
   **Then** the center bearing updates from the source toward the target after projection onto the world-up horizontal plane
   **And** an invalid or degenerate projected direction returns a typed failure.

   **Given** tracking reaches 0.40 seconds
   **When** the lock boundary commits
   **Then** the center bearing freezes for the remainder of the execution
   **And** later target movement or source facing cannot rotate the committed sector.

6. **Derive an understandable start and end orientation**

   **Given** the baseline center bearing has locked
   **When** the 180-degree clockwise sector is constructed
   **Then** its start orientation is 90 degrees counterclockwise from the center bearing and its end orientation is 90 degrees clockwise from it
   **And** the sweep reaches the original locked target bearing halfway through its two-second active duration
   **And** start, center, end, direction, axis, inner radius, outer radius, height, and thickness are recorded in one authoritative spatial binding.

7. **Show the complete sweep plan during windup**

   **Given** the execution is in windup
   **When** primitive telegraph presentation observes its current binding
   **Then** it displays the future starting plane, inner and outer boundaries, maximum height, intended half-circle sector, and clockwise direction
   **And** it clearly distinguishes the initial tracking interval from the final locked interval
   **And** no damaging query or physical collision is active during windup
   **And** presentation cannot choose a different direction, arc, size, or timing.

8. **Advance rotation from normalized simulation time**

   **Given** the active phase begins
   **When** simulation-owned active elapsed time advances
   **Then** authoritative angular progress equals clamped active elapsed seconds divided by 2.0 seconds
   **And** the current angle equals the locked start angle plus 180 degrees multiplied by that normalized progress in the configured direction
   **And** the plane reaches the exact start and end orientations once
   **And** neither render delta, animation playback, accumulated per-frame rotation, nor physics-step count determines angular speed.

9. **Bind translation to the source without following its facing**

   **Given** the source moves normally while the sweep remains active
   **When** a current valid source-anchor snapshot is committed
   **Then** the plane's pivot follows that anchor position while retaining its locked world-up axis, center bearing, start orientation, and simulation-derived angular progress
   **And** ordinary source rotation or animation cannot steer the active plane
   **And** a missing anchor, invalid source, teleport, or severe discontinuity cancels the sweep rather than dragging the damaging space unpredictably
   **And** the baseline source movement policy holds position during active gameplay while a controlled fixture case verifies the binding.

10. **Sweep the complete motion between physics steps**

    **Given** previous and current authoritative plane transforms exist
    **When** the active delivery owner checks for hits
    **Then** it evaluates the complete translated and rotated volume traversed between those transforms rather than only the plane's current pose
    **And** fast player motion or a change between 60 Hz and 120 Hz cannot pass through an unqueried angular gap
    **And** the start and final active boundaries are included exactly once
    **And** query candidates are normalized, stably ordered, and deduplicated.

11. **Match visible and damaging geometry**

    **Given** the sweep is active
    **When** the rotating primitive plane is displayed and collision candidates are evaluated
    **Then** both consume the same pivot, axis, current angle, inner and outer radii, height, thickness, and phase progress
    **And** visual interpolation may smooth between committed snapshots but cannot lead, lag, widen, or shrink gameplay beyond documented presentation tolerance
    **And** the visible direction indicator continues to agree with authoritative rotation.

12. **Let eligible cover block damage**

    **Given** the swept plane intersects the player's eligible hurt volume
    **When** named line-of-sight validation finds ordinary blocking cover between the committed source anchor and the candidate impact point
    **Then** the delivery is rejected as blocked and the player receives no damage from that contact
    **And** the blocked result is observable through primitive impact feedback
    **And** the visual plane remains non-solid and cannot push or move the cover or player.

13. **Apply at most one hit per target**

    **Given** an eligible uncovered target intersects the authoritative swept volume
    **When** its first unique delivery occurrence is accepted
    **Then** one immutable damage snapshot and current impact context resolve through the existing damage and health contracts
    **And** the baseline occurrence applies 8 damage with no knockback, tether, stun, movement modifier, or lingering status
    **And** later intersections, re-entry, duplicate hurtboxes, repeated callbacks, or boundary overlap from the same execution cannot damage that target again.

14. **Allow the player to move into cleared space**

    **Given** the active plane has already swept through part of its committed sector
    **When** the player moves into that passed region without crossing the current swept volume
    **Then** the player remains safe from that execution
    **And** the plane never reverses, restarts, or revisits an earlier angle
    **And** moving with or against the sweep produces understandable timing tradeoffs.

15. **Preserve inner, outer, vertical, and cover counters**

    **Given** the player reads the locked sweep plan
    **When** they move inside the 2.0-metre inner radius, beyond the 16.0-metre outer radius, above the 8.0-metre height, behind eligible cover, or outside the committed half-circle
    **Then** they are outside or protected from the damaging volume
    **And** the fixture makes each supported boundary visible and reachable where intended
    **And** crossing through the active plane itself is not treated as safe merely because the player moved quickly.

16. **Preserve grapple and wall traversal**

    **Given** the player uses grappling, wall-running, wall-sticking, or wall-jumping during the sweep
    **When** their movement intersects or escapes its geometry
    **Then** those traversal systems continue through their existing owners
    **And** the sweep cannot cancel grapple, invalidate an anchor, disable a wall, suppress input, write velocity, or force a locomotion transition
    **And** grappling above the height, around the pivot, or into cleared space and using an authored wall route remain manually demonstrable counters.

17. **Provide recovery after a deliberate hit**

    **Given** the player is struck once by the active plane
    **When** damage and feedback commit
    **Then** their movement remains available immediately and the same execution cannot damage them again
    **And** they may continue through or leave the sweep using an authored recovery route
    **And** the five-second cadence leaves a manually verified interval before another sweep may begin.

18. **Prevent unresolved-sweep stacking**

    **Given** the source already owns a windup or active baseline sweep
    **When** it requests another sweep
    **Then** the later request is rejected without restarting, reversing, widening, or replacing the current occurrence
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** the focused fixture does not permit simultaneous sweeps from multiple sources; later overlap belongs to the combination-testing epic.

19. **Apply source-death and reset cleanup**

    **Given** the source dies or becomes invalid during windup or active rotation
    **When** the baseline `CANCEL_WITH_SOURCE` policy resolves
    **Then** the sweep terminates immediately without further spatial queries or damage
    **And** its presentation and accepted-hit history follow the same terminal cleanup.

    **Given** the fixture resets, checkpoint reloads, or the scene exits
    **When** the prior run is invalidated
    **Then** executions, bindings, telegraphs, active geometry, delivery history, cooldown state, presenters, and late callbacks are removed or rejected exactly once.

20. **Keep sweep tuning configurable**

    **Given** an alternate valid definition changes windup, tracking and lock times, active duration, arc, direction, inner or outer radius, height, thickness, damage, cadence, origin-binding policy, or cover policy
    **When** the same lifecycle and rotating-space implementation consume it
    **Then** telegraphing, angular progress, spatial queries, presentation, diagnostics, and outcomes use the authored values without code changes
    **And** at least one alternate-profile test proves that duration, angular arc, and geometry are not hard-coded
    **And** oscillating beams, reversals, multiple arms, full-circle repetition, floor-following shapes, damaging cover penetration, and simultaneous sweeps remain outside this story.

21. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, tracking, locking, windup, rotation, blocking, hitting, cancellation, or reset occurs
    **Then** primitive planes, sector boundaries, direction arrows, source charge, phase changes, and impact markers communicate the sweep
    **And** future animation, beam VFX, audio, camera, and material presenters can consume committed lifecycle and spatial facts without controlling them
    **And** diagnostics expose definition, execution, source, target, and run identities; pivot snapshots; locked bearing; start and end angles; normalized progress; previous and current transforms; swept query range; candidates; cover results; accepted-hit history; and terminal reason.

22. **Make sweep counterplay manually reproducible**

    **Given** the named rotating-sweep fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can remain near the locked center bearing and receive one hit, enter cleared space, move with and against the sweep, use the inner and outer boundaries, reach above the height using grapple, use cover, and take the wall route
    **And** they can deliberately intersect the plane more than once to verify one-hit behavior; inspect the start, center, and end orientations; test controlled source movement; kill the source during windup and active phases; reset every phase; and repeat the scenario
    **And** the procedure distinguishes objective geometry, angular timing, delivery, cover, hit, traversal, and cleanup results from subjective observations about sweep speed, arc, dimensions, warning, and cadence.

23. **Verify rate-independent swept delivery**

    **Given** the permanent rotating-sweep suite and focused real-Jolt fixture run
    **When** they exercise tracking and lock, exact start and end boundaries, angular and radial edges, vertical limits, translation plus rotation, fast target crossing, cover, duplicate hurtboxes, re-entry, source invalidation, stale runs, randomized callback order, and repeated reset
    **Then** every accepted execution derives its angle from normalized simulation time, covers every authoritative transform interval, damages each eligible target at most once, and terminates exactly once
    **And** warning and damaging geometry remain aligned within documented tolerances
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time duration, angular position over time, hit and block outcomes, damage count, cadence, and cleanup within documented tolerances
    **And** the story has not implemented oscillation, repeated rotations, multi-sweep combinations, production encounter choreography, or final presentation.
