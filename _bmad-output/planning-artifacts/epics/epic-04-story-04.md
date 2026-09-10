---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 4
---

# Story 4.4: Escape a Telegraph-First Drifting Damage Cloud

As a player,
I want a drifting damage cloud to clearly communicate its boundary, path, and pulse timing,
So that I can route around it, move above it, use cover, or time a crossing without receiving invisible continuous damage.

**Acceptance Criteria:**

1. **Declare the drifting-cloud gameplay question**

   **Given** the damage-cloud prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player reads a moving hazardous volume and chooses a safer route or a gap between damage pulses
   **And** its placement, shape, path, ramp-up, pulse cadence, counters, recovery, cover, grapple and wall interactions, source-death policy, overlap rule, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains a temporary damage volume rather than a visibility effect, poison status, or physical obstacle.

2. **Author one immutable cloud definition**

   **Given** the baseline drifting-cloud profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 1.0-second windup, 0.50-second non-damaging ramp-up, 6.0-second active lifetime, final 1.0-second expiry warning, 3.0-metre cylindrical radius, 3.0-metre height, and 2.0-metres-per-second drift speed
   **And** it declares global pulse times beginning at 0.50 active seconds and recurring every 1.0 second, a 0.20-second cue before each pulse, 4 damage per pulse, and a maximum of six pulses
   **And** it declares an 8.0-second start-to-next-start cadence, one unresolved cloud per source, static-floor placement, drift, blocking, damage, source-death, and presentation policies
   **And** these values remain authored configuration rather than literals in the effect, pulse scheduler, fixture, or presenter.

3. **Keep runtime state outside shared definitions**

   **Given** a cloud execution or occurrence is created
   **When** its state is inspected
   **Then** it records stable definition, execution, occurrence, source, target, and run identities; frozen start geometry and drift direction; current center; lifecycle times; pulse index and history; accepted targets per pulse; movement-block result; source snapshot; and terminal reason
   **And** it never mutates the shared ability, world-effect, damage, spatial, or presentation definitions
   **And** the action owner controls windup while the scoped world-effect owner controls the detached active cloud.

4. **Request the cloud through the normal action boundary**

   **Given** the source has a valid target and the fixture or AI requests a damage cloud
   **When** the request reaches its action owner
   **Then** the owner validates source and target, current action, range, line of sight, cadence, unresolved-cloud limit, current run, definitions, effect bounds, and required resident assets before committing one execution
   **And** AI and fixture controls cannot place or move the cloud, schedule pulses, perform damage queries, or advance lifecycle timing
   **And** rejected, duplicate, stale, and busy requests produce typed results without a partial preview or cloud.

5. **Resolve one static-floor starting position**

   **Given** the request reaches its placement-lock boundary
   **When** the target's current combat reference position is projected downward
   **Then** a named ground query must find static floor-like support within 12.0 metres whose normal is within 20 degrees of world up
   **And** the complete three-metre-radius footprint and three-metre height must fit within the fixture's authored effect bounds
   **And** the support identity, plane, center, cylinder dimensions, and tolerance are frozen in one authoritative spatial snapshot
   **And** unsupported, moving, steep, discontinuous, out-of-bounds, or non-finite placement is rejected with a typed reason.

6. **Freeze one horizontal drift direction**

   **Given** a valid starting center and source position exist
   **When** the cloud's path locks
   **Then** drift direction is the normalized source-to-start-center direction projected onto the world-up horizontal plane
   **And** later source or target movement cannot rotate, reverse, or retarget the path
   **And** a zero-length, non-finite, or otherwise invalid horizontal direction cancels placement rather than selecting a hidden fallback
   **And** the frozen direction and two-metres-per-second speed imply a maximum authored 12.0-metre displacement over the complete active lifetime.

7. **Preview the exact starting volume and path**

   **Given** the cloud execution is in its 1.0-second windup
   **When** primitive telegraph presentation observes the frozen spatial binding
   **Then** it displays the future three-metre-radius, three-metre-high starting cylinder, drift direction, and intended 12.0-metre path
   **And** the preview remains non-solid, non-damaging, non-occluding, and ineligible for grapple and wall queries
   **And** presentation consumes authoritative lifecycle and spatial facts rather than calculating another path or activation time.

8. **Create one fully attributed detached cloud**

   **Given** windup completes with a valid source and run
   **When** active execution begins
   **Then** one scoped cloud occurrence is configured and attached beneath the current runtime root before activation is published
   **And** it receives the frozen start geometry, drift vector, lifecycle schedule, stable identities, and one immutable source-side damage snapshot
   **And** the cloud can complete its approved active lifecycle without retaining the source node as damage or movement authority
   **And** spawn rejection terminates the execution without a hidden retry or partially active pulse schedule.

