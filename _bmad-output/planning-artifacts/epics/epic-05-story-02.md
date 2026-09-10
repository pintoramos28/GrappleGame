---
artifact_schema: 1
artifact_id: 'grapplegame.story.5.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 5
story: 2
---

# Story 5.2: Navigate a Bounded Spore Veil Without Losing Critical Cues

As a player,
I want a local visibility obstruction to reduce distant detail while preserving nearby geometry, threat warnings, and grapple feedback,
So that I can make informed movement decisions under partial information rather than being completely blinded.

**Acceptance Criteria:**

1. **Declare the visibility-obstruction gameplay question**

   **Given** the spore-veil prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player can navigate under reduced distant visibility by using proximity, movement, silhouettes, threat cues, audio, and grapple feedback
   **And** its placement, volume, windup, ramp, obstruction rule, preserved information, counters, recovery, grapple and wall interactions, gameplay-query policy, source-death policy, overlap policy, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains a bounded local visibility effect rather than a full-screen blind, damage cloud, accuracy debuff, or gameplay control effect.

2. **Author one immutable veil definition**

   **Given** the baseline spore-veil profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 5.0-metre cylindrical radius, 5.0-metre height, 0.75-second windup, 0.50-second active ramp-up, 6.0-second active duration, and final 1.0-second expiry warning
   **And** it declares a 4.0-metre near-clarity radius, 1.0-metre minimum obscuring segment length, 0.20-metre visual hysteresis band, and maximum 0.75 obstruction strength
   **And** it declares a 20.0-metre placement range, 8.0-second start-to-next-start cadence, one unresolved veil per source, `CANCEL_WITH_SOURCE` during windup, `PERSIST_AFTER_SOURCE` after active spawn, and a `PRESENTATION_ONLY` gameplay-query policy
   **And** these values remain authored configuration rather than literals in the action, volume, visibility resolver, fixture, or presenter.

3. **Keep occurrence and presentation state outside definitions**

   **Given** a veil execution or occurrence exists
   **When** its runtime state is inspected
   **Then** it records stable definition, execution, occurrence, source, target, volume, presentation-subject, and run identities; frozen spatial geometry; lifecycle times; ramp progress; source policy; and terminal reason
   **And** per-subject visual transition or hysteresis state remains presentation-owned and bounded
   **And** no runtime object mutates the shared ability, visibility, spatial-query, gameplay-query, or presentation definitions.

4. **Request the veil through the normal action boundary**

   **Given** the fixture or AI requests the spore-veil ability
   **When** the request reaches its action owner
   **Then** the owner validates source and target identity, action state, placement range, line of sight, cadence, unresolved-veil limit, run identity, definitions, effect bounds, and required resident assets before committing one execution
   **And** AI and fixture controls cannot place the veil, advance lifecycle timing, calculate visual obstruction, hide presentation subjects, or alter gameplay line of sight directly
   **And** rejected, duplicate, busy, invalid, and stale requests produce typed results without a partial preview or volume.

5. **Resolve one supported static placement**

   **Given** a valid target reference is available at placement lock
   **When** its current combat reference position is projected downward
   **Then** a named support query must find static floor-like geometry within 12.0 metres whose normal is within 20 degrees of world up
   **And** the complete five-metre-radius and five-metre-high cylinder must fit within the fixture's authored effect bounds
   **And** the support identity, base point, world-up orientation, dimensions, and tolerance are frozen in one authoritative spatial snapshot
   **And** unsupported, moving, steep, protected, out-of-bounds, or non-finite placement is rejected rather than moved to a hidden fallback.

6. **Preview the complete future veil**

   **Given** the execution is in its 0.75-second windup
   **When** primitive telegraph presentation observes the frozen snapshot
   **Then** it displays the complete future cylinder, its height, its boundary, and its activation timing
   **And** the cue uses a non-color-only edge, vertical structure, particulate pattern, or equivalent indicator
   **And** the preview remains non-solid, non-obscuring, non-damaging, and unable to modify any gameplay or presentation query
   **And** presentation cannot move, resize, or activate the volume independently.

