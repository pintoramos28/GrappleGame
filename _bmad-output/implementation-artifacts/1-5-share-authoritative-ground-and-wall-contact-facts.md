---
baseline_commit: 2c9f8af3d151bebaf72e513e938c1407ad660ec0
context_pack: _bmad-output/.artifact-index/context-1-5.json
---

# Story 1.5: Share Authoritative Ground and Wall Contact Facts

Status: ready-for-dev

<!-- Story 1.5 replaces transitional state/controller-local floor and wall interpretation with one typed ContactFrame per committed physics step. It depends on the current Story 1.4 semantic-motor working tree, preserves traversal tuning and the runnable baseline, and does not redesign grapple targeting or range. -->

## Story

As a player,
I want ground and wall contact interpreted consistently across every traversal state,
so that landing, wall running, wall sticking, and wall jumping remain reliable on varied geometry and at high speed.

## Acceptance Criteria

1. **Publish one authoritative contact frame per committed physics step**
   - **Given** the player completes a valid motor step
   - **When** the motor has committed movement and the contact owner evaluates body facts, bounded committed collisions, and the configured ground/wall probes
   - **Then** it publishes exactly one immutable `ContactFrame` for that physics-step identity
   - **And** grounded, airborne, grappling, wall-running, and wall-sticking behavior consume that shared interpretation rather than producing competing facts.

2. **Expose a typed, bounded, value-only contract**
   - **Given** a locomotion consumer receives a `ContactFrame`
   - **When** it reads contact state
   - **Then** the closed minimum frame schema exposes: `physics_step`; typed `origin` and `status`; `is_grounded`, `has_ground_surface`, ground normal/identity/provenance; `has_wall_contact`, selected wall normal/identity/provenance/relation; continuity action; bounded typed candidate and rejection summaries; and scanned, reported, query, rejected, and overflow counts
   - **And** it exposes no untyped dictionary, mutable engine array, `Node`, `PhysicsBody3D`, `KinematicCollision3D`, query object, or other live engine reference.

3. **Confine engine contact access to the motor/contact boundary**
   - **Given** Story 1.5 migration is complete
   - **When** controller and movement-state source is audited
   - **Then** states and controller policy code do not call `is_on_floor()`, `is_on_wall()`, enumerate slide collisions, issue ground/wall rays or shape casts, filter wall eligibility by concrete node class, or independently reinterpret contact normals
   - **And** direct engine body/collision/query access exists only inside the bounded motor/contact provider boundary; current grapple-target ray logic remains a separately scoped exception and is not presented as contact-frame ownership.

4. **Configure broad eligibility and query meaning explicitly**
   - **Given** contact sampling is initialized
   - **When** the contact owner resolves its dependencies
   - **Then** broad eligibility comes from named 3D collision layers in `project.godot`, while ground and wall meaning comes from scene-wired immutable typed `GroundProbe` and `WallProbe`/`PhysicsQueryProfile` Resources under `game/shared/physics/`
   - **And** current numeric layer/mask behavior is preserved without magic bitmasks, dynamic resource paths, mutable shared Resources, or a universal `StaticBody3D` requirement.

5. **Share one stable ground interpretation**
   - **Given** the player is supported by flat ground or an allowed slope
   - **When** the current post-commit frame is published and then consumed by transition coordination and the next pre-commit locomotion evaluation
   - **Then** every locomotion consumer observes the same grounded fact and stable ground normal/identity for that frame
   - **And** landing and leaving-ground transitions each occur coherently once without a second query or contradictory state-local result.

6. **Classify walls without absorbing traversal policy**
   - **Given** one or more non-flat surface candidates are detected
   - **When** the contact owner classifies and selects a wall relationship
   - **Then** floor-like and ceiling-like normals are rejected consistently and a valid selected wall normal/identity/relation is exposed to wall-run, wall-stick, and wall-jump policy
   - **And** wall speed, entry velocity, input alignment, gravity, jump strength, activation, and exit tuning remain owned by the traversal layer and are not retuned by the contact provider.

7. **Select deterministically at corners and irregular geometry**
   - **Given** committed collisions and probes report duplicate, adjacent, or competing wall candidates
   - **When** candidates are normalized, classified, deduplicated, scored, and selected
   - **Then** the implementation uses one documented lexicographic geometric score and a stable value-based tie-break
   - **And** the selected result cannot depend on slide-collision order, physics query return order, node/tree order, signal order, object instance order, or insertion order.

8. **Protect fast thin and oblique approaches**
   - **Given** the player approaches thin or oblique geometry at traversal speed
   - **When** discrete body facts alone could miss the relationship
   - **Then** the configured provider uses velocity-aware swept probing, including overlap handling where Godot sweep semantics require it, without repeating an equivalent query elsewhere
   - **And** probe thickness, margin, sweep distance/cap, normal tolerances, and assertion tolerances are named, documented, and validated with tolerant real-Jolt assertions rather than exact floating-point equality.

9. **Bound continuity without retaining lost walls indefinitely**
   - **Given** adjacent triangles or successive frames produce small surface-normal or contact-point fluctuations
   - **When** the new candidate remains within the documented identity, angular, spatial, and step-continuity tolerances
   - **Then** the contact owner preserves a stable wall relationship
   - **And** a genuinely different surface, an out-of-tolerance candidate, invalid step, or configured loss window reports the change/loss instead of retaining stale wall contact.

10. **Transfer committed collision facts once and reject stale data**
    - **Given** `PlayerMotor` has made its one movement commit for physics step N
    - **When** it hands collision facts to the contact owner
    - **Then** live collision objects are converted immediately into bounded typed value candidates tagged with N and used to build `ContactFrame(N)` without another movement commit or duplicate equivalent engine query
    - **And** a motor result, candidate set, or frame whose step identity does not match its declared lifecycle is rejected with a typed reason before publication or consumption.

