---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 3
---

# Story 6.3: Read a Pursuing Enemy Through a Spore Veil

As a player,
I want a pursuing melee enemy's direction and committed attacks to remain readable through bounded visibility obstruction,
So that I can reposition, evade, fight, or recover without receiving an unseen close-range attack.

**Acceptance Criteria:**

1. **Declare the combined gameplay question**

   **Given** the visibility-obstruction-and-melee scenario is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player can track and counter a pursuing melee threat while distant visual detail is reduced
   **And** its placement, activation relationship, preserved information, viable responses, deliberate failures, recovery, source and enemy death behavior, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one veil and one melee combatant rather than a stealth system, perception debuff, enemy group, or production encounter.

2. **Compose the approved veil and melee combatant**

   **Given** Stories 2.9 and 5.2 established the production melee enemy and bounded spore veil
   **When** Story 6.3 is implemented
   **Then** it references their existing immutable definitions, combat scope, perception, AI intent, movement, attack lifecycle, melee space, damage, health, visibility resolution, grapple, wall, source-death, and cleanup behavior
   **And** the veil receives no melee-specific visibility rule and the enemy receives no veil-specific perception, pursuit, targeting, attack, or movement behavior
   **And** the fixture owns only authored setup, bounded activation, terminal observation, reset, and evidence.

3. **Author one immutable combination manifest**

   **Given** the baseline combination profile is inspected
   **When** its values and references are resolved
   **Then** it declares one production player, one production melee enemy, one primitive veil source, the approved component definitions, fixture geometry, starting transforms, synchronized activation, readability margins, occurrence limits, manual checks, and evidence requirements
   **And** it permits one unresolved veil and only the melee enemy's ordinary single-action lifecycle and cadence
   **And** veil dimensions and timing, enemy perception and locomotion, melee reach and timing, damage, health, and source-death policies remain referenced from their original definitions
   **And** combination-only positions and readability constraints remain immutable authored configuration.

4. **Provide one bounded pursuit-and-visibility layout**

   **Given** the baseline fixture is opened
   **When** its authored geometry is inspected
   **Then** the player begins at the center of the intended veil placement while the melee enemy begins 12 metres away on a clear approach axis within its approved perception range and field of view
   **And** the veil's five-metre radius and five-metre height fit completely inside the authored effect bounds
   **And** unobstructed pursuit space connects the enemy to the player without requiring navigation meshes or authored enemy routes
   **And** lateral exits, open space above the veil, grapple targets, wall surfaces, nearby combat space, and nonterminal recovery areas remain available.

5. **Validate the close-range readability margin**

   **Given** the active veil preserves full near clarity within four metres and the melee enemy attacks from a maximum range of 2.1 metres
   **When** the combination arrangement is validated
   **Then** the near-clarity boundary exceeds the enemy's maximum valid melee reach by at least the manifest's one-metre minimum margin after applicable body and presentation tolerances
   **And** an enemy capable of beginning or delivering an ordinary melee attack while still classified as distant obscured detail invalidates the combination profile
   **And** validation cannot compensate by shrinking melee reach, enlarging near clarity, slowing the enemy, suppressing attacks, or revealing it through an undocumented fixture override.

6. **Validate the initial pursuit conditions**

   **Given** a fresh paired attempt is requested
   **When** the pressure lab validates its participants and spatial arrangement
   **Then** it confirms stable identities, compatible definitions, current run, player and enemy health, veil placement support, effect bounds, enemy perception range, field of view, gameplay line of sight, movement clearance, attack space, and recovery routes
   **And** the player is initially visible to the enemy through ordinary gameplay queries
   **And** missing, blocked, stale, incompatible, or unsafe prerequisites return a typed failure without activating AI, an attack, a veil preview, presentation obstruction, or an evidence attempt.

7. **Start every attempt from fresh scoped state**

   **Given** all prerequisites are valid
   **When** a new attempt begins
   **Then** the player, melee enemy, and veil source receive typed initialization under one fresh fixture-run identity
   **And** the enemy begins alive, undamaged, outside attack range, without a retained target or unresolved action
   **And** the veil source begins ready with no existing occurrence
   **And** player health, transforms, velocity, traversal, perception, AI, attack, visibility, hysteresis, target, and evidence state contain no information from an earlier attempt.

