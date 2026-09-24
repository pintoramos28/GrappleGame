# 60/120 Hz comparison (NFR4)

## Structural note

Grapple targeting consumes no delta and no tick rate: `evaluate(N, frame, origin)`
answers one state query per evaluated physics step from the command frame's aim.
Rate independence is therefore structural, but it is also asserted.

## Automated comparison

`tests/player/grapple/test_grapple_targeting_integration.gd ->
test_targeting_acceptance_matches_between_sixty_and_one_twenty_hz` evaluates the
same physical query state (geometry on the acquisition boundary at the authored
35 m range) with `Engine.physics_ticks_per_second = 60` and then `= 120`,
restoring the original rate before any assertion. Both rates produced:

- identical rejection (`NONE`, accepted),
- identical `query_count` (1),
- `range_fraction` equal within 0.001,
- identical hit normal and hit position within 0.01 m,
- identical acceptance.

The pure boundary oracle in the contract suite additionally repeats the same
query state three times and asserts identical acceptance and `range_fraction`
within one quantization step (0.001 m), covering the "repeated evaluation never
flips" half of AC 11.

## Related existing coverage (unchanged)

`tests/player/motor/test_player_motor_semantic_contract.gd` keeps its 60/120 Hz
rate-resolution and sustained-rate comparisons (8/8 passing), so movement commit
equivalence remains guarded alongside targeting equivalence.
