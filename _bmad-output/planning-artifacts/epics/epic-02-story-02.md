---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 2
---

# Story 2.2: Resolve Immutable and Attributed Damage

As a player,
I want every hit to carry a stable record of its source and damage values,
So that damage remains predictable and correctly attributed even if the attacker changes or disappears before resolution.

**Acceptance Criteria:**

1. **Separate attack behavior from damage data**

   **Given** combat data is authored
   **When** its responsibilities are inspected
   **Then** `DamageDefinition` contains damage amounts, damage types, attack-power scaling, poise pressure, critical modifiers, armor penetration, minimum damage, and damage tags
   **And** lifecycle timing, targeting, spatial rules, delivery behavior, movement policy, and cancellation rules do not belong to `DamageDefinition`
   **And** current and future `AttackDefinition` instances reference damage data rather than duplicating it.

2. **Separate immutable stats from runtime state**

   **Given** a combatant has authored combat statistics
   **When** its data is composed
   **Then** shared `CombatStatsDefinition` Resources contain immutable base offense, defense, critical, resistance, and multiplier values
   **And** occurrence-specific modifiers and temporary combat state remain owned by runtime components
   **And** one combatant cannot alter another combatant by mutating a shared Resource.

3. **Migrate current combat Resources safely**

   **Given** the prototype currently uses `AttackData`, `CombatStatsData`, and their referenced `.tres` assets
   **When** those types migrate to `DamageDefinition` and `CombatStatsDefinition`
   **Then** existing Godot UIDs and applicable Resource and scene references are retained or deliberately updated before obsolete paths are removed
   **And** serialized values preserve the current observable damage calculation within documented numerical tolerance
   **And** old and new types do not remain as competing runtime authorities.

4. **Capture stable source attribution**

   **Given** a combatant prepares a delivery occurrence
   **When** a `CombatSourceRef` is created
   **Then** it records stable source identity, team or affiliation, ability execution identity, optional encounter scope and run identity, and an optional weak source reference
   **And** combat attribution does not depend on retaining the source node or inferring ownership from scene-tree parentage.

5. **Create an immutable source-side snapshot**

   **Given** a valid `DamageDefinition`, source reference, current source stats, source-side runtime modifiers, and an injected critical-decision source
   **When** a delivery occurrence is committed
   **Then** one immutable `DamageSnapshot` captures the resolved source-side damage values, outgoing multipliers, critical result, poise pressure, tags, definition identity, source attribution, execution identity, and optional run identity
   **And** later changes to the source's stats, modifiers, team, or node lifetime cannot rewrite that snapshot.

6. **Resolve current target-side facts at impact**

   **Given** a valid `DamageSnapshot` reaches a target
   **When** damage resolution occurs
   **Then** the resolver evaluates the target's current defense, resistance, vulnerability, incoming modifiers, team policy, and other currently supported target-side rules
   **And** source-side offense is not recalculated from the live attacker
   **And** the documented ordering of scaling, critical result, outgoing modifiers, armor penetration, defense, resistance, incoming modifiers, and minimum-damage handling is deterministic.

7. **Keep resolution inputs immutable**

   **Given** damage is being resolved
   **When** source-side and target-side rules are applied
   **Then** neither `DamageDefinition`, `CombatStatsDefinition`, nor the committed `DamageSnapshot` is mutated
   **And** the resolver builds a new committed `DamageInstance` or typed rejection result
   **And** runtime modifiers contribute only through their declared source-side or target-side stage.

8. **Return typed accepted and rejected outcomes**

   **Given** a damage request is valid and permitted by target and team policy
   **When** it resolves
   **Then** the result reports an accepted `DamageInstance` containing final per-type and total damage, critical state, poise pressure, tags, definition identity, source attribution, execution identity, and run identity.

   **Given** the snapshot is malformed, the target is invalid, team policy rejects the hit, the supplied run is stale, or another declared target rule rejects damage
   **When** resolution is attempted
   **Then** it returns a stable typed rejection reason without partially applying damage
   **And** expected gameplay rejection is not logged as an engine error.

9. **Preserve detached delivery attribution**

   **Given** a `DamageSnapshot` has been committed
   **When** the source node is freed or its current stats change before target-side resolution
   **Then** the snapshot resolves using its captured source-side values and stable attribution
   **And** no stale node is dereferenced
   **And** an injected scope validator may reject a stale run without requiring the full Epic 7 encounter controller.

10. **Move current hit delivery across the snapshot boundary**

    **Given** the current prototype hitbox and hurtbox path must remain runnable during staged migration
    **When** it is updated to the new damage boundary
    **Then** a hit delivery supplies a committed `DamageSnapshot` and receives a typed resolution result rather than passing mutable `AttackData` and a live source node into the target
    **And** any temporary activation adapter uses explicit occurrence and source identities
    **And** ability lifecycle integration, authoritative attack space, per-execution hit deduplication, and final player/enemy attack migration remain assigned to later Epic 2 stories.

11. **Expose bounded damage diagnostics**

    **Given** development diagnostics inspect a damage occurrence
    **When** its snapshot or result is requested
    **Then** they expose stable definition, source, execution, scope, team, critical, source-side, target-side, rejection, and final-damage facts
    **And** sensitive node internals are not retained or traversed
    **And** diagnostics neither rerun the resolver nor alter its result.

12. **Verify calculation, attribution, and immutability**

    **Given** the permanent automated damage suite runs
    **When** it exercises base damage, attack-power scaling, critical and non-critical outcomes, outgoing and incoming multipliers, defense, armor penetration, resistance, minimum damage, multiple damage types, team rejection, malformed input, stale scope, source removal, post-snapshot source changes, pre-impact target changes, and duplicate reads
    **Then** results follow the documented calculation order and retain correct attribution
    **And** an injected deterministic critical source makes tests repeatable
    **And** definitions and committed snapshots remain unchanged
    **And** running the rate-independent cases under both 60 Hz and 120 Hz configurations produces the same damage results.

    **Given** Story 2.2 is complete
    **When** the launch scene, Epic 1 route, current combat smoke behavior, Resource references, UIDs, and working-tree diff are reviewed
    **Then** the project remains runnable through the new snapshot boundary
    **And** the story has not implemented health depletion, hit reactions, death, restoration, movement or impact contexts, authoritative attack geometry, final attack lifecycle integration, encounter ownership, or combat balance changes.
