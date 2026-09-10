# Story 1.1: Verify and Protect the Playable Traversal Baseline

Status: ready-for-dev

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

- [ ] 1. Capture the preflight and starting state (AC: 1, 2, 3)
  - [ ] Record an ISO-8601 capture timestamp, full `HEAD`, branch or detached state, and the complete `git status --porcelain=v1 --untracked-files=all` output. A clean worktree is not required; preserve all pre-existing user changes.
  - [ ] Resolve the explicit Godot editor and console executables, capture the console executable's complete raw version string, and verify it is the approved 4.7.2 stable build before opening the project.
  - [ ] Capture Git and `uv` versions without installing, upgrading, or altering configuration.
  - [ ] Verify actual local add-on versions from their own metadata or version files and record where each value came from: LimboAI, Godot AI, GUT, Terrain3D, Phantom Camera, and GDQuest GDScript Formatter.
  - [ ] Record whether each required dependency is tracked, ignored, or otherwise reproducible from the repository. Do not call an ignored local add-on “repository-vendored” without evidence.
  - [ ] Capture a start-state manifest or equivalent repeatable snapshot for the protected runtime surface: `project.godot`, `main.tscn`, `.gitignore`, `scenes/`, `scripts/`, `resources/`, `materials/`, `ai/`, and `addons/`. Exclude generated `.godot/` cache files from the no-mutation assertion.
  - [ ] Record `run/main_scene`, renderer/method, Windows rendering driver, physics backend, effective physics ticks per second, and effective physics interpolation. Distinguish serialized settings from engine defaults or runtime-reported values; use the pinned editor's read-only Project Settings view for effective values when they are absent from `project.godot`, and do not apply or save changes.

- [ ] 2. Complete pinned-engine import and launch verification (AC: 2, 4)
  - [ ] Create the evidence directory, then run the pinned console build's explicit `--import` path with verbose output and `--log-file` so initial import/class-registration output is retained before interactive testing.
  - [ ] Launch the project with the explicit Godot 4.7.2 editor executable. Do not use the stale editor path recorded in ignored `.godot` metadata and do not save or resave project content.
  - [ ] Treat initial imports as complete only after the editor's import/progress work is idle and required script/extension classes have either registered successfully or produced a captured blocking error.
  - [ ] Capture a fresh verbose headless load of `res://main.tscn` as a parse/resource/scene-load smoke check; do not treat headless loading as a gameplay or traversal pass.
  - [ ] Launch `res://main.tscn` interactively with the same pinned console build and capture the complete fresh output while determining whether the player is controllable.
  - [ ] Classify import, parse, missing-resource, scene-load, runtime-error, and relevant-warning results in the evidence record, with links to the full raw logs. Do not silently filter output during capture.
  - [ ] If the required runtime cannot load, stop runtime execution, record the blocker and proposed separately scoped remediation, and proceed only with the non-mutating evidence and diff audit that remain possible. Keep AC 4 and Story 1.1 incomplete; after remediation, rerun the pinned import, launch, and smoke procedure before claiming completion.

- [ ] 3. Execute the traversal smoke procedure (AC: 5, 6)
  - [ ] Read the current InputMap and controller behavior before testing; use the actual current bindings rather than future target bindings or assumptions.
  - [ ] In `res://main.tscn`, record ground `W/A/S/D`, air steering, `Space` jump, right-mouse grapple acquisition/hold/release, momentum after release, wall run, grapple-assisted wall stick, wall jump, landing recovery, fall recovery, and death recovery as separate matrix rows where applicable.
  - [ ] For every row, record the exact scene, setup or target geometry, input sequence, result enum, and concise observation. Use only `pass`, `fail`, or `not-currently-exercisable` for the result.
  - [ ] Use `res://scenes/tree_grapple_tutorial.tscn` only if it supplies geometry needed for an observation. Label its results separately because it has different grapple-gravity and movement overrides, and do not save its generated editor preview.
  - [ ] Record a blocking issue or change candidate for any behavior required by the next migration Story that fails or cannot be exercised. Do not repair gameplay, content, controls, or architecture in Story 1.1.

- [ ] 4. Complete the Baseline Evidence Record (AC: 7)
  - [ ] Replace every `TBD` field in the Baseline Evidence Record below with observed evidence or an explicit `not available` plus reason.
  - [ ] Reference full raw logs under `_bmad-output/implementation-artifacts/evidence/1-1/`; keep the Story summary concise while preserving the original output needed to reproduce or diagnose the result.
  - [ ] State explicitly that no automated suite was run unless a separately established suite actually exists at implementation time. Presence of the GUT add-on alone is not an automated-test pass.
  - [ ] Separate facts observed during this execution from preflight intelligence recorded when the Story was authored.

- [ ] 5. Audit the ending state and prove repeatability (AC: 8)
  - [ ] Capture the complete unscoped ending `git status --porcelain=v1 --untracked-files=all`, the ending protected-surface snapshot, and the additional scoped Git status/diffs.
  - [ ] Compare starting and ending snapshots so pre-existing dirty files are not mistaken for Story changes and changes made during this Story are not hidden by a dirty worktree.
  - [ ] Confirm that only the implementation Story/evidence, retained raw logs, and sprint metadata changed. If a protected runtime file changed, restore nothing destructively: preserve user work, record the exact delta, and leave the Story incomplete pending separately scoped remediation.
  - [ ] Have another developer or agent repeat the documented launch/smoke steps from the record, or perform a dry-run review proving all paths, commands, setup, inputs, and expected observations are present.

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

