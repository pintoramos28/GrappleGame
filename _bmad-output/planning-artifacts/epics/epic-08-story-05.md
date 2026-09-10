---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 5
---

# Story 8.5: Open Garden Heart Weak Points Through Traversal

As a player,
I want successful traversal and counterplay to expose clear Garden Heart weak points,
So that my movement creates meaningful, time-bounded opportunities to damage the boss.

**Acceptance Criteria:**

1. **Declare the focused vulnerability outcome**

    **Given** the Garden Heart core runtime and approved boss design exist
    **When** the vulnerability slice is inspected
    **Then** one or more approved traversal or counter facts can open the correct Garden Heart weak point for a bounded window in which normal player attacks resolve current target-side vulnerability at impact
    **And** definitions, weak-point composition, opening requests, state ownership, timing, damage policy, presentation, reset, diagnostics, manual procedure, and automated evidence are explicit
    **And** a named arena fixture can demonstrate successful and failed openings without production boss pressure
    **And** selected attack behavior, phase escalation, complete boss encounter progression, reward, and exit remain outside this story.

2. **Consume only approved vulnerability rules**

    **Given** Story 8.1 defines weak points and traversal-created openings
    **When** Story 8.5 begins
    **Then** every weak-point identity, opening source, qualifying player fact, phase eligibility, duration or closure rule, incoming-damage policy, presentation state, and reset behavior traces to the approved specification version
    **And** the implementation records that version beside the boss definition
    **And** an unresolved or unapproved opening condition blocks implementation
    **And** no convenient trigger volume, animation event, or test shortcut becomes production authority.

3. **Author immutable vulnerability definitions**

    **Given** a Garden Heart weak-point slot is inspected
    **When** its `BossVulnerabilityDefinition` resolves
    **Then** it declares a stable definition and weak-point ID, supported phases, qualifying counter types, required traversal facts and tolerances, opening and closing behavior, open duration in seconds where timed, incoming-damage modifiers, targetability policy, per-window hit policy, presentation profile, and cancellation rules
    **And** invalid durations, empty identities, unsupported phases, contradictory targetability, malformed modifiers, or undefined qualifying facts fail validation
    **And** authored definitions remain immutable during play
    **And** runtime window occurrence, elapsed time, accepted counters, and hit history remain owner-local.

4. **Compose typed weak-point slots beneath the boss**

    **Given** the Garden Heart scene initializes
    **When** its approved weak-point host is configured
    **Then** each slot binds one stable weak-point identity to its hurtbox, spatial transform, query policy, vulnerability definition, presentation adapter, and boss occurrence
    **And** the coordinator validates that each required slot exists exactly once and belongs to the current Garden Heart
    **And** external systems address slots through typed identities rather than private node paths
    **And** a missing, duplicated, foreign, or incompatible slot blocks boss readiness.

5. **Keep vulnerability authority in the Garden Heart owner**

    **Given** a possible counter succeeds or a weak-point window may change
    **When** vulnerability state is evaluated
    **Then** the Garden Heart vulnerability owner alone validates opening, commits state transitions, advances elapsed simulation time, closes windows, and exposes current state
    **And** attack actions, trigger regions, player code, LimboAI, health, HUD, animation, VFX, audio, fixtures, and encounter code cannot set a weak point open or closed directly
    **And** requests return typed accepted, rejected, duplicate, stale, or ineligible results
    **And** committed state changes publish only after owner-local mutation.

6. **Use an immutable counter-resolution request**

    **Given** an approved future boss pressure or the focused test adapter resolves a possible counter
    **When** it requests a vulnerability opening
    **Then** the request carries application, level-session, encounter-run, boss occurrence, phase occurrence, source action execution, counter occurrence, counter type, intended weak-point identity, player identity, resolution physics step, and immutable qualifying traversal facts
    **And** it contains stable values rather than mutable player or boss internals
    **And** the opening owner can validate freshness and qualification without performing the pressure's gameplay again
    **And** malformed or incomplete requests cannot open a weak point.

