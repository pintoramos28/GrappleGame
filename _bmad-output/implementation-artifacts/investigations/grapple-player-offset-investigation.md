# Investigation: Grapple Player Offset

## 2026-09-29 clarification: stationary, zero-gravity angled wall launch

**Follow-up implementation:** Grappling now has separately exported ground/air
deceleration settings, defaulting to zero without changing ordinary movement.
The live main-scene repeat stayed within 0.000001 m of the initial pull line
at frame 60 and contacted the wall near the grapple point, rather than missing
it by meters before contact. This addresses the zero-input base-deceleration
path drift identified below; it does not add arrival braking. Full MCP/GUT
results and existing unrelated suite failures are recorded in
`../evidence/grapple-state-deceleration/verification.md`.

### Corrected causal diagnosis: zero-input base locomotion is NOT zero acceleration

The original finding that the pull itself points toward the anchor is true,
but attributing the **pre-contact off-axis miss** to grapple inertia alone was
incomplete. A player starting at rest under only a central pull toward a
stationary point would follow that initial line until it reaches/passes the
point or collides. The live motor phase trace instead shows the grappling
state submits **base locomotion every frame even with zero movement input**.
`submit_base_policy` chooses the scene's air/ground deceleration when input is
zero; `_apply_base_submission` independently applies `move_toward(..., 0,
rate * delta)` to X and Z *before* adding the grapple acceleration. It is not
a vector-aligned drag. `main.tscn`'s player has air deceleration 5 m/s² and
ground deceleration 30 m/s². Grapple gravity zero only removes gravitational
acceleration; it does not disable base deceleration.

In MCP session `grapplegame@cc9f18a8fee838ac`, `main.tscn`, at one actual
grappling physics step with no movement input and gravity scale zero, the
motor's initial velocity was `(-5.3379, 1.8831, -12.9287)` m/s. The base phase
changed it to `(-5.2546, 1.8831, -12.8454)`: X **and** Z each gained
`+0.08333` m/s (`5/60`), while Y stayed unchanged. The subsequent grapple
pull phase changed it to `(-5.4241, 1.9222, -13.1724)`. The gravity submission
was present but applied zero; there were no impulses, wall redirections or
speed-cap changes in the sampled pre-contact frames. Because X and Z began
with unequal magnitudes, equal absolute per-axis deceleration changes their
ratio and bends the trajectory away from the straight-line target bearing.

**Controlled runtime ablation (no files saved):** Reloaded the same main scene,
kept the same accepted wall hit `(-8.5, 3.1254, -17.0703)`, stationary spawn,
zero grapple gravity and no movement input; set only the runtime player's
`air_deceleration` and `ground_deceleration` to 0 before attaching. The
pre-contact displacement stayed collinear with the initial pull to within
`0.000001 m` at sampled frame 61; first wall contact occurred at frame 70,
root `(-8.0491, 2.1451, -16.4258)` (about 0.64 m *before* the hit in Z).
Closest root-to-hit distance was 1.005 m at frame 72, root
`(-8.0491, 2.2270, -17.0831)`, already in wall contact: the remaining X gap
is capsule clearance (~0.45 m), and the remaining Y gap (~0.90 m) reflects the
scene's pull origin 0.9 m above the root, not sideways flight. Without an
arrival brake, the player still slides past along the wall afterward.

**Unmodified comparison:** The authored 5/30 m/s² deceleration produced
pre-contact cross-track error 0.276 m by frame 31, 1.052 m by frame 61, and
1.715 m by frame 81. Closest approach was 1.764 m at frame 85 without wall
contact; first wall contact was at frame 97, root
`(-8.0490, 3.1940, -20.6067)`, already 3.54 m beyond the hit along Z.
This isolates the unexpected early *direction* error to the concurrent
zero-input base-motion policy; retained velocity and missing arrival braking
explain the continuing fly-by and later slide. The configured pull-origin
offset separately makes the ideal body-root endpoint lower than the surface
hit. This comparison does not by itself prescribe how much air control or
grapple braking the intended design should keep.

