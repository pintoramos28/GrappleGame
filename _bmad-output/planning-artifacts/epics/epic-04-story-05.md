---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 5
---

# Story 4.5: Adapt to a Temporarily Weakened Grapple Anchor

As a player,
I want a modified grapple anchor to remain usable while clearly communicating its temporarily weakened pull,
So that I can decide whether to commit to it, redirect to another anchor, or use a different traversal route.

**Acceptance Criteria:**

1. **Declare the weakened-anchor gameplay question**

   **Given** the weakened-anchor prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player recognizes that one valuable grapple anchor remains usable but has temporarily reduced pull and adapts their route or commitment
   **And** its eligible targets, targeting range, line of sight, windup, active duration, expiry warning, response multiplier, cadence, reapplication, source-death, target-loss, moving-anchor, active-grapple, reset, counterplay, tuning, manual procedure, and evidence policies are explicit
   **And** the modifier is local to one authored anchor rather than a player-wide grapple debuff or a change to ordinary implicit grapple geometry.

2. **Author one immutable modifier definition**

   **Given** the baseline weakened-anchor profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 0.75-second windup, 6.0-second active duration, final 1.0-second expiry warning, 20.0-metre source-to-anchor targeting range, 0.40 pull-acceleration multiplier, and 8.0-second start-to-next-start cadence
   **And** it declares `CANCEL_WITH_SOURCE`, rejection-based reapplication, and a maximum of one unresolved modifier in the weakened-pull response channel per anchor
   **And** these values and policies remain authored configuration rather than literals in the action, target, grapple motor, fixture, or presenter.

3. **Limit modification to explicit stateful grapple targets**

   **Given** the source requests a target for the weakened-anchor action
   **When** target eligibility is evaluated
   **Then** the target must expose a valid typed `Grappleable3D` response owner capable of owning runtime grapple-response modifiers, belong to the active run, lie within targeting range, and satisfy the named line-of-sight policy
   **And** ordinary implicit grappleable geometry remains available to the player's normal grapple query but is ineligible for this modifier
   **And** presentation nodes, stale targets, destroyed targets, and targets without the required response-owner capability are rejected with typed reasons.

4. **Request modification through the normal action boundary**

   **Given** the fixture or AI requests the weakened-anchor action
   **When** the request reaches its action owner
   **Then** the owner validates source and target identity, current action, range, line of sight, cadence, run identity, response-channel availability, definition validity, and required resident assets before committing one execution
   **And** AI and fixture controls cannot directly mutate the target, grapple response, player motor, lifecycle clock, or presentation
   **And** rejected, duplicate, busy, and stale requests produce typed results without a partial target modifier.

5. **Lock one stable target identity**

   **Given** an eligible anchor is selected when the action commits
   **When** the 0.75-second windup begins
   **Then** the execution records that anchor's stable target and response-owner identities
   **And** later aim movement, selection changes, or another anchor crossing the reticle cannot retarget the execution
   **And** target invalidation terminates or rejects the execution according to lifecycle phase rather than silently choosing a replacement.

6. **Follow the selected anchor during windup**

   **Given** the locked target is moving during windup
   **When** the action prepares to activate
   **Then** its primitive cue follows the target-owned grapple-anchor snapshot rather than remaining at the original world position
   **And** target validity, response ownership, range, and line of sight are revalidated at the active boundary
   **And** an obstruction or other eligibility loss at that boundary cancels activation with a typed reason and no modifier occurrence.

7. **Telegraph the exact anchor and future response**

   **Given** the action is winding up or the modifier is active
   **When** presentation observes its committed state
   **Then** a non-color-only cue identifies the exact anchor and distinguishes pending modification, active weakened pull, and the final expiry-warning interval
   **And** the grapple reticle or equivalent targeting feedback may preview the weakened response while that anchor is selected
   **And** primitive presentation communicates that the anchor remains usable rather than disabled, hostile, relocated, or repulsive
   **And** presentation consumes authoritative facts and cannot select the target, apply the multiplier, or control lifecycle timing.

8. **Create one target-owned modifier occurrence**

   **Given** windup completes with a valid source, target, response channel, and run
   **When** active execution begins
   **Then** the target's response owner creates one occurrence with stable definition, execution, occurrence, source, target, response-channel, and run identities; authoritative start and end times; source policy; and terminal reason
   **And** the target owns the runtime modifier state while the shared definition remains immutable
   **And** activation is published only after the occurrence is completely configured and available to grapple-response resolution.

