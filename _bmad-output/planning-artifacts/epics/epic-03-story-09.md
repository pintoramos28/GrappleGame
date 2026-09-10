---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.9'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 9
---

# Story 3.9: Select a Readable Anti-Wall Harpoon from Player Context

As a player,
I want designated enemies to answer prolonged wall use with a readable and avoidable attack,
So that walls remain valuable traversal tools without becoming universally safe positions.

**Acceptance Criteria:**

1. **Declare the contextual gameplay question**

   **Given** the anti-wall prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player notices and escapes an attack selected because they remained on a wall
   **And** its triggering context, intended source, attack choice, telegraph, counters, recovery, grapple and wall interactions, fallback behavior, tuning questions, manual procedure, and required evidence are explicit
   **And** it remains a contextual selection policy rather than a new damage, movement, or wall-disabling system.

2. **Publish bounded wall-use facts from the player owner**

   **Given** the player movement HSM commits a physics step
   **When** its public tactical state is published
   **Then** the immutable snapshot identifies the physics step and run, current locomotion state, stable wall-contact identity where applicable, whether the contact remains valid, and continuous time on that contact
   **And** continuous time persists when the player changes between wall-running and wall-sticking on the same valid contact
   **And** leaving wall contact, wall-jumping, changing contact identity, dying, or changing run resets the continuous-wall-use interval
   **And** no enemy reads private movement-state nodes, timers, collision objects, or state-name strings.

3. **Extend the existing enemy tactical snapshot**

   **Given** an anti-wall-capable enemy evaluates perception
   **When** its `EnemyTacticalSnapshot` is created
   **Then** the snapshot includes the target's bounded locomotion state, wall-contact identity, continuous wall-use time, position, velocity, visibility, line of sight, distance, alive state, and run identity
   **And** it retains the existing enemy identity, position, current action, target, and physics-step facts
   **And** behavior-tree tasks consume that one immutable snapshot rather than repeating player-state or physics queries.

4. **Author one immutable contextual action policy**

   **Given** the representative anti-wall policy is inspected
   **When** its configured values are resolved
   **Then** it requires `WALL_RUNNING` or `WALL_STICKING` on one continuous contact for at least 0.60 seconds, current line of sight, and a three-dimensional source-to-target distance between 6.0 and 18.0 metres
   **And** it references one approved anti-wall harpoon `AttackDefinition`, declares its contextual branch ordering and fallback intent, and identifies which source definitions may use it
   **And** its thresholds and referenced definitions are authored data rather than behavior-tree literals.

5. **Use one readable harpoon attack profile**

   **Given** the contextual policy selects its referenced harpoon
   **When** that attack definition is inspected
   **Then** it reuses Story 3.7's harpoon delivery, target-owned link, motor influence, cover break, maximum-length break, source-death, and cleanup contracts
   **And** the baseline attack has a 0.80-second windup, tracks during its first 0.40 seconds, locks for its final 0.40 seconds, launches a swept projectile at 20.0 metres per second with a 0.25-metre radius, and has a 6.0-second start-to-next-start cadence
   **And** the resulting link retains Story 3.7's 4.0-second lifetime and other approved link values
   **And** timing, projectile, link, and contextual thresholds each retain one authoritative definition owner.

6. **Limit the policy to explicitly opted-in sources**

   **Given** multiple enemy or pressure-source definitions exist
   **When** contextual policies are initialized
   **Then** only definitions that explicitly reference the anti-wall policy may evaluate or request its harpoon
   **And** ordinary melee, ranged, climbing, flying, or fixture enemies do not acquire the behavior merely by sharing a scene, behavior tree, group, or attack asset
   **And** missing or invalid policy references disable the contextual branch with a development-visible typed result.

7. **Require every eligibility gate**

   **Given** an opted-in source is alive, active, and not already executing an action
   **When** the contextual branch evaluates a current tactical snapshot
   **Then** it becomes eligible only when the target is alive in the same run, remains wall-running or wall-sticking on one contact for at least 0.60 seconds, is visible with current line of sight, is within the inclusive 6.0-to-18.0-metre range, and the referenced harpoon is available
   **And** wall-jumping, ordinary airborne movement, grappling without wall contact, grounded movement, target-loss grace without current line of sight, or a failed range gate does not satisfy the policy
   **And** every rejected gate produces an inspectable reason without starting an ability.

