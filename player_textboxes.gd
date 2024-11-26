class_name PlayerTextboxes
extends HBoxContainer

signal button_clicked

@export var ANIMATION_OFFSET = Vector2(0, 15)

@onready var _INITIAL_POSITION = position

func play_animation() -> void:
	for textbox in get_children():
		textbox.disable_clicks()
	position = _INITIAL_POSITION + ANIMATION_OFFSET
	modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(self, "position", _INITIAL_POSITION, 0.07)
	tween.parallel().tween_property(self, "modulate:a", 1.0, 0.04)
	for textbox in get_children():
		tween.tween_callback(textbox.enable_clicks)

func make_visible() -> void:
	show()
	play_animation()

func make_invisible() -> void:
	for textbox in get_children():
		textbox.disable_clicks()
	hide()
