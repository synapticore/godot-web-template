extends Node3D
## PBR Showcase - Material, Lighting, and Post-processing demo
## Each control actually affects the visual output

signal lighting_changed(preset: String)
signal shader_changed(preset: String)

@onready var world_env: WorldEnvironment = $WorldEnvironment
@onready var showcase_object: Node3D = $ShowcaseObject
@onready var main_sphere: MeshInstance3D = $ShowcaseObject/MainSphere
@onready var accent_ring: MeshInstance3D = $ShowcaseObject/AccentRing
@onready var platform: MeshInstance3D = $Platform
@onready var key_light: DirectionalLight3D = $KeyLight
@onready var fill_light: DirectionalLight3D = $FillLight
@onready var rim_light: DirectionalLight3D = $RimLight

var _current_lighting := "studio"
var _current_material := "default"
var _rotation_speed := 0.3

# Material presets - actual PBR properties
const MATERIAL_PRESETS := {
	"default": {
		"albedo": Color(0.9, 0.92, 0.95),
		"metallic": 0.0,
		"roughness": 0.4,
		"emission": Color(0, 0, 0),
		"emission_energy": 0.0,
	},
	"metallic": {
		"albedo": Color(0.95, 0.95, 0.98),
		"metallic": 1.0,
		"roughness": 0.15,
		"emission": Color(0, 0, 0),
		"emission_energy": 0.0,
	},
	"glossy": {
		"albedo": Color(0.2, 0.5, 0.9),
		"metallic": 0.0,
		"roughness": 0.05,
		"emission": Color(0, 0, 0),
		"emission_energy": 0.0,
	},
	"matte": {
		"albedo": Color(0.7, 0.65, 0.6),
		"metallic": 0.0,
		"roughness": 0.95,
		"emission": Color(0, 0, 0),
		"emission_energy": 0.0,
	},
	"emissive": {
		"albedo": Color(0.1, 0.15, 0.2),
		"metallic": 0.3,
		"roughness": 0.3,
		"emission": Color(0.3, 0.6, 1.0),
		"emission_energy": 3.0,
	},
}

# Lighting presets - change actual light properties
const LIGHTING_PRESETS := {
	"studio": {
		"key_color": Color(1.0, 0.98, 0.95),
		"key_energy": 1.2,
		"key_rotation": Vector3(-35, -45, 0),
		"fill_energy": 0.4,
		"rim_energy": 0.6,
		"ambient": Color(0.15, 0.18, 0.25),
		"ambient_energy": 0.4,
	},
	"dramatic": {
		"key_color": Color(1.0, 0.9, 0.8),
		"key_energy": 2.0,
		"key_rotation": Vector3(-25, -90, 0),
		"fill_energy": 0.1,
		"rim_energy": 1.0,
		"ambient": Color(0.05, 0.05, 0.1),
		"ambient_energy": 0.2,
	},
	"soft": {
		"key_color": Color(1.0, 1.0, 1.0),
		"key_energy": 0.8,
		"key_rotation": Vector3(-60, -30, 0),
		"fill_energy": 0.6,
		"rim_energy": 0.3,
		"ambient": Color(0.2, 0.22, 0.28),
		"ambient_energy": 0.6,
	},
	"sunset": {
		"key_color": Color(1.0, 0.6, 0.3),
		"key_energy": 1.5,
		"key_rotation": Vector3(-10, -120, 0),
		"fill_energy": 0.2,
		"rim_energy": 0.8,
		"ambient": Color(0.15, 0.1, 0.2),
		"ambient_energy": 0.3,
	},
}

# Post-processing presets
const POST_PRESETS := {
	"none": {
		"exposure": 1.0,
		"saturation": 1.0,
		"contrast": 1.0,
		"glow": 0.3,
	},
	"warm": {
		"exposure": 1.1,
		"saturation": 1.15,
		"contrast": 1.05,
		"glow": 0.4,
	},
	"cool": {
		"exposure": 0.95,
		"saturation": 0.85,
		"contrast": 1.0,
		"glow": 0.25,
	},
	"contrast": {
		"exposure": 1.0,
		"saturation": 1.2,
		"contrast": 1.4,
		"glow": 0.5,
	},
	"desaturated": {
		"exposure": 1.0,
		"saturation": 0.2,
		"contrast": 1.15,
		"glow": 0.2,
	},
}


func _ready() -> void:
	# Connect signals
	SignalBus.lighting_preset_changed.connect(set_lighting_preset)
	SignalBus.shader_preset_changed.connect(set_material_preset)
	SignalBus.post_process_changed.connect(set_post_preset)

	# Apply defaults
	set_lighting_preset("studio")
	set_material_preset("default")
	set_post_preset("none")


func _process(delta: float) -> void:
	# Gentle rotation of showcase object
	if showcase_object:
		showcase_object.rotate_y(_rotation_speed * delta)


func set_material_preset(preset_name: String) -> void:
	if preset_name not in MATERIAL_PRESETS:
		return

	var preset: Dictionary = MATERIAL_PRESETS[preset_name]
	_current_material = preset_name

	if main_sphere and main_sphere.material_override:
		var mat: StandardMaterial3D = main_sphere.material_override
		mat.albedo_color = preset.albedo
		mat.metallic = preset.metallic
		mat.roughness = preset.roughness

		if preset.emission_energy > 0:
			mat.emission_enabled = true
			mat.emission = preset.emission
			mat.emission_energy_multiplier = preset.emission_energy
		else:
			mat.emission_enabled = false

	shader_changed.emit(preset_name)


func set_lighting_preset(preset_name: String) -> void:
	if preset_name not in LIGHTING_PRESETS:
		return

	var preset: Dictionary = LIGHTING_PRESETS[preset_name]
	_current_lighting = preset_name

	if key_light:
		key_light.light_color = preset.key_color
		key_light.light_energy = preset.key_energy
		key_light.rotation_degrees = preset.key_rotation

	if fill_light:
		fill_light.light_energy = preset.fill_energy

	if rim_light:
		rim_light.light_energy = preset.rim_energy

	if world_env and world_env.environment:
		var env: Environment = world_env.environment
		env.ambient_light_color = preset.ambient
		env.ambient_light_energy = preset.ambient_energy

	lighting_changed.emit(preset_name)


func set_post_preset(preset_name: String) -> void:
	if preset_name not in POST_PRESETS:
		return

	var preset: Dictionary = POST_PRESETS[preset_name]

	if world_env and world_env.environment:
		var env: Environment = world_env.environment
		env.tonemap_exposure = preset.exposure
		env.glow_intensity = preset.glow

		if preset.saturation != 1.0 or preset.contrast != 1.0:
			env.adjustment_enabled = true
			env.adjustment_saturation = preset.saturation
			env.adjustment_contrast = preset.contrast
		else:
			env.adjustment_enabled = false


func get_available_lighting_presets() -> Array[String]:
	var presets: Array[String] = []
	for key in LIGHTING_PRESETS.keys():
		presets.append(key)
	return presets


func get_available_material_presets() -> Array[String]:
	var presets: Array[String] = []
	for key in MATERIAL_PRESETS.keys():
		presets.append(key)
	return presets
