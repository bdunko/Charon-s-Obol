extends Node2D

signal game_ended

@onready var _COIN_ROW: CoinRow = $Table/CoinRow
@onready var _SHOP: Shop = $Table/Shop
@onready var _ENEMY_ROW: EnemyRow = $Table/EnemyRow
@onready var _ENEMY_COIN_ROW: CoinRow = $Table/EnemyRow/CoinRow
@onready var _CHARON_ROW: CoinRow = $Table/CharonObolRow

@onready var _LIFE_FRAGMENTS = $LifeFragments
@onready var _SOUL_FRAGMENTS = $SoulFragments
@onready var _ARROWS = $Arrows

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _LIFE_FRAGMENT_SCENE = preload("res://components/life_fragment.tscn")
@onready var _SOUL_FRAGMENT_SCENE = preload("res://components/soul_fragment.tscn")
@onready var _ARROW_SCENE = preload("res://components/arrow.tscn")

@onready var _PLAYER_TEXTBOXES = $UI/PlayerTextboxes
@onready var _END_ROUND_TEXTBOX = $UI/PlayerTextboxes/EndRoundButton

@onready var _CHARON_POINT: Vector2 = $Points/Charon.position
@onready var _PLAYER_POINT: Vector2 = $Points/Player.position
@onready var _LIFE_FRAGMENT_PILE_POINT: Vector2 = $Points/LifeFragmentPile.position
@onready var _SOUL_FRAGMENT_PILE_POINT: Vector2 = $Points/SoulFragmentPile.position
@onready var _ARROW_PILE_POINT: Vector2 = $Points/ArrowPile.position
@onready var _MAP_SHOWN_POINT = $Points/MapShown.position
@onready var _MAP_HIDDEN_POINT = $Points/MapHidden.position
@onready var _MAP_INITIAL_POINT = $Points/MapInitial.position

@onready var _VOYAGE_MAP: VoyageMap = $UI/VoyageMap
@onready var _MAP_BLOCKER = $UI/MapBlocker
var _map_active = false
var _map_is_disabled = false

@onready var _PATRON_TOKEN_POSITION: Vector2 = $Table/PatronToken.position

@onready var _TABLE = $Table
@onready var _DIALOGUE: DialogueSystem = $UI/DialogueSystem
@onready var _CAMERA: Camera2D = $Camera

@onready var _patron_token: PatronToken = $Table/PatronToken

func _ready() -> void:
	assert(_COIN_ROW)
	assert(_SHOP)
	assert(_ENEMY_ROW)
	assert(_ENEMY_COIN_ROW)
	assert(_CHARON_ROW)
	
	assert(_PLAYER_TEXTBOXES)
	assert(_END_ROUND_TEXTBOX)
	
	assert(_CHARON_POINT)
	assert(_PLAYER_POINT)
	assert(_LIFE_FRAGMENT_PILE_POINT)
	assert(_SOUL_FRAGMENT_PILE_POINT)
	assert(_ARROW_PILE_POINT)
	assert(_ARROWS)
	
	assert(_DIALOGUE)
	assert(_TABLE)
	
	assert(_VOYAGE_MAP)
	assert(_MAP_BLOCKER)
	assert(_MAP_SHOWN_POINT)
	assert(_MAP_HIDDEN_POINT)
	assert(_MAP_INITIAL_POINT)
	_VOYAGE_MAP.position = _MAP_INITIAL_POINT #offscreen
	_VOYAGE_MAP.rotation_degrees = -90
	
	Global.COIN_ROWS = [_COIN_ROW, _ENEMY_COIN_ROW]
	
	Global.state_changed.connect(_on_state_changed)
	Global.life_count_changed.connect(_on_life_count_changed)
	Global.souls_count_changed.connect(_on_soul_count_changed)
	Global.arrow_count_changed.connect(_on_arrow_count_changed)
	Global.toll_coins_changed.connect(_show_toll_dialogue)

func _on_arrow_count_changed() -> void:
	while _ARROWS.get_child_count() > Global.arrows:
		# delete some arrows
		var arrow = _ARROWS.get_child(0)
		_ARROWS.remove_child(arrow)
		#todo - anim
		arrow.queue_free()
		
	while _ARROWS.get_child_count() < Global.arrows:
		# add more arrows
		var arrow: Arrow = _ARROW_SCENE.instantiate()
		arrow.clicked.connect(_on_arrow_pressed)
		arrow.position = _ARROW_PILE_POINT + Vector2(Global.RNG.randi_range(-4, 4), Global.RNG.randi_range(-3, 3))
		_ARROWS.add_child(arrow)

func _on_soul_count_changed() -> void:
	_update_fragment_pile(Global.souls, _SOUL_FRAGMENT_SCENE, _SOUL_FRAGMENTS, _CHARON_POINT, _CHARON_POINT, _SOUL_FRAGMENT_PILE_POINT)

func _on_life_count_changed() -> void:
	_update_fragment_pile(Global.lives, _LIFE_FRAGMENT_SCENE, _LIFE_FRAGMENTS, _PLAYER_POINT, _CHARON_POINT, _LIFE_FRAGMENT_PILE_POINT)
	
	# if we ran out of life, initiate last chance flip
	if Global.lives < 0:
		await _wait_for_dialogue("You're out of life...")
		Global.state = Global.State.CHARON_OBOL_FLIP

func _update_fragment_pile(amount: int, scene: Resource, pile: Node, give_pos: Vector2, take_pos: Vector2, pile_pos: Vector2) -> void:
	#var fragment_count = 0
	
	# move live from pile to charon
	while pile.get_child_count() > max(0, amount):
		var fragment = pile.get_child(0)
		pile.remove_child(fragment)
		get_tree().root.add_child(fragment)
		
		# visually move it from pile to charon
		var tween = create_tween()
		#tween.tween_interval(fragment_count * 0.02)
		tween.tween_property(fragment, "position", take_pos, 0.4).set_trans(Tween.TRANS_CUBIC)
		tween.tween_callback(fragment.queue_free)
		#fragment_count += 1
	
	while pile.get_child_count() < amount:
		var fragment = scene.instantiate()
		
		fragment.position = give_pos
		var target_pos = pile_pos + Vector2(Global.RNG.randi_range(-14, 14), Global.RNG.randi_range(-8, 8))
		
		# move from player to pile
		var tween = create_tween()
		#tween.tween_interval(fragment_count * 0.02)
		tween.tween_property(fragment, "position", target_pos, 0.4).set_trans(Tween.TRANS_CUBIC)
		
		pile.add_child(fragment)
		#fragment_count += 1

