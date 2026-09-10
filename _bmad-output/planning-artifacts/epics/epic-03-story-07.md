---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.7'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 7
---

# Story 3.7: Break a Harpoon Tether Without Losing Traversal Control

As a player,
I want a harpoon tether to visibly pull me until I evade it, break the link, or recover through movement,
So that being caught creates a readable movement problem without silently taking away my traversal tools.

**Acceptance Criteria:**

1. **Declare the tether gameplay question**

   **Given** the harpoon prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player avoids the delivery or uses movement and cover to escape a sustained pull
   **And** its counters, recovery options, grapple and wall interactions, link limits, source-death policy, reset behavior, tuning questions, manual procedure, and required evidence are explicit
   **And** it remains a focused Target-Owned Status or Link representative rather than a production enemy ability.

2. **Reuse the established lane-delivery contracts**

   **Given** Story 3.4 has established a telegraph-aligned swept projectile
   **When** the harpoon attack is authored
   **Then** it reuses the shared lifecycle, spatial binding, warning, projectile spawning, swept collision, cover-blocking, attribution, and impact contracts
   **And** it uses distinct harpoon definitions rather than changing the approved direct-lane prototype
   **And** it does not introduce another projectile framework.

3. **Author one immutable harpoon-link definition**

   **Given** the representative link profile is inspected
   **When** its configured values are resolved
   **Then** it declares a 4.0-second active duration, a final 1.0-second expiry warning, 8.0 metres-per-second-squared pull acceleration, a 5.0 metres-per-second inward relative-speed cap, a 24.0-metre break length, and a 0.25-second continuous-occlusion break time
   **And** it declares a maximum of one active harpoon link on the target, rejection rather than refresh as its reapplication policy, and `CANCEL_WITH_SOURCE` as its source-death policy
   **And** these remain provisional authored parameters rather than hard-coded balance values.

4. **Separate configuration from link occurrence state**

   **Given** a harpoon link is created
   **When** its recipient-owned runtime state is inspected
   **Then** it records a stable occurrence identity, definition reference, recipient, source and execution attribution, current run, source-anchor binding, lifecycle times, occlusion state, motor-submission state, and terminal reason
   **And** mutable timers and break state never modify the shared definition Resource
   **And** the recipient's effect owner, rather than the projectile, enemy AI, motor, or presenter, owns the active link.

5. **Create a link only from an accepted harpoon impact**

   **Given** the harpoon projectile reaches a candidate contact
   **When** the authoritative swept query resolves
   **Then** a link request is produced only for one accepted impact against an eligible living player
   **And** a miss, cover impact, duplicate hurtbox, rejected target, stale run, invalid source, or malformed impact cannot create a link
   **And** the baseline harpoon impact does not reduce health, allowing the link behavior to be evaluated independently from damage.

6. **Make pre-attachment counterplay authoritative**

   **Given** the harpoon is tracking, locked, or travelling
   **When** the player crosses the committed lane or eligible cover intercepts the projectile
   **Then** the projectile misses or terminates through the existing lane-delivery rules and no link is created
   **And** grappling, jumping, wall traversal, and ordinary movement remain available as avoidance methods
   **And** source death before attachment cancels the harpoon delivery under its declared policy.

7. **Resolve a moving source anchor through a typed snapshot**

   **Given** an accepted impact creates a link to a living source
   **When** each physics step begins
   **Then** the link reads a finite current anchor position and velocity through its typed source-anchor binding
   **And** it calculates distance, direction, and relative velocity from already-committed source and recipient facts
   **And** it does not reconstruct the anchor from presentation geometry, an animation socket, or an unvalidated arbitrary node transform.

8. **Pull through a sustained motor influence**

   **Given** the link is active, unobstructed, and within its break length
   **When** the recipient's sustained-influence motor phase resolves
   **Then** the link submits acceleration toward the current source anchor through the typed player-motor boundary
   **And** the baseline acceleration is 8.0 metres per second squared until inward velocity relative to the source reaches 5.0 metres per second
   **And** velocity already moving inward faster than that cap is preserved rather than reduced
   **And** the link never writes final velocity, changes global position, calls `move_and_slide()`, or forces a locomotion transition.

9. **Let normal source movement influence the pull without hard carrying**

   **Given** the source moves while the link remains valid
   **When** the next motor influence is calculated
   **Then** pull direction and relative speed use the source's latest authoritative anchor snapshot
   **And** movement of the source changes the sustained pull but never directly moves or parents the player
   **And** ordinary source movement away from the player continues pulling only while the link remains within its 24.0-metre break length.

10. **Accept each occurrence and motor submission at most once**

    **Given** duplicate impact notifications, repeated hurtboxes, or repeated effect requests carry the same occurrence identity
    **When** the target effect owner receives them
    **Then** only the first valid request can create the link
    **And** each active physics step submits no more than one sustained influence for that link
    **And** duplicate or late requests return a typed result without restarting duration or producing additional presentation.

11. **Enforce the single-link policy deterministically**

    **Given** the target already has an active harpoon link
    **When** the same or another source attempts to attach another baseline link
    **Then** the later occurrence is rejected without refreshing, replacing, or stacking with the existing link
    **And** simultaneous candidates are resolved using stable occurrence ordering rather than scene-tree, signal, or insertion order
    **And** a later attack may attach normally after the first link reaches its terminal state.

