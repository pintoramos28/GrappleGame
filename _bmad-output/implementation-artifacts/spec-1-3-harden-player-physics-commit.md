---
title: 'Harden Story 1.3 Player Physics Commit'
type: 'bugfix'
created: '2026-09-11'
status: 'done'
baseline_commit: '1e8f81bfe34a6dd2bd602b3d48d772e63d648cc2'
context:
  - '{project-root}/_bmad-output/project-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/epic-1-context.md'
  - '{project-root}/_bmad-output/implementation-artifacts/1-3-centralize-the-players-physics-step-movement-commit.md'
---

<frozen-after-approval reason="human-owned intent â€” do not modify unless human renegotiates">

## Intent

**Problem:** Story 1.3 centralizes movement, but a rejected state submission can still allow an earlier request to commit, wall-stick entry can leak grapple velocity into an immediate exit, and lifecycle/diagnostic failure paths are incomplete. Production-path and equivalence evidence is also open.

**Approach:** Harden the typed motor/coordinator contract without retuning traversal, make bounded post-commit contact facts and diagnostics deterministic, then add real-Jolt regression coverage and complete MCP/GUT evidence.

## Boundaries & Constraints

**Always:** `PlayerMotor` remains the only writer of final player velocity and caller of `move_and_slide()`. The coordinator opens one numbered frame, accepts one request, commits at most once, and fails closed on any invalid or rejected request. Wall-stick entry and exit use motor-owned typed data. Contact facts and diagnostics are bounded, read-only, and observational. Preserve UIDs, input, tuning, Jolt, Godot 4.7.2, and `res://main.tscn`. Use real-Jolt fixtures and tolerant physics assertions.

**Ask First:** None; use fail-closed submission, next-frame zero-velocity wall-stick entry, deterministic bounded wall-contact prioritization, and stable rate-limited diagnostic identity.

**Never:** No second commit, state-owned body writes, Story 1.4 phases, Story 1.5 `ContactFrame`, traversal retuning, project-setting or dependency changes, deep physics mocks, or CLI-only validation.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| ACCEPTED_REQUEST | Active frame, valid request | One commit with accepted ID | None |
| REJECTED_REQUEST | Valid request followed by duplicate/invalid request | No commit or post-commit transition; player inactive | Typed submission diagnostic |
| IMMEDIATE_WALL_EXIT | Wall stick acquired, release/jump before HOLD | Zero entry baseline; no residual grapple velocity | Motor-owned result |
| CONTACT_OVERFLOW | Wall contact exceeds ordinary bound | Bounded result retains deterministic wall fact | No unbounded storage |
| REPEATED_INVARIANT | Condition repeats across steps | Stable, rate-limited identity and bounded count | No log flood |
| INVALID_LIFECYCLE | Motor/body missing, freed, detached | Inactive player; no body operation | Typed failure |

</frozen-after-approval>

## Code Map

- `scripts/player_controller.gd` -- frame choreography, submissions, wall-stick coordination, and deactivation.
- `scripts/player_*_state.gd` -- provisional movement and HOLD requests only.
- `game/player/motor/` -- lifecycle validation, single commit, and result/contact contracts.
- `game/app/logging/` -- bounded invariant diagnostics.
- `tests/player/motor/` -- motor and real-Jolt production regressions.
- `_bmad-output/implementation-artifacts/evidence/1-3/` -- MCP, GUT, load, and preservation evidence.

## Tasks & Acceptance

**Execution:**
- [x] `scripts/player_controller.gd` -- make submission status transactional, preserve accepted ID, add lifecycle guards, and define next-frame wall-stick baseline.
- [x] `game/player/motor/` and `game/app/logging/` -- validate body lifecycle, select bounded wall facts, and rate-limit stable diagnostics without changing movement phases.
- [x] `tests/player/motor/` -- cover failed submissions, immediate wall exits, contact overflow, lifecycle failures, debug assertions, real physics ticks, production traversal, and the permitted 60/120 Hz command-frame comparison.
- [x] `_bmad-output/implementation-artifacts/evidence/1-3/` plus the Story 1.3 artifact -- record MCP, GUT, load, preservation, limitations, and final status separately.

**Acceptance Criteria:**
- Given an accepted request and a later rejection, when the frame resolves, then no commit or post-commit transition runs and the player becomes inactive.
- Given wall-stick is acquired, when release or jump occurs before HOLD, then exit uses the motor-owned baseline and not residual grapple velocity.
- Given contacts exceed the ordinary bound, when coordination consumes the result, then wall facts remain available without unbounded storage or a second move.
- Given body or initialization is invalid, when capture or commit runs, then typed failure is returned and no body operation occurs.
- Given GUT and MCP checks complete, then real-Jolt paths, per-tick commit cardinality, runtime smoke, editor readiness, and limitations are recorded separately.

