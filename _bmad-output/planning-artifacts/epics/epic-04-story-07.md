---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.7'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 7
---

# Story 4.7: Adapt to a Temporarily Infested Wall

As a player,
I want a temporarily modified traversal wall to clearly communicate its changed behavior while preserving usable movement options,
So that I can avoid it, traverse it at greater risk, or recover through another route.

**Acceptance Criteria:**

1. **Declare the surface-state gameplay question**

   **Given** the infested-wall prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player recognizes that one existing wall has temporarily lost route value and chooses to avoid it, use it carefully, or recover through another traversal option
   **And** its eligible surface, targeting, windup, active responses, contact damage, counters, recovery, grapple and wall interactions, stacking, source-death policy, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it changes a surface-owned state rather than spawning a second collision surface or permanently editing level geometry.

2. **Author one immutable infestation definition**

   **Given** the baseline infested-wall profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 1.0-second windup, 6.0-second active duration, final 1.0-second expiry warning, 20.0-metre targeting range, and 8.0-second start-to-next-start cadence
   **And** it declares a 0.60 wall-run target-speed multiplier, 0.50 wall-run acceleration multiplier, 12.0-metres-per-second-squared wall-stick slide acceleration, 3.0-metres-per-second downward slide target component, and four first-contact damage
   **And** it declares `CANCEL_WITH_SOURCE`, once-per-recipient-per-occurrence contact delivery, atomic conflict rejection, and an exclusive `ROUTE_HAZARD` state channel
   **And** these values and policies remain authored configuration rather than literals in the action, surface owner, locomotion controller, damage delivery, fixture, or presenter.

3. **Limit mutation to explicit stateful wall regions**

   **Given** the source requests an infested-wall target
   **When** target eligibility is evaluated
   **Then** the target must expose a valid typed `SurfaceStateOwner3D`, own one stable authored traversal region, be static, belong to the active run, lie within range, satisfy line of sight, and have a surface normal within 20 degrees of horizontal
   **And** the focused fixture's target region is one clearly bounded 6.0-by-6.0-metre wall panel
   **And** ordinary implicit geometry remains usable but cannot be mutated by this action
   **And** floors, ceilings, moving surfaces, destroyed surfaces, stale-run surfaces, and surfaces without the required state owner are rejected with typed reasons.

4. **Keep mutable state outside shared resources**

   **Given** a surface-state execution or occurrence exists
   **When** its runtime state is inspected
   **Then** it records stable definition, execution, occurrence, source, target, surface-region, response-channel, damage-delivery, and run identities; lifecycle times; accepted recipients; source snapshot; stacking result; and terminal reason
   **And** it never mutates the shared surface, locomotion, damage, query, grapple, or presentation definitions
   **And** the target surface owns its active runtime response modifiers.

5. **Request the mutation through the normal action boundary**

   **Given** the fixture or AI requests the infested-wall ability
   **When** the request reaches its action owner
   **Then** the owner validates source and target identity, current action, targeting range, line of sight, cadence, surface capability, region validity, response-channel compatibility, run identity, definitions, and required resident assets before committing one execution
   **And** AI and fixture controls cannot directly change the surface response, wall movement, grapple result, contact damage, lifecycle timing, or presentation
   **And** rejected, duplicate, conflicting, busy, and stale requests produce typed results without a partial mutation.

6. **Lock one stable surface region**

   **Given** an eligible wall region is selected when the action commits
   **When** windup begins
   **Then** the execution freezes the target owner, region identity, world transform, bounds, support normal, and base response version
   **And** later aim movement or another surface crossing the reticle cannot retarget the action
   **And** the static baseline target cannot move, resize, rotate, or exchange its collision region while the execution remains valid
   **And** target invalidation terminates the execution rather than silently selecting another wall.

