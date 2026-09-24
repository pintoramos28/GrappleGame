# Grapple targeting contract

## One authoritative result per evaluated physics step (AC 1)

`GrappleTargetResolver.evaluate(N, frame, origin)` performs exactly one
`intersect_ray` over the union candidate|occlusion mask and publishes one
value-only `GrappleTargetingResult(N)` carrying: `source_physics_step`,
`command_frame_step` (command-frame identity), query origin/direction,
`max_grapple_length_m`, first blocking hit (position, normal, distance),
target identity (empty allowed), validity, typed `GrappleRejection.Reason`,
`range_fraction`, accepted `GrappleTargetSeed` (or empty), profile ids, and
`query_count` (bounded at `MAX_QUERY_COUNT := 1`). Repeat evaluation of step N
returns the same published record without a second query; older steps are
rejected `STALE_RESULT` with `query_count = 0`.

## Locked classification predicate (recorded at Task 3)

Given the first blocking hit H (or none):

1. no hit -> `NO_CANDIDATE`;
2. non-finite hit facts -> `MALFORMED_TARGET_DATA`;
3. kind first: explicit `Grappleable` direct child or candidate-mask match is a
   candidate; occlusion-only match -> `OCCLUDED`; neither -> `INVALID_SURFACE`
   (union guard). Explicit-component presence makes a hit a candidate so
   exceptional targets answer for themselves on any blocking layer;
4. candidate with degenerate (zero-length) normal -> `INVALID_SURFACE`
   (ineligible surface; the documented zero-normal rule);
5. candidate with quantized distance in `(max, max + acquisition_tolerance_m]`
   -> `OUT_OF_RANGE` (`range_fraction > 1.0`); a hit beyond `max + tolerance`
   (float noise case) -> `NO_CANDIDATE`;
6. in-range explicit policy: invalid/missing target -> `TARGET_INVALID`;
   missing response or empty required identity -> `MALFORMED_TARGET_DATA`;
   `eligible == false` -> `POLICY_REJECTED`; else acceptance with the authored
   response;
7. in-range default policy -> acceptance with `GrappleTargetResponse.static_default()`.

Acceptance is inclusive and quantized: `quantized_distance <=
max_grapple_length_m`; `range_fraction = quantized_distance /
max_grapple_length_m`. Quantization uses `point_quantization_m` (0.001 m), so the
same query state never flips acceptance (AC 11; proven at 60/120 Hz).

Rationale note: the Task 3 chain reads distance-band-first while the Dev Notes
"Required mapping" scopes `OUT_OF_RANGE` to "first blocking **candidate**" and
`OCCLUDED` to "occlusion-only first hit". The implementation follows the Dev
Notes mapping (kind first, then range within the candidate path); both readings
agree everywhere except an occlusion-only hit inside the tolerance band, which
reports `OCCLUDED`.

## Closed rejection set (implementer-locked, recorded per Task 2)

`GrappleRejection.Reason = { NONE, NO_CANDIDATE, OUT_OF_RANGE, OCCLUDED,
INVALID_SURFACE, POLICY_REJECTED, TARGET_INVALID, MALFORMED_TARGET_DATA,
MISSING_RESULT, STALE_RESULT }` (10 values). The first seven non-`NONE` values
cover every AC 6 situation plus explicit policy rejection and are
`is_expected_gameplay_rejection() == true` (never routed to `GameLog`
error/warning). `MISSING_RESULT` / `STALE_RESULT` cover AC 9 activation
validation and stay developer-visible (`player.grapple.activation_*`
invariants).

## Seed and the documented engine-reference exception (AC 4)

`GrappleTargetSeed` = stable target identity, world hit position and normal,
applicable authored response, target-local hit offset computed once at
acquisition, and one `WeakRef` target reference. That `WeakRef` is the single
documented engine reference inside grapple result records; consumers gate every
dereference with `is_instance_valid` / `has_live_target()` (NFR14). No
continuous tracking, lifetime sampling, or invalidation here (Story 1.8).
Detached targets fall back to their local transform for the offset (tree targets
use `global_transform`).

## Determinism (AC 7)

