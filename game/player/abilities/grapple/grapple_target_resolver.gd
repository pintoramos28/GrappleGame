class_name GrappleTargetResolver
extends RefCounted


## Authoritative grapple target resolver (architecture "Grapple target contract").
##
## Exactly one gameplay physics query runs per evaluated physics step: a single
## ray over the union of the named candidate and occlusion profiles. The first
## blocking hit is classified through the locked predicate in
## `resolve_hit_result()` and returned as one typed `GrappleTargetingResult`;
## a rejected blocking hit is never pierced to select a target behind it.
##
## Query ownership rule: this type is the only grapple gameplay raycast call site.
## Presentation and diagnostics consume its results and never query physics.

enum InitializationStatus {
	NOT_INITIALIZED,
	SUCCESS,
	MISSING_BODY,
	WRONG_BODY,
	BODY_NOT_IN_TREE,
	MISSING_DEFINITION,
	INVALID_DEFINITION,
	MISSING_OCCLUSION_PROFILE,
	INVALID_OCCLUSION_PROFILE,
	INVALID_COMPOSITION,
}

enum HitKind {
	CANDIDATE,
	OCCLUSION_ONLY,
	INELIGIBLE,
}


const SURFACE_NORMAL_EPSILON_SQUARED := 0.000001


var _body: CharacterBody3D
var _definition: GrappleDefinition
var _candidate_profile: PhysicsQueryProfile
var _occlusion_profile: PhysicsQueryProfile
var _initialized := false
var _last_evaluated_step := -1
var _last_result: GrappleTargetingResult


func initialize(
	body: Node,
	definition: GrappleDefinition,
	occlusion_profile: PhysicsQueryProfile
) -> InitializationStatus:
	if not is_instance_valid(body):
		return InitializationStatus.MISSING_BODY
	if not body is CharacterBody3D:
		return InitializationStatus.WRONG_BODY
	var character_body := body as CharacterBody3D
	if not character_body.is_inside_tree():
		return InitializationStatus.BODY_NOT_IN_TREE
	if definition == null:
		return InitializationStatus.MISSING_DEFINITION
	if definition.validate() != GrappleDefinition.ValidationStatus.SUCCESS:
		return InitializationStatus.INVALID_DEFINITION
	if occlusion_profile == null:
		return InitializationStatus.MISSING_OCCLUSION_PROFILE
	if occlusion_profile.validate() != PhysicsQueryProfile.ValidationStatus.SUCCESS:
		return InitializationStatus.INVALID_OCCLUSION_PROFILE

	var candidate_profile := definition.target_query_profile
	if (
		candidate_profile == null
		or not candidate_profile.is_ray_profile()
		or not occlusion_profile.is_ray_profile()
	):
		return InitializationStatus.INVALID_COMPOSITION
	if candidate_profile == occlusion_profile:
		return InitializationStatus.INVALID_COMPOSITION
	if candidate_profile.profile_id == occlusion_profile.profile_id:
		return InitializationStatus.INVALID_COMPOSITION
	if candidate_profile.get_collision_mask() == 0 or occlusion_profile.get_collision_mask() == 0:
		return InitializationStatus.INVALID_COMPOSITION

	_body = character_body
	_definition = definition
	_candidate_profile = candidate_profile
	_occlusion_profile = occlusion_profile
	_initialized = true
	_last_evaluated_step = -1
	_last_result = null
	return InitializationStatus.SUCCESS


func is_initialized() -> bool:
	return _initialized


func get_definition() -> GrappleDefinition:
	return _definition


func get_candidate_profile() -> PhysicsQueryProfile:
	return _candidate_profile


func get_occlusion_profile() -> PhysicsQueryProfile:
	return _occlusion_profile


static func initialization_status_id(status: InitializationStatus) -> StringName:
	return StringName(InitializationStatus.keys()[int(status)].to_lower())


