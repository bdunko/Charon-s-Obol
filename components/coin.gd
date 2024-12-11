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

@onready var _STATUS_BAR = $Sprite/StatusBar
@onready var _LUCKY_ICON = $Sprite/StatusBar/Lucky
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

@onready var _OBOL_CLICKBOX = $ObolClickbox
@onready var _DIOBOL_CLICKBOX = $DiobolClickbox
@onready var _TRIOBOL_CLICKBOX = $TriobolClickbox
@onready var _TETROBOL_CLICKBOX = $TetrobolClickbox
@onready var _OBOL_STATUS_ANCHOR = $ObolStatusAnchor
@onready var _DIOBOL_STATUS_ANCHOR = $DiobolStatusAnchor
@onready var _TRIOBOL_STATUS_ANCHOR = $TriobolStatusAnchor
@onready var _TETROBOL_STATUS_ANCHOR = $TetrobolStatusAnchor

@onready var FX : FX = $Sprite/FX

# $HACK$ needed to center the text properly by dynamically resizing the label when charges are 0...
@onready var _FACE_LABEL_DEFAULT_POSITION = _FACE_LABEL.position

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
		match(_denomination): # update clickbox & status bar position
			Global.Denomination.OBOL:
				_MOUSE.watched = _OBOL_CLICKBOX
				_STATUS_BAR.position = _OBOL_STATUS_ANCHOR.position
			Global.Denomination.DIOBOL:
				_MOUSE.watched = _DIOBOL_CLICKBOX
				_STATUS_BAR.position = _DIOBOL_STATUS_ANCHOR.position
			Global.Denomination.TRIOBOL:
				_MOUSE.watched = _TRIOBOL_CLICKBOX
				_STATUS_BAR.position = _TRIOBOL_STATUS_ANCHOR.position
			Global.Denomination.TETROBOL:
				_MOUSE.watched = _TETROBOL_CLICKBOX
				_STATUS_BAR.position = _TETROBOL_STATUS_ANCHOR.position

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

var _heads_power: FacePower
var _tails_power: FacePower

# updates face label, glow, and price label
func _update_appearance() -> void:
	_update_face_label()
	_update_price_label()
	_update_flash()

const _FACE_FORMAT = "[center][color=%s]%s[/color][img=10x13]%s[/img][/center]"
const _RED = "#e12f3b"
const _BLUE = "#a6fcdb"
const _YELLOW = "#ffd541"
const _GRAY = "#b3b9d1"
func _update_face_label() -> void:
	if _blank:
		_FACE_LABEL.text = ""
	
	var color = _YELLOW if get_active_power_charges() != 0 else _GRAY
	match(get_active_power_family()):
		Global.POWER_FAMILY_GAIN_SOULS:
			color = _BLUE
		Global.POWER_FAMILY_LOSE_LIFE, Global.POWER_FAMILY_LOSE_SOULS:
			color = _RED
	var charges_str = "%d" % get_active_power_charges() if get_max_active_power_charges() != 0 else ""
	_FACE_LABEL.text = _FACE_FORMAT % [color, "%s" % charges_str, get_active_power_family().icon_path]
	
	# this is a $HACK$ to center the icon better
	if get_max_active_power_charges() == 0:
		_FACE_LABEL.position = _FACE_LABEL_DEFAULT_POSITION - Vector2(1, 0)
	else:
		_FACE_LABEL.position = _FACE_LABEL_DEFAULT_POSITION