11. **Fail visibly and safely on invalid composition**
    - **Given** the required provider, probe profile, body binding, or named collision configuration is missing, invalid, mutable at runtime, or mutually incompatible
    - **When** the player contact boundary initializes or samples
    - **Then** it returns a typed development-visible status through the responsible owner and records a bounded invariant diagnostic
    - **And** player activation fails closed for an invalid required provider/body/ground configuration, while an invalid wall-only profile disables unsafe wall activation; neither path falls back to private controller/state queries.

12. **Expose observational contact diagnostics**
    - **Given** development diagnostics are enabled
    - **When** the current contact snapshot or visualization is inspected
    - **Then** it reports the step, configured probe geometry, query counts, bounded candidates, classification/rejection reasons, deduplication/score facts, selected ground/wall facts, continuity decision, overflow state, and provider status
    - **And** diagnostics reuse the actual computed values, retain no live engine references, issue no additional physics queries, and cannot affect gameplay selection.

13. **Prove the contract with focused and real-Jolt tests**
    - **Given** the contact contract, focused player suites, and real-Jolt integration fixtures run
    - **When** they cover flat ground, supported slopes, airborne clearance, valid/invalid wall angles, corners, irregular normals, wall loss, landing, thin/oblique high-speed approaches, invalid configuration, stale steps, and permuted candidate order
    - **Then** they prove one frame per committed step, one movement commit, deterministic selection, bounded data, no duplicate equivalent contact queries, correct transitions, canonical physics interpolation enabled, and equivalent one-second behavior at shipping 60 Hz and diagnostic 120 Hz within recorded tolerances
    - **And** recursive GUT results are reported separately from Godot AI MCP discovery, MCP-native adapters, and live-session smoke evidence.

14. **Preserve the playable traversal slice and keep scope narrow**
    - **Given** implementation and validation are complete
    - **When** the Story 1.1 traversal smoke, scene/resource identity checks, launch check, and complete working-tree diff are reviewed
    - **Then** ground, air, jump, current grapple acquire/hold/release, wall-run, wall-stick, wall-jump, landing, and reachable transitions remain playable through the Story 1.4 semantic motor and `res://main.tscn` remains runnable with preserved scene UIDs
    - **And** the only deliberate simulation/configuration changes are the named collision matrix, typed contact profiles, and enabling canonical physics interpolation; the diff has not retuned wall behavior, redesigned grapple targets, implemented the true maximum grapple boundary, changed tutorial behavior, added final presentation, changed dependency versions, altered other project settings, or migrated unrelated domains.

## Tasks / Subtasks

- [ ] 1. Protect the implemented Story 1.4 seam and repeat the mandatory Godot AI MCP preflight before runtime edits (AC: 1-3, 10-14)
  - [ ] Start from the current working tree containing Story 1.4's implementation and review evidence; do not reset, clean, reconstruct, or overwrite its user-owned modified/untracked files. Record implementation-start `HEAD`, complete status, and the disposition of Story 1.4's pending manual feel/visual review before changing its motor/controller/state seams.
  - [ ] Through Godot AI MCP, list sessions; identify and activate the exact `testgame` project session; inspect editor readiness, current scene, play state, editor diagnostics, `main.tscn`, `scenes/player.tscn`, `/Player/PlayerMotor`, movement HSM/state nodes, affected scripts, Jolt/tick/interpolation settings, and collision-layer names. If no ready active session exists, stop before source edits and report the connection blocker; do not silently substitute CLI or generic UI automation.
  - [ ] Freeze a pre-change contact oracle for grounded, slope, airborne, landing, wall-run, wall-stick, wall-jump, wall loss, grapple-to-wall, and high-speed approach behavior. Record existing wall tuning separately from contact facts, including the current horizontal entry, distance, normal, alignment, gravity, speed, and jump policies actually used by the live working tree.
  - [ ] Preserve the Story 1.4 outer transaction: one immutable command frame; one motor frame; one manually driven movement-HSM update; seven semantic phases; one final velocity assignment and `move_and_slide()`; bounded post-commit coordination; one attack-HSM update. Preserve its duplicate-commit, rejected-follow-up, detached/freed-body, wall-stick zero-baseline, stale-grapple-landing, and bounded-diagnostics protections.
  - [ ] Reuse the established regression tolerances unless new measured contact evidence justifies tighter values: representative velocity drift at most `0.05 m/s`, position drift at most `0.10 m` over a one-second comparison, and transition alignment within one 60 Hz physics step. Record contact-specific geometric/angle tolerances separately rather than silently replacing these movement tolerances.

- [ ] 2. Establish the smallest typed contact contract, query profiles, and named matrix (AC: 1, 2, 4, 10-12)
  - [ ] Add an immutable value-only `ContactFrame` contract at the narrow shared/player boundary. Include `physics_step`, publication/status fields, grounded and wall facts, optional normalized ground/wall normals, optional stable surface identities, the selected wall relation needed by current traversal, bounded candidate/rejection summaries, and explicit overflow/loss state. Constructors validate finite vectors, coherent option flags, and limits; consumers receive only copied/read-only values.
  - [ ] Add narrow typed value records for committed contact candidates and provider outcomes as needed. Convert `KinematicCollision3D` data immediately at the motor/contact boundary using scalar/vector fields and a stable surface-identity policy; never store or return a collision, body, query, RID wrapper, or node reference in a frame or diagnostic snapshot.
  - [ ] Put typed immutable query Resources under `game/shared/physics/`, using a common `PhysicsQueryProfile` only where it removes real duplication. Provide scene-wired `GroundProbe` and `WallProbe` profiles with named fields for collision eligibility, shape/offsets/directions, margin/thickness, sweep policy/cap, classification tolerances, continuity/loss bounds, candidate/report limits, and exclusions. Validate profiles once; gameplay must not mutate shared instances.
  - [ ] Add explicit 3D layer names in `project.godot` for the existing numeric assignments after auditing every current player, world, enemy, hit/hurt, and probe mask. Preserve all numeric collision behavior and record the matrix; do not guess unused layer meaning or migrate unrelated bodies. Profile Resources hold the resolved named masks so gameplay code contains no magic bitmasks.
  - [ ] Align the live project with the canonical simulation policy by changing `physics/common/physics_interpolation` from the observed prototype value `false` to `true`. Treat this as an intentional Story 1.5 architecture-alignment change, capture before/after evidence, validate traversal/contact behavior, and change no other timing/render setting. Teleport/re-bootstrap paths must reset interpolation as required by the architecture.
  - [ ] Wire the required provider/profile dependencies explicitly from `scenes/player.tscn` or the existing motor/controller composition boundary. Use stable scene/resource references and preserve `uid://u1u36ceuo8uj`, node names, HSM topology, collision layer 2/mask 1 behavior, and all authored scene overrides. No dynamic string load or service locator.
  - [ ] Define stable surface identity as an optional typed value: use an authored semantic surface ID when available; otherwise use a documented current-frame physics identity sufficient for deduplication but mark it non-persistent. Do not manufacture persistent identity from a display name, scene/node path, instance-order rank, filename, or query return index.

