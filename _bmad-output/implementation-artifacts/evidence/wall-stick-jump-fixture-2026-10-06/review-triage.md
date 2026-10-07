# Fixture correction — review resolution

Date: 2026-10-07. Three isolated reviews used the installed adversarial and edge-case lenses plus a spec/context acceptance audit. Reviews were read-only and snapshot-scoped; pre-existing user changes were not attributed to this task.

## Resolved patch findings

| Concern | Resolution | Verification |
| --- | --- | --- |
| Delta alignment was diagnostic-only; first-hold checks could miss defective pre-spawn synchronization | Readiness requires cached/requested/committed delta agreement. Added a pre-spawn oracle before fixture creation and first-hold = entry+1 assertion. | Removing only the two helper awaits produces 3/3 expected GUT reds with observed stale cached delta; restored final regression passes 5/5. Initial passing pre-barrier attempts remain labeled separately. |
| Breaking on first failed hold could let a non-jump exit mask earlier cancellation | Explicitly fail and finish before scripted non-jump exit mutation whenever earliest-loss evidence exists. | Original exit assertions retained; final wall-stick group passes 12/12 in three processes. |
| Negative coverage did not isolate still-active invalid support, history guards or accidental release injection | Both modes reject actual wall destruction before another transaction, mismatched guard delta, incomplete/prior-loss history and actual-release inactivity. Snapshot pending input as well as velocity, player step and immutable-command identity. | Final focused readiness tests pass 2/2 in three processes; MCP observes 10/10 guard checks without mutation. Both destroyed-support cases retain active=true and held grapple at step 21. |
| Transition launch checks could conceal hold drift or vacuous tangent removal | Reuse original stationary-hold tolerances and require a nonzero tangential reference before the existing zero-tangent launch oracle. | Final transition passes 297 assertions per process; MCP observes tangent reference 3, outward reference 0.5, 18 valid holds and `(0,5.5,8)` launch. |

No unresolved implementation finding, intent gap or bad-spec loopback remains. Wider hook synchronization and unrelated corner/landing fixes were not performed. Existing diagnostics and investigation limitations remain documented, not silently treated as fixed.

## Final parent checks

- MCP session `testgame@17187ab35ae57813`, token 77: affected source read confirms the restored internal barrier and pre-spawn oracle, 2,083 lines / 101,054 bytes; editor ready/stopped on the original route, configured 60 Hz, logger cursor 6→6 with zero new entries.
- Final GUT gate: target 10/10 fresh-process passes; wall-stick group 12/12 across three runs; recursive player 281/282 across three runs, only unchanged shallow-corner failure. Whole-file runs also retain one separate landing failure. Broad gates are not globally green.
- Final source hash `1ca5f4c37e7dd3f7da20b6b9b5175b507da30f49c737855be72db293a1934e04`; 1,333 other protected files and all 278 original assertion blocks unchanged. Diff check passes.
- Game logs timed out; shutdown leaks retained; no clean-game-log, clean-shutdown, visual, native-test-parity or proven historical-cause claim.
- No commit/push: the approved frozen boundaries prohibit them. Existing dirty work remains intact.
