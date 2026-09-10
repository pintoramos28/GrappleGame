---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 6
---

# Story 4.6: Preserve Control in a Directional Wind Field

As a player,
I want a wind field to show where and how it will push me while leaving my traversal controls available,
So that I can cross, escape, counter, or exploit it without suffering hidden velocity changes.

**Acceptance Criteria:**

1. **Declare the directional-field gameplay question**

   **Given** the directional-wind prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player reads a temporary directional force and preserves a useful route or deliberately exploits the resulting momentum
   **And** its placement, volume, direction, windup, duration, force response, counters, recovery, grapple and wall interactions, source-death policy, overlap policy, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains a movement-pressure mechanic rather than damage, knockback, input suppression, or a control-lock effect.

2. **Author one immutable wind definition**

   **Given** the baseline directional-wind profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 12.0-metre-long, 6.0-metre-wide, and 5.0-metre-high oriented box; a 0.75-second windup; a 5.0-second active duration; and a final 1.0-second expiry warning
   **And** it declares 12.0 metres per second squared of horizontal downwind acceleration, a 10.0-metres-per-second downwind target component, an 8.0-second start-to-next-start cadence, `CANCEL_WITH_SOURCE`, and a maximum of one unresolved field per source
   **And** these values and policies remain authored configuration rather than literals in the action, world effect, motor integration, fixture, or presenter.

3. **Keep occurrence state outside shared definitions**

   **Given** a directional-field execution or occurrence is created
   **When** its runtime state is inspected
   **Then** it records stable definition, execution, occurrence, source, target, field, and run identities; frozen placement and orientation; lifecycle times; affected-recipient submissions; source policy; and terminal reason
   **And** it never mutates the shared ability, field, movement, spatial-query, or presentation definitions
   **And** the action owner controls windup, the scoped world effect owns active field state, and the player motor remains the sole movement authority.

4. **Request the field through the normal action boundary**

   **Given** the fixture or AI requests the directional-wind ability
   **When** the request reaches its action owner
   **Then** the owner validates source and target, current action, targeting range, line of sight, cadence, unresolved-field limit, run identity, definition validity, effect bounds, and required resident assets before committing one execution
   **And** AI and fixture controls cannot place the field, advance its lifecycle, determine field membership, submit motor acceleration, or alter player velocity directly
   **And** rejected, duplicate, busy, invalid, and stale requests produce typed results without a partial field.

5. **Resolve one supported world-frozen placement**

   **Given** the request reaches its placement-lock boundary
   **When** the target's current combat reference position is projected downward
   **Then** a named support query must find static floor-like geometry within 12.0 metres whose normal is within 20 degrees of world up
   **And** the complete oriented field volume must fit within the fixture's authored effect bounds
   **And** the support identity, base point, reference plane, dimensions, and permitted tolerances are frozen in one authoritative spatial snapshot
   **And** unsupported, moving, steep, out-of-bounds, or non-finite placement is rejected with a typed reason.

6. **Freeze one horizontal push direction**

   **Given** valid source and target reference positions exist at placement lock
   **When** field orientation is resolved
   **Then** push direction is the normalized source-to-target direction projected onto the world-up horizontal plane
   **And** the field's length axis is aligned to that direction while its width axis is the corresponding horizontal perpendicular
   **And** later source or target movement cannot rotate, translate, reverse, or retarget the field
   **And** a zero-length or non-finite horizontal direction rejects placement rather than selecting a hidden fallback.

7. **Preview the exact future field**

   **Given** the execution is in its 0.75-second windup
   **When** primitive telegraph presentation observes the frozen spatial snapshot
   **Then** it displays the complete future box, its downwind direction, its activation timing, and at least two readable lateral exits
   **And** repeated arrows, flow lines, or equivalent non-color-only cues distinguish the upwind and downwind sides
   **And** the preview remains non-solid, non-damaging, non-occluding, and unable to influence movement
   **And** presentation consumes the authoritative snapshot rather than calculating another field or direction.

8. **Create one completely configured active field**

   **Given** windup completes with a valid source and current run
   **When** active execution begins
   **Then** one scoped directional-field occurrence is attached beneath the current runtime root before activation is published
   **And** it receives the frozen geometry, push direction, lifecycle schedule, source policy, immutable definition, and stable identities
   **And** activation failure terminates the execution without a hidden retry, partial region, or movement submission.

9. **Determine membership through an authoritative spatial query**

   **Given** the field is active and an eligible player movement recipient exists
   **When** sustained external effects are collected for a physics step
   **Then** a named oriented-box query determines whether the player's authoritative movement reference point is inside the active volume
   **And** the same frozen transform, dimensions, boundary tolerance, current run, and recipient profile are used at 60 Hz and 120 Hz
   **And** render overlap, particles, visibility, scene-tree order, and `Area3D` signal timing cannot independently establish membership
   **And** enemies, projectiles, rigid bodies, dead players, stale-run players, and presentation objects remain ineligible in this focused prototype.

