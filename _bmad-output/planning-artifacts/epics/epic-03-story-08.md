---
artifact_schema: 1
artifact_id: 'grapplegame.story.3.8'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 3
story: 8
---

# Story 3.8: Identify and Disperse a Deterministic Decoy

As a player,
I want an enemy decoy to be targetable enough to mislead me while retaining a consistent visual tell,
So that I can defeat deception through observation and deliberate targeting rather than luck.

**Acceptance Criteria:**

1. **Declare the deception gameplay question**

   **Given** the decoy prototype is registered with the M2 pressure lab
   **When** its `M2PrototypeScenarioDefinition` is inspected
   **Then** its question is whether the player distinguishes the source from a plausible false target before attacking or grappling
   **And** its tell, placement, targetability, damage response, grapple response, counter, recovery, lifetime, source-death policy, reset behavior, manual procedure, and required evidence are explicit
   **And** the decoy itself does not create damage or movement pressure.

2. **Author one immutable decoy definition**

   **Given** the representative decoy profile is inspected
   **When** its authored values are resolved
   **Then** it declares a 0.6-second spawn windup, a 5.0-second active lifetime, a final 1.0-second expiry warning, a 4.0-metre primary lateral placement offset, an ordered opposite-side fallback, one accepted offensive hit to disperse, and a maximum of one previewing or active decoy per source
   **And** it declares target, damage, grapple, body-collision, AI-targeting, source-death, replacement, and cleanup policies
   **And** these remain configurable prototype values rather than hard-coded balance rules.

3. **Request the decoy through the normal ability lifecycle**

   **Given** a valid source requests its decoy ability
   **When** its action owner validates the request
   **Then** it checks definition, source state, ability state, cooldown, current run, active-decoy limit, placement inputs, and required resident assets before committing one execution
   **And** enemy AI or a fixture trigger may request the action but cannot spawn the decoy, enable targetability, or advance lifecycle timing
   **And** rejected, busy, duplicate, stale, and malformed requests return typed reasons without producing a partial decoy.

4. **Select placement deterministically**

   **Given** the ability reaches its placement-lock boundary
   **When** the baseline candidate offsets are evaluated
   **Then** it first evaluates the source-local 4.0-metre primary lateral offset and then the authored opposite-side fallback
   **And** each candidate must resolve onto valid static support, remain inside the fixture's effect bounds, and avoid protected player, source, geometry, exit, and recovery volumes
   **And** the first valid candidate in authored order becomes one frozen world transform
   **And** no valid candidate causes reason-coded cancellation rather than random placement.

5. **Preview without becoming a target**

   **Given** a valid placement has been frozen
   **When** the execution advances through its 0.6-second windup
   **Then** a primitive non-colliding preview communicates the future decoy position using normalized simulation-owned progress
   **And** the preview is ineligible for grapple, damage, projectile, melee, enemy-targeting, objective, and reward queries
   **And** presentation timing cannot make the decoy targetable before the authoritative active boundary.

6. **Spawn one run-scoped target candidate**

   **Given** windup completes with a still-valid source, placement, and run
   **When** the execution enters its active phase
   **Then** exactly one configured decoy candidate is attached to the current encounter runtime scope with a stable occurrence and target identity
   **And** its definition, source, execution, placement, lifetime, and run attribution are established before targetability is published
   **And** arbitrary scene insertion, unscoped creation, and presentation-owned spawning are prohibited.

7. **Give the decoy a persistent non-colour-only tell**

   **Given** the decoy is active
   **When** the player observes it from an intended fixture route
   **Then** it presents the source's approximate primitive silhouette while displaying two thin horizontal rings that continuously pulse around its base once per second
   **And** the real source never displays that double-ring cue
   **And** the tell remains distinguishable through shape and motion without depending solely on hue, text, final animation, or audio
   **And** the tell remains present for the complete active lifetime rather than appearing only during spawn.

8. **Declare an explicit query-eligibility matrix**

   **Given** the active decoy's targetability policy is inspected
   **When** each authoritative query family evaluates it
   **Then** it is eligible for the player's grapple-candidate and offensive-hit queries
   **And** it is ineligible as grounding, wall support, ordinary body collision, line-of-sight cover, grapple occlusion, interaction content, enemy-AI target, encounter participant, objective subject, or reward source
   **And** broad collision layers and named query profiles express physical eligibility while the typed target policy expresses gameplay meaning
   **And** no code identifies the decoy through groups, display names, scene paths, or ad hoc metadata.

9. **Resolve target selection deterministically**

   **Given** a player grapple or offensive query can reach the source, the decoy, or both
   **When** authoritative candidates are resolved
   **Then** candidates are filtered through their typed eligibility and ordered by the query's existing distance, intersection, and stable-identity rules
   **And** the decoy receives no hidden preference or penalty solely because it is false
   **And** equivalent geometry produces the same selected candidate regardless of node insertion, signal order, frame rate, or presenter state
   **And** the player-facing reticle consumes that authoritative result rather than running a competing query.

10. **Provide a deliberate grapple response**

    **Given** the active decoy is the authoritative grapple candidate
    **When** the player commits grapple acquisition
    **Then** its explicit `Grappleable3D` response accepts one stationary world-space attachment seed tied to the decoy's lifetime
    **And** ordinary player grapple acceleration, release, and maximum-length behavior remain owned by the existing grapple and motor systems
    **And** the decoy does not become body collision, move the player directly, or acquire its own movement authority
    **And** grappling it does not automatically reveal or disperse it.

