---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 5
---

# Story 7.5: Traverse a Multi-Route M3 Level Shell

As a player,
I want meaningful low, high, lateral, and recovery routes through a vertical level,
So that I can choose how to approach combat spaces and recover from ordinary traversal mistakes.

**Acceptance Criteria:**

1. **Declare the focused level-shell outcome**

   **Given** the M3 multi-route level is registered as the current validation level
   **When** its layout definition and test procedure are inspected
   **Then** its outcome is a primitive authored level that the production player can traverse from entry to completion through distinct low, high, and lateral routes with local recovery from ordinary mistakes
   **And** its topology, dimensions, route identities, traversal requirements, encounter regions, optional branch, recovery behavior, severe-failure boundary, presentation, diagnostics, manual procedure, and evidence requirements are explicit
   **And** the level loads through Stories 7.3 and 7.4
   **And** encounter activation, objectives, checkpoints, rewards, production HUD, production enemies, and boss content remain outside this story.

2. **Author one versioned layout manifest**

   **Given** the M3 level layout is inspected
   **When** its authored metadata is resolved
   **Then** it declares a stable level and layout identity, version, playable bounds, start and completion transforms, required-arena regions, optional-arena region, branch and rejoin points, route segments, recovery regions, severe-failure boundary, traversal validation markers, encounter bounds, and evidence procedure
   **And** every route segment identifies its low, high, lateral, recovery, shared, entry, exit, or optional role
   **And** exact transforms, dimensions, clearances, and marker relationships remain authored scene or immutable resource data rather than gameplay-code literals
   **And** mutable traversal attempts and observations never modify the manifest.

3. **Keep the layout authored rather than procedural**

   **Given** the level scene is opened
   **When** its static world is inspected
   **Then** platforms, walls, ramps, ledges, cover, grappleable collision, branch geometry, recovery surfaces, and arena boundaries are deliberately authored
   **And** the story does not generate arbitrary layouts, routes, cover, walls, or platforms at runtime
   **And** tuning an authored transform or dimension requires no movement, grapple, encounter, or level-controller code change
   **And** content validation reports an invalid arrangement rather than procedurally repairing it.

4. **Bound the baseline level dimensions**

   **Given** the baseline layout profile is selected
   **When** its complete playable bounds are measured
   **Then** the primary level path fits within approximately 64 metres of forward travel, 40 metres of usable width, and 28 metres of net vertical rise
   **And** every required route and recovery area remains inside one explicit level boundary
   **And** these baseline dimensions are provisional authored tuning and may change through a versioned layout update
   **And** the implementation contains no hidden assumption that these exact dimensions apply to future levels.

5. **Establish the complete route topology**

   **Given** the player begins at the authored entry
   **When** the static route graph is inspected
   **Then** the primary sequence connects entry, lower required arena, branch junction, upper required arena, and completion platform
   **And** one optional side-arena spur leaves the branch junction and rejoins the primary route before the upper arena
   **And** each required destination is reachable without entering the optional side arena
   **And** no branch terminates in an accidental dead end from which the player must reload.

6. **Reserve two required encounter regions**

   **Given** the lower and upper combat spaces are inspected
   **When** their authored encounter bounds are resolved
   **Then** each has a stable region identity, entry and exit relationship, sufficient player movement volume, ground-navigation region, vertical traversal geometry, grappleable surfaces, and recovery space
   **And** their geometry supports later activation of one Story 7.2 encounter at a time
   **And** static route geometry remains usable before encounter logic exists
   **And** marking these regions as future required encounters does not itself activate, complete, lock, or advance anything.

7. **Reserve one optional encounter branch**

   **Given** the player reaches the branch junction
   **When** the optional side route is inspected
   **Then** its entrance and rejoin direction are visually legible through geometry and primitive landmarks
   **And** entering it is not required to reach the upper arena or completion platform
   **And** its bounded combat region supports later encounter activation and a distinct optional reward location
   **And** optional status, completion, reward, and persistence remain later `LevelController` responsibilities.

