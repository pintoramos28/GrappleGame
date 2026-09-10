#!/usr/bin/env python3
"""One-time migration from the legacy GrappleGame artifact layout."""

from __future__ import annotations

import re
import sys
from datetime import date
from pathlib import Path

from resolve_artifacts import (
    frontmatter_parts,
    make_mirror,
    sha256,
    update_frontmatter,
    write_text_atomic,
)


ROOT = Path(__file__).resolve().parents[3]
TODAY = date.today().isoformat()
OUTPUT = ROOT / "_bmad-output"
PLANNING = OUTPUT / "planning-artifacts"
SOURCES = PLANNING / "sources" / "design-library"
ARCHIVE = OUTPUT / "archive"


DESIGN_FR_IDS = {
    "FR1",
    "FR2",
    *{f"FR{number}" for number in range(4, 21)},
    *{f"FR{number}" for number in range(22, 43)},
    "FR46",
    "FR48",
    "FR49",
    "FR50",
    "FR51",
    "FR52",
    "FR53",
    "FR43",
    "FR44",
    "FR45",
    "FR54",
    "FR55",
    "FR56",
    "FR57",
}
DESIGN_NFR_IDS = {
    "NFR1",
    "NFR2",
    "NFR3",
    "NFR4",
    "NFR6",
    "NFR7",
    "NFR8",
    "NFR9",
    "NFR10",
    "NFR11",
    "NFR12",
    "NFR17",
    "NFR18",
    "NFR22",
}
ARCHITECTURE_FR_IDS = {
    "FR3",
    "FR21",
    "FR47",
    "FR58",
}

