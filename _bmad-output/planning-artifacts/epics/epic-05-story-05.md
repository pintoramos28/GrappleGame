---
artifact_schema: 1
artifact_id: 'grapplegame.story.5.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 5
story: 5
---

# Story 5.5: Break Enemy Support While Under Melee Pressure

As a player,
I want an active support relationship and its interruption options to remain understandable while another enemy pressures me,
So that I can make a deliberate target-priority decision and defeat the enemies through more than one viable strategy.

**Acceptance Criteria:**

1. **Declare the target-priority gameplay question**

   **Given** the coordinated support-pressure prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player can identify the support source, relay, supported recipient, and connection while deciding what to attack or disrupt first
   **And** it combines exactly one existing healing-support source with one existing melee combatant rather than becoming a general encounter, wave, or squad-behavior system
   **And** its layout, starting state, concurrent activation, allowed strategies, success and failure conditions, recovery, reset, tuning, manual procedure, and evidence policies are explicit.

2. **Reuse the approved melee and healing-support mechanics**

   **Given** Story 2 established the production melee-combatant behavior and Story 5.4 established interruptible healing support
   **When** the target-priority fixture is implemented
   **Then** it composes those existing action, AI, attack, health, damage, support-link, relay, target, grapple, and lifecycle contracts without duplicating them
   **And** fixture code is limited to authored setup, prerequisite validation, coordinated activation, bounded scenario commands, terminal evaluation, reset, and retained evidence
   **And** no fixture-owned attack, healing, interruption, target-selection, damage, or movement implementation becomes authoritative.

3. **Author one immutable scenario manifest**

   **Given** the baseline target-priority scenario is inspected
   **When** its manifest is resolved
   **Then** it identifies the production player, one melee recipient, one support source, the approved melee and healing-support definitions, the authored fixture geometry, allowed routes, initial transforms, and scenario rules by stable references
   **And** the melee recipient starts alive at 50 percent of its configured maximum health while the support source and player start at their configured full health
   **And** referenced mechanic values remain owned by their original definitions rather than being copied into the fixture manifest, coordinator, evaluator, or presentation.

4. **Build one bounded vertical target-priority fixture**

   **Given** the scenario scene is opened
   **When** its authored layout is inspected
   **Then** it provides a central melee space, an elevated support platform approximately 6 metres above and 14 metres from the player's starting position, and one central line-of-sight blocker that can separate the recipient from the relay
   **And** grapple paths provide access toward the relay and support source, a wall route provides another elevated approach, and lateral plus lower recovery routes remain available
   **And** the layout is a focused disposable fixture rather than the current tutorial, the Last Garden production level, or a production enemy allocation.

5. **Validate every prerequisite before activation**

   **Given** a target-priority run is requested
   **When** the fixture validates its manifest and resident scene
   **Then** it confirms compatible definitions, stable participant identities, required components and bindings, authored transforms, health capacities, route and effect bounds, static geometry, query profiles, pressure-lab services, and a fresh run identity
   **And** missing, duplicated, incompatible, stale, or out-of-bounds prerequisites return a typed failure identifying the violated requirement
   **And** failure creates no partial participant activation, health change, AI command, support reservation, relay, grapple target, evidence run, or scenario result.

6. **Start every attempt from one fresh scoped state**

   **Given** all prerequisites are valid
   **When** a new attempt begins
   **Then** the player, melee recipient, and support source are initialized through their typed production boundaries under one fresh fixture-run identity
   **And** the recipient begins at exactly 50 percent of its configured maximum health without synthetic damage, hit reactions, attack credit, or an already active support occurrence
   **And** authored transforms, health, velocity, traversal state, AI state, action cadence, targeting, and scenario evidence contain no state from an earlier attempt.

7. **Give each enemy one clear existing role**

   **Given** the attempt becomes active
   **When** enemy behavior begins
   **Then** the melee recipient pursues and attacks the player through its approved Story 2 behavior
   **And** the support source holds its authored platform position and evaluates only the approved Story 5.4 healing-support request for the designated recipient
   **And** the support source gains no damaging attack, forced movement, escape behavior, armor, resistance, or hidden defensive modifier in this fixture
   **And** AI may choose and request an authored action but never owns attack execution, link creation, healing, damage, interruption, or terminal resolution.

