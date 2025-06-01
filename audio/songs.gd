# Songs
# Provides a list of songs. Basically a data node.
extends Node

class Song:
	var name
	var resource
	
	func _init(nme: String, res: Resource) -> void:
		name = nme
		resource = res
	
	func get_resource() -> Resource:
		return resource

var CharonMaliceCasting = Song.new("Charon Malice Casting", preload("res://assets/audio/songs/ambiance/SFX CharonMaliceCastingAudio.wav"))
var HeavyWater = Song.new("Heavy Water", preload("res://assets/audio/songs/ambiance/SFX HeavyWater.wav"))
var Windstorm = Song.new("Windstorm", preload("res://assets/audio/songs/ambiance/SFX Windstorm.wav"))
var Windstorm2 = Song.new("Windstorm2", preload("res://assets/audio/songs/ambiance/SFX Windstorm2.wav"))
var VictoryBirds = Song.new("Victory Birds", preload("res://assets/audio/songs/ambiance/SFX VictoryBirdsCombined.wav"))


# todo - search for all of these and replace with song api
