---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 4
---

# Story 6.4: Break Artillery Support While Evading Bombardment

As a player,
I want healing support and an incoming arcing bombardment to remain readable when they overlap,
So that I can evade the locked impact while deliberately choosing which source, relay, or recipient to pressure.

**Acceptance Criteria:**

1. **Declare the combined gameplay question**

   **Given** the support-and-artillery scenario is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player can evade source-independent bombardment while choosing whether to pressure the artillery recipient, interrupt the support source, or destroy the relay
   **And** its activation schedule, spatial relationship, target choices, viable counters, deliberate failures, recovery, source-death behavior, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one healing-support relationship and one artillery behavior rather than a general support squad or production encounter.

2. **Compose the approved support and bombardment mechanics**

   **Given** Stories 5.1 and 5.4 established source-independent arcing bombardment and interruptible healing support
   **When** Story 6.4 is implemented
   **Then** it references their existing immutable definitions, action owners, lifecycle timing, target sampling, trajectory, payload, impact, damage, health, relay, link, healing, interruption, grapple, source-death, and cleanup behavior
   **And** neither component receives combination-specific targeting, healing, damage, interruption, trajectory, movement, or terminal logic
   **And** the fixture owns only authored setup, bounded activation, result observation, reset, and evidence.

3. **Use the artillery source as the support recipient**

   **Given** the combination participants are inspected
   **When** their roles are resolved
   **Then** the artillery combatant is both the bombardment action owner and the designated recipient of the healing-support link
   **And** the support combatant owns only its approved healing-support action and has no damaging attack in this fixture
   **And** the relay retains its approved fixed placement, health, targetability, grapple response, and interruption behavior
   **And** no wrapper entity, duplicate health component, mirrored recipient, or fixture-owned proxy is introduced.

4. **Author one immutable combination manifest**

   **Given** the baseline combination profile is inspected
   **When** its values and references are resolved
   **Then** it declares one production player, one artillery recipient, one support source, the approved component definitions, fixture geometry, starting transforms, recipient starting-health rule, synchronized-opening plan, occurrence limits, manual checks, and evidence requirements
   **And** it permits one unresolved support occurrence and one unresolved bombardment per their approved source limits
   **And** healing amounts and timing, support ranges, relay health, bombardment timing and trajectory, impact geometry, damage, cadence, and source-death policies remain referenced from their original definitions
   **And** combination-only positions, scheduling, and evaluation rules remain immutable authored configuration.

5. **Provide one bounded artillery-and-support layout**

   **Given** the baseline fixture is opened
   **When** its authored geometry is inspected
   **Then** the artillery recipient occupies a stable firing platform between 6 and 30 metres from the player's starting and expected combat regions
   **And** the support source occupies a distinct lateral elevated platform within 20 metres of the artillery recipient
   **And** the frozen midpoint relay can satisfy both 12-metre segment limits with clear initial gameplay line of sight
   **And** separate grapple and movement approaches reach the recipient, relay, and support source
   **And** lateral exits, space above the three-metre impact height, eligible impact cover, wall traversal, and nonterminal recovery routes remain available.

6. **Validate recipient health for observable support**

   **Given** the artillery recipient must receive meaningful healing during the combined attempt
   **When** its authored starting health is validated
   **Then** it begins alive at 50 percent of its configured maximum health without synthetic damage, hit reaction, or player attack attribution
   **And** its missing health is sufficient for multiple baseline five-health pulses before reaching maximum health
   **And** its health owner remains authoritative for all later artillery damage, player damage, healing, and death
   **And** incompatible health capacity returns a typed setup failure instead of altering heal amount, maximum health, pulse count, or damage secretly.

