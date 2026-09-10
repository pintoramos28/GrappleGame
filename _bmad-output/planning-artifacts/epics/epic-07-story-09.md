---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.9'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 9
---

# Story 7.9: Present Gameplay State Through the Approved HUD

As a player,
I want the approved gameplay HUD to show the state that matters while I move and fight,
So that I can make traversal and combat decisions without relying on development diagnostics.

**Acceptance Criteria:**

1. **Implement the approved HUD contract without redesigning it**

    **Given** Story 7.1's versioned gameplay HUD specification is approved
    **When** Story 7.9 begins
    **Then** the implementation records the exact approved specification identity and version it follows
    **And** every implemented component, state, priority, transition, source mapping, placement, and interaction traces to that specification
    **And** a missing, superseded, or unapproved specification blocks implementation rather than allowing local invention
    **And** material design changes return through the HUD review boundary before implementation continues.

2. **Compose the HUD beneath persistent `UIRoot`**

    **Given** the application shell is running
    **When** the gameplay HUD scene is inspected
    **Then** one `GameplayHudHost` beneath persistent `UIRoot` owns the gameplay HUD instance
    **And** the HUD uses Godot `Control` scenes, shared `Theme` resources, containers, anchors, and approved safe-area rules
    **And** no HUD element is parented beneath the replaceable player, encounter runtime root, or level content scene
    **And** application system screens, pause presentation, transitions, and development diagnostics remain in their separate Story 7.1 layers.

3. **Bind one typed gameplay context at a time**

    **Given** a level session commits activation
    **When** `UIRoot` receives its `GameplayHudContext`
    **Then** the HUD validates the level-session identity, context version, required presentation sources, and supported state contracts before binding
    **And** it reads one coherent initial snapshot before subscribing once to typed committed-change signals
    **And** replacing or leaving the level disconnects every old source before another context binds
    **And** a missing required source produces the approved unavailable or safe system state rather than private node-path discovery.

4. **Present current player health in the lower-left region**

    **Given** the active context supplies authoritative health state
    **When** current health, maximum health, damage, healing, death, or checkpoint restoration changes
    **Then** the lower-left health component presents the approved bar and precise value treatment
    **And** normal, recently damaged, recently healed, low-health, zero-health, restored, and unavailable states follow Story 7.1's state table
    **And** damage and healing feedback reflects committed health results rather than predicted values
    **And** its animation cannot delay, repeat, or alter health application or death.

5. **Present authoritative grapple targeting centrally**

    **Given** the current grapple-targeting result changes
    **When** the central reticle and optional world marker update
    **Then** they distinguish no candidate, eligible, rejected, out-of-range, blocked or unavailable, attaching, attached, and connection-ending states as approved
    **And** rejection feedback maps typed gameplay reasons to concise player-facing categories
    **And** range, attachment, and candidate presentation consumes the authoritative targeting snapshot and physics-step identity
    **And** neither presenter performs another raycast, chooses a target, fabricates attachment, or changes grapple state.

6. **Present player ability state in the lower-right region**

    **Given** the active player exposes approved ability presentation sources
    **When** grapple, melee, or another M3 player ability enters ready, windup, active, recovery, cooldown, unavailable, cancelled, or restored state
    **Then** the lower-right component shows the applicable phase or cooldown using Story 7.1's priority and format
    **And** continuous cooldown fill is derived from committed elapsed and duration values while discrete transitions remain signal-driven
    **And** a 2.0-second diagnostic melee definition remains visibly distinguishable from production attack tuning only when that variant is deliberately active
    **And** HUD timing never becomes an ability clock or terminal-result authority.

7. **Present encounter and objective state in the upper-left region**

    **Given** the M3 level flow advances
    **When** the player approaches, commits to, fights, completes, bypasses, or leaves an encounter stage
    **Then** the upper-left component communicates the current objective and relevant encounter state using approved player-facing language
    **And** required lower, optional branch, required upper, route rejoin, and level-completion states remain distinguishable
    **And** participant counts or internal lifecycle detail appear only when approved for normal presentation rather than leaking diagnostics
    **And** the component consumes `LevelController` and encounter projections without advancing either owner.

