---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.9'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 9
---

# Story 2.9: Deliver One Complete Readable Melee Enemy

As a player,
I want one complete melee enemy whose pursuit, attack, reactions, and defeat follow the shared combat rules,
So that I can read its intent, exploit its commitments, and fight it reliably while using traversal.

**Acceptance Criteria:**

1. **Compose one production melee-enemy definition**

   **Given** the first production melee enemy is authored
   **When** its composition is inspected
   **Then** immutable typed definitions supply its perception, locomotion, stopping, attack lifecycle, melee space, damage, health, reaction, grapple-target, and presentation policies
   **And** the enemy scene, behavior tree, controller, and presenters contain no competing copies of authoritative values
   **And** occurrence-specific perception, movement, ability, health, and reset state remains owned by the responsible runtime components.

2. **Preserve the current enemy baseline during migration**

   **Given** the current prototype enemy is the behavior baseline
   **When** its values migrate into the production definitions
   **Then** vision range is 13 metres with a 120-degree field of view and a 1.75-second target-loss grace period
   **And** pursuit uses a 4.2-metres-per-second maximum speed, 16-metres-per-second-squared acceleration, 20-metres-per-second-squared deceleration, and a 0.35-metre stopping tolerance
   **And** melee uses a 2.1-metre attack range, 0.22-second windup, 0.20-second active window, 1.25-second start-to-next-start cadence, 8 base damage, 1.0 attack-space scale, and 4 poise where that value is already represented
   **And** the migration does not silently rebalance those values or create duplicate cooldown authority.

3. **Initialize within a typed combat scope**

   **Given** the enemy enters a focused combat fixture or future encounter activation
   **When** its combatant context initializes
   **Then** it receives a stable entity identity, team, active run and reset identities, authored spawn transform, required definitions, and validated component references
   **And** perception, AI, movement, abilities, health, grapple targeting, and presentation bind to that context through public boundaries
   **And** missing or invalid required data prevents unsafe activation through a typed development-visible failure.

4. **Acquire, retain, and lose the player readably**

   **Given** an alive player moves into, through, or out of the enemy's authored perception
   **When** the perception owner publishes tactical snapshots
   **Then** the enemy acquires the player only from valid range, field-of-view, and line-of-sight facts, retains or loses the target according to the authored grace policy, and exposes the resulting state to AI
   **And** pursuit begins and ends from committed target facts rather than animation, render timing, groups, or direct behavior-tree physics queries
   **And** target removal, player death, enemy death, or run change clears the target safely.

5. **Pursue through typed movement intent**

   **Given** the enemy has a valid visible or temporarily retained player target
   **When** the behavior policy chooses to approach, face, stop, or hold
   **Then** it submits an `EnemyMovementRequest` through the Story 2.8 intent boundary
   **And** the enemy movement owner alone accelerates, decelerates, turns, resolves contact, and commits velocity using the authored locomotion values
   **And** the enemy settles within its stopping policy without behavior-tree velocity writes, oscillatory request spam, or attack-authored teleportation.

6. **Request and commit attacks through the shared lifecycle**

   **Given** the player is a valid target and satisfies the authored attack conditions
   **When** the behavior policy requests the melee attack
   **Then** the action owner independently validates target, range, line of sight, current action, cooldown, scope, and definition before accepting it
   **And** one enemy-owned `AbilityExecution` advances windup, active, recovery, and completion in fixed-step physics time
   **And** rejected, duplicate, stale, or busy requests return typed reasons without restarting or extending the current execution.

7. **Keep warning and delivery in the same melee space**

   **Given** an enemy attack has committed
   **When** windup and active spatial snapshots are produced
   **Then** the primitive telegraph and later swept melee query consume the same source-relative `MeleeSpaceDefinition`
   **And** the enemy may track the current target during windup according to the authored facing policy
   **And** the delivery direction locks at active start so movement after commitment cannot rotate an already-released attack onto the player
   **And** rendered presentation cannot alter attack reach, timing, direction, or hit eligibility.

8. **Damage the player through authoritative delivery**

   **Given** the player's valid hurtbox intersects the active swept melee space
   **When** the hit query accepts the contact
   **Then** one immutable source-side `DamageSnapshot`, delivery occurrence, and impact-time `ImpactContext` resolve through the shared typed damage boundary
   **And** the player's `CombatHealth` receives 8 base damage subject to the approved target-side rules
   **And** the same player combatant can be hit no more than once by that execution even if multiple hurtboxes overlap or the player leaves and re-enters the active space.

9. **Expose attack commitment and recovery to retaliation**

   **Given** the enemy begins windup, enters its active window, or recovers from an attack
   **When** the player observes and responds
   **Then** the current phase and locked delivery space remain legible through the available fallback presentation
   **And** the enemy cannot begin another attack before the authored 1.25-second start cadence permits it
   **And** the player may move, grapple, evade, or land a valid counterattack during the enemy's commitment and recovery under the ordinary combat rules
   **And** no hidden invulnerability, homing correction, or behavior-tree shortcut removes that opening.