9. **Resolve the weakened response in fixed precedence**

   **Given** the grapple motor requests the selected target's current response
   **When** the target's response owner resolves it
   **Then** resolution applies the immutable base response, valid runtime modifiers in stable declared order, and final safety constraints in that fixed precedence
   **And** the active weakened-pull channel multiplies base pull acceleration by exactly 0.40 without mutating the base response
   **And** invalid, expired, terminal, stale-run, or wrong-target modifiers are excluded
   **And** callback, node, or registration order cannot alter the result.

10. **Leave grapple eligibility and range unchanged**

    **Given** an anchor has the active weakened-pull modifier
    **When** the player performs grapple acquisition, attachment, or maximum-distance resolution
    **Then** the anchor remains eligible under its ordinary target rules and retains its normal attachment point
    **And** the modifier does not shorten targeting range, shorten maximum grapple length, reject attachment, redirect aim, move the anchor, add occlusion, or change break behavior
    **And** the player's existing maximum-grapple-length constraint remains authoritative.

11. **Reduce only current pull acceleration**

    **Given** the player is attached to the modified anchor during an eligible motor step
    **When** sustained grapple influence is resolved
    **Then** the motor receives exactly 40 percent of the current base pull acceleration for that point in the existing grapple acceleration profile
    **And** the modifier does not restart, rewind, advance, or replace that profile
    **And** the target never writes player velocity directly, injects a second grapple influence, or applies an independent impulse.

12. **Weaken an already active grapple without reconnecting it**

    **Given** the player is already grappled to the selected anchor when the modifier activates
    **When** the next eligible motor step resolves
    **Then** the same attachment consumes the weakened target response
    **And** execution identity, attachment time, attachment point, current velocity, elapsed acceleration-profile state, and maximum-distance state are preserved
    **And** activation causes no snap, teleport, velocity zeroing, forced release, duplicate attachment, or new-grapple event.

13. **Restore normal pull without restarting the grapple**

    **Given** the modifier expires while the player remains attached
    **When** the next eligible motor step resolves the target response
    **Then** the same attachment consumes the immutable base response again
    **And** the existing grapple resumes from its current elapsed acceleration-profile state
    **And** expiry provides no new initial burst, artificial catch-up impulse, lost-momentum refund, reconnect event, or forced release.

14. **Keep the effect local to one anchor**

    **Given** one target owns an active weakened-pull occurrence
    **When** the player selects, attaches to, releases from, or returns to any grapple target
    **Then** only the owning target resolves the 0.40 multiplier while the occurrence is active
    **And** changing selection, releasing, or attaching elsewhere cannot transfer the modifier to another anchor or to the player
    **And** all unmodified anchors and ordinary grappleable geometry retain their base responses.

15. **Provide alternate traversal choices**

    **Given** the named weakened-anchor fixture is loaded
    **When** its routes are inspected
    **Then** it provides the modified valuable anchor, at least one unmodified alternate anchor, and a wall or ordinary-geometry traversal route to the same readable objective region
    **And** the weakened anchor remains an intentionally usable but lower-response choice
    **And** fixture geometry permits the player to compare commitment, route-switching, and recovery rather than requiring the affected anchor.

16. **Preserve moving-anchor behavior**

    **Given** the eligible target moves before or during an active grapple
    **When** target response and attachment geometry resolve
    **Then** the normal moving-anchor snapshot, attachment-point update, pull direction, maximum-distance constraint, and target-loss behavior remain authoritative
    **And** the modifier changes only the magnitude of pull acceleration through its 0.40 multiplier
    **And** a target moving away may still pull the player through the existing maximum-length behavior; this story neither adds nor removes that behavior.

17. **Preserve collision, wall, and attack ownership**

    **Given** the player uses the weakened anchor near an obstacle, wall route, enemy, or attack opportunity
    **When** grapple influence combines with ordinary movement and contact resolution
    **Then** collision, wall-running, wall-sticking, wall-jumping, grapple release, movement-context capture, impact-context capture, and attack delivery retain their existing owners and precedence
    **And** the modifier neither grants collision immunity nor changes damage, attack windows, hit uniqueness, or contact velocity
    **And** loss of speed caused by geometry is not refunded when the modifier expires.

