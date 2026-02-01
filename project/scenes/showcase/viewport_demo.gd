extends Node3D
## Synapticore Logo - Neural network inspired 3D logo
## Central glowing core with orbiting nodes connected by energy streams

signal lighting_changed(preset: String)
signal shader_changed(preset: String)

@export var core_pulse_speed: float = 1.2
@export var node_orbit_speed: float = 0.15
@export var stream_pulse_speed: float = 2.0

@onready var logo: Node3D = $SynapticoreLogo
@onready var core: MeshInstance3D = $SynapticoreLogo/Core
@onready var nodes_container: Node3D = $SynapticoreLogo/Nodes
@onready var streams_container: Node3D = $SynapticoreLogo/Streams
@onready var particles_container: Node3D = $SynapticoreLogo/Particles
@onready var main_light: DirectionalLight3D = $MainLight
@onready var fill_light: DirectionalLight3D = $FillLight
@onready var rim_light: DirectionalLight3D = $RimLight

var _world_env: WorldEnvironment
var _current_lighting := "studio"
var _current_shader := "default"
var _time: float = 0.0

# Node orbit data - each node orbits independently
var _node_orbits: Array[Dictionary] = []
var _stream_meshes: Array[MeshInstance3D] = []
var _energy_particles: Array[Dictionary] = []

# Lighting presets
const LIGHTING_PRESETS := {
	"studio": {
		"main_rotation": Vector3(-45, -45, 0),
		"main_energy": 0.8,
		"main_color": Color(0.95, 0.97, 1.0),
		"fill_energy": 0.25,
		"rim_energy": 0.4,
		"ambient": Color(0.05, 0.07, 0.12),
	},
	"dramatic": {
		"main_rotation": Vector3(-30, -90, 0),
		"main_energy": 1.2,
		"main_color": Color(0.9, 0.95, 1.0),
		"fill_energy": 0.1,
		"rim_energy": 0.6,
		"ambient": Color(0.02, 0.03, 0.06),
	},
	"soft": {
		"main_rotation": Vector3(-60, -30, 0),
		"main_energy": 0.6,
		"main_color": Color(1.0, 1.0, 1.0),
		"fill_energy": 0.4,
		"rim_energy": 0.3,
		"ambient": Color(0.08, 0.1, 0.15),
	},
	"sunset": {
		"main_rotation": Vector3(-15, -120, 0),
		"main_energy": 1.0,
		"main_color": Color(1.0, 0.8, 0.6),
		"fill_energy": 0.2,
		"rim_energy": 0.5,
		"ambient": Color(0.06, 0.04, 0.08),
	},
}

# Material color presets for the logo
const COLOR_PRESETS := {
	"default": {
		"core": Color(0.15, 0.5, 0.95),
		"pulse": Color(0.4, 0.75, 1.0),
		"nodes": Color(0.3, 0.65, 1.0),
	},
	"metallic": {
		"core": Color(0.7, 0.75, 0.85),
		"pulse": Color(0.9, 0.92, 1.0),
		"nodes": Color(0.8, 0.85, 0.95),
	},
	"glossy": {
		"core": Color(0.1, 0.35, 0.8),
		"pulse": Color(0.3, 0.6, 1.0),
		"nodes": Color(0.2, 0.5, 0.9),
	},
	"matte": {
		"core": Color(0.3, 0.4, 0.5),
		"pulse": Color(0.45, 0.55, 0.65),
		"nodes": Color(0.35, 0.45, 0.55),
	},
	"emissive": {
		"core": Color(0.2, 0.6, 1.0),
		"pulse": Color(0.5, 0.85, 1.0),
		"nodes": Color(0.4, 0.75, 1.0),
	},
}


func _ready() -> void:
	_setup_environment()
	_setup_node_orbits()
	_setup_streams()
	_setup_particles()

	SignalBus.lighting_preset_changed.connect(set_lighting_preset)
	SignalBus.shader_preset_changed.connect(set_shader_preset)
	SignalBus.post_process_changed.connect(set_post_preset)

	# Apply default presets
	set_lighting_preset("studio")
	set_shader_preset("default")


func _process(delta: float) -> void:
	_time += delta

	# Animate node orbits
	_update_node_orbits(delta)

	# Update stream connections
	_update_streams()

	# Animate energy particles
	_update_particles(delta)


