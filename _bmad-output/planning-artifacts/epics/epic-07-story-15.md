---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.15'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 15
---

# Story 7.15: Inspect and Control Development Sessions Safely

As a game developer,
I want bounded read-only diagnostics and a finite set of owner-routed development commands,
So that I can reproduce, inspect, and capture traversal, combat, AI, encounter, audio, and performance behavior without creating another gameplay authority.

**Acceptance Criteria:**

1. **Declare the focused development-tooling outcome**

    **Given** Epic 1 through Story 7.14 systems expose their approved diagnostic state and commands
    **When** the integrated development tooling is inspected
    **Then** it presents bounded read-only motor, contact, grapple, ability, encounter-lifetime, selected-AI, audio, and performance information
    **And** it can request only the approved encounter reset, checkpoint reload, active-level reload, invulnerability, AI pause, diagnostic selection, and local capture operations through their normal owners
    **And** provider contracts, binding, input context, command eligibility, capture format, bounds, release exclusion, manual procedure, and automated evidence are explicit
    **And** arbitrary scripting, a command console, live gameplay tuning, remote telemetry, replay infrastructure, cheats in release builds, and a universal event bus remain outside this story.

2. **Keep diagnostic state owner-local**

    **Given** a gameplay or application system has information useful for inspection
    **When** it exposes diagnostics
    **Then** its normal owner maintains one narrow typed read-only snapshot or bounded fact stream
    **And** the diagnostic provider contains stable identities, immutable scalar or value data, current state, and already-computed results rather than mutable internal objects
    **And** the provider cannot be used to write private fields or invoke undeclared commands
    **And** disabling diagnostics does not remove or change the authoritative state being observed.

3. **Compose diagnostics beneath `DebugOverlayLayer`**

    **Given** a development build launches through persistent `UIRoot`
    **When** the integrated overlay is created
    **Then** `DebugOverlayLayer` owns its panels, navigation, selected-subject presentation, and command controls
    **And** it binds to a versioned diagnostic context supplied for the current application and level session
    **And** it is visually and structurally separate from player-facing HUD, pause, settings, loading, recovery, and main-menu layers
    **And** it does not become an autoload service locator or own gameplay providers.

4. **Bind and unbind one current diagnostic context**

    **Given** a level session activates, restarts, reloads, completes, or ends
    **When** diagnostic context changes
    **Then** the overlay validates application, level-session, provider-set, and context-version identities before binding
    **And** it disconnects every old provider before reading a fresh coherent snapshot
    **And** encounter-run and selected-subject changes rebind only the affected narrow providers
    **And** late data from old players, levels, runs, executions, audio scopes, or selections cannot appear as current.

5. **Expose motor resolution without resolving motion again**

    **Given** the current player motor has committed a physics step
    **When** the motor panel is visible
    **Then** it can display physics-step identity, base locomotion, sustained influences, impulses, constraints, redirections, caps, final resolved velocity, and the single final commit result
    **And** it labels semantic phases and source identities using maintained motor data
    **And** it does not call movement solvers, submit influences, assign velocity, or invoke `move_and_slide()`
    **And** hidden motor presentation stops formatting high-frequency values.

6. **Expose shared contact interpretation**

    **Given** the current player's authoritative `ContactFrame` is available
    **When** the contact panel or world drawing is enabled
    **Then** it can display physics step, ground and wall classifications, normals, contact points, support identity, and applicable rejection or tolerance facts
    **And** optional world drawing uses the maintained contact result
    **And** it does not perform another shape cast, raycast, floor test, or wall classification
    **And** drawing stops and releases retained values when hidden or unbound.

7. **Expose authoritative grapple targeting and attachment**

    **Given** grapple targeting or attachment state changes
    **When** the grapple panel is inspected
    **Then** it can show candidate identity, hit position and normal, range fraction, validity, rejection reason, query profile, attachment state, sampled anchor state, execution identity, and result physics step
    **And** diagnostic world drawing agrees with the same authoritative result consumed by Story 7.9 presentation
    **And** it cannot issue an alternate query, select another gameplay target, attach, release, or move the player
    **And** stale target or anchor identities are visibly rejected rather than retained.

8. **Expose ability and attack execution state**

    **Given** a player or selected enemy ability execution exists
    **When** the ability panel is visible
    **Then** it can show definition, execution, source, scope and run identities; current phase; elapsed and remaining seconds; spatial binding; committed terminal result; and applicable movement and impact context summaries
    **And** the diagnostic 2.0-second melee variant can display commit-time and impact-time velocity facts together
    **And** the panel does not advance phases, open hit windows, deliver damage, or invoke animation callbacks
    **And** completed history uses a bounded occurrence list.

9. **Expose encounter and level lifetime**

    **Given** an M3 level and encounter sequence is active
    **When** the lifetime panel is inspected
    **Then** it can show application and level-session identities, level-flow state, checkpoint snapshot version, reward-ledger summary, active encounter and run identities, participant counts, scoped transient counts, objective facts, pending transition, stale rejections, and last terminal results
    **And** counts come from owning registries and runtime roots rather than a repeated scene-tree scan
    **And** no panel can register a participant, complete an encounter, activate a checkpoint, grant a reward, or advance the objective
    **And** an ended scope disappears from current state while bounded historical identities remain value-only.

