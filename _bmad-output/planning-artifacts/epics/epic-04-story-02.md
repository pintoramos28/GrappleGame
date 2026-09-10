---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 2
---

# Story 4.2: Defeat a Frozen Predictive Mark by Changing Course

As a player,
I want a predicted strike position to become visibly locked before it activates,
So that I can defeat the prediction by changing direction, speed, or altitude instead of being followed by a hidden homing attack.

**Acceptance Criteria:**

1. **Declare the prediction gameplay question**

   **Given** the predictive-mark prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player recognizes a prediction based on their current motion and changes that motion after the prediction locks
   **And** its prediction model, tracking and lock timing, affected space, counters, recovery, grapple and wall interactions, source-death policy, overlap rule, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one frozen spatial strike rather than a homing projectile or persistent hazard.

2. **Author one immutable predictive-mark definition**

   **Given** the baseline predictive-mark profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 1.20-second windup, a 0.40-second tracking interval, a final 0.80-second locked interval, a 0.80-second prediction horizon at lock, a 2.0-metre spherical effect radius, an 8.0-metre maximum predicted displacement, one active delivery physics step, 10 base damage, and a 4.0-second start-to-next-start cadence
   **And** it declares target-sampling, prediction, spatial validation, hit, overlap, source-death, and presentation policies
   **And** all values remain immutable authored configuration rather than literals in the predictor, execution, fixture, or presenter.

3. **Keep execution state outside shared definitions**

   **Given** a predictive-mark execution is accepted
   **When** its runtime state is inspected
   **Then** it records a stable execution identity, source and target attribution, run identity, definition references, authoritative phase times, sampled target snapshots, current spatial binding, locked spatial snapshot, delivery history, and terminal reason
   **And** no execution mutates the shared attack, spatial, damage, or presentation definitions
   **And** the action owner controls lifecycle while the predictor supplies only typed calculations.

4. **Request the attack through the normal action boundary**

   **Given** the source has a valid target and the fixture or AI requests a predictive mark
   **When** the request reaches its action owner
   **Then** the owner validates source, target, range, line of sight, current action, cadence, current run, active-mark limit, definitions, and required resident assets before committing one execution
   **And** AI and fixture controls cannot calculate authoritative prediction, activate the strike, apply damage, or advance phase timing
   **And** rejected, duplicate, stale, and busy requests produce typed results without a partial telegraph or consumed delivery.

5. **Sample one bounded target-motion snapshot**

   **Given** the execution is tracking and requires a prediction update
   **When** the target's authoritative motion is sampled on a physics step
   **Then** an immutable target snapshot records the physics step and run, stable target identity, finite combat reference position, finite velocity, alive and eligibility state, and applicable movement context
   **And** it does not expose input commands, future state transitions, camera direction, animation state, private HSM nodes, or presentation
   **And** an invalid, stale, mismatched, or non-finite snapshot produces a typed calculation failure.

6. **Use one explicit constant-velocity prediction**

   **Given** a valid target snapshot is available at the lock boundary
   **When** the predicted point is calculated
   **Then** the raw point equals the sampled combat reference position plus sampled velocity multiplied by the 0.80-second prediction horizon
   **And** the displacement from the sampled position is limited to a maximum magnitude of 8.0 metres while retaining its direction
   **And** zero velocity predicts the current reference position
   **And** the model does not anticipate acceleration, gravity, input, grapple paths, wall transitions, collisions, AI, or animation.

7. **Validate predicted space before locking**

   **Given** the predictor produces a finite candidate point
   **When** the candidate and its complete 2.0-metre sphere are validated
   **Then** the affected space must fit within the scenario's authored effect bounds and satisfy its protected-space policy
   **And** invalid, out-of-bounds, or prohibited space causes reason-coded cancellation rather than silent clamping to another location
   **And** no floor projection is required, allowing the baseline mark to exist in grounded or aerial space.

