---
baseline_commit: 317590fe882831fb7dc8117447313d733462e1f9
---

# Story 1.1: Verify and Protect the Playable Traversal Baseline

Status: review

<!-- Validation is required for this baseline-protection Story before implementation begins. -->

## Story

As a game developer,
I want a verified and repeatable record of the current traversal build,
so that I can distinguish pre-existing behavior from regressions introduced during architecture migration.

## Acceptance Criteria

1. **Environment and repository baseline**
   - **Given** the existing repository checkout before Epic 1 migration begins
   - **When** the development environment is inspected
   - **Then** the resolved Godot executable reports the approved 4.7.2-stable build
   - **And** the available Git and `uv` versions, full repository revision, branch or detached state, complete starting working-tree state, and actual local dependency versions and tracking state are recorded without installing or upgrading anything.

2. **Pinned-runtime failure safety**
   - **Given** Godot 4.7.2-stable cannot be resolved or a required runtime dependency cannot load
   - **When** baseline verification is attempted
   - **Then** no scene, Resource, import source, UID, or project configuration is intentionally opened-and-resaved with another engine version
   - **And** the problem is recorded as a blocking issue or change candidate for separately scoped remediation before migration work begins.

3. **Engine and launch configuration**
   - **Given** the project is inspected before launch
   - **When** the current engine and launch configuration is recorded
   - **Then** `res://main.tscn`, Forward+, Jolt Physics, the effective physics tick rate, and the effective interpolation setting are identified as the observed baseline
   - **And** Story 1.1 does not change those settings or move the launch path
   - **And** any difference between the observed configuration and the architecture's fixed-60-Hz-with-interpolation target is reported rather than silently corrected.

4. **Import and launch baseline**
   - **Given** the pinned editor has completed its initial imports
   - **When** the current `res://main.tscn` is opened and run
   - **Then** the project reaches its current playable state with a controllable player
   - **And** the full fresh output is retained and pre-existing import, parse, missing-resource, scene-load, runtime-error, and relevant-warning results are classified separately from later migration results.
   - **And** a blocking failure is handled safely under AC 2 but leaves AC 4 and Story 1.1 incomplete until separately scoped remediation is completed and the baseline run passes.

5. **Traversal smoke matrix**
   - **Given** the current playable build
   - **When** the traversal smoke procedure is performed
   - **Then** ground movement, air steering, jumping, grapple acquisition, grapple hold, grapple release, momentum after release, wall running, wall sticking, wall jumping, and ordinary mistake recovery are each recorded as `pass`, `fail`, or `not-currently-exercisable`
   - **And** each row names its scene, setup, actual input, expected observation, observed result, and any issue or remediation reference
   - **And** failed or unavailable behavior needed by a later migration Story is not repaired inside Story 1.1.

6. **Disposable observation fixtures**
   - **Given** an existing scene is needed to exercise traversal during baseline capture
   - **When** `scenes/tree_grapple_tutorial.tscn` or another current scene is used
   - **Then** it serves only as disposable test content for observing the underlying traversal behavior
   - **And** its layout, lesson sequence, scripts, identifiers, tuning overrides, and continued existence are not treated as requirements for later Stories
   - **And** observations from scenes with different instance overrides are labeled separately rather than generalized as `main.tscn` behavior.

7. **Reproducible evidence record**
   - **Given** the baseline run and traversal smoke procedure are complete
   - **When** the evidence is documented under the project's implementation artifacts
   - **Then** the Baseline Evidence Record in this Story contains the capture date/time, full repository revision and branch state, complete starting working-tree state, engine and dependency versions, exact launch procedure, scene used, actions exercised, observed results, fresh logs, and known pre-existing issues
   - **And** retained raw logs are stored under `_bmad-output/implementation-artifacts/evidence/1-1/`
   - **And** the record makes no unsupported claim that automated tests passed, because the project has no established `tests/` suite.

8. **Non-mutation and repeatability guard**
   - **Given** baseline evidence has been recorded
   - **When** the ending worktree and protected runtime surface are compared with their starting snapshots
   - **Then** no gameplay script, scene, Resource, UID, project setting, input binding, add-on, tutorial content, or other runtime file has been intentionally changed by this Story
   - **And** generated `.godot/` cache activity is distinguished from tracked or source-asset changes
   - **And** the resulting evidence is sufficient for another developer or agent to repeat the same import, launch, and smoke procedure.

## Tasks / Subtasks

- [x] 1. Capture the preflight and starting state (AC: 1, 2, 3)
  - [x] Record an ISO-8601 capture timestamp, full `HEAD`, branch or detached state, and the complete `git status --porcelain=v1 --untracked-files=all` output. A clean worktree is not required; preserve all pre-existing user changes.
  - [x] Resolve the explicit Godot editor and console executables, capture the console executable's complete raw version string, and verify it is the approved 4.7.2 stable build before opening the project.
  - [x] Capture Git and `uv` versions without installing, upgrading, or altering configuration.
  - [x] Verify actual local add-on versions from their own metadata or version files and record where each value came from: LimboAI, Godot AI, GUT, Terrain3D, Phantom Camera, and GDQuest GDScript Formatter.
  - [x] Record whether each required dependency is tracked, ignored, or otherwise reproducible from the repository. Do not call an ignored local add-on “repository-vendored” without evidence.
  - [x] Capture a start-state manifest or equivalent repeatable snapshot for the protected runtime surface: `project.godot`, `main.tscn`, `.gitignore`, `scenes/`, `scripts/`, `resources/`, `materials/`, `ai/`, and `addons/`. Exclude generated `.godot/` cache files from the no-mutation assertion.
  - [x] Record `run/main_scene`, renderer/method, Windows rendering driver, physics backend, effective physics ticks per second, and effective physics interpolation. Distinguish serialized settings from engine defaults or runtime-reported values; use the pinned editor's read-only Project Settings view for effective values when they are absent from `project.godot`, and do not apply or save changes.

