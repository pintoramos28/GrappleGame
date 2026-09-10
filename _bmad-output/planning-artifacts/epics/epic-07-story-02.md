---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 2
---

# Story 7.2: Complete One Run-Scoped Encounter

As a player,
I want each encounter to activate, track its combatants, complete once, and restart from a clean state,
So that I can fight and retry without enemies or effects leaking between attempts.

**Acceptance Criteria:**

1. **Declare the focused encounter outcome**

   **Given** the run-scoped encounter fixture is registered for Epic 7 validation
   **When** its definition and procedure are inspected
   **Then** its outcome is one bounded encounter that activates from an explicit request, creates a fresh combat run, registers two existing melee-enemy participants, completes after both are defeated, and can be restarted cleanly
   **And** activation, participant ownership, completion, failure, reset, presentation, diagnostics, manual procedure, and evidence requirements are explicit
   **And** the fixture uses primitive geometry and existing combat capabilities
   **And** it remains an encounter-lifecycle test rather than a production encounter, level objective, reward, checkpoint, or boss fight.

2. **Author one immutable encounter definition**

   **Given** the baseline encounter profile is inspected
   **When** its configured values and references are resolved
   **Then** it declares a stable encounter ID and version, authored bounds, two ordered participant spawn entries, participant definitions, spawn transforms, completion-contributor flags, deterministic seed policy, required resident dependencies, activation policy, completion policy, reset policy, presentation profile, and diagnostic profile
   **And** its baseline completion policy is `ALL_REQUIRED_PARTICIPANTS_TERMINAL`
   **And** participant definitions, transforms, bounds, and policies remain authored configuration rather than literals in `EncounterController`, spawners, participants, fixture controls, or presentation
   **And** runtime state never mutates this definition.

3. **Keep encounter runtime state owner-local**

   **Given** an encounter activation or run exists
   **When** its mutable state is inspected
   **Then** `EncounterController` owns the current encounter phase, run ID, runtime root, participant registry, activation result, completion state, failure state, and reset transaction
   **And** participants continue to own their health, AI, abilities, targeting, damage reactions, and death state
   **And** typed domain spawners own validation and construction of their runtime objects
   **And** no global mutable gameplay store, universal event bus, group scan, or scene-tree search becomes an encounter authority.

4. **Use a typed encounter run context**

   **Given** a new encounter run is being prepared
   **When** its context is created
   **Then** it carries stable level-session, encounter, encounter-instance, run, deterministic-seed, runtime-root, bounds, and diagnostic identities required by participating systems
   **And** it exposes only the typed spawners, query references, presentation outputs, and scoped services required by those systems
   **And** every participant, execution, projectile, hazard, obstacle, link, telegraph, effect, and encounter-audio request created for the run receives the applicable run identity
   **And** the context does not expose `EncounterController` internals as a general service locator.

5. **Accept activation through one explicit boundary**

   **Given** the encounter is inactive and its definition is available
   **When** the fixture or later `LevelController` submits a typed activation request
   **Then** `EncounterController` validates the requesting level session, encounter identity, current phase, definition, authored bounds, dependency readiness, participant entries, spawn transforms, and required runtime services
   **And** a valid request begins one activation transaction
   **And** fixture, level, trigger, UI, AI, or participant code cannot create a run ID, publish active state, register combatants, or complete the encounter directly
   **And** rejected, duplicate, stale, busy, or invalid requests return typed results without a partial run.

6. **Require resident combat dependencies before activation**

   **Given** an activation request reaches validation
   **When** its participant and combat references are checked
   **Then** both enemy scenes, definitions, behaviors, attacks, projectiles where applicable, telegraphs, primitive presentation, audio fallbacks, and required query profiles are already resident and valid
   **And** first-time synchronous loading is not initiated during encounter activation or combat
   **And** a missing encounter-critical dependency fails activation and identifies the exact dependency
   **And** optional presentation may use its approved fallback without changing gameplay readiness.

7. **Create a fresh unique run identity**

   **Given** activation prerequisites pass
   **When** the activation transaction begins
   **Then** one new encounter run ID is allocated and is never reused by a later attempt in the same level session
   **And** the previous run, if one existed, is already invalidated and cannot accept new work
   **And** the run's deterministic seed is derived through the declared policy and recorded for reproduction
   **And** no participant or transient becomes publicly active before the complete new run is ready.

