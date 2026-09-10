---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.8'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 8
---

# Story 2.8: Keep Enemy AI at the Intent Boundary

As a player,
I want enemies to make decisions through consistent combat rules,
So that their behavior remains readable and cannot bypass attack timing, damage, or movement authority.

**Acceptance Criteria:**

1. **Separate decision-making from execution**

   **Given** an enemy uses a LimboAI behavior tree
   **When** the tree selects what the enemy should do
   **Then** it may produce tactical intent and typed movement or ability requests only
   **And** movement executors own enemy velocity and movement commits
   **And** the action owner and `AbilityExecution` own attack validation, timing, spatial delivery, cancellation, and terminal results.

2. **Publish one bounded tactical snapshot**

   **Given** an active enemy begins its declared AI evaluation for a physics step
   **When** perception and current actor state are sampled
   **Then** one immutable `EnemyTacticalSnapshot` records the physics-step identity, stable enemy identity, enemy position and velocity, alive and current-action facts, current target reference and identity, target position and velocity where available, visibility, line of sight, distance, and direction
   **And** the behavior tree consumes that snapshot rather than repeatedly querying scene nodes or physics.

3. **Use stable target references**

   **Given** perception identifies a potential player target
   **When** the target is written into enemy working memory
   **Then** the blackboard stores a stable typed target reference and bounded tactical facts rather than treating a retained `Node3D` as combat authority
   **And** any optional node access uses a weak validated reference through the perception or executor boundary
   **And** target removal, death, or run mismatch produces a typed invalid-target result without a stale dereference.

4. **Use named authoritative perception queries**

   **Given** enemy perception requires range, view direction, or line-of-sight facts
   **When** the snapshot is produced
   **Then** physics access is confined to the perception owner and uses the named collision matrix plus immutable query profiles
   **And** behavior-tree tasks contain no magic masks, direct-space queries, group-based gameplay meaning, or duplicated line-of-sight calculations
   **And** duplicate candidates and ties are normalized through explicit stable rules.

5. **Request movement without writing velocity**

   **Given** the behavior tree chooses to pursue, face, hold position, or move away from a target
   **When** it submits an `EnemyMovementRequest`
   **Then** the request contains stable requester and target identities, physics-step identity, typed movement intent, and bounded desired spatial facts
   **And** the enemy movement owner validates and executes the request through its public boundary
   **And** the tree cannot assign velocity, call `move_and_slide()`, teleport the enemy, or manipulate private movement nodes.

6. **Request attacks without activating them**

   **Given** the behavior tree decides that a melee attack is tactically appropriate
   **When** it submits an `EnemyAbilityRequest`
   **Then** the request identifies the intended `AttackDefinition`, target, tactical snapshot, occurrence, and current run or scope where supplied
   **And** the enemy action owner independently validates range, target validity, line of sight, action state, cooldown, definition, and scope before committing an execution
   **And** the behavior tree cannot activate hitboxes, create damage snapshots, choose critical results, start phase timers, or invoke presentation directly.

7. **Return typed execution outcomes to AI**

   **Given** a movement or ability request has been submitted
   **When** its responsible owner accepts, rejects, completes, cancels, or requires fallback
   **Then** one typed action result records the request identity, current status, stable outcome or reason, execution identity where committed, and relevant target identity
   **And** the behavior tree may choose its next intent from that committed result during a later declared evaluation
   **And** it does not infer success from animation state, hitbox activity, elapsed wall-clock time, or a missing error.

8. **Prevent request spam and stale intent**

   **Given** a behavior-tree branch remains active across multiple evaluations
   **When** its previous request is pending or already committed
   **Then** it observes that occurrence rather than submitting a duplicate request every tick
   **And** repeated or stale physics-step requests return typed results without restarting movement or attack execution
   **And** a new request occurrence is created only when the behavior policy deliberately chooses a new action.

9. **Commit state before AI observes results**

   **Given** a movement or ability owner changes execution state
   **When** the result becomes visible to the behavior tree
   **Then** the owner's state is already committed
   **And** signals may notify observers but cannot provide request/response authority or depend on connection order
   **And** reentrant AI evaluation cannot change the just-committed action during the same owner phase.

10. **Clear AI safely on death and reset**

    **Given** an enemy dies, loses its target, is disabled, or receives a new reset/run context
    **When** the AI owner processes that event
    **Then** pending intents and requests are invalidated with typed reasons, working memory drops stale target references, and no new action is requested from the obsolete state
    **And** action cancellation and health restoration remain owned by their respective components
    **And** later reactivation begins from a fresh tactical snapshot and request identity.

11. **Migrate existing behavior-tree tasks**

    **Given** the current tree includes tasks that call controller movement methods or directly activate an attack hitbox
    **When** the intent boundary is adopted
    **Then** those tasks are replaced or migrated to construct typed requests and inspect typed results
    **And** no referenced task directly calls hitbox activation, damage, player movement, private HSM transitions, or authoritative timing
    **And** retained LimboAI Resources, task scripts, UIDs, and references are updated safely.

12. **Keep the prototype runnable during staging**

    **Given** the complete melee-enemy migration occurs in Story 2.9
    **When** Story 2.8 connects the intent boundary to the current enemy scene
    **Then** narrow typed adapters may translate accepted requests to the current movement and action owners
    **And** the current melee enemy remains exercisable without restoring forbidden behavior-tree authority
    **And** those compatibility adapters are removed when Story 2.9 adopts the production lifecycle and delivery contracts.

13. **Expose observational AI diagnostics**

    **Given** development diagnostics are enabled
    **When** an enemy evaluates perception or submits an action
    **Then** they expose the tactical snapshot, selected intent, request and result identities, acceptance or rejection reason, current execution identity, and relevant target facts
    **And** diagnostics do not repeat perception queries, choose actions, alter blackboard state, or invoke executors.

14. **Verify the intent boundary**

    **Given** the permanent enemy-intent suite runs with recording perception, movement, and action owners
    **When** it exercises target acquisition and loss, visibility and line-of-sight changes, in-range and out-of-range attack requests, accepted and rejected movement, pending actions, duplicate requests, stale steps and runs, source and target removal, death, reset, and randomized update or subscriber order
    **Then** the same tactical inputs produce the declared typed requests and committed results
    **And** recording owners confirm that the behavior tree never performs movement, hit delivery, damage, lifecycle advancement, or player mutation itself
    **And** equivalent timed scenarios at shipping 60 Hz and diagnostic 120 Hz preserve real-time perception and action-request behavior within documented tolerances.

    **Given** Story 2.8 is complete
    **When** the current enemy smoke test, player combat fixture, launch scene, Epic 1 route, retained-reference, and working-tree checks are performed
    **Then** AI decisions operate through the typed intent boundary and the project remains runnable
    **And** the story has not completed the production melee enemy, changed pursuit or combat balance, added navigation meshes, implemented climbing or flying, created additional enemy types, or introduced encounter ownership.