const _BUY_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
const _UPGRADE_FORMAT = "[center][color=%s]%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
const _APPEASE_FORMAT = "[center][color=%s]-%d[/color][/center][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]"
const _TOLL_FORMAT = "[center]%d[/center][img=12x13]res://assets/icons/coin_icon.png[/img]"
func _update_price_label() -> void:
	if Global.state == Global.State.SHOP:
		# special case - can't upgrade further, show nothing
		if _owner == Owner.PLAYER and not can_upgrade():
			_PRICE.text = ""
			return
		var price = get_upgrade_price() if _owner == Owner.PLAYER else get_store_price()
		var color = AFFORDABLE_COLOR if Global.souls >= price else UNAFFORDABLE_COLOR
		_PRICE.text = (_UPGRADE_FORMAT if _owner == Owner.PLAYER else _BUY_FORMAT) % [color, price]
		
		# hide upgrade label during some parts of tutorial
		var no_upgrade_tutorial = [Global.TutorialState.ROUND1_SHOP_AFTER_BUYING_COIN,  Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN, Global.TutorialState.ROUND1_VOYAGE]
		if _owner == Owner.PLAYER and Global.tutorialState in no_upgrade_tutorial:
			_PRICE.text = ""
	elif Global.state == Global.State.TOLLGATE:
		# if the coin cannot be offered at a tollgate, show nothing
		if _coin_family in Global.TOLL_EXCLUDE_COIN_FAMILIES:
			_PRICE.text = ""
			return
		_PRICE.text = _TOLL_FORMAT % get_value()
	elif is_appeaseable():
		var price = get_appeasal_price()
		var color = AFFORDABLE_COLOR if Global.souls >= price else UNAFFORDABLE_COLOR
		_PRICE.text = _APPEASE_FORMAT % [color, price]
		
		# hide appease label during some parts of tutorial
		var no_appease_states = [Global.TutorialState.ROUND4_MONSTER_INTRO, Global.TutorialState.ROUND4_MONSTER_AFTER_TOSS]
		if Global.tutorialState in no_appease_states:
			_PRICE.text = ""

func _update_flash():
	# if this coin is an enemy coin, flash purple at all times
	if _owner == Owner.NEMESIS:
		FX.start_flashing(Color.MEDIUM_PURPLE, 10, 0.25, 0.5, false)
		return
	
	# if coin is disabled or another coin is activated right now, don't flash at all
	if _disable_interaction or (Global.active_coin_power_coin != null and Global.active_coin_power_coin != self):
		FX.stop_flashing()
		return
	
	# if this is the active power coin, flash gold
	if Global.active_coin_power_coin == self:
		FX.start_flashing(Color.GOLD, FX.DEFAULT_FLASH_SPEED, FX.DEFAULT_FLASH_BOUND1, FX.DEFAULT_FLASH_BOUND2, false)
		return
		
	# if this coin can be activated, flash white
	if Global.state == Global.State.AFTER_FLIP and get_active_power_charges() != 0 and can_activate_power() and Global.active_coin_power_coin == null:
		FX.start_flashing(Color.AZURE, FX.DEFAULT_FLASH_SPEED, FX.DEFAULT_FLASH_BOUND1, FX.DEFAULT_FLASH_BOUND2, false)
		return
	
	FX.stop_flashing()

var _blank: bool = false:
	set(val):
		_blank = val
		_STATUS_BAR.update_icon(_BLANK_ICON, _blank)
		if _blank:
			FX.flash(Color.BISQUE)
		_update_appearance()

var _bless_curse_state: _BlessCurseState:
	set(val):
		_bless_curse_state = val
		_STATUS_BAR.update_icon(_BLESS_ICON, _bless_curse_state == _BlessCurseState.BLESSED)
		_STATUS_BAR.update_icon(_CURSE_ICON, _bless_curse_state == _BlessCurseState.CURSED)
		
		if _bless_curse_state == _BlessCurseState.BLESSED:
			FX.flash(Color.PALE_GOLDENROD)
			FX.start_scanning(FX.ScanDirection.BOTTOM_TO_TOP, Color.PALE_GOLDENROD, 1.0, 0.5, 0.75)
		elif _bless_curse_state == _BlessCurseState.CURSED:
			FX.flash(Color.ORCHID)
			FX.start_scanning(FX.ScanDirection.TOP_TO_BOTTOM, Color.DARK_ORCHID, 1.0, 0.5, 0.75)
		else:
			FX.stop_scanning(FX.ScanDirection.TOP_TO_BOTTOM)
			FX.stop_scanning(FX.ScanDirection.BOTTOM_TO_TOP)

var _freeze_ignite_state: _FreezeIgniteState:
	set(val):
		_freeze_ignite_state = val
		_STATUS_BAR.update_icon(_FREEZE_ICON, _freeze_ignite_state == _FreezeIgniteState.FROZEN)
		_STATUS_BAR.update_icon(_IGNITE_ICON, _freeze_ignite_state == _FreezeIgniteState.IGNITED)
		
		if _freeze_ignite_state == _FreezeIgniteState.FROZEN:
			FX.flash(Color.CYAN)
			FX.tint(Color.CYAN, 0.5)
		elif _freeze_ignite_state == _FreezeIgniteState.IGNITED:
			FX.flash(Color.RED)
			FX.tint(Color.RED, 0.5)
		elif _freeze_ignite_state == _FreezeIgniteState.NONE and not is_stone():
			FX.clear_tint()

