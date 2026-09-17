# Story 1.4 recursive GUT evidence

The final fix-pass run was completed on 2026-09-17.

Command shape:

```powershell
rtk <Godot_v4.7.2-stable_win64_console.exe> --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
```

Final result: exit code `0`; 6 scripts, 57 tests, 57 passing, 2,808 assertions. The recursive run includes the unchanged input coverage and the expanded motor/semantic coverage. The known input/fixture teardown noise remained 8 leaked ObjectDB instances and 1 resource still in use; it did not affect the pass result.

For comparison, the implementation-start oracle was 45/45 tests and 967 assertions. The increase is the Story 1.4 semantic and preservation coverage.
