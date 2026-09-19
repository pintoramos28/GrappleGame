# Investigation: Grapple visual launch offset

## Hand-off Brief

1. **What happened.** Confirmed: physics interpolation briefly renders the reused grapple mesh between its previous and current world transforms, so a launch can begin at the previous grapple's origin.
2. **Where the case stands.** Concluded. The cause is the combination of a retained `top_level` visual transform, physics-only transform writes, and project-wide physics interpolation.
3. **What's needed next.** If a fix is requested, make the visual's interpolation/activation lifecycle atomic with its new transform; implementation is intentionally out of scope here.

## Case Info

| Field            | Value                                                                      |
| ---------------- | -------------------------------------------------------------------------- |
| Ticket           | N/A                                                                        |
| Date opened      | 2026-09-19                                                                 |
| Status           | Concluded                                                                  |
| System           | Windows; Godot 4.7.2-stable; project `testgame`                           |
| Evidence sources | User report, Godot AI MCP session, editor diagnostics, source, git history |

## Problem Statement

When launching the grapple, the visuals are janky: an initial grapple line appears completely offset from the player and seems to originate where the grapple was last initiated before that line disappears and is replaced with the correct grapple line.

## Evidence Inventory

| Source                  | Status    | Notes                                                                                         |
| ----------------------- | --------- | --------------------------------------------------------------------------------------------- |
| User description        | Available | Symptom and suspected previous-origin behavior; treated as a hypothesis until runtime check. |
| Godot AI MCP preflight  | Available | Active session `testgame@e362124f09f388c2`; editor ready; `res://scenes/player.tscn` open; stopped. |
| Open scene hierarchy    | Available | Player scene contains no authored `GrappleVisual`; the visual is runtime-created by the player script. |
| Editor diagnostics      | Partial   | MCP editor log contains unrelated/current GDScript parse errors in contact-provider tests and source. |
| Source code              | Available | Grapple setup, launch, update, clear, and state-machine call sites identified.                  |
| Version control          | Available | Grapple visual code introduced in `acb73805`; later feedback path moved with HSM work in `f6a51f85`. |
| Runtime visual capture   | Available | MCP live run plus a two-launch runtime probe reproduced the stale/interpolated transform.       |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --------------- | -------- | ------ | ----- |
| 1 | Reconstruct grapple launch/release/update frame ordering | High | In Progress | Focus on visibility and retained transform. |
| 2 | Inspect running scene/visual transform during two launches via MCP | High | Done | Runtime probe showed old-to-new interpolation on the reused visual. |
| 3 | Check recent changes touching grapple visual lifecycle | Medium | Done | No recent change found after original visual implementation. |

## Timeline of Events

| Time       | Event | Source | Confidence |
| ---------- | ----- | ------ | ---------- |
| 2026-09-19 | Godot AI MCP listed one active ready session; editor open on `res://scenes/player.tscn`; game stopped. | MCP `session_manage`, `editor_manage` | Confirmed |
| 2026-09-19 | Source scan found runtime grapple visual setup, launch, feedback, and clear paths in `scripts/player_controller.gd`. | Source scan | Confirmed |
| 2026-09-19 | Main scene launched successfully through MCP; helper became live with no errors in the run window. | MCP `project_run` run token 15 | Confirmed |
| 2026-09-19 | Runtime probe performed two grapple launches on the actual `GrappleVisual`; the second launch's current transform was new, while the next interpolated transform remained between the first and second launch positions. | MCP `editor_manage(game_eval)` run token 16 | Confirmed |
| 2026-09-19 | Game stopped after the probe and editor returned to ready state. | MCP `project_manage(stop)`, `editor_manage(state)` | Confirmed |

## Confirmed Findings

### Finding 1: Grapple rope is a single reused runtime node

**Evidence:** `scripts/player_controller.gd:426-433`

**Detail:** `_setup_grapple_visual()` constructs one `MeshInstance3D`, sets `top_level = true`, hides it, and adds it as a child. The player scene hierarchy reported by MCP contains no authored `GrappleVisual`, confirming this is not a duplicated scene node.

### Finding 2: The project interpolates the retained visual transform

**Evidence:** `project.godot` physics interpolation setting; MCP runtime node info for `/Main/World/Player/GrappleVisual`

**Detail:** Project-wide `physics/common/physics_interpolation` is `true`. At runtime, `GrappleVisual.physics_interpolation_mode` is `0` (inherit), `top_level` is `true`, and the player scene contains the runtime-created node. The visual is therefore rendered through the same interpolation system while its transform is authored only on physics ticks.

### Finding 3: Runtime probe reproduces the prior-origin flash mechanism

**Evidence:** MCP session `testgame@e362124f09f388c2`, `project_run` run token 16; `editor_manage(game_eval)` two-launch probe

**Detail:** The probe called the real `try_start_grapple()` and `_update_grapple_visual()` path for one target, cleared it, then called the same path for a different target. On the second launch, the visual's current midpoint was `{x: 4.4522, y: 3.3867, z: -8.75}`, but on the next process frame `get_global_transform_interpolated().origin` was `{x: -1.9056, y: 3.1323, z: -1.4163}`—between the previous midpoint `{x: -3.5, y: 3.0685, z: 0.4229}` and the new midpoint. The engine-side interpolation, not a second visual node, produces the transient stale/offset segment.

## Deduced Conclusions

### Deduction 1: A previous grapple's transform can remain resident

**Based on:** Finding 1 and `scripts/player_controller.gd:980-982,1030-1038`

