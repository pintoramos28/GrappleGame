---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.5'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 5
---

# Story 1.5: Share Authoritative Ground and Wall Contact Facts

As a player,
I want ground and wall contact interpreted consistently across every traversal state,
So that landing, wall running, wall sticking, and wall jumping remain reliable on varied geometry and at high speed.

**Acceptance Criteria:**

**Given** the player begins an active physics step
**When** contact sampling occurs at its declared movement phase
**Then** one shared `ContactFrame` is produced for that physics step from the relevant body-contact facts, committed collision results, and configured probes
**And** grounded, airborne, grappling, wall-running, and wall-sticking logic consume that same authoritative interpretation rather than constructing competing contact results.

**Given** a `ContactFrame` is produced
**When** a traversal state reads it
**Then** the typed frame exposes its physics-step number, grounded fact, ground normal and identity where present, wall-contact fact, selected wall normal and identity where present, and the bounded contact information required by current traversal behavior
**And** it does not expose an untyped result dictionary or mutable engine-query data as a cross-system contract.

**Given** the player gameplay states have been migrated to the shared frame
**When** their implementations are inspected
**Then** they do not independently call `is_on_floor()`, iterate `get_slide_collision_count()`, issue wall rays or shape casts, or reinterpret ground and wall normals
**And** direct engine contact access remains confined to the motor/contact boundary.

**Given** the contact provider needs to test ground or nearby walls
**When** it performs a physics query
**Then** it uses immutable typed `GroundProbe` or `WallProbe` query profiles and the named collision matrix
**And** gameplay scripts contain no magic layer or mask literals, dynamically constructed resource paths, or hard-coded requirement that every eligible surface be a `StaticBody3D`.

**Given** the player is grounded on supported flat or sloped geometry
**When** the shared contact frame is evaluated
**Then** every locomotion state observes the same grounded fact and stable ground normal for that step
**And** leaving the surface or landing produces one consistent state transition without contradictory state-local checks.

**Given** the player approaches supported non-flat wall geometry with sufficient current movement conditions
**When** wall candidates are sampled
**Then** invalid floor-like or ceiling-like normals are rejected, valid wall candidates are classified consistently, and the selected wall relationship is exposed to wall-run and wall-stick logic
**And** wall-run speed, entry, input-alignment, gravity, and jump tuning remain owned by the existing traversal policy rather than the contact provider.

**Given** several valid wall candidates are returned at a corner or irregular surface
**When** the authoritative wall contact is selected
**Then** duplicate hits are removed and candidates are ordered using documented geometric scoring plus a stable tie-break criterion
**And** changing engine result order, node order, or signal connection order does not change the selected wall for the same physical state.

**Given** the player moves quickly toward a thin or oblique traversal surface
**When** point or ray sampling could miss the contact
**Then** the configured contact strategy uses velocity-aware and swept probing where required by the risk
**And** collision thickness and tolerances are documented and validated without demanding exact floating-point equality.

**Given** a wall normal fluctuates slightly across adjacent triangles or frames
**When** the contact remains within the documented classification and continuity tolerances
**Then** the frame preserves a stable wall relationship instead of oscillating between valid and invalid classifications
**And** a genuinely different or lost surface is still reported without indefinite contact retention.

**Given** the motor has committed movement and exposes its bounded collision result
**When** contact information is prepared for subsequent state coordination
**Then** collision facts are transferred through the contact owner without issuing another movement commit or duplicating equivalent physics queries
**And** stale collision information from an earlier physics-step number is rejected.

**Given** the contact provider, query profile, or required collision configuration is missing or invalid
**When** the player initializes or requests contact sampling
**Then** the failure is reported through a typed development-visible result and unsafe wall behavior is disabled or player activation fails according to the responsible owner
**And** states do not silently fall back to their former private queries.

**Given** contact diagnostics are enabled in a development build
**When** the current frame is inspected
**Then** the diagnostic snapshot exposes the sampled probe geometry, candidate classifications, rejection reasons, selected ground and wall facts, and physics-step identity
**And** visualization consumes the already calculated results without issuing additional physics queries.

**Given** the focused real-Jolt contact tests run
**When** they exercise flat ground, supported slopes, airborne clearance, valid and invalid wall angles, corners with competing walls, irregular adjacent normals, wall loss, landing, and high-speed approach
**Then** all consumers receive one consistent `ContactFrame`, selection remains deterministic, and state transitions occur without duplicated queries
**And** representative behavior remains equivalent at shipping 60 Hz and diagnostic 120 Hz within documented tolerances.

**Given** Story 1.5 is complete
**When** the Story 1.1 smoke procedure and working-tree diff are reviewed
**Then** ground, air, wall-run, wall-stick, wall-jump, and grapple-to-wall transitions remain playable through the shared contact boundary with retained UIDs and a runnable launch scene
**And** the story has not retuned wall behavior, implemented grapple target selection, introduced the maximum grapple boundary, preserved or redesigned the old tutorial, added final presentation, or migrated unrelated domains.
