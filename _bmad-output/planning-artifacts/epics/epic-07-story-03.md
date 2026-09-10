---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 3
---

# Story 7.3: Host One Replaceable Level Session

As a player,
I want the application to enter, replace, and leave a complete level session cleanly,
So that level transitions never leave stale players, encounters, UI state, or gameplay effects behind.

**Acceptance Criteria:**

1. **Declare the focused level-session outcome**

   **Given** the replaceable-level-host fixture is registered for Epic 7 validation
   **When** its definition and procedure are inspected
   **Then** its outcome is a persistent application shell that can host resident test Level A, replace it with resident test Level B, return to a fresh Level A, and leave gameplay for a safe no-level state
   **And** application ownership, level-session identity, initialization, activation, replacement, teardown, failure behavior, UI binding, diagnostics, manual procedure, and evidence requirements are explicit
   **And** both test levels use primitive authored content and existing gameplay contracts
   **And** asynchronous resource loading, catalog lookup, production level progression, checkpoints, rewards, and menus remain outside this story.

2. **Compose the persistent application shell**

   **Given** the application-host scene is inspected
   **When** its long-lived nodes are resolved
   **Then** it contains one `AppRoot` with a `GameFlowController`, `LevelHost`, persistent `UIRoot`, and only the narrow application services already required by the architecture
   **And** `UIRoot` retains the Story 7.1 system-screen, gameplay-HUD-host, pause, transition, and debug layer boundaries
   **And** application-owned nodes remain outside every replaceable `LevelRoot`
   **And** the shell is composition-oriented and does not make `AppRoot` a general service locator.

3. **Define the replaceable level structure**

   **Given** either resident test level scene is inspected
   **When** its public structure is validated
   **Then** its root implements the approved `LevelRoot` contract and contains static world geometry, navigation, one level-owned player, encounter containers, level audio ownership, level presentation, and one `LevelController`
   **And** Story 7.2 encounter controllers and their replaceable runtime roots remain descendants of the level rather than the persistent application shell
   **And** private descendants are initialized internally through typed context rather than being addressed by external node paths
   **And** no test level becomes an autoload or persists after its session ends.

4. **Use two deliberately small resident test levels**

   **Given** the level-host fixture is opened
   **When** its candidate scenes are reviewed
   **Then** Level A is a newly authored primitive traversal room containing the Story 7.2 encounter fixture
   **And** Level B is a newly authored primitive traversal-only room with a visibly distinct layout and start transform
   **And** both scenes and their required dependencies are already resident before the fixture requests installation
   **And** neither test scene depends on preserving or migrating the existing tutorial level.

5. **Define a typed level-session context**

   **Given** a candidate `LevelRoot` is prepared
   **When** the host creates its initialization context
   **Then** the context carries stable application-session, level, level-session, definition, player-session, input-source, UI-binding, diagnostics, and current configuration identities or references required by the level
   **And** it supplies only narrow typed interfaces needed for initialization, presentation, and application requests
   **And** encounter runs created beneath the level inherit the applicable level-session identity while retaining distinct encounter-run identities
   **And** the context does not expose application internals as mutable global state.

6. **Allocate a fresh level-session identity**

   **Given** a valid candidate level is accepted for preparation
   **When** its installation transaction begins
   **Then** `LevelHost` allocates one new level-session identity that is never reused by another installation in the same application session
   **And** the identity is supplied before level-owned gameplay objects initialize
   **And** all level-scoped delayed work, presentation sources, player state, encounters, and application requests carry or can be validated against it
   **And** preparing a candidate does not make that identity current until installation commits.

7. **Accept installation through one typed command**

   **Given** the application shell is ready
   **When** `GameFlowController` requests installation of an already-resident level scene through `LevelHost`
   **Then** the request declares candidate scene identity, expected level ID, application-session identity, request identity, and replacement intent
   **And** `LevelHost` validates its current phase and request freshness before beginning one transaction
   **And** UI, level scenes, encounters, players, fixtures, or diagnostic presentation cannot attach a `LevelRoot` or publish a level session directly
   **And** duplicate, stale, busy, null, or malformed requests return typed results without changing the current level.

