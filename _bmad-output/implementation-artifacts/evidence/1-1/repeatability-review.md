# Repeatability Review

Dry-run review completed 2026-09-09 after the evidence paths settled.

Result: PASS.

- The documented main scene exists at `res://main.tscn`; the optional tutorial scene also exists, is explicitly marked unused, and was not saved.
- The record provides the approved raw Godot version, an operator-local executable-resolution requirement, exact import and 120-frame headless-load commands, and the authoritative interactive launch procedure.
- Current bindings are named before the procedure: `W/A/S/D`, `Space`, right mouse, left mouse/`F`, `Esc`, mouse recapture, and `F3` telemetry.
- Every required traversal behavior has a matrix row with scene, setup/target geometry, actual input, expected baseline observation, result enum, observed result, and issue/remediation reference.
- The structured traversal capture preserves exact positions, velocities, frame counts, targets, state flags, health, and recovery outcomes in `traversal-smoke-observations.json`; the concise operator procedure is in `traversal-smoke.md`.
- All Story-linked evidence paths exist. The final evidence directory contains the raw import, headless, interactive, classification, traversal, start/end status, start/end manifest, and audit artifacts.
- A final independent 120-frame headless load completed `res://main.tscn` with no error/warning pattern matches; see `final-headless.log` and `end-scoped-git-checks.txt`.
- No automated-test command is prescribed or claimed because the repository has no established test suite.

A second operator can repeat the capture by resolving the approved Godot 4.7.2 stable executable, following the commands and runtime setup in the Story, and comparing their observations against the matrix. Machine-specific executable paths remain intentionally uncommitted.