8. **Show prediction updates during the tracking interval**

   **Given** the execution is within its first 0.40 seconds
   **When** current target snapshots are accepted
   **Then** a provisional spatial binding is recalculated from each accepted snapshot
   **And** a primitive low-intensity spherical preview communicates that the prediction is still tracking
   **And** prediction updates occur only on declared simulation steps
   **And** presentation cannot calculate its own predicted point or smooth gameplay into a different location.

9. **Freeze one authoritative spatial snapshot**

   **Given** the execution reaches 0.40 elapsed seconds with a valid prediction
   **When** the tracking-to-locked transition commits
   **Then** one immutable `AbilitySpatialSnapshot` records the execution and physics-step identities, frozen center, 2.0-metre radius, orientation where relevant, target snapshot identity, prediction inputs, displacement result, and locked state
   **And** the spatial binding stops consuming later target motion
   **And** the remaining 0.80 seconds advances toward that frozen space without homing, re-prediction, recentering, or target following.

10. **Make the locked warning match the affected volume**

    **Given** a locked spatial snapshot exists
    **When** the final warning and active strike are produced
    **Then** both consume exactly the same frozen center and 2.0-metre spherical radius
    **And** the warning clearly changes from tracking to locked state and remains fixed for the complete final 0.80 seconds
    **And** its primitive wireframe or translucent volume communicates three-dimensional extent rather than implying an unrelated ground-only circle
    **And** camera interpolation or presentation timing cannot move or resize the authoritative warning.

11. **Deliver one instantaneous area strike**

    **Given** the 1.20-second windup completes with a valid source policy and run
    **When** the execution enters its one-step active phase
    **Then** exactly one authoritative spherical hit query is performed at the locked center and radius using the named profile
    **And** eligible candidates are normalized, stably ordered, and deduplicated before delivery
    **And** one immutable damage snapshot and current impact context resolve for each accepted target according to the attack's hit policy
    **And** presentation cannot repeat or extend the active query.

12. **Resolve boundary contacts consistently**

    **Given** a target's authoritative hurt volume lies near the 2.0-metre boundary
    **When** the active query resolves
    **Then** inclusion uses the declared shape-contact and physics tolerance policy rather than visual estimation or center-point distance alone
    **And** duplicate hurtboxes cannot apply the same execution's damage more than once to one target
    **And** equivalent candidates and ties resolve through stable identities rather than scene-tree order.

13. **Hit predictable continued movement**

    **Given** the player moves with approximately unchanged velocity from lock until activation
    **When** the prediction horizon elapses
    **Then** the frozen strike occupies the location predicted from the lock-time snapshot
    **And** the player is hit only if their current eligible hurt volume actually intersects that sphere at activation
    **And** the result can be compared with the stored prediction inputs without reconstructing them from current motion.

14. **Let direction and speed changes defeat the prediction**

    **Given** the mark has locked
    **When** the player turns, stops, accelerates differently, reverses, or otherwise leaves the frozen sphere before activation
    **Then** the strike remains fixed and misses
    **And** no later player movement can pull the mark back onto the target
    **And** ordinary movement remains responsive under its existing policies.

15. **Let altitude changes defeat the prediction**

    **Given** the mark locks onto grounded, airborne, grappling, or wall-relative motion
    **When** the player jumps, falls, releases, grapples, wall-jumps, or otherwise changes altitude enough to leave the frozen spherical volume
    **Then** the active strike misses
    **And** the effect does not project itself onto the player's new ground position or expand vertically to compensate
    **And** the fixture provides sufficient vertical space to demonstrate both an aerial hit and an altitude-change miss.

16. **Preserve grapple and wall ownership**

    **Given** the predictive mark tracks or locks while the player is grappling, wall-running, or wall-sticking
    **When** the player continues or changes traversal
    **Then** grapple attachment, release, maximum-distance behavior, wall contact, wall transitions, and motor movement remain owned by their existing systems
    **And** the mark cannot cancel grapple, invalidate an anchor, disable a wall, write velocity, or force a locomotion state
    **And** grapple release, a new grapple direction, or a wall jump may serve as deliberate prediction-breaking counters.

