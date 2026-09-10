---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 6
---

# Story 3.6: Grow a Telegraph-First Temporary Obstacle

As a player,
I want a temporary obstacle to clearly preview where it will appear before it changes the route,
So that I can avoid it, route around it, or use it as new grappleable terrain without being trapped by surprise collision.

**Acceptance Criteria:**

1. **Declare the temporary-route-change gameplay question**

   **Given** the obstacle-growth prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player reads the preview and adapts before the obstacle changes the route
   **And** its intended avoid, reroute, grapple, wall-movement, expiry-recovery, source-death, reset, overlap, tuning, manual-procedure, and evidence expectations are explicit
   **And** it remains a single-mechanic representative rather than adding damage, movement debuffs, or another attack.

2. **Author one immutable and configurable obstacle definition**

   **Given** the representative obstacle is authored
   **When** its typed definition Resource is inspected
   **Then** it declares a stable effect identity, box dimensions, windup duration, active duration, expiry-warning duration, visual-growth policy, placement policy, active-count policy, surface behavior, source-death policy, cleanup policy, and presentation reference
   **And** the baseline profile is an upright static rectangular wall 4.0 metres wide, 3.0 metres high, and 0.5 metres thick, with a 1.0-second windup, 6.0-second active lifetime, final 1.0-second expiry warning, and maximum of one active wall per source
   **And** these authored values are not duplicated as magic constants in the spawner, runtime obstacle, telegraph presenter, or fixture.

3. **Keep shared configuration separate from occurrence state**

   **Given** an obstacle request is accepted
   **When** its run-scoped occurrence is created
   **Then** mutable state records a stable occurrence identity, source and ability-execution attribution, run identity, frozen world transform, lifecycle phase, authoritative phase times, and typed rejection or expiry reason
   **And** no occurrence mutates the shared definition Resource
   **And** the encounter runtime owner, rather than the source AI or presentation node, owns the occurrence and its cleanup.

4. **Request placement through a typed ability boundary**

   **Given** the source commits its obstacle ability
   **When** it requests the scoped world effect
   **Then** it supplies the authored definition, source, ability execution, current run, requested base transform, and requested blocking direction through the typed scope-aware spawning boundary
   **And** the request cannot use an arbitrary `add_child()`, presentation transform, or untracked timer to create gameplay collision
   **And** the pressure-lab fixture provides a clearly visible placement marker that produces the same request path as authored gameplay.

5. **Accept only bounded static support**

   **Given** a placement request has a finite transform and valid attribution
   **When** its support and bounds are validated
   **Then** the wall base must resolve onto static floor-like support whose normal is within 20 degrees of world up
   **And** the complete 4.0-by-0.5-metre footprint and 3.0-metre height must fit inside the scenario's authored effect bounds with its configured clearance margin
   **And** unsupported, steep, moving, out-of-bounds, or non-finite placements are rejected before preview with a typed reason.

6. **Freeze one authoritative footprint and orientation**

   **Given** the request passes initial placement validation
   **When** its authoritative placement is committed
   **Then** the wall remains upright with its broad face aligned to the requested horizontal blocking direction and its base seated on the accepted support
   **And** the frozen center, orientation, dimensions, and clearance volume are shared by preview, occupancy queries, collision, grapple resolution, diagnostics, and presentation
   **And** the occurrence does not track later source movement or reconstruct its transform from the source node.

7. **Protect actors, geometry, and required recovery space**

   **Given** an otherwise supported footprint is evaluated
   **When** it overlaps the player, a protected combatant, another active or previewing obstacle, protected authored geometry, or a fixture-defined required exit or recovery volume
   **Then** placement is rejected with a typed occupancy or route-safety reason
   **And** neither a smaller hidden collider nor an unvalidated fallback transform is substituted
   **And** route-safety volumes are authored explicitly for the bounded fixture rather than inferred from nondeterministic navigation behavior.

