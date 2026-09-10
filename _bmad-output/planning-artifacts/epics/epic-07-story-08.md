---
artifact_schema: 1
artifact_id: 'grapplegame.story.7.8'
document_type: 'epic-story'
status: 'complete'
path_base: 'project-root'
updated: '2026-09-09'
source_sha256: '3cc7afdc04ab7cdb13d219237a83a6d784eaeff281c8620b928da293479a8e71'
epic: 7
story: 8
---

# Story 7.8: Collect Current-Session Health and Coin Rewards

As a player,
I want to collect useful health and coin rewards after overcoming encounters,
So that exploration and combat victories provide immediate, understandable value during the current level session.

**Acceptance Criteria:**

1. **Declare the focused reward outcome**

    **Given** the M3 encounter sequence, checkpoints, and restart behavior exist
    **When** the reward slice is inspected
    **Then** it provides authored health and coin pickups that become available from committed encounter progression
    **And** it defines reward resolution, spawning, collection, exactly-once commitment, retry behavior, checkpoint behavior, cleanup, presentation data, diagnostics, manual verification, and automated evidence
    **And** it builds on Stories 7.2 through 7.7 without changing their encounter, health, checkpoint, or level ownership
    **And** inventory, equipment, shops, loot rarity, persistent currency, save files, account progression, and production reward animation, VFX, or audio remain outside this story.

2. **Author three concrete M3 reward opportunities**

    **Given** the M3 level reward configuration is inspected
    **When** its baseline reward opportunities are resolved
    **Then** lower required encounter completion authorizes one pickup that restores 25 health
    **And** optional encounter completion authorizes one pickup worth 5 coins
    **And** upper required encounter completion authorizes one pickup worth 10 coins on the approach to the completion platform
    **And** the exact values, placements, visibility profile, and presentation profile are authored parameters rather than literals in level, encounter, pickup, player, or UI code.

3. **Keep reward definitions immutable**

    **Given** any M3 reward opportunity is authored
    **When** its `RewardTableDefinition` is inspected
    **Then** it declares a stable definition ID and version plus one or more typed health or coin entries
    **And** each entry declares a stable entry ID, reward type, positive amount, pickup presentation profile, placement reference, and collection policy
    **And** unsupported, duplicate, zero-value, negative-value, or malformed entries fail validation before the level becomes playable
    **And** runtime resolution and collection never mutate the shared definition.

4. **Resolve immutable reward grants**

    **Given** a valid reward opportunity becomes eligible
    **When** `LevelController` resolves its reward table
    **Then** each entry produces an immutable `RewardGrant` containing the level-session ID, stable reward-opportunity ID, definition and entry identities, grant-occurrence ID, reward type, authored amount, source progression fact, and creation physics step
    **And** its occurrence identity is deterministic within that level session
    **And** repeating or replaying the same progression source cannot produce a second logical grant for the same opportunity and entry
    **And** the grant contains values and stable identities rather than live node references.

5. **Keep reward authority in `LevelController`**

    **Given** an encounter completes or a player touches a reward pickup
    **When** reward state may change
    **Then** `LevelController` alone authorizes reward opportunities, resolves grants, validates collection, maintains the current-session reward ledger, commits coin changes, and coordinates health application
    **And** encounters report committed completion without directly spawning or granting rewards
    **And** pickups report typed collection observations without changing health, coins, progression, or checkpoint state
    **And** HUD, presentation, audio, fixtures, and diagnostic tools cannot award rewards.

6. **Authorize rewards only from committed progression**

    **Given** an encounter appears defeated or emits completion more than once
    **When** a reward opportunity is considered
    **Then** its reward is authorized only after `LevelController` has committed the corresponding encounter-completion fact
    **And** pending, rejected, cancelled, stale, or presentation-only completion cannot create a grant
    **And** a duplicate completion for the same logical opportunity returns the existing reward state without spawning another pickup
    **And** optional-route bypass never authorizes the optional reward.

7. **Own available pickups at level-session scope**

    **Given** an eligible grant has not been collected
    **When** its pickup is created
    **Then** it is placed beneath a level-session-owned reward runtime root rather than the completed encounter's disposable runtime root
    **And** it remains available after that encounter root is removed
    **And** it carries its level-session, opportunity, grant, pickup-occurrence, and presentation identities
    **And** level replacement destroys the reward runtime root and every remaining pickup.

8. **Make reward placement safe and readable**

    **Given** a reward pickup placement is validated
    **When** its authored anchor and surrounding geometry are inspected
    **Then** the pickup is reachable from the intended route without an unintended precision maneuver, blind fall, hazard contact, or collision exploit
    **And** it does not obstruct the route, alter player velocity, become grappleable, receive damage, participate as an AI target, or block attacks or projectiles
    **And** the lower health reward, optional coin reward, and upper coin reward remain visually discoverable from their intended approach
    **And** invalid or missing placement blocks that reward opportunity through a typed failure rather than spawning at the world origin.

