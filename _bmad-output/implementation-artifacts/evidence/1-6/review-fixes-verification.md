# Review-fixes verification record (spec-1-6-review-fixes, 2026-09-24)

Scope: the eight batch-A remediation items from the story 1.6 review (spec:
`../../spec-1-6-review-fixes.md`, baseline commit `5a3bfed`). GUT and MCP
results are recorded separately per AGENTS.md; MCP-observed facts are marked.

## Godot AI MCP (session `testgame@e362124f09f388c2`, Godot 4.7.2-stable, plugin/server 4.0.4)

- **Preflight (read-only, before editing):** `session_manage(list)`, `editor_state`
  (ready / play stopped / current scene `res://scenes/player.tscn`),
  `script_manage(find_symbols)` on `grapple_target_resolver.gd` and
  `grapple_targeting_result.gd`, `resource_manage(load)` on
  `grapple_definition.tres` (values 35.0 / 0.005 / 48 / 8 / 53.333333 / 22).
- **During implementation (sub-agent, MCP-observed):** all `.gd` edits made
  through `script_patch` (reload diagnostics returned per patch); reads through
  `script_manage` / `filesystem_manage(read_text)`.
- **After editing (orchestrator):** `filesystem_manage(scan)` settled
  (123 global classes, delta 0); MCP-native `test_run` suite `grapple_targeting`
  4/4 tests (reported separately — not GUT coverage, no parity claimed);
  `logs_read` (editor) with cursor unchanged at 105 across the whole exercise —
  no new editor errors appended by any of the edits.
- **Live smoke (MCP-observed, orchestrator, run tokens 45-47):**
  `project_run(mode="main")` + `game_eval` probes + `game_manage(input_*)` +
  `project_manage(stop)`. Observed on the final patched build (token 47):
  per-step targeting result `query_count == 1`,
  `matches_single_query_contract() == true`, `is_value_only() == true` under the
  new introspection, rope reset counter 0 while hidden, `current_run_errors: []`.
  Earlier in the gate (tokens 45-46) the same probe plus a `fire_grapple`
  sequence confirmed no spurious activation (typed rejection `NONE`, no partial
  state) on empty aim. The full acquisition -> pull -> release flow on the
  pre-review build (decay 48 -> 42.667 -> 34.667 -> 27.556 matching
  `max(8.0, 48.0 - 53.333333 * elapsed)`, `applied_caps` carrying
  `&"player.grapple.speed_cap"` every grappling commit, rope reset 0->1->1->1->2)
  was observed in the implementing sub-agent's MCP smoke and is independently
  covered by the GUT integration tests below.
- **Diagnostics note:** editor-log rows showing `player_contact_provider.gd`
  parse errors are historical buffer entries (cursor unchanged at 105); the
  file parses cleanly (`find_symbols`, 43 functions). The `seed`-identifier
  reload warnings and the `player_contact_provider.gd:575` ternary warning are
  pre-existing — the identifiers exist in baseline commit `5a3bfed`
  (verified via `git show`), and the ternary is in an untouched file.

## GUT (canonical regression gate, pinned Godot 4.7.2 console via `rtk`)

| Suite | Result |
|---|---|
| `res://tests/player/grapple` (focused) | 29/29 tests, 701 asserts, exit 0 |
| `res://tests/player/contact` (focused) | 11/11 tests, 90 asserts, exit 0 |
| `res://tests/player/motor` (focused) | 36/36 tests, 2,342 asserts, exit 0 |
| `res://tests/player/input` (focused) | 21/21 tests, 677 asserts, exit 0 |
| `res://tests/player` (recursive) | 97/97 tests, 3,810 asserts, 9 scripts, exit 0 |

All `GameLog`/`PlayerInputSource` error lines in output are GUT-wrapped expected
invariants (`assert_push_error` / `assert_push_error_count` consumed them).
Teardown noise (ObjectDB/RID leak lines at exit) is pre-existing and unchanged.
Pinned load check: exit 0, no script-level errors matched
(`SCRIPT ERROR|Parse Error|Failed to load|Invalid call|Nonexistent function`).
`rtk git diff --check`: clean (exit 0).

## Review-loop record (quick-dev step 04)

Three reviewers (blind hunter / edge-case hunter / acceptance auditor) ran on
the diff since `5a3bfed`; 35 raw findings deduped and classified: no
`intent_gap`, no `bad_spec` (no loopback; `specLoopIteration` stayed 1), 11
`patch` items auto-fixed (counted ray wrapper + exactly-one-call-shape source
assert, verbatim query-count storage, `OUT_OF_RANGE`-band test distance fix,
init-failure quiet-path test, dirty-record tests for seed/response/snapshot
with base-qualified static purity checks, parity-mismatch test + shared
tolerance constant, pull-decay test hardening, non-vacuous range-scan guards,
rope-reset source guard, degenerate-vs-policy precedence cases), 2 `defer`
items appended to `deferred-work.md` (production signal for
`matches_single_query_contract()`; `MISSING_RESULT` false-positive gating),
remainder `reject` (spec-mandated behavior, review artifacts, or refactor
preferences). Two review-caught test bugs were fixed during the loop and
re-gated green (out-of-range wall placement, over-broad reset needle).

**Known gaps (honest):** the 8.0 m/s^2 pull floor is asserted by GUT but was
not sampled in the short live smoke windows; the MCP-native suite only covers
authored-asset/schema checks (behavioral coverage is GUT + live smoke).