- [ ] 3. Implement one motor-bound contact lifecycle and deterministic classification (AC: 1, 5-11)
  - [ ] Introduce one narrow contact owner/provider bound to `PlayerMotor`; it may use shared physics profile/value types but must not become a global manager or a second movement authority. Only this boundary may read `CharacterBody3D` contact facts, inspect the bounded committed collision objects, or issue the configured ground/wall probes.
  - [ ] Use the declared lifecycle: pre-commit locomotion for step N consumes only the last finalized frame `ContactFrame(N-1)`; the motor commits exactly once for N; the contact owner immediately converts committed results, samples each configured probe set once, and publishes exactly one `ContactFrame(N)`; bounded post-commit transition coordination may consume N, which becomes the sole pre-commit frame for N+1. Reject mismatched, duplicate, skipped, relabeled, or stale step hand-offs.
  - [ ] Reserve `ContactFrame(0)` for an activation-only physics callback before movement processing. Validate provider/profile/matrix composition, sample configured probes once at the spawn pose, tag the frame with typed `BOOTSTRAP` origin and “no committed-motor evidence,” perform no `move_and_slide()`, and enable the first HSM update only after success. Bootstrap must not trust pre-commit `is_on_floor()` or slide caches. A teleport/transform discontinuity invalidates the carried frame and requires the same explicit re-bootstrap before another movement update.
  - [ ] Preserve the motor's existing 32-collision scan and 8-collision report bounds unless measured fixtures prove a smaller explicit contact budget is safe. Distinguish the scan budget, authoritative candidate budget, diagnostic report budget, and overflow count; overflow must be deterministic and visible rather than unbounded or silently truncated before selection.
  - [ ] Build ground facts with this precedence: a valid post-commit `CharacterBody3D.is_on_floor()` fact is authoritative and uses its finite allowed floor normal, with identity matched from canonicalized candidates; when the body reports false, a probe may promote `is_grounded` only if its hit is within the named support/snap distance, has an allowed support normal, is within the named separation epsilon, and satisfies the named non-separating/snap-motion predicate. Otherwise it is proximity-only. Record body/probe disagreement and provenance; an invalid authoritative normal fails publication with a typed reason. Produce one grounded/leaving/landing interpretation without a second consumer query.
  - [ ] Build wall candidates from committed contacts plus configured wall probes. Reject ground-/ceiling-like normals at the contact boundary, but expose geometry/relation facts only; keep current wall entry speed, input alignment, state eligibility, gravity, speed, and jump choices in traversal policy.
  - [ ] For fast approaches, derive sweep motion from the committed/pre-commit velocity and `delta_seconds`, capped and thickened only by named profile values. Pair `cast_motion()` with an overlap-capable query when required because Godot sweeps do not report shapes already overlapping. Do not use `intersect_shape()` as if it applied the configured motion vector.
  - [ ] Deduplicate candidates by documented identity/shape plus quantized spatial/normal equivalence, then select using a documented lexicographic tuple based on geometry (for example validity class, approach/opposition alignment, distance/time-of-impact, continuity match, and quantized point/normal key). All score components, quantization, epsilon handling, and final tie behavior must be explicit and tested under permuted inputs; raw engine/node/query order is never a tie-break.
  - [ ] Apply bounded continuity only after current-step classification: retain the prior selected relationship when identity or geometric equivalence and angular/spatial tolerances match within the configured short loss window. A new stronger valid surface, exceeded tolerance, nonconsecutive/stale step, or exhausted loss window produces a typed switch/loss. Never resurrect an old frame after a discontinuity.
  - [ ] Fail composition safely: invalid required body/provider/ground configuration prevents player contact activation and therefore motor commit; invalid wall-only configuration yields a typed frame/status with wall contact unavailable and blocks wall entry. Record the failure through existing bounded `GameLog` invariant facilities once per stable code/context; expected gameplay loss/rejection is not an invariant error.

- [ ] 4. Migrate motor, coordinator, and movement states to the shared frame (AC: 1-6, 9-11, 14)
  - [ ] Evolve `PlayerMotor.resolve_and_commit()` and `PlayerMotorCommitResult` so committed live collisions never escape into controller/state policy. The result exposes the immutable current `ContactFrame` (or a typed contact publication result) with matching step and preserves resolved/pre-slide velocity, committed/post-slide velocity, position delta, hold, success/rejection, and commit-count semantics.
  - [ ] Retire the public `slide_collisions: Array[KinematicCollision3D]` hand-off after all current consumers/tests migrate. A temporary private same-call conversion is allowed only inside the contact boundary; do not leave a compatibility getter that permits renewed external collision interpretation.
  - [ ] Update `scripts/player_controller.gd` so base/gravity/grapple-clear decisions read the last finalized frame; `_coordinate_post_commit()` reads only the newly published matching-step frame; wall-run/stick entry consumes its selected wall relationship. Remove `_find_wall_with_velocity_rays()`, wall-specific private rays, collision iteration, `StaticBody3D` eligibility, and duplicate normal classification after migration while leaving current grapple acquisition ray logic scoped and unchanged.
  - [ ] Update grounded, airborne, grappling, wall-run, wall-stick, and dead locomotion paths to accept/read the coordinator-provided frame without direct engine body/query access. Preserve state transition IDs, one-HSM-update ordering, landing pass-through, current wall-stick hold/zero baseline, and stale grapple velocity clearing.
  - [ ] Ensure a state cannot consume `ContactFrame(N)` during pre-commit policy submission for the same N. Provide narrow accessors that distinguish `previous_contact_frame` for pre-commit policy from the just-published post-commit frame, validate their expected step identities, and make unavailable/stale data a typed fail-closed result rather than an implicit fallback.
  - [ ] Keep wall activation policy in the controller/state layer using the existing authored entry speed, input-alignment, state/grapple gates, wall-run target/gravity, stick hold, and jump values. The provider selects a geometric relationship; it does not decide whether wall-run versus wall-stick starts.
  - [ ] Preserve the current grapple-target selection, pull, `22 m/s` cap, release, `35.0` tutorial grapple length, `0.65` tutorial grapple gravity scale, and future Story 1.7 maximum-distance boundary. Do not propagate the unsupported claim that the tutorial assigns ground deceleration; it does not.