var _supercharged: bool:
	set(val):
		_supercharged = val
		_STATUS_BAR.update_icon(_SUPERCHARGE_ICON, _supercharged)
		if _supercharged:
			FX.flash(Color.YELLOW)
			# TODO - add particles here

var _luck_state: _LuckState:
	set(val):
		_luck_state = val
		_STATUS_BAR.update_icon(_LUCKY_ICON, _luck_state == _LuckState.LUCKY)
		_STATUS_BAR.update_icon(_UNLUCKY_ICON, _luck_state == _LuckState.UNLUCKY)
		
		if _luck_state == _LuckState.LUCKY:
			FX.flash(Color.LAWN_GREEN)
			FX.recolor_outline(Color("#59c035")) #lucky
		elif _luck_state == _LuckState.UNLUCKY:
			FX.flash(Color.ORANGE_RED)
			FX.recolor_outline(Color("#b3202a")) #unlucky
		else:
			FX.recolor_outline_to_default()

var _material_state: _MaterialState:
	set(val):
		_material_state = val
		_STATUS_BAR.update_icon(_STONE_ICON, _material_state == _MaterialState.STONE)
		
		if _material_state == _MaterialState.STONE:
			FX.flash(Color.SLATE_GRAY)
			FX.tint(Color.SLATE_GRAY, 0.7)
		elif _material_state == _MaterialState.NONE and not is_ignited():
			FX.clear_tint()

# stacks of the Athena god coin; reduces LIFE LOSS power charges by 1 permanently\
var _round_tails_penalty_reduction = 0
var _permanent_tails_penalty_reduction = 0

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
	assert(_OBOL_CLICKBOX)
	assert(_OBOL_STATUS_ANCHOR)
	assert(_DIOBOL_CLICKBOX)
	assert(_DIOBOL_STATUS_ANCHOR)
	assert(_TRIOBOL_CLICKBOX)
	assert(_TRIOBOL_STATUS_ANCHOR)
	assert(_TETROBOL_CLICKBOX)
	assert(_TETROBOL_STATUS_ANCHOR)
	Global.active_coin_power_coin_changed.connect(_on_active_coin_power_coin_changed)
	Global.tutorial_state_changed.connect(_on_tutorial_state_changed)
	FX.start_scanning(FX.ScanDirection.DIAGONAL_TOPLEFT_TO_BOTTOMRIGHT, Color.WHITE, FX.DEFAULT_SCAN_STRENGTH, FX.DEFAULT_SCAN_DURATION, FX.DEFAULT_SCAN_DELAY, false)

func show_price() -> void:
	_PRICE.show()

func hide_price() -> void:
	_PRICE.hide()

func _on_state_changed() -> void:
	_update_appearance()
	if Global.state == Global.State.SHOP or Global.state == Global.State.TOLLGATE or (is_appeaseable() and (Global.state == Global.State.BEFORE_FLIP or Global.state == Global.State.AFTER_FLIP)):
		_PRICE.show()
	else:
		_PRICE.hide()

func init_coin(family: Global.CoinFamily, denomination: Global.Denomination, owned_by: Owner):
	_coin_family = family
	_denomination = denomination
	# in the case of a trade; we don't need to reconnect signals
	if not Global.souls_count_changed.is_connected(_update_price_label):
		Global.souls_count_changed.connect(_update_price_label)
	if not Global.state_changed.is_connected(_on_state_changed):
		Global.state_changed.connect(_on_state_changed)
	_heads_power = FacePower.new(_coin_family.heads_power_family, _coin_family.heads_power_family.uses_for_denom[_denomination])
	_tails_power = FacePower.new(_coin_family.tails_power_family, _coin_family.tails_power_family.uses_for_denom[_denomination])
	_heads = true
	_owner = owned_by
	_blank = false
	_luck_state = _LuckState.NONE
	_bless_curse_state = _BlessCurseState.NONE
	_freeze_ignite_state = _FreezeIgniteState.NONE
	_material_state = _MaterialState.NONE
	_supercharged = false
	_round_tails_penalty_reduction = 0
	_permanent_tails_penalty_reduction = 0
	_PRICE.visible = Global.state == Global.State.SHOP or is_appeaseable()
	reset_power_uses()
	_on_state_changed() # a bit of a hack but it is a good catchall...

