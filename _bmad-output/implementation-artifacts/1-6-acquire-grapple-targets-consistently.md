---
baseline_commit: 7bf250e3fb82f4cc6cccdd8742a619cde01c0faa
context_pack: _bmad-output/.artifact-index/context-1-6.json
---

# Story 1.6: Acquire Grapple Targets Consistently

Status: ready-for-dev

<!-- Story 1.6 replaces the prototype's StaticBody3D grapple ray with one authoritative typed grapple targeting query per physics step (GrappleTargetResolver + optional Grappleable3D + default-grappleable geometry), and makes activation, presentation, and diagnostics agree on that single result. It consumes the current semantic-motor/ContactFrame working tree, preserves current grapple pull and release behavior, and explicitly does not implement the active maximum-distance tether constraint (Story 1.7), moving-target tracking/lifetime/invalidation (Story 1.8), pull redesign, tutorial preservation, or final presentation assets. -->

## Story

As a player,
I want the crosshair and grapple action to agree on which world target is available,
so that every grapple attempt has a predictable result and understandable feedback.

## Acceptance Criteria

1. **Produce one authoritative typed targeting result per evaluated physics step**
   - **Given** the player has a valid immutable `GrappleDefinition` and begins a physics step
   - **When** grapple targeting is evaluated from the current command frame's authoritative aim direction
   - **Then** one authoritative physics query produces one typed targeting result for that physics step
   - **And** the result identifies the candidate, world hit position, surface normal, validity, rejection reason, range fraction, and source physics-step number.

2. **Accept ordinary collision geometry by default**
   - **Given** ordinary collision geometry passes the named grapple-candidate and occlusion profiles
   - **When** the authoritative query hits that geometry within `GrappleDefinition.max_grapple_length_m`
   - **Then** the resolver accepts it using the built-in static grapple response without requiring a component on every surface
   - **And** level authors do not need to place individual grapple anchors across ordinary geometry.

3. **Obtain bounded typed responses from exceptional targets**
   - **Given** a moving, stateful, hazardous, resistant, modified, or otherwise exceptional collision body needs non-default behavior
   - **When** the resolver inspects the blocking hit
   - **Then** it can obtain a direct child named `Grappleable` typed as `Grappleable3D` and receive a bounded typed response
   - **And** the target cannot move the player, write player velocity, change locomotion state, or invoke player abilities.

4. **Create an accepted target seed for later player-owned attachment**
   - **Given** an exceptional target accepts the query
   - **When** the resolver creates the accepted target seed
   - **Then** the seed contains stable target identity, the hit position and normal, the applicable authored response, and the information needed by a later player-owned attachment
   - **And** continuous moving-target tracking, lifetime sampling, and invalidation remain scoped to Story 1.8.

5. **Never pierce a rejected first hit**
   - **Given** the first blocking collision is rejected by its default or explicit grapple policy
   - **When** another potentially valid target exists behind it
   - **Then** the resolver returns the first hit's typed rejection instead of piercing through it to select the hidden target
   - **And** gameplay and presentation report the same rejected result.

6. **Report stable typed rejection reasons without treating expected rejection as an error**
   - **Given** no candidate is hit, the target is outside the maximum acquisition range, the hit is occluded, the surface is ineligible, the target is invalid, or required target data is malformed
   - **When** targeting resolves
   - **Then** the result contains the appropriate stable `GrappleRejection` reason and no accepted attachment seed
   - **And** expected targeting rejection is treated as normal gameplay rather than logged as an error.

7. **Normalize duplicates and select deterministically**
   - **Given** multiple hits or candidate records can describe the same collider or contact
   - **When** targeting results are normalized
   - **Then** duplicate hits are removed and selection follows explicit distance, blocking, and stable tie-break rules
   - **And** engine return order, scene-tree order, and signal connection order cannot change the selected target for the same query state.

8. **Consume the same-step result at grapple activation**
   - **Given** the player presses grapple during a physics step
   - **When** the movement state attempts to start grappling
   - **Then** it consumes the valid targeting result produced for that same command-frame and physics-step identity
   - **And** it does not issue a second gameplay raycast or accept a targeting result from an earlier step.

9. **Reject activation on stale or missing results without partial state**
   - **Given** the current targeting result is missing or stale when grapple activation is requested
   - **When** the request is validated
   - **Then** activation is rejected with a typed reason and no partial grapple state is committed
   - **And** presentation cannot authorize or substitute its own target.

10. **Make presentation consume, never query**
    - **Given** the grapple reticle, world marker, or development overlay renders targeting feedback
    - **When** it updates between physics steps
    - **Then** it consumes the latest authoritative targeting result and may visually interpolate its presentation
    - **And** it does not raycast independently, change validity, delay gameplay activation, or retain a target after the authoritative result becomes unavailable.

11. **Keep one authoritative acquisition range**
    - **Given** an accepted target is at or near the authored acquisition boundary
    - **When** the query is evaluated within documented physics tolerance
    - **Then** acquisition consistently uses `GrappleDefinition.max_grapple_length_m` as its only authoritative range value
    - **And** the player scene, disposable tutorial content, targeting presenter, and other callers do not maintain competing grapple-range scalars.

12. **Fail typed on invalid composition and forbid legacy fallbacks**
    - **Given** the query profiles, grapple definition, collision configuration, resolver, or required targeting dependency is missing or invalid
    - **When** the grapple feature initializes
    - **Then** initialization fails through a typed development-visible result or the grapple feature is safely unavailable according to its owner
    - **And** gameplay does not fall back to magic collision masks, direct `StaticBody3D` checks, dynamic resource paths, or the legacy duplicate raycast.

13. **Expose bounded targeting diagnostics from the authoritative result**
    - **Given** grapple targeting diagnostics are enabled
    - **When** the latest result is inspected
    - **Then** diagnostics expose the query origin and direction, maximum range, first blocking hit, target identity, acceptance or rejection reason, range fraction, profile identifiers, and physics-step number
    - **And** diagnostics reuse the authoritative result without executing another query.

