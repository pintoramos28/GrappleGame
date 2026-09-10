---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 3
---

# Story 2.3: Capture Movement and Impact Context

As a player,
I want combat to preserve how I committed an attack while separately recording what happened at contact,
So that movement-derived outcomes use explicit evidence instead of stale or ambiguous movement assumptions.

**Acceptance Criteria:**

1. **Capture an immutable source-movement snapshot**

   **Given** a combatant exposes movement facts through its authoritative movement boundary
   **When** a movement context is captured
   **Then** one immutable `MovementCombatContext` records the capture physics step, stable source identity, source world position, locomotion state, world velocity, facing direction, grounded state, valid wall relationship, grapple state, and grapple pull direction
   **And** it contains no mutable engine query, live controller reference, or writable traversal state.

2. **Derive rather than duplicate movement facts**

   **Given** a `MovementCombatContext` has been captured
   **When** combat needs planar speed, vertical speed, travel direction, grapple alignment, or another derivative
   **Then** the value is derived from the authoritative snapshot using documented tolerant calculations
   **And** competing cached versions of the same fact are not stored in attack, damage, or presentation state.

3. **Use an explicit attack capture phase**

   **Given** an `AttackDefinition` participates in movement-context capture
   **When** its context policy is inspected
   **Then** it declares exactly one capture phase from `COMMIT`, `ACTIVE_START`, or `DELIVERY_SPAWN`, with `COMMIT` as the default
   **And** one context is captured at that declared boundary for each applicable execution or delivery occurrence
   **And** the initial player melee attack uses `COMMIT` unless the later feel evaluation produces an approved design change.

4. **Do not infer an undefined approach start**

   **Given** the player may build momentum through running, jumping, falling, grappling, releasing, or wall movement before attacking
   **When** the movement context is captured
   **Then** it describes the player only at the attack's declared capture phase
   **And** it does not attempt to infer when the broader approach began
   **And** any future sustained-approach or movement-history mechanic must define its own trigger, duration, expiry, and interruption rules.

5. **Capture actual source and target motion at impact**

   **Given** an authoritative delivery accepts a hit
   **When** its immutable `ImpactContext` is created
   **Then** it records the impact physics step, execution and delivery occurrence identities, stable target and hurtbox or weak-point identity, hit position and normal, source and target positions where available, source-body world velocity at impact, target world velocity at impact, and body-relative impact velocity
   **And** source-body velocity is sampled from the authoritative movement result for hit resolution rather than copied from `MovementCombatContext`.

6. **Distinguish delivery motion from body motion**

   **Given** a projectile, weapon shape, or other delivery has simulation-authored motion independent of its source body
   **When** impact is accepted
   **Then** `ImpactContext` separately records delivery world velocity and delivery-relative-to-target velocity
   **And** those fields are explicitly marked unavailable when the delivery has no independently meaningful velocity
   **And** an unavailable delivery velocity is not silently represented as zero or replaced with source-body velocity.

7. **Capture target-relative impact facts**

   **Given** source, delivery, target, and hit facts are available
   **When** `ImpactContext` is constructed
   **Then** it derives the bounded relative height, relative position, approach direction, approach alignment, and other approved target-relative facts from those authoritative inputs
   **And** the semantics identify whether alignment uses body motion, delivery motion, or spatial relationship
   **And** exact floating-point equality is not required.

8. **Preserve commit and impact as separate evidence**

   **Given** an attack commits while the player is moving quickly
   **When** the player loses velocity before the attack hits
   **Then** `MovementCombatContext` retains the original commit-time movement
   **And** `ImpactContext` records the lower impact-time body and relative velocities
   **And** constructing or reading the impact context cannot overwrite, reinterpret, or silently replace the committed movement context.

9. **Remain valid without live source ownership**

   **Given** a detached delivery has retained its committed movement, damage, and source attribution snapshots
   **When** its original source node changes or is freed before impact
   **Then** impact processing uses the delivery's captured source facts and current target facts without dereferencing a stale node
   **And** unavailable current source-body fields are explicitly identified
   **And** stable attribution remains available through `CombatSourceRef`.

10. **Keep context factual rather than prescriptive**

    **Given** both contexts are available to combat resolution
    **When** an attack evaluates movement-derived rules
    **Then** the contexts supply facts without automatically granting bonus damage, stagger, critical chance, or acceptance
    **And** commit-based, impact-based, or hybrid policies must be declared separately by the consuming attack rule
    **And** the current M1 proxy remains a successful vertical-angle hit whose commit-time speed exceeds configured walking speed.

11. **Expose side-by-side diagnostics**

    **Given** development combat diagnostics are enabled
    **When** an execution and accepted hit are inspected
    **Then** commit-time locomotion, velocity and derived speed are shown separately from impact-time source-body, target, relative-body, and optional delivery velocities
    **And** the display identifies both capture physics steps and the elapsed time between them
    **And** diagnostics consume the committed contexts without resampling movement or rerunning impact calculations.

12. **Verify delayed-impact and collision-induced slowdown**

    **Given** the permanent context contract suite and focused real-Jolt fixture run
    **When** they exercise capture at each supported phase, grounded and traversal states, moving targets, detached sources, independent delivery motion, invalid inputs, stale step data, and immutable snapshot reads
    **Then** each context contains the facts from its own declared capture moment and remains unchanged afterward.

    **Given** a diagnostic scenario commits an attack above walking speed, remains active for two seconds, loses most or all player-body velocity through collision, and accepts a hit later
    **When** its contexts are inspected
    **Then** the movement context reports the high commit velocity while the impact context reports the reduced source-body and relative velocity
    **And** the two-second duration is supplied by an immutable diagnostic definition rather than by mutating production attack data
    **And** the equivalent 60 Hz and 120 Hz scenarios produce equivalent real-time capture behavior within documented tolerances.

    **Given** Story 2.3 is complete
    **When** its scope and working-tree diff are reviewed
    **Then** the movement boundary, context factories, damage pipeline, launch scene, and Epic 1 route remain runnable
    **And** the story has not selected a final commit-versus-impact reward policy, migrated the playable melee attack, implemented attack geometry or telegraphs, altered damage balance, created approach-history tracking, or introduced encounter lifecycle infrastructure.
