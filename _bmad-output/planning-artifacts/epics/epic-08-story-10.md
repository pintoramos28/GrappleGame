---
artifact_schema: 1
artifact_id: 'grapplegame.story.8.10'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 8
story: 10
---

# Story 8.10: Claim the Garden Heart Reward and Exit

As a player,
I want to claim the reward earned by defeating the Garden Heart and leave the completed level,
So that victory has an immediate payoff and a clear, reliable conclusion.

**Acceptance Criteria:**

1. **Declare the focused reward-and-exit outcome**

    **Given** the current Last Garden session has one committed Garden Heart objective completion
    **When** the reward-and-exit slice is inspected
    **Then** one authored current-session coin reward becomes available in the safe post-defeat area, the current player can collect it exactly once, and collection authorizes the authored exit threshold
    **And** a valid exit observation requests one controlled completed-level transition through established application flow
    **And** reward definition, authorization, grant, pickup, collection, ledger, exit eligibility, transition, failure, cleanup, fallback presentation, diagnostics, manual procedure, and automated evidence are explicit
    **And** persistent currency, inventory, loot systems, narrative rewards, final media, full replay validation, and final balance remain outside this story.

2. **Require an explicit approved boss-reward amount**

    **Given** the source requirements require a reward but do not specify its numeric value
    **When** the Garden Heart RewardTableDefinition is prepared
    **Then** the design owner records and approves one concrete positive integer coin amount before implementation begins
    **And** the amount, decision owner, approval date or version, tuning rationale, and intended current-session value are traceable in the Story 8.1 reward handoff or a versioned amendment
    **And** no developer, fixture, presenter, or code default invents a temporary production amount
    **And** changing the approved amount creates a reviewed definition version rather than a hidden scalar override.

3. **Author one immutable boss reward table**

    **Given** the boss-reward amount is approved
    **When** its RewardTableDefinition is inspected
    **Then** it declares stable definition and version identity plus one typed coin entry with stable entry identity, approved amount, placement reference, collection policy, visibility profile, and presentation profile
    **And** the reward opportunity identifies the current Garden Heart objective completion as its sole progression source
    **And** duplicate IDs, unsupported reward types, zero or negative amounts, missing placement, malformed presentation, or unresolved approval fail validation
    **And** runtime eligibility, collection, replay, or presentation never mutates the shared definition.

4. **Authorize the reward only from committed boss progression**

    **Given** Garden Heart death or encounter completion is pending, rejected, stale, or merely presented
    **When** reward eligibility is evaluated
    **Then** no boss reward grant or pickup is created
    **And** LevelController authorizes the opportunity only after the current session's boss LevelObjective has committed completion
    **And** direct access to the reward area, removal of the boss node, diagnostic state, or gate presentation cannot authorize it
    **And** duplicate current-session objective facts return the existing reward-opportunity state.

5. **Resolve one immutable logical reward grant**

    **Given** the boss reward opportunity becomes eligible
    **When** LevelController resolves its table
    **Then** the coin entry produces one immutable RewardGrant carrying level-session, boss-objective, reward-opportunity, definition, entry, grant-occurrence, reward-type, approved-amount, and creation-step identities
    **And** logical grant identity is deterministic within the level session
    **And** replaying or rolling back the same progression source within that session cannot create a second logical grant
    **And** the grant contains stable values and identities rather than a live boss, encounter, pickup, or UI reference.

6. **Own the pickup at level-session scope**

    **Given** the boss encounter runtime is being cleaned up after objective completion
    **When** the uncollected reward pickup is created
    **Then** it belongs to the level-session reward runtime rather than the disposable Garden Heart encounter root
    **And** it remains available after the boss, weak points, attacks, presentation, and encounter transients are removed
    **And** it carries current level-session, opportunity, grant, pickup-occurrence, and presentation identities
    **And** level teardown or invalidation removes it exactly once or idempotently.

7. **Place the pickup in the authored safe reward area**

    **Given** Story 8.2 reserves reward placement and a safe post-defeat approach
    **When** the pickup placement is validated
    **Then** its complete collection volume fits the authored region and is reachable from every approved final vulnerability route after hostile cleanup
    **And** it avoids gate motion, residual pressure origins, damaging volumes, boss collision, exit overlap, blind falls, and precision-only movement
    **And** the pickup cannot obstruct traversal, become grappleable, receive damage, act as an AI target, or block combat queries
    **And** invalid placement blocks reward readiness rather than spawning at a fallback world position.

8. **Reveal reward and exit state from authoritative progression**

    **Given** the boss objective changes from incomplete to complete
    **When** post-defeat presentation updates
    **Then** the reward pickup, approved reward notice, safe route cues, and exit locked or available state follow LevelController's committed reward-and-exit projection
    **And** an uncollected reward keeps the exit visibly unavailable with concise player-facing guidance
    **And** presentation does not infer victory from boss animation, music, missing enemies, or arena appearance
    **And** final art, animation, VFX, and audio can replace the fallback adapters without changing eligibility.

