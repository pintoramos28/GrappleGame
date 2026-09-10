---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.7'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 7
---

# Story 6.7: Pass the Complete M2 Mechanic Vocabulary Gate

As a game developer and playtester,
I want one current gate proving the complete 17-mechanic M2 vocabulary and its representative combinations,
So that production-subset selection compares mechanics that are readable, counterable, deterministic, reset-safe, and technically complete.

**Acceptance Criteria:**

1. **Define one immutable M2 vocabulary gate manifest**

   **Given** all required standalone mechanics and combined-pressure scenarios are ready for evaluation
   **When** the M2 vocabulary gate manifest is inspected
   **Then** it declares a stable gate identity and version, evaluated project revision and working-tree state, Godot and physics configurations, prerequisites, standalone scenarios, combination scenarios, requirement mappings, manual checks, automated suites, evidence fields, pass rules, and explicit exclusions
   **And** it references approved scenario and gameplay definitions rather than copying or modifying their tuning
   **And** mutable run, observation, result, and evidence state remains outside the shared manifest.

2. **Require all preceding prototype gates**

   **Given** the complete vocabulary depends on the established M2 architecture and mechanic families
   **When** gate prerequisites are resolved
   **Then** Stories 3.10, 4.8, and 5.6 must have compatible passing evidence for the evaluated build fingerprint
   **And** their lifecycle, spatial-query, motor, damage, health, target, link, world-effect, AI-request, presentation, reset, and evidence contracts must remain runnable
   **And** climbing and flying family validation from Stories 3.2 and 3.3 remains represented through the Story 3.10 prerequisite
   **And** Story 6.7 cannot pass by replacing those foundations with gate-specific implementations.

3. **Map all 17 vocabulary mechanics explicitly**

   **Given** the standalone coverage matrix is validated
   **When** its required entries are examined
   **Then** it maps FR22 adhesive surface to Story 4.1, FR23 temporary obstacle growth to Story 3.6, FR24 harpoon tether to Story 3.7, FR25 knockback to Story 3.5, FR26 predictive mark to Story 4.2, and FR27 direct lane shot to Story 3.4
   **And** it maps FR28 arcing bombardment to Story 5.1, FR29 rotating sweep to Story 4.3, FR30 visibility obstruction to Story 5.2, FR31 drifting damage cloud to Story 4.4, and FR32 aerial mine lattice to Story 5.3
   **And** it maps FR33 contextual anti-wall reach to Story 3.9, FR34 grapple-anchor modification to Story 4.5, FR35 healing support tether to Story 5.4, FR36 deterministic decoy to Story 3.8, FR37 directional wind to Story 4.6, and FR38 surface-state change to Story 4.7
   **And** every required entry appears exactly once as a standalone mechanic even when it also participates in a combination.

4. **Require the complete FR39 contract for every mechanic**

   **Given** one of the 17 standalone entries is inspected
   **When** its contract and retained evidence are evaluated
   **Then** it identifies the gameplay question, authoritative windup, authoritative affected space or target, player-facing cues, active duration and feedback, primary counter, and recovery option
   **And** it defines applicable grapple and wall interactions, cancellation and source-death behavior, reset and replay behavior, overlap restrictions, immutable tuning values, and required evidence
   **And** each field references an approved implementation and observable result rather than an intention, placeholder, or future production asset
   **And** a missing, ambiguous, untestable, or contradictory field makes that mechanic incomplete.

5. **Bind all evidence to one evaluated build**

   **Given** earlier stories and epic gates may already contain detailed evidence
   **When** Story 6.7 decides whether that evidence may be reused
   **Then** it accepts evidence only when the project revision, recorded working-tree state, relevant definitions, engine version, physics configuration, fixture version, and test configuration match the evaluated build fingerprint
   **And** every referenced fixture and evidence location must still exist and remain directly runnable
   **And** each standalone mechanic receives a fresh manual spot-check during this gate even when its exhaustive evidence is reusable
   **And** stale or incompatible evidence is rerun rather than relabeled as current.

