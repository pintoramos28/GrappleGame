---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.12'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 12
---

# Story 7.12: Configure and Persist Supported Preferences

As a player,
I want to adjust supported audio, aiming, and HUD preferences from safe menus,
So that the game remains comfortable and readable each time I launch it.

**Acceptance Criteria:**

1. **Declare the focused preferences outcome**

    **Given** the application shell, gameplay HUD, audio buses, and pause menu exist
    **When** the preferences slice is inspected
    **Then** it provides one settings screen with validated audio, mouse-aim, and HUD presentation preferences that can be previewed, applied, cancelled, restored to defaults, and persisted locally
    **And** settings ownership, supported fields, staging, validation, persistence, migration, consumer updates, failure handling, diagnostics, manual procedure, and automated evidence are explicit
    **And** the screen is usable from both the safe no-level system UI and the paused M3 session
    **And** gameplay tuning, input bindings, controller options, graphics-quality presets, save-game data, cloud sync, and account settings remain outside this story.

2. **Keep user-preference authority in `SettingsService`**

    **Given** settings load, preview, apply, reset, or persistence is requested
    **When** authoritative preference state may change
    **Then** persistent `SettingsService` alone reads and writes the user settings file and commits the typed current snapshot
    **And** settings UI submits narrow typed requests and consumes read-only snapshots and results
    **And** HUD, audio, player input, level, encounter, and application flow receive only the typed values they own as consumers
    **And** no consumer reads private configuration keys or writes the file directly.

3. **Support one explicit bounded preference catalog**

    **Given** the Story 7.12 settings schema is inspected
    **When** supported fields are enumerated
    **Then** it includes Master, Music, SFX, Ambience, and UI audio levels; mouse sensitivity and approved inversion or axis-scale options; and Story 7.1's UI scale, reticle size, reticle color, and high-contrast setting
    **And** each field declares a stable typed identity, value type, approved default, range or option set, display label, formatting rule, preview policy, and consumer
    **And** Story 7.1 remains authoritative for the four HUD setting ranges and visual behavior
    **And** unsupported arbitrary keys cannot appear automatically in the settings UI or runtime snapshot.

4. **Store preferences in one versioned local file**

    **Given** the player has applied supported preferences
    **When** persistence succeeds
    **Then** `SettingsService` stores them in a versioned `ConfigFile` at `user://settings.cfg`
    **And** the file contains only current user preferences and schema metadata rather than gameplay, level, checkpoint, reward, or diagnostic state
    **And** section names and keys remain private implementation details of `SettingsService`
    **And** no JSON, registry, remote service, autoload dictionary, or second preference file competes as authority.

5. **Load settings before dependent presentation becomes active**

    **Given** the application starts
    **When** `SettingsService` initializes
    **Then** it resolves defaults, reads any supported file, validates and migrates it, commits one current typed snapshot, and then publishes readiness
    **And** `UIRoot`, audio settings, and player aim receive the committed snapshot before they become interactive
    **And** a level does not need to read the file or delay combat to discover preferences
    **And** startup cannot expose a partially loaded mixture of defaults and saved values as current.

6. **Use approved defaults when no settings file exists**

    **Given** `user://settings.cfg` is absent on first launch
    **When** settings initialize
    **Then** every supported field receives its documented factory default
    **And** the default snapshot is complete and valid without requiring a disk write
    **And** consumers behave identically to explicitly applying those defaults
    **And** absence of the file is not presented as an error.

7. **Validate and clamp loaded values**

    **Given** a settings file contains out-of-range, malformed, unknown, missing, or incompatible values
    **When** it is loaded
    **Then** known values are type-checked and clamped or replaced according to their declared field policy
    **And** missing values receive current defaults while unknown keys are ignored without becoming runtime state
    **And** the resulting current snapshot is always complete and within approved ranges
    **And** each recovery category warns at most once through bounded diagnostics.

8. **Migrate only declared schema versions**

    **Given** a recognized older settings schema is loaded
    **When** migration runs
    **Then** one explicit deterministic migration path converts supported fields into the current typed schema
    **And** migration does not infer gameplay state, input bindings reserved for Story 7.13, or unsupported options
    **And** a future or unrecognized incompatible version falls back safely with a typed result
    **And** migration occurs in temporary data before the current snapshot is committed.

