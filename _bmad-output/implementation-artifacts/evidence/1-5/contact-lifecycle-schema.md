# Contact lifecycle and schema

Story 1.5 introduces a motor-bound `PlayerContactProvider` under
`game/player/locomotion/contact/` and value-only shared records under
`game/shared/physics/`.

## Lifecycle

1. `PlayerMotor.initialize()` validates the typed body, required
   `GroundProbe`, optional `WallProbe`, and locked profile values.
2. `PlayerMotor.bootstrap_contact_frame()` publishes the activation-only
   `ContactFrame(0)` with `BOOTSTRAP` origin and no committed-motor evidence.
   It performs no movement commit.
3. Pre-commit state policy reads only the previously finalized frame.
4. The motor resolves its seven semantic phases, assigns velocity once, and
   calls `move_and_slide()` once.
5. The provider immediately converts the bounded committed collisions to
   `ContactCandidate` values, samples the configured ground and wall probe
   sets once, applies classification/deduplication/selection/continuity, and
   publishes exactly one post-commit frame for the matching step.
6. Post-commit coordination consumes that frame; it becomes the next
   pre-commit frame.

`ContactFrame`, `ContactCandidate`, `ContactRejection`, and
`ContactDiagnosticSnapshot` expose typed scalar/vector/StringName data and
return copies of bounded arrays. They do not store a Node, body, collision,
RID wrapper, query parameter, or untyped dictionary. Frame candidates are
bounded to 8 reported values, rejection summaries to 32, scan budget to 32,
and query count is an explicit value fact.

Invalid body/profile/step composition produces typed failure statuses and a
development-visible invariant through the existing bounded `GameLog` path.
Required ground configuration fails closed; a wall-only profile failure makes
wall contact unavailable without disabling otherwise valid ground motion.

Focused contract coverage in
`tests/player/contact/test_player_contact_contract.gd` verifies copying,
finite/coherent construction, bootstrap, duplicate/skipped/stale hand-offs,
required-vs-wall-only failure, and the controller source-ownership boundary.
