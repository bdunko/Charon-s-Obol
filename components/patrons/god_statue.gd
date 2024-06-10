class_name PatronStatue
extends Control

@export var patron_power: Global.Power

signal clicked

var _disabled = false

func _ready():
	assert(patron_power != Global.Power.NONE)

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _disabled:
				emit_signal("clicked", self)

func _on_clickable_area_mouse_entered():
	pass

func _on_clickable_area_mouse_exited():
	pass
