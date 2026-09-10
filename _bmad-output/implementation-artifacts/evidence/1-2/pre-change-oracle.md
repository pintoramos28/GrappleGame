# Story 1.2 pre-change oracle

Captured before the first Story 1.2 runtime edit on 2026-09-10.

- Revision: `e53d33ea7b088a38cdd8923eb3b24d6a01d5a32b` on `main`.
- Story 1.1 status: `done`; its accepted review findings, dismissals, repeatability result, and baseline evidence were read before implementation.
- Pinned runtime: Godot `4.7.2.stable.official.ed1daf0bf`.
- Launch scene: `res://main.tscn`.
- Accepted controls: `W/A/S/D` movement, `Space` jump, right mouse grapple, left mouse or `F` attack, `Esc` cursor release, and mouse-click recapture.
- Accepted limitations carried forward: `BASE-006` shutdown diagnostics, `BASE-007` fixture-only wall-state observation, `BASE-004`/`BASE-005` fall/death recovery not currently exercisable, and the Story 1.1 repeatability result of `PASS WITH LIMITATIONS`.

The pre-change worktree contained only the already-present planning/evidence changes. No protected runtime file was dirty. Concurrent user-owned import artifacts were preserved throughout implementation.

The Story 1.2 context-pack revision check also passed before runtime edits: all six recorded SHA-256 values matched `_bmad-output/.artifact-index/context-1-2.json` and the current planning files. The only inventory warning was the acknowledged scoped GDD `needs-decisions` warning.