6. **Reject incomplete gate inputs before execution**

   **Given** a required definition, fixture, procedure, requirement mapping, prerequisite, suite, evidence destination, or build identity is missing or incompatible
   **When** the manifest is validated
   **Then** the gate identifies the exact invalid entry and remains `INCOMPLETE`
   **And** no unrelated scenario is modified or partially activated to compensate
   **And** story approval, implementation presence, screenshots without run identity, or evidence from another build cannot substitute for a current result
   **And** validation failure creates no gameplay occurrence or partial evidence attempt.

7. **Provide one direct ordered launcher**

   **Given** another developer opens the M2 pressure lab
   **When** they select the complete vocabulary gate
   **Then** they can launch every standalone mechanic and all six representative combinations from one documented checklist without editing scenes, scripts, or hidden Inspector values
   **And** the launcher shows current entry, requirement mapping, run identity, definition identity, required manual actions, evidence status, result, and remaining entries
   **And** it supports forward, reverse, and one recorded deterministic shuffled order
   **And** launcher commands use existing fixture and gameplay boundaries rather than mutating private mechanic state.

8. **Run every standalone mechanic independently**

   **Given** a standalone entry is selected
   **When** its gate attempt begins
   **Then** only that mechanic's intended participants, definitions, geometry, runtime objects, and primitive presentation are active
   **And** a fresh fixture-run identity and scoped runtime root are created from its approved initial state
   **And** another vocabulary mechanic cannot influence its movement, targeting, damage, lifecycle, cues, counter, recovery, or result
   **And** the standalone pass does not run all 17 mechanics simultaneously or treat combination behavior as a substitute for isolated validation.

9. **Evaluate readability before enabling diagnostics**

   **Given** a player-facing manual spot-check begins
   **When** the tester first encounters the mechanic
   **Then** diagnostic overlays are disabled
   **And** primitive player-facing presentation communicates the windup, affected space or target, active state, outcome, and intended counter well enough for an informed response
   **And** diagnostics may be enabled afterward to verify authoritative facts but cannot supply information required for ordinary counterplay
   **And** unavailable final models, animation, audio, or VFX do not block testing while the approved fallback presentation remains sufficient.

10. **Spot-check movement and route-changing mechanics**

    **Given** the adhesive surface, temporary obstacle, harpoon tether, knockback, weakened anchor, directional wind, and infested-wall entries begin from their approved states
    **When** their manual checks are performed independently
    **Then** the tester escapes and recovers from adhesive movement, uses or routes around the grown obstacle, breaks or outlasts the harpoon, and regains useful movement after knockback
    **And** the tester compares normal and weakened anchors, crosses or exploits wind without treating 10 metres per second as a player velocity cap, and avoids, deliberately uses, or recovers from the infested wall
    **And** each mechanic changes only its declared movement, route, connection, or surface behavior
    **And** leaving, expiry, source death, destruction where applicable, and reset restore or terminate the mechanic exactly as approved.

11. **Spot-check spatial attack mechanics**

    **Given** the direct lane shot, predictive mark, arcing bombardment, rotating sweep, drifting damage cloud, and aerial mine lattice begin from their approved states
    **When** their manual checks are performed independently
    **Then** the tester crosses or uses cover against the lane, changes course after predictive lock, and escapes the bombardment's committed landing area
    **And** the tester crosses or avoids the rotating sweep, exits and recovers from the cloud, and navigates the mine lattice through lateral or altitude movement before deliberately triggering and escaping one mine
    **And** each telegraph and active delivery uses its approved authoritative affected-space snapshot or boundary
    **And** high-speed, boundary, source-death, natural-expiry, and reset behavior remains observable and consistent with the mechanic's contract.

