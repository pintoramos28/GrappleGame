---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.7'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 7
---

# Story 1.7: Zip-Pull Within a True Maximum Grapple Boundary

As a player,
I want grappling to accelerate me toward an anchor while preserving freedom inside its maximum range,
So that grappling builds useful momentum without behaving like a fixed-length rope.

**Acceptance Criteria:**

**Given** the current physics-step targeting result contains a valid accepted target seed
**When** the player's grapple request is committed
**Then** the player-owned grapple controller creates one active attachment using the authoritative anchor position and resolved immutable `GrappleDefinition`
**And** the grapple remains simulation-owned and active until release, invalidation, cancellation, or another defined terminal reason.

**Given** a valid static grapple is active
**When** the player motor resolves sustained influences
**Then** the grapple controller submits the authored acceleration profile directly toward the current anchor through the sustained-influence phase
**And** the grapple controller does not assign body velocity, call movement, or discard pre-existing momentum.

**Given** the player is closer to the anchor than `max_grapple_length_m`
**When** movement would remain inside the maximum boundary
**Then** the maximum-distance constraint makes no correction
**And** inward, outward, and tangential movement remain available subject only to the other authored motor influences and caps.

**Given** the player attaches to an anchor at 10 metres while the validation definition has a 35-metre maximum grapple length
**When** the player subsequently moves away from the anchor
**Then** the player can move beyond the original 10-metre attachment distance until reaching the authored 35-metre boundary
**And** the attachment distance is never stored or interpreted as a fixed rope length.

**Given** the player is at or would cross the maximum grapple boundary
**When** the motor resolves constraints and redirections
**Then** only the outward radial component that would carry the player beyond `max_grapple_length_m` is clipped or redirected within documented tolerance
**And** inward movement, anchor-directed pull, and tangential movement remain unrestricted by that boundary.

**Given** the player approaches the maximum boundary at high outward velocity
**When** a normal physics step would overshoot it
**Then** the motor prevents or corrects the small numerical overshoot within the documented positional tolerance while preserving valid tangential and inward velocity
**And** the correction does not snap the player to the anchor, zero all momentum, or perform an additional movement commit.

**Given** the current slice uses a resolved `max_grapple_length_m` of 35 metres
**When** acquisition and active constraint behavior are inspected
**Then** both consume the same value from the same immutable `GrappleDefinition` authority
**And** no player scene, targeting code, active attachment, presenter, or disposable tutorial content maintains a competing acquisition or tether-range scalar.

**Given** the grapple button is released in the current `PlayerCommandFrame`
**When** the grapple controller terminates the attachment
**Then** sustained pull and maximum-distance constraint submissions stop for that same simulation step according to the declared release phase
**And** the player retains the velocity resolved at release without an artificial stop, snap, or replacement launch velocity.

**Given** the player dies, the attachment becomes invalid, the owning state is cancelled, or another defined terminal condition occurs
**When** grapple termination is requested one or more times
**Then** exactly one reason-coded terminal result is committed and grapple-owned motor submissions are removed safely
**And** repeated termination calls do not repeat state transitions, presentation effects, or cleanup.

**Given** grapple acceleration, speed limits, maximum length, or other authored values are resolved for an execution
**When** runtime modifiers or state-specific values are needed
**Then** the controller computes occurrence-local resolved values without mutating the shared `GrappleDefinition`
**And** a later grapple starts from the unchanged authored definition.

**Given** the grapple line, reticle, camera, audio, or development diagnostics present an active grapple
**When** the player moves inside or along the maximum boundary
**Then** presentation follows the authoritative attachment and motor snapshot
**And** presentation geometry, animation, or audio cannot apply pull, enforce distance, release the grapple, or determine the terminal result.

**Given** grapple diagnostics are enabled
**When** an active attachment is inspected
**Then** the snapshot reports attachment identity, anchor position, current distance, maximum distance, range fraction, pull direction, submitted acceleration, radial and tangential velocity, any boundary correction, and terminal reason
**And** diagnostics are read-only and do not recalculate or alter constraint resolution.

**Given** the focused real-Jolt grapple integration tests run
**When** they exercise attachment well inside the range, attachment near the boundary, outward travel from a short initial distance, inward travel, tangential travel, high-speed overshoot, release, death cancellation, and duplicate termination
**Then** the grapple behaves as an acceleration-based zip-pull with a maximum-only boundary and preserves valid momentum within documented tolerances
**And** equivalent real-time scenarios at shipping 60 Hz and diagnostic 120 Hz produce equivalent attachment duration, acceleration, boundary behavior, and release velocity within documented tolerances.

**Given** Story 1.7 is complete
**When** the traversal smoke procedure and working-tree diff are reviewed
**Then** static-target grappling uses the semantic motor pipeline, the validation definition enforces the same 35-metre acquisition and active boundary, release preserves useful velocity, retained UIDs remain valid, and the launch scene remains runnable
**And** the story has not implemented moving-anchor sampling, target discontinuity handling, rope wrapping, rope elasticity, reeling, rope-segment simulation, final grapple presentation, tutorial preservation, or unrelated migration.
