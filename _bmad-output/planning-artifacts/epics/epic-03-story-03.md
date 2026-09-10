---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 3
---

# Story 3.3: Prove Geometry-Discovered Flying Tactics

As a player,
I want a flying enemy to reposition through open three-dimensional space using readable and bounded tactical choices,
So that altitude, cover, and movement remain meaningful without relying on hidden authored flight routes.

**Acceptance Criteria:**

1. **Define an immutable flying-tactics policy**

   **Given** the flying prototype is authored
   **When** its definitions are inspected
   **Then** immutable typed data declares encounter-bound margins, candidate types, candidate count limits, preferred distances and altitudes, clearance requirements, line-of-sight policy, scoring weights, steering limits, arrival tolerances, replanning interval, hysteresis, recovery policy, fallback priorities, and permitted override-volume responses
   **And** all durations are expressed in seconds and the selected replanning interval follows the architecture's approximate four-to-six evaluations-per-second guidance
   **And** occurrence-specific candidate, selection, movement, action, and recovery state remains owner-local
   **And** prototype values are identified as provisional and retained for playtest review rather than represented as final balance.

2. **Consume bounded tactical facts**

   **Given** the flying enemy is active
   **When** it begins a declared tactical evaluation
   **Then** one immutable tactical snapshot supplies the physics step, deterministic run seed, stable enemy and target identities, positions and velocities, player locomotion facts where relevant, encounter bounds, current action and recovery state, recent selected positions, and currently available attack requirements
   **And** AI consumes the committed snapshot rather than repeatedly querying the player, scene tree, or physics space
   **And** target removal, death, or run mismatch produces a typed invalid-target result without retaining a stale node.

3. **Use the existing encounter boundary as flight bounds**

   **Given** the pressure-lab fixture supplies one typed spatial boundary
   **When** flight candidates are generated or motion is validated
   **Then** that existing boundary constrains the enemy's body and clearance volume
   **And** candidates outside the usable boundary are rejected
   **And** no separately authored flight volume, flight route, waypoint network, flight anchor, or hand-authored connection is required.

4. **Generate candidates for every required tactical role**

   **Given** the enemy needs a new tactical destination
   **When** bounded runtime candidate generation runs
   **Then** it can generate distinct attack, strafe, staging, recovery, and avoidance candidates from the player position and velocity, encounter bounds, preferred range and altitude, current line of sight, nearby obstacles, recent selections, attack requirements, and recovery safety
   **And** every candidate records its stable identity, intended role, world position, generation facts, physics step, and initial validity
   **And** the candidate budget and spatial sampling remain bounded.

5. **Reject invalid positions explicitly**

   **Given** a generated position lies outside usable bounds, lacks body clearance, intersects blocking geometry, violates an override volume, cannot provide its required line of sight or attack relationship, duplicates another candidate, or lacks a safe steering approach
   **When** validation runs
   **Then** it is rejected with a typed reason
   **And** rejected candidates cannot be selected or silently clamped into validity
   **And** an unavailable fact is represented explicitly rather than substituted with zero or an arbitrary default.

6. **Score candidates deterministically**

   **Given** multiple valid candidates exist
   **When** the tactical-position policy scores them
   **Then** it uses immutable weights and the committed facts for preferred range, altitude, line of sight, obstacles, attack suitability, player prediction, recovery safety, and recent-selection penalty
   **And** stable candidate ordering, deterministic run seed data, and explicit tie-breaking produce reproducible results
   **And** scoring does not depend on rendered frames, unordered scene iteration, subscriber order, or diagnostic visibility.

7. **Prevent destination thrashing**

   **Given** the currently selected destination remains valid
   **When** a newly scored candidate is only marginally preferable
   **Then** the authored hysteresis policy retains the current destination
   **And** replanning occurs only at the authored bounded interval or in response to a declared meaningful event
   **And** repeated evaluations cannot continuously restart movement, recovery, or attack requests.

8. **Request flight through the AI intent boundary**

   **Given** a tactical destination has been selected
   **When** the behavior policy chooses to move toward it
   **Then** AI submits a typed flight-movement request containing the snapshot, candidate and request identities, destination, tactical role, and current run
   **And** the flight movement owner independently validates and executes the request
   **And** behavior-tree tasks cannot assign velocity, move the body, teleport, call collision queries, or infer arrival from animation.

9. **Steer through collision-aware swept motion**

   **Given** the movement owner has accepted a flight destination
   **When** it advances the enemy during a physics step
   **Then** acceleration, deceleration, turning, vertical steering, obstacle response, and body movement follow the immutable flight definition and commit through one authoritative movement boundary
   **And** swept collision and clearance checks prevent ordinary tunnelling through arena geometry
   **And** a blocked direct route produces avoidance, replan, or fallback behavior rather than clipping through the obstacle
   **And** this story does not introduce a navigation mesh or sparse free-space graph without separate measured evidence and approval.

10. **Arrive and hold position tolerantly**

    **Given** the enemy approaches a valid tactical destination
    **When** it enters the authored position and velocity tolerance
    **Then** arrival commits exactly once and the current tactical role advances according to policy
    **And** small physics variation does not repeatedly alternate between arrived and travelling states
    **And** an attack or recovery action is not started merely because a rendered transform appears visually close.

11. **Use an existing attack to exercise attack positions**

    **Given** an attack-position candidate satisfies an already-delivered compatible attack definition
    **When** the flying AI requests that attack
    **Then** the action owner validates target, line of sight, distance, current action, candidate identity, and run before committing its normal `AbilityExecution`
    **And** attack timing, space, hit delivery, damage, and terminal results remain owned by the existing combat contracts
    **And** Story 3.3 does not implement arcing bombardment, aerial mines, direct lane fire, or another new M2 pressure mechanic merely to demonstrate flight positioning.

