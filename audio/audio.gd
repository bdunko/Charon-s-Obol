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

const _MASTER_BUS = "Master"
const _SFX_BUS = "SFX"
const _SONG_BUS = "Song"

func _ready() -> void:
	# create the sfx players
	for i in N_PLAYERS:
		var player = _SFXPlayer.new(self)
		player.finished.connect(_on_player_finished)
		_free_sfx.append(player)
	
	_active_song_player.bus = _SONG_BUS
	_inactive_song_player.bus = _SONG_BUS

### SONG API ###
var _active_song: Songs.Song
var _active_song_player: AudioStreamPlayer = AudioStreamPlayer.new()
var _inactive_song_player: AudioStreamPlayer = AudioStreamPlayer.new()

func play_song(song: Songs.Song) -> void:
	_active_song_player.stop()
	_inactive_song_player.stream = song.resource
	_inactive_song_player.start()
	
	# swap the players
	var new_active = _inactive_song_player
	_inactive_song_player = _active_song_player
	_active_song_player = new_active

func stop_song() -> void:
	_active_song_player.stop()


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
		player.stream = snd.get_resource()
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
		_busy_sfx.get_oldest().stop()
	
	var player = _free_sfx.pop_front()
	_busy_sfx.add(sfx, player)
	
	return player

func play_sfx(sfx: SFX.Effect) -> void:
	if _busy_sfx.size_for(sfx) >= sfx.max_instances:
		_busy_sfx.get_oldest_for(sfx).stop()
	
	_acquire_player(sfx).play(sfx)

func stop_all_sfx(sfx: SFX.Effect) -> void:
	while _busy_sfx.size_for(sfx) != 0:
		_busy_sfx.get_oldest_for(sfx).stop()
