---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 5
---

# Story 6.5: Escape Anti-Wall Pressure on an Infested Route

As a player,
I want a hazardous wall and an enemy's response to prolonged wall use to remain distinct and counterable,
So that I can still use walls deliberately without treating them as either completely safe or completely forbidden.

**Acceptance Criteria:**

1. **Declare the combined gameplay question**

   **Given** the surface-state-and-anti-wall scenario is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player recognizes both a temporarily devalued wall and a separate attack selected because they remain on a wall too long
   **And** its surface lifecycle, wall-use threshold, spatial relationship, viable responses, deliberate failures, tether recovery, source-death behavior, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one surface mutation and one contextual enemy action rather than a general wall-punishment system or production encounter.

2. **Compose the approved mechanics without redesigning them**

   **Given** Stories 3.9 and 4.7 established contextual anti-wall harpoon selection and the infested-wall state
   **When** Story 6.5 is implemented
   **Then** it references their existing immutable definitions, surface owner, response channels, contact damage, locomotion context, tactical snapshots, AI intent, action lifecycle, projectile, harpoon link, motor influence, grapple, source-death, restoration, and cleanup behavior
   **And** neither mechanic receives combination-specific wall detection, damage, movement, attack, tether, or terminal logic
   **And** the fixture owns only authored setup, bounded activation, result observation, reset, and evidence.

3. **Use two independent pressure sources**

   **Given** the combination participants are inspected
   **When** their roles are resolved
   **Then** one primitive surface source can request infestation against the designated wall region
   **And** one explicitly opted-in anti-wall enemy evaluates the player's public tactical snapshots and may request the approved harpoon
   **And** the surface source cannot inspect player locomotion or request the harpoon
   **And** the anti-wall enemy cannot mutate, restore, retarget, or infer gameplay state from the wall's presentation.

4. **Author one immutable combination manifest**

   **Given** the baseline combination profile is inspected
   **When** its values and references are resolved
   **Then** it declares one production player, one surface source, one opted-in anti-wall source, the approved component definitions, designated surface region, alternate routes, participant transforms, activation plan, wall-use test windows, occurrence limits, manual checks, and evidence rules
   **And** it permits one unresolved infestation and only the anti-wall source's ordinary unresolved action and link limits
   **And** surface timing and responses, contact damage, contextual threshold, harpoon timing, projectile behavior, tether behavior, cadence, and source-death policies remain referenced from their original definitions
   **And** combination-only positions and route geometry remain immutable authored configuration.

5. **Provide one bounded primary and alternate wall layout**

   **Given** the baseline fixture is opened
   **When** its authored geometry is inspected
   **Then** the designated six-by-six-metre stateful wall forms the primary vertical route
   **And** an otherwise equivalent unmodified wall provides an alternate vertical comparison route
   **And** the anti-wall source remains between 6 and 18 metres from each intended wall-use region with valid gameplay line of sight
   **And** the surface source remains within its 20-metre targeting range and valid line of sight to the designated region
   **And** a lower route, grapple route, harpoon cover, wall-jump landing, and nonterminal recovery space remain available.

6. **Validate route and recovery safety before activation**

   **Given** a paired attempt is requested
   **When** the pressure lab validates its participants and layout
   **Then** it confirms stable identities, current run, source eligibility, surface-state ownership, region bounds, base response version, response-channel availability, ranges, line of sight, anti-wall opt-in policy, projectile corridor, tether range, cover, and recovery spaces
   **And** the infested wall is not the only route required to avoid the harpoon
   **And** expected modified wall movement and tether pull cannot remove every reachable wall-jump, grapple, cover, lower-route, or landing response
   **And** invalid or unsafe prerequisites return a typed failure without creating a surface execution, AI request, projectile, link, damage occurrence, or evidence attempt.

