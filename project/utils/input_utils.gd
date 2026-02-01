class_name InputUtils
## Input handling utilities for responsive controls

# === Mouse ===

static func is_mouse_in_rect(rect: Rect2) -> bool:
	var mouse_pos := get_global_mouse_position()
	return rect.has_point(mouse_pos)


static func get_global_mouse_position() -> Vector2:
	return Engine.get_main_loop().root.get_mouse_position()


static func get_mouse_velocity() -> Vector2:
	return Input.get_last_mouse_velocity()


# === Touch / Web Support ===

static func is_touch_device() -> bool:
	return DisplayServer.is_touchscreen_available()


static func get_touch_drag_distance(event: InputEventScreenDrag) -> Vector2:
	return event.relative


# === Input Mapping ===

static func get_action_strength_bidirectional(negative: String, positive: String) -> float:
	## Get combined strength for bidirectional input (e.g., left/right)
	return Input.get_action_strength(positive) - Input.get_action_strength(negative)


static func get_movement_vector(
	left: String = "ui_left",
	right: String = "ui_right",
	up: String = "ui_up",
	down: String = "ui_down"
) -> Vector2:
	## Get normalized 2D movement vector from input actions
	return Input.get_vector(left, right, up, down)


# === Action State ===

static func is_action_just_pressed_or_repeated(action: String) -> bool:
	## Check for initial press or key repeat (for UI navigation)
	return Input.is_action_just_pressed(action) or (
		Input.is_action_pressed(action) and Input.is_action_just_pressed(action)
	)


# === Deadzone ===

static func apply_deadzone(value: float, deadzone: float = 0.2) -> float:
	## Apply deadzone to analog input
	if absf(value) < deadzone:
		return 0.0
	var sign_v := signf(value)
	return sign_v * (absf(value) - deadzone) / (1.0 - deadzone)


static func apply_deadzone_vector(vec: Vector2, deadzone: float = 0.2) -> Vector2:
	## Apply radial deadzone to 2D input
	var length := vec.length()
	if length < deadzone:
		return Vector2.ZERO
	return vec.normalized() * ((length - deadzone) / (1.0 - deadzone))


# === Web-specific ===

static func request_pointer_lock() -> void:
	## Request pointer lock for FPS-style controls (web)
	if OS.has_feature("web"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


static func release_pointer_lock() -> void:
	## Release pointer lock
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
