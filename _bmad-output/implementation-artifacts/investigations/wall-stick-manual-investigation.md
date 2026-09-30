# Investigation: Manual wall-stick entry

## Hand-off Brief

1. **What happened.** Wall stick is an automatic transition out of active grappling, gated by a current side-wall contact, held grapple, aligned movement, and speed/contact checks.
2. **Where the case stands.** Concluded from the transition, input, contact-provider, scene-setting, and test source; no gameplay input sequence was simulated.
3. **What's needed next.** On a manual attempt, jump, acquire a valid grapple target with right mouse, keep it held, and move along the wall; use the checklist below if entry still fails.

## Case Info

| Field            | Value |
| ---------------- | ----- |
| Ticket           | N/A |
| Date opened      | 2026-09-27 |
| Status           | Concluded |
| System           | Godot 4.7.2-stable; Windows; active Godot AI session `grapplegame@158d53ec546cd5b1` |
| Evidence sources | Godot AI MCP session/scene/script outline/logs; delegated source trace; project input map, wall-probe resource, player scene settings, and focused GUT test source |

## Problem Statement

User asks what conditions achieve a wall stick and reports being unable to get into one manually.

## Evidence Inventory

| Source | Status | Notes |
| ------ | ------ | ----- |
| Godot AI session/editor state | Available | Active project session; `res://scenes/player.tscn` open and game live. |
| Active player scene hierarchy | Available | `/Player/MovementHSM/WallStickState` is present. |
| Wall-stick state source | Available | MCP read of `res://scripts/player_wall_stick_state.gd`; entry transition remains to be located. |
| User's exact manual inputs / attempted setup | Missing | No action sequence or target-wall details supplied. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --------------- | -------- | ------ | ----- |
| 1 | Trace state-transition request into `WallStickState` and identify its gameplay predicates | High | Done | Transition and manual input sequence are documented in Follow-up #2. |

## Timeline of Events

| Time | Event | Source | Confidence |
| ---- | ----- | ------ | ---------- |
| 2026-09-27 | Active editor reports player scene is live. | Godot AI `session_manage(list)` and `editor_state` | Confirmed |
| 2026-09-27 | Active scene hierarchy includes `MovementHSM/WallStickState`. | Godot AI `scene_get_hierarchy` | Confirmed |

## Confirmed Findings

### Finding 1: The wall-stick state is present and has a live update path

**Evidence:** Godot AI MCP read of `res://scripts/player_wall_stick_state.gd`; active hierarchy `/Player/MovementHSM/WallStickState`.

**Detail:** The state update reads a player command frame, checks grapple input and supported wall contact, and has hold/release handling. The condition that transitions into the state is outside this script and remains untraced.

## Deduced Conclusions

None yet.

## Hypothesized Paths

### Hypothesis 1: Wall stick is gated by a grapple/contact setup rather than wall proximity alone

**Status:** Confirmed

**Theory:** Manually touching a wall may be insufficient; the entry path likely depends on grapple state plus supported wall contact.

**Supporting indicators:** The wall-stick state reads grapple input and checks supported wall contact while active.

**Would confirm:** The transition code gates entry on grapple state/input and a selected, supported wall contact.

**Would refute:** The transition code permits entry from wall proximity/contact without a grapple requirement.

**Resolution:** Confirmed by `scripts/player_controller.gd:289, 402-423, 998-1040`: entry is only dispatched from the grappling path after held-grapple, non-grounded current contact, runnable wall, inward-or-tangent velocity, speed gate, and movement-alignment checks. There is no dedicated wall-stick button.

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | ------ | ------------- |
| Entry transition and its full conditions | Needed to answer how to initiate wall stick reliably. | Trace movement HSM event/transition code and supporting contact/grapple methods. |
| Exact inputs the user tried | Needed to distinguish an incorrect sequence from runtime/input or scene-specific behavior. | Ask user if code-defined steps do not fully explain the symptom. |

## Source Code Trace

| Element | Detail |
| ------- | ------ |
| Error origin | No error reported. Entry is dispatched from the post-commit grappling path in `scripts/player_controller.gd:402-423`. |
| Trigger | A valid grapple remains held while a qualifying wall contact is committed and aligned movement/speed checks pass. |
| Condition | Current-step non-grounded frame; runnable side-wall contact; GRAPPLE held; movement aligned with derived wall-run direction; horizontal speed meets scene minimum 3 m/s; total entry speed does not exceed 18 m/s; velocity is not outward from the wall. |
| Related files | `scripts/player_controller.gd:903-1040`; `game/player/locomotion/contact/player_contact_provider.gd:157-175`; `game/player/input/player_input_source.gd:287-322`; `project.godot:33-70`; `scenes/player.tscn:46-58`. |