9. **Accept collection only from the current player**

    **Given** a body or sensor overlaps the boss reward pickup
    **When** its typed collection observation reaches LevelController
    **Then** collection is accepted only for the current level-owned player with matching level-session, objective, opportunity, grant, pickup, and collision-profile identities
    **And** the observation identifies the current physics step and one pickup occurrence
    **And** enemies, projectiles, boss remnants, detached hitboxes, hazards, debris, stale players, and diagnostics cannot collect it
    **And** rejection leaves the pickup, coin total, ledger, and exit eligibility unchanged.

10. **Commit the coin reward exactly once**

    **Given** a valid current-player collection observation is accepted
    **When** reward commitment executes
    **Then** LevelController reserves the grant occurrence, adds exactly the approved amount to the current-session coin total, records one terminal ledger result, consumes the pickup after success, and publishes one committed presentation fact
    **And** the same grant cannot be pending or committed in two collection transactions
    **And** a failed application releases or terminates the reservation through a typed result without silently consuming the pickup
    **And** neither pickup, HUD, audio, objective, encounter, nor GameFlowController writes the coin total directly.

11. **Handle duplicate collection deterministically**

    **Given** multiple overlap callbacks, physics contacts, or input frames identify the same boss pickup
    **When** they are processed in any supported order
    **Then** at most one collection and one coin change commit
    **And** later duplicates return the existing terminal result without repeating presentation or exit authorization
    **And** the pickup disappears only after accepted commitment
    **And** callbacks arriving after removal remain harmless.

12. **Authorize exit only after current-session collection**

    **Given** the boss objective is complete
    **When** LevelController evaluates exit eligibility
    **Then** the authored exit becomes available only after the boss reward ledger entry is committed as collected for the current level session
    **And** reward visibility, player overlap, a pending reservation, a coin-total coincidence, a stale ledger entry, or diagnostic input cannot satisfy the requirement
    **And** the committed eligibility state exposes one read-only player-facing projection
    **And** the rule prevents accidental level departure before the required reward is actually received.

13. **Observe the authored exit threshold without granting authority**

    **Given** the player approaches Story 8.2's post-defeat exit threshold
    **When** its region detects a crossing
    **Then** it emits a typed observation containing level-session, player, exit-definition, crossing-direction, and physics-step identities
    **And** the region cannot award coins, mark the objective complete, authorize itself, unload the level, or publish application state
    **And** nonplayer bodies, stale players, wrong-direction crossings where direction is constrained, and observations before eligibility are rejected safely
    **And** rejected player observations provide the approved concise unavailable feedback without unbounded repetition.

14. **Commit one exit request through LevelController**

    **Given** the current player crosses the eligible exit threshold
    **When** LevelController validates the observation
    **Then** it verifies current session, boss objective, committed boss reward collection, exit identity, player identity, level phase, and absence of a competing transition
    **And** it commits one completed-slice exit occurrence and submits one narrow typed transition request to GameFlowController
    **And** duplicate threshold callbacks return the current exit result rather than beginning another transition
    **And** reward, pickup, gate, trigger, HUD, audio, or boss code cannot request teardown directly.

15. **Use the established safe application transition**

    **Given** GameFlowController accepts the completed-slice exit request
    **When** application flow leaves the Last Garden
    **Then** it follows Story 7.14's invalidation, owner-ordered teardown, HUD and audio unbinding, input reset, transition presentation, and safe completion or menu publication boundary
    **And** the old level becomes invalid before its mutable runtime is freed
    **And** no interval exposes both old gameplay and destination UI as authoritative
    **And** presentation animation, audio completion, or exit-region lifetime cannot publish the destination state.

16. **Preserve the committed reward during an exit transaction**

    **Given** boss reward collection is committed and an exit transition is pending
    **When** presentation, teardown, or destination readiness takes time
    **Then** the current level-session ledger continues to report the accepted grant until that session is invalidated through the normal transition
    **And** duplicate exit observations cannot recollect or reapply the reward
    **And** the bounded completion presentation may show the earned amount without claiming persistent storage
    **And** leaving the level discards current-session currency according to the approved M0-M4 boundary rather than promoting it into a save or account wallet.

17. **Recover safely from exit-transition failure**

    **Given** a required teardown, unbinding, or destination-readiness step reports failure
    **When** GameFlowController resolves the exit transaction
    **Then** the invalid old level is never resumed as healthy gameplay
    **And** best-effort idempotent cleanup reaches the established safe resident failure UI with only valid retry or main-menu choices
    **And** retrying transition or cleanup cannot grant the boss reward again or allocate a duplicate exit occurrence
    **And** the failure cannot enter an unbounded transition or loading loop.

18. **Apply current-session retry and rollback rules**

    **Given** a supported checkpoint, encounter, or development recovery occurs before the level exits
    **When** boss objective and reward availability are reconciled
    **Then** an uncollected grant exists exactly once while its source objective remains committed and is removed if that source is legitimately rolled back
    **And** recommitting the source in the same session resolves the same logical grant rather than a farmable second grant
    **And** a collected boss reward remains committed and consumed for that level session under Story 7.8's monotonic ledger policy
    **And** exit eligibility is rebuilt from the current committed objective and collection facts rather than from pickup absence.

