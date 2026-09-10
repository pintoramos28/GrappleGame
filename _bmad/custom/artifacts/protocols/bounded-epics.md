# Bounded Epic Loading Contract

The canonical epic backlog is a shard package rooted at `_bmad-output/planning-artifacts/epics/index.md`. `manifest.json` is the machine-readable inventory; `requirements.md` owns the compact requirements catalog; epic overview and story files contain detailed work.

Rules:

1. Never concatenate every epic or story shard into one model context.
2. Sprint Planning reads `manifest.json`; story bodies are unnecessary.
3. Create Story loads only the selected epic overview, selected story shard, directly referenced requirements, previous implemented story when relevant, and `_bmad-output/project-context.md`.
4. Readiness processes one shard at a time and persists coverage by digest before releasing the shard.
5. Correct Course selects affected shards from requirement IDs and source hints in the manifest.
6. A shard whose SHA-256 differs from the manifest is stale and blocks consumption until the manifest is regenerated.
7. A temporary `planning-artifacts/epics.md` may exist only while the epic producer lock is active. On successful completion it must be sharded and archived.
