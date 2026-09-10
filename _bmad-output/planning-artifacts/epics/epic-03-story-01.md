---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 1
---

# Story 3.1: Establish the M2 Prototype Contract and Manual Pressure Lab

As a game developer and playtester,
I want every combat-pressure prototype to run through a consistent manual-test fixture and evidence contract,
So that I can experience, evaluate, reset, and reproduce each mechanic before it receives production investment.

**Acceptance Criteria:**

1. **Define one immutable validation-scenario contract**

   **Given** an M2 mechanic or combination is prepared for implementation
   **When** its typed `M2PrototypeScenarioDefinition` is authored
   **Then** it identifies the scenario, mechanic, applicable FRs, composed implementation families, player-facing question, participant and fixture references, primary counter, recovery option, grapple interaction, wall interaction, source-death behavior, reset behavior, overlap restrictions, tuning questions, manual procedure, and required evidence
   **And** it references authoritative ability, effect, movement, damage, and presentation definitions instead of copying their runtime values
   **And** all occurrence-specific state remains outside the shared Resource.

2. **Reject incomplete scenarios before activation**

   **Given** a prototype scenario is missing required metadata, dependencies, definitions, participants, or evidence declarations
   **When** the pressure lab validates it
   **Then** activation fails with a typed scenario-validation result identifying the missing or invalid requirement
   **And** no participant, ability, projectile, hazard, link, obstacle, surface mutation, telegraph, or effect is partially activated
   **And** absent design decisions are surfaced rather than filled with invented defaults.

3. **Provide one reusable manual pressure-lab foundation**

   **Given** a developer opens the M2 pressure-lab base fixture
   **When** the scene runs directly
   **Then** it supplies a production player, configurable source and target positions, low, high, lateral, wall, grapple, cover, hazard, and recovery spaces, plus bounded fixture controls
   **And** future mechanic fixtures may compose or inherit the foundation without editing its internal logic for each mechanic
   **And** the fixture does not depend on the disposable tutorial level or implement Epic 7's production encounter system.

4. **Launch each prototype through a named fixture**

   **Given** a mechanic story adds a playable prototype
   **When** its manual evidence is requested
   **Then** a clearly named fixture scene can be launched directly using the pinned Godot version
   **And** the fixture selects one immutable scenario definition and begins from a documented initial state
   **And** another developer does not need to edit scenes, change hidden Inspector values, or infer undocumented setup before performing the procedure.

5. **Activate scenarios through typed scope**

   **Given** a valid scenario begins
   **When** its fixture owner activates it
   **Then** all required scenes and definitions are already resident, participants are configured through typed initialization contexts, and a fresh fixture-run identity and runtime root are committed before gameplay starts
   **And** spawned objects receive stable source, execution, scope, and run attribution
   **And** activation does not use absolute node paths, group membership as gameplay meaning, a global event bus, or first-time synchronous combat loading.

6. **Contain transient objects under the fixture run**

   **Given** a scenario creates projectiles, hazards, obstacles, links, statuses, telegraphs, surface mutations, audio emitters, or presentation effects
   **When** those occurrences are spawned
   **Then** they are attached beneath the appropriate fixture-owned runtime container and carry the active run identity
   **And** scene-tree ownership determines cleanup lifetime while immutable identities determine gameplay attribution
   **And** the fixture remains compatible with Epic 7's future encounter-scope boundary without implementing `EncounterController`.

7. **Make the manual procedure explicit**

   **Given** a named scenario fixture is launched
   **When** its instructions are consulted
   **Then** they state the initial conditions, relevant controls, action sequence, expected successful response, expected failed or mistimed response, primary counter, recovery step, grapple and wall checks, source-death check, reset check, and observable pass criteria
   **And** the instructions identify any deliberately unsupported interaction
   **And** the procedure can be repeated without relying on the author's memory.

8. **Provide primitive but sufficient feedback**

   **Given** final animation, VFX, audio, and HUD assets are unavailable
   **When** the scenario communicates windup, affected space, active state, accepted outcome, rejection, interruption, expiry, or cleanup
   **Then** consistent primitive geometry, color, material, labels, or other documented fallbacks make the required state observable
   **And** the relevant cue and authoritative gameplay state consume the same committed lifecycle and spatial facts
   **And** missing optional presentation cannot prevent scenario activation or alter its outcome.

