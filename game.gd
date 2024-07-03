extends Node2D

signal game_ended

@onready var _COIN_ROW = $Table/CoinRow
@onready var _SHOP : Shop = $Table/Shop
@onready var _BOSS = $Table/Boss
@onready var _BOSS_ROW = $Table/Boss/BossRow

@onready var _RESET_BUTTON = $UI/ResetButton

@onready var _LIFE_FRAGMENTS = $LifeFragments
@onready var _SOUL_FRAGMENTS = $SoulFragments
@onready var _ARROWS = $Arrows

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _LIFE_FRAGMENT_SCENE = preload("res://components/life_fragment.tscn")
@onready var _SOUL_FRAGMENT_SCENE = preload("res://components/soul_fragment.tscn")
@onready var _ARROW_SCENE = preload("res://components/arrow.tscn")

@onready var _PLAYER_TEXTBOXES = $UI/PlayerTextboxs

@onready var _CHARON_POINT: Vector2 = $Points/Charon.position
@onready var _PLAYER_POINT: Vector2 = $Points/Player.position
@onready var _LIFE_FRAGMENT_PILE_POINT: Vector2 = $Points/LifeFragmentPile.position
@onready var _SOUL_FRAGMENT_PILE_POINT: Vector2 = $Points/SoulFragmentPile.position
@onready var _ARROW_PILE_POINT: Vector2 = $Points/ArrowPile.position

@onready var _VOYAGE: Voyage = $UI/Voyage

@onready var _PATRON_TOKEN_POSITION: Vector2 = $PatronToken.position

@onready var _DIALOGUE: DialogueManager = $UI/DialogueManager

@onready var _patron_token = $PatronToken

func _ready() -> void:
	assert(_COIN_ROW)
	assert(_SHOP)
	assert(_BOSS)
	assert(_BOSS_ROW)
	
	assert(_PLAYER_TEXTBOXES)
	
	assert(_RESET_BUTTON)
	
	assert(_CHARON_POINT)
	assert(_PLAYER_POINT)
	assert(_LIFE_FRAGMENT_PILE_POINT)
	assert(_SOUL_FRAGMENT_PILE_POINT)
	assert(_ARROW_PILE_POINT)
	assert(_ARROWS)
	
	assert(_VOYAGE)
	assert(_DIALOGUE)
	
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
		var target_pos = pile_pos + Vector2(Global.RNG.randi_range(-16, 16), Global.RNG.randi_range(-9, 9))
		
		# move from player to pile
		var tween = create_tween()
		#tween.tween_interval(fragment_count * 0.02)
		tween.tween_property(fragment, "position", target_pos, 0.4).set_trans(Tween.TRANS_CUBIC)
		
		pile.add_child(fragment)
		#fragment_count += 1

@onready var _PLAYER_TEXTBOX_INITIAL_POSITION = $UI/PlayerTextboxs.position
@onready var _OFFSET = Vector2(0, 15)
func _play_player_text_animation() -> void:
	for textbox in _PLAYER_TEXTBOXES.get_children():
		textbox.disable()
	_PLAYER_TEXTBOXES.position = _PLAYER_TEXTBOX_INITIAL_POSITION + _OFFSET
	_PLAYER_TEXTBOXES.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property(_PLAYER_TEXTBOXES, "position", _PLAYER_TEXTBOX_INITIAL_POSITION, 0.08)
	tween.parallel().tween_property(_PLAYER_TEXTBOXES, "modulate:a", 1.0, 0.04)
	for textbox in _PLAYER_TEXTBOXES.get_children():
		tween.tween_callback(textbox.enable)

func _show_player_textboxes() -> void:
	_PLAYER_TEXTBOXES.show()
	_play_player_text_animation()

func _on_state_changed() -> void:
	_play_player_text_animation()
	if Global.state == Global.State.GAME_OVER:
		_on_game_end()
	else:
		_RESET_BUTTON.hide()

func _on_game_end() -> void:
	_DIALOGUE.show_dialogue("What? You win? How?" if victory else "Your soul is mine!")
	_RESET_BUTTON.show()

