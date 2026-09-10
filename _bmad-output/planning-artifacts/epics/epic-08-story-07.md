---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.7'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 7
---

# Story 8.7: Escalate the Garden Heart Through Its Approved Phases

As a player,
I want the Garden Heart fight to escalate through distinct but readable phases,
So that later cycles test deeper traversal-combat mastery without becoming chaotic or arbitrary.

**Acceptance Criteria:**

1. **Declare the focused phase-escalation outcome**

    **Given** the core boss and primary attack-response cycle are complete
    **When** the phase-escalation slice is inspected
    **Then** the Garden Heart executes the complete Story 8.1-approved phase sequence using its primary cycle plus only the remaining approved selected pressures, cadence changes, vulnerability rules, and arena-state changes
    **And** phase definitions, pressure integration, transition ownership, selection, overlap, counterplay, recovery, cleanup, fallback presentation, diagnostics, manual procedure, and automated evidence are explicit
    **And** the complete boss can progress from initial phase to a valid lethal state in a focused arena fixture
    **And** encounter activation, checkpoint recovery, production boss HUD and audio mix, reward, exit, and final balance remain outside this story.

2. **Consume the approved bounded phase allocation**

    **Given** Story 8.1 maps phases and selected Garden Heart mechanics
    **When** implementation scope is resolved
    **Then** each phase, primary or secondary pressure, allowed overlap, vulnerability behavior, arena-state change, transition rule, and presentation requirement traces to the approved specification and Story 6.8 selection
    **And** rejected, deferred, unselected, or unresolved mechanics remain absent
    **And** an allocation exceeding Story 8.1's story-size or content-density budget is split before implementation
    **And** reducing counterplay or verification is not used to absorb an oversized phase plan.

3. **Keep escalation meaningful when only one mechanic is selected**

    **Given** Story 6.8 may select only the primary Garden Heart pressure
    **When** later phase behavior is authored
    **Then** escalation uses only approved parameter ranges, cadence, target-lock policy, arena origin, response order, weak-point selection, recovery spacing, or route relationship defined by Story 8.1
    **And** the later phase still asks a distinguishable player question
    **And** no additional unselected mechanic is introduced merely to create variety
    **And** the same shared primary implementation remains authoritative.

4. **Productionize each additional selected pressure through its shared family**

    **Given** Story 8.1 assigns an additional selected mechanic to a Garden Heart phase
    **When** its boss variant is implemented
    **Then** it references the validated shared mechanic, ability, attack, effect, spatial, motor, targetability, surface, link, AI, and cleanup contracts applicable to that family
    **And** boss-specific tuning and compatible behavior choices live in immutable typed Resources
    **And** it preserves its selected player question, counter, ordinary failure consequence, recovery, and grapple or wall relationships
    **And** no private boss-only duplicate of the reusable mechanic is created.

5. **Require a standalone boss-context check for each added pressure**

    **Given** an additional selected pressure has a boss variant
    **When** it is considered ready for phase composition
    **Then** a named focused arena mode demonstrates its source, windup, affected space or target, active consequence, primary counter, ordinary recovery, weak-point relationship where applicable, cancellation, source death, and reset
    **And** diagnostics are initially hidden for the readability pass
    **And** its result remains traceable to the original M2 evidence and new boss-context tuning
    **And** an objectively failing standalone variant cannot enter the combined phase sequence.

6. **Complete immutable phase definitions**

    **Given** the final approved phase sequence is authored
    **When** each phase definition is inspected
    **Then** it declares stable phase identity and version, legal predecessor and successor states, entry conditions, health or other thresholds, eligible action-cycle definitions, selection policy, repetition limits, overlap policy, vulnerability rules, arena-state references, transition cancellation policy, presentation profile, and performance budget
    **And** timings use seconds and references use stable typed IDs
    **And** invalid graphs, unreachable phases, cycles absent from the design, missing safe fallback, or incompatible content fail validation
    **And** definitions remain immutable while current phase, action histories, and transition occurrences remain boss-local.

