extends Node

# todo - test if we can use the same resource in multiple audio players simultaneously?

const N_PLAYERS = 32
const MASTER_BUS = "master"

class Player:
	signal finished
	
	var player: AudioStreamPlayer
	var sound: Sound
	
	func _init(parent) -> void:
		player = AudioStreamPlayer.new()
		parent.add_child(player)
		player.bus = MASTER_BUS
		player.finished.connect(_on_stream_finished)
	
	func stop() -> void:
		player.stop()
		sound.decrease_instances()
		emit_signal("finished", self)
	
	func play(snd: Sound) -> void:
		sound = snd
		sound.increase_instances()
		player.stream = snd.resource
		player.play()
	
	func _on_stream_finished() -> void:
		sound.decrease_instances()
		emit_signal("finished", self)

class Sound:
	var resource
	var _max_instances
	var _instances_active
	
	func _init(res: Resource, max_instances: int) -> void:
		resource = res
		_max_instances = max_instances
		_instances_active = 0
	
	func increase_instances() -> void:
		assert(_instances_active != _max_instances)
		_instances_active += 1
	
	func decrease_instances() -> void:
		assert(_instances_active != 0)
		_instances_active -= 1

var TEST = Sound.new(preload("res://enemy_row.gd"), 3)

var _free = []
var _busy = []
func _ready():
	# create the audio players
	for i in N_PLAYERS:
		var player = Player.new(self)
		player.finished.connect(_on_player_finished)
		_free.append(player)

func _on_player_finished(player) -> void:
	assert(_busy.has(player))
	assert(not _free.has(player))
	_busy.erase(player)
	_free.push_back(player)

func _acquire_player() -> Player:
	# if there are no free players, we need to grab the oldest busy one
	if _free.size() == 0:
		var old = _busy.pop_back()
		old.stop()
		_free.append(old)
	
	var player = _free.pop_front()
	_busy.append(player)
	return player

func play(sound):
	_acquire_player().play(sound)