# The epic catalog deliberately contains implementation-facing detail. The GDD
# keeps the same stable IDs while expressing only player-facing outcomes; the
# architecture retains the implementation contracts verbatim.
GDD_REQUIREMENT_OVERRIDES = {
    "FR4": "The player preserves useful momentum through ground and air movement, direction changes, grapple pull and release, wall contact, attacks, displacement, and recovery unless a clearly communicated mechanic changes it.",
    "FR6": "The player can aim at and acquire the first valid grapple target under the crosshair and receives clear validity, rejection, range, and attachment feedback.",
    "FR7": "Ordinary eligible world geometry is grappleable by default, while special moving, hazardous, resistant, modified, or invalid targets communicate their exception consistently.",
    "FR9": "The same 35 m maximum governs grapple acquisition and the active outer boundary; attachment distance never becomes rope length, and inward or tangential movement remains available at the boundary.",
    "FR10": "A grapple attached to a moving target follows the chosen point and ends once, with understandable feedback, when the target is destroyed, invalidated, reset, or moves discontinuously beyond tolerance.",
    "FR11": "The player can wall-run, wall-stick, and wall-jump on supported non-flat surfaces with consistent contact behavior.",
    "FR13": "Traversal and attacks can operate together when an attack permits it, with clear outcomes when damage, death, or an incompatible action interrupts either one.",
    "FR14": "The player can perform at least one melee attack with readable windup, danger, recovery, cancellation, hit behavior, movement interaction, and presentation feedback.",
    "FR15": "A deliberate moving approach can create a measurable combat advantage or opportunity that an equivalent stationary attack does not provide.",
    "FR16": "Combat supports health, accepted or rejected damage, hit reactions, source attribution, death, and complete restoration on encounter restart.",
    "FR19": "Every timed player or enemy ability presents a consistent request, windup, dangerous interval, recovery, and one completed-or-cancelled outcome.",
    "FR20": "Every spatial attack uses the same affected area and tracking or lock behavior for its warning and its dangerous interval.",
    "FR22": "The pressure vocabulary includes an adhesive surface that changes movement, stays grappleable by default, and restores normal movement after exit, expiry, source death, or reset.",
    "FR24": "The pressure vocabulary includes a harpoon or tether that can pull or constrain its recipient, supports cover or link-breaking counterplay, and ends consistently on source death or reset.",
    "FR25": "The pressure vocabulary includes a knockback or displacement attack that moves the player once per hit and leaves a demonstrated recovery opportunity.",
    "FR28": "The pressure vocabulary includes arcing bombardment whose path and landing warning agree with the committed impact position and whose launched delivery resolves consistently if its source dies.",
    "FR29": "The pressure vocabulary includes a rotating plane or line sweep whose motion and duration stay consistent and provide readable crossing or avoidance choices.",
    "FR31": "The pressure vocabulary includes damage gas or a drifting hazard with a readable boundary and ramp-up, consistent damage intervals, and complete cleanup on source death or reset.",
    "FR34": "The pressure vocabulary includes a temporary local grapple-anchor modification that changes the target's grapple behavior and restores it deterministically on expiry or reset.",
    "FR35": "The pressure vocabulary includes a support tether that provides an authored benefit and can be interrupted through more than one viable counter, such as attacking its source, breaking line of sight, destroying a relay, or killing the source.",
    "FR37": "The pressure vocabulary includes wind, suction, or another directional force that visibly changes the player's movement and permits authored counterplay through lateral movement, grapple, jump, release, or wall interaction.",
    "FR38": "The pressure vocabulary includes a temporary surface-state change with consistent movement, damage, grapple, and presentation behavior, predictable stacking, changed route value, and exact restoration.",
    "FR39": "Every M2 mechanic defines the question it asks, warning and dangerous space, cues, duration and feedback, primary counter, recovery option, grapple and wall interactions, source-death and reset behavior, overlap limits, tunable values, and required evidence.",
    "FR43": "A climbing enemy can discover usable level geometry, pursue and pounce within clear limits, abort safely when a route is lost, and return to a readable fallback without requiring hand-authored climb routes.",
    "FR44": "A flying enemy can choose bounded attack, strafe, staging, recovery, and avoidance positions from the current arena and combat situation without requiring hand-authored flight routes.",
    "FR45": "A vertical enemy uses a safe, readable fallback when no valid route or position exists; validation evidence makes the chosen fallback and rejected options understandable.",
    "FR46": "A level can activate required and optional encounters, track their participants, determine completion, and advance objectives consistently.",
    "FR48": "The player can die, restart the current encounter or return to the current in-memory checkpoint, regain the intended state, and replay without leftover effects or progress from the prior attempt.",
    "FR49": "The player can collect current-scope health and coin rewards, and each resolved reward is applied exactly once.",
    "FR51": "A minimal HUD can present player health, grapple validity and rejection, relevant ability phases or cooldowns, encounter state, and keyboard/mouse prompts without changing gameplay outcomes.",
    "FR53": "The game can load and activate an authored level only when its required content is ready, replace the active level, and return to safe UI if loading or activation fails.",
    "FR54": "The validation boss has a readable attack-response cycle, any required phases or vulnerabilities, traversal-created openings, damage and death, and advances the level objective when defeated.",
    "FR55": "Defeating the validation-slice boss produces the intended reward and exit, and the complete boss level can be replayed without leftover effects, rewards, or encounter progress.",
    "FR56": "Playtesting can select a Last Garden production subset from the validated M2 vocabulary for candidate Rootstalker, Spore Kite, Mycelial Weaver, and Garden Heart roles without changing the validated player-facing movement and pressure behavior.",
    "FR57": "The active slice provides appropriately scoped audio cues for movement, attacks, warnings, encounters, UI, ambience, and music state without making gameplay depend on successful playback.",
    "NFR1": "The M0–M4 validation slice targets Windows PC in Godot 4.7.2-stable and supports keyboard and mouse as its only gameplay input devices.",
    "NFR3": "Across supported display refresh rates and diagnostic configurations, gameplay outcomes remain equivalent; presentation refresh must not change results.",
    "NFR4": "Traversal, ability timing, cooldowns, attack windows, rotating effects, and hazard intervals remain equivalent in real time across the shipping and diagnostic configurations defined by Architecture.",
    "NFR6": "High-speed traversal and attacks do not visibly tunnel through intended collision, skip valid targets, or produce unstable contact classification during representative tests.",
    "NFR7": "High-resolution mouse motion remains precise, brief button presses are not lost between gameplay steps, and losing window focus cannot leave an action stuck.",
    "NFR10": "Encounter restart, checkpoint reload, source death, and scene exit remove every temporary attack, warning, hazard, obstacle, tether, status, surface change, effect, and audio occurrence from the prior state exactly once or harmlessly more than once.",
    "NFR11": "Combat-critical content is ready before an encounter begins, so first use does not create an avoidable gameplay hitch.",
    "NFR12": "A required load, initialization, definition, or spawn failure prevents partial activation and returns the player to an understandable safe state.",
    "NFR17": "The HUD is authored for 1920×1080 and remains usable at 16:10 and ultrawide Windows aspect ratios, with UI scale, reticle size, reticle color, and high-contrast options.",
    "NFR18": "Audio priority preserves local-player feedback and imminent enemy warnings before distant, repetitive, or ambient sounds; missing optional presentation uses a defined fallback and never blocks valid gameplay.",
}


