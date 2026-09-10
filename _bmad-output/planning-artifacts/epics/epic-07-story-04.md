---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 4
---

# Story 7.4: Load and Replace Authored Levels Safely

As a player,
I want levels to load and transition through a clear, recoverable boundary,
So that I never enter a partially loaded level or lose a healthy session because the next level failed.

**Acceptance Criteria:**

1. **Declare the controlled-loading outcome**

   **Given** the level-loading fixture is registered for Epic 7 validation
   **When** its definition and procedure are inspected
   **Then** its outcome is to resolve a stable level ID, load its declared dependencies asynchronously, prepare it through Story 7.3's level-session boundary, install it only when ready, and recover safely from failure or cancellation
   **And** initial loading, active-level replacement, progress presentation, failure handling, cancellation, stale completion, startup migration, diagnostics, manual procedure, and evidence requirements are explicit
   **And** resident test Levels A and B remain the focused content
   **And** encounter sequencing, checkpoints, rewards, production HUD, pause, settings, and production level content remain outside this story.

2. **Author one immutable level catalog**

   **Given** the application needs to resolve a level without embedding scene paths in flow code
   **When** the `LevelCatalog` is inspected
   **Then** it maps each supported stable level ID to exactly one immutable `LevelManifest`
   **And** duplicate IDs, empty IDs, null manifests, incompatible manifest versions, and missing referenced resources fail content validation
   **And** lookup returns a typed success or rejection without loading or instantiating the level
   **And** runtime code treats the catalog and manifests as read-only.

3. **Define each level manifest completely**

   **Given** a Level A or Level B manifest is inspected
   **When** its authored fields are resolved
   **Then** it declares a stable level ID and version, `LevelRoot` scene, required dependency groups, optional dependency groups with fallback policy, loading-screen presentation profile, expected root contract version, validation metadata, and configured start profile
   **And** every combat-critical scene, definition, animation placeholder, audio fallback, query profile, and required support resource needed before encounter activation is included in the validated dependency closure
   **And** manifest metadata does not duplicate mutable level, player, encounter, objective, reward, or checkpoint state
   **And** tuning and scene references remain authored resources rather than literals in `GameFlowController` or `LoadingCoordinator`.

4. **Derive or validate dependency information from real references**

   **Given** a level manifest declares dependency groups
   **When** content validation examines the referenced level scene and resources
   **Then** dependency information is generated from or checked against ordinary Godot resource references
   **And** a required referenced dependency omitted from the declared loading boundary is reported before release-like play
   **And** a stale manually maintained list cannot silently claim that a level is ready
   **And** generated dependency metadata remains deterministic and reviewable without mutating the source resources.

5. **Keep the loading coordinator narrowly scoped**

   **Given** the application shell contains `LoadingCoordinator`
   **When** its responsibilities are inspected
   **Then** it resolves manifests, issues threaded resource requests, observes loader status, retains bounded progress and error state, and returns loaded resident resources through typed results
   **And** `GameFlowController` owns application-flow decisions and `LevelHost` owns candidate installation
   **And** `LoadingCoordinator` cannot activate gameplay, attach a level, bind the HUD, start an encounter, restore a player, grant a reward, or choose progression
   **And** it is not exposed as a general asset service or global resource cache.

6. **Submit loading through one typed request**

   **Given** the application is in a state that permits initial load or replacement
   **When** `GameFlowController` submits a level-load request
   **Then** the request carries stable request, application-session, requested-level, current-level-session where applicable, transition-purpose, and presentation-profile identities
   **And** the coordinator validates request freshness, catalog membership, manifest validity, current loading state, and supported transition purpose
   **And** UI, levels, encounters, objectives, fixtures, or diagnostics cannot begin loading or install resources directly
   **And** duplicate, stale, unknown-level, busy, and malformed requests return typed results without disturbing a healthy current level.

7. **Use Godot's threaded loading path**

   **Given** a valid manifest and unloaded required resources
   **When** loading begins
   **Then** `LoadingCoordinator` requests them through Godot's threaded `ResourceLoader` path
   **And** loading status is polled without blocking the main thread
   **And** no first-time synchronous `load()` or equivalent blocking resource acquisition occurs during combat or a level transition
   **And** only small, genuinely application-resident resources such as the shell, catalog, and safe loading presentation may be preloaded unconditionally.

