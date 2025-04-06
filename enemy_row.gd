class_name EnemyRow
extends Node2D

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _ROW = $CoinRow

var _coin_spawn_point: Vector2

const MAX_ENEMIES = 6

func _ready() -> void:
	assert(_ROW)
	Global.state_changed.connect(_on_state_changed)
	for coin in _ROW.get_children():
		coin.queue_free()

func set_coin_spawn_point(spawn_point: Vector2) -> void:
	_coin_spawn_point = spawn_point

func current_round_setup() -> void:
	# remove existing coins
	for coin in _ROW.get_children():
		coin.queue_free()
		_ROW.remove_child(coin)
	
	# generate new coins
	for coinDataPair in Global.current_round_enemy_coin_data():
		var enemy = spawn_enemy(coinDataPair[0], coinDataPair[1])
		
		# if we spawned in Echidna, also make another pair of random monsters for her
		if enemy.get_coin_family() == Global.ECHIDNA_FAMILY:
			var denom = Global.Denomination.TRIOBOL if Global.is_difficulty_active(Global.Difficulty.UNFAIR5) else Global.Denomination.DIOBOL
			for i in 2:
				spawn_enemy(Global.get_standard_monster(), Global.Denomination.DIOBOL)

func spawn_enemy(family: Global.CoinFamily, denom: Global.Denomination, index: int = -1) -> Coin:
	if _ROW.get_child_count() >= MAX_ENEMIES:
		return # don't spawn more than max
	
	var coin = _COIN_SCENE.instantiate()
	_ROW.add_child(coin)
	if index != -1:
		_ROW.move_child(coin, index)
	coin.global_position = _coin_spawn_point
	coin.init_coin(family, denom, Coin.Owner.NEMESIS)
	return coin

func _on_state_changed() -> void:
	if Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.BEFORE_FLIP:
		_ROW.expand()
	else:
		_ROW.retract(_coin_spawn_point)
