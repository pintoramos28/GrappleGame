---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.10'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 10
---

# Story 2.10: Prove the Movement-Combat Contract

As a player,
I want a focused combat route that demonstrates the advantage and risk of attacking from traversal,
So that I can judge whether movement and combat form one coherent experience.

**Acceptance Criteria:**

1. **Create a focused M1 validation route**

   **Given** Epic 2 requires integrated movement-combat evidence
   **When** the validation fixture is authored
   **Then** it provides one repeatable vertical approach, one production melee enemy, sufficient space for its telegraph and retaliation, a safe recovery area, and a fast restart
   **And** it uses the production traversal, attack, damage, health, enemy, grapple, and reset contracts
   **And** it may be created from scratch because the current tutorial level is not a preservation requirement.

2. **Define the movement-derived opportunity operationally**

   **Given** the player attacks the enemy from the fixture's authored vertical approach
   **When** the attack commits while the player's authoritative speed is greater than the configured walking speed and subsequently delivers an accepted hit
   **Then** the attempt satisfies the M1 movement-derived opportunity proxy
   **And** the authored route and recorded target-relative facts establish the vertical nature of the approach without introducing a universal numerical angle threshold
   **And** no bonus damage, stagger, poise pressure, knockback, or other numerical reward is required to satisfy this criterion.

3. **Use authoritative evidence for qualification**

   **Given** an attempt is evaluated
   **When** its qualification facts are collected
   **Then** commit-time position, locomotion state, velocity, and speed come from the immutable `MovementCombatContext`
   **And** the threshold comes from the authoritative player walking-speed definition rather than a fixture-local duplicate
   **And** the accepted delivery, target-relative relationship, and impact-time motion come from the committed execution, damage result, and `ImpactContext`
   **And** presentation, rendered frames, or manually estimated speed cannot qualify an attempt.

4. **Require the production attack for the completion gate**

   **Given** the player attempts the M1 completion route
   **When** success is evaluated
   **Then** the accepted hit uses the production player melee definition and its normal 0.18-second active window
   **And** the two-second diagnostic attack cannot be used to claim completion
   **And** a miss, rejected hit, speed at or below walking speed, or attack outside the authored vertical approach does not satisfy the gate.

5. **Compare traversal and stationary attacks**

   **Given** the fixture supports both a stationary control attempt and the authored traversal approach
   **When** both are exercised against the same enemy and production attack
   **Then** the stationary attack may still damage the enemy under ordinary combat rules but does not satisfy the movement-qualified opportunity
   **And** the traversal attempt demonstrates an approach or strike opportunity produced by entering combat from elevation with greater-than-walking speed
   **And** the comparison is recorded without changing damage values between the two attempts.

6. **Demonstrate meaningful attack commitment**

   **Given** the enemy is able to perceive, pursue, and attack the player
   **When** the player commits from traversal at a poor time or follows a readable but unsafe trajectory
   **Then** the enemy can punish the player through its ordinary telegraphed attack and damage contracts
   **And** the player attack cannot be restarted, silently redirected after its lock boundary, or cancelled through ordinary repeated attack input
   **And** a better-timed approach allows the player to land the attack and use the enemy's recovery opening.

7. **Make success and failure understandable**

   **Given** the player lands an attack, misses, or receives damage during the route
   **When** the attempt is reviewed using fallback presentation and development diagnostics
   **Then** the player can identify the relevant attack phase, affected space, accepted or rejected hit, health change, and source attribution
   **And** enemy warning space agrees with its damaging space
   **And** missing final animation, VFX, audio, or HUD assets do not prevent the combat result from being understood.

8. **Run the two-second active-window feel comparison**

   **Given** the separate immutable two-second diagnostic melee definition is selected
   **When** the player commits above walking speed, collides with an obstacle or enemy body, loses most or all velocity, and lands a delayed hit
   **Then** `MovementCombatContext` retains the higher commit-time velocity while `ImpactContext` reports the lower impact-time source-body and relative velocities
   **And** the target is damaged no more than once under the attack's per-execution hit policy
   **And** the production definition remains unchanged.

   **Given** both the production and two-second variants have been exercised
   **When** their feel is reviewed
   **Then** observations record how the longer active window affects forgiveness, apparent reach, commitment, delayed contact, and agreement between motion and impact
   **And** any proposed production timing or commit-versus-impact policy change becomes separately approved follow-up work rather than an implicit change in this story.

9. **Prove death and restart within the route**

   **Given** either combatant has pursued, attacked, grappled, taken damage, or died
   **When** the fixture restarts
   **Then** player and enemy transform, velocity, health, alive state, perception, target memory, attack readiness, grapple state, collision state, and transient presentation return to their authored values
   **And** stale executions, deliveries, damage occurrences, target references, and run-scoped facts cannot affect the new attempt
   **And** both combatants can fight normally again.

10. **Verify rate-independent integrated behavior**

    **Given** the automated M1 scenarios run at shipping 60 Hz and diagnostic 120 Hz physics rates
    **When** they exercise the successful vertical attack, stationary control, mistimed commitment, enemy retaliation, collision-induced slowdown, death, and restart
    **Then** real-time lifecycle timing, movement qualification, hit counts, damage, death, and restoration remain equivalent within documented tolerances
    **And** no result depends on render rate, animation timing, callback order, or duplicated physics queries.

11. **Retain reviewable completion evidence**

    **Given** the focused automated suite and short manual playtest have completed
    **When** their results are saved
    **Then** the evidence identifies the fixture and definition versions, walking-speed threshold, commit and impact contexts, accepted and rejected results, production-versus-two-second observations, commitment-risk observation, reset outcome, and 60/120 Hz comparison
    **And** a failed completion condition is recorded as follow-up work rather than being hidden by tuning the fixture during the evidence run.

12. **Complete Epic 2 without expanding its scope**

    **Given** Stories 2.1 through 2.10 are complete
    **When** the Epic 2 completion gate is reviewed
    **Then** the player can successfully attack the enemy from the authored vertical approach while moving faster than walking speed
    **And** attacking creates understandable exposure, damage causes are readable, the enemy can be defeated, and restart restores a valid combat state
    **And** the project and Epic 1 traversal route remain runnable with valid retained references
    **And** Epic 2 has not introduced additional attacks, enemy families, M2 pressure mechanics, encounter ownership, production HUD, final animation/VFX assets, persistent progression, or unapproved combat bonuses.
