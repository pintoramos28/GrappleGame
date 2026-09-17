# Story 1.4 pinned import/load evidence

Both checks used the pinned Godot 4.7.2 console through `rtk`, serialized.

```powershell
rtk <Godot_v4.7.2-stable_win64_console.exe> --headless --path . --import --quit-after 120
rtk <Godot_v4.7.2-stable_win64_console.exe> --headless --path . --quit-after 120
```

- Import check: exit code `0`; no parse or script-load error. Headless shutdown emitted the known renderer teardown noise: 1 dummy-texture RID, 1 CanvasItem RID, 4 ObjectDB instances, and 1 resource still in use.
- Normal load check: exit code `0`; no error or warning diagnostics in the captured tail.

No project settings, addon/dependency, scene, or resource files were changed by either process.

Final fix-pass editor-load check (2026-09-17) also exited `0`. While the MCP editor was open, the headless process emitted the known GDExtension copy/open noise for the editor-locked LimboAI and Terrain3D binaries, plus the standard renderer/resource teardown noise; it emitted no GDScript parse error. The restarted Godot AI MCP session loaded those extensions successfully and supplied the clean editor/runtime validation recorded in `mcp-verification.md`.
