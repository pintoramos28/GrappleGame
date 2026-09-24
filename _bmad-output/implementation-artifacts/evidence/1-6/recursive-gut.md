# Recursive GUT regression

Command (pinned Godot 4.7.2 console, operator-local): `--headless --path . -s
res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit`.
Raw log: `recursive-gut.log` beside this file.

| Scripts | Tests | Passing | Asserts | Time | Exit |
|---|---|---|---|---|---|
| 9 | 92 | 92 | 3,444 | ~1.3 s | 0 |

All tests passed. This supersedes the historical Story 1.5 baseline (68/68,
3,086 assertions across 7 scripts) with the two Story 1.6 suites added
(24 tests, 357 assertions). Expected `GameLog` invariant diagnostics were
asserted in-test. Exit-time teardown noise (leaked ObjectDB instances / one
retained resource) matches the pre-change baseline and is unchanged.

No regressions in `res://tests/player/input` (21), `res://tests/player/motor`
(36), or `res://tests/player/contact` (11); the pre-existing
`test_player_surface_reads_only_the_shared_contact_frame` and
`test_player_surface_keeps_motion_commit_inside_motor` source-scan contracts
still pass against the migrated controller.