14. **Prove agreement with focused real-Jolt targeting tests**
    - **Given** the focused real-Jolt targeting tests run
    - **When** they exercise default geometry, accepted and rejected exceptional targets, blockers with valid targets behind them, empty aim, occlusion, maximum-range boundaries, duplicate candidates, stale results, and presentation consumption
    - **Then** gameplay, reticle presentation, and diagnostics agree on candidate identity, hit position, and validity
    - **And** exactly one authoritative gameplay targeting query is performed for each evaluated physics step.

15. **Close scope with a playable baseline**
    - **Given** Story 1.6 is complete
    - **When** the traversal smoke procedure and working-tree diff are reviewed
    - **Then** the player can identify and start grappling valid current targets through the typed targeting boundary, current grapple pull remains playable, retained UIDs remain valid, and `res://main.tscn` still runs
    - **And** the story has not implemented the active maximum-distance constraint, redesigned pull acceleration, added moving-target sampling, preserved the disposable tutorial, introduced final presentation assets, or migrated unrelated systems.

## Tasks / Subtasks

- [ ] 1. Author grapple definitions, query profiles, and named collision configuration (AC: 2, 11, 12)
  - [ ] Create `game/player/abilities/grapple/definitions/grapple_definition.gd` (class `GrappleDefinition`, immutable authored Resource) with explicit-unit fields: `definition_id` (stable lowercase dotted `StringName`, e.g. `&"player.grapple.default"`), `max_grapple_length_m = 35.0`, `acquisition_tolerance_m`, `target_query_profile: PhysicsQueryProfile` (the candidate profile reference carried on the definition per architecture "Data Patterns"), and the current pull tuning carried verbatim under canonical unit names: `pull_initial_acceleration_mps2 = 48.0`, `pull_min_acceleration_mps2 = 8.0`, `pull_acceleration_jerk_mps3 = 53.333333`, `maximum_speed_mps = 22.0`. The architecture sample values (`45.0`, `30.0`) are schema examples, not tuning targets. `acquisition_tolerance_m` is a physics/quantization tolerance for boundary classification (W-scope: keep it at `point_quantization_m`/margin magnitude, never a second range scalar); record its bound in Completion Notes.
  - [ ] Author the default definition asset `game/player/abilities/grapple/definitions/grapple_definition.tres`; validate/lock authored values at initialization (mirror `PhysicsQueryProfile.validate()`/lock semantics; runtime code never writes the Resource).
  - [ ] Author `game/shared/physics/grapple_candidate.tres` and `game/shared/physics/grapple_occlusion.tres` as `PhysicsQueryProfile` assets (authoring style mirrors `ground_probe.tres`), with `profile_id = &"player.grapple.candidate"` / `&"player.grapple.occlusion"` and named `collision_mask_names` only.
  - [ ] Record named 3D collision layer decisions in `project.godot` (existing named layers: `world_geometry`, `player_body`, `enemy_body`, `player_hurtbox`, `enemy_hurtbox`); add named grapple candidacy/occlusion layer entries only if the matrix needs them. No magic bitmask literals anywhere in gameplay code.
  - [ ] Resolve the shared-profile variance (see Dev Notes "Range and Boundary Tolerance Decision"); two hard constraints make `PhysicsQueryProfile` unable to express a ray profile today: (a) `validate()` requires a non-null `shape` (`INVALID_SHAPE`, `physics_query_profile.gd`), and every existing profile asset carries a probe shape (see `ground_probe.tres`); (b) `MAX_PROBE_DISTANCE_M = 4.0` / `MAX_SWEEP_DISTANCE_M = 4.0` are contact-probe bounds and cannot carry a 35 m acquisition ray. The ray length must come only from `GrappleDefinition.max_grapple_length_m`. Apply the documented preferred generalization (optional ray-relevant fields/shape exemption for ray profiles) keeping every existing contact bound and `tests/player/contact/test_player_contact_contract.gd` expectation intact. Forbidden: dummy-shape hacks, a second parallel profile system, or silently raising contact bounds.

- [ ] 2. Define shared grapple contracts and typed result records (AC: 1, 3, 4, 5, 6, 7)
  - [ ] Create `game/shared/contracts/grappleable_3d.gd` (class `Grappleable3D`, `Node3D`-family component) exposing a direct-child `Grappleable` contract with a bounded typed response: eligibility, anchor mode, pull multiplier, directional adjustment, instability, and hazard response fields per architecture "Grapple target contract". The component answers queries only; it cannot move the player, write velocity, change locomotion state, or call player abilities (enforce by narrow API surface, assert in dev).
  - [ ] Create the immutable typed response record beside it (`grapple_target_response.gd`, e.g. class `GrappleTargetResponse`) plus the built-in static default response constant used for ordinary geometry.
  - [ ] Create `game/shared/contracts/grapple_targeting_result.gd` (value-only, bounded, copy-on-read like `ContactFrame`): `source_physics_step`, command-frame identity, query origin/direction, `max_grapple_length_m`, first blocking hit (position, normal, distance), candidate/target identity (`StringName`, empty allowed), validity, typed rejection reason, `range_fraction`, accepted seed (or empty), profile ids, query count. No `Node`, `PhysicsBody3D`, dictionary, or live engine reference may escape except a tightly bounded weak target reference inside the accepted seed where AC 4 requires it; document that exception.
  - [ ] Create the `GrappleRejection` typed hot-path enum starting from the architecture set `NONE, NO_CANDIDATE, OUT_OF_RANGE, OCCLUDED, INVALID_SURFACE` and extend it to cover every AC 6 condition and AC 9 (explicit policy rejection, invalid target, malformed target data, missing result, stale result). Rejection paths allocate no per-check result objects. Record the final closed value set in Completion Notes.
  - [ ] Create the accepted target seed record (`grapple_target_seed.gd`, e.g. class `GrappleTargetSeed`): stable target identity, world hit position and normal, applicable authored response, and the bounded data a later player-owned `GrappleAttachment` needs: a `WeakRef` target reference (the same weak-reference semantics `GrappleAttachment` is defined to hold; consumers gate every dereference with `is_instance_valid`, matching today's `has_valid_grapple()` checks and NFR14's no-destroyed-node-retention rule) and the target-local hit offset computed once at acquisition. This `WeakRef` is the single documented engine-reference exception in the result records. No continuous tracking, lifetime sampling, or invalidation here (Story 1.8).