- [x] 2. Complete pinned-engine import and launch verification (AC: 2, 4)
  - [x] Create the evidence directory, then run the pinned console build's explicit `--import` path with verbose output and `--log-file` so initial import/class-registration output is retained before interactive testing.
  - [x] Launch the project with the explicit Godot 4.7.2 editor executable. Do not use the stale editor path recorded in ignored `.godot` metadata and do not save or resave project content.
  - [x] Treat initial imports as complete only after the editor's import/progress work is idle and required script/extension classes have either registered successfully or produced a captured blocking error.
  - [x] Capture a fresh verbose headless load of `res://main.tscn` as a parse/resource/scene-load smoke check; do not treat headless loading as a gameplay or traversal pass.
  - [x] Launch `res://main.tscn` interactively with the same pinned console build and capture the complete fresh output while determining whether the player is controllable.
  - [x] Classify import, parse, missing-resource, scene-load, runtime-error, and relevant-warning results in the evidence record, with links to the full raw logs. Do not silently filter output during capture.
  - [x] If the required runtime cannot load, stop runtime execution, record the blocker and proposed separately scoped remediation, and proceed only with the non-mutating evidence and diff audit that remain possible. Keep AC 4 and Story 1.1 incomplete; after remediation, rerun the pinned import, launch, and smoke procedure before claiming completion.

- [x] 3. Execute the traversal smoke procedure (AC: 5, 6)
  - [x] Read the current InputMap and controller behavior before testing; use the actual current bindings rather than future target bindings or assumptions.
  - [x] In `res://main.tscn`, record ground `W/A/S/D`, air steering, `Space` jump, right-mouse grapple acquisition/hold/release, momentum after release, wall run, grapple-assisted wall stick, wall jump, landing recovery, fall recovery, and death recovery as separate matrix rows where applicable.
  - [x] For every row, record the exact scene, setup or target geometry, input sequence, result enum, and concise observation. Use only `pass`, `fail`, or `not-currently-exercisable` for the result.
  - [x] Use `res://scenes/tree_grapple_tutorial.tscn` only if it supplies geometry needed for an observation. Label its results separately because it has different grapple-gravity and movement overrides, and do not save its generated editor preview.
  - [x] Record a blocking issue or change candidate for any behavior required by the next migration Story that fails or cannot be exercised. Do not repair gameplay, content, controls, or architecture in Story 1.1.

- [x] 4. Complete the Baseline Evidence Record (AC: 7)
  - [x] Replace every `TBD` field in the Baseline Evidence Record below with observed evidence or an explicit `not available` plus reason.
  - [x] Reference full raw logs under `_bmad-output/implementation-artifacts/evidence/1-1/`; keep the Story summary concise while preserving the original output needed to reproduce or diagnose the result.
  - [x] State explicitly that no automated suite was run unless a separately established suite actually exists at implementation time. Presence of the GUT add-on alone is not an automated-test pass.
  - [x] Separate facts observed during this execution from preflight intelligence recorded when the Story was authored.

- [x] 5. Audit the ending state and prove repeatability (AC: 8)
  - [x] Capture the complete unscoped ending `git status --porcelain=v1 --untracked-files=all`, the ending protected-surface snapshot, and the additional scoped Git status/diffs.
  - [x] Compare starting and ending snapshots so pre-existing dirty files are not mistaken for Story changes and changes made during this Story are not hidden by a dirty worktree.
  - [x] Confirm that only the implementation Story/evidence, retained raw logs, and sprint metadata changed. If a protected runtime file changed, restore nothing destructively: preserve user work, record the exact delta, and leave the Story incomplete pending separately scoped remediation.
  - [x] Have another developer or agent repeat the documented launch/smoke steps from the record, or perform a dry-run review proving all paths, commands, setup, inputs, and expected observations are present.

## Dev Notes

### Scope and Completion Boundary

- This Story verifies and protects existing behavior. It implements none of FR2–FR12 and does not establish final M0 acceptance; it records the current baseline against which later Epic 1 migration work is judged.
- **Runtime files to create, update, move, or delete: none.** Legitimate writable outputs are this implementation Story, its sprint-status metadata, and baseline evidence/log artifacts under `_bmad-output/implementation-artifacts/evidence/1-1/`.
- Do not introduce the target `game/` hierarchy, refactor traversal, repair imports, alter tuning, add tests/CI/export presets, or remove stale dependencies in this Story.
- “Protect” means a repeatable evidence record plus a start/end mutation guard. It does not mean implementing the later automated architecture-contract suite.
- A failed or unavailable behavior is an honest baseline result. Record a distinct issue/change candidate; do not silently change the canonical backlog or bundle remediation into this Story.

### Current Baseline Intelligence to Reverify

These observations were gathered read-only while authoring the Story. They guide the implementation but do not satisfy AC 1–8 until recaptured at implementation time.