7. **Capture traversal facts at counter resolution**

    **Given** the approved opening depends on player route, altitude, grapple, wall behavior, velocity, timing, or spatial relationship
    **When** the counter result becomes authoritative
    **Then** its immutable context records the exact approved facts from that physics step, including canonical player position and velocity, applicable support or wall contact, grapple state, boss-relative height and direction, route or region identity, and source counter timing
    **And** derived values are calculated once from the authoritative snapshot
    **And** the context does not substitute attack-commit movement or later impact motion for counter-resolution motion
    **And** future mechanics requiring movement history must declare their own bounded history contract rather than inferring one here.

8. **Validate the complete opening identity chain**

    **Given** a counter-resolution request arrives
    **When** the vulnerability owner evaluates it
    **Then** application, level-session, encounter-run, boss, phase, source execution, counter occurrence, player, weak-point, definition, and physics-step identities must all be current and mutually compatible
    **And** the source counter must be committed and allowed to create an opening
    **And** another player's, boss's, phase's, run's, or earlier attempt's result is rejected
    **And** identity validation occurs before any window timer, presentation, targetability, or damage policy changes.

9. **Open only when the authored traversal condition succeeds**

    **Given** a current valid request reaches the intended weak point
    **When** its traversal and counter facts are compared with the immutable definition
    **Then** every required condition and tolerance must pass
    **And** success commits one opening occurrence with its source evidence and phase identity
    **And** failure returns the specific unmet-condition category without partially opening the target
    **And** a trigger overlap, visual position, approximate animation pose, or debug selection cannot stand in for the required fact.

10. **Use an explicit vulnerability state lifecycle**

    **Given** a weak point initializes closed
    **When** an accepted opening or closure condition occurs
    **Then** it follows the approved closed, opening, open, closing, and closed states where those transitions are defined
    **And** each transition has one stable occurrence, simulation-owned entry and exit condition, targetability and incoming-damage policy, and reason-coded terminal result
    **And** presentation may omit a visual substate only when the authoritative lifecycle remains intact
    **And** illegal transition, regression, or duplicate entry is rejected.

11. **Advance timed windows in simulation seconds**

    **Given** an open weak point uses a timed duration
    **When** fixed-step boss simulation advances
    **Then** elapsed time increases from physics delta in seconds with bounded carry-over
    **And** the window closes at the authored boundary independently of rendered frames, wall-clock time, animation, VFX, or audio duration
    **And** pause suspends elapsed gameplay time through Story 7.11
    **And** the same authored duration remains equivalent at fixed 60 Hz and diagnostic 120 Hz.

12. **Handle duplicate and overlapping opening requests deterministically**

    **Given** the same or another eligible counter request arrives while a weak point is opening or open
    **When** the owner resolves it
    **Then** the approved ignore, refresh, extend, replace, queue, or reject policy from Story 8.1 is applied explicitly
    **And** the default cannot silently extend a window merely because duplicate callbacks occurred
    **And** at most one current window occurrence exists per weak point unless the approved design explicitly supports distinct simultaneous slots
    **And** callback order cannot produce a longer or more damaging window than authored.

13. **Keep closed weak points non-vulnerable**

    **Given** a weak point is closed, opening but not yet active, closing after eligibility ended, disabled by phase, or invalid
    **When** a player delivery reaches its hurtbox
    **Then** target-side resolution applies the approved closed-state rejection or non-vulnerable damage policy
    **And** a closed target cannot inherit a prior window's multiplier or hit history
    **And** presentation that appears open incorrectly cannot grant damage
    **And** the result records the actual weak-point identity and current state at impact.