10. **Respect partial lifecycle steps**

    **Given** a physics step crosses the field's activation or expiry time
    **When** active exposure time for that step is calculated
    **Then** the wind contribution uses only the portion of simulation time during which the field is active
    **And** activation cannot grant a full-step early contribution or expiry grant a full-step late contribution
    **And** each occurrence-recipient-step identity can submit no more than once.

11. **Submit a sustained semantic motor influence**

    **Given** the player is eligible and inside the active field
    **When** external effects submit their current physics-step influences
    **Then** the field submits one stable sustained-acceleration influence through the motor's sustained-influence phase
    **And** the submission carries occurrence, source, recipient, field direction, acceleration, target component, effective active time, and run identity
    **And** neither the field, action, AI, fixture, presentation, nor collision volume writes `CharacterBody3D.velocity` or calls movement directly.

12. **Limit only the wind's own velocity contribution**

    **Given** the sustained-influence phase begins with authoritative phase-entry velocity
    **When** the active field resolves its contribution
    **Then** it samples the downwind component of that phase-entry velocity before any sustained influence is applied
    **And** its permitted downwind velocity change equals the smaller of 12.0 metres per second squared multiplied by effective active time and the positive difference between 10.0 metres per second and the sampled component
    **And** a sampled component at or above 10.0 metres per second produces zero wind contribution
    **And** every directional target influence uses the same phase-entry sample so registration or resolution order cannot change the result.

13. **Do not cap or brake total player velocity**

    **Given** the wind's permitted velocity contribution has been calculated
    **When** the motor aggregates sustained influences
    **Then** it combines that contribution with grapple pull, attack movement, and other approved influences under the motor's fixed aggregation rules
    **And** those combined influences may produce a downwind component greater than 10.0 metres per second
    **And** existing momentum above 10.0 metres per second is not reduced by the field
    **And** only the motor's existing constraints, collision response, and safety caps may subsequently limit or redirect the combined velocity
    **And** diagnostics expose the phase-entry component, permitted wind contribution, other sustained contributions, combined result, and any later constraint or cap.

14. **Apply and remove influence at the field boundary**

    **Given** the player begins an eligible step outside the active field
    **When** membership resolves
    **Then** no wind influence is submitted for that sampled exposure.

    **Given** the player enters or is already inside during active use
    **When** the next eligible sustained-influence phase resolves
    **Then** wind acceleration begins without an entry impulse, velocity replacement, or per-recipient timer.

    **Given** the player exits and later re-enters during the same active occurrence
    **When** membership resolves on each step
    **Then** the influence stops outside and resumes inside without stacking, refreshing the field, or accumulating a hidden lingering effect.

15. **Combine wind through fixed motor precedence**

    **Given** locomotion, grapple pull, attack movement, surface effects, or another approved sustained influence is present
    **When** the motor resolves the physics step
    **Then** wind participates in the sustained-influence phase using stable aggregation and source ordering
    **And** terminal commands and state gating resolve before it, while one-shot impulses, connection constraints, collision response, and final safety caps retain their declared later ownership
    **And** callback, registration, and scene-tree order cannot alter the result
    **And** the motor still performs exactly one final velocity assignment and movement commit.

16. **Preserve active-grapple maximum-distance behavior**

    **Given** the player is grappled while wind pushes them toward, away from, or tangentially to the anchor
    **When** the complete movement step resolves
    **Then** grapple pull and wind combine as sustained influences before the existing maximum-grapple-length constraint
    **And** wind directed away from the anchor cannot move the player beyond the maximum connection boundary
    **And** the constraint removes or redirects only the invalid outward component while preserving valid inward and tangential movement
    **And** the field cannot stretch, shorten, break, reel, relocate, or replace the grapple connection.

17. **Keep grapple counterplay available**

    **Given** the player is inside the active field
    **When** they select, attach to, release from, or switch between valid anchors
    **Then** grapple eligibility, attachment, response, pull profile, release behavior, and target-loss behavior retain their existing owners
    **And** the fixture provides readable upwind and crosswind anchors that can oppose or redirect the field's acceleration
    **And** releasing preserves the velocity resolved by the motor rather than removing momentum attributed to wind
    **And** the field itself is neither grappleable nor an occluder of valid grapple targets.

18. **Preserve jumping, walls, collision, and attacks**

    **Given** the player uses ordinary traversal or combat while affected
    **When** movement and contact resolve
    **Then** jumping, falling, wall-running, wall-sticking, wall-jumping, attacking, and player commands remain available under their existing policies
    **And** static geometry still blocks the player normally even when wind points through it
    **And** the field does not grant collision immunity, force wall detachment, alter attack windows, fabricate movement context, or modify impact context
    **And** the fixture includes a lateral exit and an elevated wall or grapple route outside the affected volume.

