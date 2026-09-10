# Preservation Audit

Captured 2026-09-09T22:52:28.6675647-04:00 through 2026-09-09T22:53:20.422752-04:00, after the pinned editor/game were stopped.

## Repository identity

- HEAD remained `317590fe882831fb7dc8117447313d733462e1f9` on `main`, tracking `origin/main` at `+10/-0`.
- The starting raw status contained 25 paths. The ending raw status contains 57 paths: all 25 starting entries remain, none disappeared, and 32 entries were added.
- Of the 32 added entries, 24 are the two authorized implementation metadata files plus 22 retained evidence files under `evidence/1-1/`.
- The other eight entries are `character_reference_views/*-fingers-separated.png` source images that appeared concurrently between the start and end captures. Story 1.1 did not create, edit, move, or delete those PNGs.
- The pinned final load generated eight matching `.import` sidecars for those concurrent PNGs. Those generated sidecars were removed before this terminal capture; the source PNGs and every pre-existing user path were preserved. Godot can regenerate the removed sidecars from the untouched PNGs.
- Every pre-existing modified/import-sidecar path has a last-write time before the starting capture, supporting its classification as pre-existing rather than Story-authored.

See `start-git-status.txt` and `end-git-status.txt` for the complete unscoped outputs.

## Protected runtime surface

- Scoped unstaged status: empty; exit `0`.
- Scoped unstaged diff: empty; exit `0`.
- Scoped staged diff: empty; exit `0`.
- `project.godot`, `main.tscn`, `.gitignore`, `scenes/`, `scripts/`, `resources/`, `materials/`, and `ai/` match their starting file counts and SHA-256 digests exactly.
- The closed-process raw `addons/` digest is `f0622aaceb443be884bb4537965956ded7155a3d9fcecf9b65e77d3ff648f026` versus starting `f81c76dbe9a005afb877623a92557ef03669a12136e0c245431cec36faca6301` at the same 1,360-file count. Controlled diagnosis showed this is solely the name/state swap of two pre-existing LimboAI/Terrain3D GDExtension loader shadows: while the editor was live, excluding the two `~...~RF*.TMP` shadows reproduced the starting 1,360-file digest exactly. With all `~` loader shadows excluded, the stable 1,358-file add-on source digest is `1e39b0cd01bc935573508f7154f8e7f7c6584557180771b14e3a8b4f54871f87`.
- Therefore no add-on source or runtime dependency byte changed. The raw aggregate difference is a process-state filename artifact, not a source mutation.

See `start-protected-surface-manifest.json`, `end-protected-surface-manifest.json`, and `end-scoped-git-checks.txt` for exact values.

## Generated cache

- `.godot/**` is ignored generated import/editor state and was excluded by design.
- At the terminal capture it contained 997 files; the newest was `.godot/editor/project_metadata.cfg`, written `2026-09-09T22:38:23.1314862-04:00`.
- No `.godot` path appears in Git status.

## Conclusion

PASS. Story-attributable durable changes are limited to the Story, sprint metadata, and retained evidence. No protected gameplay script, scene, Resource, UID-bearing source, project setting, input binding, add-on source, tutorial content, or other protected runtime file was changed.
