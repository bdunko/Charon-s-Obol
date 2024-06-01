class_name Shop
extends Node2D

signal coin_purchased

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _SHOP_ROW = $ShopRow

const _NUM_GENERIC_SHOP_ITEMS = 1
const _NUM_GOD_SHOP_ITEMS = 3

func _ready() -> void:
	assert(_SHOP_ROW)
	Global.state_changed.connect(_on_state_changed)
	
func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		show()
	else:
		hide()

func randomize_shop() -> void:
	for coin in _SHOP_ROW.get_children():
		_SHOP_ROW.remove_child(coin)
		coin.queue_free()
	
	for _i in _NUM_GENERIC_SHOP_ITEMS:
		var coin = _COIN_SCENE.instantiate()
		_SHOP_ROW.add_child(coin)
		coin.assign_coin(Global.make_coin(Global.GENERIC_FAMILY, Global.random_shop_denomination_for_round()), CoinEntity.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)
	
	for _i in _NUM_GOD_SHOP_ITEMS:
		var coin = _COIN_SCENE.instantiate()
		_SHOP_ROW.add_child(coin)
		coin.assign_coin(Global.make_coin(Global.random_god_family(), Global.random_shop_denomination_for_round()), CoinEntity.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)

func _on_try_coin_purchased(coin: CoinEntity) -> void:
	emit_signal("coin_purchased", coin, coin.get_store_price())

# called after main confirms the price can be paid and there are enough coin spaces
func purchase_coin(coin: CoinEntity) -> void:
	Global.souls -= coin.get_store_price()
	coin.clicked.disconnect(_on_try_coin_purchased)
	coin.get_parent().remove_child(coin)