19. **Reset all boss reward state for a fresh level session**

    **Given** the player returns to the safe menu or requests a fresh replay
    **When** a new Last Garden level session is installed
    **Then** it begins with no boss-objective completion, no boss reward grant or pickup, no boss reward ledger entry, zero current-session coin total, and no exit eligibility
    **And** all identities differ from the prior level session
    **And** immutable reward and exit definitions retain their fingerprints
    **And** prior-session observations, grants, ledgers, and transitions cannot affect the fresh session.

20. **Reject stale reward and exit work**

    **Given** an objective, grant, pickup, collection, ledger, exit, transition, presentation, audio, or cleanup fact belongs to an old session or occurrence
    **When** it reaches a current owner
    **Then** it cannot change coins, reward availability, pickup state, exit eligibility, level flow, HUD, audio, or application state
    **And** it returns or records a bounded typed stale reason
    **And** no retained node reference keeps the old boss, player, pickup, level, or UI alive
    **And** repeated stale work cannot increase queues, logs, histories, or subscriptions without bound.

21. **Provide readable primitive reward-and-exit presentation**

    **Given** final reward, environment, UI, animation, VFX, and audio assets are unavailable
    **When** reward authorization, pickup availability, collection, exit lock, exit authorization, transition, or failure occurs
    **Then** primitive pickup geometry, route and threshold markers, HUD notices, state shapes, text, and semantic placeholder sounds communicate the current result
    **And** reward type, amount, success, rejection, exit availability, and transition use non-color distinctions
    **And** presentation consumes committed facts without granting coins or requesting exit
    **And** later production media can replace the adapters without changing definitions, collision, collection, ledger, or flow authority.

22. **Expose bounded reward-and-exit diagnostics**

    **Given** development diagnostics are enabled after the player-facing pass
    **When** the post-defeat flow is inspected
    **Then** diagnostics show level-session and objective identity, reward definition and approval version, opportunity, logical grant and pickup occurrence, authored amount, ledger reservation and result, coin total, exit eligibility, threshold observation, exit occurrence, application transition, cleanup, and stale rejection
    **And** diagnostics read owner-maintained state without authorizing, collecting, granting, or exiting
    **And** histories and drawings have explicit bounds and stop when hidden
    **And** release-like behavior omits or disables detailed controls and identifiers.

23. **Make reward and exit manually reproducible**

    **Given** another developer reaches the Garden Heart post-defeat state through normal play with diagnostics initially disabled
    **When** they follow the documented reward-and-exit procedure
    **Then** they identify the reward, verify the exit is unavailable before collection, collect exactly the approved coin amount, observe one committed HUD and audio response, enter the now-available exit, and reach the safe destination state
    **And** they test nonplayer overlap, repeated pickup contacts, premature and wrong-direction exit crossings where applicable, checkpoint rollback, transition failure, stale callbacks, return to menu, and a fresh level session
    **And** no test path duplicates the grant, coins, pickup, exit request, or retained state
    **And** retained evidence separates objective authorization, identity, amounts, exactly-once results, teardown, and repeatability from subjective reward value, discoverability, satisfaction, feedback, and ending clarity.

24. **Verify reward and exit automatically**

    **Given** reward-definition, ledger, collection, level-flow, application-transition, UI, audio, and real-scene integration tests run
    **When** they exercise unresolved and invalid amounts, objective authorization, placement, collector validation, duplicate observations, reservation failure, coin commitment, rollback reconciliation, exit locking, eligible crossing, competing requests, transition failure, stale work, teardown, and fresh sessions
    **Then** each level session produces at most one logical boss grant, one accepted boss collection, one approved coin change, and one accepted exit occurrence
    **And** no rejected, duplicate, stale, or rolled-back uncollected event changes coins or application state
    **And** every scoped pickup, binding, audio request, and transition reference is released at session end
    **And** automation supplements rather than replaces manual reward value and exit-clarity review.

25. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** identical deterministic boss-reward and exit scenarios run at shipping 60 Hz and diagnostic 120 Hz
    **When** authorization, overlaps, collection, ledger commitment, threshold crossing, teardown, and transition resolve
    **Then** grant identities, accepted results, coin totals, exit eligibility, transition count, cleanup, and destination state remain equivalent
    **And** additional physics callbacks cannot duplicate collection or exit
    **And** no reward or exit timing is authored as a physics-step or rendered-frame count
    **And** any authoritative divergence blocks the story.

26. **Keep the story bounded to the earned reward and exit**

    **Given** Story 8.10 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains one explicitly approved current-session coin reward, immutable table and grant, safe pickup, exactly-once collection, ledger integration, collection-gated exit, safe application transition, rollback and cleanup behavior, fallback presentation, diagnostics, and focused evidence
    **And** it does not add health or randomized boss loot, inventory, equipment, persistent currency, save data, narrative content, credits, chapter progression, final media, final balance, final performance sign-off, or complete replay certification
    **And** performance and end-to-end replay remain assigned to Stories 8.11 and 8.12.