7. **Enter the initial phase once**

    **Given** a fresh Garden Heart occurrence activates in the focused fixture
    **When** readiness commits
    **Then** the approved initial phase enters exactly once with baseline action history, vulnerability state, arena state, and deterministic selection seed
    **And** no selected pressure begins before phase and player readiness
    **And** an old occurrence cannot publish an initial-phase fact into the new boss
    **And** repeated ready callbacks return the existing phase occurrence.

8. **Transition only from committed authoritative conditions**

    **Given** the boss is in a nonterminal phase
    **When** its approved health threshold, completed response cycle count, destroyed boss-owned target, or other explicit transition condition commits
    **Then** the boss phase owner validates current phase, occurrence, condition, source, run, and duplicate identity
    **And** it begins at most one legal transition
    **And** HUD state, animation, audio, elapsed wall-clock time, empty scene geometry, or AI preference cannot initiate the transition
    **And** crossing multiple conditions in one step follows the approved deterministic carry-over policy.

9. **Reach a safe action boundary during transition**

    **Given** a phase transition becomes eligible while an action or vulnerability window is active
    **When** transition policy is applied
    **Then** the current action completes, cancels, or reaches the approved safe boundary with one terminal result
    **And** open weak points close or persist only according to their explicit transition rule
    **And** hitboxes, motor influences, projectiles, hazards, surface changes, links, telegraphs, and audio follow their declared transition and scope policies
    **And** the next phase cannot select an action before cleanup and phase readiness commit.

10. **Apply arena-state changes through existing owners**

    **Given** a phase changes route, surface, obstacle, anchor, pressure origin, or gate state
    **When** its authored arena-state transition occurs
    **Then** `LevelController`, the boss action owner, or the applicable surface or effect owner commits only the state it owns through typed commands
    **And** the boss coordinator cannot edit static geometry, private collision fields, or shared Resources directly
    **And** collision and primitive presentation agree after the committed change
    **And** death, reset, and level teardown restore exact authored state without residue.

11. **Give every phase a distinct player question**

    **Given** the player enters each approved phase
    **When** its available pressures and openings are experienced
    **Then** the phase creates the documented difference in route, altitude, timing, trajectory, observation, target priority, counter sequence, or recovery
    **And** the difference is mechanical rather than solely faster animation, higher damage, a color change, or a larger health pool
    **And** earlier learned responses remain relevant even when their timing or combination changes
    **And** the player can describe the new demand after normal play or shortly after an initial failure.

12. **Select attacks deterministically within each phase**

    **Given** several phase-eligible cycles are ready
    **When** the Garden Heart chooses the next intent
    **Then** LimboAI or the approved selector uses phase policy, deterministic encounter seed, stable tie-breaking, cooldowns, recent-action history, repetition limits, spatial validity, player state, and safe fallbacks
    **And** selection remains bounded and reproducible from the same authoritative decision state
    **And** it cannot retry randomly without limit or choose an action whose required space is invalid
    **And** only the action owner may accept and execute the chosen request.

13. **Prevent oppressive repetition**

    **Given** one pressure was recently completed or cancelled
    **When** selection evaluates another cycle
    **Then** Story 8.1's consecutive-use, spacing, alternation, or contextual-reuse policy is enforced
    **And** a lack of alternative valid action reaches a declared fallback rather than bypassing the policy silently
    **And** repeated patterns remain possible only where intentionally approved and readable
    **And** action history is cleared with the boss occurrence rather than stored in definitions.

14. **Use only approved pressure overlap**

    **Given** a phase permits two pressure effects to coexist
    **When** simultaneous behavior begins
    **Then** the pairing, timing relationship, maximum active count, source distinctions, counter interaction, and cleanup were explicitly approved and tested
    **And** overlapping warning geometry and audio retain distinguishable source and affected-space information
    **And** more effects cannot join because earlier detached deliveries remain active unless the overlap policy budgets them
    **And** callback or action-selection order cannot exceed the approved maximum.