8. **Validate the candidate root before initialization**

   **Given** the resident candidate scene is instantiated in a non-active preparation state
   **When** `LevelHost` validates it
   **Then** the instance has exactly one supported `LevelRoot`, a matching stable level ID, one `LevelController`, one player boundary, valid required containers, and compatible initialization and teardown contracts
   **And** its required references, definitions, navigation data, presentation context provider, and resident gameplay dependencies pass content validation
   **And** a wrong root type, duplicate required owner, missing reference, incompatible version, or mismatched level ID fails preparation
   **And** invalid instances are released without entering the active scene hierarchy.

9. **Initialize the candidate while it remains inactive**

   **Given** the candidate root and level-session context are valid
   **When** preparation continues
   **Then** the candidate configures its `LevelController`, player, encounters, level audio owner, presentation sources, and internal references without accepting gameplay input or advancing simulation
   **And** internal initialization occurs through typed public methods and owner-local composition
   **And** no AI, encounter, ability, hazard, objective, reward, checkpoint, or level timer becomes active during preparation
   **And** initialization failure returns one typed result and tears down the candidate exactly once.

10. **Validate readiness before publishing the level**

    **Given** inactive initialization has completed
    **When** the candidate reports readiness
    **Then** `LevelHost` verifies its level identity, session identity, player readiness, required subsystem readiness, initial transform, gameplay-HUD context compatibility, and absence of partially active encounters or transients
    **And** the candidate exposes one immutable readiness result
    **And** a required failure prevents installation rather than activating a degraded gameplay level
    **And** optional presentation can use an approved fallback only when gameplay readiness remains intact.

11. **Commit one active level atomically**

    **Given** a candidate level is fully ready and no replacement invalidation has superseded the request
    **When** `LevelHost` commits installation
    **Then** the candidate becomes the one active child of `LevelHost` under its allocated level-session identity
    **And** `GameFlowController` publishes one committed level-session-started fact
    **And** gameplay input, player simulation, level systems, and eligible encounter activation become available only after that boundary
    **And** observers never see the candidate as active before its player and required owners are ready.

12. **Permit only one active `LevelRoot`**

    **Given** a level session is active or a replacement is being prepared
    **When** `LevelHost` ownership is inspected
    **Then** exactly one installed `LevelRoot` is authoritative at a time
    **And** a prepared replacement remains inactive and cannot receive current gameplay work
    **And** an old level is invalidated before a prepared replacement is published as current
    **And** there is no frame in which two levels can both accept player input, encounter requests, damage, objectives, UI updates, or audio as current.

13. **Recreate the player for each level**

    **Given** Level A is replaced by Level B or a fresh Level A
    **When** the new session commits
    **Then** the new level owns a newly created player initialized from the declared start profile and transform
    **And** the former player cannot be reparented, revived, or scrubbed for reuse
    **And** transform, velocity, health, grapple, locomotion, attacks, contacts, camera binding, and input state begin from the new level's declared baseline
    **And** only explicitly approved application-session preferences remain outside the replaceable player node.

14. **Keep encounter runs subordinate to the level session**

    **Given** Level A activates its Story 7.2 encounter
    **When** the encounter creates participants and transient gameplay
    **Then** every encounter run references the current Level A session identity and remains inside Level A's lifetime
    **And** replacing or ending Level A invalidates its active encounter run before removing the level
    **And** an encounter reset replaces only that encounter's runtime root while the Level A session remains current
    **And** an encounter cannot retain Level A or its player after the containing level session ends.

15. **Keep `UIRoot` persistent across replacement**

    **Given** Level A is active and `UIRoot` is bound to its `GameplayHudContext`
    **When** Level B replaces it
    **Then** the same persistent `UIRoot` instance survives the transition
    **And** it disconnects every Level A presentation source before accepting Level B's context
    **And** the gameplay HUD host displays the Story 7.1 neutral or transition state between valid contexts
    **And** late health, grapple, ability, encounter, prompt, reward, or checkpoint facts from Level A cannot alter Level B's presentation.

