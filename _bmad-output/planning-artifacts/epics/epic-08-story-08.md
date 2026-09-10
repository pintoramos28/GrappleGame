---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.8'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 8
---

# Story 8.8: Present the Garden Heart Fight Clearly

As a player,
I want the Garden Heart's state, attacks, openings, and escalation presented clearly,
So that I can make traversal-combat decisions from the game itself rather than from diagnostics.

**Acceptance Criteria:**

1. **Declare the focused boss-presentation outcome**

    **Given** the complete phased Garden Heart gameplay is available
    **When** the boss-presentation slice is inspected
    **Then** the fight communicates boss identity and health, current encounter and phase state, attack timing and affected space, actionable weak-point openings, successful and failed responses, phase transitions, and defeat through the approved HUD, world presentation, audio, animation, VFX, and camera seams
    **And** presentation consumes committed boss, ability, spatial, health, weak-point, encounter, and level-session state without becoming gameplay authority
    **And** primitive visuals and semantic placeholder audio make every critical state playable before final media exists
    **And** encounter activation, checkpoint recovery, reward, exit, final media production, and final balance remain outside this story.

2. **Approve the Garden Heart presentation extension before implementation**

    **Given** Story 7.1 reserved but did not define the major-encounter boundary
    **When** Story 8.8 begins
    **Then** a versioned Garden Heart extension to the approved HUD and presentation specification defines component inventory, state mappings, top-center layout, world-cue hierarchy, audio and music behavior, animation and VFX adapters, accessibility treatments, simultaneous-state priority, fallback behavior, and manual review procedure
    **And** its displayed facts trace to the approved Story 8.1 fight and Stories 8.4 through 8.7 runtime contracts
    **And** unresolved decisions are recorded and approved before their implementation rather than being invented by presenters
    **And** later aesthetic replacement cannot silently alter information meaning or gameplay behavior.

3. **Use the reserved major-encounter HUD boundary**

    **Given** the Garden Heart encounter is active
    **When** its major-target HUD appears
    **Then** the approved boss identity and health presentation occupy Story 7.1's reserved top-center or major-encounter region
    **And** exact anchors, maximum bounds, spacing, safe-area behavior, visibility rules, and transition behavior follow the approved extension
    **And** player health, grapple state, ability state, objective state, and urgent prompts remain readable
    **And** the component is hidden during ordinary encounters and whenever no valid major-target context is bound.

4. **Expose one typed read-only boss presentation context**

    **Given** the active boss encounter is ready to publish presentation state
    **When** its context is created
    **Then** it exposes stable level-session, encounter-run, boss-occurrence, boss-definition, and presentation-profile identities plus read-only current health, phase, transition, vulnerability, action, terminal, and availability state
    **And** discrete committed changes use typed scoped signals while continuous progress uses read-only authoritative snapshots
    **And** the context contains no methods for changing health, phases, actions, vulnerabilities, encounter state, rewards, or level progression
    **And** presenters cannot discover missing facts by scanning the scene tree or reading private boss fields.

5. **Bind and disconnect by current boss occurrence**

    **Given** the persistent UI can outlive levels, encounters, and boss attempts
    **When** a valid Garden Heart presentation context becomes available
    **Then** each boss HUD, world, audio, animation, VFX, and camera presenter binds once to its declared sources
    **And** encounter reset, boss replacement, level-session end, loading failure, or return to menu disconnects every old source and terminates occurrence-scoped presentation
    **And** a new occurrence begins from its complete current authoritative state rather than depending on missed historical signals
    **And** late updates from an invalid occurrence cannot alter the current presentation.

6. **Present boss identity and health without inventing combat state**

    **Given** a valid active Garden Heart exists
    **When** its committed health state changes
    **Then** the major-target component displays the approved player-facing name and current-to-maximum health relationship
    **And** accepted damage, rejected damage, restoration if permitted, zero health, unavailable state, and defeat receive their approved treatments
    **And** precise values are shown or hidden only according to the approved specification
    **And** bar smoothing, damage trails, animation, or audio cannot delay, duplicate, reject, or apply a health result.

