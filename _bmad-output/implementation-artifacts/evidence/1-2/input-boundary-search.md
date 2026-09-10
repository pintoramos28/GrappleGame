# Story 1.2 input-boundary audit

The gameplay surface was searched after migration. Direct `Input` polling remains only in `game/player/input/player_input_source.gd`, which is the player-owned hardware boundary. `scripts/debug_grapple_telemetry.gd` retains its explicit developer-only F3 `_unhandled_input` boundary. `scripts/player_controller.gd` and all six migrated player states contain no direct `Input.is_action_*`, `Input.get_vector`, or `Input.get_axis` calls.

The focused controller test repeats this audit over the runtime surface. The input-source tests exercise the production-shaped event path and the narrow deterministic seam, including InputMap-equivalent movement, semantic multi-binding aggregation, short taps, key-echo suppression, focus rearm, mouse `screen_relative`, pan gestures, and cursor recapture suppression.
