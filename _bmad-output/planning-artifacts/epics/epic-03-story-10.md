---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.10'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 10
---

# Story 3.10: Pass the Six-Family Prototype Gate

As a game developer and playtester,
I want a repeatable gate proving vertical enemy tactics and one playable representative from each implementation family,
So that later pressure mechanics can build on validated contracts instead of unproven or duplicated systems.

**Acceptance Criteria:**

1. **Define one immutable gate manifest**

   **Given** Epic 3's representative prototypes are ready for evaluation
   **When** the six-family gate manifest is inspected
   **Then** it declares a stable gate identity and version, required engine and physics configurations, prerequisite stories, required scenario definitions, primary and secondary family mappings, manual checks, automated suites, evidence fields, pass rules, and explicit exclusions
   **And** it references the existing scenario and gameplay definitions rather than duplicating their values
   **And** mutable execution and evidence state remains outside the shared manifest.

2. **Map exactly one representative to each primary family**

   **Given** the manifest's coverage matrix is validated
   **When** its six required entries are examined
   **Then** Story 3.4's direct lane shot represents Spatial Threat Delivery
   **And** Story 3.5's one-shot knockback represents Motor Influence
   **And** Story 3.6's temporary obstacle represents Scoped World Effect
   **And** Story 3.7's harpoon link represents Target-Owned Status or Link
   **And** Story 3.8's decoy represents Targetability and Deception
   **And** Story 3.9's anti-wall selection represents Contextual AI Action
   **And** every representative declares any reused secondary families without allowing one scenario to conceal a missing primary-family entry.

3. **Require the climbing and flying foundations**

   **Given** geometry-discovered vertical tactics are part of the Epic 3 completion gate
   **When** gate prerequisites are resolved
   **Then** the current Story 3.2 climbing-and-pounce evidence and Story 3.3 flying-tactics evidence must also pass
   **And** both fixtures must still discover tactical candidates from runtime geometry, exercise their safe fallbacks, and expose their approved diagnostics
   **And** required climb routes, climb anchors, flight anchors, flight connections, or separate authored flight volumes remain absent.

4. **Reject incomplete gate inputs before execution**

   **Given** a required fixture, scenario definition, gameplay definition, family declaration, manual procedure, automated suite, or retained evidence location is missing or invalid
   **When** the gate is validated
   **Then** it reports the exact missing requirement and remains incomplete
   **And** no scenario is partially activated merely to compensate for absent metadata
   **And** the gate cannot infer a pass from a story identifier, implementation presence, or prior verbal approval alone.

5. **Provide one direct gate launcher**

   **Given** another developer opens the M2 pressure lab
   **When** they select the Epic 3 representative gate
   **Then** they can launch each climbing, flying, and six-family scenario from a documented ordered checklist without editing scenes or hidden Inspector values
   **And** the launcher displays the current scenario, required manual checks, current run identity, completion state, and evidence status
   **And** launcher commands route through the existing fixture and gameplay owners rather than changing private state.

6. **Run representatives independently**

   **Given** a family representative is selected
   **When** its gate attempt begins
   **Then** only that scenario's intended participants, definitions, runtime objects, and primitive presentation are active
   **And** a fresh fixture-run identity and runtime root are created from its approved initial state
   **And** the previous family's projectile, impulse, obstacle, link, decoy, AI intent, telegraph, timer, target candidate, or presentation cannot influence the attempt
   **And** this gate does not activate two pressure abilities simultaneously.

7. **Test readability without relying on diagnostics**

   **Given** a representative's player-facing manual attempt begins
   **When** its telegraph, target, connection, route change, or contextual response appears
   **Then** the tester first performs the readability and counterplay check with diagnostic overlays disabled
   **And** primitive gameplay presentation alone must communicate the relevant timing, space, direction, target, link, or contextual threat
   **And** diagnostics may be enabled afterward to verify authoritative facts but cannot substitute for player-observable readability.