func on_start() -> void:
	# delete all existing coins
	for coin in _COIN_ROW.get_children() + _BOSS_ROW.get_children():
		coin.queue_free()
		coin.get_parent().remove_child(coin)
	
	# randomize and set up the boss
	Global.boss = Global.choose_one(Global.BOSSES)
		
	# delete any old patron token and create a new one
	_patron_token.queue_free()
	_patron_token = Global.patron.patron_token.instantiate()
	_patron_token.position = _PATRON_TOKEN_POSITION
	_patron_token.clicked.connect(_on_patron_token_clicked)
	add_child(_patron_token)
	
	victory = false
	Global.round_count = 1
	Global.lives = Global.LIVES_PER_ROUND[1]
	Global.patron_uses = Global.PATRON_USES_PER_ROUND[1]
	Global.souls = 0
	Global.arrows = 0
	Global.active_coin_power = Global.Power.NONE
	Global.flips_this_round = 0
	Global.toll_coins_offered = []
	Global.toll_index = 0
	
	#debug
	Global.souls = 100
	Global.lives = 100
	Global.arrows = 10
	_gain_coin(Global.make_coin(Global.DEMETER_FAMILY, Global.Denomination.TETROBOL))
#	_gain_coin(Global.make_coin(Global.HERA_FAMILY, Global.Denomination.TETROBOL))
#	_gain_coin(Global.make_coin(Global.POSEIDON_FAMILY, Global.Denomination.TETROBOL))
#	_gain_coin(Global.make_coin(Global.ARTEMIS_FAMILY, Global.Denomination.TETROBOL))
#	_gain_coin(Global.make_coin(Global.DIONYSUS_FAMILY, Global.Denomination.TETROBOL))
	
	_RESET_BUTTON.hide()
	
	Global.state = Global.State.BOARDING
	
	await _wait_for_dialogue("I am the ferryman Charon, shephard of the dead.")
	await _wait_for_dialogue("Fool from Eleusis, you wish to cross?")
	await _wait_for_dialogue("I cannot take the living across the river Styx...")
	await _wait_for_dialogue("But this could yet prove entertaining...")
	await _wait_for_dialogue("We shall play a game, on the way across.")
	await _wait_for_dialogue("At each tollgate, you must pay the price.")
	await _wait_for_dialogue("Or your soul shall stay here with me, forevermore!")
	_DIALOGUE.show_dialogue("Brave hero, will you board?")

var flips_completed = 0
func _on_flip_complete() -> void:
	if Global.state == Global.State.AFTER_FLIP:
		return #ignore reflips such as Zeus
	
	flips_completed += 1
	
	# if every flip is done
	if flips_completed == _COIN_ROW.get_child_count() + _BOSS_ROW.get_child_count():
		# recharge all coin powers
		for coin in _COIN_ROW.get_children():
			coin = coin as CoinEntity
			coin.reset_power_uses()
		
		Global.flips_this_round += 1
		Global.state = Global.State.AFTER_FLIP
		_DIALOGUE.show_dialogue("Alea iacta est!")
		_show_player_textboxes()

func _on_toss_button_clicked() -> void:
	if _COIN_ROW.get_child_count() == 0:
		_DIALOGUE.show_dialogue("No... coins...")
		return
	
	# take life from player
	var life_loss = Global.strain_cost()
	if Global.lives < life_loss:
		_DIALOGUE.show_dialogue("Not... enough... life...!")
		return
	
	Global.lives -= life_loss
	
	_PLAYER_TEXTBOXES.hide()
	
	# flip all the coins
	flips_completed = 0
	for coin in _COIN_ROW.get_children() :
		coin = coin as CoinEntity
		coin.flip()
	for coin in _BOSS_ROW.get_children():
		coin = coin as CoinEntity
		coin.flip()