func _setup_environment() -> void:
	_world_env = WorldEnvironment.new()
	var env := Environment.new()

	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.03, 0.035, 0.05)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.05, 0.07, 0.12)
	env.ambient_light_energy = 1.0

	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.tonemap_exposure = 1.1
	env.tonemap_white = 6.0

	env.ssao_enabled = true
	env.ssao_radius = 0.5
	env.ssao_intensity = 0.8

	env.glow_enabled = true
	env.glow_intensity = 0.8
	env.glow_bloom = 0.15
	env.glow_blend_mode = Environment.GLOW_BLEND_MODE_ADDITIVE

	_world_env.environment = env
	add_child(_world_env)


func _setup_node_orbits() -> void:
	if not nodes_container:
		return

	var node_meshes := nodes_container.get_children()
	for i in range(node_meshes.size()):
		var node_mesh: MeshInstance3D = node_meshes[i]
		var pos := node_mesh.position

		# Calculate orbit parameters from initial position
		var radius := pos.length()
		var orbit_data := {
			"mesh": node_mesh,
			"radius": radius,
			"base_pos": pos.normalized(),
			"speed": 0.1 + randf() * 0.1,
			"phase": randf() * TAU,
			"axis": Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5).normalized(),
			"wobble": randf() * 0.3,
		}
		_node_orbits.append(orbit_data)


func _setup_streams() -> void:
	if not streams_container:
		return

	_stream_meshes.clear()
	for child in streams_container.get_children():
		if child is MeshInstance3D:
			_stream_meshes.append(child)


func _setup_particles() -> void:
	if not particles_container:
		return

	# Create floating energy particles
	var particle_mat := StandardMaterial3D.new()
	particle_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	particle_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD
	particle_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	particle_mat.albedo_color = Color(0.4, 0.7, 1.0, 0.7)

	var particle_mesh := SphereMesh.new()
	particle_mesh.radius = 0.025
	particle_mesh.height = 0.05
	particle_mesh.radial_segments = 6
	particle_mesh.rings = 4
	particle_mesh.material = particle_mat

	for i in range(12):
		var particle := MeshInstance3D.new()
		particle.mesh = particle_mesh
		particles_container.add_child(particle)

		var particle_data := {
			"mesh": particle,
			"radius": 0.8 + randf() * 0.8,
			"speed": 0.2 + randf() * 0.3,
			"phase": randf() * TAU,
			"axis": Vector3(randf() - 0.5, randf() - 0.5, randf() - 0.5).normalized(),
			"scale_pulse": randf() * TAU,
		}
		_energy_particles.append(particle_data)


func _update_node_orbits(delta: float) -> void:
	for orbit in _node_orbits:
		var mesh: MeshInstance3D = orbit.mesh
		orbit.phase += orbit.speed * delta

		# Orbit around the axis
		var rotation := Quaternion(orbit.axis, orbit.phase)
		var pos: Vector3 = rotation * (orbit.base_pos * orbit.radius)

		# Add subtle wobble
		pos.y += sin(_time * 2.0 + orbit.wobble * TAU) * 0.05

		mesh.position = pos


func _update_streams() -> void:
	if _stream_meshes.is_empty() or _node_orbits.is_empty():
		return

	# Connect streams from core to nodes
	for i in range(mini(_stream_meshes.size(), _node_orbits.size())):
		var stream: MeshInstance3D = _stream_meshes[i]
		var node_pos: Vector3 = _node_orbits[i].mesh.position

		# Position stream at midpoint between core and node
		var midpoint := node_pos * 0.5
		stream.position = midpoint

		# Orient stream to point from core to node
		var direction := node_pos.normalized()
		var length := node_pos.length() - 0.15  # Subtract node radius

		# Create look-at transform
		if direction.length() > 0.001:
			stream.look_at(stream.global_position + direction, Vector3.UP)
			stream.rotate_object_local(Vector3.RIGHT, PI / 2)

		# Scale stream length
		stream.scale = Vector3(1, length, 1)


