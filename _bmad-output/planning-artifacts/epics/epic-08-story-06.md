---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 6
---

# Story 8.6: Complete the Primary Garden Heart Attack-Response Cycle

As a player,
I want to recognize and counter the Garden Heart's primary pressure to create a weak-point opening,
So that the boss fight has one complete, learnable loop connecting defense, traversal, and offense.

**Acceptance Criteria:**

1. **Declare the focused primary-cycle outcome**

    **Given** the Garden Heart core, arena, and vulnerability contracts exist
    **When** the primary pressure story is inspected
    **Then** exactly one Story 8.1-designated primary boss pressure executes a complete windup, affected-space or target, active consequence, player response, counter resolution, weak-point opening, attack opportunity, closure, and recovery cycle
    **And** definition composition, action ownership, targeting, telegraph agreement, counter mapping, failure and recovery, cleanup, fallback presentation, diagnostics, manual procedure, and automated evidence are explicit
    **And** the cycle is playable repeatedly in the boss arena with normal player controls
    **And** additional selected pressures, phase escalation, complete encounter progression, reward, exit, and final presentation remain outside this story.

2. **Require one approved primary pressure allocation**

    **Given** Story 8.1 maps the selected Garden Heart subset
    **When** Story 8.6 begins
    **Then** exactly one selected mechanic or explicitly approved single composite is marked `PRIMARY_BOSS_PRESSURE`
    **And** its player question, phase availability, counter, recovery, vulnerability relationship, tuning hypothesis, presentation fallback, and shared implementation family are complete
    **And** an allocation containing an unbounded composite, unselected mechanic, unresolved counter, or contract-changing behavior blocks implementation
    **And** this story does not substitute an architecture hypothesis for the approved selection result.

3. **Reference the validated shared mechanic implementation**

    **Given** the primary pressure was validated in M2
    **When** its boss variant is authored
    **Then** it references the same ability, attack, effect, motor influence, spatial binding, targetability, surface, link, projectile, or AI contracts used by its approved implementation family
    **And** boss-specific values and compatible policy choices live in immutable typed definitions
    **And** no Garden Heart script copies or forks the mechanic into a private implementation
    **And** Story 6 evidence remains valid only for unchanged shared behavior and its documented conditions.

4. **Author one immutable primary-cycle definition**

    **Given** the approved pressure and response are mapped
    **When** the Garden Heart primary-cycle definition is inspected
    **Then** it declares stable definition and cycle IDs, Garden Heart and phase eligibility, referenced action and mechanic definitions, selection conditions, windup and recovery policy, counter contract, vulnerability request mapping, repetition rule, cooldown or spacing rule, cancellation policy, presentation profile, audio slots, and evidence metadata
    **And** all durations use seconds and all geometry references use the approved ability-space contract
    **And** invalid references, unsupported phases, contradictory timing, missing counter mappings, or unresident dependencies fail validation
    **And** execution-local targets, elapsed time, counter state, hits, and terminal results remain outside the definition.

5. **Request the cycle through the boss action owner**

    **Given** the Garden Heart is alive, in an eligible phase, and not already executing an action
    **When** LimboAI or the focused fixture selects the primary intent
    **Then** it submits one typed action request carrying boss, run, phase, cycle-definition, target, and decision identities
    **And** the established action owner validates eligibility, cooldown, current phase, target freshness, and run scope before beginning
    **And** LimboAI cannot activate delivery, set targets after lock, open vulnerability, or change phase
    **And** duplicate or stale requests return typed results without creating another execution.

6. **Allocate one stable execution identity**

    **Given** a valid primary-cycle request is accepted
    **When** the action begins
    **Then** it receives one unique execution identity within the current Garden Heart and encounter run
    **And** target snapshots, ability-space bindings, deliveries, effects, counters, vulnerability requests, presentation, audio, and terminal results reference that identity
    **And** the identity is never reused after completion, cancellation, reset, or respawn
    **And** runtime objects do not rely on scene parentage or display names for attribution.

7. **Follow the simulation-authored action lifecycle**

    **Given** the primary execution is active
    **When** simulation advances
    **Then** it follows requested, windup, active, recovery, completed, or reason-coded cancelled states according to the shared lifecycle
    **And** elapsed time advances from fixed physics delta with bounded carry-over
    **And** each execution reaches exactly one terminal result
    **And** animation, VFX, audio, render frames, and wall-clock time cannot advance the lifecycle.

8. **Bind authoritative affected space once per policy**

    **Given** the selected mechanic requires a lane, ring, volume, wedge, plane, trajectory, surface, pose, target, or other supported ability space
    **When** its execution enters the authored binding phase
    **Then** one execution-local `AbilitySpatialBinding` resolves the approved boss origin, target or target snapshot, arena references, geometry definition, and lock policy
    **And** per-step `AbilitySpatialSnapshot` values derive from that binding where motion is supported
    **And** active delivery and fallback telegraph consume the same binding
    **And** presentation cannot perform a second target or geometry calculation.