7. **Telegraph the exact changing surface**

   **Given** the action is in its 1.0-second windup
   **When** primitive presentation observes the frozen region
   **Then** it marks the complete future affected wall without extending onto adjacent walls, floors, or grapple anchors
   **And** non-color-only boundary, thorn, instability, or direction cues communicate that the wall will become hazardous and harder to traverse while remaining physically present
   **And** pending, active, and final expiry-warning states remain distinguishable
   **And** the telegraph is non-solid, non-damaging, and unable to modify surface queries or movement.

8. **Create one completely configured surface occurrence**

   **Given** windup completes with a valid source, target, response channel, and run
   **When** active execution begins
   **Then** the surface owner atomically creates one occurrence containing all movement, contact-damage, query, and presentation response entries before activation is published
   **And** no consumer can observe a partially applied state
   **And** activation failure leaves the immutable base response and every pre-existing compatible modifier unchanged.

9. **Resolve one typed surface-response snapshot**

   **Given** a gameplay or presentation consumer queries the active wall
   **When** its `SurfaceStateOwner3D` resolves the requested surface region
   **Then** it returns one immutable response snapshot containing movement, contact-damage, collision-query, grapple-query, semantic-tag, and presentation facts
   **And** the snapshot identifies the surface, region, base-response version, contributing modifier occurrences, resolution order, current run, and validity interval
   **And** consumers cannot inspect presentation nodes or mutable occurrence internals to infer gameplay behavior.

10. **Apply the altered wall-run response**

    **Given** the player has valid wall-run contact with the active infested region
    **When** wall locomotion resolves its typed surface response
    **Then** the current base wall-run target speed is multiplied by exactly 0.60 and its current base wall-run acceleration by exactly 0.50
    **And** the multipliers apply only while authoritative wall contact identifies that region
    **And** they do not restart the wall-run state, replace velocity, change gravity independently, or modify the shared player movement definition
    **And** contact with any unmodified region continues to use its ordinary response.

11. **Convert wall-stick into a controlled downward slide**

    **Given** the player is wall-sticking on the active region
    **When** the current locomotion step resolves
    **Then** the surface response requests downward surface-tangential acceleration of at most 12.0 metres per second squared toward a 3.0-metres-per-second downward component
    **And** the downward direction is world-down projected onto the frozen wall plane
    **And** the contribution never accelerates the player beyond that target by itself and never brakes an already faster downward slide
    **And** it is resolved through locomotion and the semantic motor pipeline rather than through a direct velocity write.

12. **Preserve immediate wall-jump recovery**

    **Given** the player is running, sticking, or sliding on the active wall
    **When** they perform a valid wall jump
    **Then** the existing wall-jump impulse, direction, command timing, resource rules, and state transition remain authoritative
    **And** the surface contributes no extra launch, forced failure, jump-direction change, or post-detachment influence
    **And** leaving contact immediately removes the wall-run and wall-stick response changes.

13. **Capture one immutable contact-damage snapshot**

    **Given** the infestation becomes active with a valid source
    **When** its damage behavior is configured
    **Then** it stores one immutable source-side snapshot for four damage with stable source, execution, occurrence, definition, and run attribution
    **And** later source stat changes cannot alter that occurrence's damage
    **And** the snapshot applies no knockback, stun, stagger, input gating, forced movement reaction, or repeated pulse schedule.

14. **Deliver contact damage exactly once per recipient**

    **Given** an eligible living player first establishes authoritative body contact with the active region
    **When** surface-contact delivery resolves
    **Then** one delivery identity derived from occurrence and recipient produces at most one accepted four-damage result
    **And** duplicate shapes, contact points, physics callbacks, wall-state changes, or repeated frames cannot deliver it again
    **And** leaving and re-entering the same occurrence does not reset eligibility
    **And** grapple attachment, targeting, ray contact, attack contact, or proximity without player-body contact cannot trigger the damage.

