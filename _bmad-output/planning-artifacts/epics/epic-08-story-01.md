---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 1
---

# Story 8.1: Define and Approve the Garden Heart Boss Fight

As a player,
I want the Garden Heart to turn successful traversal and counterplay into clear attack openings,
So that defeating the boss demonstrates mastery of the abilities and pressures learned throughout the slice.

**Acceptance Criteria:**

1. **Create one versioned boss-fight specification**

    **Given** Epic 8 is ready for production allocation
    **When** the Garden Heart specification is created
    **Then** it records a stable specification identity and version, design owner, approval state, source build, selected-mechanic decision, encounter fantasy, arena relationship, attack-response cycle, pressure catalog, vulnerability rules, phase structure, health and damage rules, failure and recovery behavior, presentation requirements, implementation allocation, review procedure, and explicit exclusions
    **And** unresolved design decisions remain visible and prevent approval
    **And** implementation stories reference this approved version rather than inventing boss behavior locally
    **And** subsequent material changes produce a new reviewed version.

2. **Require an approved Last Garden selection**

    **Given** Story 6.8 owns production-subset selection
    **When** the boss specification begins
    **Then** Story 6.8 must provide a current approved decision record derived from a passing Story 6.7 vocabulary gate
    **And** the decision must assign at least one validated M2 pressure mechanic to the Garden Heart
    **And** build, physics configuration, definition fingerprints, capacity constraints, known risks, and simultaneous-use restrictions must remain traceable
    **And** an incomplete, stale, failed, or unapproved selection blocks boss allocation.

3. **Require the complete M3 foundation**

    **Given** the Garden Heart consumes traversal, combat, encounter, level, HUD, audio, checkpoint, reward, loading, and replay contracts
    **When** implementation readiness is reviewed
    **Then** Story 7.17 must have a current passing result for the intended integration build
    **And** Story 7.16's minimum-spec result and limitations must be available for boss-density planning
    **And** a failing prerequisite creates separately scoped remediation rather than being waived inside boss design
    **And** Epic 8 does not replace an existing contract merely because the boss requires it.

4. **Consume every relevant role disposition explicitly**

    **Given** Story 6.8 records decisions for Rootstalker, Spore Kite, Mycelial Weaver, and Garden Heart
    **When** the Last Garden slice allocation is documented
    **Then** every `ADVANCE_ROLE` entry identifies its intended place in the boss level, such as an approach encounter, supporting pressure, or boss behavior
    **And** every `DEFER_ROLE` entry remains absent with its approved rationale preserved
    **And** Bloombound Hunter remains optional unless the selection record explicitly allocates capacity to it
    **And** no rejected or deferred mechanic or role is silently reintroduced.

5. **Define the Garden Heart's gameplay identity**

    **Given** the boss must embody the traversal-combat pillars
    **When** its core fantasy is documented
    **Then** the Garden Heart is defined as an encounter that controls route, altitude, timing, or spatial safety while periodically becoming vulnerable through player counterplay
    **And** the player is expected to remain mobile and use the arena rather than stand in one optimal damage position
    **And** each major boss behavior asks a recognizable traversal, timing, observation, or target-priority question
    **And** visual theme alone cannot substitute for a distinct gameplay function.

6. **Define one repeatable attack-response loop**

    **Given** the boss is active and able to fight
    **When** one complete combat cycle is described
    **Then** it contains an authoritative pressure windup, readable affected space or target, active consequence, player response opportunity, counter resolution, vulnerability opening where applicable, player attack opportunity, recovery or closure, and next-cycle selection
    **And** every state identifies its owner, entry condition, exit condition, cancellation behavior, timing source, and player-facing cues
    **And** the player can fail the response without the cycle becoming permanently unwinnable
    **And** animation or audio completion never advances the cycle.

7. **Turn traversal into an offensive opening**

    **Given** a Garden Heart pressure has an intended counter
    **When** the player performs that counter successfully
    **Then** the resulting boss opening depends on an authored traversal-combat fact such as route change, altitude, grapple use, wall movement, momentum, spatial positioning, timed crossing, or destruction of a reachable encounter target
    **And** the exact qualifying facts and tolerances are documented
    **And** simply waiting, attacking a closed target, or absorbing enough damage cannot produce the same opening unless explicitly designed
    **And** the opening can be reproduced manually using normal player controls.