def extract_requirement_lines(text: str) -> dict[str, str]:
    requirements: dict[str, str] = {}
    for match in re.finditer(
        r"(?m)^(FR\d+|NFR\d+):\s*(.+?)\s*$",
        text,
    ):
        # The epics artifact also contains a later FR coverage map. Preserve
        # the first occurrence, which is the full requirement statement.
        requirements.setdefault(match.group(1), match.group(2).strip())
    return requirements


def shift_headings(text: str) -> str:
    def shift(match: re.Match[str]) -> str:
        hashes = match.group(1)
        return "#" * min(6, len(hashes) + 1) + " "

    return re.sub(r"(?m)^(#{2,5})\s+", shift, text)


def rewrite_design_links(text: str) -> str:
    filenames = [
        "GAME_DESIGN_DOCUMENT.md",
        "GAMEPLAY_SYSTEMS.md",
        "LEVEL_AND_ENCOUNTER_DESIGN.md",
        "TECHNICAL_ARCHITECTURE.md",
        "DEVELOPMENT_ROADMAP.md",
        "WORLD_BUILDING.md",
        "WORLD_ATLAS.md",
        "HISTORY_AND_FACTIONS.md",
        "STORY_AND_CHARACTER_ARCS.md",
        "PORTAL_AND_FUNGAL_ECOLOGY.md",
        "CHARACTER_DESIGNS.md",
    ]
    for filename in filenames:
        text = text.replace(
            f"]({filename}",
            f"](sources/design-library/{filename}",
        )
        text = text.replace(
            f"](<../project context/{filename}>",
            f"](sources/design-library/{filename}",
        )
    return text


def requirement_section(
    requirements: dict[str, str],
    ids: set[str],
    heading: str,
) -> str:
    ordered = sorted(
        ids,
        key=lambda item: (
            0 if item.startswith("FR") else 1,
            int(re.search(r"\d+$", item).group(0)),
        ),
    )
    lines = [heading, ""]
    for identifier in ordered:
        if identifier not in requirements:
            raise ValueError(f"missing requirement definition: {identifier}")
        lines.append(f"- **{identifier}:** {requirements[identifier]}")
    return "\n".join(lines)