7. **Create one detached visibility occurrence**

   **Given** windup completes with a valid source, spatial snapshot, and current run
   **When** active execution begins
   **Then** one completely configured veil occurrence is attached beneath the current fixture runtime root rather than beneath the source node
   **And** it receives the frozen geometry, authoritative lifecycle schedule, query policy, source-death policy, immutable definition, and stable identities before activation is published
   **And** spawn failure terminates the execution without a partial volume, hidden retry, or changed presentation subject
   **And** the active occurrence can complete without retaining the source node.

8. **Drive obstruction strength from simulation progress**

   **Given** the veil is within its first 0.50 active seconds
   **When** simulation-owned active elapsed time advances
   **Then** authoritative obstruction progress equals active elapsed time divided by 0.50 seconds, clamped from zero through one
   **And** maximum obstruction strength equals that progress multiplied by the configured 0.75 maximum
   **And** no obscuration exists before active start
   **And** render delta, particle density, animation playback, material time, or frame count cannot determine the authoritative ramp.

9. **Use one authoritative volume for presentation tests**

   **Given** the veil is active
   **When** a registered presentation subject is evaluated
   **Then** the visibility resolver uses the veil's frozen cylinder, current run, simulation-owned obstruction strength, current camera reference, and subject reference
   **And** the same geometry drives the visible veil boundary and camera-to-subject segment calculation
   **And** visual particles, material noise, mesh tessellation, camera interpolation, and rendered depth cannot redefine the affected volume
   **And** the resolver returns a typed observational result rather than hiding nodes directly.

10. **Calculate the obscuring view segment explicitly**

    **Given** a camera-to-subject segment intersects the active cylinder
    **When** the visibility resolver calculates the portion inside the volume
    **Then** it records the finite segment entry and exit positions and the resulting inside length
    **And** a subject beyond the near-clarity radius becomes eligible for obstruction only when at least 1.0 metre of its view segment lies inside the cylinder
    **And** a segment with 0.80 metres or less inside is ineligible after previously becoming unobstructed
    **And** the 0.20-metre hysteresis band preserves the previous presentation result to prevent edge flicker
    **And** invalid camera, subject, volume, or non-finite geometry returns a typed unobstructed failure result rather than hiding the subject.

11. **Keep nearby information clear**

    **Given** a registered subject lies within 4.0 metres of the player's authoritative camera reference
    **When** its view segment crosses any portion of the active veil
    **Then** the subject remains in the near-clarity presentation state
    **And** nearby collision geometry, ledges, walls, floors, the player body, and immediate movement contacts remain readable
    **And** the veil cannot reduce near-field clarity merely because the camera itself is inside the volume
    **And** near-clarity distance is measured from committed reference positions rather than apparent screen size.

12. **Obscure distant detail without complete opacity**

    **Given** an ordinary distant-detail subject lies beyond four metres and its view segment satisfies the obscuring-length rule
    **When** active obstruction presentation resolves
    **Then** its ordinary surface, texture, color, and fine-form detail may be reduced according to current obstruction strength
    **And** the resolved obstruction cannot exceed the configured 0.75 maximum
    **And** the veil cannot replace the complete screen with an opaque color, black frame, white frame, static image, or unrestricted post-process blind
    **And** sufficient contrast remains to perceive the veil's own boundary and a safe direction of travel.

13. **Preserve player and interface visibility**

    **Given** the camera is outside, entering, inside, or leaving the veil
    **When** visibility presentation is composed
    **Then** the player representation, crosshair, health and required state feedback, pause and settings interfaces, objective or fixture instruction text, and diagnostic controls remain unobstructed
    **And** the effect cannot alter camera position, rotation, field of view, exposure authority, input focus, or interface layout
    **And** final HUD design remains deferred to Epic 7 while primitive required feedback remains available.

14. **Preserve active threat warnings**

    **Given** a distant threat source or damaging space is partly obscured by the veil
    **When** its existing simulation-authored windup or active warning is presented
    **Then** the committed telegraph boundary, impact marker, attack-direction cue, and timing emphasis remain readable through or above the reduced-detail layer
    **And** the enemy's ordinary model detail may remain obscured
    **And** the veil cannot move, resize, delay, recolor into ambiguity, or suppress an authoritative threat warning
    **And** the focused fixture uses a non-damaging threat-cue probe rather than activating the later visibility-plus-melee combination.

