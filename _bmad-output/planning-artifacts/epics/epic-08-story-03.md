---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 3
---

# Story 8.3: Complete the Last Garden Approach Encounter

As a player,
I want the approach to the Garden Heart to test the selected Last Garden pressures in a coherent encounter,
So that reaching the boss feels like the culmination of learned route, movement, and target-priority decisions.

**Acceptance Criteria:**

1. **Declare the focused approach-encounter outcome**

    **Given** the Last Garden environment shell and approved production allocation exist
    **When** the approach encounter is inspected
    **Then** it provides one required encounter between level entry and the boss checkpoint using the bounded supporting-role composition approved by Story 8.1
    **And** role composition, selected mechanics, activation, route interaction, completion, recovery, presentation, cleanup, diagnostics, manual procedure, and automated evidence are explicit
    **And** the encounter is playable with primitive assets through existing M1-M3 contracts
    **And** Garden Heart runtime, boss phases, boss vulnerabilities, boss reward, and final exit remain outside this story.

2. **Consume only approved role allocations**

    **Given** Story 6.8 and Story 8.1 contain role dispositions
    **When** approach participants are allocated
    **Then** only roles marked `ADVANCE_ROLE` and explicitly assigned to the approach may receive Last Garden gameplay variants
    **And** every `DEFER_ROLE` or `REJECTED_FOR_SLICE` entry remains absent
    **And** an existing validated M3 participant may be used only when Story 8.1 explicitly assigns it to complete the bounded composition
    **And** no role is included merely because its name or visual theme fits the level.

3. **Keep the composition within approved capacity**

    **Given** the approach allocation may include Rootstalker, Spore Kite, Mycelial Weaver, or an explicitly approved optional role
    **When** implementation sizing is reviewed
    **Then** the participant count, distinct role count, selected mechanic count, overlap, tuning work, and presentation work fit Story 8.1's approved capacity
    **And** every new gameplay variant reuses a validated archetype, locomotion policy, ability family, and encounter contract
    **And** an allocation requiring more than one story-sized productionization unit is split before implementation begins
    **And** reducing evidence or combining unvalidated mechanics is not used to make an oversized composition appear bounded.

4. **Author one immutable approach encounter definition**

    **Given** the selected composition is final
    **When** its `EncounterDefinition` is inspected
    **Then** it declares stable encounter and definition versions, participant entries, spawn references, selected role definitions, mechanic definitions, deterministic seed policy, bounds, activation region, completion rule, reset policy, presentation profile, and resident dependencies
    **And** participant and mechanic variants are referenced through immutable typed Resources
    **And** duplicate IDs, missing role allocations, unselected mechanics, incompatible versions, or invalid dependencies fail validation
    **And** runtime health, AI, ability, participant, and encounter state never mutates the definition.

5. **Productionize advanced roles through composition**

    **Given** a selected supporting role enters the approach encounter
    **When** its scene and definition are inspected
    **Then** it composes the established health, damage, hit-query, movement, perception, LimboAI, enemy-action, ability, telegraph, audio, and diagnostic boundaries required by its approved function
    **And** its selected mechanics reference the shared implementations validated in M2
    **And** role-specific tuning and presentation remain typed variant data
    **And** it does not create a second motor, damage system, ability lifecycle, AI action owner, or mechanic-specific framework.

6. **Preserve geometry-discovered Rootstalker behavior when selected**

    **Given** Rootstalker is advanced and allocated to the approach
    **When** it responds to a player using a wall or elevated route
    **Then** it finds climb-entry and pounce opportunities from nearby navigation, surface probes, current geometry, and player state
    **And** it performs bounded climb-and-pounce behavior with safe abort and tactical fallback
    **And** no hand-authored climb route or climb-entry anchor is required
    **And** its selected anti-wall or melee pressure remains readable, counterable, and independently owned.

7. **Preserve geometry-discovered Spore Kite behavior when selected**

    **Given** Spore Kite is advanced and allocated to the approach
    **When** it selects an aerial tactical position
    **Then** it generates and scores bounded candidates from player state, encounter bounds, preferred distance and altitude, line of sight, obstacles, and current pressure
    **And** it uses deterministic tie-breaking, hysteresis, bounded replanning, and a safe fallback
    **And** no flight anchors, connections, or separate flight volume are required
    **And** its selected arcing, predictive, cloud, mine, or other approved pressure remains source-attributed and reset-safe.

8. **Preserve route-and-support ownership for Mycelial Weaver when selected**

    **Given** Mycelial Weaver is advanced and allocated to the approach
    **When** it changes route value or supports another participant
    **Then** obstacle, adhesive, surface, anchor, link, or other selected behavior uses its validated shared mechanic contract
    **And** every created object or target-owned state carries source, execution, scope, and encounter-run attribution
    **And** its support relationship has the approved visible source, recipient, counter, and more than one viable disruption method where required
    **And** source death, interruption, completion, or reset removes its contribution through the normal owner.

