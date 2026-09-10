---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 2
---

# Story 8.2: Traverse the Last Garden Boss Level and Arena Shell

As a player,
I want to traverse a readable Last Garden approach and vertical boss arena,
So that the environment supports both survival and movement-created attack opportunities during the future Garden Heart fight.

**Acceptance Criteria:**

1. **Declare the focused level-and-arena outcome**

    **Given** Story 8.1 has an approved Garden Heart specification
    **When** the Last Garden environment story is inspected
    **Then** it provides a loadable primitive level shell containing an authored approach, boss entrance, boss arena, traversal routes, recovery geometry, and reserved reward-and-exit space
    **And** level composition, route topology, collision, grapple and wall affordances, encounter bounds, checkpoint placement, boss access relationships, fallback presentation, loading, diagnostics, manual procedure, and automated evidence are explicit
    **And** the complete shell is traversable through production player contracts without active boss logic
    **And** Garden Heart behavior, selected attacks, vulnerabilities, supporting-enemy production, rewards, final exit, and final art remain outside this story.

2. **Require the approved arena design**

    **Given** Story 8.1 identifies the boss-arena relationship
    **When** Story 8.2 begins
    **Then** it consumes the approved specification identity and version, arena diagram, route requirements, weak-point access relationships, selected-mechanic spatial needs, recovery policy, content-density budget, and supporting-role dispositions
    **And** every material geometry decision traces to that handoff
    **And** an unapproved, incomplete, or superseded boss specification blocks environment implementation
    **And** implementation cannot silently reinterpret the fight to accommodate convenient geometry.

3. **Author a distinct Last Garden level manifest**

    **Given** the new level is registered for controlled loading
    **When** its `LevelManifest` is inspected
    **Then** it has a stable Last Garden level ID and version, level-root scene, required dependency groups, optional presentation fallbacks, loading profile, expected root-contract version, validation metadata, and player start profile
    **And** the development arena-shell fixture has a distinct stable ID or explicit candidate status so it cannot be confused with the final boss-level manifest
    **And** scene and resource references remain immutable authored data
    **And** no application-flow code embeds the level scene path.

4. **Use the established replaceable level structure**

    **Given** the Last Garden scene is instantiated
    **When** its public composition is validated
    **Then** it implements the existing `LevelRoot` contract with static world geometry, navigation, one level-owned player, encounter containers, level audio ownership, level presentation, and one `LevelController`
    **And** application-owned UI, settings, loading, and menu services remain outside the level
    **And** private descendants initialize through typed context rather than external node paths
    **And** ending the level removes the complete shell and player with its level session.

5. **Keep the environment deliberately authored**

    **Given** the Last Garden layout is opened in the editor
    **When** its approach, platforms, walls, cover, grapple surfaces, recovery areas, and arena boundaries are inspected
    **Then** they are authored directly from the approved layout rather than generated procedurally
    **And** exact transforms, dimensions, slopes, clearances, and collision shapes remain scene or immutable-resource data
    **And** changing an authored placement requires no player, boss, encounter, or application code modification
    **And** validation reports unsafe or inconsistent geometry instead of moving it automatically at runtime.

6. **Provide a bounded approach to the boss arena**

    **Given** a fresh Last Garden level session begins
    **When** the player travels from the authored start toward the boss entrance
    **Then** the approach introduces the arena's vertical scale and offers at least the approved low, high, and lateral traversal choices before commitment
    **And** production movement, jumping, grappling, release momentum, wall running, wall sticking, wall jumping, and ordinary recovery remain usable where assigned by the specification
    **And** the player can reach the boss checkpoint entrance without a diagnostic teleport or active enemy assistance
    **And** approach length and complexity remain within Story 8.1's bounded slice allocation.

7. **Create one explicit boss-arena boundary**

    **Given** the player reaches the boss entrance
    **When** the arena boundary is inspected
    **Then** it declares stable arena, entrance, encounter-region, gate, playable-bounds, failure-boundary, navigation, pressure-origin, player-start, and recovery-region identities
    **And** the boundary contains the complete space required by the approved Garden Heart cycle
    **And** it is large enough for intended high-speed traversal without exposing unbounded world space
    **And** exact boundary geometry remains authored rather than inferred from camera position or boss range.

8. **Preserve meaningful low-route play**

    **Given** the player remains near the lower arena elevation
    **When** they traverse its intended route
    **Then** it provides the approved cover, lateral movement, grapple access, counter positioning, or recovery value
    **And** it does not become a permanently safe location from all future boss pressure
    **And** the player can leave it through more than one approved movement option where the design requires route choice
    **And** collision and clearance support representative combat movement rather than only slow inspection.

