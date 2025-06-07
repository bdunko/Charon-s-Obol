# Songs
# Provides a list of songs. Basically a data node.
extends Node

class Song:
	var name
	var stream
	
	func _init(nme: String, strm: AudioStream) -> void:
		name = nme
		stream = strm
	
	func get_stream() -> Resource:
		return stream

var CharonMaliceCasting = Song.new("Charon Malice Casting", preload("res://assets/audio/songs/ambiance/CharonMaliceCasting.wav"))
var HeavyWater = Song.new("Heavy Water", preload("res://assets/audio/songs/ambiance/HeavyWater.wav"))
var LowUnderwater = Song.new("Low Underwater", preload("res://assets/audio/songs/ambiance/LowUnderwater.wav"))
var DarkWind = Song.new("Dark Wind", preload("res://assets/audio/songs/ambiance/DarkWind.wav"))
var Thunderstorm = Song.new("Thunderstorm", preload("res://assets/audio/songs/ambiance/Thunderstorm.wav"))
var VictoryBirds = Song.new("Victory Birds", preload("res://assets/audio/songs/ambiance/VictoryBirds.wav"))

# todo - search for all of these and replace with song api
