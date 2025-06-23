extends Node2D

@export var floating_label_scene: PackedScene = preload("res://ui/temp_label.tscn")

func spawn_label(text: String, position: Vector2, parent: Node = null) -> void:
	var label_instance = floating_label_scene.instantiate()
	
	label_instance.text = text
	label_instance.position = position
	
	if parent:
		parent.add_child(label_instance)
	else:
		get_tree().current_scene.add_child(label_instance)
