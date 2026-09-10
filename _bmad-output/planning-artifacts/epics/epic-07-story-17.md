---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.17'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 17
---

# Story 7.17: Complete and Replay the Integrated M3 Level Loop

As a player,
I want to enter, traverse, fight through, recover within, complete, and replay one coherent non-boss level,
So that the complete encounter-driven gameplay loop is proven understandable, stable, and worth carrying into the boss slice.

**Acceptance Criteria:**

1. **Declare the final M3 integration outcome**

    **Given** Stories 7.1 through 7.16 have produced their approved systems and evidence
    **When** the integrated M3 completion gate is inspected
    **Then** a player can begin from safe menu, load the authored level, traverse meaningful routes, complete required and optional encounter paths, collect rewards, use checkpoints, die, recover, read HUD and audio, use pause and settings, complete the objective, return, and replay
    **And** two named end-to-end journeys, player-facing comprehension, failure recovery, identity and cleanup audits, repeatability, performance prerequisite, automated smoke coverage, and retained evidence are explicit
    **And** the gate validates existing contracts rather than becoming a place to invent missing features
    **And** boss content, final art, final animation, final VFX, final audio, narrative implementation, persistent RPG progression, and production balance remain outside this story.

2. **Require every Epic 7 prerequisite to be complete**

    **Given** the final gate is about to run
    **When** prerequisite evidence is checked
    **Then** the approved HUD specification and implementation, encounter and level-session lifecycles, controlled loading, multi-route shell, required and optional progression, checkpoints and restart, health and coin rewards, semantic audio, pause, preferences, rebinding, safe menu flow, diagnostics, and M3 performance gate all have passing current-version results
    **And** their definition, scene, schema, and contract versions match the candidate build
    **And** a failed, stale, provisional where completion is required, or superseded prerequisite prevents final sign-off
    **And** material prerequisite repair is separately scoped and reverified rather than hidden inside the integration record.

3. **Freeze one versioned M3 candidate configuration**

    **Given** the integrated candidate is assembled
    **When** its handoff manifest is recorded
    **Then** it identifies application build, project and engine configuration, M3 level and flow definitions, layout, encounter definitions and selected primitive participants, route and checkpoint profiles, reward tables, HUD specification, cue matrix, settings schema, action catalog, diagnostic schema, benchmark definition, and dependency versions
    **And** every required resource is reachable through the validated level and application manifests
    **And** runtime state remains outside those immutable assets
    **And** changing a listed dependency after evidence collection invalidates or deliberately versions the affected result.

4. **Begin from a safe player-facing application state**

    **Given** the Windows application launches with no prior level current
    **When** the first journey begins
    **Then** resident main-menu UI is usable with current persisted preferences and bindings
    **And** selecting Play requests the stable M3 level through the catalog and threaded loading boundary
    **And** required dependencies become resident before one fresh level session and player activate
    **And** no editor action, diagnostic command, direct scene launch, or preserved tutorial scene is required for the qualifying player path.

5. **Traverse a meaningful authored level shell**

    **Given** the M3 level becomes active
    **When** the player travels from entry through lower arena, branch, rejoin, upper arena, and completion approach
    **Then** low, high, and lateral routes plus applicable local recovery paths remain usable through production movement, grapple, wall, contact, input, and camera contracts
    **And** route choice changes approach, exposure, target access, or recovery value under the selected encounter pressure
    **And** severe out-of-bounds failure reaches the approved recovery flow while ordinary mistakes use local geometry recovery
    **And** no route requires the disposable prototype tutorial or a diagnostic teleport.

6. **Use the approved combat-pressure subset coherently**

    **Given** the lower, optional, and upper M3 encounters activate
    **When** their authored participants and abilities apply pressure
    **Then** each composition uses existing M1 and M2 contracts plus the playtest-supported subset appropriate to the M3 validation level
    **And** telegraphs, route effects, target priorities, counters, and recovery remain distinguishable with primitive fallback assets
    **And** ordinary pressure preserves at least one viable response and cannot create an unavoidable control chain that removes the full movement vocabulary
    **And** this story does not promote or redesign additional mechanics merely to increase spectacle.

7. **Preserve required and optional progression choice**

    **Given** the player completes the lower required encounter
    **When** they reach the branch
    **Then** they can either bypass the optional encounter and proceed or deliberately cross its commitment threshold, complete it, and rejoin
    **And** both choices permit upper required encounter activation and final objective completion
    **And** the optional disposition is accurately retained in the completion summary
    **And** required, optional, locked, active, completed, skipped, and failed states remain understandable through level geometry, HUD, and applicable audio without diagnostics.

