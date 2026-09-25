# Pinned import and load (Task 9.1)

Commands (pinned Godot 4.7.2 console, operator-local; direct process capture):

1. `--headless --path . --import --quit-after 120` -> exit 0 (log:
   `final-import.log`; earlier post-write imports in `task1-7-green.log`
   region). The import registered `GrappleAnchorState` as a global class
   (`update_scripts_classes | GrappleAnchorState`) and generated the
   `.gd.uid` sidecars for the new scripts (`grapple_anchor_state.gd`,
   `test_grapple_moving_target_contract.gd`,
   `test_grapple_moving_target_integration.gd`,
   `test_grapple_moving_target_mcp.gd`). Exit-time noise unchanged (1 leaked
   RID / 1 retained resource).
2. `--headless --path . -s res://addons/gut/gut_cmdln.gd
   -gdir=res://tests/player -ginclude_subdirs -gexit` -> exit 0 (log:
   `recursive-gut-final.log`).

UID preservation: no existing `.gd.uid`, `.tscn`, or `.tres` dependency was
renamed or regenerated; `scenes/player.tscn` (`uid://u1u36ceuo8uj`),
`player_grappling_state.gd` (`uid://cjlui8t4vv7ha`), and all pre-existing
sidecars are untouched (the new files' sidecars are additive).

`rtk git diff --check` -> clean (no whitespace errors).