9. **Preserve meaningful high-route play**

    **Given** the player uses grapple, wall movement, or momentum to gain elevation
    **When** they traverse the high route
    **Then** it offers the approved weak-point access, observation, attack angle, pressure avoidance, or offensive setup
    **And** reaching it requires achievable production traversal rather than an undocumented exploit
    **And** it does not provide permanent immunity or allow the player to leave arena bounds
    **And** losing the route through an ordinary mistake leaves the documented recovery possibility.

10. **Preserve meaningful lateral-route play**

    **Given** the player crosses or circles the arena
    **When** they use the lateral route
    **Then** it provides a distinct way to change pressure angle, reach another vertical route, access cover, or prepare a counter
    **And** it cannot collapse into the same tactical path as the low or high route merely because all three are physically reachable
    **And** intended crossings support representative player speed and camera movement
    **And** future boss pressure origins retain readable sightlines to the affected space.

11. **Provide ordinary mistake recovery**

    **Given** the player misses an intended grapple, wall transition, jump, or elevated landing
    **When** the mistake remains within the approved ordinary-failure envelope
    **Then** authored recovery platforms, lower paths, grapple targets, walls, ramps, or safe drops let the player regain useful play
    **And** recovery does not automatically return the player to the best offensive position
    **And** the player retains control through normal movement contracts
    **And** no invisible teleport, velocity reset, or hidden anchor is used.

12. **Separate severe failure from ordinary recovery**

    **Given** the player leaves the bounded recoverable space or reaches an authored terminal hazard region
    **When** the severe-failure observation commits
    **Then** it carries player, level-session, region, reason, and physics-step identities to the existing recovery boundary
    **And** ordinary low-route or recovery-region occupancy does not trigger it
    **And** the region cannot restore, damage, teleport, or reload the player directly
    **And** later boss recovery uses Story 7.7's owner-controlled checkpoint and restart behavior.

13. **Author a safe boss-entry checkpoint location**

    **Given** the player reaches the final approach before arena commitment
    **When** the boss checkpoint placement is inspected
    **Then** its authored transform and view orientation place the player on stable nonhazardous support outside boss spawn, pressure, gate movement, and activation overlap
    **And** nearby geometry permits camera orientation, movement, grapple targeting, and re-entry without immediate damage
    **And** the checkpoint definition reference and activation region are stable and valid
    **And** checkpoint activation and boss-state capture remain assigned to a later integration story.

14. **Reserve an unambiguous arena commitment threshold**

    **Given** the player stands at the boss entrance
    **When** they inspect and cross the future activation threshold
    **Then** primitive geometry and presentation make the transition into the boss arena understandable
    **And** the threshold provides enough space for later validated gate closure without closing collision onto the player
    **And** its observation region carries stable level-session, arena, player, and physics-step identities
    **And** this story does not activate an encounter, close a gate, spawn a boss, or modify progression.

15. **Author safe gate geometry**

    **Given** the boss entrance and eventual post-defeat exit require controlled gates
    **When** their static and animated bounds are validated
    **Then** closed and open collision states have matching primitive presentation
    **And** no transition path intersects the approved player commitment, checkpoint, recovery, reward, or exit positions
    **And** gate animation remains cosmetic and later state authority belongs to `LevelController`
    **And** this story leaves the gates in a deliberate traversal-fixture state that allows complete arena inspection.

16. **Use an inert Garden Heart spatial stand-in**

    **Given** boss scale and access relationships must be evaluated before runtime behavior exists
    **When** the arena shell is loaded
    **Then** an explicitly non-authoritative primitive stand-in marks the approved Garden Heart body, weak-point positions, pressure origins, and occupied volume
    **And** it cannot take damage, change health, select actions, open vulnerabilities, complete an encounter, or satisfy an objective
    **And** its collision policy matches only what is required for route and clearance review
    **And** it is visibly labelled as an inert development stand-in.

17. **Validate weak-point access relationships**

    **Given** Story 8.1 defines one or more weak-point access conditions
    **When** the player follows each corresponding arena route with the inert stand-in present
    **Then** they can reach the required range, altitude, line of approach, facing relationship, or attack geometry using production movement
    **And** access remains possible at the approved baseline player and camera settings
    **And** a closed-state marker distinguishes geometric reachability from future damage eligibility
    **And** no route is accepted solely because a debug free camera can see the marker.