8. **Integrate current-session rewards into normal play**

    **Given** encounter progression authorizes the Story 7.8 opportunities
    **When** the player reaches their authored placements
    **Then** the lower health pickup restores up to 25 health, optional completion offers 5 coins, and upper completion offers 10 coins
    **And** the HUD and semantic audio distinguish availability, successful collection, full-health rejection, and current coin total
    **And** each logical grant commits no more than once within the level session across retries and checkpoint reloads
    **And** a fresh replay begins with zero current-session coins and all eligible opportunities fresh.

9. **Recover through both approved recovery choices**

    **Given** the player dies or crosses the severe traversal-failure boundary
    **When** recovery presentation appears
    **Then** Restart Encounter is offered only for an eligible current encounter while Reload Checkpoint is offered for the active in-memory checkpoint
    **And** encounter restart creates a fresh run while preserving the applicable level session, checkpoint, progression, and committed reward ledger
    **And** checkpoint reload restores the exact captured progression and authored player restore profile while applying the monotonic collected-reward policy
    **And** neither choice retains prior enemies, executions, projectiles, hazards, status, input, audio emitters, callbacks, or duplicate outcomes.

10. **Make the complete loop understandable through the HUD**

    **Given** the primary qualifying journeys run with development diagnostics hidden
    **When** health, grapple targeting, ability state, encounters, objectives, checkpoints, rewards, prompts, failure, recovery, pause, and completion change
    **Then** Story 7.9 presents each required state through the approved information hierarchy and current bindings
    **And** critical distinctions remain readable without color alone at the tested settings and aspect ratios
    **And** central traversal and combat space remains sufficiently clear
    **And** no player action requires interpreting raw stable IDs, internal enums, logs, or debug drawings.

11. **Make the complete loop understandable through semantic audio**

    **Given** the baseline audio mix is enabled
    **When** traversal, attacks, telegraphs, encounters, UI, ambience, music, checkpoints, rewards, death, restoration, and completion occur
    **Then** Story 7.10 requests the mapped scoped cues from committed facts
    **And** local-player and imminent-threat cues remain available under representative voice pressure
    **And** encounter restart, checkpoint reload, pause, level teardown, and replay do not leave stuck or duplicate playback
    **And** muting any supported category leaves the simulation valid and applicable visual feedback intact.

12. **Keep pause, settings, and rebinding safe during the journey**

    **Given** the player pauses at representative traversal and combat states
    **When** they resume, open settings, preview and cancel or apply a supported preference, or change a valid keyboard-and-mouse binding
    **Then** gameplay remains suspended until owner-controlled resume and continues without catch-up or stale input
    **And** committed settings and bindings affect their typed consumers and persist according to Stories 7.12 and 7.13
    **And** cancelled or invalid changes do not leak into gameplay
    **And** the player can still complete the level using one valid custom binding layout and after restoring factory bindings.

13. **Complete the level exactly once**

    **Given** both required encounters have committed completion and the player reaches the final platform
    **When** `LevelObjective` becomes satisfied
    **Then** `LevelController` commits one level-completion result with the correct optional disposition and current-session summary
    **And** HUD, audio, and completion presentation react once without granting another objective or reward outcome
    **And** duplicate arrivals, encounter facts, callbacks, or presentation events return the existing result
    **And** completion cannot occur early through enemy counts, open-looking gates, direct scene access, debug selection, or stale facts.

14. **Return or replay through controlled application flow**

    **Given** the level-completion presentation is current
    **When** the player chooses Return to Menu or Replay
    **Then** Story 7.14 invalidates and tears down the completed level before publishing the menu or requesting a fresh load
    **And** replay creates new level-session, player, encounter-run, checkpoint, reward, and presentation identities
    **And** application-owned settings, current bindings, `UIRoot`, and valid persistent audio ownership survive as intended
    **And** no old gameplay remains authoritative during menu or new-session state.

15. **Recover safely from representative integration failures**

    **Given** a controlled fixture injects an unknown level, missing required dependency, invalid level root, encounter activation failure, required participant failure, checkpoint restoration failure, reward application failure, audio presentation failure, settings persistence failure, or teardown failure
    **When** the responsible boundary handles it
    **Then** it produces one typed player-safe result and no partial success owned by another system
    **And** healthy current state is preserved where the approved transaction allows it, otherwise the application reaches recovery or safe UI
    **And** optional presentation failure uses only its declared fallback and never blocks valid simulation
    **And** retry begins through a new authorized request rather than continuing terminal work indefinitely.