## Publish `GrappleTargetingResult(N)` exactly once for evaluated step N. Repeat
## requests for step N return the same published result without a second query;
## older steps are rejected as `STALE_RESULT` without querying.
func evaluate(
	physics_step: int,
	command_frame: PlayerCommandFrame,
	query_origin: Vector3
) -> GrappleTargetingResult:
	var frame_step := command_frame.physics_step if command_frame != null else physics_step
	if not _initialized or not _has_usable_body() or command_frame == null:
		return no_query_failure(
			physics_step,
			frame_step,
			query_origin,
			Vector3.ZERO,
			_definition.max_grapple_length_m if _definition != null else 0.0,
			GrappleRejection.Reason.MISSING_RESULT,
			_candidate_profile.profile_id if _candidate_profile != null else &"",
			_occlusion_profile.profile_id if _occlusion_profile != null else &""
		)
	if physics_step == _last_evaluated_step and _last_result != null:
		return _last_result
	if physics_step < _last_evaluated_step:
		return no_query_failure(
			physics_step,
			frame_step,
			query_origin,
			command_frame.aim_world_direction,
			_definition.max_grapple_length_m,
			GrappleRejection.Reason.STALE_RESULT,
			_candidate_profile.profile_id,
			_occlusion_profile.profile_id
		)

	var result := _query_first_blocking_hit(
		physics_step,
		frame_step,
		query_origin,
		command_frame.aim_world_direction
	)
	_last_evaluated_step = physics_step
	_last_result = result
	return result


## The single authoritative gameplay raycast (query_count = 1). Engine dictionary
## output is converted to bounded typed values immediately and discarded.
func _query_first_blocking_hit(
	physics_step: int,
	command_frame_step: int,
	query_origin: Vector3,
	query_direction: Vector3
) -> GrappleTargetingResult:
	var max_length := _definition.max_grapple_length_m
	var tolerance := _definition.acquisition_tolerance_m
	var quantization := _candidate_profile.point_quantization_m
	var candidate_mask := _candidate_profile.get_collision_mask()
	var occlusion_mask := _occlusion_profile.get_collision_mask()
	var world := _body.get_world_3d()
	var space_state: PhysicsDirectSpaceState3D = world.direct_space_state if world != null else null
	if space_state == null:
		return no_query_failure(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_length,
			GrappleRejection.Reason.MISSING_RESULT,
			_candidate_profile.profile_id,
			_occlusion_profile.profile_id
		)

	var ray_length := max_length + tolerance
	var params := PhysicsRayQueryParameters3D.create(
		query_origin,
		query_origin + query_direction * ray_length,
		candidate_mask | occlusion_mask,
		[_body.get_rid()]
	)
	params.collide_with_bodies = (
		_candidate_profile.collide_with_bodies or _occlusion_profile.collide_with_bodies
	)
	params.collide_with_areas = (
		_candidate_profile.collide_with_areas or _occlusion_profile.collide_with_areas
	)
	params.hit_from_inside = _candidate_profile.ray_hit_from_inside
	params.hit_back_faces = _candidate_profile.ray_hit_back_faces

	var hit: Dictionary = space_state.intersect_ray(params)
	var has_hit := not hit.is_empty()
	var hit_position := Vector3.ZERO
	var hit_normal := Vector3.ZERO
	var hit_distance := 0.0
	var collider: Object = null
	if has_hit:
		hit_position = hit.get("position", Vector3.ZERO)
		hit_normal = hit.get("normal", Vector3.ZERO)
		hit_distance = query_origin.distance_to(hit_position)
		collider = hit.get("collider", null)
		if collider == null and hit.has("collider_id"):
			collider = instance_from_id(int(hit["collider_id"]))
	hit.clear()

	var explicit := select_grappleable(
		Grappleable3D.find_explicit_grappleables(collider),
		_candidate_profile,
		hit_distance,
		hit_position,
		hit_normal
	)
	var hit_kind := _classify_hit_kind(
		collider,
		explicit != null,
		candidate_mask,
		occlusion_mask
	)
	return resolve_hit_result(
		physics_step,
		command_frame_step,
		query_origin,
		query_direction,
		max_length,
		tolerance,
		quantization,
		has_hit,
		hit_position,
		hit_normal,
		hit_distance,
		hit_kind,
		collider,
		explicit,
		_candidate_profile.profile_id,
		_occlusion_profile.profile_id,
		1
	)