9. **Expose bounded observational diagnostics**

   **Given** development diagnostics are enabled for the pressure lab
   **When** a scenario runs
   **Then** they can expose the scenario and run identities, participants, selected definitions, ability phase, spatial snapshot, active spawned occurrences, applied motor influences, damage results, current health, cancellation reasons, and cleanup status where applicable
   **And** diagnostics reuse already-committed results instead of repeating physics queries or gameplay calculations
   **And** they remain bounded, perform no simulation mutation, upload nothing, and can be excluded or disabled outside development fixtures.

10. **Route finite fixture commands through normal owners**

    **Given** the developer invokes restart, source defeat, player invulnerability, AI pause, scenario activation, or evidence capture where supported
    **When** the fixture command is accepted
    **Then** it calls the responsible public gameplay or fixture owner through a typed request
    **And** it does not write private health, movement, ability, AI, target, or runtime-root state directly
    **And** unsupported or invalid commands return a typed result without leaving a partially changed scenario.

11. **Reset every manual attempt cleanly**

    **Given** a scenario has been completed, failed, interrupted, or left with active transient occurrences
    **When** manual restart is requested
    **Then** the current run is invalidated, its runtime root and transient contents are removed exactly once or idempotently, and a fresh run begins from the authored state
    **And** late hits, callbacks, effects, target references, or spawns from the previous run are rejected
    **And** the player can immediately repeat the documented procedure without reloading the editor.

12. **Record reproducible manual evidence**

    **Given** a manual scenario procedure has been performed
    **When** its result is recorded
    **Then** the record identifies the scenario and definition versions, fixture path, engine configuration, starting state, steps performed, observed success and failure, counter and recovery results, grapple and wall results, source-death and reset results, known limitations, and pass or fail conclusion
    **And** subjective readability or feel observations are distinguished from objective contract failures
    **And** evidence remains local and bounded unless the developer deliberately exports it.

13. **Self-test the pressure lab using existing gameplay**

    **Given** Story 3.1 does not yet implement an M2 pressure mechanic
    **When** the pressure-lab baseline scenario runs
    **Then** the player can move through its low, high, lateral, wall, grapple, cover, and recovery spaces and fight the existing Story 2.9 melee enemy
    **And** the developer can invoke source defeat and restart, observe the current run identity, and repeat the baseline procedure
    **And** this proves the fixture and evidence workflow without misrepresenting the baseline scenario as one of the 17 M2 mechanics.

14. **Verify fixture and scenario contracts automatically**

    **Given** the permanent M2 fixture-contract suite runs
    **When** it exercises valid and invalid scenario definitions, missing dependencies, repeated activation, repeated reset, source removal, stale-run requests, retained references, missing presentation, and randomized notification order
    **Then** validation, activation, attribution, termination, and cleanup follow the declared contracts
    **And** shared scenario and gameplay definitions remain immutable
    **And** equivalent baseline timing cases at shipping 60 Hz and diagnostic 120 Hz remain equivalent within documented tolerances.

15. **Enforce manual testability for later M2 stories**

    **Given** a later mechanic or combination story claims completion
    **When** its evidence is validated
    **Then** it has a named runnable fixture, complete scenario definition, documented manual procedure, observable success and failure, counter and recovery evidence, manual reset evidence, and the applicable focused automated results
    **And** missing final presentation assets do not exempt it from readability testing
    **And** a diagnostic-only demonstration without playable observation cannot satisfy the story.

16. **Keep the foundation story bounded**

    **Given** Story 3.1 is complete
    **When** its scope and working-tree changes are reviewed
    **Then** the pressure-lab baseline launches, resets, records evidence, and is ready to host later prototype fixtures while the project and earlier Epic routes remain runnable
    **And** the story has not implemented any of the 17 M2 mechanics, created production encounters or enemies, designed the production HUD, added final animation/VFX/audio, introduced broad telemetry, or selected the Last Garden production subset.