- [ ] 5. Extend bounded diagnostics and prove there is no second query authority (AC: 2, 3, 7, 10-12)
  - [ ] Extend `PlayerMotorDiagnosticSnapshot` or add one narrow contact snapshot with copied value records only: provider status, frame/commit step, body-fact provenance, probe geometry/motion, query count by configured probe, candidate source/class/rejection/score, dedup result, selected contacts, continuity action, limits, overflow, and loss state.
  - [ ] Keep diagnostics opt-in and observational. Snapshot/visualization access must not call the physics space, enumerate body collisions, reclassify candidates, change selection, allocate unbounded history, or retain a `Node`, `Resource`, RID-backed object, query parameter, or collision object.
  - [ ] Extend `scripts/debug_grapple_telemetry.gd` only if needed to display already-computed contact facts. Do not fold grapple telemetry into contact ownership or perform a broad overlay/presentation refactor.
  - [ ] Add a focused source/ownership audit covering controller and all movement states. Prohibit contact `is_on_*`, slide-collision enumeration, ground/wall ray/shape queries, private wall-normal classification, magic contact masks, or access to live collision objects outside the allowed boundary. Scope the audit so current grapple-target rays and unrelated enemy/level physics are not falsely prohibited.
  - [ ] Prove the query budget by instrumentation: one configured ground sample set and one configured wall sample set at the declared post-commit phase, no duplicate equivalent probe from consumers, one contact-frame publication, and one movement commit for every successful step. Diagnostic reads do not change these counters.

- [ ] 6. Add focused contract tests and real-Jolt geometry coverage (AC: 1-14)
  - [ ] Add typed unit/contract coverage for frame immutability/copying, finite/coherent fields, profile validation, required versus wall-only configuration failure, limits/overflow, stale/duplicate/skipped step rejection, activation bootstrap, and exact previous/current frame access rules.
  - [ ] Table-test classification boundaries for flat ground, the current supported slope policy, airborne clearance, valid walls, floor-like/ceiling-like rejection, candidate provenance, optional identities, identity-less fallback semantics, and continuity/switch/loss. Assert against named tolerances rather than duplicating unexplained constants in tests.
  - [ ] Lock the deterministic wall key in evidence before implementation tests: after classification/deduplication, sort ascending by `(-quantized_approach_opposition, quantized_time_of_impact, quantized_distance, continuity_penalty, evidence_rank, quantized_normal_xyz, quantized_point_xyz, surface_identity_key)`. Define `evidence_rank` as committed collision before current overlap before sweep-only prediction; use profile-owned quantization/epsilon values; sort missing authored identity after authored IDs; and collapse candidates that remain identical after the complete key into one equivalent relationship. Tests must exercise every component and exact-key ties.
  - [ ] Permute committed/probe candidate and node creation orders at corners and irregular multi-triangle surfaces. Prove identical selected normals/identities/scores and transition results. Include exact-score ties and candidates with no persistent authored ID; do not accept input order as the final tie-break.
  - [ ] Extend real-Jolt fixtures for flat/sloped ground, landing/leaving, allowed and rejected wall angles, adjacent triangles, competing corners, wall loss, thin surfaces, oblique approaches, and speeds that can cross the discrete probe volume within one 60 Hz step. Measure collision thickness/sweep behavior and use tolerant assertions.
  - [ ] Preserve/extend Story 1.4 motor integration coverage for one commit, semantic phase order, duplicate-commit rejection, wall-run/stick/jump, grapple landing/release, wall-stick hold and next-frame zero baseline, detached/freed body, bounded collision scanning, and invalid follow-up isolation.
  - [ ] Run equivalent one-second 60 Hz and 120 Hz sequences using `delta_seconds = 1.0 / tick_rate`, with physics interpolation enabled in both configurations and the shipping 60 Hz rate restored afterward. Compare contact classifications, selected relations, transition timing, and movement within recorded tolerances; do not compare raw tick counts or exact floats.
  - [ ] Run the pinned Godot/GUT suites serially from repository root to avoid import contention:

    ```powershell
    $env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/input -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player/motor -ginclude_subdirs -gexit
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . -s res://addons/gut/gut_cmdln.gd -gdir=res://tests/player -ginclude_subdirs -gexit
    ```

  - [ ] Report current scripts/tests/assertions, exit codes, expected invariant diagnostics, unexpected errors, and known teardown/import noise. Story 1.4's recorded 21/21 input, 36/36 motor, and 57/57 recursive results are historical baselines, not a substitute for a Story 1.5 run.

