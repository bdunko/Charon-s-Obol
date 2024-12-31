class_name River
extends Node2D

enum ColorStyle {
	PURPLE, GREEN, RED
}

@onready var _PURPLE = $Purple/FX
@onready var _GREEN = $Green/FX
@onready var _RED = $Red/FX

func reset() -> void:
	_PURPLE.show()
	_GREEN.hide()
	_RED.hide()

func _ready():
	assert(_PURPLE)
	assert(_GREEN)
	assert(_RED)
	reset()

func change_color(colorStyle: ColorStyle, instant: bool) -> void:
	match(colorStyle):
		ColorStyle.PURPLE:
			_PURPLE.fade_in(0.0 if instant else 1.0)
			_GREEN.fade_out(0.0 if instant else 1.0)
			_RED.fade_out(0.0 if instant else 1.0)
		ColorStyle.GREEN:
			_PURPLE.fade_out(0.0 if instant else 1.0)
			_GREEN.fade_in(0.0 if instant else 1.0)
			_RED.fade_out(0.0 if instant else 1.0)
		ColorStyle.RED:
			_PURPLE.fade_out(0.0 if instant else 1.0)
			_GREEN.fade_out(0.0 if instant else 1.0)
			_RED.fade_in(0.0 if instant else 0.5)
