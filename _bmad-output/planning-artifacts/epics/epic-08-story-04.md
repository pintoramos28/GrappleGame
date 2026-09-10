---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 4
---

# Story 8.4: Build the Garden Heart Core Boss Runtime

As a player,
I want the Garden Heart to behave as one coherent combatant with reliable health, phases, damage, death, and reset,
So that later vulnerabilities and attacks can build on a stable boss rather than special-case scene logic.

**Acceptance Criteria:**

1. **Declare the focused core-boss outcome**

    **Given** the approved Garden Heart design and arena shell exist
    **When** the core runtime is inspected
    **Then** it provides one scoped Garden Heart combatant with immutable definition data, typed initialization, health, phase authority, action-lifecycle composition, body and hurtbox boundaries, committed damage and death, cleanup, primitive state presentation, diagnostics, manual procedure, and automated evidence
    **And** the boss can be created, exercised, killed through a focused test profile, removed, and recreated without retained mutable state
    **And** it reuses established entity, combat, action, spawn, and scope contracts
    **And** production weak-point opening, selected pressure attacks, complete boss encounter progression, reward, exit, and final presentation remain outside this story.

2. **Consume the approved boss specification exactly**

    **Given** Story 8.1 has a current approved version
    **When** Garden Heart runtime composition begins
    **Then** its stable identity, body policy, health hypothesis, phase structure, action ownership, collision relationships, weak-point slots, presentation seams, reset policy, and performance allocation trace to that version
    **And** implementation records the consumed specification and selection versions
    **And** an incompatible or superseded specification blocks initialization
    **And** code does not fill an unresolved design field with a hidden default.

3. **Author one immutable Garden Heart definition**

    **Given** the boss gameplay variant is inspected
    **When** `GardenHeartDefinition` resolves
    **Then** it declares a stable definition ID and version, combatant definition, maximum and initial health, phase-definition references, body and query profiles, approved anchored or bounded movement policy, action policy, weak-point slot references, presentation profile, audio profile, and reset policy
    **And** exact tuning values use semantic units and approved authored data
    **And** duplicate phase or slot IDs, invalid health, missing required profiles, incompatible policy, or unapproved selected content fails validation
    **And** runtime health, current phase, action, vulnerability, and death never mutate the shared Resource.

4. **Compose one concrete boss coordinator**

    **Given** the Garden Heart scene is opened
    **When** its public composition is validated
    **Then** one `GardenHeartCoordinator` composes health, phase runtime, action owner, LimboAI intent adapter where approved, body collision, hurtbox and future weak-point host, presentation adapter, audio adapter, and diagnostic provider
    **And** each component exposes a narrow typed boundary and retains only owner-local mutable state
    **And** external systems initialize and query the coordinator rather than reaching into private descendants
    **And** no universal boss base class or global boss manager is introduced for this single slice.

5. **Initialize from one typed spawn context**

    **Given** a prepared Garden Heart instance is not yet active
    **When** it receives its spawn context
    **Then** the context carries stable application, level-session, encounter, encounter-run, participant, entity, definition, deterministic-seed, arena, player-target, scope, and required service identities or narrow references
    **And** the coordinator validates every required identity and dependency before activating any component
    **And** initialization prepares health, phases, action policy, collision, presentation, audio, and diagnostics while simulation remains inactive
    **And** failure returns one typed result and releases partial state exactly once.

6. **Keep each Garden Heart occurrence run-scoped**

    **Given** the boss initializes successfully
    **When** it becomes active in a fixture or later encounter
    **Then** it carries one entity occurrence and current encounter-run identity for all health, action, damage, phase, spawn, presentation, and audio facts
    **And** child effects inherit that scope unless a validated delivery policy explicitly says otherwise
    **And** the boss cannot migrate to another run or level session
    **And** invalidating the run revokes new boss work before cleanup begins.

7. **Apply the approved body policy**

    **Given** the boss design declares an anchored or bounded movement relationship
    **When** the Garden Heart body is active
    **Then** its collision shape, occupied volume, orientation, and any permitted movement remain within the Story 8.2 arena relationship
    **And** an anchored boss cannot drift, receive arbitrary knockback, or be moved by presentation
    **And** any approved bounded movement uses the established enemy motion authority and semantic influences rather than direct external transform or velocity writes
    **And** collision cannot trap the player inside the boss or close onto an approved recovery route.

8. **Give the boss owner-local health**

    **Given** the Garden Heart initializes for a fresh run
    **When** its `CombatHealth` becomes ready
    **Then** current and maximum health come from the immutable boss definition and begin at the authored baseline
    **And** alive, damaged, dead, runtime invulnerability, accepted occurrence history, and reset identity remain owner-local
    **And** no phase, HUD, AI, encounter, or presentation component writes health directly
    **And** a fresh occurrence receives fresh health state rather than copying a previous boss.

