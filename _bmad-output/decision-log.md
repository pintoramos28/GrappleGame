---
title: "GrappleGame — Design Decision Log"
project: "testgame"
created: "2026-08-31"
updated: "2026-09-02"
---

# GrappleGame — Design Decision Log

## D-001 — Use a BMad-facing GDD adapter

- **Date:** 2026-08-31
- **Status:** Accepted
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
- **Status:** Accepted
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
- **Status:** Accepted
- **Decision:** Treat `_bmad-output/game-architecture.md` as the approved target implementation architecture and `project context/TECHNICAL_ARCHITECTURE.md` as the current prototype baseline and concise contract index.
- **Consequence:** Downstream implementation follows the generated architecture when the two differ, and linked source documents are synchronized rather than allowed to become competing technical authorities.

## Open Decisions

- Select the M2 ability subset for The Last Garden after prototype playtests.
- Decide which enemy-effect mechanics may also support future player abilities.
- Establish practical limits for simultaneous ability overlap and hard movement control.
