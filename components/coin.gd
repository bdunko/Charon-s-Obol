class_name Coin
extends Control

signal flip_complete
signal clicked

enum Owner {
	SHOP, PLAYER, NEMESIS
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

enum _MaterialState {
	NONE, STONE #GOLD, GLASS(?)
}

@onready var LUCKY_ICON = $LuckyIcon
@onready var UNLUCKY_ICON = $UnluckyIcon
@onready var FROZEN_ICON = $FrozenIcon
@onready var IGNITE_ICON = $IgniteIcon
@onready var BLESSED_ICON = $BlessedIcon
@onready var CURSED_ICON = $CursedIcon
@onready var SUPERCHARGE_ICON = $SuperchargeIcon
@onready var STONE_ICON = $StoneIcon
@onready var PRICE = $Price

var _disabled := false

var _owner: Owner:
	set(val):
		_owner = val
		_update_price_label()

var _coin_family: Global.CoinFamily:
	set(val):
		_coin_family = val

var _denomination: Global.Denomination:
	set(val):
		_denomination = val
		set_animation(_Animation.FLAT) #update denom

var _heads:
	set(val):
		_heads = val
		_update_face_label()

class FacePower:
	var charges: int = 0
	var power_family: Global.PowerFamily
	
	func _init(fam: Global.PowerFamily, starting_charges: int):
		self.power_family = fam
		self.charges = starting_charges

var _heads_power: FacePower
var _tails_power: FacePower

const _FACE_FORMAT = "[center][color=%s]%s[/color][img=10x13]%s[/img][/center]"
const _RED = "#e12f3b"
const _BLUE = "#a6fcdb"
const _YELLOW = "#ffd541"
const _GRAY = "#b3b9d1"
func _update_face_label() -> void:
	var color = _YELLOW
	match(get_active_power_family()):
		Global.POWER_FAMILY_GAIN_SOULS:
			color = _BLUE
		Global.POWER_FAMILY_LOSE_LIFE:
			color = _RED
	#var charges_str = "%d" % get_active_power_charges() if get_max_active_power_charges() != 0 else ""
	_FACE_LABEL.text = _FACE_FORMAT % [color, "%d" % get_active_power_charges(), get_active_power_family().icon_path]

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

var _material_state: _MaterialState:
	set(val):
		_material_state = val
		STONE_ICON.visible = _material_state == _MaterialState.STONE

# stacks of the Athena god coin; reduces LIFE LOSS power charges by 1 permanently\
var _round_tails_penalty_reduction = 0
var _permanent_tails_penalty_reduction = 0

@onready var _SPRITE = $Sprite
@onready var _FACE_LABEL = $Sprite/FaceLabel
@onready var _PRICE = $Price

func _ready():
	assert(_SPRITE)
	assert(_FACE_LABEL)

const _PRICE_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
const _UPGRADE_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
func _update_price_label() -> void:
	# special case - can't upgrade further, show nothing
	if _owner == Owner.PLAYER and not can_upgrade():
		_PRICE.text = ""
		return
	
