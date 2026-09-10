---
artifact_schema: 1
artifact_id: 'grapplegame.story.2.1'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 2
story: 1
---

# Story 2.1: Run Every Timed Ability Through One Lifecycle

As a player,
I want timed combat actions to start, progress, cancel, and finish consistently,
So that their gameplay behavior does not change with animation, rendering rate, or duplicate requests.

**Acceptance Criteria:**

1. **Define immutable lifecycle data**

   **Given** a timed ability is authored
   **When** its `AbilityDefinition` is inspected
   **Then** it declares a stable definition identity, windup, active, recovery, and optional cooldown durations in seconds, its active-completion mode, and its allowed cancellation rules
   **And** serialized duration fields use the `_seconds` suffix
   **And** all occurrence-specific mutable state remains outside the shared Resource.

2. **Validate before committing an execution**

   **Given** an owner submits a typed ability request
   **When** the local lifecycle owner validates the definition, current execution state, cooldown, and supplied scope identity
   **Then** an accepted request commits one owner-local `AbilityExecution` with a stable execution ID
   **And** a rejected request returns a typed `AbilityStartResult` without creating an execution, starting presentation, consuming cooldown, or producing a terminal result
   **And** cross-ability and traversal arbitration remain assigned to Story 2.5.

3. **Follow one authoritative phase sequence**

   **Given** an execution has been committed
   **When** it advances normally
   **Then** it progresses through `WINDUP`, `ACTIVE`, `RECOVERY`, and `COMPLETED` in that order
   **And** its requested and validated results remain explicit records preceding the committed runtime phases
   **And** no animation, audio, VFX, timer node, rendered-frame callback, or presenter can advance those phases.

4. **Advance timing through fixed-step simulation**

   **Given** an execution is non-terminal
   **When** its owner advances it during a physics step
   **Then** phase elapsed time advances only from fixed-step physics `delta` expressed in seconds
   **And** excess elapsed time carries across phase boundaries instead of being discarded
   **And** a large physics step may cross multiple phases without silently lengthening the ability.

5. **Support fixed and held active phases**

   **Given** a definition declares a fixed active duration
   **When** that duration elapses
   **Then** the execution advances to recovery automatically.

   **Given** a definition declares an owner-controlled held active phase
   **When** its valid continuation condition remains true
   **Then** it remains active until the owner submits a typed release, invalidation, or cancellation request
   **And** this capability does not migrate or redesign the existing grapple implementation in this story.

6. **Handle zero and invalid durations safely**

   **Given** a valid definition contains one or more zero-duration phases
   **When** the execution advances
   **Then** it crosses those phases in deterministic order using bounded transition processing
   **And** it cannot hang or emit duplicate phase events.

   **Given** a duration is negative, non-finite, structurally invalid, or would exceed the transition safety bound
   **When** validation or advancement detects it
   **Then** the request is rejected or the committed execution is cancelled with the appropriate typed reason
   **And** no active gameplay window remains partially enabled.

7. **Cancel from an allowed non-terminal phase**

   **Given** an execution is in windup, active, or recovery
   **When** its owner accepts an interruption, death, reset, invalidation, or explicit cancellation request permitted by the definition
   **Then** it transitions directly to one `CANCELLED` terminal result containing the stable execution ID and typed reason
   **And** cancellation during windup never enters the active phase
   **And** cleanup hooks run exactly once.

8. **Produce exactly one terminal result**

   **Given** completion, cancellation, death, reset, or another terminal request overlaps or repeats
   **When** more than one path attempts to terminate the same execution
   **Then** the first committed terminal result remains authoritative
   **And** later requests return that result or an idempotent already-terminal response
   **And** phase notifications, cleanup, cooldown initiation, and terminal notification are not repeated.

9. **Apply cooldown as a gate rather than an attack phase**

   **Given** a definition declares a cooldown and its explicit cooldown-start policy
   **When** that boundary is committed
   **Then** the owner advances cooldown using fixed-step seconds independently of animation or rendered frames
   **And** requests received before cooldown expiry return a typed cooldown rejection
   **And** cooldown is not inserted between active and recovery as a competing lifecycle phase.

10. **Commit state before notifying observers**

    **Given** an execution changes phase or becomes terminal
    **When** it notifies presentation, diagnostics, or other observers
    **Then** the new state is fully committed before synchronous notification occurs
    **And** subscribers cannot veto the transition or depend on connection order
    **And** a reentrant start, transition, completion, or cancellation request is rejected or deferred to the owner's next declared evaluation point.

11. **Expose bounded observational state**

    **Given** presentation or development diagnostics observe an execution
    **When** they request its snapshot
    **Then** they receive read-only execution ID, definition ID, current phase, elapsed seconds, normalized progress where defined, active-completion mode, cooldown state, and terminal result
    **And** optional animation, audio, or VFX may be absent or interrupted without affecting gameplay timing
    **And** diagnostics perform no duplicate lifecycle calculation.

12. **Verify the lifecycle contract**

    **Given** the permanent automated lifecycle suite runs
    **When** it exercises normal completion, cancellation from each phase, rejected requests, fixed and held active modes, zero-duration phases, large-delta carry-over, invalid definitions, cooldown rejection and expiry, reentrant requests, duplicate terminal calls, and missing presentation
    **Then** each committed execution follows its configured phases and produces exactly one terminal result
    **And** a two-second active-duration case remains active for the authored real-time duration
    **And** equivalent scenarios at shipping 60 Hz and diagnostic 120 Hz produce equivalent real-time phase boundaries within one physics-step tolerance.

    **Given** Story 2.1 is complete
    **When** its scope and working-tree diff are reviewed
    **Then** the reusable lifecycle is independently executable through a focused test owner while the project and Epic 1 traversal route remain runnable
    **And** the story has not migrated player or enemy attacks, implemented damage, captured movement or impact contexts, created attack geometry or telegraphs, changed traversal coordination, or introduced the full encounter lifecycle.
