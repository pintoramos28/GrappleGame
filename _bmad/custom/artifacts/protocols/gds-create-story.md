# Create Story Artifact Protocol

After the story key is selected, run `rtk uv run --no-cache _bmad/custom/artifacts/resolve_artifacts.py context-pack --story <epic.story>`. Load only the returned epic overview, story shard, requirements catalog, canonical GDD and architecture, optional UX package, and exact `_bmad-output/project-context.md`. Record artifact and shard digests in the created story's source references.

Before delegating analysis or validation, read and follow `create-story-agent-routing.md`. Use the exact project-scoped Codex custom agent names defined there. Their TOML files supply the model, reasoning effort, developer instructions, and read-only sandbox; do not substitute skill-only roles or global agents.
