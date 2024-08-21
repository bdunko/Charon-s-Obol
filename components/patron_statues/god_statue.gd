class_name PatronStatue
extends Control

@export var patron_enum: Global.PatronEnum

@onready var _HITBOX = $ClickableArea
@onready var _FX: FX = $Sprite2D/FX

signal clicked

var _disabled = false

func _ready():
	assert(patron_enum != Global.PatronEnum.NONE)
	assert(_HITBOX)
	assert(_FX)

var _mouse_down = false
func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if not _disabled:
				# when we click down, remember. When the click finishes, signal if we're still over it.
				if event.pressed:
					_mouse_down = true
				if not event.pressed and _mouse_down:  
					_mouse_down = false
					emit_signal("clicked", self) 
					_FX.glow(Color.GOLD, 2, false)
					UITooltip.clear_tooltips()

func _on_clickable_area_mouse_entered():
	if not _disabled:
		var patron = Global.patron_for_enum(patron_enum)
		var nme = patron.god_name if patron_enum != Global.PatronEnum.GODLESS else "an [color=gray]Unknown God[/color]"
		var desc = patron.description if patron_enum != Global.PatronEnum.GODLESS else "???"
		UITooltip.create(_HITBOX, "Altar to %s\n%s" % [nme, desc], get_global_mouse_position(), get_tree().root)
		_FX.glow(Color.GHOST_WHITE, 2)

func clear_fx() -> void:
	_FX.clear_all()

func disable() -> void:
	_disabled = true

func _on_clickable_area_mouse_exited():
	_mouse_down = false
	if not _disabled:
		_FX.clear_glow()
