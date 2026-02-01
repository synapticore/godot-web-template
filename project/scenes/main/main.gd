extends Control
## Main scene - Synapticore Studio showcase with polished UI controls

@onready var viewport_container: SubViewportContainer = $VBoxContainer/ViewportContainer
@onready var sub_viewport: SubViewport = $VBoxContainer/ViewportContainer/SubViewport
@onready var shader_button: OptionButton = $VBoxContainer/ControlBarPanel/ControlContent/ControlBar/ShaderGroup/ShaderButton
@onready var lighting_button: OptionButton = $VBoxContainer/ControlBarPanel/ControlContent/ControlBar/LightingGroup/LightingButton
@onready var post_button: OptionButton = $VBoxContainer/ControlBarPanel/ControlContent/ControlBar/PostGroup/PostButton
@onready var settings_button: Button = $VBoxContainer/HeaderBar/HeaderContent/HeaderButtons/SettingsButton
@onready var help_button: Button = $VBoxContainer/HeaderBar/HeaderContent/HeaderButtons/HelpButton
@onready var audio_button: Button = $VBoxContainer/HeaderBar/HeaderContent/HeaderButtons/AudioButton

var _viewport_demo: Node3D
var _is_muted: bool = false


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
	# Post-processing via Environment tonemapping (set in viewport_demo.gd)
	# No overlay needed - avoids SubViewport texture issues in web export
	pass


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
	var presets: Array[String] = ["none", "warm", "cool", "contrast", "desaturated"]
	var preset_name: String = presets[index]
	SignalBus.post_process_changed.emit(preset_name)
	Settings.current_post_preset = preset_name


func _on_settings_pressed() -> void:
	# TODO: Show settings panel
	print("Settings clicked")


func _on_help_pressed() -> void:
	# TODO: Show help panel
	print("Help clicked - Drag to rotate, scroll to zoom")


func _on_audio_pressed() -> void:
	# Toggle mute
	var master_idx := AudioServer.get_bus_index("Master")
	_is_muted = not _is_muted
	AudioServer.set_bus_mute(master_idx, _is_muted)
	audio_button.text = "MUTE" if _is_muted else "VOL"


func _on_reset_pressed() -> void:
	SignalBus.camera_reset_requested.emit()
	shader_button.select(0)
	lighting_button.select(0)
	post_button.select(0)
	_on_shader_selected(0)
	_on_lighting_selected(0)
	_on_post_selected(0)