## Conclusion

**Confidence:** High for source-defined entry conditions; Medium for an exact WASD key on a particular wall, because the run direction is calculated from current wall normal/player movement and no live input reproduction was performed.

Wall stick is automatic, not a separately bound action. Jump if grounded, grapple a currently valid target with right mouse and keep it held, then move along a supported side wall at the required speed. The wall-stick transition is dispatched only when the post-commit contact frame and all movement/contact gates pass. See Follow-up #2 for exact predicates and citations.

## Recommended Next Steps

### Fix direction

No code change is indicated by this question alone. If a valid setup still fails, compare the current wall normal, contact continuity, grapple-held state, movement alignment, and speed against the gates below. Note the scene-vs-test speed-threshold discrepancy: the main player scene uses 3 m/s even though a contract test asserts a 1 m/s default case.

### Diagnostic

For a failed attempt, capture the live `GrappleTelemetry` gate/status and current input/velocity/contact frame. A clean isolated live reproduction is still unverified.

## Reproduction Plan

1. If grounded, press Space to jump; wall-stick entry requires the committed contact frame to be non-grounded (not a particular HSM state named Airborne).
2. Aim at a currently accepted grapple target and press right mouse (`fire_grapple`).
3. Keep right mouse held while grappling; on the entry physics step, press a movement direction whose world-space result runs along the wall.
4. Contact a side wall recognized by the player `WallProbe`, while meeting the speed and inward/tangent-velocity gates below. No separate wall-stick key or jump press starts the state.
5. Expected state transition: `GrapplingState` -> `WallStickState` on `EVENT_WALL_STICK_STARTED`. This procedure is code-derived; it was not runtime-simulated.

## Side Findings

- Godot AI session `grapplegame@158d53ec546cd5b1` remained connected; final MCP state reported `res://main.tscn` live with the game helper active and a `/Main/World/Player/MovementHSM` hierarchy.

## Follow-up: 2026-09-27 #2

### New Evidence

- Delegated read-only trace returned the call path and focused source locations; no files were changed and no tests were run.
- **State route:** `scripts/player_controller.gd:289` wires `GrapplingState -> WallStickState` on `EVENT_WALL_STICK_STARTED`. Post-commit processing calls `_try_start_wall_stick_from_contact(...)` only for the grappling locomotion result and dispatches the event only when the helper succeeds (`scripts/player_controller.gd:402-423`). There is no direct Airborne-to-WallStick transition (`scripts/player_controller.gd:280-295`).
- **Caller/contact-frame gates:** the contact frame must be non-null, belong to the just-committed physics step, and not be grounded (`scripts/player_controller.gd:402-420`).
- **Helper gates:** entry is refused if already sticking, not actively grappling, the current command frame is null or grapple is not held, the frame is null/grounded, the wall is not runnable, entry velocity is outward from the wall, or the wall speed gate fails (`scripts/player_controller.gd:998-1040`).
- **Runnable contact:** a same-step wall frame is required; the wall query must have succeeded, contact must not be marked lost, a wall candidate must exist, and continuity must be `INITIAL`, `PRESERVED`, or `SWITCHED`. `LOST`, `UNAVAILABLE`, absent contact, failed query, or stale step do not qualify (`scripts/player_controller.gd:907-922`). Contact candidates classify as side walls at `abs(normal.y) <= 0.2` in the assigned wall profile (`game/player/locomotion/contact/player_contact_provider.gd:157-175`; `game/shared/physics/wall_probe.tres:5-17`).
- **Movement direction:** input must be nonzero and its normalized world direction must have a dot product of at least `wall_run_min_input_alignment` (0.2) with the derived wall-run direction (`scripts/player_controller.gd:979-1003, 1035-1040`). The derived direction follows the wall; there is no universal fixed WASD key.
- **Speed/direction:** the horizontal component of entry velocity must be at least `wall_run_min_horizontal_speed`; total 3D entry speed must be at most `wall_run_max_entry_speed`; positive outward velocity along the wall normal is rejected (`scripts/player_controller.gd:954-959, 1028-1033`). The main player scene overrides the horizontal minimum to 3 m/s; total-speed cap is 18 m/s (`scenes/player.tscn:46-58`; script defaults `scripts/player_controller.gd:19-23`). A contract test checks 1 m/s against a default-style gate, while the scene uses 3 m/s; this discrepancy is source-observed and the tests were not run (`tests/player/locomotion/test_wall_traversal_contract.gd:164-213`).
- **Wall sensing:** the assigned `WallProbe` queries the `world_geometry` layer and uses a 0.8 m probe distance/sweep cap (`game/shared/physics/wall_probe.tres:5-17`). A newly generated collision is not mandatory if a wall candidate is retained as `PRESERVED` inside its two-step continuity window (`game/player/locomotion/contact/player_contact_provider.gd:359-451, 492-574`).
- **Manual controls:** `fire_grapple` is mapped to mouse button 2/right mouse; jump is Space; movement actions map to WASD (`project.godot:33-70`). Input source maps the held `fire_grapple` action to `PlayerCommandFrame.Action.GRAPPLE` (`game/player/input/player_input_source.gd:287-322`; `game/player/input/player_command_frame.gd:5-78`).
- **Grapple prerequisite:** a current accepted targeting result and valid attachment are required; merely pressing right mouse without a valid grapple target does not produce the grappling state (`scripts/player_controller.gd:542-557, 1125-1195`). The grapple target need not be the wall-stick contact surface.
- **Internal setup:** `_set_wall_stick` also requires a valid motor and successful next-frame zero-velocity baseline submission (`scripts/player_controller.gd:1043-1080`); this is an internal safety gate, not another input.

