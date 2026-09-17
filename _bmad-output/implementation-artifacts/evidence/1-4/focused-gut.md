# Story 1.4 focused GUT evidence

The final fix-pass run was completed on 2026-09-17. All runs used the pinned Godot 4.7.2 console through `rtk`, from the repository root, with the Godot processes serialized.

## Input/command-frame suite

Command shape:

```powershell
rtk <Godot_v4.7.2-stable_win64_console.exe> --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
```

Result: exit code `0`; 3 scripts, 21 tests, 21 passing, 677 assertions. The known suite teardown reported 8 leaked ObjectDB instances and 1 resource still in use; no test failed.

## Motor/semantic suite

Command shape:

```powershell
rtk <Godot_v4.7.2-stable_win64_console.exe> --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/motor -ginclude_subdirs -gexit
```

Result: exit code `0`; 3 scripts, 36 tests, 36 passing, 2,131 assertions. Coverage includes the lifecycle/typed motor tests, real-Jolt/controller integration and preservation/static audit, and the semantic contract tests. Expected `GameLog` rejection diagnostics were asserted by the tests; no unexpected parse, runtime, or failing-test output occurred.

The motor suite covers exact seven-phase facts, deterministic source ordering, duplicate occurrence rejection, stale/no-frame lifecycle rejection, fatal conflict atomicity, hold baseline, collision bounds, source ownership, rate integration, and the three tuning contexts.
