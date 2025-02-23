class_name Coin
extends Control

signal flip_complete
signal hovered
signal unhovered
signal clicked

const UNAFFORDABLE_COLOR = "#e12f3b"
const AFFORDABLE_COLOR = "#ffffff"

enum Owner {
	SHOP, PLAYER, NEMESIS
}

enum _BlessCurseState {
	NONE, BLESSED, CURSED
}

enum _LuckState {
	NONE, LUCKY, UNLUCKY,
	SLIGHTLY_LUCKY, QUITE_LUCKY, INCREDIBLY_LUCKY
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

@onready var _STATUS_BAR = $Sprite/StatusBar
@onready var _LUCKY_ICON = $Sprite/StatusBar/Lucky
@onready var _SLIGHTLY_LUCKY_ICON = $Sprite/StatusBar/SlightlyLucky
@onready var _QUITE_LUCKY_ICON = $Sprite/StatusBar/QuiteLucky
@onready var _INCREDIBLY_LUCKY_ICON = $Sprite/StatusBar/IncrediblyLucky
@onready var _UNLUCKY_ICON = $Sprite/StatusBar/Unlucky
@onready var _FREEZE_ICON = $Sprite/StatusBar/Freeze
@onready var _IGNITE_ICON = $Sprite/StatusBar/Ignite
@onready var _BLESS_ICON = $Sprite/StatusBar/Bless
@onready var _CURSE_ICON = $Sprite/StatusBar/Curse
@onready var _SUPERCHARGE_ICON = $Sprite/StatusBar/Supercharge
@onready var _STONE_ICON = $Sprite/StatusBar/Stone
@onready var _BLANK_ICON = $Sprite/StatusBar/Blank

@onready var _SPRITE = $Sprite
@onready var _FACE_LABEL = $Sprite/FaceLabel
@onready var _PRICE = $Sprite/Price

@onready var _NEXT_FLIP_INDICATOR = $Sprite/NextFlipIndicator

@onready var FX : FX = $Sprite/FX

# $HACK$ needed to center the text properly by dynamically resizing the label when charges are 0...
@onready var _FACE_LABEL_DEFAULT_POSITION = _FACE_LABEL.position

@onready var _coin_movement_tween: Global.ManagedTween = Global.ManagedTween.new(self, "global_position")
@onready var _sprite_movement_tween: Global.ManagedTween = Global.ManagedTween.new(_SPRITE, "position")

var _disable_interaction := false:
	set(val):
		_disable_interaction = val
		_update_appearance()
		if _disable_interaction:
			UITooltip.clear_tooltip_for(self)

var _owner: Owner:
	set(val):
		_owner = val
		_update_appearance()

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
		_update_appearance()

class FacePower:
	var charges: int = 0
	var power_family: Global.PowerFamily
	
	func _init(fam: Global.PowerFamily, starting_charges: int):
		self.power_family = fam
		self.charges = starting_charges

var _heads_power: FacePower:
	set(val):
		_heads_power = val
		_update_appearance()

var _tails_power: FacePower:
	set(val):
		_tails_power = val
		_update_appearance()

# updates face label, glow, and price label
func _update_appearance() -> void:
	_update_face_label()
	_update_price_label()
	_update_glow()
	_NEXT_FLIP_INDICATOR.update(_get_next_heads(), is_passive())

const _FACE_FORMAT = "[center][color=%s]%s[/color][img=10x13]%s[/img][/center]"
const _RED = "#e12f3b"
const _BLUE = "#a6fcdb"
const _YELLOW = "#ffd541"
const _GRAY = "#b3b9d1"
func _update_face_label() -> void:
	if _blank:
		_FACE_LABEL.text = ""
		return
	
	var color
	match(get_active_power_family().power_type):
		Global.PowerType.PAYOFF_LOSE_LIFE, Global.PowerType.PAYOFF_LOSE_SOULS:
			color = _RED
		Global.PowerType.PAYOFF_GAIN_SOULS:
			color = _BLUE
		_:
			color = _YELLOW if get_active_power_charges() != 0 else _GRAY
	
	# if we prefer to only show icon (generally, monsters) AND the number of charges is 0 (trials) or 1 (most monsters), only show the icon
	var only_show_icon = get_active_power_family().prefer_icon_only and get_active_power_charges() <= 1
	var charges_str = "" if only_show_icon else ("%d" % get_active_power_charges())
	_FACE_LABEL.text = _FACE_FORMAT % [color, "%s" % charges_str, get_active_power_family().icon_path]
	
	# this is a $HACK$ to center the icon better when no charges are shown
	if only_show_icon:
		_FACE_LABEL.position = _FACE_LABEL_DEFAULT_POSITION - Vector2(1, 0)
	else:
		_FACE_LABEL.position = _FACE_LABEL_DEFAULT_POSITION 

const _BUY_FORMAT = "[center][color=%s]%d[/color][/center](SOULS)"
const _UPGRADE_SELL_FORMAT = "[center][color=%s]%d[/color][/center](SOULS)"
const _APPEASE_FORMAT = "[center][color=%s]-%d[/color][/center](SOULS)"
const _TOLL_FORMAT = "[center]%d[/center](COIN)"
func _update_price_label() -> void:
	if Global.state == Global.State.SHOP:
		# special case - can't upgrade further, show nothing
		if _owner == Owner.PLAYER and not can_upgrade() and not Global.is_character(Global.Character.MERCHANT):
			_PRICE.text = ""
			return
		
		var price
		var color
		if _owner == Owner.PLAYER:
			price = get_sell_price() if Global.is_character(Global.Character.MERCHANT) else get_upgrade_price()
			color = AFFORDABLE_COLOR if Global.is_character(Global.Character.MERCHANT) or Global.souls >= price else UNAFFORDABLE_COLOR
		else:
			price = get_store_price()
			color = AFFORDABLE_COLOR if Global.souls >= price else UNAFFORDABLE_COLOR
		