Duplicate `Grappleable` records describing the same collider/contact collapse
through the Story 1.5 idiom (quantized dedup key, encounter order preserved for
reporting only); selection is lexicographic on [quantized distance, blocking
evidence rank, quantized normal xyz, quantized point xyz, stable identity key,
response content key]. Engine return order, scene-tree order, and signal
connection order never select a target; shuffled inputs produce identical
selection (contract-tested).

## Activation (AC 8, 9)

`try_start_grapple()` consumes only the current step's result (matching
`source_physics_step` and `command_frame_step`); stale/missing results reject
with a typed reason and no partial state. Acceptance seeds exactly the five
today-semantics fields: `is_grappling`, `grapple_elapsed = 0.0`,
`grapple_applied_acceleration = grapple_initial_acceleration`, `grapple_point`
= seed hit position, `grapple_target` = the seed's `WeakRef` target (gated with
`is_instance_valid`, preserving `has_valid_grapple()` semantics).

## Composition and typed failure (AC 12)

`GrappleTargetResolver.initialize(body, definition, occlusion_profile)` mirrors
`PlayerMotor.InitializationStatus`; it validates and locks the definition and
both ray profiles, and rejects non-distinct/unresolvable profile composition
(`INVALID_COMPOSITION`). Failure records
`&"player.grapple.targeting_initialization_failed"` through `GameLog` and the
grapple feature is safely unavailable while movement continues. No fallback to
magic masks, `StaticBody3D` checks, dynamic resource paths, or a second ray.

## Naming variance (Project Structure Notes)

The architecture directory row names `grapple_query.gd`; the contract table
names `GrappleTargetResolver` and project rules require class-name-matching
filenames. Implemented as `grapple_target_resolver.gd` (class
`GrappleTargetResolver`); no `grapple_query.gd` wrapper exists.

## Boundary tolerance (Task 1)

`acquisition_tolerance_m = 0.005` is a physics/quantization tolerance only;
validated against `MAX_ACQUISITION_TOLERANCE_MULTIPLIER * max(point_quantization_m,
margin_m)` = 0.01 m with the authored profiles (bound recorded per Task 1:
0.001 m-0.01 m with current quantization/margin). It exists solely so the
`OUT_OF_RANGE` band is observable at the ray endpoint; it is not acceptance
range and never a second range scalar.

## 2026-09-24 — review-fixes amendments

- **`query_count` is measured, not clamped.** `GrappleTargetResolver` routes the
  one gameplay ray through a counted wrapper (`_counted_intersect_ray`, the
  file's only engine ray call shape — pinned by a source scan), so the count
  reflects the calls that actually ran and is passed into
  `GrappleTargetingResult`, which stores it verbatim (a wrong count, negative
  included, stays observable instead of being erased by a floor clamp). The
  named contract constant `MAX_QUERY_COUNT := 1` remains, and
  `matches_single_query_contract()` returns `query_count == MAX_QUERY_COUNT`,
  so any evaluated step with a count != 1 is observable. `no_query_failure()`
  still reports `query_count = 0`.
- **Degenerate normal -> `MALFORMED_TARGET_DATA` before kind/range.** The
  zero/degenerate hit-normal check moved from the post-kind candidate path
  (where it mapped to `INVALID_SURFACE`) into the malformed-data block right
  after the non-finite checks and before kind classification and the range
  band.
- **`INVALID_SURFACE` vs `POLICY_REJECTED` definitions.** `INVALID_SURFACE` =
  the blocking surface is ineligible for grapple (surface/kind level);
  `POLICY_REJECTED` = a valid target explicitly refuses via its authored
  response; `MALFORMED_TARGET_DATA` = required hit/target data is unusable
  (non-finite vectors, degenerate normal, bad identity/response).
- **Init-failure activation -> `MISSING_RESULT` without per-press invariants.**
  When the grapple feature is unavailable because initialization failed
  (resolver missing/not initialized), `try_start_grapple()` typed-rejects with
  `MISSING_RESULT` and records NO per-press `GameLog` invariant; the one-time
  `player.grapple.targeting_initialization_failed` invariant logged at
  composition remains. The logged per-press invariant path is kept for a live
  feature that produced no result (and, unchanged, for `STALE_RESULT` step
  mismatch and `TARGET_INVALID` dead `WeakRef`).
