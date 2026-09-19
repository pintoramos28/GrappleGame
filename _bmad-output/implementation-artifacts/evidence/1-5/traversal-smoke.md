# Story 1.1 traversal smoke retained for Story 1.5

This is Godot AI MCP-observed evidence in `res://main.tscn`; it is not human
feel/visual approval. The runtime test input seam was used for discrete jump,
grapple, and wall actions because the MCP action injector does not synthesize
the project's `_input` edge events. The underlying scene, HSM, motor, and
contact provider remained the real loaded gameplay objects.

| Row | Setup and input | Observed result |
|---|---|---|
| Ground forward | Main spawn; `move_forward` / W seam for a short interval | `pass`: player moved on z and remained grounded with one motor commit. |
| Ground lateral/reverse | Main scene; seam strengths for left, right, and back | `pass`: x/z positions changed in the requested directions in the live run. |
| Jump / air | Main spawn; inject `JUMP` press, then release | `pass`: step 5959 sample was airborne at y about 0.625 with y velocity about 3.36; later GUT/MCP samples returned to ground. |
| Air steering | Jump while forward movement was held | `pass`: airborne sample had nonzero horizontal velocity and `AirborneState`. |
| Grapple acquire/hold | Main scene, aim changed to `ThinTowerB`, hold grapple | `pass`: grapple target `ThinTowerB` acquired at the wall point, `GrapplingState`, valid target, and pull velocity observed. |
| Grapple release/momentum | Release grapple after hold | `pass`: grapple cleared, `AirborneState` remained, and nonzero velocity was retained. |
| Wall run | Main scene test setup at `(-6.4, 2.0, 0)`, forward-along-wall input | `pass`: frame reported wall contact and `WallRunState`; selected normal was finite. |
| Grapple-assisted wall stick | Same wall setup, grapple held with along-wall input | `pass`: `WallStickState`, valid grapple, wall contact, and zero hold velocity observed. |
| Wall jump | Press jump from wall-run and wall-stick cases | `pass`: both cases reached `AirborneState`; wall-stick jump cleared grapple/stick and produced upward/away velocity. |
| Landing | Release movement after the wall-jump arc | `pass`: main scene sample returned to `GroundedState` with y about 0.101 and zero velocity. |
| Ordinary fall/death recovery | Main scene | `not-currently-exercisable`: the prototype has no established checkpoint/respawn recovery path; death is a terminal HSM route. No recovery behavior was invented in Story 1.5. |
| Human visual/feel review | Manual play | `not-currently-exercisable` in this agent run: Story 1.4's required human feel/visual approval remains pending. |

The deterministic GUT integration fixtures separately cover the retained
commit, jump, grapple, wall-run, wall-stick, landing cleanup, death route,
and transition contracts. The table does not claim that every row was human-played or that a 120 Hz editor runtime was observed.