10. **Expose selected AI tactics without changing selection**

    **Given** a current enemy diagnostic subject is selected
    **When** the AI panel updates
    **Then** it can show encounter seed, decision occurrence, current intent, generated candidates, rejection reasons, utility inputs and scores, tie-breaking, hysteresis state, selected destination or target, replanning reason, and safe fallback
    **And** the panel consumes results already produced by the LimboAI policy and geometry-discovered positioning systems
    **And** it does not run utility scoring, generate candidates, write blackboard authority, or choose an action
    **And** candidate and history counts are explicitly bounded.

11. **Expose audio request and voice state**

    **Given** Story 7.10 audio requests and playback are active
    **When** the audio panel is visible
    **Then** it can show recent request identities, cues, semantic reasons, scopes, buses, spatial modes, concurrency groups, priorities, accepted or rejected voice results, fallbacks, and active scoped emitters
    **And** voice counts and history come from maintained audio state
    **And** the panel cannot replay, stop, reroute, reprioritize, or fabricate a cue
    **And** old run and level audio disappears when its scope ends.

12. **Expose bounded performance measurements**

    **Given** representative gameplay runs in a development build
    **When** the performance panel is enabled
    **Then** it can show render-frame, physics-step, navigation, physics-query, encounter-transient, audio-voice, and applicable memory or object-count measurements available through approved instrumentation
    **And** it records sample windows, units, collection state, build configuration, physics rate, resolution, and selected scenario identity
    **And** histories use fixed-capacity buffers and avoid per-frame allocation where practicable
    **And** the panel distinguishes instrumented development measurements from the representative release-like benchmark completed in Story 7.16.

13. **Use a low-priority explicit debug input context**

    **Given** a development build is running
    **When** the overlay or its command controls are toggled
    **Then** debug input remains below rebinding capture, system or pause UI, and gameplay in the approved context priority
    **And** shortcuts are a finite declared set with player-facing bindings kept separate from gameplay remapping
    **And** a consumed gameplay, menu, or rebinding event cannot also invoke a debug command
    **And** focus loss clears held debug input and cannot repeat the last command.

14. **Offer exactly the approved finite command set**

    **Given** the integrated development command menu is inspected
    **When** available commands are enumerated
    **Then** it contains Restart Current Encounter, Reload Active Checkpoint, Reload Active Level, Toggle Player Invulnerability, Toggle Current-Encounter AI Pause, Select Diagnostic Subject, and Capture Diagnostic Snapshot
    **And** every command declares eligibility, typed parameters, responsible owner, result type, and reset behavior
    **And** unavailable commands remain visible with a concise reason or are omitted according to one consistent policy
    **And** arbitrary command strings, code evaluation, property editing, spawning, teleporting, reward granting, objective completion, and gameplay tuning are not supported.

15. **Route reset and reload commands through existing owners**

    **Given** encounter restart, checkpoint reload, or active-level reload is requested from diagnostics
    **When** the command router validates it
    **Then** it forwards one typed request to the Story 7.7 encounter or checkpoint owner or Story 7.4 application loading owner
    **And** the same eligibility, invalidation, cleanup, player restoration, loading, failure, and terminal-result rules apply as for normal UI requests
    **And** diagnostics cannot skip confirmation or preparation boundaries where the underlying command requires them
    **And** duplicate or stale diagnostic requests cannot start a second recovery or reload transaction.

16. **Apply invulnerability through the health owner**

    **Given** a current player exists in a development session
    **When** Toggle Player Invulnerability is accepted
    **Then** the player health owner enables or disables one explicit debug-only damage policy and reports its current state
    **And** prevented damage returns a typed `DEBUG_INVULNERABLE` result while preserving source and impact evidence for inspection
    **And** the command does not change maximum health, movement, attacks, enemy targeting, checkpoints, rewards, or definitions
    **And** invulnerability defaults off and clears on level-session replacement or release-like runs.

17. **Pause AI through encounter and enemy owners**

    **Given** a current active encounter exists in a development session
    **When** Toggle Current-Encounter AI Pause is accepted
    **Then** `EncounterController` asks its participant coordinators to stop requesting new tactical actions and cancel current cancellable enemy actions with the declared debug reason
    **And** already detached projectiles, hazards, effects, and other committed deliveries continue or terminate only through their existing lifecycle policy
    **And** unpausing resumes each valid participant from a fresh owner-controlled tactical decision
    **And** the command cannot pause player simulation, rewrite LimboAI state directly, or affect another encounter run.

18. **Select diagnostic subjects without selecting gameplay targets**

    **Given** current player, encounter, and enemy providers are registered
    **When** Select Diagnostic Subject is used
    **Then** the overlay cycles or chooses among a stable bounded list of current provider identities
    **And** selection changes only which diagnostic snapshot is displayed
    **And** it cannot change player aim, grapple target, AI target memory, attack target, camera authority, or encounter participation
    **And** removal of the selected subject falls back predictably to the next valid subject or no selection.