7. **Communicate phase and transition state at the approved level of detail**

    **Given** the Garden Heart enters, transitions between, or exits approved phases
    **When** the player-facing presentation updates
    **Then** it communicates only the phase identity, escalation, transition warning, or changed demand that Story 8.1 approved for disclosure
    **And** it does not expose internal graph IDs, deterministic seeds, thresholds, action-selection history, or debug terminology
    **And** a phase transition remains understandable through more than a palette swap or hidden numerical change
    **And** presentation cannot initiate, defer, accelerate, or repeat the transition.

8. **Make actionable weak-point openings readable in the world**

    **Given** a boss-owned weak point becomes available, open, closing, closed, invalid, or destroyed
    **When** its presentation is rendered
    **Then** source-local shape, material, motion, outline, marker, and optional semantic audio communicate its current player-facing state according to the approved extension
    **And** the opening remains spatially associated with the authoritative weak-point owner and collision identity
    **And** its treatment distinguishes an actionable opening from decorative anatomy without relying on color alone
    **And** the HUD may summarize vulnerability only when approved but cannot replace the world-space location cue or decide damage eligibility.

9. **Drive attack telegraphs from authoritative ability space**

    **Given** any selected Garden Heart pressure enters windup, lock, active, recovery, cancellation, or completion
    **When** its world telegraph updates
    **Then** timing derives from the committed simulation-owned ability phase and affected geometry derives from the same authoritative spatial binding used by delivery
    **And** source, target or affected space, lock behavior, safe relationship, and end state remain readable at the level approved for that pressure
    **And** no presenter owns a duplicate warning timer, target predictor, raycast, shape calculation, or collision outcome
    **And** missing bespoke treatment uses the validated shape-family fallback presenter.

10. **Preserve clarity during approved pressure overlap**

    **Given** Story 8.7 allows two or more boss presentation occurrences to coexist
    **When** their warnings or active effects overlap
    **Then** source identity, affected-space boundaries, temporal order, and the viable player response remain distinguishable
    **And** layering, opacity, line treatment, motion, iconography, audio priority, and camera contribution follow an approved simultaneous-state matrix
    **And** one cue cannot visually erase another still-dangerous authoritative space
    **And** optional cosmetic density reduces before critical gameplay information is removed.

11. **Keep traversal and player survival information visible**

    **Given** the boss HUD and world effects are active during high-speed traversal
    **When** the player aims, grapples, attacks, wall-interacts, takes damage, or recovers
    **Then** the central reticle, grapple candidate and attachment feedback, player silhouette, critical health, immediate route geometry, and relevant ability state remain readable
    **And** boss presentation respects Story 7.1's central-action exclusion and notification priority
    **And** camera shake, flashes, particles, screen-space overlays, or transition banners cannot obscure a required response
    **And** subjective readability findings are recorded separately from authoritative-state correctness.

12. **Use semantic boss audio requests**

    **Given** a boss state or action has an approved audible cue
    **When** the corresponding committed fact occurs
    **Then** a presentation adapter submits an immutable semantic audio request carrying stable cue and occurrence identity, spatial or nonspatial mode, priority, concurrency group, retrigger policy, and scoped lifetime
    **And** actual streams may be placeholders or absent behind the same cue definition
    **And** repeated, cancelled, stale, or overlapping requests obey bounded voice and loop policies
    **And** audio playback, stream completion, or an animation marker cannot advance gameplay.

13. **Support replaceable phase music without requiring final tracks**

    **Given** the approved presentation extension calls for boss or phase music behavior
    **When** encounter activation, phase transition, defeat, pause, reset, or level exit occurs
    **Then** a presentation-only music adapter follows those committed states through declared transition, layering, fade, pause, and stop policies
    **And** a silent or placeholder implementation preserves the complete state contract when final music is unavailable
    **And** rapid transitions and retries cannot create duplicate tracks or retained playback
    **And** music state cannot select attacks, measure phases, open weak points, or commit completion.

