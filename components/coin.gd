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
	FLAT, FLIP, SWAP
}

@onready var BLESSED_ICON = $BlessedIcon
@onready var CURSED_ICON = $CursedIcon
@onready var FROZEN_ICON = $FrozenIcon
@onready var IGNITE_ICON = $IgniteIcon
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
		_FACE_LABEL.text = _FACE_FORMAT % [_BLUE, "%d" % _coin.get_souls(), _coin.get_heads_icon_path()]

var _frozen: bool:
	set(val):
		_frozen = val
		FROZEN_ICON.visible = _frozen
	
var _ignite_stacks: int:
	set(val):
		_ignite_stacks = val
		IGNITE_ICON.visible = _ignite_stacks != 0

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
	Global.souls_count_changed.connect(update_price_label)
	Global.state_changed.connect(_on_state_changed)
	_PRICE.visible = Global.state == Global.State.SHOP
	_coin = Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL)
	_heads = true
	_reset()

const _PRICE_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
const _UPGRADE_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
func update_price_label() -> void:
	# special case - can't upgrade further, show nothing
	if _owner == Owner.PLAYER and not _coin.can_upgrade():
		_PRICE.text = ""
		return
	
	var price = get_upgrade_price() if _owner == Owner.PLAYER else get_store_price()
	var color = Global.AFFORDABLE_COLOR if Global.souls >= price else Global.UNAFFORDABLE_COLOR
	_PRICE.text = (_UPGRADE_FORMAT if _owner == Owner.PLAYER else _PRICE_FORMAT) % [color, price]

func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		update_price_label()
		_PRICE.show()
	else:
		_PRICE.hide()

func _reset() -> void:
	_bless_curse_state = _BlessCurseState.NONE
	_frozen = false
	_ignite_stacks = 0
	_athena_wisdom_stacks = 0

func assign_coin(coin: Global.Coin, owned_by: Owner):
	_reset()
	_coin = coin
	reset_power_uses()
	update_coin_text()
	_heads = true
	_owner = owned_by

func mark_owned_by_player() -> void:
	_owner = Owner.PLAYER

func is_heads() -> bool:
	return _heads

func flip() -> void:
	if _frozen: #don't flip if frozen
		# todo - animation for unfreezing
		_unfreeze()
		emit_signal("flip_complete")
		return
	
	Global.lives -= _ignite_stacks
		
	_disabled = true # ignore input while flipping
	
	# animate
	_FACE_LABEL.hide() # hide text
	
	match(_bless_curse_state):
		_BlessCurseState.NONE:
			_heads = Global.RNG.randi_range(0, 1) == 1 #50% chance for heads
		_BlessCurseState.BLESSED:
			_heads = Global.RNG.randi_range(0, 2) != 2 #66% chance for heads
		_BlessCurseState.CURSED:
			_heads = Global.RNG.randi_range(0, 2) == 2 #33% chance for heads
	
	# todo - make it move up in a parabola; add a shadow
	set_animation(_Animation.FLIP)
	var tween = create_tween()
	tween.tween_property(self, "position:y", self.position.y - 50, 0.20)
	tween.tween_property(self, "position:y", self.position.y, 0.20).set_delay(0.1)
	await tween.finished
	set_animation(_Animation.FLAT)
	
	_FACE_LABEL.show()
	
	emit_signal("flip_complete")
	
	_disabled = false

func swap_side() -> void:
	_heads = not _heads
	_FACE_LABEL.hide()
	set_animation(_Animation.FLIP)
	await _SPRITE.animation_looped
	set_animation(_Animation.FLAT)
	_FACE_LABEL.show()

func get_store_price() -> int:
	return _coin.get_store_price()

func get_sell_price() -> int:
	return _coin.get_sell_price()

func get_upgrade_price() -> int:
	return _coin.get_upgrade_price()

func can_upgrade() -> bool:
	return _coin.can_upgrade()

func get_souls() -> int:
	return _coin.get_souls()

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

func reset_power_uses() -> void:
	_power_uses_remaining = _coin.get_max_power_uses()

func recharge_power_uses_by(recharge_amount: int) -> void:
	assert(recharge_amount > 0)
	_power_uses_remaining += recharge_amount

func freeze() -> void:
	_frozen = true
	_unignite()

func _unfreeze() -> void:
	_frozen = false

func ignite() -> void:
	_ignite_stacks += 1
	_unfreeze()

func _unignite() -> void:
	_ignite_stacks = 0

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
	update_price_label()
	set_animation(_Animation.FLAT) # update sprite

func apply_athena_wisdom() -> void:
	_athena_wisdom_stacks += 1
	update_coin_text()

func disable_input() -> void:
	_disabled = true

func enable_input() -> void:
	_disabled = false

func _generate_tooltip() -> String:
	const TOOLTIP_FORMAT = "[center]%s
[color=yellow]%s[/color]
[img=12x13]res://assets/icons/heads_icon.png[/img] %s 
[img=12x13]res://assets/icons/tails_icon.png[/img] -%d[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img][/center]"
	
	var coin_name = _coin.get_name()
	var subtitle = _coin.get_subtitle()
	var power_description = _coin.get_power_string()
	var life_lost = _coin.get_life_loss()
	
	return TOOLTIP_FORMAT % [coin_name, subtitle, power_description, life_lost]

func on_round_end() -> void:
	# reset wisdom stacks
	_athena_wisdom_stacks = 0
	# force to heads
	if not _heads:
		swap_side()

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	#UITooltip.create(self, _generate_tooltip(), get_global_mouse_position(), get_tree().root)
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _disabled:
				emit_signal("clicked", self)
				

func _on_clickable_area_mouse_entered():
	_mouse_over = true
	activate_power_text()

func _on_clickable_area_mouse_exited():
	_mouse_over = false
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

var _time_mouse_hover = 0
var _mouse_over = false
const _DELAY_BEFORE_TOOLTIP = 0.3

func _physics_process(delta):
	if _mouse_over:
		_time_mouse_hover += delta
	else:
		_time_mouse_hover = 0
	
	if _time_mouse_hover >= _DELAY_BEFORE_TOOLTIP:
		UITooltip.create(self, _generate_tooltip(), get_global_mouse_position(), get_tree().root)