The earlier phrase "wall contact then blocked inward motion" must **not** be
read as "the player reached the grapple point and then slid off it." A fresh
Godot AI MCP run in the current worktree confirms the player **misses the hit
point before any wall contact**. The later collision is with another place on
the same wall. This reproduces the user's exact stationary-start condition,
which was not isolated in the earlier report.

- Godot AI MCP session `grapplegame@cc9f18a8fee838ac`, custom launch of
  `res://main.tscn` with autosave off, live game evaluation through the existing
  `PlayerInputSource` test seam. Player root at start `(0, 0.0993, 0)`, initial
  velocity `(0, 0, 0)`, no movement input, `grapple_gravity_scale = 0`. Camera
  aim accepted `LowBlockA` at `(-8.5, 3.1254, -17.0703)`. The current scene's
  `GrappleOrigin` is at local `(0, 0.9, 0)`; pull and rope use it, while the
  distance/boundary use the root. The root has zero horizontal/vertical motion
  before attachment. The attachment was active by sampled frame 4.
- At sampled frame 81: root `(-6.3986, 2.5906, -16.4412)`, 2.26 m from hit,
  velocity `(-5.9454, 2.4537, -15.8366)` m/s, **no wall contact**.
  By frame 86: root `(-6.9051, 2.7882, -17.7443)`, 1.76 m from hit,
  velocity `(-6.1653, 2.3024, -15.4466)` m/s, **still no wall contact**.
  At this point its z-coordinate has passed the hit by 0.674 m while its root
  remains 1.595 m away from the hit's x-coordinate. The pull points back
  toward the hit's z-coordinate, but forward z momentum remains large.
- By frame 91 the root is `(-7.4237, 2.9694, -18.9932)`, 2.21 m from the
  hit and moving away, **still without wall contact**. At frame 101 the root
  is `(-8.0497, 3.2811, -21.2459)` with `is_on_wall() = true`: it has reached
  the wall's capsule clearance (roughly 0.45 m off the x=-8.5 face), but its
  z-coordinate is 4.176 m past the actual grapple point. Its remaining z
  speed is -12.57 m/s. At frame 120 the root is
  `(-8.0530, 3.7283, -24.5535)`, 7.52 m from the hit; z is 7.483 m beyond it.
- Consequently the first large offset is an **unobstructed fly-by** whose
  off-axis *entry* is driven substantially by the concurrent component-wise
  zero-input locomotion deceleration, not by collision with the target point.
  Retained velocity without arrival braking then carries the player past the
  point; wall collision adds the later tangential slide. The pull-origin
  height changes which point the root aims at but does not cancel base
  deceleration, impose steering, stopping distance, or arrival.
  The authored GUT boundary fixtures explicitly preserve central-force
  angular momentum; an arrival/steering fix requires a conscious gameplay
  change and updated regression expectations rather than a visual-origin tweak.

The first attempt to gather a multi-frame trace used invalid indentation in
`game_eval`, putting that test run at a debugger break. It was stopped through
MCP and the scene relaunched without saving. The successful trace above is from
the fresh live run. No gameplay files were changed in this clarification.

## Hand-off Brief

1. **What happened.** In `main.tscn`, a clean wall grapple accelerated toward the hit point, then momentum carried the player past it. Velocity was already opposite the pull by frame 90; wall contact then blocked inward motion and the player slid along the wall.
2. **Where the case stands.** The pull vector is correct. Main-scene telemetry confirms acceleration-based overshoot plus collision redirection, not a mis-aimed force. A capsule-sized stand-off remains at the wall.
3. **What's needed next.** Decide whether grapple should brake near a wall hit or intentionally swing past it; no gameplay files were changed.

## Case Info

| Field            | Value |
| ---------------- | ----- |
| Ticket           | N/A |
| Date opened      | 2026-09-27 |
| Status           | Concluded (main-scene wall reproduction confirmed) |
| System           | Windows; Godot project `testgame` |
| Evidence sources | User report; repository source/tests/history; Godot AI MCP session `grapplegame@158d53ec546cd5b1` |

## Problem Statement

The user reports that while grappling toward a wall in the main scene, the player appears to be pulled off-axis and ends up offset. This behavior was reproduced in a controlled main-scene wall pull; the measured force direction initially matched the anchor, but the resulting velocity later carried the player past it.

