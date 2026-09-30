# Investigation: Wall Jump Force Settings

## Hand-off Brief

1. **What happened.** The player wall-jump velocity is controlled by exported settings in `scripts/player_controller.gd`; `scenes/player.tscn` overrides the away-from-wall setting.
2. **Where the case stands.** The setting locations are confirmed; the reported in-game feel has not been reproduced or diagnosed.
3. **What's needed next.** If the jump still feels weak, inspect the vertical launch value and perform a runtime check before changing movement behavior.

## Case Info

| Field            | Value |
| ---------------- | ----- |
| Ticket           | N/A |
| Date opened      | 2026-09-27 |
| Status           | Active |
| System           | Windows; Godot 4.7.2-stable |
| Evidence sources | Godot AI MCP session, GDScript, player scene resource |

## Problem Statement

User reports: “When wall jumping the player barely jumps off the wall - where is the wall jump force/speed set?”

## Evidence Inventory

| Source | Status | Notes |
| ------ | ------ | ----- |
| Godot AI MCP | Available | Session `grapplegame@158d53ec546cd5b1`; editor ready, play stopped, current scene `res://scenes/tree_grapple_tutorial.tscn`. Used session listing, editor state, project search, and read-only script/resource reads. |
| Player controller script | Available | MCP read confirms exported velocity settings and both wall-jump submission paths. |
| Player scene | Available | MCP read confirms `wall_jump_away_velocity = 20.0` override in `res://scenes/player.tscn`. |
| Runtime reproduction/logs | Missing | No gameplay run was requested or performed. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --------------- | -------- | ------ | ----- |
| 1 | Reproduce the reported wall jump and inspect launch velocity | Medium | Open | Needed only to diagnose why the player feels weak, rather than locate the settings. |

## Confirmed Findings

### Finding 1: Wall-jump launch velocities are exported on the player controller

**Evidence:** `scripts/player_controller.gd:38-41`.

**Detail:** `wall_jump_up_velocity` defaults to `5.5` and sets the vertical launch velocity; `wall_jump_away_velocity` defaults to `8.0` and sets velocity away from the wall. `submit_wall_jump()` and `submit_wall_stick_jump()` use these settings (`scripts/player_controller.gd:702-708`, `742-745`).

### Finding 2: The player scene overrides the away-from-wall velocity

**Evidence:** `scenes/player.tscn:53`.

**Detail:** The packed player scene sets `wall_jump_away_velocity = 20.0`; this takes precedence over the script default for that scene. No `wall_jump_up_velocity` override appears in that scene resource, so it uses the script default unless overridden at runtime.

## Hypothesized Paths

### Hypothesis 1: The low perceived launch may be due to the vertical setting

**Status:** Open

**Theory:** If “barely jumps” refers to jump height, the current `wall_jump_up_velocity` default (`5.5`) is the relevant setting; the scene already has a high away-from-wall value (`20.0`).

**Supporting indicators:** Confirmed values above.

**Would confirm:** A runtime capture shows low vertical launch velocity on wall jump.

**Would refute:** Runtime capture shows the expected vertical launch velocity and the weak feel comes from another movement constraint or state.

**Resolution:** Pending runtime evidence.

## Conclusion

**Confidence:** High for setting locations; Low for the cause of the reported feel.

The vertical wall-jump velocity is `wall_jump_up_velocity` in `scripts/player_controller.gd` (default `5.5`). The away-from-wall velocity is `wall_jump_away_velocity` (default `8.0`), overridden to `20.0` in `scenes/player.tscn`. Runtime behavior was not checked.