8. **Build one replaceable runtime root**

   **Given** a fresh run ID exists
   **When** runtime ownership is prepared
   **Then** one `EncounterRuntimeRoot` is created with typed containers for participants, projectiles, telegraphs, temporary hazards, spawned obstacles, links or effects, encounter presentation, and encounter audio
   **And** the root belongs only to that encounter instance and run
   **And** static level geometry, navigation, the persistent `UIRoot`, and the level-owned player remain outside the replaceable encounter subtree
   **And** arbitrary gameplay `add_child()` calls cannot bypass the appropriate scoped spawner or container.

9. **Spawn required participants transactionally**

   **Given** the runtime root and both ordered spawn requests are ready
   **When** encounter activation constructs its participants
   **Then** each enemy is instantiated, type-checked, fully configured with its immutable definition and run context, attached to the participant container, and registered before active state is published
   **And** neither enemy begins AI decisions, movement, targeting, abilities, collision delivery, or presentation before the transaction commits
   **And** failure to instantiate, configure, attach, or register either required participant rolls back both participants and the complete runtime root
   **And** the encounter returns one typed activation failure without leaving a partial arena or hidden retry.

10. **Reject unsafe participant placement**

    **Given** a participant spawn entry is evaluated
    **When** its authored transform and bounds are validated
    **Then** the complete body volume fits within the encounter's permitted spawn region, avoids prohibited overlap with the player and other participants, has valid navigation or tactical fallback support, and contains finite transform data
    **And** the existing enemy can enter a valid baseline tactical state from that placement
    **And** invalid placement fails the activation transaction rather than moving the enemy to an undocumented fallback
    **And** an explicitly authored alternate spawn profile may be used only as separate immutable configuration.

11. **Register participants through typed facts**

    **Given** a participant is fully configured during activation
    **When** it joins the encounter
    **Then** its registry entry records stable entity identity, definition identity, run ID, completion-contributor status, current alive or terminal state, and a non-owning runtime reference
    **And** registration connects only the typed committed facts required for encounter ownership and completion
    **And** duplicate entity IDs, duplicate registration, stale-run registration, or registration after activation closes are rejected with typed reasons
    **And** the registry does not infer participants from groups, collision layers, node names, child positions, or periodic scene scans.

12. **Publish active state only after complete initialization**

    **Given** the runtime root, both participants, registry entries, signals, bounds, and scoped services are valid
    **When** the activation transaction commits
    **Then** `EncounterController` publishes one `ACTIVE` state and one committed activation fact for the new run
    **And** both participants may begin normal AI, movement, targeting, combat, and presentation only after that boundary
    **And** the player receives the current encounter run context required for attributed combat without being reparented into the runtime root
    **And** no observer can see a half-active state containing only one required participant.

13. **Keep gameplay requests scoped to the active run**

    **Given** the encounter is active
    **When** a participant requests an ability, spawn, movement action, target update, damage delivery, link, hazard, obstacle, presentation cue, or encounter-audio cue
    **Then** the responsible owner validates the active run identity before accepting the request
    **And** accepted runtime objects are attached to their declared container beneath the current runtime root
    **And** scene-tree parentage determines cleanup lifetime while stable combat-source data determines attribution
    **And** a child occurrence may outlive its source entity only under its approved source-death policy, never beyond encounter-run invalidation.

14. **Reject stale and foreign work**

    **Given** a request, callback, signal payload, damage delivery, spawn, or terminal fact carries an invalid, prior, foreign, or missing run identity
    **When** it reaches an encounter-scoped boundary
    **Then** it is rejected or ignored with a bounded reason-coded result
    **And** it cannot spawn an object, affect health, alter the participant registry, complete the encounter, emit current presentation, or consume current cadence
    **And** expected stale rejection does not produce unbounded error logging
    **And** diagnostics retain enough identity information to trace the rejected work without retaining the old node.