8. **Keep loading progress presentation-only**

   **Given** a threaded request reports progress or a phase change
   **When** the loading screen observes it
   **Then** progress is normalized, bounded, and associated with the current request identity
   **And** the presentation distinguishes resolving, loading dependencies, preparing the level, installing, completed, cancelled, and failed states
   **And** missing granular progress uses an explicit indeterminate treatment rather than fabricated percentages
   **And** progress animation, minimum display duration, or transition effects cannot decide resource readiness or delay gameplay authority after the owning flow commits.

9. **Preserve the current healthy level during replacement loading**

   **Given** Level A is healthy and Level B is requested
   **When** Level B's resources are resolving or loading
   **Then** Level A remains the one current `LevelRoot` and retains its existing level-session identity
   **And** Level B has no player, encounter, gameplay process, HUD context, or level-session authority merely because its resources are loading
   **And** the loading or transition presentation follows the approved application policy without making Level B partially playable
   **And** failure or cancellation before candidate installation leaves Level A intact.

10. **Prevent loaded resources from becoming active automatically**

    **Given** every required resource reaches the loader's successful ready state
    **When** the coordinator retrieves the loaded level scene and dependency result
    **Then** it returns one typed load success to `GameFlowController`
    **And** it does not instantiate, attach, initialize, or activate the scene by itself
    **And** a completed load from a stale or cancelled request is released or retained only under the declared bounded resident-resource policy and cannot continue the old transition
    **And** resource readiness alone never counts as a started level session.

11. **Instantiate only after loading completes**

    **Given** `GameFlowController` accepts a current load success
    **When** it requests candidate preparation
    **Then** the loaded level scene is instantiated on the main thread only after all required dependencies report ready
    **And** the instance is passed through Story 7.3's type validation, inactive initialization, readiness, installation, and replacement transaction
    **And** the expected level ID and root-contract version must match the manifest
    **And** a wrong root, instantiation error, initialization failure, or readiness failure returns through the same controlled transition without partial activation.

12. **Publish readiness only when critical content is resident**

    **Given** a loaded candidate reports level readiness
    **When** `GameFlowController` evaluates whether it may commit installation
    **Then** every manifest-required gameplay and combat dependency is resident
    **And** Story 7.2 encounters can validate their own resident participant and ability dependencies without initiating first-use loads
    **And** required player, navigation, query, presentation-fallback, and level-controller resources are valid
    **And** optional content may degrade only through its manifest-declared fallback and cannot conceal a missing gameplay-critical dependency.

13. **Commit replacement through the existing level host**

    **Given** the loaded Level B candidate passes Story 7.3 readiness
    **When** replacement commits
    **Then** `LevelHost` invalidates and tears down Level A through its approved transaction before publishing Level B as current
    **And** Level B receives a fresh level-session and player rather than inheriting Level A's runtime state
    **And** persistent `UIRoot` disconnects from Level A and binds once to Level B's `GameplayHudContext`
    **And** the load request and level-install request each reach one traceable terminal result without becoming competing owners.

14. **Handle unknown level IDs safely**

    **Given** a request contains a level ID absent from the catalog
    **When** lookup occurs
    **Then** loading does not begin
    **And** the result identifies the unknown stable ID without exposing an arbitrary filesystem path
    **And** an existing current level remains current
    **And** an initial request returns the application to the safe no-level failure state.

15. **Handle required dependency failure safely**

    **Given** a required scene or dependency is missing, corrupt, incompatible, or fails threaded loading
    **When** loader status becomes terminal
    **Then** the request commits one typed failure identifying the manifest, dependency group, resource identity, loader status, and transition purpose
    **And** no candidate `LevelRoot` is instantiated from incomplete resources
    **And** an existing healthy level remains active when replacement has not committed
    **And** an initial load displays the safe failure state with bounded retry and return options.

16. **Apply optional fallback only when declared**

    **Given** an optional presentation dependency fails
    **When** its manifest policy is evaluated
    **Then** the level may continue only if a named resident fallback satisfies the same presentation boundary without changing gameplay
    **And** the degradation is recorded and warned once
    **And** undeclared fallback, silent omission, or gameplay-critical substitution is prohibited
    **And** retrying the level cannot accumulate duplicate warnings, placeholder instances, or failed-resource state.