14. **Resolve open vulnerability at actual impact**

    **Given** the player committed an attack while a weak point was closed or open
    **When** its delivery actually contacts the weak point
    **Then** `ImpactContext` captures current hit position and normal, boss and hurtbox identity, source and target motion, relative relationship, and the accepted weak-point identity at that impact physics step
    **And** target-side damage resolution reads the current open-window occurrence and incoming modifier at impact
    **And** attack-commit `MovementCombatContext` remains the source-motion snapshot declared by the attack definition
    **And** neither context overwrites or impersonates the other.

15. **Reject early and late impacts correctly**

    **Given** an attack begins before a window opens or remains active as it closes
    **When** contact occurs
    **Then** a hit before authoritative opening uses the closed-state policy even if the window opens later
    **And** a hit after authoritative closure uses the closed-state policy even if the attack was committed while open
    **And** a hit during the authoritative open interval receives the open-state policy regardless of presentation interpolation
    **And** exact boundary handling is deterministic and documented for the physics step on which state changes.

16. **Apply open-window damage through existing combat contracts**

    **Given** a valid player delivery impacts an open weak point
    **When** damage resolves
    **Then** its saved source-side offense combines with current target defense, resistance, weak-point vulnerability, and incoming modifiers in the established deterministic order
    **And** one immutable `DamageInstance` records the final result and opening occurrence
    **And** Garden Heart health accepts that delivery at most once under the attack's per-execution hit policy
    **And** vulnerability code never writes boss health or invents a second damage calculation.

17. **Support the approved attacks-per-window policy**

    **Given** a weak point remains open across multiple player attacks or a long active attack window
    **When** deliveries reach it
    **Then** each attack execution follows its own authored per-target hit policy
    **And** the vulnerability definition's per-window policy is enforced through stable delivery and window identities where required
    **And** the diagnostic 2.0-second melee variant cannot damage the same weak point more often than its attack definition permits
    **And** closing and reopening creates a distinct window occurrence without erasing global delivery deduplication.

18. **Close windows for every required terminal condition**

    **Given** a weak point is opening or open
    **When** its timer ends, approved hit or damage condition is reached, phase changes, boss dies, source counter is invalidated where policy requires, encounter restarts, checkpoint reloads, or level teardown begins
    **Then** the owner commits one reason-coded close or cancellation result
    **And** targetability and incoming-damage policy return to their defined safe state
    **And** loops, telegraphs, presentation, and audio associated with the window terminate through their owners
    **And** repeated terminal conditions remain idempotent.

19. **Coordinate multiple weak points explicitly**

    **Given** the approved boss design contains more than one weak-point slot
    **When** one opens or a phase changes
    **Then** simultaneous, mutually exclusive, ordered, or selection behavior follows the approved coordination policy
    **And** one slot cannot accidentally open another through shared presentation or generic collision
    **And** damage records identify the actual impacted slot
    **And** a design supporting only one slot carries no speculative universal multi-weak-point scheduler.

20. **Use a production-safe traversal opening fixture**

    **Given** selected boss pressure integration is not yet present
    **When** the named vulnerability fixture is launched in the Story 8.2 arena
    **Then** an explicitly development-only typed counter adapter asks the player to perform each approved traversal qualification at its authored route marker
    **And** the adapter submits the same immutable counter-resolution contract future boss actions will use
    **And** it cannot directly set vulnerability, health, phase, or damage
    **And** it is excluded from the final Last Garden manifest.

21. **Present opening and closure without final assets**

    **Given** final Garden Heart animation, VFX, audio, and model assets are unavailable
    **When** a weak point changes state
    **Then** primitive geometry, material, outline, shape, label, and semantic placeholder cue treatments distinguish closed, opening, open, closing, successful hit, rejected hit, and reset states
    **And** critical distinction does not depend on color alone
    **And** presentation consumes committed state and normalized progress without becoming a timer or targetability authority
    **And** future adapters can replace the fallback without changing opening or damage logic.

