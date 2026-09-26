---
baseline_commit: dbd3289349636b41e9a69d75e146e4ea8b27b273
---

# Story 1.9: Integrate Wall Traversal and Mistake Recovery

Status: done

<!-- Context-engine note: this story integrates the EXISTING prototype wall traversal (wall run, wall stick, wall jump) with the established command, motor, contact, and grapple contracts. It is an integration/hardening story, not a redesign and not a tuning story. All acceptance criteria transcribed verbatim from the canonical story shard. -->

## Story

As a player,
I want wall running, wall sticking, wall jumping, and recovery movement to connect cleanly with my other traversal abilities,
so that I can use walls confidently and recover from ordinary mistakes without losing control or restarting the level.

## Acceptance Criteria

1. **Enter wall running from authoritative facts**

   **Given** the player is airborne, is not grappling, and the current `ContactFrame` identifies a supported wall
   **When** current speed and command-frame movement satisfy the authored wall-run entry policy
   **Then** the movement HSM enters wall running exactly once using the selected wall identity, normal, and deterministic run direction
   **And** the wall-run state performs no separate collision query or hardware-input read.

2. **Resolve wall-run movement through the motor**

   **Given** wall running is active
   **When** the motor resolves the physics step
   **Then** along-wall acceleration, wall-relative redirection, gravity behavior, and outward-motion removal use their established semantic motor phases
   **And** useful incoming and along-wall momentum is retained according to the authored traversal policy
   **And** the state neither writes final body velocity nor performs an additional movement commit.

3. **Remain stable on supported non-flat geometry**

   **Given** the player traverses corners, oblique walls, or adjacent faces with small normal variation
   **When** the shared wall relationship remains within its continuity tolerance
   **Then** wall running continues without rapid state oscillation or unintended direction reversal
   **And** a genuinely lost or unsupported wall still causes a prompt exit.

4. **Exit wall running predictably**

   **Given** wall running is active
   **When** the player lands, loses valid wall contact, stops satisfying the input policy, starts a grapple, jumps, or dies
   **Then** exactly one appropriate movement transition occurs
   **And** retained velocity, cleared wall state, and any submitted impulses follow the transition's explicit policy
   **And** stale wall facts cannot keep the player in wall running.

5. **Perform a single wall-jump impulse**

   **Given** the player presses jump while wall running
   **When** the current wall relationship remains valid
   **Then** one occurrence-identified impulse launches the player upward and away from the selected wall while retaining the permitted along-wall component
   **And** the player transitions to airborne movement with immediate steering and grapple acquisition available
   **And** holding or repeating the same command cannot apply the impulse twice.

6. **Enter grapple-assisted wall sticking**

   **Given** an active grapple pulls the player into a supported wall
   **When** the current contact, movement, grapple, and input conditions satisfy the existing wall-stick entry policy
   **Then** the movement HSM enters wall sticking exactly once using the authoritative wall relationship
   **And** the hold is expressed through the motor's constraint phase rather than repeatedly writing `global_position` or committing movement separately.

7. **Exit wall sticking safely**

   **Given** wall sticking is active
   **When** the player releases the grapple, presses jump, loses required wall contact, the attachment becomes invalid, or the player dies
   **Then** the wall-stick constraint is removed exactly once
   **And** grapple termination remains idempotent
   **And** jump produces the authored upward, away-from-wall, and along-wall motion while non-jump exits preserve the appropriate recoverable velocity.

8. **Preserve traversal interoperability**

   **Given** the player transitions among ground movement, air movement, grappling, wall running, and wall sticking
   **When** a valid transition occurs
   **Then** the destination state begins from the authoritative post-motor velocity and current command/contact data
   **And** no transition introduces an unexplained stop, duplicated impulse, stale attachment, or second physics commit.

9. **Keep ordinary mistakes recoverable**

   **Given** the player misses a wall-run entry, leaves a wall early, releases a grapple short of the intended landing, or performs a wall jump imperfectly
   **When** a reachable surface, valid grapple target, or remaining air-control option exists
   **Then** the player retains access to that recovery option without an automatic level restart
   **And** construction of the complete authored recovery route remains assigned to Story 1.10.

10. **Verify wall traversal integration**

    **Given** focused automated fixtures running against real Godot/Jolt physics
    **When** they exercise left- and right-side wall runs, valid and invalid wall angles, corners, wall loss, landing, grapple entry from a wall run, grapple-assisted wall sticking, release, wall jumps, repeated commands, attachment invalidation, death, and recovery transitions
    **Then** state transitions, velocity policies, impulses, constraints, and cleanup produce their expected typed outcomes
    **And** representative behavior remains equivalent at shipping 60 Hz and diagnostic 120 Hz within documented tolerances.

    **Given** Story 1.9 is complete
    **When** its scope and working-tree diff are reviewed
    **Then** it has integrated existing wall traversal with the command, motor, contact, and grapple contracts
    **And** it has not created the complete M0 route, preserved or rebuilt the old tutorial, added moving-wall mechanics, implemented combat or hostile surface effects, or added final presentation.

## Tasks / Subtasks

- [x] Task 1: Wall-run entry from authoritative contact facts (AC: 1)
  - [x] 1.1 Route wall-run entry/maintenance exclusively through the shared `ContactFrame` wall facts (`has_wall_contact`, `wall_normal`, wall identity/provenance/relation, `continuity_action`, `wall_contact_lost`) in `_update_wall_run_state`; no new queries, no `is_on_wall()`/`get_wall_normal()`/slide-collision access in wall policy.
  - [x] 1.2 Make entry exactly-once: `EVENT_WALL_RUN_STARTED` fires on the single airborne→wall-run transition only; the maintenance path never re-enters, re-dispatches, or re-arms entry while `is_wall_running`.
  - [x] 1.3 Establish the wall relationship once per relationship: capture `wall_surface_identity`/`wall_identity_persistent` and derive the deterministic run direction (tangent `wall_normal × UP`, sign aligned with horizontal reference velocity) at `INITIAL`/`SWITCHED`, not every step.
  - [x] 1.4 Keep the authored entry policy (speed gate `wall_run_min_horizontal_speed`/`wall_run_max_entry_speed`, input alignment `wall_run_min_input_alignment`, airborne + not-grappling gates) in the traversal layer; the contact provider selects geometry, never wall-run eligibility.
  - [x] 1.5 Confirm wall-run state code reads only the immutable `PlayerCommandFrame` and controller views (extend the existing input source-scan to cover any new wall-policy code).

- [x] Task 2: Wall-run movement through the semantic motor phases (AC: 2)
  - [x] 2.1 Keep along-wall base movement in `BASE_LOCOMOTION_AND_GRAVITY` (`SOURCE_BASE_WALL_RUN`), gravity behavior in the gravity policy (`SOURCE_GRAVITY_WALL_RUN` / zero-vertical rule), and wall redirection + outward removal in `CONSTRAINTS_AND_REDIRECTIONS` (`SOURCE_WALL_RUN_CONSTRAINT`).
  - [x] 2.2 Verify and document the momentum policy in Completion Notes: how incoming above-target along-wall speed and entry velocity are treated; if useful momentum is discarded contrary to FR4/GDD "retained momentum", make the minimal explicit policy fix; no redesign of the base-motion or constraint formulas.
  - [x] 2.3 Assert the state writes no final velocity, no `global_position`, and performs no second commit (extend the motor writer source-scan if wall-policy code moved).
  - [x] 2.4 Preserve the `MAXIMUM_ANCHOR_DISTANCE`-after-`WALL_RUN_CONSTRAINT` resolution order and all existing submission validation.

- [x] Task 3: Stability on corners, oblique walls, and adjacent faces (AC: 3)
  - [x] 3.1 Consume continuity facts instead of re-deriving the wall relationship every step: `PRESERVED`/`CONTINUITY` keeps the established identity, normal, and run direction within the documented tolerance (25° angle, 0.2 m point, 2-step loss window in `WallProbe`); no direction reversal while continuity holds.
  - [x] 3.2 On `SWITCHED`, re-derive the relationship and run direction exactly once, deliberately; on `LOST`/`wall_contact_lost`, exit promptly per Task 4.
  - [x] 3.3 Keep tolerances authored in `WallProbe`/`PhysicsQueryProfile`; do not retune continuity values and do not treat them as range.
  - [x] 3.4 Cover corner/oblique/normal-noise scenarios in the real-Jolt matrix (AC 10), asserting no oscillation (bounded state-entry counts) and no unintended run-direction flip.

