class_name Arrow
extends Sprite2D

signal clicked

var _disabled = false

func _ready():
	Global.state_changed.connect(_on_state_changed)

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _disabled:
				emit_signal("clicked")

func _on_clickable_area_mouse_entered():
	Global.power_text = "Arrow of Light\nReflip a coin."
	Global.power_text_source = self

func _on_clickable_area_mouse_exited():
	if Global.power_text_source == self:
		Global.power_text = ""

func _on_state_changed() -> void:
	if Global.state != Global.State.AFTER_FLIP:
		_disabled = true
	else:
		_disabled = false
