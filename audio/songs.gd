# Songs
# Provides a list of songs. Basically a data node.
extends Node

const _SONG_BUS = "Song"

class Params:
	var _volume_adjustment = 0.0
	var _bus = _SONG_BUS
	
	func bus(b: String) -> Params:
		_bus = b
		return self
	
	func volume(v: float) -> Params:
		_volume_adjustment = v
		return self

class Song:
	var name
	var stream
	var volume_adjustment
	var bus
	
	func _init(nme: String, strm: AudioStream, params: Params = Params.new()) -> void:
		name = nme
		stream = strm
		volume_adjustment = params._volume_adjustment
		bus = params._bus
	
	func get_stream() -> Resource:
		return stream
	
	func get_volume_adjustment() -> float:
		return volume_adjustment
	
	func get_bus() -> String:
		return bus

var CharonMaliceCasting = Song.new("Charon Malice Casting", preload("res://assets/audio/songs/ambiance/CharonMaliceCasting.wav"))
var HeavyWater = Song.new("Heavy Water", preload("res://assets/audio/songs/ambiance/HeavyWater.wav"))
var LowUnderwater = Song.new("Low Underwater", preload("res://assets/audio/songs/ambiance/LowUnderwater.wav"))
var DarkWind = Song.new("Dark Wind", preload("res://assets/audio/songs/ambiance/DarkWind.wav"))
var Thunderstorm = Song.new("Thunderstorm", preload("res://assets/audio/songs/ambiance/Thunderstorm.wav"), Params.new())
var ThunderstormFiltered = Song.new("Thunderstorm Filtered", preload("res://assets/audio/songs/ambiance/Thunderstorm.wav"), Params.new().bus("Storm"))
var VictoryBirds = Song.new("Victory Birds", preload("res://assets/audio/songs/ambiance/VictoryBirds.wav"))

# todo - search for all of these and replace with song api
