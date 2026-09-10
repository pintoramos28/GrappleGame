---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.4'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 4
---

# Story 1.4: Resolve Traversal Through Semantic Motor Phases

As a player,
I want grappling, jumping, wall movement, gravity, and ordinary locomotion resolved in a stable order,
So that combined traversal actions behave predictably without competing systems overwriting my movement.

**Acceptance Criteria:**

**Given** the Story 1.3 player motor begins an active physics step
**When** it resolves submitted movement behavior
**Then** it processes terminal commands, state gating and interrupts, base locomotion and gravity, sustained influences, one-shot impulses, constraints and redirections, caps, and final movement commit in that exact semantic order
**And** it retains exactly one final velocity assignment and one `move_and_slide()` call.

**Given** a locomotion state or ability needs to affect player movement
**When** it submits its contribution
**Then** it uses a typed method associated with the correct semantic phase and supplies a stable source identity where required
**And** it cannot assign an arbitrary numeric priority, depend on scene-tree order, or mutate the final body velocity directly.

**Given** existing ground and air traversal executes through the motor
**When** input acceleration, deceleration, gravity, and current movement caps are resolved
**Then** ordinary horizontal locomotion and gravity contribute through their declared base and cap phases
**And** their observable behavior and authored tuning remain equivalent to the approved baseline within physics tolerances.

**Given** the current grapple is active before its later contract redesign
**When** its existing pull acceleration and velocity cap are resolved
**Then** the pull is submitted as a sustained influence and its existing cap is applied during the cap phase
**And** this story does not yet introduce the maximum-distance connection boundary assigned to Story 1.7.

**Given** wall-running or wall-sticking behavior is active
**When** its current movement behavior is resolved
**Then** wall-run acceleration, wall-relative redirection, outward-velocity removal, and wall-stick holding use the appropriate typed motor phases
**And** existing wall detection remains unchanged until shared contact classification is introduced in Story 1.5.

**Given** the player initiates a ground jump or wall jump
**When** the associated one-shot impulse is submitted
**Then** the impulse is applied during the one-shot phase after sustained influences and before constraints and caps
**And** a stable occurrence identity prevents the same jump request from applying more than once.

**Given** several compatible influences are submitted during the same semantic phase
**When** the motor aggregates them
**Then** the result follows a documented, deterministic phase-specific rule using stable source identity where tie-breaking is required
**And** changing node order or signal connection order does not change the committed velocity.

**Given** mutually exclusive movement policies are requested for the same physics step
**When** the player coordinator plans the transition or the motor validates submissions
**Then** the conflict is resolved or rejected before final movement is committed
**And** the motor does not silently select the last writer or leave partially applied state.

**Given** a one-shot request is repeated, a submission carries a stale physics-step number, or a source submits through an invalid phase API
**When** the motor validates the submission
**Then** the invalid contribution is rejected with a stable reason and development-visible diagnostic
**And** valid contributions for the current step can still resolve safely without a second commit.

**Given** a new physics step begins
**When** the motor opens its motion frame
**Then** all prior per-step submissions, occurrence guards, and temporary resolution data are cleared or advanced correctly
**And** longer-lived grapple, wall, or locomotion state remains owned by its originating component rather than being copied into mutable shared data.

**Given** acceleration, gravity, pull, or another rate-based influence is resolved
**When** the physics rate is changed between shipping 60 Hz and diagnostic 120 Hz
**Then** the influence advances using physics delta in seconds and produces equivalent real-time behavior within documented tolerances
**And** no movement value is multiplied by rendered-frame count or a raw tick assumption.

**Given** motor diagnostics are enabled in a development build
**When** a physics step is inspected
**Then** the diagnostic snapshot identifies every submitted source by semantic phase, any rejected contributions, intermediate resolved velocities, applied caps or constraints, and the final commit
**And** the snapshot is bounded, read-only, and performs no duplicate movement calculation.

**Given** the focused motor contract tests run
**When** identical submissions are provided in different insertion and node orders
**Then** the committed result is identical within physics tolerance
**And** the suite also verifies fixed phase order, one-shot deduplication, stale-step rejection, conflict handling, per-step clearing, one final commit, and 60/120 Hz real-time equivalence.

**Given** Story 1.4 is complete
**When** the traversal smoke procedure and working-tree diff are reviewed
**Then** ground, air, jump, current grapple, wall-run, wall-stick, wall-jump, death, and transition behavior remain playable through the semantic motor pipeline
**And** the story has not implemented shared `ContactFrame` queries, the typed grapple-target contract, the true maximum grapple boundary, moving-target attachment, combat-pressure effects, traversal retuning, tutorial preservation, or unrelated migration.
