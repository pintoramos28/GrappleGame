---
title: '1.6 review fixes: observable targeting contracts'
type: 'bugfix'
created: '2026-09-24'
baseline_commit: 5a3bfedf0fc2df815d5f095ffc5469e353f8274d
status: 'done'
context: ['_bmad-output/implementation-artifacts/evidence/1-6/targeting-contract.md']
---

<frozen-after-approval reason="human-owned intent — do not modify unless human renegotiates">

## Intent

**Problem:** Story 1.6's contracts can regress silently: the one-query-per-step counter is a hardcoded literal clamped to 1, the legacy-raycast source guard truncates itself on the name it forbids, preserved pull/cap and frozen rope behavior have no failing assertion, value-only records self-report `true`, and the rejection mapping leaves degenerate-normal precedence and init-failure activation undefined.

**Approach:** Make the contracts measurable and closed: count queries at the real ray site, fix the source guard, lock the rejection mapping, and add the missing GUT assertions (pull decay/cap, rope resets, value-only shape, range-scalar absence, definition-vs-export parity). No gameplay redesign.

## Boundaries & Constraints

**Always:** gameplay behavior preserved exactly (pull 48 -> 8 m/s^2 at 53.333333 m/s^3, 22 m/s cap, release, wall-stick, rope lifecycle per frozen `spec-grapple-visual-interpolation-reset.md`); `GrappleDefinition.max_grapple_length_m` the only range scalar; GUT green incl. new assertions; AGENTS.md dual gate (MCP + GUT, results separate); `.gd.uid` sidecars kept; no new dependencies.

**Ask First:** changing `GrappleRejection.Reason` values/names; any pull/release/rope behavior change; `scenes/player.tscn` wiring; frozen specs.

**Never:** second gameplay raycast; magic masks; new range scalars; shared-Resource mutation; pull redesign; Story 1.7/1.8 scope; bulk moves of legacy `scripts/`.

## I/O & Edge-Case Matrix

| Scenario | Input / State | Expected Output / Behavior | Error Handling |
|---|---|---|---|
| single query | one evaluated step | `query_count` = measured `intersect_ray` calls (1) | non-1 fails `matches_single_query_contract()` |
| violation visible | factory given count 2 or 9 | `query_count` reports the given value | no clamp erasure |
| degenerate normal | zero/non-finite hit normal | `MALFORMED_TARGET_DATA` before kind/range | no accept, no log |
| feature unavailable | grapple pressed after init failure | typed rejection (`MISSING_RESULT`) | no per-press invariant log |
| rope transitions | hidden -> visible -> visible | reset count +1 on first show only | N/A |
| dirty record | record field holding a `Node` | `is_value_only()` false | test asserts detection |

</frozen-after-approval>

## Code Map

- `game/player/abilities/grapple/grapple_target_resolver.gd` -- ray in `_query_first_blocking_hit` (~L201); `resolve_hit_result` ordering (~L280-557); query-count literal (~L246)
- `game/shared/contracts/grapple_targeting_result.gd` -- clamp (~L142); `is_value_only()` stub (~L168); `grapple_target_seed.gd` / `grapple_targeting_diagnostic_snapshot.gd` same stubs
- `game/shared/contracts/grapple_rejection.gd` -- 10-value `Reason`; `is_expected_gameplay_rejection()`
- `scripts/player_controller.gd` -- `try_start_grapple()` (~L907-945), `_compose_grapple_targeting()` (~L440), `_update_grapple_visual()` (~L1025-1043), pull exports (~L59-65)
- `tests/player/grapple/test_grapple_targeting_contract.gd` -- count/value-only asserts (~L40, L61, L473, L663); `test_grapple_targeting_integration.gd` -- activation/pull (~L196-237), fixtures (~L460-515)
- `tests/player/contact/test_player_contact_contract.gd` -- truncating guard (~L341-363); `tests/player/motor/test_player_motor_integration.gd` -- range negatives (~L347-370)
- `_bmad-output/implementation-artifacts/evidence/1-6/targeting-contract.md` -- mapping record to amend

