---
artifact_schema: 1
artifact_id: 'grapplegame.story.5.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 5
story: 3
---

# Story 5.3: Navigate a Telegraph-First Aerial Mine Lattice

As a player,
I want an aerial mine lattice to reveal its positions, trigger regions, and safe gaps before becoming dangerous,
So that I can choose a lateral or altitude route and recover after triggering a mine.

**Acceptance Criteria:**

1. **Declare the aerial-lattice gameplay question**

   **Given** the airburst-and-mine-lattice prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player reads persistent aerial danger and chooses a central gap, lateral route, altitude change, grapple route, wall route, or deliberate trigger-and-escape response
   **And** its targeting, lattice geometry, tracking and lock timing, arming, triggering, detonation, counters, recovery, grapple and wall interactions, source-death policy, overlap policy, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one stationary four-mine lattice rather than a moving minefield, projectile volley, or encounter-scale spawning system.

2. **Author one immutable lattice definition**

   **Given** the baseline aerial-lattice profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 1.0-second windup containing a 0.40-second tracking interval and final 0.60-second locked interval
   **And** it declares four mine offsets at negative-three and positive-three horizontal metres combined with negative-two and positive-two vertical metres in the lattice plane
   **And** it declares a 0.75-second arming duration, 8.0-second armed lifetime, final 1.0-second expiry warning, 1.50-metre trigger radius, 0.35-second triggered warning, 2.0-metre blast radius, 10 damage, and 0.75-second per-recipient lattice recovery interval
   **And** it declares an 8.0-to-25.0-metre source-to-center range, center height from 4.0 through 12.0 metres above eligible support, 10.0-second start-to-next-start cadence, four-mine maximum, and one unresolved lattice per source
   **And** it declares `CANCEL_WITH_SOURCE` before atomic mine creation and `PERSIST_AFTER_SOURCE` afterward
   **And** these values remain authored configuration rather than literals in the action, lattice builder, mine, fixture, or presenter.

3. **Keep execution, lattice, and mine state outside definitions**

   **Given** a lattice execution or mine occurrence exists
   **When** its runtime state is inspected
   **Then** it records stable definition, execution, source, target, lattice, mine, trigger, detonation, damage, recipient, and run identities; lifecycle times; frozen basis and positions; mine phases; accepted deliveries; recipient recovery times; source policy; and terminal reasons
   **And** no occurrence mutates the shared ability, mine, spatial, damage, grapple, or presentation definitions
   **And** the action owner controls tracking and windup, the lattice occurrence coordinates shared state, and each detached mine owns its arming, triggering, detonation, and terminal state.

4. **Request the lattice through the normal action boundary**

   **Given** the fixture or flying AI requests an aerial mine lattice
   **When** the request reaches its action owner
   **Then** the owner validates source and target identity, action state, minimum and maximum range, line of sight, target altitude, cadence, unresolved-lattice limit, run identity, definitions, effect bounds, and required resident assets before committing one execution
   **And** the flying AI may request the action from an existing valid tactical position but cannot calculate mine positions, spawn mines, detect triggers, schedule detonations, or apply damage
   **And** rejected, duplicate, busy, invalid, and stale requests produce typed results without a partial preview or mine.

5. **Sample one bounded aerial target position**

   **Given** the execution is within its tracking interval
   **When** an authoritative target sample is accepted
   **Then** it records stable target and run identities, finite combat reference position, finite velocity, alive and eligibility state, and physics-step identity
   **And** the candidate lattice center equals the current sampled combat reference position without predicting future input or motion
   **And** a named downward query must find eligible static support beneath it and measure center height from that support
   **And** a center below 4.0 metres, above 12.0 metres, outside effect bounds, unsupported, stale, or non-finite is rejected rather than silently clamped to an allowed altitude.

6. **Construct one deterministic lattice basis**

   **Given** a valid source position and candidate center exist
   **When** the lattice orientation is calculated
   **Then** its forward axis is the normalized horizontal source-to-center direction
   **And** its right axis is the stable horizontal perpendicular derived from world up and forward
   **And** its vertical axis is world up
   **And** zero-length, nearly vertical, ambiguous, or non-finite source-to-center direction returns a typed failure
   **And** source facing, animation orientation, camera direction, and scene-tree transforms cannot provide a fallback basis.