func _on_state_changed() -> void:
	_PLAYER_TEXTBOXES.make_visible()
	_COIN_ROW.show() #this is just to make the row visible if charon obol flip is not happening, for now...
	
	_CHARON_ROW.visible = Global.state == Global.State.CHARON_OBOL_FLIP
	_COIN_ROW.visible = Global.state != Global.State.CHARON_OBOL_FLIP and Global.state != Global.State.GAME_OVER
	_patron_token.visible = Global.state != Global.State.CHARON_OBOL_FLIP
	
	if Global.state == Global.State.CHARON_OBOL_FLIP:
		Global.flips_this_round = 0 # reduce strain to 0 for display purposes
		_CHARON_ROW.get_child(0).set_heads_no_anim() # force to heads for visual purposes
		_PLAYER_TEXTBOXES.make_invisible()
		await _wait_for_dialogue("Yet, I will grant you one final opportunity.")
		await _wait_for_dialogue("We will flip this single obol.")
		await _wait_for_dialogue("Tails, and the story continues.")
		await _wait_for_dialogue("Heads, and your long journey ends here.")
		await _wait_for_dialogue("And now, on the edge of life and death...")
		_DIALOGUE.show_dialogue("You must flip!")
		_PLAYER_TEXTBOXES.make_visible()
	elif Global.state == Global.State.GAME_OVER:
		_on_game_end()

func _on_game_end() -> void:
	if victory:
		await _wait_for_dialogue("And we've reached the other shore...")
		await _wait_for_dialogue("It appears that you have been victorious.")
		await _wait_for_dialogue("I wish you luck on the rest of your journey...")
	else:
		await _wait_for_dialogue("You were a fool to come here.")
		await _wait_for_dialogue("And now...")
		await _wait_for_dialogue("Your soul shall be mine!")
	emit_signal("game_ended", victory)

