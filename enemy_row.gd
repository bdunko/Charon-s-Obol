class_name EnemyRow
extends Node2D

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _ROW = $CoinRow

func _ready() -> void:
	assert(_ROW)
	Global.state_changed.connect(_on_state_changed)
	for coin in _ROW.get_children():
		coin.queue_free()

func current_round_setup() -> void:
	# remove existing coins
	for coin in _ROW.get_children():
		coin.queue_free()
		_ROW.remove_child(coin)
	
	# generate new coins
	for coinDataPair in Global.current_round_enemy_coin_data():
		var coin = _COIN_SCENE.instantiate()
		_ROW.add_child(coin)
		coin.init_coin(coinDataPair[0], coinDataPair[1], Coin.Owner.NEMESIS)

func _on_state_changed() -> void:
	if Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.BEFORE_FLIP:
		show()
	else:
		hide()
