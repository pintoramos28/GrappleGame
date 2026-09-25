# Pre-change oracle (Story 1.7)

Captured before any Story 1.7 source change, on baseline commit
`db421eacac7e0d34a581202f6d7302e0b59fd72e` (HEAD at story start; working tree
contained only the untracked story file and `context-1-7.json`, plus the
sprint-status entry).

## Command (pinned Godot 4.7.2 console, operator-local)

`<godot-4.7.2>/Godot_v4.7.2-stable_win64_console.exe --headless --path . -s
res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit`

(`rtk` + `$env:TESTGAME_GODOT_CONSOLE` is the operator's usual wrapper; the env
variable was not exported in this session, so the pinned console binary was
invoked directly. Same binary, same GUT 9.7.1 runner.)

## Result

| Scripts | Tests | Passing | Asserts | Time | Exit |
|---|---|---|---|---|---|
| 9 | 97 | 97 | 3,824 | 1.435 s | 0 |

Matches the Story 1.6 final recursive baseline (97/97, 3,810 asserts; the +14
asserts are the 1.6 review-fix additions). Expected `GameLog` motor invariant
diagnostics were asserted in-test (e.g. `player.motor.no_active_motion_frame`).
Exit-time teardown noise unchanged from baseline: `WARNING: 8 ObjectDB instances
were leaked at exit`, `ERROR: 1 resources still in use at exit` (pre-existing
GUT teardown noise, identical to the Story 1.6 record).

Raw log: `pre-change-oracle.log` beside this file.

## Godot AI MCP preflight (read-only, before editing)

Session `testgame@e362124f09f388c2` (Godot `4.7.2-stable (official)`,
plugin/server 4.0.4, protocol 2): `session_manage(list)` -> one active session,
`readiness: ready`, `play_state: stopped`, current scene
`res://scenes/player.tscn`; `editor_state` -> `ready` / `stopped`,
`game_status.status = stopped`; `resource_manage(load)` of
`res://game/player/abilities/grapple/definitions/grapple_definition.tres` ->
`definition_id = player.grapple.default`, `max_grapple_length_m = 35`,
`acquisition_tolerance_m = 0.005`, `pull_initial_acceleration_mps2 = 48`,
`pull_min_acceleration_mps2 = 8`, `pull_acceleration_jerk_mps3 = 53.333333`,
`maximum_speed_mps = 22` (matches the authored `.tres` and the Task 1 source of
truth). Editor-log triage (`logs_read(source="editor")`): the ring buffer still
holds the known stale mid-edit parse errors for
`game/player/locomotion/contact/player_contact_provider.gd` /
`tests/player/contact/test_player_contact_contract.gd` and
`tests/test_grapple_targeting_mcp.gd` load churn - documented as stale history in
the story's authoring evidence; the live suites parse and pass (this oracle), so
they are not current defects and are not Story 1.7 regressions.

## Planning-revision check (artifact protocol)

All recorded planning digests in the story match the current files exactly
(`requirements.md 59d343e6...`, `epic-01-overview.md 1e6218be...`,
`epic-01-story-07.md e9f59ac3...`, `gdd.md d630bc8b...`,
`architecture.md 77b53704...`, `project-context.md 75a86909...`, epics manifest
`8a0a51a1...`). The story is fresh against the resolver inventory; no impact
review or Correct Course is required.