func on_start() -> void:
	_CAMERA.make_current()
	_DIALOGUE.instant_clear_dialogue()
	
	# delete all existing coins
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		coin.queue_free()
		coin.get_parent().remove_child(coin)
	
	# make charon's obol
	for coin in _CHARON_ROW.get_children():
		_CHARON_ROW.remove_child(coin)
		coin.queue_free()
	var charons_obol = _COIN_SCENE.instantiate()
	_CHARON_ROW.add_child(charons_obol)
	charons_obol.flip_complete.connect(_on_flip_complete)
	charons_obol.init_coin(Global.CHARON_OBOL_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_CHARON_ROW.hide()
	
	# randomize and set up the nemesis & trials
	Global.randomize_voyage()
	_VOYAGE_MAP.update_tooltips()
	
	# delete any old patron token and create a new one
	_patron_token.queue_free()
	_patron_token = Global.patron.patron_token.instantiate()
	_patron_token.position = _PATRON_TOKEN_POSITION
	_patron_token.clicked.connect(_on_patron_token_clicked)
	_TABLE.add_child(_patron_token)
	
	victory = false
	Global.round_count = 1
	Global.lives = Global.current_round_life_regen()
	Global.patron_uses = Global.PATRON_USES_PER_ROUND[1]
	Global.souls = 0
	Global.arrows = 0
	Global.active_coin_power_family = null
	Global.active_coin_power_coin = null
	Global.flips_this_round = 0
	Global.strain_modifier = 0
	Global.shop_rerolls = 0
	Global.toll_coins_offered = []
	Global.toll_index = 0
	
	#debug
	Global.souls = 100
	#Global.lives = 100
	#Global.arrows = 10
	#_make_and_gain_coin(Global.ATHENA_FAMILY, Global.Denomination.OBOL)
	#_make_and_gain_coin(Global.POSEIDON_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.ARES_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.HEPHAESTUS_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.HESTIA_FAMILY, Global.Denomination.TRIOBOL)
	#_make_and_gain_coin(Global.DIONYSUS_FAMILY, Global.Denomination.DIOBOL)
	
	_make_and_gain_coin(Global.HESTIA_FAMILY, Global.Denomination.DIOBOL)
	_make_and_gain_coin(Global.HEPHAESTUS_FAMILY, Global.Denomination.DIOBOL)
	_make_and_gain_coin(Global.POSEIDON_FAMILY, Global.Denomination.DIOBOL)
	_make_and_gain_coin(Global.APOLLO_FAMILY, Global.Denomination.DIOBOL)
	
	
	#_make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.ATHENA_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.ATHENA_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.HEPHAESTUS_FAMILY, Global.Denomination.TETROBOL)
	#_make_and_gain_coin(Global.HEPHAESTUS_FAMILY, Global.Denomination.TETROBOL)
	
	Global.state = Global.State.BOARDING
	_PLAYER_TEXTBOXES.make_invisible()
	await Global.delay(0.1)
	await _wait_for_dialogue("I am the ferryman Charon, shephard of the dead.")
	await _wait_for_dialogue("Fool from Eleusis, you wish to cross?")
	await _wait_for_dialogue("I cannot take the living across the river Styx...")
	await _wait_for_dialogue("But this could yet prove entertaining...")
	await _wait_for_dialogue("We shall play a game, on the way across.")
	await _wait_for_dialogue("At each tollgate, you must pay the price.")
	await _wait_for_dialogue("Or your soul shall stay here with me, forevermore!")
	_DIALOGUE.show_dialogue("Brave hero, will you board?")
	_PLAYER_TEXTBOXES.make_visible()

var flips_pending = 0
func _on_flip_complete() -> void:
	flips_pending -= 1
	assert(flips_pending >= 0)
	
	if Global.state == Global.State.AFTER_FLIP:
		if flips_pending == 0:
			_PLAYER_TEXTBOXES.make_visible()
		return #ignore reflips such as Zeus
	
	# if this is after the last chance flip, resolve payoff
	if Global.state == Global.State.CHARON_OBOL_FLIP:
		var charons_obol = _CHARON_ROW.get_child(0) as Coin
		match charons_obol.get_active_power_family():
			Global.CHARON_POWER_DEATH:
				await _wait_for_dialogue("Fate is cruel indeed.")
				await _wait_for_dialogue("It seems this is the end for you.")
				await _wait_for_dialogue("And now...")
				await _wait_for_dialogue("...I collect my prize.")
				Global.state = Global.State.GAME_OVER
			Global.CHARON_POWER_LIFE:
				await _wait_for_dialogue("Fate smiles upon you...")
				await _wait_for_dialogue("It seems you have dodged death, for a time.")
				await _wait_for_dialogue("But your journey has not yet concluded...")
				Global.lives = 0
				_on_end_round_button_pressed()
			_:
				assert(false, "Charon's obol has an incorrect power?")
		return
	
	# if every flip is done
	if flips_pending == 0:
		# recharge all coin powers
		for coin in _COIN_ROW.get_children():
			coin = coin as Coin
			coin.on_toss_complete()
		
		Global.flips_this_round += 1
		Global.state = Global.State.AFTER_FLIP
		_DIALOGUE.show_dialogue("The coins fall...")
		_PLAYER_TEXTBOXES.make_visible()

func _on_toss_button_clicked() -> void:
	if Global.state == Global.State.CHARON_OBOL_FLIP:
		for coin in _CHARON_ROW.get_children():
			_safe_flip(coin)
		return
	
	if _COIN_ROW.get_child_count() == 0:
		_DIALOGUE.show_dialogue("No... coins...")
		return
	
	# take life from player
	var strain = Global.strain_cost()
	
	# don't allow player to kill themselves here if continue isn't disabled (ie, if this isn't the final round)
	if Global.lives < strain and not _END_ROUND_TEXTBOX.disabled: 
		_DIALOGUE.show_dialogue("Not... enough... life...!")
		return
	
	Global.lives -= strain
	
	if Global.lives <= 0:
		return
	
	# flip all the coins
	for coin in _COIN_ROW.get_children():
		coin = coin as Coin
		_safe_flip(coin)
	for coin in _ENEMY_COIN_ROW.get_children():
		coin = coin as Coin
		_safe_flip(coin)

func _safe_flip(coin: Coin) -> void:
	flips_pending += 1
	_PLAYER_TEXTBOXES.make_invisible()
	coin.flip()

func _on_accept_button_pressed():
	assert(Global.state == Global.State.AFTER_FLIP, "this shouldn't happen")
	Global.active_coin_power_family = null
	Global.active_coin_power_coin = null
	
	_DIALOGUE.show_dialogue("Payoff...")
	_PLAYER_TEXTBOXES.make_invisible()
	
	for payoff_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		payoff_coin.before_payoff()
		

	var resolved_ignite = false
	# trigger payoffs
	for payoff_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		var payoff_power_family = payoff_coin.get_active_power_family()
		var charges = payoff_coin.get_active_power_charges()
		
		if payoff_power_family.is_payoff() and not payoff_coin.is_stone() and charges > 0:
			payoff_coin.payoff_move_up()
			match(payoff_power_family):
				Global.POWER_FAMILY_GAIN_SOULS:
					var payoff = charges
					if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_LIMITATION): # limitation trial - min 5 souls per payoff coin
						payoff = 0 if charges <= 10 else charges
					if payoff > 0:
						payoff_coin.FX.flash(Color.AQUA)
						Global.souls += payoff
				Global.POWER_FAMILY_LOSE_SOULS:
					payoff_coin.FX.flash(Color.DARK_BLUE)
					Global.souls = max(0, Global.souls - charges)
				Global.POWER_FAMILY_LOSE_LIFE:
					if charges > 0:
						payoff_coin.FX.flash(Color.RED)
					if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_PAIN): # trial pain - 3x loss from tails penalties
						Global.lives -= charges * 3
					else:
						Global.lives -= charges
				Global.MONSTER_POWER_FAMILY_HELLHOUND:
					payoff_coin.ignite()
				Global.MONSTER_POWER_FAMILY_KOBALOS:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					_COIN_ROW.get_randomized()[0].make_unlucky()
				Global.MONSTER_POWER_FAMILY_ARAE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					_COIN_ROW.get_randomized()[0].curse()
				Global.MONSTER_POWER_FAMILY_HARPY:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					_COIN_ROW.get_randomized()[0].blank()
				Global.MONSTER_POWER_FAMILY_CENTAUR_HEADS:
					payoff_coin.FX.flash(Color.GHOST_WHITE)
					_COIN_ROW.get_randomized()[0].make_lucky()
				Global.MONSTER_POWER_FAMILY_CENTAUR_TAILS:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					_COIN_ROW.get_randomized()[0].make_unlucky()
				Global.MONSTER_POWER_FAMILY_STYMPHALIAN_BIRDS:
					payoff_coin.FX.flash(Color.GHOST_WHITE)
					Global.arrows += 1
				Global.MONSTER_POWER_FAMILY_SIREN:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for coin in _COIN_ROW.get_tails():
						coin.freeze()
				Global.MONSTER_POWER_FAMILY_BASILISK:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					Global.lives -= int(Global.lives / 2.0)
				Global.MONSTER_POWER_FAMILY_GORGON:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					_COIN_ROW.get_randomized()[0].stone()
				Global.MONSTER_POWER_FAMILY_CHIMERA:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					_COIN_ROW.get_randomized()[0].ignite()
				Global.NEMESIS_POWER_FAMILY_MEDUSA_STONE: # stone highest value non-Stoned coin
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					var possible_coins = []
					for coin in _COIN_ROW.get_highest_to_lowest_value():
						if not coin.is_stone():
							if possible_coins.is_empty() or possible_coins[0].get_value() == coin.get_value():
								possible_coins.append(coin)
					if not possible_coins.is_empty():
						Global.choose_one(possible_coins).stone()
				Global.NEMESIS_POWER_FAMILY_MEDUSA_DOWNGRADE: # downgrade highest value coin
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					var highest = _COIN_ROW.get_highest_valued()
					highest.shuffle()
					if highest[0].get_denomination() != Global.Denomination.OBOL:
						highest[0].downgrade()
				Global.NEMESIS_POWER_FAMILY_EURYALE_STONE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for coin in _COIN_ROW.get_leftmost_to_rightmost():
						if not coin.is_stone():
							coin.stone()
							break
				Global.NEMESIS_POWER_FAMILY_EURYALE_UNLUCKY2:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					var num_unluckied = 0
					for coin in _COIN_ROW.get_randomized():
						if coin.is_unlucky():
							continue
						coin.make_unlucky()
						num_unluckied += 1
						if num_unluckied == 2:
							break
				Global.NEMESIS_POWER_FAMILY_STHENO_STONE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for coin in _COIN_ROW.get_rightmost_to_leftmost():
						if not coin.is_stone():
							coin.stone()
							break
				Global.NEMESIS_POWER_FAMILY_STHENO_STRAIN:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					Global.strain_modifier += 1
			await Global.delay(0.15)
			payoff_coin.payoff_move_down()
			await Global.delay(0.15)
			if Global.lives < 0:
				return
		
		# unblank when it would payoff
		payoff_coin.unblank()
		
		# $HACK$ - this is an extremely lazy way to make ignites happen
		# after all player coins but before all enemy coins, but I don't care
		if not resolved_ignite and _COIN_ROW.get_child(_COIN_ROW.get_child_count()-1) == payoff_coin:
			# resolve ignites
			for possibly_ignited_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				if possibly_ignited_coin.is_ignited():
					possibly_ignited_coin.FX.flash(Color.RED)
					possibly_ignited_coin.payoff_move_up()
					Global.lives -= 3
					await Global.delay(0.15)
					possibly_ignited_coin.payoff_move_down()
					await Global.delay(0.15)
					if Global.lives < 0:
						return
			resolved_ignite = true
	
	# post payoff actions
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_TORTURE): # every payoff, downgrade highest value coin
		for denom in [Global.Denomination.TETROBOL, Global.Denomination.TRIOBOL, Global.Denomination.DIOBOL, Global.Denomination.OBOL]:
			var coins = _COIN_ROW.get_all_of_denomination(denom)
			if not coins.is_empty():
				Global.choose_one(coins).downgrade()
				break
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_COLLAPSE): # collapse trial - each tails becomes cursed + frozen
		for coin in _COIN_ROW.get_children():
			if coin.is_tails():
				coin.curse()
				coin.freeze()
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_OVERLOAD): # overload trial - lose 1 life per unused power charge
		for coin in _COIN_ROW.get_children():
			if coin.is_power():
				coin.flash(Color.DARK_SLATE_BLUE)
				Global.lives -= coin.get_active_power_charges()
	
	for payoff_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		payoff_coin.after_payoff()
	
	_PLAYER_TEXTBOXES.make_visible()
	
	Global.state = Global.State.BEFORE_FLIP
	_DIALOGUE.show_dialogue("Will you toss the coins...?")

