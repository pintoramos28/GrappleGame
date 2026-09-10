---
artifact_schema: 1
artifact_id: 'grapplegame.story.6.8'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 6
story: 8
---

# Story 6.8: Select the Last Garden Production Mechanic Subset

As a game designer and developer,
I want an evidence-backed comparative playtest to select the Last Garden's production mechanic subset,
So that later production focuses on distinct, readable, valuable pressures without redesigning the validated mechanic contracts.

**Acceptance Criteria:**

1. **Define one immutable selection manifest**

   **Given** the complete M2 vocabulary is ready for comparative selection
   **When** the Last Garden selection manifest is inspected
   **Then** it declares a stable decision identity and version, evaluated build fingerprint, prerequisite gate, required candidate roles, vocabulary entries, initial role hypotheses, production-capacity constraints, eligibility rules, comparison criteria, playtest procedure, evidence fields, decision statuses, approval owner, and explicit exclusions
   **And** it references validated mechanic definitions and evidence rather than copying or modifying their tuning
   **And** mutable observations, ratings, notes, decisions, and approvals remain outside the shared manifest.

2. **Require a current complete-vocabulary pass**

   **Given** production-subset selection is requested
   **When** its prerequisites are resolved
   **Then** Story 6.7 must have a current `PASSED` result covering all 17 standalone mechanics and all six representative combinations
   **And** its project revision, working-tree state, engine configuration, physics configuration, definition fingerprints, and fixture versions must match the selection build
   **And** a failed, incomplete, stale, or differently configured vocabulary result prevents selection from being finalized
   **And** Story 6.8 cannot waive a Story 6.7 failure because a mechanic appears subjectively promising.

3. **Evaluate the four required candidate roles**

   **Given** the role coverage section is inspected
   **When** required candidates are enumerated
   **Then** it includes Rootstalker, Spore Kite, Mycelial Weaver, and Garden Heart exactly as the FR56 candidate roles
   **And** each role declares its intended combat function, traversal relationship, desired player question, expected counter and recovery shape, and production constraints
   **And** each required role receives an explicit advance or defer decision with supporting evidence
   **And** no required role is silently omitted because its initial mechanic hypothesis performs poorly.

4. **Keep optional roster candidates non-binding**

   **Given** the architecture also identifies Bloombound Hunter as a provisional consumer
   **When** the selection scope is established
   **Then** Bloombound Hunter may be recorded as optional, deferred, or outside the current slice
   **And** it is not required for Story 6.8 or Epic 6 to pass
   **And** evaluating it cannot displace required evidence for the four FR56 roles
   **And** adding it to the production roster requires an explicit capacity decision rather than occurring through an incidental mechanic mapping.

5. **Use the architecture mappings as hypotheses**

   **Given** candidate role-mechanic pairings are first assembled
   **When** the architecture's provisional consumer map is applied
   **Then** Rootstalker begins with climbing-context melee and anti-wall candidates
   **And** Spore Kite begins with aerial, arcing, predictive, drifting-cloud, and mine candidates
   **And** Mycelial Weaver begins with obstacle, adhesive, surface-state, grapple-anchor, and support candidates
   **And** Garden Heart begins with rotating-sweep, obstacle-growth, aerial-mine or airburst, and other compatible spatial-pressure candidates
   **And** these mappings remain testable starting hypotheses rather than automatic production assignments.

6. **Consider the complete validated vocabulary**

   **Given** the role hypotheses do not mention every validated mechanic
   **When** the initial disposition matrix is completed
   **Then** every one of the 17 Story 6.7 vocabulary entries is marked as shortlisted for one or more roles, deferred from the slice, or rejected for the slice
   **And** each disposition records a concise role-fit, redundancy, capacity, risk, or player-experience rationale
   **And** a mechanic may be proposed outside the architecture's initial role mapping when the decision owner records why it better serves that role
   **And** the story does not require all 17 mechanics to be tested against every role.

7. **Declare production capacity before comparative scoring**

   **Given** the number of mechanics that can be productionized is not fixed by the approved inputs
   **When** the selection manifest is finalized for playtesting
   **Then** the responsible decision owner records the maximum intended mechanic count or equivalent production-capacity constraint for the slice
   **And** the constraint distinguishes regular-enemy work from Garden Heart boss work where their costs differ
   **And** no story implementation invents an unapproved capacity value
   **And** selection remains incomplete if there is no capacity constraint capable of producing a bounded subset.

