extends Node2D

@export var floating_label_scene: PackedScene = preload("res://ui/temp_label.tscn")

var _active_labels: Array[TempLabel] = []

func spawn_label(text: String, position: Vector2, parent: Node = null) -> void:
	var label_instance: TempLabel = floating_label_scene.instantiate()
	label_instance.text = text
	label_instance.position = position

	if parent:
		parent.add_child(label_instance)
	else:
		get_tree().current_scene.add_child(label_instance)

	_active_labels.append(label_instance)
	label_instance.connect("ready_for_destroy", Callable(self, "_on_label_ready_for_destroy").bind(label_instance))

func _on_label_ready_for_destroy(label: TempLabel) -> void:
	if is_instance_valid(label):
		label.queue_free()
	_active_labels.erase(label)

func destroy_all_labels() -> void:
	for label in _active_labels.duplicate():
		if is_instance_valid(label):
			label.destroy()
