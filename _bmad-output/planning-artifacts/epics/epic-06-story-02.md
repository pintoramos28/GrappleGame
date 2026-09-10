---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 2
---

# Story 6.2: Turn Knockback into a Prediction-Breaking Choice

As a player,
I want a frozen predictive mark and incoming knockback to remain understandable when they overlap,
So that I can avoid both, deliberately use displacement to escape the prediction, or recover after a mistake.

**Acceptance Criteria:**

1. **Declare the combined gameplay question**

   **Given** the predictive-mark-and-knockback scenario is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player understands that the prediction freezes before a separate impulse changes their actual motion
   **And** the player may avoid the knockback and change course, use the knockback as a costly prediction-breaking displacement, or recover through ordinary traversal
   **And** the timing relationship, impulse direction, viable responses, deliberate failures, recovery, source-death behavior, reset behavior, tuning questions, manual procedure, and evidence requirements are explicit
   **And** it remains one focused two-ability scenario rather than a launch combo, juggle system, or general crowd-control encounter.

2. **Compose the approved mechanics without redesigning them**

   **Given** Stories 3.5 and 4.2 established one-shot knockback and the frozen predictive mark
   **When** Story 6.2 is implemented
   **Then** it references their existing immutable definitions, action owners, lifecycle timing, target sampling, prediction, lane delivery, impact, damage, motor influence, grapple, wall, source-death, and cleanup behavior
   **And** the direct lane projectile remains only the approved delivery mechanism for the knockback rather than being counted or tuned as a third pressure mechanic
   **And** neither component receives combination-specific prediction, impulse, damage, collision, homing, movement, or terminal logic
   **And** the fixture owns only authored setup, bounded sequencing, result observation, reset, and evidence.

3. **Author one immutable combination manifest**

   **Given** the baseline combination profile is inspected
   **When** its values and references are resolved
   **Then** it declares one production player, one primitive predictive source, one primitive knockback source, the approved component definitions, fixture geometry, starting transforms, movement axis, source direction, request schedule, acceptable impact interval, occurrence limits, manual checks, and evidence rules
   **And** it permits one unresolved predictive mark and one knockback delivery during the baseline paired attempt
   **And** prediction timing, prediction horizon, radius, damage, projectile behavior, impulse magnitude, cadence, and source-death policies remain referenced from their owning definitions
   **And** all combination-only spatial and timing values remain immutable authored configuration rather than literals in the fixture.

4. **Provide one bounded motion-and-recovery layout**

   **Given** the baseline fixture is opened
   **When** its authored geometry is inspected
   **Then** it supplies a straight run-up that lets the player establish stable forward motion before prediction tracking begins
   **And** the predictive source faces the movement region while the knockback source occupies a lateral position whose delivery direction crosses the player's expected forward path
   **And** the complete maximum predicted displacement, frozen two-metre sphere, projectile route, expected impulse displacement, and player body remain inside validated fixture bounds
   **And** open lateral space, vertical clearance, grapple targets, wall surfaces, and nonterminal landing or recovery space remain available beyond the expected displacement.

5. **Validate the timing relationship before activation**

   **Given** a paired attempt is requested
   **When** the pressure lab validates its manifest and current component definitions
   **Then** the authored schedule causes the predictive mark to lock before the expected knockback impact
   **And** an accepted knockback can become eligible and affect player motion at least 0.30 seconds before the predictive strike activates under the baseline profile
   **And** the player receives the complete approved telegraph for each attack without either source skipping or shortening windup
   **And** incompatible timing returns a typed scenario-validation failure instead of silently changing component durations, projectile speed, source distance, impulse scheduling, or prediction timing.

6. **Validate survivable recovery conditions**

   **Given** the combination fixture must demonstrate recovery after an ordinary mistake
   **When** its player health, component damage, geometry, and displacement bounds are validated
   **Then** one accepted knockback delivery and one predictive-mark hit cannot exceed the fixture player's authored starting health
   **And** the expected one-shot displacement cannot place the player outside effect bounds, inside protected geometry, or beyond every recovery option
   **And** failure of either requirement prevents scenario activation rather than enabling fixture invulnerability, reducing damage secretly, clipping displacement, or relocating the player.

