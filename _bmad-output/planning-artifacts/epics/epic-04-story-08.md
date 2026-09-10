---
artifact_schema: 1
artifact_id: 'grapplegame.story.4.8'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 4
story: 8
---

# Story 4.8: Pass the Route-Pressure Prototype Gate

As a game developer and playtester,
I want a repeatable gate proving every Epic 4 pressure mechanic independently,
So that later threats and combinations build on readable, counterable, deterministic, and reset-safe behavior.

**Acceptance Criteria:**

1. **Define one immutable Epic 4 gate manifest**

   **Given** the seven Epic 4 mechanics are ready for evaluation
   **When** the route-pressure gate manifest is inspected
   **Then** it declares a stable gate identity and version, required project revision, engine and physics configurations, prerequisite stories, scenario definitions, applicable requirements, manual checks, automated suites, evidence fields, pass rules, and explicit exclusions
   **And** it references the approved scenario and gameplay definitions rather than duplicating their tuning values
   **And** mutable execution, observation, and evidence state remains outside the shared manifest.

2. **Require the existing M2 foundations**

   **Given** Epic 4 builds on the approved prototype architecture
   **When** gate prerequisites are resolved
   **Then** the Story 3.1 pressure-lab contract and Story 3.10 six-family gate must have current passing evidence compatible with the evaluated project revision
   **And** the shared lifecycle, spatial, damage, motor, target, world-effect, surface, presentation, reset, and evidence contracts must remain runnable
   **And** Epic 4 cannot pass by replacing those foundations with fixture-specific implementations.

3. **Map all seven required mechanics**

   **Given** the gate coverage matrix is validated
   **When** its required entries are examined
   **Then** Story 4.1 represents adhesive-surface pressure and restoration
   **And** Story 4.2 represents frozen predictive targeting
   **And** Story 4.3 represents a simulation-derived rotating sweep
   **And** Story 4.4 represents a drifting pulsed damage volume
   **And** Story 4.5 represents local target-owned grapple-response modification
   **And** Story 4.6 represents a sustained directional motor influence
   **And** Story 4.7 represents deterministic surface-owned state mutation
   **And** the matrix traces FR22, FR26, FR29, FR31, FR34, FR37, FR38, and the applicable FR39 contract.

4. **Reject incomplete gate inputs before execution**

   **Given** a required fixture, scenario definition, gameplay definition, manual procedure, automated suite, evidence destination, prerequisite result, or requirement mapping is missing or invalid
   **When** the gate validates its manifest
   **Then** it reports the exact missing or invalid entry and remains incomplete
   **And** no mechanic is partially activated to compensate for missing metadata
   **And** implementation presence, story identifiers, prior verbal approval, or an earlier project revision cannot substitute for current evidence.

5. **Provide one direct ordered launcher**

   **Given** another developer opens the M2 pressure lab
   **When** they select the Epic 4 route-pressure gate
   **Then** they can launch all seven mechanics from a documented ordered checklist without editing scenes or hidden Inspector values
   **And** the launcher displays the current mechanic, required manual checks, run identity, attempt state, evidence status, and remaining entries
   **And** launcher commands route through existing fixture and gameplay owners instead of changing private gameplay state.

6. **Run every mechanic independently**

   **Given** a mechanic entry is selected
   **When** its gate attempt begins
   **Then** only that scenario's intended participants, definitions, runtime objects, and primitive presentation are active
   **And** a fresh fixture-run identity and runtime root are created from its approved initial state
   **And** the previous scenario's patch, prediction, sweep, cloud, anchor modifier, wind field, surface modifier, damage delivery, timer, telegraph, presentation, or target reference cannot influence the attempt
   **And** the gate does not activate two Epic 4 pressure mechanics simultaneously.

7. **Evaluate player-facing readability before diagnostics**

   **Given** a mechanic's player-facing attempt begins
   **When** the tester evaluates its windup, affected space or target, active state, direction, movement response, pulse, or expiry
   **Then** diagnostic overlays are initially disabled
   **And** primitive presentation alone must communicate the information required to choose an intended counter
   **And** diagnostics may be enabled afterward to verify authoritative facts but cannot substitute for player-observable readability
   **And** a mechanic that can only be understood through development labels or numerical overlays fails its readability check.