- [x] Task 4: Predictable wall-run exits (AC: 4)
  - [x] 4.1 Enumerate and make explicit each exit: landing (`EVENT_LANDED`), genuine wall loss (`EVENT_WALL_RUN_FINISHED`), input-policy failure, grapple start (`EVENT_GRAPPLE_STARTED`), wall jump (`EVENT_WALL_RUN_FINISHED` + impulse), death (`EVENT_DIED`); exactly one transition per exit with the preserved clear/passthrough ordering.
  - [x] 4.2 Stale-fact guard: a carried previous-step frame, exhausted loss window, `wall_contact_lost`, or unavailable wall profile must end wall running rather than holding it (fail toward exit).
  - [x] 4.3 Document each exit's velocity policy (retained velocity, cleared state, submitted impulse) in Completion Notes and assert it in tests.
  - [x] 4.4 Preserve post-commit landing routing (`LOCOMOTION_WALL_RUN` treated like airborne for `EVENT_LANDED`) and the `_exit()` clear-on-leave behavior.

- [x] Task 5: Single wall-jump impulse (AC: 5)
  - [x] 5.1 Keep one occurrence-identified impulse (`SOURCE_JUMP_WALL` + `COMMAND_JUMP_PRESSED` occurrence key); the motor's `DUPLICATE_OCCURRENCE` rejection is the double-apply guard for held/repeated commands — add the repeated-command test.
  - [x] 5.2 Preserve the authored impulse math: away (`wall_normal * wall_jump_away_velocity`), up (`wall_jump_up_velocity`), retained positive along-wall component from projected horizontal reference velocity; impulse = desired − reference.
  - [x] 5.3 Ensure the wall-jump exit lands in airborne with immediate steering and grapple acquisition available on the next command frame (no lingering wall state, no stale attachment).
  - [x] 5.4 Keep the documented clear-before-submit ordering explicit (state cleared and transition dispatched even if the submission is rejected as duplicate); record it in Completion Notes.

