class_name Shop
extends HBoxContainer

signal coin_purchased

@onready var _SHOP_ITEM = preload("res://shop_item.tscn")

const _NUM_SHOP_ITEMS = 3

func _ready():
	populate()

func populate():
	for child in get_children():
		child.queue_free()
		
	for _i in _NUM_SHOP_ITEMS:
		var shop_item = _SHOP_ITEM.instantiate()
		# todo - randomize coin type
		# shop_item.assign_coin()
		add_child(shop_item)
		shop_item.purchased.connect(_on_coin_purchased)

func _on_coin_purchased(item: ShopItem, price: int):
	emit_signal("coin_purchased", item, price)
