class_name ShowHideChildrenButton
extends Button

@export var start_visible = false

func _ready():
	pressed.connect(_on_pressed)
	for child in get_children():
		child.visible = start_visible

func _on_pressed() -> void:
	for child in get_children():
		child.visible = not child.visible
