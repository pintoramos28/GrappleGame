---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 1
---

# Story 4.1: Escape a Telegraph-First Adhesive Surface

As a player,
I want an adhesive surface to clearly mark its bounds and slow me only while I remain grounded on it,
So that I can avoid it, cross it deliberately, or escape using jumps, walls, and grappling without suffering a hidden lingering penalty.

**Acceptance Criteria:**

1. **Declare the adhesive-surface gameplay question**

   **Given** the adhesive-surface prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player avoids the patch or preserves useful traversal after entering a temporary slow surface
   **And** its telegraph, footprint, surface response, counters, recovery, grapple and wall interactions, source-death policy, overlap rule, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains a movement and route-pressure mechanic rather than a damage or control-lock effect.

2. **Author one immutable adhesive definition**

   **Given** the baseline adhesive profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 4.0-by-4.0-metre square footprint, 0.75-second windup, 6.0-second active lifetime, final 1.0-second expiry warning, 20-degree maximum support slope, and maximum of one previewing or active patch per source
   **And** while eligible contact persists it applies a 0.50 ground target-speed multiplier, 0.50 ground-acceleration multiplier, and 10.0-metres-per-second-squared tangential braking toward the reduced target speed
   **And** it declares placement, overlap, contact, motor, grapple, wall, source-death, expiry, and cleanup policies
   **And** these values remain authored parameters rather than literals in the effect, motor, fixture, or presenter.

3. **Keep configuration separate from occurrence state**

   **Given** an adhesive occurrence is created
   **When** its runtime state is inspected
   **Then** it records a stable occurrence identity, immutable definition reference, source and execution attribution, current run, frozen surface footprint, lifecycle phase and times, affected-target contacts, motor-submission identities, and terminal reason
   **And** no occurrence mutates the shared definition or the player's movement definition
   **And** the scoped effect owner controls placement and lifetime while the player motor retains movement authority.

4. **Request the patch through the ability boundary**

   **Given** the source commits its adhesive-surface ability
   **When** the scoped world-effect request is created
   **Then** it carries the source, execution, run, definition, requested surface point, and spatial binding through the typed spawning boundary
   **And** the baseline request freezes a world point projected from the target's current authoritative ground position at commit
   **And** a pressure-lab placement marker invokes the same request path
   **And** AI and presentation cannot create the patch, alter its footprint, or advance its lifecycle directly.

5. **Validate one planar static-floor footprint**

   **Given** a finite requested surface point exists
   **When** placement is validated
   **Then** the footprint must resolve onto static floor-like support whose normal is within 20 degrees of world up
   **And** its center and four corner probes must resolve the same stable support and fit within the configured planar tolerance and fixture effect bounds
   **And** the frozen plane, basis, center, dimensions, support identity, and edge tolerance are stored in one authoritative spatial snapshot
   **And** unsupported, discontinuous, steep, moving, out-of-bounds, or non-finite placements are rejected before preview with a typed reason.

6. **Reject overlapping adhesive occurrences**

   **Given** a candidate footprint is otherwise valid
   **When** it overlaps the protected footprint of another previewing or active adhesive occurrence
   **Then** the later placement is rejected with a typed overlap reason
   **And** it is not moved, resized, stacked, or merged through a hidden fallback
   **And** adjacent non-overlapping patches remain valid when their configured edge tolerances do not overlap.

7. **Permit telegraphed placement beneath the player**

   **Given** the player occupies the requested footprint when placement commits
   **When** the patch enters windup
   **Then** the player's presence does not reject the non-solid surface effect
   **And** the complete footprint remains visibly previewed for 0.75 seconds before it can affect movement
   **And** the player can leave, jump, or grapple away during that warning
   **And** activation never creates solid collision, pushes the player, or changes position directly.

8. **Preview the exact future footprint**

   **Given** a valid adhesive occurrence is in windup
   **When** authoritative lifecycle time advances
   **Then** a primitive surface overlay displays the same center, orientation, 4.0-by-4.0-metre bounds, and edge tolerance used by contact resolution
   **And** the preview remains non-solid and cannot affect movement, damage, grapple, wall contact, projectiles, or line of sight
   **And** presentation consumes normalized simulation-owned progress rather than controlling activation from an animation or material timer.