9. **Accept only resolved current-run damage**

    **Given** a delivery targets a supported Garden Heart hurtbox in the focused core fixture
    **When** the health boundary receives its committed `DamageInstance`
    **Then** it validates target, hurtbox, occurrence, current run, alive state, current test-profile acceptance, and duplicate policy before changing health
    **And** source offense, movement context, impact context, defense, resistance, and incoming modifiers were resolved through the established damage pipeline
    **And** wrong-target, wrong-run, malformed, duplicate, invulnerable, closed-profile, and post-death damage returns a typed rejection
    **And** expected rejection leaves health and phase state unchanged.

10. **Use a separate core-runtime test damage profile**

    **Given** production vulnerability behavior belongs to Story 8.5
    **When** core health and phase behavior is tested in isolation
    **Then** the named Garden Heart core fixture uses an immutable development-only acceptance profile that allows explicitly authored test deliveries to reach health
    **And** the profile is visibly distinct from the production weak-point policy and cannot enter the final level manifest
    **And** test controls create normal typed damage requests rather than writing health or phase values
    **And** passing the core fixture cannot be cited as proof of a production vulnerability opening.

11. **Commit damage results once**

    **Given** a valid damage occurrence reaches living boss health
    **When** application succeeds
    **Then** one result records previous health, applied amount, resulting health, lethal state, source and execution attribution, impact identity, run identity, and physics step
    **And** current health remains within valid bounds
    **And** the committed fact publishes after owner-local mutation
    **And** reentrant or repeated delivery of the same occurrence returns the existing result without applying again.

12. **Own boss phase state explicitly**

    **Given** the Garden Heart definition declares a bounded ordered or graph-based phase structure
    **When** runtime state initializes
    **Then** one boss-owned phase component records current phase identity, phase occurrence, entry fact, eligible action set, vulnerability policy reference, elapsed simulation time where applicable, transition eligibility, and terminal state
    **And** it exposes typed read-only current state and committed transitions
    **And** presentation, LimboAI, individual actions, health, and encounter code cannot set the phase directly
    **And** the phase runtime cannot outlive its Garden Heart occurrence.

13. **Evaluate phase transitions from authoritative facts**

    **Given** the approved design uses health thresholds, completed cycles, destroyed boss-owned targets, or another declared transition input
    **When** one of those facts commits
    **Then** the phase owner validates current phase, occurrence, threshold direction, prerequisite set, run identity, and duplicate transition identity
    **And** it commits at most one legal next phase according to the immutable definition
    **And** presentation completion, animation markers, audio, scene-node absence, or unordered signal callbacks cannot advance the phase
    **And** crossing multiple thresholds in one accepted damage result follows the documented deterministic carry-over policy.

14. **Prevent phase regression and duplicate entry**

    **Given** a phase transition has committed
    **When** duplicate, delayed, reordered, or stale input arrives
    **Then** the boss cannot return to an earlier phase or enter the same phase twice unless the approved graph explicitly includes a distinct re-entry occurrence
    **And** each phase entry creates one stable occurrence and one committed fact
    **And** illegal transitions return a typed reason without changing eligible actions or health
    **And** restarting the complete boss occurrence is the normal way to return to initial phase state.

15. **Compose the established enemy action lifecycle**

    **Given** the core boss becomes active
    **When** action capability is initialized
    **Then** one boss action owner supports requested, windup, active, recovery, completion, cooldown, and reason-coded cancellation through the established simulation-authored lifecycle
    **And** the core fixture uses only an inert or non-damaging test action needed to verify state ownership
    **And** selected Garden Heart pressure definitions and delivery behavior remain absent until Stories 8.6 and 8.7
    **And** animation, VFX, audio, and LimboAI cannot directly activate hitboxes or complete actions.

16. **Keep LimboAI limited to tactical intent**

    **Given** Story 8.1 approves LimboAI for Garden Heart action selection
    **When** the behavior tree runs in the core fixture
    **Then** it may read typed boss, player, arena, phase, cooldown, and action-availability state and request one eligible intent
    **And** it cannot change health, phase, vulnerability, collision, hitboxes, damage, timers, or encounter progression
    **And** missing eligible action or invalid target state returns the approved idle or safe fallback
    **And** deterministic seed and stable tie-breaking make the same test state reproducible.

17. **Coordinate phase changes with current actions safely**

    **Given** a phase transition becomes eligible during an action lifecycle
    **When** the phase owner applies the approved transition policy
    **Then** the current action completes, cancels, or reaches a declared safe boundary according to reason-coded design data
    **And** at most one terminal action result occurs
    **And** the new phase cannot select an action before transition readiness commits
    **And** no orphaned hitbox, timer, movement influence, spawn, telegraph, or audio request survives an action cancelled for phase transition.

18. **Commit boss death exactly once**

    **Given** accepted damage reduces Garden Heart health to zero
    **When** `CombatHealth` commits lethal application
    **Then** it enters dead state and publishes one immutable current-run death fact
    **And** the coordinator prevents new tactical decisions, actions, vulnerabilities, collisions that should no longer block the player, and future damage acceptance according to the design
    **And** current actions and boss-owned transient work receive the declared death cancellation or persistence policy
    **And** duplicate lethal damage, post-death hits, animation completion, or missing body nodes cannot produce another death.