## Evidence Inventory

| Source      | Status    | Notes |
| ----------- | --------- | ----- |
| User report | Available | Describes apparent indirect pull and final offset; no reproduction details yet. |
| Source code | Available | Pull, anchor, presentation, and motor call chain traced with path/line evidence below. |
| Tests/results | Available | Grapple targeting, moving-target, and boundary tests exist under `tests/player/grapple/`; `tests/player/grapple/test_grapple_targeting_integration.gd:443-499` expects the pull may not arrive during its sampled window. Historical test logs exist for stories 1.6–1.9. Main-scene MCP runtime results are recorded below; GUT was not run. |
| Diagnostics | Partial | MCP editor reports `_load: Resource file not found: res://` / failed autoload plus script warnings. The custom tutorial and restored main scene both reached a live helper; no grapple-specific game-log errors were observed. The editor diagnostic was not traced and is not linked to the offset. |
| Version control | Available | Recent grapple history includes stories 1.6–1.9. `git status` after the test showed modified `main.tscn`, `project.godot`, and `scenes/player.tscn`, plus untracked investigation/spec artifacts; none were edited by this test and all were left untouched. |
| Issue tracker | Missing | No ticket ID or issue-tracker source was provided/available in this investigation. |
| Static analysis | Partial | MCP editor warnings are visible; no focused static-analysis report has been inspected. |
| Runtime | Available | Godot AI MCP session `grapplegame@158d53ec546cd5b1` explicitly ran `res://main.tscn` (run `r10588724-18`) and reproduced the wall offset at `LowBlockA`. A clean 120-physics-frame trace sampled the attachment and slide contacts every frame. Inputs used the existing `PlayerInputSource` test seam; no gameplay files were edited. An earlier tutorial run is documented separately below. |

## Investigation Backlog

| # | Path to Explore | Priority | Status | Notes |
| - | --------------- | -------- | ------ | ----- |
| 1 | Trace grapple anchor sampling, pull-vector calculation, and player movement commit | High | Done | Pull direction, contributing policies, constraints, and physics commit are identified below. |
| 2 | Check grapple attachment/visual origins and authored target position | Medium | Done | Rope starts at mesh center; gameplay pull references body origin. Moving-target marker may retain the initial hit position. |
| 3 | Compare prior grapple tests/results and recent relevant changes | Medium | Done | Current relevant history reaches stories 1.6–1.9; tests establish contracts but were not run for this investigation. |
| 4 | Investigate editor autoload error if runtime verification is needed | Medium | Done | Startup reports `_load: Resource file not found: res://` / autoload instantiation failure, but the game helper became live and grapple testing completed; this diagnostic did not block the test and was not traced further. |

## Timeline of Events