- An exact local Godot console executable outside the repository was resolved while authoring this Story and reported `4.7.2.stable.official.ed1daf0bf`. No `godot` command is currently on `PATH`. Re-resolve it through operator-local shell configuration; do not commit a user-specific absolute executable path.
- Ignored editor metadata currently names a Godot 4.6.3 executable. It is stale local state, not authorization to open or resave the project with 4.6.3.
- At Story authoring time the repository was on `main` at `c8e7c0ccb3fbcaa3c66c556f281ffb76e6387ad4`; the whole worktree was dirty from planning-artifact work, while the scoped runtime surface was clean. Capture the actual start state again during implementation.
- `project.godot` currently identifies `res://main.tscn`, Godot feature line `4.7`, Forward+, Direct3D 12 on Windows, and Jolt. It does not explicitly serialize the physics tick-rate or interpolation settings; record effective values and flag any architecture mismatch without changing them.
- Current controls are `W/A/S/D`, `Space` jump, right mouse grapple, left mouse or `F` attack, `Esc` cursor release, mouse press recapture, and `F3` grapple telemetry. Verify them against the current InputMap and scripts before use.
- Locally present versions were observed as LimboAI `v1.8.1`, Godot AI `3.2.4`, GUT `9.7.1`, Terrain3D `1.0.2`, Phantom Camera `0.11.0.2`, and GDQuest GDScript Formatter `0.1.0`. Reverify each from local metadata.
- `/addons/` is currently ignored, with no tracked add-on files or submodules. This means local add-ons are not reproducible from Git despite earlier “repository-vendored” wording. Record this as a pre-existing dependency-integrity issue; do not fix or upgrade dependencies here.
- Godot AI and Terrain3D are enabled editor plug-ins. LimboAI and Jolt are required to load current gameplay. Terrain3D is optional to gameplay, Phantom Camera is deferred, Godot AI is development tooling, the formatter is editor-only, and GUT is a development/test dependency without an established suite.
- No `tests/` or `test/` directory, GUT runner configuration, CI workflow, or `export_presets.cfg` was found. Manual/headless smoke evidence is required and must not be labeled an automated-test pass.
- The saved user log from 2026-08-31 contains missing-class and parse failures but is stale. Capture a fresh post-import 4.7.2 run before classifying the current baseline.

### Traversal Behavior to Preserve and Observe

- `main.tscn` currently contains a large floor, nine building-scene instances, a player, one melee enemy, and two ranged enemies. Its player instance overrides ground deceleration to `30` and grapple gravity scale to `0.0`.
- The player uses `CharacterBody3D`, built-in `Camera3D`/`SpringArm3D`, and separate Limbo movement and attack HSMs. The current movement implementation has multiple state scripts calling `move_and_slide()`; this is known migration debt and must remain untouched in Story 1.1.
- Ground and air target speed is currently `10 m/s`; ground deceleration in `main.tscn` is `30 m/s²`, player-scene air deceleration is `5 m/s²`, and jump sets vertical velocity to `4.5 m/s`.
- Grapple selects the camera-forward first ray hit up to `35 m`, currently accepts only `StaticBody3D`, stores a fixed world attachment point, starts at `48 m/s²` pull, decays by about `53.33 m/s³` to `8 m/s²`, caps total velocity at `22 m/s`, and clears without rewriting velocity on release.
- Wall run uses airborne, non-grappling side probes at `0.8 m`, a near-vertical static surface, at least `1 m/s` horizontal speed, at most `18 m/s` total speed, and input alignment of at least `0.2`. Wall jump adds `5.5 m/s` upward and `8 m/s` away while retaining a positive along-wall component.
- Wall stick is distinct from wall run: it occurs after a grapple slide collision while grapple is held, freezes the current position/velocity, and exits on release or a wall jump.
- The tutorial scene is procedural `@tool` content and uses different instance values: grapple gravity scale `0.65` and the player-scene ground deceleration `20`, rather than `main.tscn` values. Its generated preview must not be saved.
- Current ordinary recovery may only be landing on the large floor or continuing after a missed maneuver. No traversal checkpoint/fall recovery or player-death reset path has been established; mark unavailable cases honestly.

### Required Runtime Dependencies

- Latest-version web research is intentionally not an upgrade input for this Story. The task is to verify the project's pinned local baseline; raw executable and add-on metadata are authoritative evidence, and any newer release remains out of scope.
- Required for current runtime load: the approved Godot 4.7.2 stable executable, Jolt as configured physics backend, and the locally installed LimboAI build used by current HSM/behavior resources.
- Required for this Story's environment capture: Git and `uv` must be reported if available, but the Story must not install them.
- Not runtime blockers for this Story unless the current launch proves otherwise: Terrain3D (optional gameplay implementation), Phantom Camera (deferred), Godot AI (development tooling), GDQuest formatter (optional editor tooling), and GUT (test tooling with no established suite).
- A required dependency's absence or class-registration failure blocks the playable smoke run, not the non-mutating evidence capture. Record it and separately scope remediation.

### Suggested RTK-Compliant Commands

Run from the repository root. Adapt only the resolved executable path; do not substitute another Godot version.

```powershell
$env:CLAUDE_CONFIG_DIR = 'C:\Users\pinto\.codex'
$env:GRAPPLEGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
$env:GRAPPLEGAME_GODOT_EDITOR = '<operator-local path to Godot_v4.7.2-stable_win64.exe>'
$godotConsole = $env:GRAPPLEGAME_GODOT_CONSOLE
$godotEditor = $env:GRAPPLEGAME_GODOT_EDITOR

rtk $godotConsole --version
rtk git --version
rtk uv --version
rtk git rev-parse HEAD
rtk git branch --show-current
rtk git status --porcelain=v1
rtk rg -n '^version=' addons/godot_ai/plugin.cfg addons/gut/plugin.cfg addons/phantom_camera/plugin.cfg addons/terrain_3d/plugin.cfg addons/GDQuest_GDScript_formatter/plugin.cfg
rtk proxy powershell -NoProfile -Command 'Get-Content -Raw -LiteralPath "addons/limboai/version.txt"'
rtk git check-ignore -v addons/gut/plugin.cfg addons/limboai/version.txt addons/terrain_3d/plugin.cfg
rtk $godotEditor --editor --path .
```

