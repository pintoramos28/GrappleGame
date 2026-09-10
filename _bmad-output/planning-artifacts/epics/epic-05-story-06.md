---
artifact_schema: 1
artifact_id: 'grapplegame.story.5.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 5
story: 6
---

# Story 5.6: Pass the Aerial, Visibility, and Support-Pressure Gate

As a game developer and playtester,
I want a repeatable gate proving every Epic 5 threat and target-priority decision,
So that combined-pressure work builds on readable, counterable, deterministic, and reset-safe mechanics.

**Acceptance Criteria:**

1. **Define one immutable Epic 5 gate manifest**

   **Given** all five Epic 5 scenarios are ready for evaluation
   **When** the aerial-and-support gate manifest is inspected
   **Then** it declares a stable gate identity and version, required project revision, engine and physics configurations, prerequisites, scenario definitions, requirement mappings, manual checks, automated suites, evidence fields, pass rules, and explicit exclusions
   **And** it references approved scenario and gameplay definitions rather than duplicating their tuning
   **And** mutable execution, observation, and evidence state remains outside the shared manifest.

2. **Require the existing prototype foundations**

   **Given** Epic 5 builds on the established pressure architecture
   **When** gate prerequisites are resolved
   **Then** Stories 3.1, 3.10, and 4.8 must have compatible passing evidence for the evaluated project revision
   **And** their lifecycle, spatial-query, damage, health, motor, target, link, world-effect, presentation, reset, and evidence contracts must remain runnable
   **And** Epic 5 cannot pass by replacing those foundations with fixture-specific implementations.

3. **Map every Epic 5 requirement to an approved scenario**

   **Given** the gate coverage matrix is validated
   **When** its required entries are examined
   **Then** Story 5.1 represents FR28 source-independent arcing bombardment
   **And** Story 5.2 represents FR30 bounded visibility obstruction
   **And** Story 5.3 represents FR32 airburst and aerial-mine-lattice pressure
   **And** Story 5.4 represents FR35 interruptible healing support
   **And** Story 5.5 represents FR42 target-priority pressure with multiple viable disruption strategies
   **And** every entry also traces its applicable FR39 readability, counterplay, recovery, cleanup, and evidence obligations.

4. **Reject incomplete gate inputs before execution**

   **Given** a required fixture, definition, procedure, suite, evidence destination, prerequisite result, or requirement mapping is missing or invalid
   **When** the gate validates its manifest
   **Then** it identifies the exact missing or incompatible entry and remains incomplete
   **And** no scenario is partially activated to compensate for absent metadata
   **And** implementation presence, story identifiers, verbal approval, or evidence from another revision cannot substitute for a current result.

5. **Provide one direct ordered launcher**

   **Given** another developer opens the M2 pressure lab
   **When** they select the Epic 5 gate
   **Then** they can launch all five scenarios from a documented checklist without editing scenes or hidden Inspector values
   **And** the launcher displays the current scenario, required manual checks, run identity, attempt state, evidence status, and remaining entries
   **And** launcher commands use existing fixture and gameplay boundaries rather than directly modifying private gameplay state.

6. **Run each approved scenario from a fresh state**

   **Given** a gate entry is selected
   **When** its attempt begins
   **Then** only that scenario's intended participants, definitions, runtime objects, geometry, and primitive presentation are active
   **And** a fresh fixture-run identity and runtime root are created from its approved initial state
   **And** projectiles, veils, mines, links, relays, enemies, health changes, timers, targets, or presentation from another entry cannot influence the attempt
   **And** the gate introduces no additional combination beyond the coordinated pressure already approved in Story 5.5.

7. **Evaluate readability before enabling diagnostics**

   **Given** a player-facing manual attempt begins
   **When** the tester evaluates targeting, trajectory, affected space, visibility, persistent danger, support roles, interruption state, or melee pressure
   **Then** diagnostic overlays are initially disabled
   **And** primitive presentation alone communicates enough information to choose an intended lateral, altitude, cover, traversal, target, or interruption response
   **And** diagnostics may be enabled afterward to verify authoritative facts but cannot substitute for player-observable readability
   **And** unavailable final animation, audio, or VFX does not prevent testing when the approved primitive cues remain sufficient.

