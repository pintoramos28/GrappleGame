---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.7'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 7
---

# Story 7.7: Restart an Encounter or Reload the Active Checkpoint

As a player,
I want death and severe traversal failure to offer a clean encounter retry or checkpoint reload,
So that I can recover quickly without stale enemies, effects, or progression state.

**Acceptance Criteria:**

1. **Declare the focused restart outcome**

   **Given** the M3 encounter sequence is playable
   **When** its restart definition and procedure are inspected
   **Then** its outcome is to activate bounded in-memory checkpoints and recover from player death or severe out-of-bounds failure through either current-encounter restart or active-checkpoint reload
   **And** checkpoint capture, player restoration, encounter recreation, progression restoration, cleanup, command eligibility, failure behavior, presentation, diagnostics, manual procedure, and evidence requirements are explicit
   **And** it builds on Stories 7.2 through 7.6 without changing their ownership
   **And** disk saves, persistent progression, rewards, production HUD, pause, settings, and boss checkpoints remain outside this story.

2. **Author immutable checkpoint definitions**

   **Given** the M3 checkpoint set is inspected
   **When** its definitions are resolved
   **Then** it contains one implicit level-entry checkpoint, one branch checkpoint after the lower required encounter, and one upper-approach checkpoint after the optional and main routes rejoin
   **And** each `CheckpointDefinition` declares a stable ID and version, activation region where applicable, prerequisite facts, authored player transform and view orientation, player restore profile, permitted progression capture, presentation profile, and ordering rank
   **And** checkpoint transforms, prerequisites, ordering, and restoration policy remain authored data rather than literals in `LevelController`, regions, player code, fixtures, or UI
   **And** runtime activation and snapshot state never mutates the definitions.

3. **Keep checkpoint authority in `LevelController`**

   **Given** a checkpoint region is observed or restart is requested
   **When** checkpoint state may change
   **Then** `LevelController` validates and commits activation, active-snapshot replacement, encounter restart, or checkpoint reload
   **And** checkpoint regions only report typed observations
   **And** encounters, players, health, gates, objectives, HUD, system screens, audio, and fixtures cannot capture or restore level progression directly
   **And** no global save manager or mutable gameplay store is introduced.

4. **Store one active in-memory checkpoint snapshot**

   **Given** a checkpoint activation is accepted
   **When** `CheckpointRuntimeState` is created
   **Then** it records checkpoint and definition identities, level-session identity, activation occurrence, capture physics step, player restore profile, authored restore transform, flow-definition version, captured encounter-entry states, required-completion facts, optional state, gate states, objective facts, and snapshot version
   **And** it contains stable identities and immutable scalar or value data rather than live node references
   **And** only one checkpoint snapshot is active for restart in the current level session
   **And** the snapshot is discarded when the containing level session ends.

5. **Capture progression rather than transient simulation**

   **Given** a valid checkpoint activates
   **When** its snapshot is assembled
   **Then** it captures committed level-flow and objective facts permitted by its definition
   **And** it does not capture current velocity, active grapple, attack phase, ability execution, enemy health, AI memory, projectile, hazard, telegraph, timer, audio playback position, camera shake, or arbitrary scene-tree state
   **And** player health and locomotion are restored from the authored player restore profile rather than a potentially unsafe instant sample
   **And** encounter participants and transients are recreated or omitted according to restored progression rather than serialized as live objects.

6. **Use a complete player restore profile**

   **Given** any of the three M3 checkpoint definitions is inspected
   **When** its baseline restore profile is resolved
   **Then** it restores the existing level-owned player to full baseline health, the authored checkpoint transform and view orientation, zero carried linear velocity, grounded or explicitly supported start state, and the normal gameplay collision profile
   **And** it clears active grapple, wall attachment, attack execution, damage recovery, temporary statuses, pending motor influences, contact history, target selection, latched gameplay edges, and held input inherited from the failed attempt
   **And** it restores player components through their typed owners rather than directly writing private fields
   **And** it grants no undeclared coin, reward, damage immunity, attack advantage, or movement impulse.