15. **Preserve bounded enemy silhouettes and direction cues**

    **Given** an eligible enemy presentation subject is beyond the near-clarity radius and obscured
    **When** it is idle without a committed threat
    **Then** fine visual detail may be hidden without guaranteeing a continuous exact outline or position marker
    **And** when that enemy commits a threat, a bounded silhouette, source cue, or directional warning becomes visible for the authored warning interval
    **And** the cue communicates threat direction and approximate source region without eliminating the intended uncertainty
    **And** no permanent wallhack, always-visible target outline, or complete enemy identity reveal is introduced.

16. **Preserve audible threat information**

    **Given** an existing threat has an available primitive or final audio cue
    **When** its visual source lies inside or beyond the veil
    **Then** the visibility occurrence does not mute, replace, delay, spatially relocate, or otherwise modify that cue
    **And** the cue remains governed by its owning threat and audio presenter
    **And** missing final audio is represented by a documented primitive directional cue for manual testing rather than treated as a gameplay failure by itself.

17. **Preserve grapple acquisition and feedback**

    **Given** a valid or rejected grapple candidate lies inside or beyond the active veil
    **When** the player performs the ordinary crosshair-directed grapple query
    **Then** candidate selection, range, line of sight, eligibility, attachment point, response, and rejection reason remain governed by the existing grapple contracts
    **And** the active reticle result, selected-anchor outline or marker, attachment state, grapple direction, and maximum-distance feedback remain readable
    **And** the veil itself is neither grappleable nor a physics-query occluder
    **And** obscured non-selected anchors are not all revealed merely because grapple feedback is preserved.

18. **Keep gameplay line-of-sight unchanged**

    **Given** AI perception, attack targeting, damage-cover, projectile-clearance, grapple, or other gameplay queries intersect the veil
    **When** their named collision and line-of-sight profiles resolve
    **Then** the baseline `PRESENTATION_ONLY` veil contributes no blocker, candidate, range modifier, confidence modifier, or targetability change
    **And** existing solid geometry remains the only applicable obstruction under those profiles
    **And** gameplay systems cannot use visual opacity, material parameters, particle density, presentation-subject state, or camera results as authoritative line-of-sight facts
    **And** a future gameplay-blocking veil requires a separately approved typed query response and is outside this story.

19. **Restore visibility immediately when the segment clears**

    **Given** a previously obscured subject becomes near enough or its current camera-to-subject segment no longer satisfies the configured intersection rule
    **When** presentation resolves the next eligible update
    **Then** the subject returns to its ordinary presentation state without a gameplay status, delayed blind timer, or retained visibility penalty
    **And** permitted visual smoothing remains bounded and cannot continue beyond its documented presentation-only transition
    **And** leaving the veil's body volume is not by itself sufficient if the current view toward the subject still crosses the veil
    **And** moving laterally, moving closer, or gaining sufficient altitude can clear the actual view segment.

20. **Preserve traversal and cause no gameplay effect**

    **Given** the player enters, crosses, remains inside, or leaves the active veil
    **When** movement, collision, grapple, wall, attack, health, and status systems resolve
    **Then** the veil applies no damage, healing, velocity change, acceleration, friction, gravity change, grapple response, wall response, input suppression, attack modifier, target invalidation, or lingering status
    **And** it remains non-solid and cannot block the player, enemies, projectiles, or attacks
    **And** running out laterally, jumping or grappling above it, moving closer to a threat, and using nearby walls remain valid visibility-recovery choices.

21. **Prevent unresolved-veil stacking**

    **Given** the source already owns a windup or active baseline veil
    **When** it requests another
    **Then** the later request is rejected without refreshing, relocating, enlarging, strengthening, merging, or extending the existing occurrence
    **And** duplicate requests return the existing result or a typed duplicate rejection
    **And** the focused fixture permits only one unresolved visibility volume
    **And** overlapping veils, combined opacity, nested hysteresis, drifting fog, and visibility-plus-threat combinations remain outside this story.

22. **Apply source-death policy by lifecycle phase**

    **Given** the source dies or is removed during windup before active spawn
    **When** `CANCEL_WITH_SOURCE` resolves
    **Then** the preview cancels and no veil becomes active.

    **Given** the veil has spawned with `PERSIST_AFTER_SOURCE`
    **When** the source dies or is removed
    **Then** the detached occurrence continues its frozen geometry, lifecycle, obstruction progress, presentation results, and expiry without dereferencing the source node
    **And** source loss cannot clear, move, strengthen, weaken, or extend the veil.