After the pinned editor has completed imports, capture a fresh load-only run and then interactive evidence. A headless result cannot satisfy the traversal matrix.

```powershell
rtk proxy powershell -NoProfile -Command 'New-Item -ItemType Directory -Force -Path "_bmad-output\implementation-artifacts\evidence\1-1" | Out-Null'
rtk proxy powershell -NoProfile -Command '& $env:GRAPPLEGAME_GODOT_CONSOLE --path "." --import --verbose --log-file "_bmad-output\implementation-artifacts\evidence\1-1\editor-import.log"'
rtk proxy powershell -NoProfile -Command '& $env:GRAPPLEGAME_GODOT_CONSOLE --headless --path "." --quit-after 120 --verbose 2>&1 | Tee-Object -FilePath "_bmad-output\implementation-artifacts\evidence\1-1\main-headless.log"'
rtk proxy powershell -NoProfile -Command '& $env:GRAPPLEGAME_GODOT_CONSOLE --path "." --verbose 2>&1 | Tee-Object -FilePath "_bmad-output\implementation-artifacts\evidence\1-1\main-interactive.log"'
rtk proxy powershell -NoProfile -Command '& $env:GRAPPLEGAME_GODOT_CONSOLE --path "." --scene "res://scenes/tree_grapple_tutorial.tscn" --verbose 2>&1 | Tee-Object -FilePath "_bmad-output\implementation-artifacts\evidence\1-1\tutorial-interactive.log"'
```

The final Git checks are necessary but are not sufficient by themselves when the starting tree was dirty; compare them with the saved starting snapshot and protected-surface manifest.

```powershell
rtk git status --porcelain=v1 --untracked-files=all
rtk git status --porcelain=v1 --untracked-files=all -- project.godot main.tscn scenes scripts resources materials ai addons .gitignore export_presets.cfg tests
rtk git diff --exit-code -- project.godot main.tscn scenes scripts resources materials ai addons .gitignore export_presets.cfg tests
rtk git diff --cached --exit-code -- project.godot main.tscn scenes scripts resources materials ai addons .gitignore export_presets.cfg tests
```

### Project Structure Notes

- The current prototype intentionally remains under root-level `main.tscn`, `scenes/`, `scripts/`, `resources/`, `materials/`, and `ai/` paths during this Story.
- The architecture's target `game/` structure is migration guidance for later Stories. Creating it or moving files in Story 1.1 would violate the baseline-protection boundary.
- Keep raw evidence under `_bmad-output/implementation-artifacts/evidence/1-1/`. Do not place logs, scripts, or credentials under runtime directories.
- Preserve Godot UIDs, scene/resource references, unique node IDs, InputMap entries, add-on contents, current instance overrides, and tutorial content exactly.
- Ignore normal generated `.godot/` cache changes when asserting tracked/source immutability, but do not use that exclusion to ignore source imports, `.import` sidecars outside `.godot/`, or project configuration changes.

### Project Context Rules

- Use Godot 4.7.2-stable, Forward+, Jolt, Windows, keyboard/mouse, fixed-step observations, and the current `res://main.tscn` launch path. Do not opportunistically upgrade the engine, add-ons, formatter, or dependencies.
- Keep the project runnable throughout staged migration. Existing prototype behavior is evidence, not authority for the target architecture.
- Do not create new C# gameplay code, abstractions, automated tests, CI, export setup, diagnostics frameworks, future services, or speculative infrastructure in this Story.
- Do not perform blind file moves, bulk restructuring, scene/resource resaves, UID changes, input remapping, tuning changes, or gameplay repairs.
- Use reproducible, risk-appropriate evidence: exact command/scene, setup, inputs, expected and observed result, fresh logs, and start/end state comparison.
- Use Godot AI only for read-only project/editor inspection if helpful; keep personal MCP configuration, executable paths, credentials, and tokens outside the repository.
- No UX package is present. This baseline Story does not add HUD or UX requirements and cannot claim UX readiness.

### Verification Standards

- This Story requires environment capture, fresh import/load evidence, an interactive human-observed traversal smoke matrix, and a protected-surface diff/hash audit.
- `pass` means the named behavior was directly observed in the named scene using the recorded input and produced the recorded expected baseline result. It does not mean the behavior meets final GDD tuning or architecture contracts.
- `fail` means the behavior was exercisable but did not produce the expected current baseline result; attach the relevant log/observation and a separate issue reference.
- `not-currently-exercisable` means setup, geometry, dependency, or missing behavior prevented a meaningful observation; record the precise reason and separate remediation.
- Capture all launch output first, then classify relevant warnings in the summary. Do not treat stale logs as current evidence.
- Do not run or report a GUT pass merely because GUT exists locally. If no suite exists, state “automated tests not run: no established suite.”
- A successful Story validates only the repeatability and protection of the observed baseline. It does not accept M0, resolve OD-009, or prove target-architecture conformance.

### Requirements Traceability

- The bounded context pack assigns FR2–FR12 because they are Epic 1 requirements. Story 1.1 observes their existing baseline only; later Stories implement and validate the target contracts.
- Direct quality rationale: NFR1 (pinned Windows/Godot/Forward+/Jolt baseline), NFR3 (fixed-step/render independence), NFR21 (risk-appropriate evidence), NFR22 (prototype-content sufficiency), NFR23 (runnable staged migration), and NFR24 (no speculative infrastructure or opportunistic upgrades).
- Additional architecture obligations applied here: run the prototype before restructuring, preserve `main.tscn`, protect UIDs/dependencies during staged migration, and record pre-existing import/parse/runtime failures separately.

