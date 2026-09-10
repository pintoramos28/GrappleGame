---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 4
---

# Story 2.4: Share Melee Space Between Telegraph and Delivery

As a player,
I want a melee attack's visible warning and dangerous space to agree,
So that I can judge attacks fairly and trust what my own attacks can hit.

**Acceptance Criteria:**

1. **Define one immutable melee-space authority**

   **Given** a melee attack requires an affected area
   **When** its `AbilitySpatialDefinition` is authored
   **Then** it declares a stable definition identity, typed melee shape, local origin, dimensions, orientation rules, target policy, tracking rule, lock boundary, and immutable `MeleeHit` query profile
   **And** presentation styling, lifecycle timing, damage values, and mutable execution state are not stored in the spatial definition
   **And** this story implements only the melee shape required by Epic 2 rather than the complete Epic 3 shape vocabulary.

2. **Create execution-local spatial binding**

   **Given** an ability execution commits with a valid spatial definition
   **When** its attack space is bound
   **Then** one `AbilitySpatialBinding` records the execution identity and the source, socket, target, or frozen transform required by the authored tracking rule
   **And** mutable tracking and lock state belongs to that execution-local binding
   **And** neither the source scene nor a presenter mutates the shared definition.

3. **Produce one authoritative spatial snapshot per step**

   **Given** an execution has a valid spatial binding
   **When** its declared physics-step spatial phase runs
   **Then** the binding produces one immutable `AbilitySpatialSnapshot` containing the execution identity, physics-step identity, shape type, world transform, dimensions, tracking and lock state, and validity
   **And** all gameplay and presentation consumers for that step receive the committed snapshot rather than independently rebuilding the attack geometry.

4. **Apply tracking and locking deterministically**

   **Given** a spatial definition follows its source, socket, or target until an authored phase boundary
   **When** that boundary has not yet been committed
   **Then** each physics-step snapshot follows the declared reference.

   **Given** the authored lock boundary is committed
   **When** later snapshots are requested
   **Then** the execution retains the same frozen world-space binding unless its explicit invalidation policy ends the delivery
   **And** source movement, target movement, animation changes, or subscriber order cannot silently unlock or retarget it.

5. **Drive telegraph presentation from committed space**

   **Given** a melee execution is in windup or another authored visible phase
   **When** the primitive fallback telegraph is presented
   **Then** it consumes the committed spatial snapshot, lifecycle phase, elapsed seconds, normalized progress, and `TelegraphCueDefinition` styling
   **And** it performs no independent spatial query or gameplay timer
   **And** missing, delayed, interrupted, or replaced presentation cannot alter the attack's phase, lock point, or affected area.

6. **Resolve active hits from the same space**

   **Given** the execution enters its simulation-owned active phase
   **When** delivery resolution runs at its declared point after authoritative source movement for that physics step
   **Then** the `MeleeHitQuery` consumes the same committed spatial binding and current authoritative snapshot used by presentation
   **And** it uses the named collision matrix and immutable query profile without magic masks
   **And** an animation callback, `Area3D` overlap signal, or presenter cannot independently enable damage.

7. **Protect high-speed melee delivery**

   **Given** the bound melee space moves far enough between physics steps that a discrete overlap could miss a valid target
   **When** the active hit query resolves
   **Then** it uses the documented swept or velocity-aware melee strategy between authoritative spatial samples
   **And** deliberate collision thickness and tolerant comparisons prevent representative high-speed traversal attacks from tunnelling
   **And** the sweep does not expand the attack beyond its authored geometry without documenting that tolerance.

8. **Normalize hit candidates deterministically**

   **Given** the physics query returns duplicate colliders, several hurtboxes for one combatant, or results in varying engine order
   **When** candidates are normalized
   **Then** duplicate hits are removed according to stable combatant and hurtbox identities
   **And** remaining candidates follow documented geometric scoring and stable tie-break rules
   **And** scene-tree, physics-result, or signal order cannot change the normalized result for the same physical state.

9. **Enforce the authored per-execution hit policy**

   **Given** the initial melee attack declares one accepted hit per target per execution
   **When** the target remains inside the active space across several physics steps
   **Then** that target produces only its first permitted delivery occurrence
   **And** rejected or duplicate candidates cannot create additional damage snapshots or impact contexts.

   **Given** a diagnostic attack remains active for two seconds
   **When** the same target stays within or repeatedly re-enters the melee space
   **Then** it still receives no more hits than the immutable definition's declared policy allows
   **And** broader repeating or pulse-based hit policies remain deferred until a mechanic requires them.

10. **Create authoritative impact inputs**

    **Given** a normalized candidate is accepted by the delivery policy
    **When** the delivery occurrence is committed
    **Then** it pairs the execution's committed `DamageSnapshot` and `MovementCombatContext` with a new `ImpactContext` built from the accepted hit and current source, delivery, and target facts
    **And** source-body impact velocity reflects the authoritative movement result used for that hit-resolution step rather than commit-time velocity
    **And** this story returns the typed delivery result without owning health depletion, reaction, or death.

11. **Handle invalid space and cleanup safely**

    **Given** the spatial definition, source binding, target binding, query profile, or required identity becomes invalid
    **When** snapshot or delivery resolution is attempted
    **Then** the execution receives the applicable typed rejection or cancellation reason
    **And** no partially active hit query, retained target, or stale presentation remains
    **And** cleanup is safe when requested repeatedly.

12. **Expose spatial agreement diagnostics**

    **Given** development diagnostics are enabled
    **When** a melee execution is inspected
    **Then** they expose the definition and execution identities, tracking and lock rule, current and previous spatial snapshots, swept region, normalized candidates, rejections, deduplicated targets, and accepted deliveries
    **And** primitive world drawing renders those already-computed facts without issuing queries or controlling gameplay.

13. **Verify telegraph and delivery agreement**

    **Given** the permanent spatial-contract suite and focused real-Jolt fixtures run
    **When** they exercise source-following, socket-following, phase locking, source movement after lock, boundary contacts, multiple targets, duplicate hurtboxes, varying query order, high-speed traversal, missing presentation, invalid bindings, repeated cleanup, and a two-second active window
    **Then** telegraph samples and active hit classification agree with the same authoritative shape within documented geometric tolerance
    **And** each permitted target produces the expected number of delivery occurrences
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz produce equivalent tracking, locking, swept-hit, and active-duration behavior within documented tolerances.

    **Given** Story 2.4 is complete
    **When** the launch scene, Epic 1 route, lifecycle, damage, context tests, retained references, and working-tree diff are reviewed
    **Then** the spatial contract is independently demonstrable through a primitive test owner
    **And** the story has not migrated the playable player attack or melee enemy, depleted health, selected the final commit-versus-impact reward policy, added non-melee spatial shape families, implemented final animation or VFX, or introduced encounter ownership.
