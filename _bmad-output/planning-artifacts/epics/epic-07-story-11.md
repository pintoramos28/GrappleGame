---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.11'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 11
---

# Story 7.11: Pause and Resume Without State Drift

As a player,
I want to pause and resume an active level safely,
So that I can step away or use system options without gameplay advancing or stale input affecting my return.

**Acceptance Criteria:**

1. **Declare the focused pause-and-resume outcome**

    **Given** the persistent application shell, active M3 level, HUD, and semantic audio exist
    **When** the pause slice is inspected
    **Then** it allows one eligible active gameplay session to enter a bounded pause state and return to the same valid gameplay state
    **And** request ownership, transition phases, simulation suspension, input context, UI behavior, audio response, resume hygiene, invalid states, diagnostics, manual procedure, and automated evidence are explicit
    **And** pause preserves authoritative gameplay state without serializing or reconstructing the level
    **And** settings persistence, input remapping, return-to-menu teardown, photo mode, background simulation, and multiplayer pause remain outside this story.

2. **Keep pause authority in `GameFlowController`**

    **Given** gameplay or UI requests pause or resume
    **When** application state may change
    **Then** `GameFlowController` validates and commits the transition through narrow `PauseRequested` and `ResumeRequested` commands
    **And** `UIRoot`, the pause menu, player, level, encounter, input source, audio presenters, and diagnostics cannot set application pause state directly
    **And** each accepted request reaches one typed terminal result
    **And** duplicate, stale, ineligible, or malformed requests leave the current state unchanged.

3. **Use an explicit pause lifecycle**

    **Given** the application has one active level session
    **When** pause or resume proceeds
    **Then** the owner transitions through active, pausing, paused, resuming, and active phases with the current application and level-session identities
    **And** only one transition is current at a time
    **And** the paused fact publishes only after gameplay suspension and pause-menu readiness commit
    **And** the resumed fact publishes only after pause presentation closes, input is sanitized, and gameplay processing is ready.

4. **Accept pause only from eligible gameplay**

    **Given** a pause request arrives
    **When** `GameFlowController` validates it
    **Then** it is accepted only for the current active, controllable level session with no current loading, replacement, teardown, recovery-choice, or rebinding transition
    **And** requests during startup, loading, safe no-level UI, level replacement, death recovery, level completion transition, or application failure return a typed ineligible result
    **And** an old level session cannot pause a newer one
    **And** rejection does not reveal or focus a hidden pause menu.

5. **Suspend the complete level simulation at one boundary**

    **Given** pause is accepted while traversal or combat is active
    **When** the pausing phase commits suspension
    **Then** player movement and attacks, encounter AI, ability phases, cooldowns, damage windows, projectiles, hazards, telegraphs, surface effects, checkpoints, rewards, objectives, and other level-owned gameplay stop advancing
    **And** no gameplay owner receives a fabricated zero-delta update as an alternate clock
    **And** application UI and the owners needed to resume or leave remain responsive through deliberate process modes
    **And** suspension does not cancel, complete, rewind, or recreate active gameplay state.

6. **Preserve the exact authoritative state while paused**

    **Given** an ability, grapple, projectile, encounter, hazard pulse, cooldown, or timed effect is partway through its lifecycle
    **When** the game remains paused for any wall-clock duration
    **Then** its simulation-authored elapsed and remaining time, position, velocity, phase, ownership, scope, and terminal state remain unchanged
    **And** health, rewards, checkpoints, objectives, participant state, and encounter progression cannot change from paused gameplay
    **And** render-only pause presentation may animate without writing gameplay state
    **And** operating-system time or audio playback cannot advance a simulation deadline.

7. **Make the pause menu a presentation and request layer**

    **Given** the paused state commits
    **When** `PauseMenuLayer` becomes visible
    **Then** it shows the approved paused heading plus Resume, Settings, and Return to Menu choices in a clear keyboard-and-mouse layout
    **And** Resume is functional in this story while Settings and Return to Menu use the narrow integration requests completed by Stories 7.12 through 7.14
    **And** the menu reads current application state but cannot unpause, load, free, save, or modify gameplay directly
    **And** gameplay HUD presentation remains visually subordinate according to Story 7.1's layer policy.

