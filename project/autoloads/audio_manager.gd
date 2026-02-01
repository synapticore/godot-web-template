extends Node
## Centralized audio management with bus control

var _music_player: AudioStreamPlayer
var _sfx_players: Array[AudioStreamPlayer] = []
var _sfx_pool_size: int = 8

var _current_music: AudioStream
var _music_tween: Tween


func _ready() -> void:
	_setup_music_player()
	_setup_sfx_pool()


func _setup_music_player() -> void:
	_music_player = AudioStreamPlayer.new()
	_music_player.bus = "Music"
	add_child(_music_player)


func _setup_sfx_pool() -> void:
	for i in _sfx_pool_size:
		var player := AudioStreamPlayer.new()
		player.bus = "SFX"
		add_child(player)
		_sfx_players.append(player)


func play_music(stream: AudioStream, fade_duration: float = 0.5) -> void:
	if stream == _current_music and _music_player.playing:
		return

	_current_music = stream

	if _music_tween:
		_music_tween.kill()

	_music_tween = create_tween()

	if _music_player.playing:
		_music_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration * 0.5)
		_music_tween.tween_callback(_music_player.stop)

	_music_tween.tween_callback(func():
		_music_player.stream = stream
		_music_player.volume_db = -40.0
		_music_player.play()
	)
	_music_tween.tween_property(_music_player, "volume_db", 0.0, fade_duration * 0.5)

	SignalBus.music_changed.emit(stream.resource_path.get_file() if stream else "none")


func stop_music(fade_duration: float = 0.5) -> void:
	if not _music_player.playing:
		return

	if _music_tween:
		_music_tween.kill()

	_music_tween = create_tween()
	_music_tween.tween_property(_music_player, "volume_db", -40.0, fade_duration)
	_music_tween.tween_callback(_music_player.stop)

	_current_music = null


func play_sfx(stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 1.0) -> void:
	var player := _get_available_sfx_player()
	if not player:
		return

	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = pitch_scale
	player.play()

	SignalBus.sfx_played.emit(stream.resource_path.get_file() if stream else "unknown")


func _get_available_sfx_player() -> AudioStreamPlayer:
	for player in _sfx_players:
		if not player.playing:
			return player
	return _sfx_players[0]  # Fallback: reuse first


func set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		AudioServer.set_bus_volume_db(idx, linear_to_db(clampf(linear, 0.0, 1.0)))


func get_bus_volume(bus_name: String) -> float:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx >= 0:
		return db_to_linear(AudioServer.get_bus_volume_db(idx))
	return 1.0
