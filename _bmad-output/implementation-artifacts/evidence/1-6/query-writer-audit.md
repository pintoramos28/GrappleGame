# Query-writer audit

Source-level audit proving no grapple gameplay raycast call site remains outside
`GrappleTargetResolver` (the result's own counter cannot detect a stray second
raycast elsewhere). Search pattern across all `*.gd`:
`intersect_ray|PhysicsRayQueryParameters3D|PhysicsShapeQueryParameters3D|direct_space_state`.

| File | Hits | Verdict |
|---|---|---|
| `game/player/abilities/grapple/grapple_target_resolver.gd` | `direct_space_state`, `PhysicsRayQueryParameters3D.create`, `intersect_ray` (one call site, `_query_first_blocking_hit`) | The single authoritative grapple gameplay query (AC 14) |
| `game/player/locomotion/contact/player_contact_provider.gd` | `direct_space_state`, `PhysicsShapeQueryParameters3D` | Contact-domain shape probes (Story 1.5 ownership, untouched; no rays) |
| `scripts/enemy/enemy_vision_3d.gd` | `PhysicsRayQueryParameters3D.create`, `intersect_ray` | Enemy perception (LineOfSight query family), not grapple targeting; out of scope |
| `tests/player/contact/test_player_contact_contract.gd` | assertions forbidding query types in player surface scripts | Test-only |

No `intersect_ray`, `PhysicsRayQueryParameters3D`, or `PhysicsShapeQueryParameters3D`
remains in `scripts/player_controller.gd`, any movement state, the presentation
component (`game/player/abilities/grapple/presentation/grapple_target_marker.gd`
performs no physics queries), or `scripts/debug_grapple_telemetry.gd` (formats
the authoritative snapshot only). This is enforced by the existing
`test_player_surface_reads_only_the_shared_contact_frame` assertions (now
covering the whole controller file since `_get_grapple_ray_hit()` is deleted).

## Range-scalar audit (Task 5, second grep)

Pattern: `grapple_length|max_grapple|35.0` across `*.gd`, `*.tscn`, `*.tres`:

- `grapple_length`: zero runtime occurrences. Only the two negative assertions
  in `tests/player/motor/test_player_motor_integration.gd` mention the string.
  The previous occurrences (controller export; tutorial
  `player.set("grapple_length", 35.0)`) are removed.
- `max_grapple*`: only `GrappleDefinition.max_grapple_length_m` (definition asset
  + class) and the typed result/snapshot records that carry the copied result
  value (`max_grapple_length_m` fields) plus the telemetry key that reports it.
  Presenter (`GrappleTargetMarker`) and diagnostics hold no range scalar of their
  own; they read range from the authoritative result.
- `35.0` remains only where it is the authored definition value/test expectation,
  plus two unrelated non-grapple occurrences: `sun.rotation_degrees` in
  `scripts/levels/tree_grapple_tutorial.gd` and `arc_angle_degrees = 135.0` in
  `scenes/player.tscn`.
