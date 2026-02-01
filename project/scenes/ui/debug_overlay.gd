extends CanvasLayer
## Debug overlay for development - toggle with F3

var _visible := false
var _label: Label


func _ready() -> void:
	layer = 99
	_setup_ui()
	SignalBus.debug_toggled.connect(_on_debug_toggled)


func _setup_ui() -> void:
	var panel := PanelContainer.new()
	panel.set_anchors_preset(Control.PRESET_TOP_LEFT)
	panel.position = Vector2(10, 10)
	add_child(panel)

	var margin := MarginContainer.new()
	margin.add_theme_constant_override("margin_left", 10)
	margin.add_theme_constant_override("margin_right", 10)
	margin.add_theme_constant_override("margin_top", 5)
	margin.add_theme_constant_override("margin_bottom", 5)
	panel.add_child(margin)

	_label = Label.new()
	_label.add_theme_font_size_override("font_size", 14)
	margin.add_child(_label)

	panel.visible = false


func _process(_delta: float) -> void:
	if not _visible:
		return

	var fps := Engine.get_frames_per_second()
	var mem := OS.get_static_memory_usage() / 1048576.0
	var draw_calls := RenderingServer.get_rendering_info(
		RenderingServer.RENDERING_INFO_TOTAL_DRAW_CALLS_IN_FRAME
	)

	_label.text = "FPS: %d\nMemory: %.1f MB\nDraw Calls: %d" % [fps, mem, draw_calls]


func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and event.keycode == KEY_F3:
		toggle()


func toggle() -> void:
	_visible = not _visible
	get_child(0).visible = _visible
	SignalBus.debug_toggled.emit(_visible)


func _on_debug_toggled(enabled: bool) -> void:
	_visible = enabled
	get_child(0).visible = enabled
