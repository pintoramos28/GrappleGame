class_name GrappleEndReason
extends RefCounted


## Closed, typed grapple attachment terminal reasons (Story 1.7 Task 3.1, AC 9).
##
## The value set is closed and stable: gameplay, presentation, and diagnostics
## all report these reasons, and the enum is the only terminal payload carried
## out of an attachment occurrence. Exactly one terminal is committed per
## attachment (NFR15); every later termination request returns the committed
## record unchanged.
##
## Enum order is part of the schema and is locked in the Story 1.7 Completion
## Notes; Story 1.8 appended `TARGET_DESTROYED`, `SCOPE_MISMATCH`, and
## `ANCHOR_DISCONTINUITY` after the locked prefix (append-only, Task 5.1).
## Expected gameplay termination (release, landing, death) is normal play
## and never routes to `GameLog` error/warning paths.

enum Reason {
	## No terminal has been committed yet (active attachment), or no attachment
	## exists. `NONE` is never a committed terminal value.
	NONE,
	## The player released the grapple on the `PlayerCommandFrame` release edge.
	RELEASE,
	## The anchored target reference died or the anchor became unusable.
	TARGET_INVALIDATED,
	## The owning player died while attached.
	OWNER_DEATH,
	## A locomotion/state transition cancelled the attachment (for example a
	## wall-stick jump leaving the grapple wall-stick flow).
	STATE_CANCELLATION,
	## Ground contact ended the attachment while it was still active.
	GROUND_CONTACT,
	## Story 1.8 append (Task 5.1): the anchored target was freed while
	## attached (no stale reference is ever dereferenced, NFR14).
	TARGET_DESTROYED,
	## Story 1.8 append (Task 5.1): the target reports an encounter-scope
	## identity incompatible with the attachment's originating scope.
	SCOPE_MISMATCH,
	## Story 1.8 append (Task 5.1): the sampled anchor crossed the severe
	## discontinuity threshold, or the boundary needed a correction beyond the
	## configured discontinuity tolerance (AC 4/7). The player is never snapped.
	ANCHOR_DISCONTINUITY,
}


static func reason_id(reason: Reason) -> StringName:
	var value := int(reason)
	# Bounds-checked: `Reason.keys()[...]` on an out-of-range int (a bad cast or
	# a value from a stripped `assert` path) is an array index error in the
	# middle of diagnostics rendering. Degrade to a recognizable sentinel.
	if value < 0 or value >= Reason.size():
		return &"invalid"
	return StringName(Reason.keys()[value].to_lower())


## True for a committable terminal reason (the closed set minus `NONE`).
static func is_valid_reason(value: int) -> bool:
	return value >= 0 and value < Reason.size() and value != int(Reason.NONE)