func _wait_for_dialogue(dialogue: String) -> void:
	_map_is_disabled = true
	_PLAYER_TEXTBOXES.make_invisible()
	await _DIALOGUE.show_dialogue_and_wait(dialogue)
	_PLAYER_TEXTBOXES.make_visible()
	_map_is_disabled = false
	
func _show_voyage_map(include_blocker: bool, closeable: bool) -> void:
	Global.active_coin_power_coin = null
	Global.active_coin_power_family = null
	_map_active = true
	_map_is_disabled = true
	var map_display_tween = create_tween()
	map_display_tween.tween_property(_VOYAGE_MAP, "position", _MAP_SHOWN_POINT, 0.2) # tween position
	map_display_tween.parallel().tween_property(_VOYAGE_MAP, "rotation_degrees", 0, 0.2)
	if include_blocker:
		map_display_tween.parallel().tween_property(_MAP_BLOCKER, "modulate:a", 0.6, 0.2)
		_MAP_BLOCKER.show()
	_VOYAGE_MAP.set_closeable(closeable)
	await map_display_tween.finished
	_map_is_disabled = false

func _hide_voyage_map() -> void:
	_map_active = false
	_map_is_disabled = true
	var map_hide_tween = create_tween()
	map_hide_tween.parallel().tween_property(_VOYAGE_MAP, "position", _MAP_HIDDEN_POINT, 0.2) # tween position
	map_hide_tween.parallel().tween_property(_VOYAGE_MAP, "rotation_degrees", -90, 0.2)
	map_hide_tween.parallel().tween_property(_MAP_BLOCKER, "modulate:a", 0.0, 0.2)
	_MAP_BLOCKER.hide()
	await map_hide_tween.finished
	_map_is_disabled = false

func _on_voyage_map_clicked():
	if _map_is_disabled or _map_active:
		return
	_show_voyage_map(true, true)

func _on_voyage_map_closed():
	if _map_is_disabled or not _map_active:
		return
	_hide_voyage_map()

func _advance_round() -> void:
	Global.state = Global.State.VOYAGE
	_DIALOGUE.show_dialogue("Now let us sail...")
	_PLAYER_TEXTBOXES.make_invisible()
	await _show_voyage_map(true, false)
	await _VOYAGE_MAP.move_boat(Global.round_count)
	Global.round_count += 1
	
	# setup the enemy row
	_ENEMY_ROW.current_round_setup()
	for c in _ENEMY_COIN_ROW.get_children():
		var coin = c as Coin
		coin.flip_complete.connect(_on_flip_complete)
		coin.clicked.connect(_on_coin_clicked)
	
	_PLAYER_TEXTBOXES.make_visible()