### References

- [Source: `_bmad-output/planning-artifacts/epics/epic-01-story-01.md` — `grapplegame.story.1.1`, updated 2026-09-09, SHA-256 `97da50250d46fdfcfb4b5223a61cc9bf9be6fd8a85ae44460b5c0b73eecb2079`](../planning-artifacts/epics/epic-01-story-01.md)
- [Source: `_bmad-output/planning-artifacts/epics/epic-01-overview.md` — `grapplegame.epics.1`, updated 2026-09-09, SHA-256 `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168`](../planning-artifacts/epics/epic-01-overview.md)
- [Source: `_bmad-output/planning-artifacts/epics/requirements.md` — `grapplegame.epics.requirements`, updated 2026-09-09, SHA-256 `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b`](../planning-artifacts/epics/requirements.md)
- [Source: `_bmad-output/planning-artifacts/gdd.md` — `grapplegame.gdd` v1.2.0, updated 2026-09-09, SHA-256 `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156`](../planning-artifacts/gdd.md)
- [Source: `_bmad-output/planning-artifacts/architecture.md` — `grapplegame.architecture` v1.0, updated 2026-09-09, SHA-256 `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080`](../planning-artifacts/architecture.md)
- [Source: `_bmad-output/project-context.md` — `grapplegame.project-context`, updated 2026-09-09, SHA-256 `924f967d83ac664c1352f27bb89ef91cef4d4ae765746d379c77cfe91eb608d9`](../project-context.md)
- [Bounded context pack: `_bmad-output/.artifact-index/context-1-1.json`](../.artifact-index/context-1-1.json)
- Epic package lineage SHA-256: `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`; manifest SHA-256: `8a0a51a1d4915b4aa75a7f96a427d03200a2fe0b4538ac061c9ab19afe045d15`; index SHA-256: `0f7d52a19df28d0bd2d1c934fe2652f2590e043f1f39102a8cdaa63dc79dbc77`.
- The GDD remains `needs-decisions`; its exact `implementation_scope_ready` declaration permits Epic 1 implementation-start only. Story 1.1 cannot claim milestone acceptance or broaden that exception.

## Baseline Evidence Record

> Complete during implementation. A remaining `TBD` does not satisfy AC 7 unless replaced by `not available` with a precise reason and remediation reference.

### Capture Identity

- Capture date/time (ISO-8601 with timezone): `2026-09-09T21:45:20.1199670-04:00`
- Full repository commit: `317590fe882831fb7dc8117447313d733462e1f9`
- Branch or detached state: branch `main`, tracking `origin/main`, capture-time divergence `+10/-0`
- Starting working-tree snapshot: [`evidence/1-1/start-git-status.txt`](evidence/1-1/start-git-status.txt) (complete unscoped porcelain-v1 output; pre-existing changes preserved)
- Ending working-tree snapshot: [`evidence/1-1/end-git-status.txt`](evidence/1-1/end-git-status.txt) (complete unscoped porcelain-v1 output captured after the editor/game stopped)
- Start/end comparison artifact or method: deterministic protected-surface SHA-256 manifests, complete unscoped status comparison, and scoped staged/unstaged Git checks; see [`evidence/1-1/preservation-audit.md`](evidence/1-1/preservation-audit.md)

### Toolchain and Dependency Versions

| Item | Resolved command/metadata source (redact user-specific path) | Raw observed version | Git tracking/reproducibility note |
|---|---|---|---|
| Godot editor | Explicit operator-local `Godot_v4.7.2-stable_win64.exe`; live-session metadata and process inspection | `4.7.2-stable (official)` | External tool, not tracked in this repository; explicit path intentionally redacted. |
| Godot console | Explicit operator-local `Godot_v4.7.2-stable_win64_console.exe --version` | `4.7.2.stable.official.ed1daf0bf` | External tool, not tracked in this repository; paired Windows console/GUI build. |
| Git | `git --version` | `git version 2.51.2.windows.1` | N/A |
| `uv` | `uv --version` | `uv 0.11.16 (135a36367 2026-05-21 x86_64-pc-windows-msvc)` | N/A |
| LimboAI | `addons/limboai/version.txt` | `v1.8.1` | Ignored by `/addons/`; no tracked file/submodule; not reproducible from Git alone (`BASE-001`). |
| Godot AI | `addons/godot_ai/plugin.cfg:6` | `4.0.4` | Ignored/untracked; differs from planning-context `3.2.4`; not changed (`BASE-001`). |
| GUT | `addons/gut/plugin.cfg:6` | `9.7.1` | Ignored/untracked; presence does not establish a test suite (`BASE-001`). |
| Terrain3D | `addons/terrain_3d/plugin.cfg:6` | `1.0.2` | Ignored/untracked; not reproducible from Git alone (`BASE-001`). |
| Phantom Camera | `addons/phantom_camera/plugin.cfg:6` | `0.11.0.2` | Ignored/untracked; not reproducible from Git alone (`BASE-001`). |
| GDQuest GDScript Formatter | `addons/GDQuest_GDScript_formatter/plugin.cfg:6` | `0.1.0` | Ignored/untracked; not reproducible from Git alone (`BASE-001`). |

### Engine and Launch Configuration

