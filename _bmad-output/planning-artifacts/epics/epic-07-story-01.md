---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 1
---

# Story 7.1: Define and Approve the Gameplay HUD Contract

As a player,
I want critical traversal, combat, encounter, and reward information arranged through a clear and consistent HUD,
So that I can understand my immediate options and progress without the interface obscuring the action.

**Acceptance Criteria:**

1. **Create one versioned gameplay HUD specification**

   **Given** Epic 7 begins before production HUD implementation
   **When** the gameplay HUD specification is created
   **Then** it records a stable specification identity and version, design owner, approval state, supported resolutions and settings, information hierarchy, screen layout, component inventory, state tables, source mappings, transition rules, wireframes, manual review procedure, and explicit exclusions
   **And** it traces player health, grapple feedback, player ability phases or cooldowns, encounter state, keyboard-and-mouse prompts, reward feedback, and applicable NFR requirements
   **And** unresolved design decisions are visible and prevent approval rather than being left for implementation stories to invent
   **And** later HUD changes produce a new reviewed version rather than silently changing the approved contract.

2. **Define the HUD's information priority**

   **Given** several gameplay facts may be visible simultaneously
   **When** their visual priority is documented
   **Then** immediate action information—grapple targeting, attachment state, critical health, and urgent ability state—receives the highest HUD priority
   **And** current encounter or objective state receives persistent but less intrusive priority
   **And** prompts, rewards, checkpoint notices, and explanatory messages remain transient or context-dependent
   **And** decorative information cannot compete with a current threat, grapple decision, health emergency, or required objective update.

3. **Establish one baseline screen layout**

   **Given** the HUD is authored against a 1920-by-1080 reference frame
   **When** its baseline annotated wireframe is inspected
   **Then** authoritative grapple targeting and attachment feedback occupy the central reticle region
   **And** player health occupies the lower-left region, while player ability phase and cooldown information occupies the lower-right region
   **And** the current objective and encounter state occupy the upper-left region, while coin, reward, and checkpoint feedback occupy the upper-right region
   **And** temporary keyboard-and-mouse prompts occupy a lower-center region without covering the reticle, player silhouette, health, or ability information
   **And** exact anchors, offsets, maximum bounds, alignment, spacing, and safe-area rules are recorded for every region.

4. **Keep the center of play visually clear**

   **Given** traversal and combat depend on aiming and reading three-dimensional motion
   **When** persistent HUD elements are placed
   **Then** only the reticle, immediate grapple state, and a deliberately approved short contextual message may occupy the central action area
   **And** health, cooldowns, objectives, rewards, and persistent text remain outside that area
   **And** world-space enemy telegraphs, grapple markers, and route geometry remain readable through the HUD
   **And** the worst-case simultaneous-state wireframe demonstrates that the player and immediate traversal path are not substantially obscured.

5. **Define every player-health presentation state**

   **Given** the health component can expose current health, maximum health, accepted change, rejected change, death, and restoration
   **When** the health HUD state table is inspected
   **Then** it defines normal, recently damaged, recently healed, low-health, zero-health, unavailable, and restored states
   **And** the lower-left presentation communicates current and maximum health through a stable bar plus an approved numeric or equivalent precise reading
   **And** damage, healing, and critical-health feedback use motion, shape, value, or text in addition to color
   **And** presentation timing cannot delay, cancel, duplicate, or otherwise change the authoritative health result.

6. **Define the authoritative grapple-reticle states**

   **Given** grapple targeting exposes candidate identity, hit position, surface normal, validity, rejection reason, range fraction, attachment state, and result physics step
   **When** the grapple presentation table is completed
   **Then** it defines visually distinct states for no candidate, eligible candidate, rejected candidate, out-of-range candidate, blocked or otherwise unavailable candidate, attaching, attached, and connection-ending feedback
   **And** every authoritative rejection reason is mapped to a player-facing visual category and, where useful, a concise explanation rather than exposing raw enum or debug text
   **And** range and attachment feedback remain readable without requiring diagnostics
   **And** shape, motion, fill, line treatment, or text distinguishes critical states without relying only on reticle color.

