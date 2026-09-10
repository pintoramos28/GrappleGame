# Story 1.1 Preflight Evidence

Capture time: `2026-09-09T21:45:20.1199670-04:00`

No software was installed, upgraded, or reconfigured during this capture.

## Repository identity

- Full `HEAD`: `317590fe882831fb7dc8117447313d733462e1f9`
- State: branch `main`, tracking `origin/main`, 10 commits ahead and 0 behind at capture time.
- Complete starting `git status --porcelain=v1 --untracked-files=all`: [`start-git-status.txt`](start-git-status.txt)
- Protected runtime snapshot: [`start-protected-surface-manifest.json`](start-protected-surface-manifest.json)

## Toolchain

- Godot editor: explicit operator-local `Godot_v4.7.2-stable_win64.exe`; the live editor session reports `4.7.2-stable (official)` and process inspection resolved the expected 4.7.2 executable.
- Godot console: explicit operator-local sibling `Godot_v4.7.2-stable_win64_console.exe`; complete raw `--version` output: `4.7.2.stable.official.ed1daf0bf`.
- Git: `git version 2.51.2.windows.1`.
- `uv`: `uv 0.11.16 (135a36367 2026-05-21 x86_64-pc-windows-msvc)`.

The approved pinned engine was resolved and verified before any Story-driven project launch. The editor was already open when execution began, but the connected session was stopped, ready, and using the approved build; no stale 4.6.3 metadata path was used.

## Local add-on versions and reproducibility

| Dependency | Local metadata source | Observed version | Git state / reproducibility |
|---|---|---|---|
| LimboAI | `addons/limboai/version.txt` | `v1.8.1` | Ignored by `.gitignore:5` (`/addons/`); no tracked file or submodule entry. Not reproducible from this repository alone. |
| Godot AI | `addons/godot_ai/plugin.cfg:6` | `4.0.4` | Ignored by `.gitignore:5`; no tracked file or submodule entry. Not reproducible from this repository alone. Version differs from the planning-context value `3.2.4`; recorded as `BASE-001`, not changed here. |
| GUT | `addons/gut/plugin.cfg:6` | `9.7.1` | Ignored by `.gitignore:5`; no tracked file or submodule entry. Not reproducible from this repository alone. |
| Terrain3D | `addons/terrain_3d/plugin.cfg:6` | `1.0.2` | Ignored by `.gitignore:5`; no tracked file or submodule entry. Not reproducible from this repository alone. |
| Phantom Camera | `addons/phantom_camera/plugin.cfg:6` | `0.11.0.2` | Ignored by `.gitignore:5`; no tracked file or submodule entry. Not reproducible from this repository alone. |
| GDQuest GDScript Formatter | `addons/GDQuest_GDScript_formatter/plugin.cfg:6` | `0.1.0` | Ignored by `.gitignore:5`; no tracked file or submodule entry. Not reproducible from this repository alone. |

`git ls-files --stage` returned no entries for the inspected add-on metadata, and `git submodule status` returned no submodules. The local add-ons are present but are not repository-vendored.

## Engine and launch configuration

| Setting | Serialized source | Effective value observed read-only in Godot 4.7.2 | Assessment |
|---|---|---|---|
| Main scene | `project.godot:14` | `res://main.tscn` | Observed baseline; unchanged. |
| Renderer | `config/features` contains `Forward Plus`; no explicit renderer method | `forward_plus` | Observed baseline; unchanged. |
| Windows rendering driver | `project.godot`, `rendering/rendering_device/driver.windows="d3d12"` | `d3d12` | Observed baseline; unchanged. |
| 3D physics backend | `project.godot`, `physics/3d/physics_engine="Jolt Physics"` | `Jolt Physics` | Observed baseline; unchanged. |
| Physics ticks per second | Not serialized | `60` (engine/default effective value) | Matches architecture target; unchanged. |
| Physics interpolation | Not serialized | `false` (engine/default effective value) | `BASE-002`: differs from architecture target `true`; reported without correction. |

Effective values were queried through the pinned editor's read-only Project Settings interface. No setting, scene, Resource, import source, UID, input binding, or add-on was saved or changed.