		_PRICE.text = Global.replace_placeholders((_UPGRADE_SELL_FORMAT if _owner == Owner.PLAYER else _BUY_FORMAT) % [color, price])
		
		# hide upgrade label during some parts of tutorial
		var no_upgrade_tutorial = [Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN, Global.TutorialState.ROUND1_SHOP_AFTER_BUYING_COIN, Global.TutorialState.ROUND2_POWER_INTRO]
		if _owner == Owner.PLAYER and Global.tutorialState in no_upgrade_tutorial:
			_PRICE.text = ""
	elif Global.state == Global.State.TOLLGATE:
		# if the coin cannot be offered at a tollgate, show nothing
		if _coin_family in Global.TOLL_EXCLUDE_COIN_FAMILIES:
			_PRICE.text = ""
			return
		var value = get_value()
		if _coin_family in Global.TOLL_NEGATIVE_COIN_FAMILIES:
			value = -value
		_PRICE.text = Global.replace_placeholders(_TOLL_FORMAT % value)
	elif is_appeaseable():
		var price = get_appeasal_price()
		var color = AFFORDABLE_COLOR if Global.souls >= price else UNAFFORDABLE_COLOR
		_PRICE.text = Global.replace_placeholders(_APPEASE_FORMAT % [color, price])

func show_price() -> void:
	_PRICE.modulate.a = 0.0
	create_tween().tween_property(_PRICE, "modulate:a", 1.0, 0.25)

func hide_price() -> void:
	_PRICE.modulate.a = 0.0

func _update_glow():
	# if this coin is an enemy coin, glow purple at all times
	if _owner == Owner.NEMESIS:
		FX.start_glowing(Color.MEDIUM_PURPLE, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, FX.FAST_GLOW_MINIMUM, false)
		return
	
	# if coin is disabled or another coin is activated right now, don't glow at all
	if _disable_interaction:
		FX.stop_glowing()
		return
	
	# if another coin is active now and hovering this coin as a target, glow white
	if Global.active_coin_power_family != null and Global.active_coin_power_coin != self and _MOUSE.is_over():
		FX.start_glowing(Color.AZURE, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, 1.0, false)
		return
	
	# if this is the active power coin, glow solid gold
	if Global.active_coin_power_coin == self:
		FX.start_glowing(Color.GOLD, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, 1.0, false)
		return
		
	# if this coin can be activated, glow white (solid if mouse over)
	if Global.state == Global.State.AFTER_FLIP and get_active_power_charges() != 0 and can_activate_power() and Global.active_coin_power_coin == null:
		FX.start_glowing(Color.AZURE, FX.FAST_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, 1.0 if _MOUSE.is_over() else FX.FAST_GLOW_MINIMUM, false)
		return
	
	FX.stop_glowing()

var _blank: bool = false:
	set(val):
		_blank = val
		_STATUS_BAR.update_icon(_BLANK_ICON, _blank)
		if _blank:
			_play_new_status_effect("res://assets/icons/status/blank_icon.png")
			FX.flash(Color.BISQUE)
		_update_appearance()

var _bless_curse_state: _BlessCurseState:
	set(val):
		_bless_curse_state = val
		_STATUS_BAR.update_icon(_BLESS_ICON, _bless_curse_state == _BlessCurseState.BLESSED)
		_STATUS_BAR.update_icon(_CURSE_ICON, _bless_curse_state == _BlessCurseState.CURSED)
		
		if _bless_curse_state == _BlessCurseState.BLESSED:
			FX.flash(Color.YELLOW)
			_play_new_status_effect("res://assets/icons/status/bless_icon.png")
		elif _bless_curse_state == _BlessCurseState.CURSED:
			FX.flash(Color.PURPLE)
			_play_new_status_effect("res://assets/icons/status/curse_icon.png")
		_update_appearance()

var _freeze_ignite_state: _FreezeIgniteState:
	set(val):
		_freeze_ignite_state = val
		_STATUS_BAR.update_icon(_FREEZE_ICON, _freeze_ignite_state == _FreezeIgniteState.FROZEN)
		_STATUS_BAR.update_icon(_IGNITE_ICON, _freeze_ignite_state == _FreezeIgniteState.IGNITED)
		
		if _freeze_ignite_state == _FreezeIgniteState.FROZEN:
			FX.flash(Color.CYAN)
			FX.tint(Color.CYAN, 0.8)
			_play_new_status_effect("res://assets/icons/status/freeze_icon.png")
		elif _freeze_ignite_state == _FreezeIgniteState.IGNITED:
			FX.flash(Color.RED)
			FX.tint(Color.RED, 0.7)
			_play_new_status_effect("res://assets/icons/status/ignite_icon.png")
		elif _freeze_ignite_state == _FreezeIgniteState.NONE and not is_stone():
			FX.clear_tint()

var _supercharged: bool:
	set(val):
		_supercharged = val
		_STATUS_BAR.update_icon(_SUPERCHARGE_ICON, _supercharged)
		if _supercharged:
			FX.flash(Color.YELLOW)
			_play_new_status_effect("res://assets/icons/status/supercharge_icon.png")
			# TODO - add particles here

var _luck_state: _LuckState:
	set(val):
		_luck_state = val
		_STATUS_BAR.update_icon(_LUCKY_ICON, _luck_state == _LuckState.LUCKY)
		_STATUS_BAR.update_icon(_UNLUCKY_ICON, _luck_state == _LuckState.UNLUCKY)
		_STATUS_BAR.update_icon(_SLIGHTLY_LUCKY_ICON, _luck_state == _LuckState.SLIGHTLY_LUCKY)
		_STATUS_BAR.update_icon(_QUITE_LUCKY_ICON, _luck_state == _LuckState.QUITE_LUCKY)
		_STATUS_BAR.update_icon(_INCREDIBLY_LUCKY_ICON, _luck_state == _LuckState.INCREDIBLY_LUCKY)
		
