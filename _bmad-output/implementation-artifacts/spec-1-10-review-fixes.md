---
title: 'Story 1.10 review fixes'
type: 'bugfix'
created: '2026-10-02'
status: 'done'
baseline_commit: '2f56b7d39883762c96430d7389fdfb2b4fca02cb'
story_key: '1-10-complete-the-focused-traversal-validation-route'
context: ['_bmad-output/project-context.md', 'AGENTS.md']
---

<frozen-after-approval reason="human-owned intent — Pinto approved Apply all after the R1–R11 walkthrough">

## Intent

**Problem:** Story 1.10's automation fails three scripted traversal cases and omits important outcome checks. Pinto has manually confirmed that the route and player movement are good; automation failures do not authorize altering approved gameplay.

**Approach:** Apply R1–R11 from the completed review by repairing command-driven fixtures, their timing and their observed-result assertions. Validate the unchanged production route with pinned GUT and complementary live Godot AI MCP evidence.

## Boundaries & Constraints

**Always:** Preserve production movement, scene geometry, authored Resources, identifiers, UIDs and main launch path. Use canonical command-frame aiming and injected inputs, actual committed motor/contact facts and seconds-based rate comparisons. Separate production-tuned route completion, isolated constraint probes, native schema tests, GUT and human evidence. Preserve existing review documentation and keep external gates visible.

**Ask First:** Any production tuning/layout change, repair of unrelated regression failures, milestone approval or exception to mandatory MCP availability.

**Never:** Teleport within a completion/recovery attempt, write player motion, call physics manually, pre-capture future command frames, add duplicate gameplay queries, weaken outcome assertions, stage/commit/push without authorization, or claim formal M0/OD-009 acceptance.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|---|---|---|---|
| Completion | Authored spawn, production tuning, injected traversal inputs at 60/120 Hz | Same-instance completion, four intended landings, accepted ground/wall impulses, preserved release vectors | Bounded failure with current commit/stage evidence |
| Recovery | Missed jump/grapple, early release, lost run, short wall jump, target invalidation | Real catch followed by upper-route return and another accepted traversal command, without reload | Preserve actual failure type and report stalled strategy |
| Constraint | Short attachment driven outward, tangent, inward; moving retreat | Active 35 m limit, no unwanted inward/tangential alteration, no slack carry, measured taut carry | Distinguish published phase facts from independent measured endpoint |
| Wall/air | Oblique transition, unsupported slope contact, changed airborne input | Correct stamped wall facts, continuous supported corner, unsupported rejection, committed steering effect | Missing diagnostics or coverage fails explicitly |

</frozen-after-approval>

## Code Map

- `tests/levels/test_traversal_validation_route.gd` — canonical route GUT gate and fixture lifecycle.
- `tests/fixtures/traversal_route_driver.gd` — production-input driver and post-player observer shared with live MCP.
- `tests/fixtures/traversal_boundary_probe.gd` — explicitly isolated constraint-phase probe.
- `game/levels/content/traversal_validation/traversal_validation_route.tscn` — approved authored bodies; read-only.
- `scripts/player_controller.gd`, `game/player/motor/player_motor.gd`, `game/shared/physics/contact_frame.gd` — authoritative sequencing/contracts; read-only.

## Tasks & Acceptance

**Execution:**
- [x] `tests/fixtures/traversal_route_driver.gd` — finish deterministic traversal/recovery schedules; record every commit, exact accepted impulse occurrences, current wall facts, named support and first release commit; bound stalled observers independently.
- [x] `tests/fixtures/traversal_boundary_probe.gd` — verify measured target motion/local-hit tracking and constraint-stage slack/taut/outward/inward/tangent behavior, with strict diagnostic presence checks.
- [x] `tests/levels/test_traversal_validation_route.gd` — exercise both rates, all six recovery classes, changed air input, exact named landings, accepted wall jump, physical finish and clean lifecycle; retain existing comparison tolerances.
- [x] `_bmad-output/implementation-artifacts/evidence/1-10/review-fixes-2026-10-02.md` — record final gates, hardening triage, MCP session/operations/diagnostics and production preservation; update story findings only when proven.

**Acceptance Criteria:**
- Given the approved route, when the focused canonical suite runs, then all repaired route assertions pass at 60 and 120 Hz without production changes.
- Given each ordinary failure, when the recovery replay runs, then the original player returns to identified upper-route support and resumes with an accepted command.
- Given the isolated boundary fixture, when the tether becomes taut, then phase vectors and independent committed separation demonstrate the real 35 m constraint and moving carry.
- Given live Godot, when both-rate smoke checks and reloads run, then inspected runtime facts match the tested outcomes and the editor returns ready with diagnostics honestly recorded.
- Given pre-existing player failures and formal gates, when reporting completion of these fixes, then they remain identifiable, deferred and unclaimed.