12. **Expose staging, strafing, avoidance, and recovery choices**

    **Given** the flying enemy is not currently committing an attack
    **When** its tactical situation changes
    **Then** it can select a staging position before engagement, a strafe position that changes angle without leaving bounds, an avoidance position around blocking geometry, or a recovery position after commitment
    **And** each selection uses the same candidate and scoring contracts
    **And** post-attack recovery includes an authored exposed drift or vulnerability period rather than immediate invulnerable repositioning to a hidden anchor.

13. **Preserve player counterplay**

    **Given** the enemy changes altitude or attack angle
    **When** the player uses the documented counter--such as taking cover, changing lateral position or altitude, closing through a different route, or grappling to another valid surface
    **Then** the enemy's selected position or attack relationship can be defeated without forcibly cancelling the player's traversal
    **And** the player retains at least one recovery option after an ordinary positioning mistake
    **And** bounded speed, readable movement, commitment, and recovery prevent the enemy from maintaining an unavoidable ideal position.

14. **Remain a valid moving grapple target**

    **Given** the alive flying enemy is authored as an eligible moving `Grappleable` target
    **When** the player grapples it during staging, travel, attack, avoidance, or recovery
    **Then** the attachment follows its authoritative moving anchor and obeys the existing zip-pull and true maximum-length rules
    **And** flight steering cannot push the player, silently cancel or retarget the grapple, or bypass discontinuity validation
    **And** death, removal, reset, or target invalidation terminates the attachment once through the typed grapple contract.

15. **Use rare override volumes only as exclusions**

    **Given** a specific region must exclude flight or attack positions
    **When** a `NoFly` or `NoAttackPosition` override applies
    **Then** affected candidates receive the corresponding typed rejection
    **And** the volume cannot create a destination, connection, route, recovery anchor, or preferred tactical score
    **And** the normal fixture remains playable with zero flight anchors, zero flight connections, and zero separate flight volumes.

16. **Fail safely when no candidate is valid**

    **Given** all candidates are rejected or the current destination becomes invalid
    **When** the selection owner commits the no-valid-candidate result
    **Then** the enemy enters its authored safe fallback, such as controlled hover, bounded exposed drift, return toward the last safe position, controlled descent, or non-attacking hold as current geometry permits
    **And** it does not leave encounter bounds, clip through geometry, attack from an invalid position, accelerate indefinitely, or replan every physics tick
    **And** the fallback reason remains observable and can later recover when valid geometry becomes available.

17. **Clean up on death and reset**

    **Given** the flying enemy dies or the fixture resets during candidate evaluation, movement, attack, strafe, avoidance, recovery, or fallback
    **When** termination commits
    **Then** candidate state, destination ownership, movement requests, action execution, grapple validity, and presentation terminate exactly once
    **And** stale requests, selections, hits, and callbacks from the old run are rejected
    **And** a fresh run begins from the authored spawn and deterministic seed state without retaining recent-position penalties or prior candidate history.

18. **Provide replaceable presentation and bounded diagnostics**

    **Given** final flight animation, audio, and VFX are unavailable
    **When** the enemy stages, travels, selects, attacks, avoids, recovers, rejects candidates, or falls back
    **Then** primitive poses, shapes, trails, position markers, or color changes make the player-facing behavior readable without controlling it
    **And** future animation and VFX adapters can consume committed movement, tactical, ability, spatial, impact, and terminal facts
    **And** development diagnostics visualize bounded generated and rejected candidates, candidate roles, rejection reasons, component scores, selected destination, steering path, clearance result, hysteresis decision, replan trigger, and fallback reason using already-computed state.

19. **Make flying tactics manually reproducible**

    **Given** the named flying-tactics fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can observe staging, attack-position selection, strafing, obstacle avoidance, exposed recovery, and the intended player counter
    **And** they can deliberately create an unsafe response, change player altitude and velocity, use cover, grapple the flying enemy, test excluded and no-valid-candidate regions, defeat the source, reset, and repeat the scenario
    **And** repeating the same seeded setup produces the same candidate decision while subjective movement and readability observations are recorded separately.

20. **Verify deterministic flying feasibility**

    **Given** the permanent flight-policy suite and focused real-Jolt fixture run
    **When** they exercise every candidate role, multiple valid candidates, stable ties, hysteresis, moving targets, blocked steering, near-boundary clearance, obstacle changes, no valid candidates, override volumes, attack acceptance and rejection, grapple interaction, death, repeated reset, stale runs, and randomized notification order
    **Then** generation, validation, scoring, selection, steering, action requests, fallback, and cleanup follow their declared contracts
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time movement, replanning, selection, and outcomes within documented tolerances.

21. **Conclude the early feasibility gate honestly**

    **Given** automated and manual flight evidence has been collected
    **When** Story 3.3 is reviewed
    **Then** completion requires a runnable anchor-free flying-tactics prototype with attack, strafe, staging, recovery, and avoidance positions plus demonstrated safe fallback and reproducible diagnostics
    **And** a fundamental failure of bounded runtime candidate generation or swept steering is recorded as a deliberate architecture decision and separately scoped remediation rather than hidden with authored flight routes
    **And** the story has not created a sparse free-space graph, navigation-mesh flight, production Spore Kite content, authored flight anchors or connections, final animation/VFX, additional pressure mechanics, or full encounter ownership.