		if _luck_state == _LuckState.LUCKY or _luck_state == _LuckState.SLIGHTLY_LUCKY\
			or _luck_state == _LuckState.QUITE_LUCKY or _luck_state == _LuckState.INCREDIBLY_LUCKY:
			FX.flash(Color.LAWN_GREEN)
			FX.recolor_outline(Color("#59c035")) #lucky
			_play_new_status_effect("res://assets/icons/status/lucky_icon.png")
		elif _luck_state == _LuckState.UNLUCKY:
			FX.flash(Color.ORANGE_RED)
			FX.recolor_outline(Color("#b3202a")) #unlucky
			_play_new_status_effect("res://assets/icons/status/unlucky_icon.png")
		else:
			FX.recolor_outline_to_default()
		_update_appearance()

var _material_state: _MaterialState:
	set(val):
		_material_state = val
		_STATUS_BAR.update_icon(_STONE_ICON, _material_state == _MaterialState.STONE)
		
		if _material_state == _MaterialState.STONE:
			FX.flash(Color.SLATE_GRAY)
			FX.tint(Color.SLATE_GRAY, 0.7)
			_play_new_status_effect("res://assets/icons/status/stone_icon.png")
		elif _material_state == _MaterialState.NONE and not is_ignited():
			FX.clear_tint()

# modifies life penalties
var _round_life_penalty_change = 0
var _permanent_life_penalty_change = 0 

# roll that will be used the next time this coin is flipped; used so we can 'predict' flips
var _next_flip_roll = Global.RNG.randi_range(1, 100)

func _ready():
	assert(_SPRITE)
	assert(_FACE_LABEL)
	assert(FX)
	assert(_LUCKY_ICON)
	assert(_UNLUCKY_ICON)
	assert(_BLANK_ICON)
	assert(_STONE_ICON)
	assert(_FREEZE_ICON)
	assert(_IGNITE_ICON)
	assert(_BLESS_ICON)
	assert(_CURSE_ICON)
	assert(_SUPERCHARGE_ICON)
	assert(_STATUS_BAR)
	Global.active_coin_power_coin_changed.connect(_on_active_coin_power_coin_changed)
	Global.tutorial_state_changed.connect(_on_tutorial_state_changed)
	Global.passive_triggered.connect(_on_passive_triggered)

static var _PARTICLE_ICON_GROW_SCENE = preload("res://particles/icon_grow.tscn")
@onready var _POWER_ICON_GROW_POINT = $Sprite/PowerIconGrowPoint
func play_power_used_effect(power: Global.PowerFamily) -> void:
	var particle: GPUParticles2D = _PARTICLE_ICON_GROW_SCENE.instantiate()
	particle.texture = load(power.icon_path)
	_POWER_ICON_GROW_POINT.add_child(particle)

static var _PARTICLE_ICON_SHRINK_SCENE = preload("res://particles/icon_shrink.tscn")
@onready var _STATUS_ICON_SHRINK_POINT = $Sprite/StatusIconShrinkPoint
func _play_new_status_effect(icon_path: String) -> void:
	var particle: GPUParticles2D = _PARTICLE_ICON_SHRINK_SCENE.instantiate()
	particle.texture = load(icon_path)
	_STATUS_ICON_SHRINK_POINT.add_child(particle)

func _on_passive_triggered(passive: Global.PowerFamily) -> void:
	if _heads_power.power_family == passive or _tails_power.power_family == passive:
		if _owner == Owner.NEMESIS:
			FX.flash(Color.PURPLE)
		else:
			FX.flash(Color.GOLD)

func _on_state_changed() -> void:
	_update_appearance()
	if Global.state == Global.State.SHOP or Global.state == Global.State.TOLLGATE or (is_appeaseable() and (Global.state == Global.State.BEFORE_FLIP or Global.state == Global.State.AFTER_FLIP)):
		_PRICE.show()
	else:
		_PRICE.hide()

func _set_heads_power_to(power_family: Global.PowerFamily) -> void:
	_heads_power = FacePower.new(power_family, power_family.uses_for_denom[_denomination])

func _set_tails_power_to(power_family: Global.PowerFamily) -> void:
	_tails_power = FacePower.new(power_family, power_family.uses_for_denom[_denomination])

func init_coin(family: Global.CoinFamily, denomination: Global.Denomination, owned_by: Owner):
	_coin_family = family
	_denomination = denomination
	# in the case of a trade; we don't need to reconnect signals
	if not Global.souls_count_changed.is_connected(_update_price_label):
		Global.souls_count_changed.connect(_update_price_label)
	if not Global.state_changed.is_connected(_on_state_changed):
		Global.state_changed.connect(_on_state_changed)
	_set_heads_power_to(_coin_family.heads_power_family)
	_set_tails_power_to(_coin_family.tails_power_family)
	_heads = true
	_owner = owned_by
	_blank = false
	_luck_state = _LuckState.NONE
	_bless_curse_state = _BlessCurseState.NONE
	_freeze_ignite_state = _FreezeIgniteState.NONE
	_material_state = _MaterialState.NONE
	_supercharged = false
	_round_life_penalty_change = 0
	_permanent_life_penalty_change = 0
	_PRICE.visible = Global.state == Global.State.SHOP or is_appeaseable()
	reset_power_uses(true)
	_on_state_changed() # a bit of a hack but it is a good catchall...

func get_appeasal_price() -> int:
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ARES) and is_tails():
		return _coin_family.appeasal_price_for_denom[_denomination] / 2
	return _coin_family.appeasal_price_for_denom[_denomination]

func is_appeaseable() -> bool:
	return get_appeasal_price() != Global.NOT_APPEASEABLE_PRICE and _owner == Owner.NEMESIS

func get_coin_family() -> Global.CoinFamily:
	return _coin_family

func mark_owned_by_player() -> void:
	_owner = Owner.PLAYER

func is_owned_by_player() -> bool:
	return _owner == Owner.PLAYER

func is_monster() -> bool:
	return _owner == Owner.NEMESIS

