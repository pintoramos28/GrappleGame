# GrappleGame Artifact Compatibility Layer

This directory defines the project-owned artifact contract used by BMad Game Dev Studio workflows. It is intentionally outside installer-managed workflow files.

## Authority

- `planning-artifacts/gdd.md` owns game-design intent.
- `planning-artifacts/architecture.md` owns target implementation decisions.
- `planning-artifacts/epics/index.md` and its manifest own the implementation backlog.
- `planning-artifacts/decision-log.md` owns cross-artifact decision history, but accepted requirements must also be incorporated into their owning canonical artifact.
- `planning-artifacts/ux/index.md` owns UX only after both `DESIGN.md` and `EXPERIENCE.md` are finalized.
- `_bmad-output/project-context.md` is derived implementation guidance, not planning authority.

Detailed design, narrative, and prototype-baseline documents live under `planning-artifacts/sources/design-library/`. They are evidence for canonical artifacts and are excluded from canonical filename selection.

## Commands

Run commands from the project root:

```powershell
rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py resolve --consumer gds-check-implementation-readiness
rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py check
rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py readiness
rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py context-pack --story 3.4
```

The resolver writes generated inventories beneath `_bmad-output/.artifact-index/`, outside planning discovery.

`resolve --consumer gds-gdd` may reopen a canonical GDD whose status is nonfinal. All downstream consumers and the global `check` fail closed until that GDD returns to one of the contract's final statuses, except that `context-pack` may consume a nonfinal artifact for a Story only when the consumer contract explicitly matches its status, exact scope declaration, and Epic number. The current Create Story exception permits Epic 1 while the GDD declares M0 implementation-start readiness; Epic 2 and later remain blocked.

The root-level `gdd-current.md` and `game-architecture.md` files are managed compatibility mirrors for installed workflows that still perform shallow discovery. `gdd-current.md` is read-only discovery input. `game-architecture.md` remains the installed architecture workflow's managed authoring path and must be republished through the architecture protocol; neither mirror should be edited outside its declared workflow.

All integration instructions live in `_bmad/custom/*.toml` and `_bmad/custom/artifacts/`. BMad updates may replace installed `.agents/skills` and `_bmad` module files, but they do not need to be patched for this contract; validate the team overrides after every update with `_bmad/scripts/resolve_customization.py`.