8. **Keep the support request narrowly targeted**

   **Given** the support source is eligible to begin its authored healing action
   **When** its AI requests a recipient
   **Then** only the designated living melee combatant can be submitted to the existing action owner
   **And** the action owner independently validates the source, recipient, missing health, range, line of sight, cadence, reservations, definitions, and run before accepting the request
   **And** requests for the source itself, player, relay, a dead or full-health target, another target, or a stale identity are rejected without partial support state.

9. **Run melee and support as concurrent independent lifecycles**

   **Given** both enemies are active
   **When** the melee combatant attacks while the support source winds up, channels, heals, is interrupted, or waits for cadence
   **Then** each action progresses through its own simulation-owned lifecycle and existing authority boundaries
   **And** starting, interrupting, completing, or rejecting support does not restart, cancel, accelerate, or reorder the recipient's melee action
   **And** a melee attack does not alter support timing except through an ordinary consequence that already changes an authoritative endpoint, health, or connection condition.

10. **Keep all three support roles readable under pressure**

    **Given** the recipient is actively pursuing or attacking the player while healing support is winding up or active
    **When** the player observes the fixture without diagnostic overlays
    **Then** source, relay, recipient, source-to-relay segment, relay-to-recipient segment, healing pulses, invalid-segment progress, and interruption state remain distinguishable through non-color-only primitive cues
    **And** the melee attack's anticipation, active threat, and recovery cues remain visible and are not replaced or obscured by support presentation
    **And** the player can tell whether support is winding up, active, temporarily blocked, interrupted, completed, or waiting for its next cadence opportunity.

11. **Leave target and route selection under player control**

    **Given** both enemies and any active relay are valid targets under their existing rules
    **When** the player moves, aims, grapples, or attacks
    **Then** ordinary production targeting and traversal determine the selected surface or target
    **And** the fixture does not force aim, camera direction, facing, lock-on, target priority, movement route, or attack recipient
    **And** source, relay, recipient, geometry, and grapple paths retain the eligibility and rejection behavior established by their owning systems.

12. **Support a source-interruption strategy**

    **Given** healing support is winding up or active while the melee recipient remains alive and hostile
    **When** the player uses any valid traversal route to reach the source and deals accepted positive damage to it
    **Then** Story 5.4's authoritative source-damage condition interrupts support exactly once
    **And** the recipient continues its current combat behavior rather than freezing, despawning, or losing aggression
    **And** the resulting support-free interval is long enough only according to the existing cadence and does not receive a fixture-specific extension.

13. **Support a relay-destruction strategy**

    **Given** a live healing relay is active while the melee recipient pressures the player
    **When** the player grapples toward or attacks the relay and reduces its existing health to zero
    **Then** relay death terminates the support link through Story 5.4 and opens the ordinary cadence-governed support-free interval
    **And** the player can continue fighting the source or recipient through the existing combat rules
    **And** if the player is attached when the relay dies, the grapple releases once with resolved velocity preserved and no fixture-authored movement correction.

14. **Support a connection-break strategy**

    **Given** the active recipient can move around the central line-of-sight blocker while the relay remains fixed
    **When** the player deliberately lures or allows the recipient to remain behind the blocker so a relay segment is continuously invalid for 0.50 seconds
    **Then** Story 5.4 terminates the support occurrence with the appropriate connection-break reason
    **And** the strategy requires no debug command, direct AI steering, teleported participant, or fixture-authored endpoint override
    **And** at least one lateral or lower recovery route lets the player survive the maneuver and resume combat.

15. **Allow the player to fight through healing**

    **Given** the player chooses to keep attacking the supported recipient
    **When** melee damage and scheduled healing affect the recipient
    **Then** both resolve through the same existing health owner using their committed identities and defined ordering
    **And** damaging the recipient does not itself interrupt support, reset pulse timing, or transfer the link
    **And** sufficiently effective ordinary combat can defeat the recipient despite healing, while this remains one viable choice rather than the only required strategy.

16. **Retain the authored support cadence after interruption**

    **Given** support ends because of source damage, relay destruction, connection break, recipient state, or ordinary completion
    **When** the support source remains alive and the designated recipient later becomes eligible again
    **Then** a new request can begin only when Story 5.4's original start-to-next-start cadence permits it
    **And** the fixture does not immediately recast, shorten, extend, restart, or otherwise replace that cadence
    **And** primitive feedback distinguishes an interrupted link, the support-free window, and a later valid windup.

