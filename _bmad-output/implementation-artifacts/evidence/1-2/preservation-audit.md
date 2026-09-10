# Story 1.2 preservation audit

- `rtk git diff --check` passed.
- `project.godot` and `main.tscn` were not modified.
- `scenes/player.tscn` changed only to add the explicit `PlayerInputSource` script resource and child node; existing scene identity, unique node IDs, resource references, node names/paths, HSM hierarchy, and gameplay tuning overrides were preserved.
- Existing movement/grapple/attack formulas, transition events, `move_and_slide()` locations, death handling, and tuning were migrated at the input boundary without traversal retuning or grapple resolver redesign.
- The accepted Story 1.1 limitations remain unchanged: `PASS WITH LIMITATIONS`, `BASE-006`, `BASE-007`, `BASE-004`, and `BASE-005`.
- Pre-existing Story 1.1 planning/evidence edits, `_bmad-output/.artifact-index/context-1-2.json`, `_bmad-output/implementation-artifacts/deferred-work.md`, and concurrently generated `character_reference_views/*.png.import` files were preserved and are not attributed to Story 1.2 runtime implementation.