def build_legacy_gdd(adapter_text: str, detailed_text: str, epics_text: str) -> str:
    _, adapter_body = frontmatter_parts(adapter_text)
    _, detailed_body = frontmatter_parts(detailed_text)
    requirements = extract_requirement_lines(epics_text)

    start = adapter_body.index("## 5. Current Development Objective")
    end = adapter_body.index("## 11. Source Documents")
    active_scope = adapter_body[start:end].strip()
    active_scope = shift_headings(active_scope)
    active_scope = re.sub(
        r"(?m)^### 5\. Current Development Objective$",
        "### Current Development Objective",
        active_scope,
    )
    active_scope = re.sub(r"(?m)^### (\d+)\. ", "### ", active_scope)

    detailed_body = rewrite_design_links(detailed_body)
    detailed_body = detailed_body.replace(
        "# GrappleGame — Game Design Document",
        "## Detailed Design Baseline",
        1,
    )

    frontmatter = f"""---
artifact_schema: 1
artifact_id: 'grapplegame.gdd'
document_type: 'gdd'
artifact_role: 'canonical'
authority: 'game-design-intent'
path_base: 'project-root'
title: 'GrappleGame — Game Design Document'
project: 'testgame'
game_type: 'action-platformer'
genre_description: '3D traversal-combat action RPG'
scope: 'core-gameplay-validation'
platforms:
  - 'Windows PC'
input_devices:
  - 'keyboard'
  - 'mouse'
created: '2026-08-31'
updated: '{TODAY}'
version: '1.0.0'
status: 'complete'
ux_required: true
sources:
  - '_bmad-output/planning-artifacts/sources/design-library/GAME_DESIGN_DOCUMENT.md'
  - '_bmad-output/planning-artifacts/sources/design-library/GAMEPLAY_SYSTEMS.md'
  - '_bmad-output/planning-artifacts/sources/design-library/LEVEL_AND_ENCOUNTER_DESIGN.md'
  - '_bmad-output/planning-artifacts/sources/design-library/DEVELOPMENT_ROADMAP.md'
  - '_bmad-output/planning-artifacts/sources/design-library/WORLD_BUILDING.md'
decision_log: '_bmad-output/planning-artifacts/decision-log.md'
downstream_documents:
  architecture: '_bmad-output/planning-artifacts/architecture.md'
  epics: '_bmad-output/planning-artifacts/epics/index.md'
supersedes: '_bmad-output/archive/retired-design-adapter-2026-09-09.md'
---
"""

    authority = """# GrappleGame — Game Design Document

## Document Authority and Conflict Resolution

This is the canonical BMad game-design entry point. It owns player-facing intent, design pillars, loops, mechanics, level rules, validation scope, and design requirements. Supporting documents under `planning-artifacts/sources/design-library/` retain detailed evidence and domain depth.

- `GAMEPLAY_SYSTEMS.md` owns detailed traversal, combat, enemy, projectile, and reusable-ability design evidence.
- `LEVEL_AND_ENCOUNTER_DESIGN.md` owns detailed route, encounter, objective, and tutorial evidence.
- `DEVELOPMENT_ROADMAP.md` owns milestone sequencing and exit-gate detail.
- `WORLD_BUILDING.md` and its linked library own narrative and setting canon.
- `TECHNICAL_ARCHITECTURE.md` records prototype-baseline evidence only.
- `architecture.md` is downstream and owns target implementation decisions.
- `epics/index.md` is downstream and owns the implementation backlog.

When sources conflict, surface the conflict and resolve it in `decision-log.md`; never silently choose one. Accepted requirements must then be incorporated into the artifact that owns them.

## Executive Summary

GrappleGame is a Windows-PC-first 3D traversal-combat action RPG in which momentum, grappling, wall interaction, and spatial pressure form one combat language. The active M0–M4 scope proves a coherent traversal-combat slice culminating in the Last Garden boss, reward, exit, and clean replay. M5 tutorial validation and M6 persistent RPG expansion remain downstream.

### Core Concept and Unique Strengths

- Traversal is a combat resource rather than movement between fights.
- Enemies ask readable movement questions by changing route, altitude, velocity, timing, observation, or target priority.
- Ordinary eligible geometry is grappleable by default; exceptions are explicit and locally authored.
- Primitive presentation may validate gameplay, but danger, counterplay, and outcomes must remain readable.

### Target Audience

The target audience, expected skill floor, age/rating target, accessibility audience, and market positioning are not yet defined. This does not change the M0–M4 mechanical validation scope, but UX and commercial planning must resolve it before claiming production readiness.

## Goals and Context

The current goal is to validate expressive traversal, movement-powered combat, readable pressure combinations, one replayable authored level, and one complete boss loop before expanding content or RPG systems. Success is evidence that players can understand, counter, recover from, and eventually exploit the movement-combat vocabulary.
"""

    platformer = """## Action Platformer Specific Design

### Movement System

The starting vocabulary includes camera-relative ground and air steering, jump, wall-run, wall-stick, wall-jump, direct acceleration-based grapple zip-pull, momentum-preserving release, and authored recovery routes. Exact tuning values remain prototype evidence until playtest-approved.

### Combat System

The active slice requires one complete player melee action, readable enemy windup/active/recovery behavior, movement-derived openings, health and damage resolution, death, and deterministic restart. Traversal and attacks may coexist when authored coordination rules permit.

### Level Design Patterns

Authored instanced levels combine low, high, lateral, and recovery routes with required and optional encounters. Route value changes under enemy pressure. The Last Garden slice ends with a boss objective, reward, exit, and replay test.

### Player Abilities and Unlocks

M0–M4 validates the starting traversal and combat vocabulary rather than an unlock tree. Weapons, armor, loadouts, persistent progression, and broader RPG expansion are deferred to M6.

## Progression and Balance

Health and coins are the current-scope rewards. Balance work prioritizes readable windups, viable counters, recovery after ordinary errors, bounded overlap, and no routine removal of the player's complete movement vocabulary. Persistent economy and character progression are outside M0–M4.

## Art and Audio Direction

Prototype geometry and fallback effects are acceptable for validation. Presentation must still distinguish grapple validity, attack phases, affected space, damage or displacement outcomes, encounter state, and critical nearby threats. Detailed HUD hierarchy, accessibility behavior, audio priority, and settings interaction require a canonical UX package.

## Technical Specifications

- Godot 4.7.2-stable, Forward+ renderer, and Jolt Physics.
- Windows PC with keyboard and mouse for M0–M4.
- Target 1920×1080 at a stable 60 FPS on eventual minimum-spec hardware.
- High-refresh presentation is best effort; gameplay outcomes remain render-rate independent.
- Architecture, node/class ownership, data structures, and test seams belong in `architecture.md`.
"""

    design_requirements = "\n\n".join(
        [
            "## Stable Design Requirements and Traceability",
            "Identifiers are preserved from the approved epic inventory. Architecture-derived implementation requirements remain in `architecture.md` and the epic package; they are not promoted into game-design authority.",
            requirement_section(
                requirements,
                DESIGN_FR_IDS,
                "### Functional Requirements",
            ),
            requirement_section(
                requirements,
                DESIGN_NFR_IDS,
                "### Nonfunctional Design Requirements",
            ),
        ]
    )

    ending = """## Assumptions and Dependencies

- `[ASSUMPTION]` Godot 4.7.2-stable remains pinned through the M0–M4 validation slice.
- `[ASSUMPTION]` The four Last Garden roles remain candidates until FR56 is resolved through playtest evidence.
- Canonical UX documentation is required because HUD, settings, reticle, accessibility, and audio-feedback requirements are already in scope.
- Minimum-spec hardware and representative content density remain undefined.

## Source Documents

- [Detailed design baseline](sources/design-library/GAME_DESIGN_DOCUMENT.md)
- [Gameplay systems](sources/design-library/GAMEPLAY_SYSTEMS.md)
- [Level and encounter design](sources/design-library/LEVEL_AND_ENCOUNTER_DESIGN.md)
- [Development roadmap](sources/design-library/DEVELOPMENT_ROADMAP.md)
- [World and narrative index](sources/design-library/WORLD_BUILDING.md)
- [Prototype technical baseline](sources/design-library/TECHNICAL_ARCHITECTURE.md)
- [Global decision log](decision-log.md)
- [Target implementation architecture](architecture.md)
- [Canonical epic backlog](epics/index.md)
"""

    return "\n\n".join(
        [
            frontmatter.rstrip(),
            authority.strip(),
            detailed_body.strip(),
            platformer.strip(),
            "## Active M0–M4 Validation Scope\n\n" + active_scope,
            design_requirements.strip(),
            ending.strip(),
        ]
    ) + "\n"