9. **Keep optional supporting roles conditional and explicit**

    **Given** Story 8.1 allocates Bloombound Hunter or another permitted optional role
    **When** its inclusion is reviewed
    **Then** the capacity decision, role function, selected validated mechanics, overlap evidence, and production rationale are recorded
    **And** it cannot displace required evidence for advanced FR56 roles
    **And** absence remains valid when no optional role was approved
    **And** no optional participant introduces a new unvalidated pressure family.

10. **Activate through normal level and encounter authority**

    **Given** the current player reaches the authored approach region with prerequisites satisfied
    **When** activation is accepted
    **Then** `LevelController` issues one typed request to the approach `EncounterController`
    **And** a fresh encounter-run identity and replaceable runtime root are created before the complete participant set becomes active
    **And** the encounter gate changes only through level-owned committed state
    **And** duplicate crossings, stale sessions, or partial participant readiness cannot create another run.

11. **Keep every spawn inside the current run**

    **Given** participants or their abilities create projectiles, telegraphs, hazards, obstacles, links, surface changes, decoys, audio, or other transients
    **When** a domain spawner commits creation
    **Then** each instance carries its source, execution, level-session, encounter-run, definition, and occurrence identities
    **And** it attaches to the correct run, level, or target-owned scope according to the validated mechanic policy
    **And** no participant reparents gameplay objects into an untracked long-lived node
    **And** missing or invalid required spawns fail through the responsible action or encounter owner.

12. **Use the authored approach routes tactically**

    **Given** the encounter is active
    **When** the player chooses low, high, lateral, or recovery geometry
    **Then** the selected composition changes the value of at least two routes through approved pressure, position, visibility, target-priority, or recovery behavior
    **And** no route is always optimal across the complete encounter
    **And** production grapple and wall movement remain useful rather than decorative
    **And** the player can switch routes after an ordinary mistake without leaving encounter bounds.

13. **Preserve readable counters and recovery**

    **Given** any selected approach mechanic succeeds or the player makes an ordinary error
    **When** the consequence resolves
    **Then** the documented primary counter and recovery remain achievable in the authored composition
    **And** overlapping pressure retains at least one viable response and cannot form an unbroken control chain
    **And** source, warning, affected space or target, active state, and outcome remain understandable with diagnostics hidden
    **And** intentionally terminal failure remains distinct from ordinary recoverable pressure.

14. **Use only validated simultaneous combinations**

    **Given** two selected mechanics may be active together
    **When** the approach composition schedules their overlap
    **Then** the exact pairing and conditions have supporting Story 6 combination evidence or a focused new combination validation approved by Story 8.1
    **And** overlap remains within the approved maximum readable count
    **And** warning and counter distinctions survive the shared arena geometry
    **And** unvalidated additional overlap is sequenced rather than presented simultaneously.

15. **Complete from committed participant outcomes**

    **Given** the approach encounter is active
    **When** all required current-run participants commit valid defeat or other approved completion facts
    **Then** `EncounterController` commits completion exactly once
    **And** `LevelController` records the approach prerequisite and opens the onward route to the boss checkpoint
    **And** empty geometry, missing nodes, stale deaths, diagnostic selection, or visual disappearance cannot complete it
    **And** completion does not activate or damage the Garden Heart.

16. **Preserve a safe boss approach after completion**

    **Given** the approach encounter completes
    **When** its pressure and gate cleanup finishes
    **Then** the player can reach the Story 8.2 boss-entry checkpoint without remaining hazards, support links, route mutations, hostile audio loops, or blocked recovery paths
    **And** completed participants cannot reactivate or continue selecting actions
    **And** the checkpoint remains outside the former encounter's active pressure space
    **And** boss activation remains a later explicit commitment.

17. **Support death and encounter restart**

    **Given** the player dies or severely fails while the approach encounter is active
    **When** Restart Encounter is selected
    **Then** the current run is invalidated, its complete runtime root and transients are removed, the player restores at the approved approach position, and one fresh run activates
    **And** participant health, AI memory, ability state, effects, and seeded selection begin from authored baseline
    **And** a checkpoint reload restores the applicable earlier level state through Story 7.7
    **And** no old participant or detached delivery can affect the new run.

18. **Remove all pressure on source death and reset**

    **Given** a participant dies, an action cancels, the encounter completes, its run restarts, or the level ends
    **When** the relevant cleanup policy executes
    **Then** source-bound actions, tethers, telegraphs, following audio, and owner-local state terminate through their declared policy
    **And** source-independent deliveries persist only while their current scope and definition permit
    **And** run invalidation removes every remaining scoped transient exactly once or idempotently
    **And** shared definitions and other encounters remain unchanged.