| Time | Event | Source | Confidence |
| ---- | ----- | ------ | ---------- |
| 2026-09-27 | User reports player appears not pulled directly toward grapple point and ends offset. | User message | Confirmed as a report |
| 2026-09-27 | Source search identifies pull submission in grappling state. | `scripts/player_grappling_state.gd:50` | Confirmed |
| 2026-09-27 | Godot AI MCP session `grapplegame@158d53ec546cd5b1` listed; editor state, open-scene roots, grappling-state script, and editor diagnostics read. Editor is ready but game stopped; state reports tutorial scene current. | Godot AI MCP | Confirmed |
| 2026-09-27 | Git status/history checked; pre-existing edits to `project.godot`, `scenes/player.tscn`, and two other investigation files observed. | Git | Confirmed |
| 2026-09-27 | Source trace followed pull submission through grapple controller, attachment, player motor, and presentation code; runtime testing had not yet been performed at that point. | Repository source; delegated source scan | Confirmed |
| 2026-09-27 | Ran the tutorial scene through MCP with autosave disabled. A grapple begun while grounded ended at `ground_contact` after 0.3 s at 15.68 m from the anchor. | Godot AI MCP session `grapplegame@158d53ec546cd5b1` | Confirmed |
| 2026-09-27 | Repeated after jumping. The attachment remained active at a 1.09 m root-to-anchor distance; last slide contacts were with `FirstPullBranch`, both normals `(0,-1,0)`. | Godot AI MCP game telemetry, node info, and `game_eval` | Confirmed |
| 2026-09-27 | Stopped the test scene and relaunched the original main scene (`res://main.tscn`) with autosave disabled; MCP confirmed the helper live. | Godot AI MCP session `grapplegame@158d53ec546cd5b1` | Confirmed |
| 2026-09-27 | Explicitly relaunched `res://main.tscn` with autosave disabled; runtime tree root was `/Main`, player at `(0, 0.099, 0)`. Aiming via the existing test seam produced an accepted `LowBlockA` hit at `(-8.5, 3.125, -17.070)`. | Godot AI MCP run `r10588724-18`, session `grapplegame@158d53ec546cd5b1` | Confirmed |
| 2026-09-27 | During one clean pull, velocity aligned with pull at 0.999 early; by frame 90 the player was 2.38 m from the anchor and velocity/pull alignment was -0.499. At frames 98–104, slide contacts with `LowBlockA` had normal `(1,0,0)` while the player continued along the wall. At frame 120 it was 7.85 m away and alignment was -0.994. | Godot AI MCP `game_eval` trace, attachment snapshots, all-frame slide-contact inspection | Confirmed |
| 2026-09-27 | Released the test input; the attachment ended with reason `release`. The MCP game helper remained live. | Godot AI MCP run `r10588724-18`, telemetry and editor state | Confirmed |
| 2026-09-27 | Final worktree check showed `main.tscn` and other project/artifact files dirty; the test did not save or edit them. | `git status --short` | Confirmed |

## Confirmed Findings

### Finding 1: Grappling state submits a pull each update

**Evidence:** `scripts/player_grappling_state.gd:50`

**Detail:** The grappling-state path calls `agent.submit_grapple_pull(delta)`. MCP read confirms the state samples an anchor, submits movement/gravity policies, then submits grapple pull and a speed cap; the downstream calculation and motor commit are detailed in Findings 2–5.

### Finding 2: Pull acceleration points directly from the body origin to the sampled anchor

**Evidence:** `game/player/abilities/grapple/grapple_controller.gd:106-110,364-382`

**Detail:** Pull direction is `reference_position.direction_to(sample.anchor_world_position)`, and `reference_position` is the owning `CharacterBody3D.global_position`. Thus the premise that the pull acceleration vector itself is aimed elsewhere is refuted.

### Finding 3: Grapple is acceleration-based, not an arrival/position constraint

**Evidence:** `game/player/motor/player_motor.gd:328-340,800-885,905-920`; `game/player/abilities/grapple/grapple_attachment.gd:280-296`

**Detail:** The motor starts with existing body velocity, applies base movement/gravity and sustained grapple acceleration, resolves constraints and a total-speed cap, then commits with `move_and_slide()`. Pull acceleration decays to a nonzero floor; there is no arrival brake, stopping-distance calculation, proximity termination, or snap to the anchor. Pointing acceleration at the anchor therefore does not make velocity or the resulting path point exactly there, nor guarantee the character stops there.

### Finding 4: Player-visible references do not all use the same point

**Evidence:** `scripts/player_controller.gd:1270-1311`; `game/player/abilities/grapple/grapple_controller.gd:106-110,364-382`; `game/player/abilities/grapple/presentation/grapple_target_marker.gd:62-75`

**Detail:** Gameplay pull uses the body root origin, the rope starts at the player mesh center, and the marker presents the targeting result's hit position. For a moving target, targeting evaluation is skipped while attached, so the marker may show the original hit while the gameplay anchor follows the target's stored local hit offset (`game/shared/contracts/grappleable_3d.gd:111-150`; `scripts/player_controller.gd:542-558`).

### Finding 5: A surface hit may be physically unreachable by the player root

**Evidence:** `game/player/abilities/grapple/grapple_target_resolver.gd:216-229`; `scenes/player.tscn:31-33,60-67`; `game/player/motor/player_motor.gd:905-920`

