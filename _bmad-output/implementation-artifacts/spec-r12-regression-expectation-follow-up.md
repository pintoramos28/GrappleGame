---
title: 'R12 regression expectation follow-up'
type: 'bugfix'
created: '2026-10-06'
status: 'done'
route: 'one-shot'
baseline_commit: '5d128486cf695f92dd4a370a6ee4ca6fb594b10f'
---

# R12 Regression Expectation Follow-up

## Intent

**Problem:** Several deferred player-test failures asserted obsolete authored values, a stale marker transform, or a decay window too short for the current grapple profile.

**Approach:** Align only the authorized test oracles with current authored data and derive the decay sample window from that profile. Leave production movement, geometry, the shallow-corner assertion, and the intermittent wall-stick-jump investigation untouched.

## Suggested Review Order

**Authored pull values and timing**

- Confirm the locked resource oracle uses the authored 60 m/s² pull.
  [`test_grapple_targeting_contract.gd:331`](../../tests/player/grapple/test_grapple_targeting_contract.gd#L331)

- Verify same-step activation records the current initial pull value.
  [`test_grapple_targeting_integration.gd:227`](../../tests/player/grapple/test_grapple_targeting_integration.gd#L227)

- Derive enough sample steps to reach the authored acceleration floor.
  [`test_grapple_targeting_integration.gd:568`](../../tests/player/grapple/test_grapple_targeting_integration.gd#L568)

- Keep the controller-token assertion aligned with the authored resource.
  [`test_grapple_targeting_integration.gd:683`](../../tests/player/grapple/test_grapple_targeting_integration.gd#L683)

- Keep the live boundary schema aligned with the loaded resource value.
  [`test_grapple_boundary_mcp.gd:60`](../../tests/test_grapple_boundary_mcp.gd#L60)

- Keep the targeting schema's authored-text mirror aligned as well.
  [`test_grapple_targeting_mcp.gd:35`](../../tests/test_grapple_targeting_mcp.gd#L35)

**Current fixture assumptions**

- Match the camera-origin oracle to the player scene's current local marker.
  [`test_grapple_targeting_integration.gd:250`](../../tests/player/grapple/test_grapple_targeting_integration.gd#L250)

- Distinguish player-scene defaults from the main-scene deceleration override.
  [`test_player_motor_integration.gd:376`](../../tests/player/motor/test_player_motor_integration.gd#L376)

**Remaining regression disposition**

- Review the latest distinct GUT and MCP outcomes without promoting Story 1.10.
  [`review-fixes-2026-10-02.md:213`](evidence/1-10/review-fixes-2026-10-02.md#L213)

- Preserve the known shallow-corner observation and the separate investigation boundary.
  [`deferred-work.md:39`](deferred-work.md#L39)
