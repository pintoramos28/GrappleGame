# Collision matrix and query profiles

The named collision matrix preserves the observed numeric behavior:

| 3D layer | Name | Existing meaning used by this story |
|---:|---|---|
| 1 | `world_geometry` | player ground/wall probe eligibility; player mask 1 |
| 2 | `player_body` | player body layer |
| 3 | `enemy_body` | existing enemy body layer |
| 4 | `player_hurtbox` | existing player hurtbox layer |
| 5 | `enemy_hurtbox` | existing enemy hurtbox layer |

MCP `settings_get` confirmed `Jolt Physics`, 60 ticks per second, main scene
`res://main.tscn`, and `physics/common/physics_interpolation=true` after the
intentional Story 1.5 change. No other timing or render setting was changed.

## Scene-wired profiles

`res://game/shared/physics/ground_probe.tres` is a `GroundProbe` resource with
profile ID `player.contact.ground_probe`, named mask `world_geometry`, a
`SphereShape3D` radius `0.08`, offset `(0, 0.05, 0)`, down direction, probe
distance `0.30`, cap `0.35`, margin `0.001`, support distance `0.18`, and
candidate/report/scan limits `16/8/32`.

`res://game/shared/physics/wall_probe.tres` is a `WallProbe` resource with
profile ID `player.contact.wall_probe`, named mask `world_geometry`, a
`SphereShape3D` radius `0.12`, offset `(0, 0.90, 0)`, probe distance/cap
`0.80/0.80`, margin `0.001`, and candidate/report/scan limits `16/8/32`.
Both profiles enable overlap handling, collide with bodies, exclude the
player body, validate once, and lock authored values before gameplay use.

`scenes/player.tscn` wires both resources directly into `/Player/PlayerMotor`
and sets `contact_lifecycle_strict=true`. The player scene UID, node names,
HSM topology, and collision layer 2/mask 1 were preserved.