func _on_board_button_clicked():
	assert(Global.state == Global.State.BOARDING)
	_advance_round()

func _on_continue_button_pressed():
	assert(Global.state == Global.State.SHOP)
	_advance_round()

func _on_end_round_button_pressed():
	assert(Global.state == Global.State.BEFORE_FLIP or Global.state == Global.State.CHARON_OBOL_FLIP)
	_PLAYER_TEXTBOXES.make_invisible()
	for coin in _COIN_ROW.get_children():
		coin.on_round_end()
	
	
	# First round skip + pity - advanced players may skip round 1 for base 20 souls; unlucky players are brought to 20
	var first_round = Global.round_count == 2
	var min_souls_first_round = 20
	if first_round and Global.souls < min_souls_first_round and (Global.flips_this_round == 0 or Global.flips_this_round >= 7):
		if Global.flips_this_round == 0:
			await _wait_for_dialogue("Refusal to play is not an option!")
		else:
			await _wait_for_dialogue("Only %d[img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img]...?" % Global.souls)
			await _wait_for_dialogue("You are a rather misfortunate one.")
			await _wait_for_dialogue("We wouldn't want the game ending prematurely...")
		await _wait_for_dialogue("Just this once, I will take pity on you.")
		Global.souls = min_souls_first_round
		await _wait_for_dialogue("You take these...")
		Global.lives = 0
		await _wait_for_dialogue("And I'll take those...")
		await _wait_for_dialogue("Now us continue.")
	
	Global.flips_this_round = 0
	Global.strain_modifier = 0
	_SHOP.randomize_shop()
	Global.state = Global.State.SHOP
	_DIALOGUE.show_dialogue("Buying or upgrading...?")
	_PLAYER_TEXTBOXES.make_visible()

func _toll_price_remaining() -> int:
	return max(0, Global.current_round_toll() - Global.calculate_toll_coin_value())

func _show_toll_dialogue() -> void:
	var toll_price_remaining = _toll_price_remaining()
	if toll_price_remaining == 0:
		_DIALOGUE.show_dialogue("Good...")
	else:
		_DIALOGUE.show_dialogue("%d[img=12x13]res://assets/icons/coin_icon.png[/img] more..." % toll_price_remaining)

func _on_voyage_continue_button_clicked():
	_hide_voyage_map()
	var first_round = Global.round_count == 2
	
	# if this is the first round, give an obol and explain the rules a bit
	if first_round:
		await _wait_for_dialogue("Now place your payment on the table...")
		_make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL) # make a single starting coin
		
		# removed, but kept potentially for later - generate a random bonus starting coin from patron
		#_make_and_gain_coin(Global.patron.get_random_starting_coin_family(), Global.Denomination.OBOL)
	
	# if we won...
	if Global.current_round_type() == Global.RoundType.END:
		victory = true
		Global.state = Global.State.GAME_OVER
	# if there's a toll...
	elif Global.current_round_type() == Global.RoundType.TOLLGATE:
		Global.state = Global.State.TOLLGATE
		if Global.toll_index == 0:
			await _wait_for_dialogue("First tollgate...")
			await _wait_for_dialogue("You must pay %d[img=12x13]res://assets/icons/coin_icon.png[/img]..." % Global.current_round_toll())
		_show_toll_dialogue()
	else:
		#if first_round:
		await _wait_for_dialogue("...take a deep breath...")
		
		# refresh lives
		if not Global.is_passive_active(Global.TRIAL_POWER_FAMILY_FAMINE): # famine trial prevents life regen
			Global.lives += Global.current_round_life_regen()
		
		# refresh patron powers
		Global.patron_uses = Global.PATRON_USES_PER_ROUND[Global.round_count]
		
		if first_round:
			await _wait_for_dialogue("...Let's begin the game...")
		elif Global.current_round_type() == Global.RoundType.TRIAL1 or Global.current_round_type() == Global.RoundType.TRIAL2:
			await _wait_for_dialogue("Your trial begins...")
		
		Global.state = Global.State.BEFORE_FLIP #shows trial row
		_PLAYER_TEXTBOXES.make_invisible()
		
		if Global.current_round_type() == Global.RoundType.NEMESIS:
			for coin in _ENEMY_COIN_ROW.get_children():
				coin.hide_price() # bit of a $HACK$ to prevent nemesis price from being shown...
		
		for coin in _ENEMY_COIN_ROW.get_children():
			if coin.is_passive():
				if _ENEMY_COIN_ROW.get_child_count():
					await Global.delay(0.2)
				await coin.payoff_move_up()
				match coin.get_coin_family():
					Global.TRIAL_IRON_FAMILY:
						while _COIN_ROW.get_child_count() > Global.COIN_LIMIT-2: # make space for thorns obols
							_COIN_ROW.destroy_lowest_value()
						_make_and_gain_coin(Global.THORNS_FAMILY, Global.Denomination.OBOL)
						_make_and_gain_coin(Global.THORNS_FAMILY, Global.Denomination.OBOL)
						await _wait_for_dialogue("You shall be bound in Iron!")
					Global.TRIAL_MISFORTUNE_FAMILY:
						for c in _COIN_ROW.get_children():
							c.make_unlucky()
						await _wait_for_dialogue("You shall be shrouded in Misfortune!")
					Global.TRIAL_POLARIZATION_FAMILY:
						for c in _COIN_ROW.get_children():
							if c.get_denomination() == Global.Denomination.DIOBOL:
								c.blank()
						await _wait_for_dialogue("Your coins must be Polarized...")
					Global.TRIAL_PAIN_FAMILY:
						await _wait_for_dialogue("You shall writhe in Pain!")
					Global.TRIAL_BLOOD_FAMILY:
						await _wait_for_dialogue("Your Blood shall boil!")
					Global.TRIAL_EQUIVALENCE_FAMILY:
						await _wait_for_dialogue("Each flip will be one of Equivalence!")
					Global.TRIAL_FAMINE_FAMILY:
						await _wait_for_dialogue("Feel the hunger of Famine!")
					Global.TRIAL_TORTURE_FAMILY:
						await _wait_for_dialogue("Can you withstand this Torture?")
					Global.TRIAL_LIMITATION_FAMILY:
						await _wait_for_dialogue("It is time to feel mortal Limitation!")
					Global.TRIAL_COLLAPSE_FAMILY:
						await _wait_for_dialogue("You must beware an untimely Collapse!")
					Global.TRIAL_SAPPING_FAMILY:
						await _wait_for_dialogue("Your energy shall be Sapping.")
					Global.TRIAL_OVERLOAD_FAMILY:
						await _wait_for_dialogue("You may have power, but beware the Overload!")
				coin.payoff_move_down()
		
		# Nemesis introduction
		if Global.current_round_type() == Global.RoundType.NEMESIS:
			if Global.souls != 0:
					await _wait_for_dialogue("First, I will take your remaining souls...")
					Global.souls = 0
			
			await _wait_for_dialogue("And now...")
			
			for coin in _ENEMY_COIN_ROW.get_children():
				coin.payoff_move_up()
			
			for coin in _ENEMY_COIN_ROW.get_children():
				match coin.get_coin_family():
					Global.MEDUSA_FAMILY:
						await _wait_for_dialogue("Behold! The grim visage of the Gorgon Sisters!")
			
			await _wait_for_dialogue("To continue your voyage...")
			await _wait_for_dialogue("You must appease the gatekeeper!")
			await _wait_for_dialogue("Your fate lies with the coins now.")
			await _wait_for_dialogue("Let the final trial commence!")
			
			for coin in _ENEMY_COIN_ROW.get_children():
				coin.payoff_move_down()
		
		_END_ROUND_TEXTBOX.disable() if Global.current_round_type() == Global.RoundType.NEMESIS else _END_ROUND_TEXTBOX.enable()
		
		if Global.current_round_type() == Global.RoundType.NEMESIS:
			for coin in _ENEMY_COIN_ROW.get_children():
				coin.show_price() # bit of a $HACK$ to prevent nemesis price from being shown... reshow now
		
		_PLAYER_TEXTBOXES.make_visible()
		_DIALOGUE.show_dialogue("Will you toss...?")