8. **Define the weak-point and vulnerability model**

    **Given** Story 6.8 did not validate a complete boss weak-point system
    **When** Garden Heart vulnerabilities are specified
    **Then** every weak point declares a stable identity, supported hurtbox relationship, closed and open targetability, incoming-damage policy, opening source, opening duration or closure condition, presentation state, and reset behavior
    **And** `ImpactContext` captures the actual accepted weak-point or hurtbox identity at impact
    **And** current vulnerability and incoming modifiers are resolved by the target at impact rather than copied from attack commitment
    **And** a closed, disabled, stale, or visually exposed but non-authoritative weak point cannot receive vulnerability damage.

9. **Make vulnerability windows bounded and readable**

    **Given** the player satisfies an opening condition
    **When** the boss commits vulnerability
    **Then** the window has an authored duration in seconds or another explicit simulation-owned closure condition
    **And** the player receives sufficient visual and audible confirmation to identify the opening and its impending closure
    **And** closing cannot invalidate damage already accepted during the window
    **And** presentation latency or animation markers cannot extend, shorten, reopen, or duplicate it.

10. **Define a bounded phase structure**

    **Given** the complete boss encounter is reviewed
    **When** phases are enumerated
    **Then** the specification defines the minimum phase structure required to create a readable beginning, escalation, and defeat without adding phases solely to lengthen the fight
    **And** each phase declares its entry condition, available selected mechanics, attack-response changes, overlap limit, vulnerability behavior, arena-state changes, and exit condition
    **And** health thresholds, completed cycles, destroyed boss-owned targets, or other transition facts are selected explicitly rather than inferred from presentation
    **And** a phase transition commits exactly once and cannot restore an earlier phase accidentally.

11. **Map every selected boss mechanic to a purpose**

    **Given** the Garden Heart has one or more selected M2 mechanics
    **When** its pressure catalog is completed
    **Then** each selected mechanic identifies the phase or phases that can use it, the player question it creates, its primary counter, ordinary failure consequence, recovery option, grapple and wall interactions, and relationship to vulnerability
    **And** its validated shared implementation family and immutable definitions remain authoritative
    **And** supported parameter tuning may create the boss variant without changing the shared mechanic contract
    **And** contract-changing behavior is separated into new design and architecture work rather than disguised as boss tuning.

12. **Keep attack selection deterministic and bounded**

    **Given** more than one boss response is currently eligible
    **When** the Garden Heart selects its next action
    **Then** the design defines phase eligibility, repetition limits, spacing rules, deterministic seed use, stable tie-breaking, cooldown or exclusion rules, and safe fallback behavior
    **And** selection avoids unreadable repeated patterns without promising arbitrary procedural variety
    **And** no action becomes eligible through animation state, audio playback, scene-tree order, or an unbounded random retry
    **And** a missing valid action produces the documented safe fallback or typed encounter failure.

13. **Declare the maximum readable overlap**

    **Given** selected boss pressures could coexist
    **When** simultaneous use is designed
    **Then** the specification records an approved maximum overlap and the exact pairings or sequences allowed within that limit
    **And** Story 6.1 through 6.6 combination evidence is claimed only for pairings actually tested there
    **And** an unvalidated simultaneous pairing requires a focused combination test before production use
    **And** the fight always preserves a readable response and recovery route rather than forming an unavoidable control chain.

14. **Preserve low, high, lateral, and recovery options**

    **Given** the boss arena supports vertical traversal
    **When** each phase and pressure pattern is mapped onto it
    **Then** low, high, and lateral routes retain distinct tactical value
    **And** ordinary mistakes retain at least one documented recovery route where the pattern is not intentionally terminal
    **And** temporary route, surface, obstacle, anchor, or aerial pressure cannot silently remove the complete movement vocabulary
    **And** any deliberately restricted option has a visible cause, bounded duration, and alternative response.

15. **Define the boss arena relationship**

    **Given** traversal is part of both defense and offense
    **When** the boss-arena diagram is reviewed
    **Then** it identifies arena bounds, boss position or movement region, low, high, lateral, and recovery routes, grapple targets, walls, cover, weak-point access lines, pressure origins, checkpoint entrance, player start, and safe defeat or reward area
    **And** all required routes and counter opportunities use achievable production traversal metrics
    **And** no critical route depends on a diagnostic teleport, hidden anchor, or disposable tutorial geometry
    **And** exact transforms and dimensions remain authored level data rather than boss-code literals.

