# Re-anchor final parent handoff — 2026-10-02

**The re-anchor and all twelve review safeguards pass their targeted checks.**
The same occurrence and pull clock are preserved; the contact-local anchor,
marker and rope follow through wall motion and forward release. Work remains
**uncommitted / in-review**. No gameplay change was made during this last pass;
only the foreign-motor regression fixture was corrected.

**Comprehensive regression remains red.** The full run matches the nine failing
baseline identities. Player-only validation additionally reproduced a previously
recorded intermittent wall-run landing failure; it was not retried into a pass.

## Fresh gates on the final source

| Gate | Passing / total | Assertions | Exit |
|---|---:|---:|---:|
| Focused GUT hardening | **13 / 13 groups; 100 / 100 case-rate pairs** | 100 | **0** |
| Recursive player GUT | **272 / 279** | 12374 / 12388 | **1** |
| Recursive full GUT | **280 / 289** | 13035 / 13052 | **1** |
| Fresh MCP shared hardening, 60/120 Hz | **100 / 100 case-rate pairs** | Separate live harness | Passing |
| Fresh MCP original ordinary / STATIC / MOVING scenarios, 60/120 Hz | **6 / 6** | Separate live harness | Passing |
| MCP editor adapter | **4 / 4** | Source/schema only; preload warning | Passing |

Pinned engine: Godot **4.7.2-stable**, through `rtk proxy`. Commands and full
logs are reproducible with [the gate runner](run-parent-final-gates.py).
[The comparison](parent-final-gut-comparison.json) honestly reports **6/7 checks**:
player baseline parity fails because of the additional landing failure. All
three GUT runs execute and pass the same hundred hardening case-rate pairs;
none has a parse/load/compile error. Earlier sixteen feature tests also pass.

The additional identity is
`res://tests/player/locomotion/test_wall_traversal_integration.gd::test_landing_from_a_wall_run_routes_exactly_one_landed_transition`.
It already appears in the preserved prior-feature
[`review-hardening-full-final.log`](../wall-stick-attachment/review-hardening-full-final.log)
and pre-hardening [`focused-gut-attempt1.stdout.log`](focused-gut-attempt1.stdout.log).
Its source is unchanged from the approved snapshot. This supports the
previously-recorded/intermittent classification, **not a new root-cause claim**.
No tuning, route geometry or unrelated assertion was repaired.

## MCP observations

Session **`testgame@17187ab35ae57813`**, final fresh run **`r188028225-43`**.
[Complete live results and cleanup](mcp-parent-final-validation.json) preserve
all case identities and critical response/native/motor/clock details. MCP was
used for source reads, settled scan, editor diagnostics, schema tests,
`project_run(custom, autosave=false)`, runtime hierarchy, bounded `game_eval`
batches, input cleanup, logs and final scene/resource readback.

- Six actual Animatable/Character/Rigid continuation/release cases pass. Maximum
  anchor/actual marker/native point-velocity errors are **0**; actual assigned
  rope endpoint error is **2.8493575428e-6 m**. No missing active visual samples.
- Incoming-response tightening and relaxation, sampling gaps, malformed policy,
  atomic original/baseline guards, released carry, visibility/assigned-mesh
  negative controls and exact clock/curve controls pass at both rates.
- Foreign motor setup now makes **contiguous real physics commits from 1 to the
  required stamp**, with the strict contact lifecycle retained. Its equal-step
  positive setup, foreign rejection, both unchanged baselines and restored owned
  commit pass. A separate fixed twelve-probe run `r187663530-41` also passes.
- Final game log contains only helper registration, no errors or dropped lines.
  Editor logger has no additions since cursor **5**; the regular editor read
  retains **five corrected-source error rows and eleven warning rows**. Those
  retained diagnostics were not cleared or represented as a clean debugger.
- All six simulated actions and right mouse are released; **60 Hz** restored;
  original traversal route ready/stopped. Authored definitions and player
  assignments were re-inspected; stick/jump/grapple/wall-run tuning is unchanged.

Earlier unsuccessful setup run `r187355302-40` produced six
`contact_frame_failed` errors: a fresh motor had skipped directly from bootstrap
step 0 to step 6. The fixture correction preserves every intermediate step;
it does not relax strict lifecycle, ownership, success or atomicity assertions.
An oversized single-eval attempt `r187837881-42` exceeded the MCP **8 s** budget
and returned `EVAL_HUNG`; it was stopped and is not acceptance evidence. The
final fresh process uses ten bounded batches, not an acceptance retry of a
failed gameplay assertion. Earlier failed records are retained.

No new framebuffer capture, every-rendered-frame, readability, feel, export or
authored full-route acceptance is claimed. GUT and MCP remain identifiable;
shared cases do not make the schema adapter equivalent to recursive GUT.

## Preservation and next boundary

Read-only preservation passes all **nine** checks including the older **27/27**
gate. The original 437-file snapshot and 480-file hardening-start hash set remain
intact; 195 prior evidence/spec files and 28 protected scene/resource/project
files match. HEAD and frozen intent hash are unchanged. Whitespace check exits
**0**. Comprehensive CLI shutdown still reports eight leaked objects and one
resource in use, separately from expected negative-path diagnostics.

No user scene was saved/discarded/reloaded, no additional independent review or
agent dispatch occurred, and nothing was staged, committed or pushed. The
[approved spec](../../spec-wall-stick-grapple-reanchor.md) retains its clickable
review trail. Baseline/landing repair requires separately authorized work.

Final read-only [evidence verifier](verify-parent-final.py) confirms **11/11**
targeted-evidence/cleanup/preservation checks, including identical hundred
case-rate IDs across all three GUT gates and MCP. It exits **1** to retain the
failed player-parity comparison, rather than reporting a green comprehensive
gate. Its shell capture is `parent-final-verification.json` (PowerShell UTF-16;
read with `encoding="utf-16"`). Approved worktree helper ran in `diff` and
`head-diff` modes only, both exit **0**; existing motor CRLF notices are retained.
No snapshot capture, normalization or remote operation occurred.