| Setting | Serialized source | Effective observed value | Match / issue reference |
|---|---|---|---|
| Main scene | `project.godot:14`, `run/main_scene="res://main.tscn"` | `res://main.tscn` | Matches observed baseline and remained unchanged. |
| Renderer | `config/features` contains `Forward Plus`; method not explicitly serialized | `forward_plus` from pinned editor Project Settings | Forward+ baseline; unchanged. |
| Windows rendering driver | `rendering/rendering_device/driver.windows="d3d12"` | `d3d12` | Matches Windows baseline; unchanged. |
| 3D physics backend | `physics/3d/physics_engine="Jolt Physics"` | `Jolt Physics` | Matches approved backend; unchanged. |
| Physics ticks per second | Not serialized | `60` from pinned editor Project Settings (effective engine default) | Matches architecture target; unchanged. |
| Physics interpolation | Not serialized | `false` from pinned editor Project Settings (effective engine default) | Differs from architecture target `true`; report-only `BASE-002`. |

### Import and Launch Result

- Exact editor import procedure and completion signal: `<Godot-4.7.2-console> --path . --import --verbose --log-file _bmad-output/implementation-artifacts/evidence/1-1/editor-import-single-process.log`; exit `0`, followed by editor `readiness=ready`, empty editor error buffer, and instantiable `LimboHSM` ClassDB result
- Exact headless load command/result: `<Godot-4.7.2-console> --headless --path . --quit-after 120 --verbose --log-file _bmad-output/implementation-artifacts/evidence/1-1/main-headless.log`; exit `0`; `res://main.tscn` completed resource/script load with no error/warning matches
- Final regression load/result: repeated the same pinned 120-frame headless command after interactive capture; exit `0`, `res://main.tscn` completed load, and no error/warning patterns matched in [`final-headless.log`](evidence/1-1/final-headless.log)
- Exact interactive launch command/result: `<Godot-4.7.2-console> --editor --path . --verbose --log-file .../editor-console-session.log`, then Godot AI `project_run(mode=main, autosave=false)`; game helper reached `live`, current-run errors `[]`, editor errors `[]`; the Windows console launcher used its paired same-build GUI engine process
- Scene exercised: `res://main.tscn`; `tree_grapple_tutorial.tscn` was not needed, opened, run, or saved
- Player controllable: yes — `D` / `move_right` for 30 physics frames moved the live player from `x=0.000` to `x=7.874` while alive
- Automated tests: **not run: no established `tests/` or `test/` suite exists.** A fresh repository file search also found no CI workflow or `export_presets.cfg`; the GUT add-on alone is not an automated-test pass.

| Output category | Observed summary | Raw log reference | Pre-existing issue / remediation reference |
|---|---|---|---|
| Import | Single-process pinned import exited `0`; editor subsequently became idle/ready. | [`editor-import-single-process.log`](evidence/1-1/editor-import-single-process.log) | First concurrent attempt hit locked temporary extension DLLs/server socket; stopped safely and passed after closing the other editor. Procedure hazard only. |
| Parse / script classes | Main player/enemy scripts loaded; `LimboHSM` registered/instantiable; authoritative editor error buffer empty. | [`main-headless.log`](evidence/1-1/main-headless.log), [`import-and-launch-classification.md`](evidence/1-1/import-and-launch-classification.md) | none |
| Missing resources | No missing-resource output in successful import, headless load, or authoritative interactive launch. | Successful import/headless/interactive logs | none |
| Scene load | `res://main.tscn` completed headless load and produced a live 130-node runtime tree with player/HSMs/enemies. | [`main-headless.log`](evidence/1-1/main-headless.log), [`main-interactive-observation.json`](evidence/1-1/main-interactive-observation.json) | none |
| Runtime errors | No runtime/debugger errors in authoritative launch or final natural-death run. Two abandoned MCP eval snippets produced transient generated-script errors; subsequent clean runs passed and no project script was involved. | [`editor-console-session-stdout.log`](evidence/1-1/editor-console-session-stdout.log), [`traversal-smoke-observations.json`](evidence/1-1/traversal-smoke-observations.json) | Capture-harness attempts classified separately; no remediation to runtime files. |
| Relevant warnings | Interactive stderr repeats RGB8-to-RGBA8 conversion warnings; import-only Godot AI shutdown emitted three `HTTPRequest ERR_UNCONFIGURED` messages. Neither blocked import/load/play. | [`editor-console-session-stderr.log`](evidence/1-1/editor-console-session-stderr.log), [`editor-import-single-process.log`](evidence/1-1/editor-import-single-process.log) | `BASE-003`; separately investigate only if later tooling/asset evidence shows impact. |

### Traversal Smoke Matrix