7. **Keep grapple feedback aligned with authoritative targeting**

   **Given** a current grapple-targeting result is available
   **When** the reticle and any world-space marker update
   **Then** they consume that result rather than performing another raycast or deciding validity independently
   **And** discrete candidate, validity, rejection, and attachment changes are signal-driven
   **And** continuous visual interpolation may smooth position, range, or progress only after the authoritative state is known
   **And** visual easing cannot delay eligibility, preserve a stale target, fabricate attachment, or contradict the physics-step result.

8. **Define player-ability phase and cooldown presentation**

   **Given** the active player ability set exposes authoritative availability and lifecycle state
   **When** the lower-right ability region is specified
   **Then** each displayed ability can communicate ready, requested, windup, active, recovery, cooldown, unavailable, cancelled, and disabled-by-death states where those states apply
   **And** phase progress and cooldown remaining use simulation-authored values rather than HUD timers or animation completion
   **And** an ability without a meaningful cooldown or persistent status does not receive a misleading empty meter
   **And** the component inventory supports the approved player abilities without inventing a full RPG hotbar or displaying unimplemented abilities.

9. **Distinguish player state from enemy telegraphs**

   **Given** enemy abilities communicate windup and affected space through world presentation
   **When** the HUD composition is reviewed
   **Then** the player-ability region reports only player-owned ability state unless a separately approved encounter component explicitly requires otherwise
   **And** enemy timing remains communicated primarily by the enemy and authoritative world-space telegraph
   **And** the HUD does not reproduce every enemy timer, target, or affected-space calculation
   **And** encounter-level urgency may be summarized without becoming a second enemy-ability authority.

10. **Define encounter and objective presentation**

    **Given** a level may contain inactive, available, required, optional, active, completed, failed, or resetting encounter and objective states
    **When** the upper-left state table is inspected
    **Then** it defines which state is persistent, announced transiently, hidden, replaced, or queued
    **And** required and optional content remain distinguishable without relying on color alone
    **And** objective wording identifies the player's current goal without exposing internal node names, run identities, or debug state
    **And** participant counts, progress values, or completion conditions are displayed only when the encounter controller explicitly exposes them through the approved presentation context.

11. **Reserve the major-encounter presentation boundary**

    **Given** Epic 8 will introduce the Garden Heart boss
    **When** the top-center and encounter regions are planned
    **Then** the specification records where an approved major-target or boss presentation could appear without displacing critical health, grapple, ability, or objective information
    **And** Epic 7 does not invent boss health, phases, vulnerabilities, or final boss UI behavior
    **And** the reserved boundary remains optional and hidden during ordinary non-boss encounters
    **And** its later implementation must still consume authoritative encounter or boss presentation sources.

12. **Define reward and checkpoint feedback**

    **Given** the player can receive health or coin rewards and reach checkpoints
    **When** the upper-right transient-feedback table is completed
    **Then** it defines committed coin-total changes, health-reward feedback, reward pickup confirmation, checkpoint activation, duplicate or rejected grant behavior, and restoration after restart where applicable
    **And** the HUD presents only committed results from their authoritative owners
    **And** it does not grant currency, heal the player, activate a checkpoint, or infer success from collision or animation
    **And** transient notices have explicit priority, replacement, queueing, and expiry rules that prevent unbounded message buildup.

13. **Define contextual keyboard-and-mouse prompts**

    **Given** gameplay may need short movement, grapple, attack, interaction, checkpoint, restart, or pause guidance
    **When** the prompt contract is inspected
    **Then** every prompt declares its authoritative context, semantic action, display priority, suppression rules, dismissal rule, and maximum visible duration where applicable
    **And** displayed keys or mouse inputs resolve from the current InputMap binding rather than hard-coded labels
    **And** primary and alternate bindings follow one documented display policy
    **And** the prompt system includes no controller glyphs, controller navigation, rumble, or device-switching behavior.

14. **Keep prompts independent of the disposable tutorial level**

    **Given** the existing tutorial level does not need to be preserved
    **When** prompt ownership is designed
    **Then** prompt definitions and presentation are reusable by any authored level or encounter that provides the required context
    **And** no HUD component depends on the current tutorial scene's node paths, triggers, geometry, or ordering
    **And** recreating or removing that level cannot remove the underlying prompt capability
    **And** future tutorial sequencing remains level or objective logic rather than HUD-owned progression.

