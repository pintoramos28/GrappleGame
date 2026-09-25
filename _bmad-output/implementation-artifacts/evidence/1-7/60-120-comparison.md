# 60 Hz / 120 Hz equivalence (NFR4, AC 13, Task 6.3)

Test: `tests/player/grapple/test_grapple_boundary_integration.gd ->
test_boundary_scenario_matches_between_sixty_and_one_twenty_hz`. Raw log:
`60-120-comparison.log`. The scenario runs on engine-driven physics frames with
`Engine.physics_ticks_per_second` set to the tick rate under test, so the motor
delta and `move_and_slide()`'s physics delta are both `1 / tick_rate` (the same
real-time scenario at two rates).

Scenario: attach at ~10 m with a weak authored pull (`pull_multiplier = 0.1`),
seed outward momentum (`8 m/s` tangential + `20 m/s` outward), coast to the
authored 35 m maximum, observe the boundary, then release.

| Fact | 60 Hz | 120 Hz | Drift | Tolerance asserted |
|---|---|---|---|---|
| Attachment distance (m) | 10.25736 | 10.25676 | 0.0006 | (scenario sanity 5-15) |
| Boundary-hit time (s) | 1.30000 | 1.29167 | 0.0083 | 0.05 |
| Attachment duration at release (s) | 1.31667 | 1.30000 | 0.0167 | 0.05 |
| Max distance reached (m) | 35.00003 | 35.00001 | 0.00003 | 0.25 (also `<= 35.05`) |
| Correction steps | 2 | 2 | 0 | `> 0` each |
| Final radial velocity (m/s) | -0.0000016 | -0.0000010 | ~0 | `abs <= 2.0` |
| Final tangential velocity (m/s) | 2.91415 | 2.91335 | 0.0008 | (momentum preserved) |
| Submitted acceleration (m/s^2) | 0.80000 | 0.80000 | 0 | 0.05 |
| Release speed (m/s) | 2.91415 | 2.91335 | 0.0008 | 0.5 |
| Angular momentum (min-max over the run) | 101.99539-101.99550 | 101.96729-101.96738 | spread ~1e-6 relative | 2% of mean |
| Still active / definition unmodified | true / true | true / true | - | equal |

Interpretation: attachment duration, acceleration, boundary behavior (hit time,
maximum distance, correction count), and release velocity agree well inside the
documented tolerances at shipping 60 Hz and diagnostic 120 Hz, and angular
momentum is conserved to ~1e-6 relative through the pull and the boundary
clipping at both rates. Tolerances used (documented): 0.05 s for timing, 0.25 m
for the reached maximum, 0.05 m/s^2 for acceleration, 0.5 m/s for release speed,
2% of the mean for angular momentum.