func get_store_price() -> int:
	var upgrade_modifier = Global.get_cumulative_to_upgrade_to(_denomination)
	return floor(_coin_family.base_price * Global.current_round_shop_multiplier()) + floor(upgrade_modifier * Global.STORE_UPGRADE_DISCOUNT)

func get_upgrade_price() -> int:
	return Global.get_price_to_upgrade(_denomination)

const _SELL_MULT = 0.5
func get_sell_price() -> int:
	return max(1, ceil(get_store_price() * _SELL_MULT))

func can_upgrade() -> bool:
	if _coin_family in Global.UPGRADE_EXCLUDE_COIN_FAMILIES:
		return false
	
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_HEPHAESTUS) or _owner == Owner.NEMESIS:
		return _denomination != Global.Denomination.DRACHMA
	
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
		Global.Denomination.PENTOBOL:
			return 5
		Global.Denomination.DRACHMA:
			return 6
	assert(false)
	return -9999

func get_subtitle() -> String:
		return _coin_family.subtitle
	
func get_heads_icon_path() -> String:
	return _coin_family.heads_icon_path

func get_tails_icon_path() -> String:
	return _coin_family.tails_icon_path

func get_coin_name() -> String:
	return _replace_placeholder_text(_coin_family.coin_name)

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
		Global.Denomination.PENTOBOL:
			return 5
		Global.Denomination.DRACHMA:
			return 6
	return 0

func upgrade() -> void:
	if not can_upgrade():
		assert(false, "Trying to upgrade a coin that we shouldn't.")
		return
	
	var prev_denom = _denomination
	
	match(_denomination):
		Global.Denomination.OBOL:
			_denomination = Global.Denomination.DIOBOL
		Global.Denomination.DIOBOL:
			_denomination = Global.Denomination.TRIOBOL
		Global.Denomination.TRIOBOL:
			_denomination = Global.Denomination.TETROBOL
		Global.Denomination.TETROBOL:
			_denomination = Global.Denomination.PENTOBOL
			if Global.is_passive_active(Global.PATRON_POWER_FAMILY_HEPHAESTUS):
				Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_HADES)
		Global.Denomination.PENTOBOL:
			_denomination = Global.Denomination.DRACHMA
			if Global.is_passive_active(Global.PATRON_POWER_FAMILY_HEPHAESTUS):
				Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_HADES)
	
	# update charges to include the upgrade
	var heads_charges_delta = _heads_power.power_family.uses_for_denom[_denomination] - _heads_power.power_family.uses_for_denom[prev_denom]
	_heads_power.charges += heads_charges_delta
	var tails_charges_delta = _tails_power.power_family.uses_for_denom[_denomination] - _tails_power.power_family.uses_for_denom[prev_denom]
	_tails_power.charges += tails_charges_delta
	
	_update_appearance()
	set_animation(_Animation.FLAT) # update sprite
	FX.flash(Color.GOLDENROD)

func downgrade(no_flash: bool = false) -> void:
	if _denomination == Global.Denomination.OBOL:
		assert(false, "downgrading an obol")
		return
	
	var prev_denom = _denomination
	
	match(_denomination):
		Global.Denomination.DIOBOL:
			_denomination = Global.Denomination.OBOL
		Global.Denomination.TRIOBOL:
			_denomination = Global.Denomination.DIOBOL
		Global.Denomination.TETROBOL:
			_denomination = Global.Denomination.TRIOBOL
		Global.Denomination.PENTOBOL:
			_denomination = Global.Denomination.TETROBOL
		Global.Denomination.DRACHMA:
			_denomination = Global.Denomination.PENTOBOL
		_:
			assert(false, "no matching case?")
			return
	
	# update charges to include the upgrade
	var heads_charges_delta = _heads_power.power_family.uses_for_denom[_denomination] - _heads_power.power_family.uses_for_denom[prev_denom]
	_heads_power.charges += heads_charges_delta
	var tails_charges_delta = _tails_power.power_family.uses_for_denom[_denomination] - _tails_power.power_family.uses_for_denom[prev_denom]
	_tails_power.charges += tails_charges_delta
	
	_update_appearance()
	set_animation(_Animation.FLAT) # update sprite
	if not no_flash:
		FX.flash(Color.DARK_GRAY)

func is_passive() -> bool:
	return get_active_power_family().is_passive()

func is_payoff() -> bool:
	return get_active_power_family().is_payoff()

func is_power() -> bool:
	return get_active_power_family().is_power()

func is_other_face_power() -> bool:
	return get_inactive_power_family().is_power()
	
func can_activate_power() -> bool:
	return get_active_power_family().is_power() and not _blank