11. **Disperse after one accepted player attack**

    **Given** the active decoy receives an eligible player offensive impact
    **When** the first unique delivery occurrence is accepted
    **Then** it commits one typed `DISPERSED_BY_HIT` response and enters its terminal path
    **And** it does not apply ordinary health damage, armor, poise, death, loot, coin, reward, objective, or enemy-kill behavior
    **And** the attack's own hit policy determines whether another separately intersected target may also be affected
    **And** duplicate hurtboxes, callbacks, or delivery retries cannot disperse it more than once.

12. **Keep the real source independent**

    **Given** the decoy is attacked, grappled, dispersed, or allowed to expire
    **When** that interaction commits
    **Then** no damage, status, movement influence, stagger, cooldown change, or private state mutation is applied to the source
    **And** attacking the real source continues through its ordinary combat contracts
    **And** the source and decoy retain distinct stable target identities even when their visible primitive silhouettes are similar.

13. **Prevent the decoy from creating outgoing pressure**

    **Given** the decoy is active
    **When** enemy actions and combat deliveries are evaluated
    **Then** it cannot request or execute attacks, deal contact damage, create telegraphs, steer AI, block movement, or emit authoritative source-side combat snapshots
    **And** any apparent pose or motion remains observational presentation
    **And** this story does not clone the source's AI, behavior tree, health, navigation, or ability state.

14. **Enforce the one-decoy policy**

    **Given** a source already owns a previewing or active baseline decoy
    **When** it requests another decoy
    **Then** the later request is rejected without refreshing, relocating, or replacing the current occurrence
    **And** duplicate requests carrying the same execution identity return the existing result or a typed duplicate rejection
    **And** a new execution may create another decoy only after the previous occurrence has terminated.

15. **Warn and expire on authoritative time**

    **Given** the decoy reaches the final 1.0 second of its 5.0-second lifetime
    **When** simulation-owned remaining time crosses the warning boundary
    **Then** primitive presentation clearly communicates imminent expiry without changing targetability early
    **And** at lifetime completion offensive and grapple eligibility are invalidated together exactly once
    **And** cosmetic disappearance cannot extend the target's gameplay lifetime.

16. **Invalidate an attached grapple safely**

    **Given** the player is attached to the decoy when it is dispersed, expires, loses its source, or is reset
    **When** the target's terminal state commits
    **Then** the grapple owner receives one typed target-invalidation result
    **And** the grapple terminates without snapping, teleporting, or zeroing the player's resolved velocity
    **And** the player can continue through ordinary air, wall, landing, or subsequent grapple recovery.

17. **Clean up on source loss and reset**

    **Given** the source dies or is removed during windup
    **When** the execution receives source invalidation
    **Then** the preview cancels and no target candidate becomes active.

    **Given** the source dies or is removed while its decoy is active
    **When** the approved `CANCEL_WITH_SOURCE` policy resolves
    **Then** the decoy terminates through the same invalidation path as ordinary expiry.

    **Given** the encounter resets, checkpoint reloads, or the scene exits
    **When** the old run is invalidated
    **Then** every preview, candidate, grapple response, timer, presenter, callback, and source reference from that run is removed or rejected exactly once.

18. **Keep authored tuning flexible**

    **Given** an alternate valid definition changes windup, lifetime, warning time, placement offsets, hit count, tell presentation, or active-limit policy
    **When** the same lifecycle and targetability implementation consumes it
    **Then** placement, preview, eligibility, interaction, expiry, and diagnostics use the authored values without code changes
    **And** at least one alternate-profile test proves that timing and placement are not hard-coded
    **And** moving echoes, cloned attacks, multiple simultaneous decoys, copied animation, invisibility, and source-state mirroring remain future extensions rather than implied configuration.

19. **Provide replaceable feedback and diagnostics**

    **Given** final animation, audio, and VFX are unavailable
    **When** the ability previews, spawns, becomes targetable, is selected, is attacked, is grappled, warns, disperses, expires, or resets
    **Then** primitive silhouette geometry, the persistent double-ring tell, state changes, target markers, and bounded cues make the outcome observable
    **And** future meshes, animation, material effects, audio, and VFX can observe committed facts without changing targetability or timing
    **And** diagnostics expose definition, occurrence, source, execution, target, and run identities; candidate placement results; lifecycle phase and remaining time; eligibility matrix; query candidates and selection order; current grapple attachment; accepted hit; and terminal reason.

20. **Make deception manually reproducible**

    **Given** the named decoy fixture is launched through the Story 3.1 pressure lab
    **When** another developer follows its documented procedure
    **Then** they can observe the spawn tell, correctly attack the real source, intentionally attack and disperse the decoy, intentionally grapple both candidates, and verify that the decoy does not block movement or provide ground and wall support
    **And** they can line up source and decoy to exercise deterministic selection, allow natural expiry, remain grappled during expiry, exceed the active limit, kill the source during preview and active phases, reset each phase, and repeat the scenario
    **And** the evidence distinguishes objective selection, eligibility, interaction, invalidation, and cleanup results from subjective observations about whether the tell is too obvious or too subtle.

21. **Verify the family representative**

    **Given** the permanent decoy suite and focused real-Jolt fixture run
    **When** they exercise valid and rejected placements, query eligibility, source-and-decoy overlap, equal-distance candidates, randomized node insertion, attack deduplication, grapple attachment and invalidation, active-limit rejection, lifetime expiry, source loss, stale runs, scene exit, and repeated reset
    **Then** target selection remains deterministic, target and damage responses match the declared policy, and no stale decoy candidate survives cleanup
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz preserve lifecycle duration, selection outcome, accepted-hit count, and invalidation result
    **And** this establishes one bounded Targetability and Deception representative without implementing production clone AI, copied attacks, movement imitation, multiple-decoy pressure, final presentation, or the full six-family gate.
