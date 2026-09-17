# Story 1.4 physics-delta comparison

The semantic contract passes `delta_seconds = 1.0 / tick_rate` into every motor frame. `test_rate_resolution_matches_between_sixty_and_one_twenty_hz` runs equivalent one-second rate sequences at 60 and 120 Hz and compares the resulting velocity components within `0.0001` m/s. The final vectors matched, so the predecessor limits of `0.05 m/s`, `0.10 m`, and one 60 Hz transition step were not approached.

The explicit first-step characterization in `test_authored_deceleration_step_scales_with_physics_delta` starts from cardinal `10 m/s` and target zero:

| Authored context | Rate | Tick | Measured x velocity after one step | Reduction |
|---|---:|---:|---:|---:|
| Canonical main-scene value | 30 m/s² | 60 Hz | 9.500000 m/s | 0.500000 m/s |
| Canonical main-scene value | 30 m/s² | 120 Hz | 9.750000 m/s | 0.250000 m/s |
| Direct-player compatibility value | 20 m/s² | 60 Hz | 9.666667 m/s | 0.333333 m/s |
| Direct-player compatibility value | 20 m/s² | 120 Hz | 9.833333 m/s | 0.166667 m/s |

These values are `rate * delta_seconds` reductions, not raw frame-count or rendered-frame integrations. The test restores no global tick setting because it supplies the per-frame delta directly; no project tick configuration was changed.
