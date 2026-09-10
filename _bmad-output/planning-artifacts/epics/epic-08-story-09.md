---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.9'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 9
---

# Story 8.9: Activate, Defeat, and Restart the Garden Heart Encounter

As a player,
I want the Garden Heart encounter to activate, complete, and restart from the boss checkpoint reliably,
So that I can learn the fight through repeated attempts without replaying invalid state or encountering leftovers.

**Acceptance Criteria:**

1. **Declare the focused boss-encounter outcome**

    **Given** the Last Garden approach, arena, Garden Heart gameplay, and boss presentation are complete
    **When** the encounter-integration slice is inspected
    **Then** the player completes the approach prerequisite, activates the boss checkpoint, commits to the arena, begins one fresh Garden Heart run, fights through the approved phases, can die and retry, and can defeat the current boss to complete the boss objective
    **And** checkpoint, activation, gate, run, player-death, recovery, boss-death, encounter-completion, objective, cleanup, fallback presentation, diagnostics, manual procedure, and automated evidence are explicit
    **And** every attempt uses production traversal, combat, boss, encounter, level, application, HUD, and audio contracts
    **And** reward collection, final exit transition, final balance, and final media remain outside this story.

2. **Consume the approved boss-flow specification**

    **Given** Story 8.1 defines boss activation, recovery, checkpoint, gate, and objective behavior
    **When** integration is planned
    **Then** each prerequisite, trigger, restore state, eligible recovery command, gate transition, encounter rule, objective handoff, and failure behavior traces to that approved version
    **And** the Story 8.2 authored checkpoint, commitment threshold, arena bounds, gates, player start, recovery regions, and post-defeat space are used without scene-local substitutes
    **And** a material contradiction or unresolved recovery choice blocks implementation
    **And** the implementation does not silently choose whichever retry behavior is easiest.

3. **Require completion of the approach prerequisite**

    **Given** the Last Garden level session is active
    **When** the player reaches the boss-entry area
    **Then** the boss checkpoint and arena-commitment flow become available only after the current session has the valid Story 8.3 approach-completion fact required by the approved specification
    **And** bypassing geometry, teleporting through a diagnostic, removing participants, a stale completion, or visual gate state cannot satisfy the prerequisite
    **And** an already committed current-session prerequisite is idempotent
    **And** a full level-session replacement cannot inherit it unless the approved level-start profile explicitly restores that state.

4. **Activate the authored boss checkpoint once**

    **Given** the approach prerequisite is satisfied and the player enters the safe checkpoint region
    **When** LevelController validates the authored checkpoint request
    **Then** it activates the Story 8.2 boss-entry CheckpointDefinition exactly once for the current eligible state
    **And** CheckpointRuntimeState records the approved in-memory player restore transform and orientation, health policy, level and approach progression, gate baseline, boss inactive state, and other explicitly approved session facts
    **And** the region cannot create or mutate checkpoint state directly
    **And** duplicate, stale, invalid, airborne-only where prohibited, hazardous, or busy requests return bounded typed results without replacing a valid snapshot.

5. **Keep the checkpoint snapshot boss-safe**

    **Given** the boss checkpoint has activated
    **When** its captured state is inspected
    **Then** the player restore volume remains outside boss spawn, pressure origins, gate motion, activation overlap, and active hazards
    **And** the snapshot contains no boss health, phase, AI history, active action, weak-point window, projectile, hazard, presentation occurrence, or runtime node reference
    **And** the next boss attempt is recreated from immutable authored baseline rather than restored halfway through mutable combat
    **And** shared definitions remain referenced but never mutated by the snapshot.

6. **Observe arena commitment through a non-authoritative region**

    **Given** the boss checkpoint is active and no boss run is active
    **When** the player crosses the Story 8.2 commitment threshold in the permitted direction and state
    **Then** the region reports one typed observation carrying level-session, arena, player, checkpoint, and physics-step identity
    **And** LevelController validates the prerequisite, checkpoint, arena state, player state, current encounter state, and duplicate identity before requesting activation
    **And** the region itself cannot spawn the boss, close a gate, change the objective, or invent an encounter run
    **And** ordinary recovery movement outside the threshold does not activate the fight.