12. **Spot-check information, context, and target-priority mechanics**

    **Given** the spore veil, contextual anti-wall harpoon, deterministic decoy, and healing support tether begin from their approved states
    **When** their manual checks are performed independently
    **Then** the tester navigates the veil using preserved nearby information without gameplay-query contamination
    **And** the tester provokes and avoids the anti-wall response by changing wall-use behavior, identifies and disperses the decoy through its consistent tell, and interrupts healing support through more than one approved counter
    **And** target, damage, grapple, line-of-sight, and contextual-selection rules remain explicit and deterministic
    **And** each mechanic cleans up completely on its applicable cancellation, terminal, source-death, target-loss, and reset paths.

13. **Demonstrate a primary counter for every mechanic**

    **Given** each of the 17 standalone mechanics is run from fresh state
    **When** the tester performs its declared primary counter
    **Then** the counter can be completed through ordinary player movement, grapple, wall traversal, cover, timing, attack, route choice, target choice, or another action explicitly approved by that mechanic
    **And** success produces the mechanic's observable avoided, escaped, interrupted, broken, destroyed, outlasted, or safely traversed result
    **And** the fixture does not provide invulnerability, forced movement, hidden aim correction, disabled AI, altered tuning, or direct state mutation
    **And** a theoretical counter that cannot be reproduced manually does not satisfy the gate.

14. **Demonstrate failure and recovery for every applicable mechanic**

    **Given** a mechanic's successful counter has been demonstrated
    **When** the tester deliberately performs a failed, late, or mistimed response
    **Then** the failure produces the approved damage, displacement, attachment, obstruction, route loss, support result, or other consequence
    **And** after an ordinary nonterminal failure the tester demonstrates the documented recovery using available movement, grapple, walls, cover, altitude, target change, route change, destruction, break conditions, or recovery timing
    **And** a mechanic designed to terminate the player under a specifically documented severe failure records that outcome separately from ordinary recovery
    **And** a mechanic that permits only perfect avoidance or creates an unbroken control chain fails the gate.

15. **Verify grapple and wall interactions explicitly**

    **Given** a mechanic declares grapple or wall behavior as applicable
    **When** the corresponding manual and automated checks run
    **Then** grapple acquisition, attachment, pull, maximum-distance constraint, release, target loss, wall running, wall sticking, wall jumping, and surface responses retain their established owners
    **And** the mechanic produces only its declared interaction, rejection, modification, obstruction, or unaffected result
    **And** no mechanic silently removes the complete traversal vocabulary or fabricates grapple, wall-contact, movement-combat, or impact context
    **And** entries for which an interaction is genuinely not applicable record that reason instead of silently omitting the field.

16. **Verify cancellation and source-death boundaries**

    **Given** a mechanic has a windup, committed delivery, persistent occurrence, or source-dependent active state
    **When** its source dies or becomes invalid before and after the declared commitment boundary
    **Then** pre-commit behavior cancels or terminates according to the approved policy without partial delivery
    **And** post-commit projectiles, mines, occurrences, links, fields, surfaces, or obstacles either persist or terminate according to their recorded policy without dereferencing a destroyed source
    **And** source loss cannot duplicate, redirect, accelerate, refresh, or make an occurrence permanent
    **And** mechanics without a post-commit object still produce one typed terminal result.

17. **Verify overlap and occurrence limits**

    **Given** each mechanic declares an overlap, stacking, cadence, recipient-recovery, or unresolved-occurrence policy
    **When** duplicate and boundary-condition requests are exercised
    **Then** accepted, rejected, refreshed, replaced, or composed behavior matches that immutable policy exactly
    **And** unsupported overlaps do not create partial occurrences, additive strength, duplicated damage, extra motor submissions, refreshed lifetimes, or hidden precedence
    **And** callback, registration, scene-tree, and candidate order cannot change the result
    **And** Story 6.7 does not broaden any mechanic's supported overlap policy.

