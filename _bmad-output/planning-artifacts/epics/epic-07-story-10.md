---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.10'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 10
---

# Story 7.10: Hear Scoped Gameplay and Level Audio

As a player,
I want important movement, combat, encounter, reward, and level states reinforced through sound,
So that I can understand threats and outcomes without audio ever controlling gameplay.

**Acceptance Criteria:**

1. **Declare the focused semantic-audio outcome**

    **Given** traversal, combat, encounters, rewards, application flow, and the gameplay HUD expose committed state
    **When** the Epic 7 audio slice is inspected
    **Then** it provides scoped positional and non-positional audio for movement, attacks, telegraphs, encounters, UI, ambience, and music state
    **And** cue definitions, requests, presenters, scope ownership, residency, voice policy, cancellation, settings hooks, fallback behavior, diagnostics, manual review, and automated evidence are explicit
    **And** audio follows existing gameplay and application owners without becoming a timing or outcome authority
    **And** final composition, recording, sound design, mixing polish, voice acting, and external middleware remain outside this story.

2. **Define one reviewable M3 cue-coverage matrix**

    **Given** the required M3 player journey is inspected
    **When** audio coverage is mapped
    **Then** the matrix includes representative cues for grapple attachment and release, wall contact or wall jump, player attack commitment and confirmed impact, enemy windup and outcome, encounter start and completion, player death and restoration, checkpoint activation, reward collection and rejection, UI navigation and confirmation, level ambience, and menu, exploration, combat, and victory music states
    **And** every cue identifies its authoritative source fact, scope, spatial mode, priority, fallback, and cancellation behavior
    **And** duplicated cues are consolidated through shared presentation profiles where their semantic purpose is the same
    **And** an uncovered required category prevents FR57 from being marked complete.

3. **Author immutable audio cue definitions**

    **Given** any required cue is inspected
    **When** its `AudioCueDefinition` resolves
    **Then** it declares a stable cue ID and version, one or more resident streams, target bus, spatial mode, volume and pitch variation, attenuation and maximum distance where applicable, concurrency group, voice limit, retrigger policy, priority, looping policy, fade policy, and fallback
    **And** semantic units and bounded ranges are explicit
    **And** invalid buses, empty required streams, incompatible spatial policies, unbounded variation, and malformed loop policies fail validation
    **And** playback never mutates the shared definition.

4. **Create occurrence-specific audio requests**

    **Given** a committed source fact needs an audible presentation
    **When** its presenter creates an `AudioCueRequest`
    **Then** the request carries the cue definition, unique request occurrence, semantic reason or gameplay phase, application and level-session identities, encounter run and ability execution identities where applicable, position or typed follow target, source identity, and approved presentation parameters
    **And** it snapshots stable cross-lifetime attribution rather than depending on scene parentage
    **And** it contains no callback that can change gameplay
    **And** an invalid or incomplete request returns a typed rejection without producing playback.

5. **Keep audio presenters downstream of gameplay**

    **Given** movement, ability, damage, encounter, checkpoint, reward, UI, or level state changes
    **When** an audio presenter reacts
    **Then** it consumes committed facts or read-only state from the responsible owner
    **And** it cannot start or end an ability phase, open a damage window, complete an encounter, activate a checkpoint, grant a reward, or change application flow
    **And** animation markers and stream completion callbacks remain cosmetic
    **And** missing or muted audio cannot prevent or delay a valid gameplay outcome.

6. **Separate application, level, and encounter audio lifetimes**

    **Given** the audio scene hierarchy is inspected
    **When** ownership is resolved
    **Then** persistent `AppAudio` owns UI playback, settings application, and `MusicDirector`
    **And** each active `LevelRoot` owns one `LevelAudioRoot` for level ambience and other level-scoped playback
    **And** each encounter run owns one `EncounterAudioRoot` for run-scoped telegraphs, actions, and loops
    **And** a child scope cannot keep itself alive or migrate playback into a longer-lived root.

7. **Route cues through the approved bus layout**

    **Given** the project audio buses are inspected
    **When** a cue definition selects its route
    **Then** the hierarchy contains `Master`, `Music`, `SFX`, `SFX/Player`, `SFX/Player/Grapple`, `SFX/Enemy`, `SFX/Enemy/Telegraph`, `SFX/World`, `Ambience`, and `UI` routes or their validated Godot-equivalent bus arrangement
    **And** every required cue reaches exactly one intended leaf or parent bus without bypassing `Master`
    **And** user-facing volume categories map to Master, Music, SFX, Ambience, and UI
    **And** missing or renamed required buses fail development validation instead of silently routing to an unintended output.

8. **Use positional sound for world-local facts**

    **Given** a grapple contact, enemy telegraph, enemy attack, projectile impact, hazard, world effect, or positioned reward requires sound
    **When** its request is accepted
    **Then** playback uses the declared three-dimensional position or typed follow binding
    **And** attenuation, maximum distance, and spatial blend come from the cue definition
    **And** a one-shot may snapshot its committed position while a moving loop remains explicitly bound to a current source
    **And** camera position, visual shake, or HUD placement cannot redefine the gameplay source location.

