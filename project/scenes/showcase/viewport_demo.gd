extends Node3D
## 3D Showcase scene with lighting presets and shader variants

signal lighting_changed(preset: String)
signal shader_changed(preset: String)

@export_group("Demo Object")
@export var demo_mesh: MeshInstance3D
@export var auto_rotate_object: bool = true
@export var object_rotation_speed: float = 0.3

@export_group("Materials")
@export var material_presets: Dictionary = {}  # name -> Material

@export_group("Lighting")
@export var main_light: DirectionalLight3D
@export var fill_light: DirectionalLight3D
@export var rim_light: DirectionalLight3D

# Lighting presets
const LIGHTING_PRESETS := {
	"studio": {
		"main_rotation": Vector3(-45, -45, 0),
		"main_energy": 1.0,
		"main_color": Color(1.0, 0.98, 0.95),
		"fill_energy": 0.3,
		"rim_energy": 0.5,
		"ambient": Color(0.1, 0.1, 0.12),
	},
	"dramatic": {
		"main_rotation": Vector3(-30, -90, 0),
		"main_energy": 1.5,
		"main_color": Color(1.0, 0.9, 0.8),
		"fill_energy": 0.1,
		"rim_energy": 0.8,
		"ambient": Color(0.05, 0.05, 0.08),
	},
	"soft": {
		"main_rotation": Vector3(-60, -30, 0),
		"main_energy": 0.8,
		"main_color": Color(1.0, 1.0, 1.0),
		"fill_energy": 0.5,
		"rim_energy": 0.3,
		"ambient": Color(0.15, 0.15, 0.18),
	},
	"sunset": {
		"main_rotation": Vector3(-15, -120, 0),
		"main_energy": 1.2,
		"main_color": Color(1.0, 0.7, 0.4),
		"fill_energy": 0.2,
		"rim_energy": 0.6,
		"ambient": Color(0.1, 0.08, 0.15),
	},
}

var _current_lighting := "studio"
var _current_shader := "default"
var _world_env: WorldEnvironment


func _ready() -> void:
	_setup_environment()
	_setup_default_materials()

	SignalBus.lighting_preset_changed.connect(set_lighting_preset)
	SignalBus.shader_preset_changed.connect(set_shader_preset)

	set_lighting_preset("studio")


func _process(delta: float) -> void:
	if auto_rotate_object and demo_mesh:
		demo_mesh.rotate_y(object_rotation_speed * delta)


func _setup_environment() -> void:
	_world_env = WorldEnvironment.new()
	var env := Environment.new()

	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.08, 0.08, 0.1)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.1, 0.1, 0.12)
	env.ambient_light_energy = 1.0

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.0
	env.tonemap_white = 6.0

	env.ssao_enabled = true
	env.ssao_radius = 1.0
	env.ssao_intensity = 1.0

	env.glow_enabled = true
	env.glow_intensity = 0.5
	env.glow_bloom = 0.1

	_world_env.environment = env
	add_child(_world_env)


func _setup_default_materials() -> void:
	if not demo_mesh:
		return

	# Default PBR material
	var default_mat := StandardMaterial3D.new()
	default_mat.albedo_color = Color(0.8, 0.8, 0.85)
	default_mat.metallic = 0.0
	default_mat.roughness = 0.4

	# Metallic preset
	var metallic_mat := StandardMaterial3D.new()
	metallic_mat.albedo_color = Color(0.9, 0.9, 0.95)
	metallic_mat.metallic = 1.0
	metallic_mat.roughness = 0.2

	# Glossy preset
	var glossy_mat := StandardMaterial3D.new()
	glossy_mat.albedo_color = Color(0.2, 0.4, 0.8)
	glossy_mat.metallic = 0.0
	glossy_mat.roughness = 0.05

	# Matte preset
	var matte_mat := StandardMaterial3D.new()
	matte_mat.albedo_color = Color(0.6, 0.55, 0.5)
	matte_mat.metallic = 0.0
	matte_mat.roughness = 0.9

	# Emissive preset
	var emissive_mat := StandardMaterial3D.new()
	emissive_mat.albedo_color = Color(0.1, 0.1, 0.1)
	emissive_mat.emission_enabled = true
	emissive_mat.emission = Color(0.2, 0.5, 1.0)
	emissive_mat.emission_energy_multiplier = 2.0

	material_presets = {
		"default": default_mat,
		"metallic": metallic_mat,
		"glossy": glossy_mat,
		"matte": matte_mat,
		"emissive": emissive_mat,
	}


func set_lighting_preset(preset_name: String) -> void:
	if preset_name not in LIGHTING_PRESETS:
		return

	var preset: Dictionary = LIGHTING_PRESETS[preset_name]
	_current_lighting = preset_name

	if main_light:
		main_light.rotation_degrees = preset.main_rotation
		main_light.light_energy = preset.main_energy
		main_light.light_color = preset.main_color

	if fill_light:
		fill_light.light_energy = preset.fill_energy

	if rim_light:
		rim_light.light_energy = preset.rim_energy

	if _world_env and _world_env.environment:
		_world_env.environment.ambient_light_color = preset.ambient

	lighting_changed.emit(preset_name)


func set_shader_preset(preset_name: String) -> void:
	if demo_mesh and preset_name in material_presets:
		demo_mesh.material_override = material_presets[preset_name]
		_current_shader = preset_name
		shader_changed.emit(preset_name)


func get_available_lighting_presets() -> Array[String]:
	var presets: Array[String] = []
	for key in LIGHTING_PRESETS.keys():
		presets.append(key)
	return presets


func get_available_shader_presets() -> Array[String]:
	var presets: Array[String] = []
	for key in material_presets.keys():
		presets.append(key)
	return presets
