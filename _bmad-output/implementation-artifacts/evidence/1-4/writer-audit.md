# Story 1.4 active-player writer audit

The source audit is scoped to the active player. It does not ban enemy movement or the tutorial's level-owned start/reset placement.

## Sole final writer

`game/player/motor/player_motor.gd` is the only active-player final commit owner:

- line 695: motor-owned wall-stick hold correction, `_body.global_position = requested_hold_position`;
- line 696: the single final `_body.velocity = working_velocity` assignment;
- line 697: the single `_body.move_and_slide()` call.

The assignment and slide occur after validation and all seven local phase folds. The pre-slide resolved velocity and post-slide body velocity are retained separately in the result/snapshot.

## Caller restrictions

The controller and all six movement state scripts contain no `move_and_slide()`, direct body velocity assignment, or direct global-position assignment. The four attack states contain no `PlayerMotor` reference or movement submission. The retired `PlayerMotionRequest` file and UID sidecar are deleted, and no runtime caller references the old complete-velocity request path.

The integration test `test_player_surface_keeps_motion_commit_inside_motor` enforces these restrictions and passed as part of the final motor suite.
