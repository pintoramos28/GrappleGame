# Pre-implementation evidence

- HEAD `89ead0989f319a80007cb9835fea056c5ca8bf04`; no commits, resets, or remote operations.
- Fresh pinned recursive GUT: 238 tests, 229 passing, 9 failing; 11,749/11,769 assertions, exit 1 (64.098 s). Full log: `baseline-gut.log`.
- Baseline failures: three validation-route tests (zip landing, wall finish, unbroken route); grapple definition expects 48 rather than current 60; activation expects 48; moving scene-origin expectation; pull decay window/floor expectation; shallow-corner run exit; authored-context motor expectations (ground deceleration 20 / grapple gravity 1 rather than current 50 / 0).
- MCP renewed before edits: `testgame@17187ab35ae57813`, Godot 4.7.2-stable / Godot AI 4.2.3, active project `testgame`, ready/stopped, player scene. Read session list, state, editor logs, hierarchy, stick and motor scripts, player run/jump/platform/tuning values and capsule resource. Ten retained warnings, no error rows.
- Loaded run maximum 100, minimum 3, speed 10, acceleration 4, gravity 0, run jump 5.5 up / 8 away; `platform_wall_layers=0`, ground deceleration 50, grapple gravity 0. These are preservation values, not new tuning.
- Existing dirty files read before patching; unrelated documents, grapple definition, investigation and previous spec will remain untouched.