8. **Exercise the direct lane representative manually**

   **Given** the direct-lane scenario starts from its approved state
   **When** its required manual checks are performed
   **Then** the tester deliberately remains exposed and observes one accepted hit, crosses the locked lane to avoid another shot, and uses cover to block another delivery
   **And** warning and damaging width remain visibly aligned
   **And** a deliberate failure retains its documented recovery opportunity.

9. **Exercise the knockback representative manually**

   **Given** the knockback scenario starts from its approved state
   **When** its required manual checks are performed
   **Then** the tester avoids one delivery, receives exactly one displacement from another, and recovers through the authored movement option
   **And** the tester repeats the displacement during a supported grapple or wall state
   **And** no continuing force, duplicate impulse, stun-lock, or hidden movement loss remains afterward.

10. **Exercise the temporary-obstacle representative manually**

    **Given** the temporary-obstacle scenario starts from its approved state
    **When** its required manual checks are performed
    **Then** the tester crosses or leaves the preview safely, observes the complete wall activate only after windup, takes the alternate route, and uses the active wall through grapple or normal traversal
    **And** warning and expiry remain readable
    **And** activation never displaces or traps an occupant and cleanup leaves no collision or target eligibility.

11. **Exercise the harpoon-link representative manually**

    **Given** the harpoon scenario starts from its approved state
    **When** its required manual checks are performed
    **Then** the tester avoids one harpoon, accepts another, observes its sustained pull, breaks the link with continuous cover, and recovers by movement or grapple
    **And** maximum-length, duration, source-death, and active-player-grapple behavior match the approved contract
    **And** no motor influence survives the terminal result.

12. **Exercise the decoy representative manually**

    **Given** the decoy scenario starts from its approved state
    **When** its required manual checks are performed
    **Then** the tester identifies the persistent double-ring tell, deliberately selects the real and false candidates, attacks and disperses the decoy, and grapples it during another attempt
    **And** candidate selection follows the declared deterministic ordering
    **And** decoy invalidation leaves no stale target, grapple attachment, reward, objective, or source mutation.

13. **Exercise the contextual anti-wall representative manually**

    **Given** the anti-wall scenario starts from its approved state
    **When** its required manual checks are performed
    **Then** grounded or brief wall use produces no contextual request, while continuous eligible wall use produces one normal anti-wall harpoon request
    **And** the tester counters one committed attack by leaving the wall, changing direction, grappling away, or using cover
    **And** wall movement remains useful and no AI task directly changes player state or executes gameplay.

14. **Demonstrate failure and recovery for every representative**

    **Given** each family's successful counter has been demonstrated
    **When** its remaining manual procedure is completed
    **Then** the tester also performs one deliberate failed or mistimed response and, where the failure is nonterminal, one documented recovery
    **And** the attempt verifies the applicable grapple interaction, wall interaction, source-death behavior, and manual reset behavior
    **And** a scenario that can only be demonstrated through perfect avoidance does not pass.

15. **Preserve the traversal vocabulary**

    **Given** all six pressure representatives have been exercised
    **When** their interaction evidence is reviewed
    **Then** ordinary ground and air control, jumping, grappling, wall-running, wall-sticking, and wall-jumping remain governed by their approved owners
    **And** no representative arbitrarily removes the entire movement vocabulary, directly writes player velocity outside the motor, silently cancels grapple, or permanently changes a surface or route
    **And** every ordinary failure leaves either an immediate response or a documented recovery opportunity.

16. **Verify cleanup and replay between every attempt**

    **Given** a representative is active, completed, failed, or interrupted
    **When** the tester resets it or switches to another scenario
    **Then** the current run is invalidated before its runtime root is removed and the next run begins
    **And** projectiles, damage occurrences, impulses, obstacles, links, decoys, tactical memory, target references, timers, telegraphs, presentation, and late callbacks from the previous run are removed or rejected exactly once
    **And** the next scenario starts from its authored initial state without requiring an editor restart.