def extract_fr_epic_map(text: str) -> dict[str, int]:
    return {
        requirement: int(epic)
        for requirement, epic in re.findall(
            r"(?mi)^(FR\d+)\s*:\s*Epic\s+(\d+)\b",
            text,
        )
    }


def markdown_cell(value: str) -> str:
    return value.replace("|", "\\|").replace("\n", " ").strip()


def requirement_table(
    requirements: dict[str, str],
    identifiers: set[str],
    epic_map: dict[str, int],
    ownership: str,
) -> str:
    lines = [
        "| ID | Requirement | Primary delivery | Ownership |",
        "|---|---|---|---|",
    ]
    ordered = sorted(
        identifiers,
        key=lambda item: (
            0 if item.startswith("FR") else 1,
            int(re.search(r"\d+$", item).group(0)),
        ),
    )
    for identifier in ordered:
        if identifier not in requirements:
            raise ValueError(f"missing requirement definition: {identifier}")
        delivery = (
            f"Epic {epic_map[identifier]}"
            if identifier in epic_map
            else "Cross-cutting"
        )
        lines.append(
            "| "
            + " | ".join(
                [
                    identifier,
                    markdown_cell(requirements[identifier]),
                    delivery,
                    ownership,
                ]
            )
            + " |"
        )
    return "\n".join(lines)


def architecture_reference_table(
    requirements: dict[str, str],
    identifiers: set[str],
    epic_map: dict[str, int],
) -> str:
    """Keep architecture mechanisms out of the player-facing GDD."""
    lines = [
        "| ID | Owner | Primary delivery | Authoritative specification |",
        "|---|---|---|---|",
    ]
    ordered = sorted(
        identifiers,
        key=lambda item: int(re.search(r"\d+$", item).group(0)),
    )
    for identifier in ordered:
        if identifier not in requirements:
            raise ValueError(f"missing requirement definition: {identifier}")
        delivery = (
            f"Epic {epic_map[identifier]}"
            if identifier in epic_map
            else "Cross-cutting"
        )
        lines.append(
            "| "
            + " | ".join(
                [
                    identifier,
                    "Architecture",
                    delivery,
                    "[Architecture requirement disposition](architecture.md#architecture-derived-functional-requirements)",
                ]
            )
            + " |"
        )
    return "\n".join(lines)