func _update_particles(delta: float) -> void:
	for particle_data in _energy_particles:
		var mesh: MeshInstance3D = particle_data.mesh
		particle_data.phase += particle_data.speed * delta

		# Orbit
		var rotation := Quaternion(particle_data.axis, particle_data.phase)
		var pos: Vector3 = rotation * (Vector3.FORWARD * particle_data.radius)
		mesh.position = pos

		# Pulse scale
		particle_data.scale_pulse += delta * 3.0
		var scale_factor := 0.8 + sin(particle_data.scale_pulse) * 0.3
		mesh.scale = Vector3.ONE * scale_factor


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
	if preset_name not in COLOR_PRESETS:
		return

	var preset: Dictionary = COLOR_PRESETS[preset_name]
	_current_shader = preset_name

	# Update core material
	if core and core.material_override:
		var mat: ShaderMaterial = core.material_override
		mat.set_shader_parameter("core_color", Color(preset.core.r, preset.core.g, preset.core.b, 1.0))
		mat.set_shader_parameter("pulse_color", Color(preset.pulse.r, preset.pulse.g, preset.pulse.b, 1.0))

		# Adjust emission based on preset
		if preset_name == "emissive":
			mat.set_shader_parameter("base_emission", 4.0)
			mat.set_shader_parameter("pulse_intensity", 2.0)
		elif preset_name == "matte":
			mat.set_shader_parameter("base_emission", 1.0)
			mat.set_shader_parameter("pulse_intensity", 0.5)
		else:
			mat.set_shader_parameter("base_emission", 2.5)
			mat.set_shader_parameter("pulse_intensity", 1.2)

	# Update node materials
	if nodes_container:
		for node_mesh in nodes_container.get_children():
			if node_mesh is MeshInstance3D and node_mesh.material_override:
				var mat: ShaderMaterial = node_mesh.material_override
				var node_color := preset.nodes
				# Slight variation per node
				var variation := randf() * 0.1 - 0.05
				mat.set_shader_parameter("node_color", Color(
					clampf(node_color.r + variation, 0.0, 1.0),
					clampf(node_color.g + variation, 0.0, 1.0),
					clampf(node_color.b + variation, 0.0, 1.0),
					1.0
				))

	# Update stream materials
	if streams_container:
		for stream in streams_container.get_children():
			if stream is MeshInstance3D and stream.mesh:
				var mesh: CylinderMesh = stream.mesh
				if mesh.material:
					var mat: StandardMaterial3D = mesh.material
					mat.albedo_color = Color(preset.nodes.r, preset.nodes.g, preset.nodes.b, 0.5)

	# Update particle colors
	for particle_data in _energy_particles:
		var mesh: MeshInstance3D = particle_data.mesh
		if mesh.mesh and mesh.mesh.material:
			var mat: StandardMaterial3D = mesh.mesh.material
			mat.albedo_color = Color(preset.pulse.r, preset.pulse.g, preset.pulse.b, 0.6)

	shader_changed.emit(preset_name)


func get_available_lighting_presets() -> Array[String]:
	var presets: Array[String] = []
	for key in LIGHTING_PRESETS.keys():
		presets.append(key)
	return presets


func get_available_shader_presets() -> Array[String]:
	var presets: Array[String] = []
	for key in COLOR_PRESETS.keys():
		presets.append(key)
	return presets


func set_post_preset(preset_name: String) -> void:
	if not _world_env or not _world_env.environment:
		return

	var env := _world_env.environment

	match preset_name:
		"none":
			env.tonemap_exposure = 1.1
			env.adjustment_enabled = false
			env.glow_intensity = 0.8
		"warm":
			env.tonemap_exposure = 1.2
			env.adjustment_enabled = true
			env.adjustment_brightness = 1.05
			env.adjustment_contrast = 1.05
			env.adjustment_saturation = 1.1
			env.glow_intensity = 1.0
		"cool":
			env.tonemap_exposure = 1.0
			env.adjustment_enabled = true
			env.adjustment_brightness = 1.0
			env.adjustment_contrast = 1.0
			env.adjustment_saturation = 0.9
			env.glow_intensity = 0.9
		"contrast":
			env.tonemap_exposure = 1.1
			env.adjustment_enabled = true
			env.adjustment_brightness = 1.0
			env.adjustment_contrast = 1.3
			env.adjustment_saturation = 1.15
			env.glow_intensity = 1.2
		"desaturated":
			env.tonemap_exposure = 1.0
			env.adjustment_enabled = true
			env.adjustment_brightness = 1.0
			env.adjustment_contrast = 1.1
			env.adjustment_saturation = 0.3
			env.glow_intensity = 0.6