9. **Communicate source, windup, and affected space**

    **Given** the primary cycle enters windup
    **When** the player observes it with diagnostics disabled
    **Then** primitive boss state, authoritative shape-family telegraph, and semantic placeholder audio identify the Garden Heart as source and make the affected space or target and response timing understandable
    **And** the cue follows the Story 8.1 readability specification and does not rely on color alone
    **And** lock and tracking behavior is visible where it affects the response
    **And** warning duration and active geometry remain simulation-owned.

10. **Deliver the selected active consequence through its normal family**

    **Given** windup reaches the active boundary without cancellation
    **When** the pressure becomes effective
    **Then** damage, displacement, motor influence, spawned world effect, target-owned status, route or surface change, targetability effect, or contextual AI behavior is delivered only through the selected mechanic's existing typed owner
    **And** every delivery carries source, execution, definition, level-session, encounter-run, and occurrence attribution
    **And** the Garden Heart coordinator does not write player velocity, health, grapple state, surface state, or target selection directly
    **And** active geometry agrees with the warned space within documented tolerance.

11. **Provide the approved primary counter**

    **Given** the pressure is winding up or active
    **When** the player performs the Story 8.1-defined route, altitude, grapple, wall, momentum, timing, positioning, destruction, interruption, or observation response
    **Then** the responsible mechanic or action owner evaluates that response from authoritative current facts
    **And** success creates one immutable counter-resolution result with execution, player, boss, phase, spatial, and physics-step identity
    **And** failure identifies the unmet response category without opening vulnerability
    **And** neither HUD prompts nor diagnostic selection can declare the counter successful.

12. **Connect the committed counter to vulnerability**

    **Given** the primary counter result is successful and current
    **When** the cycle applies its approved response mapping
    **Then** it submits one Story 8.5 vulnerability request for the specified weak point using the exact counter occurrence and traversal facts
    **And** the vulnerability owner independently validates and commits the opening
    **And** duplicate counter callbacks cannot open or extend another window beyond the approved policy
    **And** a rejected opening leaves the action and boss in their documented recovery or fallback state.

13. **Create a real player attack opportunity**

    **Given** the primary counter opens its intended weak point
    **When** the player reaches and attacks it during the authoritative window
    **Then** normal player movement, attack lifecycle, `MovementCombatContext`, `DamageSnapshot`, current `ImpactContext`, weak-point modifier, and Garden Heart health contracts resolve the hit
    **And** the arena provides the approved route and time needed for a skilled player to attempt the opening
    **And** an attack outside the open impact interval follows the closed policy
    **And** the cycle never awards damage merely because the counter succeeded.

14. **Apply the documented failure consequence**

    **Given** the player fails, ignores, or mistimes the primary response
    **When** the active pressure resolves
    **Then** its selected mechanic produces the approved damage, displacement, route disadvantage, target state, or other consequence exactly once per delivery policy
    **And** the player receives clear outcome feedback
    **And** failure does not open vulnerability unless the approved design explicitly defines a distinct partial-success result
    **And** the consequence cannot permanently remove every recovery and movement option.

15. **Preserve ordinary recovery after failure**

    **Given** the player receives a nonterminal primary-pressure consequence
    **When** they use the documented recovery route or action
    **Then** they can regain controllable play and prepare for a later cycle
    **And** temporary motor, route, surface, anchor, status, targetability, or visibility changes expire or can be countered according to their definitions
    **And** recovery does not require diagnostics or an unannounced immunity
    **And** a severe terminal failure remains routed to the established boss-checkpoint recovery integration later.

16. **Close the cycle through an explicit recovery state**

    **Given** the pressure succeeds, is countered, opens vulnerability, or reaches its active end
    **When** the action enters recovery
    **Then** delivery and response acceptance end at their documented boundaries while allowed existing transients follow their scope policy
    **And** the weak point closes through its own owner and reason-coded condition
    **And** the Garden Heart cannot select the next action until recovery and any required phase readiness commit
    **And** recovery completes exactly once without depending on presentation.

17. **Enforce repetition and spacing rules**

    **Given** a primary cycle terminates and remains eligible in the current phase
    **When** another selection is considered
    **Then** the approved cooldown, minimum spacing, maximum consecutive-use, or intervening-action policy is applied from owner-local state
    **And** deterministic seed and stable tie-breaking preserve reproducibility
    **And** no unbounded random retry is used to find an eligible choice
    **And** the focused single-pressure fixture can deliberately repeat the cycle through an explicit test policy without changing the final definition.

18. **Cancel safely on phase, death, reset, and source invalidation**

    **Given** the primary execution is requested, winding up, active, recovering, or awaiting a counter result
    **When** boss phase policy cancels it, Garden Heart dies, the run restarts, the level ends, or another required identity becomes invalid
    **Then** the action commits one reason-coded terminal result
    **And** future damage, influence, counter, spawn, vulnerability, presentation, and audio work from it is rejected
    **And** every scoped transient terminates or persists only according to its approved delivery and run policy
    **And** repeated cancellation is idempotent.

