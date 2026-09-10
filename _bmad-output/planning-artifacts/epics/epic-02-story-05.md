---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 5
---

# Story 2.5: Coordinate Traversal and Attacks Explicitly

As a player,
I want traversal and attacks to combine only when their authored rules permit it,
So that I retain predictable movement and incompatible actions never fight over my state or velocity.

**Acceptance Criteria:**

1. **Give cross-capability arbitration one owner**

   **Given** the player can move, grapple, and attack concurrently
   **When** one capability requests a change affecting another
   **Then** `PlayerAbilityCoordinator` is the sole owner of that cross-capability decision
   **And** the movement HSM retains ownership of locomotion state
   **And** the attack lifecycle retains ownership of attack phase
   **And** the grapple controller retains ownership of its attachment and termination.

2. **Describe coordination through authored policy**

   **Given** an `AttackDefinition` can interact with traversal
   **When** its coordination policy is inspected
   **Then** it explicitly declares allowed locomotion states, grapple-start and grapple-active behavior, movement policy by attack phase, permitted interruptions, damage response, and death behavior
   **And** policy uses typed enums or definitions rather than node paths, arbitrary priorities, or state-name strings
   **And** the actual initial-melee policy values remain assigned to Story 2.6.

3. **Evaluate one authoritative capability snapshot**

   **Given** a player ability request is evaluated during a physics step
   **When** the coordinator begins arbitration
   **Then** it consumes one immutable `PlayerCapabilitySnapshot` containing the physics-step identity, current locomotion state, current attack execution and phase, current grapple execution and state, alive or terminal state, and relevant cooldown facts
   **And** it does not query private HSM children or reconstruct competing movement, contact, or grapple facts.

4. **Return a typed atomic coordination plan**

   **Given** a valid attack or grapple request and current capability snapshot
   **When** arbitration succeeds
   **Then** the coordinator returns one `PlayerCoordinationPlan` identifying the accepted request, any prerequisite cancellation or release commands, the attack start command, movement policy, and context-capture boundary
   **And** the entire plan is validated before any owner mutates state.

   **Given** arbitration rejects the request
   **When** the rejection is committed
   **Then** it returns a stable typed reason without partially cancelling another ability, consuming cooldown, capturing attack context, or starting presentation.

5. **Keep allowed traversal active during attacks**

   **Given** the attack policy permits the current locomotion state
   **When** an attack execution progresses through windup, active, and recovery
   **Then** the movement HSM continues processing command frames, contacts, and valid transitions independently
   **And** the attack may submit only its authored semantic motor policy through `PlayerMotor`
   **And** it cannot write final velocity, perform movement, or directly transition the movement HSM.

6. **Resolve incompatible grapple interaction explicitly**

   **Given** the player requests an attack while grappling
   **When** the attack's grapple policy is evaluated
   **Then** the policy explicitly allows concurrent execution, rejects the attack, or requires a typed grapple termination before attack commitment
   **And** the grapple is never cancelled implicitly as a side effect of entering an attack state.

   **Given** the player requests a grapple while attacking
   **When** the current attack phase and grapple-start policy are evaluated
   **Then** the coordinator explicitly allows the grapple, rejects it, or cancels the attack with an authored reason before committing the grapple
   **And** the result cannot depend on HSM update order.

7. **Apply attack movement policies through the motor**

   **Given** an accepted attack declares full movement, scaled steering, retained momentum, a directional commitment, or another supported movement policy for its current phase
   **When** movement resolves
   **Then** the attack submits the corresponding typed influence, constraint, or gate through the existing semantic motor phases
   **And** locomotion and other compatible influences continue to follow deterministic motor composition
   **And** presentation and attack-state scripts do not directly set player velocity or call `move_and_slide()`.

8. **Coordinate interruption and damage requests**

   **Given** an active attack receives an interruption request such as accepted damage, stagger, invalid locomotion, or an authored ability conflict
   **When** the current definition and phase permit interruption
   **Then** the coordinator requests one typed lifecycle cancellation and applies the associated movement-policy cleanup
   **And** a non-interrupting result leaves the execution unchanged
   **And** health acceptance and concrete hit-reaction behavior remain assigned to Story 2.7.

9. **Make death unconditionally terminal**

   **Given** player death is committed
   **When** the coordinator processes the terminal request
   **Then** it stops accepting new ability requests, cancels the active attack and grapple exactly once with typed death reasons, clears their motor submissions, and requests the movement owner's dead transition
   **And** no attack or grapple can become active later in that physics step
   **And** restoration remains the responsibility of the future reset owner.

10. **Consume command edges exactly once**

    **Given** attack and grapple presses occur in the same or adjacent `PlayerCommandFrame` instances
    **When** the coordinator evaluates them
    **Then** each pressed or released edge is consumed at most once using its command-frame and physics-step identity
    **And** simultaneous requests follow a documented stable ordering or return an explicit conflict result
    **And** changing HSM, node, or signal order cannot change the outcome.

11. **Preserve staged player integration**

    **Given** the coordinator is introduced before the player melee migration
    **When** it is connected to the current player scene
    **Then** typed adapters route current attack and grapple requests to their existing owners only after an accepted coordination result
    **And** the player remains controllable and the Epic 1 traversal route remains completable
    **And** any narrowly scoped attack compatibility adapter is removed when Story 2.6 adopts `AbilityExecution`.

12. **Expose coordination diagnostics**

    **Given** development diagnostics are enabled
    **When** a player request is evaluated
    **Then** they expose the command and physics-step identities, capability snapshot, applicable policy, accepted or rejected result, cancellation prerequisites, motor policy, and stable reason codes
    **And** diagnostics observe the committed decision without rerunning arbitration or invoking owner commands.

13. **Verify the coordination matrix**

    **Given** the permanent coordination suite runs with recording movement, grapple, and attack owners
    **When** it exercises grounded, airborne, grappling, wall-running, wall-sticking, and dead locomotion facts against ready, windup, active, recovery, and terminal attack states
    **Then** representative allow, reject, cancel-attack, terminate-grapple, interrupt, simultaneous-input, repeated-input, damage, and death policies produce their declared atomic outcomes
    **And** randomized owner and subscriber order cannot alter those outcomes
    **And** equivalent command sequences at shipping 60 Hz and diagnostic 120 Hz produce equivalent decisions without lost or duplicated input edges.

    **Given** Story 2.5 is complete
    **When** the launch scene, Epic 1 route, current attack smoke behavior, permanent suites, retained references, and working-tree diff are reviewed
    **Then** traversal and attack ownership remain independent behind one typed arbitration boundary
    **And** the story has not finalized the player melee policy, migrated its lifecycle and delivery, applied health damage, implemented hit reactions, built enemy AI, or introduced encounter reset infrastructure.
