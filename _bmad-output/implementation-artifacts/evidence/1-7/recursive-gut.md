# Recursive GUT regression

Command (pinned Godot 4.7.2 console, operator-local): `--headless --path . -s
res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit`.
Raw log: `recursive-gut.log` beside this file.

| Scripts | Tests | Passing | Asserts | Time | Exit |
|---|---|---|---|---|---|
| 11 | 117 | 117 | 4,780 | ~14 s | 0 |

All tests passed ("---- All tests passed! ----"). This supersedes the pre-change
oracle (9 scripts, 97 tests, 3,824 asserts - `pre-change-oracle.md`): +2
scripts and +20 tests (the Story 1.7 boundary contract + integration suites,
the new motor constraint-kind test, and the presentation-purity guard) and
+956 assertions.

No regressions in `res://tests/player/input` (21), `res://tests/player/motor`
(37), `res://tests/player/contact` (11), or the pre-existing grapple targeting
suites (24); the pre-existing `test_player_surface_reads_only_the_shared_contact_frame`
and `test_player_surface_keeps_motion_commit_inside_motor` source-scan contracts
still pass against the retained controller, and
`test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band`
stays green with its extended scan list.

Expected `GameLog` invariant diagnostics were asserted in-test. Exit-time
teardown noise matches the pre-change oracle exactly (8 leaked ObjectDB
instances / 1 retained resource), so it is unchanged by Story 1.7.