- [ ] 7. Validate the loaded Godot project through both required gates and preserve honest evidence (AC: 3-5, 8-14)
  - [ ] After edits, use the same active Godot AI MCP project session to scan/reload affected scripts/resources, inspect parse/editor diagnostics, re-open and inspect `scenes/player.tscn` plus `main.tscn`, confirm provider/profile wiring and named layers, and verify editor readiness before running. If the mandatory session becomes unavailable, stop validation and report the blocker rather than claiming a CLI-only completion.
  - [ ] Run Godot AI MCP test discovery and record its result separately. Its current runner discovers only direct `res://tests/test_*.gd` scripts extending `McpTestSuite`; it does not recurse into GUT suites. Add a small top-level contact adapter only if it reuses meaningful framework-neutral cases, and never claim GUT parity unless the same cases actually execute.
  - [ ] Launch `res://main.tscn` through MCP. Use live node/property inspection, `game_eval`, simulated input, and logs to observe matching contact/motor step IDs, one frame/commit, ground/air/landing, grapple acquire/hold/release, wall-run, wall-stick, wall-jump, wall loss, and reachable transitions on representative geometry. Explicitly distinguish automated observation from pending human feel/visual judgment.
  - [ ] Read editor, game, test, and plugin logs after runtime checks; classify known host/audio, ObjectDB, import, teardown, or stale-cache noise separately from new parse/runtime failures. Stop the run and leave the editor ready/stopped on a retained project scene.
  - [ ] Run the pinned import/load checks serially and report them separately from GUT and MCP:

    ```powershell
    $env:TESTGAME_GODOT_CONSOLE = '<operator-local path to Godot_v4.7.2-stable_win64_console.exe>'
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --import --quit-after 120
    rtk $env:TESTGAME_GODOT_CONSOLE --headless --path . --quit-after 120
    ```

  - [ ] Execute the retained Story 1.1 smoke matrix and diff review from `_bmad-output/implementation-artifacts/1-1-verify-and-protect-the-playable-traversal-baseline.md` (SHA-256 `1237588924d15f6d1a552ddee690dc5a119d92ebd233ffd26ebc42cb604504bf`): ground W/A/S/D, air steering, jump, grapple acquire/hold/release and momentum, wall run/stick/jump, landing recovery, and any reachable fall/death path. Explicitly supersede `BASE-002` with evidence for canonical interpolation enabled; preserve/report `BASE-004` through `BASE-007` unless new evidence supersedes them. Fixture-only wall evidence is not normal-play proof.
  - [ ] Record evidence under `_bmad-output/implementation-artifacts/evidence/1-5/`: pre-change oracle, contact lifecycle/schema, matrix/profiles, classification/selection, query/writer audit, focused/recursive GUT, 60/120 comparison, pinned import/load, MCP verification, traversal smoke, full status/diff, and limitations. Keep GUT, MCP-native, live-session, and human/manual claims distinct.
  - [ ] Run `rtk git diff --check`, inspect complete scoped/unscoped status, and verify no user-owned Story 1.4 work, tuning, scene UID, launch scene, tutorial behavior, grapple target/range, attack/presentation, dependency, timing setting beyond the required interpolation enablement, or unrelated domain change slipped into the diff. Update this Dev Agent Record with actual files/results and move Story 1.5 to `review` only when every checked task has corresponding evidence; do not mark `done` before required review/manual-smoke policy is satisfied.

## Dev Notes

### Developer Context

Story 1.4 has implemented the semantic motor pipeline in the current working tree and is in `review`, with manual feel/visual approval still pending. Story 1.5 is the planned consumer of the contact work Story 1.4 explicitly deferred. Do not start from a clean reconstruction of `HEAD`; the modified and untracked Story 1.4 files are the actual predecessor seam and are user-owned.

Current transitional choreography:

```text
capture PlayerCommandFrame(N)
  -> PlayerMotor.begin_motion_frame(N, delta)
  -> movement HSM submits semantic policies
       (several states/controller paths still query is_on_floor or wall rays)
  -> PlayerMotor resolves seven phases and commits once
  -> commit result exposes body booleans + live KinematicCollision3D values
  -> controller reinterprets collisions / coordinates post-commit transitions
  -> attack HSM updates once
```

Required choreography:

```text
pre-commit step N:
  PlayerCommandFrame(N) + finalized ContactFrame(N-1)
    -> movement HSM submits traversal policy only
    -> PlayerMotor resolves seven semantic phases
    -> one velocity assignment + one move_and_slide()

post-commit step N:
  body contact facts + bounded committed collision values + configured probes
    -> one motor-bound contact provider pass
    -> normalize / classify / deduplicate / score / continuity
    -> publish immutable ContactFrame(N) exactly once
    -> bounded post-commit transition coordination consumes N
    -> N becomes the sole pre-commit contact input for step N+1
    -> attack HSM updates with no movement/contact query authority
```

This one-step distinction is deliberate: a frame containing step N's committed collision results cannot exist before step N's single commit. Do not solve the timing boundary by producing separate pre- and post-contact frames, querying twice, moving twice, or allowing states to query privately. The implementation must provide one explicit bootstrap path before the first HSM policy evaluation and test its semantics.

### Minimum Contact Contract

| Field/group | Required meaning |
|---|---|
| Lifecycle | `physics_step`, publication/status, source motor step, bootstrap/availability state |
| Ground | `is_grounded`, optional finite normalized normal, optional surface identity, provenance/classification |
| Wall | `has_wall_contact`, optional finite normalized selected normal, optional surface identity, relation/provenance, continuity action |
| Bounded facts | copied value candidates/rejections/scores only up to named limits; scanned/reported/overflow counts remain distinct |
| Failure | typed configuration, lifecycle, stale-step, overflow, or unavailable reason; release correctness never depends on assertions |
| Diagnostics | query/probe facts and selection trace copied from the authoritative pass; no new query or recomputation |

The closed minimum above is mandatory; optional diagnostic detail may be added only as another bounded typed value. `ContactFrame` is a stable value contract, while probe Resources are configuration. Do not place mutable player state in a shared Resource or turn `game/shared/` into a manager layer. A narrow provider may live under `game/shared/physics/` only if it remains actor-bound and stateless apart from the explicitly bounded prior-frame continuity relation; player-specific composition may instead live under `game/player/locomotion/contact/`. Record the chosen boundary and avoid duplicate types.