18. **Provide selected-mechanic spatial affordances**

    **Given** Story 8.1 maps selected Garden Heart pressures onto the arena
    **When** their authored spatial requirements are validated
    **Then** required lane, ring, plane, volume, trajectory, surface, obstacle, anchor, or aerial spaces fit inside the arena with their approved warnings and recovery margins
    **And** those affordances use reusable markers or authored references rather than mechanic-specific node-path assumptions
    **And** they do not activate the selected mechanics in this story
    **And** an incompatible placement or insufficient clearance fails validation rather than clipping or shrinking the future pressure silently.

19. **Support advanced regular-enemy roles without authored tactical anchors**

    **Given** Story 8.1 allocates any advanced Rootstalker, Spore Kite, Mycelial Weaver, or optional supporting role to the Last Garden approach
    **When** approach geometry and bounds are inspected
    **Then** ordinary navigation, surface probes, encounter bounds, line of sight, and nearby geometry provide the required climbing, flying, route, or support context
    **And** no climb route, climb-entry anchor, flight anchor, flight connection, separate flight volume, or per-arena tactical waypoint network is introduced
    **And** zero to three approved rare override volumes may be used only when recorded by the design
    **And** supporting-role implementation and encounter activation remain later work.

20. **Provide valid navigation and encounter bounds**

    **Given** future supporting enemies and the Garden Heart encounter need spatial context
    **When** navigation and bounds validation runs
    **Then** ground navigation covers intended reachable combat surfaces while excluding unsafe or nonplayable geometry
    **And** encounter bounds contain intended player and enemy movement without redefining grapple or player failure boundaries
    **And** flying and climbing candidates can later use runtime geometry discovery within those bounds
    **And** missing, disconnected, or contradictory navigation data blocks level readiness where required.

21. **Keep grapple eligibility authored through shared policy**

    **Given** the player aims at arena and approach surfaces
    **When** the authoritative resolver evaluates them
    **Then** broad static geometry follows the named default grapple policy and special targets use explicit `Grappleable3D` contracts
    **And** intended eligible, rejected, out-of-range, and occluded targets remain reproducible from the approved routes
    **And** the environment does not branch on filenames, materials, node paths, or Terrain3D types
    **And** diagnostic markers and primitive presentation consume rather than replace resolver results.

22. **Support wall movement through shared contact interpretation**

    **Given** a wall is assigned to a route, counter, or recovery function
    **When** the player contacts it from representative directions and speeds
    **Then** shared `ContactFrame` classifications support the intended wall run, stick, jump, rejection, and separation behavior
    **And** seams, corners, slopes, and transitions avoid accidental classification traps within documented tolerance
    **And** no arena script forces a locomotion state or writes player velocity
    **And** unsuitable decorative or gate surfaces are rejected consistently.

23. **Preserve canonical aim and camera usability**

    **Given** the player traverses every approved arena elevation and route
    **When** they aim at weak-point markers, grapple targets, pressure origins, and intended approach directions
    **Then** built-in `Camera3D` and `SpringArm3D` presentation keeps the player, target area, and nearby traversal geometry usable within the approved camera contract
    **And** camera collision, smoothing, FOV, and visual shake cannot alter canonical gameplay aim
    **And** no critical route produces persistent camera clipping or hides the complete intended response area
    **And** subjective camera-comfort concerns are recorded separately from authoritative aim agreement.

24. **Reserve a safe post-defeat reward and exit space**

    **Given** the boss will later die and expose its reward and exit
    **When** the post-defeat area is inspected
    **Then** it contains authored reward placement, collection approach, exit threshold, player-safe standing region, camera view, and gate-clearance references
    **And** those positions remain outside active boss collision, pressure origins, terminal hazards, and gate movement
    **And** the area is reachable from every approved final vulnerability route after pressure cleanup
    **And** this story creates no grant, objective completion, exit request, or persistent reward.

25. **Use readable primitive environment presentation**

    **Given** final Last Garden art, models, materials, animation, lighting, and VFX are unavailable
    **When** the shell is played
    **Then** primitive geometry and bounded labels or markers distinguish approach, arena commitment, low, high, lateral, recovery, checkpoint, weak-point-access, boss-occupied, reward, and exit areas
    **And** critical distinctions use shape, placement, pattern, icon, or text in addition to color
    **And** presentation never defines collision, grapple eligibility, route completion, or failure
    **And** future environment art can replace visual surfaces without changing the approved gameplay geometry and semantic contracts.

26. **Load all required shell dependencies before activation**

    **Given** the Last Garden shell is requested through Story 7.4
    **When** its manifest reaches readiness evaluation
    **Then** static geometry, collision, navigation, player dependencies, route markers, stand-in resources, query profiles, fallback presentation, and required level contracts are resident and valid
    **And** no first-time synchronous load occurs while the player traverses the approach or arena
    **And** a required geometry, collision, navigation, or contract failure prevents partial activation
    **And** an optional presentation failure uses only its declared resident fallback.

