class_name OrbitCamera
extends Node3D
## Orbit camera for 3D showcase - supports mouse, touch, and scroll zoom

signal camera_moved
signal camera_reset

@export_group("Target")
@export var target: Node3D
@export var target_offset: Vector3 = Vector3.ZERO

@export_group("Distance")
@export var distance: float = 4.0
@export var min_distance: float = 1.5
@export var max_distance: float = 15.0
@export var zoom_factor: float = 0.15

@export_group("Rotation")
@export var rotation_speed: float = 0.4
@export var min_pitch: float = -85.0
@export var max_pitch: float = 85.0
@export var auto_rotate: bool = false
@export var auto_rotate_speed: float = 0.1

@export_group("Smoothing")
@export var smoothing: float = 15.0

var _yaw: float = 0.0
var _pitch: float = 15.0
var _target_yaw: float = 0.0
var _target_pitch: float = 15.0
var _target_distance: float = 4.0
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


func _unhandled_input(event: InputEvent) -> void:
	_handle_input(event)


func _input(event: InputEvent) -> void:
	_handle_input(event)


func _handle_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_is_dragging = event.pressed
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_target_distance = maxf(_target_distance * (1.0 - zoom_factor), min_distance)
			get_viewport().set_input_as_handled()
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_target_distance = minf(_target_distance * (1.0 + zoom_factor), max_distance)
			get_viewport().set_input_as_handled()

	if event is InputEventMouseMotion and _is_dragging:
		_target_yaw -= event.relative.x * rotation_speed
		_target_pitch -= event.relative.y * rotation_speed
		_target_pitch = clampf(_target_pitch, min_pitch, max_pitch)
		camera_moved.emit()

	if event is InputEventScreenDrag:
		_target_yaw -= event.relative.x * rotation_speed
		_target_pitch -= event.relative.y * rotation_speed
		_target_pitch = clampf(_target_pitch, min_pitch, max_pitch)
		camera_moved.emit()

	if event is InputEventMagnifyGesture:
		_target_distance = clampf(_target_distance / event.factor, min_distance, max_distance)
		get_viewport().set_input_as_handled()

	if event is InputEventPanGesture:
		_target_distance = clampf(_target_distance * (1.0 + event.delta.y * zoom_factor * 0.5), min_distance, max_distance)
		get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	if auto_rotate and not _is_dragging:
		_target_yaw += auto_rotate_speed * delta

	var factor: float = minf(smoothing * delta, 1.0)
	_yaw = lerpf(_yaw, _target_yaw, factor)
	_pitch = lerpf(_pitch, _target_pitch, factor)
	distance = lerpf(distance, _target_distance, factor)

	var target_pos: Vector3 = Vector3.ZERO
	if target:
		target_pos = target.global_position + target_offset

	var offset: Vector3 = Vector3.ZERO
	offset.x = distance * cos(deg_to_rad(_pitch)) * sin(deg_to_rad(_yaw))
	offset.y = distance * sin(deg_to_rad(_pitch))
	offset.z = distance * cos(deg_to_rad(_pitch)) * cos(deg_to_rad(_yaw))

	global_position = target_pos + offset
	look_at(target_pos, Vector3.UP)


func reset_camera() -> void:
	_target_yaw = 0.0
	_target_pitch = 15.0
	_target_distance = 4.0
	camera_reset.emit()


func set_preset(yaw: float, pitch: float, dist: float) -> void:
	_target_yaw = yaw
	_target_pitch = pitch
	_target_distance = dist


func get_camera() -> Camera3D:
	return _camera
