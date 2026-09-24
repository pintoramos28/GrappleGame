# Pre-change oracle

## Godot AI MCP preflight (before any edit)

- Active session `testgame@e362124f09f388c2` (Godot `4.7.2-stable (official)`,
  plugin/server `4.0.4`, protocol 2) was listed and used for every Godot-side
  operation in this story. Editor readiness `ready`, play state `stopped`,
  current scene `res://main.tscn`.
- Editor diagnostics at preflight contained 27 historical entries: parse/reload
  diagnostics for `game/player/locomotion/contact/player_contact_provider.gd`
  and `tests/player/contact/test_player_contact_contract.gd` whose line numbers
  do not match current file contents (mid-edit states from the Story 1.5 edit
  cycle). Current sources were verified healthy by the baseline GUT run below;
  these rows are recorded as historical, not presented as current errors.

## Baseline regression (pre-change, pinned Godot CLI + GUT 9.7.1)

Command family: pinned Godot 4.7.2 console, `--headless --path . -s
res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit`
(operator-local console path).

| Scripts | Tests | Passing | Asserts | Time | Exit |
|---|---|---|---|---|---|
| 7 | 68 | 68 | 3,086 | 1.256 s | 0 |

Per domain at baseline: contact 11/11, input 21/21 (3+2+16), motor 16/16 + 12/12
integration + 8/8 semantic. Expected `push_error` diagnostics (`GameLog`
invariants and input-source contract errors) were asserted by the tests
themselves. Teardown noise at exit: 8 leaked ObjectDB instances and 1 resource
still in use (pre-existing, unchanged by this story).

## Pre-change grapple behavior oracle (prototype)

- `try_start_grapple()` and `_update_grapple_cursor()` each called
  `_get_grapple_ray_hit()` (up to two untyped `intersect_ray()` calls per step,
  no collision mask, `collider is StaticBody3D` gate).
- Range scalar `grapple_length = 35.0` lived on the controller export and was
  re-assigned by `scripts/levels/tree_grapple_tutorial.gd`.
- No Story 1.6 test suite existed; the RED run of the new grapple suites failed
  with "Could not find type GrappleTargetResolver / Grappleable3D /
  GrappleTargetingResult ..." parse errors (expected pre-implementation state,
  recorded in `focused-gut.md`).