8. **Preserve a non-empty Garden Heart subset**

   **Given** Epic 8 requires a Garden Heart boss experience
   **When** the role decisions are finalized
   **Then** Garden Heart receives at least one selected validated M2 pressure mechanic
   **And** selected boss mechanics collectively support a readable attack-response cycle and traversal-created opportunity without attempting to define the complete boss design
   **And** a weak-point or vulnerability system not contained in the validated M2 vocabulary remains later boss-design work rather than being treated as already validated
   **And** if no validated mechanic is suitable for Garden Heart, Story 6.8 fails and records the required design decision instead of inventing a replacement.

9. **Keep role locomotion separate from mechanic selection**

   **Given** Rootstalker and Spore Kite rely on previously validated climbing and flying behavior
   **When** their mechanic candidates are compared
   **Then** climbing and flying provide relevant role context but are not miscounted as members of the 17-mechanic pressure vocabulary
   **And** candidate mechanics continue to request behavior through the approved AI and ability boundaries
   **And** role fit cannot justify replacing geometry-discovered locomotion with authored routes, hidden anchors, or fixture-controlled movement
   **And** locomotion limitations or fallback needs are recorded as production risks.

10. **Freeze comparison definitions and conditions**

    **Given** a comparative playtest session begins
    **When** candidate fixtures and profiles are loaded
    **Then** they use the same approved mechanic definitions, build fingerprint, player capabilities, input configuration, physics rate, health policy, diagnostic policy, and applicable fixture conditions throughout that comparison
    **And** candidate order, role label, fixture identity, definition identity, and attempt identity are recorded
    **And** tuning cannot be altered between candidates merely to favor a desired result
    **And** a necessary tuning experiment is recorded as a separate follow-up and cannot replace the unchanged-definition comparison.

11. **Provide one directly runnable comparative gallery**

    **Given** another developer opens the M2 pressure lab
    **When** they select the Last Garden comparison
    **Then** they can launch every shortlisted role-mechanic pairing and relevant approved combination from one documented gallery without editing scenes, scripts, or hidden Inspector values
    **And** each entry shows the role hypothesis, mechanic identity, gameplay question, intended response, required comparison checks, attempt state, evidence status, and remaining candidates
    **And** the gallery composes existing fixtures or bounded role-context configurations without creating production enemies, boss phases, encounter objectives, or rewards
    **And** gallery controls invoke normal system owners rather than modifying private gameplay state.

12. **Evaluate player-facing behavior before diagnostics**

    **Given** a candidate comparison attempt begins
    **When** the tester first encounters the pressure
    **Then** diagnostics are disabled
    **And** the tester evaluates whether the role and mechanic together communicate a readable source, windup, affected space or target, active state, outcome, counter, and recovery
    **And** diagnostics may be enabled afterward to verify authoritative facts and explain unexpected results
    **And** a candidate cannot receive a strong readability result only because development overlays reveal information unavailable in ordinary play.

13. **Compare role and pillar fit**

    **Given** a shortlisted mechanic is experienced in its proposed role context
    **When** its role-fit observation is recorded
    **Then** the tester evaluates whether it reinforces expressive momentum, vertical traversal-combat, readable commitment risk, and recovery rather than reducing play to stationary avoidance
    **And** the observation identifies the player decision the role would ask during actual gameplay
    **And** the mechanic is not favored merely because its visual theme could match the role
    **And** a weak role fit remains distinguishable from a technically failed mechanic.

14. **Compare tactical distinctness**

    **Given** multiple candidates could serve the same role or encounter
    **When** their gameplay questions and responses are compared
    **Then** the review identifies whether each candidate creates a distinct route, timing, trajectory, information, target-priority, or recovery decision
    **And** mechanically redundant candidates are identified even when their provisional presentation appears different
    **And** reuse of one mechanic family across multiple roles requires a documented reason and a plan for preserving distinct player-facing decisions
    **And** roster variety is judged through gameplay behavior rather than names or visual concepts alone.

15. **Compare counterplay and ordinary recovery**

    **Given** a candidate's primary success has been demonstrated
    **When** the tester deliberately makes an ordinary mistake
    **Then** the approved consequence occurs and the tester attempts the mechanic's documented recovery
    **And** the review records whether the role context preserves a viable response before impact and useful agency afterward
    **And** mechanics that routinely become unavoidable or form control chains in the proposed context are not eligible for unconditional selection
    **And** severe or intentionally terminal failures remain separately identified from ordinary recovery expectations.