### Additional Findings

- A reliable manual attempt is: jump if on the ground; aim at a valid grapple target; press and keep holding right mouse; while airborne and grappling, steer along the wall as the player contacts a recognized side wall. The desired WASD direction varies with wall orientation and player/camera basis. On satisfying gates, entry happens automatically; Space is for leaving via wall-stick jump, not for entering (`scripts/player_wall_stick_state.gd:48-54`).
- `tests/player/locomotion/test_wall_traversal_contract.gd:105-139, 164-213` covers wall-frame/speed/alignment gates; integration fixtures cover wall-stick hold/release and seed an active grapple (`tests/player/locomotion/test_wall_traversal_integration.gd:265-321, 789-823, 1395-1409`). Tests were inspected only.

### Updated Hypotheses

- Hypothesis 1 is **Confirmed**: wall proximity alone is insufficient; the controller needs the active grappling route plus held grapple, supported side-wall contact, speed, and movement-alignment predicates. It is automatic, not manually toggled by a dedicated wall-stick action.
- No source evidence supports a single fixed WASD direction for all wall orientations. A concrete key for one wall requires the runtime wall normal/player orientation.

### Backlog Changes

- Transition trace is complete; backlog item 1 is Done.
- If the user's attempt still fails, missing evidence is the specific wall/surface layer, current grapple targeting result, contact frame, velocity, movement input, and the telemetry speed-gate reason at the failed entry step.

### MCP Evidence and Diagnostics

- Session: `grapplegame@158d53ec546cd5b1` (Godot 4.7.2-stable, plugin 4.2.3).
- Meaningful MCP operations: `session_manage(list)` and `editor_state` confirmed the project session; `scene_get_hierarchy` observed `MovementHSM/WallStickState` in the player scene; `script_manage(find_symbols)` outlined the controller/contact provider paths; `logs_read(source="editor", include_details=true)` and `logs_read(source="game")` inspected diagnostics; a later `editor_state` and `scene_get_hierarchy` confirmed `res://main.tscn` and a live `/Main/World/Player/MovementHSM`.
- An attempted `editor_manage(game_eval)` did not execute the source excerpt because it returned `EDITOR_GAME_NOT_RUNNING`; a subsequent editor-state read showed a live game again. No runtime input simulation, visual smoke test, or successful `game_eval` was observed.
- Editor logs retain two resource/autoload load errors and GDScript warnings, including `player_contact_provider.gd:575` (`INCOMPATIBLE_TERNARY`) and a `seed` shadow warning in `player_controller.gd`. These diagnostics are recorded but were not demonstrated to cause this wall-stick symptom. Current game log had helper registration and damage messages, not a wall-stick-specific error.
- Godot AI `test_manage(results_get)` returned zero suites/tests; it is not a test pass. Focused GUT source files were found but not run. Version-control commands were not available because `rtk` is missing from PATH.

### Final Conclusion

