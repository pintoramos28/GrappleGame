# Pinned load check

Command (pinned Godot 4.7.2 console, operator-local):
`--headless --path . --quit-after 120` -> exit 0. Raw log: `pinned-load.log`
beside this file.

No `ERROR`, `SCRIPT ERROR`, or `WARNING` lines matched in `pinned-load.log`;
`res://main.tscn` loads and runs. The launch scene was also run live through
Godot AI MCP (`mcp-verification.md`, `traversal-smoke.md`).

## Preserved identities

- `scenes/player.tscn` uid `uid://u1u36ceuo8uj` unchanged; all existing
  `unique_id` node entries preserved (no scene nodes were added or removed).
- `scripts/player_grappling_state.gd` uid `uid://cjlui8t4vv7ha` and all
  pre-existing `.gd.uid` sidecars unchanged; no `.tscn`/`.tres` dependency was
  re-pointed (the only scene-file edits in the story are none - `player.tscn`
  and `main.tscn` are byte-unchanged).
- `project.godot` untouched (no new collision layers, interpolation/Jolt/main
  scene settings preserved).