7. **Validate both spatial relationships before activation**

   **Given** a paired attempt is requested
   **When** the pressure lab validates the fixture
   **Then** it confirms stable participant identities, current run, action readiness, artillery target range and gameplay line of sight, supported landing area, valid trajectory corridor, support targeting range, relay placement and clearance, segment lengths and line of sight, effect bounds, grapple routes, impact counters, and recovery spaces
   **And** at least one approach to the support source or relay remains outside any single locked impact cylinder
   **And** missing, stale, blocked, out-of-bounds, or unsafe prerequisites return a typed failure without creating an action, marker, payload, reservation, relay, link, pulse, or evidence attempt.

8. **Validate a survivable ordinary failure**

   **Given** the combination must demonstrate recovery rather than perfect avoidance only
   **When** player health, bombardment damage, fixture geometry, and follow-up cadence are validated
   **Then** one ordinary 12-damage artillery impact is nonlethal from the authored starting state
   **And** the player retains a reachable recovery route after that impact
   **And** the next bombardment cannot begin before the approved five-second start cadence
   **And** validation cannot compensate through fixture invulnerability, reduced damage, slowed flight, or suppressed enemy action.

9. **Start every attempt from fresh scoped state**

   **Given** all prerequisites are valid
   **When** a new attempt begins
   **Then** the player, artillery recipient, and support source receive typed initialization under one fresh fixture-run identity
   **And** the artillery recipient begins at its authored damaged health without a support occurrence or unresolved payload
   **And** the support source begins without a reservation, link, relay, pulse schedule, or consumed cadence
   **And** health, transforms, velocity, grapple, targeting, action, trajectory, healing, damage, and evidence state contain no data from an earlier attempt.

10. **Begin support and bombardment through normal requests**

    **Given** the fresh baseline attempt is ready
    **When** the fixture invokes its synchronized-opening command
    **Then** one healing-support request for the artillery recipient and one bombardment request targeting the player are submitted during the same authoritative simulation step with distinct stable identities
    **And** each action owner independently validates and accepts or rejects its request
    **And** the fixture cannot force target acceptance, reserve the recipient, create the relay, lock the landing area, solve the trajectory, skip windup, or bypass cadence
    **And** partial acceptance remains observable and makes the combined attempt incomplete rather than manufacturing the missing behavior.

11. **Preserve independent support and artillery lifecycles**

    **Given** both opening requests are accepted
    **When** simulation time advances
    **Then** support windup, relay creation, link activation, healing pulses, interruption, completion, and cadence follow Story 5.4
    **And** artillery tracking, landing lock, launch, detached flight, final warning, impact, and cadence follow Story 5.1
    **And** neither lifecycle pauses, accelerates, restarts, or synchronizes itself to the other after request acceptance
    **And** rendering, AI evaluation, healing presentation, or trajectory presentation cannot control their relative timing.

12. **Keep the two information structures distinguishable**

    **Given** support and bombardment warnings overlap while the player and camera are moving
    **When** the tester observes them without diagnostics
    **Then** support presentation identifies the source, recipient, relay, two link segments, activation state, pulse timing, and interruption state
    **And** bombardment presentation identifies the tracking or locked landing cylinder, trajectory, payload, and remaining impact time
    **And** non-color-only geometry, motion, elevation, direction, and timing cues prevent the tether or pulse from being mistaken for the projectile arc or landing warning
    **And** neither presentation hides the other's relevant target, boundary, timing, or counter.

13. **Preserve the approved opening timing relationship**

    **Given** both baseline requests begin on the same simulation step
    **When** their approved lifecycles advance without interruption
    **Then** the bombardment locks its landing area after its 0.40-second tracking interval
    **And** the support link activates after its 0.75-second windup
    **And** the payload launches after its complete one-second windup and remains in flight for 1.50 seconds
    **And** support pulses follow their original active-time schedule without being moved earlier or later to coincide with launch or impact
    **And** the fixture records the actual relationship rather than owning either clock.

