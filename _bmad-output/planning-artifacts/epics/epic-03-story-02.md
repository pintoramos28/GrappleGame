---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 2
---

# Story 3.2: Prove Geometry-Discovered Climbing and Pounce

As a player,
I want an enemy to climb toward an exploited wall position and commit to a readable pounce,
So that wall traversal remains valuable without becoming universally safe.

**Acceptance Criteria:**

1. **Define an immutable climbing-tactics policy**

   **Given** the climbing prototype is authored
   **When** its definitions are inspected
   **Then** immutable typed data declares surface eligibility, bounded entry search, probe and clearance requirements, maximum climb distance or duration, contact-confidence rules, replanning and hysteresis policy, pounce eligibility, abort conditions, fallback priorities, and permitted override-volume responses
   **And** all durations are expressed in seconds and the selected replanning interval follows the architecture's approximate four-to-six evaluations-per-second guidance
   **And** pounce lifecycle, affected space, damage, and presentation remain referenced through their existing authoritative definitions rather than duplicated in the climbing policy
   **And** prototype tuning values are identified as provisional and recorded for playtesting rather than presented as final balance.

2. **Read wall exploitation through bounded tactical facts**

   **Given** the player begins wall-running, wall-sticking, or otherwise occupies a supported wall-relative position
   **When** the climbing enemy evaluates its tactical snapshot
   **Then** it receives the player's relevant locomotion, position, velocity, wall relationship, visibility, and run facts through typed read-only boundaries
   **And** the behavior policy may request the climbing tactic only for an enemy definition that explicitly permits it
   **And** neither AI nor climbing logic reads private player state, traverses the player HSM, changes player movement, or treats group membership as tactical authority.

3. **Discover climb-entry candidates from runtime geometry**

   **Given** the enemy considers a climbing response
   **When** the geometry-discovery owner performs its bounded search
   **Then** it generates candidate climb entries from nearby traversable ground, collision geometry, surface probes, enemy-body clearance, the player relationship, and named immutable physics-query profiles
   **And** every candidate records the physics step, world position, surface normal, approach relationship, clearance result, eligibility facts, and stable candidate identity
   **And** authored climb routes, climb-entry anchors, arbitrary collision masks, and unrestricted whole-level searches are not required.

4. **Reject unsafe or unreachable entries explicitly**

   **Given** a sampled climb entry is occluded, outside policy bounds, unreachable by the supported approach, lacks body clearance, uses ineligible geometry, lies inside an exclusion volume, or cannot support the bounded surface pursuit
   **When** candidate validation runs
   **Then** the candidate is rejected with a stable typed reason
   **And** rejection does not start movement, reserve the candidate, or partially enter the climbing state
   **And** a lack of valid candidates leads to the authored fallback rather than an invalid best-effort climb.

5. **Select candidates deterministically**

   **Given** more than one valid climb entry exists
   **When** the climbing tactic chooses among them
   **Then** scoring uses immutable policy weights, current committed tactical facts, deterministic encounter or fixture seed data, stable tie-breaking, and bounded candidate counts
   **And** hysteresis preserves a still-valid selected entry instead of switching destinations for insignificant score changes
   **And** repeated evaluations from equivalent inputs produce the same selected entry.

6. **Approach through the enemy movement boundary**

   **Given** a valid entry has been selected
   **When** the enemy approaches it
   **Then** AI submits typed movement intent while the enemy movement owner validates, accelerates, steers, resolves collision, and commits motion
   **And** arrival is confirmed through tolerant position, orientation, contact, and clearance rules
   **And** AI does not assign velocity, teleport the enemy, call movement commits, or infer arrival from animation.

7. **Perform bounded probe-driven surface pursuit**

   **Given** the enemy reaches a valid climb entry with sufficient contact confidence
   **When** surface pursuit begins
   **Then** the movement owner derives movement from current surface probes, contact normals, policy limits, and the selected tactical objective
   **And** enemy-body motion remains swept, collision-aware, and committed once per physics step without passing through the wall or nearby obstacles
   **And** surface pursuit is bounded by authored distance, duration, confidence, and replan conditions rather than attempting unrestricted arbitrary-surface navigation.

8. **Generate a valid pounce solution**

   **Given** the enemy reaches an eligible surface position and retains a valid player target
   **When** it evaluates a pounce
   **Then** it produces a typed pounce solution containing source position, intended target or landing relationship, direction or launch motion, clearance result, affected-space binding, and stable solution identity
   **And** the solution is rejected if its required path, target, landing space, line of sight, or current run is invalid
   **And** pounce motion and attack delivery cannot pass through blocking geometry merely because the player remains targeted.

9. **Commit the pounce through the shared ability lifecycle**

   **Given** a valid pounce solution is selected
   **When** the behavior policy requests the pounce
   **Then** the action owner independently validates and commits one `AbilityExecution` with simulation-owned windup, active delivery, recovery, cancellation, and terminal result
   **And** the primitive trajectory, landing region, or attack-space warning consumes the same committed spatial facts as active delivery
   **And** movement during the pounce is submitted through the responsible movement owner and never controlled by animation or VFX.