14. **Provide future-ready animation and model adapters**

    **Given** final Garden Heart models, rigs, and animations are not currently available
    **When** boss body, action, transition, vulnerability, hit reaction, and defeat presentation is implemented
    **Then** a domain-owned adapter maps committed semantic gameplay states to replaceable model and animation presentation
    **And** the primitive fallback remains functional without a skeleton, named production clip, root motion, or animation event
    **And** later model or animation assets can be introduced by updating presentation profiles and adapters without changing phase timing, hit windows, collision identities, damage, movement, or encounter logic
    **And** animation markers may request cosmetic cues only.

15. **Provide future-ready VFX and material adapters**

    **Given** final boss VFX and materials are unavailable
    **When** telegraphs, attacks, weak points, transitions, hits, and defeat require visual treatment
    **Then** presentation adapters consume typed committed state and authoritative spatial snapshots through immutable visual cue definitions
    **And** primitive meshes, decals, lines, particles, lights, and material parameters provide bounded fallback treatment
    **And** later production effects can replace those cues without changing collision geometry, affected-space calculations, timing, or results
    **And** missing or failed optional effects degrade to the approved readable fallback rather than blocking gameplay.

16. **Keep camera response cosmetic and bounded**

    **Given** the specification approves camera emphasis for a boss event
    **When** that event commits
    **Then** the camera presenter may apply bounded framing, impulse, shake, field-of-view, or emphasis according to the approved accessibility and concurrency policies
    **And** it cannot change authoritative aim, player motion, target eligibility, affected geometry, or action timing
    **And** intense, repeated, and simultaneous requests are clamped or prioritized predictably
    **And** disabling optional camera motion leaves all critical state understandable through other cues.

17. **Support HUD and cue accessibility settings**

    **Given** UI scale, reticle size, reticle color, high contrast, and any approved reduced-motion or cue-intensity option are configured
    **When** the Garden Heart presentation is used
    **Then** boss HUD, weak points, telegraphs, transitions, captions or semantic text, and camera effects follow their documented setting behavior
    **And** health, vulnerability, danger, safe response, and completion remain distinguishable without color alone
    **And** changing a presentation setting cannot alter gameplay geometry, timing, targetability, damage, AI, or simulation frequency
    **And** unsupported optional settings are not implied by hidden diagnostic controls.

18. **Remain usable across approved Windows layouts**

    **Given** the boss fight runs at 1920 by 1080 and representative 16:10 and ultrawide layouts
    **When** normal, worst-case simultaneous, paused, damaged, transition, vulnerability, and defeat states are inspected
    **Then** anchors, containers, safe-frame limits, text behavior, and world-cue projection preserve the approved hierarchy
    **And** boss information does not overlap critical player HUD, clip, stretch, drift to unusable edges, or cover the central action area
    **And** UI scale and high-contrast variants remain within their approved bounds
    **And** any unsupported extreme layout fails visibly in the review rather than hiding critical facts.

19. **Handle pause, death, reset, and teardown explicitly**

    **Given** boss presentation is active
    **When** the game pauses, the player dies, the encounter resets, the boss dies, the level session ends, or application flow replaces the level
    **Then** each presenter follows its approved freeze, continue, cancel, fade, hide, or terminal treatment
    **And** looping sound, particles, trails, decals, camera requests, bars, markers, and transient notices terminate exactly once or idempotently
    **And** a new attempt cannot inherit smoothed health, phase banners, open markers, warning geometry, audio, or camera effects
    **And** no presentation callback can keep a destroyed gameplay source alive.

20. **Reject stale and duplicated presentation facts**

    **Given** a UI, world, audio, animation, VFX, or camera update belongs to an old level session, encounter run, boss occurrence, action execution, weak-point occurrence, or phase
    **When** it reaches a current presenter
    **Then** it cannot alter current presentation
    **And** duplicate discrete facts produce at most the already-established visual or audio occurrence
    **And** rejection remains bounded and does not grow histories or logs without limit
    **And** presentation state can always be rebuilt from the current valid context after rebinding.