19. **Keep death distinct from encounter and level completion**

    **Given** Garden Heart death commits in the core fixture
    **When** observers receive the fact
    **Then** it contains the boss, entity occurrence, definition, encounter-run, lethal damage, and physics-step identities needed by a later encounter owner
    **And** the boss coordinator does not complete an encounter, satisfy a level objective, authorize a reward, open an exit, or change application flow
    **And** the focused fixture may display death state without pretending the final boss loop completed
    **And** Story 8.9 remains responsible for encounter and objective integration.

20. **Use replaceable primitive state presentation**

    **Given** final Garden Heart model, animation, VFX, and audio are unavailable
    **When** core alive, phase, damaged, transitioning, dead, invalid, or resetting state changes
    **Then** primitive geometry, materials, labels, and optional semantic placeholder cues make the state observable
    **And** presentation consumes committed boss projections and cannot change health, phase, action, collision, or death
    **And** each state has a non-color distinction where it is critical to the review
    **And** future assets can replace the adapter without changing runtime ownership.

21. **Terminate and recreate the boss cleanly**

    **Given** the core fixture resets, the encounter run is invalidated, or the containing level ends
    **When** cleanup begins
    **Then** new work is rejected before the action owner, phase runtime, health, hurtboxes, AI, presentation, audio, diagnostics, and child scopes terminate exactly once or idempotently
    **And** every signal and typed follow binding is disconnected
    **And** shared definitions remain unchanged
    **And** a fresh spawn receives new occurrence and run identities with baseline health, initial phase, no active action, and no retained death or duplicate history.

22. **Reject stale boss work**

    **Given** damage, action, phase, AI, presentation, audio, spawn, or cleanup work belongs to an invalid run or old boss occurrence
    **When** it reaches a current owner
    **Then** it cannot change health, phase, action, collision, current presentation, or the fresh boss
    **And** it returns a bounded typed stale result
    **And** no retained source reference keeps the old boss alive
    **And** repeated stale work cannot grow histories without bound.

23. **Expose bounded core-boss diagnostics**

    **Given** development diagnostics are enabled
    **When** the Garden Heart core is inspected
    **Then** diagnostics show definition, entity, scope and run identities; health; accepted and rejected damage; current phase and transition inputs; action state; AI intent; body policy; child-scope counts; death; cleanup; and stale results
    **And** they consume maintained owner state rather than calculating health, phase, or action outcomes again
    **And** histories and drawings have explicit bounds and stop when hidden
    **And** release-like behavior omits or disables the detailed overlay and test damage controls.

24. **Make the core runtime manually reproducible**

    **Given** another developer launches the named Garden Heart core fixture with the development-only damage profile
    **When** they initialize, activate, exercise the inert action lifecycle, apply nonlethal, threshold-crossing, exact-lethal, overkill, duplicate, wrong-run, and post-death damage, then reset and respawn repeatedly
    **Then** health, phase changes, action cancellation, death, cleanup, and fresh state follow the approved contracts exactly once
    **And** the tester can inspect anchored or bounded body behavior and primitive states without an active boss pressure
    **And** stale callbacks and randomized fact ordering cannot mutate the fresh occurrence
    **And** retained evidence separates objective identity, ownership, health, phase, damage, death, cleanup, and repeatability from subjective scale and presentation observations.

25. **Verify the core runtime automatically**

    **Given** definition validators, focused health and phase tests, action-lifecycle tests, scope integration tests, and the real-scene core fixture run
    **When** they exercise initialization, invalid definitions, fresh occurrence allocation, body policy, damage acceptance and rejection, threshold carry-over, legal and illegal phase transitions, action coordination, deterministic intent, death, duplicate terminal facts, run invalidation, stale work, reset, and repeated recreation
    **Then** one current boss owns one coherent health, phase, and action state and every occurrence reaches at most one death
    **And** no private node-path dependency, direct health write, duplicate action owner, phase regression, stale mutation, or retained old boss survives
    **And** shared definitions retain their fingerprints
    **And** the production manifest cannot reference the development-only damage profile.

26. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** equivalent core-boss scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **When** action phases, timed transition boundaries, damage, threshold crossings, death, cleanup, and respawn resolve
    **Then** authored real-time behavior, phase sequence, health results, action terminal results, death, and fresh-state outcomes remain equivalent
    **And** no timer uses rendered frames, raw ticks, wall-clock time, animation callbacks, or audio playback
    **And** additional callbacks cannot create duplicate transitions or death
    **And** a rate-sensitive authoritative difference blocks the story.

27. **Keep the story bounded to the core boss combatant**

    **Given** Story 8.4 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the immutable Garden Heart definition, concrete coordinator, typed initialization, body policy, health, core phase authority, inert action composition, committed damage and death, cleanup, primitive state presentation, diagnostics, and focused verification
    **And** it does not implement production weak-point openings, selected boss pressures, phase attack escalation, complete boss encounter progression, boss checkpoint behavior, boss HUD, final presentation, reward, exit, or final balance
    **And** those outcomes remain assigned to Stories 8.5 through 8.12.
