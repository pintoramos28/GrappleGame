---
artifact_schema: 1
artifact_id: 'grapplegame.story.5.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 5
story: 1
---

# Story 5.1: Escape a Source-Independent Arcing Bombardment

As a player,
I want an arcing bombardment to show its trajectory, locked landing area, and impact timing,
So that I can leave or counter the affected space even if the attacker dies after launching it.

**Acceptance Criteria:**

1. **Declare the bombardment gameplay question**

   **Given** the arcing-bombardment prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player reads a locked landing area and uses lateral movement, altitude, grapple, wall traversal, or cover before a source-independent payload arrives
   **And** its targeting, tracking and lock timing, trajectory, landing volume, flight duration, counters, recovery, grapple and wall interactions, source-death policy, overlap policy, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one arcing delivery and instantaneous impact rather than a homing projectile, persistent hazard, or aerial-mine lattice.

2. **Author one immutable bombardment definition**

   **Given** the baseline bombardment profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 1.0-second pre-launch windup containing a 0.40-second tracking interval and final 0.60-second locked interval
   **And** it declares a 1.50-second payload flight, final 0.30-second impact-warning emphasis, 20.0-metres-per-second-squared downward trajectory acceleration, 0.25-metre payload clearance radius, and 35.0-metres-per-second maximum solved launch speed
   **And** it declares a 2.50-metre impact radius, 3.0-metre impact height, 12 damage, 6.0-to-30.0-metre targeting range, 5.0-second start-to-next-start cadence, and one unresolved payload per source
   **And** it declares `CANCEL_WITH_SOURCE` before committed spawn and `PERSIST_AFTER_SOURCE` afterward
   **And** these values remain authored configuration rather than literals in the action, trajectory solver, payload, fixture, or presenter.

3. **Keep execution and payload state outside definitions**

   **Given** a bombardment execution or payload occurrence exists
   **When** its runtime state is inspected
   **Then** it records stable definition, execution, source, target, trajectory, payload, impact-area, damage, and run identities; authoritative lifecycle times; target samples; landing snapshots; launch solution; current flight state; accepted deliveries; source policy; and terminal reason
   **And** it never mutates the shared attack, trajectory, damage, spatial-query, or presentation definitions
   **And** the action owner controls targeting and windup while the detached payload owns flight and impact after committed spawn.

4. **Request bombardment through the normal action boundary**

   **Given** the fixture or flying AI requests arcing bombardment
   **When** the request reaches its action owner
   **Then** the owner validates source and target identity, action state, minimum and maximum range, line of sight, cadence, unresolved-payload limit, run identity, definitions, effect bounds, and required resident assets before committing one execution
   **And** the flying AI may use its existing tactical-position result but cannot calculate the authoritative landing point, solve the trajectory, spawn the payload, apply damage, or advance lifecycle timing
   **And** rejected, duplicate, busy, invalid, and stale requests produce typed results without a partial marker or payload.

5. **Sample one eligible target reference**

   **Given** the execution is within its tracking interval
   **When** an authoritative target sample is requested
   **Then** it records the stable target and run identities, finite combat reference position, finite velocity, alive and eligibility state, and physics-step identity
   **And** it does not expose input commands, future movement, camera direction, animation state, private locomotion state, or an inferred trajectory
   **And** invalid, dead, stale-run, mismatched, or non-finite samples produce a typed failure.

6. **Resolve a supported landing point**

   **Given** a valid target sample is available
   **When** its current combat reference position is projected downward
   **Then** a named landing query must find static floor-like support within 20.0 metres whose normal is within 20 degrees of world up
   **And** the complete 2.50-metre-radius and 3.0-metre-high impact cylinder must fit within the fixture's authored effect bounds
   **And** unsupported, moving, steep, protected, discontinuous, out-of-bounds, or non-finite landing space is rejected with a typed reason
   **And** the candidate is not silently moved to another floor, nearby navigation point, or convenient fallback.

7. **Track only during the declared tracking interval**

   **Given** the execution is within its first 0.40 seconds
   **When** valid target samples and landing projections are accepted
   **Then** its provisional landing center may update to the newest valid supported position
   **And** a low-intensity primitive landing cylinder and provisional arc communicate that tracking remains active
   **And** updates occur only from simulation-owned samples
   **And** presentation cannot smooth or predict the marker into a different authoritative position.

