---
artifact_schema: 1
artifact_id: 'grapplegame.story.5.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 5
story: 4
---

# Story 5.4: Interrupt a Healing Support Tether

As a player,
I want a healing tether to clearly identify its source, relay, recipient, pulse timing, and interruption options,
So that I can stop enemy support by attacking the source, destroying the relay, or breaking the connection.

**Acceptance Criteria:**

1. **Declare the support-tether gameplay question**

   **Given** the healing-support prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player identifies an active support relationship and chooses among attacking the source, destroying its relay, or breaking a tether segment
   **And** its target eligibility, windup, relay placement, healing schedule, counters, recovery, grapple and wall interactions, interruption, source-death, recipient-loss, overlap, reset, tuning, manual procedure, and evidence policies are explicit
   **And** it remains one source, one relay, one recipient, and one healing behavior rather than a multi-target support encounter or general buff system.

2. **Reuse the approved lifecycle, link, health, and target contracts**

   **Given** earlier stories have established timed actions, target-owned links, scoped world effects, health changes, damage attribution, targetability, and grapple invalidation
   **When** healing support is implemented
   **Then** it composes those existing contracts with distinct support definitions
   **And** it does not introduce another ability executor, timer framework, status store, health component, target system, grapple implementation, or cleanup manager
   **And** healing uses a typed positive support request rather than negative damage or direct health mutation.

3. **Author one immutable support definition**

   **Given** the baseline healing-tether profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 0.75-second windup, 6.0-second active duration, final 1.0-second expiry warning, first healing pulse at 1.0 active seconds, 1.0-second pulse interval, five-pulse maximum, and five health per pulse
   **And** it declares a 20.0-metre source-to-recipient targeting range, 12.0-metre maximum length for each relay segment, 0.50-second continuous invalid-segment break time, 16 relay health, and 8.0-second start-to-next-start cadence
   **And** it declares one unresolved support execution per source, one active `HEALING_SUPPORT` link per recipient, rejection-based reapplication, `CANCEL_WITH_SOURCE`, `INTERRUPT_ON_ACCEPTED_PLAYER_DAMAGE`, and an atomic relay-and-link creation policy
   **And** these values remain authored configuration rather than literals in the action, link, relay, healing scheduler, fixture, or presenter.

4. **Keep runtime support state outside shared definitions**

   **Given** a support execution, link, relay, or healing occurrence exists
   **When** its runtime state is inspected
   **Then** it records stable definition, execution, source, recipient, relay, link, healing-pulse, player-attacker, and run identities; lifecycle times; endpoint snapshots; validity and break progress; applied and skipped pulses; relay health; interruption result; and terminal reason
   **And** mutable state never changes the shared ability, support, health, damage, target, grapple, query, or presentation definitions
   **And** the source action owner, recipient effect owner, relay health owner, and recipient health owner retain separate authoritative responsibilities.

5. **Request support through the normal action boundary**

   **Given** the fixture or support AI requests healing tether for an intended recipient
   **When** the request reaches its action owner
   **Then** the owner validates source and recipient identities, allied relationship, living state, missing health, current action, targeting range, initial line of sight, cadence, source and recipient link limits, run identity, definitions, effect bounds, and required resident assets before committing one execution
   **And** AI may choose an intended recipient from its existing tactical information but cannot create the link, place the relay, schedule healing, change health, or interrupt the result directly
   **And** rejected, duplicate, busy, full-health, hostile, dead, invalid, and stale requests produce typed results without a partial preview or reservation.

6. **Reserve the source and recipient atomically**

   **Given** an eligible support request is ready to enter windup
   **When** execution commits
   **Then** the source's unresolved-support slot and recipient's `HEALING_SUPPORT` channel are reserved under the same execution identity
   **And** failure to acquire either reservation releases both without beginning windup
   **And** simultaneous requests resolve through stable request identity rather than scene-tree or callback order
   **And** reservations do not themselves heal, alter targeting, or expose an active link.

