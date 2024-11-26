class_name Arrow
extends Control

signal clicked

@onready var _FX = $Sprite/FX

var _disable_interaction = false:
	set(val):
		_disable_interaction = val
		_update_effects()

var _mouse_over = false:
	set(val):
		_mouse_over = val
		_update_effects()

func _ready():
	assert(_FX)
	Global.state_changed.connect(_update_effects)
	Global.active_coin_power_family_changed.connect(_update_effects)

func _can_be_activated() -> bool:
	if _disable_interaction:
		return true
	return Global.state == Global.State.AFTER_FLIP and Global.active_coin_power_family == null

func _update_effects() -> void:
	if _disable_interaction:
		_FX.stop_flashing()
		_FX.stop_glowing()
		return
	
	if Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
		_FX.start_flashing(Color.GOLD, FX.DEFAULT_FLASH_SPEED, FX.DEFAULT_FLASH_BOUND1, FX.DEFAULT_FLASH_BOUND2, false)
	elif _can_be_activated():
		_FX.start_flashing(Color.AZURE, 10, 0.1, 0.2)
	else:
		_FX.stop_flashing()
	
	if Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
		_FX.start_glowing(Color.GOLD, FX.DEFAULT_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, FX.DEFAULT_GLOW_MINIMUM, false)
	elif _mouse_over and _can_be_activated():
		_FX.start_glowing(Color.AZURE)
	else:
		_FX.stop_glowing()

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if _disable_interaction:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _can_be_activated():
				assert(_mouse_over)
				emit_signal("clicked")
				_FX.flash(Color.GOLD)

func _on_clickable_area_mouse_entered():
	if not _disable_interaction:
		UITooltip.create(self, "[color=purple]Arrow of Night (%d)[/color]\nReflip a coin." % Global.arrows, get_global_mouse_position(), get_tree().root)
	_mouse_over = true
	
func _on_clickable_area_mouse_exited():
	_mouse_over = false

func disable_interaction() -> void:
	_disable_interaction = true

func enable_interaction() -> void:
	_disable_interaction = false