8. **Freeze one authoritative landing-area snapshot**

   **Given** the execution reaches 0.40 elapsed seconds with a valid landing candidate
   **When** the tracking-to-locked transition commits
   **Then** one immutable `AbilitySpatialSnapshot` records the frozen support identity, landing center, surface normal, 2.50-metre radius, 3.0-metre height, boundary tolerance, target-sample identity, effect bounds, and current run
   **And** the landing center and impact volume stop consuming later target movement
   **And** the final 0.60-second windup and complete projectile flight use that same snapshot
   **And** no later movement, target death, source facing, AI decision, or presentation update may retarget it.

9. **Show the complete locked impact volume**

   **Given** the landing snapshot has locked
   **When** player-facing telegraph presentation observes it
   **Then** a non-color-only ground ring plus vertical wireframe or equivalent volume cue communicates the complete impact radius and height
   **And** the cue visibly changes from tracking to locked state and remains fixed until impact or cancellation
   **And** nearby cover, traversal geometry, the player silhouette, grapple reticle, and route cues remain readable
   **And** the marker consumes the exact authoritative snapshot used by impact delivery.

10. **Resolve one typed ballistic trajectory at launch**

    **Given** the final locked windup completes with a valid source and landing snapshot
    **When** launch preparation samples the source's authoritative payload socket
    **Then** one trajectory solver freezes the finite launch origin, locked landing endpoint, 1.50-second flight time, and downward acceleration vector
    **And** initial velocity equals the displacement to the endpoint minus one-half acceleration multiplied by squared flight time, divided by flight time
    **And** substituting the solved velocity into the trajectory equation at 1.50 seconds returns the locked landing endpoint within documented numerical tolerance
    **And** a non-finite solution or launch speed greater than 35.0 metres per second rejects launch without selecting a different duration, acceleration, or endpoint.

11. **Validate the complete payload corridor**

    **Given** a finite launch solution exists
    **When** its trajectory is validated before payload spawn
    **Then** a named clearance query covers the complete parabolic path using the configured 0.25-metre payload radius and documented curve-approximation tolerance
    **And** the path must remain inside authored projectile bounds and clear of eligible static blocking geometry
    **And** an obstructed, out-of-bounds, or invalid path cancels launch with a typed reason
    **And** the prototype does not secretly shorten the arc, pass through blocking geometry, detonate early, ricochet, or move the displayed landing area.

12. **Preview the authoritative arc**

    **Given** a valid provisional or locked landing point and current valid source origin exist during windup
    **When** trajectory presentation updates
    **Then** it displays a primitive sampled arc derived through the same trajectory contract used for launch validation
    **And** the locked interval clearly communicates the intended direction, apex, endpoint, and remaining launch time
    **And** the final committed payload path is frozen from its launch snapshot
    **And** final animation or source motion may not move the payload socket into disagreement with the committed launch origin.

13. **Commit one detached payload atomically**

    **Given** launch origin, trajectory, landing area, source snapshot, definitions, and current run are valid
    **When** the spawn transaction commits
    **Then** exactly one completely configured payload is attached beneath the current fixture runtime root rather than beneath the source node
    **And** it receives stable attribution, authoritative launch time, trajectory coefficients, flight duration, impact snapshot, source-death policy, immutable damage snapshot, and terminal guard before activation is published
    **And** the action owner records successful handoff without retaining authority over payload movement or delivery
    **And** spawn failure creates no payload, impact, consumed delivery, or hidden retry.

14. **Capture immutable source-side damage at launch**

    **Given** the payload's spawn transaction is preparing to commit
    **When** its damage behavior is resolved
    **Then** it stores one immutable source-side snapshot representing 12 damage and its stable source, execution, payload, definition, and run attribution
    **And** later source stat changes, state changes, death, removal, or scene-tree invalidation cannot change the snapshot
    **And** the payload never needs to dereference the source node to complete flight or damage delivery.

15. **Advance flight from authoritative elapsed time**

    **Given** the detached payload is active and has not reached impact time
    **When** simulation-owned elapsed flight time advances
    **Then** its authoritative position equals launch position plus solved initial velocity multiplied by elapsed time plus one-half configured acceleration multiplied by squared elapsed time
    **And** elapsed time is clamped to the interval from zero through 1.50 seconds
    **And** render interpolation may smooth between committed positions but cannot lead, lag, retarget, resize, or steer gameplay
    **And** animation curves, tweens, render delta, accumulated per-frame displacement, source movement, and target movement cannot control flight.