15. **Handle activation beneath an existing contact fairly**

    **Given** the player remains in authoritative body contact throughout windup
    **When** the infestation becomes active
    **Then** that existing contact is evaluated once as the recipient's first active contact
    **And** the wall-run or wall-stick response changes on the next eligible locomotion step without cancelling the current traversal state
    **And** the player can use the telegraphed windup to jump, grapple, or leave before activation
    **And** activation creates no displacement or velocity discontinuity.

16. **Expose explicit query and hazard responses**

    **Given** the active surface is inspected by collision, traversal, targeting, or diagnostic queries
    **When** its resolved response snapshot is returned
    **Then** collision remains solid, wall traversal remains eligible with the declared modified response, and the semantic `HAZARDOUS_SURFACE` tag is present
    **And** the query response communicates that first-contact damage may apply without presenting the wall as absent or completely unusable
    **And** neighboring geometry and the same wall after restoration do not inherit that tag
    **And** query facts derive from surface state rather than material names, visual shaders, node names, or collision-layer mutation.

17. **Preserve the wall's ordinary grapple response**

    **Given** the active region was grappleable before infestation
    **When** the player targets or attaches to it
    **Then** it remains grappleable through its existing `Grappleable3D` response with the same attachment point, range, pull profile, moving-target policy, and maximum-distance behavior
    **And** the grapple reticle or equivalent feedback also communicates the resolved hazardous-surface tag
    **And** attaching alone does not count as player-body contact
    **And** reaching the wall physically may still produce the single contact-damage result
    **And** this occurrence cannot also apply Story 4.5's weakened-anchor modifier.

18. **Resolve compatible surface modifiers deterministically**

    **Given** the surface owns its immutable base response and one or more compatible runtime modifiers in distinct response channels
    **When** it resolves a response snapshot
    **Then** it applies the base response, active modifiers under fixed channel rules and stable occurrence ordering, and final safety validation in that declared precedence
    **And** multiplicative movement values combine through their declared operation, semantic tags form a stable deduplicated set, distinct damage deliveries retain their own identities, and presentation facts remain attributed
    **And** registration, callback, node, and dictionary iteration order cannot change the result
    **And** one focused alternate test proves that removing the infestation preserves a compatible modifier owned by another channel.

19. **Reject conflicting reapplication atomically**

    **Given** the target already owns a windup or active modifier in the exclusive `ROUTE_HAZARD` channel
    **When** the same or another source requests a conflicting modifier
    **Then** the complete later request is rejected without refreshing duration, multiplying movement penalties, adding damage, replacing attribution, changing the end time, or partially changing any response channel
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** a new application becomes eligible only after the previous occurrence reaches a terminal state and cadence permits it.

20. **Restore the surface by removing only the occurrence**

    **Given** the infestation expires or terminates while the surface remains valid
    **When** its target-owned occurrence is removed
    **Then** the surface recomputes its response from the immutable base definition and any remaining compatible modifiers
    **And** it does not restore a cached snapshot that could overwrite newer state
    **And** an attached grapple and existing wall contact consume the restored response on their next eligible step without reconnecting or restarting their state
    **And** restoration creates no velocity refund, movement impulse, health refund, duplicate damage opportunity, or collision discontinuity.

21. **Handle source loss, target loss, and reset safely**

    **Given** the source dies or is removed during windup
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** the telegraph cancels and no surface occurrence becomes active.

    **Given** the source dies or is removed during active use
    **When** the same policy resolves
    **Then** the occurrence terminates, the base surface response is restored, and accepted damage remains accepted.

    **Given** the target owner or region becomes invalid
    **When** invalidation resolves
    **Then** the occurrence terminates without retaining a surface, contact, damage, query, or presentation reference.

    **Given** the fixture resets, checkpoint reloads, or the scene exits during any lifecycle phase
    **When** the old run is invalidated
    **Then** executions, occurrences, response entries, accepted-recipient records, pending damage, cues, cadence state, and late callbacks are removed or rejected exactly once
    **And** the fresh run begins with the authored base surface response.