**Detail:** The grapple point is the collider ray-hit position. The player has a capsule collider of radius 0.45 m, centered 0.9 m above the body root, and moves with collision-aware `move_and_slide()`. In the main-scene trace, the player root stopped at x≈-8.05 against the `LowBlockA` face at x=-8.5 (about one capsule radius away). This explains the normal stand-off, but not the much larger tangential offset after overshoot.

### Finding 6: Ground contact can terminate an active grapple after the physics commit

**Evidence:** `scripts/player_controller.gd:425-431`; live MCP tutorial telemetry

**Detail:** When the grappling state commits a grounded contact frame, the controller terminates the attachment with `GROUND_CONTACT` and dispatches landing. In the tutorial's first-pull setup, the attachment ended after 0.3 s with 15.68 m remaining. This is conditional on still being grounded at post-commit: in the main-scene wall run, the pull lifted the player off the floor, so the grapple stayed active. Inputs in MCP were delivered through the existing `PlayerInputSource` seam because background-window action simulation did not publish command frames.

### Finding 7: When airborne, the first-pull branch collider physically blocks further approach

**Evidence:** Live MCP attachment telemetry and `game_manage.get_slide_collision_count()` / collision snapshots; `game/player/motor/player_motor.gd:905-920`

**Detail:** After jumping and grappling the same tutorial point, the attachment remained active. The player root was approximately `(0, 2.80, 4.45)`, the sampled anchor `(0, 3.79, 4.0)`, and the reported distance 1.09 m. Pull direction remained toward the anchor `(0, 0.91, -0.41)`, acceleration was at its 8 m/s² floor, and speed was about 0.08 m/s. The last two slide contacts were with `/root/TreeGrappleTutorial/Generated/FirstPullBranch`, both with downward normals `(0,-1,0)`. This confirms collision clearance under the branch as the cause of the close residual gap in this test. The player's `PlayerInputSource` test seam was used for the simulated jump/grapple inputs; no scripts or scenes were edited.

### Finding 8: Main-scene wall offset is caused by retained momentum, then wall-slide collision

**Evidence:** Godot AI MCP run `r10588724-18`; attachment snapshots and slide collisions at every physics frame; `grapple_controller.gd:364-382`; `player_motor.gd:328-340,800-920`

**Detail:** The clean run began at player root `(0, 0.099, 0)`. The third-person targeting ray originated at `(1.257, 3.125, 2.524)` and hit the `LowBlockA` wall at `(-8.5, 3.125, -17.070)`. At frame 4, pull direction was `(-0.440, 0.157, -0.884)` and velocity alignment with it was `0.999`, confirming the initial acceleration aimed directly toward the sampled hit. The 1.92 m closest approach occurred at frame 85: root `(-6.834, 3.907, -17.619)`, or anchor-relative offset `(+1.666, +0.782, -0.549)`; pull direction was `(-0.914, -0.376, +0.151)`, but velocity was `(-6.071, +3.289, -15.386)` and its alignment with the pull was only `0.118`. There were no wall contacts before frame 98, so this 1.92 m gap was a fly-by, not collision clearance. By frame 90 the player was already moving away from the anchor: distance 2.38 m, pull/velocity alignment `-0.499`. At frames 98–104 the capsule contacted `LowBlockA`'s x face (normal `(1,0,0)`); x stayed near `-8.05`, but z continued past the target from `-20.70` to `-21.93`. At frame 120 it remained attached, 7.85 m from the anchor, with velocity/pull alignment `-0.994`. The pull remains directed toward the anchor while momentum carries the player away; the wall blocks the normal component and permits tangential slide.

## Deduced Conclusions

### Deduction 1: The pull can be correctly aimed while the visible trajectory is not

**Based on:** Findings 2–4.

**Reasoning:** The pull uses body-root-to-anchor direction, but the motor integrates that acceleration into existing velocity. The live main-scene run begins aligned, then velocity reverses relative to the pull after the player passes the hit; the wall blocks inward movement and the player slides along it.

**Conclusion:** The main-scene off-axis path is reproduced without a misdirected pull: it is inertial overshoot and collision redirection. Rope/marker reference differences are separate possible visual contributors.

