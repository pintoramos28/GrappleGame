# Import and Launch Classification

## Pinned import

The authoritative import used the explicit operator-local `Godot_v4.7.2-stable_win64_console.exe` with `--path . --import --verbose --log-file .../editor-import-single-process.log`. It exited `0`. The subsequently launched editor reported `ready`, its editor error buffer was empty, and a read-only ClassDB query confirmed `LimboHSM` was registered and instantiable.

An earlier retained attempt, [`editor-import.log`](editor-import.log), was made while the already-open editor still held LimboAI and Terrain3D temporary DLL copies and the Godot AI server socket. Its terminal output reported failed `~liblimboai...dll` and `~libterrain...dll` copies/GDExtension loads; the native log also records two server-socket bind failures. Execution was stopped safely, no project content was saved, the existing editor was closed, and the identical pinned import was rerun successfully as the single Godot process. This was a process-concurrency failure, not a missing local dependency; the successful rerun is the baseline result.

The successful import log contains three `HTTPRequest` `ERR_UNCONFIGURED` messages at import-only editor shutdown from the locally installed Godot AI tooling. They did not prevent import completion, class registration, scene loading, or play, and are tracked as `BASE-003` rather than changed here.

## Headless load

The explicit pinned console command used `--headless --path . --quit-after 120 --verbose --log-file .../main-headless.log`. It exited `0`, loaded `res://main.tscn` and all reported player/enemy scripts and Resources, registered the game helper, and produced no `ERROR`, `WARNING`, parse-error, or missing-resource lines. This is a load/parse/resource smoke result only, not a traversal pass.

## Interactive launch and controllability

The explicit console launcher opened the pinned editor, which is how the Windows console distribution hosts the paired GUI engine process. From that session, `project_run(mode=main, autosave=false)` launched `res://main.tscn`; the game helper reached `live`, `current_run_errors` was empty, and the fresh editor error buffer was empty. The full console/editor/game stream is retained in [`editor-console-session-stdout.log`](editor-console-session-stdout.log) and [`editor-console-session-stderr.log`](editor-console-session-stderr.log), with the engine log in [`editor-console-session.log`](editor-console-session.log).

The player was directly observed at `(0.0, 0.0993036255, 0.0)`, alive, then given the current `move_right` action for 30 physics frames. It ended at `(7.8744435310, 0.1003896445, 0.0)`, alive. Structured evidence is in [`main-interactive-observation.json`](main-interactive-observation.json). This establishes that the current player is controllable.

A separately retained direct-console diagnostic attempt is stored in `main-interactive.log`, `main-interactive-stdout.log`, and `main-interactive-stderr.log`. The scene loaded and ran, but the manually supplied remote debugger connection was refused, so that attempt is not used as the controllability proof.

## Classification

| Category | Authoritative observed result | Raw evidence | Classification / reference |
|---|---|---|---|
| Import | Completed with exit code 0; editor later reached idle/ready. | `editor-import-single-process.log` | Pass. Concurrent-process failure retained separately; no source remediation required. |
| Parse / script classes | Main player/enemy scripts loaded; `LimboHSM` registered and instantiable; editor error buffer empty. | `main-headless.log`, live ClassDB/editor observations | Pass. |
| Missing resources | No missing-resource output in successful import, headless, or authoritative interactive run. | Successful import/headless/interactive logs | Pass. |
| Scene load | `res://main.tscn` completed load headlessly and reached a live interactive scene tree. | `main-headless.log`, `main-interactive-observation.json` | Pass. |
| Runtime errors | No runtime error or debugger error in the authoritative interactive run. | `editor-console-session-stdout.log`, live editor/game log capture | Pass. |
| Relevant warnings | Repeated `RGB8`-to-`RGBA8` conversion warnings occurred on interactive stderr; import-only Godot AI shutdown emitted three `HTTPRequest` `ERR_UNCONFIGURED` messages. | `editor-console-session-stderr.log`, `editor-import-single-process.log` | `BASE-003`; pre-existing tooling/asset warnings, non-blocking for baseline play. |

The gameplay log also records the existing enemies damaging the player shortly after spawn. This is normal current scene behavior, not a launch error; smoke observations are therefore captured promptly after each fresh restart.
