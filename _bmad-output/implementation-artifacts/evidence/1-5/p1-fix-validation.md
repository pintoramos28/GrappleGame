# Story 1.5 P1 Fix Validation

Date: 2026-09-19

Scope: only the five Story 1.5 P1 findings were changed. P2, P3, evidence-gap, and deferred findings were not implemented.

## Source changes

- Reconstructed swept rest queries at the cast impact/unsafe transform before building sweep candidates.
- Converted every bounded overlap result into a candidate and added canonical shape-index tie-breaking for wall and ground selection.
- Applied the configured ground classification gate to authoritative body-floor normals while preserving the body normal as authoritative for the published frame.
- Retagged continuity-preserved wall candidates to the current physics step and advanced the continuity step during the configured loss window.
- Added hard profile maxima for probe/sweep distance, continuity-loss steps, candidate count, report count, and scan count, with defensive provider-side caps.

## Canonical GUT gate

Command:

```text
rtk proxy 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
```

- Focused contact suite: `11/11` tests, `89` assertions, exit code `0`.
- Recursive player suites: `68/68` tests, `3,086` assertions, exit code `0`.
- Expected invariant-path diagnostics and normal teardown/import noise remained expected.

## Godot AI MCP complementary gate

- Session: `testgame@e362124f09f388c2`.
- Preflight: session listed/activated; editor inspected; `res://scenes/player.tscn` hierarchy inspected; `/Player/PlayerMotor` confirmed to reference `player_motor.gd`, `ground_probe.tres`, and `wall_probe.tres`; both probe resources loaded with the authored `16/8/32` candidate/report/scan limits.
- Post-edit: filesystem scan settled; provider/profile symbol scans succeeded; no new editor log entries appeared after retained cursor `27`.
- Runtime smoke: live main scene contained `/Main/World/Player/PlayerMotor` with both probe resources; a frame-timed movement/jump input sequence completed; the run stopped cleanly. Runtime logs contained only the existing gameplay damage/death messages from the smoke route.
- MCP-native `test_run`: `0` suites found in `res://tests/`, with the expected cache warning; this project exposes recursive GUT suites rather than direct `McpTestSuite` adapters, so this result is not coverage of the GUT run.

## Final editor state

- Main scene open: `res://main.tscn`.
- Editor ready and play stopped.
- Retained editor diagnostics: `27`; new diagnostics after cursor `27`: `0`.