8. **Exercise the arcing bombardment manually**

   **Given** the Story 5.1 fixture begins from its approved state
   **When** its required manual checks are performed
   **Then** the tester observes tracking become a frozen landing area, verifies the visible arc and impact marker correspond to that committed area, and deliberately receives no more than one accepted impact
   **And** lateral movement, altitude change, and valid cover each remain demonstrable responses
   **And** killing the source before projectile creation cancels the delivery, while killing it after creation does not erase or redirect the projectile
   **And** impact, miss, cancellation, source death, and reset leave no stale projectile or damage occurrence.

9. **Exercise the bounded spore veil manually**

   **Given** the Story 5.2 fixture begins from its approved state
   **When** its required manual checks are performed
   **Then** the tester approaches, enters, crosses, exits, and re-enters the veil while observing its windup, visibility ramp, active boundary, and expiry
   **And** nearby geometry, silhouettes, threat telegraphs, grapple feedback, and enough view direction remain readable without full-screen blindness
   **And** player gameplay line-of-sight, targeting, grapple, collision, and damage queries remain unchanged by the presentation-only obstruction
   **And** expiry, source death, reset, and repeated runs restore the original view without stale obstruction.

10. **Exercise the aerial mine lattice manually**

    **Given** the Story 5.3 fixture begins from its approved state
    **When** its required manual checks are performed
    **Then** the tester traverses the central gap, passes around both horizontal sides, moves above and below the lattice, and uses grapple and wall routes through or around the threat
    **And** the tester deliberately triggers one mine and escapes, deliberately receives one accepted hit, uses cover, tests the lattice recovery interval, and observes harmless expiry
    **And** arming, triggering, warning, blast space, and expiry remain visually distinct
    **And** killing the source before creation cancels the lattice, while killing it afterward leaves independently valid mines that still terminate and clean up correctly.

11. **Exercise the healing-support tether manually**

    **Given** the Story 5.4 fixture begins with its passive damaged recipient
    **When** its required manual checks are performed
    **Then** the tester observes scheduled healing, interrupts the source during windup and active channeling, grapples to and destroys the relay, and breaks a connection through continuous obstruction
    **And** brief obstruction does not terminate the link, blocked pulses are skipped rather than deferred, and damaging the recipient does not itself interrupt support
    **And** source death, recipient death, full-health completion, ordinary expiry, relay-grapple invalidation, and reset follow their approved terminal behavior
    **And** the relationship and its available counters remain understandable without diagnostics.

12. **Exercise target priority under melee pressure**

    **Given** the Story 5.5 fixture begins from its approved coordinated state
    **When** its manual procedure is completed across fresh attempts
    **Then** the tester first observes uninterrupted healing while surviving normal melee pressure
    **And** at least one successful attempt interrupts support through accepted damage to the source
    **And** at least one other successful attempt interrupts support through relay destruction or a continuous connection break
    **And** both strategies use identical tuning and end with both enemies defeated without cheats, debug mutation, disabled AI, or fixture edits.

13. **Verify both defeat orders and support cadence**

    **Given** the coordinated fixture remains at its approved configuration
    **When** the tester completes source-first and recipient-first attempts
    **Then** source-first defeat ends current and future healing while leaving the recipient as an ordinary hostile combatant
    **And** recipient-first defeat ends the link without resurrection or unsupported retargeting while leaving the source independently defeatable
    **And** interruptions that leave both enemies alive permit another support request only according to the original start-to-next-start cadence
    **And** neither order silently despawns the survivor or creates rewards, reinforcements, or objective progression.

14. **Demonstrate failure and recovery for every scenario**

    **Given** each scenario's successful counter has been demonstrated
    **When** its remaining manual procedure is completed
    **Then** the tester deliberately performs at least one failed or mistimed response
    **And** where the result is nonterminal, the tester demonstrates a documented recovery using ordinary movement, grapple, wall traversal, cover, altitude change, route change, target change, or a mechanic's recovery interval
    **And** source-death behavior and manual reset are tested where applicable
    **And** a scenario that can only be passed through perfect avoidance does not satisfy the gate.

