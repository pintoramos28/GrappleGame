# Epic 1 Context: Master Expressive Traversal

<!-- Compiled from planning artifacts. Edit freely. Regenerate with compile-epic-context if planning docs change. -->

## Goal

Epic 1 delivers a focused vertical traversal route in which the player can move responsively on the ground and in the air, jump, grapple, preserve momentum through release, wall-run, wall-stick, wall-jump, and recover from ordinary mistakes.

## Stories

- Story 1.1: Verify and Protect the Playable Traversal Baseline
- Story 1.2: Deliver Reliable Fixed-Step Player Commands
- Story 1.3: Centralize the Player's Physics-Step Movement Commit
- Story 1.4: Resolve Traversal Through Semantic Motor Phases
- Story 1.5: Share Authoritative Ground and Wall Contact Facts
- Story 1.6: Acquire Grapple Targets Consistently
- Story 1.7: Zip-Pull Within a True Maximum Grapple Boundary
- Story 1.8: Grapple Moving and Stateful Targets Safely
- Story 1.9: Integrate Wall Traversal and Mistake Recovery
- Story 1.10: Complete the Focused Traversal Validation Route

## Requirements & Constraints

The target is Windows PC with keyboard and mouse in Godot 4.7.2 using Jolt physics. The player consumes one immutable command frame per authoritative physics step. Traversal preserves useful momentum across ground, air, grapple, wall, attack, displacement, and recovery transitions without silently retuning authored values. The focused route must cover ground movement, air control, jumping, grappling, wall traversal, and recovery. Grapple behavior remains acceleration-based and momentum-preserving, with one authored maximum-range boundary. Failures use typed results or invariant diagnostics and leave partially configured gameplay safely inactive. Scene and resource UIDs, the retained launch path, and existing input behavior must remain intact.

## Technical Decisions

One kinematic `PlayerMotor` owns final player velocity and the single `move_and_slide()` call per 60 Hz physics step. Typed commands flow down ownership boundaries; committed typed facts flow back up. Locomotion states calculate provisional motion but do not write authoritative body state. Gameplay simulation owns timing, motion, and outcomes; presentation and diagnostics remain observational. Runtime state stays local to its owner, authored resources remain immutable, and no global mutable gameplay store or subscriber-order movement is introduced. Verification uses pinned GUT tests plus small real-Jolt integration fixtures with controlled stepping and tolerant numeric assertions. Story 1.3 establishes the one-commit boundary; semantic influence phases and shared contact classification belong to later stories.

## UX & Interaction Patterns

The retained controls are W/A/S/D movement, Space jump, right mouse grapple, left mouse or F attack, Esc cursor release, and mouse-click recapture. The player should experience responsive momentum-preserving traversal through a readable vertical route. Camera, aim presentation, VFX, audio, and UI consume authoritative gameplay facts but cannot move the player or make independent gameplay decisions.

## Cross-Story Dependencies

Story 1.1 supplies the accepted traversal baseline and its documented limitations. Story 1.2 supplies the immutable fixed-step command boundary used by movement and attack HSMs. Story 1.3 centralizes the movement commit without changing semantic influence ordering. Story 1.4 introduces those motor phases, and Story 1.5 introduces shared authoritative contact facts. Stories 1.6-1.9 extend grapple and wall behavior; Story 1.10 validates the complete route.