7. **Start every attempt from fresh scoped state**

   **Given** all prerequisites are valid
   **When** a new attempt begins
   **Then** the player and both sources receive typed initialization under one fresh fixture-run identity
   **And** the player begins at the authored run-up entrance with zero scenario-authored velocity and establishes movement through ordinary input
   **And** health, transforms, velocity, traversal state, action readiness, target state, pending impulses, prediction reservations, and evidence contain no data from an earlier attempt
   **And** the fixture never injects the desired approach velocity directly into the player motor.

8. **Begin only from a valid observable approach**

   **Given** the tester has entered the run-up and requests the paired sequence
   **When** the fixture evaluates its bounded start condition
   **Then** it requires a finite authoritative player motion snapshot inside the authored start region and travelling generally along the displayed test axis
   **And** the current speed and direction are displayed as observational guidance without becoming a forced movement target
   **And** an invalid, stationary, stale, out-of-bounds, or oppositely directed start returns a typed rejection without beginning either attack
   **And** the tester can establish another valid approach immediately through ordinary movement.

9. **Keep both sources and action lifecycles independent**

   **Given** a valid paired sequence begins
   **When** the predictive and knockback requests are submitted according to the authored schedule
   **Then** each request passes independently through its existing action owner and validation boundary with a distinct stable identity
   **And** the predictive source cannot aim, deliver, or apply the knockback
   **And** the knockback source cannot sample movement, calculate prediction, move the mark, or deliver its damage
   **And** rejection, interruption, death, or completion of one source does not automatically cancel, accelerate, or retime the other.

10. **Lock prediction before the expected impulse**

    **Given** the predictive execution enters its first 0.40 seconds while the player continues moving
    **When** its normal tracking-to-locked boundary commits
    **Then** the mark stores one immutable target-motion snapshot and frozen `AbilitySpatialSnapshot` through Story 4.2
    **And** its predicted center derives from the player's position and velocity at that lock boundary
    **And** the knockback delivery has not yet applied a movement influence under the valid baseline schedule
    **And** presentation clearly communicates that later movement will not cause the locked sphere to follow the player.

11. **Keep the two telegraphs distinguishable**

    **Given** the frozen mark warning and knockback lane warning overlap while the player is moving
    **When** the tester observes them without diagnostics
    **Then** the mark remains a fixed three-dimensional volume that communicates future area danger
    **And** the knockback delivery remains a directional lane and projectile that communicates an incoming hit and displacement direction
    **And** non-color-only shape, motion, direction, and phase cues distinguish the stationary future strike from the travelling impulse delivery
    **And** neither warning conceals the other's relevant boundary, timing, direction, or counter.

12. **Keep prediction frozen after knockback**

    **Given** the predictive mark has locked and the player subsequently receives an accepted knockback impact
    **When** the impact changes the player's velocity or position
    **Then** the stored prediction inputs, predicted center, radius, activation time, and target attribution remain unchanged
    **And** the predictor does not resample post-impact velocity, use the new player position, follow the motor, or compensate for collision response
    **And** the mark hits only if the player's actual hurt volume intersects the original frozen sphere when it activates
    **And** diagnostics distinguish the lock-time motion snapshot from the later impact and committed motor results.

13. **Let knockback use its own committed impact facts**

    **Given** the lateral projectile delivers an accepted impact after prediction lock
    **When** its knockback occurrence is constructed
    **Then** direction comes from the projectile-delivery facts stored in `ImpactContext` and magnitude comes from the approved knockback definition
    **And** it does not use the predictive center, predicted direction, current presentation, source's current transform, or player's earlier prediction snapshot to shape the impulse
    **And** the occurrence applies no more than once through the normal one-shot motor phase
    **And** subsequent collision and movement remain owned by the player motor.

14. **Allow the player to avoid both attacks directly**

    **Given** both warnings are readable and the mark has locked
    **When** the player leaves the knockback lane and changes direction, speed, or altitude enough to leave the frozen sphere
    **Then** the projectile misses or is blocked according to its approved delivery rules
    **And** the predictive strike remains fixed and misses at activation
    **And** no attack retargets, widens, repeats, or adds hidden correction to compensate
    **And** the successful response can be understood from player-facing cues without diagnostic values.

15. **Expose continued predictable movement as a deliberate failure**

    **Given** the mark has locked from approximately constant forward movement
    **When** the player avoids the knockback delivery but continues along the original predicted trajectory
    **Then** the predictive strike hits only if the player's current hurt volume occupies the frozen sphere at activation
    **And** the result applies the mark's normal single damage occurrence without knockback or lingering control
    **And** the player can distinguish that the hit resulted from continuing the predicted motion rather than from the avoided knockback or a hidden homing correction.