16. **Keep application and level commands directional**

    **Given** the active level needs to request restart, replacement, exit, or another application-owned transition
    **When** it communicates upward
    **Then** it emits or submits a narrow typed request containing its current level-session identity and semantic reason
    **And** `GameFlowController` decides whether and how the application changes state
    **And** the level cannot free itself, attach its successor, navigate system UI directly, or replace application services
    **And** stale requests from an invalidated level session are rejected without affecting the current level.

17. **Prepare replacement before invalidating a healthy current level**

    **Given** Level A is healthy and Level B is requested as its replacement
    **When** Level B is instantiated, validated, initialized, and checked for readiness
    **Then** Level A remains the current level until the candidate is ready to commit
    **And** the prepared Level B cannot run gameplay while Level A remains current
    **And** failure during Level B preparation releases the candidate and leaves Level A valid
    **And** only the final replacement transaction invalidates Level A.

18. **Replace the current level through ordered teardown**

    **Given** prepared Level B is ready and replacement commits
    **When** `LevelHost` transitions away from Level A
    **Then** it marks Level A's session invalid and stops accepting its new application, UI, encounter, spawn, audio, and delayed gameplay work
    **And** Level A cancels or terminates active encounters and other level-scoped operations through their normal owners
    **And** `UIRoot` and persistent application services disconnect from Level A before its root is freed at a safe scene-tree boundary
    **And** Level B becomes current only after the old authority has been revoked.

19. **Remove all level-scoped state on teardown**

    **Given** an ending level contains a player, active or completed encounters, participants, projectiles, telegraphs, hazards, obstacles, links, effects, presentation, navigation references, timers, or level audio
    **When** its session is torn down
    **Then** every level-owned object and signal connection is removed with the old `LevelRoot` or explicitly terminated by its owner
    **And** invalidated late callbacks, damage, spawns, audio, and presentation updates are rejected
    **And** application settings, `UIRoot`, `GameFlowController`, and `LevelHost` remain valid
    **And** no live reference prevents the old level, player, or encounter runtime from being released.

20. **Recover safely from candidate failure**

    **Given** installation or replacement fails during instantiation, validation, initialization, readiness, or commit preparation
    **When** the failure result is handled
    **Then** the candidate session identity is invalidated and all candidate state is released exactly once
    **And** an existing healthy current level remains active when replacement has not committed
    **And** an initial installation failure leaves the application in its defined safe no-level state
    **And** the failure exposes a player-safe summary plus bounded diagnostics without retrying indefinitely or publishing a partial level.

21. **Support a deliberate safe no-level state**

    **Given** no level is installed or the current level is deliberately left
    **When** the application enters its safe no-level state
    **Then** gameplay input, player simulation, encounters, damage, level audio, and gameplay HUD sources are inactive
    **And** `UIRoot` shows the approved neutral system state while retaining the ability to receive a later valid application request
    **And** no old camera, input owner, player, objective, prompt, or transient remains current
    **And** detailed main-menu and loading-screen interaction remains assigned to later stories.

22. **Reject stale level-session work**

    **Given** a callback, signal, UI update, audio request, encounter fact, application request, spawn, damage delivery, or deferred operation carries an invalid level-session identity
    **When** it reaches a current-session boundary
    **Then** it is rejected or ignored with a bounded typed reason
    **And** it cannot affect the new player, level, encounters, HUD, audio, application state, or future transitions
    **And** expected stale rejection does not create unbounded logging
    **And** evidence retains stable identities without retaining the destroyed source node.

23. **Expose read-only application and level-session state**

    **Given** presentation or diagnostics need to describe the current application state
    **When** they request a snapshot
    **Then** `GameFlowController` and `LevelHost` expose typed read-only state for no-level, preparing, installing, active, replacing, leaving, and failed conditions
    **And** the snapshot includes only stable request, application-session, level, level-session, phase, current-context availability, and terminal-result data
    **And** presentation cannot initiate, commit, cancel, or complete a transition through the snapshot
    **And** continuous polling of private scene-tree state is unnecessary.

