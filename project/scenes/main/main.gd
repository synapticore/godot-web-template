extends Control
## Main scene - Synapticore Studio with professional DCC-style UI

@onready var viewport_container: SubViewportContainer = $ViewportContainer
@onready var sub_viewport: SubViewport = $ViewportContainer/SubViewport

# Properties Panel
@onready var material_options: OptionButton = $PropertiesPanel/PanelMargin/PanelContent/MaterialSection/MaterialOptions
@onready var lighting_options: OptionButton = $PropertiesPanel/PanelMargin/PanelContent/LightingSection/LightingOptions
@onready var post_options: OptionButton = $PropertiesPanel/PanelMargin/PanelContent/PostSection/PostOptions
@onready var reset_button: Button = $PropertiesPanel/PanelMargin/PanelContent/ResetButton

# Status Bar
@onready var material_status: Label = $StatusBar/StatusContent/StatusMargin/StatusLeft/MaterialStatus
@onready var lighting_status: Label = $StatusBar/StatusContent/StatusMargin/StatusLeft/LightingStatus
@onready var post_status: Label = $StatusBar/StatusContent/StatusMargin/StatusLeft/PostStatus

var _viewport_demo: Node3D


func _ready() -> void:
	_setup_viewport()
	_setup_options()
	_connect_signals()


func _setup_viewport() -> void:
	var demo_scene := preload("res://scenes/showcase/viewport_demo.tscn")
	_viewport_demo = demo_scene.instantiate()
	sub_viewport.add_child(_viewport_demo)


func _setup_options() -> void:
	# Material presets
	material_options.clear()
	material_options.add_item("Default", 0)
	material_options.add_item("Metallic", 1)
	material_options.add_item("Glossy", 2)
	material_options.add_item("Matte", 3)
	material_options.add_item("Emissive", 4)

	# Lighting presets
	lighting_options.clear()
	lighting_options.add_item("Studio", 0)
	lighting_options.add_item("Dramatic", 1)
	lighting_options.add_item("Soft", 2)
	lighting_options.add_item("Sunset", 3)

	# Post-processing presets
	post_options.clear()
	post_options.add_item("None", 0)
	post_options.add_item("Warm", 1)
	post_options.add_item("Cool", 2)
	post_options.add_item("High Contrast", 3)
	post_options.add_item("Desaturated", 4)


func _connect_signals() -> void:
	material_options.item_selected.connect(_on_material_selected)
	lighting_options.item_selected.connect(_on_lighting_selected)
	post_options.item_selected.connect(_on_post_selected)


func _on_material_selected(index: int) -> void:
	var presets: Array[String] = ["default", "metallic", "glossy", "matte", "emissive"]
	var display_names: Array[String] = ["Default", "Metallic", "Glossy", "Matte", "Emissive"]
	if index < presets.size():
		SignalBus.shader_preset_changed.emit(presets[index])
		Settings.current_shader_preset = presets[index]
		material_status.text = "Material: " + display_names[index]


func _on_lighting_selected(index: int) -> void:
	var presets: Array[String] = ["studio", "dramatic", "soft", "sunset"]
	var display_names: Array[String] = ["Studio", "Dramatic", "Soft", "Sunset"]
	if index < presets.size():
		SignalBus.lighting_preset_changed.emit(presets[index])
		Settings.current_lighting_preset = presets[index]
		lighting_status.text = "Lighting: " + display_names[index]


func _on_post_selected(index: int) -> void:
	var presets: Array[String] = ["none", "warm", "cool", "contrast", "desaturated"]
	var display_names: Array[String] = ["None", "Warm", "Cool", "Contrast", "Desaturated"]
	if index < presets.size():
		SignalBus.post_process_changed.emit(presets[index])
		Settings.current_post_preset = presets[index]
		post_status.text = "Post: " + display_names[index]


func _on_reset_pressed() -> void:
	SignalBus.camera_reset_requested.emit()
	material_options.select(0)
	lighting_options.select(0)
	post_options.select(0)
	_on_material_selected(0)
	_on_lighting_selected(0)
	_on_post_selected(0)