17. **Permit either enemy defeat order**

    **Given** both enemies are alive at the start of combat
    **When** the player defeats the support source first
    **Then** current and future healing support ends through its source-death policy while the melee recipient remains an ordinary hostile combatant.

    **Given** the player defeats the melee recipient first
    **When** recipient death commits
    **Then** the active support link ends without resurrection or retargeting while the support source remains present and independently defeatable
    **And** neither order grants rewards, advances an objective, triggers reinforcements, or silently despawns the survivor.

18. **Do not invent a replacement recipient**

    **Given** the designated melee recipient becomes dead, invalid, or otherwise permanently ineligible
    **When** the support source next evaluates its action
    **Then** it enters its existing safe idle or fallback behavior without selecting the player, relay, itself, an arbitrary fixture entity, or an unsupported new target
    **And** no stale target, reservation, link, healing pulse, or retry survives
    **And** general multi-target support selection remains outside this story.

19. **Preserve expressive traversal during combined pressure**

    **Given** melee and healing-support pressure overlap
    **When** the player uses the central space, elevated grapple approach, wall route, lateral route, or lower recovery route
    **Then** the existing movement, grapple, wall, attack, collision, and movement-combat contracts remain authoritative
    **And** the fixture, support source, relay, recipient, and evaluator never assign player velocity, consume movement input, force facing, teleport the player, or prescribe a route
    **And** high, lateral, and lower approaches remain physically available unless ordinary enemy contact or player choice changes the immediate situation.

20. **Preserve recovery after an ordinary mistake**

    **Given** the player takes a normal melee hit, allows one or more healing pulses, misses an interruption, or initially chooses an inefficient target
    **When** the player survives the result
    **Then** they can retreat through an authored recovery route, reassess the support relationship, change target or counter, and resume the attempt
    **And** healing support does not amplify melee damage, extend control, add stagger, suppress recovery, or make either enemy invulnerable
    **And** an ordinary mistake does not cause an unavoidable control chain or fixture-authored instant failure.

21. **Recognize only authoritative interruption conditions**

    **Given** support presentation and combat activity overlap
    **When** the player crosses a rendered segment, moves the camera, aims at a role, touches a preview, produces a rejected hit, briefly breaks a segment, or triggers only presentation feedback
    **Then** support remains governed by Story 5.4's approved damage, relay-death, source-death, recipient-state, continuous connection, and lifecycle conditions
    **And** no visual overlap, camera state, beam touch, melee contact, or evaluator observation can interrupt or sustain the link
    **And** every accepted interruption retains its original typed reason and attribution.

22. **Resolve one bounded scenario result**

    **Given** a target-priority attempt is active
    **When** both the support source and melee recipient have authoritative defeated states and the support occurrence is terminal with no unresolved relay or reservation
    **Then** the evaluator commits exactly one successful scenario result for the current run
    **And** relay destruction, a temporary interruption, defeat of only one enemy, diagnostic completion, or elapsed time alone cannot satisfy success
    **And** player death commits one failed result and disables further scoring until reset
    **And** the evaluator only reads committed facts and never deals damage, changes health, interrupts support, kills enemies, or alters AI.

23. **Prove at least two distinct successful strategies**

    **Given** the fixture uses the same manifest, mechanic definitions, enemy starting state, and tuning across repeated fresh runs
    **When** the manual gate is completed
    **Then** at least one successful run interrupts support through accepted player damage to the source
    **And** at least one other successful run interrupts support through relay destruction or a continuous connection break
    **And** both runs end with both enemies defeated without cheats, debug state mutation, fixture edits, disabled AI, altered health, altered timing, or changed difficulty
    **And** variations that differ only in presentation, exact path within the same strategy, or defeat timing do not count as distinct interruption strategies.

24. **Retain comparable strategy evidence**

    **Given** a target-priority attempt begins and later becomes terminal
    **When** its evidence record is finalized
    **Then** it records the manifest and definition versions, participant starting state, chosen route and initial target, interruption method and time, healing pulses requested, applied, skipped, or prevented, damage results, relay outcome, player damage received, recovery events, defeat order, completion time, terminal result, and reset result
    **And** compared strategy runs identify the same tuning and content revision
    **And** objective lifecycle, health, interruption, traversal, terminal, and cleanup facts remain distinct from subjective observations about cue clarity, perceived pressure, preferred target, route appeal, and strategy difficulty.

