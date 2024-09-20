class_name PatronToken
extends Control

signal clicked

@onready var _FX: FX = $Sprite2D/FX
@onready var _MOUSE: MouseWatcher = $Mouse

@onready var _START_POSITION = position
const _SPEED = 5000
const _RETURN_SPEED = 500
const _ROTATION_TIME = 0.15

var _disabled = false
var _activated = false

func _ready():
	assert(_FX)
	assert(_MOUSE)
	Global.state_changed.connect(_on_state_changed)
	Global.patron_uses_changed.connect(_on_patron_uses_changed)

func _on_mouse_clicked():
	if not _disabled and not _activated and position == _START_POSITION:
		UITooltip.clear_tooltips()
		emit_signal("clicked")

func _on_mouse_entered():
	if not _activated:
		UITooltip.create(self, "%s ([color=yellow]%d/%d[/color])\n%s" % [Global.patron.token_name, Global.patron_uses, Global.PATRON_USES_PER_ROUND[Global.round_count], Global.patron.description], get_global_mouse_position(), get_tree().root)
		if Global.patron_uses != 0 and not _disabled:
			_FX.glow(Color.GOLD, 1, false)

func _on_mouse_exited():
	if Global.patron_uses != 0 and not _activated:
		_FX.glow(Color.WHITE, 1, false)

func activate() -> void:
	create_tween().tween_property(self, "rotation_degrees", 90, _ROTATION_TIME)
	Global.active_coin_power_family = Global.patron.power_family
	_activated = true

func deactivate() -> void:
	create_tween().tween_property(self, "rotation_degrees", 0, _ROTATION_TIME)
	Global.active_coin_power_family = null
	_activated = false

func is_activated() -> bool:
	return _activated

func _on_patron_uses_changed() -> void:
	if Global.patron_uses == 0:
		_FX.clear_glow()
		_FX.clear_tint()
	else:
		_FX.tint(Color.GOLD, 0.4)
		_FX.slow_flash(Color.WHITE)
		if not _activated:
			_FX.glow(Color.WHITE, 1)

func _process(delta) -> void:
	var target = (get_global_mouse_position() - Vector2(size.x/2 + 8, 0)) if _activated else _START_POSITION
	position = position.move_toward(target, (_SPEED if _activated else _RETURN_SPEED) * delta)

func _on_state_changed() -> void:
	if Global.state != Global.State.AFTER_FLIP and Global.state != Global.State.BEFORE_FLIP:
		_FX.clear_glow()
		_FX.clear_tint()
	if Global.state != Global.State.AFTER_FLIP:
		_disabled = true
	else:
		_disabled = false
