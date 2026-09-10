---
artifact_schema: 1
artifact_id: 'grapplegame.decision-log'
document_type: 'decision-log'
artifact_role: 'canonical'
authority: 'cross-artifact-decision-history'
path_base: 'project-root'
title: 'GrappleGame — Design Decision Log'
project: 'testgame'
created: '2026-08-31'
updated: '2026-09-09'
version: '1.3'
status: 'active'
---

# GrappleGame — Design Decision Log

## D-001 — Use a BMad-facing GDD adapter

- **Date:** 2026-08-31
- **Status:** Superseded
- **Context:** The project already has substantial design documentation under `project context/`, while the BMad architecture workflow performs shallow GDD discovery under `_bmad-output/`.
- **Decision:** Keep the detailed project documents authoritative for game design content and provide `_bmad-output/grapplegame-gdd-adapter.md` as the concise BMad planning entry point.
- **Consequence:** Downstream BMad workflows can discover a GDD without forcing a duplicate full-document rewrite. The later generated architecture owns target technical decisions; conflicts are reconciled into the appropriate authoritative document and recorded here.

## D-002 — Expand M2 beyond ranged pressure

- **Date:** 2026-08-31
- **Status:** Accepted
- **Context:** Ranged pressure is only one part of the documented combat vocabulary. The game also depends on displacement, route manipulation, anchor interaction, information pressure, support behavior and readable combinations.
- **Decision:** Replace M2 `Ranged pressure` with `Combat Pressure and Ability Vocabulary`. M2 will prototype every documented reusable enemy ability mechanic and test representative cross-family combinations.
- **Scope rule:** M2 is capability-complete rather than content-complete. Every mechanic receives a minimal playable prototype and counterplay test, but only a curated subset must become production-ready for the first level and boss slice.
- **Consequence:** M3 and M4 can select from a validated combat vocabulary while later worlds reuse, reskin, tune and recombine those mechanics.

## D-003 — Core-gameplay adapter synchronized and ready for architecture

- **Date:** 2026-08-31
- **Status:** Superseded
- **Context:** The adapter, detailed gameplay-system ability list and development roadmap must agree before downstream architecture work begins.
- **Decision:** Mark the adapter ready for architecture after confirming that all 17 documented reusable ability mechanics are represented, all linked source documents resolve and the roadmap uses the same M2 definition and downstream dependencies.
- **Consequence:** Architecture may proceed using the adapter as its discovery entry point while consulting the linked detailed documents for system depth.

## D-004 — Target Windows PC with keyboard and mouse

- **Date:** 2026-09-02
- **Status:** Accepted
- **Decision:** Target Windows PC first, support keyboard and mouse only, require 1920x1080 at a stable 60 FPS on eventual minimum-spec hardware, and treat high-refresh presentation as best effort.
- **Consequence:** Controller paths and secondary-platform requirements do not shape the M0-M4 architecture. Gameplay remains independent of render rate, while numeric hardware, memory, and content-density budgets are established from representative profiling.

## D-005 — Keep zip-pull behavior with a maximum-range boundary

- **Date:** 2026-09-02
- **Status:** Accepted
- **Decision:** Retain the acceleration-based direct zip-pull and preserved release velocity. Do not create a fixed rope at initial attachment distance or an automatic swing system; while active, enforce only the authored maximum grapple length as the connection boundary.
- **Consequence:** Acquisition and active constraint use the same maximum range. Inside that radius the boundary is inactive; at the boundary only outward relative motion is constrained while tangential and inward motion remain available.

## D-006 — Make the generated game architecture the target authority

- **Date:** 2026-09-02
- **Status:** Superseded
- **Decision:** Treat `_bmad-output/game-architecture.md` as the approved target implementation architecture and `project context/TECHNICAL_ARCHITECTURE.md` as the current prototype baseline and concise contract index.
- **Consequence:** Downstream implementation follows the generated architecture when the two differ, and linked source documents are synchronized rather than allowed to become competing technical authorities.

## D-007 — Canonicalize planning artifacts and authority

- **Date:** 2026-09-09
- **Status:** Accepted
- **Supersedes:** D-001, D-003, and the path declaration in D-006.
- **Decision:** Use `_bmad-output/planning-artifacts/gdd.md`, `architecture.md`, `epics/index.md`, and `decision-log.md` as the canonical planning suite. The GDD owns design intent; architecture owns target implementation decisions; epics derive implementation scope from both. Supporting design documents live under `planning-artifacts/sources/design-library/`, and `_bmad-output/project-context.md` remains derived implementation guidance.
- **Consequence:** The adapter is retired after conversion. Compatibility mirrors exist only where current installed BMad workflows still have hard-coded output-root discovery, and the artifact contract validates their canonical digest.

## D-008 — Use bounded epic shards

- **Date:** 2026-09-09
- **Status:** Accepted
- **Decision:** Replace the monolithic epic artifact with a canonical index, requirements catalog, machine-readable manifest, epic overviews, and one bounded file per story.
- **Consequence:** Readiness and Correct Course accumulate coverage by shard digest; Sprint Planning reads the manifest; Create Story loads only its target context pack.

## Open Decisions

| ID | Status | Blocks phase | Decision required |
|---|---|---|---|
| OD-001 | Open | M3-M4 | Select the Last Garden production subset from the validated M2 vocabulary. |
| OD-002 | Open | future-design | Decide which enemy-effect mechanics may also support future player abilities. |
| OD-003 | Open | M2-balance | Establish limits for hard control and movement cancellation. |
| OD-004 | Open | M2-balance | Establish the maximum readable simultaneous pressure overlap. |
| OD-005 | Open | tuning | Decide which tuning decisions require telemetry. |
| OD-006 | Open | verification | Allocate automated-test evidence versus playtest-only evidence for each prototype. |
| OD-007 | Open | UX | Define target audience, HUD hierarchy, accessibility behavior, reticle options, settings interactions, and active-slice audio minimum. |
| OD-008 | Open | performance | Define minimum-spec hardware, representative content density, capture method, pass duration, peak-memory target, and level-load target for the 1080p/60 FPS gate. |
| OD-009 | Open | M0-tuning | Measure and approve jump apex/airtime, coyote time, jump buffering, wall-relative entry tolerance, and grapple-gravity behavior after focused traversal playtests. |
| OD-010 | Open | M3-level-flow | Define checkpoint spacing, retry-time target, and encounter-versus-checkpoint reset cadence. |
| OD-011 | Open | M1-validation | Define the movement-derived combat advantage and its minimum pass threshold against an equivalent stationary attack. |
| OD-012 | Open | M1-scope | Confirm Basic Strike as the only required player attack with no combo chain in M0-M4, or define the replacement scope. |
