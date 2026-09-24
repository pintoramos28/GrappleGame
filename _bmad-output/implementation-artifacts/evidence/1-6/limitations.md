# Limitations and honest boundaries

- The live checks are automated Godot AI MCP observations (game_eval plus
  simulated input). No human visual approval, feel judgment, or screenshot-based
  claim is made; presentation verification is node-state agreement (marker state
  equals authoritative result), not pixels.
- Godot AI MCP-native tests cannot execute gameplay code: gameplay classes are
  deliberately not `@tool`, so tool scope receives placeholder instances. The
  adapter verifies authored assets and schema constants only; behavior is
  covered by the 92-test recursive GUT run and the live game smoke. The two
  result sets are reported separately and parity is not claimed.
- The MCP helper's `input_mouse(event=motion)` does not populate
  `screen_relative` (the property the fixed input boundary reads), so it cannot
  rotate gameplay aim; aim was driven through `PlayerInputSource`'s typed test
  seam (the project's own input injection contract) and grapple activation used
  a real mouse-button event matching the `fire_grapple` binding. Keyboard-style
  `input_action` delivery is action-state only and creates no press edge.
- `main.tscn` contains enemies that damage a stationary player; during early
  loose probing the player died (which disables the input source by design), so
  the smoke was re-run as single scripted passes. Death-triggered input disable
  is pre-existing behavior, unchanged here.
- `acquisition_tolerance_m = 0.005` m is an implementer-chosen value inside the
  recorded bound (0.001-0.01 m, i.e. quantization/margin magnitude). The
  `OUT_OF_RANGE` band is therefore millimetric by design; it is observable in the
  pure boundary oracle and at one integration point (band placement at
  `max + tolerance * 0.75`).
- The Task 3 predicate chain and the Dev Notes "Required mapping" read slightly
  differently for an occlusion-only hit inside the tolerance band; the
  implementation follows the Dev Notes mapping (kind first). Recorded in
  `targeting-contract.md`.
- Story 1.5 P2 findings (lossy overflow accounting; profile runtime immutability
  via `unlock_for_editor()`) and AC13 evidence gaps remain open and are not this
  story's debt. This story does not widen profile mutability; grapple bounds are
  enforced before querying.
- Pull tuning currently remains controller-export-driven (unchanged behavior);
  `GrappleDefinition` carries the same values verbatim under canonical unit
  names for Story 1.7/1.8 consumption. Only the acquisition range is
  single-sourced (AC 11).
- The disposable tutorial is intentionally not preserved beyond removing its
  competing range scalar (AC 15 scope); its remaining `grapple_gravity_scale`
  assignment and out-of-band reset teleport are untouched.
- Recorded dependency discrepancy unchanged: planning lists Godot AI 3.2.4
  while the local plugin/server reports 4.0.4. No dependency files changed.