func _on_accept_button_pressed():
	assert(Global.state == Global.State.AFTER_FLIP, "this shouldn't happen")
	Global.active_coin_power = Global.Power.NONE
	Global.active_coin_power_coin = null
	
	_DIALOGUE.show_dialogue("Payoff...")
	_PLAYER_TEXTBOXES.hide()
	
	# payoff animation
	for coin in _COIN_ROW.get_children() + _BOSS_ROW.get_children():
		var gain_souls = coin.is_heads() and coin.get_souls() > 0
		var lose_life = coin.is_tails() and coin.get_life_loss() > 0
		
		if gain_souls or lose_life:
			create_tween().tween_property(coin, "position:y", -20, 0.18).set_trans(Tween.TRANS_CIRC)
			if gain_souls:
				Global.souls += coin.get_souls()
			elif lose_life:
				Global.lives -= coin.get_life_loss()
			# todo - other abilities
			await Global.delay(0.2)
			create_tween().tween_property(coin, "position:y", 0, 0.18).set_trans(Tween.TRANS_CIRC)
			await Global.delay(0.2)
	
	_PLAYER_TEXTBOXES.show()
	
	if Global.state != Global.State.GAME_OVER:
		Global.state = Global.State.BEFORE_FLIP
		_DIALOGUE.show_dialogue("Will you flip...?")

func _wait_for_dialogue(dialogue: String) -> void:
	_PLAYER_TEXTBOXES.hide()
	await _DIALOGUE.show_dialogue_and_wait(dialogue)
	_show_player_textboxes()

func _advance_round() -> void:
	Global.state = Global.State.VOYAGE
	_VOYAGE.show()
	_DIALOGUE.show_dialogue("Let us sail...")
	_PLAYER_TEXTBOXES.hide()
	await _VOYAGE.move_boat(Global.round_count)
	Global.round_count += 1
	
	if Global.round_count == Global.BOSS_ROUND:
		_BOSS.setup()
		for c in _BOSS_ROW.get_children():
			var coin = c as CoinEntity
			coin.flip_complete.connect(_on_flip_complete)
	else:
		for c in _BOSS_ROW.get_children():
			c.queue_free()
			_BOSS_ROW.remove_child(c)
	
	_show_player_textboxes()

func _on_board_button_clicked():
	assert(Global.state == Global.State.BOARDING)
	_advance_round()

func _on_continue_button_pressed():
	assert(Global.state == Global.State.SHOP)
	_advance_round()

func _on_end_round_button_pressed():
	assert(Global.state == Global.State.BEFORE_FLIP)
	for coin in _COIN_ROW.get_children():
		coin.on_round_end()
	_SHOP.randomize_shop()
	Global.flips_this_round = 0
	Global.state = Global.State.SHOP
	_DIALOGUE.show_dialogue("Buying or upgrading...?")

func _toll_price_remaining() -> int:
	return max(0, Global.TOLLGATE_PRICES[Global.toll_index] - Global.calculate_toll_coin_value())

func _show_toll_dialogue() -> void:
	var toll_price_remaining = _toll_price_remaining()
	if toll_price_remaining == 0:
		_DIALOGUE.show_dialogue("Good...")
	else:
		_DIALOGUE.show_dialogue("%d[img=12x13]res://assets/icons/coin_icon.png[/img] more..." % toll_price_remaining)

func _on_voyage_continue_button_clicked():
	_VOYAGE.hide()
	var first_round = Global.round_count == 2
	
	# if this is the first round, give an obol and explain the rules a bit
	if first_round:
		await _wait_for_dialogue("Now place your payment on the table...")
		_gain_coin(Global.make_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL)) # make a single starting coin
	
	if Global.round_count > Global.NUM_ROUNDS: # if the game ended, just exit
		return
	
	if Global.TOLLGATE_ROUNDS.has(Global.round_count):
		Global.state = Global.State.TOLLGATE
		if Global.toll_index == 0:
			await _wait_for_dialogue("First tollgate...")
			await _wait_for_dialogue("You must pay %d[img=12x13]res://assets/icons/coin_icon.png[/img]..." % Global.TOLLGATE_PRICES[Global.toll_index])
		_show_toll_dialogue()
	else:
		#if first_round:
		await _wait_for_dialogue("...take a deep breath...")
		
		# refresh lives
		Global.lives += Global.LIVES_PER_ROUND[Global.round_count]
		
		# refresh patron powers
		Global.patron_uses = Global.PATRON_USES_PER_ROUND[Global.round_count]
		
		if first_round:
			await _wait_for_dialogue("...Let's begin the game...")
		
		Global.state = Global.State.BEFORE_FLIP #hides the shop
		_DIALOGUE.show_dialogue("Will you toss...?")

