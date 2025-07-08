class_name River
extends Node2D

enum ColorStyle {
	PURPLE, GREEN, RED
}

@onready var _PURPLE_FX: FX = $Purple/FX
@onready var _PURPLE_MOVING_FX: FX = $PurpleMoving/FX
@onready var _GREEN_FX: FX = $Green/FX
@onready var _GREEN_MOVING_FX: FX = $GreenMoving/FX
@onready var _RED_FX: FX = $Red/FX
@onready var _RED_MOVING_FX: FX = $RedMoving/FX
var _current_color: ColorStyle = ColorStyle.PURPLE

const _FADE_TIME = 1.0

func reset() -> void:
	_PURPLE_FX.show()
	_GREEN_FX.hide()
	_RED_FX.hide()

func _ready():
	assert(_PURPLE_FX)
	assert(_GREEN_FX)
	assert(_RED_FX)
	assert(_PURPLE_MOVING_FX)
	assert(_GREEN_MOVING_FX)
	assert(_RED_MOVING_FX)
	
	var PAN_SPEED = -0.25
	_PURPLE_MOVING_FX.set_uniform(FX.Uniform.VEC2_AUTO_PAN_SPEED, Vector2(0, PAN_SPEED))
	_GREEN_MOVING_FX.set_uniform(FX.Uniform.VEC2_AUTO_PAN_SPEED, Vector2(0, PAN_SPEED))
	_RED_MOVING_FX.set_uniform(FX.Uniform.VEC2_AUTO_PAN_SPEED, Vector2(0, PAN_SPEED))
	
	reset()

func change_color(colorStyle: ColorStyle, instant: bool) -> void:
	_current_color = colorStyle
	match(colorStyle):
		ColorStyle.PURPLE:
			if _is_moving:
				_PURPLE_MOVING_FX.fade_in(0.0 if instant else _FADE_TIME)
			else:
				_PURPLE_FX.fade_in(0.0 if instant else _FADE_TIME)
			_GREEN_FX.fade_out(0.0 if instant else _FADE_TIME)
			_GREEN_MOVING_FX.fade_out(0.0 if instant else _FADE_TIME)
			_RED_FX.fade_out(0.0 if instant else _FADE_TIME)
			_RED_MOVING_FX.fade_out(0.0 if instant else _FADE_TIME)
		ColorStyle.GREEN:
			_PURPLE_FX.fade_out(0.0 if instant else _FADE_TIME)
			_PURPLE_MOVING_FX.fade_out(0.0 if instant else _FADE_TIME)
			if _is_moving:
				_GREEN_MOVING_FX.fade_in(0.0 if instant else _FADE_TIME)
			else:
				_GREEN_FX.fade_in(0.0 if instant else _FADE_TIME)
			_RED_FX.fade_out(0.0 if instant else _FADE_TIME)
			_RED_MOVING_FX.fade_out(0.0 if instant else _FADE_TIME)
		ColorStyle.RED:
			_PURPLE_FX.fade_out(0.0 if instant else _FADE_TIME)
			_PURPLE_MOVING_FX.fade_out(0.0 if instant else _FADE_TIME)
			_GREEN_FX.fade_out(0.0 if instant else _FADE_TIME)
			_GREEN_MOVING_FX.fade_out(0.0 if instant else _FADE_TIME)
			if _is_moving:
				_RED_MOVING_FX.fade_in(0.0 if instant else _FADE_TIME)
			else:
				_RED_FX.fade_in(0.0 if instant else _FADE_TIME)

var _is_moving = false
func play_movement_animation() -> void:
	if _is_moving: #only one call at a time
		return
	
	_is_moving = true
	
	match(_current_color):
		ColorStyle.PURPLE:
			_PURPLE_MOVING_FX.fade_in(_FADE_TIME)
			_PURPLE_FX.fade_out(_FADE_TIME)
		ColorStyle.GREEN:
			_GREEN_MOVING_FX.fade_in(_FADE_TIME)
			_GREEN_FX.fade_out(_FADE_TIME)
		ColorStyle.RED:
			_RED_MOVING_FX.fade_in(_FADE_TIME)
			_RED_FX.fade_out(_FADE_TIME)

func stop_movement_animation() -> void:
	if not _is_moving:
		return
	
	match(_current_color):
		ColorStyle.PURPLE:
			_PURPLE_MOVING_FX.fade_out(_FADE_TIME)
			_PURPLE_FX.fade_in(_FADE_TIME)
		ColorStyle.GREEN:
			_GREEN_MOVING_FX.fade_out(_FADE_TIME)
			_GREEN_FX.fade_in(_FADE_TIME)
		ColorStyle.RED:
			_RED_MOVING_FX.fade_out(_FADE_TIME)
			_RED_FX.fade_in(_FADE_TIME)
	
	await Global.delay(_FADE_TIME)
	
	_is_moving = false

