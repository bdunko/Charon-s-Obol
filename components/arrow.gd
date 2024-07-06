class_name Arrow
extends Control

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
	UITooltip.create(self, "[color=purple]Arrow of Night (%d)[/color]\nReflip a coin." % Global.arrows, get_global_mouse_position(), get_tree().root)

func _on_clickable_area_mouse_exited():
	pass

func _on_state_changed() -> void:
	if Global.state != Global.State.AFTER_FLIP:
		_disabled = true
	else:
		_disabled = false