### Contact Ownership and Phase Decision

This is a story-level adjudicated implementation decision derived to reconcile the architecture's pre-commit `ContactFrame` consumer with the shard's requirement to include post-commit collision facts. Frame 0 and the N-1/N hand-off are not quoted verbatim from the planning artifacts; they are binding for this story because they avoid a mutable frame, two samplers, or private fallback queries.

- `PlayerMotor` remains the only active-player movement committer and the immediate owner of raw post-`move_and_slide()` collision access.
- The contact provider is invoked exactly once after successful commit, while raw collision objects are still local. It converts them immediately, performs the configured queries once, and publishes the matching-step frame.
- Pre-commit locomotion uses the preceding finalized frame; post-commit transition coordination may use the just-published frame. Accessors must encode that distinction instead of returning an ambiguous “current contact.”
- A failed motor frame publishes no successful contact frame for that step. The coordinator must fail closed according to the typed motor/contact status and cannot advance a stale frame as if it were current.
- Reserve frame 0 for an activation-only physics callback; the first ordinary motor transaction is step 1. Bootstrap validates composition and samples configured probes at the spawn pose, carries typed `BOOTSTRAP` origin plus explicit “committed evidence unavailable,” performs no `move_and_slide()`, and enables movement only after success. It must not trust pre-commit body contact caches.
- `ContactFrame(N-1)` describes the committed pose from which ordinary step N begins, so this causal double buffer does not add a spatial frame of delay in the static-world scope. Current input, speed, and traversal policy remain current-step values. Landing/leaving/wall-stick caused by commit N may transition once during post-commit coordination and govern N+1; they never retroactively resubmit N.
- A teleport or other transform discontinuity invalidates the carried frame. Movement stays inactive until an explicit provider-owned bootstrap at the new pose succeeds; numeric step adjacency alone cannot make geometrically stale contact valid.
- If contact construction fails after the body has already committed N, do not roll back, recommit, or reuse N-1. Return the typed failure, record bounded diagnostics, and deactivate before the next movement-HSM update.

### Deterministic Classification and Selection

The implementation must write down the exact tuple before coding tests. It should follow these rules:

1. Convert every committed collision/probe hit into finite normalized value data at the boundary.
2. Classify ground, wall, floor-like, ceiling-like, invalid, or duplicate through named profile tolerances.
3. Deduplicate authored identity/shape matches first, then identity-less geometric equivalents through explicit point/normal quantization.
4. Apply the binding ascending wall-selection key `(-quantized_approach_opposition, quantized_time_of_impact, quantized_distance, continuity_penalty, evidence_rank, quantized_normal_xyz, quantized_point_xyz, surface_identity_key)`. `evidence_rank` is committed collision, then current overlap, then sweep-only prediction. Quantization and epsilon values are profile-owned and recorded before tests; missing authored identity sorts after authored IDs. Raw RID, node path, instance ID, or return index is never a component.
5. If two candidates remain geometrically indistinguishable after the canonical key, collapse them into one equivalent relation; do not let their input order choose a winner.
6. Apply a short, profile-bounded continuity/loss policy after current candidates are known. Continuity may stabilize adjacent triangles; it must not override a clearly better/different valid surface or survive stale/nonconsecutive steps.

Current `PlayerMotor.prioritize_collision_indices()` is bounded reporting support whose equal-priority behavior preserves input order. It must not become Story 1.5's authoritative wall selector.

### Probe and Tolerance Decision

The GDD's horizontal speed `>= 1 m/s`, wall distance `0.8 m`, and surface approximately `12 degrees` from vertical are prototype baselines, not approved final acceptance values; OD-009 remains open and M0 acceptance remains conditional. Preserve the current effective wall policies to prevent retuning, but place contact geometry/tolerances in typed profiles and record measured real-Jolt evidence. Do not invent final design approval.

Godot-specific query constraints:

- `PhysicsDirectSpaceState3D.cast_motion()` uses the query's `motion` and returns safe/unsafe travel fractions, but ignores shapes already overlapping. Pair it with an overlap-capable query such as `collide_shape()` when required by the declared probe lifecycle.
- `intersect_shape()` reports current overlaps and does not apply the query's `motion`; do not treat it as a swept result.
- `PhysicsShapeQueryParameters3D` carries the shape, transform, motion, margin, mask, body/area flags, and exclusions. Keep the shape Resource referenced and configuration immutable.
- `CharacterBody3D.is_on_floor()`, floor normal, wall state, and slide collisions describe the last `move_and_slide()` result. Read and convert them only at the post-commit boundary.

### Requirement Traceability

- `FR11` is primary: one shared wall relationship supports wall-run, wall-stick, and wall-jump consistently.
- `FR4` is directly supported by stable ground/wall interpretation and preserved momentum transitions.
- `FR2` is supported for ground/air locomotion and context-valid wall jump; input/camera/aim are not delivered here.
- `FR5` is a landing/recovery regression obligation, not new recovery-route design.
- `FR12` is the retained focused-route and traversal-smoke integration proof.
- `FR3` remains an adjacent dependency through one immutable command frame per physics step.
- `FR6` and `FR7` are regression boundaries: the named matrix must not break current grapple eligibility/occlusion, but target-contract redesign is out of scope.
- `FR8` through `FR10` are regression-only here: preserve current pull/release/cap and defer true maximum length plus moving-target attachment.

### Architecture and Scope Guardrails