17. **Provide recovery after a deliberate hit**

    **Given** the player remains inside the frozen volume and receives the baseline 10-damage strike
    **When** damage and feedback commit
    **Then** the occurrence applies no knockback, tether, stun, lingering hazard, movement modifier, or repeated damage
    **And** the player retains ordinary traversal and can take the fixture's authored recovery route
    **And** the four-second cadence leaves a manually verified response period before another prediction can begin.

18. **Prevent unresolved-mark stacking**

    **Given** the target already has one tracking or locked baseline predictive mark reserved against it
    **When** the same or another source requests another baseline mark
    **Then** the later request is rejected by the scenario's single-unresolved-mark policy without refreshing, replacing, merging, or widening the first mark
    **And** simultaneous requests resolve by stable request identity
    **And** another mark may be accepted only after the first execution becomes terminal.

19. **Apply source and target loss policies explicitly**

    **Given** the source dies or is removed before delivery
    **When** the baseline `CANCEL_WITH_SOURCE` policy resolves
    **Then** tracking or locked execution terminates without an active query or damage.

    **Given** the original target dies or becomes invalid after the spatial snapshot has locked while the source and run remain valid
    **When** delivery time arrives
    **Then** the strike remains at its frozen world position but the invalid original target cannot receive damage
    **And** any other eligible target is handled only according to the declared area-hit policy.

    **Given** target loss occurs before lock
    **When** the execution can no longer obtain a valid target snapshot
    **Then** it cancels with a typed target-invalid reason rather than locking reconstructed data.

20. **Clean up on reset and scene exit**

    **Given** the fixture resets, checkpoint reloads, or the scene exits during tracking, locked warning, delivery, recovery, or cooldown
    **When** the old run is invalidated
    **Then** the execution, mark reservation, spatial bindings and snapshots, telegraphs, delivery history, presentation, and late callbacks are removed or rejected exactly once
    **And** a fresh run can immediately execute the documented scenario without inheriting the previous prediction or cadence.

21. **Keep prediction tuning configurable**

    **Given** an alternate valid definition changes tracking duration, locked duration, prediction horizon, maximum displacement, radius, damage, cadence, source-death policy, or overlap policy
    **When** the same predictor and lifecycle consume it
    **Then** snapshots, warnings, delivery, diagnostics, and outcomes use the authored values without code changes
    **And** at least one alternate-profile test proves that timing, horizon, displacement cap, and radius are not hard-coded
    **And** acceleration-aware prediction, navigation prediction, input reading, ballistic delivery, ground projection, homing, repeated pulses, and multiple overlapping marks remain outside this story.

22. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, tracking, prediction, lock, warning, strike, hit, miss, cancellation, or reset occurs
    **Then** primitive source cues, tracking and locked volumes, phase-state changes, and impact markers communicate the attack
    **And** future animation, audio, camera, material, and VFX presenters can consume committed lifecycle and spatial facts without controlling them
    **And** diagnostics expose request, execution, source, target, snapshot, and run identities; sampled position and velocity; prediction horizon; raw and capped displacement; current and locked center; radius; phase times; hit candidates and results; mark reservation; and terminal reason.

23. **Make prediction counterplay manually reproducible**

    **Given** the named predictive-mark fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can remain stationary and be hit, continue constant movement into the predicted point, change direction after lock, stop, reverse, jump, fall, grapple to another altitude, and wall-jump away to produce observable misses
    **And** they can test a grounded mark, an aerial mark, maximum predicted displacement, effect boundaries, overlapping request rejection, source death before and after lock, target loss, reset during every phase, and repeated runs
    **And** the procedure distinguishes objective prediction, lock, alignment, query, damage, cleanup, and counter results from subjective observations about radius, timing, and displacement cap.
