---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.13'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 13
---

# Story 7.13: Remap Keyboard-and-Mouse Actions Safely

As a player,
I want to change keyboard-and-mouse gameplay bindings with clear conflict feedback,
So that I can use a comfortable control layout without making essential actions unavailable.

**Acceptance Criteria:**

1. **Declare the focused rebinding outcome**

    **Given** semantic gameplay input and the persisted settings boundary exist
    **When** the rebinding slice is inspected
    **Then** the settings UI can capture, validate, stage, apply, cancel, persist, and restore keyboard-and-mouse gameplay bindings
    **And** the action catalog, slots, compatible input types, conflict policy, reserved controls, input-context priority, prompt updates, recovery behavior, diagnostics, manual procedure, and automated evidence are explicit
    **And** gameplay continues to consume semantic `PlayerCommandFrame` values rather than physical inputs
    **And** controller bindings, device switching, chords, macros, axis curves, rumble, and controller menu navigation remain outside this story.

2. **Use `InputMap` as the factory-binding authority**

    **Given** the project contains factory gameplay actions
    **When** rebinding initializes
    **Then** factory bindings are read from the approved `project.godot` `InputMap` definitions
    **And** the baseline catalog contains Move Forward, Move Back, Move Left, Move Right, Jump, Grapple, and Attack mapped to their stable semantic action IDs
    **And** each catalog entry declares whether it is required, its binding behavior, compatible event types, display label, and prompt label
    **And** scene scripts, HUD text, and the rebinding screen do not duplicate factory key literals as competing defaults.

3. **Preserve the established baseline controls**

    **Given** no user binding overrides exist
    **When** the factory action snapshot is displayed
    **Then** movement uses W, S, A, and D; Jump uses Space; Grapple uses the right mouse button; and Attack uses the left mouse button with F as its existing alternate unless a separately approved factory change has replaced them
    **And** the UI derives those labels from the actual validated factory events
    **And** the legacy mouse-capture action is not exposed as a remappable gameplay action because capture belongs to application input context
    **And** an unexpected factory mismatch is surfaced during content validation rather than silently hard-coded around.

4. **Support a primary and optional alternate slot**

    **Given** a remappable action is shown
    **When** its binding row is inspected
    **Then** it exposes one primary and one optional alternate keyboard-or-mouse slot
    **And** each occupied slot displays a normalized player-facing label and input-family icon or text treatment
    **And** the same physical event cannot occupy both slots of one action
    **And** every required action must retain at least one valid binding before the staged snapshot can be applied.

5. **Limit capture to supported event types**

    **Given** a binding slot is awaiting input
    **When** an event arrives
    **Then** ordinary keyboard keys, mouse buttons, and mouse-wheel directions are recognized according to the action's declared compatibility
    **And** held movement and held grapple actions reject wheel-only events that cannot represent their required held or release behavior
    **And** pointer motion, text input, unsupported device events, echo events, multi-event macros, and arbitrary modifier-only input are ignored or rejected with clear feedback
    **And** event normalization preserves the approved physical-versus-logical key policy consistently.

6. **Give rebinding capture highest input priority**

    **Given** the player activates a binding slot from safe UI or a paused game
    **When** capture begins
    **Then** one capture occurrence becomes the highest-priority input context above UI and pause, gameplay, and debug shortcuts
    **And** the next eligible event is consumed by capture and cannot also navigate UI, resume gameplay, attack, grapple, or trigger a debug command
    **And** only one slot can capture at a time
    **And** gameplay simulation remains paused or absent throughout capture.

7. **Reserve a reliable cancellation path**

    **Given** rebinding capture is active
    **When** the player presses Escape or uses the approved cancel interaction
    **Then** capture ends without changing the staged binding
    **And** Escape remains reserved for cancellation and menu recovery rather than becoming a gameplay binding through this screen
    **And** focus returns to the same binding slot
    **And** repeated cancellation is idempotent and cannot close unrelated application layers.

8. **Clear bindings deliberately**

    **Given** an occupied binding slot is selected outside active capture
    **When** the player invokes the approved Clear command
    **Then** that slot becomes empty in the working copy only
    **And** clearing an alternate slot is permitted when the primary remains valid
    **And** a staged state leaving a required action with no binding is visibly invalid and cannot be applied
    **And** clearing a slot does not immediately mutate `InputMap` or the persisted file.

9. **Detect conflicts before changing authority**

    **Given** a captured event is already assigned to another gameplay action or another slot
    **When** the candidate binding is validated
    **Then** the screen identifies the conflicting action and slot in player-facing language
    **And** it offers the bounded choices Replace and Cancel
    **And** no binding changes until the player chooses one
    **And** conflict detection operates on normalized event identity rather than display text.

