class_name ShopItem
extends VBoxContainer

signal purchased

@onready var _COIN: CoinEntity = $Coin
@onready var _COST = $Price

func take_coin() -> CoinEntity:
	var coin = _COIN
	remove_child(coin)
	return coin

const _PRICE_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
const _UNAFFORDABLE_COLOR = "#e12f3b"
const _AFFORDABLE_COLOR = "#ffffff"
func assign_coin(coin: Global.Coin) -> void:
	_COIN.assign_coin(coin)
	
	# update cost/subtitle/description
	_COST.text = _PRICE_FORMAT % [_AFFORDABLE_COLOR, _COIN.get_store_price()]

func _notify_num_fragments(num_fragments: int) -> void:
	# update color of 
	var price = _COIN.get_store_price()
	_COST.text = _PRICE_FORMAT % [_AFFORDABLE_COLOR if num_fragments >=price else _UNAFFORDABLE_COLOR, price]

func _on_coin_clicked(coin: CoinEntity):
	emit_signal("purchased", self, coin.get_store_price())