7. **Resolve exactly four candidate mine positions**

   **Given** a valid lattice center and basis exist
   **When** the immutable offset list is transformed into world space
   **Then** exactly four candidate positions are produced at the combinations of negative-three and positive-three metres along the right axis and negative-two and positive-two metres along world up
   **And** every candidate records its stable offset index and world position
   **And** all trigger and blast spheres must fit within authored effect bounds, remain sufficiently above support, and avoid prohibited or static blocking geometry
   **And** one invalid candidate rejects the complete lattice rather than deleting, relocating, or replacing only that mine.

8. **Track only during the declared interval**

   **Given** the execution is within its first 0.40 seconds
   **When** valid target samples and complete candidate lattices are accepted
   **Then** the provisional center, basis, and four positions may update from the newest accepted sample
   **And** primitive low-intensity mine, trigger, blast, and connecting-lattice previews communicate that tracking remains active
   **And** updates occur only through simulation-owned sampling and validation
   **And** presentation cannot predict, smooth, or substitute a different lattice.

9. **Freeze one complete lattice snapshot**

   **Given** tracking reaches 0.40 seconds with four valid candidates
   **When** the tracking-to-locked transition commits
   **Then** one immutable `AbilitySpatialSnapshot` records the center, basis, ordered offsets, four mine positions, trigger and blast radii, support reference, effect bounds, target-sample identity, and current run
   **And** the complete lattice stops consuming later target or source movement
   **And** the final 0.60-second windup uses that same snapshot
   **And** no later movement, target loss, source facing, AI decision, or presentation update may translate, rotate, resize, or reorder the lattice.

10. **Preview every future hazard and safe gap**

    **Given** a provisional or locked lattice snapshot exists
    **When** player-facing telegraph presentation observes it
    **Then** it displays all four mine centers, their trigger spheres, their larger blast spheres, and the lattice plane
    **And** the locked presentation clearly exposes the central opening plus available routes around, above, and below the complete lattice
    **And** tracked and locked states remain distinguishable through non-color-only cues
    **And** no mine collision, trigger query, damage, or grapple response is active during windup.

11. **Create the complete lattice atomically**

    **Given** locked windup completes with a valid source, snapshot, definitions, and current run
    **When** the harmless airburst creation transaction commits
    **Then** exactly four completely configured mine occurrences and one lattice coordinator are attached beneath the current fixture runtime root rather than beneath the source node
    **And** each mine receives its ordered identity, frozen position, lifecycle schedule, spatial profiles, damage definition, source policy, lattice identity, and terminal guard before any mine becomes observable
    **And** the central airburst event applies no damage, movement, collision, or status
    **And** any configuration or spawn failure rolls back the complete batch without leaving a partial lattice or hidden retry.

12. **Keep spawned mines stationary and source-independent**

    **Given** the four-mine batch has committed
    **When** source, target, camera, or surrounding actors move
    **Then** every mine remains at its frozen world position for its remaining lifecycle
    **And** mines do not follow, home, orbit, fall, drift, rotate the lattice, or reconstruct target motion
    **And** their lifecycle and attribution continue without dereferencing the source or original target
    **And** presentation may animate a mine locally without moving its authoritative trigger or blast center.

13. **Provide a non-damaging arming interval**

    **Given** a mine has spawned into its 0.75-second arming phase
    **When** the player intersects its trigger or blast sphere
    **Then** the mine remains non-damaging and cannot enter its triggered phase before arming completes
    **And** its primitive core, trigger boundary, and arming progress clearly distinguish it from an armed mine
    **And** the mine remains non-solid and cannot push, block, attach to, or alter the player
    **And** arming duration derives from simulation time rather than render frames or animation.