9. **Use non-positional sound for application and local-player clarity**

    **Given** UI feedback, a local-player-only critical state, checkpoint confirmation, reward summary, or music transition is requested
    **When** its semantic policy selects non-positional playback
    **Then** the sound remains stable regardless of world camera position
    **And** it uses the approved UI, player, or music bus rather than an arbitrary world emitter
    **And** local-player critical feedback remains distinguishable from distant scene noise
    **And** a world event is not converted to non-positional playback merely to evade attenuation or voice policy.

10. **Align telegraph audio with authoritative ability space and phases**

    **Given** an enemy ability enters windup, lock, active, outcome, recovery, completion, or cancellation
    **When** its audio presenter requests cues
    **Then** the request references the same execution identity, committed phase, and applicable spatial binding used by visual warning and active delivery
    **And** windup audio begins only from the authoritative windup fact and cannot extend or shorten the warning
    **And** outcome audio distinguishes confirmed hit, miss, displacement, cancellation, and source termination where the coverage matrix requires it
    **And** an audio stream ending never advances the ability lifecycle.

11. **Provide meaningful traversal-combat confirmation**

    **Given** the player grapples, uses a wall movement action, attacks, lands a valid hit, takes damage, dies, or restores
    **When** the corresponding committed facts occur
    **Then** the required local-player cues are audible under the baseline mix and remain semantically distinguishable
    **And** attempted actions rejected before commitment do not play success cues
    **And** movement loops stop or transition when their authoritative state ends
    **And** rapid contacts or repeated hit facts obey retrigger and concurrency policy rather than producing an uncontrolled stack.

12. **Reinforce encounter and level state changes**

    **Given** `LevelController` or an active encounter commits a state transition
    **When** audio presentation observes encounter start, optional commitment, completion, checkpoint activation, recovery, reward collection, level completion, or safe exit
    **Then** it requests the mapped cue exactly once per committed occurrence
    **And** duplicate, rolled-back, or stale facts cannot replay a success sound
    **And** encounter cues remain run-scoped while checkpoint, reward, and level-completion cues remain level-session-scoped
    **And** failure and recovery sounds do not imply that an uncommitted objective or reward succeeded.

13. **Drive music from high-level application and level state**

    **Given** `MusicDirector` receives typed menu, exploration, combat, boss, or victory state requests
    **When** the current high-level state changes
    **Then** the director validates requesting ownership and applies the authored transition or fade policy
    **And** M3 uses menu, exploration, combat, and victory states while the boss state remains available for Epic 8
    **And** individual enemies cannot select music or publish victory
    **And** duplicate state requests are idempotent and cannot restart the same track or transition indefinitely.

14. **Keep ambience scoped to the active level**

    **Given** the M3 level becomes active
    **When** its authored ambience begins
    **Then** the ambience loop is owned by `LevelAudioRoot`, uses its declared bus and fade policy, and does not duplicate on checkpoint or encounter restart
    **And** replacing or leaving the level stops or fades it through the level teardown boundary
    **And** a stale ambience request from the old level cannot affect the new level
    **And** missing optional ambience uses its declared fallback without preventing level activation.

15. **Protect critical cues with bounded voice policy**

    **Given** more cue requests arrive than the available voice limits permit
    **When** arbitration occurs
    **Then** local-player damage, traversal confirmation, and imminent enemy telegraphs take precedence over distant, repetitive, low-priority, or ambient requests
    **And** each concurrency group applies its authored voice limit and retrigger policy deterministically
    **And** rejected, replaced, or stolen voices produce bounded diagnostic reasons
    **And** voice arbitration cannot reject or alter the gameplay fact that requested sound.

16. **Make every combat-critical cue resident before activation**

    **Given** the M3 manifest and encounter dependencies are validated
    **When** the level and encounters report readiness
    **Then** all required player, enemy, telegraph, encounter, and recovery cue definitions and fallback streams are resident
    **And** first-time synchronous audio loading during combat is prohibited
    **And** a missing required critical cue fails readiness through the responsible typed boundary
    **And** an optional cue may degrade only through a declared resident fallback.

17. **Provide audible placeholder assets without requiring final audio**

    **Given** production sound assets are unavailable
    **When** the M3 audio coverage is exercised
    **Then** small resident placeholder streams or tones make every required semantic category audibly distinguishable for testing
    **And** their labels, waveform sources, licensing status, and intended replacement slots are documented
    **And** replacing them later requires only compatible cue-definition or presentation-asset changes
    **And** no placeholder establishes gameplay timing, collision, targeting, or damage behavior.

