# Attachment lifecycle and terminal contract (Tasks 2, 3)

## Types (new)

- `game/player/abilities/grapple/grapple_attachment.gd` (`GrappleAttachment`):
  occurrence-local mutable runtime state - stable attachment identity
  (`player.grapple.attachment_<n>`), immutable `GrappleDefinition` reference,
  accepted `GrappleTargetSeed` facts (anchor world position, target identity,
  weak target reference, local hit offset), occurrence-local resolved values,
  the pull clock, and exactly one committed terminal. Attachment distance is
  never stored as rope length (AC 4).
- `game/player/abilities/grapple/grapple_controller.gd` (`GrappleController`):
  owns the active attachment, commits it from the accepted same-step seed,
  submits the per-step motor influences, and commits the terminal. It never
  writes velocity and never calls movement (AC 2).
- `game/player/abilities/grapple/grapple_end_reason.gd` (`GrappleEndReason`):
  **closed 6-value set (locked)** - `NONE, RELEASE, TARGET_INVALIDATED,
  OWNER_DEATH, STATE_CANCELLATION, GROUND_CONTACT` with stable ids
  `none|release|target_invalidated|owner_death|state_cancellation|ground_contact`.
  `NONE` is never a committed terminal (mirrors `GrappleRejection`'s `NONE`).

## Lifecycle

accepted seed -> committed attachment (active) -> exactly one reason-coded
terminal -> submissions stop. Exactly one active attachment at a time; a second
commit reports `ATTACHMENT_ALREADY_ACTIVE`.

Termination routing (Task 3.2):

| Call site | Reason |
|---|---|
| `player_grappling_state.gd` release edge | `RELEASE` |
| `player_grappling_state.gd` / `player_wall_stick_state.gd` `has_valid_grapple()` failure, `submit_grapple_pull()` target death | `TARGET_INVALIDATED` |
| `_set_dead()` / `player_dead_state.gd` `_enter()` | `OWNER_DEATH` |
| `submit_wall_stick_jump()` (wall-stick jump leaves the flow) | `STATE_CANCELLATION` |
| `_coordinate_post_commit()` landing while grappling | `GROUND_CONTACT` |

## Exactly-once (NFR15)

`GrappleController.terminate(reason, step)` commits the terminal once and emits
`attachment_ended(attachment_id, reason)` once; repeated requests return the
same `GrappleAttachment.Terminal` record (same object) and repeat no transition,
signal, presentation effect, or cleanup. `player_controller.terminate_grapple()`
runs the preserved `_clear_grapple()` side effects (wall-stick coupling, rope
hide) exactly once and returns false on repeats.

## Preserved behavior

Activation validation flow and its typed `GrappleRejection` values
(`MISSING_RESULT` / `STALE_RESULT` / `TARGET_INVALID`) are unchanged; the
controller's five former state fields are now read-through views of the
attachment (`is_grappling`, `grapple_point`, `grapple_target`,
`grapple_elapsed`, `grapple_applied_acceleration`) - one authority, no second
state copy. Release keeps the resolved velocity; wall-stick coupling and the
frozen rope lifecycle (`spec-grapple-visual-interpolation-reset.md`) are
byte-identical.

## Verification

- `test_grapple_boundary_contract.gd`: single-commit + stable identity + seed
  facts + weak-reference death; resolved-value immutability and later-occurrence
  reset; closed end-reason set and stable ids; duplicate-termination idempotence
  (same `Terminal`, one `attachment_ended` emission, submissions stop);
  snapshot schema/purity.
- `test_grapple_boundary_integration.gd` (real Jolt, live scene): release
  preserves the committed velocity (AC 8) and commits `release`; death cancels
  once with `owner_death` and stops submissions; duplicate termination repeats
  no cleanup (rope hidden once, one signal).
- MCP live smoke: `release` and `ground_contact` terminals observed in the
  running game (`traversal-smoke.md`).
