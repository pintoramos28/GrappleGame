# 60/120 Hz comparison (NFR4, Task 8.1)

The separating-target scenario (`_separation_scenario`) runs the same real-time
scenario at 60 Hz and the diagnostic 120 Hz rate inside
`test_separating_target_carries_the_player_only_at_the_maximum`. Values printed
by the test (`integration-pass4.log`):

| Fact | 60 Hz | 120 Hz | Delta | Tolerance |
|---|---|---|---|---|
| max pre-boundary drift (m) | 0.0 | 0.0 | 0.0 | 0.05 |
| boundary hit (s) | 1.1333 | 1.1250 | 0.0083 | 0.10 |
| boundary carry (m/s) | 4.9832 | 4.9834 | 0.0002 | 0.35 |
| max distance (m) | 35.000019 | 35.000008 | 0.000011 | 0.05 |
| still active | true | true | - | equal |

Sampled target velocity (Task 2.3, `test_anchor_velocity_finite_difference_is_rate_equivalent`
and the integration scenario): an 8 m/s authored translation reports the same
velocity at both rates (within 0.35 m/s), and a 12 m/s translation is measured
as 12.0 m/s at both rates in the contract suite - the finite difference is
displacement / `delta_seconds`, so it is rate-independent by construction.

Anchor-velocity derivation and the boundary carry therefore agree across rates
within the documented tolerances; see `limitations.md` for the one
rate-sensitive edge (discontinuity classification of jumps in the
rate-transition band).