8. **Present checkpoint and reward feedback in the upper-right region**

    **Given** a checkpoint activates or a Story 7.8 reward changes
    **When** the upper-right presentation updates
    **Then** it shows the current coin total persistently according to the approved contract
    **And** checkpoint activation, health gained, coins gained, full-health rejection, and other approved reward notices appear as bounded transient feedback
    **And** repeated duplicate or stale facts cannot restart the same notice or change displayed totals
    **And** presentation distinguishes a committed reward from an available but uncollected pickup.

9. **Show current keyboard-and-mouse prompts**

    **Given** the player reaches a context with an approved prompt
    **When** the lower-center prompt becomes eligible
    **Then** it displays concise action text plus the current primary keyboard or mouse binding supplied by the input presentation boundary
    **And** grapple, attack, jump, optional-route, reward, checkpoint-recovery, and other approved M3 prompts obey the specification's eligibility and dismissal rules
    **And** a changed binding can refresh the prompt without changing its gameplay condition
    **And** raw action IDs, device codes, or stale factory bindings are not shown to the player.

10. **Respect the approved information hierarchy**

    **Given** health danger, grapple choice, ability state, encounter progress, reward feedback, checkpoint notice, and a prompt could appear together
    **When** priority and available screen space are resolved
    **Then** immediate grapple, critical-health, and urgent ability information retains highest gameplay priority
    **And** objective and encounter state remains persistent but less intrusive
    **And** lower-priority prompts and transient notices queue, coalesce, defer, or expire through the approved policy
    **And** no combination substantially obscures the reticle, player silhouette, nearby threat, or intended traversal route.

11. **Drive discrete UI changes from committed facts**

    **Given** a presentation source exposes typed current state and committed changes
    **When** the HUD refreshes
    **Then** discrete candidate, phase, health, encounter, objective, checkpoint, reward, and prompt changes are signal-driven
    **And** the HUD does not continuously inspect the scene tree, poll gameplay nodes, or duplicate gameplay calculations
    **And** continuous bar, range, and cooldown interpolation may smooth the latest authoritative values only
    **And** interpolation never extends eligibility, preserves stale state, or changes a terminal result.

12. **Handle gameplay-unavailable states explicitly**

    **Given** the application is loading, preparing a level, replacing a session, showing recovery choices, paused, leaving play, or in a safe no-level state
    **When** normal gameplay presentation is unavailable
    **Then** `GameplayHudHost` enters the approved neutral, transition, recovery, paused, or hidden state
    **And** stale last-known health, target, ability, encounter, reward, or prompt values are not presented as current
    **And** system-screen and pause layers may cover or replace HUD interaction according to the approved layer policy
    **And** returning to active gameplay requires a valid current context rather than merely revealing cached controls.

13. **Reject stale presentation updates**

    **Given** a delayed update belongs to an invalidated level session, encounter run, player, ability execution, checkpoint transaction, or reward occurrence
    **When** it reaches the HUD boundary
    **Then** its stable identities fail currentness validation
    **And** it cannot change any visible gameplay state or replay a transient notice
    **And** expected stale rejection is bounded and does not retain the old source
    **And** a fresh level session begins from its own coherent initial snapshot.

14. **Scale across the approved Windows aspect ratios**

    **Given** the HUD is tested at 1920x1080 plus representative 16:10 and ultrawide resolutions
    **When** anchors, containers, safe areas, and scale constraints resolve
    **Then** all required components remain visible, non-overlapping, and readable
    **And** the central reticle remains aligned with canonical gameplay aim rather than the cropped or stretched viewport edge
    **And** text and icons do not become clipped, disproportionately stretched, or positioned outside safe bounds
    **And** pixel-perfect equality across aspect ratios is not required when the approved relational layout is preserved.

15. **Consume accessibility and presentation settings through typed values**

    **Given** default or runtime UI-scale, reticle-size, reticle-color, and high-contrast values are supplied
    **When** the HUD applies them
    **Then** affected components update within approved ranges without scene reconstruction or gameplay mutation
    **And** high contrast applies the approved alternate theme treatment rather than a post-process that obscures world telegraphs
    **And** critical distinctions retain shape, text, position, motion, or fill differences in addition to color
    **And** Story 7.12 may persist and edit these values without changing this presentation contract.

