# Story 1.3 pinned import and launch evidence

The pinned Godot console executable was resolved before runtime verification and reported `4.7.2.stable.official.ed1daf0bf`.

## Import scan

```powershell
rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --import --quit-after 120
```

Exit code: `0`. Godot completed filesystem scan, global class registration, GDExtension verification, and editor-layout import. The expected headless teardown reported one dummy-renderer RID, one CanvasItem, four ObjectDB instances, and one resource still in use; no import or parse failure occurred. The importer created the new `.gd.uid` sidecars for the motor, logging, and motor-test scripts.

## Retained launch scene

```powershell
rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --quit-after 120
```

Exit code: `0`. `res://main.tscn` loaded, the Godot AI helper registered, and the existing startup damage print (`Player took 6.6 physical damage. HP: 93.3/100.0`) appeared. No new runtime error was reported.

## Smoke classification

- Automated/headless: import, main-scene launch, focused input regression, and recursive player tests passed.
- Real-Jolt fixture: bounded collision results and transient wall-run/wall-stick scenarios passed in `tests/player/motor/test_player_motor_integration.gd`.
- Human-observed visual smoke: not claimed in this headless verification run. The accepted Story 1.1 limitations remain in force: `BASE-002` interpolation false, `BASE-004` fall recovery unavailable, `BASE-005` death recovery unavailable, `BASE-006` shutdown noise, and `BASE-007` fixture-only wall evidence.

The final post-hardening recursive player run also exited `0` with 45/45 tests passing and no import or parse failure. The MCP live-session gate is recorded separately in `mcp-verification.md`; no headless result is promoted to human-observed visual evidence.