16. **Preserve exactly-once outcomes across the integrated loop**

    **Given** duplicate, simultaneous, reordered, delayed, or stale facts occur at encounter, damage, ability, checkpoint, reward, objective, pause, settings, loading, and leave boundaries
    **When** owners resolve them
    **Then** each ability execution, encounter run, checkpoint transaction, reward grant, level objective, settings apply, load request, and application transition reaches no more than one terminal result
    **And** connection order, UI callback order, scene-tree order, render frequency, or asynchronous resource-completion order cannot create another authority
    **And** stable scope identities reject prior-session work
    **And** expected duplicate and stale handling remains bounded.

17. **Remove every old scoped object between runs**

    **Given** a journey includes encounter restart, checkpoint reload, return to menu, replay, and application shutdown of the active level
    **When** each lifetime boundary completes
    **Then** scoped participants, projectiles, telegraphs, hazards, obstacles, tethers, statuses, surface mutations, reward pickups, timers, audio emitters, presentation bindings, input latches, deferred work, and signal connections terminate exactly once or idempotently
    **And** active registries and runtime roots report the expected zero or current-session-only counts
    **And** old nodes can be released without a persistent reference retaining them
    **And** immutable definitions retain identical fingerprints across all runs.

18. **Complete the named required-route journey**

    **Given** the application begins from safe menu with factory bindings and baseline preferences
    **When** another developer follows Journey A with diagnostics hidden
    **Then** they load the M3 level, traverse and complete the lower encounter, demonstrate the health-reward full and damaged collection behavior as directed by the procedure, activate the branch checkpoint, skip the optional route, reach the upper checkpoint, die or fail during the upper encounter, restart that encounter, complete it, collect the 10-coin reward, reach the final platform, and return to menu
    **And** the completion result records `SKIPPED_OPTIONAL` and a current-session coin total of 10 when the upper reward is collected
    **And** every required state is understandable through player-facing geometry, HUD, and audio
    **And** objective logs and post-run scope assertions confirm one valid result and complete teardown.

19. **Complete the named optional-and-rollback journey**

    **Given** the application begins a fresh M3 session with one valid custom binding and visible preference change
    **When** another developer follows Journey B with diagnostics hidden for the player-facing path
    **Then** they complete the lower encounter, collect health when eligible, activate the branch checkpoint, commit to and complete the optional encounter, collect 5 coins, deliberately reload the branch checkpoint, verify the coins remain while the optional encounter becomes selectable and its pickup remains consumed, replay or skip it according to the recorded branch, activate and complete the upper encounter, collect 10 coins, and complete the level
    **And** replaying the optional encounter cannot raise the final current-session total above 15
    **And** the completion result reports the actual final optional disposition required by the chosen post-rollback path
    **And** pause, resume, settings, prompt updates, checkpoint reconciliation, and reward anti-farming remain correct throughout the journey.

20. **Repeat complete sessions without degradation**

    **Given** Journeys A and B have each completed once
    **When** the documented repeatability cycle performs the approved number of menu-to-level-to-menu and completion-to-replay transitions
    **Then** each fresh session begins with authored player, encounter, gate, checkpoint, objective, reward, coin, HUD, audio, and input state
    **And** active and peak scoped-object, signal, audio-voice, diagnostic-provider, and bounded-history counts do not show unexplained run-over-run growth
    **And** completion, reward, checkpoint, and encounter results never accumulate duplicates
    **And** performance remains within Story 7.16's approved variance policy.

21. **Run the player-facing gate before using diagnostics**

    **Given** each named journey has a primary comprehension pass
    **When** that pass begins
    **Then** development overlay, world drawing, invulnerability, AI pause, diagnostic reset or reload shortcuts, and automatic capture are disabled
    **And** the tester uses only normal menu, gameplay, pause, settings, recovery, completion, and replay interactions
    **And** failure to understand or complete the intended path cannot be excused by debug-only information
    **And** diagnostics may be enabled in a later audit pass to explain and capture already observed behavior.

22. **Audit the complete loop with bounded diagnostics**

    **Given** the player-facing passes are complete
    **When** the diagnostic audit repeats their critical lifecycle boundaries
    **Then** Story 7.15 confirms motor, contact, grapple, ability, encounter, selected-AI, audio, performance, session, checkpoint, reward, and objective identities and results agree with observed play
    **And** its finite commands are exercised only in the specifically documented command audit
    **And** one bounded local capture records the final candidate's representative state and cleanup evidence
    **And** diagnostic presence cannot change the pass outcome.

