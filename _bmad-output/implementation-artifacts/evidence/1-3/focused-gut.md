# Story 1.3 focused verification

Verified on 2026-09-11 from the repository root with the operator-resolved pinned console executable:

`C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe`

The executable reported `Godot 4.7.2.stable.official.ed1daf0bf`; GUT reported `9.7.1`.

## Ordered commands

```powershell
rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
```

Both processes exited `0`.

## Results

- Story 1.2 input regression: 3 scripts, 21 tests, 21 passing, 677 assertions.
- Recursive player suite: 5 scripts, 45 tests, 45 passing, 967 assertions.
- Focused motor suite: 2 scripts, 24 tests, 24 passing, 290 assertions.
- Motor tests cover typed initialization, frame snapshots, one accepted MOVE/HOLD request, duplicate begin/commit rejection, stable consecutive diagnostic deduplication, invalid/non-monotonic input, bounded slide collisions, real-Jolt traversal IDs, the retained player scene coordinator, grounded/jump, dead, wall-run/jump, wall-stick hold/release, and the player/attack writer audits.
- The input run's non-monotonic-step, missing-action, and missing-dependency console diagnostics were classified by GUT as expected errors. The motor run's invariant diagnostics were likewise expected test cases, not failures.
- The recursive run ended with the known Godot teardown warning about 8 ObjectDB instances and 1 resource still in use; this did not affect the zero exit code and remains shutdown-noise classification `BASE-006`.

The final hardening rerun retained the same zero exit code after the invalid-body stale-result guard, grapple-landing cleanup, and warning-only local renames were added. It passed 45/45 recursively and 24/24 in the focused motor run; its expected console diagnostics include rejected initialization/submission/commit cases and the production duplicate-frame regression, which GUT classified as expected test-generated diagnostics.

The suite includes the existing input contract's 60/120-step frame-cardinality checks. No project physics or interpolation setting was changed for diagnostic runs.