var victory = false
func _on_pay_toll_button_clicked():
	if _toll_price_remaining() == 0 or true:
		# delete each of the coins used to pay the toll
		for coin in Global.toll_coins_offered:
			_COIN_ROW.remove_child(coin)
			coin.queue_free()
		Global.toll_coins_offered.clear()
		
		# advance the toll
		Global.toll_index += 1
		
		await _wait_for_dialogue("The toll is paid.")
		
		if _COIN_ROW.get_child_count() == 0:
			await _wait_for_dialogue("...Ah, no more coins?")
			await _wait_for_dialogue("...So you've lost the game...")
			await _wait_for_dialogue("...A shame... goodbye...")
			_on_die_button_clicked()
			return
		
		# now move the boat forward...
		_advance_round()
	else:
		_DIALOGUE.show_dialogue("Not... enough...")

func _on_die_button_clicked() -> void:
	Global.state = Global.State.GAME_OVER

func _on_shop_coin_purchased(coin: Coin, price: int):
	# make sure we can afford this coin
	if Global.souls < price:
		_DIALOGUE.show_dialogue("Not... enough... souls...")
		return 
	
	if _COIN_ROW.get_child_count() == Global.COIN_LIMIT:
		_DIALOGUE.show_dialogue("Too... many... coins...")
		return
	
	_SHOP.purchase_coin(coin)
	
	_gain_coin_entity(coin)

func _make_and_gain_coin(coin_family: Global.CoinFamily, denomination: Global.Denomination) -> Coin:
	var new_coin: Coin = _COIN_SCENE.instantiate()
	new_coin.clicked.connect(_on_coin_clicked)
	new_coin.flip_complete.connect(_on_flip_complete)
	_COIN_ROW.add_child(new_coin)
	new_coin.init_coin(coin_family, denomination, Coin.Owner.PLAYER)
	return new_coin

func _gain_coin_entity(coin: Coin):
	_COIN_ROW.add_child(coin)
	coin.mark_owned_by_player()
	coin.clicked.connect(_on_coin_clicked)
	coin.flip_complete.connect(_on_flip_complete)

func _remove_coin(coin: Coin):
	_COIN_ROW.remove_child(coin)
	coin.queue_free()

func _get_row_for(coin: Coin) -> CoinRow:
	if _COIN_ROW.has_coin(coin):
		return _COIN_ROW
	if _ENEMY_COIN_ROW.has_coin(coin):
		return _ENEMY_COIN_ROW
	assert(false, "Not in either row!")
	return null