7. **Start every attempt from fresh scoped state**

   **Given** all prerequisites are valid
   **When** a new attempt begins
   **Then** the player and both sources receive typed initialization under one fresh fixture-run identity
   **And** the designated wall begins with its immutable base response and no active modifier or accepted-recipient history
   **And** the anti-wall source begins without a target-history artifact, accumulated wall-use duration, pending request, projectile, link, or consumed cadence
   **And** player health, transform, velocity, locomotion, contacts, grapple, AI, surface, action, damage, and evidence state contain no data from an earlier attempt.

8. **Activate infestation through its normal action boundary**

   **Given** the fresh attempt is ready
   **When** the fixture requests the combined sequence
   **Then** one infestation request is submitted through the surface source's existing action owner
   **And** the owner independently validates and advances the complete one-second non-damaging windup before surface activation
   **And** the fixture does not assign the surface response, add the hazardous tag, apply contact damage, skip windup, or reserve the anti-wall attack
   **And** rejection remains observable and makes the paired attempt incomplete.

9. **Let anti-wall evaluation remain continuously available**

   **Given** the anti-wall source is alive, active, and opted into its contextual policy
   **When** current tactical snapshots become available before, during, or after infestation activation
   **Then** it evaluates the ordinary wall-use, contact, line-of-sight, range, action, and cadence gates from Story 3.9
   **And** it does not wait for a fixture signal declaring the wall infested
   **And** it cannot fabricate wall contact or submit the attack merely because the surface execution exists
   **And** an ineligible snapshot produces its normal reason-coded fallback without request spam.

10. **Keep surface state out of the contextual trigger**

    **Given** the designated surface is previewing, active, hazardous, restored, or unmodified
    **When** the anti-wall policy evaluates the player
    **Then** eligibility depends on committed wall-running or wall-sticking state, stable contact identity, continuous wall-use time, range, line of sight, target validity, action readiness, and cadence
    **And** the `HAZARDOUS_SURFACE` tag, infestation occurrence, contact-damage result, surface presentation, movement multiplier, or slide speed cannot directly satisfy or bypass the policy
    **And** the same qualifying wall use on the normal comparison wall remains eligible
    **And** merely aiming at, grappling, attacking, or standing near either wall remains ineligible.

11. **Keep continuous wall-use timing independent of movement speed**

    **Given** infestation changes the player's wall-run speed or wall-stick movement
    **When** public tactical state reports continuous time on the same valid contact
    **Then** time accumulates from authoritative simulation duration rather than distance travelled, animation progress, speed, surface state, or rendered frames
    **And** the threshold remains exactly the approved 0.60 seconds
    **And** slower movement may increase practical exposure without shortening or accelerating the timer itself
    **And** equivalent real elapsed time produces equivalent eligibility on normal and infested walls.

12. **Preserve same-contact state transitions**

    **Given** the player changes between wall running and wall sticking on the same infested or normal contact
    **When** the anti-wall policy evaluates the next tactical snapshot
    **Then** the continuous-wall-use interval remains uninterrupted
    **And** infestation-driven downward sliding does not create a new contact identity or reset the interval
    **And** leaving contact, wall-jumping, changing wall identity, dying, or changing run resets the interval according to Story 3.9
    **And** surface activation or restoration alone does not fabricate a contact change.

13. **Keep both warnings distinguishable**

    **Given** infestation warning or active presentation overlaps an anti-wall harpoon windup
    **When** the tester observes the fixture without diagnostics
    **Then** the infestation remains a bounded wall-region cue communicating changed traversal and first-contact hazard
    **And** the anti-wall attack remains a directional source-to-player lane that visibly changes from tracking to locked
    **And** non-color-only location, geometry, motion, and phase cues distinguish the persistent wall condition from the incoming projectile
    **And** neither cue hides the wall boundary, attack direction, lock state, route alternatives, or relevant counter.

