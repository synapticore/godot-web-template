extends Node
## Persistent settings manager with save/load functionality

const SETTINGS_PATH := "user://settings.cfg"

# Audio
var audio_master: float = 1.0:
	set(value):
		audio_master = clampf(value, 0.0, 1.0)
		_apply_audio()
var audio_music: float = 0.8:
	set(value):
		audio_music = clampf(value, 0.0, 1.0)
		_apply_audio()
var audio_sfx: float = 1.0:
	set(value):
		audio_sfx = clampf(value, 0.0, 1.0)
		_apply_audio()

# Display
var fullscreen: bool = false:
	set(value):
		fullscreen = value
		_apply_display()
var vsync: bool = true:
	set(value):
		vsync = value
		_apply_display()
var ui_scale: float = 1.0

# Showcase
var current_shader_preset: String = "default"
var current_lighting_preset: String = "studio"
var current_post_preset: String = "none"


func _ready() -> void:
	load_settings()


func save_settings() -> void:
	var config := ConfigFile.new()

	config.set_value("audio", "master", audio_master)
	config.set_value("audio", "music", audio_music)
	config.set_value("audio", "sfx", audio_sfx)

	config.set_value("display", "fullscreen", fullscreen)
	config.set_value("display", "vsync", vsync)
	config.set_value("display", "ui_scale", ui_scale)

	config.set_value("showcase", "shader_preset", current_shader_preset)
	config.set_value("showcase", "lighting_preset", current_lighting_preset)
	config.set_value("showcase", "post_preset", current_post_preset)

	var err := config.save(SETTINGS_PATH)
	if err == OK:
		SignalBus.settings_saved.emit()


func load_settings() -> void:
	var config := ConfigFile.new()
	var err := config.load(SETTINGS_PATH)

	if err != OK:
		save_settings()  # Create default settings file
		return

	audio_master = config.get_value("audio", "master", 1.0)
	audio_music = config.get_value("audio", "music", 0.8)
	audio_sfx = config.get_value("audio", "sfx", 1.0)

	fullscreen = config.get_value("display", "fullscreen", false)
	vsync = config.get_value("display", "vsync", true)
	ui_scale = config.get_value("display", "ui_scale", 1.0)

	current_shader_preset = config.get_value("showcase", "shader_preset", "default")
	current_lighting_preset = config.get_value("showcase", "lighting_preset", "studio")
	current_post_preset = config.get_value("showcase", "post_preset", "none")

	SignalBus.settings_loaded.emit()


func _apply_audio() -> void:
	if not AudioServer:
		return
	var master_idx := AudioServer.get_bus_index("Master")
	var music_idx := AudioServer.get_bus_index("Music")
	var sfx_idx := AudioServer.get_bus_index("SFX")

	if master_idx >= 0:
		AudioServer.set_bus_volume_db(master_idx, linear_to_db(audio_master))
	if music_idx >= 0:
		AudioServer.set_bus_volume_db(music_idx, linear_to_db(audio_music))
	if sfx_idx >= 0:
		AudioServer.set_bus_volume_db(sfx_idx, linear_to_db(audio_sfx))

	SignalBus.settings_updated.emit()


func _apply_display() -> void:
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED
	)

	SignalBus.settings_updated.emit()
