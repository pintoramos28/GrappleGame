---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 5
---

# Story 3.5: Apply One-Shot Knockback with Recovery

As a player,
I want a powerful hit to displace me once in a readable direction while leaving me control and a route back,
So that knockback creates a movement-recovery problem rather than a stun-lock.

**Acceptance Criteria:**

1. **Declare the displacement gameplay question**

   **Given** the knockback prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player avoids the telegraphed hit or recovers useful movement after their velocity changes
   **And** its primary counter, recovery surfaces, grapple and wall interactions, source-death policy, reset behavior, overlap rule, provisional tuning questions, manual procedure, and required evidence are explicit
   **And** the scenario reuses the Story 3.4 direct lane shot as its readable delivery rather than implementing another pressure mechanic.

2. **Define one immutable knockback policy**

   **Given** the displacement effect is authored
   **When** its typed definition is inspected
   **Then** it declares a stable effect identity, application gate, direction mode, velocity-change magnitude, optional directional shaping, target-state eligibility, motor phase, distinct-occurrence aggregation rule, cap interaction, source-death behavior, and presentation reference
   **And** the representative prototype uses the committed projectile-delivery direction as its direction mode
   **And** magnitude is represented as a one-time velocity change rather than a rate multiplied by physics delta
   **And** all mutable pending, consumed, rejected, and applied occurrence state remains outside the shared definition.

3. **Create displacement only from an accepted impact**

   **Given** the direct lane projectile reaches a candidate target
   **When** its authoritative swept hit query resolves
   **Then** a knockback occurrence can be created only from an accepted impact against an eligible living player
   **And** a miss, blocking cover contact, rejected target, duplicate delivery, stale run, or malformed impact cannot produce displacement
   **And** the definition explicitly records whether its accepted-impact displacement depends on successful health damage rather than allowing receiver code to infer that relationship.

4. **Derive direction from committed impact facts**

   **Given** an accepted projectile impact creates a knockback occurrence
   **When** its velocity-change vector is calculated
   **Then** direction comes from the immutable delivery-motion facts in `ImpactContext` and magnitude comes from the immutable knockback definition
   **And** no effect code queries the current projectile node, source transform, player controller, camera, animation, or presentation to reconstruct direction
   **And** missing, zero-length, non-finite, or otherwise invalid required direction data rejects the occurrence with a typed reason rather than applying an arbitrary fallback vector.

5. **Identify each occurrence stably**

   **Given** a valid knockback effect is created
   **When** it enters the player's external-effect boundary
   **Then** it carries a stable occurrence identity derived from the source, ability execution, delivery occurrence, effect definition, target, and run
   **And** it records the impact physics step, immutable velocity-change vector, application policy, and source attribution
   **And** the player external-effect owner--not the projectile, damage receiver, AI, or motor--owns its pending and consumed runtime state.

6. **Schedule application at a declared motor boundary**

   **Given** an accepted impact may occur before or after the player motor's one-shot phase for the current physics step
   **When** the external-effect owner accepts the occurrence
   **Then** it assigns one explicit eligible motor step according to a single documented scheduling policy
   **And** it never applies after an already-completed motor commit or changes timing according to scene-tree processing order
   **And** diagnostics expose the impact step, eligible step, actual application step, and any bounded physics-step latency.

7. **Submit through the one-shot impulse phase**

   **Given** the occurrence reaches its eligible active motor step and the player remains valid
   **When** external effects submit movement influences
   **Then** the velocity-change vector is submitted once through the player motor's one-shot impulse API with its stable occurrence identity
   **And** it resolves after base movement and sustained influences but before constraints, redirections, caps, and the single final movement commit
   **And** the effect never assigns final velocity, changes global position, calls `move_and_slide()`, or invokes a player locomotion transition directly.

8. **Preserve existing momentum rather than replacing it**

   **Given** the player has nonzero velocity before knockback applies
   **When** the motor resolves the one-shot impulse
   **Then** the authored velocity change combines with the movement accumulated earlier in the semantic pipeline
   **And** it does not silently zero unrelated tangential, vertical, grapple-derived, or traversal momentum
   **And** the resulting velocity remains subject to the declared safety caps and later constraints.

9. **Apply each occurrence at most once**

   **Given** the same knockback occurrence reaches the external-effect owner through duplicate callbacks, repeated damage notifications, multiple hurtboxes, replayed events, or repeated motor submissions
   **When** application is attempted more than once
   **Then** only its first valid application may change velocity
   **And** later attempts return the existing result or a typed duplicate rejection
   **And** presentation, reactions, and diagnostics do not falsely report another applied impulse.

10. **Aggregate distinct simultaneous impulses deterministically**

    **Given** two genuinely distinct eligible knockback occurrences share an application step
    **When** the one-shot phase resolves them
    **Then** they follow the motor's declared phase-specific aggregation and final-cap rules using stable occurrence identities
    **And** insertion, node, or signal order cannot change the resulting velocity
    **And** this contract does not yet design repeated control chains or the later predictive-mark-plus-knockback combination.