15. **Update participant state from committed facts**

    **Given** a registered enemy takes damage, dies, is removed, or otherwise reaches an approved terminal state
    **When** its entity coordinator emits the corresponding committed fact
    **Then** `EncounterController` verifies entity and run identities before updating that registry entry exactly once
    **And** accepted enemy death changes the completion-contributor state without scanning its health component or node existence
    **And** duplicate death or terminal facts return the already-recorded result without decrementing another count or repeating side effects
    **And** ordinary nonterminal damage, attack completion, target loss, or temporary AI fallback does not count as participant completion.

16. **Do not count unexplained participant disappearance as victory**

    **Given** a required participant leaves the tree or becomes unavailable without an approved terminal fact
    **When** encounter ownership detects the loss
    **Then** the encounter records an operation failure for that participant rather than treating it as defeated
    **And** completion remains uncommitted
    **And** the responsible failure policy cancels or resets the encounter through `EncounterController`
    **And** diagnostics identify the participant, run, last committed state, and loss reason.

17. **Complete only after both required enemies terminate**

    **Given** the encounter is active with two required completion contributors
    **When** the first enemy dies
    **Then** its registry entry becomes terminal while the encounter remains active and incomplete
    **And** the surviving enemy continues under its existing AI and combat behavior.

    **Given** the second enemy then dies in the same valid run
    **When** the registry commits its terminal fact
    **Then** the `ALL_REQUIRED_PARTICIPANTS_TERMINAL` rule becomes satisfied
    **And** the encounter begins one completion transaction.

18. **Commit encounter completion exactly once**

    **Given** the completion condition becomes satisfied
    **When** `EncounterController` commits completion
    **Then** it records one immutable encounter-completion result containing encounter, instance, run, participating entity, terminal, timing, and evidence identities
    **And** it publishes one past-tense completion fact to the later `LevelController` boundary
    **And** duplicate participant facts, delayed callbacks, repeated evaluations, or repeated completion requests return the committed result without another fact
    **And** encounter completion itself does not advance a level objective, grant a reward, activate a checkpoint, load another level, or display production HUD state.

19. **Resolve completion and reset races deterministically**

    **Given** the final required death and a reset request can arrive near the same simulation boundary
    **When** encounter commands and committed facts are ordered
    **Then** one documented owner-controlled precedence rule determines whether completion commits before reset invalidation or the death is rejected as stale
    **And** callback, signal-connection, participant-registration, and scene-tree order cannot change that result
    **And** at most one completion result and one reset result are recorded for their applicable runs
    **And** retained evidence exposes the chosen ordering and terminal reasons.

20. **Reset through the declared transaction**

    **Given** reset is accepted while the encounter is activating, active, completing, completed, or failing
    **When** `EncounterController` performs the transaction
    **Then** it invalidates the current run ID and stops accepting new work before cancelling executions or removing runtime objects
    **And** it cancels active executions, ends source-bound links and effects, and removes or fades scoped presentation and audio under their approved policies
    **And** it frees the old runtime root at a safe scene-tree boundary before creating and configuring the replacement run
    **And** repeated reset requests during the same transaction return its existing result rather than creating competing roots.

21. **Keep player restoration at the level boundary**

    **Given** encounter reset needs the player returned to a valid starting state
    **When** the reset transaction reaches player restoration
    **Then** `EncounterController` issues one typed restoration request to the fixture adapter or later `LevelController`
    **And** it does not directly change player transform, velocity, health, grapple, attack, input, camera, or inventory state
    **And** Story 7.2's fixture adapter restores only its declared test start state
    **And** checkpoint selection and production player restoration remain assigned to a later level-owned story.

22. **Recreate participants instead of scrubbing them**

    **Given** the old runtime root has been invalidated and removed
    **When** a new encounter attempt is activated
    **Then** both enemies are newly instantiated and initialized from immutable definitions
    **And** their health, AI memory, target, action state, cooldowns, cadence, damage reactions, navigation state, and signal connections begin from the authored baseline
    **And** runtime cleanup does not attempt to resurrect or manually reset the old enemy nodes
    **And** the new run uses a new identity even when every authored input remains identical.

23. **Expose one read-only encounter presentation state**

    **Given** HUD implementation has not yet begun
    **When** encounter state changes
    **Then** `EncounterController` exposes a typed read-only snapshot and committed change facts for unavailable, inactive, activating, active, completing, completed, failed, and resetting states
    **And** the snapshot includes only presentation-safe encounter identity, label, state, required progress where authored, and current level-session and run identities
    **And** primitive fixture presentation can consume it without controlling activation or completion
    **And** it conforms to the Story 7.1 `GameplayHudContext` mapping without implementing the production HUD.