7. **Initialize the level-entry checkpoint automatically**

   **Given** a fresh M3 level session becomes active
   **When** level-flow and player readiness commit
   **Then** the implicit entry checkpoint becomes the active snapshot exactly once
   **And** it captures the authored initial flow with all encounters unstarted, required gates closed, optional state unstarted, and objective incomplete
   **And** it uses the level's supported player start transform
   **And** it requires no collision-region callback or player interaction.

8. **Activate the branch checkpoint after lower completion**

   **Given** the lower required encounter has completed and no encounter is active
   **When** the current player enters the branch checkpoint region
   **Then** `LevelController` validates player, level-session, checkpoint, prerequisite, ordering, region, and duplicate identities
   **And** it replaces the entry snapshot with a branch snapshot preserving lower completion, the opened lower gate, available optional and upper entries, and incomplete final objective
   **And** the optional encounter remains unstarted and selectable
   **And** entering the region before lower completion returns an unmet-prerequisite result without changing the active checkpoint.

9. **Activate the upper-approach checkpoint at the shared rejoin**

   **Given** the lower encounter is complete, no encounter is active, and the player reaches the shared upper approach
   **When** the upper checkpoint region is accepted
   **Then** it replaces the active snapshot with an upper-approach snapshot
   **And** it preserves whether the optional encounter is completed or remains unstarted and available
   **And** it preserves the corresponding optional rejoin-gate state and keeps the upper required encounter available but unstarted
   **And** it does not mark an unentered optional encounter completed merely because the player used the bypass.

10. **Allow a checkpoint to refresh only after real progression**

    **Given** the current player crosses the active checkpoint region again
    **When** the checkpoint and captured flow state are compared
    **Then** an identical or older state returns an already-current result without another activation or notification
    **And** a compatible strictly advanced state—such as completing the optional encounter before recrossing the upper checkpoint—may create one new snapshot version at the same checkpoint
    **And** regression, foreign-session facts, or debug-only mutations cannot overwrite the active snapshot
    **And** replacement preserves prior evidence rather than silently rewriting its history.

11. **Keep checkpoint activation safe**

    **Given** a checkpoint candidate is eligible
    **When** its authored restoration location is validated
    **Then** the complete player body fits on supported non-hazardous geometry outside enemy spawn volumes, progression-gate collision, severe-failure space, and active hazard regions
    **And** the player has a valid camera, ground, grapple, and route context on restoration
    **And** an unsafe, blocked, unsupported, non-finite, or out-of-bounds checkpoint fails level readiness or activation as appropriate
    **And** the system does not relocate the checkpoint to an undocumented fallback.

12. **Accept one authoritative player-failure fact**

    **Given** the current player's health commits death or the player crosses the Story 7.5 severe-failure boundary
    **When** the level receives that fact
    **Then** `LevelController` validates player, level-session, cause, occurrence, and physics-step identities before committing one recovery-required result
    **And** health death retains its combat attribution while out-of-bounds remains a distinct traversal-failure reason
    **And** duplicate hurtboxes, repeated death callbacks, continued boundary occupancy, or late prior-session facts cannot start another recovery flow
    **And** ordinary landings on recovery geometry do not count as severe failure.

13. **Quiesce gameplay after failure**

    **Given** one current recovery-required result has committed
    **When** the restart-choice state begins
    **Then** new gameplay commands, player movement commits, AI decisions, encounter actions, damage deliveries, and level progression are stopped through their normal state-gating or cancellation boundaries
    **And** the current encounter run and level session remain identifiable while a valid recovery command is chosen
    **And** presentation may continue only through the bounded death or failure transition policy
    **And** freezing presentation or input cannot itself complete cleanup or restore gameplay state.

14. **Present only valid recovery commands**

    **Given** the resident system-screen layer shows the restart choice
    **When** available actions are resolved
    **Then** `Reload Checkpoint` is available whenever a valid active checkpoint snapshot exists
    **And** `Restart Encounter` is available only when one current active or just-failed encounter has a valid authored encounter-restart profile
    **And** a safe return or full level reload remains available only through the existing application-flow boundary where required
    **And** UI buttons emit narrow typed requests and cannot reset an encounter, restore the player, or modify checkpoint state directly.

