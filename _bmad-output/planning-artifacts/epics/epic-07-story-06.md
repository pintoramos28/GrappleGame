---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 6
---

# Story 7.6: Complete Required Encounters with an Optional Challenge

As a player,
I want required encounters to guide level progression while an optional encounter remains my choice,
So that I can complete the main route or accept an additional combat challenge without confusing progression rules.

**Acceptance Criteria:**

1. **Declare the focused encounter-sequence outcome**

   **Given** the M3 level from Story 7.5 is ready for progression logic
   **When** its level-flow definition and procedure are inspected
   **Then** its outcome is a sequence containing a lower required encounter, a skippable optional side encounter, an upper required encounter, and a completion platform
   **And** encounter availability, activation, gating, required and optional classification, completion, failure, level-objective ownership, presentation, diagnostics, manual procedure, and evidence requirements are explicit
   **And** every encounter composes the Story 7.2 lifecycle and existing primitive enemy content
   **And** checkpoints, rewards, death restart, production HUD, production audio, and boss progression remain outside this story.

2. **Author one immutable level-flow definition**

   **Given** the M3 level-flow profile is inspected
   **When** its configured entries are resolved
   **Then** it declares stable level-flow and objective IDs, ordered encounter references, required or optional classification, prerequisites, activation-region references, associated progression gates, completion-fact mappings, final-arrival condition, failure policy, presentation labels, and diagnostic metadata
   **And** the lower and upper encounter entries are required while the side-arena entry is optional
   **And** encounter definitions, trigger geometry, gate identities, prerequisites, and objective rules remain authored data rather than literals in `LevelController`, encounters, gates, fixtures, or presentation
   **And** mutable availability, activation, completion, and objective state remains outside the definition.

3. **Keep progression authority in `LevelController`**

   **Given** the level session is active
   **When** encounter-entry, encounter-completion, arrival, failure, or reset facts occur
   **Then** `LevelController` validates and commits level-flow state
   **And** each `EncounterController` continues to own only its own activation, participants, run, completion, failure, and reset
   **And** activation regions and progression gates report or present facts but cannot decide prerequisites or level completion
   **And** enemies, UI, audio, rewards, fixtures, and completion-platform presentation cannot advance progression directly.

4. **Keep one level-session-scoped progression state**

   **Given** the M3 level becomes active
   **When** its runtime flow state is created
   **Then** it records the current level-session identity, flow-definition version, encounter-entry states, required-completion set, optional-completion state, gate states, arrival state, objective state, accepted fact identities, and terminal result
   **And** it begins from immutable authored defaults rather than retained state from a prior level session
   **And** it stores stable identities and scalar facts rather than owning encounter participant nodes
   **And** it cannot outlive the containing `LevelRoot`.

5. **Register all encounter controllers before play begins**

   **Given** the level is initializing through Story 7.3
   **When** its progression owners are configured
   **Then** the lower, optional, and upper `EncounterController` instances register through typed initialization with stable encounter-instance and level-session identities
   **And** each instance matches the encounter reference and authored bounds in the flow definition
   **And** duplicate IDs, missing controllers, wrong classifications, invalid prerequisites, overlapping activation ownership, or foreign-session controllers fail level readiness
   **And** registration does not create an encounter run or spawn a participant.

6. **Require resident encounter content**

   **Given** the level reports readiness through Story 7.4
   **When** flow dependencies are validated
   **Then** all three encounter definitions, existing participant scenes and definitions, attacks, projectiles where applicable, primitive telegraphs, audio fallbacks, query profiles, and runtime-root dependencies are resident
   **And** first-time synchronous loading cannot occur when an activation region is crossed
   **And** an invalid required encounter dependency blocks level readiness
   **And** an invalid optional encounter dependency is reported explicitly and may disable that optional branch only through a declared level-manifest fallback.

7. **Use non-authoritative activation regions**

   **Given** the active player enters or leaves an authored encounter activation region
   **When** the region reports its observation
   **Then** the fact includes stable region, encounter-instance, player, level-session, and physics-step identities
   **And** `LevelController` independently validates current player identity, current session, prerequisites, entry state, encounter availability, and active-flow restrictions
   **And** the region cannot spawn enemies, create a run ID, close or open a gate, complete an objective, or modify the player
   **And** duplicate shapes and repeated enter callbacks for the same crossing are normalized and deduplicated.

8. **Initialize the lower required encounter as available**

   **Given** a fresh M3 level session becomes active
   **When** its initial progression snapshot is published
   **Then** the lower encounter is `AVAILABLE`
   **And** the optional and upper encounters are `LOCKED` by the lower-completion prerequisite
   **And** the lower exit gate and upper completion-path gate begin visibly closed while the optional route remains unavailable before the branch junction
   **And** no encounter has an active run or spawned participant before its validated activation.