16. **Keep the travelling payload non-damaging**

    **Given** the payload is travelling before its committed impact time
    **When** the player, an enemy, a projectile, or presentation intersects its displayed path or primitive mesh
    **Then** no damage, knockback, collision, grapple target, detonation, or target redirection occurs
    **And** the prevalidated baseline path remains authoritative until impact
    **And** projectile interception, mid-flight body hits, ricochet, destructibility, and dynamic trajectory obstruction remain outside this story.

17. **Intensify the final impact warning**

    **Given** the payload has 0.30 seconds or less remaining before impact
    **When** presentation consumes the authoritative remaining flight time
    **Then** the landing volume provides a non-color-only pulse, contraction, vertical marker, countdown rhythm, or equivalent final-warning cue
    **And** the cue remains aligned with the same frozen center, radius, height, and impact time
    **And** the cue cannot accelerate, delay, repeat, enlarge, or deliver the impact.

18. **Land exactly once at the locked endpoint**

    **Given** a physics step reaches or crosses the 1.50-second impact boundary
    **When** payload flight resolves
    **Then** the authoritative payload position is set to the exact locked endpoint before delivery
    **And** one stable impact occurrence becomes due exactly once
    **And** bounded timing catch-up processes the boundary without skipping or duplicating impact
    **And** the payload cannot overshoot, continue below the surface, bounce, or create another impact on a later step.

19. **Deliver the frozen impact cylinder**

    **Given** the unique impact occurrence becomes due
    **When** authoritative delivery resolves
    **Then** one named cylinder query uses the frozen 2.50-metre radius, 3.0-metre height, landing transform, target profile, and current run
    **And** candidates are normalized, stably ordered, and deduplicated before damage delivery
    **And** each candidate is tested against the actual cylinder and declared physics-contact tolerance rather than center-point distance or the rendered marker alone
    **And** the visible landing volume and damaging space remain aligned within documented tolerances.

20. **Let eligible cover block impact damage**

    **Given** an eligible hurt volume overlaps the impact cylinder
    **When** named line-of-sight validation finds solid blocking geometry between the impact point and the accepted candidate impact point
    **Then** that candidate is rejected as protected by cover
    **And** other uncovered candidates remain independently eligible
    **And** the blocked result is observable without turning the instantaneous impact into a persistent hazard
    **And** cover policy uses gameplay collision queries rather than rendered visibility or material appearance.

21. **Apply impact damage no more than once per target**

    **Given** an eligible uncovered target intersects the impact cylinder
    **When** its unique delivery is accepted
    **Then** the stored source snapshot and current impact context produce one 12-damage result
    **And** duplicate hurtboxes, contact points, overlap callbacks, or candidate entries cannot damage that target more than once
    **And** the impact applies no knockback, tether, stun, movement modifier, lingering area, or repeated pulse
    **And** payload and delivery become terminal after the impact transaction completes.

22. **Apply source-death policy by commitment phase**

    **Given** the source dies or is removed before the payload spawn transaction commits
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** tracking or locked windup terminates, its cues are removed, and no payload or damage occurrence is created.

    **Given** the payload has committed with `PERSIST_AFTER_SOURCE`
    **When** the source dies or is removed
    **Then** flight, warning, impact, damage attribution, and cleanup continue from immutable payload state
    **And** the source node is not retained, reconstructed, or dereferenced
    **And** source death cannot redirect, accelerate, weaken, cancel, or duplicate the payload.

23. **Keep the locked world threat valid after target loss**

    **Given** the original target moves, dies, or becomes invalid after landing lock
    **When** the final windup, launch, flight, and impact occur
    **Then** the payload continues toward the frozen world position while the original target is no longer required
    **And** a dead or otherwise ineligible original target cannot receive damage
    **And** any other eligible target inside the impact cylinder is processed only according to the declared area-delivery policy
    **And** target loss before lock cancels if no valid target sample remains available.

24. **Preserve traversal and immediate recovery**

    **Given** the landing area has locked or the payload is in flight
    **When** the player runs, jumps, falls, grapples, releases, wall-runs, wall-sticks, or wall-jumps
    **Then** those systems remain controlled by their existing owners without input suppression, forced movement, grapple cancellation, or wall invalidation
    **And** leaving the radius laterally, reaching above the three-metre height, or using eligible cover produces a valid counter
    **And** a player who deliberately receives the impact retains ordinary movement and can use the fixture's authored recovery route
    **And** the five-second cadence provides a manually verified response interval before another bombardment can begin.

