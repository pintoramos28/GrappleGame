# Classification, selection, and continuity

Contact normals are normalized at the provider boundary. Ground candidates
require `normal.y >= 0.70`; ceiling-like candidates are rejected for
`normal.y <= -0.70`; wall candidates require `abs(normal.y) <= 0.20`.
Ground body facts have precedence after a valid post-commit floor normal is
read once. A probe can promote grounded state only under the named support
distance, separation, normal, and non-separating-motion predicates. A
non-promoting probe remains proximity evidence rather than a contradictory
ground fact. Invalid authoritative body normals fail publication.

After classification and geometric deduplication, wall selection uses the
documented deterministic ascending key:

```text
(-quantized_approach_opposition,
 quantized_time_of_impact,
 quantized_distance,
 continuity_penalty,
 evidence_rank,
 quantized_normal_xyz,
 quantized_point_xyz,
 surface_identity_key)
```

Evidence rank is committed collision/body evidence before current overlap
before sweep-only prediction. Authored semantic surface IDs sort before
missing authored IDs. Exact geometry/key ties collapse to one relationship.
Missing authored IDs use only a frame-local physics identity for
deduplication and are never promoted to persistent semantic identity.

Wall continuity is bounded by the profile's 25-degree angular tolerance,
0.20 m spatial tolerance, authored/frame identity policy, consecutive-step
validation, and two-step loss window. A stronger different candidate,
discontinuity, stale step, or exhausted loss window reports a switch/loss.
The provider computes approach-aware sweep distance from velocity and delta,
caps it by the profile, and pairs `cast_motion()` with overlap-capable
`intersect_shape()` handling. Consumers do not repeat these queries.

The focused contract test permutes candidate order, exercises exact ties,
normal gates, identity-less values, and the published lifecycle statuses.
