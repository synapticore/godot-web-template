class_name OrbitCamera
extends Node3D
## Orbit camera for 3D showcase - supports mouse, touch, and scroll zoom

signal camera_moved
signal camera_reset

@export_group("Target")
@export var target: Node3D
@export var target_offset: Vector3 = Vector3.ZERO

@export_group("Distance")
@export var distance: float = 5.0
@export var min_distance: float = 2.0
@export var max_distance: float = 20.0
@export var zoom_speed: float = 0.5

@export_group("Rotation")
@export var rotation_speed: float = 0.005
@export var min_pitch: float = -80.0
@export var max_pitch: float = 80.0
@export var auto_rotate: bool = false
@export var auto_rotate_speed: float = 0.2

@export_group("Smoothing")
@export var position_smoothing: float = 10.0
@export var rotation_smoothing: float = 10.0

var _yaw: float = 0.0
var _pitch: float = 20.0
var _target_yaw: float = 0.0
var _target_pitch: float = 20.0
var _target_distance: float = 5.0
var _is_dragging: bool = false

@onready var _camera: Camera3D = $Camera3D


func _ready() -> void:
	_target_distance = distance
	_target_yaw = _yaw
	_target_pitch = _pitch

	if not _camera:
		_camera = Camera3D.new()
		add_child(_camera)

	SignalBus.camera_reset_requested.connect(reset_camera)


func _input(event: InputEvent) -> void:
	# Mouse drag rotation
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			_target_distance = maxf(_target_distance - zoom_speed, min_distance)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			_target_distance = minf(_target_distance + zoom_speed, max_distance)

	if event is InputEventMouseMotion and _is_dragging:
		_target_yaw -= event.relative.x * rotation_speed
		_target_pitch -= event.relative.y * rotation_speed
		_target_pitch = clampf(_target_pitch, min_pitch, max_pitch)
		camera_moved.emit()

	# Touch support
	if event is InputEventScreenDrag:
		_target_yaw -= event.relative.x * rotation_speed
		_target_pitch -= event.relative.y * rotation_speed
		_target_pitch = clampf(_target_pitch, min_pitch, max_pitch)
		camera_moved.emit()

	# Pinch zoom (touch)
	if event is InputEventMagnifyGesture:
		_target_distance = clampf(
			_target_distance / event.factor,
			min_distance,
			max_distance
		)


func _process(delta: float) -> void:
	# Auto rotation
	if auto_rotate and not _is_dragging:
		_target_yaw += auto_rotate_speed * delta

	# Smooth interpolation
	_yaw = lerpf(_yaw, _target_yaw, rotation_smoothing * delta)
	_pitch = lerpf(_pitch, _target_pitch, rotation_smoothing * delta)
	distance = lerpf(distance, _target_distance, position_smoothing * delta)

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
	_target_pitch = 20.0
	_target_distance = 5.0
	camera_reset.emit()


func set_preset(yaw: float, pitch: float, dist: float) -> void:
	_target_yaw = yaw
	_target_pitch = pitch
	_target_distance = dist


func get_camera() -> Camera3D:
	return _camera
