# Investigation: Wall-Run Start, Continuation, and Exit Criteria

## Hand-off Brief

1. **What happened.** Source inspection distinguishes wall-run and wall-stick entry, maintenance, and exit gates; wall sticking additionally requires a live grapple attachment and the selected wall.
2. **Where the case stands.** Concluded for the source-level comparison; Godot MCP confirmed the editor was ready and its current player scene was stopped.
3. **What's needed next.** No further evidence is needed to answer the user's question; runtime verification is available if desired.

## Case Info

| Field            | Value |
| ---------------- | ----- |
| Ticket           | N/A |
| Date opened      | 2026-09-30 |
| Status           | Concluded |
| System           | Windows; Godot 4.7.2-stable; project `testgame` |
| Evidence sources | Godot AI MCP session/editor/log/script/scene inspection; repository source |

## Problem Statement

User asked: “What are the difference criteria for exiting, maintaining and exiting wall running”. For this explanation, interpret the first “exiting” as “entering”; no implementation change was requested.

## Evidence Inventory

| Source | Status | Notes |
| ------ | ------ | ----- |
| Godot AI MCP session/editor state | Available | Active session `testgame@17187ab35ae57813`; editor ready, current scene `res://scenes/player.tscn`, game stopped. |
| Godot AI MCP editor diagnostics | Available | 10 warning rows, including a `seed` shadow warning in `res://scripts/player_controller.gd:1195`; no errors observed in this read. |
| Godot AI MCP scene hierarchy | Available | Current player scene includes `MovementHSM/WallRunState` and `AirborneState`. |
| Wall-run source logic | Available | Controller, airborne handler, wall-run handler, and contact classification traced; exact conditions cited below. |
| Wall-stick source logic | Available | Grapple post-commit entry, wall-stick state maintenance/exits, contact identity gate, and state transitions traced in the follow-up below. |
| Tests and version history | Partial | GUT locomotion integration/contract tests exist; not run for this explanation. Git history includes wall-traversal changes; no issue/ticket or diagnostic archive was supplied. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --------------- | -------- | ------ | ----- |
| 1 | Trace entry, maintenance, exit predicates and state events across controller and state scripts | High | Done | Confirmed entry-only speed gate, shared maintenance gates, and explicit state exits. |

## Timeline of Events

| Time | Event | Source | Confidence |
| ---- | ----- | ------ | ---------- |
| 2026-09-30 | User asked for wall-run criteria comparison. | User message | Confirmed |
| 2026-09-30 | MCP listed one active `testgame` session; editor ready, player scene open, game stopped. | Godot AI MCP `session_manage(list)`, `editor_state` | Confirmed |
| 2026-09-30 | MCP inspected controller/state scripts and current scene; editor diagnostics showed warnings only. | Godot AI MCP `script_manage(read/find_symbols)`, `scene_get_hierarchy`, `logs_read` | Confirmed |
| 2026-09-30 | Source trace established shared validity, input, relationship, and outward-speed checks; only new entry applies `_can_start_wall_run`. | `scripts/player_controller.gd:894-916`, `:925-977` | Confirmed |

## Confirmed Findings

### Finding 1: Wall-run logic is owned by the player controller and a dedicated movement state

**Evidence:** `scripts/player_controller.gd:894` (`_update_wall_run_state`); `scripts/player_wall_run_state.gd` (state handler); Godot AI MCP scene hierarchy `/Player/MovementHSM/WallRunState`.

**Detail:** The active player scene contains a dedicated `WallRunState`. The controller owns the runnable-contact gate, relationship lifecycle, entry speed gate, input alignment, outward-motion check, and cleanup.

### Finding 2: Entering has a speed gate that maintenance bypasses

**Evidence:** `scripts/player_controller.gd:908-912`, `:972-977`.

**Detail:** `_can_start_wall_run` requires horizontal speed at least `wall_run_min_horizontal_speed` (default 1.0) and total velocity magnitude at most `wall_run_max_entry_speed` (default 18.0). It is called only when `is_wall_running` is false. Once already running, the minimum and maximum speed gates are skipped.

### Finding 3: Entry and maintenance share contact, outward-motion, and input requirements