15. **Validate new combinations before integration**

    **Given** an approved phase calls for a simultaneous pairing not covered by Stories 6.1 through 6.6
    **When** the pairing is implemented
    **Then** a focused boss-arena combination fixture proves both sources, warnings, active spaces, counters, failure consequences, ordinary recovery, source death, reset, and repeated runs
    **And** at least one viable response and recovery route remains
    **And** objective and subjective evidence remain separate
    **And** the pairing cannot enter the full phase fixture until it passes.

16. **Preserve useful traversal in every phase**

    **Given** selected pressures alter spatial safety or route value
    **When** low, high, lateral, and recovery paths are evaluated
    **Then** each phase retains the approved useful routes and at least one path to its required counter or weak-point opportunity
    **And** common abilities cannot arbitrarily cancel the complete movement vocabulary
    **And** temporary restrictions have readable sources, bounded lifetimes, and alternatives
    **And** no intended response depends on a hidden movement exception or diagnostic command.

17. **Preserve counter and vulnerability causality**

    **Given** an action cycle has an approved relationship to a weak point
    **When** its response succeeds or fails
    **Then** only its committed current-run counter result can submit the mapped vulnerability request
    **And** successful openings identify their source phase and action execution
    **And** failed, partial, duplicate, stale, or unapproved responses cannot open another weak point
    **And** actual damage eligibility remains current at impact through Story 8.5.

18. **Keep phase difficulty out of hidden damage inflation**

    **Given** a later phase is intended to escalate
    **When** its tuning differs from an earlier phase
    **Then** changes remain within the approved health, damage, timing, geometry, cadence, overlap, and recovery hypotheses
    **And** the design identifies which player decision becomes harder and why
    **And** arbitrary unavoidable damage or health inflation cannot substitute for a distinct challenge
    **And** final numerical balance remains later playtest work.

19. **Reach the approved terminal phase and boss death**

    **Given** the player completes enough valid openings and applies accepted damage
    **When** Garden Heart health reaches zero from any legal phase
    **Then** boss death commits exactly once and prevents new phase transitions or action selection
    **And** active cycles, windows, and arena changes follow their approved death cleanup
    **And** the focused fixture reaches a stable defeated state without completing the final level objective
    **And** post-death damage, late counters, or transition callbacks cannot reactivate the boss.

20. **Reset the complete phased fight cleanly**

    **Given** the focused fixture resets after any phase, active pressure, overlap, vulnerability, damage state, or death
    **When** the old boss occurrence and run are invalidated
    **Then** all actions, deliveries, effects, arena mutations, weak-point windows, phase state, health, AI history, presentation, audio, diagnostics, and callbacks terminate exactly once or idempotently
    **And** a fresh boss begins in initial phase with baseline definitions and a new deterministic occurrence
    **And** shared Resources retain their fingerprints
    **And** no old phase fact or source-independent delivery can affect the fresh boss.

21. **Reject stale phase and pressure work**

    **Given** selection, transition, action, delivery, counter, vulnerability, arena-state, presentation, or cleanup work belongs to an old phase, boss occurrence, run, or level session
    **When** it reaches a current owner
    **Then** it cannot alter current health, phase, actions, player state, weak points, arena state, or presentation
    **And** it returns a bounded typed stale reason
    **And** it retains no destroyed source node
    **And** repeated stale work cannot increase logs or histories without bound.

22. **Provide complete primitive phase presentation**

    **Given** production boss presentation remains unavailable
    **When** phase entry, pressure selection, transition, vulnerability policy, escalation, and defeat occur
    **Then** primitive body states, fallback telegraphs, phase labels, weak-point markers, route cues, and semantic placeholder sounds make the current demand reviewable
    **And** sources and active spaces remain distinguishable during approved overlap
    **And** presentation follows committed state and cannot advance a phase or action
    **And** Story 8.8 remains responsible for complete player-facing HUD, audio, and presentation integration.