8. **Telegraph visual growth without physical growth**

   **Given** a valid obstacle occurrence enters its 1.0-second windup
   **When** authoritative simulation time advances toward activation
   **Then** a non-colliding preview rises linearly from the frozen footprint's base to its full 3.0-metre height, producing an apparent baseline growth rate of 3.0 metres per second
   **And** the apparent rate is derived from configured height divided by configured windup duration rather than stored as a conflicting independent value
   **And** collision, grapple eligibility, projectile blocking, line-of-sight blocking, wall contact, landing support, damage, and movement influence remain disabled throughout preview
   **And** the presenter consumes normalized simulation-owned windup progress rather than advancing gameplay from an animation clock.

9. **Revalidate occupancy immediately before activation**

   **Given** the preview is about to finish
   **When** the complete frozen footprint and configured clearance margin are queried again using the named profiles
   **Then** activation proceeds only if the volume remains free of every protected actor, obstacle, geometry, exit, and recovery exclusion checked at placement
   **And** a player or combatant entering the preview volume during windup cancels the occurrence with a typed final-occupancy reason
   **And** cancellation never pushes, teleports, damages, traps, or silently relocates an occupant.

10. **Activate the complete collider atomically**

    **Given** the windup finishes and final validation succeeds
    **When** the occurrence enters its active phase
    **Then** one full-size static box collider becomes authoritative at exactly the frozen preview transform
    **And** collision, ordinary static-surface behavior, grapple eligibility, projectile blocking, and line-of-sight blocking become active together at that phase boundary
    **And** there is no partial, rising, segmented, or progressively expanding gameplay collider.

11. **Create a meaningful but recoverable route change**

    **Given** the baseline pressure-lab route is unobstructed before activation
    **When** the wall becomes active at its marked placement
    **Then** it blocks the fixture's direct route or firing lane strongly enough to require an observable movement decision
    **And** the player retains at least one authored alternate path and can also use the wall's top or faces through existing traversal where the approach permits
    **And** the wall does not seal every exit, invalidate all recovery options, or require damage to remove it.

12. **Behave as ordinary non-hazardous static geometry**

    **Given** the obstacle is active
    **When** actors and authoritative queries interact with it
    **Then** it participates through the project's named ground, wall, grapple-candidate, grapple-occlusion, projectile-hit, and line-of-sight profiles as ordinary static geometry
    **And** it uses the project's standard non-moving wall response without a custom bounce, conveyor, adhesive, launch, slowdown, damage, or other motor-effect override
    **And** it is non-damageable for this prototype and cannot be ended early by receiving attacks.

13. **Allow normal grapple, wall, and landing interaction while active**

    **Given** the full obstacle collider is active
    **When** the player targets or contacts a valid face or top surface
    **Then** the built-in static grapple response applies without a bespoke target component unless the shared contract requires one for spawned lifetime invalidation
    **And** ordinary grapple pulling and maximum-length constraints, wall-running or wall-sticking, collision sliding, and landing support continue through their existing owners
    **And** the obstacle never assigns player velocity, forces a locomotion state, or adds a hidden traversal modifier.

14. **Warn and expire on simulation-owned time**

    **Given** an active wall reaches the final 1.0 second of its 6.0-second active lifetime
    **When** its authoritative remaining time crosses the warning boundary
    **Then** replaceable presentation clearly distinguishes the expiring state without changing collision early
    **And** at lifetime completion collision, grapple eligibility, projectile blocking, line-of-sight blocking, and landing or wall support are invalidated together exactly once
    **And** any cosmetic fade after invalidation remains observational and cannot extend gameplay presence.

15. **Resolve expiry interactions through existing owners**

    **Given** the player is standing on, touching, or grappling the wall when it expires
    **When** the active surface is atomically invalidated
    **Then** contact and grapple owners receive the resulting absence or typed target invalidation on their normal authoritative boundary
    **And** the player keeps valid current motion and falls or recovers through ordinary motor, air-control, wall, and grapple rules
    **And** the obstacle does not teleport the player, invent a launch impulse, preserve a ghost contact, or leave a stale grapple attachment.

