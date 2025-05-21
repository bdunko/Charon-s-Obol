# SFX
# Provides a list of sound effects. Basically a data node.
extends Node

class Effect:
	var resource
	var _max_instances
	var _instances_active
	
	func _init(res: Resource, max_instances: int) -> void:
		resource = res
		_max_instances = max_instances
		_instances_active = 0
	
	func can_make_instance() -> bool:
		return _instances_active != _max_instances
	
	func increase_instances() -> void:
		assert(can_make_instance)
		_instances_active += 1
	
	func decrease_instances() -> void:
		assert(_instances_active != 0)
		_instances_active -= 1

var MajorButton = Effect.new(preload("res://assets/audio/sounds/SFX MajorButton.wav"), 3)