14. **Make impact evasion remain the immediate requirement**

    **Given** the artillery landing area has locked while support remains active or is becoming active
    **When** the player chooses a support target or approach route
    **Then** the frozen impact remains at its committed world position and lands at its original time
    **And** attacking the support source, relay, or artillery recipient does not remove or relocate the landing warning
    **And** the player must leave laterally, move above the three-metre impact height, use valid cover, grapple away, or accept the ordinary impact
    **And** no support interruption is incorrectly treated as an artillery counter after payload commitment.

15. **Allow support-source interruption during artillery pressure**

    **Given** the healing relationship is winding up or active and a bombardment is tracking, locked, or in flight
    **When** the player reaches the support source and deals accepted positive damage
    **Then** the support execution or active link interrupts through Story 5.4's source-damage policy
    **And** the artillery recipient remains alive, hostile, and able to finish its current bombardment according to its own lifecycle
    **And** any detached payload continues independently
    **And** the player still has at least one observable impact response from the support-source approach region.

16. **Allow relay destruction during artillery pressure**

    **Given** the live relay is active while a bombardment is pending
    **When** the player grapples toward it or attacks it until its existing 16 health reaches zero
    **Then** relay death terminates healing support exactly once
    **And** the artillery recipient's current or future valid bombardment behavior remains otherwise unchanged
    **And** if the player is attached when the relay dies, the grapple releases through its existing target-invalid path with resolved velocity preserved
    **And** relay access does not force the player to remain inside every possible locked impact area.

17. **Allow the player to fight through healing**

    **Given** the player chooses to pressure the artillery recipient directly while support remains active
    **When** player damage and scheduled healing affect the recipient
    **Then** both resolve through the same health owner using their committed occurrence identities and defined ordering
    **And** damaging the recipient does not itself interrupt the support link or reset the healing schedule
    **And** sufficiently effective ordinary combat can defeat the recipient despite healing
    **And** this remains one viable but potentially slower strategy rather than the only required solution.

18. **Do not invent a connection-breaking interaction**

    **Given** the baseline support source, relay, and artillery recipient remain at fixed authored positions
    **When** the player crosses a tether segment, stands between endpoints, moves behind unrelated cover, or changes camera visibility
    **Then** those player actions do not block, cut, absorb, or redirect the healing connection
    **And** only Story 5.4's actual segment line of sight, length, endpoint, damage, relay, death, and lifecycle conditions govern it
    **And** the fixture does not teleport or steer an endpoint merely to offer continuous line-breaking
    **And** Story 5.4 remains the focused evidence for that counter.

19. **Let cover retain its actual scoped effects**

    **Given** authored cover is available in the combination fixture
    **When** the player uses it against a locked artillery impact
    **Then** the impact's existing line-of-sight query determines whether the player is protected
    **And** the same cover affects a support segment only if it actually lies between that segment's authoritative endpoints
    **And** rendered overlap with the tether or projectile arc cannot create a gameplay block
    **And** cover does not become a universal cancellation surface for both mechanics.

20. **Preserve lateral, altitude, grapple, and wall responses**

    **Given** support and artillery pressure overlap
    **When** the player runs, jumps, falls, grapples, releases, wall-runs, wall-sticks, or wall-jumps
    **Then** movement and traversal remain controlled by their existing owners
    **And** at least one lateral route and one altitude, grapple, wall, or cover response can leave the current impact area
    **And** traversal approaches to the source, relay, and recipient remain available under their approved target rules
    **And** neither support nor bombardment suppresses input, assigns velocity, cancels grapple, invalidates walls, forces facing, or prescribes a target.

21. **Preserve target choice under pressure**

    **Given** the support source, relay, and artillery recipient are all valid under their existing target rules
    **When** the player aims, grapples, moves, or attacks
    **Then** ordinary production selection and combat rules determine the chosen target
    **And** the fixture does not force lock-on, camera direction, attack recipient, grapple candidate, movement route, or interruption strategy
    **And** the player can change targets after reading a locked impact or observing a healing pulse
    **And** target choice remains a tactical decision rather than a hidden prescribed order.