8. **Apply the declared input-context priority**

    **Given** the application is paused
    **When** keyboard or mouse input arrives
    **Then** rebinding capture, when deliberately active in a later story, has highest priority, followed by UI and pause, then gameplay, then debug shortcuts
    **And** the pause menu consumes only its declared navigation, activation, pointer, and cancel actions
    **And** gameplay command-frame creation cannot treat pause-menu actions as movement, jump, grapple, or attack input
    **And** low-priority debug shortcuts cannot dismiss a modal pause or settings screen unexpectedly.

9. **Manage mouse capture deliberately**

    **Given** captured-mouse gameplay enters pause
    **When** the pause menu opens
    **Then** the pointer becomes visible and usable by the UI without synthesizing an attack from the click that opened or focused it
    **And** resuming restores the approved captured-mouse mode only after the pause menu stops receiving pointer input
    **And** accumulated mouse motion from the paused or uncaptured period is discarded
    **And** canonical gameplay aim remains unchanged until new captured movement is received.

10. **Sanitize gameplay commands on pause entry**

    **Given** movement, grapple, attack, jump, or another gameplay input is held or latched as pause begins
    **When** gameplay input authority is suspended
    **Then** held, pressed, released, and between-step edge latches are cleared through the player input source
    **And** the last active command frame is not replayed while paused
    **And** a press used to open the pause menu cannot also reach gameplay
    **And** clearing input does not directly command the movement or attack state machines.

11. **Resume from a neutral input boundary**

    **Given** the player requests Resume
    **When** the resuming phase hands control back to gameplay
    **Then** the first authoritative gameplay command frame contains no synthetic pressed or released edges and no accumulated mouse delta
    **And** physically held keys may become held again only through the normal input-source policy without generating a false just-pressed action
    **And** grapple, attack, jump, and menu-confirm inputs used during pause do not fire on resume
    **And** new input received after gameplay becomes active behaves normally.

12. **Resume without catch-up simulation**

    **Given** the level was paused for an arbitrary wall-clock duration
    **When** fixed-step processing resumes
    **Then** gameplay continues from the next normal physics delta rather than receiving the paused duration as accumulated delta
    **And** ability phases, cooldowns, projectiles, hazards, AI replanning, and animations driven from gameplay state continue from their preserved remaining duration
    **And** no loop performs multiple hidden catch-up commits on the resume frame
    **And** final player velocity remains committed once by `PlayerMotor` on each resumed physics step.

13. **Keep audio subordinate to pause state**

    **Given** Story 7.10 playback is active when pause begins
    **When** the pause policy applies
    **Then** gameplay and encounter audio pauses, ducks, or fades according to its authored presentation policy while UI audio remains available
    **And** music follows the approved pause treatment without changing its authoritative music state
    **And** resume restores eligible playback without duplicating cue requests or restarting loops unless their definition requires it
    **And** audio device or playback behavior cannot determine whether gameplay is paused.

14. **Handle focus loss without stuck input**

    **Given** the application loses window focus while active, pausing, paused, or resuming
    **When** the input source receives the focus change
    **Then** all held and latched gameplay and UI input is cleared
    **And** mouse capture is released according to the application policy
    **And** focus loss alone does not invent a pause-state transition not committed by `GameFlowController`
    **And** regaining focus cannot synthesize gameplay actions or dismiss the pause menu.

15. **Resolve pause and competing transitions deterministically**

    **Given** pause, resume, death, encounter completion, checkpoint recovery, level completion, load, or leave requests occur near the same update boundary
    **When** `GameFlowController` and the current gameplay owner resolve them
    **Then** an explicit owner-controlled precedence policy produces one current application state
    **And** signal connection order, UI event order, render timing, or scene-tree order cannot change the result
    **And** an invalidated pause or resume request reaches one rejected or cancelled terminal result
    **And** no state leaves both gameplay and pause UI authoritative simultaneously.

