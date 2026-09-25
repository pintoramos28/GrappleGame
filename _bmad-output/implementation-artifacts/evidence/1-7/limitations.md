# Limitations and known gaps (Story 1.7)

1. **Manual-step test idiom is not physics-delta accurate.** Calling
   `player.call("_physics_process", delta)` outside the engine's physics
   callback makes `CharacterBody3D.move_and_slide()` integrate with the *frame*
   delta (measured: `10 m/s` moved `1.35 m` at `process_dt 0.135 s`). All
   Story 1.7 integration scenarios therefore step on engine-driven physics
   frames (`await get_tree().physics_frame`); the contract suite's position
   assertions are bounded accordingly (velocity-space contracts are exact). Any
   future test that asserts positions under the manual idiom must account for
   this. Recommended follow-up (not this story's debt): document this in the
   shared test idiom notes.
2. **Acquisition and the active boundary use different origins by design.**
   Acquisition (Story 1.6, locked) measures the crosshair ray from the camera;
   the active boundary, pull direction, and diagnostics measure from the body
   origin (Task 4.4). The authored 35 m value is shared from the one
   `GrappleDefinition`, but a target can only be acquired while the *camera-ray*
   distance is `<= 35 m`, so the maximum *attachment* distance is roughly 3 m
   shorter than the active boundary (the camera sits behind/above the body).
   AC 4's "attach at 10 m, travel to 35 m" is unaffected; a "attach at exactly
   35 m body-distance" case is not physically reachable through acquisition.
3. **Live tangential-slide staging was partially effective.** The MCP smoke's
   tangential re-seed did not reproduce the full seeded speed in the running
   game (see `traversal-smoke.md`); the tangential-preservation contract is
   proven in the GUT real-Jolt suite instead (contract: exact; integration +
   60/120: 2.914 -> 2.913 m/s over the release window).
4. **Overshoot tolerance is verified as a bound, not a distribution.** The
   documented `0.05 m` positional tolerance is asserted as
   `max_distance <= 35.05` across the real-Jolt scenarios (measured peaks
   `35.00003` / `35.00001`); it is not a statistical characterization of
   collision-resolution drift, which needs representative content.
5. **`GrappleTargetResponse.directional_adjustment`, `instability`, and
   `hazard_response` are not consumed** (locked schema, Story 1.8+ owns moving
   anchors and hazard semantics). Only `pull_multiplier` affects occurrence-local
   resolution; the speed cap and maximum length resolve 1:1 from the definition.
6. **Moving anchors are out of scope (AC 14).** The attachment stores one
   authoritative anchor position (`seed.hit_position`); no moving-anchor
   sampling, target discontinuity handling, rope wrapping/elasticity/reeling,
   rope-segment simulation, final grapple presentation, or tutorial
   preservation was implemented.
7. **The untyped `get_grapple_telemetry()` Dictionary is removed**, not
   migrated in place: the dev overlay now consumes the typed attachment +
   targeting snapshots. Any external caller of the Dictionary would need the
   typed accessors (`get_grapple_attachment_diagnostic_snapshot()` /
   `get_grapple_targeting_diagnostic_snapshot()`); there are none in-repo.
8. **Pre-existing issues left untouched (not Story 1.7 debt):** the prototype's
   extra `move_and_slide()` call sites (Story 1.3-era debt), the stale editor-log
   parse-error history, the `seed` shadowing warnings in Story 1.6 files, the
   Story 1.5 P2s (lossy motor overflow accounting, `unlock_for_editor()` at
   runtime, init `SUCCESS` on an invalid optional wall profile), and the enemy
   damage-on-spawn behavior in `main.tscn`.