8. **Evaluate continuous wall use consistently**

   **Given** the player transitions between wall-running and wall-sticking on the same wall contact
   **When** the anti-wall policy evaluates the elapsed interval
   **Then** those states count as one continuous period of wall use.

   **Given** the player leaves the wall before 0.60 seconds, wall-jumps, or transfers to a different contact identity
   **When** a later snapshot is evaluated
   **Then** the previous interval does not satisfy the threshold
   **And** the player must remain on the new valid contact for a fresh 0.60-second interval.

9. **Choose the contextual branch deterministically**

   **Given** every anti-wall gate is satisfied while ordinary behavior branches are also possible
   **When** the opted-in source selects its next intent
   **Then** the baseline policy evaluates the anti-wall harpoon before its ordinary ranged or pursuit fallback
   **And** one stable policy and snapshot identity explains the selected branch
   **And** the outcome cannot depend on behavior-tree node insertion, signal order, render timing, diagnostic state, or presentation.

10. **Request rather than execute the attack**

    **Given** the contextual branch selects the anti-wall harpoon
    **When** its LimboAI task acts
    **Then** it submits one typed `EnemyAbilityRequest` containing the referenced attack, target, current tactical snapshot, request identity, source, and run
    **And** it cannot activate the projectile, link, hit response, telegraph, timer, damage, or player movement directly
    **And** the AI observes the returned request and execution result rather than inferring success from animation or elapsed time.

11. **Revalidate through the normal action owner**

    **Given** the contextual request reaches the source's action owner
    **When** ability start is evaluated
    **Then** the owner independently validates source and target validity, current run, action availability, cadence, attack definition, range, line of sight, and required resident assets
    **And** rejection commits no partial windup, cooldown, telegraph, projectile, or link
    **And** the action owner does not reach back into the player movement HSM to repeat or reinterpret the contextual wall-state decision.

12. **Treat wall context as a selection fact, not an ongoing attack requirement**

    **Given** an anti-wall request has been accepted
    **When** the player leaves the wall, wall-jumps, grapples away, or changes locomotion state during windup or delivery
    **Then** the committed harpoon proceeds through its ordinary lifecycle rather than cancelling or retargeting solely because the selection context changed
    **And** it tracks only during the first 0.40 seconds, freezes its authoritative lane at the lock boundary, and cannot home after lock
    **And** leaving the wall becomes a legitimate evasion action rather than a hidden cancellation exploit.

13. **Keep warning and delivery aligned**

    **Given** the anti-wall harpoon enters windup
    **When** its tracking and lock phases advance
    **Then** the primitive lane warning consumes the same spatial binding, origin, direction, length, and 0.25-metre projectile radius used by delivery
    **And** the tracking-to-locked transition is observable before launch
    **And** the projectile uses the existing swept collision and cover-blocking behavior
    **And** no wall-relative presentation offset changes the authoritative attack path.

14. **Preserve several viable counters**

    **Given** the player recognizes the anti-wall windup
    **When** they leave the wall, wall-jump, change altitude or lateral direction after lock, grapple to another route, or place eligible cover in the projectile path
    **Then** the frozen non-homing delivery can miss or be blocked through its ordinary rules
    **And** a player hit by the harpoon retains Story 3.7's cover break, distance break, active-grapple interaction, and duration-based recovery options
    **And** the fixture demonstrates at least one successful pre-impact counter and one successful post-impact recovery.

15. **Keep wall traversal tactically valuable**

    **Given** the anti-wall-capable source is present
    **When** the player uses wall-running, wall-sticking, or wall-jumping
    **Then** those abilities retain their normal movement, momentum, input, contact, and transition policies
    **And** the anti-wall mechanic never disables a wall surface, shortens wall-state duration, forces detachment, suppresses input, writes velocity, or changes private locomotion state
    **And** the 0.60-second threshold, readable windup, six-second cadence, limited source eligibility, and ordinary projectile counters leave deliberate short-duration wall use valuable.

