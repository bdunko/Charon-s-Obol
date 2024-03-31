class_name Shop
extends HBoxContainer

signal coin_purchased

@onready var _SHOP_ITEM = preload("res://shop_item.tscn")

const _NUM_SHOP_ITEMS = 3

func randomize_shop():
	for child in get_children():
		child.queue_free()
		
	for _i in _NUM_SHOP_ITEMS:
		var shop_item = _SHOP_ITEM.instantiate()
		add_child(shop_item)
		
		# randomize the coin type
		shop_item.assign_coin(Global.make_coin(Global.random_coin_type(), Global.random_denomination()))
		
		# todo - smarter coin shop randomization
		shop_item.purchased.connect(_on_coin_purchased)

func _on_coin_purchased(item: ShopItem, price: int):
	emit_signal("coin_purchased", item, price)