18. **Restore exact standalone state between entries**

    **Given** a standalone attempt is previewing, active, recovering, terminal, failed, or waiting in cadence
    **When** the tester resets it or advances to another entry
    **Then** the current run is invalidated before its scoped runtime root is removed and the next run begins
    **And** player transform, velocity, health, alive state, traversal state, grapple, attacks, participants, AI, action readiness, targets, cadence, surfaces, and presentation return to the declared initial state
    **And** projectiles, hazards, obstacles, links, mines, damage occurrences, recovery records, motor influences, timers, diagnostics, and late callbacks from the old run are removed or rejected exactly once
    **And** the next entry can begin immediately without restarting the editor.

19. **Protect immutable definitions throughout the gate**

    **Given** all standalone and combination attempts have run
    **When** their referenced definitions are compared with their pre-gate fingerprints
    **Then** ability, movement, damage, surface, target, query, link, AI-policy, fixture, and presentation definitions retain their original authored values
    **And** runtime observations, tuning notes, accepted recipients, cooldowns, cadence, and lifecycle state have not been written into shared resources
    **And** alternate test profiles remain separate immutable definitions
    **And** any definition mutation or hidden between-attempt tuning change fails the complete gate.

20. **Require current evidence for all six combinations**

    **Given** all 17 standalone mechanics have current passing results
    **When** representative combination coverage is evaluated
    **Then** Story 6.1 provides lane shot plus obstacle growth, Story 6.2 provides predictive mark plus knockback, and Story 6.3 provides visibility obstruction plus melee pursuit
    **And** Story 6.4 provides support tether plus artillery, Story 6.5 provides surface-state change plus anti-wall pressure, and Story 6.6 provides aerial mines plus directional wind
    **And** all six combination results use the same evaluated build fingerprint and retain their approved definitions
    **And** a missing, stale, partial, or failed combination prevents the complete gate from passing.

21. **Preserve distinct behavior inside every combination**

    **Given** one of the six representative combinations is run
    **When** its component lifecycles and player-facing results are inspected
    **Then** both mechanics remain independently attributable and visually distinguishable
    **And** the pair preserves at least one viable pre-impact response, recovery after an ordinary mistake, and a meaningful tactical decision
    **And** the pair creates neither unavoidable damage nor an unbroken control chain
    **And** passing the combination cannot conceal a failed standalone mechanic or modify its approved contract.

22. **Aggregate every permanent automated suite**

    **Given** all prerequisite and mechanic suites are available
    **When** the complete M2 gate runs through the canonical headless test entry point
    **Then** it executes the current architecture, pressure-lab, prior-gate, all 17 standalone-mechanic, and all six combination suites
    **And** a missing, skipped, crashed, timed-out, quarantined, or failed required suite prevents a passing result
    **And** the aggregate retains suite names, test counts, durations, failures, configuration, and evidence references rather than reporting only one boolean
    **And** focused real-Jolt scene tests remain included wherever physics interaction cannot be established by isolated tests.

23. **Retest rate-sensitive and high-speed behavior**

    **Given** the vocabulary includes simulation timing, sustained forces, projectiles, sweeps, pulses, prediction, collision, triggers, links, and recovery intervals
    **When** required scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **Then** real-time phase boundaries, affected-space results, damage and healing counts, movement contributions, trigger outcomes, recovery windows, source-death precedence, and cleanup remain equivalent within documented tolerances
    **And** high-speed lane, projectile, mine, obstacle, tether, surface, and player-motion queries use their approved swept or velocity-aware behavior where applicable
    **And** total velocity above the wind's target component remains possible without wind adding or braking when its phase-entry component is already at least 10 metres per second
    **And** any rate-dependent gameplay divergence fails the responsible mechanic and therefore the complete gate.

24. **Prove run-order independence**

    **Given** all standalone and combination entries pass once
    **When** the gate repeats them in forward order, reverse order, and one recorded deterministic shuffled order
    **Then** each entry produces the same authoritative outcome and cleanup result
    **And** shared definitions retain their original values
    **And** no result depends on an earlier fixture, run identity, static value, subscriber order, candidate order, random-seed leak, or retained runtime object
    **And** a run-order failure identifies the first contaminated entry and relevant prior state.

