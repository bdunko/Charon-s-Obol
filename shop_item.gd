class_name ShopItem
extends VBoxContainer

signal purchased

var price := 5:
	set(val):
		price = val
		_COST.text = "Price: %s" % price

@onready var _COIN = $Coin
@onready var _COST = $Cost
@onready var _DESCRIPTION = $Description

func take_coin() -> Coin:
	var coin = _COIN
	remove_child(coin)
	return coin

func assign_coin(_coin: Coin) -> void:
	pass # todo
	
	# price
	#description

func _on_coin_clicked():
	emit_signal("purchased", self, price)