19. **Reject stale cycle and counter work**

    **Given** an action request, spatial snapshot, delivery, response fact, counter result, vulnerability request, or callback belongs to an old execution, phase, boss occurrence, run, or level session
    **When** it reaches a current boundary
    **Then** it cannot affect the player, current boss, weak point, health, phase, action state, or presentation
    **And** it returns a bounded typed stale reason
    **And** no retained node keeps the prior occurrence alive
    **And** repeated stale activity cannot grow logs or histories without bound.

20. **Keep primary-cycle presentation replaceable**

    **Given** final boss animation, VFX, and audio are unavailable
    **When** source pose, windup, target lock, affected space, active consequence, successful counter, failed response, vulnerability, hit, recovery, completion, or cancellation occurs
    **Then** primitive geometry, state materials, fallback telegraphs, concise labels, and semantic placeholder cues communicate the state
    **And** critical distinctions use more than color
    **And** every presenter consumes authoritative action, spatial, counter, vulnerability, impact, or terminal state
    **And** later assets can replace the presenters without changing the primary-cycle definition or gameplay.

21. **Expose bounded primary-cycle diagnostics**

    **Given** development diagnostics are enabled after the player-facing pass
    **When** the cycle is inspected
    **Then** diagnostics show selection, definition, boss, phase, execution, target, spatial binding, action phase, counter qualification, traversal facts, deliveries, vulnerability request, weak-point window, damage, recovery, cancellation, cleanup, and terminal identities and results
    **And** they distinguish source commit, counter resolution, and actual impact facts
    **And** histories and world drawings remain bounded and stop when hidden
    **And** diagnostics perform no duplicate targeting, geometry, counter, vulnerability, or damage computation.

22. **Make the complete cycle manually reproducible**

    **Given** another developer launches the named Garden Heart primary-cycle fixture in the approved arena with diagnostics initially disabled
    **When** they observe windup, deliberately fail the response, recover, then perform the primary counter and attack the opened weak point
    **Then** the expected consequence occurs only on failure and the expected vulnerability opens only on a successful current-run response
    **And** they demonstrate a successful and missed attack opportunity, early and late impact, repeated cycles, phase cancellation fixture, boss death, pause, restart, source invalidation, duplicate facts, and stale callbacks
    **And** every state remains understandable through primitive player-facing presentation and normal controls
    **And** retained evidence separates objective lifecycle, geometry, counter, vulnerability, damage, cleanup, and repeatability from subjective readability, pressure, fairness, duration, and satisfaction.

23. **Verify the primary cycle automatically**

    **Given** definition validation, lifecycle, spatial-binding, mechanic-family, counter, vulnerability, damage, cleanup, and real-Jolt arena tests run
    **When** they exercise eligibility, deterministic selection, every action phase, tracking and lock policy, active delivery, response success and failure, duplicate counters, weak-point integration, hit boundaries, failure consequence, recovery, spacing, phase cancellation, death, restart, stale work, and repeated executions
    **Then** every cycle and delivery reaches one valid terminal result and only an approved counter can request the intended opening
    **And** telegraph and delivery space agree, health changes only from accepted damage, and cleanup leaves no escaped transient
    **And** shared definitions retain their fingerprints
    **And** real scene evidence confirms the counter and attack opportunity are achievable through production traversal.

24. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** equivalent deterministic primary-cycle scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **When** selection, windup, tracking, active delivery, counter, vulnerability, attack, recovery, cancellation, and cleanup resolve
    **Then** authored real-time timing, affected space, response classification, consequences, openings, damage, and terminal results remain equivalent within documented tolerance
    **And** high-speed movement does not tunnel through required counter or delivery queries
    **And** additional physics callbacks cannot duplicate damage, counters, openings, or terminal results
    **And** a rate-sensitive authoritative difference blocks the story.

25. **Stay within the primary-pressure budget**

    **Given** the cycle runs in the minimum-spec release-like environment
    **When** its representative active and cleanup windows are measured
    **Then** spatial queries, spawned objects, effects, navigation work, presentation, and audio remain within Story 8.1's primary-cycle allocation
    **And** repeated executions and restarts do not increase retained counts
    **And** final M4 performance is not claimed before full phase escalation and presentation exist
    **And** a measured issue produces scoped remediation rather than changing gameplay silently.

26. **Keep the story bounded to one primary attack-response cycle**

    **Given** Story 8.6 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains exactly one approved primary pressure variant, complete simulation-owned action cycle, authoritative affected space, player response and counter, weak-point opening connection, failure and recovery, fallback presentation, cleanup, diagnostics, and focused verification
    **And** it does not add additional selected pressures, complete phase escalation, production boss HUD or audio mix, full encounter and checkpoint progression, reward, exit, or final balance
    **And** those outcomes remain assigned to Stories 8.7 through 8.12.