**Confidence:** High for source-defined gates and mapped actions; Medium for a live manual reproduction and the exact WASD key on a particular wall.

Wall stick is entered automatically from active grappling when the just-committed contact frame is current and non-grounded, a supported side-wall frame is runnable, grapple remains held, movement aligns with the wall-run direction, horizontal speed meets the player scene's 3 m/s minimum, total speed is no more than 18 m/s, and entry velocity is not outward from the wall. The manual inputs are Space if needed to get airborne, right mouse to grapple and keep held, and the camera-relative WASD direction that moves along the wall. There is no separate wall-stick button. No code change was made, and no runtime input sequence was simulated.

## Follow-up: 2026-09-27 #3

### New Evidence

- Re-read the focused transition excerpt in Godot AI `game_eval` during live session `grapplegame@158d53ec546cd5b1`; editor state reported `res://main.tscn` live. A bounded repository read confirmed `scripts/player_controller.gd:875-1040`.
- Wall-run update is disabled while grappling and reads the previous-step contact frame (`scripts/player_controller.gd:876-898`). Wall-stick is separately attempted after grapple motion commits, reads the just-committed current-step frame, and transitions directly from GrapplingState (`scripts/player_controller.gd:289, 402-423, 1013-1040`).
- The two paths do share named wall-run eligibility helpers: wall-stick explicitly calls `_can_start_wall_run(entry_velocity)` and `_has_wall_run_input_for_direction(...)` (`scripts/player_controller.gd:1031, 1035-1038`); those enforce the shared speed and input-alignment gates (`scripts/player_controller.gd:954-959, 997-1002`).

### Updated Hypotheses

- Clarification: the earlier conditions were not a requirement to enter `WallRunState`; they are shared wall-traversal speed/direction gates reused by wall-stick. The wall-stick-specific route is grapple-assisted and post-commit.

### Updated Conclusion

Wall-stick and wall-run entry requirements are partly shared and partly distinct. Wall-stick does not require an existing wall-run state, but its helper deliberately reuses wall-run speed and movement-alignment checks. It additionally requires active held grapple, a current non-grounded post-commit contact frame, and successful wall-stick motor setup. This clarification was source-checked; no runtime input was simulated and no tests were run.

## Follow-up: 2026-09-27

### New Evidence

- **Source code — Available (mapped, not yet traced):** search locates `MovementHSM` transition wiring and the wall-stick startup helper in `scripts/player_controller.gd` (lines 289, 416–423, 998 onward), plus the speed gate and supporting contact/grapple code. Candidate acceptance coverage exists under `tests/player/locomotion/` and `tests/player/contact/`.
- **Tests — Partial:** GUT test files are present, including `tests/player/locomotion/test_wall_traversal_integration.gd` and `test_wall_traversal_contract.gd`; no GUT run was requested or performed. The most recent Godot AI `test_manage(results_get)` response contained zero suites and zero tests, so it is not evidence of a successful test run.
- **Godot diagnostics — Available:** MCP editor logs contain retained errors for a missing `res://` autoload resource and multiple warnings, including `player_controller.gd:1146` (`seed` shadows a built-in) and `player_contact_provider.gd:575` (incompatible ternary values). No wall-stick-specific runtime error appeared in the returned current game log; the game helper is live.
- **Version control — Missing for this pass:** repository `rtk` commands were attempted, but PowerShell reports `rtk` is not installed/on PATH. No history or working-tree status was obtained.
- **Issue tracker — Missing:** no issue-tracker MCP/tool is available in this session; the user supplied no ticket ID.
- **Static analysis — Partial:** the live editor diagnostics above are available; no separate static-analysis report was located.

### Additional Findings

- Search confirms the active transition is registered from `GrapplingState` to `WallStickState` on `EVENT_WALL_STICK_STARTED`, and a call site dispatches that event only after `_try_start_wall_stick_from_contact(...)` returns true (`scripts/player_controller.gd:289, 416–423`). Exact predicates are still pending source trace.
- The active Godot AI session remains live on `res://scenes/player.tscn` (session `grapplegame@158d53ec546cd5b1`).

### Updated Hypotheses

- Hypothesis 1 remains **Open**. Transition wiring supports a grapple-origin entry path, but exact contact, motion, and user-input conditions still require inspection.

### Backlog Changes

- Source, tests, diagnostics, issue-tracker availability, and version-control command availability have been inventoried.
- Next: read the transition dispatch/candidate helper and its contact/speed/command predicates, then inspect the focused locomotion test cases.
