# Audio
# Provides an API for playing sound effects and songs.
extends Node

class MapQueue:
	var _map = {}
	var _queue = []
	
	func erase(key, obj) -> void:
		assert(_queue.has(obj))
		assert(_map[key].has(obj))
		_queue.erase(obj)
		_map[key].erase(obj)
	
	func add(key, obj) -> void:
		_queue.append(obj)
		if not _map.has(key):
			_map[key] = []
		_map[key].append(obj)
	
	func has(obj) -> bool:
		return _queue.has(obj)
	
	func size() -> int:
		return _queue.size()
	
	func size_for(key) -> int:
		if not _map.has(key):
			return 0
		return _map[key].size()
	
	func get_oldest() -> Variant:
		if _queue.size() == 0:
			return null
		return _queue[0]
	
	func get_oldest_for(key) -> Variant:
		if not _map.has(key) or _map[key].size() == 0:
			return null
		
		return _map[key][0]
	
	func get_all_for(key) -> Array:
		if not _map.has(key) or _map[key].size() == 0:
			return []
		return _map[key] 

const _MASTER_BUS = "Master"
const _SFX_BUS = "SFX"

func _ready() -> void:
	# create the sfx players
	for i in N_PLAYERS:
		_create_player()

func _create_player() -> void:
	var player = _SFXPlayer.new(self)
	player.finished.connect(_on_player_finished)
	_free_sfx.append(player)

### SONG API ###
var _songs_map = {}

func play_song(song: Songs.Song, fade_time: float = 1.5, overwrite_starting_playback_time: float = -1.0) -> void:
	if _songs_map.has(song):
		print("Already playing this song! %s" % song.name)
		return
	
	var player = AudioStreamPlayer.new()
	add_child(player)
	_songs_map[song] = player
	player.stream = song.get_stream()
	player.bus = song.get_bus()
	player.volume_db = song.get_volume_adjustment()
	player.play(overwrite_starting_playback_time if overwrite_starting_playback_time >= 0 else song.get_start())
	
	if fade_time > 0:
		player.volume_db = -72
		create_tween().tween_property(player, "volume_db", 0, fade_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)

func stop_song(song: Songs.Song, fade_time: float = 1.5) -> void:
	if not _songs_map.has(song):
		print("Song isn't playing! %s" % song.name)
		return
	
	var player = _songs_map[song]
	_songs_map.erase(song)
	var tween = create_tween().tween_property(player, "volume_db", -72, fade_time).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	await tween.finished
	player.queue_free()

# swap two songs with a crossfade. 
# the second song uses the playback position of the first song as its starting position.
# this is intended for dynamic audio uses.
func seamless_swap_song(old_song: Songs.Song, new_song: Songs.Song, fade_time: float = 2.0) -> void:
	if not _songs_map.has(old_song):
		print("Song isn't playing! %s" % old_song.name)
		return
	if _songs_map.has(new_song):
		print("Already playing this song! %s" % new_song.name)
		return
	
	# get playback position of old
	var playback_position = _songs_map[old_song].get_playback_position()
	
	# stop old song
	stop_song(old_song, fade_time)
	
	# play new song at position
	play_song(new_song, fade_time, playback_position)

### SOUND EFFECTS API ###
const N_PLAYERS = 32

# available sfx players from least recently use dto most recently used
var _free_sfx = []
var _busy_sfx = MapQueue.new()

class _SFXPlayer:
	signal finished
	
	var player: AudioStreamPlayer
	var sound: SFX.Effect
	
	func _init(parent) -> void:
		player = AudioStreamPlayer.new()
		parent.add_child(player)
		player.bus = _SFX_BUS
		player.finished.connect(_on_stream_finished)
	
	func stop() -> void:
		player.stop()
		emit_signal("finished", self)
	
	func play(snd: SFX.Effect) -> void:
		sound = snd
		player.stream = snd.get_stream()
		player.pitch_scale = snd.get_pitch_adjustment()
		player.volume_db = snd.get_volume_adjustment()
		player.play()
	
	func _on_stream_finished() -> void:
		emit_signal("finished", self)

func _on_player_finished(player: _SFXPlayer) -> void:
	assert(_busy_sfx.has(player))
	assert(not _free_sfx.has(player))
	_busy_sfx.erase(player.sound, player)
	_free_sfx.push_back(player)

func _acquire_player(sfx: SFX.Effect) -> _SFXPlayer:
	# if there are no free players, we need to stop the oldest busy one
	if _free_sfx.size() == 0:
		var oldest = _busy_sfx.get_oldest()
		if oldest != null:
			oldest.stop()
	
	# case that there are still no free players,
	# create a new player in the system.
	if _free_sfx.size() == 0:
		print("Unable to acquire sound player! Creating new player. %s" % sfx.name)
		_create_player()
	
	var player = _free_sfx.pop_front()
	_busy_sfx.add(sfx, player)
	
	return player

func play_sfx(sfx: SFX.Effect) -> void:
	if _busy_sfx.size_for(sfx) >= sfx.max_instances:
		var oldest = _busy_sfx.get_oldest_for(sfx)
		if oldest != null:
			oldest.stop()
	
	_acquire_player(sfx).play(sfx)