23. **Clean up reset and scene exit correctly**

    **Given** the fixture resets, checkpoint reloads, or the scene exits during windup, ramp-up, active obstruction, expiry warning, source-independent persistence, or expiry
    **When** the old run is invalidated
    **Then** executions, veil occurrences, spatial snapshots, registered-subject results, hysteresis state, presentation changes, cues, cadence state, source references, and late callbacks are removed or rejected exactly once
    **And** every affected subject returns to its ordinary presentation state
    **And** no visibility result or source-independent veil survives into the fresh run.

24. **Keep visibility behavior configurable**

    **Given** an alternate valid definition changes radius, height, windup, ramp-up, duration, expiry warning, near-clarity radius, minimum obscuring length, hysteresis, maximum obstruction, placement range, cadence, query policy, overlap policy, or source-death policy
    **When** the same action, world-effect, visibility-resolver, and presentation implementations consume it
    **Then** placement, lifecycle, segment evaluation, visual response, diagnostics, and cleanup use the authored values without code changes
    **And** at least one alternate-profile test proves volume, timing, near clarity, segment threshold, and maximum obstruction are not hard-coded
    **And** gameplay line-of-sight blocking, complete blindness, aim disruption, hallucinations, enemy duplication, moving or spreading fog, overlapping veils, damage, movement effects, and final presentation remain outside this story.

25. **Provide replaceable primitive presentation and diagnostics**

    **Given** final fog materials, particles, animation, audio, and VFX are unavailable
    **When** targeting, windup, ramp-up, obstruction, near clarity, threat preservation, grapple feedback, source death, expiry, rejection, or reset occurs
    **Then** primitive translucent geometry, boundary rings, depth cards, silhouettes, direction indicators, reticle emphasis, state changes, and typed result displays communicate the mechanic
    **And** future fog shaders, particles, lighting, silhouettes, animation, audio, camera-compatible effects, and VFX can consume committed facts without controlling gameplay queries, lifecycle, or movement
    **And** diagnostics expose stable identities, frozen volume, lifecycle and ramp times, obstruction strength, camera and subject references, segment entry and exit, inside length, near-clarity result, hysteresis state, subject presentation response, query policy, source policy, run identity, and terminal reason.

26. **Make visibility counterplay manually reproducible**

    **Given** the named spore-veil fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can compare unobstructed and obscured distant detail, inspect a subject within the near-clarity radius, move across the segment threshold and hysteresis band, travel laterally out of the sight line, move closer, and gain altitude above the volume
    **And** they can observe the player, crosshair, nearby geometry, wall feedback, threat-cue probe, directional cue, and selected grapple feedback remaining readable while ordinary distant detail is reduced
    **And** they can target and use an anchor beyond the veil, verify gameplay line-of-sight probes remain unchanged, kill the source before and after spawn, test duplicate requests, reset during every lifecycle phase, and repeat the scenario
    **And** retained evidence distinguishes objective geometry, timing, segment classification, preserved feedback, query isolation, source independence, cleanup, and repeatability results from subjective observations about opacity, visual comfort, readability, uncertainty, near distance, and duration.

27. **Verify bounded visibility behavior**

    **Given** the permanent spore-veil suite and focused rendered fixture run
    **When** they exercise valid and invalid placement, cylinder boundaries, exact lifecycle and ramp times, camera positions inside and outside, near-clarity edges, segment-length thresholds, hysteresis transitions, multiple registered subject types, preserved threat and grapple cues, gameplay query isolation, source death before and after spawn, stale runs, randomized registration order, and repeated reset
    **Then** every eligible subject receives one deterministic typed presentation result, gameplay line-of-sight outcomes remain unchanged, and cleanup restores ordinary presentation without stale obstruction
    **And** the veil never produces complete-screen opacity or suppresses required player, threat, traversal, or grapple feedback
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time lifecycle and ramp timing, volume geometry, segment classifications, query isolation, source independence, terminal results, and cleanup within documented tolerances
    **And** the story has not implemented gameplay blindness, perception changes, overlapping or moving fog, damage, movement effects, visibility-plus-melee pursuit, other ability combinations, or final presentation.