def build_gdd(_adapter_text: str, _detailed_text: str, epics_text: str) -> str:
    requirements = extract_requirement_lines(epics_text)
    gdd_requirements = {**requirements, **GDD_REQUIREMENT_OVERRIDES}
    epic_map = extract_fr_epic_map(epics_text)
    template_path = (
        ROOT
        / "_bmad/custom/artifacts/templates/canonical-gdd.md"
    )
    text = template_path.read_text(encoding="utf-8")
    replacements = {
        "%%TODAY%%": TODAY,
        "%%FUNCTIONAL_REQUIREMENTS%%": requirement_table(
            gdd_requirements,
            DESIGN_FR_IDS,
            epic_map,
            "GDD",
        ),
        "%%ARCHITECTURE_FUNCTIONAL_REQUIREMENTS%%": architecture_reference_table(
            requirements,
            ARCHITECTURE_FR_IDS,
            epic_map,
        ),
        "%%NONFUNCTIONAL_REQUIREMENTS%%": requirement_table(
            gdd_requirements,
            DESIGN_NFR_IDS,
            epic_map,
            "GDD",
        ),
    }
    for marker, value in replacements.items():
        text = text.replace(marker, value)
    unresolved = re.findall(r"%%[A-Z_]+%%", text)
    if unresolved:
        raise ValueError(
            "unresolved canonical GDD template markers: "
            + ", ".join(sorted(set(unresolved)))
        )
    return text.rstrip() + "\n"


def architecture_requirement_disposition(epics_text: str) -> str:
    requirements = extract_requirement_lines(epics_text)
    all_nfr_ids = {f"NFR{number}" for number in range(1, 25)}
    return "\n\n".join(
        [
            "## Requirement Disposition",
            "The GDD owns player-facing design requirements. This architecture disposes all technical and quality obligations that the canonical epic package must implement. The preserved identifiers prevent drift across GDD, architecture, epics, stories, and readiness checks.",
            requirement_section(
                requirements,
                ARCHITECTURE_FR_IDS,
                "### Architecture-Derived Functional Requirements",
            ),
            requirement_section(
                requirements,
                all_nfr_ids,
                "### Nonfunctional Requirement Dispositions",
            ),
        ]
    )


def build_architecture(
    architecture_text: str,
    epics_text: str,
    gdd_digest: str,
    decision_digest: str,
) -> str:
    _, body = frontmatter_parts(architecture_text)
    disposition = architecture_requirement_disposition(epics_text)
    if "## Requirement Disposition" not in body:
        body = body.rstrip() + "\n\n" + disposition + "\n"
    frontmatter = f"""---
artifact_schema: 1
artifact_id: 'grapplegame.architecture'
document_type: 'game-architecture'
artifact_role: 'canonical'
authority: 'target-implementation'
path_base: 'project-root'
title: 'Game Architecture'
project: 'testgame'
date: '2026-08-31'
updated: '{TODAY}'
author: 'Pinto'
version: '1.0'
stepsCompleted: [1, 2, 3, 4, 5, 6, 7, 8, 9]
status: 'complete'
engine: 'Godot 4.7.2-stable'
platform: 'Windows PC'
gdd: '_bmad-output/planning-artifacts/gdd.md'
gdd_sha256: '{gdd_digest}'
decision_log: '_bmad-output/planning-artifacts/decision-log.md'
decision_log_sha256: '{decision_digest}'
source_documents:
  - '_bmad-output/planning-artifacts/sources/design-library/GAME_DESIGN_DOCUMENT.md'
  - '_bmad-output/planning-artifacts/sources/design-library/GAMEPLAY_SYSTEMS.md'
  - '_bmad-output/planning-artifacts/sources/design-library/LEVEL_AND_ENCOUNTER_DESIGN.md'
  - '_bmad-output/planning-artifacts/sources/design-library/TECHNICAL_ARCHITECTURE.md'
  - '_bmad-output/planning-artifacts/sources/design-library/DEVELOPMENT_ROADMAP.md'
downstream_documents:
  epics: '_bmad-output/planning-artifacts/epics/index.md'
  project_context: '_bmad-output/project-context.md'
---
"""
    return frontmatter.rstrip() + "\n\n" + body.rstrip() + "\n"


