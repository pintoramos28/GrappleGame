# Story 1.8 code review and review fixes (2026-09-25)

Review workflow: `gds-code-review` (blind hunter / edge-case path tracer /
acceptance auditor layers). Diff range `db421ea..9335764` (Stories 1.7 + 1.8
stacked in one commit; findings scoped to the 1.8 delta per review scope
decision). Outcome: 3 decision_needed (all resolved by the user), 18 patch,
3 defer, 1 dismissed. All 21 patches applied the same day; this note records
the verification evidence. Findings and implementation notes live in
`1-8-grapple-moving-and-stateful-targets-safely.md` ("Review Findings" /
"Review Fixes — Implementation Notes").

## GUT (canonical regression gate, pinned Godot 4.7.2 CLI)

- Focused `res://tests/player/grapple`: **107/107 tests, 6,538 asserts** across
  6 scripts (log: `%TEMP%/opencode/review-1-8/gut-grapple-run2.log`).
- Canonical recursive `res://tests/player` (`-ginclude_subdirs -gexit`):
  **177/177 tests, 9,738 asserts, 13 scripts** (log: `gut-recursive-run2.log`).
  Story baseline was 163/163 / 8,629 asserts - no regressions; the +14 tests
  are the review-fix contract tests and the dual-rate scenario wrappers.
- One intermediate iteration is recorded honestly (`gut-grapple-run1.log`,
  12 failures): caused by the rejected `distance_at_resolution_m` sentinel
  variant and three review-test bugs (gap arithmetic, accepted-count
  expectation, carry aggregation placement). All resolved as documented in the
  story's implementation notes.
- Pinned `--import --quit-after 120`: exit 0; only the known benign
  `CanvasItem` RID-leak warning already present in `final-import.log`.
- `git diff --check`: clean (exit 0).

## Godot AI MCP (complementary live gate)

Session `testgame@e362124f09f388c2` (Godot 4.7.2-stable official, plugin/server
4.0.4, protocol 2). MCP-observed results only; no visual/runtime claim without
observation.

- Preflight before editing: `session_manage(list)` (one active session, ready /
  stopped), `editor_state`, `logs_read(editor)` triage - only the pre-existing
  `player_contact_provider.gd` parse-error ring-buffer history documented by
  Stories 1.7/1.8 (`recent_errors_may_predate_run: true`).
- Implementation-time: `filesystem_manage(scan)` after every write batch
  (settled, `global_classes_registered_delta: 0`); `script_manage(find_symbols)`
  parse verification of every changed runtime and test file (all clean).
- MCP-native `test_run` (final): **15/15 passed, 0 failed** across
  `grapple_boundary`, `grapple_moving_target`, `grapple_targeting`
  (`cache_warning` documented in `limitations.md`; GUT fresh processes cover
  dependency changes).
- Live `res://main.tscn` smoke (project_run(mode="main"), staged moving/stateful
  anchor `target.review_smoke` - `Grappleable3D` MOVING, `pull_multiplier 0.5`,
  `instability 0.25`, target box `Vector3(8, 40, 1)`, player teleported to
  `(0, 20, 12)`, press edge via `inject_action_binding`):
  1. Commit `player.grapple.attachment_1`; `sampled_step == motion_step`
     (621, then 1378, then 637 at each observation) - the per-step sampling
     fix observed live.
  2. Translation follow: after moving the target to `(0.4, 20, -8.2)` the
     sampled anchor read `(0.4, 23.02606, -7.7)`, exactly equal to
     `target.global_transform * target_local_hit_offset`; `anchor_status:
     valid`; the attachment stayed active (no false discontinuity/termination).
  3. Explicit invalidation: terminal `target_invalidated` committed once,
     `grappling=false`; repeated read returned the identical terminal record
     (`player.grapple.attachment_1`) - idempotent.
  4. Live screenshot `review-fix-smoke-after-invalidation` (game source):
     debug overlay shows `ENDED terminal: target_invalidated`,
     `Anchor status: target_invalidated`, `Target velocity: (0.0, 0.0, 0.0)`,
     `Targeting: accepted step 1586 queries 1` (one-query discipline).
  5. Final run game log (`r688337493-65`): only the game-helper registration
     line, zero errors. `project_manage(op="stop")` -> stopped, editor ready.
- Harness noise recorded honestly: two smoke evals raised harness-side errors
  (a null node access; a dynamically compiled staging script parse error) and
  tripped the editor debugger break - the known behavior `limitations.md`
  documents. Each affected run was relaunched cleanly; the final run's logs are
  clean. Staging used the same live-scene aids as the Story 1.8 smoke (enemy
  `CharacterBody3D` nodes freed, target box resized, player teleported).

## Coverage summary

| Gate | Result |
|---|---|
| GUT focused (grapple) | 107/107, 6,538 asserts |
| GUT recursive (`tests/player`) | 177/177, 9,738 asserts |
| Pinned import / `git diff --check` | exit 0 / clean |
| MCP-native `test_run` | 15/15, 0 failed |
| MCP live smoke (main.tscn) | commit + follow + typed idempotent termination, screenshot, clean log |

GUT and MCP results are separate gates; no parity is claimed (MCP `test_run`
only discovers direct `res://tests/test_*.gd` `McpTestSuite` files).
