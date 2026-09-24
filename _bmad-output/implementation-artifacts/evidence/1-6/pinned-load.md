# Pinned import and load checks

Commands (pinned Godot 4.7.2 console, operator-local):

1. `--headless --path . --import --quit-after 120` -> exit 0.
   Registered the ten new/changed global classes (`GrappleDefinition`,
   `GrappleTargetMarker`, `GrappleTargetResolver`, `Grappleable3D`,
   `GrappleRejection`, `GrappleTargetingDiagnosticSnapshot`,
   `GrappleTargetingResult`, `GrappleTargetResponse`, `GrappleTargetSeed`,
   `PhysicsQueryProfile`) with no script errors; generated `.gd.uid` sidecars for
   all new scripts. Warnings were limited to pre-existing CSV-translation locale
   noise from `_bmad` manifest imports.
2. `--headless --path . --quit-after 120` -> exit 0. No `ERROR`, `SCRIPT ERROR`,
   or `WARNING` lines matched in `pinned-load.log`; `res://main.tscn` loads and
   runs (also verified live through Godot AI MCP, see `mcp-verification.md`).
3. `rtk git diff --check` -> exit 0 (no whitespace errors).

Raw logs: `pinned-import.log`, `pinned-load.log` beside this file.

## Preserved identities

- `scenes/player.tscn` uid `uid://u1u36ceuo8uj` unchanged; all existing
  `unique_id` node entries preserved; new `GrappleTargetMarker` node added
  without disturbing existing node contracts.
- `scripts/player_grappling_state.gd` uid `uid://cjlui8t4vv7ha` and all existing
  `.gd.uid` sidecars unchanged; no `.tscn`/`.tres` dependency was re-pointed.
- `project.godot` untouched (no new collision layers, interpolation/Jolt/main
  scene settings preserved).