- Use Godot `4.7.2-stable`, typed GDScript, Forward+, Jolt, fixed 60 Hz shipping physics with `physics/common/physics_interpolation = true`, and restored diagnostic 120 Hz comparisons. The observed prototype value is `false`; Story 1.5 must deliberately enable it to satisfy the canonical architecture/project context and validate the change rather than treating prototype evidence as authority.
- Preserve vendored LimboAI `1.8.1`, GUT `9.7.1`, Terrain3D, Phantom Camera, Godot AI dependencies, `res://main.tscn`, and the current input map.
- Canonical planning names Godot AI `3.2.4`; the connected local MCP/plugin/server is observed as `4.0.4`. The local observation is not an approved dependency revision. Use the mandatory connected session, record the discrepancy, change no dependency/plugin files, and stop if the mismatch prevents required validation.
- Preserve command-frame capture, separate manually driven movement/attack HSMs, stable semantic source IDs, typed rejection reasons, bounded storage, and existing `GameLog` dedupe/FIFO behavior.
- Do not add a global contact autoload, service locator, mutable shared Resource, global event bus/store, numeric movement priority, second body/motor, or deferred authoritative physics callback.
- Do not bulk-move legacy controller/state files to match the future target tree. New query profiles belong under `game/shared/physics/`; new player-specific provider code may use `game/player/locomotion/contact/`; stable value contracts may use `game/shared/contracts/` when truly cross-domain.
- Do not redesign grapple acquisition, occlusion, moving targets, or maximum range; do not retune wall policy; do not migrate the tutorial, attack, enemy, application shell, final UI/VFX/audio, or unrelated levels.
- Preserve `scripts/levels/tree_grapple_tutorial.gd` as a compatibility seam. It assigns grapple length `35.0` and grapple gravity scale `0.65`; it does not author ground deceleration.

### Current-State Update Map

Definite `UPDATE` files:

- `game/player/motor/player_motor.gd`
- `game/player/motor/player_motor_commit_result.gd`
- `game/player/motor/player_motor_diagnostic_snapshot.gd`
- `scripts/player_controller.gd`
- `scripts/player_grounded_state.gd`
- `scripts/player_airborne_state.gd`
- `scripts/player_grappling_state.gd`
- `scripts/player_wall_run_state.gd`
- `project.godot`
- `tests/player/motor/test_player_motor.gd`
- `tests/player/motor/test_player_motor_integration.gd`
- `tests/player/motor/test_player_motor_semantic_contract.gd`

Expected `NEW` responsibilities; choose the fewest concrete files that preserve the architecture split:

- immutable `ContactFrame` and narrow typed contact candidate/status records
- immutable `PhysicsQueryProfile`, `GroundProbe`, and `WallProbe` definitions/resources under `game/shared/physics/`
- one player/motor-bound contact provider, preferably under `game/player/locomotion/contact/` if it owns player lifecycle/continuity
- focused contact tests mirroring the selected runtime paths under `tests/player/`
- optional direct `res://tests/test_contact_frame_mcp.gd` only if an MCP-native adapter adds material non-GUT coverage

Inspect and update only when the selected composition proves it necessary:

- `scripts/player_wall_stick_state.gd`
- `scripts/player_dead_state.gd`
- `scenes/player.tscn`
- `scripts/debug_grapple_telemetry.gd`
- current motor fixtures/source audits

Preserve without broad changes:

- `main.tscn`
- `scenes/tree_grapple_tutorial.tscn`
- `scripts/levels/tree_grapple_tutorial.gd`
- grapple-target, attack, enemy, presentation, and unrelated level code

### Predecessor and Git Intelligence

- Current `HEAD` at story authoring is `2c9f8af3d151bebaf72e513e938c1407ad660ec0` (`Story 1.4 created`). Runtime implementation is in the dirty working tree, not that commit.
- Story 1.4 is currently `review`, not `done`; its evidence records final historical GUT results of 21/21 input (677 assertions), 36/36 motor (2,131 assertions), and 57/57 recursive player (2,808 assertions), with manual feel/visual approval still pending.
- Commit `c200a182546ec0f40b0d4e4dac3926c19dc51c9b` established the earlier typed single-commit motor transaction. Story 1.4 then evolved it to semantic phases in the current working tree.
- Story 1.3 was marked done only after manual smoke confirmation; do not infer `done` from automated Story 1.5 checks alone.
- Preserve all current modified/untracked Story 1.4 source, tests, evidence, sprint/story edits, `.vscode`, and the generated bounded context pack unless the user separately authorizes cleanup.

### Testing Requirements

- GUT 9.7.1 through the pinned Godot 4.7.2 console is the canonical recursive regression gate. Run input, motor, then recursive player suites serially.
- Geometry-sensitive acceptance requires real Jolt, physics frames, typed fixtures, `autofree`, and tolerant numeric/angle/spatial assertions. Deep mocks cannot prove wall/ground classification.
- Godot AI MCP is the complementary live-session gate. It must inspect the loaded scene/resources, run any meaningful MCP-native adapter, launch the relevant scene, inspect runtime state/logs, and finish ready/stopped.
- MCP `test_run` does not recurse into `tests/player/**` and cannot be reported as GUT coverage. A zero-suite MCP result is expected unless a direct top-level `McpTestSuite` adapter is deliberately added.
- Record known teardown/import/stale-cache/host noise separately from unexpected errors. Refresh/reload before treating cached diagnostics as source defects.
- Run the retained Story 1.1 smoke honestly using the pinned path/hash recorded above. Story 1.5 intentionally supersedes `BASE-002` with validated interpolation-enabled evidence. `BASE-007` means previous wall evidence was fixture-limited; new varied/high-speed wall claims require new evidence. Preserve/report `BASE-004`/`BASE-005` (unavailable fall/death recovery paths) and `BASE-006` (known teardown noise) unless superseded.

### Latest Technical Information

- Godot 4.7 `CharacterBody3D`: `move_and_slide()` may change `velocity`; floor/wall/slide-collision facts refer to the last movement call. Official reference: <https://docs.godotengine.org/en/4.7/classes/class_characterbody3d.html>
- Godot 4.7 `PhysicsDirectSpaceState3D`: `cast_motion()` is swept and ignores already-overlapping shapes; `collide_shape()`/overlap handling is complementary, while `intersect_shape()` does not apply motion. Official reference: <https://docs.godotengine.org/en/4.7/classes/class_physicsdirectspacestate3d.html>
- Godot 4.7 `PhysicsShapeQueryParameters3D`: query shape, transform, motion, margin, collision mask, body/area flags, and exclusions are explicit parameters. Official reference: <https://docs.godotengine.org/en/4.7/classes/class_physicsshapequeryparameters3d.html>
- Godot 4.7 `KinematicCollision3D`: collider/shape/normal/point/velocity data is engine-owned; convert required fields immediately to bounded value records. Official reference: <https://docs.godotengine.org/en/4.7/classes/class_kinematiccollision3d.html>