15. **Author an encounter restart position for each arena**

    **Given** the lower, optional, and upper encounter definitions participate in death recovery
    **When** their restart profiles are validated
    **Then** each declares one safe player transform and view orientation associated with its arena and current commitment state
    **And** the lower and upper positions preserve their required encounter context while remaining outside participant spawn overlap
    **And** the optional position remains inside its committed branch so encounter retry cannot be used to escape the chosen challenge
    **And** every restart position passes the same support, bounds, collision, camera, and route-safety checks as a checkpoint.

16. **Restart only the current encounter when requested**

    **Given** an eligible active or failed encounter exists and the player chooses `Restart Encounter`
    **When** `LevelController` accepts the typed request
    **Then** it preserves the current level session, active checkpoint snapshot, and all committed level-flow progress outside that encounter
    **And** it commands the current `EncounterController` to invalidate its run before removing its runtime root and scoped transients
    **And** it prepares a fresh run with a new encounter-run identity under the same encounter entry
    **And** other completed or unstarted encounters are not recreated, reactivated, or otherwise changed.

17. **Restore the player during encounter restart**

    **Given** the old encounter run is invalidated and its scoped work no longer accepts requests
    **When** encounter restart reaches player restoration
    **Then** `LevelController` applies the authored player restore profile at that encounter's safe restart transform
    **And** the level-owned player remains the current level's player rather than being reparented into the encounter runtime
    **And** camera, input source, HUD context, and level-session identity remain bound to the restored player through their typed owners
    **And** no old velocity, grapple, attack, damage, target, input edge, or status affects the fresh attempt.

18. **Activate the fresh encounter only after restoration**

    **Given** a new encounter runtime root and fully configured participants are ready
    **When** player restoration reports success
    **Then** `EncounterController` publishes the fresh run as active
    **And** participant AI, targeting, abilities, collision delivery, and presentation begin only after the player is in the safe restart state
    **And** no temporary invulnerability is required to conceal premature activation
    **And** failure to restore the player prevents activation and returns a typed level-recovery failure.

19. **Preserve commitment during optional encounter retry**

    **Given** the player dies after committing to the optional branch
    **When** they select `Restart Encounter`
    **Then** the optional entry remains active under a fresh encounter run, its rejoin gate remains closed, and the player returns to the optional arena's safe restart transform
    **And** lower required completion and the current active checkpoint remain preserved
    **And** optional participants, health, AI, abilities, and transients begin fresh
    **And** encounter retry cannot mark the optional challenge skipped or move the player onto the main bypass.

20. **Reload the active checkpoint transactionally**

    **Given** the player chooses `Reload Checkpoint`
    **When** `LevelController` accepts the request
    **Then** it invalidates every active encounter run and stops accepting level-scoped work created after the checkpoint snapshot
    **And** it cancels player executions and transient level operations before restoring flow, gate, objective, encounter-entry, optional, and player state
    **And** restoration either commits completely or returns one typed failure suitable for full safe level reload
    **And** duplicate reload requests return the current transaction result without overlapping restoration work.

21. **Restore checkpointed progression exactly**

    **Given** the branch or upper checkpoint snapshot is being reloaded
    **When** its captured flow state is applied
    **Then** required encounters completed at capture remain completed and do not respawn
    **And** gates open at capture return open, while gates closed at capture return closed
    **And** encounters available or locked at capture return to those states without active runtime roots
    **And** objective facts, optional state, arrival state, and level completion return exactly to the captured pre-completion values.

22. **Discard post-checkpoint progression**

    **Given** an encounter, gate, optional result, arrival fact, or objective fact was committed after the active checkpoint snapshot
    **When** that checkpoint is reloaded
    **Then** the later fact is removed from current progression state
    **And** any associated active or terminal encounter runtime and transient objects are invalidated or removed
    **And** the fact remains only in bounded diagnostic or evidence history, not current gameplay
    **And** no post-checkpoint completion can reopen a gate or satisfy the restored objective through a late callback.

