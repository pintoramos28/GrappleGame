---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.14'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 14
---

# Story 7.14: Leave the Active Level for a Safe Menu

As a player,
I want to leave an active or completed level and return to a dependable main menu,
So that I can change settings or begin a fresh run without old gameplay continuing in the background.

**Acceptance Criteria:**

1. **Declare the focused safe-menu outcome**

    **Given** the application can host, load, pause, complete, and replace an M3 level session
    **When** the safe-menu flow is inspected
    **Then** it provides a persistent main-menu state and an authorized transition that completely leaves the active level before publishing that state
    **And** entry paths, confirmation, flow ownership, teardown, UI and audio rebinding, input hygiene, loading integration, failure recovery, stale rejection, diagnostics, manual procedure, and automated evidence are explicit
    **And** returning from an unfinished run clearly communicates that current-session progress will be discarded
    **And** save games, continue slots, profiles, cloud state, chapter selection, desktop exit, credits, and production front-end art remain outside this story.

2. **Keep menu-transition authority in `GameFlowController`**

    **Given** UI, level completion, recovery presentation, or another approved source requests a return to menu
    **When** application state may change
    **Then** `GameFlowController` validates and commits the transition through one narrow `ReturnToMenuRequested` command
    **And** the request carries application-session, current level-session, source-screen occurrence, reason, and request identities
    **And** UI, level, player, encounter, checkpoint, reward, audio, and diagnostic code cannot free the level or publish the main-menu state directly
    **And** every accepted, rejected, cancelled, or duplicate request reaches one typed terminal result.

3. **Provide one persistent safe main-menu state**

    **Given** no level session is current
    **When** `GameFlowController` commits the main-menu state
    **Then** resident `SystemScreenLayer` shows the approved title treatment plus Play Validation Level and Settings actions
    **And** Retry appears only when a recoverable current loading failure supplies a valid request context
    **And** gameplay HUD, pause menu, recovery choices, level-completion controls, and debug-only controls are not presented as current player actions
    **And** the menu remains usable without loading a gameplay level or retaining one in the scene tree.

4. **Start the M3 level through the loading boundary**

    **Given** the safe main menu is current
    **When** the player selects Play Validation Level
    **Then** the UI emits one typed request for the configured stable M3 level ID
    **And** `GameFlowController` routes it through Story 7.4's catalog, threaded loading, readiness, and installation transaction
    **And** the menu cannot instantiate the level or hold a private direct scene reference
    **And** loading success enters one fresh level session while failure or cancellation returns to resident safe UI.

5. **Permit settings without a loaded level**

    **Given** the safe main menu is current
    **When** the player selects Settings
    **Then** Story 7.12's system-owned settings screen opens with the current committed preference snapshot
    **And** Story 7.13's binding section remains available through that settings flow
    **And** closing settings returns focus to the main-menu Settings action
    **And** no player, level, encounter, checkpoint, reward, or gameplay HUD is created merely to preview supported settings.

6. **Request return from the pause menu**

    **Given** an M3 level is paused through Story 7.11
    **When** the player selects Return to Menu
    **Then** the pause layer emits one current-session return request and opens the approved confirmation state
    **And** gameplay remains suspended while the decision is pending
    **And** the confirmation states that unpersisted level, checkpoint, reward, and encounter progress for the current session will be discarded
    **And** neither the pause menu nor confirmation frees gameplay objects directly.

7. **Allow the player to cancel an unfinished-run exit**

    **Given** the unfinished-run confirmation is open
    **When** the player selects Cancel or uses the approved back action
    **Then** the return request commits cancellation without invalidating the level session
    **And** focus returns to Return to Menu in the pause menu
    **And** gameplay remains paused with its authoritative state unchanged
    **And** later Resume continues through Story 7.11's neutral-input boundary.

8. **Confirm an unfinished-run exit exactly once**

    **Given** the current level session is paused and its confirmation is current
    **When** the player confirms Return to Menu
    **Then** `GameFlowController` accepts one leave transaction for that level-session identity
    **And** the confirmation and pause layers stop accepting duplicate activation
    **And** no current-session checkpoint, reward, coin total, encounter progress, or player state is promoted into application persistence
    **And** repeated confirm input cannot begin a second teardown or load request.

