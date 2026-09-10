---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.16'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 16
---

# Story 7.16: Define and Pass the M3 Minimum-Spec Performance Gate

As a player,
I want the representative M3 level to sustain its approved performance target on the selected minimum-spec Windows PC,
So that traversal and combat remain responsive when the complete level-loop systems are active together.

**Acceptance Criteria:**

1. **Declare the focused performance-gate outcome**

    **Given** the complete M3 systems and representative level content are available
    **When** the performance gate is inspected
    **Then** it defines, approves, executes, and records a release-like 1920x1080 Windows benchmark on the actual selected minimum-spec PC
    **And** hardware, software, build, scenario, content density, metrics, pass thresholds, capture method, run procedure, variance policy, failure handling, and retained evidence are explicit before the qualifying measurement begins
    **And** the gate verifies performance without changing gameplay rules or substituting a reduced unrepresentative encounter
    **And** speculative optimization frameworks, open-world streaming, networking, broad telemetry, and a production-wide optimization pass remain outside this story.

2. **Record an approved minimum-spec hardware profile**

    **Given** NFR2 cannot be claimed against unnamed hardware
    **When** the M3 performance profile is approved
    **Then** it records the exact CPU, GPU, GPU memory, system memory, storage class, Windows version, graphics driver, display resolution and refresh configuration, and any power or thermal mode required for the test
    **And** it identifies the decision owner, approval date, rationale, and whether the machine is the intended shipping minimum or an explicitly labelled provisional candidate
    **And** the selected hardware is physically or remotely available for repeatable qualifying runs
    **And** a faster proxy machine may provide diagnostic evidence but cannot satisfy the minimum-spec completion result.

3. **Approve measurable stable-60 criteria before testing**

    **Given** the phrase “sustain 60 FPS” requires an objective interpretation
    **When** the benchmark definition is finalized
    **Then** it records the frame-time target corresponding to 60 FPS plus approved percentile, sustained-miss, hitch, warm-up, sample-duration, repetition, and variance thresholds
    **And** it separately defines pass treatment for render, main-thread, physics, and GPU limits where the tooling exposes them
    **And** threshold values are approved before qualifying results are viewed and cannot be relaxed silently after a failure
    **And** averages alone are insufficient if the approved hitch or sustained-frame criteria fail.

4. **Use the required release-like configuration**

    **Given** a qualifying benchmark is launched
    **When** build and project configuration are captured
    **Then** it uses a Windows export or equivalent release-like executable with Godot 4.7.2-stable, Forward+, Jolt Physics, fixed 60 Hz gameplay physics with interpolation, 1920x1080 output, and the approved display synchronization policy
    **And** representative HUD, fallback presentation, semantic audio, encounter content, settings, and level flow are enabled
    **And** development overlays, verbose logging, world drawing, automatic diagnostic captures, editor overhead, and unrelated background instrumentation are disabled
    **And** any unavoidable measurement instrumentation is named and its overhead is measured or bounded.

5. **Author one representative M3 benchmark scenario**

    **Given** the M3 level contains traversal, required and optional encounters, route pressure, rewards, checkpoints, HUD, and audio
    **When** its performance route is defined
    **Then** it includes a repeatable start state, deterministic encounter seeds, camera path or player procedure, traversal segments, required encounter phases, the optional branch, upper encounter, reward collection, checkpoint activity, death or restart boundary, and level completion
    **And** it deliberately includes the maximum representative M3 overlap of enemies, telegraphs, projectiles, hazards, temporary effects, AI navigation work, HUD updates, and audio voices expected from the authored level
    **And** its content-density counts and active-duration windows are recorded
    **And** the scenario does not introduce a synthetic stress load that cannot occur in normal M3 play or omit a normal worst case merely to pass.

