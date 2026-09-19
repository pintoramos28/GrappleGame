# Query and writer audit

The allowed engine-contact boundary is:

- `PlayerMotor`: owns the one movement commit and passes the bounded local
  collision result to the provider.
- `PlayerContactProvider`: the only player boundary that reads committed
  `CharacterBody3D` floor/wall facts, converts slide collisions, and issues
  ground/wall `PhysicsDirectSpaceState3D` overlap/sweep queries.
- `ContactDiagnosticSnapshot`: copies values already produced by that pass;
  it does not query or reclassify.

`PlayerMotorCommitResult` no longer exposes a `slide_collisions` array. It
exposes the matching immutable `ContactFrame` plus the existing velocity,
position, hold, success, rejection, and commit-count facts.

The controller and movement states now consume previous/current
`ContactFrame` accessors. An `rg` audit of the controller and all movement
states found no `is_on_floor()`, `is_on_wall()`, slide-collision enumeration,
wall probe/cast, or private wall-normal classification. The remaining
`StaticBody3D` and `intersect_ray()` references are the explicitly scoped
existing grapple-target ray path and are not contact-frame ownership.

The focused source audit is the seventh contact contract test and passes in
the canonical GUT run. Integration tests also assert one post-commit frame,
matching step/source step, one commit, bounded scan/report counts, and
nonzero configured probe counts on real player fixtures.
