---
artifact_schema: 1
artifact_id: 'grapplegame.design-sources'
document_type: 'planning-source-index'
artifact_role: 'supporting-evidence-index'
authority: 'source-evidence'
path_base: 'project-root'
updated: '2026-09-09'
status: 'complete'
---

# GrappleGame Design Source Library

These files preserve detailed design, narrative, prototype, roadmap, and visual evidence. They inform the canonical planning suite but do not compete with it for authority.

Use the canonical artifacts for workflow decisions:

- [Game Design Document](../gdd.md) — player-facing intent, design scope, and requirements.
- [Game Architecture](../architecture.md) — target implementation decisions and technical requirement disposition.
- [Epic and Story Index](../epics/index.md) — bounded implementation backlog.
- [Decision Log](../decision-log.md) — cross-artifact decision history and unresolved decisions.
- [Project Context](../../project-context.md) — concise implementation rules for coding agents.

## Design and Delivery Sources

- [Detailed game design](design-library/GAME_DESIGN_DOCUMENT.md)
- [Gameplay systems](design-library/GAMEPLAY_SYSTEMS.md)
- [Level and encounter design](design-library/LEVEL_AND_ENCOUNTER_DESIGN.md)
- [Development roadmap](design-library/DEVELOPMENT_ROADMAP.md)
- [Prototype technical baseline](design-library/TECHNICAL_ARCHITECTURE.md)

## Narrative and World Sources

- [World building](design-library/WORLD_BUILDING.md)
- [World atlas](design-library/WORLD_ATLAS.md)
- [History and factions](design-library/HISTORY_AND_FACTIONS.md)
- [Story and character arcs](design-library/STORY_AND_CHARACTER_ARCS.md)
- [Character designs](design-library/CHARACTER_DESIGNS.md)
- [Portal and fungal ecology](design-library/PORTAL_AND_FUNGAL_ECOLOGY.md)

## Visual Sources

Concept references are grouped under [`design-library/concept_art/`](design-library/concept_art/). Their `.import` sidecars use the current project-relative source paths so Godot can refresh them after the library move.

## Authority Rule

When a source conflicts with the canonical GDD or architecture, record and resolve the conflict in the decision log. Incorporate an accepted result into the owning canonical artifact before treating it as implementation guidance.