func _classify_hit_kind(
	collider: Object,
	has_explicit_grappleable: bool,
	candidate_mask: int,
	occlusion_mask: int
) -> HitKind:
	if has_explicit_grappleable:
		return HitKind.CANDIDATE
	if collider == null or not is_instance_valid(collider) or not collider is CollisionObject3D:
		return HitKind.INELIGIBLE
	var collision_layer := (collider as CollisionObject3D).collision_layer
	if (collision_layer & candidate_mask) != 0:
		return HitKind.CANDIDATE
	if (collision_layer & occlusion_mask) != 0:
		return HitKind.OCCLUSION_ONLY
	return HitKind.INELIGIBLE


## Locked classification predicate (Story 1.6). Pure and engine-independent so the
## boundary oracle and every AC 6 mapping stay directly testable:
## 1. no blocking hit -> `NO_CANDIDATE`;
## 2. non-finite hit facts -> `MALFORMED_TARGET_DATA`;
## 3. occlusion-only first hit -> `OCCLUDED`; neither profile -> `INVALID_SURFACE`;
## 4. candidate with degenerate surface normal -> `INVALID_SURFACE`;
## 5. candidate with quantized distance in (max, max + tolerance] -> `OUT_OF_RANGE`;
## 6. explicit `Grappleable3D` policy -> `TARGET_INVALID` / `MALFORMED_TARGET_DATA`
##    / `POLICY_REJECTED` / acceptance with authored response;
## 7. default policy -> acceptance with the built-in static response.
##
## Acceptance is inclusive and quantized: quantized distance `<= max_grapple_length_m`.
static func resolve_hit_result(
	physics_step: int,
	command_frame_step: int,
	query_origin: Vector3,
	query_direction: Vector3,
	max_grapple_length_m: float,
	acquisition_tolerance_m: float,
	quantization_m: float,
	has_blocking_hit: bool,
	hit_position: Vector3,
	hit_normal: Vector3,
	hit_distance_m: float,
	hit_kind: HitKind,
	target: Object,
	explicit_grappleable: Grappleable3D,
	candidate_profile_id: StringName,
	occlusion_profile_id: StringName,
	query_count: int
) -> GrappleTargetingResult:
	if not has_blocking_hit:
		return _make_result(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_grapple_length_m,
			GrappleRejection.Reason.NO_CANDIDATE,
			Vector3.ZERO,
			Vector3.ZERO,
			0.0,
			0.0,
			&"",
			null,
			candidate_profile_id,
			occlusion_profile_id,
			query_count
		)
	if (
		not hit_position.is_finite()
		or not hit_normal.is_finite()
		or is_nan(hit_distance_m)
		or is_inf(hit_distance_m)
	):
		return _make_result(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_grapple_length_m,
			GrappleRejection.Reason.MALFORMED_TARGET_DATA,
			hit_position,
			hit_normal,
			hit_distance_m,
			0.0,
			&"",
			null,
			candidate_profile_id,
			occlusion_profile_id,
			query_count
		)

	var quantized_distance := _quantize_value(hit_distance_m, quantization_m)
	var safe_maximum := max_grapple_length_m
	if is_nan(safe_maximum) or is_inf(safe_maximum) or safe_maximum <= 0.0:
		safe_maximum = 0.0
	var range_fraction := (
		quantized_distance / safe_maximum
		if safe_maximum > 0.0
		else 0.0
	)

	match hit_kind:
		HitKind.OCCLUSION_ONLY:
			return _make_result(
				physics_step,
				command_frame_step,
				query_origin,
				query_direction,
				max_grapple_length_m,
				GrappleRejection.Reason.OCCLUDED,
				hit_position,
				hit_normal,
				hit_distance_m,
				range_fraction,
				&"",
				null,
				candidate_profile_id,
				occlusion_profile_id,
				query_count
			)
		HitKind.INELIGIBLE:
			return _make_result(
				physics_step,
				command_frame_step,
				query_origin,
				query_direction,
				max_grapple_length_m,
				GrappleRejection.Reason.INVALID_SURFACE,
				hit_position,
				hit_normal,
				hit_distance_m,
				range_fraction,
				&"",
				null,
				candidate_profile_id,
				occlusion_profile_id,
				query_count
			)

	if hit_normal.length_squared() <= SURFACE_NORMAL_EPSILON_SQUARED:
		return _make_result(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_grapple_length_m,
			GrappleRejection.Reason.INVALID_SURFACE,
			hit_position,
			hit_normal,
			hit_distance_m,
			range_fraction,
			&"",
			null,
			candidate_profile_id,
			occlusion_profile_id,
			query_count
		)
	if quantized_distance > safe_maximum + acquisition_tolerance_m:
		return _make_result(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_grapple_length_m,
			GrappleRejection.Reason.NO_CANDIDATE,
			hit_position,
			hit_normal,
			hit_distance_m,
			range_fraction,
			&"",
			null,
			candidate_profile_id,
			occlusion_profile_id,
			query_count
		)
	if quantized_distance > safe_maximum:
		return _make_result(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_grapple_length_m,
			GrappleRejection.Reason.OUT_OF_RANGE,
			hit_position,
			hit_normal,
			hit_distance_m,
			range_fraction,
			&"",
			null,
			candidate_profile_id,
			occlusion_profile_id,
			query_count
		)

	if explicit_grappleable != null:
		if (
			target == null
			or not is_instance_valid(target)
			or not is_instance_valid(explicit_grappleable)
		):
			return _make_result(
				physics_step,
				command_frame_step,
				query_origin,
				query_direction,
				max_grapple_length_m,
				GrappleRejection.Reason.TARGET_INVALID,
				hit_position,
				hit_normal,
				hit_distance_m,
				range_fraction,
				&"",
				null,
				candidate_profile_id,
				occlusion_profile_id,
				query_count
			)
		var response := explicit_grappleable.build_response()
		var identity := explicit_grappleable.get_target_id()
		if response == null or not response.is_finite() or identity == &"":
			return _make_result(
				physics_step,
				command_frame_step,
				query_origin,
				query_direction,
				max_grapple_length_m,
				GrappleRejection.Reason.MALFORMED_TARGET_DATA,
				hit_position,
				hit_normal,
				hit_distance_m,
				range_fraction,
				identity,
				null,
				candidate_profile_id,
				occlusion_profile_id,
				query_count
			)
		if not response.eligible:
			return _make_result(
				physics_step,
				command_frame_step,
				query_origin,
				query_direction,
				max_grapple_length_m,
				GrappleRejection.Reason.POLICY_REJECTED,
				hit_position,
				hit_normal,
				hit_distance_m,
				range_fraction,
				identity,
				null,
				candidate_profile_id,
				occlusion_profile_id,
				query_count
			)
		return _accepted_result(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_grapple_length_m,
			hit_position,
			hit_normal,
			hit_distance_m,
			range_fraction,
			identity,
			response,
			target,
			candidate_profile_id,
			occlusion_profile_id,
			query_count
		)

	if target == null or not is_instance_valid(target) or not target is Node3D:
		return _make_result(
			physics_step,
			command_frame_step,
			query_origin,
			query_direction,
			max_grapple_length_m,
			GrappleRejection.Reason.TARGET_INVALID,
			hit_position,
			hit_normal,
			hit_distance_m,
			range_fraction,
			&"",
			null,
			candidate_profile_id,
			occlusion_profile_id,
			query_count
		)
	return _accepted_result(
		physics_step,
		command_frame_step,
		query_origin,
		query_direction,
		max_grapple_length_m,
		hit_position,
		hit_normal,
		hit_distance_m,
		range_fraction,
		&"",
		GrappleTargetResponse.static_default(),
		target,
		candidate_profile_id,
		occlusion_profile_id,
		query_count
	)