22. **Provide viable counterplay and recovery routes**

    **Given** the named infested-wall fixture is active
    **When** the player evaluates the route
    **Then** they can leave during windup, use an equivalent unmodified wall, use an alternate grapple route, wait for expiry, or kill the source
    **And** they may intentionally accept the one contact hit and reduced wall performance because wall-running, wall-sticking, wall-jumping, and grappling remain available
    **And** a player who contacts the wall can immediately recover through wall jump, grapple, or the fixture's lower recovery route
    **And** the affected wall is never the only route required to avoid unavoidable repeated damage.

23. **Keep surface-state behavior configurable**

    **Given** an alternate valid definition changes windup, duration, expiry warning, range, cadence, wall-run multipliers, wall-stick slide acceleration or target component, contact damage, delivery uniqueness, semantic tags, stacking channel, conflict policy, or source-death policy
    **When** the same action, surface owner, locomotion, damage, query, and presentation implementations consume it
    **Then** lifecycle and all typed response channels use the authored values without code changes
    **And** at least one alternate-profile test proves timing, movement response, damage, and tags are not hard-coded
    **And** arbitrary mesh painting, spreading growth, dynamic or deforming surfaces, collision-shape changes, physics-material mutation, periodic damage, floor and ceiling variants, surface destruction, anchor-response modification, and final presentation remain outside this story.

24. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, windup, activation, contact, damage, altered traversal, expiry warning, expiry, stacking, rejection, source loss, target loss, or reset occurs
    **Then** primitive region outlines, thorn markers, movement-response indicators, hazard reticle cues, contact markers, state changes, and typed result displays communicate the mechanic
    **And** future material changes, mesh growth, animation, particles, audio, camera feedback, and VFX can consume committed surface facts without controlling lifecycle, movement, queries, collision, or damage
    **And** diagnostics expose stable identities, region geometry, base-response version, lifecycle times, contributing modifiers and resolution order, movement values, contact state, accepted recipients, damage result, grapple and hazard responses, stacking result, source policy, run identity, and terminal reason.

25. **Make surface-state counterplay manually reproducible**

    **Given** the named infested-wall fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can compare otherwise identical normal and infested walls, measure wall-run speed and acceleration, observe wall-stick sliding, wall-jump away, grapple the region without body contact, deliberately contact it once, leave and re-enter, use alternate routes, and remain on it through expiry
    **And** they can begin activation while already touching the wall, test region edges and neighboring geometry, attempt implicit and invalid targets, request duplicate and conflicting states, retain a compatible modifier, kill the source during windup and active use, invalidate the target, and reset during every lifecycle phase
    **And** retained evidence distinguishes objective targeting, timing, movement, contact-damage uniqueness, query, grapple, stacking, restoration, cleanup, and repeatability results from subjective observations about cue clarity, route value, punishment, recovery, altered movement feel, duration, and whether the wall remains worth using.

26. **Verify deterministic surface mutation and restoration**

    **Given** the permanent surface-state suite and focused real-Jolt fixture run
    **When** they exercise valid and invalid targets, range and line-of-sight edges, region boundaries, exact lifecycle times, activation during existing contact, normal and high-speed contact, duplicate contact shapes, wall-run, wall-stick, wall-jump, grapple attachment, compatible and conflicting modifiers, source and target invalidation, stale runs, randomized registration and callback order, and repeated reset
    **Then** every accepted occurrence produces one deterministic resolved response, each recipient receives no more than one attributed contact hit, shared definitions remain unchanged, and removal restores the base plus surviving compatible state exactly
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve lifecycle timing, movement response, contact eligibility, damage results, query facts, stacking, restoration, cadence, and cleanup within documented tolerances
    **And** the story has not implemented arbitrary surface painting, spreading, geometry changes, periodic damage, destructible surfaces, anchor modification, ability combinations, or final presentation.