## Spec Change Log

- 2026-10-02 resume: persisted this restatement of the already approved R1–R11 scope after earlier implementation began without a separate quick-dev spec. It does not retroactively claim a pre-edit artifact or introduce new intent.
- 2026-10-02 final check: strengthened existing oracle implementation (applied/committed impulses, post-takeoff air input, actual request-step rejection, current wall samples, fixed initial local hit, delta/wait guards and committed unsupported-face rejection). No frozen intent or production work changed. The face oracle distinguishes the authored sloped face from legitimate box side/bevel contacts; the acceptance auditor confirmed that correction statically.

## Design Notes

The observer runs after the production player and deduplicates `commit.physics_step`; coroutine wakeups can miss commits at 120 Hz. Named support combines stamped candidates with existing committed slide collisions and physical bounds. The boundary probe uses private pre-tree zero-pull/zero-gravity setup only to isolate the constraint; production completion never uses that setup.

## Verification

- Pinned Godot 4.7.2/GUT 9.7.1 via `rtk proxy`, `-gtest=res://tests/levels/test_traversal_validation_route.gd -gexit` — focused gate must pass.
- Same pinned CLI, `-gdir=res://tests/player -ginclude_subdirs -gexit` — report recursive regression results separately; do not repair R12.
- Godot AI MCP scan, script reload/diagnostics, native suite, fresh route/main launches, runtime observer facts and logs — complementary live gate, not claimed as GUT parity.
- `rtk git diff --check` and production path diff — clean whitespace, no gameplay/tuning/layout edits.

## Implementation Result

All R1–R11 repairs and the thirteen concrete hardening gaps are covered. Final normal-speed focused GUT is **13/13, 818 assertions**, exit **0**, **248.846 s**, including the final independent-review corrections; recursive player GUT remains **272/279**, exit **1**, with the seven pre-existing identities. MCP `testgame@17187ab35ae57813` separately observes production-tuned completion in **12.916667/12.900000 s**, all six named catch/ramp/upper-route returns, isolated taut constraints/carry, a real finish screenshot, main launch and retained UIDs. Final-source MCP rechecks additionally confirm committed launch vectors, actual request-step rejection/recovery, authoritative unsupported-face rejection and steering begun only after takeoff. Native schema results are **4/4 wall-stick, 6/6 moving-target, 4/5 boundary**; the untouched boundary pull expectation is external. See [full evidence](evidence/1-10/review-fixes-2026-10-02.md) and [deferrals](deferred-work.md).

`done` applies only to this authorized repair spec. Story/sprint remain **in-progress** for unfinished formal/external gates; automatic story promotion and local commit are intentionally withheld to honor the frozen boundaries, not presented as completed workflow operations. No staging, commit or push occurred.

## Suggested Review Order

**Route outcome and committed evidence**

- Start with the dual-rate uninterrupted route: exact destinations, impulses, releases and timing.
  [`test_traversal_validation_route.gd:116`](../../tests/levels/test_traversal_validation_route.gd#L116)
- Sample after the player; reject stale steps and bound missing commits independently.
  [`traversal_route_driver.gd:59`](../../tests/fixtures/traversal_route_driver.gd#L59)
- Count accepted and applied jump occurrences; distinguish launch intent from committed motion.
  [`traversal_route_driver.gd:577`](../../tests/fixtures/traversal_route_driver.gd#L577)

**Recovery and physical support**

- Follow six actual failures through authored catches and ramp to a next-step resume jump.
  [`traversal_route_driver.gd:412`](../../tests/fixtures/traversal_route_driver.gd#L412)
- Require named support and physical bounds instead of broad grounded-position guesses.
  [`traversal_route_driver.gd:465`](../../tests/fixtures/traversal_route_driver.gd#L465)

**Boundary, wall and air oracles**

- Compare constraint vectors against independent endpoint/motion measurements in explicitly isolated probes.
  [`traversal_boundary_probe.gd:86`](../../tests/fixtures/traversal_boundary_probe.gd#L86)
- Require committed rejection of the unsupported face, not merely inactive abilities.
  [`traversal_route_driver.gd:167`](../../tests/fixtures/traversal_route_driver.gd#L167)
- Begin changed steering input only after committed takeoff.
  [`traversal_route_driver.gd:375`](../../tests/fixtures/traversal_route_driver.gd#L375)

**Verification and remaining gates**

- Check separate GUT/MCP results, retained diagnostics, hardening dispositions and preservation evidence.
  [`review-fixes-2026-10-02.md:1`](evidence/1-10/review-fixes-2026-10-02.md#L1)
- Keep external regressions and formal milestone decisions outside this completed repair scope.
  [`deferred-work.md:35`](deferred-work.md#L35)
