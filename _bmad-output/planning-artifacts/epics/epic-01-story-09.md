---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.9'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 9
---

# Story 1.9: Integrate Wall Traversal and Mistake Recovery

As a player,
I want wall running, wall sticking, wall jumping, and recovery movement to connect cleanly with my other traversal abilities,
So that I can use walls confidently and recover from ordinary mistakes without losing control or restarting the level.

**Acceptance Criteria:**

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