7. **Require all combat-critical dependencies before activation**

    **Given** a valid commitment request is being evaluated
    **When** Last Garden and Garden Heart readiness is checked
    **Then** the boss scene and definition, approved phase and action definitions, selected mechanic content, weak points, projectiles and effects, query profiles, checkpoint and gate definitions, objective adapter, HUD and presentation adapters, primitive cues, semantic audio fallbacks, and required arena content are resident and valid
    **And** no first-time synchronous combat load occurs
    **And** missing required content rejects activation before gate closure or boss publication
    **And** missing optional presentation uses its approved readable fallback.

8. **Begin one transactional boss run**

    **Given** commitment and dependency validation pass
    **When** LevelController requests Garden Heart encounter activation
    **Then** EncounterController creates one fresh unique encounter-run identity, deterministic seed, and replaceable boss runtime root
    **And** the Garden Heart and every boss-owned weak point, action runtime, selected pressure owner, presentation binding, and scoped service are configured and registered before active state is published
    **And** failure at any construction or readiness step rolls back the complete attempted run
    **And** no partial boss, closed gate, hidden active hazard, or unusable player state remains after rejection.

9. **Replace the inert arena stand-in with the runtime boss**

    **Given** Story 8.2 supplied a non-authoritative Garden Heart spatial stand-in
    **When** a boss run prepares
    **Then** the stand-in is hidden or replaced according to the authored environment profile before the authoritative boss becomes active
    **And** exactly one authoritative Garden Heart body and its approved weak points occupy the current run
    **And** the stand-in can never receive damage, emit boss state, or satisfy participant registration
    **And** reset and teardown restore the correct stand-in or inactive-arena presentation without duplicating either representation.

10. **Close the boss gate through level-owned state**

    **Given** the complete boss run and player placement are ready
    **When** activation commits
    **Then** LevelController requests the approved boss-entry gate state through its typed owner
    **And** gate collision and primitive presentation reach the same committed closed state without intersecting or trapping the player
    **And** the boss cannot select an action until gate, player, encounter, HUD, and presentation readiness are committed
    **And** gate animation completion cannot start the boss or become encounter authority.

11. **Publish one coherent active encounter state**

    **Given** the boss, gate, arena, player, and presentation are ready
    **When** the activation transaction completes
    **Then** EncounterController publishes one active current-run state and the Garden Heart enters its approved initial phase exactly once
    **And** LevelController, GameplayHudContext, boss presentation, audio, and diagnostics consume that committed state
    **And** all occurrence-scoped objects carry current level-session and encounter-run identity
    **And** duplicate commitment observations cannot create another boss or reseed the current fight.

12. **Keep the player inside the authored fight contract**

    **Given** the Garden Heart encounter is active
    **When** the player traverses, attacks, reaches arena edges, enters recovery space, or approaches the closed gate
    **Then** authored bounds, collision, recovery regions, route geometry, and failure rules behave as specified by Stories 8.1 and 8.2
    **And** low, high, lateral, and ordinary recovery options remain available where the current approved phase permits them
    **And** an out-of-bounds or severe-failure observation is resolved only by the approved level or recovery owner
    **And** no boss ability, gate script, trigger, or HUD component teleports the player or writes authoritative movement directly.

13. **Resolve player death once per attempt**

    **Given** the player is alive in the current boss run
    **When** the health owner commits lethal damage
    **Then** player death commits exactly once with current level-session and encounter-run identity
    **And** EncounterController enters the approved failed or recovery-pending state and prevents new boss action selection
    **And** active boss actions, pressures, weak-point windows, gates, HUD, audio, and presentation follow their declared death and recovery policies
    **And** duplicate, stale, post-death, animation, or out-of-scope damage cannot create another death or recovery request.

14. **Offer only the approved recovery commands**

    **Given** player death or another recoverable boss-run failure has committed
    **When** the recovery interface appears
    **Then** it exposes exactly the Restart Encounter, Reload Checkpoint, full level restart, or safe-menu choices approved by Story 8.1 and the established Story 7.7 contract
    **And** unavailable choices state or present their unavailability without issuing partial commands
    **And** UI output remains a narrow typed request to the owning application, level, or encounter controller
    **And** selecting, animating, or timing out a presentation cannot perform recovery without owner validation.