9. **Activate the lower encounter once**

   **Given** the lower encounter is available and the current player crosses its entry region
   **When** `LevelController` accepts the observation
   **Then** it issues one typed activation command to the lower `EncounterController`
   **And** the Story 7.2 transaction creates its fresh run and complete two-enemy participant set before reporting active
   **And** successful activation changes only that entry to `ACTIVE`
   **And** repeated crossing, duplicate callbacks, or a second request cannot create another lower run.

10. **Keep the lower progression gate authoritative and static-safe**

    **Given** the lower required encounter is available or active
    **When** the player approaches its onward route
    **Then** the existing lower exit gate remains visibly and physically closed
    **And** it was authored closed before the player could overlap its closing path, so runtime progression never closes collision onto the player
    **And** the entrance and arena recovery routes remain usable while the encounter is active
    **And** the gate does not damage, push, teleport, grapple, or independently inspect encounter participants.

11. **Advance only from the committed lower completion**

    **Given** the lower encounter is active
    **When** its `EncounterController` commits the valid completion fact for the current run
    **Then** `LevelController` accepts that fact exactly once and marks the lower entry `COMPLETED`
    **And** the lower exit gate opens through its typed level-owned state boundary
    **And** the optional and upper encounter entries become `AVAILABLE` according to their authored prerequisites
    **And** killing one participant, observing empty geometry, receiving a stale completion, or reaching the gate cannot advance the flow.

12. **Keep opened required gates open for the session**

    **Given** a required encounter has completed and its progression gate is open
    **When** the player backtracks, another encounter activates, presentation reloads, or duplicate facts arrive
    **Then** that gate remains open for the current level session
    **And** its collision and visual state continue to agree
    **And** it cannot close onto the player or re-lock because an old encounter callback arrives
    **And** a fresh level session recreates the gate from its authored initial state.

13. **Present the optional choice before commitment**

    **Given** the lower encounter is complete and the branch junction is reachable
    **When** the player views the side branch
    **Then** geometry and primitive presentation distinguish the optional route, one-way commitment threshold, bounded arena, rejoin gate, and main-route bypass
    **And** the player can choose the bypass without entering the optional activation region
    **And** optional status is conveyed through shape, icon, text, or route treatment in addition to color
    **And** presentation does not claim that a reward exists before the later reward story defines one.

14. **Allow the optional encounter to be skipped completely**

    **Given** the optional encounter is available and has never activated
    **When** the player remains on the main bypass and proceeds toward the upper arena
    **Then** the optional encounter creates no run, participants, abilities, audio, completion result, or hidden failure
    **And** the upper required encounter remains eligible under the lower-completion prerequisite
    **And** final level completion does not require the optional completion fact
    **And** the optional entry remains available if the player backtracks before level completion.

15. **Make optional entry a deliberate commitment**

    **Given** the optional encounter is available
    **When** the player crosses its clearly marked one-way entry threshold
    **Then** `LevelController` validates and requests one optional encounter activation before treating the branch as committed
    **And** successful Story 7.2 activation changes the optional entry to `ACTIVE`
    **And** authored geometry prevents accidental return across the one-way threshold while the closed rejoin gate prevents bypass through the arena
    **And** the arena retains low, high, lateral, and recovery options so commitment does not remove the player's movement vocabulary.

16. **Fail optional activation safely**

    **Given** the player crosses the optional commitment threshold but its encounter cannot activate
    **When** the activation transaction returns a failure
    **Then** `LevelController` records one typed level-flow failure rather than treating the optional encounter as completed or silently spawning a partial run
    **And** no partial participant, runtime root, gate change, objective result, or reward exists
    **And** the application can leave or reload the level through the existing Story 7.4 boundary
    **And** checkpoint-local recovery from this rare failure remains assigned to the later restart story.

17. **Open the optional rejoin only on optional completion**

    **Given** the optional encounter is active
    **When** its current run commits completion
    **Then** `LevelController` marks the optional entry `COMPLETED` exactly once and opens its rejoin gate
    **And** the player can return to the primary route ahead of the branch junction
    **And** optional completion is retained for the current level session but is not added to the required-completion set
    **And** the completed optional encounter cannot reactivate when its regions are crossed again.

18. **Prevent overlapping arena activation in the baseline sequence**

    **Given** one of the three baseline encounters is active
    **When** another activation-region observation is received
    **Then** the request is rejected unless the active encounter has already committed completion
    **And** authored gates and route order prevent ordinary play from requiring two encounter runs to remain active together
    **And** the rejected observation cannot spawn participants or consume the later encounter's future activation
    **And** overlapping encounter runs, cross-arena waves, and encounter-group orchestration remain outside this story.