12. **Suspend pull immediately when cover blocks the link**

    **Given** the link is active
    **When** the named line-of-sight query first finds eligible blocking geometry between the current source and recipient attachment points
    **Then** the link's motor influence is suspended on that physics step
    **And** continuous simulation-owned occlusion time begins accumulating
    **And** the player is not pulled through the blocking surface during the break grace period.

13. **Break only after continuous occlusion**

    **Given** eligible cover continues blocking the link
    **When** continuous occlusion reaches 0.25 seconds
    **Then** the link terminates once with a typed `BROKEN_BY_COVER` reason
    **And** its motor influence, visual connection, timer, and source binding are removed through the normal terminal path.

    **Given** line of sight becomes clear before 0.25 seconds elapse
    **When** the next authoritative query resolves
    **Then** the occlusion accumulator resets and pull resumes without creating or refreshing the link
    **And** total active lifetime continues counting while the pull is suspended.

14. **Break at the authored maximum length**

    **Given** normal player or source movement increases separation
    **When** authoritative anchor distance exceeds 24.0 metres plus the documented physics tolerance
    **Then** the link terminates once with a typed `MAX_LENGTH_EXCEEDED` reason
    **And** it does not snap, teleport, launch, or constrain the player back inside the boundary
    **And** a missing anchor, invalid source, or severe anchor discontinuity cancels the link rather than producing an extreme pull vector.

15. **Preserve the player's active grapple**

    **Given** the player is already grappling when the harpoon attaches or activates a grapple while tethered
    **When** the motor resolves both influences
    **Then** the harpoon contributes sustained acceleration while the player's grapple retains ownership of its pull and maximum-distance constraint
    **And** the harpoon cannot cancel, retarget, shorten, lengthen, or replace the player's grapple.

    **Given** the harpoon attempts to pull the player outward while the player is at maximum grapple distance
    **When** the grapple constraint phase resolves after sustained influences
    **Then** only the component that would cross the player-grapple boundary is clipped or redirected
    **And** valid inward and tangential movement remains available.

16. **Preserve collision and wall-state ownership**

    **Given** the harpoon pulls the player toward geometry or while the player is wall-running, wall-sticking, airborne, or grounded
    **When** the motor commits movement
    **Then** ordinary collision, sliding, contact publication, gravity, and locomotion policies determine the resulting movement and state
    **And** the tether cannot pull the player through solid geometry or directly force them out of a wall state
    **And** leaving or maintaining wall contact follows the authoritative `ContactFrame`.

17. **End the link cleanly for every terminal condition**

    **Given** the link reaches its 4.0-second duration, exceeds maximum length, remains occluded long enough, loses its source, loses its recipient, or is invalidated by reset
    **When** the corresponding terminal condition commits
    **Then** the recipient effect owner removes the sustained influence and emits exactly one reason-coded terminal result
    **And** source death or removal ends the link immediately under `CANCEL_WITH_SOURCE`
    **And** target death prevents further movement submissions
    **And** encounter reset, checkpoint reload, and scene exit remove all link state, presenters, timers, bindings, and stale callbacks.

18. **Preserve agency and an understandable recovery**

    **Given** the player is successfully tethered
    **When** they steer, jump where eligible, grapple, use a wall, reach cover, move beyond break range, or survive until expiry
    **Then** those actions continue through their ordinary systems and at least one fixture-authored response can break or outlast the link
    **And** the tether applies no stun, input suppression, forced facing, direct state transition, repeated impact, or hidden post-expiry slowdown
    **And** its attack cadence leaves a manually verified recovery period before another harpoon can attach.

19. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** the harpoon warns, travels, attaches, pulls, becomes occluded, approaches expiry, breaks, or is cancelled
    **Then** primitive projectile geometry, a non-colliding straight link, state changes, and a pull-direction indicator communicate the current threat and counter
    **And** future animation, cable VFX, audio, camera, and reaction presenters can consume committed lifecycle facts without changing gameplay
    **And** diagnostics expose occurrence identity, source and run, anchor position and velocity, recipient position and velocity, distance, pull direction, relative inward speed, requested and accepted acceleration, occlusion duration, remaining lifetime, motor result, and terminal reason.

20. **Make tether counterplay manually reproducible**

    **Given** the named harpoon-tether fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can dodge the shot, block it with cover before impact, accept a hit in open space, feel and observe the sustained pull, break it using continuous cover, briefly cross cover without breaking it, exceed maximum length, and outlast its duration
    **And** they can repeat the tether while grounded, airborne, grappling below and at maximum range, wall-running or wall-sticking, and while the source moves toward, across, and away from the player
    **And** they can test a second attachment attempt, source death, target death, invalid anchor, reset during delivery and link phases, and repeated runs
    **And** the procedure separates objective attachment, pull, break, interaction, and cleanup outcomes from subjective pull-strength and duration notes.

21. **Verify the family representative**

    **Given** the permanent harpoon-link suite and focused real-Jolt fixture run
    **When** they exercise accepted and blocked impacts, duplicate delivery, simultaneous link candidates, moving sources, relative-velocity caps, sustained motor ordering, brief and continuous cover, maximum length, active player grapple, wall contacts, source and target loss, stale runs, and repeated reset
    **Then** each accepted occurrence creates no more than one recipient-owned link, submits no more than one influence per eligible physics step, and terminates exactly once
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve duration, acceleration rate, relative-speed cap, occlusion break time, distance-break result, and recovery opportunity within documented tolerances
    **And** this establishes one bounded Target-Owned Status or Link representative without implementing rope physics, wrapping, elasticity, reeling, an attackable cable body, multiple-link pressure, support tethers, final presentation, or the full six-family gate.