15. **Restart the encounter from a clean boss occurrence**

    **Given** the approved Restart Encounter command is accepted
    **When** recovery executes
    **Then** the old boss run is invalidated before its complete runtime root, boss, weak points, actions, projectiles, hazards, effects, arena mutations, presentation, audio, subscriptions, and delayed work are removed
    **And** the player is restored according to the approved boss-retry policy at the safe boss checkpoint state
    **And** the approach prerequisite and other current-level facts are preserved or restored exactly according to the approved recovery matrix
    **And** re-entry creates one new run with baseline Garden Heart health, phase, action history, weak points, gates, arena state, and deterministic occurrence identity.

16. **Reload the boss checkpoint transactionally**

    **Given** the approved Reload Checkpoint command is accepted
    **When** CheckpointRuntimeState is applied
    **Then** LevelController invalidates the old run and reconciles player, level progression, approach state, gates, arena mutations, rewards, and boss inactive state to the complete captured snapshot
    **And** the restore either commits as one valid checkpoint state or falls back through the established typed failure policy
    **And** no partially restored player or level can activate a boss
    **And** crossing commitment afterward creates a fresh boss rather than reviving the old occurrence.

17. **Preserve full-level restart semantics**

    **Given** the player requests a full Last Garden restart where that command is approved
    **When** application and level replacement complete
    **Then** the old level session, approach run, boss run, checkpoint runtime, objective state, presentation context, rewards, and transient work are invalidated and released
    **And** a fresh Last Garden session begins from its authored entry state
    **And** the player must satisfy the new session's prerequisites before boss activation
    **And** immutable level, encounter, boss, ability, and presentation definitions retain their fingerprints.

18. **Complete the boss encounter only from current boss death**

    **Given** the current Garden Heart is alive and registered as the required boss participant
    **When** its health owner commits one valid death
    **Then** EncounterController validates boss entity, participant, occurrence, run, level session, lethal damage result, and current encounter phase
    **And** it commits Garden Heart participant terminal state and boss-encounter completion exactly once
    **And** missing geometry, hidden presentation, a freed boss node, an open gate, diagnostic input, stale death, or destroyed stand-in cannot complete the encounter
    **And** late action, pressure, hit, counter, and phase work cannot reactivate or damage the defeated boss.

19. **Commit the boss objective through LevelController**

    **Given** EncounterController emits one valid current-run boss-completion fact
    **When** the boss LevelObjective adapter consumes it
    **Then** LevelController validates and commits the Garden Heart objective exactly once for the current level session
    **And** the objective exposes committed completion state to the approved HUD and later reward-and-exit flow
    **And** EncounterController, the boss, a weak point, reward pickup, gate, UI, or presentation cannot commit level objective state directly
    **And** duplicate or stale encounter completion returns the existing result without repeating side effects.

20. **Reach a stable post-defeat arena state**

    **Given** boss encounter and objective completion commit
    **When** death cleanup and level-owned post-defeat transitions finish
    **Then** no boss pressure, hostile hitbox, projectile, hazard, temporary obstacle, surface mutation, support effect, action audio, or damaging weak point remains active
    **And** the approved route to Story 8.2's safe reward-and-exit space becomes traversable through level-owned gate or arena state
    **And** player movement, camera, HUD, and nonhostile presentation remain usable
    **And** this story creates no RewardGrant, collectible reward, exit completion, or application transition.

21. **Reject stale work from prior attempts**

    **Given** a participant, damage, counter, vulnerability, phase, action, delivery, trigger, checkpoint, gate, objective, presentation, audio, or cleanup fact belongs to an old run or level session
    **When** it reaches a current owner
    **Then** it cannot affect current boss health, player health, phase, weak points, arena state, encounter state, objective, checkpoint, gates, HUD, or audio
    **And** it returns or records a bounded typed stale reason
    **And** detached deliveries use immutable attribution rather than retaining destroyed source nodes
    **And** repeated retries do not grow stale queues, logs, references, or subscriptions without bound.

22. **Provide readable fallback flow presentation**

    **Given** final environment, boss, UI, animation, VFX, and audio media are unavailable
    **When** checkpoint activation, arena commitment, gate closure, fight activation, player death, recovery choice, restart, boss defeat, objective completion, and post-defeat access occur
    **Then** primitive geometry, panels, markers, state materials, text, and semantic placeholder cues make every transition understandable
    **And** critical states use non-color distinctions and remain clear with diagnostics disabled
    **And** presentation follows committed owner state and cannot perform a transition
    **And** future media can replace the adapters without changing checkpoint, encounter, objective, gate, or cleanup logic.