19. **Require lower completion before upper activation**

    **Given** the upper encounter receives an entry observation
    **When** its prerequisites are evaluated
    **Then** a current accepted lower-completion fact is required
    **And** optional completion is not required
    **And** a stale lower result, diagnostic teleport, direct arrival at the upper region, or an open visual mesh without authoritative gate state cannot satisfy the prerequisite
    **And** rejection exposes a typed locked or unmet-prerequisite result.

20. **Activate and complete the upper required encounter once**

    **Given** the lower encounter is complete, no other baseline encounter is active, and the player crosses the upper activation region
    **When** the upper entry request is accepted
    **Then** one fresh Story 7.2 encounter run activates with its complete participant set
    **And** its onward completion-path gate remains closed while it is active
    **And** current-run completion marks the upper entry `COMPLETED` and opens that gate exactly once
    **And** duplicate triggers, participant facts, completion facts, or backtracking cannot reactivate the upper encounter.

21. **Build the level objective from committed facts**

    **Given** the level-flow definition declares two required encounters and one final arrival condition
    **When** its `LevelObjective` runtime is initialized
    **Then** it consumes only current-session committed lower-completion, upper-completion, and completion-platform-arrival facts
    **And** it tracks optional completion separately without including it in the required condition
    **And** it does not scan encounter nodes, count enemies, inspect gates, infer player location, or grant completion itself
    **And** its mutable accepted-fact set belongs to the current level session.

22. **Require arrival at the completion platform**

    **Given** both required encounters have completed
    **When** the current player enters the completion-platform region
    **Then** the region reports one typed arrival observation to the level boundary
    **And** `LevelController` validates player, level-session, region, prerequisite, and duplicate identities before accepting it
    **And** arriving before both required completions records an unmet-prerequisite result without completing the level
    **And** the arrival region cannot load another level, grant a reward, or commit completion directly.

23. **Commit level completion exactly once**

    **Given** valid lower and upper encounter completions plus final-platform arrival have all been accepted for the current level session
    **When** the objective becomes satisfied
    **Then** `LevelObjective` emits one immutable objective-satisfied fact
    **And** `LevelController` commits one level-completion result containing the level, session, objective, required encounter, optional disposition, arrival, and timing identities
    **And** duplicate facts, repeated region occupancy, late callbacks, or repeated evaluation return the committed result without another completion
    **And** level completion does not yet grant a reward, load an exit destination, destroy the level, or begin a boss encounter.

24. **Preserve the optional result in the completion summary**

    **Given** the level completes after the optional encounter was completed, skipped, or never entered
    **When** the immutable completion result is recorded
    **Then** it identifies the optional disposition without changing the required pass result
    **And** `COMPLETED_OPTIONAL` and `SKIPPED_OPTIONAL` remain distinguishable
    **And** optional failure or activation failure remains an explicit level-flow failure rather than being mislabeled as a normal skip
    **And** the summary creates no reward difference until a later reward definition consumes it.

25. **Reject stale and foreign progression facts**

    **Given** an encounter completion, entry observation, gate request, objective fact, or arrival observation carries an invalid encounter run, level session, player, region, or definition identity
    **When** it reaches `LevelController`
    **Then** it is rejected or ignored with a bounded reason-coded result
    **And** it cannot unlock an encounter, open a gate, satisfy an objective, complete the level, or alter current presentation
    **And** repeated stale facts do not produce unbounded logging
    **And** diagnostics retain stable source identities without retaining destroyed runtime nodes.

26. **Handle required encounter failure explicitly**

    **Given** a required encounter fails after level activation because a required participant disappears, initialization invariant breaks, or another Story 7.2 critical condition occurs
    **When** its failure fact reaches `LevelController`
    **Then** the affected entry and level flow become `FAILED`
    **And** required progression gates remain closed and level completion remains impossible
    **And** the application receives one typed failure request suitable for later restart or safe level reload
    **And** the failure cannot be converted into completion because the arena becomes empty.

27. **Reset progression only with the level session**

    **Given** the M3 level is replaced, deliberately reloaded, or its level session ends
    **When** Story 7.3 teardown invalidates the session
    **Then** encounter entries, accepted facts, gate state, activation observations, objective state, optional disposition, completion result, and presentation sources from that session are invalidated
    **And** every active encounter run is invalidated through its own controller before the level is freed
    **And** a fresh loaded session recreates both required gates closed, all encounters unstarted, and the objective incomplete
    **And** checkpoint-preserved partial progression remains assigned to a later story.