23. **Differentiate optional retry from checkpoint rollback**

    **Given** the player dies during the active optional encounter while the branch checkpoint remains current
    **When** they compare the two recovery commands
    **Then** `Restart Encounter` returns them to a fresh optional run while preserving commitment
    **And** `Reload Checkpoint` restores the branch snapshot with the optional encounter unstarted and selectable
    **And** both outcomes are communicated before confirmation
    **And** neither path silently chooses or completes the optional challenge for the player.

24. **Handle failure outside an active encounter**

    **Given** the player dies or crosses the severe-failure boundary while traversing between encounters
    **When** the restart choice is shown
    **Then** `Restart Encounter` is unavailable because no current encounter owns the failure context
    **And** `Reload Checkpoint` restores the active snapshot
    **And** completed encounters and open gates captured by that snapshot remain preserved
    **And** no unrelated encounter is activated merely to provide a retry target.

25. **Resolve death, encounter completion, and checkpoint races deterministically**

    **Given** player death, final participant death, checkpoint entry, gate opening, or objective facts occur near the same simulation boundary
    **When** `LevelController` orders committed facts and commands
    **Then** one documented owner-controlled precedence policy determines the current progression and recovery result
    **And** signal connection, collision callback, participant, checkpoint-region, and scene-tree order cannot change it
    **And** facts committed before the accepted checkpoint capture are included while later facts are not
    **And** at most one recovery-required, checkpoint activation, encounter completion, and level completion result exists for each applicable identity.

26. **Remove every invalidated transient before play resumes**

    **Given** encounter restart or checkpoint reload is in progress
    **When** cleanup is inspected
    **Then** invalid encounter executions, participants, projectiles, telegraphs, hazards, obstacles, links, surface mutations, statuses, motor influences, timers, audio emitters, presentation callbacks, and damage deliveries stop or are removed exactly once
    **And** source-independent objects cannot survive encounter-run or level-recovery invalidation
    **And** stale input, collision overlap, region occupancy, and deferred calls cannot immediately retrigger the old failure
    **And** gameplay resumes only after cleanup, restoration, and required fresh initialization succeed.

27. **Reject stale recovery work**

    **Given** a death fact, boundary fact, checkpoint observation, restart request, restoration callback, encounter fact, spawn, damage delivery, HUD update, or audio request carries an invalid player, encounter-run, level-session, checkpoint-snapshot, or recovery-transaction identity
    **When** it reaches a current boundary
    **Then** it is rejected or ignored with a bounded typed reason
    **And** it cannot restore the player, replace the active checkpoint, reactivate an encounter, reopen a gate, affect health, or resume gameplay
    **And** expected stale rejection does not create unbounded logging
    **And** diagnostics retain stable identities without retaining destroyed nodes.

28. **Leave rewards out of checkpoint state for now**

    **Given** Story 7.7 precedes current-scope reward implementation
    **When** checkpoint snapshots and restoration are reviewed
    **Then** no coin, reward pickup, reward table, or inventory value is fabricated or restored
    **And** the checkpoint contract exposes an explicit empty or unavailable current-reward-state boundary for Story 7.8 to integrate deliberately
    **And** later reward integration must preserve committed grants according to its own approved policy
    **And** this story cannot use rewards as proof that checkpoint reload succeeded.

29. **Expose read-only recovery presentation state**

    **Given** primitive system presentation or the later production HUD needs failure and checkpoint information
    **When** it reads the current state
    **Then** it can identify active checkpoint label, newly activated checkpoint, player failure reason, available recovery commands, active transaction, restored checkpoint, restarted encounter, recovery failure, and return to gameplay
    **And** checkpoint and encounter choices use presentation-safe text rather than internal identifiers
    **And** presentation consumes committed state and emits only narrow UI commands
    **And** it conforms to the Story 7.1 checkpoint, death, restart, transition, and system-layer rules.

