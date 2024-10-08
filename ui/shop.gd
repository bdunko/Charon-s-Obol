class_name Shop
extends Node2D

signal coin_purchased

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _SHOP_ROW = $ShopRow

const _NUM_GENERIC_SHOP_ITEMS = 1
const _NUM_GOD_SHOP_ITEMS = 3

func _ready() -> void:
	for coin in _SHOP_ROW.get_children():
		_SHOP_ROW.remove_child(coin)
		coin.queue_free()
	
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
		coin.init_coin(Global.GENERIC_FAMILY, Global.random_shop_denomination_for_round(), Coin.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)
	
	for _i in _NUM_GOD_SHOP_ITEMS:
		var coin = _COIN_SCENE.instantiate()
		_SHOP_ROW.add_child(coin)
		coin.init_coin(Global.random_god_family(), Global.random_shop_denomination_for_round(), Coin.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)
	
	# prevent duplicate coins
	# $HACK$ this is an excessively lazy way to do this, but it's not really a big deal...
	var dup = false
	for i in _SHOP_ROW.get_child_count():
		for j in range(i+1, _SHOP_ROW.get_child_count()):
			if _SHOP_ROW.get_child(i).get_coin_family() == _SHOP_ROW.get_child(j).get_coin_family():
				dup = true
	if dup:
		randomize_shop()

func _on_try_coin_purchased(coin: Coin) -> void:
	emit_signal("coin_purchased", coin, coin.get_store_price())

# called after main confirms the price can be paid and there are enough coin spaces
func purchase_coin(coin: Coin) -> void:
	Global.souls -= coin.get_store_price()
	coin.clicked.disconnect(_on_try_coin_purchased)
	coin.get_parent().remove_child(coin)
