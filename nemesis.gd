class_name Nemesis
extends Node2D

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _NEMESIS_ROW = $NemesisRow

func _ready() -> void:
	Global.state_changed.connect(_on_state_changed)
	for coin in _NEMESIS_ROW.get_children():
		coin.queue_free()

func setup() -> void:
	for coinFamily in Global.nemesis.coins:
		var coin = _COIN_SCENE.instantiate()
		_NEMESIS_ROW.add_child(coin)
		coin.init_coin(coinFamily, Global.Denomination.TETROBOL, Coin.Owner.NEMESIS)

func _on_state_changed() -> void:
	if Global.round_count == Global.NEMESIS_ROUND and (Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.BEFORE_FLIP):
		show()
	else:
		hide()