25. **Audit reusable architecture boundaries**

    **Given** all 17 mechanics and six combinations are reviewed together
    **When** their ownership and dependencies are inspected
    **Then** they reuse the established immutable definitions, simulation-owned lifecycles, authoritative spatial snapshots, named queries, player-motor boundary, scoped runtime roots, stable attribution, health and damage contracts, target-owned links and responses, AI request boundary, reset boundary, and observational presentation
    **And** no mechanic introduces a competing ability executor, movement authority, damage system, projectile framework, surface manager, target authority, query authority, AI executor, global mutable gameplay store, or mechanic-specific reset framework
    **And** combination fixtures compose approved mechanics without becoming gameplay authorities
    **And** future animation, audio, and VFX adapters can consume committed facts without controlling gameplay outcomes.

26. **Record one traceable complete-vocabulary report**

    **Given** manual and automated evaluation is complete
    **When** the M2 gate report is generated
    **Then** it records the project revision and working-tree state, engine and physics configurations, manifest version, tester, date, fixture and definition identities, all 17 requirement mappings, manual spot-checks, primary counters, deliberate failures, recoveries, source-death checks, reset results, six combination results, automated commands, and 60/120 Hz comparisons
    **And** every required contract field, scenario, prerequisite, suite, and architecture audit has an explicit pass or fail with retained evidence
    **And** earlier reusable evidence is linked with its matching build fingerprint while newly rerun evidence remains distinguishable
    **And** the report remains local and bounded unless deliberately exported.

27. **Separate contract failures from tuning observations**

    **Given** a mechanic is functionally correct but a provisional distance, size, timing, force, damage, warning, density, route value, pressure level, or presentation treatment feels imperfect
    **When** the tester records the result
    **Then** the concern is retained as a subjective tuning observation rather than automatically failing the architecture contract
    **And** unreadable cues, unavailable counterplay, absent recovery, visible and authoritative space disagreement, incorrect damage or movement, nondeterminism, stale state, source-policy errors, or ownership violations remain objective failures
    **And** subjective observations retain their mechanic, profile, tester, evidence, and proposed follow-up context
    **And** tuning cannot be altered during an evidence attempt to manufacture a pass.

28. **Fail closed and identify remediation**

    **Given** any prerequisite, contract field, standalone entry, manual check, combination, automated suite, rate comparison, reset check, definition audit, or architecture audit fails
    **When** the complete result is committed
    **Then** the overall result is `FAILED` or `INCOMPLETE`, never a partial pass
    **And** it identifies the responsible story, mechanic or combination, criterion, evidence, and narrowly scoped remediation target
    **And** rerunning a corrected entry retains the earlier result and records the new build fingerprint
    **And** unrelated passing evidence remains available but cannot override the failure.

29. **Mark the vocabulary technically validated only on a full pass**

    **Given** all 17 standalone mechanics, all six combinations, and every prerequisite have current passing evidence for the same evaluated build
    **When** the final M2 vocabulary result is evaluated
    **Then** it becomes `PASSED` exactly once with a complete evidence matrix
    **And** every mechanic has a proven question, cue, affected space, counter, recovery, traversal interaction, lifecycle, overlap policy, immutable tuning source, and repeatable test path
    **And** all representative combinations remain distinguishable, survivable after an ordinary mistake, and tactically meaningful
    **And** this result permits comparative production-subset selection in Story 6.8 but does not itself authorize Epic 8 production allocation.

30. **Keep the gate bounded**

    **Given** Story 6.7 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it has validated and aggregated the approved 17-mechanic vocabulary and six representative combinations without redesigning or productionizing them
    **And** it has not selected Last Garden mechanics, assigned mechanics to production enemies or bosses, built production encounters, created objectives or rewards, designed the final HUD, authored final animation, audio, or VFX, or performed minimum-spec production profiling
    **And** comparative Last Garden subset selection remains assigned to Story 6.8, while production allocation and integration remain assigned to later epics.