func _on_coin_clicked(coin: Coin):
	# if we're in the shop, sell this coin
	# if Global.state == Global.State.SHOP:
	#	# don't sell if this is the last coin
	#	if _COIN_ROW.get_child_count() == 1:
	#		_DIALOGUE.show_dialogue("Can't sell last coin!")
	#		return
	#	Global.souls += coin.get_sell_price()
	#	_remove_coin(coin)
	#	return

	if Global.state == Global.State.TOLLGATE:
		# if this coin cannot be offered at a toll, error message and return
		if coin.get_coin_family() in Global.TOLL_EXCLUDE_COIN_FAMILIES:
			_DIALOGUE.show_dialogue("Don't... want... that...")
			return
		# if this coin is in the toll offering, remove it
		if Global.toll_coins_offered.has(coin):
			Global.remove_toll_coin(coin)
			# move the coin back down
			create_tween().tween_property(coin, "position:y", 0, 0.2).set_trans(Tween.TRANS_CUBIC)
		else: # otherwise add it
			Global.add_toll_coin(coin)
			# move the coin up a bit
			create_tween().tween_property(coin, "position:y", -20, 0.2).set_trans(Tween.TRANS_CUBIC)
		return

	if Global.state == Global.State.SHOP:
		if not coin.can_upgrade():
			if coin.get_denomination() == Global.Denomination.TETROBOL:
				_DIALOGUE.show_dialogue("Can't... upgrade... more...")
			else:
				_DIALOGUE.show_dialogue("Can't... upgrade.... that...")
		elif Global.souls >= coin.get_upgrade_price():
			Global.souls -= coin.get_upgrade_price()
			coin.upgrade()
			coin.reset_power_uses()
			_DIALOGUE.show_dialogue("More... power...")
		else:
			_DIALOGUE.show_dialogue("Not... enough... souls...!")
		return
	
	# try to appease a coin in enemy row
	if coin.is_appeaseable() and Global.active_coin_power_family == null:
		if Global.souls >= coin.get_appeasal_price():
			coin.queue_free()
			_ENEMY_COIN_ROW.remove_child(coin)
			Global.souls -= coin.get_appeasal_price()
			_DIALOGUE.show_dialogue("Very good...")
			
			# if nemesis round and the row is now empty, go ahead and end the round
			if _ENEMY_COIN_ROW.get_child_count() == 0 and Global.current_round_type() == Global.RoundType.NEMESIS:
				_on_end_round_button_pressed()
				return
		else:
			_DIALOGUE.show_dialogue("Not enough souls to appease...")
		return
	
	# only use coin powers during after flip
	if Global.state != Global.State.AFTER_FLIP:
		return
	
	var row = _get_row_for(coin)
	var left = row.get_left_of(coin)
	var right = row.get_right_of(coin)
	
	# if we have a coin power active, we're using a power on this coin; do that
	if Global.active_coin_power_family != null:
		if coin.is_passive(): # powers can't be used on passive coins
			_DIALOGUE.show_dialogue("Can't... do... that...")
		if Global.is_patron_power(Global.active_coin_power_family):
			match(Global.active_coin_power_family):
				Global.PATRON_POWER_FAMILY_ZEUS:
					coin.supercharge()
					_safe_flip(coin)
				Global.PATRON_POWER_FAMILY_HERA:
					coin.turn()
					if left:
						left.turn()
					if right:
						right.turn()
				Global.PATRON_POWER_FAMILY_POSEIDON:
					coin.freeze()
					if left:
						left.freeze()
					if right:
						right.freeze()
				Global.PATRON_POWER_FAMILY_ATHENA:
					if not coin.can_reduce_life_penalty():
						_DIALOGUE.show_dialogue("No... need...")
						return
					coin.reduce_life_penalty_permanently()
				Global.PATRON_POWER_FAMILY_HEPHAESTUS:
					if row == _ENEMY_COIN_ROW:
						_DIALOGUE.show_dialogue("Can't... upgrade... that...")
						return
					if coin.get_denomination() == Global.Denomination.OBOL:
						_DIALOGUE.show_dialogue("Can't... downgrade... that one...")
						return
					if left and left.get_denomination() == Global.Denomination.TETROBOL and right and right.get_denomination() == Global.Denomination.TETROBOL:
						_DIALOGUE.show_dialogue("Can't... upgrade... further...")
						return
					coin.downgrade()
					if left and left.can_upgrade():
						left.upgrade()
					if right and right.can_upgrade():
						right.upgrade()
				Global.PATRON_POWER_FAMILY_HERMES:
					if row == _ENEMY_COIN_ROW:
						_DIALOGUE.show_dialogue("Can't... trade... that...")
						return
					coin.init_coin(Global.random_family(), coin.get_denomination(), Coin.Owner.PLAYER)
					if Global.RNG.randi_range(1, 4) == 1 and coin.can_upgrade():
						coin.upgrade()
				Global.PATRON_POWER_FAMILY_HESTIA:
					coin.make_lucky()
					coin.bless()
				Global.PATRON_POWER_FAMILY_HADES:
					if row == _ENEMY_COIN_ROW:
						#todo - will need to revisit for Echidna; make exception for monster coins
						_DIALOGUE.show_dialogue("Can't... destroy... that...")
						return
					if _COIN_ROW.get_child_count() == 1: #destroying itself, and last coin
						_DIALOGUE.show_dialogue("Can't destroy... last coin...")
						return
					# gain life & souls
					Global.lives += 5 * coin.get_value()
					Global.souls += 5 * coin.get_value()
					coin.queue_free()
			Global.patron_uses -= 1
			if Global.patron_uses == 0:
				_patron_token.deactivate()
			return
		match(Global.active_coin_power_family):
			Global.POWER_FAMILY_REFLIP:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... reflip... itself...")
				_safe_flip(coin)
			Global.POWER_FAMILY_FREEZE:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... freeze... itself...")
					return
				coin.freeze()
			Global.POWER_FAMILY_REFLIP_AND_NEIGHBORS:
				# flip coin and neighbors
				_safe_flip(coin)
				if left:
					_safe_flip(left)
				if right:
					_safe_flip(right)
			Global.POWER_FAMILY_TURN_AND_BLURSE:
				coin.turn()
				coin.curse() if coin.is_heads() else coin.bless()
			Global.POWER_FAMILY_REDUCE_PENALTY:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... reduce... itself...")
					return
				if not coin.can_reduce_life_penalty():
					_DIALOGUE.show_dialogue("No... need...")
					return
				coin.reduce_life_penalty_for_round()
			Global.POWER_FAMILY_UPGRADE_AND_IGNITE:
				if row == _ENEMY_COIN_ROW:
					_DIALOGUE.show_dialogue("Can't... upgrade... that...")
					return
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... forge... itself...")
					return
				if not coin.can_upgrade():
					if coin.get_denomination() == Global.Denomination.TETROBOL:
						_DIALOGUE.show_dialogue("Can't... upgrade... more...")
					else:
						_DIALOGUE.show_dialogue("Can't... upgrade.... that...")
					return
				# Heph Obol can only upgrade Obols; Diobol can only upgrade Obol + Diobol
				if Global.active_coin_power_coin.get_denomination_as_int() < coin.get_denomination_as_int():
					_DIALOGUE.show_dialogue("Can't... upgrade... %ss..." % Global.denom_to_string(coin.get_denomination()))
					return
				coin.upgrade()
				coin.ignite()
			Global.POWER_FAMILY_RECHARGE:
				if row == _ENEMY_COIN_ROW:
					_DIALOGUE.show_dialogue("Can't... love... that...")
					return
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... love... yourself...")
					return
				if not coin.can_activate_power():
					_DIALOGUE.show_dialogue("Can't... recharge... that...")
					return
				coin.recharge_power_uses_by(1)
			Global.POWER_FAMILY_EXCHANGE:
				if row == _ENEMY_COIN_ROW:
					_DIALOGUE.show_dialogue("Can't... trade... that...")
					return
				coin.init_coin(Global.random_family(), coin.get_denomination(), Coin.Owner.PLAYER)
			Global.POWER_FAMILY_MAKE_LUCKY:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... benefit... itself...")
					return
				coin.make_lucky()
			Global.POWER_FAMILY_DESTROY_FOR_LIFE:
				if row == _ENEMY_COIN_ROW:
					_DIALOGUE.show_dialogue("Can't... destroy...")
					return
				if _COIN_ROW.get_child_count() == 1: #destroying itself, and last coin
					_DIALOGUE.show_dialogue("Can't destroy... last coin...")
					return
				# gain life equal to (2 * hades_value) * destroyed_value
				Global.lives += (2 * Global.active_coin_power_coin.get_value()) * coin.get_value()
				coin.queue_free()
			Global.POWER_FAMILY_ARROW_REFLIP:
				_safe_flip(coin)
				Global.arrows -= 1
				if Global.arrows == 0:
					Global.active_coin_power_family = null
				return #special case - this power is not from a coin, so just exit immediately
		Global.active_coin_power_coin.spend_power_use()
		if Global.active_coin_power_coin.get_active_power_charges() == 0 or not Global.active_coin_power_coin.is_heads():
			Global.active_coin_power_coin = null
			Global.active_coin_power_family = null
	
	# otherwise we're attempting to activate a coin
	elif coin.can_activate_power() and coin.get_active_power_charges() > 0:
		# if this is a power which does not target, resolve it
		match coin.get_active_power_family():
			Global.POWER_FAMILY_GAIN_LIFE:
				Global.lives += coin.get_denomination_as_int() + 1
				coin.spend_power_use()
			Global.POWER_FAMILY_GAIN_ARROW:
				Global.arrows += coin.get_denomination_as_int()
				coin.spend_power_use()
			Global.POWER_FAMILY_REFLIP_ALL:
				# reflip all coins
				coin.spend_power_use()
				for c in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
					c = c as Coin
					_safe_flip(c)
			Global.POWER_FAMILY_GAIN_COIN:
				if _COIN_ROW.get_child_count() == Global.COIN_LIMIT:
					_DIALOGUE.show_dialogue("Too... many... coins...")
					return
				_make_and_gain_coin(Global.random_family(), Global.Denomination.OBOL)
				coin.spend_power_use()
			_: # otherwise, make this the active coin and coin power and await click on target
				Global.active_coin_power_coin = coin
				Global.active_coin_power_family = coin.get_active_power_family()

