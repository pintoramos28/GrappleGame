# Canonical UX Protocol

## Prepare

Resolve the `gds-ux` inventory and use only the canonical GDD, architecture, and decision log. UX workspaces remain under `_bmad-output/workspaces/ux/`.

## Publish

Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py publish-ux --source <run-workspace>`. Publication is atomic and succeeds only when both `DESIGN.md` and `EXPERIENCE.md` exist; it generates `planning-artifacts/ux/index.md` and archives the prior bundle.