16. **Allow knockback to break the prediction at a cost**

    **Given** the frozen sphere lies along the player's continuing forward trajectory and the lateral knockback delivery remains incoming
    **When** the player deliberately accepts the nonlethal hit and its one-shot impulse moves their eligible hurt volume outside the frozen sphere before activation
    **Then** the predictive strike misses at its unchanged world position
    **And** the player receives only the knockback delivery's ordinary damage and displacement
    **And** the fixture records that displacement altered the actual trajectory without altering the stored prediction
    **And** intentionally accepting damage remains an optional emergency or experimental response rather than the required optimal counter.

17. **Preserve traversal-based prediction breaks**

    **Given** both attacks are active
    **When** the player grapples, releases, changes grapple direction, jumps, falls, wall-runs, wall-sticks, or wall-jumps
    **Then** ordinary traversal and the semantic motor pipeline remain authoritative
    **And** those actions may leave the lane, frozen sphere, or both according to the resulting movement
    **And** neither ability cancels grapple, invalidates a wall, suppresses input, forces facing, or directly changes locomotion state
    **And** the fixture retains at least one grapple response and one wall or altitude response that can avoid both attacks under baseline tuning.

18. **Allow active traversal to recover after displacement**

    **Given** an accepted knockback applies while the player is grounded, airborne, grappling, wall-running, or wall-sticking
    **When** the player responds after the impulse
    **Then** existing collision, air control, grapple constraints, wall contacts, and locomotion policies determine the outcome
    **And** the player may use remaining air control, an existing grapple, a new grapple, or an available wall or landing surface to recover
    **And** the combination does not automatically detach grapple, fabricate wall loss, restore the pre-impact velocity, or script a return
    **And** recovery remains possible even if the predictive strike subsequently hits once.

19. **Prevent an unavoidable control chain**

    **Given** the player receives the knockback delivery and remains eligible for the predictive strike
    **When** both occurrences complete
    **Then** the knockback supplies one velocity change with no continuing force, stun, repeated impulse, or input suppression
    **And** the predictive strike supplies at most one damage occurrence with no displacement, tether, stun, or lingering hazard
    **And** the interval and fixture space preserve a player-controlled recovery opportunity after the impulse
    **And** taking both hits does not create a combination-specific reaction that removes all control until another attack begins.

20. **Resolve close timing boundaries deterministically**

    **Given** prediction lock, projectile impact, impulse eligibility, motor commit, and predictive activation occur on nearby physics steps
    **When** their authoritative times are compared
    **Then** each owner uses the project's declared fixed-step ordering and committed snapshots
    **And** the baseline schedule avoids depending on equal-time ambiguity by preserving its validated post-impact response interval
    **And** explicit boundary tests for impact immediately before or after lock and activation produce stable documented results
    **And** scene-tree, signal, subscriber, and callback order cannot change which velocity is predicted, whether an impulse applies, or whether the player occupies the strike volume.

21. **Apply source-death policies independently**

    **Given** either source dies during the paired sequence
    **When** its approved policy resolves
    **Then** predictive-source death before delivery cancels only the predictive execution
    **And** knockback-source death before projectile spawn cancels only that delivery, while a spawned projectile or accepted knockback occurrence follows its approved post-commit policy
    **And** killing one source does not cancel, retarget, advance, or satisfy the other execution
    **And** no committed prediction, impact, impulse, or damage result dereferences a removed source node.

22. **Record one bounded attempt result**

    **Given** the paired sequence has begun
    **When** both accepted executions become terminal, the player dies, the run resets, or the scenario is manually aborted
    **Then** the fixture records one terminal attempt result without altering gameplay to manufacture it
    **And** it distinguishes both avoided, prediction-only hit, knockback-only hit, both hit, knockback-assisted prediction escape, recovery demonstrated, source interruption, partial rejection, invalid setup, player defeat, and abort
    **And** evidence records lock-time position and velocity, frozen center, impact context, impulse vector and application step, actual player position at strike activation, damage results, traversal response, recovery, and terminal reasons
    **And** the result grants no reward, objective progress, checkpoint, or production encounter state.

