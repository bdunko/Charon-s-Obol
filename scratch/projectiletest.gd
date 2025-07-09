extends Node2D

@onready var _PLAYER_COIN = $PlayerCoin
@onready var _LEFT_COIN = $LeftCoin
@onready var _CENTER_COIN = $CenterCoin
@onready var _RIGHT_COIN = $RightCoin


# Called when the node enters the scene tree for the first time.
func _ready():
	_PLAYER_COIN.init_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, Coin.Owner.PLAYER)
	_LEFT_COIN.init_coin(Global.MONSTER_CENTAUR_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_CENTER_COIN.init_coin(Global.MONSTER_MELIAE_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_RIGHT_COIN.init_coin(Global.MONSTER_CHIMERA_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)

func _on_fire_left_pressed():
	_LEFT_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position())

func _on_fire_center_pressed():
	_CENTER_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position())

func _on_fire_right_pressed():
	_RIGHT_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position())