14. **Preserve safe short-duration wall use**

    **Given** the player begins wall-running or wall-sticking on either wall from a fresh contact
    **When** they wall-jump, grapple away, or otherwise leave before 0.60 continuous seconds
    **Then** no anti-wall request is produced from that contact interval
    **And** use of the infested region still applies its approved movement response and at most one first-contact damage result while contact exists
    **And** the player retains the movement and momentum produced by the ordinary exit action
    **And** short wall use remains a useful deliberate traversal option.

15. **Trigger the normal harpoon after prolonged wall use**

    **Given** the player remains wall-running or wall-sticking on one contact for at least 0.60 seconds while all contextual gates are valid
    **When** the anti-wall policy selects its branch
    **Then** it submits one ordinary `EnemyAbilityRequest` for the approved anti-wall harpoon
    **And** the source action owner independently validates and commits the 0.80-second windup
    **And** surface state cannot force acceptance, skip tracking, shorten lock, improve aim, or alter projectile speed
    **And** an accepted request is not duplicated while pending or active.

16. **Treat wall exit as evasion rather than cancellation**

    **Given** the anti-wall harpoon has committed
    **When** the player leaves the infested wall, wall-jumps, grapples away, transfers walls, or reaches the lower route
    **Then** the attack continues through its ordinary first 0.40-second tracking and final 0.40-second locked phases
    **And** the player's context change does not automatically cancel or retarget it
    **And** leaving before or after lock can produce a miss according to the current or frozen lane
    **And** the player can understand that crossing the threshold committed an attack that now requires a separate response.

17. **Keep the infested wall usefully traversable**

    **Given** the designated surface is active
    **When** the player runs, sticks, slides, wall-jumps, or grapples along it
    **Then** the approved 0.60 wall-run speed multiplier, 0.50 acceleration multiplier, and bounded downward slide apply through existing locomotion and motor owners
    **And** wall-running, wall-sticking, wall-jumping, collision, and grapple eligibility remain available
    **And** one first-contact hit or reduced wall performance does not force detachment or disable the route
    **And** a sufficiently decisive player can still use the wall and leave before or during the anti-wall attack.

18. **Prove the normal wall does not bypass anti-wall pressure**

    **Given** the player uses the unmodified comparison wall
    **When** they remain on the same contact beyond 0.60 seconds with all other gates valid
    **Then** the anti-wall source requests the same approved harpoon
    **And** no infestation movement response, contact damage, or hazardous-surface cue applies
    **And** leaving the infested wall for the normal wall resets the old contact interval but does not make prolonged use of the new wall universally safe
    **And** this demonstrates that the contextual action responds to wall behavior rather than a specific surface asset or tag.

19. **Keep non-contact grappling distinct from wall use**

    **Given** the infested wall remains ordinarily grappleable
    **When** the player attaches to it without establishing authoritative body contact
    **Then** attachment alone applies no contact damage and produces no wall-running or wall-sticking interval
    **And** the anti-wall policy remains ineligible unless a later committed contact enters an approved wall locomotion state
    **And** grapple targeting communicates the hazardous-surface response without inventing a wall-use fact
    **And** ordinary grapple pull and maximum-length behavior remain authoritative.

20. **Compose tether pull and surface movement through existing owners**

    **Given** the anti-wall harpoon hits and creates its recipient-owned link while the player remains on or returns to the infested wall
    **When** the player motor resolves movement
    **Then** the link submits its approved sustained pull while wall locomotion consumes the current surface-response snapshot
    **And** both contributions follow the existing semantic motor ordering, grapple constraints, collision, contacts, and one final movement commit
    **And** neither component assigns final velocity, parents the player, teleports them, or directly changes the other component's state
    **And** actual contact loss or continuation is published through the resulting `ContactFrame`.