10. **Replace a conflicting binding predictably**

    **Given** a valid conflict is displayed
    **When** the player selects Replace
    **Then** the captured event moves to the requested slot and is removed from the conflicting slot in one staged operation
    **And** any affected required action must still retain another valid slot or the working copy remains visibly invalid until corrected
    **And** no third action or unrelated event changes
    **And** the operation remains reversible by Cancel before the complete snapshot is applied.

11. **Cancel a conflict without side effects**

    **Given** a valid conflict is displayed
    **When** the player selects Cancel
    **Then** both the requested and conflicting bindings remain exactly as they were in the working copy
    **And** no `InputMap`, file, prompt, or gameplay change occurs
    **And** focus returns to the requested binding slot
    **And** the conflict presentation and capture occurrence terminate once.

12. **Stage a complete typed binding snapshot**

    **Given** the rebinding screen contains edits
    **When** its working copy is inspected
    **Then** it records the expected settings version plus stable action IDs, slot identities, normalized typed events, required-action validity, and unresolved conflicts
    **And** it contains no executable callbacks, mutable `InputEvent` instances shared with factory data, or scene-node references
    **And** Apply is available only when every required action is usable and no conflict remains
    **And** duplicate or semantically identical snapshots compare deterministically.

13. **Apply bindings atomically through `SettingsService`**

    **Given** a complete valid working snapshot differs from current bindings
    **When** the player selects Apply
    **Then** the request carries its screen occurrence and expected current settings version
    **And** `SettingsService` validates and persists the user override, replaces the applicable runtime `InputMap` events as one controlled transaction, commits one immutable binding snapshot, and publishes one result
    **And** either the complete candidate becomes current or the prior bindings remain authoritative
    **And** an unchanged or duplicate apply cannot create a second version or repeated action-map mutation.

14. **Persist overrides without overwriting factory defaults**

    **Given** custom bindings are applied successfully
    **When** they are stored in `user://settings.cfg`
    **Then** only the versioned user override representation is persisted through `SettingsService`
    **And** the `project.godot` factory events remain unchanged and recoverable
    **And** existing non-binding preferences from Story 7.12 remain intact
    **And** no level, player, UI scene, or second file stores another binding authority.

15. **Restore factory bindings completely**

    **Given** one or more custom bindings are current
    **When** the player selects Restore Factory Bindings and confirms
    **Then** the working copy is rebuilt from the current validated `InputMap` factory snapshot
    **And** every required primary and approved alternate slot reflects that snapshot
    **And** the change remains staged until Apply succeeds
    **And** restoring bindings does not reset audio, aiming, HUD, or other Story 7.12 preferences.

16. **Cancel staged binding edits**

    **Given** the player has captured, cleared, replaced, or restored bindings in the working copy
    **When** they cancel or close without applying
    **Then** runtime `InputMap`, persisted overrides, current binding snapshot, and HUD prompts remain unchanged
    **And** no staged event survives the screen occurrence
    **And** any active capture or conflict modal closes safely
    **And** reopening begins from the current committed bindings.

17. **Recover safely from invalid persisted overrides**

    **Given** the user settings file contains missing actions, malformed events, duplicate assignments, unsupported devices, incompatible schema, or a required action with no valid binding
    **When** binding overrides load
    **Then** `SettingsService` validates them before applying anything to runtime `InputMap`
    **And** invalid binding state falls back to a complete safe factory snapshot with a typed recovery result
    **And** valid non-binding preferences remain recoverable independently where the schema allows
    **And** the problem warns once through bounded diagnostics rather than leaving controls unusable.

18. **Update prompts from committed bindings**

    **Given** a new binding snapshot commits
    **When** Story 7.9 prompt presentation refreshes
    **Then** each action prompt reads the current primary binding and approved alternate treatment from the input presentation source
    **And** player-facing labels update once without changing the prompt's gameplay eligibility
    **And** prompts fall back safely when an optional alternate is empty
    **And** raw action IDs, key codes, or stale factory labels are not displayed.

19. **Keep gameplay semantic after rebinding**

    **Given** the player returns from settings to active gameplay with custom bindings
    **When** physical input is received
    **Then** the player-owned input source converts it into the same immutable semantic command fields consumed before rebinding
    **And** movement and ability HSMs remain unaware of which key or mouse event produced a command
    **And** rebinding does not change attack timing, grapple eligibility, movement tuning, or action ownership
    **And** every received mouse-motion event continues to feed canonical aim independently of action bindings.

