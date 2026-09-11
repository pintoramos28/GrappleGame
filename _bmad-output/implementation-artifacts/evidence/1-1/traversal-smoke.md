# Traversal Smoke Evidence

Scene: `res://main.tscn`

Raw structured observations: [`traversal-smoke-observations.json`](traversal-smoke-observations.json)

Full editor/game stream: [`editor-console-session-stdout.log`](editor-console-session-stdout.log) and [`editor-console-session-stderr.log`](editor-console-session-stderr.log)

## Current controls read before testing

The serialized and live-read InputMap exposes `move_forward` = `W`, `move_back` = `S`, `move_left` = `A`, `move_right` = `D`, `jump` = `Space`, and `fire_grapple` = right mouse button. The current controller and all six movement-state scripts were read before testing. Discrete action pulses were injected at the named InputMap action corresponding to the recorded physical binding; held movement used frame-timed action input.

For traversal isolation only, the three enemy nodes were set to `PROCESS_MODE_DISABLED` in the running scene and the player was repositioned between observations. These transient values were never saved. Natural enemy processing was restored by a fresh launch for the death-recovery row.

The wall-run, wall-stick, and resulting wall-jump rows are `pass` observations of the current state machine from a runtime-only positioned and entry-velocity fixture. They do not prove that an ordinary player-controlled approach from the playable start reliably reaches those states; that limitation is recorded as `BASE-007`.

## Smoke matrix

| Scene | Behavior | Setup / target | Actual input | Expected baseline observation | Result | Observed result | Issue / remediation reference |
|---|---|---|---|---|---|---|---|
| `res://main.tscn` | Ground movement | Flat floor at runtime-only reset `(0, 0.1, 40)`; yaw `0`; enemies runtime-disabled | `W`, `S`, `A`, and `D` each held for 30 physics frames in separate resets | Controllable ground movement in every bound direction | `pass` | From the same origin: `W` ended at `z=32.126`, `S` at `z=47.874`, `A` at `x=-7.874`, and `D` at `x=7.874`; player remained grounded/alive. | none |
| `res://main.tscn` | Air steering | Same isolated floor setup | `Space` one-physics-frame pulse, then `W` held for 22 physics frames | Controllable aerial correction with carried commitment | `pass` | While airborne at `y=1.137`, forward position changed `z=40.000 → 39.555`; velocity was `(0, 0.907, -1.767)`. | none |
| `res://main.tscn` | Jump | Same isolated floor setup | `Space` / `jump` one-physics-frame pulse | Ground jump launches the player | `pass` | Ten physics frames after the pulse the player was airborne at `y=0.625` with vertical velocity `3.357 m/s`. | none |
| `res://main.tscn` | Grapple acquisition | Player at origin; yaw `-26.565°`; camera pivot `+20°`; forward ray aimed at `TallTowerA` | Right mouse / `fire_grapple` pressed and held | First eligible crosshair hit within current range attaches | `pass` | Ray hit `/Main/World/Buildings/TallTowerA` at `(8.75, 2.10, -17.5)`; grapple became active with a valid target. | none |
| `res://main.tscn` | Grapple hold | Continue the acquired `TallTowerA` grapple | Continue holding right mouse for 20 physics frames | Held grapple pulls toward the current attachment | `pass` | Player moved to `(0.842, 0.238, -1.942)`; target distance decreased `19.596 → 17.479 m`; pull speed reached `11.059 m/s`. | none |
| `res://main.tscn` | Grapple release | Same active grapple | Release right mouse; observe after 2 physics frames | Release ends the grapple | `pass` | `is_grappling=false` and target validity cleared. | none |
| `res://main.tscn` | Momentum after release | Same pull/release sequence | Release right mouse after the 20-frame pull | Useful velocity is retained after release | `pass` | Velocity remained `(4.468, 0.764, -10.546)`, speed `11.480 m/s`, two physics frames after release. | none |
| `res://main.tscn` | Wall run | Runtime-only placement `(10, 4, -0.25)` beside `WideBlockA` north face; entry velocity `(6, 0, 0)` | Hold `D` for 5 physics frames | Valid side-wall approach enters current wall-run behavior | `pass` | `is_wall_running=true`; wall normal `(0,0,1)`, run direction `(1,0,0)`, velocity `(6.4,0,0)`. Fixture-only observation; normal player-controlled entry was not established. | `BASE-007` limitation |
| `res://main.tscn` | Wall stick | Same wall approach; horizontal camera ray hits `WideBlockA`; valid entry speed | Hold `D` and right mouse | Grapple-assisted wall collision can enter current stick behavior | `pass` | On frame 12, grapple remained active and held, `is_wall_sticking=true`, normal `(0,0,1)`, and velocity was frozen to zero. Fixture-only observation; normal player-controlled entry was not established. | `BASE-007` limitation |
| `res://main.tscn` | Wall jump | Active wall run and, separately, active grapple wall stick beside `WideBlockA` | Pulse `Space` while directional input remains held | Jump exits wall interaction up and away | `pass` | Wall-run exit produced velocity `(6.467, 5.5, 8.0)`; wall-stick exit produced `(10.0, 5.5, 8.0)` and cleared grapple/stick state. This inherits the wall-entry fixture limitation. | `BASE-007` limitation |
| `res://main.tscn` | Landing recovery | Same isolated floor setup after a normal jump | Wait 60 physics frames to land, then hold `D` for 15 | Ordinary missed movement can continue after landing | `pass` | Player returned grounded/alive at `y=0.100`; follow-up `D` moved `x=0 → 0.642` with live velocity `3.0 m/s`. | none |
| `res://main.tscn` | Fall recovery | Runtime-only placement just beyond the 300 m floor's `+X` edge at `(151.5, 3, 0)` | No input for 180 physics frames | Current fall/recovery behavior is observable or unavailable | `not-currently-exercisable` | Player remained alive and unreset at `(151.737, -40.368, 0)`, falling at `-29.073 m/s`; no fall/checkpoint recovery path exists. | `BASE-004`: future recovery/checkpoint scope; not required by Story 1.2 |
| `res://main.tscn` | Death recovery | Fresh, unisolated main launch; natural melee enemy damage at spawn | Wait 540 physics frames; after death hold `D` + `Space` + right mouse for 60 frames | Current death/recovery behavior is observable or unavailable | `not-currently-exercisable` | Health reached `0`, `is_dead=true`; position/velocity stayed unchanged and grapple stayed inactive after all inputs. No player-death reset path exists. | `BASE-005`: future death/encounter reset scope; not required by Story 1.2 |

## Fixture boundary and follow-up assessment

`tree_grapple_tutorial.tscn` was not needed, opened, run, or saved. All measurements above are explicitly `main.tscn` observations and therefore use its `ground_deceleration=30` and `grapple_gravity_scale=0.0` instance overrides. The named floor/buildings and transient test placements are observation fixtures only; their layout, identities, tuning, or continued existence are not requirements for later migration Stories.

No behavior required to begin Story 1.2 failed or was unavailable: current directional actions and the jump/grapple edges needed as input-baseline evidence were all exercisable. `BASE-004` and `BASE-005` are honest future recovery candidates and were not repaired here. The wall interaction passes remain fixture-limited as described by `BASE-007`.
