class_name CoinEntity
extends Control

signal flip_complete
signal clicked

enum Owner {
	SHOP, PLAYER, BOSS
}

enum _BlessCurseState {
	NONE, BLESSED, CURSED
}

enum _LuckState {
	NONE, LUCKY, UNLUCKY
}

enum _Animation {
	FLAT, FLIP, SWAP
}

enum _FreezeIgniteState {
	NONE, FROZEN, IGNITED
}

@onready var LUCKY_ICON = $LuckyIcon
@onready var UNLUCKY_ICON = $UnluckyIcon
@onready var FROZEN_ICON = $FrozenIcon
@onready var IGNITE_ICON = $IgniteIcon
@onready var BLESSED_ICON = $BlessedIcon
@onready var CURSED_ICON = $CursedIcon
@onready var SUPERCHARGE_ICON = $SuperchargeIcon
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
		_FACE_LABEL.text = _FACE_FORMAT % [_RED, "%d" % get_tails_penalty(), _coin.get_tails_icon_path()]
	elif _coin.get_power() != Global.Power.NONE:
		_FACE_LABEL.text = _FACE_FORMAT % [_YELLOW if _power_uses_remaining != 0 else _GRAY, "%d" % _power_uses_remaining, _coin.get_heads_icon_path()]
	else:
		_FACE_LABEL.text = _FACE_FORMAT % [_BLUE, "%d" % _coin.get_souls(), _coin.get_heads_icon_path()]

var _bless_curse_state: _BlessCurseState:
	set(val):
		_bless_curse_state = val
		BLESSED_ICON.visible = _bless_curse_state == _BlessCurseState.BLESSED
		CURSED_ICON.visible = _bless_curse_state == _BlessCurseState.CURSED

var _freeze_ignite_state: _FreezeIgniteState:
	set(val):
		_freeze_ignite_state = val
		FROZEN_ICON.visible = _freeze_ignite_state == _FreezeIgniteState.FROZEN
		IGNITE_ICON.visible = _freeze_ignite_state == _FreezeIgniteState.IGNITED

var _supercharged: bool:
	set(val):
		_supercharged = val
		SUPERCHARGE_ICON.visible = _supercharged

var _luck_state: _LuckState:
	set(val):
		_luck_state = val
		LUCKY_ICON.visible = _luck_state == _LuckState.LUCKY
		UNLUCKY_ICON.visible = _luck_state == _LuckState.UNLUCKY

# stacks of the Athena god coin; reduces tails penalty by 1 temporary (coin) or permanently (patron)
var _round_tails_penalty_reduction = 0
var _permanent_tails_penalty_reduction = 0

@onready var _SPRITE = $Sprite
@onready var _FACE_LABEL = $Sprite/FaceLabel
@onready var _PRICE = $Price

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
	_luck_state = _LuckState.NONE
	_freeze_ignite_state = _FreezeIgniteState.NONE
	_supercharged = false
	_round_tails_penalty_reduction = 0
	_permanent_tails_penalty_reduction = 0

func assign_coin(coin: Global.Coin, owned_by: Owner):
	_reset()
	_coin = coin
	reset_power_uses()
	update_coin_text()
	_heads = true
	_owner = owned_by

func mark_owned_by_player() -> void:
	_owner = Owner.PLAYER