9. **Ramp up visibly before the first pulse**

   **Given** the cloud has entered its first 0.50 active seconds
   **When** simulation-owned ramp progress advances
   **Then** primitive presentation grows from a clearly non-damaging forming state to the complete authoritative cylinder
   **And** no damage query occurs before active elapsed time reaches 0.50 seconds
   **And** drift still advances from active start, so the first damaging volume is centered one metre along the declared path
   **And** the first 0.20-second pulse cue begins at 0.30 active seconds.

10. **Move from elapsed simulation time**

    **Given** the active cloud is not blocked or terminal
    **When** authoritative active elapsed time advances
    **Then** its intended center equals its frozen start center plus frozen drift direction multiplied by 2.0 metres per second and active elapsed seconds
    **And** its actual movement covers the complete translation between the previous and intended centers
    **And** neither render delta, particle motion, animation, accumulated frame displacement, source movement, nor target movement controls the cloud path.

11. **Stop safely at blocking world geometry**

    **Given** the cloud's intended horizontal translation intersects eligible static blocking geometry
    **When** its swept world-effect movement query resolves
    **Then** the center stops at the last valid transform before penetration and remains there for the rest of its active lifetime
    **And** the cloud does not pass through, climb, flow around, destroy, push, or deform the obstruction
    **And** its pulse schedule and expiry continue unchanged after stopping
    **And** presentation consumes the committed stopped position rather than continuing along the originally previewed path.

12. **Expire rather than leave authored bounds**

    **Given** the complete cloud cylinder would move outside its authored effect bounds
    **When** the next intended transform is validated
    **Then** the occurrence terminates early with a typed `LEFT_EFFECT_BOUNDS` reason
    **And** it is not clamped, wrapped, reflected, teleported, or allowed to pulse partly outside the permitted space
    **And** no later pulse from that occurrence may execute.

13. **Schedule pulses globally for the occurrence**

    **Given** an active cloud has a valid pulse schedule
    **When** active elapsed time reaches 0.50, 1.50, 2.50, 3.50, 4.50, and 5.50 seconds
    **Then** exactly one new stable pulse occurrence becomes due at each time
    **And** entry, exit, re-entry, source removal, render timing, or target identity cannot restart or offset that schedule
    **And** a physics step that crosses a due boundary processes that pulse exactly once using bounded ordered catch-up rather than skipping or duplicating it.

14. **Warn before every damaging pulse**

    **Given** the next pulse is 0.20 seconds away
    **When** the pulse-warning boundary is crossed
    **Then** the cloud's primitive volume displays an unambiguous contraction, flash, boundary emphasis, or equivalent non-text timing cue
    **And** the cue is driven by the authoritative next-pulse time
    **And** the cue cannot itself deal damage or alter the query volume
    **And** missing final VFX or audio does not remove the primitive pulse warning.

15. **Query the current cylinder at pulse time**

    **Given** a pulse becomes due
    **When** its authoritative delivery resolves
    **Then** one cylinder-shaped overlap query uses the cloud's committed center, three-metre radius, three-metre height, current run, and named damage profile
    **And** eligible candidates are normalized, stably ordered, and deduplicated
    **And** each candidate is evaluated against the current pulse occurrence rather than the complete cloud lifetime
    **And** no continuous per-frame or entry-trigger damage occurs between pulses.

16. **Let solid cover block a pulse**

    **Given** the pulse volume overlaps the player's eligible hurt volume
    **When** named line-of-sight validation finds solid blocking geometry between the cloud center and the accepted impact point
    **Then** that candidate is rejected as protected by cover and receives no damage from the pulse
    **And** other uncovered candidates remain independently eligible
    **And** the block result is observable without making the cloud a physical collider.

17. **Apply each pulse once per target**

    **Given** an eligible uncovered target is inside the cylinder when a pulse resolves
    **When** its unique delivery is accepted
    **Then** the stored source-side snapshot and current impact context produce one four-damage result
    **And** duplicate hurtboxes, overlap callbacks, or query candidates cannot damage that target more than once for that pulse
    **And** a target may receive damage again only from a later authored pulse occurrence
    **And** remaining inside for all six pulses produces no more than 24 total baseline damage.

18. **Make entry and exit timing meaningful**

    **Given** the player enters immediately after a pulse
    **When** they leave before the next scheduled pulse
    **Then** they receive no damage merely for entering or crossing the volume.

    **Given** the player is inside at the next pulse boundary
    **When** the authoritative cylinder query resolves
    **Then** they may receive that pulse regardless of how recently they entered
    **And** leaving immediately removes exposure without a delayed poison tick or retained target timer.

19. **Apply no lingering movement or visibility effect**

    **Given** the player is inside or leaves the cloud
    **When** movement, perception, grapple, and presentation systems evaluate their state
    **Then** the cloud applies no speed change, acceleration, knockback, tether, input suppression, wall restriction, targetability change, screen-wide blind, or post-exit status
    **And** its transparent primitive presentation preserves enough nearby geometry, enemy silhouette, grapple feedback, and route information for informed play
    **And** the dedicated visibility-obstruction mechanic remains outside this story.