11. **Resolve displacement through ordinary collision movement**

    **Given** a knockback velocity has been resolved
    **When** the player motor performs its single movement commit
    **Then** normal swept body collision, sliding, contact publication, and movement tolerances govern the resulting displacement
    **And** the effect cannot teleport the player through walls, floors, cover, or recovery surfaces
    **And** impact with geometry may change the committed result through normal collision response without reapplying the original impulse.

12. **Preserve active-grapple ownership**

    **Given** the player is grappling when knockback applies
    **When** the motor reaches constraints and redirections
    **Then** the grapple remains active unless its own typed invalidation policy ends it
    **And** the maximum-distance constraint may clip or redirect only motion that would cross the true maximum boundary while inward and tangential components remain available
    **And** knockback cannot directly cancel, retarget, lengthen, or replace the grapple
    **And** the player can use the active grapple or a later grapple as an authored recovery option.

13. **Let wall-state changes emerge from authoritative contacts**

    **Given** the player is wall-running or wall-sticking when displaced
    **When** the impulse changes their resulting motion or contact
    **Then** the motor and subsequent `ContactFrame` report the actual collision outcome
    **And** the locomotion owner may continue or leave the wall state according to its existing policy
    **And** the knockback effect cannot directly force a private HSM transition, fabricate wall loss, or permanently disable wall traversal.

14. **Preserve player agency after displacement**

    **Given** a nonlethal knockback has applied
    **When** the player attempts to recover
    **Then** ordinary air control, jumping where eligible, grappling, wall interaction, and available route choices continue under their existing policies
    **And** the fixture supplies at least one nearby recovery surface or grapple target reachable under the provisional displacement tuning
    **And** recovery success depends on player response rather than an automatic scripted return.

15. **Avoid creating a control chain**

    **Given** the player is struck once
    **When** the delivery and displacement complete
    **Then** no continuing force, stun timer, input suppression, repeated impulse, or hidden movement lock remains from that occurrence
    **And** another attack requires a distinct authored execution and occurrence
    **And** the source's attack cadence and the player's demonstrated recovery time leave a manually verified response window.

16. **Handle death, source removal, and reset explicitly**

    **Given** a lethal damage result commits before a queued knockback becomes eligible
    **When** the player motor processes terminal and gating phases
    **Then** dead-state policy rejects or clears the pending impulse without moving the dead player.

    **Given** an accepted nonlethal impact has committed its knockback occurrence
    **When** the source is removed before the eligible motor step
    **Then** the occurrence retains its immutable source attribution and applies according to its authored post-impact source-death policy without dereferencing the source node.

    **Given** the fixture resets before or after application
    **When** the prior run is invalidated
    **Then** pending occurrences, consumed-history state, presentation, and late submissions from that run are removed or rejected exactly once.

17. **Provide replaceable feedback and motor diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** the hit, queued displacement, applied impulse, collision, recovery, rejection, or reset occurs
    **Then** primitive impact feedback and a bounded directional indicator communicate the displacement source and direction
    **And** future reactions, animation, audio, camera, and VFX consume committed impact and motor results without changing them
    **And** diagnostics expose occurrence identity, impact and application steps, pre-impulse velocity, raw velocity-change vector, aggregation result, constraint or cap changes, collision result, committed velocity, and rejection reason using the existing motor snapshot.

18. **Make knockback and recovery manually reproducible**

    **Given** the named knockback fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can avoid the lane shot, deliberately receive one knockback, observe its direction, and recover using the fixture's intended movement option
    **And** they can repeat the hit while grounded, airborne, grappling, wall-running or wall-sticking where the fixture supports those states; decline recovery to observe the failed response; and inspect the resulting collision and locomotion behavior
    **And** they can test source removal, manual reset, and repeated runs while distinguishing objective one-shot and cleanup results from subjective magnitude and recovery-feel notes.

19. **Verify one-shot displacement**

    **Given** the permanent knockback suite and focused real-Jolt fixture run
    **When** they exercise accepted and rejected impacts, missing delivery direction, duplicate hurtboxes, duplicate notifications, two distinct same-step occurrences, varying node and insertion order, pre-existing player velocity, grounded and airborne movement, active grapple constraints, wall contacts, geometry collision, lethal damage, source removal, stale runs, and repeated reset
    **Then** each accepted occurrence applies through the one-shot phase no more than once and produces the declared collision-aware movement result
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve the impulse vector, hit count, resulting motion, and recovery opportunity within documented physics and scheduling tolerances.

20. **Contribute one bounded family representative**

    **Given** Story 3.5 is reviewed for completion
    **When** its manual and automated evidence is inspected
    **Then** one direct-lane impact demonstrates the Motor Influence family's one-shot form through immutable policy, stable occurrence identity, semantic motor submission, deterministic aggregation, collision response, counterplay, and recovery
    **And** the project and previous fixtures remain runnable with valid retained references
    **And** the story has not implemented sustained wind, adhesive movement, tether constraints, stagger, poise break, launch combos, repeated control chains, final presentation, or the full six-family gate.
