---
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
updated: '%%TODAY%%'
version: '1.2.0'
status: 'needs-decisions'
implementation_scope_ready: 'M0 implementation-start only; no milestone is acceptance-ready'
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

# GrappleGame — Game Design Document

## Document Status, Authority, and Scope

This is the sole canonical game-design artifact for BMad planning. It owns player-facing intent, pillars, loops, mechanics, level rules, validation scope, and design requirements. The target architecture owns implementation structure, and the bounded epic package owns delivery decomposition.

Supporting files under `sources/design-library/` preserve detailed evidence. When a source conflicts with this GDD or the architecture, record the conflict in the decision log and incorporate the accepted result into the artifact that owns it; never silently choose one.

The document is structurally usable to begin M0 implementation, but no milestone is acceptance-ready: OD-009 blocks M0 acceptance, and M1 lacks an approved movement-combat advantage metric, threshold, and attack-scope decision. UX, audience, performance-hardware, M2 balance, production-subset, and cadence decisions also remain open. The readiness workflow must treat those decisions according to the phase they block.

## Executive Summary

GrappleGame is a Windows-PC-first 3D action-platformer with a deferred RPG layer. Momentum, grappling, wall interaction, and spatial pressure form one combat language: the player reads the environment, builds a route, commits through danger, turns movement into an attack opportunity, and recovers without dropping back into passive ground play.

The active M0–M4 validation slice culminates in a replayable Last Garden boss level with a reward and exit. It proves the game’s traversal-combat vocabulary before production-scale content, persistent progression, or the wider ten-world concept is funded.

### Product Goals

- Make movement feel freeing at first contact and meaningfully expressive at expert play.
- Make traversal create offensive opportunity while attacks create readable commitment risk.
- Make enemies alter route, altitude, velocity, timing, information, or target priority instead of merely adding health.
- Preserve player agency under pressure through visible danger, viable counters, and recovery after ordinary mistakes.
- Validate one complete, replayable level loop before expanding content or RPG systems.

### Target Audience

