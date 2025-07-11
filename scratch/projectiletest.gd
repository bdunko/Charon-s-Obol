extends Node2D

@onready var _TRAJECTORY_OPTIONS = $TrajectoryOptions

@onready var _PLAYER_COIN = $PlayerCoin
@onready var _PLAYER_COIN2 = $PlayerCoin2
@onready var _LEFT_COIN = $LeftCoin
@onready var _CENTER_COIN = $CenterCoin
@onready var _RIGHT_COIN = $RightCoin
@onready var _FAR_RIGHT_COIN = $FarRightCoin
@onready var _FAR_LEFT_COIN = $FarLeftCoin

var _trajectory_type = Projectile.TrajectoryType.STRAIGHT

func _ready():
	_PLAYER_COIN.init_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, Coin.Owner.PLAYER)
	_PLAYER_COIN2.init_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, Coin.Owner.PLAYER)
	_LEFT_COIN.init_coin(Global.MONSTER_CENTAUR_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_CENTER_COIN.init_coin(Global.MONSTER_MELIAE_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_RIGHT_COIN.init_coin(Global.MONSTER_CHIMERA_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_FAR_LEFT_COIN.init_coin(Global.MONSTER_AETERNAE_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_FAR_RIGHT_COIN.init_coin(Global.MONSTER_CYCLOPS_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)

func _on_fire_left_pressed():
	_LEFT_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position(),\
		Projectile.ProjectileParams.new().trajectory(_trajectory_type))

func _on_fire_center_pressed():
	_CENTER_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position(),\
		Projectile.ProjectileParams.new().trajectory(_trajectory_type))

func _on_fire_right_pressed():
	_RIGHT_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position(),\
		Projectile.ProjectileParams.new().trajectory(_trajectory_type))

func _on_fire_far_left_pressed():
	_FAR_LEFT_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position(),\
		Projectile.ProjectileParams.new().trajectory(_trajectory_type))

func _on_fire_far_right_pressed():
	_FAR_RIGHT_COIN.fire_projectile(_PLAYER_COIN.get_projectile_target_position(),\
		Projectile.ProjectileParams.new().trajectory(_trajectory_type))

func _on_trajectory_options_item_selected(index):
	match _TRAJECTORY_OPTIONS.get_item_text(index):
		"STRAIGHT":
			_trajectory_type = Projectile.TrajectoryType.STRAIGHT
		"CURVED":
			_trajectory_type = Projectile.TrajectoryType.CURVED
		"PARABOLIC":
			_trajectory_type = Projectile.TrajectoryType.PARABOLIC
		"WOBBLE":
			_trajectory_type = Projectile.TrajectoryType.WOBBLE
		"DELAY HOP":
			_trajectory_type = Projectile.TrajectoryType.DELAYED_HOP
		_:
			assert(false)
