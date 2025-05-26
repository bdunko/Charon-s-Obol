# SFX
# Provides a list of sound effects. Basically a data node.
extends Node

class Effect:
	var resource
	var max_instances
	
	func _init(res: Resource, maxinstances: int) -> void:
		resource = res
		max_instances = maxinstances

var MajorButton = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 3)

var CharonMaliceCasting = Effect.new(preload("res://assets/audio/sounds/SFX CharonMaliceCasting.wav"), 1)