var victory = false
func _on_pay_toll_button_clicked():
	if _toll_price_remaining() == 0:
		# delete each of the coins used to pay the toll
		for coin in Global.toll_coins_offered:
			_COIN_ROW.remove_child(coin)
			coin.queue_free()
		Global.toll_coins_offered.clear()
		
		# advance the toll
		Global.toll_index += 1
		
		# now move the boat forward...
		_advance_round()
		
		# if we're reached the end, end the game
		if Global.toll_index == Global.TOLLGATE_ROUNDS.size():
			victory = true
			Global.state = Global.State.GAME_OVER
	else:
		_DIALOGUE.show_dialogue("Not... enough...")

func _on_die_button_clicked() -> void:
	Global.state = Global.State.GAME_OVER

func _on_shop_coin_purchased(coin: CoinEntity, price: int):
	# make sure we can afford this coin
	if Global.souls < price:
		_DIALOGUE.show_dialogue("Not... enough... souls...")
		return 
	
	if _COIN_ROW.get_child_count() == Global.COIN_LIMIT:
		_DIALOGUE.show_dialogue("Too... many... coins...")
		return
	
	_SHOP.purchase_coin(coin)
	
	_gain_coin_entity(coin)

func _gain_coin(coin: Global.Coin) -> void:
	var new_coin: CoinEntity = _COIN_SCENE.instantiate()
	new_coin.clicked.connect(_on_coin_clicked)
	new_coin.flip_complete.connect(_on_flip_complete)
	_COIN_ROW.add_child(new_coin)
	new_coin.assign_coin(coin, CoinEntity.Owner.PLAYER)

func _gain_coin_entity(coin: CoinEntity):
	_COIN_ROW.add_child(coin)
	coin.mark_owned_by_player()
	coin.clicked.connect(_on_coin_clicked)
	coin.flip_complete.connect(_on_flip_complete)

func _remove_coin(coin: CoinEntity):
	_COIN_ROW.remove_child(coin)
	coin.queue_free()