func _on_arrow_pressed():
	assert(Global.arrows >= 0)
	Global.active_coin_power_family = Global.POWER_FAMILY_ARROW_REFLIP

func _on_patron_token_clicked():
	if Global.patron_uses == 0:
		_DIALOGUE.show_dialogue("No... more... gods...")
		return
	
	# immediate patron powers
	match(Global.patron.power_family):
		Global.PATRON_POWER_FAMILY_DEMETER:
			for coin in _COIN_ROW.get_children():
				var as_coin: Coin = coin
				if as_coin.is_tails() and as_coin.get_active_power_family() == Global.POWER_FAMILY_LOSE_LIFE:
					Global.lives += as_coin.get_active_power_charges()
			Global.patron_uses -= 1
		Global.PATRON_POWER_FAMILY_APOLLO:
			for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				var as_coin: Coin = coin
				as_coin.turn()
			Global.patron_uses -= 1
		Global.PATRON_POWER_FAMILY_ARTEMIS:
			for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				var as_coin: Coin = coin
				Global.arrows += 1
				if as_coin.is_heads():
					as_coin.turn()
			Global.patron_uses -= 1
		Global.PATRON_POWER_FAMILY_ARES:
			for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				_safe_flip(coin)
				coin.clear_statuses()
			_COIN_ROW.shuffle()
			Global.patron_uses -= 1
		Global.PATRON_POWER_FAMILY_APHRODITE:
			for coin in _COIN_ROW.get_children():
				var as_coin: Coin = coin
				if not as_coin.get_active_power_family().is_payoff():
					as_coin.recharge_power_uses_by(1)
			Global.patron_uses -= 1
		Global.PATRON_POWER_FAMILY_DIONYSUS:
			if _COIN_ROW.get_child_count() == Global.COIN_LIMIT:
				_DIALOGUE.show_dialogue("Too... many... coins...")
				return
			var new_coin = _make_and_gain_coin(Global.random_family(), Global.Denomination.OBOL)
			new_coin.make_lucky()
			Global.patron_uses -= 1
		_: # if not immediate, activate the token
			_patron_token.activate()

func _input(event):
	# right click with a god power disables it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			Global.active_coin_power_family = null
			Global.active_coin_power_coin = null
			if _patron_token.is_activated():
				_patron_token.deactivate()
			if _map_active and not Global.state == Global.State.VOYAGE:
				_hide_voyage_map()

func _on_shop_reroll_button_clicked():
	if Global.souls <= Global.reroll_cost():
		_DIALOGUE.show_dialogue("Not... enough... souls...")
		return
	Global.souls -= Global.reroll_cost()
	_SHOP.randomize_shop()
	Global.shop_rerolls += 1
