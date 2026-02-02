class_name OrbitCamera
extends Node3D
## Orbit camera for 3D showcase - professional DCC-style controls with momentum

signal camera_moved
signal camera_reset

@export_group("Target")
@export var target: Node3D
@export var target_offset: Vector3 = Vector3.ZERO

@export_group("Distance")
@export var distance: float = 4.0
@export var min_distance: float = 1.5
@export var max_distance: float = 15.0
@export var zoom_factor: float = 0.15  ## Percentage-based zoom (15% per scroll)

@export_group("Rotation")
@export var rotation_speed: float = 0.4  ## Degrees per pixel - much more responsive
@export var min_pitch: float = -85.0
@export var max_pitch: float = 85.0
@export var auto_rotate: bool = false
@export var auto_rotate_speed: float = 0.1

@export_group("Momentum")
@export var momentum_enabled: bool = true
@export var momentum_friction: float = 0.92  ## How fast momentum decays (0.9-0.98)
@export var momentum_threshold: float = 0.1  ## Stop when velocity below this

@export_group("Smoothing")
@export var position_smoothing: float = 15.0  ## Snappier zoom
@export var rotation_smoothing: float = 18.0  ## More responsive rotation

var _yaw: float = 0.0
var _pitch: float = 15.0
var _target_yaw: float = 0.0
var _target_pitch: float = 15.0
var _target_distance: float = 4.0
var _is_dragging: bool = false

# Momentum tracking
var _velocity_yaw: float = 0.0
var _velocity_pitch: float = 0.0
var _last_drag_delta: Vector2 = Vector2.ZERO

@onready var _camera: Camera3D = $Camera3D


func _ready() -> void:
	_target_distance = distance
	_target_yaw = _yaw
	_target_pitch = _pitch

	if not _camera:
		_camera = Camera3D.new()
		add_child(_camera)

	SignalBus.camera_reset_requested.connect(reset_camera)


func _unhandled_input(event: InputEvent) -> void:
	_handle_input(event)


func _input(event: InputEvent) -> void:
	# Also handle in _input for SubViewport compatibility
	_handle_input(event)


func _handle_input(event: InputEvent) -> void:
	# Mouse drag rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_is_dragging = true
				_velocity_yaw = 0.0
				_velocity_pitch = 0.0
			else:
				_is_dragging = false
				# Transfer last drag to momentum
				if momentum_enabled:
					_velocity_yaw = _last_drag_delta.x * rotation_speed
					_velocity_pitch = _last_drag_delta.y * rotation_speed
		# Percentage-based zoom - feels more natural
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_distance = maxf(_target_distance * (1.0 - zoom_factor), min_distance)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_distance = minf(_target_distance * (1.0 + zoom_factor), max_distance)
			get_viewport().set_input_as_handled()

	if event is InputEventMouseMotion and _is_dragging:
		var delta_yaw := -event.relative.x * rotation_speed
		var delta_pitch := -event.relative.y * rotation_speed
		_target_yaw += delta_yaw
		_target_pitch += delta_pitch
		_target_pitch = clampf(_target_pitch, min_pitch, max_pitch)
		_last_drag_delta = event.relative
		camera_moved.emit()

	# Touch support
	if event is InputEventScreenDrag:
		var delta_yaw := -event.relative.x * rotation_speed
		var delta_pitch := -event.relative.y * rotation_speed
		_target_yaw += delta_yaw
		_target_pitch += delta_pitch
		_target_pitch = clampf(_target_pitch, min_pitch, max_pitch)
		_last_drag_delta = event.relative
		camera_moved.emit()

	# Pinch zoom (touch) - percentage based
	if event is InputEventMagnifyGesture:
		_target_distance = clampf(
			_target_distance / event.factor,
			min_distance,
			max_distance
		)
		get_viewport().set_input_as_handled()

	# Pan gesture (two-finger scroll on trackpad) for zoom
	if event is InputEventPanGesture:
		var zoom_delta := event.delta.y * zoom_factor * 0.5
		_target_distance = clampf(
			_target_distance * (1.0 + zoom_delta),
			min_distance,
			max_distance
		)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	# Apply momentum when not dragging
	if momentum_enabled and not _is_dragging:
		if absf(_velocity_yaw) > momentum_threshold or absf(_velocity_pitch) > momentum_threshold:
			_target_yaw += _velocity_yaw
			_target_pitch += _velocity_pitch
			_target_pitch = clampf(_target_pitch, min_pitch, max_pitch)

			# Apply friction
			_velocity_yaw *= momentum_friction
			_velocity_pitch *= momentum_friction

			# Stop when too slow
			if absf(_velocity_yaw) < momentum_threshold:
				_velocity_yaw = 0.0
			if absf(_velocity_pitch) < momentum_threshold:
				_velocity_pitch = 0.0

	# Auto rotation (only when no momentum and not dragging)
	if auto_rotate and not _is_dragging and absf(_velocity_yaw) < momentum_threshold:
		_target_yaw += auto_rotate_speed * delta

	# Smooth interpolation - use exp decay for consistent feel regardless of framerate
	var rot_factor := 1.0 - exp(-rotation_smoothing * delta)
	var pos_factor := 1.0 - exp(-position_smoothing * delta)

	_yaw = lerpf(_yaw, _target_yaw, rot_factor)
	_pitch = lerpf(_pitch, _target_pitch, rot_factor)
	distance = lerpf(distance, _target_distance, pos_factor)

	# Calculate camera position
	var target_pos := Vector3.ZERO
	if target:
		target_pos = target.global_position + target_offset

	var offset := Vector3.ZERO
	offset.x = distance * cos(deg_to_rad(_pitch)) * sin(deg_to_rad(_yaw))
	offset.y = distance * sin(deg_to_rad(_pitch))
	offset.z = distance * cos(deg_to_rad(_pitch)) * cos(deg_to_rad(_yaw))

	global_position = target_pos + offset
	look_at(target_pos, Vector3.UP)


func reset_camera() -> void:
	_target_yaw = 0.0
	_target_pitch = 15.0
	_target_distance = 4.0
	_velocity_yaw = 0.0
	_velocity_pitch = 0.0
	camera_reset.emit()


func set_preset(yaw: float, pitch: float, dist: float) -> void:
	_target_yaw = yaw
	_target_pitch = pitch
	_target_distance = dist


func get_camera() -> Camera3D:
	return _camera