15. **Preserve informed lateral and altitude responses**

    **Given** the bombardment, veil, mine lattice, support tether, and coordinated fixture have been exercised
    **When** their route and counterplay evidence is reviewed
    **Then** aerial and obscured pressure preserves at least one informed lateral or altitude response wherever that response is applicable
    **And** grapple and wall options remain useful where the fixture declares them
    **And** no threat secretly removes the complete traversal vocabulary, forces a prescribed route, writes player velocity outside the motor, or converts ordinary contact into an unavoidable control chain
    **And** unavailable routes and blocked connections remain observable rather than hidden.

16. **Audit visibility-query isolation**

    **Given** the spore veil is inactive, ramping, active, and expiring
    **When** equivalent gameplay queries are captured from the same authoritative positions
    **Then** target eligibility, gameplay line of sight, grapple selection, grapple occlusion, projectile collision, movement collision, and damage obstruction produce the same results except for ordinary world changes unrelated to the veil
    **And** only presentation-owned visibility is altered
    **And** a material, shader, camera, or presentation callback cannot become gameplay authority.

17. **Audit source-independent deliveries**

    **Given** a bombardment projectile or aerial mine lattice has committed creation successfully
    **When** its original source dies, is removed, or becomes invalid
    **Then** the spawned delivery retains its frozen attribution, lifecycle, collision, damage, expiry, and terminal rules without dereferencing the source
    **And** source removal does not erase, retarget, accelerate, duplicate, or make the delivery permanent
    **And** equivalent source death before committed creation cancels without leaving a partial projectile, mine batch, timer, or presentation.

18. **Distinguish natural cleanup from fixture reset**

    **Given** an Epic 5 occurrence expires, impacts, completes, is interrupted, or otherwise terminates naturally
    **When** its owned transient state is removed
    **Then** projectiles, obstruction presentation, mines, links, relays, reservations, pulses, targets, and lifecycle state clean up according to their approved contracts
    **And** accepted damage is not healed, destroyed actors are not resurrected, and valid player movement is not reversed.

    **Given** the tester requests a complete fixture reset
    **When** a fresh run begins
    **Then** participant transforms, velocity, health, alive state, traversal state, AI, targets, action readiness, cadence, runtime objects, presentation, evaluator state, and scenario result return to their authored starting values.

19. **Verify cleanup between every gate entry**

    **Given** a scenario is active, complete, failed, interrupted, or waiting in cadence
    **When** the tester resets it or switches to another entry
    **Then** the current run is invalidated before its runtime root is removed and the next run begins
    **And** trajectories, impacts, veils, mines, trigger records, recovery records, links, relays, pulses, health results, AI intents, target references, timers, cues, and late callbacks from the old run are removed or rejected exactly once
    **And** the next scenario can start immediately without restarting the editor.

20. **Aggregate every permanent automated suite**

    **Given** all prerequisite story suites are available
    **When** the Epic 5 automated gate runs through the canonical headless test entry point
    **Then** it executes the current architecture, pressure-lab, prior-gate, bombardment, visibility-obstruction, aerial-lattice, healing-support, and target-priority suites
    **And** a missing, skipped, crashed, timed-out, quarantined, or failed required suite prevents a passing gate result
    **And** the aggregate retains individual suite names, test counts, durations, failures, engine configuration, and evidence references rather than reporting only one summary boolean.

21. **Retest every rate-sensitive contract**

    **Given** Epic 5 includes timed targeting, flight, obstruction, mine, support, healing, connection, and combat behavior
    **When** required scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **Then** bombardment tracking, lock and impact; veil ramp and duration; mine creation, arming, trigger, warning and expiry; support windup, pulses, connection break, duration and cadence; and coordinated terminal behavior remain equivalent in real time within documented tolerances
    **And** spatial boundaries, hit counts, healing totals, recovery intervals, source-death outcomes, interruption precedence, terminal counts, and cleanup remain equivalent
    **And** a rate-sensitive failure blocks its scenario and therefore the complete Epic 5 gate.