20. **Clear transient input across capture and focus changes**

    **Given** capture opens, closes, loses focus, applies bindings, or returns to gameplay
    **When** input context changes
    **Then** held and latched gameplay edges, captured candidate events, pointer clicks, and accumulated mouse delta are sanitized according to Stories 7.11 and 7.12
    **And** the captured binding event cannot become a gameplay press on return
    **And** focus loss cancels or safely suspends the active capture without committing an event
    **And** no action remains stuck after a binding it used is replaced or removed.

21. **Handle persistence or runtime-apply failure transactionally**

    **Given** file persistence or controlled `InputMap` replacement fails
    **When** binding Apply reaches a terminal result
    **Then** the prior committed bindings remain or are restored as one coherent runtime snapshot
    **And** the UI reports a concise player-safe failure without claiming the new bindings were saved
    **And** non-binding settings and factory definitions remain unchanged
    **And** retry begins through a new typed request rather than continuing a partial transaction.

22. **Reject stale capture and settings work**

    **Given** a capture event, conflict choice, apply result, prompt update, or callback belongs to a closed screen, superseded settings version, or invalid application session
    **When** it reaches a current owner
    **Then** it cannot change runtime bindings, persisted overrides, current prompts, focus, input context, or gameplay commands
    **And** expected stale work returns a bounded typed reason
    **And** old event and screen references are released
    **And** repeated stale callbacks remain idempotent.

23. **Provide bounded rebinding diagnostics**

    **Given** development input diagnostics are enabled
    **When** catalog validation, capture, normalization, compatibility checking, conflict resolution, apply, restore, load recovery, focus change, or stale rejection occurs
    **Then** diagnostics expose stable action and slot IDs, normalized event category, capture occurrence, settings version, conflict category, input context, validation result, transaction phase, and terminal result
    **And** they do not log arbitrary text entry or upload input histories
    **And** histories and repeated warnings have explicit bounds
    **And** release behavior omits or disables detailed capture diagnostics.

24. **Make rebinding manually reproducible**

    **Given** another developer follows the documented keyboard-and-mouse rebinding procedure from safe UI and a paused M3 level
    **When** they remap every supported action across primary and alternate slots using keys, mouse buttons, and compatible wheel events
    **Then** they can demonstrate successful apply, cancel, clear, required-action validation, exact duplicate rejection, Replace and Cancel conflict paths, factory restoration, prompt refresh, relaunch persistence, focus loss, and gameplay use
    **And** unsupported event types, held-action wheel rejection, malformed saved data, write failure, stale capture, and rapid repeated capture remain safe
    **And** the M3 traversal and combat route remains completable with one valid custom layout and again after factory restoration
    **And** retained evidence separates objective action, slot, conflict, persistence, prompt, command-frame, and recovery results from subjective binding comfort and label clarity.

25. **Verify rebinding contracts and integration behavior**

    **Given** focused action-catalog, normalization, conflict, persistence, input-context, prompt, and real-gameplay tests run
    **When** they exercise every supported event category, primary and alternate slots, required-action rules, capture priority, conflict choices, apply, cancel, restore, malformed overrides, transactional failure, focus loss, stale work, relaunch, and repeated remaps
    **Then** exactly one complete binding snapshot remains authoritative and factory recovery always leaves all required actions usable
    **And** one physical event produces only its committed semantic action behavior
    **And** no capture event leaks into gameplay or debug commands, and no gameplay HSM depends on physical binding identity
    **And** human review remains required for capture clarity, conflict language, focus order, and custom-layout comfort.

26. **Remain input-equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** identical event streams and committed binding snapshots are supplied at fixed 60 Hz and diagnostic 120 Hz
    **When** movement, short press-and-release edges, held actions, grapple release, attack, focus loss, and capture transitions are exercised
    **Then** semantic pressed, held, and released command outcomes are equivalent
    **And** short edges are not lost or duplicated and mouse delta is not multiplied per physics tick
    **And** rebinding UI state does not depend on gameplay physics frequency
    **And** any configuration-dependent semantic divergence blocks the story.

27. **Keep the story bounded to keyboard-and-mouse rebinding**

    **Given** Story 7.13 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the explicit gameplay action catalog, primary and alternate slots, keyboard and mouse capture, compatibility rules, conflict feedback, staged apply and cancel, persistence, factory restoration, prompt integration, recovery, diagnostics, and focused verification
    **And** it does not add controller support, controller glyphs, device switching, chords, macros, mouse acceleration, gameplay tuning, arbitrary UI-navigation remapping, accessibility automation, or cloud profiles
    **And** additional actions require a deliberate catalog and factory-binding update rather than appearing implicitly.
