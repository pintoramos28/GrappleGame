# Extended Implementation Readiness Preflight

**Ready:** no
**Declared implementation scope ready:** M0 implementation-start only; no milestone is acceptance-ready
**Epic shards validated:** 91
**Shard digests processed:** 91/91
**GDD functional requirements:** 58
**GDD non-functional requirements:** 21
**Manifest requirements:** 82

## Errors

- gdd: status is 'needs-decisions'; expected one of active, complete, final, ready-for-development
- UX is required by the GDD, but the canonical UX bundle is absent

## Warnings

- 71 story shards have no explicit requirement IDs; functional coverage currently relies on primary epic mappings
- 12 open decisions remain; apply their phase labels before starting the affected work

## Open Decisions

| ID | Blocks phase | Decision required |
|---|---|---|
| OD-001 | M3-M4 | Select the Last Garden production subset from the validated M2 vocabulary. |
| OD-002 | future-design | Decide which enemy-effect mechanics may also support future player abilities. |
| OD-003 | M2-balance | Establish limits for hard control and movement cancellation. |
| OD-004 | M2-balance | Establish the maximum readable simultaneous pressure overlap. |
| OD-005 | tuning | Decide which tuning decisions require telemetry. |
| OD-006 | verification | Allocate automated-test evidence versus playtest-only evidence for each prototype. |
| OD-007 | UX | Define target audience, HUD hierarchy, accessibility behavior, reticle options, settings interactions, and active-slice audio minimum. |
| OD-008 | performance | Define minimum-spec hardware, representative content density, capture method, pass duration, peak-memory target, and level-load target for the 1080p/60 FPS gate. |
| OD-009 | M0-tuning | Measure and approve jump apex/airtime, coyote time, jump buffering, wall-relative entry tolerance, and grapple-gravity behavior after focused traversal playtests. |
| OD-010 | M3-level-flow | Define checkpoint spacing, retry-time target, and encounter-versus-checkpoint reset cadence. |
| OD-011 | M1-validation | Define the movement-derived combat advantage and its minimum pass threshold against an equivalent stationary attack. |
| OD-012 | M1-scope | Confirm Basic Strike as the only required player attack with no combo chain in M0-M4, or define the replacement scope. |
