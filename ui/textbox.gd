class_name Textbox
extends MarginContainer

signal clicked

@onready var _TEXT = $TextMargin/Text

func _ready():
	assert(_TEXT)

func set_text(txt: String) -> void:
	_TEXT.text = txt

func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("clicked")
