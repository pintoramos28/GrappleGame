---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.6'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 6
---

# Story 1.6: Acquire Grapple Targets Consistently

As a player,
I want the crosshair and grapple action to agree on which world target is available,
So that every grapple attempt has a predictable result and understandable feedback.

**Acceptance Criteria:**

**Given** the player has a valid immutable `GrappleDefinition` and begins a physics step
**When** grapple targeting is evaluated from the current command frame's authoritative aim direction
**Then** one authoritative physics query produces one typed targeting result for that physics step
**And** the result identifies the candidate, world hit position, surface normal, validity, rejection reason, range fraction, and source physics-step number.

**Given** ordinary collision geometry passes the named grapple-candidate and occlusion profiles
**When** the authoritative query hits that geometry within `max_grapple_length_m`
**Then** the resolver accepts it using the built-in static grapple response without requiring a component on every surface
**And** level authors do not need to place individual grapple anchors across ordinary geometry.

**Given** a moving, stateful, hazardous, resistant, modified, or otherwise exceptional collision body needs non-default behavior
**When** the resolver inspects the blocking hit
**Then** it can obtain a direct child named `Grappleable` typed as `Grappleable3D` and receive a bounded typed response
**And** the target cannot move the player, write player velocity, change locomotion state, or invoke player abilities.

**Given** an exceptional target accepts the query
**When** the resolver creates the accepted target seed
**Then** the seed contains stable target identity, the hit position and normal, the applicable authored response, and the information needed by a later player-owned attachment
**And** continuous moving-target tracking, lifetime sampling, and invalidation remain scoped to Story 1.8.

**Given** the first blocking collision is rejected by its default or explicit grapple policy
**When** another potentially valid target exists behind it
**Then** the resolver returns the first hit's typed rejection instead of piercing through it to select the hidden target
**And** gameplay and presentation report the same rejected result.

**Given** no candidate is hit, the target is outside the maximum acquisition range, the hit is occluded, the surface is ineligible, the target is invalid, or required target data is malformed
**When** targeting resolves
**Then** the result contains the appropriate stable `GrappleRejection` reason and no accepted attachment seed
**And** expected targeting rejection is treated as normal gameplay rather than logged as an error.

**Given** multiple hits or candidate records can describe the same collider or contact
**When** targeting results are normalized
**Then** duplicate hits are removed and selection follows explicit distance, blocking, and stable tie-break rules
**And** engine return order, scene-tree order, and signal connection order cannot change the selected target for the same query state.

**Given** the player presses grapple during a physics step
**When** the movement state attempts to start grappling
**Then** it consumes the valid targeting result produced for that same command-frame and physics-step identity
**And** it does not issue a second gameplay raycast or accept a targeting result from an earlier step.

**Given** the current targeting result is missing or stale when grapple activation is requested
**When** the request is validated
**Then** activation is rejected with a typed reason and no partial grapple state is committed
**And** presentation cannot authorize or substitute its own target.

**Given** the grapple reticle, world marker, or development overlay renders targeting feedback
**When** it updates between physics steps
**Then** it consumes the latest authoritative targeting result and may visually interpolate its presentation
**And** it does not raycast independently, change validity, delay gameplay activation, or retain a target after the authoritative result becomes unavailable.

**Given** an accepted target is at or near the authored acquisition boundary
**When** the query is evaluated within documented physics tolerance
**Then** acquisition consistently uses `GrappleDefinition.max_grapple_length_m` as its only authoritative range value
**And** the player scene, disposable tutorial content, targeting presenter, and other callers do not maintain competing grapple-range scalars.

**Given** the query profiles, grapple definition, collision configuration, resolver, or required targeting dependency is missing or invalid
**When** the grapple feature initializes
**Then** initialization fails through a typed development-visible result or the grapple feature is safely unavailable according to its owner
**And** gameplay does not fall back to magic collision masks, direct `StaticBody3D` checks, dynamic resource paths, or the legacy duplicate raycast.

**Given** grapple targeting diagnostics are enabled
**When** the latest result is inspected
**Then** diagnostics expose the query origin and direction, maximum range, first blocking hit, target identity, acceptance or rejection reason, range fraction, profile identifiers, and physics-step number
**And** diagnostics reuse the authoritative result without executing another query.

**Given** the focused real-Jolt targeting tests run
**When** they exercise default geometry, accepted and rejected exceptional targets, blockers with valid targets behind them, empty aim, occlusion, maximum-range boundaries, duplicate candidates, stale results, and presentation consumption
**Then** gameplay, reticle presentation, and diagnostics agree on candidate identity, hit position, and validity
**And** exactly one authoritative gameplay targeting query is performed for each evaluated physics step.

**Given** Story 1.6 is complete
**When** the traversal smoke procedure and working-tree diff are reviewed
**Then** the player can identify and start grappling valid current targets through the typed targeting boundary, current grapple pull remains playable, retained UIDs remain valid, and `res://main.tscn` still runs
**And** the story has not implemented the active maximum-distance constraint, redesigned pull acceleration, added moving-target sampling, preserved the disposable tutorial, introduced final presentation assets, or migrated unrelated systems.
