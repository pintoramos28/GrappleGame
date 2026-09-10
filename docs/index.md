# Project Documentation Index

This directory is the codebase-documentation entry point. BMad planning artifacts remain under `_bmad-output` so installed and customized workflows can discover them consistently.

## Implementation Entry Points

- [AI project context](../_bmad-output/project-context.md) — concise, current implementation rules; read this before changing game code.
- [Game architecture](../_bmad-output/planning-artifacts/architecture.md) — authoritative target systems, boundaries, patterns, and verification strategy.
- [Epic and story manifest](../_bmad-output/planning-artifacts/epics/manifest.json) — machine-readable backlog inventory; load only the relevant story shard.
- [Epic and story index](../_bmad-output/planning-artifacts/epics/index.md) — human-readable bounded backlog.

## Product and Design Entry Points

- [Canonical GDD](../_bmad-output/planning-artifacts/gdd.md) — design intent, scope, mechanics, and FR/NFR requirements.
- [Decision log](../_bmad-output/planning-artifacts/decision-log.md) — accepted, superseded, and open cross-artifact decisions.
- [Supporting source library](../_bmad-output/planning-artifacts/sources/index.md) — detailed design, narrative, prototype, roadmap, and concept-art evidence.

## Workflow Contract

- [Artifact contract](../_bmad/custom/artifacts/artifact-contract.toml) — canonical paths, compatibility mirrors, consumer requirements, and package limits.
- [Artifact workflow guide](../_bmad/custom/artifacts/README.md) — resolver, publication, sharding, readiness, and context-pack commands.

Do not duplicate canonical planning content here. Add durable codebase documentation to `docs/`; update the owning planning artifact when game intent, architecture, backlog, or implementation-agent rules change.