static func no_query_failure(
	physics_step: int,
	command_frame_step: int,
	query_origin: Vector3,
	query_direction: Vector3,
	max_grapple_length_m: float,
	rejection_reason: GrappleRejection.Reason,
	candidate_profile_id: StringName,
	occlusion_profile_id: StringName
) -> GrappleTargetingResult:
	return _make_result(
		physics_step,
		command_frame_step,
		query_origin,
		query_direction,
		max_grapple_length_m,
		rejection_reason,
		Vector3.ZERO,
		Vector3.ZERO,
		0.0,
		0.0,
		&"",
		null,
		candidate_profile_id,
		occlusion_profile_id,
		0
	)


## Collapse duplicate `Grappleable3D` records describing the same collider/contact
## (Story 1.5 idiom). Encounter order is preserved for reporting only.
static func normalize_grappleables(
	candidates: Array[Grappleable3D],
	profile: PhysicsQueryProfile,
	contact_distance_m: float = 0.0,
	contact_point: Vector3 = Vector3.ZERO,
	contact_normal: Vector3 = Vector3.ZERO
) -> Array[Grappleable3D]:
	var result: Array[Grappleable3D] = []
	var seen: Dictionary = {}
	for candidate in candidates:
		if candidate == null or not is_instance_valid(candidate):
			continue
		var key := _grappleable_deduplication_key(
			candidate,
			profile,
			contact_distance_m,
			contact_point,
			contact_normal
		)
		if seen.has(key):
			var existing_index: int = seen[key]
			if _grappleable_precedes(
				candidate,
				result[existing_index],
				profile,
				contact_distance_m,
				contact_point,
				contact_normal
			):
				result[existing_index] = candidate
			continue
		seen[key] = result.size()
		result.append(candidate)
	return result


