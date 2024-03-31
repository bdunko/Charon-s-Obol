class_name CoinEntity
extends Control

signal clicked

@onready var LOCKED_ICON = $LockedIcon
@onready var BLESSED_ICON = $BlessedIcon
@onready var CURSED_ICON = $CursedIcon

var _coin: Global.Coin:
	set(val):
		_coin = val
		_NAME_LABEL.text = _coin.get_name()
		_heads = true  #default a new coin to the heads side; this also updates the coin graphic

var _heads := true:
	set(val):
		_heads = val
		_SPRITE.color = _HEADS_COLOR if _heads else _TAILS_COLOR
		update_coin_text()
		
var _power_uses_remaining = -1:
	set(val):
		_power_uses_remaining = val
		update_coin_text()

func update_coin_text() -> void:
	if not _heads:
		_SIDE_LABEL.text = "-%d Life" % _coin.get_life_loss()
	elif _coin.get_power() != Global.Power.NONE:
		_SIDE_LABEL.text = "%d %s" % [_power_uses_remaining, _coin.get_power_string()]
	else:
		_SIDE_LABEL.text = "+%d Frag" % _coin.get_fragments()

var _locked: bool:
	set(val):
		_locked = val
		LOCKED_ICON.visible = _locked

enum BlessCurseState {
	NONE, BLESSED, CURSED
}

var _bless_curse_state: BlessCurseState:
	set(val):
		_bless_curse_state = val
		BLESSED_ICON.visible = _bless_curse_state == BlessCurseState.BLESSED
		CURSED_ICON.visible = _bless_curse_state == BlessCurseState.CURSED

const _HEADS_COLOR = Color("#6db517")
const _TAILS_COLOR = Color("#ea1e2d")

@onready var _SPRITE = $Sprite
@onready var _SIDE_LABEL = $Sprite/SideLabel
@onready var _NAME_LABEL = $NameLabel

func _ready():
	assert(_SPRITE)
	assert(_SIDE_LABEL)
	assert(_NAME_LABEL)
	_coin = Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL)
	_locked = false
	_bless_curse_state = BlessCurseState.NONE

func assign_coin(coin: Global.Coin):
	_coin = coin
	recharge_power_uses_fully()

func is_heads() -> bool:
	return _heads

func get_store_price() -> int:
	return _coin.get_store_price()

func get_fragments() -> int:
	return _coin.get_fragments()

func get_life_loss() -> int:
	return _coin.get_life_loss()

func get_value() -> int:
	return _coin.get_value()

func get_power() -> Global.Power:
	return _coin.get_power()

func get_power_string() -> String:
	return _coin.get_power_string()

func get_power_uses_remaining() -> int:
	return _power_uses_remaining

func spend_power_use() -> void:
	assert(_power_uses_remaining > 0)
	_power_uses_remaining -= 1

func recharge_power_uses_fully() -> void:
	_power_uses_remaining = _coin.get_max_power_uses()

func recharge_power_uses_by(recharge_amount: int) -> void:
	assert(recharge_amount > 0)
	_power_uses_remaining = clamp(_power_uses_remaining + recharge_amount, 0, _coin.get_max_power_uses())

func flip() -> void:
	if _locked: #don't flip if locked
		return
	
	_heads = Global.RNG.randi_range(0, 1) == 1 # randomly flip the coin

func lock() -> void:
	_locked = true

func unlock() -> void:
	_locked = false

func bless() -> void:
	_bless_curse_state = BlessCurseState.BLESSED

func curse() -> void:
	_bless_curse_state = BlessCurseState.CURSED

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("clicked", self)