25. **Reject unresolved-payload stacking**

    **Given** the source already owns a tracking, locked, or travelling baseline bombardment
    **When** it requests another
    **Then** the later request is rejected without refreshing, retargeting, adding another marker, changing the trajectory, replacing attribution, or extending the first payload
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** the focused fixture permits only one unresolved bombardment at a time
    **And** volleys, clusters, overlapping impacts, and bombardment-plus-mine combinations remain outside this story.

26. **Clean up reset and scene exit correctly**

    **Given** the fixture resets, checkpoint reloads, or the scene exits during tracking, locked windup, launch, flight, final warning, impact, recovery, or cadence
    **When** the old run is invalidated
    **Then** executions, target samples, reservations, landing and trajectory snapshots, payloads, damage snapshots, impact occurrences, queries, accepted-hit history, cues, cadence state, and late callbacks are removed or rejected exactly once
    **And** no source-independent payload or impact can survive into the fresh run
    **And** the scenario can be repeated immediately without restarting the editor.

27. **Keep bombardment tuning configurable**

    **Given** an alternate valid definition changes tracking or lock duration, flight time, impact-warning duration, trajectory acceleration, payload radius, launch-speed limit, target range, support query, impact dimensions, damage, cadence, cover policy, overlap policy, or source-death policy
    **When** the same lifecycle, trajectory, payload, delivery, and presentation implementations consume it
    **Then** prediction, landing validation, trajectory solution, flight, warning, impact, diagnostics, and cleanup use the authored values without code changes
    **And** at least one alternate-profile test proves trajectory timing, acceleration, radius, height, and damage are not hard-coded
    **And** homing, physical mid-flight collision, projectile interception, destructibility, ricochet, dynamic obstruction, volleys, persistent impact hazards, aerial mines, and final presentation remain outside this story.

28. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, tracking, lock, launch validation, spawn, flight, final warning, impact, cover rejection, damage, source death, cancellation, or reset occurs
    **Then** primitive source cues, trajectory lines, payload geometry, landing rings and volumes, countdown emphasis, impact markers, and typed result displays communicate the mechanic
    **And** future animation, projectile meshes, particles, trails, impact VFX, audio, camera feedback, and materials can consume committed facts without controlling targeting, trajectory, timing, movement, or damage
    **And** diagnostics expose stable identities, lifecycle times, target samples, landing geometry, source origin, trajectory coefficients, solved velocity and speed, clearance results, authoritative and rendered payload positions, remaining time, impact candidates, cover results, damage results, source policy, run identity, and terminal reason.

29. **Make bombardment counterplay manually reproducible**

    **Given** the named arcing-bombardment fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can remain in the locked area and receive one impact, leave laterally after lock, reach above the impact height, use eligible cover, grapple away, wall-jump away, and continue moving through the predicted point to compare outcomes
    **And** they can observe tracking and lock, inspect the complete arc and final warning, test minimum and maximum range, force unsupported and obstructed trajectory rejection, kill the source before and after payload spawn, invalidate the original target after lock, test duplicate requests, reset during every lifecycle phase, and repeat the scenario
    **And** retained evidence distinguishes objective landing, trajectory, timing, source independence, affected-space, cover, damage, traversal, cleanup, and repeatability results from subjective observations about arc height, flight duration, warning clarity, radius, damage, cadence, and recovery time.

30. **Verify rate-independent source-independent delivery**

    **Given** the permanent arcing-bombardment suite and focused real-Jolt fixture run
    **When** they exercise valid and invalid target samples, support and bounds rejection, exact tracking and lock boundaries, trajectory solutions, launch-speed limits, clearance failures, source death before and after spawn, target loss, flight endpoints, impact-time boundaries, cylinder edges, vertical limits, cover, duplicate hurtboxes, stale runs, randomized callback order, and repeated reset
    **Then** each accepted launch creates exactly one detached payload, follows its frozen trajectory, reaches its locked endpoint, and delivers no more than one attributed impact result per eligible target
    **And** landing presentation, trajectory presentation, authoritative flight, and impact geometry remain aligned within documented tolerances
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time windup and flight durations, sampled trajectory positions, exact endpoint, impact count, damage, source independence, cadence, terminal results, and cleanup within documented tolerances
    **And** the story has not implemented homing, interception, dynamic collision, ricochet, multiple payloads, persistent impact hazards, aerial mines, ability combinations, or final presentation.
