# Story 1.3 motor contract evidence

`PlayerMotor` is a typed child boundary under `game/player/motor/`, initialized with the retained player-root `CharacterBody3D`. The controller now owns the fixed-step choreography:

```text
capture PlayerCommandFrame N
  -> begin_motion_frame(N)
  -> movement HSM update once
  -> one MOVE or HOLD submission
  -> resolve_and_commit once
  -> post-commit collision/transition coordination
  -> attack HSM update once
```

The motor applies an optional wall-stick hold correction, assigns the complete provisional velocity once, calls `move_and_slide()` once, captures post-slide velocity/collisions, and returns a bounded typed result. Invalid requests, duplicate frames, duplicate submissions, duplicate commits, and initialization failures return typed statuses/results and emit stable dotted diagnostics through the small `GameLog` facade. The diagnostic snapshot is opt-in and contains only copied scalar/vector/ID facts.

The six locomotion states submit complete provisional requests. Wall-stick uses the explicit motor HOLD request; grappling consumes the returned bounded slide collisions after commit; attack states remain movement-authority-free. No influence phases, `ContactFrame`, global store, autoload, AppRoot migration, grapple-contract redesign, or traversal retuning were added.

## Hardening follow-up

- The controller now treats the frame as a transaction: the first accepted request is not committed after any later submission rejection. It aborts the active frame, deactivates traversal, and emits no post-commit transition.
- Wall-stick acquisition arms a motor-owned zero-velocity baseline for the next frame before the state flag is changed. A release or jump therefore cannot inherit the previous grapple velocity.
- Initialization, begin, submit, baseline, abort, and commit paths validate the live `CharacterBody3D` lifecycle. Detached and freed-body paths return typed failures without reading or writing body state; invalid commit paths clear stale success results.
- Collision facts are scanned from at most 32 engine contacts and returned in a stable maximum-eight order that prioritizes wall-like normals. The result exposes truncation without retaining an unbounded contact history.
- `GameLog` deduplicates stable code/context identities across physics steps and keeps a bounded FIFO key set of 32 entries. Physics-step numbers remain in the emitted context but do not cause a repeated invariant to flood the engine log.

Focused GUT coverage exercises each of these cases, plus a real-Jolt per-tick coordinator path. The final recursive player run passed 45/45 tests and 967 assertions; the focused motor run passed 24/24 tests and 290 assertions.

The integration tests use real `CharacterBody3D` nodes in real Jolt physics spaces. They cover each stable ID (`player.locomotion.grounded`, `.airborne`, `.grappling`, `.wall_run`, `.wall_stick`, `.dead`), bounded collision exposure, duplicate side-effect rejection, the retained player scene, grounded/jump/dead coordinator steps, transient wall-run/jump, and transient grapple-to-wall-stick hold/release. Wall geometry is test-created and therefore remains fixture evidence consistent with `BASE-007`; no stronger normal-play wall claim is made.