10. **React to damage without bypassing combat ownership**

    **Given** the enemy receives accepted nonlethal damage
    **When** its health result commits
    **Then** it produces the authored basic hit-reaction occurrence and fallback feedback from committed damage and impact facts
    **And** any attack continuation, interruption, poise use, or movement consequence follows an explicit typed policy
    **And** the reaction itself does not recalculate damage, write velocity, advance ability phases, or directly manipulate AI state.

11. **Die and clean up exactly once**

    **Given** accepted damage reduces the enemy to zero health
    **When** death commits
    **Then** AI evaluation, perception, movement requests, active abilities, hit delivery, and hostile collision behavior terminate in the declared order exactly once
    **And** subsequent damage and action requests are rejected for the dead combatant
    **And** death presentation and diagnostics consume the committed death fact without owning cleanup or emitting duplicate outcomes.

12. **Remain a valid moving grapple target**

    **Given** the alive enemy is authored as `Grappleable`
    **When** the player acquires and grapples it while the enemy moves, attacks, reacts, or reaches the tether boundary
    **Then** grapple targeting uses the enemy's stable identity and current authoritative anchor transform
    **And** the Story 1.8 moving-anchor and true maximum-length rules remain authoritative, including pulling the player only when an away-moving target makes the tether taut and never pushing the player when it moves closer
    **And** enemy death, removal, invalidation, reset, or discontinuous relocation ends or updates the grapple through the typed target contract without a stale reference.

13. **Restore the enemy to a fresh combat state**

    **Given** the fixture or future encounter owner supplies a new typed reset context
    **When** the enemy resets after pursuit, attack, damage, death, or grapple interaction
    **Then** it returns to its authored spawn transform, health, alive state, perception state, locomotion state, action readiness, collision state, and grapple-target availability
    **And** old tactical snapshots, requests, executions, deliveries, hit history, target references, and presentation occurrences are invalidated by the prior run identity
    **And** repeated reset requests are idempotent and the restored enemy can acquire and fight the player again.

14. **Support replaceable animation and effects**

    **Given** final enemy animation, audio, and VFX assets are not yet available
    **When** perception, pursuit, windup, active delivery, recovery, hit reaction, death, grapple interaction, or reset commits
    **Then** primitive geometry, material changes, poses, or other documented fallbacks communicate the currently required combat state
    **And** typed presentation adapters expose the committed lifecycle, spatial, movement, impact, damage, and death facts needed to add bespoke animation and VFX later
    **And** animation markers and effects remain cosmetic, missing presentation cannot block simulation, and any future root motion must enter through a typed motor influence rather than moving the authoritative body directly.

15. **Exercise early vertical-target feasibility**

    **Given** the player occupies representative positions above, below, and level with the grounded melee enemy
    **When** perception, pursuit, attack validation, and diagnostics evaluate the target
    **Then** three-dimensional range, direction, and line-of-sight facts remain coherent and deterministic
    **And** the grounded enemy either submits a valid supported intent or returns a typed inability or out-of-reach reason without invalid movement, aim, or request spam
    **And** this evidence is retained for Epic 3 without adding climbing, flying, navigation meshes, or a complete vertical enemy family in this story.

16. **Expose complete observational diagnostics**

    **Given** development diagnostics are enabled
    **When** the enemy perceives, moves, attacks, hits or misses, takes damage, dies, grapples, or resets
    **Then** diagnostics expose stable actor and target identities, tactical state, selected intent, movement and ability requests and results, execution and phase, committed melee space, hit and damage occurrences, health, reaction, death, grapple validity, and run identity
    **And** diagnostics observe committed owner state without repeating physics queries, deciding behavior, changing simulation, or relying on raw `print()` output.

17. **Verify the complete melee enemy**

    **Given** the permanent melee-enemy suite and focused real-Jolt combat fixture run
    **When** they exercise acquisition and target loss, occlusion, pursuit and stopping, accepted and rejected attack requests, windup tracking and active-direction lock, hit and miss delivery, duplicate hurtboxes, player retaliation during commitment and recovery, nonlethal reaction, lethal damage during every attack phase, moving-target grapple behavior, target removal, reset, representative vertical positions, missing presentation, stale runs, and randomized update or subscriber order
    **Then** perception, AI intent, movement, lifecycle, space, damage, health, grapple, cleanup, and restoration follow their declared ownership and typed contracts
    **And** equivalent timed cases at shipping 60 Hz and diagnostic 120 Hz produce equivalent real-time behavior and outcomes within documented tolerances.

    **Given** Story 2.9 is complete
    **When** the enemy is exercised against the player in the launch scene and focused combat fixture and the migration diff is reviewed
    **Then** one readable melee enemy can pursue, attack, damage, be damaged, die, serve as a moving grapple target, and reset through production contracts, and Story 2.8 compatibility adapters are removed
    **And** retained scene, Resource, behavior-tree, and script references remain valid
    **And** the story has not created additional enemy families, navigation meshes, encounter spawning, rewards, checkpoints, production HUD, final animation or VFX assets, or the Story 2.10 movement-opportunity evaluation.