22. **Keep healing and damage attribution distinct**

    **Given** healing pulses, player attacks, and artillery impacts may commit on nearby simulation steps
    **When** health results are resolved
    **Then** every occurrence retains its stable source, execution, recipient, definition, and run attribution
    **And** support healing can affect only the artillery recipient
    **And** artillery damage can affect only eligible impact-cylinder candidates according to its approved delivery
    **And** no healing result reduces player damage, no damage occurrence becomes negative healing, and callback order cannot duplicate or exchange results.

23. **Preserve source-independent artillery after recipient defeat**

    **Given** the artillery recipient launches a detached payload and is then defeated before impact
    **When** recipient death and payload flight resolve
    **Then** the active support link ends through recipient death and no later healing can revive the combatant
    **And** the detached payload retains its frozen trajectory, landing area, damage snapshot, attribution, impact time, and cleanup
    **And** the combination attempt cannot declare all pressure resolved while that payload remains capable of impact
    **And** the payload never dereferences, reconstructs, or respawns its dead source.

24. **Apply support-source death independently**

    **Given** the support source dies during support windup or active healing
    **When** its approved source-death policy resolves
    **Then** its execution, link, relay, and future pulses terminate through Story 5.4
    **And** artillery targeting, launch, detached flight, impact, and cadence remain governed only by the artillery recipient
    **And** killing the support source does not cancel or weaken a pending payload
    **And** simultaneous support-source death and healing-pulse eligibility follow the existing support terminal precedence.

25. **Preserve recovery after an ordinary mistake**

    **Given** the player misses an interruption, allows one or more healing pulses, chooses an inefficient target, or receives one nonlethal artillery impact
    **When** the player survives
    **Then** they retain ordinary movement, grapple, wall, attack, camera, and target-selection control
    **And** they can leave the impact region, reach a recovery route, reassess the support relationship, and select another counter
    **And** support does not amplify artillery damage or add control, and artillery does not strengthen healing or protect the relay
    **And** the combination creates no stun, repeated impact, unavoidable follow-up, or unbroken control chain.

26. **Require a viable response from each target region**

    **Given** the player occupies the starting region, support-source approach, relay approach, or artillery-recipient approach
    **When** an impact area locks under baseline tuning
    **Then** at least one observable lateral, altitude, grapple, wall, timing, or cover response remains physically achievable
    **And** a single landing cylinder cannot cover all routes away from any expected target region
    **And** support geometry cannot block every impact escape
    **And** a profile that removes all responses fails validation or playtest evidence rather than being accepted as intended difficulty.

27. **Resolve combined completion only after remaining pressure ends**

    **Given** a combination attempt is active
    **When** both combatants are authoritatively defeated, support is terminal, no relay or reservation remains, and every launched payload has completed impact or cancellation
    **Then** the evaluator commits exactly one successful attempt result
    **And** destroying only the relay, interrupting one link, defeating only one combatant, or killing the artillery source while a payload remains active cannot satisfy completion
    **And** player death commits a failed result and prevents later callbacks from changing it
    **And** the evaluator observes committed facts without dealing damage, healing, interrupting, despawning, or changing action state.

28. **Retain comparable strategy evidence**

    **Given** repeated attempts use the same manifest and component definitions
    **When** the tester completes different target-priority approaches
    **Then** at least one successful attempt interrupts support by damaging its source
    **And** at least one successful attempt interrupts support by destroying the relay or defeats the artillery recipient through active healing
    **And** evidence records initial target, route, interruption method and time, healing pulses, player and enemy damage, payload launches and impacts, recovery, defeat order, completion time, and reset result
    **And** strategies are compared without changing tuning, disabling actions, invoking cheats, or editing the fixture between runs.