| Scene | Behavior | Setup / target | Actual input | Expected baseline observation | Result | Observed result | Issue / remediation reference |
|---|---|---|---|---|---|---|---|
| `res://main.tscn` | Ground movement | Flat floor reset `(0,0.1,40)`; enemies transiently disabled | `W/S/A/D`, each held 30 physics frames | Controllable ground movement | `pass` | Ended `7.874 m` in each expected cardinal direction; grounded/alive. | none |
| `res://main.tscn` | Air steering | Same isolated floor setup | `Space` pulse, then `W` held 22 frames | Controllable aerial correction with carried commitment | `pass` | Airborne at `y=1.137`; `z=39.555`, velocity `z=-1.767 m/s`. | none |
| `res://main.tscn` | Jump | Same isolated floor setup | `Space` one-frame action pulse | Ground jump launches the player | `pass` | Airborne at `y=0.625`, vertical velocity `3.357 m/s` after 10 frames. | none |
| `res://main.tscn` | Grapple acquisition | Origin; camera aimed at `TallTowerA` hit `(8.75,2.10,-17.5)` | Press/hold right mouse | First eligible crosshair hit within current range attaches | `pass` | Active valid target `/Main/World/Buildings/TallTowerA`. | none |
| `res://main.tscn` | Grapple hold | Continue same attachment | Hold right mouse 20 frames | Held grapple pulls toward the current attachment | `pass` | Distance fell `19.596→17.479 m`; pull speed `11.059 m/s`. | none |
| `res://main.tscn` | Grapple release | Same active grapple | Release right mouse | Release ends the grapple | `pass` | Grapple and target validity cleared within 2 frames. | none |
| `res://main.tscn` | Momentum after release | Same pull/release sequence | Release after 20-frame pull | Useful velocity is retained after release | `pass` | Velocity `(4.468,0.764,-10.546)`, speed `11.480 m/s`, after release. | none |
| `res://main.tscn` | Wall run | Beside `WideBlockA` north face; entry `(6,0,0)` | Hold `D` 5 frames | Valid side-wall approach enters current wall-run behavior | `pass` | Running true; normal `+Z`, direction `+X`, vertical velocity `0`. | none |
| `res://main.tscn` | Wall stick | Same wall; horizontal grapple ray hits face | Hold `D` + right mouse | Grapple-assisted wall collision can enter current stick behavior | `pass` | By frame 12: grapple/stick true, held inputs true, velocity frozen to zero. | none |
| `res://main.tscn` | Wall jump | Active run and separately active stick | Pulse `Space` while `D` held | Jump exits wall interaction up and away | `pass` | Run exit `(6.467,5.5,8)`; stick exit `(10,5.5,8)`, grapple/stick cleared. | none |
| `res://main.tscn` | Landing recovery | Normal isolated jump | Wait 60 frames, then hold `D` 15 | Ordinary missed movement can continue after landing | `pass` | Grounded/alive; follow-up movement changed `x=0→0.642`. | none |
| `res://main.tscn` | Fall recovery | Runtime-only placement beyond floor edge `(151.5,3,0)` | No input 180 frames | Current fall/recovery behavior is observable or unavailable | `not-currently-exercisable` | No reset; at `y=-40.368`, falling `-29.073 m/s`, alive. | `BASE-004`; future checkpoint/recovery scope |
| `res://main.tscn` | Death recovery | Fresh unisolated launch; natural enemy damage | Wait 540 frames, then hold `D+Space+RMB` 60 | Current death/recovery behavior is observable or unavailable | `not-currently-exercisable` | Health `0`, dead state persisted; position/velocity unchanged, grapple inactive. | `BASE-005`; future death/encounter-reset scope |

### Known Pre-existing Issues and Separately Scoped Remediation

| Issue ID / candidate | Evidence | Impact on later Story | Required next action | Owner / status |
|---|---|---|---|---|
| `BASE-001` | Every inspected add-on is ignored/untracked with no submodule; Godot AI is locally `4.0.4` versus planning-context `3.2.4`. | Dependency provenance and another checkout's reproducibility are not guaranteed. | Separately define/install-lock dependency provenance; reconcile planning context before relying on the newer tooling version. | Unassigned / open, non-blocking for Story 1.2 on this machine |
| `BASE-002` | Effective `physics/common/physics_interpolation=false`; setting absent from `project.godot`. | Differs from approved target and must not be mistaken for a regression introduced later. | Change only in a separately scoped migration Story with before/after validation. | Unassigned / open, report-only |
| `BASE-003` | Three Godot AI import-shutdown `HTTPRequest ERR_UNCONFIGURED` messages and repeated RGB8 conversion warnings. | Adds noise to clean-log comparisons; no observed load/play failure. | Investigate tooling/asset source separately only if warnings persist as actionable migration noise. | Unassigned / open, non-blocking |
| `BASE-004` | Beyond-floor observation fell below `y=-40` without reset. | No current fall/checkpoint recovery behavior to preserve or compare. | Address in later level/checkpoint/recovery scope; do not repair in Epic 1.1. | Unassigned / deferred |
| `BASE-005` | Natural death persisted after movement/jump/grapple inputs. | No current player death/restart behavior to preserve or compare. | Address in later health/encounter reset scope; do not repair in Epic 1.1. | Unassigned / deferred |

### Preservation Audit

- Protected-surface starting manifest/reference: [`evidence/1-1/start-protected-surface-manifest.json`](evidence/1-1/start-protected-surface-manifest.json), 1,473 files, aggregate `83cb9880b908e06dfa24737db3e4349d58ee5b6e81ab080a239b40ae43cb36ce`
- Protected-surface ending manifest/reference: [`evidence/1-1/end-protected-surface-manifest.json`](evidence/1-1/end-protected-surface-manifest.json), 1,473 raw files; eight of nine targets match start exactly, while `addons/` differs only by the process-state names of two pre-existing GDExtension loader shadows
- Scoped Git diff result: [`evidence/1-1/end-scoped-git-checks.txt`](evidence/1-1/end-scoped-git-checks.txt) records empty scoped status, unstaged diff, and staged diff, all exit `0`
- Generated `.godot/` activity excluded and classified: `.godot/**` contained 997 ignored cache files at the terminal capture; newest was `.godot/editor/project_metadata.cfg` at `2026-09-09T22:38:23.1314862-04:00`
- Runtime/source/add-on changes introduced by Story 1.1: none. The stable 1,358-file add-on source digest is `1e39b0cd01bc935573508f7154f8e7f7c6584557180771b14e3a8b4f54871f87`; a controlled live loader-equivalent snapshot reproduced the exact starting add-on digest. Full classification is in [`evidence/1-1/preservation-audit.md`](evidence/1-1/preservation-audit.md)
- Evidence/workflow artifacts introduced by Story 1.1: this Story file, sprint-status metadata, and the 22 retained files under `_bmad-output/implementation-artifacts/evidence/1-1/`. Eight concurrent `character_reference_views/*-fingers-separated.png` files were preserved and classified separately; generated sidecars from the final load were removed without touching those PNGs
- Repeatability review result: `pass`; [`evidence/1-1/repeatability-review.md`](evidence/1-1/repeatability-review.md) confirms all paths, commands, setup, inputs, expected observations, and result evidence are present