### Story-Authoring Godot AI MCP Evidence

- Session: `testgame@40d061afaea5bfeb`
- Observed engine: Godot `4.7.2-stable`; Godot AI MCP/plugin server `4.0.4`
- Read-only operations: listed sessions; inspected editor readiness/current scene/play state/editor diagnostics; inspected the player scene, `CharacterBody3D`, `PlayerMotor`, movement HSM/states and relevant script symbols; read project physics/main-scene/layer settings; opened and inspected `res://main.tscn` hierarchy and representative world bodies.
- Observed state: editor ready, play stopped, no editor diagnostics, Jolt at 60 physics ticks, interpolation false, launch `res://main.tscn`, and unnamed 3D collision layers. The retained player is layer 2/mask 1. The false interpolation value is recorded as a prototype discrepancy to correct, not an approved target.
- This is authoring preflight evidence only. No gameplay source/resource was mutated through MCP, no MCP test/runtime smoke was performed, and no implementation validation is claimed. The implementing agent must repeat the required preflight and perform the post-edit MCP gate.

### Project Structure Notes

- The story intentionally bridges legacy `scripts/player_*.gd` consumers with target-domain additions. Do not use this focused migration to relocate every existing player script.
- `game/shared/physics/` owns reusable immutable query configuration, not player state or a singleton manager.
- Stable cross-domain value contracts may live under `game/shared/contracts/`; player-only lifecycle/continuity behavior belongs under `game/player/locomotion/contact/` or the established motor boundary.
- Tests mirror the chosen runtime domain under `tests/player/`; real-Jolt fixtures remain integration tests even when they share framework-neutral classification cases.

### Source References and Artifact Ledger

The bounded resolver reported `inventory_valid: true`, no inventory errors, and one permitted warning: the GDD remains `needs-decisions` because OD-009 blocks final M0 wall-tolerance acceptance. Do not broaden the source set during implementation without recording why.

| Source | Artifact identity / revision used | Context-pack SHA-256 |
|---|---|---|
| `_bmad-output/planning-artifacts/epics/requirements.md` | `grapplegame.epics.requirements`; complete; updated 2026-09-09; `source_sha256` `3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71` | `59d343e69c9665bff66b06cc1b1cac701f16539c0d874a0832d551641eb8f29b` |
| `_bmad-output/planning-artifacts/epics/epic-01-overview.md` | `grapplegame.epics.1`; complete; updated 2026-09-09; same epic-source revision | `1e6218beba7e5361b374f02722620c129e3ab6b21af321b280d9fb3899eab168` |
| `_bmad-output/planning-artifacts/epics/epic-01-story-05.md` | `grapplegame.story.1.5`; complete planning shard; updated 2026-09-09; same epic-source revision | `7457e456a0962c075b0bbb75ecd0df3ff93df83a47a40f8525ecc1ea41ad9329` |
| `_bmad-output/planning-artifacts/gdd.md` | `grapplegame.gdd`; version `1.2.0`; game-design-intent; `needs-decisions`; updated 2026-09-09 | `d630bc8b194d16de29004b4d461b949b446b4e87bef895bf43ff25f8adc77156` |
| `_bmad-output/planning-artifacts/architecture.md` | `grapplegame.architecture`; version `1.0`; target-implementation; complete; updated 2026-09-09 | `77b5370419ec5358ab29760a256f9ad2aa817efa6e84b8ff124d0f7774387080` |
| `_bmad-output/project-context.md` | `grapplegame.project-context`; derived-implementation-guidance; complete; updated 2026-09-09 | `75a869097acf79d253fc36d3e6c5544ba4ba1c4b0d74ae4e1e3de6be6c3bac97` |

Additional implementation continuity references:

- `_bmad-output/.artifact-index/context-1-5.json`
- `_bmad-output/implementation-artifacts/1-4-resolve-traversal-through-semantic-motor-phases.md`
- `_bmad-output/implementation-artifacts/1-1-verify-and-protect-the-playable-traversal-baseline.md` — baseline commit `317590fe882831fb7dc8117447313d733462e1f9`; SHA-256 `1237588924d15f6d1a552ddee690dc5a119d92ebd233ffd26ebc42cb604504bf`
- `_bmad-output/implementation-artifacts/evidence/1-4/`
- `AGENTS.md`

## Dev Agent Record

### Agent Model Used

To be recorded by the implementing agent.

### Debug Log References

- Story authoring context: `_bmad-output/.artifact-index/context-1-5.json`
- Story-authoring Godot AI MCP session: `testgame@40d061afaea5bfeb`
- Implementation evidence target: `_bmad-output/implementation-artifacts/evidence/1-5/`

### Completion Notes List

- Ultimate context engine analysis completed - comprehensive developer guide created.
- Fresh-context checklist revalidation passed with no remaining blockers; `ready-for-dev` is substantively justified.
- Implementation, automated tests, live MCP validation, and human feel/visual approval have not been performed by story creation.

### File List

- `_bmad-output/.artifact-index/context-1-5.json` (validated bounded source pack)
- `_bmad-output/implementation-artifacts/1-5-share-authoritative-ground-and-wall-contact-facts.md` (story artifact)
- `_bmad-output/implementation-artifacts/sprint-status.yaml` (status only)

## Change Log

- 2026-09-17: Created Story 1.5 from the validated bounded context pack; adjudicated the post-commit `ContactFrame` lifecycle, incorporated predecessor/working-tree safeguards, required canonical interpolation alignment, recorded the named matrix/profile and deterministic-selection contracts, and specified separate GUT/Godot AI MCP validation. Fresh-context checklist revalidation passed with no blockers, and sprint status was synchronized to `ready-for-dev`.