23. **Reset both mechanics and pending motion completely**

    **Given** reset is requested during approach validation, tracking, lock, knockback windup, projectile travel, impact, pending impulse, motor application, predictive activation, recovery, source death, or evidence finalization
    **When** the old run is invalidated
    **Then** both executions, mark reservation, motion snapshots, spatial snapshots, lane warning, projectile, impact, pending or consumed impulse, damage occurrences, source states, presentations, attempt result, and late work are removed or rejected exactly once
    **And** player health, transform, velocity, traversal state, contacts, and both sources return to their authored starting state
    **And** a new approach can begin immediately without inheriting a prediction, impulse, cadence, or collision result.

24. **Keep combination timing and direction configurable**

    **Given** an alternate valid combination profile changes source positions, run-up direction, request offset, accepted impact interval, minimum post-impact response interval, route markers, or recovery geometry
    **When** the same fixture consumes it
    **Then** validation, sequencing, observation, evaluation, and evidence use those values without code changes
    **And** no alternate profile mutates predictive timing, prediction radius, damage, projectile delivery, impulse magnitude, motor ordering, or other component definitions
    **And** one mirrored-direction profile demonstrates that changing the authored delivery direction can make the impulse less helpful or move the player toward the predicted region while still preserving a viable direct counter and recovery option
    **And** invalid profiles fail validation rather than applying hidden aim assistance or displacement correction.

25. **Provide replaceable combined feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** approach validation, tracking, lock, knockback warning, impact, impulse, strike, hit, miss, recovery, source death, or reset occurs
    **Then** primitive prediction volumes, lane and projectile geometry, displacement arrows, trajectory traces, impact markers, health feedback, route markers, and typed result displays make the interaction testable
    **And** future presentation can consume committed prediction, impact, motor, damage, and attempt facts without controlling them
    **And** diagnostics expose scenario and run identities, request order, lifecycle phases, target snapshots, raw and capped prediction, frozen sphere, projectile state, `ImpactContext`, pending and applied impulse, pre- and post-impulse velocity, player position at activation, hit results, source states, and cleanup.

26. **Make the combination manually reproducible**

    **Given** the named prediction-and-knockback fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they first evaluate both warnings with diagnostics disabled and avoid both by leaving the lane and changing course after lock
    **And** they avoid the knockback while continuing predictable movement to receive a mark hit, deliberately accept the lateral knockback to escape the frozen mark, and recover from displacement through ordinary movement, grapple, or wall interaction
    **And** they test a knockback-only hit, a safely survivable both-hit case where spatially achievable, the mirrored direction profile, each source's pre- and post-commit death behavior, reset during every combined phase, and repeated runs
    **And** every check has observable pass or fail conditions and retained evidence separates objective timing, movement, damage, and cleanup results from subjective readability, impulse usefulness, recovery difficulty, and pressure observations.

27. **Verify deterministic combined behavior**

    **Given** the permanent prediction-and-knockback suite and focused real-Jolt fixture run
    **When** they exercise valid and invalid approaches, prediction sampling, lock boundaries, request scheduling, projectile hit and miss, accepted and rejected impacts, impulse application, direct and traversal counters, prediction escape, mirrored direction, both-hit conditions, source deaths, duplicate callbacks, stale runs, randomized notification order, and repeated reset
    **Then** the mark predicts from exactly one lock-time snapshot, each knockback occurrence applies no more than once, and each attack damages the player no more than once
    **And** later displacement never moves or rebuilds the frozen mark, and the combination retains at least one viable response plus recovery after an ordinary nonlethal mistake
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time phase timing, snapshot choice, impact and impulse ordering, resulting motion, hit outcomes, damage totals, terminal counts, and cleanup within documented tolerances.

28. **Keep the story bounded to one approved pair**

    **Given** Story 6.2 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it contains only the existing predictive mark, existing lane-delivered one-shot knockback, two primitive sources, one bounded fixture with an alternate direction profile, finite sequencing, observational evaluation, reset, and focused verification
    **And** it has not added homing prediction, acceleration-aware prediction, repeated launches, juggling, stagger, stun, general crowd-control resistance, production enemy AI, encounter orchestration, difficulty scaling, final presentation, or Last Garden allocation
    **And** the remaining four combinations, full 17-mechanic gate, and production-subset decision remain assigned to later Epic 6 stories.