	var price = get_upgrade_price() if _owner == Owner.PLAYER else get_store_price()
	var color = Global.AFFORDABLE_COLOR if Global.souls >= price else Global.UNAFFORDABLE_COLOR
	_PRICE.text = (_UPGRADE_FORMAT if _owner == Owner.PLAYER else _PRICE_FORMAT) % [color, price]

func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		_update_price_label()
		_PRICE.show()
	else:
		_PRICE.hide()

func _reset() -> void:
	_luck_state = _LuckState.NONE
	_freeze_ignite_state = _FreezeIgniteState.NONE
	_material_state = _MaterialState.NONE
	_supercharged = false
	_round_tails_penalty_reduction = 0
	_permanent_tails_penalty_reduction = 0

func init_coin(coin_family: Global.CoinFamily, denomination: Global.Denomination, owned_by: Owner):
	_coin_family = coin_family
	_denomination = denomination
	# in the case of a trade; we don't need to reconnect signals
	if not Global.souls_count_changed.is_connected(_update_price_label):
		Global.souls_count_changed.connect(_update_price_label)
	if not Global.state_changed.is_connected(_on_state_changed):
		Global.state_changed.connect(_on_state_changed)
	_PRICE.visible = Global.state == Global.State.SHOP
	_heads_power = FacePower.new(coin_family.heads_power_family, coin_family.heads_power_family.uses_for_denom[_denomination])
	_tails_power = FacePower.new(coin_family.tails_power_family, coin_family.tails_power_family.uses_for_denom[_denomination])
	_heads = true
	reset_power_uses()
	_owner = owned_by
	_reset()

func coin_family() -> Global.CoinFamily:
	return _coin_family

func mark_owned_by_player() -> void:
	_owner = Owner.PLAYER

func get_store_price() -> int:
	return _coin_family.store_price_for_denom[_denomination]

func get_sell_price() -> int:
	#breakpoint #deprecated for now
	return max(1, int(get_store_price()/3.0))

func can_upgrade() -> bool:
	return _denomination != Global.Denomination.TETROBOL

func get_denomination() -> Global.Denomination:
	return _denomination

func get_denomination_as_int() -> int:
	match(_denomination):
		Global.Denomination.OBOL:
			return 1
		Global.Denomination.DIOBOL:
			return 2
		Global.Denomination.TRIOBOL:
			return 3
		Global.Denomination.TETROBOL:
			return 4
	assert(false)
	return -9999

func get_subtitle() -> String:
		return _coin_family.subtitle
	
func get_heads_icon_path() -> String:
	return _coin_family.heads_icon_path

func get_tails_icon_path() -> String:
	return _coin_family.tails_icon_path

func get_coin_name() -> String:
	return _replace_placeholder_text(_coin_family.coin_name, -1, -1)

func get_style_string() -> String:
	return _coin_family.get_style_string()

func get_value() -> int:
	match(_denomination):
		Global.Denomination.OBOL:
			return 1
		Global.Denomination.DIOBOL:
			return 2
		Global.Denomination.TRIOBOL:
			return 3
		Global.Denomination.TETROBOL:
			return 4
	return 0

func upgrade() -> void:
	match(_denomination):
		Global.Denomination.OBOL:
			_denomination = Global.Denomination.DIOBOL
		Global.Denomination.DIOBOL:
			_denomination = Global.Denomination.TRIOBOL
		Global.Denomination.TRIOBOL:
			_denomination = Global.Denomination.TETROBOL
	_update_face_label()
	_update_price_label()
	set_animation(_Animation.FLAT) # update sprite

func downgrade() -> void:
	match(_denomination):
		Global.Denomination.DIOBOL:
			_denomination = Global.Denomination.OBOL
		Global.Denomination.TRIOBOL:
			_denomination = Global.Denomination.DIOBOL
		Global.Denomination.TETROBOL:
			_denomination = Global.Denomination.TRIOBOL
	_update_face_label()
	_update_price_label()
	set_animation(_Animation.FLAT) # update sprite

func get_upgrade_price() -> int:
	match(_denomination):
		Global.Denomination.OBOL:
			return _coin_family.store_price_for_denom[Global.Denomination.DIOBOL] - _coin_family.store_price_for_denom[Global.Denomination.OBOL] + 1
		Global.Denomination.DIOBOL:
			return _coin_family.store_price_for_denom[Global.Denomination.TRIOBOL] - _coin_family.store_price_for_denom[Global.Denomination.DIOBOL] + 3
		Global.Denomination.TRIOBOL:
			return _coin_family.store_price_for_denom[Global.Denomination.TETROBOL] - _coin_family.store_price_for_denom[Global.Denomination.TRIOBOL] + 5
		Global.Denomination.TETROBOL:
			return 100000 #error case really
	breakpoint
	return 10000

func flip(bonus: int = 0) -> void:
	if is_frozen(): #don't flip if frozen
		# todo - animation for unfreezing
		_freeze_ignite_state = _FreezeIgniteState.NONE
		emit_signal("flip_complete")
		return
	
	if is_stone(): #don't flip if stoned
		emit_signal("flip_complete")
		return
	
	if is_ignited():
		#todo - animation for ignite
		Global.lives -= get_value()
		
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
	if is_stone():
		return
	_heads = not _heads
	_FACE_LABEL.hide()
	set_animation(_Animation.FLIP)
	await _SPRITE.animation_looped
	set_animation(_Animation.FLAT)
	_FACE_LABEL.show()

func get_active_power_family() -> Global.PowerFamily:
	return _heads_power.power_family if is_heads() else _tails_power.power_family

func get_active_power_charges() -> int:
	return _heads_power.charges if is_heads() else _tails_power.charges

func get_max_active_power_charges() -> int:
	return _heads_power.power_family.uses_for_denom[_denomination] if is_heads() else _tails_power.power_family.uses_for_denom[_denomination]

func spend_power_use() -> void:
	if is_heads():
		_heads_power.charges -= 1
	else:
		_tails_power.charges -= 1
	assert(_heads_power.charges >= 0)
	assert(_tails_power.charges >= 0)
	_update_face_label()

func reset_power_uses() -> void:
	_heads_power.charges = _heads_power.power_family.uses_for_denom[_denomination]
	_tails_power.charges = _tails_power.power_family.uses_for_denom[_denomination]
	
