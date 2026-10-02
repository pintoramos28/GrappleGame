class_name PlayerInputSource
extends Node


enum InitializationStatus {
	NOT_INITIALIZED,
	SUCCESS,
	MISSING_DEPENDENCY,
	MISSING_ACTION,
}


const REQUIRED_ACTIONS: Array[StringName] = [
	&"move_left",
	&"move_right",
	&"move_forward",
	&"move_back",
	&"jump",
	&"fire_grapple",
	&"attack",
	&"ui_cancel",
]

@export var mouse_sensitivity := 0.003
@export var trackpad_pan_sensitivity := 0.03
@export var pitch_min_radians := deg_to_rad(-45.0)
@export var pitch_max_radians := deg_to_rad(45.0)
@export var invert_mouse_y := false

var initialization_status: InitializationStatus = InitializationStatus.NOT_INITIALIZED
var initialization_error := ""

var _player_body: Node3D
var _camera_pivot: Node3D
var _initialized := false
var _enabled := true
var _focus_is_active := true
var _rearm_required := false
var _window_focus_connected := false

var _canonical_yaw_radians := 0.0
var _canonical_pitch_radians := 0.0
var _pending_look_delta_radians := Vector2.ZERO

var _held_flags := 0
var _pending_pressed_flags := 0
var _pending_released_flags := 0
var _last_committed_step := -1
var _cached_frame: PlayerCommandFrame

var _test_input_seam_enabled := false
var _test_movement_raw := Vector2.ZERO
var _test_movement_strengths := Vector4.ZERO
var _test_action_binding_masks: Array[int] = [0, 0, 0]
var _test_mouse_mode_override := -1


func _ready() -> void:
	set_process_input(true)


func initialize(
	player_body: Node3D,
	camera_pivot_node: Node3D,
	required_action_names: PackedStringArray = PackedStringArray()
) -> InitializationStatus:
	_initialized = false
	_cached_frame = null
	_last_committed_step = -1
	_held_flags = 0
	_pending_pressed_flags = 0
	_pending_released_flags = 0
	_pending_look_delta_radians = Vector2.ZERO
	initialization_error = ""

	if not is_instance_valid(player_body) or not is_instance_valid(camera_pivot_node):
		return _fail_initialization(
			InitializationStatus.MISSING_DEPENDENCY,
			"PlayerInputSource requires a valid player body and camera pivot."
		)

	if required_action_names.is_empty():
		for action_name in REQUIRED_ACTIONS:
			if not InputMap.has_action(action_name):
				return _fail_initialization(
					InitializationStatus.MISSING_ACTION,
					"PlayerInputSource requires InputMap action '%s'." % action_name
				)
	else:
		for action_name in required_action_names:
			var required_name := StringName(action_name)
			if not InputMap.has_action(required_name):
				return _fail_initialization(
					InitializationStatus.MISSING_ACTION,
					"PlayerInputSource requires InputMap action '%s'." % required_name
				)

	_player_body = player_body
	_camera_pivot = camera_pivot_node
	_canonical_yaw_radians = _player_body.global_rotation.y if _player_body.is_inside_tree() else _player_body.rotation.y
	_canonical_pitch_radians = clampf(
		_camera_pivot.rotation.x,
		minf(pitch_min_radians, pitch_max_radians),
		maxf(pitch_min_radians, pitch_max_radians)
	)
	_initialized = true
	_enabled = true
	_focus_is_active = true
	_rearm_required = false
	initialization_status = InitializationStatus.SUCCESS
	_connect_window_focus_signals()
	return initialization_status


func is_initialized() -> bool:
	return _initialized


func set_enabled(enabled: bool) -> void:
	_enabled = enabled
	_clear_pending_input()
	if enabled:
		_rearm_required = true
	else:
		_rearm_required = false


func request_mouse_capture() -> void:
	if is_inside_tree():
		call_deferred("_capture_mouse")
	else:
		_capture_mouse()


