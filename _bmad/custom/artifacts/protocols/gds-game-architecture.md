# Canonical Architecture Protocol

## Prepare

1. Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py resolve --consumer gds-game-architecture`.
2. Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py mirror --artifact gdd` so installed root-level GDD discovery sees a digest-verified compatibility mirror.
3. Treat `_bmad-output/planning-artifacts/gdd.md` as design authority and `_bmad-output/game-architecture.md` as the managed authoring mirror.

## Publish

1. Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py publish --artifact architecture --source _bmad-output/game-architecture.md`.
2. Normalize its GDD, decision-log, source-library, epics, and project-context references to the contract paths.
3. Run the resolver check and do not complete on a stale source revision or authority cycle.