28. **Expose read-only flow and objective presentation**

    **Given** primitive presentation or the later gameplay HUD needs level state
    **When** it reads the current `GameplayHudContext` sources
    **Then** it can distinguish the current required objective, available or active encounter, optional opportunity, completed encounters, locked prerequisite, flow failure, and committed level completion
    **And** presentation-safe labels and progress are supplied by typed current state and committed signals
    **And** HUD or primitive presentation cannot activate encounters, open gates, satisfy the objective, or choose optional disposition
    **And** the mapping conforms to the approved Story 7.1 encounter and objective states.

29. **Keep gate collision and presentation synchronized**

    **Given** a lower, optional-rejoin, or upper progression gate is closed or open
    **When** its level-owned state commits
    **Then** authoritative collision and visible primitive presentation consume the same state
    **And** an open-looking gate cannot remain blocking and a closed-looking gate cannot silently permit traversal beyond documented tolerance
    **And** gate animation is cosmetic and cannot decide when collision or progression changes
    **And** level unload or fresh-session initialization restores the declared authored state exactly.

30. **Provide bounded progression diagnostics**

    **Given** development diagnostics are enabled
    **When** the M3 sequence is inspected
    **Then** the overlay reads the level-session identity, flow-definition version, encounter availability and run IDs, active-entry restriction, prerequisites, accepted completion facts, optional disposition, gate states, objective conditions, arrival state, failure, stale rejections, and final result
    **And** it does not scan enemies, recompute encounter completion, infer region occupancy, or issue progression commands
    **And** hidden diagnostics stop formatting and refreshing the data
    **And** histories and rejection counters remain bounded and unavailable or disabled in release behavior.

31. **Make both routes through the sequence manually reproducible**

    **Given** another developer loads a fresh M3 level session through the normal application path
    **When** they follow the documented procedure with diagnostics initially disabled
    **Then** in one attempt they complete the lower encounter, skip the optional branch, complete the upper encounter, reach the completion platform, and receive exactly one level-completion result
    **And** in another fresh attempt they complete the lower encounter, deliberately enter and complete the optional challenge, rejoin, complete the upper encounter, reach the platform, and receive the same required completion with a different optional disposition
    **And** they test arrival before prerequisites, duplicate region crossings, one required failure profile, optional activation failure, repeated completion facts, stale prior-session facts, and full level reload
    **And** gates, primitive labels, and route geometry make required, locked, active, completed, optional, skipped, and failed states understandable without diagnostics
    **And** retained evidence separates objective activation, sequencing, gating, optional choice, completion, failure, stale-rejection, teardown, and repeatability results from subjective route, commitment, encounter-flow, and cue observations.

32. **Verify progression automatically**

    **Given** the permanent level-flow suite and focused real-Jolt M3 scene run are available
    **When** they exercise definition validation, controller registration, initial states, activation deduplication, lower gating, lower completion, optional skip, optional commitment and completion, active-encounter restriction, upper prerequisites, upper completion, early and valid arrival, objective satisfaction, optional dispositions, gate collision alignment, encounter failure, stale facts, level replacement, randomized callback order, and repeated sessions
    **Then** each encounter activates and completes no more than once per session, each gate follows one valid state path, and level completion commits no more than once
    **And** optional skip never blocks required completion while optional participation cannot be mislabeled as a skip
    **And** no stale fact, partial encounter, duplicate participant, gate mismatch, escaped runtime root, or prior-session objective state survives
    **And** immutable flow, encounter, participant, gate, and objective definitions retain their original fingerprints.

33. **Preserve equivalent progression at both physics rates**

    **Given** equivalent skip-optional and complete-optional attempts run at shipping 60 Hz and diagnostic 120 Hz
    **When** region crossings, encounter activations, combat, completion facts, gates, and final arrival resolve
    **Then** authoritative encounter order, gate states, optional disposition, objective conditions, level-completion result, and teardown remain equivalent
    **And** participant combat and traversal retain their previously documented real-time behavior within tolerance
    **And** additional callbacks cannot duplicate entry, activation, gate changes, arrival, objective satisfaction, or completion
    **And** a rate-sensitive progression difference blocks the story.

34. **Keep the story bounded to encounter sequencing**

    **Given** Story 7.6 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it contains one level-flow definition and state, three existing encounter compositions, typed activation regions, three progression gates, two required encounters, one optional committed challenge, one final-arrival condition, one exactly-once level-completion result, primitive presentation, diagnostics, and focused verification
    **And** it has not implemented waves, simultaneous arenas, encounter rewards, checkpoints, death restart, level exit loading, production HUD, pause, settings, input remapping, production audio, production enemies, boss phases, or final level content
    **And** those concerns remain assigned to later stories.
