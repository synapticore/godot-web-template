extends Control
## Main scene - Studio template showcase with UI controls

@onready var viewport_container: SubViewportContainer = $VBoxContainer/ViewportContainer
@onready var sub_viewport: SubViewport = $VBoxContainer/ViewportContainer/SubViewport
@onready var shader_button: OptionButton = $VBoxContainer/ControlBar/ShaderButton
@onready var lighting_button: OptionButton = $VBoxContainer/ControlBar/LightingButton
@onready var post_button: OptionButton = $VBoxContainer/ControlBar/PostButton
@onready var settings_button: Button = $VBoxContainer/HeaderBar/SettingsButton
@onready var help_button: Button = $VBoxContainer/HeaderBar/HelpButton
@onready var audio_button: Button = $VBoxContainer/HeaderBar/AudioButton

var _viewport_demo: Node3D
var _post_process_rect: ColorRect
var _color_grade_shader: ShaderMaterial


func _ready() -> void:
	_setup_viewport()
	_setup_controls()
	_setup_post_processing()
	_connect_signals()


func _setup_viewport() -> void:
	# Load and instance the 3D demo scene
	var demo_scene := preload("res://scenes/showcase/viewport_demo.tscn")
	_viewport_demo = demo_scene.instantiate()
	sub_viewport.add_child(_viewport_demo)

	# Connect demo mesh reference
	_viewport_demo.demo_mesh = _viewport_demo.get_node("DemoMesh")
	_viewport_demo.main_light = _viewport_demo.get_node("MainLight")
	_viewport_demo.fill_light = _viewport_demo.get_node("FillLight")
	_viewport_demo.rim_light = _viewport_demo.get_node("RimLight")


func _setup_controls() -> void:
	# Shader presets
	shader_button.clear()
	shader_button.add_item("Default", 0)
	shader_button.add_item("Metallic", 1)
	shader_button.add_item("Glossy", 2)
	shader_button.add_item("Matte", 3)
	shader_button.add_item("Emissive", 4)

	# Lighting presets
	lighting_button.clear()
	lighting_button.add_item("Studio", 0)
	lighting_button.add_item("Dramatic", 1)
	lighting_button.add_item("Soft", 2)
	lighting_button.add_item("Sunset", 3)

	# Post-processing presets
	post_button.clear()
	post_button.add_item("None", 0)
	post_button.add_item("Warm", 1)
	post_button.add_item("Cool", 2)
	post_button.add_item("High Contrast", 3)
	post_button.add_item("Desaturated", 4)


func _setup_post_processing() -> void:
	# Create post-processing overlay for viewport
	var shader := preload("res://resources/shaders/color_grade.gdshader")
	_color_grade_shader = ShaderMaterial.new()
	_color_grade_shader.shader = shader

	_post_process_rect = ColorRect.new()
	_post_process_rect.material = _color_grade_shader
	_post_process_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_post_process_rect.set_anchors_preset(Control.PRESET_FULL_RECT)

	# Add to viewport container (overlays the SubViewport)
	viewport_container.add_child(_post_process_rect)


func _connect_signals() -> void:
	shader_button.item_selected.connect(_on_shader_selected)
	lighting_button.item_selected.connect(_on_lighting_selected)
	post_button.item_selected.connect(_on_post_selected)
	settings_button.pressed.connect(_on_settings_pressed)
	help_button.pressed.connect(_on_help_pressed)
	audio_button.pressed.connect(_on_audio_pressed)


func _on_shader_selected(index: int) -> void:
	var presets := ["default", "metallic", "glossy", "matte", "emissive"]
	if index < presets.size():
		SignalBus.shader_preset_changed.emit(presets[index])
		Settings.current_shader_preset = presets[index]


func _on_lighting_selected(index: int) -> void:
	var presets := ["studio", "dramatic", "soft", "sunset"]
	if index < presets.size():
		SignalBus.lighting_preset_changed.emit(presets[index])
		Settings.current_lighting_preset = presets[index]


func _on_post_selected(index: int) -> void:
	match index:
		0:  # None
			_apply_post_preset(0.0, 1.0, 1.0, Color.WHITE, 0.0)
		1:  # Warm
			_apply_post_preset(0.1, 1.05, 1.1, Color(1.0, 0.95, 0.9), 0.3)
		2:  # Cool
			_apply_post_preset(-0.1, 1.0, 0.95, Color(0.9, 0.95, 1.0), 0.3)
		3:  # High Contrast
			_apply_post_preset(0.0, 1.3, 1.1, Color.WHITE, 0.0)
		4:  # Desaturated
			_apply_post_preset(0.0, 1.1, 0.3, Color.WHITE, 0.0)

	Settings.current_post_preset = post_button.get_item_text(index).to_lower().replace(" ", "_")


func _apply_post_preset(exposure: float, contrast: float, saturation: float, tint: Color, tint_strength: float) -> void:
	_color_grade_shader.set_shader_parameter("exposure", exposure)
	_color_grade_shader.set_shader_parameter("contrast", contrast)
	_color_grade_shader.set_shader_parameter("saturation", saturation)
	_color_grade_shader.set_shader_parameter("tint", tint)
	_color_grade_shader.set_shader_parameter("tint_strength", tint_strength)


func _on_settings_pressed() -> void:
	# TODO: Show settings panel
	print("Settings clicked")


func _on_help_pressed() -> void:
	# TODO: Show help panel
	print("Help clicked - Drag to rotate, scroll to zoom")


func _on_audio_pressed() -> void:
	# Toggle mute
	var master_idx := AudioServer.get_bus_index("Master")
	var is_muted := AudioServer.is_bus_mute(master_idx)
	AudioServer.set_bus_mute(master_idx, not is_muted)
	audio_button.text = "🔇" if not is_muted else "🔊"


func _on_reset_pressed() -> void:
	SignalBus.camera_reset_requested.emit()
	shader_button.select(0)
	lighting_button.select(0)
	post_button.select(0)
	_on_shader_selected(0)
	_on_lighting_selected(0)
	_on_post_selected(0)