19. **Cause no damage or hidden control effect**

    **Given** the player enters, remains in, or leaves the field
    **When** health, combat, input, camera, animation, and status systems inspect the result
    **Then** the field applies no damage, stun, stagger, invulnerability, input suppression, forced facing, camera rotation, animation root motion, targetability change, or lingering status
    **And** it creates no entry, exit, or expiry impulse
    **And** difficulty comes only from the declared sustained directional acceleration and the surrounding route.

20. **Preserve momentum after exit or expiry**

    **Given** the player leaves the active volume, the field expires, or the source-death policy terminates it
    **When** the next motor step resolves
    **Then** no further wind submission from that occurrence is accepted
    **And** velocity already produced remains subject to ordinary locomotion, gravity, grapple, collision, friction, and safety rules
    **And** cleanup does not subtract accumulated wind velocity, restore a pre-entry snapshot, zero movement, or provide a recovery impulse.

21. **Reject unsupported field stacking**

    **Given** the source already owns a windup or active baseline field
    **When** it requests another
    **Then** the later request is rejected without refreshing, relocating, rotating, strengthening, or extending the existing field
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** the focused fixture permits only one unresolved directional field at a time
    **And** overlapping wind fields, additive field stacking, opposing-field resolution, and wind-plus-suction composition remain outside this story.

22. **Handle source loss and reset safely**

    **Given** the source dies or is removed during windup
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** the preview cancels and no active field is created.

    **Given** the source dies or is removed during active use
    **When** the same policy resolves
    **Then** the field terminates, future motor submissions stop, and existing player momentum is preserved.

    **Given** the fixture resets, checkpoint reloads, or the scene exits during windup, activation, active use, expiry warning, or termination
    **When** the old run is invalidated
    **Then** executions, occurrences, spatial registrations, recipient references, motor submissions, cadence state, presentation, and late callbacks are removed or rejected exactly once
    **And** no wind influence survives into the fresh run.

23. **Keep the directional field configurable**

    **Given** an alternate valid definition changes dimensions, windup, active duration, expiry warning, acceleration, target component, cadence, placement policy, direction policy, eligible-recipient profile, boundary tolerance, or source-death policy
    **When** the same action, world-effect, spatial-query, motor-influence, and presentation implementations consume it
    **Then** placement, lifecycle, membership, acceleration, diagnostics, and cleanup use the authored values without code changes
    **And** at least one alternate-profile test proves volume, timing, strength, and target component are not hard-coded
    **And** radial suction, attraction to a moving point, rotating or moving fields, turbulence, lift, rigid-body effects, field overlap, damage, and final presentation remain outside this story.

24. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** placement, windup, activation, entry, sustained influence, boundary exit, expiry warning, expiry, source death, rejection, or reset occurs
    **Then** primitive volumes, arrows, flow lines, state colors plus non-color cues, velocity-component gauges, and typed result markers communicate the mechanic
    **And** future animation, particles, materials, audio, camera feedback, and VFX can consume committed facts without controlling placement, membership, lifecycle, acceleration, or movement
    **And** diagnostics expose stable identities, geometry, push direction, lifecycle times, membership result, current downwind velocity component, submitted acceleration, effective active time, other motor channels, grapple-constraint result, source policy, run identity, and terminal reason.

25. **Make wind counterplay manually reproducible**

    **Given** the named directional-wind fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can remain outside, enter from every side, escape laterally, cross the field, grapple upwind and crosswind, use the elevated wall route, release while moving, and deliberately use the field as a downwind boost
    **And** they can enter stationary, enter against the wind, enter above the target component, activate the field while already inside, collide with geometry, test the grapple maximum boundary with wind directed away from the anchor, exit and re-enter, kill the source during windup and active use, and reset during every lifecycle phase
    **And** retained evidence distinguishes objective volume, timing, direction, acceleration, target-component, motor-composition, grapple-constraint, locality, source-loss, cleanup, and repeatability results from subjective observations about strength, cue clarity, route value, counterplay difficulty, recovery, dimensions, and duration.

26. **Verify rate-independent directional influence**

    **Given** the permanent directional-field suite and focused real-Jolt fixture run
    **When** they exercise valid and invalid placement, volume faces and corners, exact lifecycle boundaries, stationary and high-speed recipients, opposing and downwind velocities, target-component edges, entry and re-entry, grapple and maximum-distance combinations, wall contacts, duplicate submissions, source invalidation, stale runs, randomized callback order, and repeated reset
    **Then** every eligible step produces no more than one correctly attributed sustained influence, the field never writes velocity directly, and every execution reaches one terminal result without stale influence
    **And** base movement and shared definitions remain unchanged
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time lifecycle timing, field membership within documented boundary tolerances, acceleration, target-component behavior, grapple constraints, resulting velocity, cadence, and cleanup within documented tolerances
    **And** the story has not implemented suction, moving or overlapping fields, rigid-body force, damage, control locks, ability combinations, or final presentation.
