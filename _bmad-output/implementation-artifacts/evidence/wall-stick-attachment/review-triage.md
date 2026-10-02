# Wall-stick review triage — 2026-10-01

The blind, edge-case and acceptance passes were completed independently. Findings were deduplicated into localized code/test safeguards (`patch`) and an existing backlog reconciliation (`defer`, now resolved). No frozen-intent renegotiation or broad rollback was needed; user changes were preserved.

| Concern | Disposition | Closure evidence |
|---|---|---|
| In-place supporting-shape mutation | Patch | Weak dirty-only listener; next physics sample detaches before another hold; growth and listener-lifetime cases pass. |
| Body-wide collision exclusion ignores sibling geometry | Patch | One active owner/one shape required at bind/sample/commit; compound and dynamically added sibling cases pass. Conservative compound-wall restriction remains explicit. |
| Camera turn selects a neighboring wall | Patch | Bound physical support corroborated independently of the legacy run winner; two-wall camera and genuine-support-loss cases pass. |
| Moving-before-entry author/query pose mismatch | Patch | Distinct binding and motion baselines, separately bounded catch-up; 20 m/s at 120 Hz first hold and entry teleport cases pass. |
| Owner/native/static surface point velocity | Patch | Owner-keyed samples, native point velocity without double counting, persistent static surface velocity; relative entry controls pass. |
| Incremental tilt hides cumulative pitch/roll | Patch | Binding-relative orientation check; small-increment roll/pitch cases pass. |
| Missing/invalid definition composition or entry | Patch | Fail-closed composition/entry and physical positive controls pass. |
| Negative entry tests rejected by absent support rather than tested guard | Patch | Every case establishes bindable physical positive entry before changing one guard. |
| Global shape-index renumbering | Patch | Stable owner/local shape refresh; removing disabled owner preserves attachment at both rates. |
| Bound carry timestep differs from engine integration | Patch | Physics-frame mismatch blocks movement; idle algebraic tests remain supported. |
| Settled overlap observations miss physics commits | Patch to fixture/evidence | IDs, missed counts and blocked-commit follow-up observations recorded. No claim of every-tick or visual coverage. |
| Preservation script prints approval digest without enforcing it | Patch | Hash included in aggregate/exit status; actual and altered-expectation controls pass. |
| Existing deferred telemetry distinction became stale | Defer/reconciled | Entry and speed telemetry use submitted incoming wall-relative velocity; original backlog text preserved and append-only reconciliation added. |

Final results: focused GUT **136/138**, full recursive GUT **251/260**, same nine baseline failing identities, all 22 added tests passing. Fresh MCP **36/36** hardening cases, **2/2** motion checks, **14/14** interruptions; editor-schema adapter **3/3** separately. Preservation **27/27** and whitespace check pass. Details and limits are in [verification](verification.md).

No unaddressed actionable finding from these passes remains. This is not a green comprehensive regression or route-completion claim. Compound-collider sticking, arbitrary teleport carry, visual/feel acceptance and every-physics-step overlap proof are not claimed. Final source safety guards and recorded regressions were checked after patching; no second independent full review is claimed.