def replace_decision_status(body: str, decision_id: str) -> str:
    pattern = re.compile(
        rf"(?ms)(^## {re.escape(decision_id)}\b.*?)(?=^## D-\d+\b|^## Open Decisions|\Z)"
    )
    match = pattern.search(body)
    if not match:
        raise ValueError(f"decision section not found: {decision_id}")
    section = match.group(1).replace(
        "- **Status:** Accepted",
        "- **Status:** Superseded",
        1,
    )
    return body[: match.start()] + section + body[match.end() :]


def build_decision_log(decision_text: str) -> str:
    _, body = frontmatter_parts(decision_text)
    for decision_id in ("D-001", "D-003", "D-006"):
        body = replace_decision_status(body, decision_id)
    open_index = body.find("## Open Decisions")
    if open_index >= 0:
        body = body[:open_index].rstrip()
    body += f"""

## D-007 — Canonicalize planning artifacts and authority

- **Date:** {TODAY}
- **Status:** Accepted
- **Supersedes:** D-001, D-003, and the path declaration in D-006.
- **Decision:** Use `_bmad-output/planning-artifacts/gdd.md`, `architecture.md`, `epics/index.md`, and `decision-log.md` as the canonical planning suite. The GDD owns design intent; architecture owns target implementation decisions; epics derive implementation scope from both. Supporting design documents live under `planning-artifacts/sources/design-library/`, and `_bmad-output/project-context.md` remains derived implementation guidance.
- **Consequence:** The adapter is retired after conversion. Compatibility mirrors exist only where current installed BMad workflows still have hard-coded output-root discovery, and the artifact contract validates their canonical digest.

## D-008 — Use bounded epic shards

- **Date:** {TODAY}
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
"""
    frontmatter = f"""---
artifact_schema: 1
artifact_id: 'grapplegame.decision-log'
document_type: 'decision-log'
artifact_role: 'canonical'
authority: 'cross-artifact-decision-history'
path_base: 'project-root'
title: 'GrappleGame — Design Decision Log'
project: 'testgame'
created: '2026-08-31'
updated: '{TODAY}'
version: '1.3'
status: 'active'
---
"""
    return frontmatter.rstrip() + "\n\n" + body.strip() + "\n"