- [ ] 3. Implement `GrappleTargetResolver` single-query evaluation (AC: 1, 2, 3, 5, 6, 7, 11)
  - [ ] Create `game/player/abilities/grapple/grapple_target_resolver.gd` (class `GrappleTargetResolver`; filename matches class name - see Project Structure Notes variance) implementing the architecture activation order for acquisition: one authoritative ray query with the immutable grapple query profiles; resolve the first blocking collision through the default policy or its explicit `Grappleable3D` child; return typed acceptance (seed) or `GrappleRejection`; never pierce a rejected blocking hit.
  - [ ] Query exactly once per evaluated physics step from the command frame's `aim_world_direction`. One ray over the union of the two named profiles (`candidate | occlusion` masks); a body passing both is a candidate, and the occlusion profile only marks surfaces that block without being acquirable. Ray length is `max_grapple_length_m + acquisition_tolerance_m` (the tolerance exists only so the `OUT_OF_RANGE` band is observable at the endpoint; it is not acceptance range). Exclude the player RID; set `collision_mask` from `PhysicsQueryProfile.get_collision_mask()`; honor profile body/area flags. A second occlusion ray is prohibited (AC 14). Count queries in the result (AC 14 asserts exactly one).
  - [ ] Classify the first blocking hit with this locked predicate: quantized distance `<= max_grapple_length_m` inclusive -> candidate policy (default or `Grappleable3D`, AC 2, 3); distance in `(max_grapple_length_m, max_grapple_length_m + acquisition_tolerance_m]` -> `OUT_OF_RANGE`; occlusion-only first hit -> `OCCLUDED`; no hit -> `NO_CANDIDATE`; ineligible surface -> `INVALID_SURFACE`; invalid target or malformed required data (e.g. non-finite position/normal, degenerate identity where required) -> typed reason per AC 6 mapping. `range_fraction` = quantized hit distance / `max_grapple_length_m` (accepted `<= 1.0`, `OUT_OF_RANGE` band `> 1.0`). The boundary rule is inclusive and quantized: repeated evaluation of the same query state must never flip acceptance (AC 11).
  - [ ] Normalize duplicates and select deterministically (AC 7): collapse duplicate hits/records describing the same collider or contact; explicit stable ordering (quantized distance, blocking/evidence rank, quantized normal and point, stable identity key - the Story 1.5 contact-selection idiom). Engine return order, scene-tree order, and signal connection order must not influence selection.
  - [ ] Evaluate targeting in the pre-commit window (after `PlayerCommandFrame(N)` capture, before movement-HSM update) and publish `GrappleTargetingResult(N)` exactly once; record `source_physics_step = N` and the command-frame identity.

- [ ] 4. Wire same-step activation and remove the legacy duplicate raycast (AC: 8, 9, 10)
  - [ ] In `scripts/player_controller.gd`, delete `_get_grapple_ray_hit()` and its two call sites: `try_start_grapple()` must consume the current step's `GrappleTargetingResult` only (verify `source_physics_step` and command-frame identity match; otherwise typed rejection with no partial state - do not set `is_grappling`, `grapple_point`, `grapple_target`, or elapsed values). `_update_grapple_cursor()` must stop raycasting (AC 10).
  - [ ] Preserve `try_start_grapple() -> bool` call-site semantics in `scripts/player_grounded_state.gd`, `scripts/player_airborne_state.gd`, `scripts/player_wall_run_state.gd` (press-edge activation) and the held-grapple checks in `player_grappling_state.gd` / `player_wall_stick_state.gd`; edit those states only if the typed rejection path requires it.
  - [ ] On accepted activation, seed all five state fields exactly as today's `try_start_grapple()` does: `is_grappling = true`, `grapple_elapsed = 0.0`, `grapple_applied_acceleration = grapple_initial_acceleration`, `grapple_point` = accepted hit position, and `grapple_target` = the seed's `WeakRef` target (same validity semantics as today's `is_instance_valid(grapple_target)` checks). Omitting `is_grappling` or `grapple_target` immediately breaks `submit_grapple_pull()`, `has_valid_grapple()`, and the wall-stick gate. Pull, `22.0 m/s` cap, release, and wall-stick-from-grapple behavior stay playable and unchanged (AC 15).
  - [ ] Presentation consumption (AC 10): extract the targeting reticle/world marker into `game/player/abilities/grapple/presentation/grapple_target_marker.gd` (architecture: "the player-created grapple cursor becomes a dedicated presentation component"); it reads the latest authoritative result at render rate, may visually interpolate, and must not change validity, delay activation, or retain a target after the result becomes unavailable. Preserve current marker visuals (sphere, `grapple_cursor_*` colors) and the frozen rope behavior: hidden-to-visible rope activation resets physics interpolation exactly once (`spec-grapple-visual-interpolation-reset.md`).

- [ ] 5. Consolidate the single authoritative range source (AC: 11)
  - [ ] Remove the competing range scalar `grapple_length` from `scripts/player_controller.gd` exports (keep pull/cap/gravity-scale exports) and remove `player.set("grapple_length", 35.0)` from `scripts/levels/tree_grapple_tutorial.gd`; the disposable tutorial need not keep working, but it and every other caller must stop carrying grapple-range values. Presenter and diagnostics read range from the `GrappleDefinition`/result.
  - [ ] Grep the working tree for `grapple_length`, `35.0`, and `max_grapple` scalars; record the audit result in evidence.

- [ ] 6. Initialization and typed failure handling (AC: 12)
  - [ ] Compose the resolver with its `GrappleDefinition` and profiles through explicit typed references (no dynamic `load()`/path strings at runtime); validate at initialization and return a typed initialization status (mirror `PlayerMotor.InitializationStatus` / `PhysicsQueryProfile.ValidationStatus` style).
  - [ ] On missing/invalid definition, profiles, collision configuration, or resolver dependency: report a typed development-visible result through `GameLog.record_invariant` (existing `game/app/logging/` facade; stable dotted code like `&"player.grapple.targeting_initialization_failed"`) and make the grapple feature safely unavailable per its owner. No fallback to magic masks, direct `StaticBody3D` checks, dynamic resource paths, or a second raycast.

- [ ] 7. Bounded targeting diagnostics (AC: 13)
  - [ ] Expose a bounded read-only targeting diagnostic snapshot (value-only, copied scalars/IDs, built from the authoritative result - zero extra queries) with: query origin and direction, maximum range, first blocking hit, target identity, accept/reject reason, range fraction, profile identifiers, physics-step number.
  - [ ] Route `scripts/debug_grapple_telemetry.gd` to consume the result/snapshot fields (extend `get_grapple_telemetry()` or replace with the typed snapshot); keep the overlay opt-in, throttled (~20 Hz), development-only. Full `DebugOverlayLayer` migration is out of scope; the overlay must not compute gameplay facts.

- [ ] 8. Focused unit and real-Jolt integration tests (AC: 14)
  - [ ] Create `tests/player/grapple/test_grapple_targeting_contract.gd`: typed result/rejection schema (value-only, copy semantics like `test_player_contact_contract.gd`), duplicate normalization and tie-break determinism (shuffled input orders yield identical selection), rejection mapping for all AC 6 conditions, boundary oracle with the locked predicate: geometry at `max_grapple_length_m - epsilon` and exactly `max_grapple_length_m` -> accepted; at `max_grapple_length_m + acquisition_tolerance_m / 2` -> `OUT_OF_RANGE`; beyond `max_grapple_length_m + acquisition_tolerance_m` (e.g. `+ 2 m`) -> `NO_CANDIDATE`; tolerant numeric assertions, definition immutability (writes after lock do not mutate), seed content (AC 4), stale/missing rejection (AC 9), query-count == 1 per evaluated step.
  - [ ] Create `tests/player/grapple/test_grapple_targeting_integration.gd` (small real-Jolt scenes/fixtures with a real `CharacterBody3D` player and controlled stepping): default geometry accepted (AC 2); exceptional `Grappleable3D` accepted and rejected responses (AC 3); first-hit rejection with a valid target behind it (AC 5, no piercing); empty aim; occlusion-only blocker; maximum-range boundary cases; duplicate candidate shapes on one collider; stale-result activation attempt; presentation consumption agreement (reticle state equals result validity/hit position, and mutating presenter state cannot change gameplay validity); diagnostics agreement (AC 13).
  - [ ] Assert exactly one authoritative query per evaluated physics step across integration flows (AC 14) via the result's query count, and deliver `query-writer-audit.md` as a Task 8 artifact: a source-level audit proving no gameplay raycast call site remains outside `GrappleTargetResolver` (the result's own counter cannot detect a stray second raycast elsewhere).
  - [ ] Optional live-gate adapter: `res://tests/test_grapple_targeting_mcp.gd` extending `McpTestSuite` (framework-neutral cases shared where practical). Remember the MCP runner discovers only direct `res://tests/test_*.gd` files and never covers GUT suites; report the two result sets separately.

