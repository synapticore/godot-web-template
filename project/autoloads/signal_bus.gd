extends Node
## Global signal bus for loose coupling between systems

# Scene Management
signal scene_change_requested(scene_path: String, transition: bool)
signal scene_changed(scene_name: String)

# Settings
signal settings_updated
signal settings_saved
signal settings_loaded

# Audio
signal music_changed(track_name: String)
signal sfx_played(sfx_name: String)

# Debug
signal debug_toggled(enabled: bool)
signal debug_message(message: String, level: int)

# Showcase specific
signal shader_preset_changed(preset_name: String)
signal lighting_preset_changed(preset_name: String)
signal post_process_changed(preset_name: String)
signal camera_reset_requested