16. **Compare use of vertical traversal**

    **Given** the Last Garden slice is built around vertical traversal-combat
    **When** a candidate's route interaction is reviewed
    **Then** the tester records whether ground movement, altitude change, grapple, grapple release, wall movement, momentum, cover, or route switching creates useful counterplay or offensive opportunity
    **And** the review distinguishes genuine traversal interaction from a mechanic that merely occupies a three-dimensional location
    **And** a mechanic need not use every movement option, but it cannot silently invalidate the complete vocabulary
    **And** selected mechanics collectively preserve meaningful low, high, lateral, and recovery choices for later encounter authoring.

17. **Compare technical reliability and testability**

    **Given** a candidate has passed Story 6.7
    **When** its production-readiness evidence is reviewed
    **Then** the decision considers lifecycle determinism, source-death handling, reset safety, rate equivalence, high-speed behavior, ownership boundaries, fixture reproducibility, and diagnostic support
    **And** known defects, fragile assumptions, missing evidence, or difficult-to-reproduce behavior are recorded as explicit risks
    **And** an objectively failing mechanic cannot be selected until its technical failure is remediated and Story 6.7 is rerun
    **And** subjective tuning concerns may lower priority without being mislabeled as contract failures.

18. **Compare production and presentation cost honestly**

    **Given** final enemy art, animation, audio, and VFX do not yet exist
    **When** a candidate's production cost is assessed
    **Then** the review records its expected AI integration, encounter-authoring, geometry, animation, audio, VFX, UI, accessibility, testing, and content-density needs using available evidence
    **And** unknown cost remains identified as unknown rather than being treated as low
    **And** primitive presentation quality is not mistaken for final production cost or final visual quality
    **And** this assessment creates no production assets or minimum-spec performance claim.

19. **Use performance evidence without claiming the future minimum-spec gate**

    **Given** prototype diagnostics or focused performance observations exist
    **When** production risk is compared
    **Then** bounded object counts, spatial-query load, persistent effects, overlapping presentation, cleanup behavior, and likely content-density sensitivity may inform the decision
    **And** candidates with materially different runtime costs remain distinguishable
    **And** lack of selected minimum-spec hardware or representative release-like content is recorded
    **And** Story 6.8 cannot claim NFR2 complete or replace the later M3-M4 profiling gate.

20. **Use combination evidence conservatively**

    **Given** a candidate may overlap another selected pressure in a future encounter
    **When** combination readiness is reviewed
    **Then** the six Story 6.1 through 6.6 results provide direct evidence only for their approved mechanic pairings and conditions
    **And** an untested pairing is not described as validated merely because both standalone mechanics passed
    **And** the selection record may identify an untested pairing as a future possibility, but it marks simultaneous production use as requiring separate combination validation
    **And** selected roles remain implementable with independently validated mechanics even when an optional future overlap is deferred.

21. **Reduce order and familiarity bias**

    **Given** shortlisted candidates are ready for manual comparison
    **When** the comparative sessions are performed
    **Then** candidates are run in forward order, reverse order, and at least one recorded deterministic shuffled order where the shortlist size permits it
    **And** starting state, instructions, diagnostic policy, and comparison conditions remain equivalent
    **And** the report distinguishes first-exposure readability from later familiarity
    **And** order-sensitive or learning-sensitive observations remain visible rather than being averaged away.

22. **Retain objective and subjective evidence separately**

    **Given** a comparative attempt ends
    **When** its evidence is recorded
    **Then** objective fields capture build, configuration, run and definition identities, lifecycle result, successful counter, deliberate failure, recovery, damage or movement outcome, reset result, and relevant diagnostic facts
    **And** subjective fields capture role fit, clarity, pressure, novelty, traversal value, satisfaction, frustration, perceived fairness, production value, and tuning observations
    **And** subjective judgment may guide selection but cannot overwrite an objective failure
    **And** recordings, screenshots, logs, notes, and result files remain traceable to the attempt that produced them.

23. **Keep the final decision human-owned**

    **Given** all candidate evidence and any ordinal or numeric comparison aids are available
    **When** the production subset is chosen
    **Then** the named decision owner explicitly approves each final role and mechanic disposition
    **And** automated scores, averages, rankings, or weighted tables may summarize evidence but cannot commit the selection
    **And** the decision owner may depart from the highest aggregate rating when the rationale, trade-off, and evidence are recorded
    **And** no runtime system, test runner, or fixture writes production allocation automatically.

24. **Give every candidate a terminal disposition**

    **Given** comparative review is complete
    **When** the disposition matrix is finalized
    **Then** every shortlisted role-mechanic pairing is marked `SELECTED`, `DEFERRED`, or `REJECTED_FOR_SLICE`
    **And** every required role is marked `ADVANCE_ROLE` or `DEFER_ROLE`
    **And** `NEEDS_MORE_EVIDENCE` or an unreviewed state prevents the final selection from passing
    **And** rejection or deferral for this slice does not invalidate the mechanic's reusable M2 contract.