6. **Separate loading performance from active gameplay performance**

    **Given** Story 7.4 uses threaded level-boundary loading
    **When** benchmark phases are analyzed
    **Then** initial or replacement loading, candidate preparation, and transition presentation are measured separately from active gameplay
    **And** active traversal and combat contain no first-time synchronous loading of required scenes, definitions, animations, audio, shaders covered by the readiness policy, or other combat-critical content
    **And** cold-start and warmed-resource behavior are labelled rather than combined into one misleading average
    **And** a loading hitch during combat is a content-residency failure even if overall average FPS passes.

7. **Capture sufficient performance evidence**

    **Given** a qualifying scenario run is active
    **When** the bounded measurement harness records it
    **Then** evidence includes rendered frame times, main-thread and GPU timing where available, physics-step timing, navigation and relevant query timing, memory use, object and scoped-transient counts, audio voice counts, and detected hitches
    **And** every sample set records build identity, content and definition versions, hardware profile, settings, resolution, physics rate, scenario identity, seed, warm-up, run occurrence, and capture-tool version
    **And** timestamps and units are explicit
    **And** capture contains no remote upload, player analytics, or unbounded trace history.

8. **Exercise traversal at representative speed**

    **Given** the benchmark route contains high-speed movement, grappling, wall actions, and recovery
    **When** the player traverses its declared segments
    **Then** performance evidence includes the intended high-speed camera and world-rendering conditions rather than stationary observation alone
    **And** collision probes, grapple targeting, `ContactFrame`, motor influences, interpolation, and HUD reticle updates remain active
    **And** no query profile, collision thickness, target count, or movement speed is reduced only for the benchmark
    **And** traversal correctness remains covered by its existing functional evidence while performance is measured.

9. **Exercise representative combat pressure**

    **Given** the benchmark reaches its authored combat windows
    **When** enemies and abilities overlap at expected M3 density
    **Then** AI selection, geometry-discovered positioning, ability lifecycles, telegraphs, projectiles, hazards, effects, audio, damage queries, encounter accounting, and cleanup run through production contracts
    **And** deterministic seeds and starting state make the workload reproducible
    **And** invulnerability or AI pause diagnostics are disabled unless a separately labelled diagnostic run is being conducted
    **And** successful performance cannot depend on preventing normal attacks, shortening authored active windows, or reducing required participants.

10. **Include lifecycle and cleanup pressure**

    **Given** runtime spikes can occur at activation, death, restart, checkpoint reload, and teardown
    **When** the benchmark completes its lifecycle phases
    **Then** it records relevant frame and timing behavior around encounter activation, reward creation, checkpoint restoration, run invalidation, transient cleanup, level completion, and return or replay
    **And** cleanup remains exact and bounded while measurement is active
    **And** a repeated run begins without higher retained object, memory, signal, emitter, or history counts attributable to the prior session
    **And** performance success cannot hide stale-state growth that would degrade later runs.

11. **Repeat qualifying measurements under controlled conditions**

    **Given** the selected hardware and benchmark definition are ready
    **When** qualifying evidence is collected
    **Then** the approved number of complete repetitions runs under the recorded power, thermal, driver, background-process, and display conditions
    **And** warm-up and cooldown treatment follow the preapproved policy
    **And** outlier exclusion is permitted only through a recorded reason allowed by that policy
    **And** run-to-run variance outside the approved bound prevents a stable pass claim until investigated.

12. **Report bottlenecks without guessing**

    **Given** a run approaches or exceeds an approved limit
    **When** evidence is analyzed
    **Then** the result distinguishes CPU main-thread, physics, navigation or query, GPU, memory, loading, audio, presentation, and unknown constraints using captured evidence
    **And** correlation is labelled separately from proven cause
    **And** the report names the scenario phase and content counts associated with the limit
    **And** no optimization is justified solely by intuition or an unrelated microbenchmark.

13. **Fail visibly when the gate is not met**

    **Given** any required threshold, configuration, content-density, repeatability, residency, cleanup, or evidence condition fails
    **When** the benchmark result is finalized
    **Then** Story 7.16 remains failed with the measured evidence retained
    **And** a separately scoped remediation story identifies the proven bottleneck and preserves functional behavior
    **And** content, resolution, cue coverage, HUD behavior, physics correctness, or pass thresholds are not silently reduced
    **And** the qualifying benchmark is rerun from the approved definition after remediation.

