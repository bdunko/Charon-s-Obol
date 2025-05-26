# Audio
# Provides an API for playing sound effects and songs.
extends Node

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
# busy sfx players from oldest to newest
var _busy_sfx = {}

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
		player.stream = snd.resource
		player.play()
	
	func _on_stream_finished() -> void:
		emit_signal("finished", self)

func _on_player_finished(player: _SFXPlayer) -> void:
	assert(_busy_sfx[player.sound].has(player))
	assert(not _free_sfx.has(player))
	_busy_sfx[player.sound].erase(player)
	_free_sfx.push_back(player)

func _acquire_player(sfx: SFX.Effect) -> _SFXPlayer:
	# if there are no free players, we need to grab the oldest busy one
	if _free_sfx.size() == 0:
		var old = _busy_sfx.pop_back()
		old.stop()
		_free_sfx.append(old)
	
	var player = _free_sfx.pop_front()
	
	if not _busy_sfx.has(sfx):
		_busy_sfx[sfx] = []
	
	_busy_sfx[sfx].append(player)
	
	return player

func play_sfx(sfx: SFX.Effect) -> void:
	if _busy_sfx.has(sfx) and _busy_sfx[sfx].size() >= sfx.max_instances:
		# we need to stop an existing player, because we've reached the voice count for this sound
		# the 'oldest' player for this sound is the front of the array, so kill it.
		var oldest = _busy_sfx[sfx][0].stop()
	
	_acquire_player(sfx).play(sfx)

func stop_all_sfx(sfx: SFX.Effect) -> void:
	if not _busy_sfx.has(sfx):
		return
	
	while _busy_sfx[sfx].size() != 0:
		var player = _busy_sfx[sfx].pop_front()
		player.stop()