17. **Aggregate the permanent automated suites**

    **Given** all prerequisite story suites are available
    **When** the six-family automated gate runs through the canonical headless test entry point
    **Then** it executes the current architecture, pressure-lab, climbing, flying, direct-lane, knockback, temporary-obstacle, harpoon-link, decoy, and contextual-action suites
    **And** a missing, skipped, crashed, timed-out, or failed required suite prevents a passing gate result
    **And** the aggregated result retains the individual suite names, counts, durations, failures, and relevant evidence references instead of reporting only one summary boolean.

18. **Retest rate-sensitive behavior**

    **Given** timing and motion contracts must remain independent of diagnostic physics rate
    **When** the required representative timing cases run at shipping 60 Hz and diagnostic 120 Hz
    **Then** windups, active windows, projectile travel, impulses, sustained pull, obstacle lifetime, decoy lifetime, wall-context dwell, cooldowns, terminal counts, and cleanup remain equivalent in real time within their documented tolerances
    **And** rate-sensitive failure blocks the corresponding representative and therefore the complete gate.

19. **Prove run-order independence**

    **Given** all required automated and smoke scenarios pass once
    **When** the gate repeats them in forward, reverse, and one recorded deterministic shuffled order
    **Then** each scenario produces the same authoritative outcomes and cleanup result
    **And** shared immutable Resources retain their original values
    **And** no result depends on prior scenario state, node insertion, subscriber order, retained static data, or an earlier run identity.

20. **Audit the reusable architecture boundaries**

    **Given** the representative implementations are reviewed together
    **When** their ownership and dependencies are inspected
    **Then** they reuse the simulation-owned ability lifecycle, immutable definitions, ability-space snapshots, named query profiles, scoped spawning, stable attribution, semantic motor pipeline, target/link contracts, AI request boundary, and observational presentation where applicable
    **And** no representative introduces a competing projectile framework, obstacle manager, status system, targeting authority, AI executor, universal event bus, mutable global gameplay store, or family-wide base class
    **And** each family remains a composable implementation recipe rather than a new universal hierarchy.

21. **Record one traceable gate report**

    **Given** manual and automated evaluation is complete
    **When** the gate report is generated
    **Then** it records the project revision and working-tree state, Godot and physics configuration, manifest version, fixture and definition identities, tester, date, manual steps and observations, automated command and results, 60/120 Hz comparison, cleanup results, known limitations, and evidence references
    **And** every prerequisite and family entry has an explicit pass or fail with its supporting evidence
    **And** the report remains local and bounded unless deliberately exported.

22. **Separate objective failures from tuning observations**

    **Given** a mechanic is functionally correct but its provisional dimensions, timing, intensity, cadence, or tell feels imperfect
    **When** the tester records the result
    **Then** the subjective concern is retained as a tuning observation without being misreported as an architecture failure
    **And** unreadable telegraphing, unavailable counterplay, missing recovery, incorrect collision, nondeterminism, stale state, or contract violation remains an objective gate failure
    **And** unresolved tuning observations are visible for later playtesting and cannot be silently discarded.

23. **Fail closed and identify remediation**

    **Given** any required prerequisite, manual check, automated suite, rate comparison, cleanup check, or architecture boundary fails
    **When** the gate result is committed
    **Then** the overall result is `FAILED` or `INCOMPLETE`, never a partial pass
    **And** it identifies the responsible story, scenario, criterion, evidence, and narrowly scoped remediation target
    **And** rerunning a corrected entry cannot overwrite or conceal the earlier recorded result.

24. **Complete Epic 3 only on a full pass**

    **Given** all climbing, flying, and six-family entries have current passing evidence from the same project revision
    **When** the final gate result is evaluated
    **Then** the overall result becomes `PASSED` exactly once with a complete evidence matrix
    **And** all fixtures and previous Epic routes remain runnable with valid retained references
    **And** the passing result permits Epic 4 implementation to begin.

25. **Keep the gate bounded**

    **Given** Story 3.10 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it has validated existing representatives without redesigning or productionizing them
    **And** it has not implemented the remaining M2 mechanics, simultaneous two-ability scenarios, production enemy allocation, Last Garden subset selection, production encounters, final HUD, final animation/VFX/audio, or minimum-spec production profiling
    **And** those concerns remain assigned to Epics 4-8.