7. **Track valid endpoint anchors during windup**

   **Given** the execution is winding up
   **When** current support-source and recipient-anchor snapshots are sampled
   **Then** each snapshot provides stable owner and run identity, finite world position and velocity, living state, and current eligibility through a typed binding
   **And** neither endpoint is reconstructed from a rendered beam, animation socket without a gameplay binding, or an arbitrary node path
   **And** target movement may update the provisional relay position throughout windup
   **And** invalid, stale, missing, discontinuous, or out-of-range endpoints cancel with a typed reason.

8. **Resolve one provisional midpoint relay**

   **Given** valid source and recipient anchors exist during windup
   **When** relay placement is calculated
   **Then** its candidate center is the exact midpoint between the two current anchors
   **And** a named sphere-clearance query verifies its complete 0.50-metre presentation and targeting region lies inside effect bounds, outside protected player space, and clear of prohibited static geometry
   **And** both resulting endpoint segments must satisfy their 12.0-metre maximum length and named line-of-sight profile
   **And** an invalid midpoint cancels rather than adding a hidden offset, choosing another relay, or connecting source directly to recipient.

9. **Preview the source, relay, recipient, and counters**

   **Given** a valid provisional relay exists during the 0.75-second windup
   **When** primitive presentation observes the execution
   **Then** it displays the future relay, source-to-relay segment, relay-to-recipient segment, support direction, and activation progress
   **And** source, relay, and recipient use distinguishable non-color-only shapes or motion cues
   **And** the preview communicates that the source and relay will be interruptible
   **And** the preview remains non-targetable, non-grappleable, non-healing, non-solid, and unable to establish an active link.

10. **Revalidate and freeze relay placement at activation**

    **Given** windup reaches its active boundary
    **When** activation is prepared
    **Then** fresh source and recipient anchor snapshots, allied and living state, missing health, range, both segment lengths, both line-of-sight results, relay clearance, reservations, and current run are revalidated
    **And** the valid midpoint becomes one frozen world-space relay transform
    **And** later source or recipient movement cannot move or replace the relay
    **And** any failed requirement cancels activation and releases reservations without a partial relay, link, or healing pulse.

11. **Create the relay and recipient-owned link atomically**

    **Given** activation inputs remain valid
    **When** the support creation transaction commits
    **Then** exactly one configured relay is attached beneath the current fixture runtime root and one support-link occurrence is attached to the recipient's effect owner
    **And** relay and link receive their immutable definitions, stable identities, source and recipient bindings, lifecycle schedule, query profiles, healing snapshot, source policy, and terminal guards before either becomes active
    **And** the source action enters its channelled active state only after both creations succeed
    **And** any failure rolls back relay, link, reservations, presentation, and healing state without a hidden retry.

12. **Keep the link owned by the recipient**

    **Given** atomic activation succeeds
    **When** active support state is inspected
    **Then** the recipient's effect owner owns the `HEALING_SUPPORT` occurrence and its pulse history
    **And** the relay owns only its health, targetability, grapple response, and frozen transform
    **And** the source action owner publishes current channel state and receives typed interruption or terminal requests without directly modifying recipient health
    **And** presentation observes these owners without becoming a second source of link state.

13. **Follow moving endpoints without moving the relay**

    **Given** source or recipient moves normally while the link is active
    **When** each support-validation step begins
    **Then** the link reads current typed endpoint snapshots and forms two current segments through the fixed relay center
    **And** source or recipient movement may change segment direction, length, and line of sight
    **And** neither participant is parented, carried, steered, slowed, or constrained by the tether
    **And** invalid endpoint discontinuity terminates rather than producing an extreme or reconstructed segment.

14. **Suspend support immediately when a segment becomes invalid**

    **Given** the active link currently has two valid segments
    **When** either segment becomes occluded, exceeds 12.0 metres, loses a valid endpoint, or otherwise fails its named connection policy
    **Then** healing eligibility is suspended on that simulation step
    **And** one continuous invalid-segment accumulator begins or continues from the first invalid instant
    **And** the visual link identifies the failing segment and current break progress
    **And** no healing occurs through cover or beyond maximum segment length during the grace interval.