func capture_command_frame(physics_step: int) -> PlayerCommandFrame:
	if not _initialized:
		push_error("PlayerInputSource cannot capture a command frame before initialization.")
		return null

	if physics_step == _last_committed_step and _cached_frame != null:
		return _cached_frame
	if physics_step < _last_committed_step:
		push_error(
			"PlayerInputSource rejected non-monotonic physics step %d after %d."
			% [physics_step, _last_committed_step]
		)
		return null

	var movement_axis := Vector2.ZERO
	var forward_held := false
	var pressed_flags := 0
	var held_flags := 0
	var released_flags := 0
	var can_publish_gameplay_input := _enabled and _focus_is_active
	if can_publish_gameplay_input and not _rearm_required:
		_apply_pending_look_delta()
	if can_publish_gameplay_input:
		if _rearm_required:
			if _controls_are_neutral():
				_rearm_required = false
		else:
			movement_axis = _get_movement_axis()
			forward_held = _is_move_forward_held()
			pressed_flags = _pending_pressed_flags
			held_flags = _held_flags
			released_flags = _pending_released_flags

	var frame := PlayerCommandFrame.new(
		physics_step,
		movement_axis,
		_canonical_yaw_radians,
		_canonical_pitch_radians,
		_build_aim_world_direction(),
		pressed_flags,
		held_flags,
		released_flags,
		forward_held
	)
	_pending_pressed_flags = 0
	_pending_released_flags = 0
	_pending_look_delta_radians = Vector2.ZERO
	_last_committed_step = physics_step
	_cached_frame = frame
	return frame


func enable_test_input_seam() -> void:
	_test_input_seam_enabled = true


func set_test_mouse_captured(captured: bool) -> void:
	_test_input_seam_enabled = true
	_test_mouse_mode_override = Input.MOUSE_MODE_CAPTURED if captured else Input.MOUSE_MODE_VISIBLE


func inject_movement_strengths(left: float, right: float, forward: float, back: float) -> void:
	_test_input_seam_enabled = true
	_test_movement_strengths = Vector4(clampf(left, 0.0, 1.0), clampf(right, 0.0, 1.0), clampf(forward, 0.0, 1.0), clampf(back, 0.0, 1.0))
	_test_movement_raw = Vector2(_test_movement_strengths.y - _test_movement_strengths.x, _test_movement_strengths.w - _test_movement_strengths.z)


func inject_action_binding(
	action: PlayerCommandFrame.Action,
	binding_index: int,
	is_down: bool,
	is_echo: bool = false
) -> void:
	_test_input_seam_enabled = true
	if is_echo and is_down:
		return
	if action < 0 or action >= PlayerCommandFrame.Action.COUNT:
		return
	var safe_binding_index := clampi(binding_index, 0, 30)
	var binding_flag := 1 << safe_binding_index
	var action_index := int(action)
	var previous_mask: int = _test_action_binding_masks[action_index]
	var next_mask := previous_mask
	if is_down:
		next_mask |= binding_flag
	else:
		next_mask &= ~binding_flag
	_test_action_binding_masks[action_index] = next_mask

	var was_down := previous_mask != 0
	var is_now_down := next_mask != 0
	if was_down == is_now_down:
		return
	if _enabled and _focus_is_active and not _rearm_required:
		_set_action_held(action, is_now_down)


func inject_mouse_motion(screen_relative: Vector2) -> void:
	_test_input_seam_enabled = true
	if _enabled and _focus_is_active and not _rearm_required:
		_pending_look_delta_radians += Vector2(
			-screen_relative.x * mouse_sensitivity,
			-screen_relative.y * mouse_sensitivity * (-1.0 if invert_mouse_y else 1.0)
		)


func inject_pan_motion(pan_delta: Vector2) -> void:
	_test_input_seam_enabled = true
	if _enabled and _focus_is_active and not _rearm_required:
		_pending_look_delta_radians += Vector2(
			-pan_delta.x * trackpad_pan_sensitivity,
			-pan_delta.y * trackpad_pan_sensitivity * (-1.0 if invert_mouse_y else 1.0)
		)


func notify_focus_lost() -> void:
	_on_window_focus_exited()


func notify_focus_restored() -> void:
	_on_window_focus_entered()


func _input(event: InputEvent) -> void:
	if not _initialized:
		return

	if event.is_action_pressed(&"ui_cancel", false):
		_release_mouse_capture()
		_clear_pending_input()
		return

	if event is InputEventMouseButton:
		var mouse_button := event as InputEventMouseButton
		if mouse_button.pressed and not _is_mouse_captured():
			_capture_mouse()
			return

	if not _enabled or not _focus_is_active or _rearm_required:
		return

	if event is InputEventMouseMotion and _is_mouse_captured():
		var mouse_motion := event as InputEventMouseMotion
		_pending_look_delta_radians += Vector2(
			-mouse_motion.screen_relative.x * mouse_sensitivity,
			-mouse_motion.screen_relative.y * mouse_sensitivity * (-1.0 if invert_mouse_y else 1.0)
		)
		return

	if event is InputEventPanGesture and _is_mouse_captured():
		var pan_gesture := event as InputEventPanGesture
		_pending_look_delta_radians += Vector2(
			-pan_gesture.delta.x * trackpad_pan_sensitivity,
			-pan_gesture.delta.y * trackpad_pan_sensitivity * (-1.0 if invert_mouse_y else 1.0)
		)
		return

	if event is InputEventKey and (event as InputEventKey).echo:
		return
	_update_action_from_event(event, PlayerCommandFrame.Action.JUMP, &"jump")
	_update_action_from_event(event, PlayerCommandFrame.Action.GRAPPLE, &"fire_grapple")
	_update_action_from_event(event, PlayerCommandFrame.Action.ATTACK, &"attack")