14. **Evaluate existing occupancy when arming completes**

    **Given** an eligible player remains inside a mine's trigger sphere at the arming boundary
    **When** the mine becomes armed
    **Then** that mine enters its triggered phase exactly once on the first eligible query step
    **And** the player receives the complete 0.35-second triggered warning before detonation
    **And** activation does not cause an immediate hidden explosion, direct damage, displacement, or repeated trigger
    **And** a player outside the trigger sphere leaves the mine armed and waiting.

15. **Detect high-speed trigger crossings**

    **Given** an armed mine has previous and current authoritative player hurt-volume states
    **When** the player moves through or into its 1.50-metre trigger sphere during a physics step
    **Then** a named swept trigger query evaluates the complete motion interval rather than only the final position
    **And** the earliest eligible intersection time and contact facts are recorded
    **And** duplicate hurtboxes and query candidates are normalized and deduplicated
    **And** equivalent supported motion cannot tunnel through a mine at 60 Hz while triggering it at 120 Hz.

16. **Enter the triggered phase only once**

    **Given** an armed mine accepts its first eligible trigger occurrence
    **When** its phase transition commits
    **Then** it freezes a detonation time exactly 0.35 seconds later and retains its original mine center
    **And** leaving the trigger sphere, changing altitude, killing the source, or touching it again cannot cancel, delay, accelerate, relocate, or duplicate that detonation
    **And** later trigger callbacks are ignored with an observable already-triggered result
    **And** the mine remains non-damaging until the committed detonation boundary.

17. **Warn throughout the triggered interval**

    **Given** a mine is triggered and not terminal
    **When** its remaining detonation time is presented
    **Then** its core, complete two-metre blast sphere, and countdown state provide a clear non-color-only warning
    **And** the warning distinguishes the triggering mine from armed and expiring neighboring mines
    **And** presentation consumes the authoritative mine center and detonation time
    **And** the player can leave the blast sphere laterally or vertically before delivery.

18. **Resolve simultaneous triggers deterministically**

    **Given** one player motion interval intersects multiple armed trigger spheres
    **When** the lattice processes their trigger results
    **Then** candidates are ordered by earliest swept intersection time and stable mine identity
    **And** every uniquely intersected mine may enter its own triggered phase exactly once
    **And** callback, shape, node, and mine-registration order cannot alter the resulting triggered set or detonation times
    **And** no mine is silently deleted merely because another mine triggered first.

19. **Detonate at the fixed mine center**

    **Given** a triggered mine reaches or crosses its committed detonation boundary before expiry
    **When** lifecycle resolution processes the boundary
    **Then** one stable detonation occurrence becomes due exactly once at the frozen mine center
    **And** bounded timing catch-up cannot skip or duplicate it
    **And** the mine cannot chase the triggering player, enlarge its sphere, move toward a current position, or remain active after its terminal detonation
    **And** the mine's own explosion cannot trigger another mine.

20. **Query one spherical blast**

    **Given** a unique mine detonation becomes due
    **When** authoritative delivery resolves
    **Then** one named spherical query uses the frozen center, two-metre radius, eligible target profile, and current run
    **And** candidates are normalized, stably ordered, and deduplicated
    **And** contact inclusion uses the declared physics-shape and tolerance policy rather than rendered size or center-point distance alone
    **And** the visible triggered sphere and authoritative blast remain aligned within documented tolerances.

21. **Let eligible cover block mine damage**

    **Given** an eligible hurt volume intersects the blast sphere
    **When** named line-of-sight validation finds solid blocking geometry between the mine center and the accepted impact point
    **Then** that candidate is rejected as protected by cover
    **And** other uncovered candidates remain independently eligible
    **And** the blocked result is observable
    **And** cover neither prevents the mine from becoming terminal nor causes a chain reaction.

22. **Apply each mine's damage once**

    **Given** an eligible uncovered target intersects a mine's blast sphere
    **When** its delivery passes the lattice recovery policy
    **Then** the immutable source snapshot and current impact context produce one 10-damage result
    **And** the same mine cannot damage that target again through duplicate hurtboxes, callbacks, candidate entries, or delayed cleanup
    **And** the blast applies no knockback, tether, stun, movement modifier, lingering volume, or repeated pulse
    **And** accepted or rejected delivery leaves that mine terminal exactly once.

