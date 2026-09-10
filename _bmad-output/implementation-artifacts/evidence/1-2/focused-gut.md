# Story 1.2 focused GUT evidence

Canonical command run from the repository root with the operator-local pinned console executable substituted for the placeholder:

```powershell
$env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
```

The local GUT CLI help was checked before using the command; it accepted `-gdir`, `-ginclude_subdirs`, and `-gexit`. The pinned engine reported Godot `4.7.2.stable.official.ed1daf0bf`, and the suite reported GUT `9.7.1`.

Result: process exit `0`; 3 scripts, 21 tests, 21 passing tests, 677 asserts, and approximately 0.395 seconds on the final verification run. The suite covered the immutable frame, semantic action edges, movement semantics, focus/rearm, cursor recapture, mouse and pan accumulation, 60/120-step diagnostics, controller/HSM sequencing, initialization failures, disabled gating, and the no-direct-polling gameplay-surface audit.

The non-monotonic-step and invalid-initialization tests intentionally emitted `push_error` diagnostics; GUT classified those messages as expected errors and the tests passed. The process also reported 8 ObjectDB instances and 1 resource at shutdown. These are test/add-on teardown diagnostics after a fully passing run, not active test failures; they are recorded with the accepted Story 1.1 shutdown-diagnostic limitation rather than hidden.
