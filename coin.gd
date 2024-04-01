class_name CoinEntity
extends Control

signal clicked

@onready var LOCKED_ICON = $LockedIcon
@onready var BLESSED_ICON = $BlessedIcon
@onready var CURSED_ICON = $CursedIcon

var _coin: Global.Coin:
	set(val):
		_coin = val
		# update sprite to match denomination
		_SPRITE.texture = load(_coin.get_denomination_sprite_path())

var _heads:
	set(val):
		_heads = val
		update_coin_text()
		
var _power_uses_remaining = -1:
	set(val):
		_power_uses_remaining = val
		update_coin_text()

const _FACE_FORMAT = "[center][color=%s]%s[/color][/center][img=10x13]%s[/img]"
const _RED = "#e12f3b"
const _BLUE = "#a6fcdb"
const _YELLOW = "#ffd541"
const _GRAY = "#b3b9d1"
func update_coin_text() -> void:
	if not _heads:
		_FACE_LABEL.text = _FACE_FORMAT % [_RED, "%d" % get_life_loss(), _coin.get_tails_icon_path()]
	elif _coin.get_power() != Global.Power.NONE:
		_FACE_LABEL.text = _FACE_FORMAT % [_YELLOW if _power_uses_remaining != 0 else _GRAY, "%d" % _power_uses_remaining, _coin.get_heads_icon_path()]
	else:
		_FACE_LABEL.text = _FACE_FORMAT % [_BLUE, "%d" % _coin.get_fragments(), _coin.get_heads_icon_path()]

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
@onready var _FACE_LABEL = $Sprite/FaceLabel

# times the Wisdom power has been used on this coin; which reduces the tail downside by 1 each time
var _athena_wisdom_stacks = 0

func _ready():
	assert(_SPRITE)
	assert(_FACE_LABEL)
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

func apply_athena_wisdom() -> void:
	_athena_wisdom_stacks += 1
	update_coin_text()

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("clicked", self)

func _on_clickable_area_mouse_entered():
	Global.power_text = _coin.get_name() + "\n" + get_power_string()
	Global.power_text_source = self

func _on_clickable_area_mouse_exited():
	if Global.power_text_source == self:
		Global.power_text = ""