23. **Provide lattice-scoped recovery between hits**

    **Given** a target has accepted damage from one mine in the lattice
    **When** another mine attempts damage less than 0.75 seconds later
    **Then** the later damage is rejected by a recipient-and-lattice recovery record without granting global invulnerability
    **And** the later mine still completes its detonation and becomes terminal
    **And** other unrelated enemy damage remains governed by its existing rules
    **And** a mine detonation at or after the recovery boundary may damage the target normally.

24. **Expire every remaining mine harmlessly**

    **Given** an armed or triggered mine reaches the end of the eight-second armed lifetime
    **When** terminal lifecycle precedence resolves
    **Then** expiry wins over an equal-time or later pending detonation and the mine terminates without damage
    **And** armed mines visibly communicate the final one-second expiry interval
    **And** expiry removes the mine's trigger, pending delivery, presentation, and runtime references exactly once
    **And** one mine's expiry does not refresh, detonate, or otherwise change another mine.

25. **Preserve lateral and altitude routes**

    **Given** the complete lattice is locked, arming, or armed
    **When** the player evaluates its geometry
    **Then** the central gap and at least one route around either horizontal side remain outside every trigger sphere
    **And** at least one route above or below remains reachable within the fixture's authored traversal space
    **And** the player can deliberately trigger one mine and escape its larger blast sphere during the 0.35-second warning
    **And** the lattice does not silently reposition to close a route after lock.

26. **Preserve grapple and wall traversal**

    **Given** valid anchors and wall routes lie near, across, above, or below the lattice
    **When** the player uses them
    **Then** acquisition, attachment, pull, release, maximum-distance behavior, wall-running, wall-sticking, and wall-jumping retain their existing owners
    **And** mines and their previews do not occlude valid grapple queries
    **And** grappling through the central gap, changing altitude, releasing around a mine, and using the fixture's wall route remain manually demonstrable responses
    **And** the lattice cannot suppress input, force release, change velocity, or invalidate an ordinary wall.

27. **Make mines explicitly non-solid and non-grappleable**

    **Given** the player collides with, aims at, attacks, or passes through a mine's primitive representation
    **When** collision, grapple, attack, and target queries resolve
    **Then** the mine creates no solid-body collision and returns an explicit non-grappleable-hazard response
    **And** rejected grapple feedback remains readable without selecting an anchor behind the crosshair incorrectly
    **And** ordinary player attacks do not destroy, push, disarm, or prematurely detonate the mine
    **And** destructible mines, grappleable mines, projectile interception, and player-triggered chain reactions remain outside this story.

28. **Apply source and target loss policies explicitly**

    **Given** the source dies or is removed before atomic mine creation
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** tracking or locked windup terminates and no mine becomes active.

    **Given** the mine batch has committed with `PERSIST_AFTER_SOURCE`
    **When** the source dies or is removed
    **Then** every mine continues its own arming, triggering, detonation, damage attribution, expiry, and cleanup without dereferencing the source node.

    **Given** the original target moves, dies, or becomes invalid after lattice lock
    **When** windup completes
    **Then** the airburst still creates the frozen world-space lattice while the invalid original target remains ineligible for damage
    **And** target loss before lock cancels if no valid target sample remains.

29. **Reject unresolved-lattice stacking**

    **Given** the source already owns a tracking, locked, arming, armed, or triggered baseline lattice
    **When** it requests another
    **Then** the later request is rejected without refreshing, relocating, adding mines, replacing attribution, or extending any mine
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** the focused fixture permits only one unresolved lattice
    **And** overlapping lattices, mine waves, respawning mines, and mine-plus-wind combinations remain outside this story.

