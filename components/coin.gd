class_name CoinEntity
extends Control

signal flip_complete
signal clicked

enum Owner {
	SHOP, PLAYER
}

enum _BlessCurseState {
	NONE, BLESSED, CURSED
}

enum _Animation {
	FLAT, FLIP
}

@onready var LOCKED_ICON = $LockedIcon
@onready var BLESSED_ICON = $BlessedIcon
@onready var CURSED_ICON = $CursedIcon
@onready var PRICE = $Price

var _disabled := false

var _owner: Owner:
	set(val):
		_owner = val
		update_price_label()

var _coin: Global.Coin:
	set(val):
		_coin = val
		# update sprite animation to match denomination
		set_animation(_Animation.FLAT)

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

var _bless_curse_state: _BlessCurseState:
	set(val):
		_bless_curse_state = val
		BLESSED_ICON.visible = _bless_curse_state == _BlessCurseState.BLESSED
		CURSED_ICON.visible = _bless_curse_state == _BlessCurseState.CURSED

@onready var _SPRITE = $Sprite
@onready var _FACE_LABEL = $Sprite/FaceLabel
@onready var _PRICE = $Price

# times the Wisdom power has been used on this coin; which reduces the tail downside by 1 each time
var _athena_wisdom_stacks = 0

func _ready():
	assert(_SPRITE)
	assert(_FACE_LABEL)
	Global.fragments_count_changed.connect(update_price_label)
	Global.state_changed.connect(_on_state_changed)
	_PRICE.visible = Global.state == Global.State.SHOP
	_coin = Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL)
	_heads = true
	_reset()

const _PRICE_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
const _SELL_COLOR = "#59c135"
func update_price_label() -> void:
	var price = get_sell_price() if _owner == Owner.PLAYER else get_store_price()
	var color = _SELL_COLOR if _owner == Owner.PLAYER else (Global.AFFORDABLE_COLOR if Global.fragments >= price else Global.UNAFFORDABLE_COLOR)
	_PRICE.text = _PRICE_FORMAT % [color, price]

func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		update_price_label()
		_PRICE.show()
	else:
		_PRICE.hide()

func _reset() -> void:
	_bless_curse_state = _BlessCurseState.NONE
	_locked = false
	_athena_wisdom_stacks = 0

func assign_coin(coin: Global.Coin, owned_by: Owner):
	_reset()
	_coin = coin
	reset_power_uses()
	update_coin_text()
	_owner = owned_by

func mark_owned_by_player() -> void:
	_owner = Owner.PLAYER

func is_heads() -> bool:
	return _heads

func flip() -> void:
	if _locked: #don't flip if locked
		# todo - animation for _locked
		_unlock()
		emit_signal("flip_complete")
		return
		
	_disabled = true # ignore input while flipping
	
	# animate
	_FACE_LABEL.hide() # hide text
	
	# todo - make it move up in a parabola; add a shadow
	set_animation(_Animation.FLIP)
	var tween = create_tween()
	tween.tween_property(self, "position:y", self.position.y - 50, 0.20)
	tween.tween_property(self, "position:y", self.position.y, 0.20).set_delay(0.1)
	await tween.finished
	set_animation(_Animation.FLAT)
	
	match(_bless_curse_state):
		_BlessCurseState.NONE:
			_heads = Global.RNG.randi_range(0, 1) == 1 #50% chance for heads
		_BlessCurseState.BLESSED:
			_heads = Global.RNG.randi_range(0, 2) != 2 #66% chance for heads
		_BlessCurseState.CURSED:
			_heads = Global.RNG.randi_range(0, 2) == 2 #33% chance for heads
	
	_FACE_LABEL.show()
	
	emit_signal("flip_complete")
	
	_disabled = false

func get_store_price() -> int:
	return _coin.get_store_price()

func get_sell_price() -> int:
	return _coin.get_sell_price()

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

func _unlock() -> void:
	_locked = false

func bless() -> void:
	_bless_curse_state = _BlessCurseState.BLESSED

func curse() -> void:
	_bless_curse_state = _BlessCurseState.CURSED

func is_blessed() -> bool:
	return _bless_curse_state == _BlessCurseState.BLESSED

func is_cursed() -> bool:
	return _bless_curse_state == _BlessCurseState.CURSED

func get_subtitle() -> String:
	return _coin.get_subtitle()

func upgrade_denomination() -> void:
	_coin.upgrade_denomination()
	update_coin_text()
	set_animation(_Animation.FLAT) # update sprite

func apply_athena_wisdom() -> void:
	_athena_wisdom_stacks += 1
	update_coin_text()

func disable_input() -> void:
	_disabled = true

func enable_input() -> void:
	_disabled = false

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _disabled:
				emit_signal("clicked", self)

func _on_clickable_area_mouse_entered():
	activate_power_text()

func _on_clickable_area_mouse_exited():
	if Global.power_text_source == self:
		Global.power_text = ""

func activate_power_text() -> void:
	Global.power_text = _coin.get_name() + "\n" + get_power_string()
	Global.power_text_source = self

func set_animation(anim: _Animation) -> void:
	var denom_str = ""
	match(_coin.get_denomination()):
		Global.Denomination.OBOL:
			denom_str = "obol"
		Global.Denomination.DIOBOL:
			denom_str = "diobol"
		Global.Denomination.TRIOBOL:
			denom_str = "triobol"
		Global.Denomination.TETROBOL:
			denom_str = "tetrobol"
	assert(denom_str != "")
	
	var anim_str = ""
	match(anim):
		_Animation.FLAT:
			anim_str = "flat"
		_Animation.FLIP:
			anim_str = "flip"
	assert(anim_str != "")
	
	_SPRITE.play("%s_%s_%s" % [_coin.get_style_string(), denom_str, anim_str])
