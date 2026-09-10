---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 6
---

# Story 2.6: Deliver One Simulation-Owned Player Melee Attack

As a player,
I want one responsive melee attack that works throughout my supported traversal states,
So that I can deliberately commit to combat without losing the movement system I have learned.

**Acceptance Criteria:**

1. **Compose one authoritative player attack definition**

   **Given** the initial player melee attack is authored
   **When** its `AttackDefinition` is inspected
   **Then** it references the approved lifecycle, melee-space, damage, coordination, motor, movement-context capture, hit-policy, source-death, and presentation definitions
   **And** the player controller, scene nodes, state scripts, and presenters contain no competing copies of those values
   **And** all occurrence-specific state remains owned by the current execution.

2. **Preserve the current attack cadence during migration**

   **Given** the playable prototype currently uses a 0.08-second windup, 0.18-second active window, and a 0.45-second start-to-next-start cadence
   **When** those values migrate into the production lifecycle definition
   **Then** the effective recovery duration preserves the existing cadence without maintaining a second total-cooldown scalar
   **And** the migration does not silently retune damage, reach, steering, or attack frequency
   **And** future tuning changes require editing the typed definition rather than the player scene or controller.

3. **Declare the initial traversal policy explicitly**

   **Given** the existing player attack operates independently of ordinary locomotion
   **When** its initial coordination policy is authored
   **Then** grounded, airborne, grappling, wall-running, and wall-sticking states remain eligible while the player is alive
   **And** an active grapple may continue concurrently
   **And** ordinary traversal continues under the existing baseline movement policy with no attack-authored velocity replacement or root motion
   **And** later playtest-driven restrictions require an explicit policy change.

4. **Start from one committed command edge**

   **Given** the player is alive, the attack is ready, and the current `PlayerCommandFrame` contains an unconsumed attack press
   **When** `PlayerAbilityCoordinator` accepts the request
   **Then** one player-owned `AbilityExecution` begins with a stable execution ID
   **And** `MovementCombatContext` is captured once at `COMMIT` from the authoritative movement boundary
   **And** lifecycle, cooldown, spatial binding, and presentation start only after the atomic coordination plan commits.

5. **Drive attack phases from simulation**

   **Given** the melee execution is active
   **When** fixed-step simulation advances
   **Then** windup, active, recovery, and completion are controlled exclusively by `AbilityExecution` using physics seconds and bounded carry-over
   **And** the player attack HSM reflects or organizes the committed lifecycle state without running competing phase countdowns
   **And** animation, visual effects, audio, and rendered frames cannot enable hits or complete the attack.

6. **Bind the attack to authoritative player-facing space**

   **Given** the melee execution has committed
   **When** its spatial binding produces windup and active snapshots
   **Then** it uses the approved source-relative melee definition and authoritative player facing according to its source-following policy
   **And** primitive warning and attack presentation consume the same snapshots as the active melee query
   **And** turning, moving, grappling, or contacting geometry cannot cause visual and damaging shapes to diverge.

7. **Commit one source-side delivery snapshot**

   **Given** the execution reaches active start
   **When** its melee delivery is created
   **Then** it creates one immutable `DamageSnapshot` from the attack's `DamageDefinition`, current source-side stats and modifiers, stable `CombatSourceRef`, execution identity, and committed movement context
   **And** every target permitted by that single melee delivery receives the appropriate immutable source-side values
   **And** current attacker state is not recalculated separately for each later impact.

8. **Accept authoritative melee impacts**

   **Given** a valid hostile hurtbox enters the active melee space
   **When** the swept `MeleeHitQuery` accepts it
   **Then** it creates one delivery occurrence and one `ImpactContext` using the current hit and impact-time motion facts
   **And** the committed damage snapshot resolves through the typed damage boundary
   **And** the compatible receiver obtains the accepted or rejected result through its existing application seam
   **And** full health acceptance, reactions, death, and restoration remain assigned to Story 2.7.