8. **Begin pursuit and veil creation through normal boundaries**

   **Given** the fresh baseline attempt is ready
   **When** the fixture invokes its synchronized-opening command
   **Then** the melee enemy becomes eligible to acquire and pursue the player through its normal combat context while one veil request is submitted through the veil source's normal action boundary
   **And** each owner independently validates and advances its state
   **And** the fixture cannot assign the enemy's target, write movement, force an attack, place the veil directly, skip windup, or alter visibility strength
   **And** partial rejection remains observable and makes the combined attempt incomplete.

9. **Keep pursuit and veil lifecycles independent**

   **Given** the veil is previewing, ramping, active, expiring, cancelled, or source-independent
   **When** the melee enemy perceives, pursues, stops, attacks, reacts, or dies
   **Then** its behavior continues through the approved perception, AI, movement, attack, health, and death contracts
   **And** enemy behavior does not advance, pause, weaken, move, or terminate the veil
   **And** the veil does not advance, pause, accelerate, or cancel enemy behavior
   **And** render timing, veil opacity, or presentation-subject state cannot change either gameplay lifecycle.

10. **Keep the veil presentation-only during pursuit**

    **Given** the enemy-to-player perception segment or movement path intersects the active veil
    **When** gameplay perception, line of sight, movement, collision, attack validation, melee delivery, damage, or target retention resolves
    **Then** the veil contributes no blocker, target modifier, confidence modifier, range change, path change, collision, or damage rule
    **And** the enemy can perceive and pursue the player exactly as equivalent solid geometry and existing gameplay rules permit
    **And** the player's attacks, grapple queries, and damage-cover queries are likewise unchanged
    **And** visual opacity, silhouettes, particles, materials, and camera results never become gameplay facts.

11. **Show the threat before obstruction begins**

    **Given** pursuit and veil windup begin together
    **When** the veil remains in its 0.75-second non-obscuring preview
    **Then** the player can see the enemy's initial location, general approach direction, and pursuit movement
    **And** the complete future veil boundary and activation timing are also visible
    **And** the player may begin repositioning before obstruction ramps
    **And** the fixture does not hide the enemy before the approved veil lifecycle permits it.

12. **Reduce only distant enemy detail**

    **Given** the veil is active and the enemy is more than four metres from the camera reference with a qualifying view segment through the volume
    **When** visibility presentation resolves
    **Then** the enemy's fine model, material, color, and exact-form detail may be reduced up to the approved obstruction strength
    **And** the player retains enough veil boundary, geometry, movement context, and safe-direction information to navigate
    **And** the effect does not guarantee an exact persistent enemy outline or eliminate the intended uncertainty
    **And** it never produces complete opacity or a full-screen blind.

13. **Preserve bounded pursuit-direction information**

    **Given** the pursuing enemy is obscured beyond near clarity
    **When** it moves toward the player without a committed attack
    **Then** available primitive motion, silhouette, positional audio, or bounded directional presentation communicates its approximate approach region
    **And** this information is sufficient to distinguish a threat approaching from ahead, behind, left, right, above, or below where applicable
    **And** it does not provide a permanent exact position marker, continuous wallhack, target lock, or path prediction
    **And** missing final audio uses the documented primitive directional cue for manual testing.

14. **Restore full enemy clarity before melee reach**

    **Given** the enemy approaches through or around the veil
    **When** its current presentation reference enters the four-metre near-clarity region
    **Then** it returns to the ordinary near-field presentation state before satisfying its 2.1-metre melee attack range
    **And** the transition follows the approved segment and hysteresis rules without flickering between clear and obscured states
    **And** the player can read the enemy's body orientation, approach, and current combat state before a valid close-range attack begins
    **And** camera position inside the veil cannot remove this guarantee.

15. **Preserve the complete melee telegraph**

    **Given** the enemy commits its 0.22-second windup while the veil is active
    **When** the attack warning and later active melee space are presented
    **Then** the enemy's committed attack direction, phase, approximate reach, and timing remain readable through the approved threat-warning treatment
    **And** the warning and swept melee query continue to consume the same source-relative melee space
    **And** the veil cannot hide, delay, resize, redirect, recolor into ambiguity, or replace the committed warning
    **And** final attack delivery still locks its direction at active start and can be evaded through ordinary movement.

16. **Allow a lateral visibility response**

    **Given** the enemy is obscured by a qualifying view segment through the veil
    **When** the player moves laterally until the current camera-to-enemy segment no longer satisfies the veil's intersection rule
    **Then** ordinary enemy presentation returns according to the approved hysteresis behavior
    **And** enemy pursuit and attack timing remain unchanged
    **And** at least one authored lateral route clears the view without forcing the player into the enemy's attack space
    **And** the player can continue retreating, engage, or select another route.