15. **Define one typed read-only HUD context**

    **Given** the active level supplies presentation state to the persistent `UIRoot`
    **When** the `GameplayHudContext` contract is specified
    **Then** it identifies the typed read-only source for health, grapple, player abilities, encounter and objective state, prompts, rewards, and checkpoints
    **And** every source declares its current-state read, typed change signals, availability state, stable session identity, and disconnect behavior
    **And** the mapping table identifies which HUD component consumes each field and how absent optional sources are presented
    **And** the HUD cannot discover gameplay state by scanning the scene tree, reading private actor fields, or issuing independent physics queries.

16. **Keep the HUD presentation-only**

    **Given** any gameplay HUD component receives a state update or player interaction occurs elsewhere
    **When** the component responds
    **Then** it may update visual state, accessibility treatment, animation, or presentation audio requests only
    **And** it cannot change health, select a grapple target, start or cancel an ability, advance an encounter, grant a reward, activate a checkpoint, alter input bindings, pause simulation, or reset gameplay
    **And** pause, settings, resume, and return-to-menu remain narrow UI commands owned by their later system-screen stories
    **And** development controls remain in the separate `DebugOverlayLayer`.

17. **Bind and disconnect by active level session**

    **Given** `UIRoot` persists while levels can be loaded, replaced, failed, or unloaded
    **When** a valid level session supplies a `GameplayHudContext`
    **Then** `GameplayHudHost` binds once to that context and displays its declared initial state
    **And** replacing or ending the session disconnects every old source before the next context is accepted
    **And** unavailable or failed level state produces the approved neutral or hidden HUD presentation rather than stale gameplay data
    **And** late signals from an invalid session cannot change the current HUD.

18. **Define simultaneous-state and notification priority**

    **Given** low health, a grapple rejection, an active ability phase, an objective update, a reward notice, and a contextual prompt may occur together
    **When** the simultaneous-state matrix is reviewed
    **Then** every persistent and transient component has a declared layering, priority, suppression, replacement, and queueing rule
    **And** immediate traversal and survival information remains visible
    **And** lower-priority notices defer, collapse, or expire according to bounded rules rather than stacking indefinitely
    **And** no ordering depends on signal arrival, scene-tree order, or animation completion.

19. **Specify pause, transition, and system-screen layering**

    **Given** `UIRoot` contains system screens, gameplay HUD, pause, transition, and debug layers
    **When** their presentation relationship is documented
    **Then** the specification defines which HUD elements remain visible, dim, freeze visually, or hide during pause, loading transition, level failure, death, restart, return to menu, and debug inspection
    **And** system and transition screens can cover gameplay without destroying HUD state
    **And** the debug overlay cannot displace or become required for the production HUD
    **And** detailed pause, settings, loading, death, and menu interactions remain assigned to their owning implementation stories.

20. **Support the required aspect ratios**

    **Given** the baseline layout is approved at 1920 by 1080
    **When** responsive wireframes are rendered at representative 16:10 and ultrawide Windows aspect ratios
    **Then** anchors, containers, safe-frame rules, maximum widths, and alignment preserve the intended information hierarchy
    **And** persistent elements do not drift to unusably distant physical edges, overlap each other, stretch incorrectly, or cover the central action region
    **And** text wrapping, truncation, icon placement, and transient-message bounds have explicit behavior
    **And** unsupported extreme layouts fail the review visibly rather than silently clipping critical information.

21. **Define the four required accessibility settings**

    **Given** the HUD must support UI scale, reticle size, reticle color, and a high-contrast setting
    **When** their design behavior is specified
    **Then** each setting has an explicit supported range or option set, default, preview behavior, persistence owner, and affected components
    **And** UI scale preserves layout and safe-frame behavior rather than scaling around arbitrary screen positions
    **And** reticle size and color affect presentation without changing targeting geometry, query range, or eligibility
    **And** high contrast has documented treatments for text, panels, outlines, health, grapple states, cooldowns, prompts, and notifications.

