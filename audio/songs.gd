# Songs
# Provides a list of songs. Basically a data node.
extends Node

const _SONG_BUS = "Song"

class Params:
	var _volume_adjustment = 0.0
	var _bus = _SONG_BUS
	var _start = 0.0 # in seconds
	
	func bus(b: String) -> Params:
		_bus = b
		return self
	
	func volume(v: float) -> Params:
		_volume_adjustment = v
		return self
	
	func start(s: float) -> Params:
		_start = s
		return self

class Song:
	var name
	var stream
	var volume_adjustment
	var bus
	var start
	
	func _init(nme: String, strm: AudioStream, params: Params = Params.new()) -> void:
		name = nme
		stream = strm
		volume_adjustment = params._volume_adjustment
		bus = params._bus
		start = params._start
	
	func get_stream() -> Resource:
		return stream
	
	func get_volume_adjustment() -> float:
		return volume_adjustment
	
	func get_bus() -> String:
		return bus
	
	func get_start() -> float:
		return start

var CharonMaliceCasting = Song.new("Charon Malice Casting", preload("res://assets/audio/songs/ambiance/CharonMaliceCastingStereo.wav"))
var HeavyWater = Song.new("Heavy Water", preload("res://assets/audio/songs/ambiance/HeavyWaterStereo.wav"))
var LowUnderwater = Song.new("Low Underwater", preload("res://assets/audio/songs/ambiance/LowUnderwaterStereo.wav"))
var DarkWind = Song.new("Dark Wind", preload("res://assets/audio/songs/ambiance/DarkWindStereo.wav"))

const _THUNDERSTORM_WAV = "res://assets/audio/songs/ambiance/ThunderstormStereo.wav"
var Thunderstorm = Song.new("Thunderstorm", preload(_THUNDERSTORM_WAV), Params.new().start(1.8).volume(-6.0))
var ThunderstormFiltered = Song.new("Thunderstorm Filtered", preload(_THUNDERSTORM_WAV), Params.new().bus("Storm").volume(-10.0))

var VictoryBirds = Song.new("Victory Birds", preload("res://assets/audio/songs/ambiance/VictoryBirdsStereo.wav"))

# todo - search for all of these and replace with song api