## Deterministic selection over normalized records: quantized distance, blocking
## evidence rank, quantized normal and point, then the stable identity key. Engine
## return order, scene-tree order, and signal connection order never decide.
static func select_grappleable(
	candidates: Array[Grappleable3D],
	profile: PhysicsQueryProfile,
	contact_distance_m: float = 0.0,
	contact_point: Vector3 = Vector3.ZERO,
	contact_normal: Vector3 = Vector3.ZERO
) -> Grappleable3D:
	var normalized := normalize_grappleables(
		candidates,
		profile,
		contact_distance_m,
		contact_point,
		contact_normal
	)
	var selected: Grappleable3D = null
	for candidate in normalized:
		if selected == null or _grappleable_precedes(
			candidate,
			selected,
			profile,
			contact_distance_m,
			contact_point,
			contact_normal
		):
			selected = candidate
	return selected


static func _accepted_result(
	physics_step: int,
	command_frame_step: int,
	query_origin: Vector3,
	query_direction: Vector3,
	max_grapple_length_m: float,
	hit_position: Vector3,
	hit_normal: Vector3,
	hit_distance_m: float,
	range_fraction: float,
	identity: StringName,
	response: GrappleTargetResponse,
	target: Object,
	candidate_profile_id: StringName,
	occlusion_profile_id: StringName,
	query_count: int
) -> GrappleTargetingResult:
	var local_hit_offset := Vector3.ZERO
	if target is Node3D:
		var target_node := target as Node3D
		# Detached targets fall back to their local transform (no tree transform).
		var target_transform := (
			target_node.global_transform
			if target_node.is_inside_tree()
			else target_node.transform
		)
		local_hit_offset = target_transform.affine_inverse() * hit_position
	var seed := GrappleTargetSeed.new(
		identity,
		hit_position,
		hit_normal,
		response,
		weakref(target),
		local_hit_offset
	)
	return _make_result(
		physics_step,
		command_frame_step,
		query_origin,
		query_direction,
		max_grapple_length_m,
		GrappleRejection.Reason.NONE,
		hit_position,
		hit_normal,
		hit_distance_m,
		range_fraction,
		identity,
		seed,
		candidate_profile_id,
		occlusion_profile_id,
		query_count
	)


