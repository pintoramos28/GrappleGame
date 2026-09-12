# Story 1.3 writer and preservation audit

## Player writer boundary

The scoped source audit was run against `scripts/player_controller.gd`, all six player locomotion states, and `game/player/motor/player_motor.gd`:

```powershell
rtk rg -n "move_and_slide\(|\b(?:global_position|velocity)(?:\.|\s*=)" scripts/player_controller.gd scripts/player_grounded_state.gd scripts/player_airborne_state.gd scripts/player_grappling_state.gd scripts/player_wall_run_state.gd scripts/player_wall_stick_state.gd scripts/player_dead_state.gd game/player/motor/player_motor.gd
```

The only active player-body writes/call are:

```text
game/player/motor/player_motor.gd:355:        _body.global_position = hold_position
game/player/motor/player_motor.gd:356:    _body.velocity = request.provisional_velocity
game/player/motor/player_motor.gd:357:    _body.move_and_slide()
```

The remaining scoped match is `scripts/player_controller.gd:873`, which writes `grapple_cursor.global_position` for presentation. Local `motion_velocity` calculations are provisional values and do not match a body-level writer. Attack-state source audit found no movement call, `PlayerMotor` reference, or motor submission.

Non-player matches remain intentionally untouched: enemy movement, projectile/visual transforms, and the tutorial's out-of-band player reset teleport. The pre-change writer list and classifications are preserved in `pre-change-oracle.md`.

## Scene and tuning preservation

- `scenes/player.tscn` retains `uid://u1u36ceuo8uj`, its existing ext-resource UIDs, unique node IDs, collision setup, HSM topology, and controller tuning. It only adds the `PlayerMotor` child/resource.
- `main.tscn` retains its launch role and `ground_deceleration = 30.0` / `grapple_gravity_scale = 0.0` overrides.
- `project.godot`, `main.tscn`, Resources, add-on versions, input definitions, tutorial content, and attack timing have no diff.
- `rtk git diff --check` exited `0`.
- The final working-tree status preserves the pre-existing `.codex/config.toml` modification and generated context index; they were not cleaned or reset.

The hardening follow-up reran the same scoped audit after adding transactional aborts, body-lifecycle guards, wall-stick baselines, and bounded contact selection. It still found exactly one `move_and_slide()` call, in the motor, and no controller/state final body-velocity writer.
