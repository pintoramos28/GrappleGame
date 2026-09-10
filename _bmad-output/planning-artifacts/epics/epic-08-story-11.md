---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.11'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 11
---

# Story 8.11: Pass the M4 Boss Performance Gate

As a player,
I want the complete Garden Heart encounter to sustain the approved performance target on the selected minimum-spec Windows PC,
So that traversal, counterplay, and attack timing remain responsive during the slice's most demanding fight.

**Acceptance Criteria:**

1. **Declare the focused M4 performance outcome**

    **Given** the complete Last Garden boss content, presentation, encounter flow, reward, and exit are available
    **When** the M4 performance gate is inspected
    **Then** it executes and records a release-like 1920-by-1080 Windows benchmark on the actual approved minimum-spec PC using the complete selected Garden Heart content
    **And** hardware, software, build, inherited thresholds, scenario, content density, capture method, repetition, variance, failure handling, and evidence are explicit before qualifying measurement
    **And** the benchmark includes the representative worst legal boss phase and pressure overlap without changing gameplay rules or removing normal presentation
    **And** speculative infrastructure, broad optimization work, new gameplay, final media production, and a research report remain outside this story.

2. **Reuse the approved minimum-spec hardware profile**

    **Given** Story 7.16 established the qualifying hardware boundary
    **When** the M4 benchmark package is prepared
    **Then** it references the current approved exact CPU, GPU, GPU memory, system memory, storage class, Windows version, graphics driver, display configuration, and power or thermal mode
    **And** any hardware-profile change records its decision owner, approval, rationale, compatibility with the intended shipping minimum, and relationship to the M3 result
    **And** the named machine is physically or remotely available for repeated qualifying runs
    **And** faster proxy hardware may diagnose but cannot satisfy this gate.

3. **Inherit stable-60 criteria without silent relaxation**

    **Given** Story 7.16 approved an objective interpretation of stable 60 FPS
    **When** the M4 benchmark definition is versioned
    **Then** it inherits the frame-time, percentile, sustained-miss, hitch, warm-up, sample-duration, repetition, variance, and subsystem threshold rules unless an explicit premeasurement decision changes them
    **And** every permitted change records why it remains consistent with the 1920-by-1080 stable-60 target
    **And** thresholds cannot be relaxed after Garden Heart results are viewed merely to obtain a pass
    **And** averages cannot conceal a failed hitch, sustained-frame, physics, main-thread, or GPU requirement.

4. **Capture one release-like M4 configuration**

    **Given** a qualifying run is launched
    **When** build and project state are recorded
    **Then** it uses the approved Windows export or equivalent release-like executable, Godot 4.7.2-stable, Forward+, Jolt Physics, fixed 60 Hz gameplay physics with interpolation, 1920-by-1080 output, and approved display synchronization
    **And** the production-bound HUD, boss presentation adapters, primitive or available media, semantic audio, level and encounter flow, selected settings, reward, and exit are enabled
    **And** editor overhead, development overlays, world drawing, verbose logging, diagnostic controls, automatic captures, and unrelated instrumentation are disabled
    **And** required bounded measurement instrumentation and its known overhead are named.

5. **Author one representative complete-boss scenario**

    **Given** the final boss loop contains approach traversal, a required approach encounter, checkpoint, boss activation, phases, vulnerabilities, death or retry, reward, and exit
    **When** the benchmark scenario is defined
    **Then** it records a repeatable start state, deterministic seeds, camera or player procedure, phase markers, content counts, active-duration windows, and terminal state
    **And** at least one qualifying path runs from normal Last Garden load through approach, checkpoint, Garden Heart defeat, reward collection, and exit
    **And** focused measurement windows include activation, every phase, representative traversal-created openings, the maximum approved simultaneous pressure, boss death cleanup, retry cleanup, and exit teardown
    **And** the scenario neither adds an impossible synthetic load nor omits a normal legal worst case to pass.

6. **Assert the approved M4 content density**

    **Given** Story 8.1 and Story 6.8 bound the Last Garden allocation
    **When** a benchmark run reaches each marked phase
    **Then** assertions record the expected supporting roles, boss and weak points, eligible actions, selected mechanics, simultaneous pressure limit, projectiles, hazards, temporary geometry or surfaces, telegraphs, effects, HUD components, and audio voices
    **And** each count traces to an approved gameplay state that can occur through normal play
    **And** deferred roles, unselected mechanics, final assets, and diagnostic-only objects are absent
    **And** an incorrect or reduced representative count invalidates the qualifying run.