14. **Avoid speculative infrastructure**

    **Given** performance evidence is reviewed
    **When** a possible optimization is considered
    **Then** pooling, custom allocators, broad caches, job systems, streaming, level-of-detail frameworks, or other infrastructure require a measured current-scope need and explicit approved decision
    **And** small local fixes remain within the owner and contract that produced the cost
    **And** shared definitions remain immutable and gameplay outcomes remain equivalent
    **And** an optimization that changes feel, timing, collision, AI choice, or encounter content requires separate gameplay approval.

15. **Validate Windows export behavior**

    **Given** the release-like Windows build is produced
    **When** it boots and completes the benchmark path
    **Then** required scenes, shaders, fonts, audio streams, configuration, native extensions, Jolt integration, and vendored dependencies load successfully
    **And** the build reaches safe menu, loads the M3 level, completes gameplay, and returns without editor-only dependencies
    **And** debug-only commands and overlays are absent or disabled
    **And** export-specific failures block the performance pass even when editor measurements appear acceptable.

16. **Treat diagnostic 120 Hz as a correctness configuration**

    **Given** the project supports diagnostic 120 Hz gameplay physics
    **When** performance evidence is interpreted
    **Then** the shipping 60 Hz configuration remains the minimum-spec performance target
    **And** the 120 Hz configuration receives a separately labelled diagnostic run for gameplay equivalence and bottleneck visibility rather than an implied 120 FPS minimum-spec promise
    **And** switching physics frequency occurs only before the session starts
    **And** any functional divergence remains a failure even if the 60 Hz performance target passes.

17. **Keep the benchmark reproducible by another developer**

    **Given** the performance package is handed to another developer with access to the selected hardware
    **When** they follow its documented setup and scenario procedure
    **Then** they can build or obtain the identified executable, apply the exact configuration, confirm content counts and seed, execute all phases, collect the same metrics, and evaluate the preapproved thresholds
    **And** the procedure identifies expected variance and troubleshooting boundaries without requiring undocumented editor manipulation
    **And** retained results include raw bounded captures plus a concise pass or fail summary
    **And** subjective smoothness observations are recorded separately from objective threshold evidence.

18. **Provide automated benchmark-harness checks without fragile CI gating**

    **Given** the benchmark harness and scenario definition change
    **When** focused automated checks run
    **Then** they validate required metadata, content-density assertions, deterministic seed setup, phase markers, units, sample bounds, diagnostic-disable policy, output schema, and pass-evaluation logic
    **And** a smoke run proves the scenario can complete and emit a valid capture
    **And** hardware-dependent frame thresholds are evaluated only on the named qualifying environment rather than assumed from arbitrary CI hardware
    **And** functional tests continue to protect gameplay independently of performance variance.

19. **Record one decision-grade performance result**

    **Given** all qualifying runs complete
    **When** Story 7.16 is reviewed
    **Then** the retained artifact identifies every required condition and reports pass, fail, or explicitly provisional status without ambiguous “looks fine” language
    **And** it summarizes threshold results, worst phases, bottleneck classification, repeatability, residency, cleanup, export behavior, and outstanding risks
    **And** only an approved actual-minimum-spec pass satisfies NFR2 for the current representative M3 scope
    **And** provisional hardware evidence remains useful but visibly cannot be mistaken for completion.

20. **Keep the story bounded to the M3 performance gate**

    **Given** Story 7.16 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the approved hardware and benchmark definition, representative M3 scenario, release-like Windows configuration, bounded capture, repeated measurements, analysis, pass or fail result, export smoke, and harness checks
    **And** it does not add new gameplay mechanics, reduce authored content silently, promise 120 FPS, implement speculative optimization infrastructure, profile a boss not yet built, or substitute a research report for measured project evidence
    **And** proven remediation remains separately scoped and the final integrated M3 gameplay gate remains Story 7.17.