9. **Activate a non-solid scoped surface effect**

   **Given** windup reaches 0.75 seconds with a valid run and source
   **When** the occurrence enters its active phase
   **Then** its surface-effect footprint becomes eligible at the frozen transform for exactly 6.0 seconds unless terminated earlier
   **And** it does not add ground, wall, or body collision; replace the underlying surface; deform terrain; block projectiles; or obstruct line of sight
   **And** its active query representation cannot itself become a grapple target or occluder.

10. **Resolve contact from authoritative movement facts**

    **Given** the patch is active
    **When** the player's committed `ContactFrame` is evaluated
    **Then** adhesive eligibility requires a valid primary ground contact on the same support identity with the contact point inside the authoritative footprint and edge tolerance
    **And** merely overlapping a visual mesh, trigger volume, or bounding box while airborne does not apply the effect
    **And** entry and exit are derived once from committed contact facts rather than competing `body_entered`, `body_exited`, state, or presentation callbacks.

11. **Apply the effect at a declared motor boundary**

    **Given** an authoritative contact first reports eligible adhesive support
    **When** the next applicable player-motor step begins
    **Then** the player effect owner submits one occurrence-keyed adhesive movement policy through the declared gating and sustained-influence phases
    **And** diagnostics expose the contact step, first eligible motor step, actual application step, and any bounded one-step scheduling latency
    **And** duplicate contact notifications cannot create multiple applications.

12. **Reduce grounded locomotion without replacing velocity**

    **Given** the adhesive policy is active on the player
    **When** grounded base locomotion resolves
    **Then** its configured target speed and acceleration are multiplied by 0.50 for the eligible surface-tangent movement
    **And** current surface-tangent speed above the reduced target is moved toward that target by no more than 10.0 metres per second squared in simulation time
    **And** braking cannot reverse the player, remove vertical velocity, erase unrelated movement components, or assign final velocity directly
    **And** the ordinary motor still performs one final collision-aware movement commit.

13. **Preserve high-speed entry as a recoverable slowdown**

    **Given** the player enters the patch above the reduced ground target speed
    **When** adhesive braking resolves over subsequent physics steps
    **Then** excess tangential speed decreases progressively rather than being instantaneously replaced or clipped to the reduced target
    **And** the player retains directional input under the reduced acceleration policy
    **And** collision, slopes, and fixture boundaries continue through ordinary movement rules.

14. **Restore capabilities exactly on exit**

    **Given** the player no longer has an eligible ground contact inside the active footprint
    **When** the next applicable motor step resolves
    **Then** only that occurrence's speed, acceleration, and braking submissions are removed
    **And** normal authored ground target speed and acceleration apply again without a lingering timer, cached scalar, or mutation that requires manual restoration
    **And** unrelated active movement influences remain intact
    **And** velocity lost while traversing the adhesive surface is not artificially refunded.

15. **Allow jumping and preserve airborne control**

    **Given** the player is grounded on the adhesive patch and remains otherwise eligible to jump
    **When** jump is requested
    **Then** the ordinary jump owner evaluates and commits it without adhesive input suppression or jump-height modification
    **And** once authoritative ground contact ends, the adhesive ground policy is removed
    **And** ordinary air control and gravity resume under their existing definitions
    **And** a later landing inside the still-active footprint reapplies the effect through a new eligible contact interval.

16. **Preserve grapple targeting and pull**

    **Given** an adhesive overlay lies on otherwise grappleable static geometry
    **When** the player targets that geometry
    **Then** the underlying surface retains its ordinary grapple eligibility and response
    **And** the overlay itself neither intercepts nor alters the grapple-candidate or grapple-occlusion result.

    **Given** the player grapples while grounded on the patch
    **When** locomotion and grapple influences resolve
    **Then** adhesive scaling applies only to its declared grounded locomotion channels while grapple acceleration, attachment, release, and maximum-distance constraints retain their approved ownership
    **And** grapple can provide an intentional escape without silently clearing the patch before ground contact ends.

