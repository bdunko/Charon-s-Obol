class_name PatronToken
extends Control

signal clicked

@onready var _START_POSITION = position
const _SPEED = 5000
const _RETURN_SPEED = 500
const _ROTATION_TIME = 0.15

var _disabled = false
var _activated = false

func _ready():
	Global.state_changed.connect(_on_state_changed)

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _disabled and not _activated and position == _START_POSITION:
				UITooltip.clear_tooltips()
				emit_signal("clicked")

func _on_clickable_area_mouse_entered():
	Global.power_text = "this does nothing"
	Global.power_text_source = self
	if not _activated:
		UITooltip.create(self, "%s (%d)\n%s" % [Global.patron.token_name, Global.patron_uses, Global.patron.description], get_global_mouse_position(), get_tree().root)

func _on_clickable_area_mouse_exited():
	if Global.power_text_source == self:
		Global.power_text = ""

func activate() -> void:
	create_tween().tween_property(self, "rotation_degrees", 90, _ROTATION_TIME)
	Global.active_coin_power = Global.patron.power
	_activated = true

func deactivate() -> void:
	create_tween().tween_property(self, "rotation_degrees", 0, _ROTATION_TIME)
	Global.active_coin_power = null
	_activated = false

func is_activated() -> bool:
	return _activated

func _process(delta) -> void:
	var target = (get_global_mouse_position() - Vector2(size.x/2 + 8, 0)) if _activated else _START_POSITION
	position = position.move_toward(target, (_SPEED if _activated else _RETURN_SPEED) * delta)

func _on_state_changed() -> void:
	if Global.state != Global.State.AFTER_FLIP:
		_disabled = true
	else:
		_disabled = false