16. **Reject stale pause and resume work**

    **Given** a request, deferred UI callback, audio callback, or transition completion belongs to an invalidated application or level session
    **When** it reaches the current flow boundary
    **Then** it cannot suspend or resume the new session, reveal an old menu, restore old input, or change current audio treatment
    **And** stale work returns a bounded typed reason
    **And** old pause-menu connections and context references are released
    **And** repeated stale callbacks remain idempotent.

17. **Expose read-only pause presentation state**

    **Given** `UIRoot`, audio, or diagnostics needs to reflect pause
    **When** it requests current state
    **Then** `GameFlowController` exposes application and level-session identities, lifecycle phase, eligibility, accepted request identity, and last terminal result through a typed read-only snapshot
    **And** consumers cannot mutate or complete a pause transition through that snapshot
    **And** discrete phase changes are signal-driven
    **And** hidden presentation performs no continuous gameplay inspection.

18. **Provide bounded pause diagnostics**

    **Given** development pause diagnostics are enabled
    **When** pause and resume are exercised
    **Then** diagnostics expose request and session identities, lifecycle phase, eligibility or rejection, active input context, mouse mode, simulation suspension state, cleared-edge counts, audio policy, competing transition, stale rejection, and terminal result
    **And** they can compare selected authoritative gameplay snapshots before and during pause without recomputing them
    **And** histories and counters have explicit bounds
    **And** the overlay is unavailable or disabled in release behavior.

19. **Make pause and resume manually reproducible**

    **Given** another developer follows the documented M3 pause procedure
    **When** they pause during ordinary traversal, held movement, grapple attachment, melee windup, enemy windup, projectile flight, hazard activity, encounter combat, and immediately around death or level transitions
    **Then** eligible scenarios freeze completely and resume from their preserved state without catch-up, duplicate outcomes, unintended input, or stuck audio
    **And** ineligible scenarios return the documented result and retain one valid application state
    **And** repeated rapid requests, focus loss, pointer use, long wall-clock pauses, checkpoint reload after resume, and level replacement after resume remain safe
    **And** retained evidence separates objective state preservation, timing, input, ownership, and cleanup results from subjective menu usability and audio-treatment observations.

20. **Verify pause contracts and real-scene behavior**

    **Given** focused flow, input, timing, and M3 scene tests run
    **When** they exercise eligibility, duplicate requests, every lifecycle phase, active gameplay subsystems, held and latched input, mouse motion, focus changes, audio treatment, competing transitions, stale callbacks, long pauses, and repeated pause-resume cycles
    **Then** paused simulation state remains unchanged and each accepted request reaches one terminal result
    **And** resume produces no accumulated delta, duplicate signal, false command edge, second motor commit, or altered gameplay outcome
    **And** old contexts and connections are released after level replacement
    **And** human review remains responsible for pause-menu clarity and perceived transition quality.

21. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** equivalent pause scenarios run from the shipping 60 Hz and diagnostic 120 Hz configurations
    **When** gameplay is paused for the same authored scenario boundary and resumed
    **Then** authoritative before-pause and after-resume state, remaining real-time durations, command-edge behavior, transition results, and eventual gameplay outcomes are equivalent within documented physics tolerance
    **And** the number of paused wall-clock frames cannot advance simulation
    **And** neither configuration performs catch-up work
    **And** any rate-dependent pause outcome blocks the story.

22. **Keep the story bounded to pause and resume**

    **Given** Story 7.11 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains flow-owned pause lifecycle, complete level suspension, pause-menu Resume behavior, input-context isolation, mouse handling, neutral resume, audio treatment, stale rejection, diagnostics, and focused verification
    **And** it does not implement persistent settings, finished settings screens, input rebinding, return-to-menu teardown, save-on-pause, photo mode, background gameplay, controller navigation, or multiplayer synchronization
    **And** those concerns remain assigned to Stories 7.12 through 7.14 or later work.