static func _make_result(
	physics_step: int,
	command_frame_step: int,
	query_origin: Vector3,
	query_direction: Vector3,
	max_grapple_length_m: float,
	rejection_reason: GrappleRejection.Reason,
	hit_position: Vector3,
	hit_normal: Vector3,
	hit_distance_m: float,
	range_fraction: float,
	identity: StringName,
	seed: GrappleTargetSeed,
	candidate_profile_id: StringName,
	occlusion_profile_id: StringName,
	query_count: int
) -> GrappleTargetingResult:
	return GrappleTargetingResult.new(
		physics_step,
		command_frame_step,
		query_origin,
		query_direction,
		max_grapple_length_m,
		rejection_reason,
		hit_position,
		hit_normal,
		hit_distance_m,
		range_fraction,
		identity,
		seed,
		candidate_profile_id,
		occlusion_profile_id,
		query_count
	)


static func _grappleable_precedes(
	left: Grappleable3D,
	right: Grappleable3D,
	profile: PhysicsQueryProfile,
	contact_distance_m: float,
	contact_point: Vector3,
	contact_normal: Vector3
) -> bool:
	var left_key := _grappleable_selection_key(
		left,
		profile,
		contact_distance_m,
		contact_point,
		contact_normal
	)
	var right_key := _grappleable_selection_key(
		right,
		profile,
		contact_distance_m,
		contact_point,
		contact_normal
	)
	return _compare_lexicographic(left_key, right_key) < 0


static func _grappleable_selection_key(
	candidate: Grappleable3D,
	profile: PhysicsQueryProfile,
	contact_distance_m: float,
	contact_point: Vector3,
	contact_normal: Vector3
) -> Array:
	var response := candidate.build_response()
	return [
		_quantize_int(contact_distance_m, profile.point_quantization_m),
		0,
		_quantize_int(contact_normal.x, profile.normal_quantization),
		_quantize_int(contact_normal.y, profile.normal_quantization),
		_quantize_int(contact_normal.z, profile.normal_quantization),
		_quantize_int(contact_point.x, profile.point_quantization_m),
		_quantize_int(contact_point.y, profile.point_quantization_m),
		_quantize_int(contact_point.z, profile.point_quantization_m),
		_identity_key(candidate.get_target_id()),
		response.get_stable_content_key(),
	]


static func _grappleable_deduplication_key(
	candidate: Grappleable3D,
	profile: PhysicsQueryProfile,
	contact_distance_m: float,
	contact_point: Vector3,
	contact_normal: Vector3
) -> String:
	var response := candidate.build_response()
	return "%s|%s|%d|%d,%d,%d" % [
		_identity_key(candidate.get_target_id()),
		response.get_stable_content_key(),
		_quantize_int(contact_distance_m, profile.point_quantization_m),
		_quantize_int(contact_normal.x, profile.normal_quantization),
		_quantize_int(contact_normal.y, profile.normal_quantization),
		_quantize_int(contact_point.z, profile.point_quantization_m),
	]


static func _compare_lexicographic(left: Array, right: Array) -> int:
	for index in range(mini(left.size(), right.size())):
		if left[index] == right[index]:
			continue
		if left[index] < right[index]:
			return -1
		return 1
	return 0


static func _identity_key(identity: StringName) -> String:
	return "0:%s" % String(identity) if identity != &"" else "1:"


static func _quantize_value(value: float, step: float) -> float:
	var safe_step := maxf(step, 0.000001)
	if is_nan(value) or is_inf(value):
		return 0.0
	return float(roundi(value / safe_step)) * safe_step


static func _quantize_int(value: float, step: float) -> int:
	var safe_step := maxf(step, 0.000001)
	if is_nan(value) or is_inf(value):
		return 0
	return roundi(value / safe_step)


func _has_usable_body() -> bool:
	return _initialized and is_instance_valid(_body) and _body.is_inside_tree()