func get_appeasal_price() -> int:
	return _coin_family.appeasal_price_for_denom[_denomination]

func is_appeaseable() -> bool:
	return get_appeasal_price() != Global.NOT_APPEASEABLE_PRICE and _owner == Coin.Owner.NEMESIS

func get_coin_family() -> Global.CoinFamily:
	return _coin_family

func mark_owned_by_player() -> void:
	_owner = Owner.PLAYER

func get_store_price() -> int:
	return _coin_family.store_price_for_denom[_denomination] * Global.shop_price_multiplier

func get_upgrade_price() -> int:
	match(_denomination):
		Global.Denomination.OBOL:
			return (_coin_family.store_price_for_denom[Global.Denomination.DIOBOL] - _coin_family.store_price_for_denom[Global.Denomination.OBOL]) * Global.shop_price_multiplier
		Global.Denomination.DIOBOL:
			return (_coin_family.store_price_for_denom[Global.Denomination.TRIOBOL] - _coin_family.store_price_for_denom[Global.Denomination.DIOBOL]) * Global.shop_price_multiplier
		Global.Denomination.TRIOBOL:
			return (_coin_family.store_price_for_denom[Global.Denomination.TETROBOL] - _coin_family.store_price_for_denom[Global.Denomination.TRIOBOL]) * Global.shop_price_multiplier
		Global.Denomination.TETROBOL:
			return 10000000 #error case really
	breakpoint
	return 1000000

func get_sell_price() -> int:
	#breakpoint #deprecated for now
	return max(1, int(get_store_price()/3.0))

func can_upgrade() -> bool:
	if _coin_family in Global.UPGRADE_EXCLUDE_COIN_FAMILIES:
		return false
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
	if not can_upgrade():
		assert(false, "Trying to upgrade a coin that we shouldn't.")
		return
	
	match(_denomination):
		Global.Denomination.OBOL:
			_denomination = Global.Denomination.DIOBOL
		Global.Denomination.DIOBOL:
			_denomination = Global.Denomination.TRIOBOL
		Global.Denomination.TRIOBOL:
			_denomination = Global.Denomination.TETROBOL
	
	# immediately update specifically payoff powers...
	# and if it's a lose life power, reapply athena bonuses
	if _heads_power.power_family.is_payoff():
		_heads_power.charges = max(_heads_power.charges + 1, _heads_power.power_family.uses_for_denom[_denomination])
		if _heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE:
			_heads_power.charges -= (_permanent_tails_penalty_reduction + _round_tails_penalty_reduction)
	if _tails_power.power_family.is_payoff():
		_tails_power.charges = max(_tails_power.charges + 1, _tails_power.power_family.uses_for_denom[_denomination])
		if _tails_power.power_family == Global.POWER_FAMILY_LOSE_LIFE:
			_tails_power.charges -= (_permanent_tails_penalty_reduction + _round_tails_penalty_reduction)
	
	_update_appearance()
	set_animation(_Animation.FLAT) # update sprite
	FX.flash(Color.GOLDENROD)

func downgrade() -> void:
	match(_denomination):
		Global.Denomination.DIOBOL:
			_denomination = Global.Denomination.OBOL
		Global.Denomination.TRIOBOL:
			_denomination = Global.Denomination.DIOBOL
		Global.Denomination.TETROBOL:
			_denomination = Global.Denomination.TRIOBOL
	_update_appearance()
	set_animation(_Animation.FLAT) # update sprite
	FX.flash(Color.DARK_GRAY)

func is_passive() -> bool:
	return get_active_power_family().is_passive()

func is_payoff() -> bool:
	return get_active_power_family().is_payoff()

func is_power() -> bool:
	return get_active_power_family().is_power()
	
func can_activate_power() -> bool:
	return get_active_power_family().is_power() and not _blank