25. **Clean up correctly after either defeat order**

    **Given** either enemy dies while melee, support windup, an active link, pulse delivery, relay targeting, cadence, or another action is unresolved
    **When** authoritative death and scenario-terminal processing completes
    **Then** the dead participant's actions, AI, targets, reservations, support state, presentation, and late work terminate through their existing owners
    **And** the surviving participant retains only valid current state and never references the defeated actor as an actionable target or recipient
    **And** the scenario result becomes terminal no more than once even if both deaths, link termination, relay cleanup, and callbacks occur in the same simulation step.

26. **Reset the coordinated attempt completely**

    **Given** the player requests reset or the fixture reloads after success, failure, or any intermediate phase
    **When** the old run is invalidated and a fresh run is created
    **Then** player, source, recipient, relay, support, melee action, AI, health, transforms, velocity, grapple, wall interaction, cadence, cues, evaluator, result, and retained per-run evidence return to their authored initial conditions
    **And** late callbacks, targets, pulses, damage, reservations, interrupts, and terminal results from the old run are rejected by run identity
    **And** repeating either strategy does not depend on scene reload order or state left by the preceding strategy.

27. **Keep presentation and diagnostics replaceable**

    **Given** final character animation, audio, and VFX are unavailable
    **When** melee and support lifecycles overlap
    **Then** primitive silhouettes, endpoint and relay shapes, link segments, pulse cues, health indicators, melee telegraphs, interruption states, cadence states, route markers, and typed result displays make the fixture testable
    **And** future animation, support and combat VFX, audio, camera feedback, enemy models, and materials can consume committed facts without controlling gameplay or success evaluation
    **And** diagnostics expose stable run and participant identities, current actions and targets, support lifecycle and cadence, relay and segment state, pulse and health results, interruption attribution, movement and grapple state, enemy deaths, evaluator state, and cleanup results.

28. **Make the target-priority scenario manually reproducible**

    **Given** the named target-priority fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can first observe uninterrupted healing while surviving melee pressure, then complete separate attempts by interrupting the source, destroying the relay, and luring the recipient behind cover until the connection breaks
    **And** they can verify that a brief obstruction does not break the link, recipient damage does not interrupt it, and a later support request respects the original cadence
    **And** they can defeat the source first and the recipient first, recover after a normal mistake, complete at least two qualifying strategies under unchanged tuning, die and reset, and repeat each result
    **And** the procedure supplies observable pass or fail conditions for targeting, readability, support, melee pressure, interruption, recovery, victory, cleanup, and repeatability rather than relying on developer intuition alone.

29. **Verify deterministic coordinated behavior**

    **Given** the permanent target-priority suite and focused real-Jolt fixture run
    **When** they exercise simultaneous melee and support starts, uninterrupted pulses, source interruption, relay destruction, brief and continuous obstruction, recipient damage and death, source death, both defeat orders, cadence re-entry, player death, simultaneous terminal events, stale runs, randomized callback order, and repeated reset
    **Then** melee and support retain independent valid lifecycles, every attack and healing occurrence affects health no more than once, and each attempt commits no more than one terminal result
    **And** automated checks prove the required source-damage strategy and at least one relay-destruction or connection-break strategy remain achievable under the same authored configuration without mutating the run to manufacture success
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve lifecycle timing, damage and healing results, interruptions, cadence, defeat order, terminal result, and cleanup within documented tolerances.

30. **Keep this story bounded to one target-priority fixture**

    **Given** Story 5.5 is complete
    **When** its scope is reviewed
    **Then** it contains only the existing melee combatant, existing healing-support source, one relay, authored routes and cover, scenario coordination, terminal evaluation, reset, evidence, and focused verification needed for the target-priority question
    **And** it has not implemented encounter orchestration, waves, reinforcements, multiple support recipients, relay networks, squad tactics, difficulty scaling, rewards, loot, objectives, checkpoints, production enemy placement, production HUD, final animation, final audio, or final VFX
    **And** broader combinations remain allocated to Epic 6 and production encounter use remains allocated to later approved epics.