### Deduction 2: A remaining gap is compatible with the implemented mechanics

**Based on:** Findings 3 and 5.

**Reasoning:** There is no rule that converges position to the anchor, while a surface hit may be blocked by the player capsule; `move_and_slide()` resolves collisions instead of teleporting through them.

**Conclusion:** The system does not promise that the body root reaches or stops at the hit point. In the tutorial run, branch contact left a 1.09 m gap; in the main-scene run, capsule stand-off at the wall was compounded by tangential overshoot to 7.85 m from the anchor.

## Hypothesized Paths

### Hypothesis 1: The pull acceleration is aimed away from the grapple point

**Status:** Refuted

**Theory:** The acceleration vector itself is not directed from the player toward the sampled grapple point.

**Supporting indicators:** User report describes a visually indirect pull.

**Would confirm:** A code/runtime vector that differs from the normalized body-origin-to-anchor vector.

**Would refute:** Pull-vector implementation and runtime vector match body-origin-to-anchor direction.

**Resolution:** Refuted by `grapple_controller.gd:364-382`; the acceleration direction is direct. The original wording conflated force direction with velocity/position convergence.

### Hypothesis 2: Pulling does not guarantee arrival because it is an acceleration influence without an arrival rule

**Status:** Confirmed

**Theory:** Existing velocity and movement policies affect the path; no stopping-distance brake or positional snap ensures convergence.

**Supporting indicators:** Confirmed motor order, persistent velocity, speed cap, nonzero pull floor, and `move_and_slide()` commit.

**Would confirm:** Source evidence of no arrival rule and the pull being applied as a velocity influence.

**Would refute:** A separate active grapple arrival constraint or snap in the traced path.

**Resolution:** Confirmed by `player_motor.gd:328-340,800-920` and `grapple_attachment.gd:280-296`.

### Hypothesis 3: Collision clearance is the specific cause of the close residual gap in the airborne tutorial attempt

**Status:** Confirmed for the tutorial attempt; partial contributor in the main-scene run

**Theory:** The player capsule collides with the target before its root can occupy the target's ray-hit point.

**Supporting indicators:** The target anchor is a surface hit, the capsule radius is 0.45 m, and movement is collision-resolved.

**Would confirm:** Runtime telemetry showing stable target contact and a residual distance consistent with the collision shape/target surface.

**Would refute:** A non-colliding target or a residual gap while clear of all collision constraints.

**Resolution:** Confirmed in the tutorial run: at 1.09 m from its anchor, the player had two `FirstPullBranch` contacts. In the main-scene run, contact against the wall held the root about 0.45 m off the face, but the larger offset came from motion along the wall after passing the anchor.

### Hypothesis 4: Presentation references contribute to the perceived offset

**Status:** Confirmed (reference mismatch); runtime contribution unverified

**Theory:** The rope starts at mesh center rather than the body origin used by the force; for moving targets, the marker can retain the initial hit point.

**Supporting indicators:** Direct source evidence in rope and marker presentation paths.

**Would confirm:** Compare rope start/marker with body origin/sampled anchor during play.

**Would refute:** A presentation path that updates from the same body reference and current sampled anchor throughout the attachment.

**Resolution:** Source confirms distinct references; whether this explains the user's specific visual report needs runtime observation.

### Hypothesis 5: The tutorial's grounded grapple stops far short because ground contact ends the attachment

**Status:** Confirmed for the tutorial setup only

**Theory:** In the tutorial's first-pull setup, the post-commit grounded-contact path terminated the attachment before it could reach the anchor.

**Supporting indicators:** `player_controller.gd:425-431` commits `GROUND_CONTACT` for a grounded frame in the grappling state; the MCP tutorial attempt ended at that reason after 0.3 s with 15.68 m remaining.

**Would confirm:** A grounded grapple run ending with the typed `ground_contact` terminal while still distant from the anchor.

**Would refute:** A grounded grapple that remains active despite grounded post-commit contact.

**Resolution:** Confirmed only for that tutorial case. The main-scene wall pull began grounded but accelerated the player off the floor and remained active; this is not the cause of the reproduced main-scene offset.