16. **Keep the HUD from intercepting gameplay input**

    **Given** no modal system or pause screen is open
    **When** the player aims, moves, attacks, grapples, or uses another gameplay action over a HUD element
    **Then** non-interactive HUD controls ignore mouse input and cannot take keyboard focus
    **And** the cursor remains captured according to the active gameplay input context
    **And** HUD transitions cannot emit synthetic gameplay presses or releases
    **And** modal input ownership remains assigned to system, pause, settings, or rebinding screens.

17. **Keep presentation work bounded**

    **Given** the HUD is visible during representative traversal and combat
    **When** profiling inspects its update behavior
    **Then** dormant elements stop per-frame formatting, hidden transitions stop advancing, and duplicate values do not rebuild controls unnecessarily
    **And** histories, transient-notice queues, animation instances, and cached labels have explicit bounds
    **And** no gameplay source is retained after unbinding
    **And** the HUD introduces no synchronous content load during combat.

18. **Support future presentation assets without changing gameplay**

    **Given** production icons, animations, VFX, and refined typography are not yet available
    **When** the HUD uses primitive fallback assets
    **Then** every required state remains readable and manually testable
    **And** future presenters can replace approved visual adapters and theme assets while continuing to consume the same typed state
    **And** animation markers, visual completion, and VFX events cannot create or terminate gameplay state
    **And** a missing optional asset uses the approved fallback and warns once.

19. **Expose bounded HUD diagnostics**

    **Given** development HUD diagnostics are enabled
    **When** binding or presentation behavior is inspected
    **Then** diagnostics expose current context and level-session identities, source availability, last accepted state versions, active component states, notice-queue counts, stale rejections, aspect profile, and applied accessibility values
    **And** they distinguish authoritative values from interpolated display values
    **And** they remain read-only and perform no duplicate targeting, cooldown, health, encounter, or reward computation
    **And** hidden diagnostics stop formatting and remain unavailable or disabled in release behavior.

20. **Make the implemented HUD manually reviewable**

    **Given** another developer launches the M3 level with the Story 7.1 review checklist
    **When** they traverse both route choices, target valid and invalid grapple surfaces, use abilities, take and recover health, activate encounters and checkpoints, collect and reject rewards, die, restart, pause, and replace the level session
    **Then** every approved state and transition can be deliberately produced without a debug-only shortcut being required for the core path
    **And** a worst-case simultaneous-state setup demonstrates the information hierarchy and clear central action area
    **And** 1920x1080, 16:10, and ultrawide captures demonstrate relational layout and accessibility treatments
    **And** retained evidence separates objective source agreement, binding, stale rejection, bounds, and state coverage from subjective legibility, clutter, timing, and feel observations.

21. **Verify HUD contracts and smoke behavior**

    **Given** focused HUD contract tests and representative UI smoke scenes run
    **When** they exercise initial binding, every state table, signal updates, interpolation, context replacement, missing sources, stale facts, transient coalescing, input pass-through, setting application, and supported aspect profiles
    **Then** displayed discrete state agrees with authoritative source snapshots and one source change produces at most one corresponding presentation transition
    **And** no HUD interaction changes gameplay state or emits an application command outside its declared narrow output
    **And** old contexts and signal connections are released after replacement
    **And** human review remains required for hierarchy, readability, motion, and clutter rather than being replaced by pixel-perfect screenshot assertions.

22. **Remain simulation-neutral at 60 Hz and diagnostic 120 Hz**

    **Given** equivalent M3 gameplay scenarios run at fixed 60 Hz and diagnostic 120 Hz
    **When** HUD results are compared
    **Then** authoritative health, grapple, ability, encounter, objective, checkpoint, reward, and prompt outcomes remain equivalent
    **And** presentation may interpolate at render rate without changing the physics-step state it describes
    **And** no HUD timer or animation advances gameplay or changes a terminal outcome
    **And** any simulation difference caused by HUD presence blocks the story.

23. **Keep the story bounded to approved gameplay HUD implementation**

    **Given** Story 7.9 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it contains the approved gameplay HUD scene, active-context binding, health, grapple, ability, encounter, objective, reward, checkpoint, and prompt presentation, responsive layout, accessibility hooks, fallback assets, diagnostics, and focused verification
    **And** it does not redesign the HUD, implement persistent settings storage, input rebinding, pause behavior, production art, production animation or VFX, production audio, inventory, narrative UI, controller support, or boss-specific presentation
    **And** those concerns remain assigned to later stories or later production work.