Target age/rating, expected action-game skill floor, accessibility audience, and market position are unresolved under [OD-007](decision-log.md#open-decisions). [ASSUMPTION: A-003 — Internal keyboard/mouse playtesters are sufficient for M0–M1 mechanical validation.] UX and commercial readiness may not be claimed until OD-007 is resolved.

## Game Vision and Design Pillars

### Pillar 1 — Freedom Through Momentum and Spatial Traversal

The player can move through the whole three-dimensional space using ground and air steering, jumping, crosshair-directed grappling, momentum-preserving release, wall running, wall sticking, and wall jumping. Height, distance, walls, surfaces, grappleable geometry, and enemy positions create alternate routes. Grapple is an aimed acceleration-based zip-pull, not an automatic climb, teleport, initial-distance rope, or automatic swing.

### Pillar 2 — High-Risk Combat Powered by Movement

Mobility creates attack angles and defensive choices rather than effortless kiting. Faster or more exposed approaches can create a measurable advantage, while attack commitment gives enemies a readable chance to retaliate, displace the player, deny a route, or force recovery.

### Pillar 3 — Enemies Are Movement and Combat Problems

Enemies shape the space. Melee pressure punishes stagnation, ranged and spatial pressure changes safe routes, controllers alter surfaces or anchors, supports create target priority, vertical enemies test altitude, and bosses combine learned pressures around exploitable openings.

### Pillar 4 — Readable Danger, Fast Onboarding, Deep Mastery

Players should understand their basic actions and why an outcome occurred even when optimal execution is difficult. Warnings, affected space, active windows, grapple feedback, damage or displacement outcomes, nearby threats, and recovery paths must remain interpretable with prototype presentation.

### Supporting Design Principle — Every System Reinforces Traversal-Combat

New mechanics are justified by how they change route value, position, altitude, velocity, timing, observation, target priority, attack opportunity, or readable ability interaction. Implementation modularity belongs to the architecture rather than serving as a separate player-facing pillar.

## Core Gameplay

### Player Fantasy

The player fights through space rather than moving to a separate combat arena. A successful sequence reads geometry and enemy intent, builds momentum, chooses an approach, commits to an attack, responds to the counterpressure, and carries useful motion into the next decision.

### Encounter Loop

1. Read surfaces, grapple targets, enemies, warnings, and recovery routes.
2. Build or redirect momentum through movement, jumping, grappling, walls, and release timing.
3. Commit to an attack, evasion, interruption, or route change while exposed to pressure.
4. Read the outcome and enemy response; recover or continue the route.
5. Defeat or deliberately bypass optional pressure, collect available rewards, and advance.

### Level Loop

1. Enter one authored, self-contained vertical level.
2. Traverse required spaces and resolve required encounters; optional encounters trade risk for reward, safety, or information.
3. Reach and defeat the boss objective.
4. Receive the current-scope reward, expose the exit, and complete the level.
5. Replay without stale encounter, reward, or presentation state.

### Win and Loss Conditions

- A standard level is won when its boss dies, the level authority commits completion, the reward resolves once, and the exit becomes usable.
- The tree tutorial is an explicit non-combat exception: activating its summit goal completes it.
- Reaching zero health loses the current attempt. Through M3–M4, the player restarts the encounter or returns to the current in-memory checkpoint; no persistent save is implied.
- An unrecoverable fall or out-of-bounds state uses the same current-attempt recovery path once that boundary is authored. Ordinary movement mistakes should remain recoverable in-space when a designed route exists.
- Required loading or initialization failure returns to safe UI and cannot activate a partial level.

### Primary Controls

| Action | Input | Design behavior |
|---|---|---|
| Move | `WASD` | Camera-relative ground or air steering. |
| Jump | `Space` | Ground jump or context-valid wall jump. |
| Grapple | Hold right mouse | Select the first valid crosshair hit, accelerate toward its current anchor, and preserve velocity on release. |
| Attack | Left mouse or `F` | Request the current player attack when its movement and lifecycle rules allow it. |
| Pause / cursor | `Esc` | M3 target: enter pause or safe UI; current prototype releases cursor capture. |

No target-priority assist or aim snapping is planned for grapple acquisition. Controller support is outside M0–M4.

## Action-Platformer Design

### Movement Feel Table

[ASSUMPTION: A-002 — Current movement and Basic Strike numbers are validation baselines rather than final shipping balance.] A change made during M0 playtesting must be recorded with its evidence rather than silently creating scene-specific variants.

| Movement element | Validation baseline | Required feel or behavior | Evidence / unresolved item |
|---|---:|---|---|
| Ground horizontal speed | 10 m/s | Immediate, controllable movement without erasing carried momentum during direction changes. | Current player instance. |
| Air horizontal speed | 10 m/s | Meaningful air steering with less braking authority than ground movement. | Current player instance. |
| Ground deceleration | 30 m/s² | Responsive stopping on ordinary ground. | Current player instance. |
| Air deceleration | 5 m/s² | Preserve aerial commitment while allowing correction. | Current player instance. |
| Ground jump launch | 4.5 m/s upward | Reliable basic jump with no hidden stamina cost. | Current prototype. |
| Ground jump apex / airtime | Not yet measured | The player-facing height and timing must be repeatable and support the authored M0 route. | OD-009; measure the current prototype, tune if needed, and approve both values. |
| Coyote time / jump buffer | Not yet set | Forgive near-edge and just-before-landing inputs without changing the advanced vocabulary. | OD-009; tune and verify in M0. |
| Wall-run contact | ≥1 m/s horizontal; wall within 0.8 m; surface within approximately 12° of vertical | Enter only with useful along-wall travel; near-perpendicular impact must not become an implausible run. | Prototype thresholds; OD-009 must approve the player-facing tolerance. Architecture owns the exact vector test. |
| Wall-run acceleration | 4 m/s² | Preserve useful tangential travel while stabilizing against the surface. | Current scene baseline. |
| Wall jump | 8 m/s outward; 5.5 m/s upward | Redirect momentum and retain positive along-wall travel. | Current prototype. |
| Grapple acquisition / boundary | 35 m | The same maximum governs first-hit acquisition and the active outer boundary; initial attachment distance never becomes rope length. | Accepted D-005. |
| Grapple pull | 48 m/s² initial, 8 m/s² minimum, 53.33 m/s³ decay, 22 m/s cap | Strong direct zip-pull whose acceleration reaches its floor at roughly 0.75 s and preserves release velocity. | Current shared baseline; context gravity remains a tuning variable. |

Movement-feel acceptance uses completion runs across the shipping and diagnostic refresh configurations defined by Architecture, contact and velocity evidence, and observed player comprehension. Final tuning thresholds beyond the values above remain playtest decisions, not architecture defaults.

### Combat Specifications

| Combat element | Validation baseline | Design contract |
|---|---:|---|
| Basic Strike windup | 0.08 s | The warning ends where danger begins. |
| Basic Strike active window | 0.18 s | Only the active window can connect; the warning and hit region describe the same attack space. |
| Basic Strike total cycle | About 0.45 s | Recovery creates commitment and prevents immediate repeat attacks. |
| Basic Strike damage | 16 physical | Prototype baseline; movement-derived advantage must be measurable and capped before expanding damage types. |
| Player health | 100 | Prototype baseline for M1 survivability and death/restart tests. |
| Prototype enemy health | 60 | Baseline only; role and counterplay matter more than health inflation. |
| Hit convention | One target hit per activation | A single attack activation may not repeatedly damage the same target, and ordinary friendly fire is rejected. |
| Movement interaction | Allowed unless the attack says otherwise | Traversal and attack can coexist; a specific attack may restrict, redirect, or preserve movement and grapple behavior. |
| Player combo policy | No combo chain in M0–M4 | [ASSUMPTION: A-004 — Basic Strike is the only required player attack in the validation slice.] A future decision may expand the attack vocabulary after the movement-combat contract is proven. |

Every timed attack or ability has a warning, dangerous interval, recovery, cancellation result, affected space or target, source-death behavior, and restart behavior. Animation and effects communicate those facts but do not redefine when or where the attack is dangerous.

OD-011 must select the movement-derived advantage to measure and its minimum pass threshold against an equivalent stationary attack before M1 can pass. OD-012 must confirm or replace the Basic-Strike-only, no-combo scope before M1 scope is accepted.

### Level Gating and Checkpoint Cadence

| Gate | Player proof | Unlocks |
|---|---|---|
| M0 traversal route | Use ground, air, jump, grapple, release, wall-run, wall-stick, wall-jump, and recovery with understandable outcomes. | Movement-combat validation. |
| M1 combat route | Turn a moving approach into a deliberate advantage, survive readable retaliation, defeat one melee enemy, and reset cleanly. | Combat-pressure prototypes. |
| M2 vocabulary labs | Counter each pressure mechanic and six representative combinations without unavoidable damage or control chains. | Production-subset selection. |
| M3 level shell | Enter, traverse, fight, collect, die, restart, and complete a non-boss sequence. | Boss-slice integration. |
| M4 boss slice | Apply learned traversal-combat behavior to defeat the Garden Heart, receive the reward, exit, and replay. | M5 tutorial validation and later M6 RPG expansion. |

Each major combat space provides low, high, and lateral routes; a recovery route is required where an ordinary miss or displacement would otherwise force an unexplained restart. Exact checkpoint spacing, retry time, and whether any encounter resets independently of a checkpoint are unresolved under OD-010.

### Difficulty Curve

| Stage | Expected mastery | Encounter and geometry progression | Failure / recovery expectation |
|---|---|---|---|
| Beginner / M0 | Move, jump, acquire grapple targets, release with momentum, and use one wall interaction. | Wide routes, clear targets, generous recovery geometry, one lesson at a time. | Ordinary misses expose recovery routes; failure explains the missed condition. |
| Developing / M1 | Maintain motion while reading one melee pattern and choosing a safe commitment. | Vertical approaches and one readable retaliation pressure. | Death/restart is deterministic and the damage cause is evident. |
| Intermediate / early M2 | Counter one pressure family at a time and vary route or altitude. | Distinct warnings and uncluttered pressure labs. | First failure teaches the counter; one recovery opportunity remains. |
| Advanced / late M2–M3 | Read two interacting pressures, identify target priority, and preserve a viable route. | Low/high/lateral routes change value under controllers, supports, and vertical enemies. | Combined pressure remains distinguishable and survivable after an ordinary mistake. |
| Expert / M4 | Route through boss patterns, preserve momentum, exploit openings, and recover without abandoning flow. | The Garden Heart combines only the playtest-selected production subset. | Victory reflects readable mastery, not health attrition or unavoidable overlap. |

The curve is geometry-driven: later spaces combine previously taught route and pressure questions before introducing another. Numeric damage scaling and final encounter density remain tuning outcomes and may not replace readable mechanic progression.

### Player Abilities and Unlocks

M0–M4 validates the starting traversal and combat vocabulary rather than an unlock tree. Persistent weapons, armor, loadouts, skill trees, and character progression are deferred to M6. Health and coins are the only current-scope rewards.

## Enemy and Combat-Pressure Vocabulary

### Enemy Roles

| Role | Purpose | Movement question |
|---|---|---|
| Melee pursuer | Punish stagnation and unsafe commitment. | How do I keep changing position and identify the recovery opening? |
| Ranged / spatial attacker | Make open routes, altitude, and timing conditional. | Which line, cover, height, or crossing window stays viable? |
| Route controller | Change a surface, obstacle, or grapple anchor temporarily. | How does the route’s value change without losing the full movement vocabulary? |
| Support | Create target priority and interrupt choices. | Which source or connection matters, and which counter is safest? |
| Climber / flyer | Extend pressure onto walls and into aerial routes. | How do I change altitude or route when no static safe layer exists? |
| Elite / boss | Combine learned pressures around clear openings. | Can I maintain flow, read the pattern, and commit at the right moment? |

### M2 Capability-Complete Scope

M2 prototypes every reusable pressure mechanic, but it does not productionize every enemy or presentation variant.

- **Direct and spatial threats:** direct lane shot, arcing bombardment, rotating line or plane sweep, damage gas or drifting hazard, and airburst/aerial mine lattice.
- **Displacement and movement disruption:** harpoon or tether, knockback, wind or suction, and contextual anti-wall reach.
- **Route, surface, and anchor manipulation:** adhesive surface, temporary obstacle growth, anchor modification, and temporary surface-state change.
- **Prediction, visibility, and deception:** predictive mark, visibility obstruction, and decoy or echo.
- **Support and target priority:** interruptible support tether providing healing, armor, recovery, resistance, or stagger support.

Every prototype states the question it asks, warning, dangerous space or target, active duration, outcome feedback, primary counter, recovery option, grapple and wall interactions, source-death behavior, reset behavior, overlap restrictions, and tunable values. A mechanic that only deals damage without changing a meaningful decision does not satisfy the game’s combat pillars.

### Required Combination Tests

- Direct lane shot plus temporary obstacle growth.
- Predictive mark plus knockback.
- Visibility obstruction plus melee pursuit.
- Support tether plus artillery.
- Surface-state change plus anti-wall pressure.
- Aerial mines plus directional wind.

Each combination must preserve distinguishable warnings, at least one viable response, recovery after an ordinary mistake, and a tactical choice rather than unavoidable damage or an unbroken control chain.

### Last Garden Candidate Roles

[ASSUMPTION: A-001 — Rootstalker, Spore Kite, Mycelial Weaver, and Garden Heart remain candidate Last Garden roles.] Their provisional functions preserve the design intent while OD-001 selects the production subset using M2 evidence before M3–M4 content is committed.

| Candidate | Provisional player-facing role |
|---|---|
| Rootstalker | Melee pursuit that creates recovery openings after committed pressure. |
| Spore Kite | Arcing or predicted-position pressure that changes route timing. |
| Mycelial Weaver | Route modification or support pressure that changes target priority. |
| Garden Heart | Boss-scale combination of spatial, surface, and aerial pressure with traversal-created openings. |

## World, Level, Progression, and Rewards

The long-term concept uses authored, self-contained worlds rather than one continuous open world. The active slice is the Last Garden: a vertical route with required and optional encounters, route choices, a boss objective, current-scope health/coin rewards, an exit, and clean replay.

Optional encounters may be bypassed only when the level makes the tradeoff legible through reward, safety, information, or route value. Boss completion cannot be bypassed in a standard level. Narrative, factions, and the remaining world concepts may inform names and themes but are not production dependencies for M0–M4.

## UX, Art, and Audio Requirements

### Active-Slice UX

- Show player health, authoritative grapple validity and rejection, relevant ability phase or cooldown, encounter state, and keyboard/mouse prompts without changing gameplay state.
- Provide pause/resume, settings, safe-menu return, keyboard/mouse remapping with conflict feedback, and factory-binding restoration by M3.
- Author at 1920×1080 while remaining usable at 16:10 and ultrawide Windows ratios; support UI scale, reticle size, reticle color, and high contrast.
- Keep gameplay aim canonical and unshaken; camera motion and feedback must not move or delay the point used for gameplay queries.
- Define hierarchy, flows, focus behavior, settings interactions, accessibility defaults, and error messaging in the canonical UX package.

The UX bundle does not yet exist, so OD-007 blocks full readiness and UX-dependent M3 implementation.

### Visual and Asset Requirements

| Area | M0–M4 minimum | Deferred |
|---|---|---|
| Geometry | Clear collision, route, wall, anchor, hazard, and objective silhouettes using blockout-quality assets. | Final environments for all worlds. |
| Grapple | Distinct valid, invalid/rejected, active, broken, and moving-anchor feedback. | Final rope, particles, and animation polish. |
| Combat | Warnings, affected space, active outcome, damage/displacement, recovery opening, and death remain readable. | Full attack animation and VFX roster. |
| Characters | Prototype silhouettes distinguish player, pressure role, support, elite, and boss. | Final character models, rigs, and cosmetics. |
| HUD | Functional gameplay and settings presentation defined by UX. | Final theme, localization, and production polish. |

### Active-Slice Audio Minimum

Epic 7 must prove scoped audio requests and priority for player actions, imminent enemy warnings, outcomes, encounters, UI, ambience, and music state. Missing optional audio may fall back or remain silent without changing valid gameplay. Final authored music, voice, mix, and complete sound libraries are deferred; visual presentation must remain sufficient when sound is unavailable.

## Technical and Platform Constraints

- Godot 4.7.2-stable is the accepted target engine. Renderer and physics-backend choices are architecture constraints.
- Windows PC and keyboard/mouse are the only M0–M4 shipping targets.
- Gameplay targets 1920×1080 at 60 FPS on eventual minimum-spec hardware, with high-refresh presentation as best effort and no render-rate-dependent outcomes.
- OD-008 must name minimum-spec hardware, representative content density, capture method, pass duration, peak-memory target, and level-load target before performance becomes an executable acceptance gate.
- Architecture owns class/node structure, data ownership, simulation timing, failure transport, migration strategy, and automated test seams.

## Development Scope and Milestones

| Milestone | Purpose | Exit evidence |
|---|---|---|
| M0 — Traversal Foundation | Prove expressive, reliable movement and recovery. | A repeatable route uses the whole starting vocabulary; high-speed and non-flat wall behavior remain understandable. |
| M1 — Movement-Combat Contract | Prove movement creates advantage and attacks create risk. | A moving approach differs measurably from a stationary one; damage, death, and reset are readable. |
| M2 — Combat Pressure and Ability Vocabulary | Prove all pressure mechanics and representative combinations. | Every prototype has counterplay and cleanup; the production subset is selected. |
| M3 — Encounter and Level Shell | Prove repeatable level entry, encounters, reward, death, restart, HUD, settings, and exit flow. | A non-boss sequence runs from entry through completion without stale state. |
| M4 — Boss and Complete Gameplay Slice | Prove the Last Garden boss loop. | The player defeats the Garden Heart through learned traversal-combat behavior, receives the reward, exits, and replays cleanly. |

M5 tutorial validation and M6 persistent RPG expansion are downstream, not prerequisites for M0–M4 validation.

## Development Epics

Milestones express validation gates; Epics express the canonical delivery sequence. M0 maps primarily to Epic 1, M1 to Epic 2, M2 to Epics 3–6, M3 to Epic 7, and M4 to Epic 8.

| Epic | Player value and principal delivery | Stories | Detail |
|---|---|---:|---|
| 1 — Master Expressive Traversal | Reliable input and consistent ground, air, grapple, moving-target, wall-traversal, boundary, and validation-route behavior. | 10 | [Overview](epics/epic-01-overview.md) |
| 2 — Turn Movement into Combat Advantage | One complete player attack, readable melee enemy, movement-derived combat context, health/death, reactions, and reset. | 10 | [Overview](epics/epic-02-overview.md) |
| 3 — Prove Core Combat-Pressure Patterns | Prototype contract, direct and displacement threats, decoy pressure, plus geometry-discovered climber/flyer behavior and fallbacks. | 10 | [Overview](epics/epic-03-overview.md) |
| 4 — Adapt to Route and Movement Disruption | Adhesive, predictive, sweep, hazard, anchor, wind, and surface-change pressure. | 8 | [Overview](epics/epic-04-overview.md) |
| 5 — Read Aerial, Obscured, and Coordinated Threats | Bombardment, visibility, aerial mines, support, and multi-enemy target priority. | 6 | [Overview](epics/epic-05-overview.md) |
| 6 — Survive Combined Combat Pressure | Six required combinations, vocabulary-wide evidence, overlap limits, and production-subset selection. | 8 | [Overview](epics/epic-06-overview.md) |
| 7 — Complete a Replayable Encounter-Driven Level | Encounter scope, loading, objectives, rewards, death/restart, routes, HUD, settings, audio, and validation evidence. | 17 | [Overview](epics/epic-07-overview.md) |
| 8 — Defeat the Garden Heart and Complete the Slice | Last Garden assembly, boss patterns and openings, objective, reward, exit, replay, and final evidence. | 12 | [Overview](epics/epic-08-overview.md) |

The complete 81-story inventory is in the [bounded Epic index](epics/index.md) and machine-readable [manifest](epics/manifest.json). Consumers load only the selected shard rather than concatenating the entire backlog.

## Design Requirements and Traceability

The requirement text below is authoritative for game-design behavior. “Primary delivery” identifies the Epic where completion is demonstrated; other Epics may contribute. Architecture-owned obligations remain explicitly listed afterward so identifiers do not disappear or masquerade as design authority.

### Functional Design Requirements

%%FUNCTIONAL_REQUIREMENTS%%

### Architecture-Owned Functional Obligations

%%ARCHITECTURE_FUNCTIONAL_REQUIREMENTS%%

These obligations are fully specified in [Architecture](architecture.md) and retained in the [requirements catalog](epics/requirements.md).

### Nonfunctional Design Requirements

%%NONFUNCTIONAL_REQUIREMENTS%%

The remaining technical, lifecycle, test, migration, and infrastructure requirements—NFR5, NFR13–NFR16, NFR19–NFR21, and NFR23–NFR24—are owned and dispositioned by [Architecture](architecture.md#requirement-disposition); all 24 remain in the [requirements catalog](epics/requirements.md).

## Success Metrics and Playtest Plan

| Gate | Method | Pass rule |
|---|---|---|
| Traversal comprehension | Observed M0 route plus input/contact/velocity evidence. | Players execute the vocabulary, understand failures, and recover from ordinary mistakes. |
| Movement-combat value | Repeat equivalent moving and stationary approaches in M1. | The moving approach creates a deliberate, measurable opportunity or outcome without becoming mandatory damage inflation. |
| Pressure readability | Run each M2 lab and record first-failure explanation, counter, and recovery. | Every mechanic asks a distinct question and preserves a viable response. |
| Combination agency | Run the six fixed combination scenarios from equivalent reset state. | Warnings remain distinguishable; no unavoidable damage or unbroken control chain occurs. |
| Level-loop integrity | Repeat entry, required/optional encounters, death, checkpoint/restart, reward, and exit. | No stale state, duplicate reward, or unexplained progression block survives a replay. |
| Boss mastery | Observe Last Garden boss attempts and trace openings to learned mechanics. | Victory comes from readable traversal-combat mastery rather than health attrition. |
| Performance | Capture representative release-like M3/M4 play and level loading on OD-008 hardware/content. | Stable 60 FPS at 1920×1080 for the defined duration, within the approved peak-memory and level-load targets. |
| UX/accessibility | Execute the canonical UX test matrix after OD-007. | HUD, reticle, settings, remapping, contrast, scaling, focus, and safe errors meet the approved UX specification. |

Each result records build/revision, scene, setup, input sequence, expected result, observed result, and relevant death/reset/reload behavior. Human playtests remain mandatory for feel, readability, counterplay, recovery, and tuning.

## Out of Scope and Deferred Work

- Full narrative, dialogue, cutscene, faction, and mission implementation.
- Production content for all ten worlds.
- Persistent saves, RPG progression, inventory, equipment, loadouts, and skill trees.
- Full weapon, armor, player-ability, and enemy rosters.
- Final art, animation, audio, VFX, music, voice, localization, and balance.
- Controller support, secondary platforms, networking, modding, remote services, and open-world streaming.

## Assumptions Index

| ID | Assumption | Validation / disposition |
|---|---|---|
| A-001 | [ASSUMPTION: Rootstalker, Spore Kite, Mycelial Weaver, and Garden Heart remain candidate Last Garden roles.] | Resolve through M2 evidence and OD-001 before M3–M4 production allocation. |
| A-002 | [ASSUMPTION: Current movement and Basic Strike numbers are validation baselines rather than final ship balance.] | Record M0/M1 playtest evidence and approve any baseline change through the decision log. |
| A-003 | [ASSUMPTION: Internal keyboard/mouse playtesters are sufficient for M0–M1 mechanical validation.] | Replace with the OD-007 audience and accessibility sampling plan before UX validation. |
| A-004 | [ASSUMPTION: Basic Strike is the only required player attack in the M0–M4 validation slice.] | Confirm or replace through OD-012 before M1 scope is accepted; record any later expansion as a design decision. |

## Open Decisions

| ID | Blocks | Required outcome |
|---|---|---|
| OD-001 | M3–M4 | Select the Last Garden production subset from validated M2 mechanics. |
| OD-002 | Future design | Decide which enemy-effect mechanics may later support player abilities. |
| OD-003 | M2 balance | Set acceptable hard-control and movement-cancellation limits. |
| OD-004 | M2 balance | Set the maximum readable simultaneous pressure overlap. |
| OD-005 | Tuning | Decide which tuning choices require telemetry. |
| OD-006 | Verification | Allocate automated versus playtest-only evidence per prototype. |
| OD-007 | UX / production readiness | Define audience, HUD hierarchy, accessibility, reticle, settings interactions, and the UX test matrix. |
| OD-008 | Performance acceptance | Define minimum-spec hardware, representative content density, capture method, pass duration, peak-memory target, and level-load target. |
| OD-009 | M0 tuning | Measure and approve jump apex/airtime, coyote time, jump buffering, wall-relative entry tolerance, and grapple-gravity behavior after focused traversal playtests. |
| OD-010 | M3 level flow | Define checkpoint spacing, retry-time target, and encounter-versus-checkpoint reset cadence. |
| OD-011 | M1 validation | Define the movement-derived combat advantage and its minimum pass threshold against an equivalent stationary attack. |
| OD-012 | M1 scope | Confirm Basic Strike as the only required player attack with no combo chain in M0–M4, or define the replacement scope. |

The canonical [decision log](decision-log.md#open-decisions) owns status and resolution. This table mirrors only the design consequence.

## Source Documents

- [Detailed design baseline](sources/design-library/GAME_DESIGN_DOCUMENT.md)
- [Gameplay systems](sources/design-library/GAMEPLAY_SYSTEMS.md)
- [Level and encounter design](sources/design-library/LEVEL_AND_ENCOUNTER_DESIGN.md)
- [Development roadmap](sources/design-library/DEVELOPMENT_ROADMAP.md)
- [World and narrative index](sources/design-library/WORLD_BUILDING.md)
- [Prototype technical baseline](sources/design-library/TECHNICAL_ARCHITECTURE.md)
- [Global decision log](decision-log.md)
- [Target implementation architecture](architecture.md)
- [Canonical Epic backlog](epics/index.md)
