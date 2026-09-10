---
artifact_schema: 1
artifact_id: 'grapplegame.story.1.10'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 1
story: 10
---

# Story 1.10: Complete the Focused Traversal Validation Route

As a player,
I want a short, readable route that asks me to use the complete traversal vocabulary and provides recovery opportunities,
So that I can demonstrate movement mastery without ordinary mistakes forcing a full restart.

**Acceptance Criteria:**

1. **Create a focused route from primitive content**

   **Given** the current tree-grapple tutorial is disposable prototype content
   **When** the M0 validation route is created
   **Then** it may be recreated from scratch using simple geometry, lightweight markers, and the production player and traversal systems
   **And** no existing tutorial layout, lesson sequence, script, identifier, or scene dependency must be preserved
   **And** `res://main.tscn` remains a runnable launch path.

2. **Exercise the complete traversal vocabulary**

   **Given** the player starts the route
   **When** they progress from its start to its finish
   **Then** the route provides deliberate opportunities requiring ground movement, air steering, jumping, grapple acquisition, zip-pull, momentum-preserving grapple release, wall running, grapple-assisted wall sticking, wall jumping, and mistake recovery
   **And** completion does not depend on combat, damage, enemies, an encounter controller, rewards, or checkpoint infrastructure.

3. **Use production traversal contracts**

   **Given** the route needs a player, walls, grapple surfaces, and exceptional grapple targets
   **When** those elements are composed
   **Then** they use the production `PlayerCommandFrame`, motor, `ContactFrame`, grapple targeting, `GrappleAttachment`, and locomotion-state contracts from Stories 1.2–1.9
   **And** the route does not contain private movement calculations, duplicate physics queries, direct player-velocity writes, or route-specific copies of core traversal tuning.

4. **Demonstrate the true grapple boundary**

   **Given** the route includes near-range, boundary-range, and out-of-range grapple opportunities
   **When** the player aims, attaches, moves inward or tangentially, and attempts to move beyond the active boundary
   **Then** acquisition and attachment use the same validation `GrappleDefinition` with a 35-metre maximum
   **And** the route demonstrates that attachment distance does not become tether length, movement remains free inside the boundary, and only excess outward separation is constrained.

5. **Demonstrate a moving grapple target**

   **Given** the route includes one primitive moving or rotating `Grappleable3D` target
   **When** the player attaches to it
   **Then** the attachment follows the target-local hit position, responds to continuous target motion, and pulls the player only when its retreat makes the tether taut
   **And** the route provides a safe way to observe or recover from target invalidation or a configured severe discontinuity.

6. **Demonstrate wall traversal on representative geometry**

   **Given** the route includes supported non-flat walls, an oblique wall, and a stable corner or adjacent-face transition
   **When** the player uses wall running, wall sticking, and wall jumping
   **Then** authoritative wall classification and movement transitions remain stable
   **And** floor-like, ceiling-like, and otherwise unsupported surfaces do not behave as valid walls.

7. **Provide local mistake recovery**

   **Given** the player misses an intended grapple, releases early, loses a wall run, or undershoots a wall jump
   **When** they fall into the corresponding recovery area
   **Then** a lower route, reachable surface, grapple opportunity, or remaining movement option lets them return to the route without reloading the level
   **And** only leaving the deliberately bounded playable area may use the existing safe restart behavior
   **And** this does not introduce the production checkpoint or level-restart systems assigned to Epic 7.

8. **Communicate route affordances with minimal presentation**

   **Given** the player approaches a route challenge
   **When** the intended surface, target, movement direction, success state, or rejection state needs clarification
   **Then** primitive geometry, high-contrast materials, concise in-world labels or markers, and the existing authoritative grapple feedback make the relevant fact understandable
   **And** presentation observes production simulation results rather than defining success, target validity, or movement timing
   **And** this story does not define the production HUD reserved for Epic 7.

9. **Verify end-to-end traversal at both physics rates**

   **Given** the route's deterministic validation command source or automated scene test drives representative traversal sequences through real Godot/Jolt physics
   **When** the same scenarios run at shipping 60 Hz and diagnostic 120 Hz
   **Then** action durations, state-transition order, grapple-release velocity, maximum attachment distance, moving-anchor behavior, wall transitions, and final route outcomes remain equivalent within documented tolerances
   **And** assertions use elapsed seconds and tolerant physical comparisons rather than raw tick counts or exact floating-point equality.

10. **Capture repeatable M0 evidence**

    **Given** automated validation has passed
    **When** the route is manually completed at 60 Hz and sampled again at diagnostic 120 Hz
    **Then** the evidence records the engine version, repository revision and working-tree state, launch and test commands, route scene, physics rates, actions exercised, observed recovery attempts, results, tolerances, and relevant logs
    **And** no new parse, missing-resource, scene-load, runtime error, or gameplay-critical warning remains unexplained.

11. **Close the Epic 1 completion gate**

    **Given** Stories 1.1–1.10 are complete
    **When** the permanent contract suite, focused real-Jolt tests, route validation, launch-scene smoke test, retained UID/reference check, and working-tree review are performed
    **Then** the player can complete the focused route using the full traversal vocabulary, understand relevant success and failure states, and recover from ordinary mistakes
    **And** traversal is equivalent in real time at 60 Hz and 120 Hz within documented tolerances
    **And** the story has not added combat, hostile surface mechanics, the production encounter or checkpoint shell, final HUD, final art, final audio, or unrelated migration.