19. **Capture one bounded local diagnostic artifact**

    **Given** diagnostics are enabled and a current context exists
    **When** Capture Diagnostic Snapshot is accepted
    **Then** it freezes a schema-versioned value-only capture containing current provider snapshots, bounded recent fact histories, command states, build and scenario metadata, stable identities, units, and capture reason
    **And** the artifact is written only to the approved local development capture location with a bounded size and deterministic naming policy
    **And** live nodes, unrestricted user input, arbitrary memory, final assets, and mutable Resources are not serialized
    **And** capture performs no automatic upload or remote analytics request.

20. **Support bounded automatic capture triggers**

    **Given** the approved development capture policy enables a trigger
    **When** player death, an invariant failure, a defined performance spike, a manual capture, or a test failure occurs
    **Then** at most one capture is accepted per trigger occurrence and cooldown or count bound
    **And** capture work uses maintained diagnostic buffers rather than replaying gameplay computation
    **And** file failure returns a typed local result without changing gameplay
    **And** automatic capture is disabled in release and representative performance runs unless the benchmark procedure explicitly enables low-overhead counters.

21. **Reject stale diagnostic data and commands**

    **Given** a provider update, command, result, selection, or capture completion belongs to an invalid application session, level session, encounter run, execution, or overlay occurrence
    **When** it reaches a current boundary
    **Then** it cannot change current presentation, invoke an owner, write a current capture, or restore an old selection
    **And** expected stale work returns a bounded typed reason
    **And** no historical record retains a destroyed node or keeps an old scope alive
    **And** repeated stale activity cannot grow logs or histories without bound.

22. **Remain absent or disabled in release behavior**

    **Given** a release or representative release-like configuration is built
    **When** diagnostics and commands are inspected
    **Then** debug overlays, verbose histories, world drawing, command inputs, invulnerability, AI pause, and local capture triggers are excluded or disabled according to the build policy
    **And** gameplay systems do not require a diagnostic provider consumer to function
    **And** disabled instrumentation avoids formatting, drawing, file output, and expensive history collection
    **And** attempting to invoke a development command cannot mutate release gameplay.

23. **Measure and bound diagnostic overhead**

    **Given** representative M3 activity runs with diagnostics hidden, visible, and fully disabled
    **When** instrumentation overhead is measured
    **Then** the evidence records frame and physics cost, allocations, retained history size, active drawings, provider counts, and capture cost under each state
    **And** hidden presentation stops avoidable work while owner snapshots remain no more expensive than their approved bounded policy
    **And** any material impact on representative release-like results is removed or explicitly isolated before Story 7.16
    **And** the overlay never performs duplicate gameplay queries merely to improve its display.

24. **Make integrated diagnostics manually reproducible**

    **Given** another developer follows the documented M3 diagnostic procedure
    **When** they inspect traversal, contact, grapple, player and enemy abilities, encounter lifetime, selected AI tactics, audio, and performance across required and optional routes
    **Then** each panel can be opened, understood, hidden, rebound to a new run, and captured without changing gameplay outcomes
    **And** every approved command demonstrates valid, invalid, duplicate, stale, and cleanup behavior through its normal owner
    **And** level reload, checkpoint reload, encounter restart, AI pause, invulnerability, subject removal, capture failure, and repeated complete sessions leave no stale provider or command authority
    **And** retained evidence separates objective values, identities, bounds, commands, cleanup, and overhead from subjective overlay legibility and workflow usefulness.

25. **Verify diagnostic and command contracts automatically**

    **Given** focused provider, binding, command-router, capture, build-policy, and real-scene tests run
    **When** they exercise every provider, hidden-state behavior, context replacement, selection, all seven commands, eligibility, duplicate and stale requests, owner failures, scope teardown, buffer saturation, capture limits, file failure, and release configuration
    **Then** diagnostic observation never changes gameplay and every authorized mutation is performed by exactly one normal system owner
    **And** histories remain within their bounds and no destroyed source is retained
    **And** release behavior contains no usable debug command path
    **And** automated comparisons prove the overlay reads the same maintained state used by the owning systems rather than recomputing it.

26. **Remain gameplay-equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** equivalent M3 scenarios run at shipping 60 Hz and diagnostic 120 Hz with diagnostics hidden and visible
    **When** authoritative results are compared
    **Then** gameplay outcomes, owner state, scope cleanup, request identity, and terminal results remain equivalent within documented physics tolerance
    **And** high-frequency presentation may display different sample density while preserving the same typed facts
    **And** an authorized command produces the same semantic owner result at the same declared scenario boundary
    **And** any unintended diagnostic-dependent gameplay divergence blocks the story.

27. **Keep the story bounded to integrated development tooling**

    **Given** Story 7.15 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the integrated read-only panels, context binding, fixed-capacity histories, seven finite owner-routed commands, local captures, release exclusion, overhead evidence, and focused verification
    **And** it does not add arbitrary scripting, a console, remote analytics, gameplay replay, live tuning, free spawning, teleportation, save editing, bot control, production cheats, or a universal diagnostic event bus
    **And** future diagnostic panels and commands require their own bounded provider or owner-routed contract.