9. **Return directly after committed level completion**

    **Given** the M3 level objective has committed completion
    **When** the completion presentation offers Return to Menu and the player selects it
    **Then** the request uses the completed-session reason and does not require the unfinished-progress warning
    **And** it still performs the complete ordered level teardown
    **And** level completion and reward results remain visible only for their bounded completion presentation
    **And** the menu does not claim persistent progression was saved.

10. **Offer a fresh replay after completion**

    **Given** the M3 completion presentation is current
    **When** the player selects Replay
    **Then** `GameFlowController` leaves the completed level through the same teardown boundary and requests the configured M3 level through Story 7.4
    **And** the new run receives a fresh level session, player, encounter runs, checkpoints, reward ledger, and zero current-session coins
    **And** the old level is not scrubbed or reactivated
    **And** a replay loading failure returns to safe UI with bounded Retry and Main Menu options.

11. **Invalidate the level before teardown begins**

    **Given** a return or replay transaction is accepted
    **When** the leaving phase starts
    **Then** `LevelHost` marks the current level session invalid before cancelling its operations or freeing its root
    **And** new input, encounter, damage, spawn, checkpoint, reward, objective, audio, UI, and delayed work from that session is rejected
    **And** current application UI remains available to complete the transition
    **And** no old callback can reverse the leaving decision or publish itself as current.

12. **Tear down gameplay through normal owners**

    **Given** the invalidated level contains active or completed encounters and other mutable runtime state
    **When** teardown proceeds
    **Then** encounter runs are cancelled through their controllers, player gameplay is disabled through its owner, checkpoint and reward runtime is ended by `LevelController`, and scoped spawners reject new work
    **And** projectiles, telegraphs, hazards, temporary obstacles, links, statuses, surface mutations, timers, pickups, pending grants, and other level or encounter transients terminate exactly once or idempotently
    **And** shared immutable definitions and persistent application services are not scrubbed or mutated
    **And** the replaceable `LevelRoot` is freed only after its authority and external bindings are revoked.

13. **Disconnect HUD and presentation before releasing sources**

    **Given** `UIRoot` is bound to the leaving level's `GameplayHudContext`
    **When** teardown reaches presentation unbinding
    **Then** every gameplay HUD, recovery, completion, checkpoint, reward, and level-specific presentation source is disconnected before its owner is freed
    **And** `GameplayHudHost` enters its neutral or hidden state
    **And** stale source facts cannot appear over the main menu or a later level
    **And** persistent settings and system-screen presentation remain valid.

14. **End scoped audio and enter menu audio state**

    **Given** level ambience, encounter playback, gameplay one-shots, or combat music is active
    **When** the level session leaves
    **Then** encounter and level-scoped requests are invalidated and their loops, follow bindings, and emitters stop or fade through Story 7.10's ownership policy
    **And** `MusicDirector` accepts the menu state only from current application flow
    **And** persistent UI audio remains available
    **And** no old level audio can restart, retarget, or change menu music after teardown.

15. **Reset input and pointer ownership for the menu**

    **Given** the player leaves captured gameplay or a paused level
    **When** the main menu becomes current
    **Then** held and latched gameplay actions, mouse delta, rebinding capture, modal confirmation input, and debug selection are cleared
    **And** the pointer is visible and UI input context is authoritative
    **And** the confirm click or key cannot also select Play, reopen settings, or trigger gameplay
    **And** custom committed bindings and non-binding preferences remain available as application-session settings.

16. **Publish the menu only after the level is gone**

    **Given** ordered teardown is in progress
    **When** `GameFlowController` evaluates completion
    **Then** the main-menu state commits only after `LevelHost` reports no current `LevelRoot`, all external gameplay bindings are cleared, and required resident UI is ready
    **And** there is no interval where both the old level and main-menu Play action are authoritative
    **And** one committed menu-entry fact identifies the leave request and prior level session
    **And** presentation transition timing cannot publish the menu early.

17. **Recover to safe UI if teardown reports a failure**

    **Given** a required owner reports an unexpected teardown or unbinding failure
    **When** the leave transaction handles it
    **Then** the invalid old level is never resumed as healthy gameplay
    **And** `GameFlowController` completes best-effort idempotent cleanup and enters a safe resident failure state with Return to Main Menu or Retry Cleanup only where valid
    **And** technical details remain in bounded diagnostics
    **And** the failure cannot trigger an unbounded reload or teardown loop.