18. **Apply audio preferences through a typed service boundary**

    **Given** default Master, Music, SFX, Ambience, and UI values are supplied
    **When** `AudioSettingsService` applies them
    **Then** the corresponding bus gain or mute state changes within validated ranges
    **And** currently playing compatible sounds respond without recreating gameplay sources
    **And** Story 7.12 may persist and edit these typed values without reaching into individual emitters
    **And** zero volume or mute never suppresses the gameplay fact or visual fallback behind a critical cue.

19. **Terminate encounter audio with its run**

    **Given** an encounter run completes, restarts, is invalidated by checkpoint reload, loses its source, or ends with level teardown
    **When** cleanup begins
    **Then** new requests carrying that run identity are rejected before existing emitters are stopped or faded by their owners
    **And** all following sounds, loops, deferred starts, and encounter-owned emitters terminate exactly once or idempotently
    **And** a permitted short detached one-shot survives only according to its explicit snapshot and scope policy
    **And** a fresh run cannot inherit a prior run's emitter, follow target, voice reservation, or callback.

20. **Reject stale audio requests and callbacks**

    **Given** a request or playback callback carries an invalid application session, level session, encounter run, execution, source, or request occurrence
    **When** it reaches an audio boundary
    **Then** it cannot start, stop, retarget, fade, or reprioritize current playback
    **And** expected stale work returns a bounded typed reason
    **And** no retained source reference prevents old gameplay objects from being released
    **And** stale stream completion cannot publish a current presentation result.

21. **Keep audio failure non-authoritative**

    **Given** a device is unavailable, an optional stream fails, a voice is rejected, or an emitter cannot be created
    **When** audio handling reaches a terminal result
    **Then** gameplay, encounter progression, checkpoint restoration, reward commitment, and application flow continue from their authoritative state
    **And** critical missing content detected before activation follows the manifest readiness policy rather than failing mid-combat silently
    **And** runtime presentation failure uses its declared fallback or a bounded warning
    **And** no gameplay owner waits for playback success.

22. **Expose bounded audio diagnostics**

    **Given** development audio diagnostics are enabled
    **When** cues are requested, accepted, rejected, started, followed, faded, stolen, or stopped
    **Then** diagnostics expose cue and request IDs, semantic reason, source and scope identities, spatial mode, selected bus, priority, concurrency group, voice result, fallback use, and terminal state
    **And** active voice and recent-request histories have explicit bounds
    **And** diagnostics consume maintained audio state rather than replaying arbitration or scanning the scene tree
    **And** disabling them stops formatting and capture while release behavior omits or disables the overlay.

23. **Make semantic audio manually reviewable**

    **Given** another developer follows the documented M3 audio procedure with the baseline mix
    **When** they traverse, grapple, use wall movement, attack, receive and avoid enemy attacks, activate and complete each encounter, collect and reject rewards, activate checkpoints, die, restart, pause, complete the level, and return to safe UI
    **Then** every required cue category can be deliberately heard and associated with its intended event
    **And** crowded combat demonstrates that local-player and imminent-telegraph cues survive representative voice pressure
    **And** encounter restart, checkpoint reload, level replacement, stale requests, muted categories, missing optional presentation, and repeated complete runs leave no stuck or duplicate audio
    **And** retained evidence separates objective request, identity, scope, residency, voice, cleanup, and settings results from subjective clarity, balance, fatigue, and mix observations.

24. **Verify audio contracts and smoke behavior**

    **Given** focused audio contract tests and real-scene smoke checks run
    **When** they exercise definition validation, request construction, bus routing, positional and non-positional playback, phase mapping, music state, ambience, voice arbitration, retrigger rules, settings application, run invalidation, stale callbacks, fallback behavior, and teardown
    **Then** one committed source occurrence produces at most the authored playback behavior and no rejected source produces a success cue
    **And** all loop and follow bindings terminate with their owning scope
    **And** missing required content blocks readiness while optional presentation failure remains gameplay-neutral
    **And** human review remains required for audibility, semantic distinction, priority, and fatigue.

25. **Remain gameplay-equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** equivalent M3 scenarios run at fixed 60 Hz and diagnostic 120 Hz
    **When** audio request and gameplay evidence are compared
    **Then** committed gameplay outcomes, semantic request occurrences, scope ownership, cancellation, and terminal request results are equivalent
    **And** different render or physics callback counts cannot duplicate cues or alter gameplay timing
    **And** audible presentation may vary only within authored randomization and playback-device tolerance
    **And** any simulation difference caused by audio blocks the story.

26. **Keep the story bounded to semantic audio integration**

    **Given** Story 7.10 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the M3 cue matrix, immutable cue definitions, typed requests, scoped playback roots, bus layout, voice policy, music states, ambience, placeholder assets, settings hooks, cleanup, diagnostics, and focused verification
    **And** it does not include final audio assets, external middleware, voice acting, procedural music, cinematic mixing, controller audio, persistent audio preferences, boss-specific content, or gameplay driven by sound playback
    **And** those concerns remain assigned to later stories or production work.