### Evidence Provenance

All values above were observed during this implementation execution from commands, local metadata, the pinned editor, or live runtime state. Authoring-time intelligence in Dev Notes was used only to choose what to reverify; none of its version, worktree, configuration, launch, or traversal statements was counted as execution evidence without recapture.

## Dev Agent Record

### Agent Model Used

OpenAI Codex (GPT-5)

### Implementation Plan

- RED: treat every missing baseline datum, raw log, smoke observation, and preservation comparison as an unsatisfied verification check; do not create an automated suite where none exists.
- GREEN: capture each requirement with pinned-engine, read-only commands and interactive observations, retaining raw output under `evidence/1-1/`.
- REFACTOR: consolidate observed facts into the Baseline Evidence Record, classify issues separately, and prove the protected runtime surface is byte-identical at the end.

### Debug Log References

- `_bmad-output/implementation-artifacts/evidence/1-1/preflight.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/start-git-status.txt`
- `_bmad-output/implementation-artifacts/evidence/1-1/start-protected-surface-manifest.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-import.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-import-single-process.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/main-headless.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-console-session.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-console-session-stdout.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-console-session-stderr.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/main-interactive-observation.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/import-and-launch-classification.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/traversal-smoke.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/traversal-smoke-observations.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/final-headless.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/end-git-status.txt`
- `_bmad-output/implementation-artifacts/evidence/1-1/end-scoped-git-checks.txt`
- `_bmad-output/implementation-artifacts/evidence/1-1/end-protected-surface-manifest.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/preservation-audit.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/repeatability-review.md`

### Completion Notes List

- Story context created from the bounded Epic 1.1 context pack and validated for non-mutating baseline work.
- Create-story performed no runtime implementation; this implementation execution likewise made no runtime/source changes.
- Task 1 complete: captured repository identity, full dirty state, pinned Godot/Git/uv versions, actual add-on metadata and ignored/untracked status, protected-surface hashes, and effective launch/physics settings without changing the runtime surface.
- Recorded `BASE-001` for the locally observed Godot AI `4.0.4` versus planning-context `3.2.4`, and `BASE-002` for effective physics interpolation `false` versus the architecture target `true`; neither was corrected in this baseline Story.
- Task 2 complete: the single-process pinned import and fresh headless main-scene load exited successfully, LimboAI registered, the authoritative interactive run had no debugger/runtime errors, and injected current input moved the live player 7.874 m.
- The initial concurrent import lock and a standalone remote-debug diagnostic failure are retained and classified separately; both were stopped safely, followed by successful pinned runs, and required no runtime-file remediation.
- Task 3 complete: all four ground bindings plus air steering, jump, grapple acquisition/hold/release, retained momentum, wall run, wall stick, wall jumps, and landing recovery passed in `main.tscn` with exact frame/state evidence.
- Fall and death recovery are recorded as `not-currently-exercisable` (`BASE-004`, `BASE-005`) because the current prototype exposes no recovery path; neither blocks Story 1.2 and neither was repaired here. The tutorial scene was not needed or saved.
- Task 4 complete: every Baseline Evidence Record field now contains execution evidence, full raw logs are linked, no automated suite exists or ran, and recaptured facts are separated from authoring-time intelligence.
- Task 5 complete: final scoped staged/unstaged checks are empty, protected runtime/source bytes are unchanged, the final pinned headless regression load is clean, and the dry-run repeatability audit passes.
- All 25 starting dirty paths remain preserved. Eight reference PNGs appeared concurrently during execution and remain untouched; eight Godot-generated sidecars for those new PNGs were removed before the terminal capture and are regenerable.

### File List

- `_bmad-output/implementation-artifacts/1-1-verify-and-protect-the-playable-traversal-baseline.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `_bmad-output/implementation-artifacts/evidence/1-1/preflight.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/start-git-status.txt`
- `_bmad-output/implementation-artifacts/evidence/1-1/start-protected-surface-manifest.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-import.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-import-single-process.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/main-headless.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/main-interactive.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/main-interactive-stdout.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/main-interactive-stderr.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-console-session.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-console-session-stdout.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/editor-console-session-stderr.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/main-interactive-observation.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/import-and-launch-classification.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/traversal-smoke.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/traversal-smoke-observations.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/final-headless.log`
- `_bmad-output/implementation-artifacts/evidence/1-1/end-git-status.txt`
- `_bmad-output/implementation-artifacts/evidence/1-1/end-scoped-git-checks.txt`
- `_bmad-output/implementation-artifacts/evidence/1-1/end-protected-surface-manifest.json`
- `_bmad-output/implementation-artifacts/evidence/1-1/preservation-audit.md`
- `_bmad-output/implementation-artifacts/evidence/1-1/repeatability-review.md`

## Change Log

- 2026-09-09: Began implementation and completed non-mutating preflight/start-state capture.
- 2026-09-09: Completed pinned import, headless load, interactive launch, controllability proof, and output classification.
- 2026-09-09: Completed the `main.tscn` traversal smoke matrix and recorded unavailable fall/death recovery without gameplay changes.
- 2026-09-09: Consolidated the reproducible Baseline Evidence Record and classified all observed launch/smoke outcomes and pre-existing issues.
- 2026-09-09: Completed the terminal mutation guard, final headless regression load, concurrent-change classification, and repeatability review; moved Story 1.1 to review.