21. **Preserve every approved harpoon counter**

    **Given** an anti-wall harpoon is tracking, locked, travelling, or tethered
    **When** the player responds
    **Then** they may leave or change direction after lock, use eligible cover against delivery, grapple to another route, wall-jump, or otherwise leave the frozen lane before impact
    **And** an attached tether may be broken through 0.25 seconds of continuous cover, separation beyond 24 metres, source loss, or ordinary four-second expiry
    **And** the player's active grapple remains independently owned
    **And** the infestation does not disable, shorten, redirect, or secretly invalidate these counters.

22. **Preserve recovery after contact or attachment**

    **Given** the player receives the infestation's one-time four damage, becomes tethered, or experiences both during one attempt
    **When** they remain alive
    **Then** they retain movement input, wall jump, air control, grapple, wall traversal, cover, camera, and attack control
    **And** the lower route, alternate wall, grapple route, or harpoon-cover region remains reachable
    **And** contact damage does not stun or repeat, and tether pull does not become stronger because the surface is infested
    **And** the combination cannot create an unbroken pull, slide, damage, or attack chain that removes every recovery response.

23. **Apply surface contact damage exactly once**

    **Given** the player contacts, leaves, re-enters, changes wall states on, or is pulled back onto the active infested region
    **When** surface damage eligibility resolves
    **Then** that infestation occurrence can damage the player no more than once
    **And** anti-wall selection, projectile impact, tether attachment, tether pull, grapple attachment, or restored contact cannot reset its accepted-recipient identity
    **And** the harpoon's baseline impact remains non-damaging as established by Story 3.7
    **And** attribution clearly distinguishes the surface-contact result from the harpoon link.

24. **Apply both source-death policies independently**

    **Given** the surface source dies during windup or active infestation
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** only the preview or active surface occurrence terminates and the wall recomputes its base response
    **And** any committed harpoon projectile or link continues according to its own source policy.

    **Given** the anti-wall source dies during harpoon delivery or active tether
    **When** its approved source-death policy resolves
    **Then** the harpoon execution or link terminates without changing the infestation
    **And** killing either source cannot kill, heal, reset, retarget, or alter the other source.

25. **Restore surface state without altering contextual history**

    **Given** infestation expires or its source dies while the player is on the wall or a harpoon is unresolved
    **When** the surface occurrence is removed
    **Then** the surface recomputes its immutable base response plus any surviving compatible state
    **And** existing contact and grapple owners consume the restored response without reconnecting or restarting
    **And** continuous wall-use time remains based on actual contact rather than being reset solely by restoration
    **And** accepted contact damage remains accepted and no velocity or health is refunded.

26. **Record one bounded attempt result**

    **Given** the paired attempt has begun
    **When** the player reaches an authored traversal endpoint, returns to a recovery region, dies, the surface expires, the run resets, or the tester aborts
    **Then** the fixture records one terminal attempt result without moving the player, changing health, ending a link, or altering the surface to manufacture it
    **And** it distinguishes short safe wall use, prolonged-use attack, clean harpoon evasion, tether recovery, route completion, recovery after damage, player defeat, partial activation, invalid setup, and abort
    **And** evidence records wall identity, surface state, contact intervals, locomotion transitions, contextual gates, harpoon phases, contact damage, link state, movement responses, routes, source states, and terminal times
    **And** the result grants no reward, objective progress, checkpoint, or production encounter state.

27. **Reset surface, context, and tether state completely**

    **Given** reset is requested during surface targeting, windup, activation, body contact, wall locomotion, threshold accumulation, harpoon request, tracking, lock, projectile travel, attachment, pull, break, source death, restoration, or evidence finalization
    **When** the old run is invalidated
    **Then** surface executions, occurrences, response entries, accepted-recipient records, tactical snapshots, continuous-use time, AI intent, action requests, projectiles, links, motor submissions, targets, source states, presentations, attempt results, and late work are removed or rejected exactly once
    **And** player health, transform, velocity, traversal and grapple state, both walls, and both sources return to their authored starting conditions
    **And** a fresh attempt begins without stale damage eligibility, wall time, cadence, link, or surface response.