24. **Provide bounded level-session diagnostics**

    **Given** development diagnostics are enabled
    **When** application and level ownership are inspected
    **Then** the overlay reads maintained state for the active and prepared level identities, level-session IDs, current phase, player identity, HUD-context binding, encounter run identities, scoped-object counts, pending transaction, stale rejections, and last terminal result
    **And** it does not scan the scene tree, recalculate readiness, keep old levels alive, or become required for the transition
    **And** hidden diagnostics stop formatting and refreshing this data
    **And** histories and counters remain bounded and unavailable or disabled in release behavior.

25. **Make replacement manually reproducible**

    **Given** the named replaceable-level-host fixture begins in the safe no-level state
    **When** another developer follows its documented procedure
    **Then** they install Level A, traverse with its fresh player, activate its two-enemy encounter, and create at least one encounter-scoped transient
    **And** they replace Level A with Level B while the encounter is active, confirm Level B has its own fresh player and no Level A state, then replace Level B with a fresh Level A
    **And** they exercise deliberate leave-to-safe-state, duplicate requests, stale Level A updates, a failing candidate profile while Level B remains healthy, and an initial failure from the no-level state
    **And** the persistent `UIRoot` survives every successful transition while binding only to the current context
    **And** retained evidence separates objective ownership, identity, initialization, replacement, teardown, failure, stale-rejection, and repeatability results from subjective transition and primitive-presentation observations.

26. **Verify session ownership automatically**

    **Given** the permanent level-session suite and focused scene fixture are available
    **When** they exercise shell composition, candidate type validation, unique session allocation, inactive initialization, readiness failure, atomic installation, one-level ownership, player recreation, encounter subordination, HUD-context binding, healthy-current retention on candidate failure, ordered replacement, explicit leave, stale work, duplicate requests, randomized callback order, and repeated A-to-B-to-A transitions
    **Then** each request reaches one typed terminal result, each successful session owns one complete level root, and exactly one level is current
    **And** no partial candidate, second input owner, stale player, escaped encounter object, retained signal, duplicate transition, or late current-state mutation survives
    **And** immutable scene and gameplay definitions retain their original fingerprints
    **And** focused scene evidence confirms real player, encounter, UI-binding, and scene-tree teardown behavior.

27. **Preserve equivalent event behavior at both physics rates**

    **Given** equivalent host-fixture transitions run at shipping 60 Hz and diagnostic 120 Hz
    **When** levels install, encounters run, candidates fail, replacements commit, and sessions end
    **Then** event-driven application and level-session state reaches equivalent authoritative transitions and terminal results
    **And** player, encounter, and transient gameplay retains its previously documented real-time behavior within tolerance
    **And** changing physics callback frequency cannot create a second current level, duplicate binding, missed teardown, or stale accepted request
    **And** any rate-sensitive divergence blocks the story.

28. **Retain the existing launch path until loading is proven**

    **Given** the persistent application shell and resident replacement fixture pass Story 7.3
    **When** project startup configuration is inspected
    **Then** the current main launch scene remains unchanged
    **And** the new `AppRoot` can be launched directly for focused verification without replacing the established runnable path
    **And** no existing scene or UID is removed merely because the replacement contract now exists
    **And** switching the project's main scene remains assigned to Story 7.4 after asynchronous loading and failure recovery pass.

29. **Keep the story bounded to level-session ownership**

    **Given** Story 7.3 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it contains the persistent application shell, typed level-session context, one-level host, two resident primitive test levels, atomic installation and replacement, teardown, safe no-level state, UI-context binding, diagnostics, and focused verification
    **And** it has not implemented the level catalog, asynchronous dependency loading, production startup switch, encounter sequencing, objectives, checkpoints, rewards, production HUD, pause or settings, input remapping, production audio, selected Last Garden content, boss behavior, or final levels
    **And** those concerns remain assigned to later Epic 7 and Epic 8 stories.