17. **Preserve wall traversal as a counter**

    **Given** the baseline profile is limited to floor-like support
    **When** the player leaves the patch and establishes a valid wall contact
    **Then** wall-running, wall-sticking, and wall-jumping use their normal speed, acceleration, contact, and transition policies
    **And** remaining visually close to the floor overlay does not preserve adhesive eligibility without qualifying ground contact
    **And** the fixture includes a nearby wall route that provides a manually testable bypass or recovery option.

18. **Expire without leaving movement state behind**

    **Given** the patch reaches the final 1.0 second of its active lifetime
    **When** the warning phase begins
    **Then** primitive presentation communicates imminent expiry while the active surface policy remains unchanged.

    **Given** the patch reaches 6.0 active seconds while the player is inside or outside it
    **When** expiry commits
    **Then** its contact eligibility and every occurrence-keyed motor submission are invalidated together exactly once
    **And** a player standing on the footprint regains normal capabilities at the next declared motor boundary without a launch, velocity refund, or lingering slow.

19. **Clean up on source loss and reset**

    **Given** the source dies or is removed during windup
    **When** its `CANCEL_WITH_SOURCE` policy resolves
    **Then** the preview cancels and can never activate.

    **Given** the source dies or is removed while the patch is active
    **When** source invalidation is processed
    **Then** the patch immediately follows its authoritative expiry and motor-cleanup path.

    **Given** the fixture resets, checkpoint reloads, or the scene exits
    **When** the previous run is invalidated
    **Then** previews, active footprints, target-contact state, motor submissions, timers, presenters, and late callbacks are removed or rejected exactly once.

20. **Keep authored tuning flexible**

    **Given** an alternate valid definition changes footprint dimensions, windup, duration, warning time, slope tolerance, edge tolerance, speed multiplier, acceleration multiplier, braking rate, active limit, or source-death policy
    **When** the same implementation consumes it
    **Then** placement, presentation, contact resolution, movement, expiry, and diagnostics use the authored values without code changes
    **And** at least one alternate-profile test proves that geometry, timing, and movement scalars are not hard-coded
    **And** wall-mounted patches, moving supports, lingering target statuses, damage, jumping suppression, destructibility, terrain deformation, and overlapping adhesive stacking remain outside this story.

21. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** placement is accepted or rejected, preview advances, the patch activates, the player enters or exits, braking applies, warning begins, or cleanup occurs
    **Then** primitive surface geometry, boundary lines, state changes, and a bounded player indicator make the effect and its extent observable
    **And** future materials, animation, foot effects, audio, camera, and VFX can observe committed facts without controlling contact or movement
    **And** diagnostics expose definition and occurrence identity, source and run, footprint and support facts, lifecycle phase and remaining time, contact identity and point, application and removal steps, authored multipliers, pre- and post-influence tangent velocity, grapple state, and terminal reason.

22. **Make adhesive counterplay manually reproducible**

    **Given** the named adhesive-surface fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can leave during preview, route around the patch, intentionally enter at low and high speed, steer while slowed, leave and immediately regain normal capabilities, jump out, grapple out, use the nearby wall route, re-enter, and remain inside through expiry
    **And** they can test edge contacts, airborne overlap, an underlying grapple target, duplicate requests, overlap rejection, source death during preview and active phases, reset during every lifecycle phase, and repeated runs
    **And** the procedure distinguishes objective footprint, timing, contact, scaling, restoration, traversal, and cleanup results from subjective observations about size, strength, braking, warning, and duration.

23. **Verify exact application and restoration**

    **Given** the permanent adhesive-surface suite and focused real-Jolt fixture run
    **When** they exercise valid and invalid support, footprint edges, high-speed entry, grounded and airborne overlap, jump, grapple, wall transition, re-entry, expiry while contacted, duplicate contact notifications, adjacent patches, rejected overlap, source loss, stale runs, randomized callback order, and repeated reset
    **Then** each eligible occurrence submits its authored policy no more than once per motor step and removes only its own influence at the declared exit boundary
    **And** the underlying movement and grapple definitions remain unchanged before, during, and after every attempt
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time windup, active lifetime, braking rate, entry and exit outcomes, and exact capability restoration within documented tolerances
    **And** the story has not implemented the later predictive, sweep, gas, anchor, wind, or temporary surface-state mechanics.