15. **Skip rather than defer blocked healing pulses**

    **Given** a scheduled pulse becomes due while either segment is invalid
    **When** pulse resolution occurs
    **Then** that pulse records a typed skipped result and applies no healing
    **And** the pulse is never stored, retried, combined with a later pulse, or delivered immediately when the segment clears
    **And** later pulses remain on the original global active-time schedule
    **And** skipped pulses still count toward the five-pulse maximum.

16. **Break only after continuous invalidity**

    **Given** at least one segment remains invalid continuously
    **When** the invalid-segment accumulator reaches 0.50 seconds
    **Then** the link terminates exactly once with a reason distinguishing cover, excessive length, endpoint loss, or invalid data
    **And** terminal resolution occurs before a healing pulse due at the same simulation time
    **And** relay, link, channel state, and remaining pulse schedule enter ordinary terminal cleanup.

    **Given** both segments become valid before 0.50 seconds
    **When** the next authoritative validation resolves
    **Then** the accumulator resets, healing eligibility resumes, and the original active lifetime and pulse schedule remain unchanged.

17. **Schedule exactly five healing opportunities**

    **Given** the link activates at authoritative active time zero
    **When** simulation-owned active elapsed time reaches 1.0, 2.0, 3.0, 4.0, and 5.0 seconds
    **Then** exactly one stable healing-pulse occurrence becomes due at each time
    **And** no pulse occurs at active time zero or at six-second expiry
    **And** a step crossing a due boundary processes the pulse exactly once using bounded ordered catch-up
    **And** render timing, beam animation, endpoint movement, obstruction recovery, and source AI cannot shift or restart the schedule.

18. **Submit healing through a typed health boundary**

    **Given** a pulse is due while source, recipient, relay, link, connection, and run remain eligible
    **When** the pulse delivers
    **Then** one immutable support snapshot requests five positive health through the recipient's health owner
    **And** the request carries stable source, execution, link, pulse, recipient, definition, and run attribution
    **And** the health owner returns requested, applied, rejected, and excess healing facts
    **And** the link, relay, source, AI, fixture, and presentation never assign recipient health directly or represent healing as negative damage.

19. **Apply each pulse no more than once**

    **Given** duplicate timers, lifecycle callbacks, recipient references, or delivery requests carry the same pulse identity
    **When** healing resolution occurs
    **Then** only the first eligible request can change health
    **And** all later duplicates return the committed result without additional healing or presentation
    **And** callback, listener, node, and dictionary ordering cannot change pulse count or applied amount
    **And** each pulse reaches one terminal result even if the recipient becomes invalid during delivery.

20. **Clamp healing and prohibit resurrection**

    **Given** the recipient is alive and below maximum health
    **When** an eligible five-health pulse resolves
    **Then** applied healing is limited to the missing-health amount and current health never exceeds the authoritative maximum
    **And** excess healing is reported without conversion to armor, temporary health, resistance, reward, or another status.

    **Given** the recipient is dead or reaches zero health before delivery
    **When** a due pulse evaluates eligibility
    **Then** healing is rejected and cannot revive, re-enable collision, restart AI, or recreate the combatant.

21. **End early when the recipient becomes full**

    **Given** an accepted pulse raises the recipient to maximum health
    **When** its committed health result returns
    **Then** the support link completes exactly once with a typed `RECIPIENT_FULL` reason
    **And** no later scheduled pulse is delivered
    **And** relay and channel cleanup follow the same terminal path as ordinary expiry
    **And** the completed link does not reserve the recipient against a later independently valid support request after cadence permits it.

22. **Interrupt windup or active support when the source is hit**

    **Given** the production player attack delivers an accepted positive-damage result to the support source during windup or active channeling
    **When** the source's typed interrupt policy observes that committed result
    **Then** the support execution or link terminates exactly once with `INTERRUPTED_BY_PLAYER_DAMAGE` unless source death has higher terminal precedence
    **And** interruption resolves before any healing pulse due at the same simulation time
    **And** a miss, rejected hit, friendly hit, zero applied damage, duplicate delivery, presentation contact, or attack against the recipient cannot trigger this interruption
    **And** the damage owner remains authoritative for the source's health result.

