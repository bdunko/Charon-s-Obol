extends Node2D

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _BOSS_ROW = $BossRow

func _ready() -> void:
	Global.state_changed.connect(_on_state_changed)
	for coin in _BOSS_ROW.get_children():
		coin.queue_free()

func setup() -> void:
	print(Global.boss.name)
	print(Global.boss.description)
	for coinFamily in Global.boss.coins:
		print(coinFamily)
		var coin = _COIN_SCENE.instantiate()
		_BOSS_ROW.add_child(coin)
		coin.assign_coin(Global.make_coin(coinFamily, Global.Denomination.TETROBOL), CoinEntity.Owner.BOSS)

func _on_state_changed() -> void:
	print("this is in boss btw")
	print(Global.round_count)
	print(Global.BOSS_ROUND)
	if Global.round_count == Global.BOSS_ROUND and (Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.BEFORE_FLIP):
		show()
	else:
		hide()