9. **Hit each target only as authored**

   **Given** the production melee attack declares one hit per target per execution
   **When** a target remains within, leaves, or re-enters the active space
   **Then** it cannot receive another delivery occurrence from that execution
   **And** multiple hurtboxes for one combatant are normalized according to the approved stable policy
   **And** a later attack execution may hit the target again.

10. **Make attack commitment observable**

    **Given** the player has committed the melee attack
    **When** they press attack again during windup, active, or recovery
    **Then** the new request is rejected with the applicable busy or cooldown reason
    **And** the current attack continues instead of restarting or extending its window
    **And** ordinary attack input cannot cancel the committed execution
    **And** the resulting cadence and need to enter melee space create a testable temporal commitment without inventing an unapproved movement penalty.

11. **Preserve grapple and locomotion ownership**

    **Given** the player starts the attack while grappling or enters another allowed locomotion state during it
    **When** both systems advance
    **Then** grapple pull, maximum-distance constraint, wall interaction, jumping, gravity, and steering continue through their existing owners and semantic motor phases
    **And** the attack contributes only its declared motor policy
    **And** neither state machine directly transitions or mutates the other.

12. **Cancel and clean up exactly once**

    **Given** death, an accepted coordinator interruption, invalid required data, scene removal, or reset cancellation ends the execution
    **When** termination commits
    **Then** hit delivery, spatial binding, attack motor submissions, and presentation are disabled exactly once
    **And** the execution emits one typed terminal result
    **And** no stale hit eligibility, cooldown side effect, visual, context, or damage occurrence survives termination.

13. **Provide replaceable attack feedback**

    **Given** the player attack changes phase, is rejected, lands a hit, or is cancelled
    **When** presentation observes the committed result
    **Then** the primitive arc, player pose or animation adapter, and optional audio/VFX request communicate the relevant state without controlling it
    **And** missing bespoke assets use the documented fallback or remain absent without preventing a valid attack
    **And** feedback consumes committed spatial, lifecycle, and hit facts rather than repeating gameplay work.

14. **Provide the two-second feel-test variant**

    **Given** a development-only melee `AttackDefinition` variant is selected in the focused combat fixture
    **When** the player attacks with it
    **Then** it uses a 2.0-second active window while reusing the production attack's damage, spatial, hit, context, coordination, and presentation contracts
    **And** it is a separate immutable Resource rather than a runtime mutation of the production definition
    **And** the fixture permits a high-speed commit followed by player-body collision and a later accepted impact.

    **Given** that collision substantially reduces player velocity before the delayed hit
    **When** diagnostics are inspected
    **Then** `MovementCombatContext` shows the higher commit velocity and `ImpactContext` shows the lower source-body and relative impact velocities
    **And** the same target is still hit no more than once during the extended window
    **And** the observation is retained for the Story 2.10 commit-based versus impact-based feel evaluation.

15. **Verify the playable player melee**

    **Given** the permanent player-melee suite and focused real-Jolt fixtures run
    **When** they exercise every initially allowed locomotion state, grapple concurrency, normal phase timing, repeated attack input, multiple and duplicate hurtboxes, high-speed swept hits, misses, typed damage rejection, death cancellation, missing presentation, invalid definitions, and the two-second slowdown scenario
    **Then** each execution follows the authored lifecycle, movement, space, context, delivery, hit-count, and cleanup rules
    **And** equivalent cases at shipping 60 Hz and diagnostic 120 Hz produce equivalent real-time attack timing and outcomes within documented tolerances.

    **Given** Story 2.6 is complete
    **When** the player attack is exercised in the launch scene and Epic 1 traversal route and the migration diff is reviewed
    **Then** one melee attack is playable through the production contracts, prior attack compatibility adapters and competing scalar authorities are removed, and retained references remain valid
    **And** the story has not finalized health reactions or reset, built enemy behavior, added additional attacks or combos, selected a numeric movement bonus, changed the approved commit-time M1 proxy, or introduced final art and animation.
