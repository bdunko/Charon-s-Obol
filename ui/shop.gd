class_name Shop
extends HBoxContainer

signal coin_purchased

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _GENERIC_COIN_CONTAINER = $GenericCoinContainer
@onready var _GOD_COIN_CONTAINER = $GodCoinContainer 

const _NUM_GENERIC_SHOP_ITEMS = 1
const _NUM_GOD_SHOP_ITEMS = 3

func _ready() -> void:
	Global.state_changed.connect(_on_state_changed)
	
func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		show()
	else:
		hide()

func randomize_shop() -> void:
	for generic_child in _GENERIC_COIN_CONTAINER.get_children():
		generic_child.queue_free()
	for god_child in _GOD_COIN_CONTAINER.get_children():
		god_child.queue_free()
	
	for _i in _NUM_GENERIC_SHOP_ITEMS:
		var coin = _COIN_SCENE.instantiate()
		_GENERIC_COIN_CONTAINER.add_child(coin)
		coin.assign_coin(Global.make_coin(Global.GENERIC_FAMILY, Global.random_shop_denomination_for_round()), CoinEntity.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)
	
	for _i in _NUM_GOD_SHOP_ITEMS:
		var coin = _COIN_SCENE.instantiate()
		_GOD_COIN_CONTAINER.add_child(coin)
		coin.assign_coin(Global.make_coin(Global.random_god_family(), Global.random_shop_denomination_for_round()), CoinEntity.Owner.SHOP)
		coin.clicked.connect(_on_try_coin_purchased)

func _on_try_coin_purchased(coin: CoinEntity) -> void:
	emit_signal("coin_purchased", coin, coin.get_store_price())

# called after main confirms the price can be paid and there are enough coin spaces
func purchase_coin(coin: CoinEntity) -> void:
	Global.fragments -= coin.get_store_price()
	coin.clicked.disconnect(_on_try_coin_purchased)
	coin.get_parent().remove_child(coin)