7. **Measure loading separately from active gameplay**

    **Given** combat-critical content must be resident before activation
    **When** load, approach, encounter, and boss phases are analyzed
    **Then** cold and warm level loading, candidate preparation, installation, transition presentation, and teardown are reported separately from active traversal and combat
    **And** no required boss scene, definition, shader, animation fallback, audio cue, projectile, effect, query profile, UI component, or reward content loads synchronously for the first time during combat
    **And** warmed-resource results are labelled rather than blended with cold-start measurements
    **And** any combat-time residency hitch fails the applicable condition even when overall FPS averages pass.

8. **Capture bounded decision-grade metrics**

    **Given** the benchmark is running on the selected machine
    **When** the measurement harness samples it
    **Then** evidence includes rendered frame times, main-thread and GPU timing where available, physics-step timing, AI and navigation timing, collision and query timing, memory, object and scoped-transient counts, audio voices, and detected hitches
    **And** every sample set records build identity, source revision, hardware profile, definitions and selected-content versions, resolution, settings, physics rate, scenario, seeds, phase, warm-up, run occurrence, and tool version
    **And** units, clock sources, phase boundaries, sample bounds, and dropped-data behavior are explicit
    **And** the harness performs no remote upload, player analytics, or unbounded trace collection.

9. **Exercise high-speed traversal during boss pressure**

    **Given** Garden Heart victory requires traversal-created openings
    **When** the benchmark executes its representative counters and attacks
    **Then** high-speed movement, camera motion, grappling, maximum-length behavior, wall actions, recovery, melee commitment, MovementCombatContext capture, and current ImpactContext queries remain active
    **And** weak-point access, telegraph tracking, collision probes, hit queries, interpolation, HUD reticle, and boss presentation run through production contracts
    **And** player speed, query thickness, target count, movement vocabulary, attack active window, or boss affected space is not reduced for the benchmark
    **And** functional correctness remains independently protected while cost is measured.

10. **Exercise the representative worst Garden Heart phase**

    **Given** Story 8.7 defines each phase and legal overlap
    **When** the worst representative phase window begins
    **Then** the boss uses the approved maximum normal AI, action, spatial, projectile or hazard, weak-point, arena-state, telegraph, VFX fallback, audio, HUD, and camera workload
    **And** deterministic seed and preconditions reproduce that legal window without diagnostic spawning or impossible state injection in the qualifying path
    **And** counterplay and vulnerability behavior remain playable rather than frozen for measurement
    **And** no cooldown, action, phase duration, participant, effect, or visual cue is suppressed solely to improve results.

11. **Include activation, death, restart, and teardown cost**

    **Given** lifecycle transitions can create transient spikes or leaks
    **When** the scenario activates the boss, kills the player, restarts or reloads through an approved path, defeats the boss, creates and collects the reward, and exits
    **Then** frame, physics, loading, cleanup, memory, object, signal, and audio behavior around each boundary is retained
    **And** every old boss run and level session releases its scoped state exactly once or idempotently
    **And** a repeated run begins without increasing retained object, memory, subscription, emitter, voice, history, or stale-work counts attributable to earlier runs
    **And** a frame-rate pass cannot conceal cleanup growth that degrades replay.

12. **Repeat qualifying measurements under controlled conditions**

    **Given** the benchmark profile is approved
    **When** qualifying evidence is collected
    **Then** the preapproved number of complete repetitions runs under the recorded power, thermal, driver, background-process, display, warm-up, and cooldown conditions
    **And** scenario inputs or player procedure remain within documented reproducibility tolerance
    **And** outliers may be excluded only through the preapproved policy with a recorded reason
    **And** variance outside the approved bound prevents a stable pass until investigated.

13. **Classify measured limits without guessing**

    **Given** a phase approaches or exceeds a threshold
    **When** evidence is analyzed
    **Then** the result distinguishes CPU main-thread, physics, AI or navigation, collision or query, GPU, memory, loading, audio, UI or presentation, cleanup, and unknown constraints
    **And** it identifies the exact scenario phase, selected mechanic state, content counts, and capture evidence associated with the limit
    **And** correlation remains labelled separately from proven cause
    **And** an unrelated microbenchmark or subjective impression cannot establish the bottleneck.