9. **Accept collection only from the current player**

    **Given** a body or sensor overlaps a reward pickup
    **When** the collection observation reaches `LevelController`
    **Then** the observation is accepted only for the current level-owned player with matching level-session, opportunity, grant, pickup, and collision-profile identities
    **And** enemies, projectiles, detached hitboxes, hazards, debris, and stale player instances cannot collect it
    **And** a rejected observation leaves the pickup and reward ledger unchanged
    **And** raw node paths or group membership are insufficient collection authority.

10. **Apply the health reward through the health owner**

    **Given** the current player is below maximum health and touches the 25-health pickup
    **When** collection is validated
    **Then** `LevelController` submits the immutable grant occurrence through the player's typed health boundary
    **And** the health owner restores up to 25 health without exceeding maximum health
    **And** the committed collection result records both the authored amount and the amount actually restored
    **And** no reward code writes the health component's private state directly.

11. **Keep a full-health pickup available**

    **Given** the player is already at maximum health
    **When** the player touches the health pickup
    **Then** collection is rejected with the typed reason `HEALTH_FULL`
    **And** no grant is committed and the pickup remains available
    **And** the player may return and collect it after taking damage
    **And** the rejection does not repeatedly create intrusive messages while the player remains overlapping it.

12. **Consume a partially useful health grant once**

    **Given** the player is missing fewer than 25 health points
    **When** the health pickup is collected
    **Then** health is restored only to maximum
    **And** the grant is fully committed and the pickup is consumed
    **And** the unused portion is not stored, converted to coins, or made collectible later
    **And** another overlap cannot apply the grant again.

13. **Maintain one current-session coin total**

    **Given** a fresh M3 level session becomes active
    **When** its reward state initializes
    **Then** its current coin total begins at zero
    **And** collecting the optional reward adds exactly 5 coins while collecting the upper reward adds exactly 10 coins
    **And** `LevelController` exposes the committed total and last accepted change through a read-only presentation source
    **And** no inventory, wallet autoload, save data, or persistent RPG state is created.

14. **Commit every collection exactly once**

    **Given** a valid collection observation is received
    **When** reward commitment runs
    **Then** `LevelController` reserves the grant occurrence, applies its typed effect, records one terminal ledger result, consumes the pickup after success, and publishes one committed presentation event
    **And** the same grant occurrence cannot be pending or committed through two simultaneous transactions
    **And** an application failure releases or terminates the reservation according to its typed result without silently consuming the pickup
    **And** a successful effect and its ledger commitment cannot be independently repeated.

15. **Handle duplicate overlaps deterministically**

    **Given** multiple overlap callbacks, physics contacts, or input frames reference the same pickup
    **When** they are processed in any supported order
    **Then** at most one collection commits
    **And** later duplicates return the existing committed result without changing health, coins, or presentation counts
    **And** the pickup disappears only after the accepted result
    **And** duplicate callbacks after its removal remain harmless.

16. **Preserve committed rewards through encounter restart**

    **Given** a reward was collected earlier in the current level session
    **When** the player restarts a current encounter
    **Then** its ledger entry, coin contribution, and consumed state remain committed
    **And** the reward pickup does not respawn
    **And** restarting or completing the encounter again cannot issue the same grant
    **And** uncollected rewards from earlier committed progression remain available unless their source is deliberately rolled back by checkpoint reload.

17. **Preserve collected rewards through checkpoint reload**

    **Given** a reward was collected after the active checkpoint was captured
    **When** the player reloads that checkpoint
    **Then** the current-session reward ledger and committed coin total are not rolled back
    **And** the collected pickup remains consumed even if its source encounter must be replayed
    **And** Story 7.7's player restore profile still restores baseline health independently of the earlier health grant
    **And** this monotonic reward policy prevents checkpoint reload from either deleting coins or farming the same reward.

18. **Reconcile uncollected rewards with restored progression**

    **Given** checkpoint reload changes which encounter-completion facts are currently committed
    **When** reward availability is rebuilt
    **Then** an uncollected reward whose source remains completed is recreated once at its authored placement
    **And** an uncollected reward whose source was rolled back is removed until that source is completed again
    **And** completing that source again resolves the same logical grant occurrence for the level session
    **And** a grant already recorded as collected never respawns regardless of source rollback.

19. **Prevent optional-reward farming**

    **Given** the player completes the optional encounter, collects its 5 coins, and reloads the earlier branch checkpoint
    **When** the optional encounter returns to its unstarted and selectable state
    **Then** the player retains the 5 committed coins
    **And** replaying and completing the optional encounter does not produce another optional coin pickup
    **And** skipping the optional encounter after that reload does not remove the committed coins
    **And** a separate fresh level session may offer the optional reward again.