	if _heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE:
		_heads_power.charges -= (_permanent_tails_penalty_reduction + _round_tails_penalty_reduction)
	if _tails_power.power_family == Global.POWER_FAMILY_LOSE_LIFE:
		_tails_power.charges -= (_permanent_tails_penalty_reduction + _round_tails_penalty_reduction)
	
	_update_face_label()

func recharge_power_uses_by(recharge_amount: int) -> void:
	assert(recharge_amount > 0)
	if is_heads():
		_heads_power.charges += recharge_amount
	else:
		_tails_power.charges += recharge_amount
	_update_face_label()

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

func stone() -> void:
	_material_state = _MaterialState.STONE

func clear_freeze_ignite() -> void:
	_freeze_ignite_state = _FreezeIgniteState.NONE

func clear_material() -> void:
	_material_state = _MaterialState.NONE

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

func is_stone() -> bool:
	return _material_state == _MaterialState.STONE

func can_reduce_life_penalty() -> bool:
	var can_reduce_heads = (_heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _heads_power.charges != 0)
	var can_reduce_tails = (_tails_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _tails_power.charges != 0)
	return can_reduce_heads or can_reduce_tails

func reduce_life_penalty_permanently() -> void:
	_permanent_tails_penalty_reduction += 1
	var reduced_power = _heads_power if (_heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _heads_power.charges != 0) else _tails_power
	reduced_power.charges -= 1
	_update_face_label()
	_generate_tooltip()

func reduce_life_penalty_for_round() -> void:
	assert(can_reduce_life_penalty())
	var reduced_power = _heads_power if (_heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _heads_power.charges != 0) else _tails_power
	_round_tails_penalty_reduction += 1
	reduced_power.charges -= 1
	_update_face_label()
	_generate_tooltip()

func disable_input() -> void:
	_disabled = true

func enable_input() -> void:
	_disabled = false

func _replace_placeholder_text(txt: String, max_charges: int = -1, current_charges: int = -1) -> String:
	txt = txt.replace("(DENOM)", Global.denom_to_string(_denomination))
	if max_charges != -1:
		txt = txt.replace("(MAX_CHARGES)", str(max_charges))
	if current_charges != -1:
		txt = txt.replace("(CURRENT_CHARGES)", str(current_charges))
	txt = txt.replace("(HADES_MULTIPLIER)", str(get_value() * 2))
	txt = txt.replace("(1_PER_DENOM)", str(get_denomination_as_int()))
	txt = txt.replace("(1+1_PER_DENOM)", str(get_denomination_as_int() + 1))
	return txt

func _generate_tooltip() -> void:
	const TOOLTIP_FORMAT = "[center]%s\n[color=yellow]%s[/color]\n[img=12x13]res://assets/icons/heads_icon.png[/img] %s\n[img=12x13]res://assets/icons/tails_icon.png[/img] %s[/center]"
	
	var coin_name = get_coin_name()
	var subtitle = get_subtitle()
	var heads_power_str = _replace_placeholder_text(_heads_power.power_family.description, _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
	var tails_power_str = _replace_placeholder_text(_tails_power.power_family.description, _tails_power.power_family.uses_for_denom[_denomination], _tails_power.charges)
	
	var txt = TOOLTIP_FORMAT % [coin_name, subtitle, heads_power_str, tails_power_str]
	
	UITooltip.create(self, txt, get_global_mouse_position(), get_tree().root)

func on_round_end() -> void:
	_round_tails_penalty_reduction = 0
	reset_power_uses()
	# force to heads
	if not _heads:
		turn()

func on_toss_complete() -> void:
	if not is_stone():
		reset_power_uses()

func on_payoff() -> void:
	pass

func set_animation(anim: _Animation) -> void:
	var denom_str = Global.denom_to_string(_denomination).to_lower()
	
	var anim_str = ""
	match(anim):
		_Animation.FLAT:
			anim_str = "flat"
		_Animation.FLIP:
			anim_str = "flip"
	assert(anim_str != "")
	
	_SPRITE.play("%s_%s_%s" % [get_style_string(), denom_str, anim_str])

func _on_clickable_area_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed and not _disabled:
				emit_signal("clicked", self)

func _on_clickable_area_mouse_entered():
	_mouse_over = true

func _on_clickable_area_mouse_exited():
	_mouse_over = false

var _time_mouse_hover = 0
var _mouse_over = false
const _DELAY_BEFORE_TOOLTIP = 0.3

func _physics_process(delta):
	if _mouse_over:
		_time_mouse_hover += delta
	else:
		_time_mouse_hover = 0
	
	if _time_mouse_hover >= _DELAY_BEFORE_TOOLTIP:
		_generate_tooltip()