16. **Clean up on source loss and encounter reset**

    **Given** the source dies or is removed during preview
    **When** its source-death policy resolves
    **Then** the preview is cancelled before collision can activate.

    **Given** the source dies or is removed while its wall is active
    **When** the occurrence processes that loss
    **Then** the wall immediately follows the same authoritative expiry and invalidation path.

    **Given** the encounter resets, checkpoint reloads, or scene exits in any lifecycle phase
    **When** the prior run is invalidated
    **Then** preview, collision, target eligibility, timers, presenters, and late callbacks from that run are removed or rejected exactly once.

17. **Enforce one active occurrence per source and reject overlap deterministically**

    **Given** a source already owns a previewing or active wall in the current run
    **When** it submits another request under the baseline maximum of one
    **Then** the later request is rejected with a typed active-limit reason unless the definition explicitly selects a replacement policy
    **And** requests from different sources whose protected volumes overlap resolve through documented stable ordering rather than scene-tree, signal, or insertion order
    **And** duplicate delivery of the same occurrence identity cannot create a second preview, collider, timer, or expiry event.

18. **Keep tuning flexible without promising a general geometry system**

    **Given** an alternate obstacle definition changes valid box dimensions, windup duration, active duration, warning duration, slope tolerance, clearance margin, growth curve, or active-count limit
    **When** the same spawning and lifecycle implementation consumes it
    **Then** placement, preview, derived visual growth, activation, interaction, expiry, and diagnostics use the authored values without code changes
    **And** at least one automated alternate-profile case proves changed dimensions and timing are not hard-coded
    **And** non-box topology, moving support, destructibility, segmented construction, and progressive physical growth remain explicit future extensions rather than implied configuration supported by this story.

19. **Provide replaceable feedback and lifecycle diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** placement is accepted or rejected, preview advances, final validation cancels, the wall activates, the warning begins, or the wall expires
    **Then** primitive Godot-native geometry and bounded cues make footprint, growth, active state, warning, and removal readable
    **And** future animation, material, audio, camera, and VFX presenters can observe the same lifecycle without controlling placement, collision, or timing
    **And** diagnostics expose definition and occurrence identity, source and run, frozen transform, dimensions, configured and remaining phase times, normalized windup progress, support result, occupancy result, active count, surface eligibility, and typed rejection or expiry reason.

20. **Make route adaptation manually reproducible**

    **Given** the named temporary-obstacle fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented baseline procedure
    **Then** they can cross the marked footprint during preview, avoid it before activation, observe the direct route become blocked, take the alternate route, grapple to the active wall, use a valid face or top through ordinary traversal, and wait for warning and expiry
    **And** they can deliberately enter the preview during windup to verify safe cancellation; request unsupported, steep, out-of-bounds, overlapping, and protected-exit placements; exceed the per-source limit; remove the source in preview and active phases; reset each phase; and remain attached or supported at expiry
    **And** the procedure distinguishes objective placement, collision, interaction, cleanup, and timing results from subjective notes about dimensions, windup, lifetime, route value, and visual growth feel.

21. **Verify the scoped world-effect representative**

    **Given** the permanent obstacle suite and focused real-Jolt fixture run
    **When** they exercise the baseline and alternate definitions, valid and invalid supports, boundary and clearance cases, protected occupancy, player entry during preview, duplicate requests, same-source limits, cross-source overlap ordering, grapple and wall contact, projectile and line-of-sight blocking, expiry while supported or attached, source loss, stale runs, scene exit, and repeated reset
    **Then** collision can begin only once at the full frozen footprint after the declared non-colliding telegraph and can end only once through the authoritative invalidation path
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve lifecycle durations in real time, activation and expiry counts, placement outcomes, route-safety results, and cleanup within documented scheduling tolerances
    **And** this evidence establishes one bounded Scoped World Effect family representative while the project and previous fixtures remain runnable with valid retained references.
