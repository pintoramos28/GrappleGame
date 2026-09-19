# Pinned import/load checks

The pinned Godot 4.7.2 console checks were run serially from the repository
root:

```text
rtk <pinned Godot 4.7.2 console> --headless --path . --import --quit-after 120
rtk <pinned Godot 4.7.2 console> --headless --path . --quit-after 120
```

Both processes exited with code `0`. The load check reached the game helper
and emitted only the existing player damage info line during startup.

The explicit import pass reported pre-existing local addon artifacts that
are outside Story 1.5: LimboAI's `~liblimboai.windows.editor.x86_64.dll` and
Terrain3D's `~libterrain.windows.debug.x86_64.dll` could not be opened, so
their GDExtension libraries were not loaded in that headless import process.
It also reported the existing renderer/ObjectDB/resource shutdown leak
messages. These did not produce a nonzero exit or a Story 1.5 source parse
failure and were not repaired as unrelated dependency work.