30. **Provide bounded checkpoint and recovery diagnostics**

    **Given** development diagnostics are enabled
    **When** checkpoint or recovery state is inspected
    **Then** the overlay reads checkpoint-definition and snapshot identities, snapshot version, captured progression, active encounter and run, failure occurrence, available commands, transaction phases, cleanup counts, player restoration result, stale rejections, and terminal outcome
    **And** it does not capture another checkpoint, recalculate progression, resurrect a participant, or restore private player fields
    **And** hidden diagnostics stop formatting and refreshing this data
    **And** histories and counters remain bounded and unavailable or disabled in release behavior.

31. **Make both recovery paths manually reproducible**

    **Given** another developer loads a fresh M3 level session through the normal application path
    **When** they follow the documented procedure with diagnostics initially disabled
    **Then** they die in the lower required encounter and successfully compare encounter retry with entry-checkpoint reload
    **And** they activate the branch checkpoint, die in the optional encounter, verify that encounter retry preserves commitment, and verify in a separate attempt that branch-checkpoint reload restores the unstarted choice
    **And** they complete or skip the optional path, activate the upper checkpoint, die in the upper encounter, and verify the correct lower and optional progress survives each applicable recovery path
    **And** they fail outside an encounter, cross the severe-failure boundary, refresh the upper checkpoint after later optional completion, issue duplicate commands, inject a stale callback, and repeat after full level reload
    **And** every resumed attempt contains the intended player and progression state with no prior enemy, attack, projectile, hazard, link, status, gate mismatch, objective fact, input edge, audio, or callback
    **And** retained evidence separates objective checkpoint, death, choice eligibility, encounter recreation, rollback, restoration, cleanup, stale-rejection, and repeatability results from subjective recovery speed, clarity, placement, and frustration observations.

32. **Verify restart and checkpoint contracts automatically**

    **Given** the permanent checkpoint-recovery suite and focused real-Jolt M3 scene run are available
    **When** they exercise definition validation, safe transforms, entry, branch and upper activation, snapshot replacement and refresh, duplicate observations, health death, out-of-bounds failure, quiescence, command eligibility, lower, optional and upper encounter retry, checkpoint rollback from each progression state, post-checkpoint fact removal, player restoration, cleanup, failure rollback, stale work, full level replacement, randomized callback order, and repeated recovery
    **Then** every failure creates no more than one recovery transaction, every encounter retry creates one fresh run, and every checkpoint reload restores exactly one valid snapshot
    **And** no completed-before-checkpoint encounter respawns, no post-checkpoint fact remains current, and no invalidated transient or player state survives
    **And** immutable checkpoint, player, flow, encounter, gate, objective, and gameplay definitions retain their original fingerprints
    **And** focused scene evidence confirms the same contracts under real combat, collision, grapple, wall traversal, severe falls, and scene-tree behavior.

33. **Preserve recovery behavior at both physics rates**

    **Given** equivalent failure and recovery scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **When** death, boundary crossing, encounter completion, checkpoint activation, restart, rollback, player restoration, and gameplay resumption occur
    **Then** authoritative precedence, checkpoint snapshots, encounter states, gate states, objective facts, player restore results, and terminal outcomes remain equivalent
    **And** restored traversal and combat retain their previously documented real-time behavior within tolerance
    **And** additional physics callbacks cannot duplicate failure, activation, cleanup, restoration, or resumption
    **And** a rate-sensitive recovery difference blocks the story.

34. **Keep the story bounded to in-memory recovery**

    **Given** Story 7.7 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it contains three M3 checkpoint definitions, one active in-memory snapshot, typed failure and recovery commands, current-encounter restart, checkpoint reload, player restoration, progression rollback, primitive system presentation, diagnostics, and focused verification
    **And** it has not implemented disk saves, persistent RPG progression, inventories, rewards, production HUD, pause, settings, input remapping, production audio, level-exit loading, production enemies, boss checkpoints, or final content
    **And** those concerns remain assigned to later stories.
