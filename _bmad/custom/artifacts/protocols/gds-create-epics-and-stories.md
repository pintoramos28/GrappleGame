# Canonical Epics Protocol

## Prepare

1. Resolve the consumer inventory and use its exact GDD, architecture, optional UX bundle, and decision-log paths.
2. Stop when lineage is stale or a decision marked `blocks_phase: implementation` remains open.
3. The dedicated epic workflow is the sole producer of the canonical backlog. A GDD workspace's epic companion is only an outline.
4. Create `_bmad-output/.artifact-index/epics-producer.lock` immediately before writing the temporary monolith.

## Publish

Run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py shard-epics --source _bmad-output/planning-artifacts/epics.md`. This builds the bounded package, validates every shard, archives the monolith, removes the producer lock, and refreshes the artifact inventory.
