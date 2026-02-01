extends Node
## Main application state and scene management

enum State { MENU, SHOWCASE, SETTINGS, PAUSED }

var current_state: State = State.MENU:
	set(value):
		var old_state := current_state
		current_state = value
		state_changed.emit(old_state, current_state)

signal state_changed(from: State, to: State)

var _current_scene: Node
var _transition_rect: ColorRect


func _ready() -> void:
	_setup_transition()
	SignalBus.scene_change_requested.connect(_on_scene_change_requested)


func _setup_transition() -> void:
	var canvas := CanvasLayer.new()
	canvas.layer = 100
	add_child(canvas)

	_transition_rect = ColorRect.new()
	_transition_rect.color = Color.BLACK
	_transition_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_rect.set_anchors_preset(Control.PRESET_FULL_RECT)
	_transition_rect.modulate.a = 0.0
	canvas.add_child(_transition_rect)


func change_scene(scene_path: String, use_transition: bool = true) -> void:
	if use_transition:
		await _fade_out()

	get_tree().change_scene_to_file(scene_path)

	if use_transition:
		await _fade_in()

	SignalBus.scene_changed.emit(scene_path.get_file().get_basename())


func _fade_out(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(_transition_rect, "modulate:a", 1.0, duration)
	await tween.finished


func _fade_in(duration: float = 0.3) -> void:
	var tween := create_tween()
	tween.tween_property(_transition_rect, "modulate:a", 0.0, duration)
	await tween.finished


func _on_scene_change_requested(scene_path: String, transition: bool) -> void:
	change_scene(scene_path, transition)


func quit_game() -> void:
	Settings.save_settings()
	get_tree().quit()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		match current_state:
			State.SHOWCASE:
				current_state = State.MENU
			State.SETTINGS:
				current_state = State.MENU
