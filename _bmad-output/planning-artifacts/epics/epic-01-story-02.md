---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.2'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 2
---

# Story 1.2: Deliver Reliable Fixed-Step Player Commands

As a player,
I want my movement, actions, and mouse aim captured consistently at physics-step boundaries,
So that jumping, attacking, grappling, releasing, and aiming remain responsive regardless of render timing.

**Acceptance Criteria:**

**Given** the player has been initialized successfully
**When** a physics step begins
**Then** the player-owned input source produces exactly one immutable `PlayerCommandFrame` for that physics step
**And** the frame contains the physics-step number, movement axis, canonical view yaw and pitch, authoritative world-space aim direction, and pressed, held, and released states for jump, grapple, and attack.

**Given** both the movement and attack state machines evaluate the same physics step
**When** they read player intent
**Then** they consume the same committed `PlayerCommandFrame` instance or snapshot
**And** neither state machine resamples hardware input or changes the frame.

**Given** the input migration is complete
**When** the grounded, airborne, grappling, wall-running, wall-sticking, attack-ready, and other player gameplay states are inspected
**Then** they contain no direct `Input.is_action_*()`, `Input.get_vector()`, or equivalent global hardware polling
**And** hardware access is confined to the player input source and explicitly permitted application or development input boundaries.

**Given** directional keys are pressed, held, combined, and released
**When** successive command frames are produced
**Then** the movement axis preserves the existing Input Map direction and normalization behavior
**And** ground and air controls respond as they did in the approved Story 1.1 baseline.

**Given** an action is pressed and released between two physics steps
**When** the next command frame is committed
**Then** its pressed and released edges are represented without losing the short input
**And** each latched edge appears in exactly one command frame before being cleared.

**Given** an action remains held across multiple physics steps
**When** successive command frames are committed
**Then** the first frame reports the press, every applicable frame reports the held state, and only the release frame reports the release
**And** changing the diagnostic physics rate from 60 Hz to 120 Hz does not cause duplicated or missing edges.

**Given** the game window loses focus while movement, attack, jump, or grapple input is held or latched
**When** focus-loss handling runs
**Then** held and pending gameplay input is cleared before the next active gameplay frame
**And** returning focus cannot produce stuck movement, an unintended attack, an unintended jump, or a continuing grapple command.

**Given** the mouse is captured and one or more mouse-motion events arrive
**When** canonical aim is updated
**Then** every received relative-motion event contributes exactly once, sensitivity is applied exactly once, pitch remains within the configured limits, and mouse delta is not multiplied by render or physics delta
**And** the next physics command frame snapshots the latest canonical orientation and corresponding aim direction.

**Given** the camera presents the player's current view between physics steps
**When** it reads the latest canonical orientation
**Then** presentation may update at render rate while gameplay continues to use the committed physics-step aim snapshot
**And** camera presentation, collision, shake, or smoothing cannot modify the authoritative aim stored in a command frame.

**Given** the player is dead or gameplay input is otherwise gated by the current state
**When** a command frame contains an action request
**Then** the owning gameplay state rejects or ignores that request without mutating the command frame
**And** the input source does not take ownership of locomotion, ability, or death-state decisions.

**Given** the player input source or another required typed dependency is missing or invalid
**When** player initialization occurs
**Then** initialization fails through an explicit development-visible error instead of silently falling back to global hardware polling
**And** the invalid player does not enter active gameplay in a partially configured state.

**Given** the first rewritten input seam and GUT test location now exist
**When** the focused command-frame tests run
**Then** they verify movement-axis sampling, press/hold/release progression, same-frame press-and-release latching, focus-loss clearing, one frame per physics step, and stable aim accumulation
**And** the canonical recursive headless GUT command and test location are recorded for subsequent stories.

**Given** Story 1.2 is complete
**When** the Story 1.1 traversal smoke procedure and working-tree diff are reviewed
**Then** the existing keyboard-and-mouse controls, current mouse-capture and release behavior, launch path, and observed traversal behavior remain equivalent to the baseline
**And** the story has not introduced remapping UI, settings persistence, controller support, motor restructuring, traversal retuning, grapple redesign, tutorial preservation, dependency upgrades, or unrelated domain migration.