- [ ] 9. Regression gates, traversal smoke, and evidence (AC: 15)
  - [ ] Run the pinned recursive GUT suites serially from the repository root (canonical command from Story 1.2; substitute the new and existing directories):
    ```powershell
    $env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/grapple -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/motor -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/contact -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
    ```
  - [ ] Run the pinned import/load check and `rtk git diff --check`:
    ```powershell
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --import --quit-after 120
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --quit-after 120
    rtk git diff --check
    ```
  - [ ] Perform the Godot AI MCP dual-gate workflow per AGENTS.md (preflight before editing, verification and runtime/visual smoke after editing): launch `res://main.tscn`, simulate input, and observe grapple acquisition against current targets, reticle agreement, and pull playability. Record MCP session ID, operations, and diagnostics separately from CLI results. If the Godot AI MCP server or an active session is unavailable, stop and report the connection blocker before implementing (AGENTS.md availability rule); never claim unobserved visual/runtime verification.
  - [ ] Write evidence to `_bmad-output/implementation-artifacts/evidence/1-6/` mirroring the 1.5 set (`pre-change-oracle.md`, `matrix-profiles.md`, `targeting-contract.md`, `query-writer-audit.md`, `focused-gut.md`, `recursive-gut.md`, `60-120-comparison.md`, `pinned-load.md`, `mcp-verification.md`, `mcp-native-discovery.md`, `traversal-smoke.md`, `complete-status-diff.md`, `limitations.md`). Do not copy live nodes, absolute personal paths, secrets, or unbounded raw logs into evidence.
  - [ ] Reconcile `_bmad-output/implementation-artifacts/deferred-work.md`: verify the "grapple pull activation" note against current `scripts/player_grappling_state.gd` (where `submit_grapple_pull(delta)` is now called unconditionally) and update the note's status without redesigning pull behavior.

## Dev Notes

### Developer Context

Per-step choreography after this story (binding; extends the Story 1.5 contract):

```text
pre-commit step N:
  capture immutable PlayerCommandFrame(N)            (player input boundary)
  evaluate grapple targeting ONCE from frame N aim    (GrappleTargetResolver; the only gameplay raycast)
  publish GrappleTargetingResult(N)                   (value-only, query_count = 1)
  movement HSM update:
    states submit traversal policy to PlayerMotor
    grapple activation consumes GrappleTargetingResult(N) ONLY (same frame/step identity)
  PlayerMotor resolves semantic phases -> one velocity assignment + one move_and_slide()

post-commit step N:
  contact provider publishes ContactFrame(N)          (unchanged Story 1.5 ownership)
  presentation (reticle/marker, render-rate) reads latest GrappleTargetingResult read-only
  diagnostics read the same result/snapshot (no recompute, no extra query)
  GrappleTargetingResult(N) becomes the sole accepted activation input for step N
```

Targeting is evaluated every physics step so reticle feedback stays current; exactly one gameplay query per evaluated step (AC 14). Activation still fires on the `PlayerCommandFrame.Action.GRAPPLE` press edge (`was_pressed`), held/release checks in `player_grappling_state.gd` / `player_wall_stick_state.gd` are unchanged. `ContactFrame(N-1)` pre-commit semantics, single-motor-commit, and attack-HSM separation are untouched.

### Single Authoritative Query and Result Ownership