23. **Verify the integrated loop automatically**

    **Given** the permanent contract suites and an M3 end-to-end smoke harness run against the frozen candidate
    **When** they exercise startup, threaded loading, both route dispositions, encounter activation and completion, rewards, death and both recovery choices, checkpoints, HUD binding, audio scoping, pause, settings, bindings, objective completion, return, replay, injected failures, stale events, and repeated sessions
    **Then** all required contracts remain passing and the smoke path reaches exactly one completion per level session
    **And** no partial load, duplicate authority, stale mutation, escaped transient, retained source, mismatched presentation, or invalid definition fingerprint survives
    **And** tests use deterministic scenario boundaries and owner state rather than arbitrary sleeps, pixel-perfect gameplay screenshots, or private node paths
    **And** human play remains required for route value, comprehension, combat readability, control comfort, sound clarity, and overall feel.

24. **Preserve real-time behavior at both physics rates**

    **Given** equivalent deterministic Journey A and focused Journey B boundaries run at shipping 60 Hz and diagnostic 120 Hz
    **When** authoritative traces are compared
    **Then** movement and combat timing, input edges, encounter order, optional disposition, checkpoint snapshots, reward totals, objective completion, pause and resume, cleanup, and terminal results remain equivalent within documented physics tolerance
    **And** high-speed queries do not introduce rate-dependent tunnelling or route failure
    **And** presentation sample density may differ without changing the gameplay facts described
    **And** a rate-sensitive authoritative divergence blocks Epic 7 completion.

25. **Require the approved M3 performance result**

    **Given** Story 7.16 produced its decision-grade result for the frozen candidate
    **When** Epic 7 completion is evaluated
    **Then** the actual selected minimum-spec Windows PC has the required passing status for the approved 1920x1080 stable-60 criteria
    **And** the content density and system configuration match the final integration candidate
    **And** release-like diagnostics remain disabled and no combat-critical synchronous loading occurs
    **And** provisional proxy evidence or a benchmark from superseded content cannot satisfy this gate.

26. **Confirm the Windows release-like build remains complete**

    **Given** the frozen candidate is exported for Windows
    **When** Journeys A and B receive their required export smoke coverage
    **Then** application bootstrap, dependencies, native extensions, Forward+ rendering, Jolt physics, fonts, fallback visuals, audio, local settings, input overrides, level loading, gameplay, teardown, and replay function without editor-only assets or tools
    **And** development commands and verbose diagnostics are absent or disabled
    **And** the old disposable tutorial is not required by startup or gameplay references
    **And** export-only failure blocks final sign-off.

27. **Retain a complete M3 evidence package**

    **Given** all objective and human-review checks finish
    **When** the Epic 7 evidence package is assembled
    **Then** it records candidate versions, prerequisite results, Journey A and B procedures and outcomes, comprehension checklist, failure matrix, exactly-once assertions, cleanup and repeatability counts, 60/120 comparison, Windows export smoke, minimum-spec result, diagnostic capture reference, and unresolved risks
    **And** objective results are separated from subjective route, readability, audio, control, pacing, and feel observations
    **And** failures and accepted limitations remain visible rather than being rewritten as passes
    **And** another developer can reproduce the result without the excluded research report or undocumented project knowledge.

28. **Trace every Epic 7 requirement to passing evidence**

    **Given** the final traceability matrix is reviewed
    **When** FR46 through FR53 and FR57 through FR58 plus applicable NFRs and architecture requirements are mapped
    **Then** each requirement identifies its primary story, integrated scenario step, objective evidence, and current pass status
    **And** encounter authority, run scope, recovery, reward commitment, routes, HUD, settings and menu flow, loading, audio, diagnostics, timing, cleanup, residency, definition immutability, accessibility, release exclusion, and risk-appropriate verification have no unexplained gap
    **And** a missing or failed mapping blocks Epic 7 completion
    **And** traceability does not claim FR54 through FR56 boss outcomes delivered by this epic.

29. **Keep the final story bounded to integration and sign-off**

    **Given** Story 7.17 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the frozen M3 candidate, two named player-facing journeys, repeat-run and failure audits, diagnostic audit, automated smoke, physics-rate comparison, performance and export prerequisites, traceability, and final evidence package
    **And** it does not create a boss, new enemy mechanic, new progression system, persistent inventory or save framework, final art or presentation, narrative content, or an unapproved optimization system
    **And** passing it completes the non-boss M3 encounter-and-level shell and permits Epic 8 integration work to begin from proven contracts.