## Tasks & Acceptance

**Execution:**
- [x] `grapple_target_resolver.gd` -- count `intersect_ray` at the query site; pass measured count into result construction
- [x] `grapple_targeting_result.gd`, `grapple_target_seed.gd`, `grapple_targeting_diagnostic_snapshot.gd` -- report measured `query_count` unclamped + `matches_single_query_contract()`; real `is_value_only()` introspection (seed `WeakRef` and value-only response allowed)
- [x] `grapple_rejection.gd`, `grapple_target_resolver.gd`, `player_controller.gd` -- degenerate/zero normal -> `MALFORMED_TARGET_DATA` before kind/range; document `INVALID_SURFACE` vs `POLICY_REJECTED`; init-failure activation typed-rejects with no per-press invariant
- [x] `player_controller.gd` -- `grapple_visual_reset_count` incremented at the hidden->visible reset; definition pull fields vs controller exports compared at composition (invariant on mismatch)
- [x] `test_player_contact_contract.gd` -- scan whole files (drop `func _get_grapple_ray_hit` truncation) + positive control that the resolver file does contain `intersect_ray`
- [x] `test_grapple_targeting_contract.gd` -- unclamped counts (2 and 9 observable), dirty-record `is_value_only()` false, degenerate normal -> `MALFORMED_TARGET_DATA`
- [x] `test_grapple_targeting_integration.gd` -- pull decay `max(8.0, 48.0 - 53.333333 * elapsed)` across steps; `&"player.grapple.speed_cap"` in `applied_caps` every commit; reset count +1 per hidden->visible only; definition pull fields = controller exports
- [x] `test_player_motor_integration.gd` -- range-scalar absence at all four AC 11 sites (controller, marker, telemetry, `scenes/player.tscn`): no `grapple_length` token (word-boundary), no `= 35.0` literal
- [x] `evidence/1-6/targeting-contract.md` -- dated mapping amendments; `deferred-work.md` -- 1.7 pull-tuning convergence note
- [x] AGENTS.md dual gate -- GUT focused + recursive via pinned console; MCP rescan, `test_run` (separate), `main.tscn` smoke via `game_eval`, log inspection

**Acceptance Criteria:**
- Given one evaluated step, then `query_count` = measured calls and any count != 1 is observable (`matches_single_query_contract()` false)
- Given a zero/non-finite hit normal, then `MALFORMED_TARGET_DATA` before kind/range; `INVALID_SURFACE` = ineligible surface, `POLICY_REJECTED` = explicit refusal only
- Given init-failure, then grapple press is typed-rejected with no per-press `GameLog` invariant
- Given grappling over N steps, then `grapple_applied_acceleration` follows the decay formula and every commit carries `&"player.grapple.speed_cap"` in `applied_caps`
- Given rope visibility transitions, then the reset counter increments exactly once per hidden->visible and never while visible
- Given clean and dirty records, then `is_value_only()` true only for value types, the seed `WeakRef`, or a value-only response
- Given the four AC 11 sites, then no competing grapple-range scalar exists
- Given the composed player, then `GrappleDefinition` pull fields equal the controller exports
- Given GUT + MCP smoke, then all GUT tests pass and MCP shows unchanged acquisition/pull with no new diagnostics

## Spec Change Log

## Design Notes

Measure at the call site (query counts, rope resets) instead of asserting constants or clamping violations away. Value-only checks introspect script variables (`get_property_list()`) with per-class allowances so a dirty subclass is detectable. `PlayerMotorCommitResult` records caps in `applied_caps`, not `applied_constraints`.

## Verification

