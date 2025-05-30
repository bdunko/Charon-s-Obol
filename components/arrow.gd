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
	Global.arrow_count_changed.connect(_update_effects)
	_update_effects()
	_FX.set_uniform(FX.Uniform.FLOAT_FLASH_STRENGTH, 0.0) # this is a bit of a silly brute force that fixes a graphical glitch with arrows...

func _can_be_activated() -> bool:
	if _disable_interaction:
		return false
	return Global.state == Global.State.AFTER_FLIP

func _update_effects() -> void:
	if _disable_interaction:
		_FX.stop_glowing()
		return
	
	if Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
		_FX.start_glowing(Color.GOLD, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, 1.0, false)
	elif _can_be_activated():
		_FX.start_glowing(Color.AZURE, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, 1.0 if _mouse_over else FX.FAST_GLOW_MINIMUM, false)
	else:
		_FX.stop_glowing()

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
		var props = UITooltip.Properties.new().anchor(get_global_rect().get_center()).offset(get_global_rect().size.y / 2.0 + 11).direction(UITooltip.Direction.ABOVE)
		UITooltip.create(self, "[color=purple]Arrow of Night[/color][img=10x13]res://assets/icons/arrow_icon.png[/img] [color=yellow](%d/%d)[/color]\nReflip a coin." % [Global.arrows, Global.ARROWS_LIMIT], get_global_mouse_position(), get_tree().root, props)
	_mouse_over = true
	
func _on_clickable_area_mouse_exited():
	_mouse_over = false

func disable_interaction() -> void:
	_disable_interaction = true

func enable_interaction() -> void:
	_disable_interaction = false

func _process(_delta):
	_once_per_frame = false