9. **Open settings from safe menu or pause**

    **Given** the application is either in safe no-level UI or paused through Story 7.11
    **When** the player selects Settings
    **Then** `SystemScreenLayer` or `PauseMenuLayer` presents the same settings content through the correct modal host
    **And** the screen receives a working copy of the current committed snapshot plus its version
    **And** opening it does not change current preferences or gameplay state
    **And** an ineligible request during loading, replacement, active unpaused gameplay, rebinding, or teardown returns a typed result without showing a stale screen.

10. **Stage edits in a working copy**

    **Given** the settings screen is open
    **When** the player changes a supported control
    **Then** only the screen's bounded working copy changes initially
    **And** values are normalized and validated before any preview is sent
    **And** the screen clearly distinguishes changed, invalid, applying, applied, and failed states
    **And** editing a slider does not write the settings file once per pointer event.

11. **Preview only declared presentation-safe changes**

    **Given** a valid staged audio or HUD presentation value supports preview
    **When** the player adjusts it
    **Then** the applicable buses or HUD presentation temporarily reflect the staged value through a typed preview context
    **And** preview cannot alter gameplay targeting, input geometry, health, ability timing, or encounter state
    **And** cancelling or closing without apply restores the last committed values exactly
    **And** a preview is scoped to the current settings-screen occurrence and cannot survive its closure or replacement.

12. **Apply a complete validated snapshot transactionally**

    **Given** the working copy is valid and differs from the committed snapshot
    **When** the player selects Apply
    **Then** the request carries its screen occurrence and expected current settings version
    **And** `SettingsService` validates the complete candidate, persists it through its controlled file boundary, commits one new immutable settings snapshot, and publishes one typed change result
    **And** consumers receive only the committed values relevant to them
    **And** a duplicate request or unchanged working copy cannot create a second version or repeated consumer update.

13. **Cancel without retaining staged changes**

    **Given** the player has changed one or more staged values
    **When** they select Cancel or back out through the approved navigation
    **Then** every previewed consumer returns to the current committed snapshot
    **And** no file write, version increment, or committed change signal occurs
    **And** focus returns to the menu entry that opened settings
    **And** reopening settings begins from the committed values rather than the discarded working copy.

14. **Restore preference defaults deliberately**

    **Given** the settings screen is open
    **When** the player requests Restore Defaults and confirms the action
    **Then** the working copy receives every supported non-binding factory value from the current schema
    **And** previewable values may preview those defaults while the change remains staged
    **And** the player must still Apply to commit and persist them
    **And** restoring keyboard-and-mouse bindings remains the separate responsibility of Story 7.13.

15. **Apply audio values through the audio settings boundary**

    **Given** a committed or preview audio snapshot changes
    **When** `AudioSettingsService` consumes it
    **Then** Master, Music, SFX, Ambience, and UI controls affect only their mapped bus categories within validated gain and mute behavior
    **And** currently eligible playback responds without reconstructing gameplay sources or duplicating cue requests
    **And** cancelling preview restores the prior bus values
    **And** audio settings cannot suppress the visual fallback or authoritative fact behind a critical event.

16. **Apply HUD values through the approved presentation boundary**

    **Given** UI scale, reticle size, reticle color, or high contrast changes
    **When** `GameplayHudHost` or the HUD state gallery consumes the typed value
    **Then** the affected components follow the exact Story 7.1 range, default, and treatment rules
    **And** layout remains usable at the supported aspect ratios and scale combinations
    **And** critical state distinctions remain available without color alone
    **And** reticle changes never alter aim, raycasts, grapple range, or target eligibility.

17. **Apply mouse-aim values without losing precision**

    **Given** mouse sensitivity, inversion, or approved axis scaling is committed
    **When** the player returns to captured gameplay
    **Then** the event-driven canonical aim accumulator consumes every new motion event through the typed settings values
    **And** mouse delta is not multiplied once per physics tick or applied again by camera presentation
    **And** the setting change cannot synthesize a motion event or rotate aim while the settings screen is open
    **And** equivalent physical input retains the documented behavior at 60 Hz and diagnostic 120 Hz.