### Hypothesis 6: Retained velocity carries the player past the wall anchor

**Status:** Confirmed

**Theory:** Grapple acceleration points toward the anchor but has no arrival brake, so existing high velocity persists after the player passes the target. Wall collision blocks the inward component while preserving tangential movement.

**Supporting indicators:** In the main-scene MCP trace, pull/velocity alignment changed from `0.999` at frame 4 to `-0.499` at frame 90 and `-0.994` at frame 120. `LowBlockA` contacts at frames 98–104 had normal `(1,0,0)` while z velocity remained strongly negative.

**Would confirm:** Velocity pointing away while pull points toward the anchor, followed by contact-normal blocking and tangential slide.

**Would refute:** Velocity remaining aligned and slowing to a stop at the anchor without collision.

**Resolution:** Confirmed in a clean 120-physics-frame main-scene run. The attachment was still active 7.85 m from the anchor at frame 120; after the test input was released, telemetry reported terminal `release`.

## Missing Evidence

| Gap | Impact | How to Obtain |
| --- | ------ | ------------- |
| Whether intended grapple feel is to swing past a point or brake near it | Determines whether the overshoot is a bug or the intended acceleration-based movement style | Confirm expected design behavior; the current code and live run establish the mechanics but not design intent. |

## Source Code Trace

| Element | Detail |
| ------- | ------ |
| Error origin | No erroneous pull direction found. Pull is submitted at `scripts/player_grappling_state.gd:50` and calculated at `game/player/abilities/grapple/grapple_controller.gd:364-382`. |
| Trigger | Grapple state's per-update pull submission. |
| Condition | Pull starts directly toward the wall hit, but acceleration is integrated into velocity without an arrival brake. Once the player passes the anchor, wall collision blocks inward movement and remaining tangential momentum slides the capsule away along the wall. |
| Related files | `scripts/player_grappling_state.gd`, `scripts/player_controller.gd`, `game/player/abilities/grapple/grapple_controller.gd`, `grapple_attachment.gd`, `grapple_target_resolver.gd`, `game/shared/contracts/grappleable_3d.gd`, `game/player/motor/player_motor.gd`, and `scenes/player.tscn`. |

## Conclusion

**Confidence:** High

The clean main-scene wall run reproduces the user's off-axis movement. The pull direction initially matches the anchor (velocity alignment `0.999` at frame 4), but there is no arrival brake. After the player passes close to the anchor, velocity points away even while pull points back (`-0.499` alignment at frame 90). The capsule then contacts `LowBlockA`'s face and slides tangentially along it; at frame 120 the active grapple is 7.85 m from the anchor and velocity/pull alignment is `-0.994`. The wall's surface clearance contributes roughly one capsule radius, while the conspicuous offset comes from retained momentum and wall sliding. Separate tutorial tests also confirmed conditional `ground_contact` termination and branch stand-off, but those were not the cause of this main-scene reproduction.

## Recommended Next Steps

### Fix direction

The force vector does not need redirection. If grapple should stop near the aimed wall point, the pull needs an arrival/braking behavior that accounts for the capsule's wall stand-off; otherwise the current acceleration model carries momentum past the point, and wall contact redirects it into tangential slide. No gameplay change was made; decide whether the intended feel is to stop at the hit or swing past it before implementation.

### Diagnostic

The live test used existing F3 grapple telemetry (`scripts/debug_grapple_telemetry.gd:100-175`), read-only attachment snapshots, and per-physics-frame slide-collision inspection. The key discriminator is velocity alignment with the pull direction: negative alignment after approaching the target confirms overshoot; wall-normal contact plus continued tangential velocity explains travel along the wall.

## Reproduction Plan

MCP run: explicitly launch `res://main.tscn` with autosave disabled. From spawn `(0, 0.099, 0)`, aim at the `LowBlockA` wall hit `(-8.5, 3.125, -17.070)`, hold grapple for 120 physics frames, and record read-only attachment snapshots and slide collisions every frame. The test used the existing `PlayerInputSource` seam; the action was released afterward, the MCP helper remained live, and no source or scene files were modified.

## Side Findings

None.