24. **Provide bounded encounter diagnostics**

    **Given** a development build enables encounter diagnostics
    **When** the encounter is inspected
    **Then** the overlay reads the controller's maintained state, active run identity, deterministic seed, participant registry, completion contributors, scoped-object counts, pending transaction, rejection summaries, and terminal results
    **And** it does not scan the scene tree, recompute completion, query participant health independently, or keep strong references to prior-run nodes
    **And** hidden diagnostics stop formatting or refreshing encounter data
    **And** retained histories and rejection counts remain bounded and are unavailable or disabled in release behavior.

25. **Make the encounter manually reproducible**

    **Given** the named run-scoped encounter fixture is launched from its documented start state
    **When** another developer follows its manual procedure
    **Then** they activate the encounter, observe exactly two ready enemies, fight and kill one without completing the encounter, defeat the second, and observe one completion result
    **And** they repeat after resetting during activation, ordinary combat, an enemy windup or active attack, after one enemy dies, and after completion
    **And** they exercise duplicate activation and reset, the invalid-participant alternate profile, and one recorded stale callback or spawn attempt
    **And** every fresh attempt contains two restored enemies and no attack, projectile, telegraph, hazard, link, audio, participant state, completion result, or callback from the prior run
    **And** retained evidence separates objective activation, registry, combat, completion, rejection, reset, and cleanup results from subjective encounter-flow or cue observations.

26. **Verify the encounter contracts automatically**

    **Given** the permanent encounter-lifecycle suite and focused real-Jolt fixture run are available
    **When** they exercise definition validation, unique run allocation, transactional root and participant creation, invalid placement, duplicate registration, activation publication, scoped spawning, stale-run rejection, ordered participant death, unexplained participant loss, completion uniqueness, source-independent child objects, failure rollback, reset at every phase, randomized callback order, and repeated attempts
    **Then** every activation reaches one typed success or failure, every accepted run owns one runtime root, every participant appears once in its registry, and completion occurs no more than once
    **And** no partial root, stale participant, retained signal, escaped transient, duplicate terminal fact, or late gameplay effect survives invalidation
    **And** shared encounter and participant definitions retain their original fingerprints
    **And** focused scene evidence confirms the same contracts under real collision, navigation, combat, and scene-tree behavior.

27. **Preserve real-time behavior at both physics rates**

    **Given** equivalent encounter attempts run at shipping 60 Hz and diagnostic 120 Hz
    **When** activation, enemy combat, participant death, completion, failure, and reset occur
    **Then** event-driven encounter state produces equivalent authoritative transitions and terminal results
    **And** participant abilities and transient effects retain their previously documented real-time timing within tolerance
    **And** no run is completed, failed, or reset differently because more physics callbacks occurred
    **And** rate-sensitive divergence blocks this story's gate.

28. **Keep ownership and signal boundaries narrow**

    **Given** the implementation is reviewed against the architecture
    **When** commands, queries, and emitted facts are traced
    **Then** commands use direct typed methods, queries use typed read-only snapshots, and signals report only committed past-tense facts within the smallest required scope
    **And** entity coordinators report participant facts to `EncounterController`, while the encounter exposes completion and reset facts for `LevelController`
    **And** UI, audio, AI, participants, fixture controls, and diagnostic presentation cannot commit encounter state
    **And** the story introduces no competing encounter manager, global signal bus, arbitrary reflection, or mutable global registry.

29. **Keep the story bounded to one encounter lifecycle**

    **Given** Story 7.2 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it contains one reusable encounter definition and controller boundary, run context, replaceable runtime root, scoped spawning, two-participant fixture, completion rule, reset transaction, primitive presentation, diagnostics, and focused verification
    **And** it has not implemented waves, required-versus-optional level sequencing, checkpoints, rewards, objectives, production HUD, level loading, pause or settings, production audio integration, selected Last Garden enemies, boss behavior, or final encounter content
    **And** those concerns remain assigned to later Epic 7 and Epic 8 stories.