**Evidence:** `scripts/player_controller.gd:894-916`, `:925-940`, `:984-1003`, `:1027-1033`; `game/player/locomotion/contact/player_contact_provider.gd:157-175`; `game/shared/physics/wall_probe.gd:13`.

**Detail:** Both paths require an airborne/non-grappling state and a current successful wall-contact frame with the expected physics step, no contact-loss flag, and an accepted `INITIAL`, `PRESERVED`, or `SWITCHED` continuity action. Horizontal velocity pointing outward through the wall rejects the run. Movement input must be nonzero and have a dot product of at least `wall_run_min_input_alignment` (default 0.2) with the run direction. Wall classification uses the wall probe's `wall_max_abs_normal_y` threshold (default 0.2).

### Finding 4: The active wall-run state has additional explicit exits

**Evidence:** `scripts/player_wall_run_state.gd:16-46`, `:49-50`; `scripts/player_controller.gd:292-304`.

**Detail:** Ground contact exits to grounded; a successfully started grapple exits to grappling; a jump press exits via wall jump only when the wall-jump relationship is valid. Failure of the shared wall-run update clears `is_wall_running` and dispatches `EVENT_WALL_RUN_FINISHED`, transitioning to airborne. Death transitions through the any-state death event, and `_exit()` clears wall-run data.

## Deduced Conclusions

### Deduction 1: The minimum-speed export's comment overstates wall-run maintenance behavior

**Based on:** Confirmed Finding 2; export comment at `scripts/player_controller.gd:23`.

**Reasoning:** The export comment says the minimum horizontal speed is required to “start or keep” wall running, but the controller invokes the speed predicate only for a non-running player.

**Conclusion:** Current source permits an established run to continue below the minimum horizontal speed, provided all other shared checks still pass.

## Hypothesized Paths

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | ------ | ------------- |
| Runtime/gameplay confirmation | Not required for a source-level answer; would confirm observed feel/state transitions | Launch the player scene through Godot MCP and inspect state while simulating movement near a wall. |

## Source Code Trace

| Element | Detail |
| ------- | ------ |
| Error origin | N/A — behavior explanation, not a reported defect. |
| Trigger | Airborne update calls `_update_wall_run_state`; when it sets `is_wall_running`, airborne dispatches `EVENT_WALL_RUN_STARTED` (`scripts/player_airborne_state.gd:26-31`). |
| Condition | See Confirmed Findings 2-4. A valid relationship is established on `INITIAL`/`SWITCHED`, established on first `PRESERVED` entry, and retained unchanged on continued `PRESERVED` frames (`scripts/player_controller.gd:951-969`). |
| Related files | `scripts/player_controller.gd`; `scripts/player_airborne_state.gd`; `scripts/player_wall_run_state.gd`; `game/player/locomotion/contact/player_contact_provider.gd`; `game/shared/physics/wall_probe.gd`. |

## Conclusion

**Confidence:** High

Wall-run entry and maintenance share wall-frame validity, non-outward horizontal motion, wall relationship, and directional input checks; only entry calls the 1.0 minimum horizontal / 18.0 maximum total speed gate. Wall-stick entry is instead grapple-assisted and post-commit, with the same entry speed and directional gates; maintenance requires a valid grapple anchor, supported original wall, grapple hold, and no outward motion. Both are condition-driven, but only wall running can re-establish its relationship on a switched wall. This is a source-level conclusion; no runtime behavior or automated tests were executed.

## Recommended Next Steps

### Fix direction

No fix requested; provide an evidence-backed explanation only.

### Diagnostic

If runtime confirmation is wanted, launch the player scene with Godot MCP and inspect `MovementHSM` while applying directional input at a wall. Do not treat the source trace as a runtime smoke result.

## Reproduction Plan

Not applicable; this is an exploration/explanation request.

## Side Findings

- Godot AI MCP reported existing editor warnings, including `SHADOWED_GLOBAL_IDENTIFIER` for `seed` in `scripts/player_controller.gd:1195`; this appears unrelated to the requested wall-run criteria.
- `wall_run_max_normal_y` is exported at `scripts/player_controller.gd:33` but has no other GDScript references; actual contact classification uses the wall probe profile's `wall_max_abs_normal_y` (`game/player/locomotion/contact/player_contact_provider.gd:166-172`, default initialized in `game/shared/physics/wall_probe.gd:13`).

