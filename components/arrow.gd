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
	_update_effects()

func _can_be_activated() -> bool:
	if _disable_interaction:
		return false
	return Global.state == Global.State.AFTER_FLIP

func _update_effects() -> void:
	if _disable_interaction:
		_FX.stop_flashing()
		_FX.stop_glowing()
		return
	
	if Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
		_FX.start_glowing(Color.GOLD, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, FX.DEFAULT_GLOW_MINIMUM, false)
	elif _can_be_activated():
		_FX.start_glowing(Color.AZURE, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, FX.FAST_GLOW_MINIMUM, false)
	else:
		_FX.stop_glowing()
	
	if Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
		_FX.start_flashing(Color.GOLD, FX.DEFAULT_FLASH_SPEED, FX.DEFAULT_FLASH_BOUND1, FX.DEFAULT_FLASH_BOUND2, false)
	elif _mouse_over and _can_be_activated():
		_FX.start_flashing(Color.AZURE, FX.DEFAULT_FLASH_SPEED, FX.DEFAULT_FLASH_BOUND1, FX.DEFAULT_FLASH_BOUND2, false)
	else:
		_FX.stop_flashing()

static var _once_per_frame = false
func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if _disable_interaction:
		return
	if _once_per_frame:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and _can_be_activated():
				assert(_mouse_over)
				_once_per_frame = true
				if Global.active_coin_power_family != Global.POWER_FAMILY_ARROW_REFLIP:
					_FX.flash(Color.GOLD)
				emit_signal("clicked")

func _on_clickable_area_mouse_entered():
	if not _disable_interaction:
		UITooltip.create(self, "[color=purple]Arrow of Night[/color] [color=yellow](%d/%d)[/color]\nReflip a coin." % [Global.arrows, Global.ARROWS_LIMIT], get_global_mouse_position(), get_tree().root)
	_mouse_over = true
	
func _on_clickable_area_mouse_exited():
	_mouse_over = false

func disable_interaction() -> void:
	_disable_interaction = true

func enable_interaction() -> void:
	_disable_interaction = false

func _process(_delta):
	_once_per_frame = false
