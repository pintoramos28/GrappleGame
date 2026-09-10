# Extended Implementation Readiness Protocol

## Prepare

1. Resolve `gds-check-implementation-readiness`; canonical contract selection supersedes filename inference.
2. Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py readiness` and load the compact Markdown result from `_bmad-output/.artifact-index/readiness.md`.
3. Use the bounded epic protocol. Never concatenate all story shards.

## Supplemental gates

- GDD, architecture, epics, decision log, and exact project context exist, are final/active as appropriate, and have current lineage.
- Every stable GDD FR and NFR is represented in the epic manifest.
- Every NFR has an architecture disposition and every architecture-derived obligation maps to an epic or story.
- If HUD/UI is in scope, both UX spines must exist and every UX-DR maps to an epic or story. Missing UX is blocking unless the GDD explicitly sets `ux_required: false` with rationale.
- An open decision with `blocks_phase: implementation` blocks readiness.
- Project context must identify the selected architecture revision.
- Semantic contradictions among GDD, architecture, decisions, UX, and epics are reported even when identifier coverage passes.

## Record

Record the exact artifact IDs, versions, paths, SHA-256 revisions, shard count, and manifest digest in the readiness report. A report cannot claim complete reading unless every expected shard digest was processed.
