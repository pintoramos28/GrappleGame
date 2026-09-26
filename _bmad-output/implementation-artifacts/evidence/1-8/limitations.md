# Limitations and documented edge behavior (Story 1.8)

## Discontinuity band behavior (Task 6.2, documented choice)

The two authored tolerances classify the sampled anchor's implied speed
(`|anchor_position_now - anchor_position_prev| / delta_seconds`):

- `<= anchor_continuous_motion_tolerance_mps` (50 m/s): continuous - the
  grapple follows normally and the boundary may carry the player with the
  anchor's separating radial motion.
- `>= anchor_severe_discontinuity_threshold_mps` (250 m/s): severe - the
  grapple terminates `ANCHOR_DISCONTINUITY` at the sampling phase, before any
  submission for the step (AC 7).
- The band between them: the grapple keeps following the anchor position (no
  re-acquisition, no snap), but no boundary carry above the continuous
  tolerance is ever applied. If the boundary REQUIRES a correction above the
  continuous tolerance to keep the player within the maximum, the grapple
  terminates `ANCHOR_DISCONTINUITY` instead (AC 4 rule 4), and if no correction
  is required (tangential motion, approaching motion, or a player already
  keeping up) the attachment stays active.

## Rate sensitivity at the classification edge (NFR4)

Implied speed is rate-equivalent for smooth motion (displacement and
`delta_seconds` scale together). A fixed-distance teleport, however, implies a
higher speed at the diagnostic 120 Hz rate than at 60 Hz, so a jump whose
60 Hz implied speed lies just below the severe threshold can classify as
severe at 120 Hz only. Consequences are bounded: detection at 60 Hz implies
detection at 120 Hz, the AC 10 discontinuity scenario uses a 10 m jump (600
m/s implied at 60 Hz, far above the threshold at either rate), and the band
rule still refuses any snap-scale carry at both rates. The same asymmetry
applies to the band edges for smooth motion only within one step of the
thresholds.

## Boundary engagement inside the maximum (AC 4 first Given)

Before the boundary the anchor transfers no motion; the one exception is a
step in which the pair would cross the maximum within that step (the grapple
reaches its maximum length during the step): the player then receives exactly
the anchor's separating radial motion required to stay within the maximum
(relative overshoot prevention), never more. **RATIFIED by code-review
decision (2026-09-25):** this one-step pre-boundary carry is intended behavior
("one step may not carry the pair past the maximum"); the separation scenario
now measures the drag band instead of masking it and asserts the drift stays
within one step of anchor separation plus the measurement tolerance at both
rates (previously the assertion window excluded the band).

## Terminating-step timing

A freed/invalid/discontinuous sample terminates BEFORE any grapple submission
for that step (no pull, cap, or boundary submission). A refused boundary carry
is detected from the motor's boundary record post-commit and terminates the
attachment within the same physics step: the step's commit already applied
nothing from the anchor (only the unchanged Story 1.7 outward clipping), so no
constraint impulse or snap is ever observable.

## Sampling-phase compatibility path

`GrappleAttachment` is committed with the accepted hit position as its initial
sample, so callers that never run the sampling phase (Story 1.7-era direct
controller use, retained test fixtures) still resolve the pull and boundary
against the frozen anchor - byte-compatible Story 1.7 behavior. The player
state layer runs the sampling phase every active step (Story 1.8 review fix:
the wall-stick state now samples every step with a live command frame, not
only on its stale-anchor path), so gameplay always consumes per-step samples,
and the stale-sample guard refuses submissions that would consume another
step's sample.

## Targeting evaluation while attached (Task 3.3 interpretation)

While an attachment is active, `player_controller._evaluate_grapple_targeting`
is gated off: the anchor follows the stored target-local hit point by
transform math and no target-selection raycast is repeated. The Story 1.6
discipline stands unchanged - every EVALUATED step performs exactly one
authoritative query (`query_count == 1`), and an attached step is not an
evaluated step. After release the next step evaluates exactly once again.

## Scope-identity contract (AC 10 scope guard)

The attachment stores an optional originating encounter-scope identity
(`StringName`, lowercase dotted) supplied by an injectable `Callable` provider
at commit time. A mismatch terminates `SCOPE_MISMATCH` only when both the
attachment and the target declare identities and they differ. No encounter
lifecycle, registry, run-ID rejection machinery, anchor-modification
mechanics, rope wrapping, elasticity, reeling, or rope-segment simulation is
introduced.

## Tool-scope harness staleness

MCP tool scope serves a preloaded-GDScript cache that ResourceLoader modes do
not invalidate (the harness's own `cache_warning`); newly added script
properties may read back as `null` on loaded resources until the editor
restarts. The MCP adapter therefore falls back to the authored `.tres` values,
and behavioral verification rests on the GUT suites (fresh processes) and the
live game smoke. MCP `test_run` never covers GUT suites; no parity is claimed.
