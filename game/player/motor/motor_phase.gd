class_name MotorPhase
extends RefCounted


## Semantic phases are an ordered contract, not gameplay priorities.
enum Phase {
	TERMINAL_COMMANDS,
	STATE_GATING_AND_INTERRUPTS,
	BASE_LOCOMOTION_AND_GRAVITY,
	SUSTAINED_INFLUENCES,
	ONE_SHOT_IMPULSES,
	CONSTRAINTS_AND_REDIRECTIONS,
	CAPS_AND_FINAL_COMMIT,
}


const PHASE_COUNT := 7
const CANONICAL_ORDER: Array[int] = [
	Phase.TERMINAL_COMMANDS,
	Phase.STATE_GATING_AND_INTERRUPTS,
	Phase.BASE_LOCOMOTION_AND_GRAVITY,
	Phase.SUSTAINED_INFLUENCES,
	Phase.ONE_SHOT_IMPULSES,
	Phase.CONSTRAINTS_AND_REDIRECTIONS,
	Phase.CAPS_AND_FINAL_COMMIT,
]
const CANONICAL_PHASE_IDS: Array[StringName] = [
	&"terminal_commands",
	&"state_gating_and_interrupts",
	&"base_locomotion_and_gravity",
	&"sustained_influences",
	&"one_shot_impulses",
	&"constraints_and_redirections",
	&"caps_and_final_commit",
]


static func canonical_order() -> Array[int]:
	return CANONICAL_ORDER.duplicate()


static func canonical_phase_ids() -> Array[StringName]:
	return CANONICAL_PHASE_IDS.duplicate()


static func is_valid_phase(phase: int) -> bool:
	return phase >= 0 and phase < PHASE_COUNT


static func phase_id(phase: int) -> StringName:
	if not is_valid_phase(phase):
		return &""
	return CANONICAL_PHASE_IDS[phase]