17. **Allow an altitude-based visibility response**

    **Given** the enemy is obscured across the five-metre-high veil
    **When** the player jumps, grapples, wall-runs, wall-jumps, or otherwise gains sufficient altitude to clear the actual view segment
    **Then** ordinary visibility returns without changing enemy targetability or AI
    **And** the player may observe and respond to the pursuing enemy from the resulting position
    **And** the fixture preserves a valid elevated route and recovery path
    **And** the veil does not stretch vertically, follow the camera, or enlarge to defeat the response.

18. **Allow moving closer as an information choice**

    **Given** the enemy remains obscured beyond near clarity
    **When** the player deliberately approaches until the enemy is within four metres
    **Then** the enemy becomes clear under the existing near-field rule
    **And** the player accepts the corresponding proximity and melee risk rather than receiving a free information reveal
    **And** ordinary attack, evasion, grapple, and movement rules remain available
    **And** the fixture records this as a distinct information-for-risk response.

19. **Support readable close-range combat inside the veil**

    **Given** both player and melee enemy occupy the active veil
    **When** the enemy attacks and the player evades or retaliates
    **Then** nearby bodies, collision geometry, melee warnings, impacts, health changes, grapple feedback, and recovery routes remain readable
    **And** enemy and player hit queries, damage, reactions, health, death, and attack cadence follow their approved contracts
    **And** the veil applies no accuracy penalty, attack modifier, target invalidation, movement effect, or damage
    **And** the player can defeat the enemy through ordinary production combat without a fixture-only reveal or damage command.

20. **Preserve enemy grapple targeting and feedback**

    **Given** the living melee enemy is partly obscured, selected through the veil, or within near clarity
    **When** the player performs the ordinary crosshair-directed grapple query
    **Then** selection, eligibility, line of sight, range, attachment, moving-anchor behavior, and maximum-length constraints remain unchanged
    **And** the selected-target and active-grapple feedback remain readable
    **And** the veil itself remains non-grappleable and non-occluding
    **And** preserving selected-target feedback does not reveal every unselected target or remove uncertainty before selection.

21. **Allow recovery after an ordinary melee hit**

    **Given** the player misjudges the enemy's approach or attack and receives one nonlethal melee hit
    **When** damage and hit feedback commit
    **Then** the player retains ordinary movement, grapple, jump, wall, attack, and camera control
    **And** at least one lateral, elevated, nearer-clarity, or retreat route remains reachable
    **And** the veil does not add stun, repeated damage, movement suppression, target loss, delayed blindness, or an amplified reaction
    **And** the enemy's 1.25-second start cadence preserves its existing retaliation or recovery opportunity.

22. **Reject unreadable or unavoidable arrangements**

    **Given** fixture geometry, veil tuning, camera references, enemy tuning, or presentation changes
    **When** the combination profile is validated or manually evaluated
    **Then** it fails if a valid melee attack can begin while the enemy and attack warning remain unreadable
    **And** it fails if every lateral, altitude, proximity, grapple, wall, or timing response is unavailable
    **And** it fails if one ordinary melee hit creates an unavoidable follow-up or control chain
    **And** difficulty or intended uncertainty cannot be used to waive missing threat direction, attack warning, near clarity, or recovery.

23. **Apply source and enemy death policies independently**

    **Given** the veil source dies during windup
    **When** its approved source-death policy resolves
    **Then** only the preview and pending veil execution cancel.

    **Given** the veil source dies after active spawn
    **When** its detached occurrence observes source loss
    **Then** the veil persists to ordinary expiry while melee behavior continues.

    **Given** the melee enemy dies while the veil is previewing or active
    **When** death commits
    **Then** its AI, movement, attacks, collision, and grapple eligibility terminate through Story 2.9 while the veil continues according to its own lifecycle
    **And** neither death automatically completes, removes, or rewrites the other participant.

24. **Record one bounded attempt result**

    **Given** the coordinated attempt has begun
    **When** the melee enemy is defeated, the player survives until veil expiry, the player dies, the run resets, or the tester aborts
    **Then** the fixture records one terminal attempt result without changing combat or visibility state to manufacture it
    **And** it distinguishes enemy defeated, veil survived, clean evasion, recovered after melee damage, player defeated, partial activation, invalid setup, and abort
    **And** evidence records player and enemy routes, distance and visibility classifications, threat cues, melee executions, hit and damage results, grapple and wall responses, recovery, source state, terminal reasons, and elapsed time
    **And** the result grants no reward, objective progress, checkpoint, or production encounter state.

