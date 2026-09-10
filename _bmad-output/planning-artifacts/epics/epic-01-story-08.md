---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.8'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 8
---

# Story 1.8: Grapple Moving and Stateful Targets Safely

As a player,
I want my grapple attachment to follow moving or stateful targets and end safely when they become invalid,
So that dynamic anchors behave predictably without stale references or violent snaps.

**Acceptance Criteria:**

1. **Store target-relative attachment state**

   **Given** a grapple hit is accepted on a moving or stateful `Grappleable3D`
   **When** the attachment is created
   **Then** the player-owned `GrappleAttachment` stores the target's stable identity, a weak target reference, and the hit position in target-local coordinates
   **And** it stores bounded response values and an optional originating encounter-scope identity
   **And** it does not mutate any shared Resource.

2. **Sample authoritative anchor state**

   **Given** the attachment target remains valid
   **When** each physics step reaches the grapple-sampling phase
   **Then** the target supplies a `GrappleAnchorState` containing its world-space attachment position, target velocity, validity, effective response values, and any typed invalidation reason
   **And** the motor and grapple presentation consume the same sampled state for that physics step
   **And** the target cannot directly move the player or change player state.

3. **Follow continuous target movement**

   **Given** an attached target translates or rotates normally
   **When** its transform changes
   **Then** the attachment point follows the stored target-local hit position through both translation and rotation
   **And** target motion is reflected in the sampled anchor velocity
   **And** the system does not repeat target-selection raycasts to find the attachment point.

4. **Resolve a taut tether using relative motion**

   **Given** the player is inside the maximum grapple distance
   **When** the attached target moves away
   **Then** the player is not pulled until the grapple reaches its maximum length.

   **Given** the grapple is at maximum length
   **When** continuous target motion would increase the player-to-anchor distance
   **Then** the player receives only the target's separating radial motion required to keep the grapple within its maximum length
   **And** inward and tangential player motion remain available
   **And** target motion toward the player does not push the player
   **And** any required correction exceeding the configured discontinuity tolerance terminates the grapple instead of snapping the player.

5. **Preserve static-target behavior**

   **Given** the accepted target does not provide exceptional moving or stateful behavior
   **When** it is grappled
   **Then** the default static-target response from Story 1.7 remains in effect
   **And** existing zip-pull and maximum-boundary behavior does not regress.

6. **Handle invalid targets safely**

   **Given** an attached target is freed, explicitly invalidated, or reports an incompatible encounter-scope identity
   **When** the attachment is next sampled
   **Then** the grapple ends exactly once with the corresponding typed termination reason
   **And** no stale reference is dereferenced
   **And** no residual constraint impulse or player velocity spike is introduced.

7. **Reject severe transform discontinuities**

   **Given** the attached target moves within the configured continuous-motion tolerance
   **When** its anchor state is sampled
   **Then** the grapple follows it normally
   **But given** the anchor crosses the configured severe-discontinuity threshold
   **When** that state is sampled
   **Then** the grapple terminates with a typed discontinuity reason instead of snapping or teleporting the player.

8. **Make termination idempotent**

   **Given** release input, player death, target invalidation, or source removal overlap during the same physics step
   **When** more than one termination path is requested
   **Then** attachment cleanup and its termination event occur only once
   **And** the player returns to a valid traversal state.

9. **Expose state without transferring authority**

   **Given** grapple presentation or diagnostics need the active attachment position and status
   **When** they query the grapple system
   **Then** they receive read-only data derived from the authoritative sampled anchor state
   **And** they cannot modify attachment, motor, or target state.

10. **Verify moving-target behavior**

    **Given** focused automated tests running against real Godot/Jolt physics
    **When** translation, rotation about the local hit point, target velocity, relative maximum-distance resolution, target removal, explicit invalidation, scope mismatch, severe discontinuity, duplicate termination, and static-target regression scenarios are exercised
    **Then** every scenario passes at both 60 Hz and 120 Hz physics rates
    **And** the story introduces only an injectable scope-identity contract—not the full encounter lifecycle, anchor-modification mechanics, rope wrapping, elasticity, or reeling.
