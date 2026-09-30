---
title: 'Reject outward motion during wall traversal'
type: 'bugfix'
created: '2026-09-27'
status: 'in-review'
baseline_commit: '00a3026fa3336c921b9c283849c61efaf841b354'
context:
  - '{project-root}/_bmad-output/project-context.md'
  - '{project-root}/_bmad-output/planning-artifacts/architecture.md'
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Wall-run and grapple-assisted wall-stick policies can currently accept traversal while the player has outward velocity relative to the selected wall. Wall-run motion later removes outward velocity in the motor, but that correction does not prevent an invalid state entry; wall-stick can hold despite the same separating motion.

**Approach:** Add one shared controller predicate based on horizontal velocity projected onto the horizontal outward wall normal. Reject outward speed beyond the cancellation-relative floating-point roundoff bound when entering or maintaining either WallRun or WallStick; treat only residuals within that bound as zero. Preserve intentional wall jumps: they leave the traversal state and launch outward.

## Boundaries & Constraints

**Always:** Use the authoritative ContactFrame wall normal and the velocity already supplied by the current motion transaction. Flatten both vectors to the horizontal plane before projection so wall-normal vertical tolerance does not mix with vertical velocity. Apply the predicate on WallRun entry and maintenance, WallStick entry and hold. When an active WallStick becomes invalid due to outward motion, use its existing state-cancellation cleanup and airborne release route exactly once. Preserve current speed gates, input alignment, contact continuity, grapple sampling, motor ownership, and one-commit-per-step rules.

**Ask First:** If a correct implementation requires changing PlayerMotor's hold/constraint contract, scene tuning, or wall-jump impulse semantics, stop and ask before making that additional change.

**Never:** Do not alter wall-run speed/alignment thresholds, wall-jump launch velocity, wall-contact provider/query behavior, input bindings, or unrelated scene/project settings. Do not prevent the explicit WallRun/WallStick jump exit from launching away from the wall.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| TANGENTIAL_OR_INWARD | Valid wall; outward-normal velocity projection is zero or negative, including cancellation-scale floating-point residuals | WallRun/WallStick eligibility is unchanged | N/A |
| OUTWARD_ENTRY | Valid wall; horizontal velocity has positive projection onto outward normal | Do not enter WallRun or WallStick | Remain/route to Airborne; do not fabricate contact loss |
| OUTWARD_DURING_RUN | WallRun active; a later step has positive outward projection | Clear wall-run relation; transition to Airborne once | Preserve normal non-wall-run velocity policy |
| OUTWARD_DURING_STICK | WallStick active; no fresh jump edge; outward projection becomes positive | Terminate grapple as STATE_CANCELLATION, clear hold, route to Airborne once | Preserve recoverable velocity and idempotent cleanup |
| INTENTIONAL_WALL_JUMP | Fresh valid jump edge from WallRun or WallStick | Existing upward/away jump submits once and leaves traversal state | Do not reject the jump because its submitted impulse is outward |

</frozen-after-approval>

## Code Map

- `scripts/player_controller.gd` -- add the shared projection predicate; gate `_update_wall_run_state()` and `_try_start_wall_stick_from_contact()`; keep their existing independent speed/input/contact policies.
- `scripts/player_wall_stick_state.gd` -- exit an active hold through the current typed cancellation path when its incoming velocity is separating from the selected wall; keep jump priority and anchor/contact checks.
- `game/player/motor/player_motor.gd` -- existing wall-run constraint already removes outward velocity; inspect only, do not change unless required and approved.
- `tests/player/locomotion/test_wall_traversal_contract.gd` -- unit/contract cases for outward, tangent, and inward projections.
- `tests/player/locomotion/test_wall_traversal_integration.gd` -- real-Jolt entry/maintenance/cleanup and jump-regression coverage.

## Tasks & Acceptance

**Execution:**
- [x] `scripts/player_controller.gd` -- implement one horizontal outward-speed predicate and apply it to WallRun entry/continued validity and post-commit WallStick entry -- prevent separating movement from qualifying as wall traversal without changing unrelated speed or alignment gates.
- [x] `scripts/player_wall_stick_state.gd` -- cancel a held WallStick when incoming velocity is outward, except when the current fresh jump edge intentionally exits -- ensure no hold constraint or attachment remains after the exit.
- [x] `tests/player/locomotion/test_wall_traversal_contract.gd` -- cover positive, zero, and negative normal projections, including sloped wall normals -- lock down the sign and horizontal-only math.
- [x] `tests/player/locomotion/test_wall_traversal_integration.gd` -- exercise outward entry rejection and active exits for both states, plus intentional jumps and exactly-once grapple cleanup -- protect real motor/HSM behavior.