func flip(bonus: int = 0) -> void:
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
	
	# hide the glow
	FX.stop_glowing()
	
	# animate
	_FACE_LABEL.hide() # hide text
	_PRICE.hide() # hide appease cost
	
	if is_blessed():
		FX.flash(Color.PALE_GOLDENROD)
		_heads = true
		_bless_curse_state = _BlessCurseState.NONE
	elif is_cursed():
		FX.flash(Color.ORCHID)
		_heads = false
		_bless_curse_state = _BlessCurseState.NONE
	else:
		const LUCKY_MODIFIER = 20
		const UNLUCKY_MODIFIER = -20
		# the % value to succeed
		var percentage_success = 50 + bonus
		match(_luck_state):
			_LuckState.LUCKY:
				percentage_success += LUCKY_MODIFIER
			_LuckState.UNLUCKY:
				percentage_success += UNLUCKY_MODIFIER
		var roll = Global.RNG.randi_range(1, 100)
		var success = percentage_success >= roll 
		if success and _luck_state == _LuckState.LUCKY and percentage_success - roll < LUCKY_MODIFIER:
			#prnt("roll %d, success chance %d; lucky mattered" % [roll, percentage_success])
			FX.flash(Color.LAWN_GREEN) # succeeded because of lucky
		elif not success and _luck_state == _LuckState.UNLUCKY and percentage_success - roll >= UNLUCKY_MODIFIER:
			#prnt("roll %d, success chance %d; unlucky mattered" % [roll, percentage_success])
			FX.flash(Color.ORANGE_RED) # failed because of unlucky
		
		_heads = success
	
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_EQUIVALENCE): # equivalence trial - if heads, curse, if tails, bless
		_luck_state = _LuckState.UNLUCKY if _heads else _LuckState.LUCKY
	
	# todo - make it move up in a parabola; add a shadow
	set_animation(_Animation.FLIP)
	var tween = _new_movement_tween()
	tween.tween_property(_SPRITE, "position:y", -50, 0.20)
	tween.tween_interval(0.1)
	tween.tween_property(_SPRITE, "position:y", 0, 0.20)
	await tween.finished
	set_animation(_Animation.FLAT)
	
	_FACE_LABEL.show()
	if is_appeaseable():
		_PRICE.show()
	
	# if supercharged and we landed on tails, flip again.
	if _supercharged and not _heads:
		FX.flash(Color.YELLOW)
		_supercharged = false
		await flip()
		return
	
	# if the mouse is still over after the flip, start glowing again
	if _MOUSE.is_over():
		FX.start_glowing(Color.WHITE)
	
	emit_signal("flip_complete")
	
	_disable_interaction = false

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

func destroy() -> void:
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
	_update_appearance()
	FX.flash(Color.WHITE)

func reset_power_uses() -> void:
	var new_heads_charges = -1
	var new_tails_charges = -1
	
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_SAPPING) and is_power(): # sapping trial - recharge only by 1
		new_heads_charges = max(_heads_power.charges + 1, _heads_power.power_family.uses_for_denom[_denomination])
		_tails_power.charges = max(_tails_power.charges + 1, _tails_power.power_family.uses_for_denom[_denomination])
	else:
		new_heads_charges = _heads_power.power_family.uses_for_denom[_denomination]
		new_tails_charges = _tails_power.power_family.uses_for_denom[_denomination]
	
	if _heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE:
		new_heads_charges -= (_permanent_tails_penalty_reduction + _round_tails_penalty_reduction)
	if _tails_power.power_family == Global.POWER_FAMILY_LOSE_LIFE:
		new_tails_charges -= (_permanent_tails_penalty_reduction + _round_tails_penalty_reduction)
	
	if _heads_power.charges > new_heads_charges or _tails_power.charges > new_tails_charges:
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

func make_lucky() -> void:
	_luck_state = _LuckState.LUCKY

func make_unlucky() -> void:
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

func ignite() -> void:
	FX.flash(Color.RED) # flash ahead of time, even if effect fails
	# if stoned, don't ignite
	_freeze_ignite_state = _FreezeIgniteState.NONE if is_stone() else _FreezeIgniteState.IGNITED

func stone() -> void:
	_material_state = _MaterialState.STONE
	_freeze_ignite_state = _FreezeIgniteState.NONE

func clear_statuses() -> void:
	_blank = false
	_supercharged = false
	clear_blessed_cursed()
	clear_freeze_ignite()
	clear_material()
	clear_lucky_unlucky()

func clear_lucky_unlucky() -> void:
	_luck_state = _LuckState.NONE

func clear_blessed_cursed() -> void:
	_bless_curse_state = _BlessCurseState.NONE
	
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

func is_blank() -> bool:
	return _blank

func can_reduce_life_penalty() -> bool:
	var can_reduce_heads = (_heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _heads_power.charges != 0)
	var can_reduce_tails = (_tails_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _tails_power.charges != 0)
	return can_reduce_heads or can_reduce_tails

