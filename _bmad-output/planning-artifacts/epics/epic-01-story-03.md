---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.3'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 3
---

# Story 1.3: Centralize the Player's Physics-Step Movement Commit

As a player,
I want every traversal state to resolve through one authoritative movement commit,
So that state transitions cannot move me twice, skip collision movement, or produce order-dependent velocity.

**Acceptance Criteria:**

**Given** a successfully initialized player enters an active physics step
**When** player movement processing begins
**Then** the player motor opens one motion frame identified by the current physics-step number
**And** that frame begins from the player body's previously committed velocity and current transform without allowing a movement commit yet.

**Given** the movement state machine evaluates grounded, airborne, grappling, wall-running, wall-sticking, or dead behavior
**When** the active state calculates its existing motion result
**Then** it submits that result through the typed player-motor boundary
**And** the state does not assign the `CharacterBody3D`'s final velocity, change its authoritative global position, or call `move_and_slide()` directly.

**Given** movement-state evaluation completes or dispatches a state transition during a physics step
**When** the player movement coordinator reaches its commit phase
**Then** the player motor assigns final body velocity and calls `move_and_slide()` exactly once for that active physics step
**And** early returns, state changes, grapple start or release, landing, jumping, wall transitions, and death cannot create either a second commit or a missing commit.

**Given** both movement and attack state machines are active
**When** they evaluate the same command frame
**Then** only the movement coordination path can request and commit player displacement
**And** attack-state processing cannot call movement methods or cause an additional body commit.

**Given** grounded or airborne locomotion is active
**When** movement, gravity, jumping, landing, and deceleration are exercised
**Then** their observable velocity and collision behavior remain equivalent to the approved Story 1.1 baseline within documented physics tolerances
**And** the new motor boundary does not retune any traversal scalar.

**Given** grappling, wall running, wall jumping, wall sticking, or dead movement is active
**When** that state requests its current movement behavior
**Then** its complete provisional velocity or hold request is resolved by the motor before the single commit
**And** this story preserves the current behavior without yet decomposing it into the semantic influence phases reserved for Story 1.4.

**Given** wall-stick entry or another transition depends on collisions produced by movement
**When** the single motor commit completes
**Then** the resulting slide collisions are exposed through a bounded post-commit result for state coordination
**And** inspecting or reacting to those results does not call `move_and_slide()` again in the same physics step.

**Given** wall sticking needs to hold the player at its committed location
**When** the wall-stick state remains active
**Then** it requests the hold through the motor boundary
**And** the wall-stick script does not write `global_position` or authoritative velocity directly.

**Given** a second commit is requested using the same physics-step number
**When** the player motor validates the request
**Then** a debug assertion and stable diagnostic event identify the duplicate request, the second movement operation is rejected, and release execution remains safely guarded
**And** the player body is not moved a second time.

**Given** the player motor is missing, initialized twice, or receives an invalid motion request
**When** player initialization or movement processing occurs
**Then** the failure is exposed through a typed development-visible result or invariant diagnostic without falling back to state-owned movement
**And** the partially configured player does not continue active traversal.

**Given** the player motor exposes development diagnostics
**When** the motor snapshot is inspected
**Then** it reports the physics-step number, initial velocity, submitted provisional result, committed velocity, commit count, active locomotion state identifier, and any rejection reason
**And** diagnostics remain read-only, bounded, and disabled when not requested.

**Given** the focused real-Jolt player-motor integration tests run
**When** they exercise grounded, airborne, jump, grapple, wall-run, wall-jump, wall-stick, dead, and state-transition steps
**Then** every active physics step records exactly one player movement commit and duplicate requests are rejected
**And** the test uses physics tolerances rather than exact floating-point equality or a deeply mocked physics body.

**Given** Story 1.3 is complete
**When** the player gameplay scripts, scene references, baseline smoke procedure, and working-tree diff are reviewed
**Then** `move_and_slide()` and final player-body velocity assignment occur only through the player motor, retained scenes and Resources preserve their UIDs, and `res://main.tscn` remains runnable
**And** the story has not introduced semantic influence ordering, shared `ContactFrame` classification, grapple-contract redesign, traversal retuning, tutorial preservation, application-root migration, or unrelated domain changes.