20. **Preserve grapple and wall traversal**

    **Given** grappleable geometry or valid walls lie inside, above, beside, or beyond the cloud
    **When** the player targets or uses them
    **Then** the non-solid cloud neither intercepts grapple queries nor changes target response
    **And** grappling above the three-metre height, crossing quickly between pulses, and using the fixture's elevated wall route remain viable counters
    **And** wall-running, wall-sticking, wall-jumping, grapple release, and maximum-distance behavior retain their existing ownership.

21. **Provide immediate recovery after a pulse**

    **Given** the player receives one cloud pulse
    **When** damage commits
    **Then** movement and traversal remain available without stun or forced reaction
    **And** the player can leave before the next one-second pulse or reach cover through an authored recovery route
    **And** the cloud cannot apply another hit until the next globally scheduled pulse.

22. **Prevent unresolved-cloud stacking**

    **Given** the source already owns a windup or active baseline cloud
    **When** it requests another
    **Then** the later request is rejected without refreshing, relocating, merging, enlarging, or adding pulses to the existing occurrence
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** the focused fixture does not permit overlapping clouds from different sources; that overlap remains reserved for later combination testing.

23. **Apply source-death policy by lifecycle phase**

    **Given** the source dies or is removed during windup before cloud creation
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** the preview cancels and no cloud or pulse becomes active.

    **Given** the cloud has spawned with its approved `PERSIST_AFTER_SOURCE` policy
    **When** the source dies or is removed
    **Then** the cloud continues its frozen path, pulses, attribution, and expiry using its immutable source snapshot without dereferencing the source node
    **And** source death cannot refresh or otherwise modify the cloud.

24. **Clean up death and reset correctly**

    **Given** the player dies inside the cloud
    **When** later pulses evaluate candidates
    **Then** the dead player is ineligible and no additional damage is applied.

    **Given** the fixture resets, checkpoint reloads, or the scene exits during windup, ramp-up, drift, pulse warning, pulse delivery, stopped movement, or expiry
    **When** the old run is invalidated
    **Then** execution, cloud, pulse schedule, due deliveries, source snapshot, presentation, cooldown state, and late callbacks are removed or rejected exactly once
    **And** no pulse may survive into the fresh run.

25. **Keep cloud tuning configurable**

    **Given** an alternate valid definition changes windup, ramp-up, lifetime, warning time, cylinder dimensions, drift speed or direction policy, pulse start, interval, warning, count, damage, cadence, blocking response, or source-death policy
    **When** the same lifecycle, world-effect, and pulse-delivery implementation consume it
    **Then** placement, path, movement, presentation, pulse schedule, damage, diagnostics, and cleanup use the authored values without code changes
    **And** at least one alternate-profile test proves geometry, drift, and pulse timing are not hard-coded
    **And** arbitrary volume shapes, fluid simulation, spreading, homing, poison, lingering statuses, visibility obstruction, overlapping clouds, and terrain interaction remain outside this story.

26. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** placement, windup, ramp-up, drift, obstruction, pulse warning, damage, expiry, source death, or reset occurs
    **Then** primitive cylinders, path lines, direction arrows, boundary emphasis, pulse cues, state changes, and impact markers communicate the hazard
    **And** future particles, fog materials, animation, audio, camera, and VFX can consume committed facts without controlling movement, pulse timing, or damage
    **And** diagnostics expose definition, execution, occurrence, source, target, pulse, and run identities; start and current geometry; drift vector and intended displacement; block result; lifecycle and next-pulse times; pulse index; candidates; cover results; damage results; source policy; and terminal reason.

27. **Make cloud counterplay manually reproducible**

    **Given** the named drifting-cloud fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can leave during windup, route around the cloud, grapple above it, use the elevated wall route, shelter behind cover, cross between pulses, deliberately remain for one pulse, and leave before the next
    **And** they can remain through all pulses to verify the maximum count, enter immediately before and after a pulse, cross the radius and height boundaries, observe drift, block its path, force bounds expiry, kill the source before and after spawn, reset during every lifecycle phase, and repeat the scenario
    **And** the procedure distinguishes objective volume, movement, cadence, damage, cover, traversal, source independence, and cleanup results from subjective observations about size, speed, pulse timing, warning, opacity, and duration.

28. **Verify rate-independent drifting pulses**

    **Given** the permanent drifting-cloud suite and focused real-Jolt fixture run
    **When** they exercise valid and invalid placement, exact ramp and pulse boundaries, high-speed entry and exit, radius and height edges, drift obstruction, effect bounds, cover, duplicate hurtboxes, repeated pulse eligibility, source death before and after spawn, target death, stale runs, randomized callback order, and repeated reset
    **Then** every accepted cloud follows one frozen path, creates only its declared pulse occurrences, damages each target no more than once per pulse, and terminates exactly once
    **And** warning and current damaging volume remain aligned within documented tolerances
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time windup, ramp, drift position, pulse times and count, damage results, cadence, source independence, and cleanup within documented tolerances
    **And** the story has not implemented poison, visibility obstruction, fluid behavior, overlapping hazards, ability combinations, or final presentation.
