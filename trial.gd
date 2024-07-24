class_name Trial
extends Node2D

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _TRIAL_ROW = $TrialRow

func _ready() -> void:
	assert(_TRIAL_ROW)
	Global.state_changed.connect(_on_state_changed)
	for coin in _TRIAL_ROW.get_children():
		coin.queue_free()

func setup_trial() -> void:
	for coinFamily in Global.current_round_trial().coins:
		var coin = _COIN_SCENE.instantiate()
		_TRIAL_ROW.add_child(coin)
		
		var denom
		
		match Global.current_round_type():
			Global.RoundType.TRIAL1:
				denom = Global.Denomination.OBOL
			Global.RoundType.TRIAL2:
				denom = Global.Denomination.DIOBOL
			Global.RoundType.NEMESIS:
				denom = Global.Denomination.TETROBOL
			_:
				assert(false, "Round type isn't trial or nemesis?")
		
		coin.init_coin(coinFamily, denom, Coin.Owner.NEMESIS)

func _on_state_changed() -> void:
	var trial_or_boss = (Global.current_round_type() == Global.RoundType.NEMESIS or Global.current_round_type() == Global.RoundType.TRIAL1 or Global.current_round_type() == Global.RoundType.TRIAL2)
	if trial_or_boss and (Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.BEFORE_FLIP):
		show()
	else:
		hide()
