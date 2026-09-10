---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.7'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 7
---

# Story 2.7: Complete Health, Reactions, Death, and Combat Reset

As a player,
I want damage, reactions, death, and restoration to resolve consistently,
So that I understand what happened and can return to a valid combat state after restarting.

**Acceptance Criteria:**

1. **Separate immutable health data from runtime state**

   **Given** a combatant is authored with health
   **When** its health composition is inspected
   **Then** an immutable typed definition supplies maximum and initial health plus the currently supported acceptance and reaction policies
   **And** `CombatHealth` owns only that combatant's current health, alive or dead state, runtime invulnerability, accepted-occurrence history, and reset identity
   **And** runtime changes never mutate the shared definition or another combatant.

2. **Initialize through a typed combatant context**

   **Given** a combatant enters a combat fixture or receives a fresh activation context
   **When** `CombatHealth` initializes
   **Then** it validates its definition, stable entity identity, team, optional scope and run identity, and required receiver dependencies
   **And** it commits the authored initial health and alive state exactly once
   **And** invalid required data prevents unsafe activation through a typed development-visible failure.

3. **Apply only resolved damage**

   **Given** a damage delivery reaches a combatant
   **When** the receiver evaluates it
   **Then** it accepts only a committed `DamageInstance` produced by the approved snapshot and target-side resolver
   **And** it validates target identity, occurrence identity, current run, alive state, invulnerability, and receiver policy before changing health
   **And** it does not recalculate offense, defense, critical results, impact context, or attribution.

4. **Return a typed application result**

   **Given** a valid positive damage instance is accepted
   **When** health application commits
   **Then** one `DamageApplicationResult` records previous health, applied damage, resulting health, lethal state, stable source and execution attribution, impact identity, and reset/run identity
   **And** current health is clamped within its valid range.

   **Given** damage is rejected because it is duplicate, stale, invulnerable, dead, malformed, incorrectly targeted, or otherwise disallowed
   **When** application is attempted
   **Then** a stable rejection reason is returned
   **And** health, reaction state, death state, and presentation remain unchanged
   **And** expected rejection is not logged as an engine error.

5. **Apply each delivery occurrence at most once**

   **Given** the same accepted delivery occurrence reaches a combatant through repeated calls, duplicate hurtboxes, overlapping callbacks, or replayed events
   **When** health application is requested more than once
   **Then** only the first accepted request can change health
   **And** later requests return the existing result or a typed duplicate rejection
   **And** reaction, interruption, death, and presentation side effects are not repeated.

6. **Commit health before notifying consumers**

   **Given** damage changes current health
   **When** the component notifies reactions, ability coordination, diagnostics, or presentation
   **Then** previous health, current health, lethal state, and attribution are fully committed before notification
   **And** subscribers cannot veto the application or depend on connection order
   **And** reentrant damage or reset requests are rejected or deferred to the owner's next declared evaluation point.

7. **Produce one basic nonlethal hit reaction**

   **Given** accepted nonlethal damage permits the initial reaction policy
   **When** the application result commits
   **Then** one typed hit-reaction occurrence is produced from the committed damage and impact facts
   **And** a primitive flash, pose, or other fallback presents the reaction
   **And** the reaction does not alter health or rerun damage
   **And** it does not apply stagger, knockback, velocity replacement, or attack cancellation unless a later typed policy explicitly requests those mechanics.

8. **Commit death exactly once**

   **Given** accepted damage reduces current health to zero
   **When** the lethal application commits
   **Then** `CombatHealth` enters its dead state exactly once and emits one typed death fact containing the killing damage, stable source attribution, execution identity, and run identity
   **And** subsequent damage is rejected as targeting a dead combatant
   **And** duplicate lethal and death requests cannot repeat rewards, interruption, cleanup, or presentation.

9. **Coordinate player death through public owners**

   **Given** the player's typed death fact commits
   **When** the player coordination boundary processes it
   **Then** new ability requests stop, attack and grapple terminate exactly once, their motor submissions clear, and the movement HSM enters its dead state through the approved terminal command
   **And** health does not directly traverse HSM children, move the player, cancel hitboxes, or change ability phases
   **And** no player attack, grapple, wall action, or movement input becomes active later in that physics step.

10. **Restore through an injectable reset contract**

    **Given** a fixture or future encounter owner requests combatant restoration
    **When** it supplies a typed reset context with a new reset occurrence and active run identity
    **Then** the combatant's public reset boundary coordinates ability cancellation, grapple cleanup, transient motor cleanup, health restoration, dead-state clearing, authored fixture transform restoration, and valid locomotion reactivation in a documented order
    **And** each internal owner resets only its own state
    **And** the old run is invalid before the restored combatant can accept new actions or damage.

11. **Make reset idempotent and reject stale work**

    **Given** the same reset is requested repeatedly or late damage from the previous run arrives during restoration
    **When** reset and damage validation occur
    **Then** restoration side effects happen once for that reset occurrence
    **And** stale damage, callbacks, lifecycle transitions, and presentation requests are rejected by their old run identity
    **And** a later distinct reset can restore the combatant again.

12. **Prove restoration without building the encounter system**

    **Given** the focused combat fixture owns one player and a recording damage target
    **When** the player takes nonlethal damage, takes lethal damage, and invokes fixture restart
    **Then** health, alive state, player transform, velocity, movement state, attack readiness, grapple state, cooldown state, and input readiness return to their authored fixture values
    **And** the player can move and attack again without stale damage or duplicate connections
    **And** the fixture injects reset and run identities without implementing Epic 7's `EncounterController`, replaceable runtime root, checkpoint, objective, reward, or level-restart flow.

13. **Provide observational feedback and diagnostics**

    **Given** damage, reaction, death, rejection, or reset commits
    **When** presentation and development diagnostics observe it
    **Then** primitive feedback communicates the applicable current-scope result without controlling simulation
    **And** diagnostics expose health before and after, applied or rejected damage, source and execution attribution, reaction, lethal state, reset occurrence, and run identity
    **And** raw `print()` calls, duplicate damage calculations, and retained source-node traversal are not used as the combat contract
    **And** the production HUD remains deferred to Epic 7.

14. **Verify health and reset behavior**

    **Given** the permanent health suite and focused combat fixture run
    **When** they exercise nonlethal, exact-lethal, overkill, duplicate, invulnerable, dead-target, malformed, wrong-target, stale-run, and source-freed damage; reentrant notification; basic reaction; death during attack and grapple; reset while alive and dead; repeated reset; and damage arriving during reset
    **Then** health, reaction, death, attribution, cancellation, and restoration each commit exactly as declared
    **And** shared definitions and committed damage records remain immutable
    **And** equivalent timed cases at shipping 60 Hz and diagnostic 120 Hz produce equivalent outcomes within documented tolerances.

    **Given** Story 2.7 is complete
    **When** the player damage, death, restart, attack, launch-scene, Epic 1 route, retained-reference, and working-tree checks are performed
    **Then** the player and generic combat targets use one reliable health and reset boundary and return to valid operation after fixture restart
    **And** the story has not completed the melee enemy, introduced production encounter ownership, implemented rewards or checkpoints, added stagger or knockback, designed the production HUD, or changed combat balance.