**Acceptance Criteria:**
- Given a supported wall and an otherwise-valid WallRun entry, when horizontal velocity projects positively beyond the roundoff bound onto the outward wall normal, then WallRun does not start.
- Given WallRun is active, when a later policy update has outward-normal velocity beyond the roundoff bound, then the wall-run relationship clears and the player exits to Airborne once.
- Given a supported wall and an otherwise-valid grapple-assisted WallStick entry, when entry velocity projects positively beyond the roundoff bound onto the outward normal, then WallStick does not start.
- Given WallStick is active without a fresh jump edge, when incoming velocity projects positively beyond the roundoff bound onto its selected wall's outward normal, then the grapple ends once with `STATE_CANCELLATION`, the hold is not submitted again, and locomotion exits to Airborne.
- Given a valid WallRun or WallStick jump press, when its intentional away-from-wall impulse is submitted, then the existing jump exit remains available and occurs once.
- Given zero or inward normal velocity, when all existing contact, speed, grapple, and input gates pass, then existing wall traversal behavior remains unchanged.

## Design Notes

For velocity `v` and outward normal `n`, use `v_h = (v.x, 0, v.z)`, `n_h = normalize((n.x, 0, n.z))`, and `outward_speed = v_h.dot(n_h)`. Positive is separating; zero is tangent; negative is toward the wall. Do not use the tangent input-alignment dot as a substitute. Godot `Vector3` components are single precision, so cancellation between the horizontal dot-product terms can leave a tiny positive residual for an exactly tangent vector. Treat only `outward_speed <= 4 * 1.1920928955078125e-7 * (abs(v_h.x*n_h.x) + abs(v_h.z*n_h.z))` as representational zero. This is a cancellation-relative arithmetic bound, not a fixed gameplay-speed dead zone: direct outward motion, including `1e-6 m/s`, remains rejectable. WallStick jump handling must take precedence over the active-hold rejection because that command intentionally ends sticking and launches away.

## Verification

**Commands:**
- Pinned recursive GUT: `Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit` -- expected: all recursive player tests pass.
- Pinned editor import/load: `Godot_v4.7.2-stable_win64_console.exe --headless --editor --path . --quit` -- expected: exit 0 and no new parse errors.
- `git diff --check` -- expected: exit 0.

**Manual checks (if no CLI):** Godot AI MCP live session verifies editor readiness, affected script reload, both traversal routes, one-commit behavior, cleanup, and intentional jump exit. Report GUT and MCP results separately; do not treat MCP-native tests as recursive GUT coverage.

**Observed results:**
- `git diff --check` passed.
- The latest pinned recursive GUT 9.7.1 run executed 220 tests across 15 scripts: 219 passed / 1 failed. Both changed traversal suites passed: integration 20/20 (including the shallow-corner case at 60 and 120 Hz) and contract 20/20. The sole remaining failure is `test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band` at `test_player_motor_integration.gd:375,379`; its assertions conflict with pre-existing dirty `scenes/player.tscn`/`main.tscn` tuning. The stale hard-coded wall-run threshold assertion was corrected to test immediately below/at/above the loaded controller's configured boundaries. No scene changes were made.
- The previously non-parsing `test_wall_traversal_integration.gd` now parses and runs. At 120 Hz, the shallow-corner fixture reaches a switched wall relation with material positive outward projection and correctly exits once; at 60 Hz it continues on the supported seam. The test records and asserts that distinction rather than requiring identical exits at both rates.
- The projection contract test passes: it filters a positive residual from fast tangential components while still rejecting a direct outward projection of `1e-6 m/s`.
- After the contract fixture edit, Godot AI MCP `test_run` again reported 15 passed / 0 failed in direct MCP suites. It warned that preloaded GDScript dependencies may be stale; this is not a GUT result or coverage of these locomotion tests.
- MCP live smoke checks used isolated real-player/Jolt fixtures: both outward-entry cases had every other eligibility gate open and were rejected. Active WallRun maintenance had valid supported contact and aligned input alongside positive outward speed, then exited to Airborne while preserving velocity; an outward-reference wall jump still launched once. Active WallStick cancellation had supported selected-wall contact, submitted no hold, and reached Airborne next step. An outward-reference WallStick jump launched once with the authored `(10, 5.5, 8)` velocity. Outward motion concurrent with an observed released Grapple command cancelled; a fresh supported jump plus an observed released Grapple command still launched once with the authored jump velocity. On lost wall contact, simultaneous fresh jump plus released Grapple produced zero wall-jump impulses and a `RELEASE` terminal. The WallRun exit and WallStick post-exit commits each reported `commit_count = 1`.
- The current MCP session launched `res://scenes/player.tscn`; `project_run` first reported the existing autoload errors, then `editor_state` confirmed the helper live. Runtime `game_eval` confirmed the positive tangent residual was allowed while direct outward projections of `1e-6` and `0.01 m/s` were rejected. The game was stopped afterward and the editor ended `ready` on the player scene. Earlier scratch-eval parser errors were caused by eval code, not project scripts.
- The pinned headless editor import/load command completed its scan but reported a LimboAI editor DLL copy/load error and the pre-existing unrecognized autoload UID (`uid://duq6jhf6unyis`), which resolves to an invalid `.` path. This is not a clean import/load pass.