22. **Prove run-order independence**

    **Given** all required scenarios and suites pass once
    **When** the gate repeats them in forward order, reverse order, and one recorded deterministic shuffled order
    **Then** each scenario produces the same authoritative outcomes and cleanup result
    **And** shared immutable definitions retain their original values
    **And** no result depends on a previous scenario, old run identity, retained static data, scene-tree insertion, subscriber order, callback order, or an earlier strategy attempt.

23. **Audit reusable architecture boundaries**

    **Given** all five Epic 5 implementations are reviewed together
    **When** their ownership and dependencies are inspected
    **Then** they reuse the established simulation-owned lifecycle, immutable definitions, spatial snapshots, named query profiles, scoped runtime roots, stable attribution, damage and health contracts, target-owned links, AI request boundary, reset boundary, and observational presentation where applicable
    **And** no mechanic introduces a competing projectile framework, visibility authority, mine manager, health system, link system, targeting authority, AI executor, encounter orchestrator, mutable global gameplay store, or mechanic-specific reset framework
    **And** the implementations remain compositions of validated families rather than a new universal hierarchy.

24. **Record one traceable Epic 5 report**

    **Given** manual and automated evaluation is complete
    **When** the gate report is generated
    **Then** it records the project revision and working-tree state, Godot and physics configurations, manifest version, fixture and definition identities, tester, date, manual steps, successful counters, deliberate failures, recoveries, source-death checks, coordinated strategies, defeat orders, automated commands and results, 60/120 Hz comparison, cleanup results, known limitations, and retained evidence references
    **And** every scenario, requirement mapping, strategy requirement, and prerequisite has an explicit pass or fail with supporting evidence
    **And** the report remains local and bounded unless deliberately exported.

25. **Separate contract failures from tuning observations**

    **Given** a mechanic is functionally correct but its provisional dimensions, timing, density, damage, healing, obstruction strength, cadence, warning, route value, or pressure feels imperfect
    **When** the tester records the result
    **Then** that concern is retained as a subjective tuning observation rather than automatically failing the architecture contract
    **And** unreadable cues, unavailable counterplay, missing recovery, mismatched visible and affected space, gameplay-query contamination, incorrect health changes, nondeterminism, stale state, or ownership violations remain objective gate failures
    **And** tuning observations remain visible for later playtesting and cannot be silently discarded.

26. **Fail closed and identify remediation**

    **Given** any prerequisite, scenario entry, manual check, strategy demonstration, automated suite, rate comparison, source-independence check, cleanup check, or architecture audit fails
    **When** the gate result is committed
    **Then** the overall result is `FAILED` or `INCOMPLETE`, never a partial pass
    **And** it identifies the responsible story, scenario, criterion, evidence, and narrowly scoped remediation target
    **And** rerunning a corrected entry retains the earlier recorded result rather than concealing it
    **And** tuning cannot be changed during an evidence run merely to manufacture a passing result.

27. **Complete Epic 5 only on a full pass**

    **Given** all five scenarios and prerequisite gates have current passing evidence from the same project revision
    **When** the final gate result is evaluated
    **Then** it becomes `PASSED` exactly once with a complete evidence matrix
    **And** aerial and obscured threats are readable and preserve informed responses, spawned threats remain source-independent and reset-safe, and healing support is disruptable through multiple counters
    **And** the coordinated fixture has two qualifying successful strategies under unchanged tuning
    **And** the passing result permits Epic 6 implementation to begin.

28. **Keep the gate bounded**

    **Given** Story 5.6 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it has validated and aggregated the five approved Epic 5 scenarios without redesigning or productionizing them
    **And** it has not created Epic 6's six two-ability combinations, run the complete 17-mechanic vocabulary gate, selected the Last Garden production subset, created production encounters, designed the final HUD, authored final animation, audio, or VFX, or performed minimum-spec production profiling
    **And** those concerns remain assigned to Epics 6-8.
