# Songs
# Provides a list of songs. Basically a data node.
extends Node

class Song:
	var resource
	
	func _init(res: Resource) -> void:
		resource = res

var TEST = Song.new(preload("res://enemy_row.gd"))
