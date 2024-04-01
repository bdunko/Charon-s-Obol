class_name Shop
extends HBoxContainer

signal coin_purchased

@onready var _SHOP_ITEM = preload("res://shop_item.tscn")
@onready var _GENERIC_COIN_CONTAINER = $GenericCoinContainer
@onready var _GOD_COIN_CONTAINER = $GodCoinContainer 

const _NUM_GENERIC_SHOP_ITEMS = 1
const _NUM_GOD_SHOP_ITEMS = 3

func randomize_shop():
	for generic_child in _GENERIC_COIN_CONTAINER.get_children():
		generic_child.queue_free()
	for god_child in _GOD_COIN_CONTAINER.get_children():
		god_child.queue_free()
	
	# todo - smarter coin generation; set possible coin denoms based on round; ie round 1 always generates obols, round 5 makes tetrobols
	
	for _i in _NUM_GENERIC_SHOP_ITEMS:
		var shop_item = _SHOP_ITEM.instantiate()
		_GENERIC_COIN_CONTAINER.add_child(shop_item)
		shop_item.assign_coin(Global.make_coin(Global.GENERIC_FAMILY, Global.random_shop_denomination()))
		shop_item.purchased.connect(_on_coin_purchased)
	
	for _i in _NUM_GOD_SHOP_ITEMS:
		var shop_item = _SHOP_ITEM.instantiate()
		_GOD_COIN_CONTAINER.add_child(shop_item)
		shop_item.assign_coin(Global.make_coin(Global.random_god_family(), Global.random_shop_denomination()))
		shop_item.purchased.connect(_on_coin_purchased)

func _notify_num_fragments(num_fragments: int) -> void:
	# 

func _on_coin_purchased(item: ShopItem, price: int):
	print("coin")
	emit_signal("coin_purchased", item, price)
