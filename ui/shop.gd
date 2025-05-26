class_name Shop
extends Node2D

signal coin_purchased

static var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _SHOP_ROW = $ShopRow

const _TUTORIAL_NUM_PAYOFF = 1
const _TUTORIAL_NUM_FLEX = 1
const _TUTORIAL_NUM_POWER = 2

const _STANDARD_NUM_PAYOFF = 1
const _STANDARD_NUM_FLEX = 1
const _STANDARD_NUM_POWER = 3

const _MERCHANT_NUM_PAYOFF = 1
const _MERCHANT_NUM_FLEX = 2
const _MERCHANT_NUM_POWER = 3

var _coin_spawn_point: Vector2

func _ready() -> void:
	_remove_children()
	
	assert(_SHOP_ROW)
	Global.state_changed.connect(_on_state_changed)
	
func _on_state_changed() -> void:
	if Global.state != Global.State.SHOP:
		await retract() # move all the coins offscreen to 'hide' the shop
		_remove_children()

func set_coin_spawn_point(spawn_point: Vector2) -> void:
	_coin_spawn_point = spawn_point

enum _StockType {
	PAYOFF, POWER
}

func _remove_children():
	for coin in _SHOP_ROW.get_children():
		_SHOP_ROW.remove_child(coin)
		coin.queue_free()

func _num_payoff() -> int:
	if Global.tutorialState != Global.TutorialState.INACTIVE:
		return _TUTORIAL_NUM_PAYOFF
	if Global.is_character(Global.Character.MERCHANT):
		return _MERCHANT_NUM_PAYOFF
	return _STANDARD_NUM_PAYOFF

func _num_flex() -> int:
	if Global.tutorialState != Global.TutorialState.INACTIVE:
		return _TUTORIAL_NUM_FLEX
	if Global.is_character(Global.Character.MERCHANT):
		return _MERCHANT_NUM_FLEX
	return _STANDARD_NUM_FLEX

func _num_power() -> int:
	if Global.tutorialState != Global.TutorialState.INACTIVE:
		return _TUTORIAL_NUM_POWER
	if Global.is_character(Global.Character.MERCHANT):
		return _MERCHANT_NUM_POWER
	return _STANDARD_NUM_POWER

func randomize_and_show_shop() -> void:
	_remove_children()
	
	if Global.tutorialState != Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE and Global.tutorialState != Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN:
		_SHOP_ROW.expand()
	
	if Global.tutorialState == Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN:
		var coin = _COIN_SCENE.instantiate()
		_SHOP_ROW.add_child(coin)
		coin.global_position = _coin_spawn_point
		coin.init_coin(Global.ZEUS_FAMILY, Global.Denomination.OBOL, Coin.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)
		return
	
	var payoff_coinpool = Global.get_payoff_coinpool()
	assert(payoff_coinpool.size() != 0)
	var power_coinpool = Global.get_power_coinpool()
	assert(power_coinpool.size() != 0)
	
	# randomize the types of coins to add to stock
	var to_stock = []
	for i in _num_payoff():
		to_stock.append(_StockType.PAYOFF)
	for i in _num_flex():
		if Global.RNG.randi_range(0, 1) == 0:
			to_stock.append(_StockType.PAYOFF)
		else:
			to_stock.append(_StockType.POWER)
	for i in _num_power():
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
		
		# telemachus is only available in obol
		if coin.get_coin_family() == Global.TELEMACHUS_FAMILY:
			coin.set_denomination(Global.Denomination.OBOL, true)
		
		# if the denomination offered by the shop is unaffordable, attempt to downgrade it until it is affordable
		while coin.get_denomination() != Global.Denomination.OBOL and coin.get_store_price() > Global.souls:
			coin.downgrade(true)

func retract() -> void:
	await _SHOP_ROW.retract(_coin_spawn_point)

func expand() -> void:
	await _SHOP_ROW.expand()

func _on_try_coin_purchased(coin: Coin) -> void:
	emit_signal("coin_purchased", coin, coin.get_store_price())

# called after main confirms the price can be paid and there are enough coin spaces
func purchase_coin(coin: Coin) -> void:
	Global.souls -= coin.get_store_price()
	coin.clicked.disconnect(_on_try_coin_purchased)
	Audio.play_sfx(SFX.PurchaseCoin)