29. **Reset both combatants and all transient pressure**

    **Given** reset is requested during support windup, relay creation, healing, artillery tracking, lock, launch, detached flight, impact, interruption, grapple, damage, either death, cadence, completion, or evidence finalization
    **When** the old run is invalidated
    **Then** executions, reservations, links, relays, pulse schedules, target samples, trajectory and landing snapshots, payloads, damage and healing occurrences, health state, source state, grapple references, presentations, evaluator state, and late work are removed or rejected exactly once
    **And** player health, transform, velocity, traversal state, both combatants, and all action readiness return to their authored initial conditions
    **And** no source-independent payload, heal, target, cadence, or terminal result survives into the fresh attempt.

30. **Keep combination layout and scheduling configurable**

    **Given** an alternate valid profile changes participant positions, synchronized offset, relay arrangement, cover, target routes, recovery geometry, or starting recipient-health rule
    **When** the same fixture consumes it
    **Then** validation, activation, observation, evaluation, and evidence use those authored values without code changes
    **And** no profile mutates support, relay, healing, bombardment, trajectory, damage, health, grapple, or source-death definitions
    **And** at least one alternate-profile test proves the participant geometry and request relationship are not hard-coded
    **And** invalid profiles fail instead of receiving hidden trajectory correction, support range extension, heal reduction, or player protection.

31. **Provide replaceable combined feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** support and artillery states overlap
    **Then** primitive endpoint and relay shapes, tether segments, healing pulses, health indicators, trajectory lines, payload geometry, landing cylinders, impact countdowns, route markers, interruption cues, and typed result displays make the scenario testable
    **And** future presentation can consume committed support, trajectory, impact, health, and attempt facts without controlling them
    **And** diagnostics expose scenario and run identities, independent action phases, support endpoints and relay, segment validity, pulse results, recipient health, landing snapshot, trajectory and payload state, impact results, target selection, interruption attribution, deaths, evaluator state, and cleanup.

32. **Make the combination manually reproducible**

    **Given** the named support-and-artillery fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they first observe both warnings and at least one uninterrupted healing pulse while evading bombardment with diagnostics disabled
    **And** they evade locked impacts laterally, by altitude, through grapple or wall movement, and with valid cover while approaching each available support target
    **And** they interrupt the support source, destroy the relay, fight the artillery recipient through healing, test different defeat orders, and deliberately receive one impact before recovering
    **And** they kill the artillery recipient before launch and after detached launch, kill the support source during windup and active healing, reset during every combined phase, and repeat the scenario
    **And** every check has observable pass or fail conditions and retained evidence separates objective lifecycle, counterplay, damage, healing, source-independence, and cleanup results from subjective readability, target-priority, pressure, route, and difficulty observations.

33. **Verify deterministic combined behavior**

    **Given** the permanent support-and-artillery suite and focused rendered real-Jolt fixture run
    **When** they exercise synchronized requests, link and relay creation, artillery tracking and lock, healing pulses, player attacks, source interruption, relay destruction, recipient damage and death, launch before death, detached flight, impact and cover, both defeat orders, simultaneous health events, stale runs, randomized callback order, and repeated reset
    **Then** each support occurrence creates no more than one link and relay, each pulse heals no more than once, each payload impacts no more than once, and every damage occurrence affects an eligible target no more than once
    **And** source-independent payloads survive artillery-source death correctly, support ends under its approved conditions, and at least one viable response plus post-mistake recovery remains available
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time phase timing, healing schedule, trajectory, impact timing, health ordering, interruption precedence, terminal results, and cleanup within documented tolerances.

34. **Keep the story bounded to one approved pair**

    **Given** Story 6.4 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it contains only the existing healing-support tether, existing arcing bombardment, one support source, one artillery recipient, one relay, one bounded fixture, finite activation, observational evaluation, reset, and focused verification
    **And** it has not added artillery volleys, moving support endpoints, relay networks, multiple recipients, armor or resistance support, encounter waves, production group AI, rewards, objectives, difficulty scaling, final presentation, or Last Garden allocation
    **And** the remaining two combinations, full 17-mechanic gate, and production-subset decision remain assigned to later Epic 6 stories.