8. **Provide a reliable low route**

   **Given** the player enters either required combat region
   **When** they follow its low route
   **Then** broad floors, ramps, cover relationships, and ordinary jumps provide a continuous route through or around the space
   **And** the route requires no precision grapple release, prolonged wall use, hidden boost, or fixture assistance
   **And** it remains longer or more centrally exposed than the high route so that it represents a meaningful trade-off rather than a universally superior path
   **And** exact route length and exposure remain recorded as playtest observations rather than unverified balance claims.

9. **Provide a committed high route**

   **Given** the player enters either required combat region
   **When** they choose the high route
   **Then** authored walls, ledges, open grappleable geometry, and landing surfaces support wall running, wall sticking, wall jumping, grapple pull, and momentum-preserving release
   **And** the route offers a more direct or positionally advantageous crossing than the low route
   **And** missed timing can drop the player toward a recovery route rather than causing unavoidable death
   **And** the route does not supply invisible rails, scripted velocity, aim correction, automatic grapple selection, or teleportation.

10. **Provide a distinct lateral route**

    **Given** central movement through a combat region would expose the player to future pressure
    **When** they choose its lateral route
    **Then** side ledges, offset walls, cover, and grappleable surfaces permit movement around the central lane
    **And** the lateral route rejoins the shared progression path without requiring the player to backtrack through its full length
    **And** it creates a different approach direction and line-of-sight relationship from both the low and high routes
    **And** it remains identifiable from player-visible geometry rather than a diagnostic route label.

11. **Provide local recovery beneath committed routes**

    **Given** the player releases a grapple early, misses a high landing, loses a wall run, undershoots a wall jump, or falls from a lateral ledge
    **When** their trajectory remains inside the ordinary-failure envelope
    **Then** a lower catch platform, wall, grappleable surface, ramp, or remaining air-control opportunity allows them to survive and reconnect to the low or shared route
    **And** recovery uses the production traversal vocabulary without resetting or teleporting the player
    **And** the route back is understandable from geometry and primitive landmarks
    **And** recovery does not place the player inside a future encounter spawn or sealed progression boundary.

12. **Reserve severe failure for leaving the recovery envelope**

    **Given** the player misses both an intended route and its authored recovery space
    **When** their body crosses the bounded severe-failure volume below the playable level
    **Then** the fixture records one typed out-of-bounds result and requests restoration through the current level-owned test boundary
    **And** the volume does not apply damage or teleportation repeatedly
    **And** ordinary mistakes that land on reachable recovery geometry do not trigger it
    **And** production checkpoint selection and death-restart behavior remain assigned to later stories.

13. **Respect the approved grapple maximum**

    **Given** the validation player uses the 35-metre grapple definition
    **When** every intended grapple transition is measured from its supported approach region
    **Then** no required grapple acquisition exceeds 30 metres before declared query and geometry tolerances
    **And** the remaining five-metre margin protects the route from requiring exact maximum-range acquisition
    **And** optional challenge lines may approach the full maximum only when their non-required status and rejection feedback are explicit
    **And** the layout cannot maintain a competing grapple-range value.

14. **Keep grapple targets geometry-driven**

    **Given** the player aims at ordinary walls, ledges, ceilings, temporary future-obstacle regions, or other eligible static collision
    **When** authoritative grapple targeting resolves
    **Then** ordinary collision geometry receives the approved default grapple response without per-placement grapple components
    **And** an exceptional target uses an explicit `Grappleable3D` response only when non-default behavior is actually required
    **And** a rejected blocking surface is not pierced to select geometry behind it
    **And** route markers and decorative meshes cannot become hidden grapple authorities.

15. **Provide supported wall geometry**

    **Given** the high, lateral, and recovery routes use wall traversal
    **When** their collision normals, continuity, dimensions, and adjacent surfaces are validated
    **Then** intended walls satisfy the shared non-flat wall classification with tolerances that support stable running, sticking, and jumping
    **And** floor-like and ceiling-like surfaces remain correctly classified
    **And** intended corner or adjacent-face transitions avoid abrupt unmarked normal changes that make the route nondeterministic
    **And** decorative geometry cannot disagree materially with the authoritative collision surface.

16. **Reward retained momentum without requiring one speed**

    **Given** the player approaches a route with different valid velocities
    **When** they grapple, release, steer, jump, or transition from a wall
    **Then** retained momentum can shorten, smooth, or improve the route without being required at one exact hidden speed
    **And** a slower valid approach still has an understandable route or setup option
    **And** collision geometry does not introduce unexplained velocity cancellation, duplicate impulses, or forced launches
    **And** route success uses spatial endpoints and authoritative traversal state rather than exact frame counts.

