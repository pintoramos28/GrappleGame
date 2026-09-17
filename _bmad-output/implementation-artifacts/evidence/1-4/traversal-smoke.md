# Story 1.4 live traversal smoke

This is Godot AI MCP-observed runtime evidence, not human feel/visual approval.

For clean run token `15`, `project_run(mode=main, autosave=false)` launched the main scene with the helper live and no current-run errors. Runtime tree inspection found `/Main/World/Player` and `/Main/World/Player/PlayerMotor`; the runtime tree contained 132 nodes. Initial `game_eval` reported the player physics active and grounded with one successful commit.

The MCP `input_key` operation pressed `W`, and `game_eval` awaited 0.1 seconds while the game advanced. The player moved from z `-10.124446` to `-11.291115` (`moved=true`), ended grounded at velocity `(0, 0, -10)`, and the result reported `commit_count=1`, `is_hold_request=false`, and the exact seven canonical phase IDs. The key was released through MCP before stopping the run.

GUT's real-Jolt integration cases separately cover air, ground jump, grapple pull/cap/release, wall run/jump, wall-stick hold/release, death, landing cleanup, and transition behavior. The MCP smoke intentionally records only the live main-scene interaction actually observed; it does not claim that a human approved traversal feel or that every transition was replayed through MCP.

## Fix-pass rerun

The final fix-pass MCP runs first used tokens `17`–`19`, then a restarted editor used tokens `1`–`2`. Runtime tree inspection found the player and `PlayerMotor` in the main scene; the final clean `game_eval` returned `physics_active=true`, `grounded=true`, `result_success=true`, `commit_count=1`, and all seven canonical phases. The free-running scene produced only normal damage info messages; no current-run or editor error was reported for the clean run. This rerun validates live loading and the single-commit path after the contract fixes; it does not replace the deterministic GUT traversal cases above.