21. **Keep diagnostics separate from player-facing cues**

    **Given** the fight is first evaluated as a player
    **When** diagnostics are disabled
    **Then** every required attack, affected space, response, weak-point opening, health change, phase transition, and defeat remains understandable through the approved player-facing presentation
    **And** enabling diagnostics may expose source IDs, bindings, phases, timing, geometry, cue requests, and stale rejections without changing those outcomes
    **And** diagnostic drawings and histories are bounded and stop when hidden
    **And** a diagnostic label, shape, or sound is never required to win.

22. **Make the complete presentation manually reviewable**

    **Given** another developer launches the named Garden Heart presentation fixture and integrated phased-fight fixture with diagnostics initially disabled
    **When** they follow the documented procedure
    **Then** they inspect every HUD, phase, action, weak-point, response, transition, overlap, damage, defeat, pause, death, reset, and teardown state using primitive or available presentation
    **And** they repeat the review at baseline, 16:10, ultrawide, high-contrast, scaled-UI, and approved reduced-motion or cue-intensity configurations
    **And** they intentionally remove optional animation, audio, model, and VFX assets and confirm readable fallbacks plus future replacement seams
    **And** retained evidence separates objective source agreement, state coverage, cleanup, layout, and boundedness from subjective clarity, comfort, spectacle, intensity, and satisfaction.

23. **Verify presentation contracts automatically**

    **Given** boss-context, HUD-binding, telegraph, audio, animation-adapter, VFX-adapter, camera, accessibility, and lifecycle tests run
    **When** they exercise every mapped state, valid and stale occurrence, duplicate fact, missing optional asset, phase transition, pressure overlap, pause, death, reset, boss defeat, level teardown, and repeated rebinding
    **Then** each presenter reflects only current committed state and releases all occurrence-scoped work
    **And** HUD layout state, audio voices, looping effects, camera requests, subscriptions, and presentation nodes remain within declared bounds
    **And** no presentation output changes gameplay authority or survives its scope
    **And** automation supplements rather than replaces human readability, accessibility, and audiovisual review.

24. **Preserve gameplay equivalence across presentation rates**

    **Given** the same deterministic boss sequence runs with normal presentation, presentation disabled, uncapped rendering where supported, shipping 60 Hz simulation, and diagnostic 120 Hz simulation
    **When** actions, warnings, weak points, phases, damage, and death resolve
    **Then** gameplay timing, spatial snapshots, selections, openings, health outcomes, and terminal results remain equivalent within documented tolerance
    **And** presentation interpolates current authoritative values without adding simulation updates or callbacks
    **And** visible and audible timing remains acceptably aligned to committed state at the supported presentation configurations
    **And** any authoritative difference blocks the story.

25. **Stay within the approved boss presentation allocation**

    **Given** the representative worst phase, approved overlap, full HUD, audio fallbacks, primitive effects, and camera presentation run on the selected minimum-spec PC
    **When** presentation cost and repeated attempts are profiled
    **Then** draw, particle, audio-voice, UI, memory, and lifecycle counts stay within Story 8.1's presentation allocation
    **And** optional cosmetic density follows the documented reduction order before critical cues are affected
    **And** no first-time synchronous combat load occurs
    **And** this evidence informs but does not replace Story 8.11's release-like full-slice gate.

26. **Keep the story bounded to boss presentation**

    **Given** Story 8.8 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the approved Garden Heart presentation extension, read-only context, major-target HUD, world telegraphs, weak-point cues, semantic audio and music behavior, future-ready animation and VFX adapters, bounded camera treatment, accessibility behavior, fallbacks, cleanup, and focused evidence
    **And** it does not add or alter boss mechanics, phases, damage rules, encounter activation, checkpoint behavior, objective completion, reward, exit, final media assets, persistent settings infrastructure, or final balance
    **And** encounter completion, reward, exit, performance sign-off, and full-slice replay remain assigned to Stories 8.9 through 8.12.
