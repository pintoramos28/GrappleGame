# Canonical GDD Protocol

## Prepare

1. Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py resolve --consumer gds-gdd`.
2. Use a resolver-selected existing GDD when updating. Detailed inputs come only from `planning-artifacts/sources/design-library/` and the global decision log.
3. Treat the run-local `epics.md` as an outline, never as the canonical implementation backlog.
4. Keep architecture out of the GDD's upstream sources; architecture is downstream.

## Publish

1. Rename the completed run-local companion `epics.md` to `epic-outline.md` and mark it `document_type: epic-outline`, `canonical: false`.
2. Reconcile accepted run-local decisions into `planning-artifacts/decision-log.md`; incorporate each accepted requirement into its owning artifact.
3. Complete source reconciliation and the GDD discipline-validator pass. If a phase-blocking decision, required section, genre-specific specification, or unresolved placeholder remains, set `status: needs-decisions`, keep the document in its run workspace, and do not publish it as final.
4. Set a final status only after the validator passes, then run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py publish --artifact gdd --source <run-workspace>/gdd.md`.
5. Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py check` and halt on failure.