17. **Preserve more than one viable route**

    **Given** a required combat space is entered before enemy pressure exists
    **When** all intended route segments are validated
    **Then** low, high, and lateral crossings are each independently reachable with the production player
    **And** blocking or missing one route marker does not redefine another route as successful
    **And** no required progression point can be reached only through an undocumented exploit or a single pixel-perfect action
    **And** at least one ordinary-failure recovery path remains available from each committed elevated route.

18. **Author future pressure-placement regions without activating them**

    **Given** later encounters will use the Epic 6-selected mechanic subset
    **When** the level's combat spaces are prepared
    **Then** named bounded authoring regions identify candidate lane, surface, obstacle, aerial, support, cover, and recovery relationships where applicable
    **And** these regions are tooling and content-authoring references rather than active hazards or runtime targeting authority
    **And** they do not hard-code a mechanic to a production enemy before later encounter design
    **And** selected mechanics still perform their own authoritative placement, affected-space, eligibility, and safety validation.

19. **Support route-value change without permanent route removal**

    **Given** future temporary pressure may affect a wall, surface, grapple target, central lane, or aerial space
    **When** authored candidate regions are reviewed
    **Then** the static layout retains at least one alternate low, high, lateral, or recovery response appropriate to the intended pressure
    **And** a single temporary mechanic cannot occupy every route solely because all routes share one narrow choke point
    **And** route alternatives remain spatially distinguishable enough for separate telegraphs
    **And** the story does not activate or balance any future mechanic combination.

20. **Support ground, climbing, and flying behavior from geometry**

    **Given** the future level may contain ground, Rootstalker-like climbing, or Spore-Kite-like flying enemies
    **When** each combat region's navigation and bounds are inspected
    **Then** the low route and combat floor provide valid ground-navigation space and tactical fallbacks
    **And** representative walls and nearby navigable geometry permit the existing geometry-discovered climb-entry and pounce probes
    **And** open three-dimensional encounter bounds, obstacle clearances, and recovery space permit the existing flying candidate generator and swept steering to find bounded options
    **And** the level contains no required climb-entry anchors, flight anchors, hand-authored flight connections, or separate flight volume.

21. **Keep rare navigation overrides explicit**

    **Given** an authored region genuinely requires an exception for enemy safety or readability
    **When** a no-climb, no-fly, no-pounce, or no-attack-position override is added
    **Then** it uses the approved typed rare-override boundary
    **And** its purpose, bounds, affected policy, and evidence are recorded
    **And** each arena remains within the architecture's zero-to-three rare-override expectation
    **And** overrides cannot replace ordinary encounter bounds or a broadly invalid layout.

22. **Preserve camera and aiming readability**

    **Given** the player moves quickly through low, high, lateral, and recovery paths
    **When** the third-person camera and authoritative aim are exercised
    **Then** walls, ceilings, cover, corners, and narrow spaces avoid sustained camera occlusion or forced framing that hides the immediate route
    **And** intended grapple candidates remain aimable from their documented approach regions
    **And** the camera presenter may respond through its existing collision and framing rules without moving the player or changing targeting
    **And** known subjective camera-comfort concerns are recorded separately from objective blocked or invalid routes.

23. **Keep collision and query geometry coherent**

    **Given** visible and authoritative level geometry are compared
    **When** the player traverses surfaces, edges, corners, cover, and recovery spaces
    **Then** collision shapes align with the presented primitive forms within documented tolerances
    **And** ground, wall, grapple, line-of-sight, projectile, interaction, and camera query profiles receive the intended broad collision eligibility
    **And** gameplay scripts contain no layout-specific bitmask literals or node-name tests
    **And** high-speed traversal does not pass through intended blocking geometry under supported movement conditions.

24. **Integrate through the controlled level manifest**

    **Given** the M3 level shell is ready for use
    **When** it is registered for normal startup or focused loading
    **Then** its stable level ID and `LevelManifest` reference the new `LevelRoot` scene and validated dependency closure
    **And** Stories 7.3 and 7.4 prepare, install, replace, and tear it down without a special loading path
    **And** no combat-critical first-use synchronous load is introduced
    **And** leaving or replacing the level removes the player, geometry, encounter fixtures, validation markers, presentation, and level-owned runtime state.

