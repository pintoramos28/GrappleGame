class_name GrappleRejection
extends RefCounted


## Typed, allocation-free grapple targeting rejection reasons for the hot path.
##
## The value set is closed and stable: gameplay, presentation, and diagnostics all
## report these reasons, and the enum is the only rejection payload carried through
## a step (rejection paths allocate no per-check result objects). Expected gameplay
## rejection is normal play and never routes to `GameLog` error/warning paths.

enum Reason {
	NONE,
	NO_CANDIDATE,
	OUT_OF_RANGE,
	OCCLUDED,
	INVALID_SURFACE,
	POLICY_REJECTED,
	TARGET_INVALID,
	MALFORMED_TARGET_DATA,
	MISSING_RESULT,
	STALE_RESULT,
}


static func reason_id(reason: Reason) -> StringName:
	return StringName(Reason.keys()[int(reason)].to_lower())


## AC 6 targeting situations are expected gameplay, not errors. `MISSING_RESULT`
## and `STALE_RESULT` are activation contract violations and stay developer-visible.
static func is_expected_gameplay_rejection(reason: Reason) -> bool:
	match reason:
		Reason.NO_CANDIDATE, Reason.OUT_OF_RANGE, Reason.OCCLUDED, Reason.INVALID_SURFACE, Reason.POLICY_REJECTED, Reason.TARGET_INVALID, Reason.MALFORMED_TARGET_DATA:
			return true
		_:
			return false
