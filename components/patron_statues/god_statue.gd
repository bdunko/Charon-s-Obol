class_name PatronStatue
extends Control

@export var patron_enum: Global.PatronEnum

@onready var _HITBOX = $ClickableArea

signal clicked

var _disabled = false

func _ready():
	assert(patron_enum != Global.PatronEnum.NONE)


func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _disabled:
				emit_signal("clicked", self)

func _on_clickable_area_mouse_entered():
	var patron = Global.patron_for_enum(patron_enum)
	var nme = patron.god_name if patron_enum != Global.PatronEnum.GODLESS else "an [color=gray]Unknown God[/color]"
	var desc = patron.description if patron_enum != Global.PatronEnum.GODLESS else "???"
	UITooltip.create(_HITBOX, "Altar to %s\n%s" % [nme, desc], get_global_mouse_position(), get_tree().root)

func _on_clickable_area_mouse_exited():
	pass