const LUCKY_MODIFIER = 20
const SLIGHTLY_LUCKY_MODIFIER = 13
const QUITE_LUCKY_MODIFIER = 26
const INCREDIBLY_LUCKY_MODIFIER = 39
const UNLUCKY_MODIFIER = -20
func flip(is_toss: bool, bonus: int = 0) -> void:
	if get_active_power_family().is_passive():
		_freeze_ignite_state = _FreezeIgniteState.NONE
		emit_signal("flip_complete")
		return
	
	if is_frozen(): #don't flip if frozen
		FX.flash(Color.AQUAMARINE)
		_freeze_ignite_state = _FreezeIgniteState.NONE
		emit_signal("flip_complete")
		return
	
	if is_stone(): #don't flip if stoned
		emit_signal("flip_complete")
		return
		
	_disable_interaction = true # ignore input while flipping
	
	# hide the flash
	FX.stop_flashing()
	
	# animate
	_FACE_LABEL.hide() # hide text
	_PRICE.hide() # hide appease cost
	_NEXT_FLIP_INDICATOR.hide()
	
	_heads = _get_next_heads(is_toss, bonus)
	
	if not is_toss and Global.is_passive_active(Global.PATRON_POWER_FAMILY_HERA):
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_HERA)
	elif is_blessed():
		FX.flash(Color.PALE_GOLDENROD)
		_bless_curse_state = _BlessCurseState.NONE
	elif is_cursed():
		FX.flash(Color.ORCHID)
		_bless_curse_state = _BlessCurseState.NONE
	
	if is_heads() and _luck_state == _LuckState.LUCKY and _get_percentage_success(bonus) - _next_flip_roll < LUCKY_MODIFIER:
		#prnt("roll %d, success chance %d; lucky mattered" % [roll, percentage_success])
		FX.flash(Color.LAWN_GREEN) # succeeded because of lucky
	elif is_heads() and _luck_state == _LuckState.SLIGHTLY_LUCKY and _get_percentage_success(bonus) - _next_flip_roll < SLIGHTLY_LUCKY_MODIFIER:
		FX.flash(Color.LAWN_GREEN) # succeeded because of lucky
	elif is_heads() and _luck_state == _LuckState.QUITE_LUCKY and _get_percentage_success(bonus) - _next_flip_roll < SLIGHTLY_LUCKY_MODIFIER:
		FX.flash(Color.LAWN_GREEN) # succeeded because of lucky
	elif is_heads() and _luck_state == _LuckState.INCREDIBLY_LUCKY and _get_percentage_success(bonus) - _next_flip_roll < SLIGHTLY_LUCKY_MODIFIER:
		FX.flash(Color.LAWN_GREEN) # succeeded because of lucky
	elif is_tails() and _luck_state == _LuckState.UNLUCKY and _get_percentage_success(bonus) - _next_flip_roll >= UNLUCKY_MODIFIER:
		#prnt("roll %d, success chance %d; unlucky mattered" % [roll, percentage_success])
		FX.flash(Color.ORANGE_RED) # failed because of unlucky
	
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_EQUIVALENCE): # equivalence trial - if heads, curse, if tails, bless
		_luck_state = _LuckState.UNLUCKY if _heads else _LuckState.LUCKY
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_EQUIVALENCE)
	
	# roll new RNG number
	_next_flip_roll = Global.RNG.randi_range(1, 100)
	
	# todo - make it move up in a parabola; add a shadow
	set_animation(_Animation.FLIP)

	await _sprite_movement_tween.tween(Vector2(0, -50), 0.2)
	await Global.delay(0.1)
	await _sprite_movement_tween.tween(Vector2(0, 0), 0.2)
	
	set_animation(_Animation.FLAT)
	
	_FACE_LABEL.show()
	if is_appeaseable():
		_PRICE.show()
	_NEXT_FLIP_INDICATOR.update_visibility()
	
	# if supercharged and we landed on tails, flip again.
	if _supercharged and not _heads:
		FX.flash(Color.YELLOW)
		_supercharged = false
		await flip(is_toss)
		return
	
	emit_signal("flip_complete")
	
	_disable_interaction = false

func _get_next_heads(is_toss: bool = false, bonus: int = 0) -> bool:
	if not is_toss and Global.is_passive_active(Global.PATRON_POWER_FAMILY_HERA):
		return not _heads
	elif is_blessed():
		return true
	elif is_cursed():
		return false
	return _get_percentage_success(bonus) >= _next_flip_roll 

func _get_percentage_success(bonus: int = 0):
	# the % value to succeed
	var percentage_success = 50 + bonus
	match(_luck_state):
		_LuckState.LUCKY:
			percentage_success += LUCKY_MODIFIER
		_LuckState.SLIGHTLY_LUCKY:
			percentage_success += SLIGHTLY_LUCKY_MODIFIER
		_LuckState.QUITE_LUCKY:
			percentage_success += QUITE_LUCKY_MODIFIER
		_LuckState.INCREDIBLY_LUCKY:
			percentage_success += INCREDIBLY_LUCKY_MODIFIER
		_LuckState.UNLUCKY:
			percentage_success += UNLUCKY_MODIFIER
	return percentage_success

# turn a coin to its other side
func turn() -> void:
	if is_stone():
		return
	_disable_interaction = true
	_heads = not _heads
	_FACE_LABEL.hide()
	set_animation(_Animation.FLIP)
	await _SPRITE.animation_looped
	set_animation(_Animation.FLAT)
	_FACE_LABEL.show()
	_disable_interaction = false

# sets to heads without an animation
func set_heads_no_anim() -> void:
	_heads = true

# sets to tails without an animation
func set_tails_no_anim() -> void:
	_heads = false

var _marked_for_destruction = false
func destroy() -> void:
	assert(not _marked_for_destruction)
	_marked_for_destruction = true
	_disable_interaction = true # disable all interaction while destroying
	FX.stop_all() # disable all effects
	_FACE_LABEL.hide() # hide the text
	_STATUS_BAR.hide() # hide the status icons
	hide_price() # hide price (for monsters)
	FX.disable_exclude_colors() # don't exclude border when disintegrating
	
	# fade and disintegrate quickly
	FX.fade_out(0.2)
	await FX.disintegrate(0.2)
	queue_free() # and free when done

func is_being_destroyed() -> bool:
	return _marked_for_destruction

func get_active_power_family() -> Global.PowerFamily:
	return _heads_power.power_family if is_heads() else _tails_power.power_family

func get_inactive_power_family() -> Global.PowerFamily:
	return _heads_power.power_family if is_tails() else _heads_power.power_family

func get_active_power_charges() -> int:
	return _heads_power.charges if is_heads() else _tails_power.charges

func get_max_active_power_charges() -> int:
	return _heads_power.power_family.uses_for_denom[_denomination] if is_heads() else _tails_power.power_family.uses_for_denom[_denomination]

func spend_power_use() -> void:
	if is_heads():
		assert(_heads_power.charges >= 0)
		_heads_power.charges -= 1
	else:
		assert(_tails_power.charges >= 0)
		_tails_power.charges -= 1
	
	_update_appearance()
	FX.flash(Color.WHITE)

