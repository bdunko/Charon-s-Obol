extends Node2D

@export var coin_row: CoinRow

@onready var _COIN_LIMIT = $CoinLimit
@onready var _ARROW_COUNT = $ArrowCount

func _ready():
	Global.info_view_toggled.connect(_on_info_view_toggled)
	_on_info_view_toggled()

const _RED = "#e12f3b"
const _GRAY = "#b3b9d1"
const _ARROW_FORMAT = "[center]%d/%d[img=12x13]res://assets/icons/arrow_icon.png[/img][/center]"
const _COIN_LIMIT_FORMAT = "[center][color=%s]%d/%d[img=12x13]res://assets/icons/coin_icon.png[/img][/color][/center]"
func _on_info_view_toggled() -> void:
	_ARROW_COUNT.text = _ARROW_FORMAT % [Global.arrows, Global.ARROWS_LIMIT]
	var num_coins = coin_row.get_child_count()
	_COIN_LIMIT.text = _COIN_LIMIT_FORMAT % [_RED if Global.COIN_LIMIT == num_coins else _GRAY, num_coins, Global.COIN_LIMIT]
	_ARROW_COUNT.visible = Global.info_view_active and Global.arrows != 0
	_COIN_LIMIT.visible = Global.info_view_active