30. **Clean up reset and scene exit correctly**

    **Given** the fixture resets, checkpoint reloads, or the scene exits during tracking, locked windup, atomic creation, arming, armed waiting, triggering, detonation, recipient recovery, or expiry
    **When** the old run is invalidated
    **Then** executions, reservations, snapshots, lattice coordinators, all four mines, trigger queries, pending detonations, damage snapshots, recipient recovery records, presentations, cadence state, and late callbacks are removed or rejected exactly once
    **And** no mine, damage, or recovery record survives into the fresh run
    **And** the scenario can be repeated immediately without restarting the editor.

31. **Keep lattice behavior configurable**

    **Given** an alternate valid definition changes tracking or lock timing, ordered mine offsets, mine count up to the authored maximum, arming duration, armed lifetime, expiry warning, trigger radius, triggered warning, blast radius, damage, recipient recovery, placement range or height, cover policy, cadence, overlap policy, or source-death policy
    **When** the same action, lattice builder, mine, delivery, and presentation implementations consume it
    **Then** preview, validation, creation, lifecycle, triggering, damage, diagnostics, and cleanup use the authored values without code changes
    **And** at least one alternate-profile test proves geometry, mine count, timing, trigger radius, and blast radius are not hard-coded
    **And** moving, homing, destructible, grappleable, respawning, or chain-reacting mines; projectile volleys; arbitrary procedural fields; and final presentation remain outside this story.

32. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, tracking, lock, airburst creation, arming, armed waiting, triggering, warning, detonation, cover rejection, damage, recovery rejection, expiry, source death, cancellation, or reset occurs
    **Then** primitive mine cores, trigger and blast spheres, lattice lines, phase changes, countdown cues, impact markers, and typed result displays communicate the mechanic
    **And** future models, animation, particles, trails, explosion VFX, audio, camera feedback, and materials can consume committed facts without controlling placement, lifecycle, triggers, or damage
    **And** diagnostics expose stable identities, target samples, lattice center and basis, ordered offsets and mine positions, validation results, lifecycle times, mine phase, swept trigger results, detonation time, blast candidates, cover results, damage results, recipient recovery state, source policy, run identity, and terminal reason.

33. **Make aerial-lattice counterplay manually reproducible**

    **Given** the named aerial-mine-lattice fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can traverse the central gap, pass around both horizontal sides, move above and below the lattice, grapple through or around it, use the wall route, deliberately trigger one mine and escape, and deliberately remain for one accepted hit
    **And** they can occupy a trigger sphere during arming, cross a trigger at high speed, leave after triggering, use cover, trigger multiple mines together, test lattice recovery, observe harmless expiry including a near-expiry trigger, aim and attack a mine, and verify its explicit grapple rejection
    **And** they can test invalid altitude and geometry, kill the source before and after creation, invalidate the original target after lock, request duplicates, reset during every lifecycle phase, and repeat the scenario
    **And** retained evidence distinguishes objective lattice geometry, safe routes, lifecycle, triggering, damage, recovery, traversal, source independence, cleanup, and repeatability results from subjective observations about density, gap size, warning clarity, persistence, damage, and route difficulty.

34. **Verify rate-independent mine lifecycle and delivery**

    **Given** the permanent aerial-lattice suite and focused real-Jolt fixture run
    **When** they exercise valid and invalid centers, basis construction, ordered offsets, atomic batch failure, exact tracking and lock boundaries, arming occupancy, trigger-sphere boundaries, high-speed crossings, simultaneous triggers, triggered warnings, blast boundaries, cover, recipient recovery, source death before and after spawn, target loss, exact expiry precedence, stale runs, randomized callback order, and repeated reset
    **Then** every accepted execution creates exactly four attributed stationary mines, every mine follows one valid lifecycle to one terminal result, and each detonation delivers no more than one result per eligible target
    **And** incomplete batches, missed high-speed triggers, chain reactions, stale mines, and post-expiry damage never occur
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve tracking, lock, arming, triggered-warning, detonation, recipient-recovery and expiry timing; trigger and blast results; damage; source independence; cadence; and cleanup within documented tolerances
    **And** the story has not implemented moving, homing, destructible, grappleable, respawning, or chain-reacting mines, overlapping lattices, wind combinations, production enemy allocation, or final presentation.
