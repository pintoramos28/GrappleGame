# Integration matrix (AC 10, Task 8.1)

`tests/player/grapple/test_grapple_moving_target_integration.gd` - 14 tests,
all passing at the project's 60 Hz production rate; the two rate-sensitive
scenarios additionally run the same real-time scenario at the diagnostic
120 Hz rate inside the test (see `60-120-comparison.md`). Every scenario runs
through the real player scene (real `PlayerMotor`, real Jolt, engine-driven
physics frames, the typed input seam). Raw logs: `integration-pass4.log`,
`recursive-gut-final.log`.

| # | AC 10 scenario | Test | Observed |
|---|---|---|---|
| 1 | translation follow | `test_translation_follow_tracks_the_target_local_hit_point` | sampled anchor == `target.global_transform * offset` to 0.001 m over 20 moving steps; rope endpoint agrees every step |
| 2 | rotation about the local hit point | `test_rotation_follow_tracks_the_target_local_hit_point` | anchor tracks the rotated offset exactly (radius preserved to 0.001 m) over 12 rotating steps; grapple never ends |
| 3 | sampled target velocity | `test_sampled_target_velocity_reflects_target_motion_at_both_rates` | 8 m/s authored translation measured 8 m/s at 60 Hz and 120 Hz (within 0.35 m/s) |
| 4 | relative maximum-distance resolution | `test_separating_target_carries_the_player_only_at_the_maximum` | pre-boundary drift 0.0 m at both rates (no drag before the maximum); at the boundary the player receives exactly the anchor's separating radial motion (4.983 m/s for a 5 m/s separating target); max distance 35.00002 m |
| 4 | inward/tangential free | `test_inward_and_tangential_motion_stay_free_at_a_moving_boundary` | tangential 12 m/s preserved (> 8 m/s asserted), inward motion shrinks the tether below 35 m |
| 4 | approaching anchor no push | `test_approaching_target_never_pushes_the_player` | `boundary_carry_applied_mps == 0` every step; player velocity change <= 1.0 m/s |
| 5 | static-target regression | `test_static_target_regression_keeps_the_story_1_7_response` | frozen world anchor, zero target velocity, decaying pull active, one commit per step, definition unmodified |
| 6 | target removal (freed) | `test_freed_target_terminates_once_without_a_velocity_spike` | `TARGET_DESTROYED`, one `attachment_ended`, no grapple constraint/cap on the terminating step, velocity drift <= 1.0 m/s, locomotion leaves grappling |
| 6 | explicit invalidation | `test_explicit_invalidation_terminates_once_with_target_invalidated` | `TARGET_INVALIDATED`, exactly one event |
| 6 | scope mismatch | `test_scope_mismatch_terminates_once_with_scope_mismatch` | `SCOPE_MISMATCH` at the first sample after commit (provider `encounter.run_a` vs target `encounter.run_b`) |
| 7 | severe discontinuity | `test_severe_anchor_discontinuity_terminates_instead_of_snapping` | 10 m one-step jump -> `ANCHOR_DISCONTINUITY`; player displacement <= 1.0 m; one commit; no hold request |
| 8 | duplicate termination | `test_overlapping_termination_paths_commit_exactly_once` | release edge + death + target removal in one step: one terminal, one `attachment_ended`, repeated `_set_dead` re-commits nothing |
| 3 / Task 3.3 | no raycast while attached | `test_anchor_follow_repeats_no_target_selection_raycast_while_attached` | the targeting result's `source_physics_step` stays at the acquisition step across 15 attached moving steps (`query_count == 1` per evaluated step); after release the next step refreshes |
| 7.2 | presentation agreement | `test_rope_endpoint_follows_the_sampled_anchor_without_new_resets` | rope endpoint == sampled anchor every step; `grapple_visual_reset_count` stays 1 while visible; exactly one `reset_physics_interpolation()` call site in `player_controller.gd` |

Scope guard (AC 10 / Task 8.3): the scenario set and the code introduce no
encounter lifecycle/registry, no anchor-modification mechanics, and no rope
wrapping/elasticity/reeling/rope-segment simulation; the scope-identity
contract is an injectable provider only (asserted through the provider seam in
the scope-mismatch scenario).
