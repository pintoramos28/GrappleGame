# Story 1.2 pinned-engine load evidence

Runs were serialized so the Godot import cache was not shared by concurrent processes.

Import/editor scan command:

```powershell
rtk <operator-local path to Godot_v4.7.2-stable_win64_console.exe> --headless --path . --import --quit-after 120
```

Result: exit `0`. The scan registered `PlayerInputSource`, completed filesystem and editor initialization, and emitted no project parse, resource-load, or scene-load failure. It reported the known editor/import shutdown diagnostics (1 dummy texture RID, 1 CanvasItem RID, 4 ObjectDB instances, and 1 resource at exit); these are tooling shutdown noise consistent with the accepted `BASE-006`/`BASE-003` classifications, not active gameplay errors.

Main-scene load command:

```powershell
rtk <operator-local path to Godot_v4.7.2-stable_win64_console.exe> --headless --path . --quit-after 120
```

Result: exit `0`. `res://main.tscn` loaded through the existing player scene, the new input source, and the existing player/enemy runtime scripts. The active run emitted the normal gameplay damage telemetry (`Player took 6.6 physical damage. HP: 93.3/100.0`) and no parse, resource, or scene-load error.

The interactive Story 1.1 GUI replay was not available through the current headless/UI surface. The protected baseline was therefore checked by the accepted Story 1.1 oracle, the focused synthetic input-boundary tests for the same controls/cursor flow, the unchanged traversal code/tuning audit, and the pinned main-scene load. No manual visual smoke result is claimed here.