8. **Exercise the adhesive surface manually**

   **Given** the adhesive-surface scenario begins from its approved state
   **When** its required manual checks are performed
   **Then** the tester avoids one patch during windup, deliberately enters another, observes its grounded movement response, and escapes by jumping, grappling, or reaching the alternate route
   **And** the tester verifies that airborne, wall, and grapple behavior remain under their existing owners
   **And** exit, expiry, source death, and reset leave no lingering movement modifier or altered geometry.

9. **Exercise the predictive mark manually**

   **Given** the predictive-mark scenario begins from its approved state
   **When** its required manual checks are performed
   **Then** the tester observes tracking change into a frozen lock, continues approximately predicted movement to receive one hit, and changes direction, speed, or altitude after lock to produce misses
   **And** the visible locked sphere remains aligned with the authoritative delivery space
   **And** grapple release, a new grapple direction, and wall jump remain demonstrable prediction-breaking responses
   **And** no delivery follows the player after lock or repeats after its single active step.

10. **Exercise the rotating sweep manually**

    **Given** the rotating-sweep scenario begins from its approved state
    **When** its required manual checks are performed
    **Then** the tester identifies the starting plane, direction, extent, and timing; enters cleared space; moves with and against the sweep; and uses an inner, outer, elevated, cover, grapple, or wall counter
    **And** the tester deliberately intersects the active sweep and receives no more than one hit from that execution
    **And** the visible plane and damaging volume remain aligned throughout the complete simulation-derived rotation.

11. **Exercise the drifting cloud manually**

    **Given** the drifting-cloud scenario begins from its approved state
    **When** its required manual checks are performed
    **Then** the tester routes around it, moves above it, uses cover, crosses between pulses, deliberately receives one pulse, and leaves before the next
    **And** the tester observes its ramp-up, drift, obstruction response, pulse warnings, expiry, and maximum pulse count
    **And** the cloud produces no entry damage, continuous damage, lingering status, movement penalty, or post-expiry pulse.

12. **Exercise the weakened anchor manually**

    **Given** the weakened-anchor scenario begins from its approved state
    **When** its required manual checks are performed
    **Then** the tester compares equivalent normal and modified anchors, observes the 0.40 pull response, attaches before and after activation, and remains attached through expiry
    **And** the tester redirects to the alternate anchor or wall route and verifies that the modifier remains local to its owning target
    **And** moving-anchor and maximum-grapple-length behavior remain governed by the existing grapple contract
    **And** activation and restoration neither reconnect the grapple nor create a velocity discontinuity.

13. **Exercise the directional wind manually**

    **Given** the directional-field scenario begins from its approved state
    **When** its required manual checks are performed
    **Then** the tester enters stationary, against the wind, and above the wind's target component; exits laterally; grapples upwind and crosswind; uses the elevated wall route; and deliberately uses the field as a boost
    **And** total downwind velocity may exceed 10.0 metres per second through existing momentum or other sustained influences while the field itself does not brake that movement
    **And** wind directed away from an active grapple anchor remains subordinate to the maximum-length constraint
    **And** leaving or expiry stops additional wind contribution without subtracting accumulated velocity.

14. **Exercise the infested wall manually**

    **Given** the infested-wall scenario begins from its approved state
    **When** its required manual checks are performed
    **Then** the tester compares normal and infested wall-running, observes wall-stick sliding, performs an ordinary wall jump, grapples without body contact, and deliberately contacts the wall to receive one attributed hit
    **And** leaving and re-entering the same occurrence cannot deliver contact damage again
    **And** the tester uses the unmodified wall or alternate grapple route and verifies exact surface-response restoration after expiry or source death
    **And** compatible state remains intact while conflicting reapplication is rejected atomically.