23. **Make the relay a damageable interruption target**

    **Given** the active relay has 16 maximum health
    **When** the production player attack delivers accepted damage to it
    **Then** the relay's existing health owner applies and attributes that damage exactly once per attack occurrence
    **And** relay health and hit feedback remain observable
    **And** reaching zero health commits one relay death and terminates the support link with `RELAY_DESTROYED` before any equal-time pulse
    **And** attacking the relay neither redirects the healing nor damages the source or recipient.

24. **Make the live relay usefully grappleable**

    **Given** the relay is active and alive
    **When** the player's ordinary grapple query selects it
    **Then** it supplies one explicit valid `Grappleable3D` response with its frozen center as the attachment point and the normal baseline pull and maximum-distance policies
    **And** the player can grapple toward or past it and attack it through existing traversal-combat coordination
    **And** grappling does not damage, move, disable, or otherwise interrupt the relay by itself
    **And** the support beams remain non-solid and non-grappleable.

25. **Invalidate an attached relay grapple safely**

    **Given** the player is attached to the relay when it dies, support terminates, expires, or resets
    **When** relay cleanup invalidates its grapple target
    **Then** the existing grapple controller ends the attachment exactly once with the appropriate typed target-invalid reason
    **And** resolved player velocity is preserved
    **And** cleanup creates no snap, teleport, fall-state command, replacement anchor, or hidden grapple cooldown
    **And** stale relay references cannot be selected in the next run.

26. **Do not let recipient damage interrupt support**

    **Given** the player damages the supported recipient without killing it
    **When** the link processes the committed damage and current health
    **Then** the link remains active if all other requirements are valid
    **And** damage does not reset pulse timing, refresh duration, increase healing, retarget the support source, or count as source interruption
    **And** subsequent pulses heal from the recipient's resulting current health
    **And** killing the recipient terminates the link with `RECIPIENT_DIED` and prevents later healing.

27. **Resolve terminal conditions through fixed precedence**

    **Given** multiple terminal or delivery conditions become eligible in one simulation step
    **When** support lifecycle resolution commits
    **Then** stale-run or reset invalidation resolves first, followed by source death, recipient death, relay death, accepted source-damage interruption, connection break, recipient-full completion, duration expiry, and healing delivery
    **And** exactly one terminal reason is committed
    **And** no lower-precedence pulse or callback executes after terminal commitment
    **And** callback and node order cannot change the chosen result.

28. **Reject conflicting support links**

    **Given** the source already owns an unresolved support execution or the recipient already owns an active `HEALING_SUPPORT` occurrence
    **When** the same or another source requests a conflicting link
    **Then** the later request is rejected without refreshing duration, adding pulses, multiplying healing, replacing the relay, transferring source attribution, or changing the existing schedule
    **And** simultaneous candidates resolve by stable request identity
    **And** another valid link may begin only after the existing occurrence becomes terminal and cadence permits it
    **And** compatible unrelated status channels remain unchanged.

29. **Apply source-death and duration cleanup**

    **Given** the source dies or is removed during windup or active channeling
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** preview, execution, link, relay, healing eligibility, and remaining pulses terminate without dereferencing the removed source
    **And** source death takes precedence over ordinary damage interruption.

    **Given** the active link reaches six elapsed seconds without another terminal condition
    **When** duration expiry resolves
    **Then** it terminates once without a sixth healing pulse
    **And** the final one-second expiry warning ends with link and relay cleanup.

30. **Preserve movement and create no hidden control effect**

    **Given** the support source, recipient, relay, link, and player are active
    **When** any participant moves, grapples, uses a wall, attacks, takes damage, or changes tactical state
    **Then** the healing tether applies no velocity, acceleration, collision constraint, input suppression, forced facing, stun, invulnerability, or target redirection
    **And** the player can approach the source directly, use cover to invalidate a segment, grapple to the relay, attack the relay, or continue attacking the recipient
    **And** support pressure comes from recoverable healing rather than disabling the player or making the recipient invulnerable.