25. **Record selected allocations completely**

    **Given** a mechanic is marked `SELECTED`
    **When** its production-decision entry is inspected
    **Then** it records the intended role or roles, primary gameplay question, expected counter and recovery, relevant traversal interactions, supporting standalone and combination evidence, known tuning work, known presentation work, technical risks, content constraints, and simultaneous-use restrictions
    **And** it identifies whether the selection is a primary role behavior, secondary pressure, or Garden Heart boss candidate
    **And** it references the existing shared family contract rather than creating a role-specific replacement
    **And** exact production tuning, final presentation, AI authoring, and encounter placement remain later implementation work.

26. **Record deferred and rejected candidates completely**

    **Given** a role or mechanic is deferred or rejected for the slice
    **When** its decision entry is inspected
    **Then** it records whether the reason is capacity, redundancy, weak role fit, limited traversal value, presentation burden, technical risk, unvalidated combination, unclear counterplay, or another evidence-backed constraint
    **And** it distinguishes "not selected for this slice" from "mechanic contract failed"
    **And** it records any condition under which the candidate could be reconsidered
    **And** no rejected candidate is silently reintroduced during Epic 8 without an explicit selection update.

27. **Protect shared mechanic contracts during selection**

    **Given** a role concept would benefit from different timing, targeting, affected space, movement ownership, damage delivery, source-death behavior, overlap semantics, or reset behavior
    **When** the requested change is compared with the validated family contract
    **Then** parameter changes already supported by immutable definitions may be recorded as later tuning work
    **And** a behavior that changes the shared contract is marked as new design or architecture work and is not included as though already validated
    **And** Story 6.8 changes no gameplay definitions, implementations, fixtures, or evidence to force a preferred fit
    **And** production roles remain consumers of the validated families rather than owners of new parallel systems.

28. **Publish one traceable production-subset decision record**

    **Given** every required comparison and disposition is complete
    **When** the selection report is generated
    **Then** it records the evaluated build fingerprint, Story 6.7 result, manifest version, capacity constraint, testers and decision owner, dates, candidate mappings, gallery procedure, comparison orders, objective results, subjective observations, selected subset, role decisions, deferred and rejected entries, risks, combination restrictions, and retained evidence references
    **And** it contains a concise machine-readable or structurally validated allocation section suitable for later Epic 8 planning
    **And** the report can be reproduced from the named fixtures without relying on memory or an external research report
    **And** changing the approved subset creates a new versioned decision rather than silently editing its history.

29. **Fail closed on unresolved selection requirements**

    **Given** Story 6.7 is stale or failing, a required role is omitted, production capacity is undefined, a candidate lacks a terminal disposition, Garden Heart has no suitable selected mechanic, evidence is untraceable, or contract-changing work is disguised as selection
    **When** the selection result is evaluated
    **Then** it becomes `FAILED` or `INCOMPLETE`, never a partial approval
    **And** it identifies the missing decision, evidence, or remediation owner
    **And** no Epic 8 production allocation is authorized from that result
    **And** corrected evaluation preserves the earlier record and produces a new versioned result.

30. **Complete Epic 6 only with an approved subset**

    **Given** Story 6.7 has a current complete pass and Story 6.8 has a complete decision record
    **When** the Epic 6 completion gate is evaluated
    **Then** all 17 mechanics remain contract-complete, all six representative combinations remain readable and recoverable, and the Last Garden subset is explicitly recorded
    **And** the named decision owner has approved the selected, deferred, and rejected dispositions
    **And** the gate becomes `PASSED` exactly once for that build and decision version
    **And** the result supplies the prerequisite for later Epic 8 production allocation without skipping Epic 7 or implementing production content inside Epic 6.

31. **Keep the selection story bounded**

    **Given** Story 6.8 is reviewed for completion
    **When** its changes and evidence are inspected
    **Then** it contains only the comparative gallery configuration, playtest procedure, evidence capture, human-owned subset decision, and Epic 6 gate result
    **And** it has not implemented production Rootstalker, Spore Kite, Mycelial Weaver, Bloombound Hunter, or Garden Heart behavior; boss phases; encounters; rewards; objectives; final HUD; final animation, audio, or VFX; or minimum-spec profiling
    **And** production allocation, authored encounter integration, and final slice validation remain assigned to Epics 7 and 8.
