class_name Trial
extends Node2D

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _TRIAL_ROW = $TrialRow

func _ready() -> void:
	assert(_TRIAL_ROW)
	Global.state_changed.connect(_on_state_changed)
	for coin in _TRIAL_ROW.get_children():
		coin.queue_free()

func setup() -> void:
	#trialtododo
	#fetch trial coins from Global
	for coinFamily in Global.nemesis.coins:
		var coin = _COIN_SCENE.instantiate()
		_TRIAL_ROW.add_child(coin)
		coin.init_coin(coinFamily, Global.Denomination.TETROBOL, Coin.Owner.NEMESIS)

func _on_state_changed() -> void:
	var trial_or_boss = (Global.current_round_type() == Global.RoundType.NEMESIS or Global.current_round_type() == Global.RoundType.TRIAL)
	if trial_or_boss and (Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.BEFORE_FLIP):
		show()
	else:
		hide()