func _calculate_charge_amount(power_family: Global.PowerFamily, current_charges: int, ignore_sapping: bool) -> int:
	if power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE:
		return max(0, power_family.uses_for_denom[_denomination] + (_permanent_life_penalty_change + _round_life_penalty_change))
	elif is_stone():
		return current_charges
	elif Global.is_passive_active(Global.TRIAL_POWER_FAMILY_SAPPING) and not ignore_sapping: #recharge only by 1
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_SAPPING)
		return min(current_charges + 1, power_family.uses_for_denom[_denomination])
	return power_family.uses_for_denom[_denomination]

func reset_power_uses(ignore_sapping: bool = false) -> void:
	var new_heads_charges = _calculate_charge_amount(_heads_power.power_family, _heads_power.charges, ignore_sapping)
	var new_tails_charges = _calculate_charge_amount(_tails_power.power_family, _tails_power.charges, ignore_sapping)
	
	if _heads_power.charges < new_heads_charges or _tails_power.charges < new_tails_charges:
		FX.flash(Color.LIGHT_PINK)
	_heads_power.charges = new_heads_charges
	_tails_power.charges = new_tails_charges
	
	_update_appearance()

func recharge_power_uses_by(recharge_amount: int) -> void:
	assert(recharge_amount > 0)
	if is_heads():
		_heads_power.charges += recharge_amount
	else:
		_tails_power.charges += recharge_amount
	_update_appearance()
	FX.flash(Color.LIGHT_PINK)

func drain_power_uses_by(drain_amount: int) -> void:
	assert(drain_amount < 0)
	if is_heads():
		_heads_power.charges = max(_heads_power.charges - drain_amount, 0)
	else:
		_tails_power.charges -= max(_tails_power.charges - drain_amount, 0)
	_update_appearance()
	FX.flash(Color.WEB_PURPLE)

func make_lucky() -> void:
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_HESTIA):
		if _luck_state == _LuckState.SLIGHTLY_LUCKY:
			_luck_state = _LuckState.QUITE_LUCKY
		elif _luck_state == _LuckState.QUITE_LUCKY:
			_luck_state = _LuckState.INCREDIBLY_LUCKY
		else:
			_luck_state = _LuckState.SLIGHTLY_LUCKY
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_HESTIA) 
		return
	_luck_state = _LuckState.LUCKY

func make_unlucky() -> void:
	if _luck_state == _LuckState.QUITE_LUCKY:
		_luck_state = _LuckState.SLIGHTLY_LUCKY
	elif _luck_state == _LuckState.INCREDIBLY_LUCKY:
		_luck_state = _LuckState.QUITE_LUCKY
	else:
		_luck_state = _LuckState.UNLUCKY

func blank() -> void:
	_blank = true

func unblank() -> void:
	if _blank:
		FX.flash(Color.BISQUE)
	_blank = false

func supercharge() -> void:
	_supercharged = true

func bless() -> void:
	_bless_curse_state = _BlessCurseState.BLESSED

func curse() -> void:
	_bless_curse_state = _BlessCurseState.CURSED

func freeze() -> void:
	FX.flash(Color.CYAN) # flash ahead of time, even if effect fails
	# if stoned, don't freeze
	_freeze_ignite_state = _FreezeIgniteState.NONE if is_stone() else _FreezeIgniteState.FROZEN
	
	if _freeze_ignite_state == _FreezeIgniteState.FROZEN and Global.is_passive_active(Global.PATRON_POWER_FAMILY_POSEIDON) and _owner == Owner.NEMESIS:
		blank()
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_POSEIDON)

func ignite() -> void:
	FX.flash(Color.RED) # flash ahead of time, even if effect fails
	# if stoned, don't ignite
	_freeze_ignite_state = _FreezeIgniteState.NONE if is_stone() else _FreezeIgniteState.IGNITED

func stone() -> void:
	_material_state = _MaterialState.STONE
	_freeze_ignite_state = _FreezeIgniteState.NONE

func has_status() -> bool:
	return is_blessed() or is_cursed() or is_blank() or is_frozen() or is_ignited() or is_lucky() or is_unlucky() or is_stone() or is_supercharged()

func clear_statuses() -> void:
	if not has_status():
		return
	FX.flash(Color.LIGHT_GREEN)
	_blank = false
	_supercharged = false
	clear_blessed_cursed()
	clear_freeze_ignite()
	clear_material()
	clear_lucky_unlucky()

func clear_lucky_unlucky() -> void:
	if _luck_state == _LuckState.NONE:
		return
	FX.flash(Color.LIGHT_GREEN)
	_luck_state = _LuckState.NONE

func clear_blessed_cursed() -> void:
	if _bless_curse_state == _BlessCurseState.NONE:
		return
	FX.flash(Color.LIGHT_GREEN)
	_bless_curse_state = _BlessCurseState.NONE
	
func clear_freeze_ignite() -> void:
	if _freeze_ignite_state == _FreezeIgniteState.NONE:
		return
	FX.flash(Color.LIGHT_GREEN)
	_freeze_ignite_state = _FreezeIgniteState.NONE

func clear_material() -> void:
	if _material_state == _MaterialState.NONE:
		return
	FX.flash(Color.LIGHT_GREEN)
	_material_state = _MaterialState.NONE

func clear_blanked() -> void:
	if not _blank:
		return
	FX.flash(Color.LIGHT_GREEN)
	_blank = false
	
func is_heads() -> bool:
	if _heads == null:
		return true
	return _heads

func is_tails() -> bool:
	return not _heads

func can_make_lucky() -> bool:
	return _luck_state != _LuckState.LUCKY and _luck_state != _LuckState.INCREDIBLY_LUCKY

func is_lucky() -> bool:
	return _luck_state == _LuckState.LUCKY or _luck_state == _LuckState.SLIGHTLY_LUCKY\
		or _luck_state == _LuckState.QUITE_LUCKY or  _luck_state == _LuckState.INCREDIBLY_LUCKY

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

