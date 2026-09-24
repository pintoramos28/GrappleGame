# Focused GUT runs (canonical regression gate, per domain)

All runs: pinned Godot 4.7.2 console (operator-local), `--headless --path . -s
res://addons/gut/gut_cmdln.gd -gdir=<dir> -ginclude_subdirs -gexit`, GUT 9.7.1.
Raw logs: `focused-gut-<domain>.log` beside this file.

## RED phase (before implementation, recorded honestly)

`res://tests/player/grapple` failed to parse: "Could not find type
GrappleTargetResolver / Grappleable3D / GrappleTargetingResult /
GrappleTargetingDiagnosticSnapshot / GrappleTargetSeed / GrappleTargetResponse /
GrappleRejection / GrappleDefinition / GrappleTargetMarker in the current
scope" - the expected pre-implementation failure that validates the new suites
exercise not-yet-existing contracts.

## GREEN phase (final)

| Domain | Scripts | Tests | Passing | Asserts | Exit |
|---|---|---|---|---|---|
| `tests/player/input` | 3 | 21 | 21 | 677 | 0 |
| `tests/player/motor` | 3 | 36 | 36 | 2,321 | 0 |
| `tests/player/contact` | 1 | 11 | 11 | 89 | 0 |
| `tests/player/grapple` | 2 | 24 | 24 | 357 | 0 |

Expected `push_error` diagnostics (`GameLog` motor invariants; the two Story 1.6
activation-contract invariants `player.grapple.activation_stale_result` /
`player.grapple.activation_missing_result`) were asserted in-test and are not
unexpected errors.

## Intermediate regression caught and fixed during the run

The first motor run after migration failed 35/36: the migrated
`test_authored_tuning_contexts_remain_distinct_and_tutorial_reset_stays_out_of_band`
asserted a blanket `tutorial_source.contains("35.0") == false`, which collided
with the tutorial's unrelated `sun.rotation_degrees = Vector3(-58.0, 35.0, 0.0)`.
The assertion was narrowed to the actual contract (`grapple_length` /
`max_grapple` must not appear), after which motor passed 36/36 with 2,321
assertions. A grapple-suite fix during the same cycle replaced detached-node
`to_local()` calls (engine "not inside tree" errors) with the documented
local-transform fallback, keeping all 24 grapple tests green without engine
noise.

## Story 1.6 suite contents

- `tests/player/grapple/test_grapple_targeting_contract.gd` (12 tests): result
  schema/value-only/copy bounds and malformed-payload sanitization; closed
  rejection set and expected-gameplay classification; definition validation,
  locking, immutability, tolerance bound, authored asset; ray-profile shape
  exemption with contact bounds intact; duplicate normalization and
  order-independent selection; full AC 6 rejection mapping; the quantized
  inclusive boundary oracle (max-epsilon, max, max+tol/2, band top, beyond band,
  repeat-stability); seed content and documented `WeakRef` exception; missing/
  stale rejection schema and resolver evaluation guards (idempotent publish,
  zero-query stale/missing); typed initialization failure matrix; diagnostic
  snapshot derivation.
- `tests/player/grapple/test_grapple_targeting_integration.gd` (12 tests, real
  Jolt): default geometry acceptance; exceptional `Grappleable3D` accepted and
  rejected responses plus query-only API surface scan; no-piercing first-hit
  rejection (policy and occlusion); empty aim and occlusion-only blockers;
  maximum-range boundary cases through the authored 35 m range; duplicate
  candidate shapes on one collider; same-step activation seeding all five state
  fields with playable pull; stale/missing/rejected activation without partial
  state; presentation consumption and agreement; diagnostics agreement;
  exactly-one-query-per-step flows; 60/120 Hz acceptance equivalence.