22. **Expose a read-only boss vulnerability projection**

    **Given** later HUD, audio, encounter, or diagnostics need vulnerability state
    **When** they query the Garden Heart coordinator
    **Then** they receive boss and run identities, current phase, weak-point identity, state, window occurrence, elapsed and remaining seconds where applicable, opening source category, and presentation-safe reason
    **And** discrete changes are signalled after commitment
    **And** consumers cannot open, close, refresh, or damage the weak point through the projection
    **And** old projections become invalid with their boss occurrence.

23. **Reset all vulnerability state with the boss occurrence**

    **Given** the fixture resets or the encounter run ends
    **When** the Garden Heart is removed and recreated
    **Then** every weak point returns to its authored initial state with no active window, elapsed time, accepted counter, hit history, modifier, presentation loop, audio binding, or pending callback
    **And** new slots receive the fresh boss and run identities
    **And** shared definitions retain their original fingerprints
    **And** stale old-window work cannot affect the new occurrence.

24. **Expose bounded vulnerability diagnostics**

    **Given** development diagnostics are enabled after the player-facing test
    **When** opening, damage, closure, rejection, or reset is inspected
    **Then** diagnostics show definition, boss, run, phase, counter, player, weak-point, window, attack, delivery, and impact identities; qualifying facts; state; elapsed time; damage policy; rejection reason; and terminal result
    **And** commit-time movement, counter-resolution movement, and impact-time motion remain separately labelled
    **And** histories and world drawings are bounded and stop when hidden
    **And** diagnostics do not perform another traversal test, hit query, or damage calculation.

25. **Make vulnerability behavior manually reproducible**

    **Given** another developer launches the named arena vulnerability fixture with diagnostics initially disabled
    **When** they perform each approved traversal qualification successfully and deliberately fail each required condition
    **Then** only successful current-run counter facts open the intended weak point
    **And** they demonstrate early, valid, boundary, and late impacts; multiple attacks; the 2.0-second diagnostic attack; duplicate counters; phase closure; death; pause; reset; and stale work
    **And** open hits use the intended target-side vulnerability while closed hits do not, with health changing exactly once per accepted delivery
    **And** retained evidence separates objective qualification, timing, identity, state, impact, damage, and reset results from subjective opening clarity, duration, satisfaction, and attack-window feel.

26. **Verify vulnerability contracts automatically**

    **Given** definition, state-machine, timing, counter-validation, damage-integration, and real-Jolt fixture tests run
    **When** they exercise every approved qualification, success and failure tolerances, duplicate and overlapping requests, legal and illegal transitions, early and late impact, exact boundary order, multiple weak points where applicable, hit policies, phase change, death, pause, run invalidation, stale work, and repeated resets
    **Then** each request and window reaches one typed terminal state and only a valid open impact receives its modifier
    **And** no trigger, presentation callback, stale context, duplicate delivery, or private node write changes vulnerability or health
    **And** shared definitions remain immutable and the development adapter is absent from the final manifest
    **And** real scene evidence confirms the approved arena access relationships.

27. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** equivalent opening and attack scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **When** traversal qualification, window timing, impact, damage, closure, pause, and reset resolve
    **Then** real-time window duration, accepted counter, weak-point state sequence, impact classification, damage results, and terminal outcomes remain equivalent within documented tolerance
    **And** additional physics callbacks cannot extend a window or add damage
    **And** exact boundary cases follow the same documented owner order
    **And** a rate-sensitive authoritative difference blocks the story.

28. **Keep the story bounded to traversal-opened vulnerability**

    **Given** Story 8.5 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains immutable vulnerability definitions, typed weak-point slots, counter-resolution requests, traversal qualification, simulation-owned windows, current-impact damage policy, fallback presentation, reset, diagnostics, and focused verification
    **And** it does not implement selected boss pressure actions, final phase escalation, boss encounter activation, boss checkpoint recovery, production boss HUD or audio, reward, exit, or final balance
    **And** actual boss actions connect to this approved counter seam in Stories 8.6 and 8.7.