## Spec Change Log

## Implementation Notes

- Added one horizontal outward-speed predicate in `scripts/player_controller.gd`, using the current transaction velocity and authoritative `ContactFrame.wall_normal`; it filters only cancellation-relative floating-point residuals and applies to WallRun entry/maintenance and post-commit WallStick entry.
- Active WallStick now routes separating motion through its existing `STATE_CANCELLATION`, velocity passthrough, and airborne release cleanup. The fresh jump branch remains ahead of this hold check.
- Added projection contract cases and real-Jolt regression scenarios for both states, including outward-reference wall jumps, exactly-once grapple termination, and inward-motion baseline fixtures.
- The entry-speed contract now reads the controller's configured min/max exports and tests both sides of those values, avoiding stale hard-coded defaults when a scene overrides them.
- Corrected the WallStick outward-entry integration fixture to give its seed an outward world hit position; its previous default seed pulled inward, invalidating that case.
- When outward motion coincides with grapple release, the WallStick state now classifies the exit as `STATE_CANCELLATION` unless a fresh jump edge is present; a dedicated integration case pins that precedence.
- A fresh WallStick jump on a still-supported selected wall also takes priority over a simultaneous grapple release; unsupported/lost-wall jumps retain the ordinary release exit.

## Dev Agent Record

- **Godot AI MCP sessions:** current final verification `grapplegame@cc9f18a8fee838ac` and earlier story smoke session `grapplegame@158d53ec546cd5b1` (Godot 4.7.2-stable).
- **MCP operations:** read-only session/editor/log and affected-resource preflight; `filesystem_manage(scan)`; `script_manage(read/find_symbols)` and parse-validated `script_patch`; direct MCP `test_run(verbose=true)`; runtime `project_run`, scene-tree/node inspection, simulated input, and `game_eval` checks; final editor state/log inspection. The current-session runtime eval confirmed that a positive tangential cancellation residual is allowed and direct outward projections of `1e-6` and `0.01 m/s` are rejected.
- **MCP results:** the final scan settled with 115 registered global classes and no class-table delta. Direct MCP tests reported 15 passed / 0 failed across three suites, with a stale-preload warning; they are not recursive GUT coverage. Earlier real-Jolt fixtures confirmed outward entry rejection for both states with other entry gates open, a full supported/input-aligned WallRun maintenance witness and exit, both intentional outward wall jumps (including jump plus Grapple release), active WallStick cancellation/cleanup with supported selected-wall contact, command-frame-confirmed Grapple release precedence, lost-wall jump/release rejection, and Airborne next-step transitions. The WallRun exit and WallStick post-exit commits each reported one commit. The active MCP session reported Godot AI plugin/server 4.2.3 while project context documents 3.2.4; no tool-version change was made. Final editor state is ready/stopped on `res://scenes/player.tscn`.
- **MCP diagnostics:** the MCP-native runner discovers only its direct `McpTestSuite` scripts and is not the recursive GUT runner; its passing 15-test result does not cover the changed locomotion GUT suites. Editor logs retain the unresolved autoload UID error from the pre-existing modified `project.godot` and unrelated existing GDScript warnings. The latest player-scene run became live after those startup errors; no story-related project-script runtime errors were observed.
- **CLI/tool results:** latest pinned recursive GUT completed with 219/220 passing as detailed above; both changed traversal suites passed. The pinned editor import/load command reported LimboAI DLL copy/load errors and the pre-existing unresolved UID/autoload path; no clean CLI import pass is claimed. `rtk` is unavailable. `git diff --check` passed. MCP-native results are recorded separately and are not claimed as GUT coverage.
- **Review:** the WallRun maintenance witness proves supported contact, aligned input, and positive outward projection before the exit step. WallStick's selected normal is the authoritative ContactFrame normal captured at entry and intentionally stays stable across preserved-contact noise; `has_supported_wall_contact()` rejects lost/switched wall relationships before the fresh-jump path. Outward motion plus release uses `STATE_CANCELLATION`, while a fresh supported jump takes priority over simultaneous Grapple release; regressions assert the captured command is released and supported selected-wall contact exists. A dedicated regression confirms that simultaneous fresh jump/release after wall loss cannot jump from stale contact. A null captured command frame is intercepted by the controller before HSM update, so no valid motion transaction reaches the state-level null-frame fallback; no story behavior is claimed for that path. The corner regression exposed floating-point tangential residuals; the shared predicate now filters only the cancellation-relative single-precision bound, with direct small-outward coverage. The single remaining GUT failure conflicts with pre-existing dirty scene tuning, which remains untouched. The pinned import/load errors and MCP plugin/server version mismatch also remain. Keep status `in-review` until the recursive suite is green or the scene-tuning conflict is isolated/authorized and the import/load blocker is resolved.