22. **Do not rely on color alone**

    **Given** normal and high-contrast variants are inspected
    **When** critical HUD states are compared
    **Then** health urgency, grapple validity, rejection, attachment, ability readiness, cooldown, required versus optional objectives, and success versus failure each have a non-color distinction
    **And** the specification declares icon, shape, line, fill, motion, value, or text treatments for those distinctions
    **And** reticle-color customization cannot make valid and invalid states visually identical
    **And** primitive fallback assets remain sufficient to conduct the review before final art exists.

23. **Define presentation motion without creating gameplay clocks**

    **Given** HUD components may animate damage, healing, attachment, cooldown progress, objective updates, rewards, or checkpoint notices
    **When** their motion and transition rules are specified
    **Then** gameplay state and phase progress always come from the authoritative source
    **And** visual interpolation may smooth continuous values but cannot delay or extend the underlying result
    **And** interrupt, replacement, pause, session loss, and reset behavior is defined for every looping or transient presentation
    **And** animation callbacks cannot advance gameplay, grant rewards, complete encounters, or decide when an ability becomes available.

24. **Use replaceable visual and audio presentation**

    **Given** final HUD art, animation, audio, and VFX are unavailable
    **When** the approved wireframes and state gallery are produced
    **Then** shared theme tokens, primitive panels, bars, shapes, icons, text, and optional placeholder audio requests communicate every required state
    **And** the specification identifies replaceable presentation seams for later typography, icons, materials, animation, audio, and effects
    **And** replacing those assets cannot change source mapping, state interpretation, layout ownership, or gameplay behavior
    **And** missing optional presentation uses a documented fallback rather than hiding critical information or blocking the session.

25. **Provide annotated wireframes and a state gallery**

    **Given** the component and state specifications are complete
    **When** the review bundle is opened
    **Then** it contains annotated baseline, 16:10, and ultrawide wireframes plus focused views for health, grapple, abilities, encounter state, prompts, rewards, checkpoints, accessibility variants, system layering, and worst-case simultaneous presentation
    **And** a named HUD state gallery allows another developer to view every state and transition using static or fixture-provided presentation data
    **And** gallery data is visibly marked non-authoritative and cannot enter gameplay systems
    **And** every wireframe annotation references its component, source field, state, layout rule, and unresolved or approved design decision.

26. **Make the design manually reviewable**

    **Given** another developer launches the named HUD state gallery and opens the specification
    **When** they follow the documented review procedure
    **Then** they can inspect every component state with diagnostics absent, cycle the four accessibility settings, and view baseline, 16:10, and ultrawide layouts
    **And** they can exercise the worst-case simultaneous state, long prompt and objective text, missing optional sources, session replacement, pause layering, death or restart layering, and transient-notification priority
    **And** objective checks record missing states, overlaps, clipping, stale data, color-only distinctions, incorrect binding labels, source mismatches, and unbounded queues
    **And** subjective observations about hierarchy, clutter, readability, placement, timing, and visual comfort remain recorded separately.

27. **Approve a complete implementation handoff**

    **Given** the specification, mappings, wireframes, state gallery, and manual review evidence are complete
    **When** the designated design owner evaluates Story 7.1
    **Then** every required component and state is approved or explicitly removed from scope
    **And** all blocking design questions have a recorded decision
    **And** the handoff identifies bounded later implementation units for HUD context integration, health and grapple presentation, ability and encounter presentation, prompts and rewards, settings behavior, and verification
    **And** later implementation stories may refine replaceable visual treatment but cannot invent contradictory information hierarchy, state meaning, or interaction ownership without a versioned design update.

28. **Keep the story bounded to HUD definition**

    **Given** Story 7.1 is reviewed for completion
    **When** its artifacts and changes are inspected
    **Then** it contains only the gameplay HUD specification, source and state mappings, annotated wireframes, design-only state gallery, manual review evidence, and approved implementation handoff
    **And** it has not implemented the production HUD, encounter lifecycle, level loading, objectives, rewards, checkpoints, death and restart, pause or settings behavior, input remapping, production audio, boss UI, final art, or gameplay authority
    **And** those concerns remain assigned to later Epic 7 and Epic 8 stories.