func reduce_life_penalty_permanently() -> void:
	_permanent_tails_penalty_reduction += 1
	var reduced_power = _heads_power if (_heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _heads_power.charges != 0) else _tails_power
	reduced_power.charges -= 1
	_update_appearance()
	_generate_tooltip()
	FX.flash(Color.SEA_GREEN)

func reduce_life_penalty_for_round() -> void:
	assert(can_reduce_life_penalty())
	var reduced_power = _heads_power if (_heads_power.power_family == Global.POWER_FAMILY_LOSE_LIFE and _heads_power.charges != 0) else _tails_power
	_round_tails_penalty_reduction += 1
	reduced_power.charges -= 1
	_update_appearance()
	_generate_tooltip()
	FX.flash(Color.SEA_GREEN)

func _replace_placeholder_text(txt: String, max_charges: int = -1, current_charges: int = -1) -> String:
	txt = txt.replace("(DENOM)", Global.denom_to_string(_denomination))
	if max_charges != -1:
		txt = txt.replace("(MAX_CHARGES)", str(max_charges))
	if current_charges != -1:
		txt = txt.replace("(CURRENT_CHARGES)", str(current_charges))
	txt = txt.replace("(HADES_MULTIPLIER)", str(get_value() * 2))
	txt = txt.replace("(1_PER_DENOM)", str(get_denomination_as_int()))
	txt = txt.replace("(1+1_PER_DENOM)", str(get_denomination_as_int() + 1))
	
	
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