func _on_coin_clicked(coin: CoinEntity):
	# if we're in the shop, sell this coin
	#sif Global.state == Global.State.SHOP:
	#	# don't sell if this is the last coin
	#	if _COIN_ROW.get_child_count() == 1:
	#		_DIALOGUE.show_dialogue("Can't sell last coin!")
	#		return
	#	Global.souls += coin.get_sell_price()
	#	_remove_coin(coin)
	#	return

	if Global.state == Global.State.TOLLGATE:
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
		if Global.souls >= coin.get_upgrade_price():
			Global.souls -= coin.get_upgrade_price()
			coin.upgrade_denomination()
			_DIALOGUE.show_dialogue("More... power...")
		else:
			_DIALOGUE.show_dialogue("Not...enough... souls...!")
		return
	
	# only use coin powers during after flip
	if Global.state != Global.State.AFTER_FLIP:
		return
	
	# if we have a coin power active, we're using a power on this coin; do that
	if Global.active_coin_power != Global.Power.NONE:
		if Global.is_patron_power(Global.active_coin_power):
			match(Global.active_coin_power):
				Global.Power.PATRON_ZEUS:
					coin.supercharge()
					coin.flip()
			Global.patron_uses -= 1
			if Global.patron_uses == 0:
				_patron_token.deactivate()
			return
		match(Global.active_coin_power):
			Global.Power.REFLIP:
				coin.flip()
			Global.Power.FREEZE:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... freeze... itself...")
					return
				coin.freeze()
			Global.Power.FLIP_AND_NEIGHBORS:
				# find neighboring coins
				var left_neighbor: CoinEntity = null
				var right_neighbor: CoinEntity = null
				for i in _COIN_ROW.get_child_count():
					var curr_coin = _COIN_ROW.get_child(i)
					if curr_coin == coin:
						# if there is a right neighbor, grab it
						if i+1 < _COIN_ROW.get_child_count():
							right_neighbor = _COIN_ROW.get_child(i+1)
						break #then we're done
					left_neighbor = curr_coin
				
				# flip coin and neighbors
				coin.flip()
				if left_neighbor:
					left_neighbor.flip()
				if right_neighbor:
					right_neighbor.flip()
			Global.Power.CHANGE_AND_BLURSE:
				coin.swap_side()
				coin.curse() if coin.is_heads() else coin.bless()
			Global.Power.WISDOM:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... reduce... itself...")
					return
				if coin.get_life_loss() == 0:
					_DIALOGUE.show_dialogue("No... need...")
					return
				coin.apply_athena_wisdom()
			Global.Power.UPGRADE_AND_IGNITE:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... forge... itself...")
					return
				if coin.get_denomination() == Global.Denomination.TETROBOL:
					_DIALOGUE.show_dialogue("Can't... upgrade... further...")
					return
				coin.upgrade_denomination()
				coin.ignite()
			Global.Power.RECHARGE:
				if coin == Global.active_coin_power_coin:
					_DIALOGUE.show_dialogue("Can't... love... yourself...")
					return
				if coin.get_power() == Global.Power.NONE:
					_DIALOGUE.show_dialogue("No... power... to... recharge...")
					return
				coin.recharge_power_uses_by(1)
			Global.Power.EXCHANGE:
				coin.assign_coin(Global.make_coin(Global.random_family(), coin.get_denomination()), CoinEntity.Owner.PLAYER)
				coin.activate_power_text() # update power text
			Global.Power.MAKE_LUCKY:
				if coin.is_lucky():
					_DIALOGUE.show_dialogue("Already... lucky...")
					return
				coin.make_lucky()
			Global.Power.DESTROY_FOR_LIFE:
				if _COIN_ROW.get_child_count() == 1: #destroying itself, and last coin
					_DIALOGUE.show_dialogue("Can't destroy... last coin...")
					return
				# gain life equal to (2 * hades_value) * destroyed_value
				Global.lives += (2 * Global.active_coin_power_coin.get_value()) * coin.get_value()
				coin.queue_free()
			Global.Power.ARROW_REFLIP:
				coin.flip()
				Global.arrows -= 1
				if Global.arrows == 0:
					Global.active_coin_power = Global.Power.NONE
				return #special case - this power is not from a coin, so just exit immediately
				
		Global.active_coin_power_coin.spend_power_use()
		if Global.active_coin_power_coin.get_power_uses_remaining() == 0 or not Global.active_coin_power_coin.is_heads():
			Global.active_coin_power_coin = null
			Global.active_coin_power = Global.Power.NONE
	
	# otherwise we're attempting to activate a coin
	elif coin.is_heads() and coin.get_power() != Global.Power.NONE and coin.get_power_uses_remaining() > 0:
		# if this is a power which does not target, resolve it
		match coin.get_power():
			Global.Power.GAIN_LIFE:
				Global.lives += coin.get_denomination_as_int() + 1
				coin.spend_power_use()
			Global.Power.GAIN_ARROW:
				Global.arrows += 1
				coin.spend_power_use()
			Global.Power.REFLIP_ALL:
				# reflip all coins
				var all_coins = []
				for c in _COIN_ROW.get_children():
					c = c as CoinEntity
					c.flip()
					all_coins.append(c)
					_COIN_ROW.remove_child(c)
				# randomize locations
				all_coins.shuffle()
				for c in all_coins:
					_COIN_ROW.add_child(c)
				coin.spend_power_use()
			Global.Power.GAIN_COIN:
				if _COIN_ROW.get_child_count() == Global.COIN_LIMIT:
					_DIALOGUE.show_dialogue("Too... many... coins...")
					return
				_gain_coin(Global.make_coin(Global.random_family(), Global.Denomination.OBOL))
				coin.spend_power_use()
			_: # otherwise, make this the active coin and coin power and await click on target
				Global.active_coin_power_coin = coin
				Global.active_coin_power = coin.get_power()

func _on_arrow_pressed():
	assert(Global.arrows >= 0)
	Global.active_coin_power = Global.Power.ARROW_REFLIP

func _on_patron_token_clicked():
	if Global.patron_uses == 0:
		_DIALOGUE.show_dialogue("No... more... gods...")
		return
	_patron_token.activate()

func _input(event):
	if Input.is_key_pressed(KEY_SPACE):
		breakpoint
	
	# right click with a god power disables it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			Global.active_coin_power = Global.Power.NONE
			if _patron_token.is_activated():
				_patron_token.deactivate()

# todo - delete this thing
func _on_reset_button_pressed():
	emit_signal("game_ended")
