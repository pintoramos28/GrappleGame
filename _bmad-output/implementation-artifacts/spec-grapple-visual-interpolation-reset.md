---
title: 'Reset grapple visual interpolation on activation'
type: 'bugfix'
created: '2026-09-19'
status: 'done'
baseline_commit: '216e935e8e55822b87f675be0eb213f8c511f372'
context: ['{project-root}/_bmad-output/implementation-artifacts/investigations/grapple-visual-launch-offset-investigation.md']
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** When a grapple is launched after a previous grapple, the reused top-level rope mesh can render from the previous grapple's position for its first visible frame. Project-wide physics interpolation is using the retained visual transform as the prior sample, producing a visibly offset rope before it settles onto the current segment.

**Approach:** Reset the `GrappleVisual` physics-interpolation history only when the rope transitions from hidden to visible, after its new world transform has been assigned. Preserve interpolation during the active grapple and leave the player motor, grapple targeting, and project-wide interpolation settings unchanged.

## Boundaries & Constraints

**Always:** Preserve all existing uncommitted motor/contact changes. Restrict source changes to the grapple visual lifecycle in `scripts/player_controller.gd`. Reset interpolation only on activation, not on every active-frame update. Keep the existing release/clear behavior and world-space rope geometry.

**Ask First:** Any change to project-wide `physics/common/physics_interpolation`, player motor/contact code, grapple targeting, or a different visual architecture.

**Never:** Do not disable interpolation globally. Do not rewrite or revert unrelated working-tree changes. Do not claim visual/runtime verification unless it is observed through Godot AI MCP.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|----------|--------------|---------------------------|----------------|
| First activation | `GrappleVisual` is hidden; grapple becomes valid | New transform is assigned, interpolation history is reset, and the first visible frame uses the current rope segment | Existing invalid/zero-length hiding remains unchanged |
| Active update | `GrappleVisual` is already visible and grapple remains valid | Transform and mesh length update normally without resetting interpolation every frame | Existing grapple update path remains authoritative |
| Re-activation | Rope was cleared/hidden, then a new grapple starts | New activation resets history again; previous grapple position is not rendered as the first frame | Existing `_clear_grapple()` state reset remains unchanged |

</frozen-after-approval>

## Code Map

- `scripts/player_controller.gd` — creates the runtime rope, updates its mesh/world transform, and clears its visibility.
- `game/player/input/player_input_source.gd` — fixed-step input boundary that triggers grapple launch; unchanged by this fix.
- `project.godot` — enables project-wide physics interpolation; unchanged by this fix.
- `_bmad-output/implementation-artifacts/investigations/grapple-visual-launch-offset-investigation.md` — confirmed cause and MCP runtime evidence.

## Tasks & Acceptance

**Execution:**
- [x] `scripts/player_controller.gd` — detect hidden-to-visible activation in `_update_grapple_visual()`, assign the current transform, reset physics interpolation once, then show the rope — eliminate the stale previous-grapple interpolation sample without sacrificing active-rope smoothing.

**Acceptance Criteria:**
- [x] Given the rope was hidden after a previous grapple, when a new grapple makes it visible, then the first visible transform is based on the new player-center-to-target segment and is not interpolated from the previous grapple.
- [x] Given the rope remains visible during an active grapple, when subsequent physics updates reposition it, then interpolation is not reset on every update.
- [x] Given an invalid or zero-length grapple segment, when visual feedback updates, then the rope remains hidden and the existing behavior is preserved.
- [x] Given the repository contains unrelated uncommitted changes, when this fix is applied, then those changes remain byte-for-byte untouched.

## Verification

**Commands:**
- `rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs=true` — expected: recursive GUT suites complete without new failures.
- `rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --import --quit-after 120` — expected: project imports with no new parse/load failures.

**Manual checks (if no CLI):**
- Through Godot AI MCP, launch `res://main.tscn`, inspect the runtime `GrappleVisual`, and run a two-launch probe. On the second activation, its current and interpolated transform should agree on the first visible frame; the active grapple should continue updating normally.