23. **Expose bounded phased-fight diagnostics**

    **Given** development diagnostics are enabled after player-facing checks
    **When** the fight is inspected
    **Then** diagnostics show definition versions, boss and run identity, deterministic seed, phase and transition occurrences, eligibility inputs, action candidates and selection, recent history, active pressure and overlap, counter and vulnerability mapping, arena state, health, cleanup, stale rejection, and terminal results
    **And** they read maintained owner data without recomputing selection, geometry, counters, or damage
    **And** histories and drawings have explicit bounds and stop when hidden
    **And** release-like behavior omits or disables the detailed overlay.

24. **Make each phase and transition manually reproducible**

    **Given** another developer launches the named Garden Heart phased-fight fixture with diagnostics initially disabled
    **When** they play from initial state through every phase and boss death
    **Then** they experience each added pressure independently before its phase composition, demonstrate every counter and ordinary recovery, open and attack each required vulnerability, and identify the distinct player question of every phase
    **And** they deliberately fail responses, test each approved overlap, cross transition boundaries during actions and windows, pause, reset from every phase, kill the boss in each legally possible phase, and inject stale facts afterward
    **And** the complete sequence remains readable and winnable with normal controls and primitive presentation
    **And** retained evidence separates objective selection, lifecycle, overlap, state, damage, cleanup, and repeatability from subjective escalation, clarity, pacing, fairness, fatigue, and satisfaction.

25. **Verify phase escalation automatically**

    **Given** phase-definition, selection, action, mechanic, overlap, vulnerability, damage, arena-state, cleanup, and real-Jolt fixture tests run
    **When** they exercise every phase, legal and illegal transitions, threshold carry-over, selection candidates, repetition limits, safe fallback, each added pressure, allowed combinations, counter mapping, vulnerability, death, pause, reset, stale work, randomized callback order, and repeated full sequences
    **Then** phases follow only the approved graph, each execution and transition has one terminal result, and overlap never exceeds policy
    **And** no unselected mechanic, duplicate damage, stale opening, phase regression, escaped effect, or mutated shared definition appears
    **And** the final boss occurrence can reach death through legitimate player attacks
    **And** automated evidence supplements rather than replaces manual readability, counterplay, route-use, and escalation review.

26. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** the same deterministic complete phase sequence runs at shipping 60 Hz and diagnostic 120 Hz
    **When** selection, timings, overlaps, counters, vulnerabilities, damage, transitions, death, and cleanup resolve
    **Then** real-time behavior, phase sequence, decision results at declared boundaries, allowed overlap, openings, health outcomes, and terminal results remain equivalent within documented tolerance
    **And** high-speed traversal and delivery queries remain reliable
    **And** additional callbacks cannot add an action, transition, hit, opening, or lingering effect
    **And** a rate-sensitive authoritative difference blocks the story.

27. **Stay within the approved full-boss gameplay budget**

    **Given** the complete phased gameplay fixture runs on the selected minimum-spec PC
    **When** its representative worst phase and transition are profiled with primitive presentation
    **Then** participants, AI, queries, projectiles, hazards, effects, weak points, route mutations, and cleanup remain within Story 8.1's gameplay allocation
    **And** repeated full resets do not increase retained object, memory, signal, or history counts
    **And** this evidence informs but does not replace the final presentation-complete M4 benchmark
    **And** measured over-budget behavior creates scoped remediation rather than silent mechanic removal.

28. **Keep the story bounded to approved phase escalation**

    **Given** Story 8.7 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the complete approved phase definitions, any additional selected pressure variants, deterministic phase selection, transitions, repetition and overlap rules, vulnerability mappings, arena-state integration, death, cleanup, primitive presentation, diagnostics, and focused evidence
    **And** it does not add unselected mechanics, complete encounter and checkpoint flow, production boss HUD or audio, reward, exit, final balance, or final performance sign-off
    **And** those outcomes remain assigned to Stories 8.8 through 8.12.