15. **Demonstrate one failure and recovery for every mechanic**

    **Given** a mechanic's successful counter has been demonstrated
    **When** its remaining manual procedure is completed
    **Then** the tester deliberately performs one failed or mistimed response
    **And** where the failure is nonterminal, the tester demonstrates the documented recovery using ordinary movement, jump, grapple, wall traversal, cover, route change, or the mechanic's recovery interval
    **And** the attempt verifies the applicable source-death behavior and manual reset
    **And** a mechanic that can only be passed through perfect avoidance does not satisfy the gate.

16. **Preserve useful traversal choices**

    **Given** all seven manual scenarios have been exercised
    **When** their counterplay evidence is reviewed
    **Then** every scenario preserves at least one useful immediate response and, after an ordinary mistake, one documented recovery route where the player remains alive
    **And** ground movement, air control, jumping, grappling, release, wall-running, wall-sticking, and wall-jumping remain governed by their approved owners
    **And** no mechanic disables the complete traversal vocabulary, creates an unavoidable control chain, silently cancels grapple, or directly writes player velocity outside the motor
    **And** altered routes remain readable rather than becoming hidden invalid surfaces or targets.

17. **Distinguish natural cleanup from complete fixture reset**

    **Given** a mechanic expires or terminates naturally
    **When** its owned temporary state is removed
    **Then** its world effect, reservation, target modifier, motor influence, surface response, delivery schedule, presentation, and other transient authority are removed according to its approved contract
    **And** accepted damage is not healed, valid player displacement is not reversed, and momentum already produced is not subtracted unless an existing gameplay rule independently causes that result.

    **Given** the tester requests a fixture reset
    **When** a fresh run begins
    **Then** player transform, velocity, health, alive state, grapple state, locomotion state, source state, target state, anchor response, surface response, fixture geometry, ability readiness, and presentation return to their authored initial values.

18. **Verify cleanup between every attempt**

    **Given** a scenario is active, completed, failed, interrupted, or waiting in cadence
    **When** the tester resets it or switches to another mechanic
    **Then** the current run is invalidated before its runtime root is removed and the next run begins
    **And** patches, predictions, snapshots, sweeps, clouds, pulses, anchor modifiers, wind submissions, surface modifiers, accepted-recipient records, damage deliveries, timers, cues, and late callbacks from the old run are removed or rejected exactly once
    **And** the next scenario runs immediately without restarting the editor.

19. **Aggregate every permanent automated suite**

    **Given** all prerequisite story suites are available
    **When** the Epic 4 automated gate runs through the canonical headless test entry point
    **Then** it executes the current architecture, pressure-lab, six-family, adhesive-surface, predictive-mark, rotating-sweep, drifting-cloud, weakened-anchor, directional-field, and surface-state suites
    **And** a missing, skipped, crashed, timed-out, quarantined, or failed required suite prevents a passing gate result
    **And** the aggregate retains individual suite names, test counts, duration, failures, engine configuration, and evidence references rather than reporting only one summary boolean.

20. **Retest every rate-sensitive contract**

    **Given** Epic 4 includes simulation-timed movement, spatial delivery, and state restoration
    **When** the required scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **Then** adhesive lifecycle and movement response, prediction tracking and lock, sweep angular progression, cloud drift and pulse cadence, anchor-response timing, wind integration, and surface movement and contact delivery remain equivalent in real time within documented tolerances
    **And** spatial boundaries, hit counts, damage totals, maximum-distance results, source-death outcomes, cadence, terminal counts, and cleanup remain equivalent
    **And** a rate-sensitive failure blocks its mechanic and therefore the complete Epic 4 gate.

21. **Prove run-order independence**

    **Given** all required scenarios and suites pass once
    **When** the gate repeats them in forward order, reverse order, and one recorded deterministic shuffled order
    **Then** each mechanic produces the same authoritative outcomes and cleanup result
    **And** shared immutable definitions retain their original values
    **And** no result depends on a previous mechanic, old run identity, retained static data, scene-tree insertion, subscriber order, physics callback order, or an earlier tuning profile.