18. **Reject conflicting reapplication**

    **Given** the target already owns a windup or active occurrence in the weakened-pull response channel
    **When** the same or another source requests a conflicting occurrence
    **Then** the later request is rejected without refreshing duration, multiplying the response again, replacing source attribution, changing end time, or disturbing stable modifier ordering
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** a new application becomes eligible only after the previous occurrence reaches a terminal state and cadence permits it.

19. **Remove only the owning occurrence**

    **Given** the weakened-pull occurrence expires or terminates
    **When** its response owner removes it
    **Then** exactly that occurrence leaves the response stack while the immutable base response and unrelated target-owned state remain unchanged
    **And** an active grapple observes the current resolved response on its next eligible motor step rather than retaining a cached multiplier in the player
    **And** duplicate or late removal cannot remove a newer occurrence.

20. **Handle source loss, target loss, and reset safely**

    **Given** the source dies or is removed during windup
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** the execution and cue cancel and no modifier becomes active.

    **Given** the source dies or is removed during the active duration
    **When** the active source policy resolves
    **Then** the target-owned occurrence terminates and normal pull is restored through ordinary response resolution.

    **Given** the target is destroyed during windup or active use
    **When** invalidation resolves
    **Then** the modifier terminates and any active grapple follows its existing target-loss behavior without retaining weakened response state.

    **Given** the fixture resets, checkpoint reloads, or the scene exits in any lifecycle phase
    **When** the old run is invalidated
    **Then** executions, occurrences, response entries, cues, cadence state, references, and late callbacks are removed or rejected exactly once and cannot affect the fresh run.

21. **Keep grapple-response modification configurable**

    **Given** an alternate valid definition changes windup, active duration, expiry warning, targeting range, pull multiplier, cadence, line-of-sight policy, reapplication policy, response-channel limit, or source-death policy
    **When** the same action, response-owner, grapple-motor, and presentation implementations consume it
    **Then** targeting, lifecycle, response resolution, diagnostics, and cleanup use the authored values without code changes
    **And** at least one alternate-profile test proves timing and response magnitude are not hard-coded
    **And** range reduction, grapple rejection, repulsion, elasticity, reeling, anchor relocation, player-wide debuffs, ordinary-geometry modification, and multiple simultaneous same-channel modifiers remain outside this story.

22. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, windup, activation, grapple selection, pull resolution, expiry warning, expiry, rejection, source loss, target loss, or reset occurs
    **Then** primitive target markers, outlines, state changes, reticle feedback, response gauges or vectors, expiry cues, and typed result markers communicate the mechanic
    **And** future animation, audio, particles, materials, camera feedback, and VFX can consume committed facts without controlling target selection, lifecycle, response resolution, or movement
    **And** diagnostics expose stable identities, lifecycle times, source and target validity, range and line-of-sight results, base and resolved pull acceleration, multiplier, modifier ordering, attachment state, acceleration-profile time, maximum-distance state, reapplication result, source policy, run identity, and terminal reason.

23. **Make weakened-anchor counterplay manually reproducible**

    **Given** the named weakened-anchor fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can compare otherwise identical normal and modified anchors, observe the 0.40 pull response, attach before and after activation, remain attached through expiry, redirect to the alternate anchor, and complete the wall or ordinary-geometry route
    **And** they can test range and line-of-sight boundaries, implicit-geometry rejection, a moving anchor, duplicate application, source death during windup and active use, target destruction, maximum grapple length, and reset during every lifecycle phase
    **And** retained evidence distinguishes objective target identity, timing, response magnitude, locality, moving-target, attachment, recovery, cleanup, and repeatability results from subjective observations about cue clarity, weakened feel, route value, warning duration, and whether the anchor remains worth using.

24. **Verify deterministic target-owned response changes**

    **Given** the permanent weakened-anchor suite and focused real-Jolt fixture run
    **When** they exercise eligible and ineligible targets, range and line-of-sight edges, exact lifecycle boundaries, activation and expiry before and during attachment, normal and high player speeds, maximum grapple length, moving targets, simultaneous selection changes, duplicate applications, source and target invalidation, stale runs, randomized registration or callback order, and repeated reset
    **Then** only the selected target owns one accepted occurrence, every eligible motor step resolves the declared response, base definitions remain unchanged, and cleanup reaches one terminal result without stale influence
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve windup and active timing, response magnitude, attachment continuity, moving-target and maximum-distance behavior, expiry restoration, cadence, and cleanup within documented tolerances
    **And** the story has not implemented range reduction, rejection, repulsion, reeling, relocation, global grapple debuffs, implicit-geometry modifiers, same-channel stacking, or final presentation.