## Design Notes

The motor may retain the first accepted request defensively, but the coordinator treats later rejection as transaction failure. Wall-stick is discovered after movement, so entry applies next frame. Contact prioritization selects geometric facts only; the controller still owns traversal decisions. Diagnostics identify stable conditions independently of step occurrence and retain only bounded metadata.

## Review Disposition

- The completed edge review identified a real stale-state path: a grappled player could land while retaining `is_grappling`. The coordinator now clears grapple state before dispatching the landing transition, and a real-Jolt regression covers the path.
- The edge review's concern that `PlayerMotor` itself could retain the first accepted request after a rejected follow-up was rejected against the frozen design: the motor may retain that request defensively, while the production coordinator must abort the transaction and make the player inactive. The coordinator behavior is covered by the production duplicate-frame regression.
- The edge review's concern about duplicate-frame precedence after body detachment was rejected against the lifecycle matrix: invalid-body status intentionally takes precedence and avoids all body reads/writes.
- The blind and acceptance replacement review runs were terminated after producing no result; no verdict is claimed for those runs. The available edge-review findings were triaged as one patch and two rejected findings above.
- The story remains `in-review`. No human visual smoke, full normal-play wall/grapple replay, or quantitative 120 Hz pre/post traversal replay is claimed; the existing Story 1.2 60/120 command-frame cardinality regression is the permitted comparison evidence.

## Verification

**Commands:**
- `rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/motor -ginclude_subdirs -gexit` -- expected: focused motor tests pass.
- `rtk 'C:\Users\pinto\Documents\Godot Projects\Godot 4.7.2\Godot_v4.7.2-stable_win64_console.exe' --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit` -- expected: recursive player suite passes.
- `rtk git diff --check` -- expected: exit 0.

**Manual checks (Godot AI MCP):**
- Preflight active session, inspect `main.tscn`, rescan/reload affected scripts, run the relevant scene, inspect runtime motor results, simulate movement and traversal inputs, read current editor/game logs, and confirm the editor returns ready/stopped. Record MCP observations separately from CLI results.

## Suggested Review Order

**Coordinator transaction boundary**

- Start here: the coordinator defines one transactional physics step and fail-closed lifecycle.
  [`player_controller.gd:247`](../../scripts/player_controller.gd#L247)

- Rejected submissions abort the frame before commit or traversal transitions can run.
  [`player_controller.gd:322`](../../scripts/player_controller.gd#L322)

- Landing clears stale grapple state before dispatching the grounded transition.
  [`player_controller.gd:331`](../../scripts/player_controller.gd#L331)

- Wall-stick acquisition arms the zero baseline before changing locomotion state.
  [`player_controller.gd:692`](../../scripts/player_controller.gd#L692)

**Motor contract and diagnostics**

- The motor validates initialization and frame ownership before accepting movement work.
  [`player_motor.gd:133`](../../game/player/motor/player_motor.gd#L133)

- Submission and baseline APIs expose typed failures without changing movement phases.
  [`player_motor.gd:208`](../../game/player/motor/player_motor.gd#L208)

- One commit owns body writes, slide movement, result capture, and bounded collision facts.
  [`player_motor.gd:304`](../../game/player/motor/player_motor.gd#L304)

- Abort explicitly closes invalid transactions and prevents stale accepted requests from committing.
  [`player_motor.gd:425`](../../game/player/motor/player_motor.gd#L425)

- Stable diagnostic identities deduplicate repeated physics-step errors within bounded memory.
  [`game_log.gd:15`](../../game/app/logging/game_log.gd#L15)

**Regression and evidence trail**

- The new real-Jolt regression proves grapple state is cleared before landing coordination.
  [`test_player_motor_integration.gd:247`](../../tests/player/motor/test_player_motor_integration.gd#L247)

- Focused motor tests exercise lifecycle, rejection, baseline, overflow, and diagnostic contracts.
  [`test_player_motor.gd:105`](../../tests/player/motor/test_player_motor.gd#L105)

- Final MCP observations and harness boundaries are recorded separately from pinned GUT results.
  [`mcp-verification.md:85`](evidence/1-3/mcp-verification.md#L85)

- Final counts, expected diagnostics, and teardown limitations are summarized for review.
  [`focused-gut.md:17`](evidence/1-3/focused-gut.md#L17)
