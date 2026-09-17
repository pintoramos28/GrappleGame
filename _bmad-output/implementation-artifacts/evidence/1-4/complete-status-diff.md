# Story 1.4 final status and scope audit

Implementation-start HEAD remained `2c9f8af3d151bebaf72e513e938c1407ad660ec0`; the story frontmatter baseline remained `7f0e5cd3a53b5dc202a2cd2a84d0966aaa1d08cc`. The final working tree is intentionally uncommitted. The Story 1.4-scoped changes are the implementation, tests/evidence, and status-record updates below; the pre-existing untracked `.vscode/` directory was preserved and not touched:

- motor contract: `game/player/motor/motor_phase.gd`, `player_motor_submission.gd`, `player_motor.gd`, `player_motor_commit_result.gd`, `player_motor_diagnostic_snapshot.gd`;
- retired request removal: `game/player/motor/player_motion_request.gd` and its UID sidecar deleted;
- controller and six movement states under `scripts/player_*`;
- focused motor/integration/semantic GUT files under `tests/player/motor/`;
- Story 1.4 evidence under this directory;
- the Story 1.4 Markdown record and sprint status.

`rtk git diff --check` passed. `git status --short --branch` showed no scene, project.godot, Resource, addon/dependency, existing scene-UID/topology, tutorial, attack, or unrelated domain migration. `main.tscn`, `scenes/player.tscn`, project settings, the tutorial script, and dependency manifests remain outside the diff. The source audit found no `ContactFrame`, typed grapple-target redesign, true maximum-distance grapple boundary, moving-target attachment, combat-pressure effect, or traversal retuning.

The fix pass added explicit contract validation for kind/phase pairs, the supported `total_speed` cap scope, stable source IDs, degenerate wall vectors, duplicate-before-overflow ordering, wall-relative redirection, diagnostic identity facts, terminal dead-state markers, and controller rejection classification. Final focused GUT coverage is 36/36 tests with 2,131 assertions; final recursive `res://tests/player` coverage is 57/57 with 2,808 assertions. Godot AI MCP validation used the original session `testgame@d3ecac167a39b179` through the cache-recovery step and the fresh final session `testgame@40d061afaea5bfeb`; the restarted editor ended ready/stopped with zero editor diagnostics, and live main-scene checks observed successful seven-phase single commits with no current-run errors.