10. **Resolve pounce hits and misses readably**

    **Given** the pounce enters active delivery
    **When** it intersects or misses the player
    **Then** an accepted hit resolves once through the shared hit-query, `ImpactContext`, damage, health, and attribution contracts
    **And** duplicate player hurtboxes cannot cause additional damage from the same execution
    **And** a miss produces an observable committed recovery opening during which the player can reposition or retaliate
    **And** presentation does not invent a hit, miss, or recovery state before simulation commits it.

11. **Preserve wall-based counterplay and recovery**

    **Given** the player observes the climbing response or pounce windup
    **When** they use the documented counter--such as changing lateral position or altitude, leaving the predicted wall relationship, or grappling to another valid position
    **Then** they can cause the pounce to miss or otherwise avoid its affected space without having their traversal state forcibly cancelled
    **And** the player retains at least one authored recovery option after an ordinary mistake
    **And** the tactic's eligibility, bounded reach, telegraph, and recovery prevent it from making all wall use tactically invalid.

12. **Remain compatible with active grappling**

    **Given** the alive climbing enemy remains an eligible moving `Grappleable` target
    **When** the player grapples it during approach, surface pursuit, pounce, or recovery
    **Then** the grapple tracks its authoritative moving anchor and obeys the existing pull and true maximum-length rules
    **And** climbing or pouncing does not silently cancel, push, retarget, or rewrite the player's grapple
    **And** death, reset, target invalidation, or an explicitly rejected discontinuity ends the attachment through the typed grapple contract.

13. **Abort safely when confidence is lost**

    **Given** surface contact, route confidence, target validity, pounce validity, required clearance, run identity, or policy eligibility becomes invalid
    **When** the climbing owner detects the condition
    **Then** it commits one typed abort reason, cancels pending movement and ability work exactly once, and enters its authored safe fallback
    **And** fallback returns the enemy to supported grounded pursuit, controlled descent or recovery, or a safe non-climbing tactical state as current geometry permits
    **And** the enemy cannot remain suspended indefinitely, continue damaging from an invalid route, repeatedly restart the same failed climb, or teleport to safety.

14. **Use rare override volumes only as exclusions**

    **Given** particular geometry must not support climbing or pouncing
    **When** an authored `NoEnemyClimb` or `NoPounce` override volume is present
    **Then** intersecting candidates receive the corresponding rejection reason
    **And** the override cannot provide a positive route, entry point, destination, or pounce solution
    **And** the ordinary fixture and normal arena workflow remain valid with zero climb routes and zero climb-entry anchors.

15. **Clean up on death and reset**

    **Given** the enemy dies or the fixture resets during entry approach, surface pursuit, pounce windup, active delivery, recovery, or abort
    **When** termination commits
    **Then** tactical reservations, probe state, movement submissions, active delivery, spatial bindings, target references, and presentation terminate exactly once
    **And** stale candidate, movement, pounce, damage, or fallback work from the prior run is rejected
    **And** a fresh run can discover and execute the climbing tactic again from its authored starting state.

16. **Provide replaceable presentation and bounded diagnostics**

    **Given** final climbing and pounce animation or VFX do not exist
    **When** discovery, selection, approach, climb, windup, active pounce, recovery, rejection, or fallback occurs
    **Then** primitive fallback presentation makes the important player-facing phase and affected space readable
    **And** animation and VFX adapters can later consume the committed climbing, movement, ability, spatial, impact, and terminal facts without becoming authoritative
    **And** development diagnostics can visualize bounded candidate positions, rejection reasons, scores, selection, surface normals, contact confidence, pounce solution, current tactic state, replan reason, and fallback reason using already-computed data.

17. **Make the climbing prototype manually reproducible**

    **Given** the named climbing-and-pounce fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can provoke a supported climb, observe surface pursuit and pounce, execute the intended avoidance response, punish a missed-pounce recovery, and deliberately experience the failed response
    **And** they can test an excluded or unsupportable surface, observe safe fallback, grapple the moving enemy, defeat its source, reset the fixture, and repeat the scenario
    **And** the record distinguishes objective contract results from subjective notes about telegraph timing, pursuit readability, and pounce feel.

18. **Verify deterministic feasibility**

    **Given** the permanent climbing-policy suite and focused real-Jolt fixture run
    **When** they exercise multiple valid entries, no valid entry, occlusion, insufficient clearance, noisy surface normals, supported and discontinuous geometry, stable ties, hysteresis, override volumes, target movement and loss, blocked pounces, duplicate hurtboxes, grapple interaction, death, abort, repeated reset, stale runs, and randomized notification order
    **Then** discovery, selection, movement, pounce, damage, fallback, and cleanup follow their declared contracts
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time behavior and outcomes within documented tolerances.

19. **Conclude the early feasibility gate honestly**

    **Given** automated and manual climbing evidence has been collected
    **When** Story 3.2 is reviewed
    **Then** completion requires a runnable anchor-free climb-and-pounce prototype with demonstrated safe fallback and reproducible diagnostics
    **And** a fundamental failure of runtime geometry discovery is recorded as a deliberate architecture decision and separately scoped remediation rather than being hidden through authored climb routes
    **And** the story has not created unrestricted arbitrary-surface navigation, a navigation-mesh framework, production Rootstalker content, authored climb anchors, final animation/VFX, additional pressure mechanics, or full encounter ownership.
