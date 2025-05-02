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
	
	func increase_instances() -> void:
		assert(_instances_active != _max_instances)
		_instances_active += 1
	
	func decrease_instances() -> void:
		assert(_instances_active != 0)
		_instances_active -= 1

var TEST = Effect.new(preload("res://enemy_row.gd"), 3)
