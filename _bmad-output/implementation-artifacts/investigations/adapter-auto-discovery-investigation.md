# Investigation: BMad adapter auto-discovery

## Hand-off Brief

1. **What happened.** The BMad architecture workflow reportedly did not auto-discover the adapter, although the adapter exists in the configured output root and matches the documented filename pattern.
2. **Where the case stands.** Active; static evidence confirms a path/pattern match, so the remaining cause is likely an execution-context, stale-workflow, or discovery-implementation mismatch.
3. **What's needed next.** Capture the exact workflow output and execution context, then compare it with the local discovery rule to identify where the observed run diverges.

## Case Info

| Field            | Value |
| ---------------- | ----- |
| Ticket           | N/A |
| Date opened      | 2026-08-31 |
| Status           | Active |
| System           | Windows; Godot project; BMad Game Dev Studio workflows |
| Evidence sources | Architecture workflow instructions, resolved configuration, adapter artifact, repository status |

## Problem Statement

The user reported that BMad did not auto-discover `_bmad-output/grapplegame-gdd-adapter.md` as the project's GDD.

## Evidence Inventory

| Source   | Status | Notes |
| -------- | ------ | ----- |
| Architecture discovery instructions | Available | `.agents/skills/gds-game-architecture/steps/step-01-init.md:90-95` defines the GDD search patterns. |
| Resolved project configuration | Available | `_bmad/gds/config.yaml:18` defines `_bmad-output` as `output_folder`. |
| Adapter artifact | Available | `_bmad-output/grapplegame-gdd-adapter.md:2-5` exists and is marked `ready-for-architecture`. |
| Local filename inventory | Available | The adapter is present under `_bmad-output` and contains `gdd` in its filename. |
| User-visible workflow output | Missing | The exact message, command, and current working directory from the failing run have not been provided. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --------------- | -------- | ------ | ----- |
| 1 | Capture the exact BMad discovery message and the task's working directory | High | Open | Needed to distinguish stale context from a path-resolution defect. |
| 2 | Reproduce the documented glob against the current workspace | High | Done | Static path and filename evidence already match. |
| 3 | Compare the workflow version used by the failing task with the local skill file | Medium | Open | A different installed copy may be in use. |
| 4 | Inspect the actual discovery implementation if it differs from the step instructions | Medium | Open | The step may describe patterns that the runner does not execute literally. |

## Timeline of Events

| Time | Event | Source | Confidence |
| ---- | ----- | ------ | ---------- |
| 2026-08-31 | Adapter created under `_bmad-output` with a filename containing `gdd`. | `_bmad-output/grapplegame-gdd-adapter.md:1-5` | Confirmed |
| 2026-08-31 | Architecture workflow documented a search under `{output_folder}` for `*gdd*.md` and `*game-design*.md`. | `.agents/skills/gds-game-architecture/steps/step-01-init.md:90-95` | Confirmed |
| 2026-08-31 | Project configuration set `output_folder` to `{project-root}/_bmad-output`. | `_bmad/gds/config.yaml:18` | Confirmed |
| 2026-08-31 | User reported that the adapter was not auto-discovered. | Current conversation | Confirmed |

## Confirmed Findings

### Finding 1: The adapter matches the documented local search contract

**Evidence:** `.agents/skills/gds-game-architecture/steps/step-01-init.md:90-95`; `_bmad/gds/config.yaml:18`; `_bmad-output/grapplegame-gdd-adapter.md:2`

**Detail:** The local architecture instructions search `{output_folder}` for `*gdd*.md` and `*game-design*.md`. The resolved project output folder is `_bmad-output`, and the adapter is `_bmad-output/grapplegame-gdd-adapter.md`, which matches the first pattern.

## Deduced Conclusions

### Deduction 1: The failure is not explained by the adapter's current path or filename

**Based on:** Finding 1.

**Reasoning:** The configured search root and the adapter's location agree, and the filename contains the required token. Therefore a run using the local instructions from the workspace root should find at least one candidate.

**Conclusion:** The observed failure requires another explanation: a different working directory, a stale or different workflow copy, an implementation that does not execute the documented glob, or an artifact inventory taken before the adapter existed.