18. **Reject stale and competing menu requests**

    **Given** return, replay, play, retry, settings, pause, load, or completion requests arrive near the same application boundary
    **When** `GameFlowController` resolves them
    **Then** one documented precedence policy selects at most one current transition
    **And** stale session, screen, confirmation, or request identities cannot affect current UI or loading
    **And** each rejected or superseded request reaches one typed terminal result
    **And** signal, callback, resource-completion, and UI focus order cannot produce two active levels or duplicate menu screens.

19. **Expose read-only menu and leave state**

    **Given** UI, audio, or diagnostics needs application-flow information
    **When** it queries current state
    **Then** it receives stable application, request, prior and current level-session, screen-occurrence, flow-phase, confirmation, loading eligibility, and terminal-result data
    **And** the snapshot carries no mutable level or scene authority
    **And** discrete state changes are signalled after commitment
    **And** hidden presentation performs no scene-tree scan to infer whether gameplay still exists.

20. **Provide bounded safe-menu diagnostics**

    **Given** development application-flow diagnostics are enabled
    **When** menu entry, confirmation, cancellation, teardown, replay, loading, failure, or stale rejection occurs
    **Then** diagnostics expose request and session identities, source reason, transition phase, remaining scope counts, HUD and audio binding state, input context, load request, cleanup result, stale rejection, and terminal state
    **And** histories, failures, and repeated requests have explicit bounds
    **And** diagnostics cannot bypass confirmation, force scene removal, or install a level directly
    **And** release behavior omits or disables the detailed overlay.

21. **Make safe return and replay manually reproducible**

    **Given** another developer follows the documented M3 application-flow procedure
    **When** they start from the main menu, open and close settings, load the M3 level, create active encounter and transient state, pause, cancel an exit, confirm an exit, complete the level, return, and replay
    **Then** every path reaches exactly one valid menu or fresh level state with correct confirmation behavior
    **And** old players, encounters, projectiles, effects, checkpoints, rewards, coins, HUD facts, audio, signals, input, and callbacks never affect the menu or next run
    **And** loading failure, teardown failure fixture, duplicate activation, stale completion, rapid repeated requests, and repeated play-return-replay cycles recover safely
    **And** retained evidence separates objective ownership, cleanup, identity, loading, input, binding, and repeatability results from subjective menu clarity and transition quality.

22. **Verify safe-menu transitions automatically**

    **Given** focused application-flow and real-scene integration tests run
    **When** they exercise menu boot, Play, Settings return, unfinished confirmation and cancellation, confirmed leave from active and paused states, completion return, replay, loading failure, teardown failure, concurrent requests, stale callbacks, audio and HUD unbinding, input reset, and repeated cycles
    **Then** exactly one application state and at most one level session remain current
    **And** no invalid level object, signal connection, scoped transient, audio emitter, reward state, checkpoint state, or input edge survives its boundary
    **And** each request reaches one typed terminal result and immutable definitions retain their fingerprints
    **And** real-scene checks verify that menu and gameplay never remain authoritative together.

23. **Remain application-flow equivalent at both physics rates**

    **Given** equivalent leave, return, and replay scenarios run with shipping 60 Hz and diagnostic 120 Hz gameplay physics
    **When** the same owner-controlled boundaries occur
    **Then** confirmation, invalidation, cleanup, menu entry, load, session allocation, and terminal results remain equivalent
    **And** changing gameplay callback frequency cannot duplicate a request, preserve a transient, or change which flow transition wins
    **And** the menu remains independent of level physics once teardown completes
    **And** any rate-sensitive flow difference blocks the story.

24. **Keep the story bounded to safe menu return and replay**

    **Given** Story 7.14 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the resident main menu, Play and Settings entry points, unfinished-run confirmation, completed return, fresh replay, ordered teardown, HUD and audio unbinding, input reset, failure recovery, diagnostics, and focused verification
    **And** it does not add save slots, persistent level progress, profiles, cloud data, chapter selection, matchmaking, controller navigation, production front-end art, credits, or desktop-exit UX
    **And** future front-end presentation may replace this bounded menu without changing the application and level-session contracts.