func _update_action_from_event(
	event: InputEvent,
	action: PlayerCommandFrame.Action,
	action_name: StringName
) -> void:
	if event.is_action_pressed(action_name, false):
		_set_action_held(action, true)
	elif event.is_action_released(action_name, false) and not Input.is_action_pressed(action_name):
		_set_action_held(action, false)


func _set_action_held(action: PlayerCommandFrame.Action, is_down: bool) -> void:
	var action_flag := _action_flag(action)
	var was_down := (_held_flags & action_flag) != 0
	if was_down == is_down:
		return
	if is_down:
		_held_flags |= action_flag
		_pending_pressed_flags |= action_flag
	else:
		_held_flags &= ~action_flag
		_pending_released_flags |= action_flag


func _get_movement_axis() -> Vector2:
	if _test_input_seam_enabled:
		return _apply_circular_deadzone(_test_movement_raw, 0.5)
	return Input.get_vector(&"move_left", &"move_right", &"move_forward", &"move_back")


func _apply_circular_deadzone(raw_axis: Vector2, deadzone: float) -> Vector2:
	var length := raw_axis.length()
	if length <= deadzone:
		return Vector2.ZERO
	return (raw_axis.normalized() * ((length - deadzone) / (1.0 - deadzone))).limit_length(1.0)


func _controls_are_neutral() -> bool:
	if _test_input_seam_enabled:
		return (
			_test_movement_strengths == Vector4.ZERO
			and _test_action_binding_masks[0] == 0
			and _test_action_binding_masks[1] == 0
			and _test_action_binding_masks[2] == 0
		)
	for action_name in [&"move_left", &"move_right", &"move_forward", &"move_back"]:
		if Input.is_action_pressed(action_name):
			return false
	return (
		not Input.is_action_pressed(&"jump")
		and not Input.is_action_pressed(&"fire_grapple")
		and not Input.is_action_pressed(&"attack")
	)


func _is_move_forward_held() -> bool:
	if _test_input_seam_enabled:
		return _test_movement_strengths.z > 0.5
	return Input.is_action_pressed(&"move_forward")


func _build_aim_world_direction() -> Vector3:
	var pitch_basis := Basis(Vector3.RIGHT, _canonical_pitch_radians)
	var yaw_basis := Basis(Vector3.UP, _canonical_yaw_radians)
	return (yaw_basis * pitch_basis * Vector3.FORWARD).normalized()


func _apply_pending_look_delta() -> void:
	if _pending_look_delta_radians == Vector2.ZERO:
		return
	_canonical_yaw_radians += _pending_look_delta_radians.x
	_canonical_pitch_radians = clampf(
		_canonical_pitch_radians + _pending_look_delta_radians.y,
		minf(pitch_min_radians, pitch_max_radians),
		maxf(pitch_min_radians, pitch_max_radians)
	)


func _capture_mouse() -> void:
	if _test_mouse_mode_override >= 0:
		_test_mouse_mode_override = Input.MOUSE_MODE_CAPTURED
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


func _release_mouse_capture() -> void:
	if _test_mouse_mode_override >= 0:
		_test_mouse_mode_override = Input.MOUSE_MODE_VISIBLE
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func _is_mouse_captured() -> bool:
	if _test_mouse_mode_override >= 0:
		return _test_mouse_mode_override == Input.MOUSE_MODE_CAPTURED
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED


func _connect_window_focus_signals() -> void:
	if _window_focus_connected or not is_inside_tree():
		return
	var window := get_window()
	if window == null:
		return
	window.focus_exited.connect(_on_window_focus_exited)
	window.focus_entered.connect(_on_window_focus_entered)
	_window_focus_connected = true


func _on_window_focus_exited() -> void:
	_focus_is_active = false
	_rearm_required = true
	_clear_pending_input()


func _on_window_focus_entered() -> void:
	_focus_is_active = true
	_rearm_required = true
	_clear_pending_input()


func _clear_pending_input() -> void:
	_held_flags = 0
	_pending_pressed_flags = 0
	_pending_released_flags = 0
	_pending_look_delta_radians = Vector2.ZERO


func _action_flag(action: PlayerCommandFrame.Action) -> int:
	return 1 << int(action)


func _fail_initialization(status: InitializationStatus, message: String) -> InitializationStatus:
	initialization_status = status
	initialization_error = message
	push_error(message)
	return status
