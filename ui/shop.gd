class_name Shop
extends Node2D

signal coin_purchased

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _SHOP_ROW = $ShopRow

const _NUM_GENERIC_SHOP_ITEMS = 1
const _NUM_FLEX_SHOP_ITEMS = 1
const _NUM_GOD_SHOP_ITEMS = 3

var _coin_spawn_point: Vector2

func _ready() -> void:
	for coin in _SHOP_ROW.get_children():
		_SHOP_ROW.remove_child(coin)
		coin.queue_free()
	
	assert(_SHOP_ROW)
	Global.state_changed.connect(_on_state_changed)
	
func _on_state_changed() -> void:
	if Global.state != Global.State.SHOP:
		retract() # move all the coins offscreen to 'hide' the shop

func set_coin_spawn_point(spawn_point: Vector2) -> void:
	_coin_spawn_point = spawn_point

enum _StockType {
	PAYOFF, POWER
}

func randomize_shop() -> void:
	for coin in _SHOP_ROW.get_children():
		_SHOP_ROW.remove_child(coin)
		coin.queue_free()
	
	if Global.tutorialState != Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE:
		_SHOP_ROW.expand()
	
	if Global.tutorialState == Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN:
		var coin = _COIN_SCENE.instantiate()
		_SHOP_ROW.add_child(coin)
		coin.global_position = _coin_spawn_point
		coin.init_coin(Global.ZEUS_FAMILY, Global.Denomination.OBOL, Coin.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)
		return
	
	var payoff_coinpool = Global.get_payoff_coinpool()
	var power_coinpool = Global.get_power_coinpool()
	
	# randomize the types of coins to add to stock
	var to_stock = []
	for i in _NUM_GENERIC_SHOP_ITEMS:
		to_stock.append(_StockType.PAYOFF)
	for i in _NUM_FLEX_SHOP_ITEMS:
		if Global.RNG.randi_range(0, 1) == 0:
			to_stock.append(_StockType.PAYOFF)
		else:
			to_stock.append(_StockType.POWER)
	for i in _NUM_GOD_SHOP_ITEMS:
		to_stock.append(_StockType.POWER)
	
	# choose the specific coin families given the types
	var coin_families_to_stock = []
	for stockType in to_stock:
		match stockType:
			_StockType.PAYOFF:
				coin_families_to_stock.append(payoff_coinpool.pop_front())
				if payoff_coinpool.size() == 0: # replenish if empty
					payoff_coinpool = Global.get_payoff_coinpool()
			_StockType.POWER:
				coin_families_to_stock.append(power_coinpool.pop_front())
				if power_coinpool.size() == 0: # replenish if empty
					power_coinpool = Global.get_payoff_coinpool()
	
	# make the coins and add to shop
	for family in coin_families_to_stock:
		var coin = _COIN_SCENE.instantiate()
		_SHOP_ROW.add_child(coin)
		coin.global_position = _coin_spawn_point
		coin.init_coin(family, Global.random_shop_denomination_for_round(), Coin.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)


func retract() -> void:
	await _SHOP_ROW.retract(_coin_spawn_point)

func _on_try_coin_purchased(coin: Coin) -> void:
	emit_signal("coin_purchased", coin, coin.get_store_price())

# called after main confirms the price can be paid and there are enough coin spaces
func purchase_coin(coin: Coin) -> void:
	Global.souls -= coin.get_store_price()
	coin.clicked.disconnect(_on_try_coin_purchased)
