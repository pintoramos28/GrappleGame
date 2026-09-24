## Deferred from: code review of 1-1-verify-and-protect-the-playable-traversal-baseline (2026-09-09)

- Separate pre-existing and unrelated changes from the Story 1.1 review scope. The baseline-to-HEAD range includes the pre-existing Godot AI 3.2.4-to-4.0.4 configuration change, planning import-sidecar changes, and the later reference-image commit `e53d33e`; review or split those changes separately rather than treating them as Story 1.1 output.

## Deferred from: code review of 1-5-share-authoritative-ground-and-wall-contact-facts (2026-09-18)

- Revisit grapple pull activation: `scripts/player_grappling_state.gd` still calls `submit_grapple_pull(delta)` only inside the jump-edge branch. The Story 1.5 diff changed the floor predicate from `is_on_floor()` to `has_ground_contact()` but did not introduce the jump-edge gating; address under the owning grapple/traversal story rather than coupling it to the contact-frame review.
  - **Reconciled (Story 1.6, 2026-09-24): verified stale.** `scripts/player_grappling_state.gd` calls `agent.submit_grapple_pull(delta)` unconditionally each grappling update (after base/gravity policy and outside the jump-edge branch). No jump-edge gating exists and none was introduced. Pull behavior stays as-is (preserved scope); nothing remains to "address" from this note, and no pull redesign is performed here (that is Story 1.7/1.8 territory).