28. **Keep combination layout and activation configurable**

    **Given** an alternate valid profile changes source positions, wall positions, infestation request timing, player entry window, route markers, cover, or recovery geometry
    **When** the same fixture consumes it
    **Then** validation, activation, AI observation, evaluation, and evidence use those authored values without code changes
    **And** no profile mutates infestation timing or responses, contact damage, wall threshold, harpoon timing, projectile speed, tether behavior, cadence, or source-death definitions
    **And** at least one alternate-profile test proves the participant geometry and surface activation relationship are not hard-coded
    **And** invalid profiles fail instead of receiving hidden wall-time adjustment, aim assistance, movement restoration, or tether weakening.

29. **Provide replaceable combined feedback and diagnostics**

    **Given** final surface art, enemy animation, audio, and VFX are unavailable
    **When** infestation and anti-wall states overlap
    **Then** primitive wall-region boundaries, hazardous-surface cues, locomotion-response indicators, wall-use progress, source and lane warnings, projectile and tether geometry, pull direction, contact markers, route markers, and typed result displays make the scenario testable
    **And** future presentation can consume committed surface, context, action, link, motor, damage, and attempt facts without controlling them
    **And** diagnostics expose scenario and run identities, surface lifecycle and resolved responses, current contact identity, locomotion state, continuous wall-use time, every contextual gate, selected request, harpoon phases, projectile and link state, motor results, damage history, source state, terminal outcomes, and cleanup.

30. **Make the combination manually reproducible**

    **Given** the named infested-wall-and-anti-wall fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they first compare normal and infested movement, first-contact damage, and both overlapping warnings with diagnostics disabled
    **And** they use the infested wall for less than 0.60 seconds and leave safely, remain longer to trigger the harpoon, transition between run and stick on one contact, transfer walls, and verify prolonged use of the normal wall also triggers the attack
    **And** they evade a committed harpoon by leaving after lock, accept another tether and break or outlast it, grapple the infested wall without body contact, and recover through the alternate wall, lower route, cover, or grapple path
    **And** they activate infestation while already touching the wall, test surface expiry and restoration during prolonged use and tether pull, kill each source during its relevant phases, reset during every combined phase, and repeat the scenario
    **And** every check has observable pass or fail conditions and retained evidence separates objective surface, context, attack, recovery, and cleanup results from subjective route value, pressure, cue clarity, punishment, and movement-feel observations.

31. **Verify deterministic combined behavior**

    **Given** the permanent surface-and-anti-wall suite and focused real-Jolt fixture run
    **When** they exercise normal and infested wall use, exact dwell boundaries, same-contact state transitions, contact changes, activation during contact, contextual branch selection, harpoon tracking and lock, projectile hit and miss, link pull and break, grapple interaction, contact-damage uniqueness, surface restoration, both source deaths, stale runs, randomized callback order, and repeated reset
    **Then** surface response and restoration remain deterministic, continuous-use time comes only from committed locomotion context, each qualifying interval produces no more than one accepted attack request, and each infestation damages the player no more than once
    **And** the combination retains at least one viable pre-impact response and one recovery after ordinary nonlethal contact or attachment without creating a control chain
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time surface lifecycle, movement response, wall-use eligibility, harpoon timing, tether behavior, damage, terminal results, and cleanup within documented tolerances.

32. **Keep the story bounded to one approved pair**

    **Given** Story 6.5 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it contains only the existing infested-wall state, existing contextual anti-wall harpoon, one surface source, one opted-in anti-wall source, two comparison walls, one bounded fixture, observational evaluation, reset, and focused verification
    **And** it has not added spreading infestation, wall destruction, anchor modification, universal anti-wall behavior, new harpoon effects, repeated control chains, production enemy allocation, encounter orchestration, rewards, objectives, difficulty scaling, final presentation, or Last Garden allocation
    **And** the final combination, full 17-mechanic gate, and production-subset decision remain assigned to later Epic 6 stories.