16. **Avoid health-attrition victory**

    **Given** the Garden Heart has authored health
    **When** expected damage opportunities are planned
    **Then** meaningful damage is concentrated in understandable openings created through the intended response loop
    **And** closed-state chip damage, if permitted at all, cannot become the fastest or safest primary victory strategy
    **And** expected successful openings, approximate attacks per opening, and target fight length are recorded as tuning hypotheses rather than hidden code constants
    **And** final numerical balance remains adjustable through immutable definitions and later playtesting.

17. **Reuse established damage and death contracts**

    **Given** the player attacks an exposed Garden Heart target
    **When** a hit is accepted
    **Then** attack commitment, immutable movement context, delivery snapshot, actual impact context, current weak-point state, target-side modifiers, health application, reaction, and lethal result follow the established M1 contracts
    **And** each delivery occurrence can affect each supported hurtbox only according to its authored per-execution hit policy
    **And** boss health reaches death through one committed damage result
    **And** duplicate, stale, closed-target, wrong-run, or post-death damage cannot produce another health or death result.

18. **Keep boss state under explicit owners**

    **Given** the Garden Heart runtime is decomposed for implementation
    **When** ownership mappings are inspected
    **Then** the boss coordinator composes health, weak points, presentation, tactical selection, and the established enemy action lifecycle without becoming the level or encounter authority
    **And** LimboAI may select intent but cannot activate hitboxes, change vulnerability, write velocity, commit phase transitions, or complete the encounter directly
    **And** the action owner controls windup, active, recovery, completion, and cancellation for each boss ability
    **And** `EncounterController` owns the current boss run while `LevelController` alone owns level objective progression.

19. **Define boss encounter activation and recovery**

    **Given** the player reaches the boss boundary
    **When** activation, death, encounter restart, checkpoint reload, level reload, or exit occurs
    **Then** the design identifies the boss checkpoint, authored player restore position, gate behavior, fresh run creation, boss reset state, arena restoration, and eligible recovery commands
    **And** every boss-owned participant, weak point, spawned pressure, surface mutation, audio emitter, presentation adapter, and delayed callback belongs to the current encounter or level scope
    **And** a retry recreates mutable boss state rather than scrubbing shared definitions
    **And** no prior attempt can damage, expose, select, or complete the fresh boss.

20. **Connect boss death to the level objective**

    **Given** Garden Heart health commits one valid death for the current boss run
    **When** the boss encounter resolves its participant and completion rules
    **Then** `EncounterController` commits one boss-encounter completion fact
    **And** the boss-level `LevelObjective` consumes that scoped fact through `LevelController`
    **And** empty geometry, a missing boss node, presentation completion, a stale death, or direct reward access cannot satisfy the objective
    **And** the exact reward and exit implementation remains assigned to later Epic 8 stories.

21. **Define boss HUD and feedback requirements**

    **Given** Story 7.1 reserved a major-encounter presentation boundary
    **When** the Garden Heart HUD handoff is completed
    **Then** it specifies when boss identity, health, phase, vulnerability, current response objective, and terminal state appear, change, hide, or fail safely
    **And** the boss presentation consumes authoritative encounter, health, phase, and weak-point projections
    **And** it coexists with player health, grapple feedback, abilities, prompts, and central world telegraphs without obscuring traversal
    **And** critical states use non-color distinctions and remain understandable with diagnostics disabled.

22. **Define replaceable animation, VFX, and audio adapters**

    **Given** final Garden Heart assets are unavailable
    **When** presentation responsibilities are allocated
    **Then** primitive geometry, materials, fallback telegraphs, placeholder animation state, and semantic audio cues make every required source, windup, affected space, active state, vulnerability, impact, phase transition, and death state reviewable
    **And** future animation, VFX, audio, and model assets can replace the presentation adapters without changing gameplay geometry or timing
    **And** animation markers and audio completion remain cosmetic
    **And** a missing optional presentation asset uses its declared fallback rather than making the attack unreadable or blocking gameplay.

23. **Define combat-critical residency requirements**

    **Given** the boss level is loaded through the controlled application boundary
    **When** Garden Heart readiness is evaluated
    **Then** the boss scene, selected mechanic definitions, abilities, projectiles, effects, weak points, primitive telegraphs, animation placeholders, audio fallbacks, query profiles, HUD adapters, checkpoint, reward, and objective dependencies are resident before activation
    **And** the dependency mapping identifies required and optional presentation content explicitly
    **And** first-time synchronous loading during the boss encounter is prohibited
    **And** a missing required dependency blocks activation through a typed failure.