## Godot AI MCP Evidence

- **Session:** `testgame@17187ab35ae57813` (Godot 4.7.2-stable, plugin/server 4.2.3).
- **Operations:** `session_manage(list)`, `editor_state`, `logs_read(source="editor")`, `script_manage(read/find_symbols)` for the player controller and wall-run state, and `scene_get_hierarchy`.
- **Observed result:** Editor ready; `res://scenes/player.tscn` open; game stopped; player hierarchy contains `MovementHSM/WallRunState`; 10 editor warning rows, no errors in the returned diagnostics.
- **Not performed:** No MCP runtime launch/input smoke test and no GUT/CLI test suite run. This request was answered by source inspection only.

## Follow-up: 2026-09-30

### New Evidence

- MCP session `testgame@17187ab35ae57813` remained active and ready; `res://scenes/player.tscn` remained open with play stopped. `editor_state` and `logs_read(source="editor")` reported readiness and the same 10 existing warnings, with no errors in the returned diagnostics.
- MCP `script_manage(find_symbols)` confirmed the controller entry points; MCP `script_manage(read)` read `res://scripts/player_wall_stick_state.gd` and `res://scripts/player_grappling_state.gd`.
- Source inspection confirmed wall-stick entry is attempted post-commit only while the grappling state submitted motion and grapple remains held; airborne-to-wall-stick is explicitly absent (`scripts/player_controller.gd:414-435`, `:1043-1070`).

### Additional Findings

| Mode | Enter | Maintain | Exit |
| ---- | ----- | -------- | ---- |
| **Wall run** | Airborne; valid runnable wall frame; not moving outward; entry speed gate (horizontal ≥ 1.0 and total ≤ 18.0); nonzero input aligned ≥ 0.2 with run direction. | Same wall-frame, outward-motion, and input-alignment checks. `PRESERVED` keeps the relationship; `SWITCHED` deliberately establishes a new one. Entry speed gate is skipped once `is_wall_running`. | Ground contact, successful grapple, valid wall jump, or a failed shared run condition. Death also leaves to the dead state. |
| **Wall stick** | Grapple state after commit; grapple attachment live and GRAPPLE held; ungrounded, valid wall frame, not moving outward; same 1.0/18.0 entry speed gate and ≥ 0.2 input alignment. The motor must accept a zero-velocity next-frame baseline. | GRAPPLE stays held; anchor sampling and attachment remain valid; supported original wall remains selected; no outward motion. No movement-input alignment or speed gate is rechecked. A switched wall or persistent-identity mismatch is unsupported and ends the hold. | GRAPPLE release (unless a supported-wall jump is pressed), valid wall-stick jump, invalid/lost/out-of-range grapple anchor, lost/switched wall support, outward motion, or death. Non-jump release preserves reference velocity; jump adds outward, along-wall, and upward components. |

### Updated Hypotheses

- Wall-stick has its own continuous speed gate: **Refuted.** `_can_start_wall_run()` is used at entry; the wall-stick state does not call it during hold. The speed-gate query at `scripts/player_controller.gd:1287-1302` is a read-only status helper, not a maintenance gate.
- Wall-stick can follow the player onto any adjacent wall: **Refuted.** `has_supported_wall_contact()` rejects `SWITCHED` continuity and, when identity is persistent, requires the selected surface identity to remain equal (`scripts/player_controller.gd:1122-1143`).

### Backlog Changes

- Wall-stick source trace: Done. Runtime playtest remains optional and was not performed.

### Updated Conclusion

Wall running begins from airborne traversal and is maintained by contact, input alignment, and outward-motion checks; it can deliberately re-establish on a switched wall. Wall sticking begins only after a grapple-driven post-commit wall contact and is maintained by the live grapple/anchor plus continued support for the selected wall; it does not recheck speed or movement alignment, but wall switching ends it. Source confidence: High; gameplay runtime and automated tests remain unverified.