18. **Handle persistence failure safely**

    **Given** the settings file cannot be created, written, replaced, or read back as required by the persistence policy
    **When** Apply reaches the persistence boundary
    **Then** the request returns one typed player-safe failure and does not claim the candidate snapshot was persisted
    **And** the service retains the last known committed snapshot or explicitly marks a bounded unsaved state according to the approved transaction policy
    **And** previews are reconciled to that authoritative result
    **And** technical paths and filesystem detail remain in diagnostics rather than normal UI text.

19. **Reject stale settings screens and requests**

    **Given** a staged copy, apply result, preview callback, or screen event belongs to a closed or superseded settings-screen occurrence or old application session
    **When** it reaches a current boundary
    **Then** it cannot change the current snapshot, consumer values, file, focus, or visible screen
    **And** expected stale work returns a bounded typed reason
    **And** old preview contexts and signal connections are released
    **And** repeated stale callbacks remain idempotent.

20. **Expose read-only settings state**

    **Given** UI, consumers, or diagnostics require current preferences
    **When** they query `SettingsService`
    **Then** they receive an immutable typed snapshot with schema and state version plus supported values
    **And** consumers may subscribe to committed changes for only the fields they need
    **And** no caller receives mutable configuration data or private file access
    **And** settings are not polled from disk during gameplay.

21. **Provide bounded settings diagnostics**

    **Given** development settings diagnostics are enabled
    **When** load, validation, migration, preview, apply, cancel, restore, consumer update, or persistence failure occurs
    **Then** diagnostics expose schema and snapshot versions, field-level recovery categories, request and screen identities, preview state, persistence result, consumer acknowledgements where required, stale rejection, and terminal result
    **And** sensitive filesystem detail is limited to local diagnostics and never uploaded automatically
    **And** histories and warnings have explicit bounds
    **And** disabling diagnostics stops formatting and release behavior omits or disables the overlay.

22. **Make preference behavior manually reproducible**

    **Given** another developer follows the documented settings procedure from both safe UI and a paused M3 level
    **When** they preview, cancel, apply, relaunch, restore defaults, and exercise minimum, maximum, and representative intermediate values
    **Then** audio buses, mouse aim, UI scale, reticle size and color, and high contrast reflect only the correct staged or committed state
    **And** applied settings survive application restart while cancelled settings do not
    **And** missing, malformed, out-of-range, old-version, future-version, unwritable, duplicate, and stale cases recover through their documented behavior
    **And** retained evidence separates objective values, persistence, version, consumer, layout, and gameplay-neutrality results from subjective comfort, legibility, and audio-level observations.

23. **Verify settings contracts and integration behavior**

    **Given** focused settings unit tests plus UI, audio, aim, and persistence integration tests run
    **When** they exercise defaults, all supported field types and bounds, loading, migration, staging, preview, cancel, apply, unchanged apply, reset, consumer updates, file failure, stale work, relaunch, and supported layout combinations
    **Then** one current immutable snapshot remains authoritative and only a successful apply creates one new committed version
    **And** no invalid or cancelled value reaches persistent authority
    **And** consumers receive correct typed values without reading the file or duplicating gameplay computation
    **And** human review remains required for control usability, readability, and perceived audio and aiming comfort.

24. **Keep the story bounded to supported non-binding preferences**

    **Given** Story 7.12 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains `SettingsService`, the versioned local settings file, typed snapshots, the shared settings screen, supported audio, mouse-aim, and HUD fields, preview, apply, cancel, defaults, validation, migration, failure handling, diagnostics, and focused verification
    **And** it does not implement keyboard or mouse rebinding, controller support, graphics-quality profiles, arbitrary resolution switching, save games, cloud synchronization, account profiles, gameplay tuning, or accessibility options absent from the approved schema
    **And** bindings remain assigned to Story 7.13 and additional settings require a later approved schema change.