24. **Keep tuning parameterized and reviewable**

    **Given** the boss design includes health, phase, timing, geometry, selection, vulnerability, damage, route, and overlap values
    **When** its tuning table is inspected
    **Then** each value declares its semantic unit, approved baseline hypothesis, supported range or option set, definition owner, affected behavior, and evidence needed for later adjustment
    **And** shared Resources remain immutable during play
    **And** challenge variants reference alternate typed definitions rather than mutable runtime overrides
    **And** final balance remains explicitly unapproved until playtest evidence supports it.

25. **Allocate implementation into bounded follow-on stories**

    **Given** the selected subset, boss phases, and role decisions are approved
    **When** the implementation allocation is reviewed
    **Then** each boss-arena, core-runtime, selected-pressure, vulnerability, phase, presentation, encounter, reward, exit, and final-validation outcome has one identified follow-on story
    **And** a selected mechanic or advanced supporting role too large for an existing story is split before implementation begins
    **And** no story is expected to productionize an unbounded number of selected mechanics
    **And** deferred roles and mechanics create no empty placeholder implementation work.

26. **Respect the measured performance envelope**

    **Given** Story 7.16 defines the current minimum-spec and representative M3 measurements
    **When** boss content density is budgeted
    **Then** the design records expected maximum participants, active selected pressures, spatial queries, projectiles, hazards, temporary objects, telegraphs, audio voices, and presentation elements by phase
    **And** unknown boss-specific costs remain identified as risks requiring measurement
    **And** the design does not assume unmeasured pooling, streaming, or speculative optimization
    **And** M4 performance must be remeasured with representative boss density before final completion.

27. **Provide a manually reviewable boss-cycle package**

    **Given** the design is ready for review
    **When** another developer opens the named Garden Heart design package
    **Then** it contains an annotated arena diagram, phase and health-state table, attack-response timelines, selected-mechanic mappings, weak-point state gallery, allowed-overlap matrix, HUD layout, cue mapping, recovery flow, tuning table, implementation allocation, and unresolved-risk list
    **And** selected mechanics can be viewed through their existing M2 fixtures or recorded evidence without claiming that a full boss already exists
    **And** a non-authoritative state gallery can demonstrate boss HUD and fallback-presentation states without entering gameplay authority
    **And** every artifact identifies the specification and source-selection version it represents.

28. **Walk through success and failure manually**

    **Given** the review package and selected-mechanic evidence are available
    **When** the reviewer follows the documented walkthrough
    **Then** they can trace at least one complete successful attack-response cycle, one failed response with ordinary recovery, one vulnerability opening and closure, each proposed phase transition, boss death, encounter restart, and the intended reward-and-exit handoff
    **And** they can identify the expected player decision, authoritative fact, presentation cue, counter, failure consequence, and cleanup scope at every step
    **And** objective omissions and contract conflicts are recorded separately from subjective excitement, clarity, pacing, and perceived difficulty
    **And** implementation approval does not depend on final art, animation, VFX, or audio.

29. **Fail closed on unresolved boss design**

    **Given** the selected subset is missing, the boss has no traversal-created opening, a pressure lacks counter or recovery, overlap is unvalidated, weak-point authority is ambiguous, a required role has no disposition, ownership conflicts with the architecture, required presentation has no fallback, or implementation allocation is unbounded
    **When** design readiness is evaluated
    **Then** Story 8.1 becomes `INCOMPLETE` or `FAILED` rather than partially approved
    **And** each blocker identifies the missing decision or remediation owner
    **And** Garden Heart production implementation cannot begin from that result
    **And** resolving the blockers produces a new reviewable specification version.

30. **Approve one complete implementation handoff**

    **Given** all required design artifacts, mappings, decisions, and review evidence are complete
    **When** the designated design owner evaluates Story 8.1
    **Then** the selected Garden Heart mechanics, attack-response cycle, traversal-created opening, weak-point behavior, phases, arena relationship, overlap limits, presentation requirements, tuning hypotheses, and follow-on allocation are explicitly approved
    **And** every blocking question has a recorded answer
    **And** the handoff remains traceable to Story 6.8 and Story 7.17
    **And** implementation may begin without inventing fundamental boss behavior.

31. **Keep the story bounded to boss-fight definition**

    **Given** Story 8.1 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains only the approved Garden Heart design specification, diagrams, state and response tables, fallback-presentation requirements, implementation allocation, review gallery, and human approval evidence
    **And** it does not implement the boss runtime, boss arena, selected mechanics, production supporting enemies, final HUD, final assets, reward, exit, or final balance
    **And** those outcomes remain assigned to later Epic 8 stories.