## Follow-up: 2026-09-30 #2

### New Evidence

- `_try_start_wall_stick_from_contact()` and wall-run entry both call `_can_start_wall_run()`, so the current minimum and maximum are coupled (`scripts/player_controller.gd:972-977`, `:1046-1068`).
- The wall-stick telemetry gate also calls `_can_start_wall_run()` and exposes `horizontal_speed_low` (`scripts/player_controller.gd:1287-1302`; `scripts/debug_grapple_telemetry.gd:181-190`).
- Story 1.9 records the shared speed gate as part of the accepted wall-stick entry policy (`_bmad-output/implementation-artifacts/1-9-integrate-wall-traversal-and-mistake-recovery.md:131-133`, `:226`). The searched tests include `test_wall_run_entry_policy_keeps_the_authored_speed_gates` (`tests/player/locomotion/test_wall_traversal_contract.gd:164`).

### Additional Findings

- Removing only the lower wall-stick entry bound would admit wall-stick attempts with horizontal speed below 1.0, including near-zero horizontal speed, as long as total 3D speed remains at most 18.0 and the other entry conditions still pass.
- Wall-stick entry still requires nonzero movement input aligned with the derived run direction by at least 0.2. At zero horizontal velocity, `_get_wall_run_direction()` cannot orient its tangent from velocity and leaves the normal-cross-up direction unflipped (`scripts/player_controller.gd:1018-1024`); the subsequent wall-stick jump applies a full `wall_run_speed` along that cached direction (`:754-766`). This can make low-speed wall-stick jump direction less intuitive even though entry is allowed.
- The hold arms a zero next-frame velocity baseline and pins the saved committed position (`scripts/player_controller.gd:1090-1109`, `:732-738`), so the change creates a stationary/low-momentum latch where the current policy rejects it.

### Updated Hypotheses

- Low-speed-only wall-stick entry could make traversal more forgiving and remove the need to build momentum before a grappled wall latch. **Status:** Deduced from the widened predicate.
- The broader entry envelope could also allow easier stationary latching or momentum bypass around traversal obstacles. **Status:** Hypothesized; gameplay impact needs a route/playtest to confirm.
- Making the change inside `_can_start_wall_run()` would also remove the wall-run entry minimum. **Status:** Confirmed by shared call sites; use an independent wall-stick upper-speed predicate to preserve wall-run behavior.
- Leaving the telemetry helper unchanged would show low-speed wall-stick attempts as `BLOCKED` / `horizontal_speed_low` despite the new entry policy. **Status:** Confirmed by the helper implementation.

### Backlog Changes

- No implementation requested. If implemented later, update wall-stick telemetry/reason IDs, add a low-horizontal-speed acceptance case and an over-18 total-speed rejection case, preserve wall-run minimum-speed tests, and revise Story 1.9's documented shared-gate policy.

### Updated Conclusion

The change is narrow if it replaces only the wall-stick call to the shared speed helper with an upper-total-speed-only predicate. Expect more low/zero-horizontal-speed grapple-assisted latches; retain the grapple-held, valid-contact, non-outward, aligned-input, and zero-baseline conditions. The main behavioral risks are stationary-latch exploits and less intuitive along-wall jump direction at low speed. Update telemetry and Story 1.9 policy documentation; source-level impact is confirmed, while gameplay balance is unverified.

## Approved Policy Amendment and Implementation — 2026-09-30

The user subsequently approved [spec-wall-stick-upper-entry-speed.md](../spec-wall-stick-upper-entry-speed.md). Earlier findings remain historical evidence of the coupled predicate; this appendix intentionally amends that policy without rewriting the prior investigation or Story 1.9 acceptance/evidence.