25. **Reset visibility and combat state completely**

    **Given** reset is requested during acquisition, pursuit, veil windup, ramp-up, obstruction, near-clarity transition, attack windup, delivery, damage, reaction, grapple, either death, veil expiry, or evidence finalization
    **When** the old run is invalidated
    **Then** enemy perception, AI, movement requests, actions, hit history, health, death, grapple references, veil executions, occurrences, subject results, hysteresis, presentation, source state, attempt result, and late work are removed or rejected exactly once
    **And** player health, transform, velocity, traversal state, camera presentation, enemy state, and veil source return to their authored starting conditions
    **And** a fresh attempt begins without stale visibility, target retention, cadence, damage, or combat state.

26. **Keep combination layout and readability tuning configurable**

    **Given** an alternate valid profile changes participant positions, veil placement, synchronized offset, recovery geometry, route markers, or minimum clarity margin
    **When** the same fixture consumes it
    **Then** validation, activation, visibility presentation, observation, evaluation, and evidence use those authored values without code changes
    **And** no profile mutates veil dimensions or opacity, enemy perception or movement, melee reach or cadence, damage, grapple behavior, or other component definitions
    **And** at least one alternate-profile test proves starting separation and activation relationship are not hard-coded
    **And** profiles that violate readability, response, or recovery requirements fail rather than receiving hidden assistance.

27. **Provide replaceable combined feedback and diagnostics**

    **Given** final fog, enemy animation, audio, and VFX are unavailable
    **When** veil and melee states overlap
    **Then** primitive veil geometry, silhouettes, directional cues, enemy phase shapes, melee spaces, impact markers, health feedback, route markers, grapple feedback, and typed result displays make the scenario testable
    **And** future fog, model, animation, attack, audio, camera, and VFX presentation can consume committed facts without controlling visibility classification, perception, movement, attacks, damage, or attempt results
    **And** diagnostics expose scenario and run identities, veil lifecycle and strength, view segments and classifications, preserved cue state, enemy perception and target state, movement and attack requests, melee phase and space, grapple state, damage and health results, terminal outcomes, and cleanup.

28. **Make the combination manually reproducible**

    **Given** the named veil-and-melee fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they first evaluate the pursuit, visibility loss, approximate direction cue, near-clarity transition, and complete melee telegraph with diagnostics disabled
    **And** they clear the view laterally, clear it by gaining altitude, approach to trade distance for information, evade and counterattack inside the veil, grapple the enemy, and defeat it through normal combat
    **And** they deliberately receive one melee hit and recover, survive until veil expiry, kill the veil source before and after spawn, kill the melee enemy while the veil remains active, reset during every combined phase, and repeat the scenario
    **And** every check has observable pass or fail conditions and retained evidence separates objective visibility, combat, recovery, and cleanup results from subjective fairness, uncertainty, comfort, cue quality, and pressure observations.

29. **Verify deterministic combined behavior**

    **Given** the permanent veil-and-melee suite and focused rendered real-Jolt fixture run
    **When** they exercise placement, synchronized activation, pursuit through the veil, near-clarity boundaries, segment hysteresis, preserved threat cues, melee warning and delivery, lateral and altitude responses, close combat, grapple selection, player and enemy damage, both death paths, source loss, expiry, stale runs, randomized callback order, and repeated reset
    **Then** gameplay perception and combat queries remain unchanged by the veil, each melee execution damages the player no more than once, and every subject receives one deterministic presentation classification
    **And** the enemy becomes clear before valid melee reach, at least one combined response remains viable, and one ordinary hit preserves a recovery opportunity
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve veil timing, visibility classification, enemy pursuit and cadence, attack outcomes, damage, source behavior, terminal counts, and cleanup within documented tolerances.

30. **Keep the story bounded to one approved pair**

    **Given** Story 6.3 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it contains only the existing spore veil, existing production melee combatant, one primitive veil source, one bounded fixture, finite activation, observational evaluation, reset, and focused verification
    **And** it has not added enemy vision impairment, stealth, detection meters, aim penalties, hallucinations, extra enemies, coordinated group AI, encounter orchestration, rewards, objectives, difficulty scaling, final presentation, or Last Garden allocation
    **And** the remaining three combinations, full 17-mechanic gate, and production-subset decision remain assigned to later Epic 6 stories.