25. **Use primitive but readable presentation**

    **Given** final environmental art, lighting, materials, audio, and VFX are unavailable
    **When** the player approaches a branch, elevation change, optional spur, recovery path, or completion platform
    **Then** distinct primitive silhouettes, value contrast, lighting, surface treatment, and bounded landmarks communicate the available direction and vertical relationship
    **And** low, high, lateral, and recovery routes remain understandable without persistent diagnostic labels
    **And** optional and primary paths can be distinguished without relying only on color
    **And** future art can replace primitive presentation without changing traversal collision or route topology unintentionally.

26. **Provide read-only route diagnostics**

    **Given** development diagnostics are enabled
    **When** the M3 level is inspected
    **Then** the overlay may show level and layout identities, playable and encounter bounds, start and completion points, route classifications, branch and rejoin points, grapple-distance measurements, recovery envelopes, severe-failure boundary, navigation results, override volumes, and validation failures
    **And** it reads authored metadata and existing traversal results rather than driving the player or recalculating gameplay physics
    **And** hidden diagnostics stop drawing and formatting route data
    **And** diagnostic histories and labels remain bounded and unavailable or disabled in release behavior.

27. **Make every route manually reproducible**

    **Given** another developer loads the M3 level through the normal application path
    **When** they follow the documented manual procedure with diagnostics initially disabled
    **Then** they reach the completion platform once through the low route, once through the high route, and once using the lateral route relationships in both required spaces
    **And** they enter the optional side arena and rejoin the primary path without using it for required progression
    **And** they deliberately miss a grapple, release early, lose a wall run, undershoot a wall jump, and fall from a lateral ledge, demonstrating the corresponding local recovery route where still inside the ordinary-failure envelope
    **And** they deliberately cross the severe-failure boundary once and verify a single typed restoration request
    **And** retained evidence separates objective reachability, grapple range, wall classification, route identity, recovery, collision, loading, and repeatability results from subjective flow, exposure, route value, camera comfort, and presentation observations.

28. **Validate static layout and traversal automatically**

    **Given** the permanent level-content validator and focused real-Jolt traversal tests are available
    **When** they inspect bounds, route graph connectivity, required and optional reachability, branch rejoin, intended grapple distances, wall classifications, recovery connections, severe-failure separation, encounter regions, navigation coverage, candidate pressure regions, query masks, resource references, and repeated load and unload
    **Then** every required route and recovery relationship passes its declared geometric contract
    **And** no route depends on a missing resource, stale node path, hidden teleport, scripted velocity, duplicate movement commit, or out-of-bounds grapple
    **And** invalid alternate profiles report the precise disconnected, unsafe, overlapping, or out-of-range relationship
    **And** shared traversal and gameplay definitions retain their original fingerprints.

29. **Preserve traversal outcomes at both physics rates**

    **Given** representative low, high, lateral, and recovery traversals run through real Godot and Jolt physics
    **When** equivalent command sequences execute at shipping 60 Hz and diagnostic 120 Hz
    **Then** route endpoints, grapple acquisition, maximum-distance behavior, release momentum, wall-state transitions, collision outcomes, recovery results, and severe-failure detection remain equivalent within documented tolerances
    **And** assertions use elapsed seconds, stable state transitions, and tolerant physical comparisons rather than raw tick counts or exact floating-point equality
    **And** no route is valid at one supported rate and invalid at the other
    **And** a rate-sensitive route failure blocks the story.

30. **Keep the story bounded to the authored level shell**

    **Given** Story 7.5 is reviewed for completion
    **When** its implementation and evidence are inspected
    **Then** it contains one new primitive M3 level, bounded topology, two required-arena regions, one optional-arena branch, low, high, lateral and recovery routes, loading integration, primitive presentation, diagnostics, and focused validation
    **And** it has not preserved or rebuilt the old tutorial, activated encounters, implemented objectives, checkpoints, rewards, death restart, production HUD, pause, settings, input remapping, production audio, production enemies, boss content, procedural level generation, or final environment art
    **And** those concerns remain assigned to later stories.