23. **Expose bounded encounter-flow diagnostics**

    **Given** diagnostics are enabled after the player-facing pass
    **When** boss flow is inspected
    **Then** diagnostics show level session, prerequisite, checkpoint identity and snapshot version, commitment observation, gate state, dependency readiness, encounter run, deterministic seed, boss occurrence, current encounter and objective state, failure and recovery transaction, cleanup status, and stale rejection
    **And** the overlay reads maintained owner state without creating triggers, runs, checkpoints, deaths, objectives, or resets
    **And** occurrence histories and drawings remain bounded and stop when hidden
    **And** release-like play omits or disables the detailed controls and overlay.

24. **Make activation, defeat, and recovery manually reproducible**

    **Given** another developer launches the named Last Garden boss-flow fixture through normal application loading with diagnostics initially disabled
    **When** they follow the documented procedure
    **Then** they complete the approach, activate the boss checkpoint, commit to the arena, observe safe gate closure, fight through every phase, die in representative action and transition states, use every approved recovery choice, and defeat the boss
    **And** they verify the correct approach and checkpoint state after each recovery, one fresh baseline boss per attempt, stable post-defeat cleanup, objective completion, and access to but no automatic collection from the reward area
    **And** they repeat activation and completion, replace the level mid-fight, and inject duplicate and stale observations, deaths, completion facts, and callbacks
    **And** retained evidence separates objective identity, state, transaction, cleanup, and repeatability results from subjective checkpoint placement, retry friction, gate readability, pacing, and fairness.

25. **Verify the boss flow automatically**

    **Given** level, checkpoint, encounter, Garden Heart, objective, loading, HUD-binding, audio-scope, and real-Jolt integration tests run
    **When** they exercise missing prerequisites, checkpoint activation, duplicate threshold crossings, readiness failure and rollback, gate transitions, fight activation, player death, every approved recovery command, boss death, duplicate and stale completion, objective commit, post-defeat cleanup, level replacement, and repeated attempts
    **Then** at most one current boss run, boss occurrence, checkpoint snapshot, player-death result, encounter-completion fact, and objective-completion result exists where each contract permits one
    **And** every invalidated runtime object and presentation or audio occurrence is released
    **And** no old attempt can affect the next attempt and immutable definitions retain their fingerprints
    **And** automation supplements rather than replaces manual retry feel, flow clarity, and encounter pacing review.

26. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** the same deterministic activation, fight, death, retry, and defeat sequence runs at shipping 60 Hz and diagnostic 120 Hz
    **When** observations, actions, gates, damage, phases, cleanup, recovery, and objective completion resolve
    **Then** real-time behavior, accepted transitions, boss and player outcomes, restore state, run counts, and terminal results remain equivalent within documented tolerance
    **And** additional physics callbacks cannot duplicate commitment, checkpoint, death, restart, boss completion, or objective facts
    **And** high-speed crossing of the commitment threshold remains reliable
    **And** a rate-sensitive authoritative difference blocks the story.

27. **Stay within the approved integrated boss-flow budget**

    **Given** the complete encounter flow runs on the selected minimum-spec PC with representative boss presentation
    **When** activation, worst-phase combat, player death, cleanup, restart, and boss defeat are profiled across repeated attempts
    **Then** boss, encounter, level, query, physics, presentation, audio, cleanup, and reload costs remain within Story 8.1's provisional allocations
    **And** restart does not cause retained object, signal, memory, audio-voice, or loading-time growth
    **And** no combat-critical first-use synchronous load occurs
    **And** this evidence informs but does not replace Story 8.11's final M4 gate.

28. **Keep the story bounded to boss encounter flow**

    **Given** Story 8.9 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains approach gating, boss checkpoint activation, arena commitment, transactional run activation, gate behavior, player death, approved recovery paths, clean retry, boss encounter completion, boss objective completion, post-defeat cleanup, fallback presentation, diagnostics, and focused evidence
    **And** it does not add boss mechanics, reward grants or collection, exit interaction or application transition, final numerical balance, final media, persistent campaign saving, or final performance sign-off
    **And** reward, exit, M4 performance, and complete-slice replay remain assigned to Stories 8.10 through 8.12.