14. **Fail the gate visibly and preserve gameplay**

    **Given** any required threshold, configuration, density, residency, repeatability, cleanup, export, or evidence condition fails
    **When** the M4 result is finalized
    **Then** Story 8.11 remains failed with bounded raw evidence and a clear failing condition
    **And** measured remediation is scoped separately to the responsible owner or asset
    **And** boss mechanics, selected roles, weak points, route options, presentation clarity, physics correctness, resolution, or thresholds are not silently reduced
    **And** any proposed content or feel change returns to gameplay approval before the unchanged or versioned benchmark is rerun.

15. **Avoid speculative optimization infrastructure**

    **Given** a possible optimization is considered
    **When** its need and scope are reviewed
    **Then** pooling, custom allocation, broad caches, job systems, streaming, generalized level-of-detail frameworks, or other infrastructure require measured current-scope evidence and an explicit decision
    **And** small fixes remain with the owner that produced the measured cost
    **And** immutable definitions, deterministic outcomes, cleanup guarantees, and gameplay equivalence remain intact
    **And** the story does not perform unrelated engine modernization or production-wide optimization.

16. **Validate the complete Windows export**

    **Given** the release-like M4 build is produced
    **When** it boots and executes the complete benchmark path
    **Then** required scenes, shaders, fonts, UI, audio streams, native extensions, Jolt, LimboAI, configuration, selected mechanic content, boss content, reward, and exit dependencies load without editor-only assumptions
    **And** the build reaches safe UI, loads the Last Garden, completes the approach and boss, collects the reward, exits, and returns or offers replay through the approved flow
    **And** debug-only commands, overlays, and fixture shortcuts are absent or disabled
    **And** any export-specific failure blocks the M4 pass regardless of editor results.

17. **Use 120 Hz only as diagnostic correctness evidence**

    **Given** a separately labelled 120 Hz physics configuration is run
    **When** its result is compared with the shipping 60 Hz benchmark
    **Then** the 60 Hz configuration remains the only minimum-spec performance target
    **And** 120 Hz exposes rate-sensitive gameplay, query, timing, or bottleneck behavior without implying a 120 FPS shipping promise
    **And** physics frequency changes only before the level session begins
    **And** any functional divergence blocks the story even if 60 Hz frame performance passes.

18. **Make the M4 benchmark reproducible**

    **Given** another developer has access to the selected minimum-spec PC
    **When** they follow the retained benchmark package
    **Then** they can identify or build the exact executable, apply the recorded configuration, verify selected content and counts, reproduce seeds and phase windows, collect the same bounded metrics, and evaluate inherited thresholds
    **And** the procedure identifies setup, warm-up, expected variance, run count, failure handling, and troubleshooting limits without undocumented editor operations
    **And** raw bounded captures accompany a concise pass, fail, or explicitly provisional summary
    **And** subjective smoothness and input-feel observations remain separate from objective gate results.

19. **Verify the harness without making arbitrary CI hardware authoritative**

    **Given** the M4 benchmark scenario or evaluation logic changes
    **When** focused automated checks run
    **Then** they validate required metadata, selected-content and density assertions, deterministic setup, phase markers, metric units, bounds, diagnostic-disable policy, output schema, and threshold calculation
    **And** a smoke run proves normal application flow can complete the scenario and emit a structurally valid capture
    **And** hardware-dependent frame thresholds are evaluated only on the named qualifying environment
    **And** functional test suites continue to protect gameplay and lifecycle behavior independently of performance variance.

20. **Record one decision-grade M4 result**

    **Given** all required qualifying and diagnostic runs complete
    **When** Story 8.11 is reviewed
    **Then** one retained result reports pass, fail, or explicitly provisional status for every configuration, density, threshold, residency, cleanup, export, and reproducibility condition
    **And** it summarizes worst phase, limiting subsystem, variance, repeatability, lifecycle spikes, memory stability, risks, and any separately scoped remediation
    **And** only a complete actual-minimum-spec pass satisfies NFR2 for the M4 boss slice
    **And** a proxy or provisional result remains visibly insufficient for final completion.

21. **Keep the story bounded to the M4 performance gate**

    **Given** Story 8.11 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the inherited approved hardware and thresholds, representative complete-boss scenario, release-like Windows configuration, worst legal phase, bounded captures, repeated measurements, analysis, export validation, harness checks, and one M4 pass or fail result
    **And** it does not add mechanics, remove approved content, change balance, promise 120 FPS, create speculative infrastructure, produce a research report, replace final media, or certify subjective boss quality
    **And** final functional, qualitative, reward, exit, and replay certification remains Story 8.12.