func is_blank() -> bool:
	return _blank

func is_supercharged() -> bool:
	return _supercharged

func can_change_life_penalty() -> bool:
	return _heads_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE or _tails_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE

func can_reduce_life_penalty() -> bool:
	var can_reduce_heads = (_heads_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE and _heads_power.charges != 0)
	var can_reduce_tails = (_tails_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE and _tails_power.charges != 0)
	return can_reduce_heads or can_reduce_tails

func change_life_penalty_permanently(amt: int) -> void:
	assert(can_change_life_penalty())
	_permanent_life_penalty_change += amt
	if _heads_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE:
		_heads_power.charges = max(_heads_power.charges + amt, 0)
	if _tails_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE:
		_tails_power.charges = max(_tails_power.charges + amt, 0)
	_update_appearance()
	_generate_tooltip()
	if amt < 0:
		FX.flash(Color.SEA_GREEN)
	else:
		FX.flash(Color.CRIMSON)

func change_life_penalty_for_round(amt: int) -> void:
	assert(can_reduce_life_penalty())
	_round_life_penalty_change += amt
	if _heads_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE:
		_heads_power.charges = max(_heads_power.charges + amt, 0)
	if _tails_power.power_family.power_type == Global.PowerType.PAYOFF_LOSE_LIFE:
		_tails_power.charges = max(_tails_power.charges + amt, 0)
	_update_appearance()
	_generate_tooltip()
	if amt < 0:
		FX.flash(Color.SEA_GREEN)
	else:
		FX.flash(Color.CRIMSON)

var _heads_power_overwritten = null
var _tails_power_overwritten = null
func overwrite_active_face_power_for_toss(temporary_power: Global.PowerFamily) -> void:
	FX.flash(Color.HOT_PINK)
	if is_heads():
		_heads_power_overwritten = _heads_power.power_family
		_set_heads_power_to(temporary_power)
	else:
		_tails_power_overwritten = _tails_power.power_family
		_set_tails_power_to(temporary_power)


const NUMERICAL_ADVERB_DICT = {
	1 : "Once",
	2 : "Twice", 
	3 : "Thrice",
	4 : "Four times",
	5 : "Five times",
	6 : "Six times",
	7 : "Seven times",
	8 : "Eight times",
	9 : "Nine times", 
	10 : "Ten times"
}
func _replace_placeholder_text(txt: String, max_charges: int = -100000, current_charges: int = -100000) -> String:
	assert((max_charges != -100000 and current_charges != -100000) or (max_charges == -100000 and current_charges == -100000),\
		"If you provide either a max charges or current charges, you have to pass both (probably accidentally passed only 1 optional param)")
	
	txt = txt.replace("(DENOM)", Global.denom_to_string(_denomination))
	if max_charges != -100000:
		txt = txt.replace("(MAX_CHARGES)", str(max(0, max_charges)))
	if current_charges != -100000:
		var charges = max(0, current_charges)
		txt = txt.replace("(CURRENT_CHARGES)", "%d" % charges)
		txt = txt.replace("(CURRENT_CHARGES_COINS)", "%d %s" % [charges, "coin" if charges == 1 else "coins"])
		if charges != 0 and charges <= 10:
			txt = txt.replace("(CURRENT_CHARGES_NUMERICAL_ADVERB)", NUMERICAL_ADVERB_DICT[charges])
			txt = txt.replace("(CURRENT_CHARGES_NUMERICAL_ADVERB_LOWERCASE)", NUMERICAL_ADVERB_DICT[charges].to_lower())
		
		
	txt = txt.replace("(HADES_SELF_GAIN)", str(Global.HADES_SELF_GAIN[get_value()-1]))
	txt = txt.replace("(HADES_MONSTER_COST)", str(Global.HADES_MONSTER_COST[get_value()-1]))
	
	txt = txt.replace("(1_PER_DENOM)", str(get_denomination_as_int()))
	txt = txt.replace("(1+1_PER_DENOM)", str(get_denomination_as_int() + 1))
	txt = txt.replace("(2+1_PER_DENOM)", str(get_denomination_as_int() + 2))
	txt = txt.replace("(2_PER_DENOM)", str(get_denomination_as_int() * 2))
	txt = txt.replace("(1_PLUS_2_PER_DENOM)", str(1 + (get_denomination_as_int() * 2)))
	
	var heph_str = func(denom_as_int: int) -> String:
		match(denom_as_int):
			1:
				return "an Obol"
			2:
				return "an Obol or Diobol"
			_:
				return "a coin"
	txt = txt.replace("(HEPHAESTUS_OPTIONS)", heph_str.call(get_denomination_as_int()))
	return txt

