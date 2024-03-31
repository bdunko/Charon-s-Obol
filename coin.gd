class_name CoinEntity
extends Control

signal clicked

var _coin: Global.Coin:
	set(val):
		_coin = val
		#default a new coin to the heads side; this also updates the coin label/sprite
		_heads = true 

var _heads := true:
	set(val):
		_heads = val
		# todo - power text
		_SIDE_LABEL.text = "+%d Frag" % _coin.get_fragments() if _heads else "-%d Life" % _coin.get_life_loss()
		_SPRITE.color = _HEADS_COLOR if _heads else _TAILS_COLOR
		_NAME_LABEL.text = _coin.get_name()

const _HEADS_COLOR = Color("#6db517")
const _TAILS_COLOR = Color("#ea1e2d")

@onready var _SPRITE = $Sprite
@onready var _SIDE_LABEL = $Sprite/SideLabel
@onready var _NAME_LABEL = $NameLabel

func _ready():
	assert(_SPRITE)
	assert(_SIDE_LABEL)
	assert(_NAME_LABEL)
	_coin = Global.make_coin(Global.CoinType.GENERIC, Global.Denomination.OBOL)

func assign_coin(coin: Global.Coin):
	_coin = coin

func is_heads() -> bool:
	return _heads

func get_store_price() -> int:
	return _coin.get_store_price()

func get_fragments() -> int:
	return _coin.get_fragments()

func get_life_loss() -> int:
	return _coin.get_life_loss()

func get_value() -> int:
	return _coin.get_value()

func flip() -> void:
	_heads = Global.RNG.randi_range(0, 1) == 1 # randomly flip the coin

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("clicked")