31. **Clean up reset and scene exit correctly**

    **Given** the fixture resets, checkpoint reloads, or the scene exits during reservation, windup, activation, pulse delivery, brief or continuous invalidity, source interruption, relay damage, relay grapple, recipient death, full-health completion, expiry, or cadence
    **When** the old run is invalidated
    **Then** executions, reservations, links, relays, endpoint bindings, validation accumulators, pulse schedules, healing occurrences, accepted results, grapple references, channel state, presentations, cadence state, and late callbacks are removed or rejected exactly once
    **And** source, relay, and recipient health plus all fixture state return to their authored initial values
    **And** no healing or support state survives into the fresh run.

32. **Keep support behavior configurable**

    **Given** an alternate valid definition changes windup, duration, expiry warning, pulse start, interval, count, heal amount, source-to-recipient range, segment length, invalidity break time, relay health or size, cadence, interruption policy, reapplication policy, or source-death policy
    **When** the same action, relay, target-owned link, health, query, and presentation implementations consume it
    **Then** targeting, creation, validation, healing, interruption, diagnostics, and cleanup use the authored values without code changes
    **And** at least one alternate-profile test proves healing amount, pulse schedule, break duration, segment length, and relay health are not hard-coded
    **And** armor, resistance, stagger support, recovery acceleration, resurrection, temporary health, multi-target support, relay networks, attackable beam segments, and final presentation remain outside this story.

33. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** targeting, windup, relay creation, link activation, pulse warning, healing, skipped pulse, invalid segment, break progress, source interruption, relay damage, relay death, recipient completion, expiry, cancellation, or reset occurs
    **Then** primitive endpoint markers, two link segments, relay geometry, pulse movement, health indicators, break-progress cues, state changes, and typed result displays communicate the relationship and counters
    **And** future animation, healing VFX, tether effects, relay models, audio, camera feedback, and materials can consume committed facts without controlling targeting, health, interruption, or lifecycle
    **And** diagnostics expose stable identities, reservations, lifecycle and pulse times, source and recipient anchors, relay transform and health, segment lengths and line-of-sight results, invalidity progress, requested and applied healing, skipped pulses, source-damage result, grapple state, terminal precedence, run identity, and terminal reason.

34. **Make support interruption manually reproducible**

    **Given** the named healing-support fixture is launched through the Story 3.1 pressure lab with one passive damaged recipient
    **When** another developer follows its documented procedure
    **Then** they can observe five scheduled healing opportunities, interrupt the source during windup, interrupt an active link by damaging the source, kill the source, grapple to and destroy the relay, and maintain segment obstruction until the link breaks
    **And** they can briefly obstruct and restore the link, observe skipped rather than deferred healing, exceed segment length, damage the recipient without interrupting, kill the recipient, fill the recipient to maximum health, and remain until ordinary expiry
    **And** they can test relay grapple invalidation, duplicate and conflicting requests, simultaneous terminal conditions, source or endpoint invalidation, and reset during every lifecycle phase
    **And** retained evidence distinguishes objective targeting, pulse timing, healing, interruption, relay, connection, grapple, cleanup, and repeatability results from subjective observations about heal pressure, cue clarity, relay accessibility, break time, duration, and perceived target priority.

35. **Verify deterministic interruptible healing**

    **Given** the permanent healing-support suite and focused real-Jolt fixture run
    **When** they exercise eligible and ineligible recipients, reservations, midpoint validation, moving endpoints, segment range and line of sight, exact pulse boundaries, skipped pulses, healing clamps, full and dead recipients, duplicate deliveries, source damage and death, relay damage and death, relay grapple invalidation, simultaneous terminal conditions, conflicting links, stale runs, randomized callback order, and repeated reset
    **Then** each accepted execution creates no more than one recipient-owned link and one relay, each pulse changes health no more than once, and each support occurrence reaches one terminal result under fixed precedence
    **And** shared resources remain unchanged and cleanup leaves no relay, healing, reservation, target, grapple, or channel state
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve windup, duration, pulse times and count, invalidity break time, healing results, interruption precedence, cadence, terminal outcome, and cleanup within documented tolerances
    **And** the story has not implemented armor, resistance, stagger or recovery support, resurrection, multiple recipients, relay networks, coordinated combat pressure, production enemy allocation, or final presentation.
