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

var _heads:
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
		_SIDE_LABEL.text = "-%d Life" % get_life_loss() if get_life_loss() != 0 else "No Penalty"
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

# times the Wisdom power has been used on this coin; which reduces the tail downside by 1 each time
var _athena_wisdom_stacks = 0

func _ready():
	assert(_SPRITE)
	assert(_SIDE_LABEL)
	assert(_NAME_LABEL)
	_coin = Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL)
	_heads = true
	_locked = false
	_bless_curse_state = BlessCurseState.NONE

func assign_coin(coin: Global.Coin):
	_coin = coin
	reset_power_uses()
	update_coin_text()

func is_heads() -> bool:
	return _heads

func flip() -> void:
	if _locked: #don't flip if locked
		return
	
	match(_bless_curse_state):
		BlessCurseState.NONE:
			_heads = Global.RNG.randi_range(0, 1) == 1 #50% chance for heads
		BlessCurseState.BLESSED:
			_heads = Global.RNG.randi_range(0, 2) != 2 #66% chance for heads
		BlessCurseState.CURSED:
			_heads = Global.RNG.randi_range(0, 2) == 2 #33% chance for heads

func get_store_price() -> int:
	return _coin.get_store_price()

func get_fragments() -> int:
	return _coin.get_fragments()

func get_life_loss() -> int:
	return max(_coin.get_life_loss() - _athena_wisdom_stacks, 0)

func get_value() -> int:
	return _coin.get_value()

func get_power() -> Global.Power:
	return _coin.get_power()

func get_power_string() -> String:
	return _coin.get_power_string()

func get_power_uses_remaining() -> int:
	return _power_uses_remaining

func get_max_power_uses() -> int:
	return _coin.get_max_power_uses()

func get_denomination() -> Global.Denomination:
	return _coin.get_denomination()

func spend_power_use() -> void:
	assert(_power_uses_remaining > 0)
	_power_uses_remaining -= 1

func spend_all_power_uses() -> void:
	assert(_power_uses_remaining > 0)
	_power_uses_remaining = 0

func reset_power_uses() -> void:
	_power_uses_remaining = _coin.get_max_power_uses()

func recharge_power_uses_by(recharge_amount: int) -> void:
	assert(recharge_amount > 0)
	_power_uses_remaining += recharge_amount

func change_face() -> void:
	_heads = not _heads

func lock() -> void:
	_locked = true

func unlock() -> void:
	_locked = false

func bless() -> void:
	_bless_curse_state = BlessCurseState.BLESSED

func curse() -> void:
	_bless_curse_state = BlessCurseState.CURSED

func is_blessed() -> bool:
	return _bless_curse_state == BlessCurseState.BLESSED

func is_cursed() -> bool:
	return _bless_curse_state == BlessCurseState.CURSED

func upgrade_denomination() -> void:
	_coin.upgrade_denomination()
	update_coin_text()
	_NAME_LABEL.text = _coin.get_name()

func apply_athena_wisdom() -> void:
	_athena_wisdom_stacks += 1
	update_coin_text()

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("clicked", self)