# icons which we don't show an icon and charge count for in tooltips at the front.
var EXCLUDE_ICON_FAMILIES = [Global.POWER_FAMILY_LOSE_LIFE, Global.POWER_FAMILY_GAIN_SOULS, Global.POWER_FAMILY_LOSE_SOULS, Global.CHARON_POWER_DEATH, Global.CHARON_POWER_LIFE]
func _generate_tooltip() -> void:
	var txt = ""
	var coin_name = get_coin_name()
	var subtitle = get_subtitle()
	
	# special case - use a shortened tooltip for passive coins
	if get_active_power_family().powerType == Global.PowerType.PASSIVE:
		const PASSIVE_FORMAT = "%s\n[color=lightgray]%s[/color]\n%s"
		var desc = _replace_placeholder_text(_heads_power.power_family.description, _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		txt = PASSIVE_FORMAT % [coin_name, subtitle, desc]
	# regular case - payoff, payoff, and nemesis coins
	else:
		const TOOLTIP_FORMAT = "%s\n%s\n%s[img=12x13]res://assets/icons/heads_icon.png[/img]%s\n[img=12x13]res://assets/icons/tails_icon.png[/img]%s"
		var appease_hint = "Spend %d[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img] to appease.\n" % get_appeasal_price() if is_appeaseable() else ""
		var heads_power_desc = _replace_placeholder_text(_heads_power.power_family.description, _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		var tails_power_desc = _replace_placeholder_text(_tails_power.power_family.description, _tails_power.power_family.uses_for_denom[_denomination], _tails_power.charges)
		var heads_power_icon = "" if _heads_power.power_family in EXCLUDE_ICON_FAMILIES else "[img=10x13]%s[/img]: " % _heads_power.power_family.icon_path
		var tails_power_icon = "" if _tails_power.power_family in EXCLUDE_ICON_FAMILIES else "[img=10x13]%s[/img]: " % _tails_power.power_family.icon_path
		var heads_charges = "" if _heads_power.power_family in EXCLUDE_ICON_FAMILIES else _replace_placeholder_text(" [color=yellow](CURRENT_CHARGES)[/color]", _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		var tails_charges = "" if _tails_power.power_family in EXCLUDE_ICON_FAMILIES else _replace_placeholder_text(" [color=yellow](CURRENT_CHARGES)[/color]", _tails_power.power_family.uses_for_denom[_denomination], _tails_power.charges)
		var max_heads_charges = "" if _heads_power.power_family in EXCLUDE_ICON_FAMILIES else _replace_placeholder_text("[color=yellow]/(MAX_CHARGES)[/color]", _heads_power.power_family.uses_for_denom[_denomination], _heads_power.charges)
		var max_tails_charges = "" if _tails_power.power_family in EXCLUDE_ICON_FAMILIES else _replace_placeholder_text("[color=yellow]/(MAX_CHARGES)[/color]", _tails_power.power_family.uses_for_denom[_denomination], _tails_power.charges)
		
		#(currcharges)/(maxcharges)[icon]:description
		const POWER_FORMAT = "%s%s%s%s"
		var heads_power = POWER_FORMAT % [heads_charges, max_heads_charges, heads_power_icon, heads_power_desc]
		var tails_power = POWER_FORMAT % [tails_charges, max_tails_charges, tails_power_icon, tails_power_desc]
		
		txt = TOOLTIP_FORMAT % [coin_name, subtitle, appease_hint, heads_power, tails_power]
	
	UITooltip.create(_MOUSE, txt, get_global_mouse_position(), get_tree().root)

func on_round_end() -> void:
	_round_tails_penalty_reduction = 0
	reset_power_uses()
	# force to heads
	if not _heads:
		turn()
	clear_statuses()

func on_toss_complete() -> void:
	pass

func before_payoff() -> void:
	_disable_interaction = true

func after_payoff() -> void:
	_disable_interaction = false
	reset_power_uses()

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

var _movement_tween: Tween = null
func _new_movement_tween() -> Tween:
	if _movement_tween:
		_movement_tween.kill()
	_movement_tween = create_tween()
	return _movement_tween

func payoff_move_up() -> void:
	await _new_movement_tween().tween_property(_SPRITE, "position:y", -20, 0.15).set_trans(Tween.TRANS_CIRC).finished

func payoff_move_down() -> void:
	await _new_movement_tween().tween_property(_SPRITE, "position:y", 0, 0.15).set_trans(Tween.TRANS_CIRC).finished

func _on_mouse_clicked():
	if not _disable_interaction:
		emit_signal("clicked", self)

func _on_mouse_entered():
	if not _disable_interaction and Global.state == Global.State.AFTER_FLIP and not Global.active_coin_power_coin == self and ((get_active_power_charges() != 0 and can_activate_power()) or Global.active_coin_power_family != null):
		#_new_movement_tween().tween_property(_SPRITE, "position:y", -2, 0.15).set_trans(Tween.TRANS_CIRC)
		FX.start_glowing(Color.WHITE)
	emit_signal("hovered", self)

func _on_mouse_exited():
	if not _disable_interaction and Global.state == Global.State.AFTER_FLIP and not Global.active_coin_power_coin == self:
		#_new_movement_tween().tween_property(_SPRITE, "position:y", 0, 0.15).set_trans(Tween.TRANS_CIRC)
		FX.stop_glowing()
	emit_signal("unhovered", self)

var _was_active_power_coin = false
func _on_active_coin_power_coin_changed() -> void:
	if not is_inside_tree(): #bit of a $HACK$ since this gets called before we're in tree to make tween; could also check tween return value but meh
		return
	
	_update_appearance()
	
	if not _disable_interaction:
		if Global.active_coin_power_coin == self:
			_was_active_power_coin = true
			FX.start_glowing(Color.GOLD, FX.DEFAULT_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, FX.DEFAULT_GLOW_MINIMUM, false)
		else:
			# if this coin was active and the mouse is not over it anymore, we need to remember stop its glow
			# if this coin wasn't active, make sure it stops glowing
			var was_active_and_mouse_no_longer_over = _was_active_power_coin and not _MOUSE.is_over()
			var wasnt_active_and_cant_be_activated = get_active_power_charges() == 0 or not can_activate_power()
			if was_active_and_mouse_no_longer_over or wasnt_active_and_cant_be_activated:
				#_new_movement_tween().tween_property(_SPRITE, "position:y", 0, 0.15).set_trans(Tween.TRANS_CIRC)
				FX.stop_glowing()
			
			# lastly if this was the active power and we're still over it, glow white instead of gold again
			if _was_active_power_coin and _MOUSE.is_over():
				FX.start_glowing(Color.WHITE, FX.DEFAULT_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, FX.DEFAULT_GLOW_MINIMUM, false)
	else:
		FX.stop_glowing()

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
const _DELAY_BEFORE_TOOLTIP = 0.1 # not sure if we really want this?

func _physics_process(delta):
	if _MOUSE.is_over() and not _disable_interaction:
		_time_mouse_hover += delta
	else:
		_time_mouse_hover = 0
	
	if _time_mouse_hover >= _DELAY_BEFORE_TOOLTIP:
		_generate_tooltip()