func _generate_tooltip() -> void:
	var tooltip = ""
	
	# special case - use a shortened tooltip for passive coins
	# later, if we add coins with passives, this will need to change. But it works fine for now, with only passive trials.
	if get_active_power_family().power_type == Global.PowerType.PASSIVE:
		assert(_heads_power.power_family == _tails_power.power_family, "Need to refactor!") # this is always true for trials; just a warning for myself if I forget to change this l8r
		# (name)
		# (subtitle)
		# (desc)
		const PASSIVE_FORMAT = "%s\n[color=lightgray]%s[/color]\n%s"
		var desc = _replace_placeholder_text(_heads_power.power_family.description, _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		tooltip = PASSIVE_FORMAT % [get_coin_name(), get_subtitle(), desc]
	else:
		# (name)
		# (subtitle)
		# heads (type) [opt: uses] (icon) [opt: -> (desc)]
		# tails (type) [opt: uses] (icon) [opt: -> (desc)]
	
		# get descriptions for powers
		var heads_power_type = _heads_power.power_family.get_power_type_placeholder()
		var tails_power_type = _tails_power.power_family.get_power_type_placeholder()
		var heads_desc = _replace_placeholder_text(_heads_power.power_family.description, _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		var tails_desc = _replace_placeholder_text(_tails_power.power_family.description, _tails_power.power_family.uses_for_denom[_denomination], _tails_power.charges)
		
		# N/N(icon)->   OR for certain powers,   N(icon)->
		var heads_power = ""
		var tails_power = ""
		
		const POWER_FORMAT = "[color=yellow](CURRENT_CHARGES)/(MAX_CHARGES)[/color][img=10x13]%s[/img](POWERARROW)"
		if _heads_power.power_family.is_power():
			heads_power = _replace_placeholder_text(POWER_FORMAT % _heads_power.power_family.icon_path, _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		if _tails_power.power_family.is_power():
			tails_power = _replace_placeholder_text(POWER_FORMAT % _tails_power.power_family.icon_path, _tails_power.power_family.uses_for_denom[_denomination], _tails_power.charges)
		
		const PAYOFF_FORMAT = "[color=yellow](CURRENT_CHARGES)[/color][img=10x13]%s[/img](POWERARROW)"
		const PAYOFF_FORMAT_ONE_CHARGE = "[img=10x13]%s[/img](POWERARROW)"
		var exclude_powers = [Global.PowerType.PAYOFF_GAIN_SOULS, Global.PowerType.PAYOFF_LOSE_SOULS, Global.PowerType.PAYOFF_LOSE_LIFE]
		if _heads_power.power_family.is_payoff() and not _heads_power.power_family.power_type in exclude_powers:
			if _heads_power.power_family.uses_for_denom[_denomination] <= 1:
				heads_power = _replace_placeholder_text(PAYOFF_FORMAT_ONE_CHARGE % _heads_power.power_family.icon_path)
			else:
				heads_power = _replace_placeholder_text(PAYOFF_FORMAT % _heads_power.power_family.icon_path, _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		if _tails_power.power_family.is_payoff() and not _tails_power.power_family.power_type in exclude_powers:
			if _tails_power.power_family.uses_for_denom[_denomination] <= 1:
				tails_power = _replace_placeholder_text(PAYOFF_FORMAT_ONE_CHARGE % _tails_power.power_family.icon_path)
			else:
				tails_power = _replace_placeholder_text(PAYOFF_FORMAT % _tails_power.power_family.icon_path, _heads_power.power_family.uses_for_denom[_denomination], _tails_power.charges)
		
		# (HEADS/TAILS)(power_stuff)(desc)
		const FACE_FORMAT = "%s%s%s%s"
		var heads_power_str = FACE_FORMAT % ["(HEADS)", heads_power_type, heads_power, heads_desc]
		var tails_power_str = FACE_FORMAT % ["(TAILS)", tails_power_type, tails_power, tails_desc]
		
		# name
		# subtitle
		# heads
		# tails
		const TOOLTIP_FORMAT = "%s\n%s\n%s\n%s"
		tooltip = TOOLTIP_FORMAT % [get_coin_name(), get_subtitle(), heads_power_str, tails_power_str]
	
	UITooltip.create(_MOUSE, Global.replace_placeholders(tooltip), get_global_mouse_position(), get_tree().root)

func on_round_end() -> void:
	_round_life_penalty_change = 0
	reset_power_uses(true)
	# force to heads
	if not _heads:
		turn()
	
	# clear status, unless Apollo patron
	if not Global.is_passive_active(Global.PATRON_POWER_FAMILY_APOLLO):
		clear_statuses()
	elif has_status():
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_APOLLO)

func get_heads_icon() -> String:
	return _heads_power.power_family.icon_path

func get_tails_icon() -> String:
	return _tails_power.power_family.icon_path

func on_toss_initiated() -> void:
	reset_power_uses()

func on_toss_complete() -> void:
	pass

func before_payoff() -> void:
	_disable_interaction = true

func after_payoff() -> void:
	_disable_interaction = false
	
	# if we have any temporary powers, reset them to original
	if _heads_power_overwritten != null:
		FX.flash(Color.HOT_PINK)
		_set_heads_power_to(_heads_power_overwritten)
		_heads_power_overwritten = null
	if _tails_power_overwritten != null:
		FX.flash(Color.HOT_PINK)
		_set_tails_power_to(_tails_power_overwritten)
		_tails_power_overwritten = null

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

func payoff_move_up() -> void:
	await _sprite_movement_tween.tween(Vector2(0, -20), 0.15, Tween.TRANS_CIRC)

func payoff_move_down() -> void:
	await _sprite_movement_tween.tween(Vector2(0, 0), 0.15, Tween.TRANS_CIRC)

func _on_mouse_clicked():
	if not _disable_interaction:
		emit_signal("clicked", self)

func _on_mouse_entered():
	emit_signal("hovered", self)
	_update_appearance()

func _on_mouse_exited():
	emit_signal("unhovered", self)
	_update_appearance()

func _on_active_coin_power_coin_changed() -> void:
	if not is_inside_tree(): #bit of a $HACK$ since this gets called before we're in tree to make tween; could also check tween return value but meh
		return
	
	_update_appearance()

func _on_tutorial_state_changed() -> void:
	if not is_inside_tree(): # a bit of a hack for startup, but whatever
		return
	_update_appearance()

func disable_interaction() -> void:
	_disable_interaction = true

func enable_interaction() -> void:
	_disable_interaction = false

@onready var _MOUSE = $Mouse

var _time_mouse_hover = 0
const _DELAY_BEFORE_TOOLTIP = 0.15 # not sure if we really want this?

func _physics_process(delta):
	if _MOUSE.is_over() and not _disable_interaction:
		_time_mouse_hover += delta
	else:
		_time_mouse_hover = 0
	
	if _time_mouse_hover >= _DELAY_BEFORE_TOOLTIP:
		_generate_tooltip()

func move_to(pos: Vector2, time: float) -> void:
	#await _coin_movement_tween.tween(pos, time, Tween.TRANS_QUINT, Tween.EASE_OUT)
	await _coin_movement_tween.tween(pos, time, Tween.TRANS_CUBIC)
	
