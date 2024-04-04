class_name ShopItem
extends VBoxContainer

signal purchased

@onready var _COIN: CoinEntity = $Coin
@onready var _COST = $Price

func _ready() -> void:
	Global.fragments_count_changed.connect(_update_price_label)

func take_coin() -> CoinEntity:
	var coin = _COIN
	remove_child(coin)
	return coin

func assign_coin(coin: Global.Coin) -> void:
	_COIN.assign_coin(coin)
	_update_price_label()

func _on_coin_clicked(coin: CoinEntity):
	emit_signal("purchased", self, coin.get_store_price())
