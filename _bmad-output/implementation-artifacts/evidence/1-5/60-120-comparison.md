# 60/120 Hz comparison

The motor semantic suite passed the three rate-sensitive cases:

- `test_rate_resolution_matches_between_sixty_and_one_twenty_hz`
- `test_authored_deceleration_step_scales_with_physics_delta`
- `test_sustained_rate_sequence_matches_between_sixty_and_one_twenty_hz`

These cases use `delta_seconds = 1.0 / tick_rate` for one-second 60 Hz and
120 Hz sequences and compare semantic/rate outcomes rather than raw tick
counts or exact floating-point values. The inherited comparison tolerances
are `0.05 m/s` representative velocity drift, `0.10 m` position drift, and
transition alignment within one 60 Hz step.

The serialized project policy is interpolation enabled and the restored
shipping rate is 60 Hz. The MCP live Jolt smoke was performed at that
shipping rate. This evidence does not claim a second editor-run 120 Hz Jolt
session; the 120 Hz proof here is the deterministic motor comparison in the
passing GUT suite.