func flip(bonus: int = 0) -> void:
	if is_frozen(): #don't flip if frozen
		# todo - animation for unfreezing
		_freeze_ignite_state = _FreezeIgniteState.NONE
		emit_signal("flip_complete")
		return
	
	if is_ignited():
		#todo - animation for ignite
		Global.lives -= _coin.get_tails_penalty()
		
	_disabled = true # ignore input while flipping
	
	# animate
	_FACE_LABEL.hide() # hide text
	
	if is_blessed():
		_heads = true
		_bless_curse_state = _BlessCurseState.BLESSED
	elif is_cursed():
		_heads = false
		_bless_curse_state = _BlessCurseState.CURSED
	else:
		var success_roll_min = 50 + bonus
		match(_luck_state):
			_LuckState.LUCKY:
				success_roll_min += 20
			_LuckState.UNLUCKY:
				success_roll_min -= 20
		_heads = success_roll_min >= Global.RNG.randi_range(1, 100)
	
	# todo - make it move up in a parabola; add a shadow
	set_animation(_Animation.FLIP)
	var tween = create_tween()
	tween.tween_property(self, "position:y", self.position.y - 50, 0.20)
	tween.tween_property(self, "position:y", self.position.y, 0.20).set_delay(0.1)
	await tween.finished
	set_animation(_Animation.FLAT)
	
	_FACE_LABEL.show()
	
	# if supercharged and we landed on tails, flip again.
	if _supercharged:
		_supercharged = false
		await flip()
	
	emit_signal("flip_complete")
	
	_disabled = false

# turn a coin to its other side
func turn() -> void:
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

func get_tails_penalty() -> int:
	return max(_coin.get_tails_penalty() - (_round_tails_penalty_reduction + _permanent_tails_penalty_reduction), 0)

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

func get_denomination_as_int() -> int:
	return _coin.get_denomination_as_int()

func spend_power_use() -> void:
	assert(_power_uses_remaining > 0)
	_power_uses_remaining -= 1

func reset_power_uses() -> void:
	_power_uses_remaining = _coin.get_max_power_uses()

func recharge_power_uses_by(recharge_amount: int) -> void:
	assert(recharge_amount > 0)
	_power_uses_remaining += recharge_amount

func make_lucky() -> void:
	_luck_state = _LuckState.LUCKY

func make_unlucky() -> void:
	_luck_state = _LuckState.UNLUCKY

func clear_lucky_unlucky() -> void:
	_luck_state = _LuckState.NONE

func supercharge() -> void:
	_supercharged = true

func bless() -> void:
	_bless_curse_state = _BlessCurseState.BLESSED

func curse() -> void:
	_bless_curse_state = _BlessCurseState.CURSED

func clear_blessed_cursed() -> void:
	_bless_curse_state = _BlessCurseState.NONE

func freeze() -> void:
	_freeze_ignite_state = _FreezeIgniteState.FROZEN

func ignite() -> void:
	_freeze_ignite_state = _FreezeIgniteState.IGNITED

func clear_freeze_ignire() -> void:
	_freeze_ignite_state = _FreezeIgniteState.NONE

func is_heads() -> bool:
	return _heads

func is_tails() -> bool:
	return not _heads

func is_lucky() -> bool:
	return _luck_state == _LuckState.LUCKY

func is_blessed() -> bool:
	return _bless_curse_state == _BlessCurseState.BLESSED

func is_cursed() -> bool:
	return _bless_curse_state == _BlessCurseState.CURSED

func is_unlucky() -> bool:
	return _luck_state == _LuckState.UNLUCKY

func is_frozen() -> bool:
	return _freeze_ignite_state == _FreezeIgniteState.FROZEN
	
func is_ignited() -> bool:
	return _freeze_ignite_state == _FreezeIgniteState.IGNITED

func get_subtitle() -> String:
	return _coin.get_subtitle()

func upgrade_denomination() -> void:
	_coin.upgrade_denomination()
	update_coin_text()
	update_price_label()
	set_animation(_Animation.FLAT) # update sprite

func reduce_tails_penalty_permanently() -> void:
	_permanent_tails_penalty_reduction += 1
	update_coin_text()

func reduce_tails_downside_for_round() -> void:
	_round_tails_penalty_reduction += 1
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
	var life_lost = _coin.get_tails_penalty()
	
	return TOOLTIP_FORMAT % [coin_name, subtitle, power_description, life_lost]

func on_round_end() -> void:
	# reset wisdom stacks
	_round_tails_penalty_reduction = 0
	# force to heads
	if not _heads:
		turn()

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