**Commands:**
- pinned console: `--headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/grapple -ginclude_subdirs -gexit` (then `contact`, `motor`, `input`, `res://tests/player`) -- all pass, exit 0
- pinned console: `--headless --path . --import --quit-after 120`, then `--quit-after 120` -- exit 0, no ERROR/SCRIPT ERROR/WARNING
- `rtk git diff --check` -- clean
- MCP `testgame@e362124f09f388c2`: `filesystem_manage(scan)`, `test_run` (reported separately), `project_run(mode="main")` + `game_eval` smoke, `logs_read` -- no new errors

## Suggested Review Order

**Query-count honesty (core contract fix)**

- The counted wrapper is now the file's only ray call shape and increments the count itself
  [`grapple_target_resolver.gd:263`](../../game/player/abilities/grapple/grapple_target_resolver.gd#L263)

- Call site routes through the wrapper instead of a declared literal
  [`grapple_target_resolver.gd:210`](../../game/player/abilities/grapple/grapple_target_resolver.gd#L210)

- Result stores the measured count verbatim; wrong counts stay observable
  [`grapple_targeting_result.gd:148`](../../game/shared/contracts/grapple_targeting_result.gd#L148)

**Rejection mapping closure**

- Degenerate/zero normal joins the malformed-data block before kind and range
  [`grapple_target_resolver.gd:328`](../../game/player/abilities/grapple/grapple_target_resolver.gd#L328)

- Init-failure activation rejects typed and quiet per press
  [`player_controller.gd:940`](../../scripts/player_controller.gd#L940)

**Value-only record purity**

- Base-qualified static check; nested records cannot smuggle references via overrides
  [`grapple_targeting_result.gd:188`](../../game/shared/contracts/grapple_targeting_result.gd#L188)

- Seed allows only its documented `WeakRef` exception plus a value-only response
  [`grapple_target_seed.gd:93`](../../game/shared/contracts/grapple_target_seed.gd#L93)

**Pull-tuning parity and frozen-rope observability**

- Definition-vs-export drift is a composition-time invariant
  [`player_controller.gd:472`](../../scripts/player_controller.gd#L472)

- Reset counter incremented exactly at the hidden-to-visible edge
  [`player_controller.gd:1076`](../../scripts/player_controller.gd#L1076)

**Verification (tests and guards)**

- Source guard scans whole files; positive control pins exactly one ray call shape
  [`test_player_contact_contract.gd:366`](../../tests/player/contact/test_player_contact_contract.gd#L366)

- Dirty-record detection now covers result, seed, response, snapshot, and smuggling
  [`test_grapple_targeting_contract.gd:124`](../../tests/player/grapple/test_grapple_targeting_contract.gd#L124)

- Precedence pins: malformed over policy, range band over policy
  [`test_grapple_targeting_contract.gd:596`](../../tests/player/grapple/test_grapple_targeting_contract.gd#L596)

- Pull decay derived from exports, floor asserted, cap in `applied_caps` per commit
  [`test_grapple_targeting_integration.gd:414`](../../tests/player/grapple/test_grapple_targeting_integration.gd#L414)

- Rope test now also pins the single reset call site
  [`test_grapple_targeting_integration.gd:471`](../../tests/player/grapple/test_grapple_targeting_integration.gd#L471)

- Parity mismatch fires the invariant; init-failure press stays quiet (`assert_push_error_count(0)`)
  [`test_grapple_targeting_integration.gd:528`](../../tests/player/grapple/test_grapple_targeting_integration.gd#L528)

- Range-scalar scan is non-vacuous (file existence + regex positive controls)
  [`test_player_motor_integration.gd:372`](../../tests/player/motor/test_player_motor_integration.gd#L372)

**Records**

- Dated mapping amendments to the locked targeting contract
  [`targeting-contract.md:117`](evidence/1-6/targeting-contract.md#L117)

- Dual-gate evidence: GUT counts and MCP session/operations, reported separately
  [`review-fixes-verification.md`](evidence/1-6/review-fixes-verification.md)

- Two deferred follow-ups from the review loop
  [`deferred-work.md`](deferred-work.md)
