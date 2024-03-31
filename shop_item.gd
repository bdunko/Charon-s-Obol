class_name ShopItem
extends VBoxContainer

signal purchased

@onready var _COIN: CoinEntity = $Coin
@onready var _COST = $Cost
@onready var _SUBTITLE = $Subtitle
@onready var _DESCRIPTION = $Description

func take_coin() -> CoinEntity:
	var coin = _COIN
	remove_child(coin)
	return coin

func assign_coin(coin: Global.Coin) -> void:
	_COIN.assign_coin(coin)
	
	# update cost/subtitle/description
	_COST.text = "Price: %s Frags" % coin.get_store_price()
	_SUBTITLE.text = coin.get_store_subtitle()
	_DESCRIPTION.text = coin.get_store_description()

func _on_coin_clicked(coin: CoinEntity):
	emit_signal("purchased", self, coin.get_store_price())