- [x] Task 6: Grapple-assisted wall sticking entry and hold (AC: 6)
  - [x] 6.1 Preserve the existing wall-stick entry policy (`_try_start_wall_stick_from_contact`: grapple active, `GRAPPLE` held, not grounded, committed-frame wall contact, shared speed gate, input alignment) and the single `EVENT_WALL_STICK_STARTED` transition (grappling → wall-stick).
  - [x] 6.2 Express the hold through the motor's `WALL_STICK_HOLD` constraint-phase submission (exclusive-hold frame rule preserved: `STATE_POLICY` + `WALL_STICK_HOLD` only); the state layer never writes `global_position` and never commits movement separately.
  - [x] 6.3 **Stop-and-ask guard:** if AC 6 requires changing how `PlayerMotor` implements the hold (e.g. removing the motor's per-commit hold position write in favor of velocity-space correction), stop and ask the user before altering the established motor commit contract.
  - [x] 6.4 Keep the wall-stick zero-velocity baseline seam (`set_next_frame_velocity_baseline`) and the Story 1.8 per-step grapple sampling in the stick state.

- [x] Task 7: Wall-stick exits, idempotency, and wall-contact loss (AC: 7)
  - [x] 7.1 Add the missing required-wall-contact-loss exit: consume `ContactFrame` loss facts (continuity window, `wall_contact_lost`) so a lost/unsupported wall ends the hold; today the stick state has no wall-contact exit (integration gap).
  - [x] 7.2 Preserve the existing exits: grapple release (`RELEASE` + rate-0 passthrough), jump (`EVENT_WALL_STICK_JUMPED` + impulse + `STATE_CANCELLATION` termination), attachment invalid (Story 1.8 sampling termination), death.
  - [x] 7.3 Keep grapple termination idempotent through the single `GrappleController.terminate(reason, step)` funnel; `_clear_wall_stick()` runs exactly once on any grapple terminal (preserved `_on_grapple_attachment_ended` coupling).
  - [x] 7.4 Preserve the authored jump motion (up + away + `wall_stick_run_direction * wall_run_speed`) and document its intentional difference from the wall-run jump's projected along-wall component; non-jump exits preserve recoverable velocity.

- [x] Task 8: Traversal interoperability audit (AC: 8)
  - [x] 8.1 Audit every transition among grounded, airborne, grappling, wall-run, wall-stick, dead: destination state reads committed post-motor velocity plus current command/contact data only.
  - [x] 8.2 Verify no transition adds an unexplained stop, duplicated impulse, stale wall/grapple attachment, or second physics commit; preserve the Story 1.4 outer transaction (one command frame, one motor frame, one HSM update, seven phases, one commit, bounded post-commit coordination).
  - [x] 8.3 Keep movement/attack HSM separation and `EVENT_*` dispatch discipline; no cross-HSM mutation.

- [x] Task 9: Mistake-recovery guarantees and scope guard (AC: 9)
  - [x] 9.1 Verify missed entries, early wall exits, short grapple releases, and imperfect wall jumps leave a reachable surface, valid grapple target, or air-control option available (recovery-transition coverage in the matrix).
  - [x] 9.2 Verify no path triggers an automatic level restart (level/tutorial scripts unchanged).
  - [x] 9.3 Scope guard: do NOT construct the complete authored recovery route (Story 1.10), rebuild or preserve the old tutorial, add moving-wall mechanics, implement combat/hostile surface effects, or add final presentation.

- [x] Task 10: Verification matrix and dual harness (AC: 10)
  - [x] 10.1 Build the real-Jolt fixture matrix: left/right wall runs, valid/invalid wall angles, corners, wall loss, landing, grapple entry from a wall run, grapple-assisted sticking, release, wall jumps, repeated commands, attachment invalidation, death, recovery transitions.
  - [x] 10.2 Assert typed outcomes: transitions, velocity policies, single impulses, constraint application/removal exactly once, cleanup.
  - [x] 10.3 Run representative scenarios at 60 Hz and diagnostic 120 Hz inside the tests with documented tolerances (NFR4); always restore `Engine.physics_ticks_per_second` on every exit path.
  - [x] 10.4 GUT canonical gate (recursive `res://tests/player/**`) + focused runs; MCP live gate (preflight, rescans, `game_eval`/input smoke, logs); report both separately, claim no parity.
  - [x] 10.5 Evidence set under `_bmad-output/implementation-artifacts/evidence/1-9/`; update the story Dev Agent Record (MCP session ID, operations, results).

### Review Findings (2026-09-26)

- [x] [Review][Patch] [P1] Retain the required wall when camera yaw changes during a wall stick [game/player/locomotion/contact/player_contact_provider.gd:651]
- [x] [Review][Patch] [P2] Check the current wall relationship before applying a wall-stick jump [scripts/player_wall_stick_state.gd:35]
- [x] [Review][Patch] [P2] End or re-establish a wall stick when the authoritative wall switches [scripts/player_controller.gd:1077]
- [x] [Review][Patch] [P2] Assert uninterrupted wall-run continuity across the supported shallow corner [tests/player/locomotion/test_wall_traversal_integration.gd:76]
- [x] [Review][Patch] [P2] Verify authored wall-jump vectors against the real player controller [tests/player/locomotion/test_wall_traversal_integration.gd:162]
- [x] [Review][Patch] [P2] Verify above-target tangential momentum through an actual wall-run handoff [tests/player/locomotion/test_wall_traversal_integration.gd:330]
- [x] [Review][Patch] [P3] Exercise a recovery action after landing or an imperfect jump [tests/player/locomotion/test_wall_traversal_integration.gd:838]
- [x] [Review][Patch] [P3] Assert retained velocity on landing and input-policy wall-run exits [tests/player/locomotion/test_wall_traversal_integration.gd:142]
- [x] [Review][Patch] [P3] Assert the specific grapple terminal reason after anchor destruction [tests/player/locomotion/test_wall_traversal_integration.gd:272]

## Dev Notes

### Developer Context

Per-step choreography after Story 1.8 (binding). Story 1.9 adds no new step; it makes the wall paths consume the facts that already exist:

```text
pre-commit step N:
  capture immutable PlayerCommandFrame(N)                 (player input boundary)
  movement HSM update (manual, exactly once):
    wall-run entry/maintenance reads ContactFrame(N-1)     (shared wall facts ONLY)
      entry gate: airborne + not grappling + supported wall + speed gate + input alignment
      relationship: INITIAL/SWITCHED derives run direction once; PRESERVED keeps it
    grapple states sample GrappleAnchorState(N)            (Story 1.8 sampling phase)
    wall-stick step samples the anchor AND checks required wall contact
    states submit typed motor influences only:
      base motion / gravity policy        (BASE_LOCOMOTION_AND_GRAVITY)
      WALL_RUN_CONSTRAINT                 (CONSTRAINTS_AND_REDIRECTIONS)
      WALL_STICK_HOLD                     (CONSTRAINTS_AND_REDIRECTIONS, exclusive frame)
      one-shot jump impulses              (ONE_SHOT_IMPULSES, occurrence-identified)
  PlayerMotor resolves seven semantic phases -> one velocity assignment + one move_and_slide()

post-commit step N:
  contact provider publishes ContactFrame(N)               (Story 1.5 ownership)
  bounded controller coordination: landing routing; wall-stick entry from the
    committed frame + committed position (existing post-commit policy)
  presentation and diagnostics read the SAME snapshots (no recompute, no extra query)
```

Only `PlayerMotor` writes final velocity or calls `move_and_slide()`, exactly once per physics step (its single hold position write is inside that one commit). Wall states are influence submitters and fact consumers.

### Wall Relationship and Continuity Semantics (locked)

- **Facts come from the shared `ContactFrame` only.** Wall policy consumes `has_wall_contact`, `wall_normal` (normalized), `wall_surface_identity` / `wall_identity_persistent`, `wall_provenance`, `wall_relation`, `continuity_action`, `wall_contact_lost`, `wall_probe_query_succeeded`. Raw `is_on_wall()`, `get_wall_normal()`, slide-collision enumeration, and wall rays/shape casts stay out of controller/state code (Story 1.5 source-scan tests enforce; extend scans to any new wall-policy code).
- **The integration gap this story closes:** those wall facts are computed and published today but wall-run/wall-stick logic reads only `has_wall_contact` + `wall_normal`. Consuming the continuity/identity facts is the core of AC 1/3/4/7.
- **Continuity consumption rule.** `INITIAL` → establish relationship + derive run direction once. `PRESERVED` (provenance `CONTINUITY`) → keep identity/normal/run direction; small normal variation within tolerance must not reverse direction or re-trigger entry. `SWITCHED` → deliberate single re-derivation. `LOST` / `wall_contact_lost` → prompt exit. `UNAVAILABLE` → wall entry and hold are blocked (fail closed; the provider disables wall contact when the wall profile is invalid).
- **Tolerances are authored facts, not policy knobs:** `continuity_angle_degrees = 25`, `continuity_distance_m = 0.2 m`, `continuity_loss_steps = 2`, `wall_max_abs_normal_y = 0.2` (≈ 11.5°, matching the GDD "approximately 12° of vertical"), `probe_distance_m = 0.8` (GDD "wall within 0.8 m") in `game/shared/physics/wall_probe.gd` + `wall_probe.tres`. Do not retune; OD-009 still owns player-facing tolerance approval.
- **Deterministic run direction.** `_get_wall_run_direction` (tangent `wall_normal × UP`, sign aligned with horizontal reference velocity) runs at relationship establishment, not per step; per-step sign recomputation on varying normals is the AC 3 reversal hazard to eliminate.

### Wall-Run Entry, Movement, and Exit Policy (locked)

- **Entry policy stays in the traversal layer (do not retune; A-002/OD-009 baselines):** airborne, not grappling, `contact_frame.has_wall_contact`, horizontal speed ≥ `wall_run_min_horizontal_speed = 1.0`, total speed ≤ `wall_run_max_entry_speed = 18.0`, input alignment dot ≥ `wall_run_min_input_alignment = 0.2`. The provider answers "which wall"; the traversal layer answers "may we run it" (Story 1.5 AC 6 boundary, preserved).
- **Movement mapping (AC 2):** `submit_wall_run_base` → `submit_base_motion(SOURCE_BASE_WALL_RUN, wall_run_direction * wall_run_speed(10), wall_run_acceleration(4.0 as overridden in scenes/player.tscn), horizontal_only, zero_vertical per wall_run_zero_vertical_velocity)`; gravity behavior via `submit_gravity_policy` (`wall_run_gravity_scale` overridden to 0.0 in `scenes/player.tscn`; zero-vertical skips gravity entirely); redirection via `submit_wall_run_constraint(SOURCE_WALL_RUN_CONSTRAINT, wall_normal, wall_run_direction)` which projects horizontal velocity onto the wall direction and removes the outward normal component.
- **Momentum policy must be explicit (AC 2 rule 2).** Document in Completion Notes exactly how entry velocity and faster-than-target along-wall speed are treated. The GDD requires "preserve useful tangential travel" and FR4 requires momentum preservation; if the base policy silently bleeds useful incoming momentum, fix minimally and record it. Do not redesign the base-motion or constraint formulas.
- **Exits (AC 4) each produce exactly one transition** with documented velocity policy: land → `EVENT_LANDED` (grounded); genuine wall loss / input-policy failure → `EVENT_WALL_RUN_FINISHED` (airborne, committed velocity preserved); grapple press + accepted seed → `EVENT_GRAPPLE_STARTED`; jump → `EVENT_WALL_RUN_FINISHED` + one-shot impulse; death → `EVENT_DIED`. Stale or unavailable wall facts fail toward exit, never toward staying.

### Wall-Jump Impulse Contract (AC 5)

- One occurrence-identified impulse: `submit_wall_jump(reference_velocity)` submits `ONE_SHOT_IMPULSE (SOURCE_JUMP_WALL, COMMAND_JUMP_PRESSED, desired − reference)`; the motor rejects `DUPLICATE_OCCURRENCE`, so held/repeated commands cannot apply twice (add explicit repeated-command coverage).
- Authored motion: `desired = wall_normal * wall_jump_away_velocity(8.0) + along_wall`, `desired.y = wall_jump_up_velocity(5.5)`, where `along_wall` retains the positive projected horizontal reference velocity along the run direction (GDD: "Redirect momentum and retain positive along-wall travel").
- Exit lands in airborne with immediate steering and grapple acquisition on the next command frame. The current clear-before-submit ordering (`_clear_wall_run()` then submit, then `EVENT_WALL_RUN_FINISHED`) is the established behavior — keep it explicit and documented; a rejected duplicate must still leave a coherent airborne state.

### Wall-Stick Contract (AC 6, 7)

- **Grapple-assisted by design (do not generalize).** Entry requires an active grapple with `GRAPPLE` held, committed-frame wall contact, not grounded, the shared speed gate, and input alignment (`_try_start_wall_stick_from_contact`, post-commit). There is deliberately no airborne→wall-stick path. Project-context rule: "Wall sticking remains grapple-assisted and requires active grapple, held input, valid contact, and its speed/alignment conditions; it is not invulnerability."
- **Hold = motor constraint phase (AC 6).** `WALL_STICK_HOLD (SOURCE_WALL_STICK_HOLD, hold_position)` resolves in `CONSTRAINTS_AND_REDIRECTIONS`; the motor's exclusive-hold frame rule (only `STATE_POLICY` + `WALL_STICK_HOLD`; anything else is `EXCLUSIVE_POLICY_CONFLICT`, fail-closed) is a locked Story 1.4/1.5 contract. The hold position write is the motor's, inside the single commit. The wall-stick state and controller never write `global_position` or commit movement separately. **Stop-and-ask guard (Task 6.3):** changing the motor's hold mechanism itself requires user approval first.
- **Missing exit closed (AC 7):** the stick state currently exits only on grapple release, jump, invalid attachment, or death — it has no wall-contact-loss exit. Add the required-wall-contact-loss exit driven by the same continuity facts/loss window as wall run, removing the hold constraint exactly once.
- **Idempotent termination preserved (Story 1.8 locks):** all exits funnel through `GrappleController.terminate(reason, step)`; first committed terminal wins; `attachment_ended` fires once; preserved cleanup ordering (including `_clear_wall_stick()`) runs exactly once before consumers observe "ended". Wall-stick jump keeps `STATE_CANCELLATION`; release keeps `RELEASE`; new loss exit may reuse an existing typed reason or append a new value to the closed `GrappleEndReason.Reason` set **append-only** (never reorder; keep `reason_id()` bounds checks and stable lowercase ids).
- **Asymmetry note:** `submit_wall_stick_jump` builds along-wall motion from `wall_stick_run_direction * wall_run_speed` (full target speed), unlike `submit_wall_jump`'s projected component. This is the authored current policy — document it; do not silently harmonize (GDD baselines are validation values under A-002).

### Traversal Interoperability and Recovery (AC 8, 9)

- Destination states begin from the authoritative post-motor velocity (`result.submitted_velocity` / committed velocity views) and current command/contact data. No transition may introduce an unexplained stop, duplicated impulse (occurrence keys), stale wall/grapple attachment, or a second physics commit.
- Preserve the Story 1.4 outer transaction and its protections (duplicate-commit guard, rejected-follow-up handling, detached/freed-body safety, wall-stick zero baseline, stale-grapple landing clearing, bounded diagnostics).
- Recovery (AC 9) is a guarantee over transitions, not new content: after a missed entry, early exit, short release, or imperfect wall jump, a reachable surface / valid grapple target / remaining air control must remain usable and nothing restarts the level. The complete authored recovery route is Story 1.10 — do not build it here.

### Requirement Traceability

- **FR11** (primary): wall-run, wall-stick, wall-jump on supported non-flat surfaces using one shared authoritative wall interpretation -> AC 1, 2, 3, 4, 5, 6, 7, 10.
- **FR4** (supporting): preserve useful momentum across wall contact, grapple pull/release, and recovery actions per explicit policies -> AC 2, 5, 7, 8.
- **FR5** (supporting): recover from ordinary traversal mistakes without restarting the level while a recovery option remains -> AC 9.
- **FR2 / FR3** (consume): keyboard-and-mouse control and the immutable per-step `PlayerCommandFrame` drive all wall decisions -> AC 1, 4, 5, 7.
- **FR8 / FR9 / FR10** (preserve, interop): grapple zip-pull, maximum boundary, moving/stateful target termination must interoperate with wall-run entry and wall-stick holds -> AC 6, 7, 8.
- **FR12** (defer content): the focused route demonstrating the full vocabulary is Story 1.10; only the recovery guarantee is in scope -> AC 9, 10.
- **NFR3/NFR4** (60 Hz fixed step; 60/120 real-time equivalence), **NFR5** (seconds-authored timing), **NFR6** (tolerant physics assertions, swept/velocity-aware contact), **NFR7** (input edge handling; no hardware reads in states), **NFR10** (exactly-once/idempotent cleanup), **NFR15** (idempotent terminal results), **NFR20** (contract suite: motor commit, influence ordering, 60/120 equivalence, single terminal, idempotency), **NFR21** (risk-appropriate real-Jolt evidence) -> AC 2, 4, 5, 7, 8, 10.

### Architecture and Scope Guardrails

- File placement: wall policy remains in the legacy `scripts/` locations (`player_controller.gd`, `scripts/player_wall_run_state.gd`, `scripts/player_wall_stick_state.gd`) per the Story 1.6/1.7/1.8 naming-variance precedent — do not bulk-move; record any further variance in Completion Notes. Motor changes in `game/player/motor/`; contact facts stay in `game/player/locomotion/contact/` + `game/shared/physics/`. Tests mirror domains under `tests/player/…`.
- Naming: `snake_case` files/functions/variables/signals; `PascalCase` classes/enums; `UPPER_SNAKE_CASE` enum values; units in names; stable lowercase dotted source/locomotion ids already defined (`player.locomotion.wall_run`, `player.wall_run.constraint`, `player.wall_stick.hold`, `player.jump.wall`, …). Do not add new cross-object `_private` access; the existing `agent._clear_wall_run()` / `agent._update_wall_run_state()` calls are pre-existing debt — extend via the same narrow surface and record, do not proliferate.
- Motor discipline (locked): no new velocity writers, no numeric priorities, no scene-tree-order precedence; typed submissions keep stable `source_id`, kind/phase coherence, finite payloads, duplicate rejection, `MAX_ACCEPTED_SUBMISSIONS` bounds. No new submission kinds are expected (`WALL_RUN_CONSTRAINT`, `WALL_STICK_HOLD` already exist); if one becomes unavoidable, extend `player_motor_submission.gd` with the same validation discipline and append-only enum order.
- Preserve exactly: seven-phase resolution and single commit; `ContactFrame` ownership and its closed schema (extend only append-only if truly required); movement/attack HSM separation and `EVENT_*` transitions; press-edge activation and the `PlayerCommandFrame.Action` enum; Story 1.6 targeting locks (10-value `GrappleRejection`, quantized inclusive acquisition predicate, one authoritative raycast per evaluated step, `GrappleDefinition` sole range authority); Story 1.7 boundary locks (`GrappleEndReason` order/ids, occurrence-local resolution, `NO_ACTIVE_ATTACHMENT`, boundary resolves last in `CONSTRAINTS_AND_REDIRECTIONS`, body-origin reference, velocity-space overshoot prevention); Story 1.8 anchor-sampling locks (one `GrappleAnchorState` sample per step, target-relative offsets, relative-motion boundary + carry rules, `anchor_continuous_motion_tolerance_mps = 50.0` / `anchor_severe_discontinuity_threshold_mps = 250.0`).
- Frozen-spec discipline: `spec-grapple-visual-interpolation-reset.md` is preserved byte-for-byte; anything altering project-wide `physics/common/physics_interpolation`, grapple targeting, motor commit semantics, or the rope visual lifecycle is **stop and ask the user first** (see Task 6.3).
- UIDs preserved: `scenes/player.tscn` (`uid://u1u36ceuo8uj`), `player_grappling_state.gd` (`uid://cjlui8t4vv7ha`), all `.gd.uid` sidecars; new files get new UIDs only.
- Known migration debt to not expand: prototype `move_and_slide()` call sites (Story 1.3-era), legacy `print`/`push_error` diagnostics, `scripts/player_controller.gd` retained as the controller, dead exports `wall_run_max_normal_y` and `wall_check_distance` (superseded by `WallProbe` values) — leave in place or remove only with test updates and a Completion Notes entry.
- Dependency pins: Godot 4.7.2-stable, Forward+ (D3D12), Jolt Physics, GUT 9.7.1, LimboAI 1.8.1 (vendored), Terrain3D 1.0.2 optional (no wall dependency), Phantom Camera 0.11.0.2 deferred. Recorded discrepancy (do not act on): planning lists Godot AI 3.2.4 while the live MCP plugin/server reports 4.0.4.

### Current-State Update Map

Definite UPDATE (current state verified at authoring via MCP + file reads):

- `scripts/player_wall_run_state.gd` — today: `LimboState` (`_update`, `_exit`) reading only `agent`/`PlayerCommandFrame`; order: state policy → death → null frame → ground contact (`EVENT_LANDED`) → grapple press (`EVENT_GRAPPLE_STARTED`) → jump press (`submit_wall_jump` + `EVENT_WALL_RUN_FINISHED`) → `_update_wall_run_state(input_dir, reference_velocity)` maintenance → steady `submit_wall_run_base()` + `submit_gravity_policy()` + `submit_wall_run_constraint()`; `_exit()` clears wall run. This story: continuity-stable relationship consumption (Tasks 1, 3), explicit exit policies (Task 4), repeated-command evidence (Task 5). Preserve: submission ordering, transition events, command-frame-only reads.
- `scripts/player_wall_stick_state.gd` — today: state policy → death → null frame (hold) → grapple not held (`terminate_grapple(RELEASE)` + `submit_wall_stick_release` + `EVENT_GRAPPLE_RELEASED`) → Story 1.8 per-step anchor sampling with typed invalid-sample termination → jump (`submit_wall_stick_jump` + `EVENT_WALL_STICK_JUMPED`) → `submit_wall_stick_hold()`. This story: add the required-wall-contact-loss exit (Task 7.1). Preserve: grapple coupling, sampling phase, idempotent termination, source-scan rule "reads grapple snapshots only" (no `get_grapple_attachment(`).
- `scripts/player_controller.gd` — today: wall tuning exports (`wall_run_*`, `wall_jump_*` at lines 19–41; two dead exports), wall state vars (185–191), `EVENT_*`/`LOCOMOTION_*`/`SOURCE_*` constants (110–138), HSM wiring (276–295), post-commit wall-stick entry `_try_start_wall_stick_from_contact` (919–942) and landing routing (433–437), wall-run policy `_update_wall_run_state`/`_can_start_wall_run`/`_set_wall_run`/`_get_wall_run_direction`/`_has_wall_run_input_for_direction`/`_clear_wall_run` (867–916), stick lifecycle `_set_wall_stick` (945–980, arms `set_next_frame_velocity_baseline(Vector3.ZERO)`)/`_clear_wall_stick` (983–987)/`_on_grapple_attachment_ended` (1202–1208), submissions `submit_wall_run_base`/`submit_wall_run_constraint`/`submit_wall_jump`/`submit_wall_stick_hold`/`submit_wall_stick_release`/`submit_wall_stick_jump` (674–751), dev views `is_wall_stick_speed_gate_open`/`get_wall_stick_speed_gate_reason_id` (1122–1137). This story: continuity-aware relationship handling in `_update_wall_run_state`/`_set_wall_run` (establish-once run direction), wall-loss exit routing, documented momentum policy. Preserve: entry gates and tuning values, post-commit-only stick entry, single movement commit discipline, read-through diagnostic views.
- `scripts/player_airborne_state.gd` — today: wall-run probing entry point (`_update_wall_run_state` then `EVENT_WALL_RUN_STARTED`). This story: exactly-once entry confirmation (Task 1.2). Preserve: ordering (ground → grapple → wall).
- `game/player/motor/player_motor_submission.gd` — today: `Kind.WALL_RUN_CONSTRAINT` / `Kind.WALL_STICK_HOLD` with factories and `has_valid_wall_constraint_vectors()` (wall normal + horizontal run-direction checks), phase `CONSTRAINTS_AND_REDIRECTIONS`. This story: consume-only unless a documented payload need arises. Preserve: enum order, validation, finiteness checks.
- `game/player/motor/player_motor.gd` — today: sole commit authority; `WALL_STICK_HOLD` dominance in `CONSTRAINTS_AND_REDIRECTIONS` (zeroes working velocity, requests hold position — the single `global_position` write at commit); `WALL_RUN_CONSTRAINT` (horizontal projection onto wall direction + outward removal); `MAXIMUM_ANCHOR_DISTANCE` second pass after redirecting constraints; exclusive-hold frame validation (`EXCLUSIVE_POLICY_CONFLICT`); `INVALID_WALL_CONSTRAINT` isolated status; `set_next_frame_velocity_baseline` seam. This story: no behavior change expected (Task 6.3 guard). Preserve everything, including all motor tests.
- `game/shared/physics/contact_frame.gd` — today: closed value-only schema with `WallProvenance`, `WallRelation`, `ContinuityAction`, wall identity/persistence, `wall_contact_lost`, `wall_probe_query_succeeded` (verified via MCP `find_symbols`). This story: consume-only. Preserve the schema and `is_value_only()` purity.
- `game/player/locomotion/contact/player_contact_provider.gd` + `game/shared/physics/wall_probe.gd` / `wall_probe.tres` — today: combined committed-collision/body-fact/overlap/sweep evidence, deterministic lexicographic wall selection with continuity penalty, continuity machine (`INITIAL`/`PRESERVED`/`SWITCHED`/`LOST`, 2-step loss window), optional-wall-profile fail-safe (`ready_wall_unavailable`). This story: consume-only; do not retune tolerances or selection. Preserve query budget and diagnostics.
- `scripts/player_grounded_state.gd`, `player_grappling_state.gd`, `player_dead_state.gd` — today: `_clear_wall_run()` (and `_clear_wall_stick()` on death) on enter. Preserve; only touch if exit cleanup must be unified (Task 4.1).
- Tests (extend): `tests/player/motor/test_player_motor.gd` (wall constraint/hold/exclusivity semantics), `tests/player/motor/test_player_motor_integration.gd` (real-player-scene wall-run/wall-jump and wall-stick hold/release routes), `tests/player/contact/test_player_contact_contract.gd` (wall facts + source scans), `tests/player/input/test_player_controller_command_sequence.gd` (no-hardware-read scans).

Expected NEW:

- `tests/player/locomotion/test_wall_traversal_contract.gd` (+ `.gd.uid`) — policy/unit coverage: entry gates, establish-once run direction, continuity stability, exit policy table, wall-jump impulse math, stick-loss exit, idempotency.
- `tests/player/locomotion/test_wall_traversal_integration.gd` (+ `.gd.uid`) — the real-Jolt AC 10 matrix incl. 60/120 Hz pairs.
- Optional MCP adapter `tests/test_wall_traversal_mcp.gd` extending `McpTestSuite` (+ `.gd.uid`) — schema/source checks only, never GUT parity.
- Evidence set `_bmad-output/implementation-artifacts/evidence/1-9/`.

Inspect if needed (no changes expected): `game/player/input/player_command_frame.gd` / `player_input_source.gd` (test seams), `game/player/abilities/grapple/*` (interop only; see Story 1.8 locks), `game/shared/physics/physics_query_profile.gd` / `contact_diagnostic_snapshot.gd`, `scripts/debug_grapple_telemetry.gd` (wall gate rows already present; keep read-only/bounded), `tests/player/grapple/*`, `tests/player/motor/test_player_motor_semantic_contract.gd`.

Preserve unchanged: `scenes/player.tscn`, `res://main.tscn`, `project.godot`, `game/shared/physics/*` behavior, `game/player/abilities/grapple/*` behavior, `demo/**`, `addons/**`, `ai/**`, `materials/**`, `scripts/levels/tree_grapple_tutorial.gd` (compiles only; no tutorial rebuild).

### Predecessor and Git Intelligence (Story 1.8 and earlier)

- **Git state at authoring:** HEAD `dbd3289` ("fix: 1.8 review fixes: sample lifecycle, carry-refusal wiring, dual-rate matrix"); Story 1.7 (`9335764`) and 1.8 work are committed and the working tree is clean apart from this authoring output. Recent pattern: implement → review-fixes → mark complete commits per story. Story 1.9 stacks on this tree; never reset/revert predecessor work.
- Story 1.8 (done, review-fixed) delivered: per-step `GrappleAnchorState` sampling, relative-motion maximum-distance boundary with carry rules, append-only typed termination (`TARGET_DESTROYED`, `SCOPE_MISMATCH`, `ANCHOR_DISCONTINUITY`), immutable anchor-motion tolerances (50/250 m/s), read-only sampled-anchor diagnostics. Notably it touched `scripts/player_wall_stick_state.gd` (typed classification before the preserved fallback) and `scripts/player_wall_stick_state.gd`'s sampling discipline — both preserved above.
- Story 1.5 (in `review`) delivered the `ContactFrame`/`PlayerContactProvider`/`WallProbe` authority, continuity machine, and the source scans this story must keep green; Story 1.4 (in `review`) delivered the semantic phases and single-commit transaction. Their review status means: do not assume their story files are final authority — the code and tests are.
- Test idioms established (mirror them): small real-Jolt scenes and the real `scenes/player.tscn` in a `SubViewport` with a real `World3D`; `autofree`; engine-driven physics frames (`await get_tree().physics_frame` and the manual `_physics_process` idiom that integrates `move_and_slide()` with the frame delta); input injection via `input_source.enable_test_input_seam()` + `inject_action_binding(PlayerCommandFrame.Action.…)` / `inject_movement_strengths`; tolerant assertions (velocity drift ≤ 0.05 m/s, position drift ≤ 0.10 m over 60 steps); `delta_seconds = 1.0 / tick_rate`; **always restore `Engine.physics_ticks_per_second` on every exit path**; separate accepted vs duplicate-rejected counters; query-count assertions; source scans for forbidden APIs; physically-possible displacement bounds for no-snap guards.
- Open risks not to widen (recorded by predecessors): lossy overflow accounting in the motor; profile runtime immutability not fully closed (`unlock_for_editor()` callable at runtime); motor init reports `SUCCESS` on an invalid optional wall profile (wall contact correctly degrades to `ready_wall_unavailable`, but the init status is loose — a wall-relevant known P2, fix only if trivially safe and tested); Story 1.5 AC13 evidence gaps (live 120 Hz comparison, wall-loss smoke) partially overlap this story's AC 10 matrix — close what AC 10 requires here and record the rest in `deferred-work.md`. Deferred grapple-pull activation note in `deferred-work.md` (jump-edge gating in `player_grappling_state.gd`) stays out of scope unless it blocks wall interop.
- Sprint bookkeeping: `1-4`/`1-5` sit at `review`; `1-6`–`1-8` are `done`; never infer predecessor completion from automated checks alone (manual smoke sign-off precedent).

### Testing Requirements

- **Dual test harness is mandatory (AGENTS.md):**
  - **GUT (canonical comprehensive regression gate):** pinned Godot CLI recursive runs under `res://tests/player/**` plus focused per-domain runs. Canonical recursive command (Story 1.2 pin): `Godot_v4.7.2-stable_win64_console.exe --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit` (focused: swap `-gdir` for `res://tests/player/locomotion`, `.../motor`, `.../contact`, `.../grapple`). Report scripts/tests/assertions, exit codes, expected invariant diagnostics, unexpected errors, and import/teardown noise separately. Record the pre-change baseline and prove no regressions.
  - **Godot AI MCP (live-session gate):** preflight before editing; MCP-backed Godot-side operations during implementation (script rescan/reload, scene inspection); post-edit rescan + editor diagnostics; launch `res://main.tscn` and smoke wall-run/wall-stick/wall-jump/recovery behavior with `game_eval`/simulated input (`input_sequence` for frame-timed action timelines); inspect MCP logs; record session ID, operations, and results. MCP `test_run` discovers only direct `res://tests/test_*.gd` `McpTestSuite` files and never covers GUT suites — report both separately and claim no parity.
- Real-Jolt integration is required for all wall contact/movement behavior (AC 10 names real Godot/Jolt physics). No fake `move_and_slide()`, no arbitrary sleeps, no exact float equality, no rendered-frame timing, no private node-path coupling, no deep physics mocks, no large tree snapshots, no pixel-perfect screenshot assertions.
- Determinism and equivalence: identical scenarios produce equivalent transitions, velocity policies, and impulse timing at 60 Hz and diagnostic 120 Hz within documented tolerances (NFR4). Wall entry/continuity decisions must be rate-independent.
- Every runtime/visual claim needs reproducible evidence: command or scene, setup and inputs, expected result, plus relevant death/cancellation/exit behavior (NFR21). Claim visual verification only when observed through Godot AI MCP.
- Fix defects with reproduction-focused regression tests; no redundant coverage tests (no percentage targets exist).

### Latest Technical Information

- Pinned engine Godot 4.7.2-stable; no upgrades. Use the 4.7 doc tree for version-specific behavior.
- **Wall detection caveats (engine-wide, still relevant):** `CharacterBody3D.is_on_wall()` / `get_wall_normal()` are velocity-dependent and unreliable when not actively moving into the wall (godotengine/godot#80938; godot-jolt/godot-jolt#758 reports `is_on_wall_only()` misbehavior under Jolt). This validates the project design: wall facts come from the `ContactFrame`'s combined committed-collision + overlap + swept-probe evidence, never from a raw `is_on_wall()` read. Do not "simplify" wall detection back to body flags.
- `wall_min_slide_angle` (default ≈ 15°) and `floor_block_on_wall` affect `move_and_slide()` sliding; wall-run constraints resolve in velocity space before the commit, so do not fight the engine slide rules with extra post-commit corrections.
- `CharacterBody3D` semantics: `velocity` is m/s modified by `move_and_slide()`; call it from `_physics_process()`; `get_real_velocity()` is post-slide while `velocity` is requested motion — keep diagnostics explicit about which basis they report.
- Physics interpolation (project-wide, enabled): direct transform writes outside the physics step cause jitter. The wall-stick hold position write happens inside the motor's single commit (the established contract); do not add new transform writes for wall behavior, and keep the frozen rope `reset_physics_interpolation()` discipline untouched.
- Jolt Physics: tolerant numeric assertions; stable tolerances over exact equality; swept/velocity-aware reasoning for high-speed wall approaches (NFR6).

### Story-Authoring Godot AI MCP Evidence

- **Run (read-only) for this authoring pass.** MCP session `testgame@e362124f09f388c2` (project `testgame`, Godot 4.7.2-stable official, plugin/server 4.0.4, protocol 2): `session_manage(list)` → one active session, readiness `ready`, play state `stopped`, current scene `res://main.tscn`; `editor_state` → ready/stopped, `game_status.status = stopped`. `script_manage(find_symbols)` of `res://scripts/player_wall_run_state.gd` (`LimboState`, `_update` at line 4, `_exit` at line 46), `res://scripts/player_wall_stick_state.gd` (`LimboState`, `_update` at line 4), and `res://game/shared/physics/contact_frame.gd` (`ContactFrame`, `RefCounted`, value-only API incl. `failure`/`is_value_only`) — confirming the Current-State Update Map above.
- **Editor-log triage (MCP-observed):** `logs_read(source="editor")` shows the same historical parse-error ring-buffer entries Stories 1.7/1.8 recorded (`player_contact_provider.gd` "Expected statement, found Indent" cascade into `test_player_contact_contract.gd`) plus `test_grapple_targeting_mcp.gd` placeholder-instance errors from prior MCP test runs. These are stale mid-edit/ring-buffer history and MCP-runner artifacts — not current defects (Story 1.8 verification was green against this tree). Do not mistake them for damage caused by this story's work.
- No gameplay state was mutated and no scene/resources were edited during authoring. The dev-story agent must run its own full MCP preflight/implementation/validation cycle per AGENTS.md and record results separately from CLI evidence.

### Project Structure Notes

- Wall traversal policy lives in legacy `scripts/` (controller + LimboState scripts) while its contracts live in `game/player/motor/`, `game/player/locomotion/contact/`, and `game/shared/physics/` — the Story 1.6–1.8 variance precedent applies: integrate in place, do not bulk-move, record variance.
- Tests mirror runtime domains: new wall suites under `tests/player/locomotion/` (mirroring `game/player/locomotion/`) are the recommended placement; shared fixtures stay out of `tests/fixtures/` unless multiple suites need them.
- Incremental, Godot-aware migration only: preserve UIDs, update `.tscn`/`.tres` dependencies, verify affected scenes, remove superseded code only after its replacement works.

### Project Context Rules

Extracted from `_bmad-output/project-context.md` (91 rules; the following bind this story):

- **Engine/authority:** authoritative gameplay advances in `_physics_process(delta)`; only `PlayerMotor` writes final velocity or calls `move_and_slide()`, exactly once per physics step; fixed semantic phases (terminal commands → state gating → base locomotion/gravity → sustained influences → one-shot impulses → constraints and redirections → caps and commit); never settle precedence by scene-tree order or numeric priorities.
- **Contact authority:** one shared authoritative `ContactFrame` per physics step for ground and wall interpretation; movement states consume it instead of competing queries; broad eligibility is the named collision matrix, query meaning is immutable `PhysicsQueryProfile`/`WallProbe` Resources.
- **Input authority:** immutable `PlayerCommandFrame` is the sole gameplay input boundary; movement/ability states never poll hardware input; short press/release edges latch; focus loss clears held input.
- **Definitions:** immutable authored Resources during play (tuning lives in `.tres`/scene-exported baselines, not scattered constants); per-occurrence state is owner-local; no live-tuning framework. Wall tuning is A-002/OD-009 baselines — do not silently retune.
- **Contracts:** commands/queries are direct typed methods; typed signals report committed past-tense facts synchronously; expected rejection uses compact typed reason enums and is never logged as errors.
- **Layout:** `game/player/` for input/motor/locomotion/abilities; `game/shared/physics/` + `game/shared/contracts/` only for genuinely cross-domain types; tests mirror domains under `tests/`. `snake_case`/`PascalCase`/`UPPER_SNAKE_CASE`; units in names; stable lowercase dotted IDs.
- **Testing:** GUT 9.7.1 with the pinned recursive headless command; mandatory contract coverage includes motor commit and influence ordering, 60/120 Hz equivalence, one terminal result, idempotent termination, and input-edge latching; small real-Jolt integration scenes; reproducible evidence; deterministic stepping; tolerant numeric assertions.
- **Platform/build:** Windows x86-64, Forward+ (D3D12), Jolt; Godot 4.7.2-stable pinned; keyboard and mouse only; no secondary-platform or controller work.
- **Presentation:** `_process` is presentation/smoothing/UI only; presentation consumes read-only snapshots and committed signals; missing presentation degrades but never blocks valid simulation.
- **MCP/tooling:** Godot AI MCP is mandatory for Godot work (preflight, implementation operations, validation) per repository AGENTS.md, with GUT as the canonical regression gate and MCP as the complementary live gate; record both separately with the MCP session ID.

### References

- Story source of truth: `_bmad-output/planning-artifacts/epics/epic-01-story-09.md` (all 10 acceptance criteria transcribed above). Epic context: `epic-01-overview.md` (FR2–FR12).
- Architecture: "Player state" (movement HSM owns wall-running/wall-sticking); "Motion Authority and Effect Precedence" (seven phases; wall behavior submits influences); "Collision Matrix and Query Profiles" (`WallProbe`, one shared `ContactFrame`, states do not repeat competing wall queries); "Semantic Motor Influence Pipeline" (typed phase submissions, single commit, one-shot identities); "Movement and impact context" (`locomotion_state_id`, `wall_contact_normal`); "Cross-System Contract Specifications" -> "Grapple target contract"; "Lean AI-First Verification and Instrumentation"; "Setup and Verification Commands"; "Naming Conventions". [Source: `_bmad-output/planning-artifacts/architecture.md`]
- GDD: Pillar 1 (traversal vocabulary); Movement Feel Table rows "Wall-run contact (≥1 m/s horizontal; wall within 0.8 m; ~12° of vertical)", "Wall-run acceleration (4 m/s²)", "Wall jump (8 m/s outward; 5.5 m/s upward)"; controls table (Space = ground jump or context-valid wall jump); M0 traversal-route gate; Beginner/M0 recovery expectation ("Ordinary misses expose recovery routes"); FR4/FR5/FR11/FR12 rows; OD-009 (unresolved tuning approval), A-002 (validation baselines). [Source: `_bmad-output/planning-artifacts/gdd.md`]
- Requirements: FR2, FR3, FR4, FR5, FR11, FR12 (primary set for this story); NFR3, NFR4, NFR5, NFR6, NFR7, NFR10, NFR15, NFR20, NFR21. [Source: `_bmad-output/planning-artifacts/epics/requirements.md`]
- Frozen intent: `_bmad-output/implementation-artifacts/spec-grapple-visual-interpolation-reset.md` (preserve; ask-first boundaries above).
- Deferred items: `_bmad-output/implementation-artifacts/deferred-work.md`.
- Predecessor records: `1-8-grapple-moving-and-stateful-targets-safely.md` (sampling/termination locks, test idioms, evidence layout), `1-7-…`, `1-6-…` (targeting locks), `1-5-…` (ContactFrame authority, continuity machine, source scans), `1-4-…` (semantic phases, outer transaction).
- Current-state sources read at authoring: `scripts/player_wall_run_state.gd`, `scripts/player_wall_stick_state.gd`, `scripts/player_controller.gd` (wall sections), `game/player/motor/player_motor.gd` / `player_motor_submission.gd` (wall kinds), `game/shared/physics/contact_frame.gd`, `game/player/locomotion/contact/player_contact_provider.gd`, `game/shared/physics/wall_probe.gd`, MCP-observed editor state/symbols/logs (see Story-Authoring Godot AI MCP Evidence).
- Engine docs/issues: `CharacterBody3D` wall-detection caveats (godotengine/godot#80938, godot-jolt/godot-jolt#758), `wall_min_slide_angle` semantics (Latest Technical Information).

### Source References and Artifact Ledger

Bounded resolver context pack: `_bmad-output/.artifact-index/context-1-9.json` (6 files; `inventory_valid: true`; warning: GDD `status: 'needs-decisions'` is permitted for scoped story 1.9 — never present any milestone as acceptance-ready). Artifact IDs and revisions (SHA-256) used to create this story:

| Artifact ID | Path | SHA-256 (revision) |
|---|---|---|
| `grapplegame.epics.requirements` | `_bmad-output/planning-artifacts/epics/requirements.md` | `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b` |
| `grapplegame.epics.1` | `_bmad-output/planning-artifacts/epics/epic-01-overview.md` | `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168` |
| `grapplegame.story.1.9` | `_bmad-output/planning-artifacts/epics/epic-01-story-09.md` | `683d883b4f6691b98038c4e78d00180fa7c844bfad1ce2024a6e16e1e7bd691f` |
| `grapplegame.gdd` | `_bmad-output/planning-artifacts/gdd.md` | `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156` |
| `grapplegame.architecture` | `_bmad-output/planning-artifacts/architecture.md` | `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080` |
| `grapplegame.project-context` | `_bmad-output/project-context.md` | `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97` |

- Epics manifest revision: `epics_manifest_sha256 = 8a0a51a1d4915b4aa75a7f96a427d03200a2fe0b4538ac061c9ab19afe045d15` (source `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71`).
- `grapplegame.decision-log` (`_bmad-output/planning-artifacts/decision-log.md`, digest `01454eb5...72a00` per project-context frontmatter) is an optional input and was referenced by digest only, not loaded into this bounded pack.
- GDD scope note (resolver warning, permitted): GDD `status: 'needs-decisions'` with `implementation_scope_ready: 'M0 implementation-start only; no milestone is acceptance-ready'` — allowed for epic-1 story scopes.
- Continuity references: `1-8-grapple-moving-and-stateful-targets-safely.md`, `1-7-…`, `1-6-…`, `1-5-…`, `1-4-…`, `deferred-work.md`, `spec-grapple-visual-interpolation-reset.md` (frozen), `evidence/1-3..1-8/`.
- Godot AI MCP authoring session: `testgame@e362124f09f388c2` (read-only evidence above).

### Story Completion Status

- Status: `ready-for-dev` — ultimate context-engine analysis completed (2026-09-25): 10 acceptance criteria, 10 task groups, continuity-aware wall-relationship contract, momentum-policy disclosure requirement, single-impulse wall-jump contract, grapple-assisted wall-stick contract with the missing wall-loss exit identified, interoperability and recovery scope guard, real-Jolt 60/120 Hz verification matrix, current-state update map, and MCP/AGENTS.md guardrails. Story key `1-9-integrate-wall-traversal-and-mistake-recovery`.

## Dev Agent Record

### Agent Model Used

MiMo-V2.6-Pro (OpenCode) authored the story and began dev-story implementation; GPT-6 Sol (OpenCode) completed the integration matrix, live validation, and story record.

### Implementation Plan

- Preserve the existing one-command/one-HSM/one-motor-commit pipeline. Extend only the wall-policy consumers of the published `ContactFrame`: guard stale/unavailable/lost frames, establish the run relationship at entry or a deliberate switch, preserve it on continuity, and validate the current relationship before a wall jump.
- Keep the existing motor influence kinds, phase order, wall-stick hold implementation, grapple sampling, attachment terminal funnel, tuning resources, and scene UIDs. Add the missing wall-stick loss exit with `STATE_CANCELLATION` and a zero-rate velocity passthrough.
- Test policy in GUT contract fixtures, wall behavior against the actual player scene and Jolt at 60/120 Hz, and runtime interop through Godot AI MCP. Keep the complete authored recovery route assigned to Story 1.10.

### Debug Log References

- Evidence index: `_bmad-output/implementation-artifacts/evidence/1-9/verification.md`; full raw logs in the same directory. Planning digests matched the story ledger. Baseline GUT 177/177 tests, 9,724 assertions; final focused GUT 33/33 tests, 487 assertions; final recursive GUT **210/210 tests, 10,223 assertions, exit 0** (`recursive-gut-final.log`). Pinned headless editor import exit 0 with only teardown resource/RID noise; `git diff --check` exit 0. Earlier integration logs document red/green and matrix corrections; the lost-wall jump regression is explicitly red at both rates in `task5-stale-wall-jump-red.log` and green in the final focused log.
- Godot AI MCP session **`testgame@e362124f09f388c2`** (Godot 4.7.2; Godot AI 4.0.4): `session_manage(list)`, `editor_state`, `script_manage(find_symbols)`, `scene_open`/`scene_get_hierarchy`, `filesystem_manage(scan)`, `project_run(main)`, `game_manage(get_scene_tree/input_sequence)`, `editor_manage(game_eval)`, `logs_read(editor/game)`, `test_run`, and stop/recheck. MCP observed live wall-run → wall jump → airborne steering/accepted target and grapple-assisted stick → hold → wall loss → airborne with typed reason; after the final guard edit a fresh live run observed lost-wall+jump yielding **no impulse**, retained x velocity, one commit, and airborne recovery. Fresh game log had no errors/warnings, no new editor entries after cursor 117, final editor ready/stopped with `res://scenes/player.tscn` loaded. MCP-native grapple adapters: **15/15**, with preload-cache warning; they are not GUT coverage. Two scratch `game_eval` harness errors were recovered with relaunch; details in `verification.md`.

### Code Review Validation (2026-09-26)

- Review used the uncommitted Story 1.9 diff against `dbd3289`, the story ACs, three independent review layers, and the active Godot AI MCP session **`testgame@e362124f09f388c2`**. MCP preflight found the editor ready/stopped on `res://scenes/player.tscn`; `scene_get_hierarchy`, `node_get_properties`, and `script_manage(find_symbols)` confirmed the player, motor, movement HSM, attached wall-state scripts, controller, and integration suite. `filesystem_manage(scan)` settled with 128 global classes; `logs_read(source="editor", since_cursor=117)` found no new editor diagnostics.
- **Independent CLI/GUT gate:** pinned Godot 4.7.2 recursive `-gdir=res://tests/player -ginclude_subdirs -gexit` exited **0**, 15 scripts, **210/210 tests**, 10,223 assertions; expected negative-test diagnostics and pre-existing exit-time ObjectDB/resource noise remained. This is separate from MCP observation.
- **MCP runtime gate:** `project_run(main)` opened a live `/Main/World/Player`; `game_manage(get_scene_tree)` and `game_manage(input_sequence)` confirmed the runtime tree and delivered a 19-frame movement/jump timeline. Three in-memory real-Jolt `SubViewport` fixtures via `editor_manage(game_eval)` reproduced review findings: (1) after wall loss was reported while sticking, jump still submitted `player.jump.wall` and `(10, 5.5, 8)` m/s with one motor commit; (2) a 180° mouse-look rotation with an unchanged supported wall produced `wall_contact_lost` and ended the grapple/stick after four steps; (3) removing wall A beside supported wall B produced `SWITCHED`, but the hold stayed active and retained wall A's cached `(0, 0, 1)` normal while the frame selected wall B's `(-1, 0, 0)` normal. The final live run had no game warnings/errors and no editor log entries after cursor 117. A scratch `game_eval` compile error in an earlier run (untyped local variable in the review fixture) paused that run; MCP stop/relaunch recovered it before the successful fixtures. `project_manage(stop)` and `editor_state` ended ready/stopped with the affected scene loaded. No visual verification is claimed.

### Review Fix Completion (2026-09-26)

- All nine review patches applied. The wall provider now reserves one of its existing four stationary probe directions for the last selected wall, independent of camera yaw; no query-count, tolerance, or selection-policy changes were made. The stick state checks required wall support before jump, and a `SWITCHED` relationship (or mismatch of persistent wall identity) ends the old hold through the existing idempotent `STATE_CANCELLATION` path. The provider change is a narrow review-driven exception to the authoring update map's original consume-only expectation; it does not change the motor hold mechanism or frozen-spec boundaries.
- New real-Jolt regression scenarios run at both 60 and 120 Hz for lost-wall plus jump, camera rotation, and selected-wall switch. Existing tests now assert uninterrupted shallow-corner traversal, actual controller jump vectors and above-target handoff momentum, a responding recovery command, exit velocity, and the exact destroyed-anchor terminal. The supported-corner fixture was extended from 1.3 to 1.45 seconds to cross the second face at both rates before its far cap; a shorter intermediate run failed the newly tightened 60 Hz crossing assertion, then the adjusted focused run passed.
- **CLI/GUT canonical gate (after fixes):** pinned Godot 4.7.2 focused `res://tests/player/locomotion` **37/37 tests, 594 assertions, exit 0**; pinned recursive `res://tests/player` **214/214 tests, 10,330 assertions, exit 0** (15 scripts). Pinned `--headless --editor --path . --quit` import/load exited **0**, editor-layout ready. Pre-existing teardown RID/ObjectDB/resource messages remain; no test failures or parse errors. `git diff --check` passed after changes. Raw review-fix logs are indexed in `evidence/1-9/verification.md`.
- **Godot AI MCP live gate (separate from GUT):** active session **`testgame@e362124f09f388c2`**; fresh `session_manage(list)`, `editor_state`, `scene_get_hierarchy`, `script_manage(find_symbols)` preflight was ready/stopped on `res://scenes/player.tscn`, with no new editor diagnostics after cursor 117. `filesystem_manage(scan)` settled with 128 classes after edits and again after tests. `scene_open(main)` + `test_run` passed **15/15 across three existing top-level grapple adapters** with a preload-cache warning; these are not wall GUT tests or parity evidence. A fresh `project_run(main)` launched live `/Main/World/Player`; MCP `game_eval` real-Jolt fixtures observed the 180° turn keep the still-present wall and grapple active for eight steps with one commit/step and no lost frame, the A→B `SWITCHED` frame end the old stick (normal A `(0,0,1)`, selected B `(-1,0,0)`), and lost-wall plus jump produce **no wall impulse**, `STATE_CANCELLATION` (4), and one commit. `game_manage(input_sequence)` delivered a 19-frame movement/jump timeline; `logs_read(game)` for that run contained only main-scene informational damage/death lines, zero warnings/errors; `logs_read(editor, since_cursor=117)` returned no entries. `project_manage(stop)`, `scene_open(player)`, and final `editor_state` observed ready/stopped with the player scene loaded. No visual verification is claimed.

### Completion Notes List

- Wall run consumes the authoritative contact frame (including step freshness, probe availability, continuity/loss, identity, normal) without extra collision or hardware-input reads. Initial contact and `SWITCHED` establish a deterministic tangent and identity once; `PRESERVED` holds normal, identity, and run direction. The authored 25°/0.2 m/2-step continuity parameters and entry/input gates were not retuned.
- **Momentum policy:** entry passes through the incoming velocity. Subsequent wall-run base motion aims for 10 m/s along the selected wall at the authored 4 m/s², so faster useful incoming tangential speed decelerates gradually (16 m/s → 15.9333 m/s on one 60 Hz step) rather than snapping; the constraint retains tangential travel and removes outward velocity, and the existing zero-vertical/gravity policy remains in its motor phase. `MAXIMUM_ANCHOR_DISTANCE` still resolves after wall redirection. No motor behavior or hold mechanism changed (Task 6.3 guard satisfied).
- **Wall-run exit policy:** landing dispatches `EVENT_LANDED` and grounds from the post-commit contact frame; genuine loss, stale/unavailable contact, or failed input clears the wall and passes through committed velocity to airborne; accepted grapple press clears wall state and transitions once to grappling; valid wall jump uses current wall facts and submits one `SOURCE_JUMP_WALL`/`COMMAND_JUMP_PRESSED` occurrence impulse before transitioning airborne; death clears wall state and dispatches `EVENT_DIED`. Pressing jump on the first lost-wall frame now takes the ordinary airborne loss exit, with retained velocity and **no stale impulse**. Wall-jump clear-before-submit and exit dispatch remain explicit even if a duplicate occurrence is rejected; holding jump cannot reapply it.
- Wall sticking remains grapple-assisted, entered once after a committed eligible wall contact. Its exclusive `WALL_STICK_HOLD` submission is a motor constraint and its zero-velocity baseline and per-step anchor sample remain intact. Release uses `RELEASE`; attachment destruction uses the existing typed invalidation; required-wall loss uses **`STATE_CANCELLATION`**; death uses `OWNER_DEATH`. Non-jump exits use the zero-rate base passthrough; the motor drops the hold after the exit. The terminal signal fires once on the first committed termination, with `_clear_wall_stick()` already applied when subscribers see it; repeated termination returns the same terminal without another signal.
- **Jump asymmetry retained:** a wall-run jump uses the positive projected along-wall reference component, while a wall-stick jump uses the full authored `wall_stick_run_direction * wall_run_speed`; both add 8 m/s away and 5.5 m/s up via the one-shot impulse (desired minus reference). Recovery cases verify actual miss/exit/release/jump transitions with a remaining surface, accepted target, or responsive air control and no automatic level restart. The complete recovery route remains Story 1.10.
- Naming/placement variance: wall policy stays in the established legacy `scripts/` controller and LimboState files; the new suites mirror locomotion under `tests/player/locomotion/`. No UIDs, scene resources, grapple targeting, motor formulas, tutorial, or frozen visual-interpolation specification were changed.

### File List

- `game/player/locomotion/contact/player_contact_provider.gd` (review fix: stationary probe retains selected wall without increasing query count)
- `scripts/player_controller.gd`
- `scripts/player_wall_run_state.gd`
- `scripts/player_wall_stick_state.gd`
- `tests/player/locomotion/test_wall_traversal_contract.gd`
- `tests/player/locomotion/test_wall_traversal_contract.gd.uid`
- `tests/player/locomotion/test_wall_traversal_integration.gd`
- `tests/player/locomotion/test_wall_traversal_integration.gd.uid`
- `_bmad-output/.artifact-index/context-1-9.json` (pre-existing story-authoring context pack carried in this working tree)
- `_bmad-output/implementation-artifacts/1-9-integrate-wall-traversal-and-mistake-recovery.md`
- `_bmad-output/implementation-artifacts/sprint-status.yaml`
- `_bmad-output/implementation-artifacts/evidence/1-9/verification.md`
- `_bmad-output/implementation-artifacts/evidence/1-9/pre-change-oracle-raw.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/recursive-gut-pass1.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/recursive-gut-final.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/pinned-import-final.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/task10-contract-pass1.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/task10-contract-pass2.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/task10-integration-pass1.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/task10-integration-pass2.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/task5-stale-wall-jump-red.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/task5-stale-wall-jump-green.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/review-fix-corner-red.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/review-fix-focused.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/review-fix-recursive.log`
- `_bmad-output/implementation-artifacts/evidence/1-9/review-fix-import.log`

### Change Log

- 2026-09-25: Story 1.9 "Integrate Wall Traversal and Mistake Recovery" context created from the bounded resolver pack (6 artifacts, digests recorded above). Comprehensive dev guide: 10 acceptance criteria, 10 task groups, continuity-aware wall-relationship contract consuming the currently publish-only `ContactFrame` wall facts (identity/provenance/relation/continuity/loss), establish-once deterministic run direction, explicit exit-policy and single-occurrence wall-jump contracts, grapple-assisted wall-stick hold expressed through the motor constraint phase with the missing wall-contact-loss exit identified, traversal interoperability audit, mistake-recovery scope guard (complete route deferred to Story 1.10), real-Jolt 60/120 Hz verification matrix, current-state update map, and frozen-spec/MCP/AGENTS.md guardrails. Status: ready-for-dev.
- 2026-09-26: Integrated continuity-aware wall policy and required-wall-loss stick exit; guarded wall jump against a stale lost wall; added 19 contract and 14 real-Jolt integration tests, 60/120 Hz comparison, dual-harness runtime evidence, and full recursive regression results. Ready for review.
- 2026-09-26: Review-fix pass completed all nine findings; stationary wall detection survives camera rotation, wall-stick jump rejects lost contact, and a wall switch ends the old hold. Strengthened acceptance assertions and added three dual-rate real-Jolt regressions. Final focused 37/37, recursive 214/214, MCP-native grapple 15/15, and three fresh MCP runtime smoke outcomes recorded above. Status: done.