19. **Keep presentation replaceable and player-facing**

    **Given** final Last Garden enemy art, animation, VFX, and audio are unavailable
    **When** the encounter runs
    **Then** primitive silhouettes, role markers, fallback telegraphs, state materials, and semantic placeholder cues communicate each role, selected pressure, counter, hit, interruption, death, and completion
    **And** critical roles and states remain distinguishable without color alone
    **And** presentation consumes committed gameplay and never owns timing, collision, target selection, or completion
    **And** future assets can replace the role presentation adapters without changing gameplay contracts.

20. **Keep combat-critical content resident**

    **Given** the Last Garden manifest and approach encounter report readiness
    **When** activation is considered
    **Then** every required participant, selected mechanic, attack, projectile, effect, telegraph, audio fallback, query profile, navigation dependency, and presentation fallback is resident
    **And** no first-time synchronous load occurs during activation or combat
    **And** missing required content blocks the encounter before partial activation
    **And** optional presentation degrades only through a declared resident fallback.

21. **Expose bounded approach diagnostics**

    **Given** development diagnostics are enabled after the player-facing pass
    **When** the encounter is inspected
    **Then** they show role and definition versions, deterministic seed, participant and run identities, selected tactics, geometry candidates, action executions, selected mechanics, transient counts, overlap state, completion facts, cleanup, stale rejections, and timing
    **And** they consume maintained owner state without selecting tactics or recalculating gameplay
    **And** histories and drawings remain bounded and stop when hidden
    **And** release-like behavior omits or disables the detailed overlay and commands.

22. **Make each advanced role and the composition manually reproducible**

    **Given** another developer follows the named Last Garden approach procedure
    **When** they first run with diagnostics disabled
    **Then** they can identify every included role, experience each selected pressure, demonstrate its primary counter and ordinary recovery, choose at least two meaningful routes, complete the encounter, and reach the boss checkpoint
    **And** an isolated review step demonstrates each newly composed advanced role before the combined encounter where more than one is included
    **And** deliberate failure, interruption, source death, restart, checkpoint reload, stale work, and repeated completion leave the expected clean state
    **And** retained evidence separates objective lifecycle, mechanics, identities, routes, cleanup, and reproducibility from subjective role fit, clarity, difficulty, pacing, and production value.

23. **Verify the approach automatically**

    **Given** role validators, AI and mechanic contract tests, encounter integration tests, real-Jolt scene tests, and the Last Garden approach smoke fixture run
    **When** they exercise allocation validation, participant readiness, geometry-discovered tactics, action lifecycles, selected mechanics, source attribution, activation, route pressure, allowed overlap, completion, death, restart, stale work, cleanup, and repeated runs
    **Then** every participant and action reaches one valid terminal state and the encounter completes no more than once per run
    **And** no deferred role, unselected mechanic, hidden tactical anchor, escaped transient, duplicate signal, or prior-run state appears
    **And** immutable definitions retain their fingerprints
    **And** automated evidence supplements rather than replaces manual readability, counterplay, route-value, and recovery review.

24. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** the same deterministic approach scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **When** AI replanning, movement, abilities, telegraphs, damage, route effects, interruption, completion, and reset resolve
    **Then** real-time behavior, tactical choices at declared decision boundaries, gameplay outcomes, cleanup, and terminal results remain equivalent within documented tolerance
    **And** frame frequency cannot duplicate an action, participant, pressure, damage occurrence, or completion fact
    **And** no gameplay duration is authored in ticks or rendered frames
    **And** a rate-sensitive authoritative difference blocks the story.

25. **Respect the Last Garden performance allocation**

    **Given** the complete approach composition runs in the release-like minimum-spec environment
    **When** its representative worst-case overlap is measured
    **Then** participant, AI, navigation, query, projectile, hazard, presentation, and audio costs remain within the approved approach budget from Story 8.1
    **And** repeated encounter restarts do not increase retained object, signal, memory, or voice counts
    **And** the measurement remains provisional for the complete M4 gate until the boss is active
    **And** a proven over-budget result creates scoped remediation rather than silent content removal.

26. **Keep the story bounded to one approach encounter**

    **Given** Story 8.3 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains one bounded required approach encounter, only approved supporting roles and selected mechanics, route interaction, completion, restart, cleanup, fallback presentation, diagnostics, and focused evidence
    **And** it does not implement the Garden Heart runtime, boss weak points, boss attacks, boss phases, boss HUD, boss checkpoint activation, boss reward, final exit, final assets, or additional encounters
    **And** any oversized selected-role allocation is split before implementation rather than absorbed into this story.
