# Pre-change oracle (Task 9.1)

Command (pinned Godot 4.7.2 console, operator-local): `--headless --path . -s
res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit`.
Raw logs: `pre-change-oracle.log` (via `rtk` + pipeline) and
`pre-change-oracle-raw.log` (direct process, exit code captured) beside this
file.

| Scripts | Tests | Passing | Asserts | Time | Exit |
|---|---|---|---|---|---|
| 11 | 119 | 119 | 4,821 | 12.2 s | 0 |

This matches the documented Story 1.7/1.8 baseline exactly (119/119 tests,
4,821 asserts, exit 0). Exit-time teardown noise matches the recorded history
(8 leaked ObjectDB instances / 1 retained resource).

Note on exit codes: the `rtk` + `Tee-Object` pipeline wrapper reports
`Exited with code 1` even when Godot exits 0; the direct-process capture
(`GODOT_EXIT=0`) is authoritative. Story 1.8 final runs use the direct capture.