22. **Audit exact target and surface restoration**

    **Given** the anchor and surface-state mechanics temporarily modify target-owned responses
    **When** their natural termination and reset evidence are inspected
    **Then** the weakened anchor returns to its immutable base response without retaining a cached multiplier
    **And** the infested wall recomputes its base response plus any surviving compatible modifier without restoring a stale snapshot
    **And** repeated apply, terminate, reset, and reapply cycles produce the same resolved responses
    **And** unrelated anchors, surfaces, geometry, and shared definitions never change.

23. **Audit reusable architecture boundaries**

    **Given** all seven implementations are reviewed together
    **When** their ownership and dependencies are inspected
    **Then** they reuse the simulation-owned ability lifecycle, immutable definitions, shared spatial snapshots, named query profiles, scoped runtime roots, stable attribution, semantic motor pipeline, typed grapple responses, typed surface responses, damage contracts, reset boundary, and observational presentation where applicable
    **And** no mechanic introduces a competing ability executor, movement controller, damage system, spatial-query authority, surface manager, grapple manager, mutable global store, universal event bus, or mechanic-specific reset framework
    **And** the implementations remain compositions of the previously validated families rather than new universal inheritance hierarchies.

24. **Record one traceable Epic 4 report**

    **Given** manual and automated evaluation is complete
    **When** the gate report is generated
    **Then** it records the project revision and working-tree state, Godot and physics configurations, manifest version, fixture and definition identities, tester, date, manual steps, successful counters, deliberate failures, recoveries, grapple and wall observations, source-death and reset results, automated commands and results, 60/120 Hz comparison, known limitations, and retained evidence references
    **And** every mechanic, requirement mapping, and prerequisite has an explicit pass or fail with supporting evidence
    **And** the report remains local and bounded unless deliberately exported.

25. **Separate contract failures from tuning observations**

    **Given** a mechanic is functionally correct but its provisional dimensions, timing, speed, acceleration, damage, cadence, warning, or route value feels imperfect
    **When** the tester records the result
    **Then** that concern is retained as a subjective tuning observation rather than automatically failing the architecture contract
    **And** unreadable telegraphing, unavailable counterplay, missing recovery, mismatched visible and affected space, incorrect movement or damage, nondeterminism, stale state, failed restoration, or ownership violation remains an objective gate failure
    **And** tuning observations remain visible for later playtesting and cannot be silently discarded.

26. **Fail closed and identify remediation**

    **Given** any prerequisite, mechanic entry, manual check, automated suite, rate comparison, restoration check, cleanup check, or architecture audit fails
    **When** the gate result is committed
    **Then** the overall result is `FAILED` or `INCOMPLETE`, never a partial pass
    **And** it identifies the responsible story, scenario, criterion, evidence, and narrowly scoped remediation target
    **And** rerunning a corrected entry retains the earlier result instead of overwriting or concealing it
    **And** tuning values cannot be changed during the evidence run merely to manufacture a passing result.

27. **Complete Epic 4 only on a full pass**

    **Given** all seven mechanics and prerequisites have current passing evidence from the same project revision
    **When** the final gate result is evaluated
    **Then** the overall result becomes `PASSED` exactly once with a complete evidence matrix
    **And** all seven fixtures, the Story 3.1 pressure lab, the Story 3.10 gate, and previous Epic routes remain runnable with valid references
    **And** every mechanic is independently readable, counterable, recoverable, reset-safe, and supported by automated evidence
    **And** the passing result permits Epic 5 implementation to begin.

28. **Keep the gate bounded**

    **Given** Story 4.8 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it has validated and aggregated the seven existing mechanics without redesigning or productionizing them
    **And** it has not activated simultaneous pressure combinations, implemented Epic 5's arcing attack, visibility obstruction, aerial mines, or support behavior, selected the Last Garden production subset, created production encounters, designed the final HUD, authored final animation/VFX/audio, or performed minimum-spec production profiling
    **And** those concerns remain assigned to Epics 5-8.