## Hypothesized Paths

### Hypothesis 1: The failing task used a stale artifact inventory or workflow context

**Status:** Open

**Theory:** The workflow run occurred before the adapter was created, or the task retained a prior scan result.

**Supporting indicators:** The adapter was created during the immediately preceding work.

**Would confirm:** The failing task timestamp or output predates the adapter, or a fresh run finds it.

**Would refute:** A fresh run from the project root using the current skill also fails.

**Resolution:** Pending.

### Hypothesis 2: The workflow ran with a different project root or installed skill copy

**Status:** Open

**Theory:** The task resolved `{project-root}` or `gds-game-architecture` from a different workspace or installation than the files inspected here.

**Supporting indicators:** BMad skills can be installed in more than one location, and the user-facing task may not expose its working directory.

**Would confirm:** The failing output identifies another path, host, or skill root.

**Would refute:** The failing task reports this exact project root and local skill path.

**Resolution:** Pending.

### Hypothesis 3: The runner does not execute the documented glob literally

**Status:** Open

**Theory:** The instructions describe a search pattern, but the actual runner relies on a separate artifact index or only recognizes standard `gdd.md` output names.

**Supporting indicators:** The workflow is a prose/micro-file workflow; the actual runtime discovery implementation is not present in the project files inspected so far.

**Would confirm:** A fresh run from the correct root still ignores the matching adapter, or the runner source reveals a stricter filename/path check.

**Would refute:** A fresh run discovers the adapter with no workflow changes.

**Resolution:** Pending.

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | --- | --- |
| Exact failure message | Determines whether the workflow saw zero files or rejected the adapter format. | Copy the BMad prompt/output that requested a GDD. |
| Working directory and skill path | Distinguishes project-root and installed-skill mismatches. | Capture the task's workspace path and the skill path it reports. |
| Fresh reproduction result | Tests whether the issue is stale state. | Start a fresh architecture task in this project and run discovery again. |

## Source Code Trace

| Element | Detail |
| ------- | ------- |
| Error origin | Not yet identified; the visible local rule is `.agents/skills/gds-game-architecture/steps/step-01-init.md:90-105`. |
| Trigger | Starting the Game Architecture workflow. |
| Condition | The workflow reports no GDD despite `_bmad-output/grapplegame-gdd-adapter.md` matching the documented pattern. |
| Related files | `_bmad/gds/config.yaml`, `_bmad-output/grapplegame-gdd-adapter.md`, `.agents/skills/gds-game-architecture/steps/step-01-init.md`. |

## Conclusion

**Confidence:** Medium

The local evidence confirms that the adapter exists in the configured output root and matches the architecture workflow's documented `*gdd*.md` pattern. The root cause of the user-visible failure is not yet confirmed because the failing task's output and execution context are missing. The highest-probability causes are stale workflow state, a different project root or skill copy, or a runner that enforces a stricter standard `gdd.md` convention than its instructions describe.

## Recommended Next Steps

### Fix direction

Do not change or duplicate the adapter yet. First obtain the exact discovery output and reproduce from a fresh architecture task in this project. If the fresh run still fails, inspect or patch the discovery contract to accept the adapter explicitly.

### Diagnostic

Run the architecture workflow again from the project root and capture the complete initialization message, including the paths it searched and the files it found. Compare those paths with `_bmad-output/grapplegame-gdd-adapter.md`.

## Reproduction Plan

1. Start a fresh `gds-game-architecture` task in `C:\Users\pinto\Documents\Godot Projects\testgame`.
2. Allow the workflow to perform its initial document discovery.
3. Record the exact GDD search path and result.
4. Expected result: `_bmad-output/grapplegame-gdd-adapter.md` is listed as a GDD candidate.
5. If it is not listed, record the actual resolved path and workflow source used.

## Side Findings

- `_bmad/gds/config.yaml` currently identifies Godot as the primary platform, but the broader merged configuration should be checked separately if engine selection is also inconsistent.
- The project's detailed design documents are under `project context/`, while the adapter provides the BMad output-root entry point.