20. **Reset rewards at the level-session boundary**

    **Given** the active level is replaced, fully reloaded, exited, or fails through Story 7.4's controlled application boundary
    **When** the old level session ends
    **Then** its pickups, reservations, ledger, and current coin total are discarded with that session
    **And** a newly activated level session begins with zero coins and fresh reward opportunities
    **And** old reward state is not transferred through an autoload or static cache
    **And** replaying the level from a new session can earn each authored reward once again.

21. **Reject stale reward work**

    **Given** a delayed callback, health result, pickup observation, or presentation event belongs to an invalidated level session or superseded transaction
    **When** it arrives
    **Then** it cannot change player health, coin total, reward ledger, pickup availability, encounter state, or level progression
    **And** it returns a typed stale result with the relevant stable identities
    **And** repeated stale work is bounded and cannot recreate removed nodes
    **And** no stale node reference is retained by the active session.

22. **Expose reward state without granting UI authority**

    **Given** reward state changes or collection is rejected
    **When** presentation consumes the reward projection
    **Then** it can read reward availability, pickup type, authored amount, current coin total, accepted health amount, rejection category, and committed occurrence
    **And** this data can drive the upper-right reward area defined in Story 7.1
    **And** presentation cannot request a different amount, fabricate collection, consume a pickup, or modify the ledger
    **And** raw internal enum names and stable IDs are not shown as normal player-facing text.

23. **Provide testable fallback pickup presentation**

    **Given** production models, animations, VFX, and audio are not yet available
    **When** either reward pickup is present
    **Then** a bounded fallback presenter distinguishes health from coins through both shape or iconography and color
    **And** it communicates availability and accepted collection without controlling collision or commitment
    **And** future animation, VFX, and audio presenters can subscribe to the same reward state and committed events without changing reward logic
    **And** missing or failed presentation cannot prevent a valid grant from remaining collectible.

24. **Provide bounded reward diagnostics**

    **Given** reward diagnostics are enabled
    **When** an opportunity resolves, pickup appears, collection is attempted, a transaction completes, a checkpoint reload reconciles state, or stale work is rejected
    **Then** diagnostics expose level-session, opportunity, grant, pickup, source, player, physics-step, authored amount, applied amount, coin total, transaction phase, ledger state, and terminal result
    **And** they distinguish `HEALTH_FULL`, invalid collector, duplicate, stale session, unavailable source, application failure, and accepted collection
    **And** diagnostic views are read-only, bounded, and removable from release presentation
    **And** disabling them stops their ongoing work and retained history.

25. **Make the complete reward behavior manually reproducible**

    **Given** the M3 manual test procedure is followed
    **When** the tester plays the required and optional routes
    **Then** the tester can damage the player, clear the lower encounter, collect the health pickup, and verify the capped health increase
    **And** the tester can demonstrate full-health rejection, later successful collection, optional 5-coin collection, upper 10-coin collection, and a final total of 15 coins
    **And** the tester can exercise duplicate overlap, encounter restart, checkpoint rollback before and after collection, optional replay, death, stale callbacks, level replacement, and fresh-session reset
    **And** objective evidence records health before and after, coin changes, grant and ledger identities, pickup counts, checkpoint reconciliation, and duplicate suppression, while subjective notes separately assess placement and readability.

26. **Automate reward contract and integration coverage**

    **Given** automated reward tests run
    **When** unit, integration, and real-scene cases execute
    **Then** they cover definition validation, deterministic grant identities, progression authorization, placement failure, collector validation, health capping, full-health rejection, coin totals, reservation, exactly-once commitment, duplicates, source rollback, checkpoint persistence, optional anti-farming, encounter retry, stale work, cleanup, and session reset
    **And** every accepted grant produces exactly one ledger result and one gameplay effect
    **And** no rejected, duplicate, stale, or rolled-back uncollected grant changes health or coins
    **And** the real M3 level demonstrates all three authored reward opportunities through production level and encounter boundaries.

27. **Remain equivalent at 60 Hz and diagnostic 120 Hz**

    **Given** the same scripted reward scenarios run at fixed 60 Hz and diagnostic 120 Hz
    **When** their results are compared
    **Then** opportunity eligibility, grant identities, collection acceptance, health results, coin totals, ledger state, pickup availability, checkpoint reconciliation, and terminal outcomes are equivalent
    **And** faster overlap sampling cannot create duplicate grants
    **And** no reward timing is authored as a frame count
    **And** any divergence blocks story completion.

28. **Keep the story bounded**

    **Given** Story 7.8 is reviewed for completion
    **When** its delivered scope is enumerated
    **Then** it contains the three M3 reward opportunities, immutable health-and-coin tables and grants, level-session pickups and ledger, exactly-once collection, checkpoint and retry integration, fallback presentation, diagnostics, and verification
    **And** it does not add inventory, shops, equipment, consumable storage, loot rarity, procedural drops, persistent currency, save migration, production HUD, production audio, or final visual assets
    **And** those deferred systems may consume the stable reward contracts later without being preimplemented here.