17. **Support explicit cancellation**

    **Given** a level request is resolving, loading, preparing, or waiting for installation
    **When** `GameFlowController` submits an authorized cancellation with the current request identity
    **Then** the transition commits one cancelled result and stops accepting its future progress or completion as current
    **And** prepared candidate instances and candidate session state are released exactly once
    **And** a healthy current level remains intact, while an initial load returns to the safe no-level state
    **And** cancellation does not free shared resident resources still owned by the application or another current request.

18. **Reject stale asynchronous completions**

    **Given** an old load request finishes after cancellation, replacement, application-session invalidation, or a newer authorized request
    **When** its progress or completion callback arrives
    **Then** request and application-session identities fail currentness validation
    **And** the callback cannot instantiate a level, replace the current session, alter loading UI, emit current success, or overwrite the newer result
    **And** any occurrence-local data is released idempotently
    **And** expected stale callbacks produce bounded diagnostics rather than unbounded error output.

19. **Resolve simultaneous and repeated requests deterministically**

    **Given** initial, replacement, retry, duplicate, or cancel requests arrive near the same application update boundary
    **When** `GameFlowController` orders them
    **Then** one documented owner-controlled precedence policy determines the accepted operation
    **And** callback arrival, UI signal order, resource completion order, or scene-tree order cannot change that result
    **And** rejected requests receive typed reasons and cannot inherit another request's resources or progress
    **And** at most one load transition may be current.

20. **Provide a safe initial-load failure screen**

    **Given** no healthy level exists and initial loading fails or is cancelled
    **When** `GameFlowController` returns to the safe no-level state
    **Then** `SystemScreenLayer` presents a concise player-facing failure state using resident UI resources
    **And** it offers only the approved retry of the same stable level ID and return-to-safe-shell requests
    **And** technical dependency paths, stack traces, and loader internals remain in bounded diagnostics rather than player-facing text
    **And** the failure screen cannot directly mutate loader state or attach a level.

21. **Report replacement failure without destroying current play**

    **Given** Level A remains healthy while a Level B replacement load fails or is cancelled
    **When** the terminal result is presented
    **Then** Level A remains current with its original player, level-session, encounters, HUD context, and level-owned state
    **And** replacement presentation clears or reports the failure according to the approved system-layer behavior
    **And** Level B leaves no candidate root, player, encounter, UI binding, audio, or delayed operation
    **And** retry requires a new typed request rather than continuing a terminal operation.

22. **Expose read-only loading state**

    **Given** system UI or diagnostics needs current loading information
    **When** it requests a snapshot
    **Then** `LoadingCoordinator` exposes stable request, manifest, level ID, phase, progress kind and value, dependency status summary, transition purpose, cancellation state, and terminal result
    **And** it exposes scalar data and stable identities rather than live resource or candidate-node authority
    **And** presentation cannot poll ResourceLoader independently or calculate another readiness result
    **And** hidden presentation does not cause additional loader work.

23. **Keep loading evidence and diagnostics bounded**

    **Given** development diagnostics are enabled
    **When** a load transition is inspected
    **Then** diagnostics expose catalog and manifest versions, request identity, dependency groups, threaded statuses, progress, timings, current and candidate session identities, fallback use, cancellation, stale-callback rejection, install result, and terminal reason
    **And** maintained histories, warnings, and failed-dependency entries have explicit bounds
    **And** diagnostics do not retain loaded levels, resources, or callbacks beyond their intended ownership
    **And** the diagnostic overlay is unavailable or disabled in release behavior and does not control loading.

24. **Preserve Godot UIDs and references**

    **Given** the new catalog, manifests, application shell, and level scenes are introduced
    **When** resources or scenes move into the target project hierarchy
    **Then** existing Godot UIDs and valid references are preserved or migrated deliberately and verified before old paths are retired
    **And** one domain or scene boundary is migrated at a time
    **And** the current project remains runnable throughout the change
    **And** no bulk path rewrite, duplicate competing resource type, or all-at-once tree migration is required.