27. **Cleanly replace or reload the shell**

    **Given** the player leaves, reloads, or replaces the Last Garden shell
    **When** its level session ends
    **Then** the player, level geometry instance, navigation ownership, stand-in, regions, markers, presentation sources, audio root, and diagnostic bindings are invalidated and removed through established level teardown
    **And** late region, grapple, contact, failure, or presentation facts cannot affect a new session
    **And** reloading creates a fresh player and shell state from immutable authored data
    **And** repeated shell sessions do not accumulate nodes, signals, navigation maps, or retained references.

28. **Expose bounded environment diagnostics**

    **Given** development diagnostics are enabled
    **When** the Last Garden shell is inspected
    **Then** diagnostics can show level and layout versions, level-session identity, route and region identities, player route position, arena and failure bounds, grapple results, contact classifications, navigation status, stand-in and access markers, validation failures, and scoped-object counts
    **And** they consume maintained gameplay and validation results rather than recomputing movement, grapple targeting, contacts, or navigation
    **And** histories and drawings have explicit bounds and stop when hidden
    **And** release-like behavior omits or disables the detailed overlay.

29. **Make every route manually reproducible**

    **Given** another developer loads the named Last Garden arena-shell fixture through normal application flow
    **When** they follow the documented traversal procedure with diagnostics initially disabled
    **Then** they travel from entry to the boss checkpoint, cross the commitment threshold, complete the low, high, and lateral arena circuits, reach every weak-point access marker, demonstrate each ordinary recovery route, visit the reserved reward-and-exit area, and return to the entrance where intended
    **And** they deliberately test missed grapple, failed wall transition, high-speed crossing, route switching, camera collision, unsuitable surfaces, severe out-of-bounds failure, reload, and level replacement
    **And** every intended route and recovery is achievable using normal keyboard-and-mouse controls and production movement behavior
    **And** retained evidence separates objective reachability, collision, query, identity, bounds, loading, and cleanup results from subjective route value, readability, scale, camera comfort, and flow observations.

30. **Verify the level shell automatically**

    **Given** reusable content validators, focused real-Jolt traversal tests, loading integration tests, and scene smoke checks run
    **When** they exercise manifest and root validation, authored markers, route connectivity, representative clearances, arena and failure bounds, checkpoint and reward-space safety, grapple profiles, wall classifications, navigation, high-speed queries, loading, stale facts, teardown, and repeated sessions
    **Then** every required route and semantic region is valid and the complete scene loads without a partial level
    **And** no shell script writes player velocity, changes gameplay state, activates a boss, or duplicates authoritative queries
    **And** old sessions and references are released while immutable assets retain their fingerprints
    **And** automated geometry checks supplement rather than replace manual route and camera review.

31. **Remain traversally equivalent at both physics rates**

    **Given** the same scripted route and recovery attempts run at shipping 60 Hz and diagnostic 120 Hz
    **When** movement, grapple, wall contact, high-speed crossings, failure regions, and route markers resolve
    **Then** authoritative reachability, contact classifications, grapple eligibility, failure outcomes, and final route destinations remain equivalent within documented physics tolerance
    **And** rendered interpolation may differ without changing the gameplay path
    **And** no timing is authored as a frame count
    **And** a rate-dependent route or recovery failure blocks the story.

32. **Respect the approved performance budget**

    **Given** the shell runs in the Story 7.16 release-like environment
    **When** its geometry, navigation, lighting fallback, presentation, and traversal cost are measured
    **Then** the result remains within its allocated portion of the approved M4 content-density budget
    **And** no unexplained object, navigation, query, or rendering growth occurs across repeated loads
    **And** final boss-performance completion is not claimed before representative Garden Heart behavior exists
    **And** measured problems produce bounded remediation rather than speculative pooling or streaming.

33. **Keep the story bounded to the playable environment shell**

    **Given** Story 8.2 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the loadable Last Garden approach, boss arena, authored routes, recovery geometry, regions, checkpoint and reward-exit placements, inert boss stand-in, selected-mechanic affordances, navigation, fallback presentation, diagnostics, and focused verification
    **And** it does not implement the Garden Heart runtime, boss health, vulnerability, attacks, phase logic, supporting-enemy production, encounter activation, boss HUD, boss audio, reward grant, exit transition, or final environment art
    **And** those outcomes remain assigned to later Epic 8 stories.