- `_try_start_wall_stick_from_contact()` now uses independent `_can_start_wall_stick()`: finite total 3D speed **≤ the existing upper threshold**, with no horizontal minimum. Its read-only telemetry uses the same predicate and reports `pass` / `total_speed_high` (defensive nonfinite fallback); `horizontal_speed_low` is obsolete for sticking.
- `_can_start_wall_run()`, run entry/maintenance/relationship/state code, shared tangent/input/outward helpers, grapple-only post-commit coordination, baseline/hold/release/jump mechanics, contact/motor ownership, and UIDs remain unchanged. MCP confirmed loaded scene values **3 m/s run minimum**, **18 m/s upper**, **0.2 alignment**; the earlier 1 m/s statements described the script default, not this scene's override. The user's dirty `wall_check_distance` 0.2 edit was preserved without saving or retuning the scene.
- **GUT evidence (CLI only):** selected stick regressions **16/16, 774 assertions, exit 0**. Final focused **43/44, 1,198/1,202 assertions, exit 1**; final full recursive `res://tests`, including `tests/player/**`, **232/237, 11,728/11,740 assertions, exit 1**. The four new tests pass; the same five baseline tests remain failing (two route tests, moving-origin expectation, 120 Hz corner exit, motor authored-context tuning). Pre-edit full baseline was **228/233**. Existing tests/assertions were retained; an intermediate corner pass is variability, not a claimed fix.
- **MCP evidence:** session **`testgame@17187ab35ae57813`**; ready/stopped preflight, controller/stick/node reads, settled scans, `project_run(custom player, autosave=false)`, runtime tree/node inspection, injected command seams and two `game_eval` matrices, logs, stop/rescan/readiness. Real-Jolt initial-zero/1.5 cases at 60/120 Hz observed subminimum committed entry horizontal speeds **0.674429 / 2.163690 / 0.337117 / 1.830769**, one stick entry, zero baseline, 18 zero-speed/no-drift holds, one airborne cleanup, one idempotent release terminal, and one commit/step; the run speed gate stayed false. Real-commit/synthetic-contact smoke also confirmed exact upper and vertical/mixed boundaries, over-limit rejection, and telemetry purity.
- Native MCP adapters were **15/15** with a preload-cache warning, not GUT/wall coverage. One scratch eval parser break (nonexistent `GrappleEndResult` harness type) was recovered by stop/relaunch and a corrected eval; no successful result was claimed from the failed call. Final fresh game logs had no warnings/errors, ten existing editor warnings remained, and the editor ended ready/stopped on the player scene. No visual verification or balance/feel sign-off is claimed.
- Evidence is under `C:\Users\pinto\AppData\Local\Temp\opencode\`: `wall-stick-upper-*-gut-verified.log`, `wall-stick-upper-baseline-gut.log`, `wall-stick-upper-mcp-evidence.md`, and `wall-stick-upper-preservation.json`. The approved spec's Dev Agent Record lists exact commands, counts, diagnostics, and gate blockers. Static preservation checks and `rtk git diff --check` passed. At implementation hand-off the subagent had not reviewed, transitioned status, committed, or pushed; parent closeout follows below.

**Updated conclusion:** the requested eligibility/telemetry amendment is implemented and observed in live gameplay fixtures, with unchanged wall-run policy. The broader low-speed latch envelope is deliberate; route balance and low-speed wall-stick jump feel remain unverified, and pre-existing comprehensive regression failures remain unresolved.

## Final Implementation Closeout — 2026-09-30

After review, nonfinite-speed coverage and stricter actual-velocity/immutable-position hold assertions passed. Final selected stick regressions: **17/17, 782 assertions**; full recursive GUT: **233/238, 11,736/11,748 assertions**, with the same five pre-edit failures. Logs are `wall-stick-upper-stick-gut-closeout.log` and `wall-stick-upper-recursive-gut-closeout.log` in the evidence directory above.

MCP session `testgame@17187ab35ae57813`, final runtime `r46021510-6`, reconfirmed upper-only stick acceptance, over-limit/nonfinite rejection, unchanged run bounds, clean live logs, and ready/stopped editor. Earlier real-Jolt 60/120 Hz low-speed hold/release evidence remains the meaningful gameplay smoke; no visual/feel sign-off is claimed. Preservation and whitespace checks passed again. The baseline's submitted-entry-speed versus collision-adjusted telemetry distinction is documented in deferred work, not changed beyond the user's minimum-gate request. The amendment spec is complete; historical story/sprint status and user scene changes are preserved, with no commit or push.
