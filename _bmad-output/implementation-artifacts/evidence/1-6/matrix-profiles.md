# Collision matrix and query profiles

## Decision: no new named collision layers

Existing named layers in `project.godot` stay exactly: `world_geometry`,
`player_body`, `enemy_body`, `player_hurtbox`, `enemy_hurtbox`. The grapple
matrix is expressible with them:

| Profile | Asset | `collision_mask_names` | Meaning |
|---|---|---|---|
| Candidate | `game/shared/physics/grapple_candidate.tres` | `world_geometry` | Ordinary collision geometry is default-grappleable (AC 2) |
| Occlusion | `game/shared/physics/grapple_occlusion.tres` | `world_geometry`, `enemy_body` | Marks surfaces that block without being default-acquirable (dynamic actors keep the prototype's block-don't-acquire behavior) |

- The single ray runs over `candidate | occlusion`; a body passing both is a
  candidate; a body carrying an explicit `Grappleable` direct child is a
  candidate regardless of layer so exceptional targets can answer for themselves.
- Player exclusion is unconditional (player RID), independent of the profile
  `exclude_body` field (contact semantics, untouched).
- Body/area colliders flags are the OR of both profiles; ray hit flags come from
  the candidate (acquisition) profile. No magic bitmask literals appear in
  gameplay code (masks resolve through `PhysicsQueryProfile.get_collision_mask()`
  from the named matrix).

## `PhysicsQueryProfile` ray generalization (Task 1 shared-profile variance)

Applied the documented preferred generalization, preserving every existing
contact bound and `tests/player/contact/test_player_contact_contract.gd`:

- New `QueryKind { CONTACT, RAY }` (default `CONTACT`, so `GroundProbe` /
  `WallProbe` and their assets are unchanged).
- Shape exemption: only `CONTACT` profiles require a non-null `shape`
  (`INVALID_SHAPE` preserved for them); `RAY` profiles carry no shape
  (no dummy shapes).
- Optional ray-relevant fields: `ray_hit_back_faces = true`,
  `ray_hit_from_inside = false` (mirroring documented ray defaults).
- `MAX_PROBE_DISTANCE_M = 4.0` / `MAX_SWEEP_DISTANCE_M = 4.0` and all other
  contact bounds are enforced unchanged; nothing silently raises them. Ray reach
  is stored nowhere in the profile - it comes only from
  `GrappleDefinition.max_grapple_length_m` (35 m), so the contact-probe bounds
  can never carry or limit the acquisition ray.

## Authored values

- `grapple_candidate.tres`: `profile_id = &"player.grapple.candidate"`,
  `query_kind = 1`, named mask only, `margin_m = 0.001`,
  `point_quantization_m = 0.001`, `normal_quantization = 0.001`.
- `grapple_occlusion.tres`: `profile_id = &"player.grapple.occlusion"`,
  otherwise identical quantization/flags.
- `grapple_definition.tres`: `definition_id = &"player.grapple.default"`,
  `max_grapple_length_m = 35.0`, `acquisition_tolerance_m = 0.005`,
  `target_query_profile = grapple_candidate.tres`, pull tuning verbatim
  (`48.0`, `8.0`, `53.333333`, `22.0`).