16. **Preserve grapple and motor ownership**

    **Given** the player grapples before, during, or after anti-wall selection
    **When** the attack and any resulting tether interact with movement
    **Then** the player grapple remains independently owned and cannot be cancelled merely because anti-wall context was detected
    **And** any accepted harpoon link submits only Story 3.7's sustained influence through the motor
    **And** the player's maximum grapple boundary, normal constraints, collision, and final movement commit retain their approved ordering.

17. **Fall back safely without request spam**

    **Given** any contextual gate fails or the action owner rejects the request
    **When** the behavior policy evaluates its next intent
    **Then** it chooses the declared ordinary hold, pursue, or ranged fallback from a later committed snapshot
    **And** it does not attack through cover, fabricate wall state, repeatedly submit the same occurrence each tick, bypass cadence, or remain stuck in a failed branch
    **And** an accepted or pending request is observed until it reaches a result before another contextual occurrence can be submitted.

18. **Clear contextual state on death, target loss, and reset**

    **Given** the source or player dies, the target becomes invalid, the source is disabled, or the encounter run changes
    **When** AI and action owners process the event
    **Then** wall-context working memory, pending intent, request identity, and stale snapshots are cleared or rejected
    **And** committed harpoon delivery and link cleanup follow their existing source-death and run-invalidation policies
    **And** reactivation begins from a fresh tactical snapshot with no inherited wall-use duration or cadence state from the prior run.

19. **Keep contextual tuning configurable**

    **Given** an alternate anti-wall policy changes wall-state eligibility, continuous-use threshold, minimum or maximum range, current-line-of-sight requirement, branch ordering, fallback, intended sources, or referenced normal ability
    **When** the same contextual evaluator consumes it
    **Then** selection and diagnostics use the authored policy without behavior-tree code changes
    **And** at least one alternate-profile test proves that the wall-use threshold and range are not hard-coded
    **And** predictive aiming, wall-surface mutation, direct player-state reactions, universal tactical scoring, and a general ability-planning framework remain outside this story.

20. **Provide replaceable feedback and decision diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** wall context approaches eligibility, the branch selects or rejects, the action commits, the lane tracks or locks, or the attack resolves
    **Then** primitive source, lane, lock, projectile, impact, and tether cues communicate the player-facing threat
    **And** future animation, audio, camera, and VFX can consume committed action facts without controlling selection or execution
    **And** development diagnostics expose snapshot and physics-step identities, target locomotion state, contact identity, continuous wall-use time, distance, visibility, line of sight, every contextual gate, selected branch, policy and request identities, action-owner result, execution identity, and terminal reason.

21. **Make contextual anti-wall pressure manually reproducible**

    **Given** the named anti-wall fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can remain grounded and confirm no contextual request, leave a wall before 0.60 seconds, transition between run and stick on one contact, transfer contacts, remain on a wall long enough to trigger the attack, and observe the tracking and lock boundary
    **And** they can counter by leaving or jumping from the wall, changing direction after lock, grappling away, and using cover; deliberately accept the harpoon; and recover through the existing tether counters
    **And** they can test the 6.0- and 18.0-metre boundaries, current line-of-sight requirement, six-second cadence, an enemy without the opt-in policy, source and player death, target loss, reset, and repeated runs
    **And** the evidence distinguishes objective context, selection, request, execution, counter, and cleanup results from subjective observations about threshold, warning time, projectile speed, and how strongly the behavior discourages prolonged wall use.

22. **Verify the family representative**

    **Given** the permanent contextual-action suite and focused real-Jolt fixture run
    **When** they exercise every eligible and rejected locomotion state, exact dwell and range boundaries, same-contact state transitions, contact changes, current and lost line of sight, branch competition, action rejection, request deduplication, moving targets, post-commit wall exit, grapple interaction, source and target loss, stale snapshots, randomized processing order, and repeated reset
    **Then** equivalent tactical inputs produce the same normal ability request and no AI task performs gameplay execution or player mutation
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time eligibility, selected branch, windup and lock timing, request count, delivery result, cadence, and recovery opportunity within documented tolerances
    **And** this establishes one bounded Contextual AI Action representative without adding a universal planner, private player-state access, homing behavior, wall disabling, a production anti-wall enemy, final presentation, or the full six-family gate.