- Capture date/time (ISO-8601 with timezone): TBD
- Full repository commit: TBD
- Branch or detached state: TBD
- Starting working-tree snapshot: TBD
- Ending working-tree snapshot: TBD
- Start/end comparison artifact or method: TBD

### Toolchain and Dependency Versions

| Item | Resolved command/metadata source (redact user-specific path) | Raw observed version | Git tracking/reproducibility note |
|---|---|---|---|
| Godot editor | TBD | TBD | TBD |
| Godot console | TBD | TBD | TBD |
| Git | TBD | TBD | N/A |
| `uv` | TBD | TBD | N/A |
| LimboAI | TBD | TBD | TBD |
| Godot AI | TBD | TBD | TBD |
| GUT | TBD | TBD | TBD |
| Terrain3D | TBD | TBD | TBD |
| Phantom Camera | TBD | TBD | TBD |
| GDQuest GDScript Formatter | TBD | TBD | TBD |

### Engine and Launch Configuration

| Setting | Serialized source | Effective observed value | Match / issue reference |
|---|---|---|---|
| Main scene | TBD | TBD | TBD |
| Renderer | TBD | TBD | TBD |
| Windows rendering driver | TBD | TBD | TBD |
| 3D physics backend | TBD | TBD | TBD |
| Physics ticks per second | TBD | TBD | TBD |
| Physics interpolation | TBD | TBD | TBD |

### Import and Launch Result

- Exact editor import procedure and completion signal: TBD
- Exact headless load command/result: TBD
- Exact interactive launch command/result: TBD
- Scene exercised: TBD
- Player controllable: TBD
- Automated tests: TBD

| Output category | Observed summary | Raw log reference | Pre-existing issue / remediation reference |
|---|---|---|---|
| Import | TBD | TBD | TBD |
| Parse / script classes | TBD | TBD | TBD |
| Missing resources | TBD | TBD | TBD |
| Scene load | TBD | TBD | TBD |
| Runtime errors | TBD | TBD | TBD |
| Relevant warnings | TBD | TBD | TBD |

### Traversal Smoke Matrix

| Scene | Behavior | Setup / target | Actual input | Expected baseline observation | Result | Observed result | Issue / remediation reference |
|---|---|---|---|---|---|---|---|
| TBD | Ground movement | TBD | TBD | Controllable ground movement | TBD | TBD | TBD |
| TBD | Air steering | TBD | TBD | Controllable aerial correction with carried commitment | TBD | TBD | TBD |
| TBD | Jump | TBD | TBD | Ground jump launches the player | TBD | TBD | TBD |
| TBD | Grapple acquisition | TBD | TBD | First eligible crosshair hit within current range attaches | TBD | TBD | TBD |
| TBD | Grapple hold | TBD | TBD | Held grapple pulls toward the current attachment | TBD | TBD | TBD |
| TBD | Grapple release | TBD | TBD | Release ends the grapple | TBD | TBD | TBD |
| TBD | Momentum after release | TBD | TBD | Useful velocity is retained after release | TBD | TBD | TBD |
| TBD | Wall run | TBD | TBD | Valid side-wall approach enters current wall-run behavior | TBD | TBD | TBD |
| TBD | Wall stick | TBD | TBD | Grapple-assisted wall collision can enter current stick behavior | TBD | TBD | TBD |
| TBD | Wall jump | TBD | TBD | Jump exits wall interaction up and away | TBD | TBD | TBD |
| TBD | Landing recovery | TBD | TBD | Ordinary missed movement can continue after landing | TBD | TBD | TBD |
| TBD | Fall recovery | TBD | TBD | Current fall/recovery behavior is observable or unavailable | TBD | TBD | TBD |
| TBD | Death recovery | TBD | TBD | Current death/recovery behavior is observable or unavailable | TBD | TBD | TBD |

### Known Pre-existing Issues and Separately Scoped Remediation

| Issue ID / candidate | Evidence | Impact on later Story | Required next action | Owner / status |
|---|---|---|---|---|
| TBD | TBD | TBD | TBD | TBD |

### Preservation Audit

- Protected-surface starting manifest/reference: TBD
- Protected-surface ending manifest/reference: TBD
- Scoped Git diff result: TBD
- Generated `.godot/` activity excluded and classified: TBD
- Runtime/source/add-on changes introduced by Story 1.1: TBD
- Evidence/workflow artifacts introduced by Story 1.1: TBD
- Repeatability review result: TBD

## Dev Agent Record

### Agent Model Used

TBD by implementation agent

### Debug Log References

- TBD during implementation

### Completion Notes List

- Story context created from the bounded Epic 1.1 context pack and validated for non-mutating baseline work.
- No runtime implementation or baseline execution has been performed by create-story.

### File List

- TBD during implementation; runtime file changes are prohibited by this Story.