**Reasoning:** The visual's transform is written only by `_update_grapple_visual()`, while `_clear_grapple()` hides it without resetting its transform. If visibility becomes true before the next transform write, the last grapple's transform is the only available transform.

**Conclusion:** The previous-origin line is caused by the interpolation history of the reused visual. Hiding the node does not reset its previous transform; re-showing it after a new physics-tick transform write lets the renderer interpolate from the old grapple segment toward the new one.

## Hypothesized Paths

### Hypothesis 1: Visibility is exposed before the current transform is written

**Status:** Confirmed

**Theory:** The reused `GrappleVisual` remains positioned at the previous grapple after `_clear_grapple()`. With project physics interpolation enabled, the launch-frame render interpolates from that retained transform after `_update_grapple_visual()` applies the new segment.

**Supporting indicators:** `_clear_grapple()` hides but does not reset; transform and visibility are separate assignments in `_update_grapple_visual()`; the user reports exactly the prior launch origin.

**Would confirm:** A runtime probe showing the visual's current transform at the new segment while `get_global_transform_interpolated()` reports an old/partway transform immediately afterward.

**Would refute:** A runtime trace showing the node remains hidden until after the new global transform is assigned, with the offset caused instead by a coordinate-space conversion.

**Resolution:** Confirmed by the two-launch MCP runtime probe in Finding 3.

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | ------ | ------------ |
| Clean editor/game diagnostics | Existing parse errors may prevent reliable runtime validation | Resolve or isolate the unrelated contact-provider parse errors, then rerun through MCP. |

## Source Code Trace

| Element | Detail |
| ------- | ------ |
| Error origin | `scripts/player_controller.gd:967-982` (`_update_grapple_visual`) in combination with `scripts/player_controller.gd:1030-1038` (`_clear_grapple`). |
| Trigger | A successful `try_start_grapple()` from a locomotion state on a pressed grapple command (`scripts/player_grounded_state.gd:25-28`, `scripts/player_airborne_state.gd:21-24`, or `scripts/player_wall_run_state.gd:22-26`). |
| Condition | `is_grappling` becomes true and the reused visual is made visible after its new physics transform is written, but interpolation still has the previous grapple transform as its prior sample. |
| Related files | `scripts/player_controller.gd`, `scripts/player_grappling_state.gd`, `scripts/player_grounded_state.gd`, `scripts/player_airborne_state.gd`, `scripts/player_wall_run_state.gd`, `scenes/player.tscn`. |

## Conclusion

**Confidence:** High

The defect is localized to the runtime-created `GrappleVisual` lifecycle in `scripts/player_controller.gd`. The player creates one `top_level` mesh, writes its world transform only from `_physics_process()` after the motor commit (`scripts/player_controller.gd:322-332` and `967-982`), and hides it on clear without resetting its transform (`1030-1038`). Because `project.godot` enables physics interpolation and the visual inherits it, the renderer uses the prior grapple transform as the previous interpolation sample when the node is shown for a new grapple. The MCP two-launch probe confirmed the current transform and interpolated transform diverge in exactly that old-to-new direction.

## Recommended Next Steps

### Fix direction

Not implementing a fix in this investigation. The fix needs to address the interpolation lifecycle: either disable/reset interpolation for this transient world-space visual, or update/activate it in a way that resets the interpolation history to the new segment before it becomes visible. Merely changing the ray hit or grapple target is not the relevant mechanism.

### Diagnostic

The MCP two-launch smoke check already confirmed the cause. If implementing a fix, repeat the same probe and require the current and interpolated visual transforms to agree on the first visible frame.

## Reproduction Plan

Start a playable scene with a valid static grapple target. Hold grapple until the first rope is visible, release, aim at a different target, and press grapple again. Compare the first rendered frame's rope origin with the player's mesh center and the previous grapple's origin.

## Side Findings

- MCP editor diagnostics currently include parse errors under `game/player/locomotion/contact/player_contact_provider.gd` and dependent tests; the main scene still launched with no run-window errors, but these diagnostics remain an independent project issue.
- The MCP game run later stopped because the idle player was killed by enemies; this did not affect the two-launch transform probe, which completed before the stop.

## Godot AI MCP Evidence / Dev Agent Record

- **Session:** `testgame@e362124f09f388c2`
- **Preflight:** `session_manage(list)` found one active session; `editor_manage(state)` reported Godot 4.7.2, editor ready, `res://scenes/player.tscn` open, game stopped; `scene_get_hierarchy` confirmed no authored `GrappleVisual`; `script_manage(read)` read the affected controller and state scripts; `logs_read(editor)` captured existing diagnostics.
- **Validation:** `project_run(mode=main, autosave=false)` reported live helper/no current-run errors; `game_manage(get_scene_tree)` found the runtime-created `GrappleVisual`; `game_manage(get_node_info)` confirmed `top_level=true`, `physics_interpolation_mode=0`, and hidden state between grapples; `project_manage(settings_get)` confirmed `physics/common/physics_interpolation=true`; `editor_manage(game_eval)` reproduced the old-to-new interpolation across two grapple launches; `project_manage(stop)` and `editor_manage(state)` returned the editor to ready/stopped.
- **Diagnostics:** MCP game logs for run token 16 contained only gameplay damage/death messages during the run; no grapple script errors were emitted. Existing editor parse errors are recorded above and were not attributed to this defect.

## Follow-up: 2026-09-19

### New Evidence

### Additional Findings

### Updated Hypotheses

### Backlog Changes

### Updated Conclusion