25. **Switch startup only after the new path passes**

    **Given** Story 7.3 and all Story 7.4 focused loading, replacement, cancellation, and failure checks pass
    **When** the project startup configuration is changed
    **Then** `project.godot` names `game/app/app_root.tscn` as the normal main scene
    **And** `AppRoot` boots into resident system UI and requests the configured validation-level ID through the catalog and loading coordinator
    **And** startup does not instantiate the level through a hidden direct scene reference or bypass the loading boundary
    **And** the previous launch scene is not deleted merely by this startup change.

26. **Keep startup playable without the old tutorial**

    **Given** the current tutorial level is disposable
    **When** the new main scene launches normally
    **Then** the configured validation-level manifest may reference the newly authored primitive Level A rather than the old tutorial
    **And** the player can reach a valid controllable level session after the loading transition
    **And** underlying traversal, combat, encounter, input, and camera behavior remains available through their established contracts
    **And** preserving the old tutorial's layout, triggers, node paths, prompts, or presentation is not a completion requirement.

27. **Prevent synchronous first-use loading during combat**

    **Given** the loaded validation level and Story 7.2 encounter are active
    **When** the player traverses, enemies activate abilities, projectiles or effects spawn, HUD sources update, and audio fallbacks are requested
    **Then** no combat-critical path performs an unplanned first-time synchronous resource load
    **And** every required instance is created from resources made resident at the level or encounter boundary
    **And** a missing required resource returns through its responsible typed failure path rather than freezing gameplay or using an invalid partial object
    **And** instrumentation or focused audit evidence identifies prohibited synchronous calls.

28. **Make the loading flow manually reproducible**

    **Given** another developer launches the project through its normal main scene after the startup switch
    **When** they follow the documented procedure
    **Then** they observe resident loading UI, load Level A by stable ID, receive a fresh controllable player, activate its encounter, and verify required content is resident
    **And** they request Level B while Level A remains healthy, observe bounded progress, and verify atomic replacement followed by a fresh A-to-B-to-A sequence
    **And** they exercise an unknown ID, missing required dependency, invalid root, optional fallback, cancellation, retry, duplicate request, and recorded stale completion
    **And** initial failures return to safe UI while replacement failures preserve the current level
    **And** retained evidence separates objective catalog, loading, readiness, installation, startup, cancellation, failure, fallback, stale-rejection, and cleanup results from subjective loading-screen or transition observations.

29. **Verify the loading pipeline automatically**

    **Given** deterministic loader-adapter tests, real threaded-loading integration tests, and the focused application fixture are available
    **When** they exercise catalog validation, dependency-closure validation, typed lookup, threaded status transitions, progress normalization, required and optional failure, cancellation at every phase, stale completion, simultaneous requests, candidate instantiation, Story 7.3 installation, healthy-current preservation, initial safe failure, startup boot, repeated replacement, and teardown
    **Then** every request reaches one typed terminal result and no incomplete level becomes active
    **And** exactly one load operation and one level session remain current where applicable
    **And** no partial candidate, blocking combat load, stale callback, duplicated UI result, escaped dependency state, or retained old level survives
    **And** immutable catalogs, manifests, scene resources, and gameplay definitions retain their original fingerprints.

30. **Preserve equivalent behavior across physics configurations**

    **Given** equivalent application-loading and replacement scenarios run with shipping 60 Hz and diagnostic 120 Hz gameplay physics
    **When** resources complete at the same controlled loader boundaries
    **Then** catalog, loader, cancellation, installation, replacement, failure, and terminal results remain equivalent
    **And** changing physics callback frequency cannot make a partially loaded level active, accept a stale completion, duplicate a transition, or alter dependency readiness
    **And** gameplay after installation retains its previously documented real-time equivalence
    **And** a configuration-dependent flow failure blocks the story.

31. **Keep the story bounded to controlled level loading**

    **Given** Story 7.4 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it contains the immutable catalog and manifests, dependency validation, threaded loading coordinator, resident loading and failure presentation, cancellation, stale-result rejection, integration with Story 7.3, startup migration, diagnostics, and focused verification
    **And** it has not implemented open-world streaming, speculative pooling, background combat streaming, downloadable content, save-game loading, required-versus-optional encounter sequencing, objectives, checkpoints, rewards, production HUD, pause, settings, input remapping, selected Last Garden content, boss behavior, or final levels
    **And** those concerns remain assigned to later stories.