- The prototype issues up to two untyped `intersect_ray()` calls per step (`try_start_grapple()` and `_update_grapple_cursor()` both call `_get_grapple_ray_hit()`) and gates acceptance on `collider is StaticBody3D`. All three behaviors are removed (AC 8, 10, 12).
- One owner-local `GrappleTargetingResult` per evaluated step replaces them; activation, reticle/marker, and diagnostics all read it. This is the "grapple/presentation agreement" item of the mandatory contract suite (NFR20).
- Architecture activation order for acquisition (steps 1-3) is implemented verbatim; steps 4-6 (attachment commit, per-step `GrappleAnchorState` sampling, maximum-range constraint) stay with Stories 1.7/1.8 except the seed's one-time target-local hit offset (AC 4).
- Hot-path rule: rejection checks use the typed enum; the single per-step result record is existing typed state, not a per-consumer allocation (architecture "Error Handling" hot-path guidance).

### Rejection and Determinism Decision

- Closed stable reason set starts from architecture `GrappleRejection` (`NONE, NO_CANDIDATE, OUT_OF_RANGE, OCCLUDED, INVALID_SURFACE`) and must cover all six AC 6 situations plus AC 9 (suggested additions: explicit policy rejection, `TARGET_INVALID`, `MALFORMED_TARGET_DATA`, `MISSING_RESULT`, `STALE_RESULT`; final names are the implementer's to lock and record).
- Required mapping (locked predicate): no hit -> `NO_CANDIDATE`; first blocking candidate with quantized distance in `(max_grapple_length_m, max_grapple_length_m + acquisition_tolerance_m]` -> `OUT_OF_RANGE`; occlusion-only first hit -> `OCCLUDED`; ineligible surface -> `INVALID_SURFACE`; invalid target -> target-invalid reason; missing required target data (non-finite vectors, unusable identity where required) -> malformed-data reason. Expected rejection never routes to `GameLog` error/warning paths.
- Determinism (AC 7) reuses the Story 1.5 idiom: quantized distances/points/normals from `PhysicsQueryProfile` quantization fields, explicit evidence rank, stable identity key; indistinguishable duplicates collapse; input/engine/scene-tree/signal order is never a tie-break (`prioritize_collision_indices()` style order-preservation is reporting only and must not become the selector).

### Range and Boundary Tolerance Decision

- `GrappleDefinition.max_grapple_length_m` (35 m) is the sole authoritative acquisition range (AC 11). Locked predicate: accept iff quantized hit distance `<= max_grapple_length_m` (inclusive; quantization makes the exact boundary stable across 60/120 Hz and repeated evaluation); report `OUT_OF_RANGE` for a first blocking candidate in `(max_grapple_length_m, max_grapple_length_m + acquisition_tolerance_m]`; the ray itself extends only by `acquisition_tolerance_m` so that band is observable. `acquisition_tolerance_m` is a physics/quantization tolerance (bound at `point_quantization_m`/margin magnitude), not a range scalar. No other range scalar may exist in scenes, tutorial, presenter, or diagnostics.
- The shared `PhysicsQueryProfile` carries query *meaning* (named masks, flags, quantization) but not acquisition range. Two constraints make it unable to express a ray profile today: the mandatory non-null `shape` (`INVALID_SHAPE`) with probe-shape assets, and `MAX_PROBE_DISTANCE_M = 4.0` / `MAX_SWEEP_DISTANCE_M = 4.0` contact-probe bounds (Story 1.5 P1 fix: bounds enforced before querying). Preferred resolution: a small typed generalization of `PhysicsQueryProfile` (optional ray-relevant fields and/or a ray-profile shape exemption) that preserves every existing contact bound and keeps `tests/player/contact/test_player_contact_contract.gd` green. Prohibited: dummy shapes, a second parallel profile system, magic masks, or silently raising contact bounds.
- Composition rule (AC 14): one ray per evaluated step over the union candidate|occlusion mask; a body passing both profiles is a candidate; the occlusion profile only marks blocking-but-unacquirable surfaces. No second occlusion ray.
- Boundary behavior is inclusive and quantized so 60 Hz, 120 Hz, and repeated same-state evaluation agree (NFR4); tests assert at `max - epsilon`, `max` (accept), `max + acquisition_tolerance_m / 2` (`OUT_OF_RANGE`), and beyond the tolerance band (`NO_CANDIDATE`).

### Requirement Traceability

- **FR6** (primary): one authoritative crosshair-directed grapple query reporting candidate identity, hit point, validity, rejection reason, range, attachment state -> AC 1, 6, 8, 13, 14.
- **FR7** (primary): ordinary geometry grappleable by default; exceptional typed `Grappleable3D` responses -> AC 2, 3, 4.
- **FR3** (supporting): immutable per-step command frame supplies authoritative aim and action edges -> AC 1, 8.
- **FR8 / FR9** (preserve, do not change): zip-pull and maximum-length boundary behavior stay as-is; FR9's active boundary enforcement is Story 1.7 -> AC 11, 15.
- **FR10** (deferred): moving-target tracking/invalidation is Story 1.8 -> AC 4.
- **FR58 / NFR19** (partial): bounded read-only grapple targeting diagnostics reusing authoritative results -> AC 13.
- **NFR4** (60/120 Hz equivalence), **NFR6** (query tolerance, no tunnelling assumptions), **NFR12** (typed init failure, no partial activation), **NFR20** (contract suite: grapple/presentation agreement, definition immutability), **NFR21** (risk-appropriate evidence) -> AC 11, 12, 14.
- GDD pillar 1 (aimed acceleration-based zip-pull, no aim snapping) and "No target-priority assist or aim snapping is planned for grapple acquisition" bind the resolver: first valid crosshair hit only.

### Architecture and Scope Guardrails

- File the feature under `game/player/abilities/grapple/` (targeting, definitions, presentation) with cross-domain contracts in `game/shared/contracts/` and profile assets in `game/shared/physics/`. Do not add systems to legacy `scripts/` beyond the migration edits listed above.
- Only `PlayerMotor` writes final velocity or calls `move_and_slide()`; the resolver, `Grappleable3D`, and presentation are not motor writers. `Grappleable3D` returns bounded data only (AC 3).
- Immutable definitions; owner-local mutable state (`is_grappling`, `grapple_point`, elapsed/acceleration remain player-owned runtime state). No shared-Resource mutation (`definition.max_grapple_length_m *= x` is the documented anti-pattern).
- Typed direct methods for commands/queries; past-tense signals only after committed facts; per-step data flows through read-only snapshots, not per-step signal mirrors. No event bus, global store, or service locator.
- Commands verb-led (`request_/apply_/cancel_`), queries `can_/has_/is_/find_/get_`, booleans `is_/has_/can_`, classes `PascalCase`, enum values `UPPER_SNAKE_CASE`, units in names (`max_grapple_length_m`, `range_fraction`, `source_physics_step`), stable dotted lowercase `StringName` IDs (`&"player.grapple.default"`, diagnostic codes like `&"player.grapple.targeting_initialization_failed"`).
- Preserve exactly: single motor commit and seven-phase resolution; `ContactFrame` semantics and ownership; movement/attack HSM separation and all `EVENT_*` transitions; press-edge activation; pull formula (`48 -> 8 m/s^2` at `53.333333 m/s^3`), `22.0 m/s` total-speed cap (`player.grapple.speed_cap`), `grapple_gravity_scale`, velocity-preserving release, wall-stick-from-grapple conditions (held GRAPPLE + contact + speed/alignment gates); rope hidden-to-visible `reset_physics_interpolation()` (frozen spec `spec-grapple-visual-interpolation-reset.md`); `PhysicsQueryProfile` contact bounds; `res://main.tscn` as launch scene; UIDs (`scenes/player.tscn` `uid://u1u36ceuo8uj`, `player_grappling_state.gd` `uid://cjlui8t4vv7ha`, all existing `.gd.uid` sidecars); `PlayerCommandFrame` immutability and `Action` enum.
- Frozen-spec discipline: `spec-grapple-visual-interpolation-reset.md` is human-owned intent. Story 1.6 must preserve its accepted rope behavior. If implementation would alter the rope visual lifecycle beyond preservation or change project-wide interpolation/motor/contact behavior, stop and ask the user first.
- Known migration debt (do not expand; remove only what this story supersedes): prototype `move_and_slide()` call sites, legacy `print`/`push_error` diagnostics, `scripts/player_controller.gd` as the retained controller. Do not bulk-move legacy controller/state files.
- Unrelated uncommitted working-tree changes (create-story routing configuration cleanup) must remain untouched; scope edits to the File List.
- Dependency versions are pinned: Godot 4.7.2-stable, Forward+, Jolt, GUT 9.7.1, LimboAI 1.8.1 (vendored), Terrain3D optional (grapple code must not depend on it), Phantom Camera deferred (use built-in `Camera3D`/`SpringArm3D` only). Known recorded discrepancy: planning lists Godot AI 3.2.4 while the local MCP plugin/server reports 4.0.4 - record only, change no dependency files.

### Current-State Update Map

Definite UPDATE:
- `scripts/player_controller.gd` - today: owns grapple exports (`grapple_length = 35.0` plus pull/cap/gravity/visual tuning), `is_grappling`/`grapple_point`/`grapple_target: StaticBody3D` runtime state, `_get_grapple_ray_hit()` (untyped `intersect_ray` from `camera.global_position` along `frame.aim_world_direction`), `try_start_grapple()` (`StaticBody3D` check), `_update_grapple_cursor()` (second raycast), `_update_grapple_visual()` (rope + interpolation reset), `get_grapple_telemetry()` (Dictionary). This story: replaces targeting internals with resolver consumption, removes the duplicate raycast and the `grapple_length` scalar, extracts the reticle presentation, keeps pull/cap/release/wall-stick logic and the rope lifecycle byte-compatible in behavior.
- `scripts/levels/tree_grapple_tutorial.gd` - today: assigns `player.set("grapple_length", 35.0)` and `player.set("grapple_gravity_scale", 0.65)` after `add_child()`. This story: removes the competing range assignment (and any other grapple-range scalar); tutorial survival is explicitly not required (AC 15).
- `scripts/debug_grapple_telemetry.gd` - today: CanvasLayer overlay (F3), ~20 Hz refresh, consumes `get_grapple_telemetry() -> Dictionary`. This story: consumes the typed targeting result/diagnostic snapshot fields (AC 13); stays dev-only and bounded.
- `scenes/player.tscn` - today: wires `player_grappling_state.gd`, `debug_grapple_telemetry.gd` (GrappleTelemetry node) and the motor child. This story: wires the new presentation component; preserves all UIDs and existing node contracts.
- `project.godot` - today: named layers `world_geometry`, `player_body`, `enemy_body`, `player_hurtbox`, `enemy_hurtbox`; interpolation enabled. This story: named grapple collision entries if required by the matrix decision; nothing else.
- `game/shared/physics/physics_query_profile.gd` - conditional update per "Range and Boundary Tolerance Decision"; all existing validation semantics and `tests/player/contact/test_player_contact_contract.gd` expectations preserved.
- `_bmad-output/implementation-artifacts/deferred-work.md` - reconcile the stale grapple-pull-activation note.

Expected NEW: `game/player/abilities/grapple/grapple_target_resolver.gd`; `game/player/abilities/grapple/definitions/grapple_definition.gd` + `.tres`; `game/player/abilities/grapple/presentation/grapple_target_marker.gd`; `game/shared/contracts/grappleable_3d.gd`, `grapple_target_response.gd`, `grapple_targeting_result.gd`, `grapple_rejection.gd` (or equivalent enum placement), `grapple_target_seed.gd`, `grapple_targeting_diagnostic_snapshot.gd`; `game/shared/physics/grapple_candidate.tres`, `grapple_occlusion.tres`; `tests/player/grapple/test_grapple_targeting_contract.gd`, `test_grapple_targeting_integration.gd`; optional `res://tests/test_grapple_targeting_mcp.gd`; evidence files under `evidence/1-6/`. All new `.gd` files get `.gd.uid` sidecars via the editor/import flow.

Inspect if needed (no changes expected): `game/player/motor/player_motor.gd` and `player_motor_commit_result.gd` (submission API and step identity to mirror); `game/shared/physics/contact_frame.gd`, `contact_candidate.gd`, `contact_rejection.gd`, `player_contact_provider.gd` (value-record, quantization, and tie-break patterns to mirror); `game/player/input/player_command_frame.gd`, `player_input_source.gd` (frame identity, aim fields); `game/app/logging/game_log.gd`, `diagnostic_context.gd` (typed failure/diagnostic conventions); `tests/player/motor/*`, `tests/player/input/*` (fixture style, 60/120 Hz harness); `scripts/player_*_state.gd` (call sites).

Preserve unchanged: `scripts/player_grappling_state.gd` pull/cap/release flow (edit only if typed rejection plumbing requires), `scripts/player_wall_stick_state.gd`, `scripts/player_dead_state.gd`, `scripts/player_wall_run_state.gd`, motor and contact implementations, `demo/**`, `addons/**`, `ai/**`, `materials/**`.

### Predecessor and Git Intelligence

- Stories 1.3 (done), 1.4 and 1.5 (both `review`, not `done`) established: single `PlayerMotor` commit with seven semantic phases; immutable `PlayerCommandFrame` per step with latched edges; one `ContactFrame` per committed step with value-only bounded records; typed init/submission enums; `GameLog.record_invariant` failure routing; canonical deterministic selection with quantization and stable tie-breaks. Do not infer `done` from automated checks alone (1.3 precedent: manual smoke confirmation required).
- Carry-forward lessons (1.5 P1 fixes): never publish predicted instead of authoritative data (re-query at the authoritative transform); consume complete result sets and make ties canonical (never `result[0]` or input order); enforce bounds before querying; fix step-identity bookkeeping on every branch; convert engine collision/query output to bounded value records immediately (no `KinematicCollision3D`, `Dictionary`, or `Node` escapes).
- Test conventions: small real-Jolt scenes with typed fixtures and controlled stepping; `autofree`; tolerant numeric assertions (velocity drift `<= 0.05 m/s`, position drift `<= 0.10 m` over 60 steps, one-step transition alignment); `delta_seconds = 1.0 / tick_rate` for 60/120 Hz comparisons; restore `Engine.physics_ticks_per_second` even on failure; assert accepted/duplicate-rejected counters separately.
- Open risks to respect: Story 1.5 P2s (lossy overflow accounting; profile runtime immutability not fully closed - `unlock_for_editor()` callable at runtime; init `SUCCESS` on invalid optional wall profile) mean do not widen profile mutability and keep grapple bounds enforced pre-query; Story 1.5 AC13 evidence gaps (120 Hz live comparison, wall-loss smoke) remain open and are not this story's debt. Deferred work item on grapple pull activation must be verified/reconciled (Task 9).
- Recent commits: `ef3cc06` (Story 1.5 completion + grapple visual interpolation reset - preserve exactly), `2dc80de` (Story 1.6 planning context), `7bf250e` (AGENTS.md tooling-requirement cleanup), `0585848`/`c200a18` (command-frame boundary, physics commit hardening patterns to mirror). Working tree at authoring time contains an uncommitted create-story routing configuration cleanup; leave it untouched.

### Testing Requirements

- Dual test harness is mandatory (AGENTS.md):
  - **GUT (canonical regression gate):** pinned Godot CLI recursive runs under `res://tests/player/**` (commands in Task 9). Report scripts/tests/assertions, exit codes, expected invariant diagnostics, unexpected errors, and teardown/import noise separately. Historical baselines (21/21 input, 36/36 motor, 11/11 contact with 89 assertions at 1.5, 68/68 recursive) are not a substitute for a Story 1.6 run.
  - **Godot AI MCP (live-session gate):** preflight before editing; post-edit scan/reload and editor diagnostics; launch `res://main.tscn` with `game_eval`/simulated input for grapple acquisition smoke; MCP log inspection; record session ID and operations. MCP `test_run` discovers only direct `res://tests/test_*.gd` `McpTestSuite` files - never treat it as GUT coverage or parity, and report `total=0` discovery outcomes honestly.
- Real-Jolt integration coverage is required for grapple/collision behavior (architecture risk table). No fake `move_and_slide()`, no arbitrary sleeps, no exact float equality, no rendered-frame timing, no private node-path coupling, no deep physics mocking, no large tree snapshots, no pixel-perfect screenshot assertions.
- Determinism: fixed seeds, stable IDs, controlled physics stepping; shuffled candidate orders must produce identical selection (AC 7); same query state must produce identical acceptance at the boundary (AC 11); query-count assertions prove the single-query contract (AC 14).
- Every claim of runtime/visual behavior needs reproducible verification evidence: command or scene, setup and inputs, expected result. Visual verification may only be claimed when actually observed (Godot AI MCP per AGENTS.md; frozen spec states the same rule).

### Latest Technical Information

- Pinned engine Godot 4.7.2-stable; do not upgrade. Version-specific docs via Context7 or the 4.7 doc tree.
- `PhysicsRayQueryParameters3D` (https://docs.godotengine.org/en/4.7/classes/class_physicsrayqueryparameters3d.html): `create(from, to, collision_mask, exclude)`; set `collision_mask` from `PhysicsQueryProfile.get_collision_mask()` and `exclude` to the player RID. `collide_with_bodies = true`, `collide_with_areas = false` defaults - honor profile flags instead of defaults.
- `hit_from_inside` defaults to `false` (a ray starting inside a shape returns no hit) and when enabled such a hit reports `normal = Vector3(0, 0, 0)` - treat a zero/degenerate normal as malformed target data or ineligible surface per the documented mapping, never as a valid surface normal.
- `hit_back_faces` defaults to `true`; `PhysicsDirectSpaceState3D.intersect_ray()` returns a `Dictionary` with `position`, `normal`, `collider`, `collider_id`, `shape`, `rid` - convert to bounded typed values immediately and discard the dictionary.
- Ray-casting tutorial: https://docs.godotengine.org/en/4.7/tutorials/physics/ray-casting.html. Jolt physics: ray queries are stable; keep assertions tolerant (NFR6).
- Story 1.5 probe semantics remain binding elsewhere: `cast_motion()` ignores already-overlapping shapes; `intersect_shape()` ignores `motion`; `is_on_floor()` facts describe the last `move_and_slide()` - none of these are used by the grapple ray path.

### Story-Authoring Godot AI MCP Evidence

- **Not run - environment limitation, recorded honestly.** The story-authoring session (OpenCode) exposes no godot-ai MCP tools (tool catalog search returned no godot-ai/mcp editor tools; the `godot-ai` MCP server is configured only in `.codex/config.toml` for the Codex harness). No scene, node, script, or editor state was inspected through MCP for this authoring pass; all current-state facts come from repository files listed in the Source References.
- Consequence per AGENTS.md availability rule: the dev-story agent must establish an active Godot AI MCP session (list sessions, identify the active project session, verify editor readiness, current scene, play state, diagnostics) before editing, use MCP for Godot-side operations during implementation, and complete the MCP validation gate (rescan/reload, tests where supported, logs, runtime/visual smoke) afterward. If the server or an active session is unavailable at implementation time, stop before implementing and report the connection blocker.
- Distinguish MCP-observed results from CLI-only results in the Dev Agent Record; never claim visual or runtime verification that was not observed.

### Project Structure Notes

- Naming variance (recorded with rationale): architecture's directory row names `grapple_query.gd` inside `game/player/abilities/grapple/`, while the contract table names the type `GrappleTargetResolver` and project naming rules require a class-name-matching filename. Implement the type in `grapple_target_resolver.gd` (class `GrappleTargetResolver`) and note the variance in Completion Notes; do not create both a `grapple_query.gd` wrapper and a resolver.
- Tests mirror runtime domains: grapple targeting tests live in `tests/player/grapple/`; cross-domain integration and fixtures stay in `tests/integration/` and `tests/fixtures/` only when shared.
- Target architecture migration continues incrementally and Godot-aware: new systems go to `game/`, legacy `scripts/` remains a migration source; no blind bulk moves; preserve UIDs and verify affected scenes.
- No speculative folders or abstractions (no managers, registries, save/inventory/networking scaffolding).

### Source References and Artifact Ledger

Bounded context pack: `_bmad-output/.artifact-index/context-1-6.json` (6 files; `inventory_valid: true`). Artifact IDs and revisions (SHA-256) used to create this story:

| Artifact ID | Path | SHA-256 (revision) |
|---|---|---|
| `grapplegame.epics.requirements` | `_bmad-output/planning-artifacts/epics/requirements.md` | `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b` |
| `grapplegame.epics.1` | `_bmad-output/planning-artifacts/epics/epic-01-overview.md` | `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168` |
| `grapplegame.story.1.6` | `_bmad-output/planning-artifacts/epics/epic-01-story-06.md` | `a5141fc63abd0cba2168f61fba4334fe2eca480f6e81daa73c3a22dc13ead41e` |
| `grapplegame.gdd` | `_bmad-output/planning-artifacts/gdd.md` | `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156` |
| `grapplegame.architecture` | `_bmad-output/planning-artifacts/architecture.md` | `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080` |
| `grapplegame.project-context` | `_bmad-output/project-context.md` | `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97` |
| `grapplegame.decision-log` | `_bmad-output/planning-artifacts/decision-log.md` | `01454eb5eadbeb60cffe4508fcae8336cfb4bc8dd14c19230964c28a5fb72a00` |

- Epics manifest revision: `epics_manifest_sha256 = 8a0a51a1d4915b4aa75a7f96a427d03200a2fe0b4538ac061c9ab19afe045d15` (source `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`).
- GDD scope note (resolver warning, permitted): GDD `status: 'needs-decisions'` with `implementation_scope_ready: 'M0 implementation-start only; no milestone is acceptance-ready'` - allowed for epic-1 story scopes. Do not present any milestone as acceptance-ready.
- Continuity references: `_bmad-output/implementation-artifacts/1-5-share-authoritative-ground-and-wall-contact-facts.md`, `1-4-resolve-traversal-through-semantic-motor-phases.md`, `1-3-centralize-the-players-physics-step-movement-commit.md`, `deferred-work.md`, `spec-grapple-visual-interpolation-reset.md` (frozen), `evidence/1-3..1-5/`.
- Key architecture sources: "Cross-System Contract Specifications" -> "Grapple target contract"; "Collision Matrix and Query Profiles"; "Keyboard and Mouse Input" -> "Command frames"; "HUD and UI" -> "Grapple presentation"; "Error Handling"; "Data Patterns" (`GrappleDefinition` sample, immutable-definition rules); "Lean AI-First Verification and Instrumentation"; "Setup and Verification Commands"; "Consistency Rules" (grapple range/tether rows).
- Key requirement sources: FR3, FR6, FR7, FR8, FR9, FR10, FR58; NFR4, NFR6, NFR12, NFR19, NFR20, NFR21 (see `_bmad-output/planning-artifacts/epics/requirements.md`).
- Current-state sources read at authoring: `scripts/player_controller.gd`, `scripts/player_grappling_state.gd`, `scripts/player_grounded_state.gd`, `scripts/debug_grapple_telemetry.gd`, `scripts/levels/tree_grapple_tutorial.gd` (range assignments), `game/player/input/player_command_frame.gd`, `game/player/motor/player_motor.gd` (API surface), `game/shared/physics/physics_query_profile.gd`, `game/shared/physics/contact_frame.gd`, `game/shared/physics/ground_probe.tres`, `tests/player/contact/test_player_contact_contract.gd`, `project.godot` (layer names), `scenes/player.tscn` (grapple references).
- Web references: Godot 4.7 `PhysicsRayQueryParameters3D` and Ray-casting documentation (see Latest Technical Information).

### Story Completion Status

- Status: `ready-for-dev` - Ultimate context engine analysis completed - comprehensive developer guide created. Story key `1-6-acquire-grapple-targets-consistently`; sprint status updated to `ready-for-dev` on 2026-09-24. Boundary tolerance naming (`acquisition_tolerance_m`), final `GrappleRejection` value set, grapple collision-layer matrix, and the `PhysicsQueryProfile` ray-variance resolution are bounded implementation decisions to record in Completion Notes at dev time.

## Dev Agent Record

### Agent Model Used

MiMo-V2.6-Pro (OpenCode) - story authoring only; no implementation performed.

### Debug Log References

### Completion Notes List

### File List