def update_project_context(path: Path, architecture_path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = text.replace("game-architecture.md", "planning-artifacts/architecture.md")
    text = update_frontmatter(
        text,
        {
            "artifact_schema": 1,
            "artifact_id": "grapplegame.project-context",
            "document_type": "project-context",
            "artifact_role": "derived-implementation-guidance",
            "authority": "implementation-guidance",
            "path_base": "project-root",
            "date": TODAY,
            "updated": TODAY,
            "architecture_path": "_bmad-output/planning-artifacts/architecture.md",
            "architecture_sha256": sha256(architecture_path),
            "decision_log": "_bmad-output/planning-artifacts/decision-log.md",
            "decision_log_sha256": sha256(
                PLANNING / "decision-log.md"
            ),
        },
    )
    if "## Artifact Authority and Usage" not in text:
        marker = "\n## Technology Stack & Versions"
        authority = """

## Artifact Authority and Usage

- Read this file before implementation, but use `_bmad-output/planning-artifacts/gdd.md` for design intent and `planning-artifacts/architecture.md` for target technical decisions.
- Use `planning-artifacts/epics/manifest.json` for backlog inventory and load only the selected story shard.
- Consult `planning-artifacts/decision-log.md` for history; accepted requirements must also appear in their owning canonical artifact.
- Supporting documents under `planning-artifacts/sources/design-library/` are evidence, not competing planning authorities.
"""
        text = text.replace(marker, authority + marker, 1)
    text = re.sub(
        r"Last Updated:\s*\d{4}-\d{2}-\d{2}",
        f"Last Updated: {TODAY}",
        text,
    )
    write_text_atomic(path, text)


def update_prototype_architecture(path: Path) -> None:
    text = path.read_text(encoding="utf-8")
    text = text.replace(
        "[`_bmad-output/game-architecture.md`](../_bmad-output/game-architecture.md)",
        "[`architecture.md`](../../architecture.md)",
    )
    write_text_atomic(path, text)


def refine_current_gdd() -> None:
    """Rebuild the canonical GDD and refresh its downstream lineage stamps."""
    requirements_path = PLANNING / "epics" / "requirements.md"
    gdd_path = PLANNING / "gdd.md"
    architecture_path = PLANNING / "architecture.md"
    context_path = OUTPUT / "project-context.md"
    required = [requirements_path, gdd_path, architecture_path, context_path]
    missing = [str(path.relative_to(ROOT)) for path in required if not path.is_file()]
    if missing:
        raise FileNotFoundError(
            "GDD refinement inputs missing: " + ", ".join(missing)
        )

    requirements_text = requirements_path.read_text(encoding="utf-8")
    write_text_atomic(gdd_path, build_gdd("", "", requirements_text))
    make_mirror(ROOT, "gdd")

    architecture_text = architecture_path.read_text(encoding="utf-8")
    disposition_marker = "\n## Requirement Disposition"
    if disposition_marker in architecture_text:
        architecture_text = architecture_text.split(
            disposition_marker,
            1,
        )[0].rstrip()
    architecture_text = (
        architecture_text
        + "\n\n"
        + architecture_requirement_disposition(requirements_text)
        + "\n"
    )
    architecture_text = update_frontmatter(
        architecture_text,
        {
            "updated": TODAY,
            "gdd_sha256": sha256(gdd_path),
            "decision_log_sha256": sha256(
                PLANNING / "decision-log.md"
            ),
        },
    )
    write_text_atomic(architecture_path, architecture_text)
    make_mirror(ROOT, "architecture")
    update_project_context(context_path, architecture_path)
    print(f"Refined canonical GDD: {gdd_path.relative_to(ROOT)}")
    print(
        "Refreshed architecture lineage: "
        f"{architecture_path.relative_to(ROOT)}"
    )
    print(f"Refreshed project context: {context_path.relative_to(ROOT)}")


def main() -> None:
    PLANNING.mkdir(parents=True, exist_ok=True)
    ARCHIVE.mkdir(parents=True, exist_ok=True)

    adapter_path = OUTPUT / "grapplegame-gdd-adapter.md"
    architecture_source = OUTPUT / "game-architecture.md"
    decision_source = OUTPUT / "decision-log.md"
    epics_source = PLANNING / "epics.md"
    detailed_source = SOURCES / "GAME_DESIGN_DOCUMENT.md"
    context_path = OUTPUT / "project-context.md"

    required = [
        adapter_path,
        architecture_source,
        decision_source,
        epics_source,
        detailed_source,
        context_path,
    ]
    missing = [str(path.relative_to(ROOT)) for path in required if not path.is_file()]
    if missing:
        raise FileNotFoundError("migration inputs missing: " + ", ".join(missing))

    adapter_text = adapter_path.read_text(encoding="utf-8")
    architecture_text = architecture_source.read_text(encoding="utf-8")
    decision_text = decision_source.read_text(encoding="utf-8")
    epics_text = epics_source.read_text(encoding="utf-8")
    detailed_text = detailed_source.read_text(encoding="utf-8")

    retired_adapter = update_frontmatter(
        adapter_text,
        {
            "status": "superseded",
            "updated": TODAY,
            "superseded_by": "_bmad-output/planning-artifacts/gdd.md",
        },
    )
    retired_adapter_path = ARCHIVE / "retired-design-adapter-2026-09-09.md"
    write_text_atomic(retired_adapter_path, retired_adapter)

    gdd_path = PLANNING / "gdd.md"
    write_text_atomic(
        gdd_path,
        build_gdd(adapter_text, detailed_text, epics_text),
    )
    decision_path = PLANNING / "decision-log.md"
    write_text_atomic(decision_path, build_decision_log(decision_text))
    architecture_path = PLANNING / "architecture.md"
    write_text_atomic(
        architecture_path,
        build_architecture(
            architecture_text,
            epics_text,
            sha256(gdd_path),
            sha256(decision_path),
        ),
    )

    update_prototype_architecture(SOURCES / "TECHNICAL_ARCHITECTURE.md")
    update_project_context(context_path, architecture_path)

    make_mirror(ROOT, "gdd")
    make_mirror(ROOT, "architecture")

    adapter_path.unlink()
    decision_source.unlink()
    (PLANNING / "sources" / ".gitkeep").unlink(missing_ok=True)

    print(f"Canonical GDD: {gdd_path.relative_to(ROOT)}")
    print(f"Canonical architecture: {architecture_path.relative_to(ROOT)}")
    print(f"Canonical decision log: {decision_path.relative_to(ROOT)}")
    print(f"Retired adapter: {retired_adapter_path.relative_to(ROOT)}")


if __name__ == "__main__":
    if sys.argv[1:] == ["--refine-gdd"]:
        refine_current_gdd()
    elif sys.argv[1:]:
        raise SystemExit("usage: migrate_current_artifacts.py [--refine-gdd]")
    else:
        main()
