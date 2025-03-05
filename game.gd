extends Node2D

signal game_ended

@onready var _COIN_ROW: CoinRow = $Table/CoinRow
@onready var _SHOP: Shop = $Table/Shop
@onready var _SHOP_COIN_ROW: CoinRow = $Table/Shop/ShopRow
@onready var _ENEMY_ROW: EnemyRow = $Table/EnemyRow
@onready var _ENEMY_COIN_ROW: CoinRow = $Table/EnemyRow/CoinRow
@onready var _CHARON_COIN_ROW: CoinRow = $Table/CharonObolRow

@onready var _LIFE_LABEL = $Table/LivesLabel
@onready var _SOUL_LABEL = $Table/SoulsLabel
@onready var _LIFE_FRAGMENTS = $Table/LifeFragments
@onready var _SOUL_FRAGMENTS = $Table/SoulFragments
@onready var _ARROWS = $Table/Arrows

@onready var _COIN_SCENE = preload("res://components/coin.tscn")
@onready var _LIFE_FRAGMENT_SCENE = preload("res://components/life_fragment.tscn")
@onready var _SOUL_FRAGMENT_SCENE = preload("res://components/soul_fragment.tscn")
@onready var _ARROW_SCENE = preload("res://components/arrow.tscn")

@onready var _PLAYER_TEXTBOXES = $UI/PlayerTextboxes
@onready var _END_ROUND_TEXTBOX = $UI/PlayerTextboxes/EndRoundButton
@onready var _SHOP_CONTINUE_TEXTBOX = $UI/PlayerTextboxes/ShopContinueButton
@onready var _ACCEPT_TEXTBOX = $UI/PlayerTextboxes/AcceptButton
@onready var _VOYAGE_NEXT_ROUND_TEXTBOX = $UI/PlayerTextboxes/VoyageNextRoundButton

@onready var _CHARON_POINT: Vector2 = $Points/Charon.position
@onready var _PLAYER_POINT: Vector2 = $Points/Player.position
@onready var _PLAYER_NEW_COIN_POSITION: Vector2 = _PLAYER_POINT - Vector2(22, 0)
@onready var _PLAYER_FLIP_POSITION: Vector2 = _PLAYER_NEW_COIN_POSITION - Vector2(0, 25)
@onready var _CHARON_NEW_COIN_POSITION: Vector2 = _CHARON_POINT - Vector2(22, 0)
@onready var _CHARON_FLIP_POSITION: Vector2 = _CHARON_NEW_COIN_POSITION
@onready var _LIFE_FRAGMENT_PILE_POINT: Vector2 = $Points/LifeFragmentPile.position
@onready var _SOUL_FRAGMENT_PILE_POINT: Vector2 = $Points/SoulFragmentPile.position
@onready var _ARROW_PILE_POINT: Vector2 = $Points/ArrowPile.position
@onready var _MAP_SHOWN_POINT = $Points/MapShown.position
@onready var _MAP_HIDDEN_POINT = $Points/MapHidden.position
@onready var _MAP_INITIAL_POINT = $Points/MapInitial.position

@onready var _TRIAL_TINT_FX = $TrialTint/FX
@onready var _NEMESIS_TINT_FX = $NemesisTint/FX
@onready var _CHARON_TINT_FX = $CharonTint/FX
const _TINT_TIME = 0.25
const _TINT_ALPHA = 0.075
@onready var _CHARON_FOG_FX = $CharonFog/FX

@onready var _FOG_FX = $Fog/FX
@onready var _FOG_BLUE_FX = $FogBlue/FX

@onready var _RIVER_LEFT: River = $RiverLeft
@onready var _RIVER_RIGHT: River = $RiverRight
@onready var _VOYAGE_MAP: VoyageMap = $Table/VoyageMap
@onready var _MAP_BLOCKER = $UI/MapBlocker
var _map_open = false: # if the map is currently open
	set(val):
		_map_open = val
		_VOYAGE_MAP.disable_glow() if _map_is_disabled or _map_open else _VOYAGE_MAP.enable_glow()
	
var _map_is_disabled = false: # if the map can be clicked on (ie, disabled during waiting dialogues and if the map is mid transition)
	set(val):
		_map_is_disabled = val
		_VOYAGE_MAP.disable_glow() if _map_is_disabled or _map_open else _VOYAGE_MAP.enable_glow()

@onready var _PATRON_TOKEN_POSITION: Vector2 = $Table/PatronToken.position

@onready var _TABLE = $Table
@onready var _DIALOGUE: DialogueSystem = $UI/DialogueSystem
@onready var _CAMERA: Camera2D = $Camera

@onready var _patron_token: PatronToken = $Table/PatronToken

@onready var _LEFT_HAND: CharonHand = $Table/CharonHandLeft
@onready var _RIGHT_HAND: CharonHand = $Table/CharonHandRight

@onready var _SPEEDRUN_TIMER: SpeedrunTimer = $UI/SpeedrunTimer

@onready var _EMBERS_PARTICLES = $Embers
@onready var _TRIAL_EMBERS_PARTICLES = $TrialEmbers

@onready var _TUTORIAL_FADE_FX: FX = $TutorialFade/FX
const _TUTORIAL_FADE_ALPHA = 0.45
const _TUTORIAL_FADE_TIME = 0.15
@onready var _TUTORIAL_FADE_Z = $TutorialFade.z_index + 1
var _tutorial_items_shown_above_filter = null
var _tutorial_fading = false # used to prevent clicking on coins during fades...
func _tutorial_fade_out() -> void:
	_tutorial_fading = true
	_PLAYER_TEXTBOXES.make_invisible()
	await _TUTORIAL_FADE_FX.fade_out(_TUTORIAL_FADE_TIME)
	_PLAYER_TEXTBOXES.make_visible()
	Global.restore_z(_LEFT_HAND)
	Global.restore_z(_RIGHT_HAND)
	for node in _tutorial_items_shown_above_filter:
		assert(node is CanvasItem)
		Global.restore_z(node)
	_tutorial_items_shown_above_filter = null
	_tutorial_fading = false

func _tutorial_fade_in(items_shown_above_filter: Array = []) -> void:
	assert(_tutorial_items_shown_above_filter == null)
	_tutorial_fading = true
	_tutorial_items_shown_above_filter = []
	Global.temporary_set_z(_LEFT_HAND, _TUTORIAL_FADE_Z)
	Global.temporary_set_z(_RIGHT_HAND, _TUTORIAL_FADE_Z)
	for node in items_shown_above_filter:
		if node is CoinRow:
			for child in node.get_children():
				Global.temporary_set_z(child, _TUTORIAL_FADE_Z)
				_tutorial_items_shown_above_filter.append(child)
		else:
			assert(node is CanvasItem)
			Global.temporary_set_z(node, _TUTORIAL_FADE_Z)
			_tutorial_items_shown_above_filter.append(node)
	_PLAYER_TEXTBOXES.make_invisible()
	await _TUTORIAL_FADE_FX.fade_in(_TUTORIAL_FADE_TIME, _TUTORIAL_FADE_ALPHA)
	_PLAYER_TEXTBOXES.make_visible()
	_tutorial_fading = false

func _tutorial_show(item: CanvasItem):
	Global.temporary_set_z(item, _TUTORIAL_FADE_Z)
	_tutorial_items_shown_above_filter.append(item)

var river_color_index = 0
var _RIVER_COLORS = [River.ColorStyle.PURPLE, River.ColorStyle.GREEN, River.ColorStyle.RED]

const SOUL_TO_LIFE_CONVERSION_RATE = 5.0


var powers_used = []
var malice_activations_this_game := 0

func _ready() -> void:
	assert(_COIN_ROW)
	assert(_SHOP)
	assert(_SHOP_COIN_ROW)
	assert(_ENEMY_ROW)
	assert(_ENEMY_COIN_ROW)
	assert(_CHARON_COIN_ROW)
	
	assert(_LIFE_LABEL)
	assert(_SOUL_LABEL)
	
	assert(_PLAYER_TEXTBOXES)
	assert(_END_ROUND_TEXTBOX)
	assert(_VOYAGE_NEXT_ROUND_TEXTBOX)
	
	assert(_CHARON_POINT)
	assert(_PLAYER_POINT)
	assert(_LIFE_FRAGMENT_PILE_POINT)
	assert(_SOUL_FRAGMENT_PILE_POINT)
	assert(_ARROW_PILE_POINT)
	assert(_ARROWS)
	
	assert(_DIALOGUE)
	assert(_TABLE)
	assert(_RIVER_LEFT)
	assert(_RIVER_RIGHT)
	
	assert(_VOYAGE_MAP)
	assert(_MAP_BLOCKER)
	assert(_MAP_SHOWN_POINT)
	assert(_MAP_HIDDEN_POINT)
	assert(_MAP_INITIAL_POINT)
	
	assert(_CHARON_FOG_FX)
	assert(_TRIAL_TINT_FX)
	assert(_NEMESIS_TINT_FX)
	assert(_CHARON_TINT_FX)
	
	assert(_FOG_FX)
	assert(_FOG_BLUE_FX)
	assert(_TUTORIAL_FADE_FX)
	
	assert(_SPEEDRUN_TIMER)
	
	assert(_EMBERS_PARTICLES)
	assert(_TRIAL_EMBERS_PARTICLES)
	_TRIAL_EMBERS_PARTICLES.emitting = false
	
	_CHARON_FOG_FX.get_parent().show() # this is dumb but I want to hide the fog in editor...
	_TRIAL_TINT_FX.get_parent().show() # ...same for these tints!
	_NEMESIS_TINT_FX.get_parent().show() # ...same for these tints!
	_CHARON_TINT_FX.get_parent().show() # ...same for these tints!
	_CHARON_FOG_FX.hide()
	_TRIAL_TINT_FX.hide()
	_NEMESIS_TINT_FX.hide()
	_CHARON_TINT_FX.hide()
	
	_SHOP.set_coin_spawn_point(_CHARON_NEW_COIN_POSITION)
	_ENEMY_ROW.set_coin_spawn_point(_CHARON_NEW_COIN_POSITION)
	
	_VOYAGE_MAP.position = _MAP_INITIAL_POINT #offscreen
	_VOYAGE_MAP.rotation_degrees = -90
	
	# delete all existing coins
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		coin.queue_free()
		coin.get_parent().remove_child(coin)
	Global.COIN_ROWS = [_COIN_ROW, _ENEMY_COIN_ROW]
	
	Global.state_changed.connect(_on_state_changed)
	Global.life_count_changed.connect(_on_life_count_changed)
	Global.souls_count_changed.connect(_on_soul_count_changed)
	Global.arrow_count_changed.connect(_on_arrow_count_changed)
	Global.toll_coins_changed.connect(_show_toll_dialogue)
	Global.malice_changed.connect(_on_malice_changed)

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
		arrow.position = _ARROW_PILE_POINT + Vector2(Global.RNG.randi_range(-3, 3), Global.RNG.randi_range(-3, 3))
		_ARROWS.add_child(arrow)

func _on_soul_count_changed() -> void:
	_update_fragment_pile(Global.souls, _SOUL_FRAGMENT_SCENE, _SOUL_FRAGMENTS, _CHARON_POINT, _CHARON_POINT, _SOUL_FRAGMENT_PILE_POINT)

func _on_life_count_changed() -> void:
	_update_fragment_pile(Global.lives, _LIFE_FRAGMENT_SCENE, _LIFE_FRAGMENTS, _PLAYER_POINT, _CHARON_POINT, _LIFE_FRAGMENT_PILE_POINT)
	
	# if we ran out of life, initiate last chance flip
	if Global.lives < 0:
		await _wait_for_dialogue("You are out of life...")
		if Global.is_current_round_trial() or Global.is_current_round_nemesis():
			Global.state = Global.State.GAME_OVER
		else:
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
	_update_payoffs()
	
	if Global.state == Global.State.SHOP:
		_TRIAL_TINT_FX.fade_out(_TINT_TIME)
		_NEMESIS_TINT_FX.fade_out(_TINT_TIME)
		_CHARON_TINT_FX.fade_out(_TINT_TIME)
		_TRIAL_EMBERS_PARTICLES.emitting = false
	elif Global.is_current_round_trial():
		_TRIAL_TINT_FX.fade_in(_TINT_TIME, _TINT_ALPHA)
		_TRIAL_EMBERS_PARTICLES.emitting = true
	elif Global.is_current_round_nemesis():
		_NEMESIS_TINT_FX.fade_in(_TINT_TIME, _TINT_ALPHA)
		_TRIAL_EMBERS_PARTICLES.emitting = true
	else:
		_TRIAL_TINT_FX.fade_out(_TINT_TIME)
		_NEMESIS_TINT_FX.fade_out(_TINT_TIME)
		_CHARON_TINT_FX.fade_out(_TINT_TIME)
		_TRIAL_EMBERS_PARTICLES.emitting = false
	
	# remove fog in shop
	if Global.state == Global.State.SHOP:
		_FOG_FX.fade_out()
		_FOG_BLUE_FX.fade_out()
	else:
		_FOG_FX.fade_in()
		_FOG_BLUE_FX.fade_in()
	
	if Global.state != Global.State.CHARON_OBOL_FLIP:
		_CHARON_FOG_FX.fade_out(_TINT_TIME)
	
	if Global.state == Global.State.CHARON_OBOL_FLIP and Global.tutorialState != Global.TutorialState.INACTIVE:
		if Global.tutorialState == Global.TutorialState.ROUND6_TRIAL_COMPLETED:
			await _tutorial_fade_in()
			await _wait_for_dialogue("It seems you were unable to defeat the trial.")
			await _wait_for_dialogue("I pity you.")
			await _wait_for_dialogue("You have lost the game...")
			await _wait_for_dialogue("...but we will continue regardless.")
			await _wait_for_dialogue("The only challenge left is the tollgate...")
			await _wait_for_dialogue("But first, we will visit one final shop.")
			await _tutorial_fade_out()
			_DIALOGUE.show_dialogue("Spend your meagre earnings before we proceed.")
			Global.lives = 0
			Global.tutorialState = Global.TutorialState.ROUND7_TOLLGATE_INTRO
			_on_end_round_button_pressed()
			return
		else:
			await _wait_for_dialogue("That means you lose the game.")
			await _wait_for_dialogue("...I did not expect it to end so soon...")
			await _wait_for_dialogue("Very well!")
			await _wait_for_dialogue("This time I will have mercy upon you.")
			await _wait_for_dialogue("The game shall continue.")
			await _wait_for_dialogue("Let us imagine you cleverly ended the round instead.")
			Global.lives = 0
			_on_end_round_button_pressed()
			return
	
	if Global.state != Global.State.CHARON_OBOL_FLIP:
		_CHARON_COIN_ROW.retract(_CHARON_NEW_COIN_POSITION)
	else:
		_COIN_ROW.retract(_PLAYER_NEW_COIN_POSITION)
	_CHARON_COIN_ROW.visible = Global.state == Global.State.CHARON_OBOL_FLIP
	
	if Global.state == Global.State.CHARON_OBOL_FLIP:
		Global.tosses_this_round = 0 # reduce ante to 0 for display purposes
		Global.ante_modifier_this_round = 0
		_ENEMY_COIN_ROW.clear()
		_CHARON_COIN_ROW.get_child(0).set_heads_no_anim() # force to heads for visual purposes
		_PLAYER_TEXTBOXES.make_invisible()
		await _wait_for_dialogue("I did not expect you to perish here...")
		await _wait_for_dialogue("Very well!")
		await _wait_for_dialogue("This time, I shall grant you one final opportunity.")
		_PLAYER_TEXTBOXES.make_invisible()
		await _CHARON_COIN_ROW.expand()
		await _wait_for_dialogue("We will flip this single obol.")
		_LEFT_HAND.point_at(_hand_point_for_coin(_CHARON_COIN_ROW.get_child(0)))
		await _wait_for_dialogue(Global.replace_placeholders("Heads(HEADS), and the story continues."))
		_CHARON_COIN_ROW.get_child(0).turn()
		await _wait_for_dialogue(Global.replace_placeholders("Tails(TAILS), and your long journey ends here."))
		_CHARON_COIN_ROW.get_child(0).turn()
		_LEFT_HAND.unpoint()
		await _wait_for_dialogue("And now, on the edge of life and death...")
		_CHARON_FOG_FX.fade_in(_TINT_TIME)
		_CHARON_TINT_FX.fade_in(_TINT_TIME, _TINT_ALPHA)
		_DIALOGUE.show_dialogue("You must toss!")
		_PLAYER_TEXTBOXES.make_visible()
	elif Global.state == Global.State.GAME_OVER:
		_on_game_end()

func _on_game_end() -> void:
	_SPEEDRUN_TIMER.finish()
	if Global.tutorialState == Global.TutorialState.ENDING:
		await _tutorial_fade_in()
		await _wait_for_dialogue("We've reached the other shore...")
		await _wait_for_dialogue("I hope my game was a suitable distraction.")
		await _wait_for_dialogue("...You should head to the palace immediately.")
		await _wait_for_dialogue("I'm sure he is waiting for you.")
		await _wait_for_dialogue("Until we meet again.")
		await _wait_for_dialogue("Farewell...")
		_tutorial_fade_out()
	elif victory:
		await _wait_for_dialogue("And we've reached the other shore...")
		await _wait_for_dialogue("I wish you luck on the rest of your journey...")
	else:
		await _wait_for_dialogue("You were a fool to come here.")
		await _wait_for_dialogue("And now...")
		await _wait_for_dialogue("Your soul shall be mine!")
	_LEFT_HAND.unlock()
	_LEFT_HAND.move_offscreen()
	_RIGHT_HAND.unlock()
	_RIGHT_HAND.move_offscreen()
	Global.souls = 0
	Global.lives = 0
	emit_signal("game_ended", victory)

func on_start() -> void: #reset
	_CAMERA.make_current()
	_DIALOGUE.instant_clear_dialogue()
	
	# reset color to purple...
	river_color_index = 0
	_recolor_river(_RIVER_COLORS[river_color_index], true)
	
	# delete all existing coins
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		coin.get_parent().remove_child(coin)
		coin.free()
	
	# make charon's obol
	for coin in _CHARON_COIN_ROW.get_children():
		_CHARON_COIN_ROW.remove_child(coin)
		coin.free()
	
	# move map to offscreen starting position and rotation
	_VOYAGE_MAP.position = _MAP_INITIAL_POINT #offscreen
	_VOYAGE_MAP.rotation_degrees = -90
	
	Global.tutorialState = Global.TutorialState.PROLOGUE_BEFORE_BOARDING if Global.is_character(Global.Character.LADY) else Global.TutorialState.INACTIVE
	if Global.is_character(Global.Character.LADY): # ensure difficulty is minimum if playing as Lady
		Global.difficulty = Global.Difficulty.INDIFFERENT1
	Global.tutorial_warned_zeus_reflip = false
	Global.tutorial_pointed_out_patron_passive = false
	Global.tutorial_patron_passive_active = false
	
	var charons_obol = _COIN_SCENE.instantiate()
	_CHARON_COIN_ROW.add_child(charons_obol)
	charons_obol.flip_complete.connect(_on_flip_complete)
	charons_obol.turn_complete.connect(_on_turn_complete)
	charons_obol.init_coin(Global.CHARON_OBOL_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_CHARON_COIN_ROW.hide()
	
	# randomize and set up the nemesis & trials
	Global.randomize_voyage()
	Global.generate_coinpool()
	_VOYAGE_MAP.update_tooltips()
	
	if Global.patron == null: # tutorial - use Charon
		Global.patron = Global.patron_for_enum(Global.PatronEnum.CHARON)
	_make_patron_token()
	if Global.patron == Global.patron_for_enum(Global.PatronEnum.CHARON): # tutorial - starts offscreen
		_patron_token.position = _CHARON_POINT
	
	victory = false
	Global.round_count = 1
	Global.souls_earned_this_round = 0
	Global.lives = Global.current_round_life_regen()
	Global.patron_uses = Global.patron.get_uses_per_round()
	Global.souls = 0
	Global.arrows = 0
	Global.active_coin_power_family = null
	Global.active_coin_power_coin = null
	Global.tosses_this_round = 0
	Global.ante_modifier_this_round = 0
	Global.shop_rerolls = 0
	Global.toll_coins_offered = []
	Global.toll_index = 0
	Global.malice = 0
	powers_used = []
	malice_activations_this_game = 0
	Global.monsters_destroyed_this_round = 0
	
	Global.state = Global.State.BOARDING
	
	_SPEEDRUN_TIMER.start()
	
	# pull back the hands, and have them move in
	_LEFT_HAND.unlock()
	_RIGHT_HAND.unlock()
	_LEFT_HAND.move_offscreen(true)
	_RIGHT_HAND.move_offscreen(true)
	_LEFT_HAND.move_to_default_position()
	_RIGHT_HAND.move_to_default_position()
	
	_PLAYER_TEXTBOXES.make_invisible()
	
	if Global.tutorialState == Global.TutorialState.PROLOGUE_BEFORE_BOARDING:
		await _tutorial_fade_in() #i'm cheating a bit here but it should be fine...
		await _wait_for_dialogue("Ah, a surprise... (Click anywhere to continue)")
		await _wait_for_dialogue("You grace us with your presence once more.")
		await _wait_for_dialogue("He has been impatiently anticipating your arrival.")
		await _wait_for_dialogue("Come aboard my ship and we shall be off.")
		await _wait_for_dialogue("We wouldn't want to keep him waiting...")
		await _tutorial_fade_out()
		_DIALOGUE.show_dialogue("Noble one, will you board?")
		Global.tutorialState = Global.TutorialState.PROLOGUE_AFTER_BOARDING
	else:
		await _wait_for_dialogue("I am the ferryman Charon, shephard of the dead.")
		await _wait_for_dialogue("Fool from Eleusis, you wish to cross?")
		await _wait_for_dialogue("I cannot take the living across the river Styx...")
		await _wait_for_dialogue("But this could yet prove entertaining...")
		await _wait_for_dialogue("We shall play a game, on the way across.")
		await _wait_for_dialogue("At each tollgate, you must pay the price.")
		await _wait_for_dialogue("Or your soul shall stay here with me, forevermore!")
		_DIALOGUE.show_dialogue("Brave hero, will you board?")
	_PLAYER_TEXTBOXES.make_visible()

func _make_patron_token():
	# delete any old patron token and create a new one
	_patron_token.queue_free()
	_patron_token = Global.patron.patron_token.instantiate()
	_patron_token.position = _PATRON_TOKEN_POSITION
	_patron_token.clicked.connect(_on_patron_token_clicked)
	_patron_token.name = "PatronToken"
	_TABLE.add_child(_patron_token)

var flips_pending = 0
func _on_flip_complete(flipped_coin: Coin) -> void:
	flips_pending -= 1
	assert(flips_pending >= 0)
	_update_payoffs()
	
	_handle_tantalus(flipped_coin)

	
	if flips_pending == 0:
		if Global.state == Global.State.AFTER_FLIP: #ignore reflips such as Zeus
			_PLAYER_TEXTBOXES.make_visible()
			_map_is_disabled = false
			if Global.tutorialState == Global.TutorialState.ROUND2_POWER_USED:
				_LEFT_HAND.unlock()
				_LEFT_HAND.unpoint()
				await _tutorial_fade_in([_COIN_ROW])
				await _wait_for_dialogue(Global.replace_placeholders("This time, your coin landed on heads(HEADS)!"))
				await _wait_for_dialogue("Using a power costs one of that coin's charges.")
				var icon = _COIN_ROW.get_child(1).get_heads_icon()
				await _wait_for_dialogue("This coin previously had 2[img=10x13]%s[/img], and now has 1[img=10x13]%s[/img]." % [icon, icon])
				await _wait_for_dialogue("Charges are replenished each toss.")
				await _wait_for_dialogue("So there is no need to hold back on using powers.")
				await _tutorial_fade_out()
				_DIALOGUE.show_dialogue("Deactivate the coin by clicking it or right clicking.")
				Global.tutorialState = Global.TutorialState.ROUND2_POWER_UNUSABLE
			return 
		elif Global.state == Global.State.CHARON_OBOL_FLIP: # if this is after the last chance flip, resolve payoff
			var charons_obol = _CHARON_COIN_ROW.get_child(0) as Coin
			_map_is_disabled = false
			match charons_obol.get_active_power_family():
				Global.CHARON_POWER_DEATH:
					await _wait_for_dialogue("Fate is cruel indeed.")
					await _wait_for_dialogue("It seems this is the end for you.")
					Global.state = Global.State.GAME_OVER
				Global.CHARON_POWER_LIFE:
					await _wait_for_dialogue("Fate smiles upon you...")
					await _wait_for_dialogue("You have dodged death, for a time.")
					await _wait_for_dialogue("But your journey has not yet concluded...")
					Global.lives = 0
					_on_end_round_button_pressed()
				_:
					assert(false, "Charon's obol has an incorrect power?")
			_COIN_ROW.expand()
			_CHARON_COIN_ROW.retract(_CHARON_NEW_COIN_POSITION)
			return
		else:
			# otherwise, this was a toss:
			for coin in _COIN_ROW.get_children():
				coin = coin as Coin
				coin.on_toss_complete()
			
			Global.tosses_this_round += 1
			Global.state = Global.State.AFTER_FLIP
			
			if Global.tutorialState == Global.TutorialState.ROUND1_FIRST_HEADS:
				_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(0)))
				await _tutorial_fade_in([_COIN_ROW])
				await _wait_for_dialogue(Global.replace_placeholders("Heads(HEADS)... how fortunate for you."))
				await _tutorial_fade_out()
				_LEFT_HAND.unpoint()
				_DIALOGUE.show_dialogue("You may accept your prize.")
				Global.tutorialState = Global.TutorialState.ROUND1_FIRST_HEADS_ACCEPTED
			elif Global.tutorialState == Global.TutorialState.ROUND1_FIRST_TAILS:
				_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(0)))
				await _tutorial_fade_in([_COIN_ROW])
				await _wait_for_dialogue(Global.replace_placeholders("Tails(TAILS)... unlucky."))
				await _tutorial_fade_out()
				_LEFT_HAND.unpoint()
				_DIALOGUE.show_dialogue("You must accept your fate.")
				Global.tutorialState = Global.TutorialState.ROUND1_FIRST_TAILS_ACCEPTED
			elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_INTRO:
				await _tutorial_fade_in([_COIN_ROW])
				await _wait_for_dialogue("Hmm...")
				_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(0)))
				await _wait_for_dialogue(Global.replace_placeholders("Your payoff coin has landed on tails(TAILS)..."))
				_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(1)))
				await _wait_for_dialogue(Global.replace_placeholders("But your power coin has landed on heads(HEADS)!"))
				await _wait_for_dialogue("You can use its power before accepting payoff.")
				await _tutorial_fade_out()
				_DIALOGUE.show_dialogue("Activate the power coin by clicking on it.")
				_LEFT_HAND.lock()
				_ACCEPT_TEXTBOX.disable()
				Global.tutorialState = Global.TutorialState.ROUND2_POWER_ACTIVATED
			elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE:
				_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(1)))
				await _tutorial_fade_in([_COIN_ROW])
				await _wait_for_dialogue("Unfortunate...")
				await _wait_for_dialogue(Global.replace_placeholders("Both coins landed on tails(TAILS)."))
				await _wait_for_dialogue(Global.replace_placeholders("A power can only activate if it lands on heads(HEADS)..."))
				await _tutorial_fade_out()
				_LEFT_HAND.unpoint()
				_DIALOGUE.show_dialogue("You have no choice but to accept this outcome.")
				Global.tutorialState = Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE
			elif Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
				_ACCEPT_TEXTBOX.disable()
				Global.tutorial_patron_passive_active = true
				await _tutorial_fade_in([_COIN_ROW, _patron_token])
				await _wait_for_dialogue("Hmm... that is a truly dismal turn of fortune.")
				await _wait_for_dialogue("I shall offer one last piece of assistance.")
				_patron_token.show()
				_patron_token.position = _CHARON_POINT
				var tween = create_tween()
				tween.tween_property(_patron_token, "position", _PATRON_TOKEN_POSITION, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
				await _wait_for_dialogue("Take this...")
				await _wait_for_dialogue("This is a patron token.")
				await _wait_for_dialogue("It calls upon the power of a higher being.")
				await _wait_for_dialogue("Patron tokens are always available.")
				await _wait_for_dialogue(Global.replace_placeholders("Tokens have both an activated power and a (PASSIVE)."))
				await _wait_for_dialogue(Global.replace_placeholders("For its (PASSIVE), which is always active..."))
				await _wait_for_dialogue(Global.replace_placeholders("If all your coins end on (HEADS), you'll earn an extra 5(SOULS)."))
				await _wait_for_dialogue(Global.replace_placeholders("And for its power..."))
				await _wait_for_dialogue(Global.replace_placeholders("This one turns a coin over and makes it (LUCKY)."))
				await _wait_for_dialogue("Try using the patron's power now.")
				await _tutorial_fade_out()
				Global.temporary_set_z(_LEFT_HAND, _COIN_ROW.z_index + 1) # make sure hand appears over coins
				_LEFT_HAND.point_at(_PATRON_TOKEN_POSITION + Vector2(22, 5)) # $hack$ this is hardcoded, whatever
				_LEFT_HAND.lock()
				_DIALOGUE.show_dialogue("Activate this token by clicking on it.")
				Global.tutorialState = Global.TutorialState.ROUND3_PATRON_ACTIVATED
			elif Global.tutorialState == Global.TutorialState.ROUND4_MONSTER_AFTER_TOSS:
				_LEFT_HAND.point_at(_hand_point_for_coin(_ENEMY_COIN_ROW.get_child(0)))
				_LEFT_HAND.lock()
				await _tutorial_fade_in([_ENEMY_COIN_ROW])
				await _wait_for_dialogue("The coin shows what it will do during payoff.")
				await _wait_for_dialogue("In this case...")
				if _ENEMY_COIN_ROW.get_child(0).is_heads():
					await _wait_for_dialogue(Global.replace_placeholders("It will make one of your coins (UNLUCKY)."))
				else:
					await _wait_for_dialogue(Global.replace_placeholders("It is going to deal damage to your (LIFE)."))
				await _wait_for_dialogue("As monsters are also coins, you may use your powers on them.")
				await _wait_for_dialogue("You can reflip a monster to manipulate its behavior, for example.")
				await _wait_for_dialogue("Lastly...")
				_ENEMY_COIN_ROW.get_child(0).show_price()
				await _wait_for_dialogue(Global.replace_placeholders("You may use souls(SOULS) to defeat monsters."))
				await _wait_for_dialogue("You may click on a monster to banish it.")
				await _tutorial_fade_out()
				_DIALOGUE.show_dialogue("Let's see how you fare against this new test!")
				_LEFT_HAND.unlock()
				_LEFT_HAND.unpoint()
				Global.tutorialState = Global.TutorialState.ROUND4_VOYAGE
			else:
				if _COIN_ROW.has_a_power_coin():
					_DIALOGUE.show_dialogue("Change your fate...")
				else:
					_DIALOGUE.show_dialogue("The coins fall...")
			_map_is_disabled = false
			_PLAYER_TEXTBOXES.make_visible()

func _on_turn_complete(turned_coin: Coin) -> void:
	_update_payoffs()
	_handle_tantalus(turned_coin)

# if tantalus is ever showing after a flip/turn, immediately turn to the other side and gain souls
func _handle_tantalus(coin: Coin) -> void:
	# and not here covers infinite case... we should just try to prevent this
	if coin.get_active_power_family() == Global.POWER_FAMILY_GAIN_SOULS_TANTALUS and not coin.get_inactive_power_family() == Global.POWER_FAMILY_GAIN_SOULS_TANTALUS:
		coin.play_power_used_effect(coin.get_active_power_family())
		_earn_souls(coin.get_active_souls_payoff())
		coin.turn()

func _on_toss_button_clicked() -> void:
	if Global.state == Global.State.CHARON_OBOL_FLIP:
		for coin in _CHARON_COIN_ROW.get_children():
			_safe_flip(coin, true)
		return
	
	if _COIN_ROW.get_child_count() == 0:
		_DIALOGUE.show_dialogue("No coins...")
		return
	
	# take life from player
	var ante = Global.ante_cost()
	
	# DEBUG - allow self kill
	# don't allow player to kill themselves here if continue isn't disabled (ie if this isn't a trial or nemesis round)
	if Global.lives < ante and not _END_ROUND_TEXTBOX.disabled: # and false: 
		_DIALOGUE.show_dialogue("Not enough life...")
		return
	
	Global.lives -= ante
	
	if Global.lives < 0:
		return
	
	_PLAYER_TEXTBOXES.make_invisible()
	_map_is_disabled = true
	if not Global.is_current_round_trial(): #obviously don't move trial coins up, we only want that for enemy coins
		_ENEMY_COIN_ROW.retract_for_toss(_CHARON_FLIP_POSITION)
	await _COIN_ROW.retract_for_toss(_PLAYER_FLIP_POSITION)
	_COIN_ROW.expand()
	_ENEMY_COIN_ROW.expand()
	
	# flip all the coins
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		coin = coin as Coin
		coin.on_toss_initiated()
		
		if Global.tutorialState == Global.TutorialState.ROUND1_FIRST_HEADS:
			_safe_flip(coin, true, 1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND1_FIRST_TAILS:
			_safe_flip(coin, true, -1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_INTRO or (Global.tutorialState == Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE and Global.tosses_this_round % 2 == 0):
			if coin.get_coin_family() == Global.ZEUS_FAMILY:
				_safe_flip(coin, true, 1000000)
			else:
				_safe_flip(coin, true, -1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE:
			_safe_flip(coin, true, -1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
			_safe_flip(coin, true, -1000000)
		else:
			_safe_flip(coin, true)

func _safe_flip(coin: Coin, is_toss: bool, bonus: int = 0) -> void:
	flips_pending += 1
	_map_is_disabled = true
	_PLAYER_TEXTBOXES.make_invisible()
	coin.flip(is_toss, bonus)

func _earn_souls(soul_amt: int) -> void:
	assert(soul_amt >= 0)
	if soul_amt == 0:
		return
	Global.souls += soul_amt
	Global.souls_earned_this_round += soul_amt

func _heal_life(heal_amt: int) -> void:
	assert(heal_amt >= 0)
	if heal_amt == 0:
		return
	Global.lives += heal_amt
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_DEMETER):
		_earn_souls(heal_amt)
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_DEMETER)

func _lose_souls(soul_amt: int) -> void: 
	assert(soul_amt >= 0)
	if soul_amt == 0:
		return
	Global.souls = max(0, Global.souls - soul_amt)
	Global.souls_earned_this_round -= soul_amt

func _on_accept_button_pressed():
	assert(Global.state == Global.State.AFTER_FLIP, "this shouldn't happen")
	_patron_token.deactivate()
	Global.active_coin_power_family = null
	Global.active_coin_power_coin = null
	Global.patron_used_this_toss = false
	
	_DIALOGUE.show_dialogue("Payoff...")
	_PLAYER_TEXTBOXES.make_invisible()
	_disable_interaction_coins_and_patron()
	
	for payoff_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		payoff_coin.before_payoff()
		
	var resolved_ignite = false
	# trigger payoffs
	for payoff_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		var payoff_power_family: Global.PowerFamily = payoff_coin.get_active_power_family()
		var charges = payoff_coin.get_active_power_charges()
		var row = payoff_coin.get_parent()
		var left = row.get_left_of(payoff_coin)
		var _right = row.get_right_of(payoff_coin)
		var is_last_player_coin = _COIN_ROW.get_child(_COIN_ROW.get_child_count()-1) == payoff_coin
		
		if payoff_power_family.is_payoff() and (not payoff_coin.is_stone() and not payoff_coin.is_blank()) and charges > 0:
			payoff_coin.payoff_move_up()
			var payoff_type = payoff_power_family.power_type
			
			payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
			match(payoff_type):
				Global.PowerType.PAYOFF_LOSE_LIFE:
					payoff_coin.FX.flash(Color.RED)
					if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_PAIN): # trial pain - 3x loss from tails penalties
						Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_PAIN)
						Global.lives -= charges * 3
					else:
						Global.lives -= charges
					
					# handle special payoff actions
					if payoff_power_family == Global.POWER_FAMILY_LOSE_LIFE_ACHILLES_HEEL:
						destroy_coin(payoff_coin)
					
				Global.PowerType.PAYOFF_HALVE_LIFE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					Global.lives -= int(Global.lives / 2.0)
				Global.PowerType.PAYOFF_GAIN_SOULS:
					var payoff = payoff_coin.get_active_souls_payoff()
					if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_LIMITATION): # limitation trial - min 10 souls per payoff coin
						Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_LIMITATION)
						payoff = 0 if payoff <= 10 else payoff
					if payoff > 0:
						payoff_coin.FX.flash(Color.AQUA)
						_earn_souls(payoff)
						Global.malice += Global.MALICE_INCREASE_ON_HEADS_PAYOFF * Global.current_round_malice_multiplier()
					
					# handle special payoff actions
					# helios - bless coin to the left and move to the left, if possible
					if payoff_power_family == Global.POWER_FAMILY_GAIN_SOULS_HELIOS and left:
						left.bless()
						row.swap_positions(payoff_coin, left)
					# icarus - if every coin is heads, destroy
					elif payoff_power_family == Global.POWER_FAMILY_GAIN_SOULS_ICARUS:
						if row.get_filtered(CoinRow.FILTER_HEADS).size() == row.get_child_count():
							payoff_coin.FX.flash(Color.YELLOW)
							destroy_coin(payoff_coin)
					# telemachus - after X tosses, transform
					elif payoff_power_family == Global.POWER_FAMILY_GAIN_SOULS_TELEMACHUS:
						payoff_coin.set_active_face_metadata(Coin.METADATA_TELEMACHUS, payoff_coin.get_active_face_metadata(Coin.METADATA_TELEMACHUS, 0) + 1)
						print(payoff_coin.get_active_face_metadata(Coin.METADATA_TELEMACHUS))
						if payoff_coin.get_active_face_metadata(Coin.METADATA_TELEMACHUS) >= Global.TELEMACHUS_TOSSES_TO_TRANSFORM:
							payoff_coin.init_coin(Global.random_power_coin_family_excluding(Global.TRANSFORM_OR_GAIN_EXCLUDE_COIN_FAMILIES), Global.Denomination.DRACHMA, payoff_coin.get_current_owner())
							payoff_coin.permanently_consecrate()
				Global.PowerType.PAYOFF_LOSE_SOULS:
					var payoff = payoff_coin.get_active_souls_payoff()
					payoff_coin.FX.flash(Color.DARK_BLUE)
					_lose_souls(payoff)
				Global.PowerType.PAYOFF_GAIN_ARROWS:
					payoff_coin.FX.flash(Color.GHOST_WHITE)
					Global.arrows = min(Global.arrows + charges, Global.ARROWS_LIMIT)
					_disable_interaction_coins_and_patron() # stupid bad hack to make the arrow not light up
				Global.PowerType.PAYOFF_LUCKY:
					payoff_coin.FX.flash(Color.GHOST_WHITE)
					for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_LUCKY), charges):
						target.make_lucky()
						target.play_power_used_effect(payoff_coin.get_active_power_family())
				Global.PowerType.PAYOFF_UNLUCKY:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_UNLUCKY), charges):
						target.make_unlucky()
						target.play_power_used_effect(payoff_coin.get_active_power_family())
				Global.PowerType.PAYOFF_CURSE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_CURSED), charges):
						target.curse()
						target.play_power_used_effect(payoff_coin.get_active_power_family())
				Global.PowerType.PAYOFF_BLANK:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_BLANK), charges):
						target.blank()
						target.play_power_used_effect(payoff_coin.get_active_power_family())
				Global.PowerType.PAYOFF_FREEZE_TAILS:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for coin in _COIN_ROW.get_tails():
						coin.freeze()
						coin.play_power_used_effect(payoff_coin.get_active_power_family())
				Global.PowerType.PAYOFF_STONE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_STONE), charges):
						target.stone()
						target.play_power_used_effect(payoff_coin.get_active_power_family())
				Global.PowerType.PAYOFF_IGNITE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_STONE), charges):
						target.ignite()
						target.play_power_used_effect(payoff_coin.get_active_power_family())
				Global.PowerType.PAYOFF_IGNITE_SELF:
					payoff_coin.ignite() #ignite itself
				Global.PowerType.PAYOFF_DOWNGRADE_MOST_VALUABLE:
					payoff_coin.FX.flash(Color.MEDIUM_PURPLE)
					for i in range(0, charges):
						var highest = _COIN_ROW.get_highest_valued()
						highest.shuffle()
						# don't downgrade if it's the last coin
						if highest[0].get_denomination() != Global.Denomination.OBOL or _COIN_ROW.get_child_count() != 1:
							highest[0].play_power_used_effect(payoff_coin.get_active_power_family())
							downgrade_coin(highest[0])
				_:
					assert(false, "No matching case for power type!")
				# END MATCH
			_update_payoffs()
			await Global.delay(0.15)
			if is_instance_valid(payoff_coin): # it may have been destroyed by now; ex Achilles/Icarus
				payoff_coin.payoff_move_down()
			await Global.delay(0.15)
			if Global.lives < 0:
				Global.payoffs_this_round += 1
				return
		
		# unblank when it would payoff
		if is_instance_valid(payoff_coin): # may have been destroyed by now
			payoff_coin.unblank()
		# doomed coins destroyed at this point
		if is_instance_valid(payoff_coin) and payoff_coin.is_doomed():
			payoff_coin.FX.flash(Color.BLACK)
			destroy_coin(payoff_coin)
		
		# $HACK$ - this is an extremely lazy way to make ignites happen
		# after all player coins but before all enemy coins, but I don't care
		# the idea here is that this condition is true for the very last player coin.
		# so in the time AFTER all player coins and BEFORE any enemy coins, we resolve ignites on all coins. 
		# THEN, enemies activate. This is basically as player friendly as possible.
		if not resolved_ignite and is_last_player_coin:
			# resolve ignites
			for possibly_ignited_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				if possibly_ignited_coin.is_ignited():
					possibly_ignited_coin.FX.flash(Color.RED)
					#possibly_ignited_coin.payoff_move_up()
					Global.lives -= 3
					_update_payoffs()
					await Global.delay(0.15)
					#possibly_ignited_coin.payoff_move_down()
					await Global.delay(0.15)
					if Global.lives < 0:
						Global.payoffs_this_round += 1
						return
			resolved_ignite = true
	
	# post payoff actions
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_TORTURE): # every payoff, downgrade highest value coin
		var coins = _COIN_ROW.get_highest_valued_heads()
		if not coins.is_empty():
			Global.choose_one(coins).downgrade()
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_TORTURE)
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_MISFORTUNE): # every payoff, unlucky coins
		_apply_misfortune_trial()
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_COLLAPSE): # collapse trial - each tails becomes cursed + frozen
		for coin in _COIN_ROW.get_children():
			if coin.is_tails():
				coin.curse()
				coin.freeze()
				Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_COLLAPSE)
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_OVERLOAD): # overload trial - lose 1 life per unused power charge
		for coin in _COIN_ROW.get_children():
			if coin.is_active_face_power():
				coin.FX.flash(Color.DARK_SLATE_BLUE)
				Global.lives -= coin.get_active_power_charges()
				Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_OVERLOAD)
	
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_CHARON) and Global.tutorial_patron_passive_active:
		if _COIN_ROW.get_filtered(CoinRow.FILTER_HEADS).size() == _COIN_ROW.get_child_count():
			if Global.tutorialState != Global.TutorialState.INACTIVE and not Global.tutorial_pointed_out_patron_passive:
				await _tutorial_fade_in([_COIN_ROW, _patron_token, _SOUL_FRAGMENTS, _SOUL_LABEL])
				await _wait_for_dialogue(Global.replace_placeholders("Ah, all your coins are heads(HEADS)!"))
				_LEFT_HAND.point_at(_PATRON_TOKEN_POSITION + Vector2(22, 5)) # $hack$ this is hardcoded, whatever
				_LEFT_HAND.lock()
				await _wait_for_dialogue(Global.replace_placeholders("Your patron has a passive bonus for that..."))
				_LEFT_HAND.unlock()
				_LEFT_HAND.unpoint()
			_earn_souls(5)
			if Global.tutorialState != Global.TutorialState.INACTIVE and not Global.tutorial_pointed_out_patron_passive:
				await _wait_for_dialogue(Global.replace_placeholders("You earn 5 extra souls(SOULS)."))
				await _wait_for_dialogue(Global.replace_placeholders("Well played."))
				await _tutorial_fade_out()
				Global.tutorial_pointed_out_patron_passive = true
	
	for payoff_coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		payoff_coin.after_payoff()
	Global.payoffs_this_round += 1
	_update_payoffs()
	
	
	if Global.tutorialState == Global.TutorialState.ROUND1_FIRST_HEADS_ACCEPTED:
		await _tutorial_fade_in([_LIFE_FRAGMENTS, _LIFE_LABEL])
		await _wait_for_dialogue("Now, let's move on to the next toss.")
		await _wait_for_dialogue("Each toss after the first demands a price...")
		await _wait_for_dialogue(Global.replace_placeholders("You must pay an Ante of %d(LIFE) for this toss." % Global.ante_cost()))
		await _wait_for_dialogue("Shall we try your luck again?")
		await _tutorial_fade_out()
		Global.tutorialState = Global.TutorialState.ROUND1_FIRST_TAILS
	elif Global.tutorialState == Global.TutorialState.ROUND1_FIRST_TAILS_ACCEPTED:
		await _tutorial_fade_in([_SOUL_FRAGMENTS, _LIFE_FRAGMENTS, _SOUL_LABEL, _LIFE_LABEL])
		await _wait_for_dialogue("Perhaps the next toss will be more fortunate?")
		await _wait_for_dialogue("You may toss as many times as you wish...")
		await _wait_for_dialogue(Global.replace_placeholders("...though the ante(LIFE) will continue to increase."))
		await _wait_for_dialogue(Global.replace_placeholders("Each toss, you may earn souls(SOULS), or lose life(LIFE)."))
		await _wait_for_dialogue(Global.replace_placeholders("Acquiring souls(SOULS) will help you later..."))
		await _wait_for_dialogue(Global.replace_placeholders("I advise tossing until you are low on life(LIFE)."))
		await _wait_for_dialogue("You may end the round whenever you are done.")
		await _tutorial_fade_out()
		Global.tutorialState = Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN
	
	# if malice is >= 95.0 before increase, go ahead and activate with a post-payoff malice effect.
	if Global.malice >= Global.MALICE_ACTIVATION_THRESHOLD_AFTER_TOSS:
		await activate_malice(MaliceActivation.AFTER_PAYOFF)
	else:
		# increase by 10 but cap at 95
		Global.malice = min(Global.MALICE_ACTIVATION_THRESHOLD_AFTER_TOSS,\
			Global.malice + (Global.MALICE_INCREASE_ON_TOSS_FINISHED * Global.current_round_malice_multiplier()))
	
	_enable_interaction_coins_and_patron()
	_enable_or_disable_end_round_textbox()
	_PLAYER_TEXTBOXES.make_visible()
	
	Global.state = Global.State.BEFORE_FLIP
	_DIALOGUE.show_dialogue("Will you toss the coins...?")

func _wait_for_dialogue(dialogue: String, minimum_delay: float = 0.0) -> void:
	_PLAYER_TEXTBOXES.make_invisible()
	await _DIALOGUE.show_dialogue_and_wait(dialogue, minimum_delay)
	_PLAYER_TEXTBOXES.make_visible()

const _MAP_ACTIVE_Z_INDEX = 2001
func _show_voyage_map(include_blocker: bool, closeable: bool) -> void:
	_PLAYER_TEXTBOXES.make_invisible()
	_disable_interaction_coins_and_patron()
	_VOYAGE_MAP.z_index = _MAP_ACTIVE_Z_INDEX # move on top of blocker
	_map_open = true
	Global.active_coin_power_coin = null
	Global.active_coin_power_family = null
	_patron_token.deactivate()
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
	_map_open = false
	_map_is_disabled = true
	var map_hide_tween = create_tween()
	map_hide_tween.parallel().tween_property(_VOYAGE_MAP, "position", _MAP_HIDDEN_POINT, 0.2) # tween position
	map_hide_tween.parallel().tween_property(_VOYAGE_MAP, "rotation_degrees", -90, 0.2)
	map_hide_tween.parallel().tween_property(_MAP_BLOCKER, "modulate:a", 0.0, 0.2)
	_MAP_BLOCKER.hide()
	_PLAYER_TEXTBOXES.make_visible()
	await map_hide_tween.finished
	_map_is_disabled = false
	_VOYAGE_MAP.z_index = 0
	_enable_interaction_coins_and_patron()

func _on_voyage_map_clicked():
	var no_map_states = [Global.TutorialState.ROUND2_POWER_USED, Global.TutorialState.ROUND2_POWER_UNUSABLE, Global.TutorialState.ROUND3_PATRON_USED]
	if Global.tutorialState in no_map_states:
		return
	if _map_is_disabled or _map_open or _tutorial_fading or _DIALOGUE.is_waiting():
		return
	_show_voyage_map(true, true)

func _on_voyage_map_closed():
	if _map_is_disabled or not _map_open:
		return
	_hide_voyage_map()

func connect_enemy_coins() -> void:
	for c in _ENEMY_COIN_ROW.get_children():
		var coin = c as Coin
		if not coin.flip_complete.is_connected(_on_flip_complete):
			coin.flip_complete.connect(_on_flip_complete)
		if not coin.turn_complete.is_connected(_on_turn_complete):
			coin.turn_complete.connect(_on_turn_complete)
		if not coin.clicked.is_connected(_on_coin_clicked):
			coin.clicked.connect(_on_coin_clicked)

func spawn_enemy(family: Global.CoinFamily, denom: Global.Denomination) -> void:
	_ENEMY_ROW.spawn_enemy(family, denom)
	connect_enemy_coins()

func _advance_round() -> void:
	Global.state = Global.State.VOYAGE
	_DIALOGUE.show_dialogue("Now let us sail...")
	_PLAYER_TEXTBOXES.make_invisible()
	await _show_voyage_map(true, false)
	await _VOYAGE_MAP.move_boat(Global.round_count)
	Global.round_count += 1
	
	# setup the enemy row
	_ENEMY_ROW.current_round_setup()
	connect_enemy_coins()
	
	if Global.tutorialState == Global.TutorialState.PROLOGUE_AFTER_BOARDING:
		await _wait_for_dialogue("We have quite the voyage ahead of us.")
		await _wait_for_dialogue("Perhaps we can pass the time with a little game?")
		_DIALOGUE.show_dialogue("I think you'll find it to be quite intriguing...")
		Global.tutorialState = Global.TutorialState.ROUND1_OBOL_INTRODUCTION
	elif Global.tutorialState == Global.TutorialState.ROUND4_VOYAGE:
		await _wait_for_dialogue("We still have a way to go...")
		await _wait_for_dialogue("Let me explain further your goal in this game.")
		await _wait_for_dialogue("The map shows what you must endure to win.")
		_PLAYER_TEXTBOXES.make_invisible() # necessary since wait for dialogue makes em visible...
		await _LEFT_HAND.move_offscreen()
		Global.temporary_set_z(_LEFT_HAND, _MAP_ACTIVE_Z_INDEX + 1)
		_LEFT_HAND.point_at(_VOYAGE_MAP.node_position(6) + Vector2(6, 5))
		await _wait_for_dialogue("Black dots are standard rounds...")
		await _wait_for_dialogue("So far, you've completed four standard rounds.")
		_LEFT_HAND.point_at(_VOYAGE_MAP.node_position(7) + Vector2(6, 3))
		await _wait_for_dialogue("Red dots are Trial rounds.")
		await _wait_for_dialogue("A trial presents additional challenges to overcome...")
		_DIALOGUE.show_dialogue("Mouse over the red icon to learn about the Trial...")
		_PLAYER_TEXTBOXES.make_invisible() # necessary since wait for dialogue makes em visible...
		await _VOYAGE_MAP.trial_hovered
		await _wait_for_dialogue("To pass a trial...")
		await _wait_for_dialogue(Global.replace_placeholders("You must earn a certain Quota of souls(SOULS) that round."))
		await _wait_for_dialogue("And if you fail, you will perish.")
		_LEFT_HAND.point_at(_VOYAGE_MAP.node_position(8) + Vector2(6, 1))
		await _wait_for_dialogue("Lastly, this is a Tollgate...")
		await _wait_for_dialogue(Global.replace_placeholders("To pass, you must pay a certain value(COIN) worth of coins."))
		await _wait_for_dialogue("If you cannot, you will perish.")
		_LEFT_HAND.set_appearance(CharonHand.Appearance.NORMAL)
		_PLAYER_TEXTBOXES.make_invisible()
		await _LEFT_HAND.move_offscreen()
		Global.restore_z(_LEFT_HAND)
		_LEFT_HAND.unpoint()
		await _wait_for_dialogue("To win my game...")
		await _wait_for_dialogue("You must pass all the trials...")
		await _wait_for_dialogue("And pay all the tolls.")
		await _wait_for_dialogue("I shall speak more about them upon arrival.")
		await _wait_for_dialogue("You may view the map during a round by clicking it.")
		_DIALOGUE.show_dialogue("For now, let's continue to the next normal round.")
		Global.tutorialState = Global.TutorialState.ROUND5_INTRO
	
	# first round - point at the trials and nemesis
	if Global.round_count == Global.FIRST_ROUND and Global.tutorialState == Global.TutorialState.INACTIVE and not Global.DEBUG_SKIP_INTRO:
		await _wait_for_dialogue("Take a moment to view our route...")
		_DIALOGUE.show_dialogue("Observe the challenges which lie ahead.")
		_PLAYER_TEXTBOXES.make_invisible() # hide while moving hand...
		await _LEFT_HAND.move_offscreen()
		Global.temporary_set_z(_LEFT_HAND, _MAP_ACTIVE_Z_INDEX + 1)
		UITooltip.disable_automatic_tooltips()
		# point at trials in order...
		var i = 1
		for rnd in Global.VOYAGE:
			if rnd.roundType == Global.RoundType.TRIAL1 or rnd.roundType == Global.RoundType.TRIAL2 or rnd.roundType == Global.RoundType.NEMESIS:
				_PLAYER_TEXTBOXES.make_invisible() # hide while moving hand...
				
				# helper lambda
				var show_tooltip_and_wait = func(tooltip_string, tooltip_pos) -> void:
					var tooltip = UITooltip.create_manual(tooltip_string, tooltip_pos, get_tree().root)
					await Global.delay(0.1)
					await Global.left_click_input
					tooltip.destroy_tooltip()
				
				if Global.is_difficulty_active(Global.Difficulty.CRUEL3) and (rnd.roundType == Global.RoundType.TRIAL1 or rnd.roundType == Global.RoundType.TRIAL2):
					await _LEFT_HAND.point_at(_VOYAGE_MAP.node_position(i) + Vector2(3, -2)) # point at upper
					await show_tooltip_and_wait.call(_VOYAGE_MAP.node_tooltip_strings(i)[0], _VOYAGE_MAP.node_position(i) + Vector2(6, 4))
					_PLAYER_TEXTBOXES.make_invisible() # hide while moving hand...
					await _LEFT_HAND.point_at(_VOYAGE_MAP.node_position(i) + Vector2(8, 5)) # point at lower
					await show_tooltip_and_wait.call(_VOYAGE_MAP.node_tooltip_strings(i)[1], _VOYAGE_MAP.node_position(i) + Vector2(6, 4))
				else:
					await _LEFT_HAND.point_at(_VOYAGE_MAP.node_position(i) + Vector2(6, 3))
					await show_tooltip_and_wait.call(_VOYAGE_MAP.node_tooltip_strings(i)[0], _VOYAGE_MAP.node_position(i) + Vector2(6, 4))
			i += 1
		_PLAYER_TEXTBOXES.make_invisible()
		await _LEFT_HAND.move_offscreen()
		UITooltip.enable_all_tooltips()
		Global.restore_z(_LEFT_HAND)
		_LEFT_HAND.unpoint()
		_DIALOGUE.show_dialogue("Are you ready to begin?")
	
	if Global.did_ante_increase():
		await _wait_for_dialogue("The river is deepening...")
		river_color_index = min(river_color_index + 1, _RIVER_COLORS.size() - 1)
		_recolor_river(_RIVER_COLORS[river_color_index], false)
		_DIALOGUE.show_dialogue("Let's raise the Ante...") 
	if Global.is_current_round_end():
		_VOYAGE_NEXT_ROUND_TEXTBOX.set_text("Continue")
	else:
		_VOYAGE_NEXT_ROUND_TEXTBOX.set_text("Begin %d%s Round" % [Global.round_count - 1, Global.ordinal_suffix(Global.round_count - 1)])
	_PLAYER_TEXTBOXES.make_visible()

func _recolor_river(colorStyle: River.ColorStyle, instant: bool) -> void:
	_RIVER_LEFT.change_color(colorStyle, instant)
	_RIVER_RIGHT.change_color(colorStyle, instant)
	_VOYAGE_MAP.change_river_color(colorStyle, instant)
	
	match colorStyle: # also recolor the particles
		River.ColorStyle.PURPLE:
			create_tween().tween_property(_EMBERS_PARTICLES, "modulate", Color("#bc4a9b"), 0.5)
			create_tween().tween_property(_TRIAL_EMBERS_PARTICLES, "modulate", Color("#bc4a9b"), 0.5)
		River.ColorStyle.GREEN:
			create_tween().tween_property(_EMBERS_PARTICLES, "modulate", Color("#cdf7e2"), 0.5)
			create_tween().tween_property(_TRIAL_EMBERS_PARTICLES, "modulate", Color("#cdf7e2"), 0.5)
		River.ColorStyle.RED:
			create_tween().tween_property(_EMBERS_PARTICLES, "modulate", Color("#df3e23"), 0.5)
			create_tween().tween_property(_TRIAL_EMBERS_PARTICLES, "modulate", Color("#df3e23"), 0.5)

func _on_board_button_clicked():
	assert(Global.state == Global.State.BOARDING)
	_advance_round()

func _on_continue_button_pressed():
	assert(Global.state == Global.State.SHOP)
	_RIGHT_HAND.move_to_default_position()
	_LEFT_HAND.move_to_default_position()
	_LEFT_HAND.set_appearance(CharonHand.Appearance.NORMAL)
	
	var no_lose_souls_states = [Global.TutorialState.ROUND2_POWER_INTRO]
	if not Global.tutorialState in no_lose_souls_states:
		if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
			_SHOP_COIN_ROW.retract(_CHARON_NEW_COIN_POSITION)
			await _tutorial_fade_in([_SOUL_FRAGMENTS, _SOUL_LABEL, _LIFE_FRAGMENTS, _LIFE_LABEL])
			await _wait_for_dialogue(Global.replace_placeholders("As stated, I will take your remaining souls(SOULS)..."))
			if Global.souls == 0:
				await _wait_for_dialogue(Global.replace_placeholders("Ah, you've spent them all."))
				await _wait_for_dialogue(Global.replace_placeholders("Cleverly done."))
		
		var pity_life = 0
		if not (Global.is_passive_active(Global.PATRON_POWER_FAMILY_HADES) and not Global.is_next_round_nemesis()):
			pity_life = ceil(Global.souls / SOUL_TO_LIFE_CONVERSION_RATE)
			Global.souls = 0
		elif Global.souls > 0:
			Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_HADES)
		
		if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
			if pity_life == 0:
				await _wait_for_dialogue(Global.replace_placeholders("If you had happened to have any leftover souls(SOULS)..."))
				await _wait_for_dialogue(Global.replace_placeholders("I would have given you a pittance of (HEAL) in exchange."))
			else:
				await _wait_for_dialogue(Global.replace_placeholders("And give you a pittance of (HEAL) in exchange..."))
			await _wait_for_dialogue(Global.replace_placeholders("Not a great exchange for you..."))
			await _wait_for_dialogue(Global.replace_placeholders("But better than nothing."))
		_heal_life(pity_life)

		if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
			await _wait_for_dialogue(Global.replace_placeholders("Let's continue onwards."))
			await _tutorial_fade_out()

	await _advance_round()

func _on_end_round_button_pressed():
	assert(Global.state == Global.State.BEFORE_FLIP or Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.CHARON_OBOL_FLIP)
	_PLAYER_TEXTBOXES.make_invisible()
	_enable_interaction_coins_and_patron()
	for coin in _COIN_ROW.get_children():
		coin.on_round_end()
	
	# reduce accumulated malice significantly (mult by 0.3)
	Global.malice *= Global.MALICE_MULTIPLIER_END_ROUND
	
	# First round skip + pity - advanced players may skip round 1 for base 20 souls; unlucky players are brought to 20
	var first_round = Global.round_count == Global.FIRST_ROUND
	const bad_luck_souls_first_round = 15
	const average_souls = 17
	if Global.tutorialState == Global.TutorialState.INACTIVE and first_round and Global.souls < bad_luck_souls_first_round and (Global.tosses_this_round == 0 or Global.tosses_this_round >= 7):
		var souls_awarded = 0
		if Global.tosses_this_round == 0:
			await _wait_for_dialogue("Refusal to play is not an option!")
			souls_awarded = average_souls
		else:
			await _wait_for_dialogue(Global.replace_placeholders("Only %d(SOULS)...?" % Global.souls))
			await _wait_for_dialogue("You are a rather misfortunate one.")
			await _wait_for_dialogue("We wouldn't want the game ending prematurely...")
			await _wait_for_dialogue("This time, I will take pity on you.")
			souls_awarded = bad_luck_souls_first_round
		Global.souls = souls_awarded
		await _wait_for_dialogue("Take these...")
		Global.lives = 0
		await _wait_for_dialogue("And I'll take those...")
		await _wait_for_dialogue("Now us continue.")
	
	# if we just won by defeating the nemesis
	if Global.current_round_type() == Global.RoundType.NEMESIS:
		await _wait_for_dialogue("So, you have triumphed.")
		await _wait_for_dialogue("This outcome is most surprising.")
		await _wait_for_dialogue("And it seems our voyage is nearing its end...")
		_advance_round()
		return
	
	Global.powers_this_round = 0
	Global.tosses_this_round = 0
	Global.ante_modifier_this_round = 0
	Global.souls_earned_this_round = 0
	Global.monsters_destroyed_this_round = 0
	Global.powers_this_round = 0
	_update_payoffs()
	
	Global.state = Global.State.SHOP
	randomize_and_show_shop()
	
	_RIGHT_HAND.move_offscreen()
	_LEFT_HAND.move_to_retracted_position()
	
	if Global.tutorialState == Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN:
		_LEFT_HAND.set_appearance(CharonHand.Appearance.NORMAL)
		_LEFT_HAND.lock()
		_SHOP_COIN_ROW.get_child(0).hide_price()
		await _tutorial_fade_in([_SHOP_COIN_ROW, _SOUL_FRAGMENTS, _SOUL_LABEL])
		await _wait_for_dialogue("Now we move to the next part of the game...")
		await _wait_for_dialogue("This is the Shop.")
		await _wait_for_dialogue("Between each round of tosses...")
		await _wait_for_dialogue("You may [color=white]purchase new coins[/color] here.")
		await _wait_for_dialogue(Global.replace_placeholders("I shall accept souls(SOULS) in exchange."))
		await _wait_for_dialogue("Let me show you a new type of coin...")
		_LEFT_HAND.unlock()
		_LEFT_HAND.point_at(_hand_point_for_coin(_SHOP_COIN_ROW.get_child(0)))
		_LEFT_HAND.lock()
		await _wait_for_dialogue("This is a Power Coin.")
		await _wait_for_dialogue("These coins can manipulate fate.")
		await _wait_for_dialogue("Currently, you have a single Payoff Coin.")
		await _wait_for_dialogue(Global.replace_placeholders("If it is on tails(TAILS), there is nothing to be done."))
		await _wait_for_dialogue("Using powers allows you to change that.")
		var icon = _SHOP_COIN_ROW.get_child(0).get_heads_icon()
		await _wait_for_dialogue("This particular power,[img=10x13]%s[/img], can reflip other coins." % icon)
		_SHOP_COIN_ROW.get_child(0).show_price()
		await _wait_for_dialogue(Global.replace_placeholders("The coin's price of %d souls(SOULS) is shown above it." % _SHOP_COIN_ROW.get_child(0).get_store_price()))
		if Global.souls < _SHOP_COIN_ROW.get_child(0).get_store_price():
			await _wait_for_dialogue("...Ah, you don't have enough souls for this coin.")
			Global.souls = _SHOP_COIN_ROW.get_child(0).get_store_price()
			await _wait_for_dialogue("Just this time, take these...")
		await _tutorial_fade_out()
		_DIALOGUE.show_dialogue("Purchase this coin by clicking on it.")
		Global.tutorialState = Global.TutorialState.ROUND1_SHOP_AFTER_BUYING_COIN
		_SHOP_CONTINUE_TEXTBOX.disable()
	elif Global.tutorialState == Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE:
		_SHOP_CONTINUE_TEXTBOX.disable()
		_LEFT_HAND.lock()
		_COIN_ROW.get_child(0).hide_price()
		_COIN_ROW.get_child(1).hide_price()
		await _tutorial_fade_in([_COIN_ROW, _SOUL_FRAGMENTS, _SOUL_LABEL])
		await _wait_for_dialogue("We return to the shop once more.")
		await _wait_for_dialogue("In addition to purchasing new coins...")
		await _wait_for_dialogue("You can also upgrade your current coins.")
		_COIN_ROW.get_child(0).show_price()
		_COIN_ROW.get_child(1).show_price()
		await _wait_for_dialogue("The upgrade's price is shown above the coin.")
		var upgrade_price = _COIN_ROW.get_child(0).get_upgrade_price()
		if Global.souls < upgrade_price:
			await _wait_for_dialogue("Hmm...")
			await _wait_for_dialogue("You don't have enough souls to upgrade a coin.")
			Global.souls = upgrade_price
			await _wait_for_dialogue("Take these.")
		await _tutorial_fade_out()
		_DIALOGUE.show_dialogue("Upgrade this coin by clicking on it.")
		_LEFT_HAND.unlock()
		_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(0)))
		_LEFT_HAND.lock()
		Global.tutorialState = Global.TutorialState.ROUND2_SHOP_AFTER_UPGRADE
	elif Global.tutorialState == Global.TutorialState.ROUND6_TRIAL_COMPLETED:
		await _tutorial_fade_in()
		await _wait_for_dialogue("You have completed the trial!")
		await _wait_for_dialogue("It seems you have become quite proficient.")
		await _wait_for_dialogue("The only challenge left is the tollgate...")
		await _tutorial_fade_out()
		_DIALOGUE.show_dialogue("Spend your earnings before we proceed.")
		Global.tutorialState = Global.TutorialState.ROUND7_TOLLGATE_INTRO
	else:
		_DIALOGUE.show_dialogue("Buying or upgrading...?")
	_PLAYER_TEXTBOXES.make_visible()

func _hand_point_for_coin(coin: Coin) -> Vector2:
	return coin.global_position + Vector2(20, 0)

func _on_coin_hovered(coin: Coin) -> void:
	# hovering coin in shop updates mouse cursor, and if shop coin, charon points
	if not _map_open and Global.state == Global.State.SHOP:
		if coin.is_owned_by_player():
			Global.set_custom_mouse_cursor_to_icon("res://assets/icons/ui/sell.png" if Global.is_character(Global.Character.MERCHANT) else "res://assets/icons/ui/upgrade.png")
		else:
			Global.set_custom_mouse_cursor_to_icon("res://assets/icons/ui/buy.png")
			_LEFT_HAND.point_at(_hand_point_for_coin(coin))

func _on_coin_unhovered(coin: Coin) -> void:
	if Global.state == Global.State.SHOP:
		Global.clear_custom_mouse_cursor()
		if not coin.is_owned_by_player(): #if shop coin
			_LEFT_HAND.move_to_retracted_position()

func _toll_price_remaining() -> int:
	return max(0, Global.current_round_toll() - Global.calculate_toll_coin_value())

func _show_toll_dialogue() -> void:
	var toll_price_remaining = _toll_price_remaining()
	if toll_price_remaining == 0:
		_DIALOGUE.show_dialogue("Good...")
	else:
		_DIALOGUE.show_dialogue(Global.replace_placeholders("%d(COIN) more..." % toll_price_remaining))

func _apply_misfortune_trial() -> void:
	for i in Global.MISFORTUNE_QUANTITY:
		var targets = _COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_UNLUCKY)
		if targets.size() != 0:
			targets[0].make_unlucky()
	Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_MISFORTUNE)

func _on_voyage_continue_button_clicked():
	_hide_voyage_map()
	_PLAYER_TEXTBOXES.make_invisible()
	await Global.delay(0.1)
	var first_round = Global.round_count == Global.FIRST_ROUND
	
	# if this is the first round, give an obol
	if first_round:
		if Global.tutorialState != Global.TutorialState.ROUND1_OBOL_INTRODUCTION:
			await _wait_for_dialogue("Place your payment on the table...")
			_make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, _PLAYER_NEW_COIN_POSITION) # make a single starting coin
		
			# removed, but kept potentially for later - generate a random bonus starting coin from patron
			#_make_and_gain_coin(Global.patron.get_random_starting_coin_family(), Global.Denomination.OBOL)
	
	# if we won...
	if Global.current_round_type() == Global.RoundType.END:
		victory = true
		Global.state = Global.State.GAME_OVER
		return
	# if there's a toll...
	if Global.current_round_type() == Global.RoundType.TOLLGATE:
		Global.state = Global.State.TOLLGATE
		
		if Global.tutorialState == Global.TutorialState.ROUND7_TOLLGATE_INTRO:
			await _tutorial_fade_in([_COIN_ROW])
			await _wait_for_dialogue("We have reached a tollgate...")
			await _wait_for_dialogue(Global.replace_placeholders("To pass, you must pay %d(COIN)." % Global.current_round_toll()))
			await _wait_for_dialogue(Global.replace_placeholders("Obols are worth 1(COIN), Diobols 2(COIN)..."))
			await _wait_for_dialogue(Global.replace_placeholders("Triobols are worth 3(COIN), and Tetrobols 4(COIN)."))
			await _tutorial_fade_out()
			_DIALOGUE.show_dialogue("Add a coin to your payment by clicking it.")
			Global.tutorialState = Global.TutorialState.ENDING
		else:
			if Global.toll_index == 0:
				await _wait_for_dialogue("First tollgate...")
			await _wait_for_dialogue(Global.replace_placeholders("You must pay %d(COIN)..." % Global.current_round_toll()))
			_show_toll_dialogue()
		return
	
	if Global.tutorialState == Global.TutorialState.ROUND1_OBOL_INTRODUCTION:
		_PLAYER_TEXTBOXES.make_invisible()
		await _tutorial_fade_in([_COIN_ROW, _SOUL_FRAGMENTS, _SOUL_LABEL, _LIFE_FRAGMENTS, _LIFE_LABEL])
		await _wait_for_dialogue("Let's begin.")
		await _wait_for_dialogue("The rules are simple.")
		var coin = _make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, _CHARON_NEW_COIN_POSITION) # make a single starting coin
		_tutorial_show(coin)
		await _wait_for_dialogue("Take this Coin...")
		await _wait_for_dialogue("This is a game about tossing Coins.")
		await _wait_for_dialogue("Each Round will consist of multiple Tosses.")
		_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(0)))
		var souls_earned = _COIN_ROW.get_child(0).get_active_power_charges()
		Global.souls += souls_earned
		_SOUL_LABEL.fade_in()
		await _wait_for_dialogue(Global.replace_placeholders("If the coin lands on Heads(HEADS), you earn +%d Souls(SOULS)." % souls_earned))
		_COIN_ROW.get_child(0).turn()
		Global.souls -= souls_earned
		var life_loss = _COIN_ROW.get_child(0).get_active_power_charges()
		Global.lives += life_loss
		_LIFE_LABEL.fade_in()
		await _wait_for_dialogue(Global.replace_placeholders("If it [color=white]lands on Tails(TAILS), you lose %d Life(LIFE)[/color]." % life_loss))
		Global.lives += Global.current_round_life_regen() - life_loss
		_LEFT_HAND.unpoint()
		_COIN_ROW.get_child(0).turn()
		await _wait_for_dialogue(Global.replace_placeholders("Each round, you will gain 100 Life(HEAL)."))
		await _wait_for_dialogue("To win, survive until the end of the Voyage.")
		await _wait_for_dialogue(Global.replace_placeholders("Earning Souls(SOULS) will help you do this."))
		await _wait_for_dialogue(Global.replace_placeholders("But, if you ever run out of Life(LIFE)..."))
		await _wait_for_dialogue("Then I am the victor.")
		await _wait_for_dialogue("Why don't you give it a try?")
		await _tutorial_fade_out()
		Global.tutorialState = Global.TutorialState.ROUND1_FIRST_HEADS
	else:
		if Global.tutorialState != Global.TutorialState.INACTIVE and Global.tutorialState != Global.TutorialState.ROUND1_FIRST_HEADS:
			await _tutorial_fade_in([_LIFE_FRAGMENTS, _LIFE_LABEL, _ENEMY_COIN_ROW])
		await _wait_for_dialogue("...take a deep breath...")
		# refresh lives
		if not Global.is_passive_active(Global.TRIAL_POWER_FAMILY_FAMINE): # famine trial prevents life regen
			Global.lives += Global.current_round_life_regen()
		else:
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_FAMINE)
		
		if Global.current_round_type() == Global.RoundType.NEMESIS: # nemesis - regen an additional 100
			await _wait_for_dialogue("...and steel your nerves...")
			Global.lives += Global.current_round_life_regen()
	
	# refresh patron powers
	Global.patron_uses = Global.patron.get_uses_per_round()
		
	if first_round and not Global.tutorialState == Global.TutorialState.ROUND1_FIRST_HEADS:
		await _wait_for_dialogue("...Let's begin the game...")
	elif Global.current_round_type() == Global.RoundType.TRIAL1 or Global.current_round_type() == Global.RoundType.TRIAL2:
		await _wait_for_dialogue("Your trial begins...")
	elif Global.tutorialState == Global.TutorialState.ROUND2_INTRO:
		await _wait_for_dialogue("As I mentioned before...")
		await _wait_for_dialogue(Global.replace_placeholders("At the start of each round, you gain 100(HEAL)."))
		await _wait_for_dialogue("Additionally, the Ante has been reset to 0.")
		await _wait_for_dialogue("Now let's begin the second round.")
		await _tutorial_fade_out()
		Global.tutorialState = Global.TutorialState.ROUND2_POWER_INTRO
	elif Global.tutorialState == Global.TutorialState.ROUND3_INTRO:
		await _wait_for_dialogue("Are you getting the hang of this?")
		await _wait_for_dialogue("Let the third round begin!")
		await _tutorial_fade_out()
		Global.tutorialState = Global.TutorialState.ROUND3_PATRON_INTRO
	elif Global.tutorialState == Global.TutorialState.ROUND4_MONSTER_INTRO:
		_ENEMY_COIN_ROW.get_child(0).hide_price()
		await _wait_for_dialogue("Allow me to introduce an additional challenge.") # shown by setting state to BEFORE_FLIP below
	elif Global.tutorialState == Global.TutorialState.ROUND5_INTRO:
		await _wait_for_dialogue("This round...")
		await _wait_for_dialogue("I have no further guidance for you.")
		await _wait_for_dialogue("Show me what you have learned!")
		await _tutorial_fade_out()
		Global.tutorialState = Global.TutorialState.ROUND6_TRIAL_INTRO
	elif Global.tutorialState == Global.TutorialState.ROUND6_TRIAL_INTRO and Global.is_current_round_trial():
		await _wait_for_dialogue("We have reached a Trial...")
		
	Global.state = Global.State.BEFORE_FLIP #shows trial row
	_PLAYER_TEXTBOXES.make_invisible()
	
	if Global.tutorialState == Global.TutorialState.ROUND4_MONSTER_INTRO:
		await Global.delay(Global.COIN_TWEEN_TIME)
		_LEFT_HAND.point_at(_hand_point_for_coin(_ENEMY_COIN_ROW.get_child(0)))
		_LEFT_HAND.lock()
		await _wait_for_dialogue("This is a Monster Coin.")
		await _wait_for_dialogue("Each time you toss your coins...")
		await _wait_for_dialogue("I will toss the monsters as well.")
		await _wait_for_dialogue("And during each payoff...")
		await _wait_for_dialogue("They will activate, and hinder you.")
		await _wait_for_dialogue("Go ahead and toss, so I may show you.")
		await _tutorial_fade_out()
		_LEFT_HAND.unlock()
		_LEFT_HAND.unpoint()
		Global.tutorialState = Global.TutorialState.ROUND4_MONSTER_AFTER_TOSS
	elif Global.tutorialState == Global.TutorialState.ROUND6_TRIAL_INTRO and Global.is_current_round_trial():
		await _wait_for_dialogue("Behold!")
		_PLAYER_TEXTBOXES.make_invisible() # clumsy that we have to do this...; otherwise the boxes are visible for a split second as the coin rises
	
	if Global.current_round_type() == Global.RoundType.NEMESIS:
		for coin in _ENEMY_COIN_ROW.get_children():
			coin.hide_price() # bit of a $HACK$ to prevent nemesis price from being shown...
	
	# activate trial modifiers
	for coin in _ENEMY_COIN_ROW.get_children():
		if coin.is_trial_coin():
			match coin.get_coin_family():
				Global.TRIAL_IRON_FAMILY:
					while _COIN_ROW.get_child_count() > Global.COIN_LIMIT-2: # make space for thorns obols
						destroy_coin(_COIN_ROW.get_rightmost_to_leftmost()[0])
					_make_and_gain_coin(Global.THORNS_FAMILY, Global.Denomination.OBOL, _CHARON_NEW_COIN_POSITION)
					_make_and_gain_coin(Global.THORNS_FAMILY, Global.Denomination.OBOL, _CHARON_NEW_COIN_POSITION)
					await _wait_for_dialogue("You shall be bound in Iron!")
				Global.TRIAL_MISFORTUNE_FAMILY:
					#_apply_misfortune_trial() # note - removed the initial application, for balance for now at least
					await _wait_for_dialogue("You shall be shrouded in Misfortune!")
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
	
	if Global.tutorialState == Global.TutorialState.ROUND6_TRIAL_INTRO and Global.is_current_round_trial():
		_LEFT_HAND.point_at(_hand_point_for_coin(_ENEMY_COIN_ROW.get_child(0)))
		_LEFT_HAND.lock()
		await _wait_for_dialogue("During a trial, an additional challenge is active.")
		await _wait_for_dialogue(Global.replace_placeholders("For this trial, life(LIFE) penalties are tripled."))
		await _wait_for_dialogue(Global.replace_placeholders("To proceed, you must earn at least %s souls(SOULS)." % Global.current_round_quota()))
		_LEFT_HAND.unlock()
		_LEFT_HAND.unpoint()
		await _wait_for_dialogue("Now, your final test begins!")
		await _tutorial_fade_out()
		Global.tutorialState = Global.TutorialState.ROUND6_TRIAL_COMPLETED
	
	# Nemesis introduction
	if Global.current_round_type() == Global.RoundType.NEMESIS:
		await _wait_for_dialogue("We have arrived at your final challenge...")
		
		for coin in _ENEMY_COIN_ROW.get_children():
			match coin.get_coin_family():
				Global.MEDUSA_FAMILY:
					await _wait_for_dialogue("Behold! The grim visage of the Gorgon Sisters!")
		
		await _wait_for_dialogue("To continue your voyage...")
		await _wait_for_dialogue("You must defeat the gatekeeper!")
		await _wait_for_dialogue("Your fate lies with the coins now.")
		await _wait_for_dialogue("Let the final challenge commence!")
	
	if Global.current_round_type() == Global.RoundType.NEMESIS:
		for coin in _ENEMY_COIN_ROW.get_children():
			coin.show_price() # bit of a $HACK$ to prevent nemesis price from being shown... reshow now
	
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ARTEMIS) and Global.arrows != Global.ARROWS_LIMIT:
		Global.arrows = min(Global.ARROWS_LIMIT, Global.arrows + 3)
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_ARTEMIS)
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_APHRODITE):
		var randomized = _COIN_ROW.get_randomized()
		for i in range(0, randomized.size(), 2):
			randomized[i].bless()
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_APHRODITE)
	
	_enable_or_disable_end_round_textbox()
	_PLAYER_TEXTBOXES.make_visible()
	_DIALOGUE.show_dialogue("Will you toss...?")

func _enable_or_disable_end_round_textbox() -> void:
	var tutorial_disabled_states = [
		Global.TutorialState.ROUND1_FIRST_HEADS, # waiting for first toss
		Global.TutorialState.ROUND1_FIRST_TAILS, # waiting for second toss
		Global.TutorialState.ROUND2_POWER_INTRO, # need a toss to explain powers
		Global.TutorialState.ROUND2_POWER_UNUSABLE, # need a second toss to explain powers only on heads
		Global.TutorialState.ROUND3_PATRON_INTRO, # need a toss to explain patrons
		Global.TutorialState.ROUND4_MONSTER_AFTER_TOSS] # need a toss to explain monsters
	var first_round = Global.round_count == Global.FIRST_ROUND
	var first_toss_of_round = Global.tosses_this_round == 0
	var disable_textbox = (not first_round and first_toss_of_round and not Global.DEBUG_DONT_FORCE_FIRST_TOSS) or Global.current_round_type() == Global.RoundType.NEMESIS or (Global.souls_earned_this_round < Global.current_round_quota()) or tutorial_disabled_states.has(Global.tutorialState)
	_END_ROUND_TEXTBOX.disable() if disable_textbox else _END_ROUND_TEXTBOX.enable()

var victory = false
func _on_pay_toll_button_clicked():
	if _toll_price_remaining() == 0:
		
		var overpay = Global.current_round_toll() - Global.calculate_toll_coin_value()
		# delete each of the coins used to pay the toll
		for coin in Global.toll_coins_offered:
			destroy_coin(coin)
		Global.toll_coins_offered.clear()
		
		# advance the toll
		Global.toll_index += 1
		
		await _wait_for_dialogue("The toll is paid.")
		
		# todo - if I ever add tartarus, this probably needs more elegant handling just for robustness
		# don't die if the game ended on a tollgate AND we ran out of coins 
		# (paid the final toll with nothing left is a victory)
		if _COIN_ROW.get_child_count() == 0 and not Global.is_next_round_end():
			await _wait_for_dialogue("...Ah, no more coins?")
			await _wait_for_dialogue("...So you've lost the game...")
			await _wait_for_dialogue("A shame. Goodbye.")
			_on_die_button_clicked()
			return
		
		if overpay != 0:
			pass #we might do something here someday... or maybe not
		
		# now move the boat forward...
		_advance_round()
	else:
		_DIALOGUE.show_dialogue("Not enough...")

func _on_die_button_clicked() -> void:
	if Global.tutorialState == Global.TutorialState.ENDING:
		if _COIN_ROW.calculate_total_value() < Global.current_round_toll():
			Global.clear_toll_coins()
			await _tutorial_fade_in([_COIN_ROW])
			await _wait_for_dialogue("Ah... you don't have enough to pay the toll.")
			while _COIN_ROW.get_child_count() < Global.COIN_LIMIT and _COIN_ROW.calculate_total_value() < Global.current_round_toll():
				var coin = _make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.TETROBOL, _CHARON_NEW_COIN_POSITION)
				_tutorial_show(coin)
			assert(_COIN_ROW.calculate_total_value() >= Global.current_round_toll())
			await _wait_for_dialogue("Here...")
			await _tutorial_fade_out()
			_DIALOGUE.show_dialogue("Now pay the toll.")
			return
		else:
			await _tutorial_fade_in([_COIN_ROW])
			await _wait_for_dialogue("Is this in jest?")
			await _wait_for_dialogue("You have enough coins.")
			await _tutorial_fade_out()
			_DIALOGUE.show_dialogue("So pay the toll.")
			return
	
	Global.state = Global.State.GAME_OVER

func _on_shop_coin_purchased(coin: Coin, price: int):
	# prevent buying coin before tutorial is ready
	# and during upgrade sequence...
	var no_buy_states = [Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN, Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE, Global.TutorialState.ROUND2_SHOP_AFTER_UPGRADE]
	if Global.tutorialState in no_buy_states:
		if Global.tutorialState == Global.TutorialState.ROUND2_SHOP_AFTER_UPGRADE:
			_DIALOGUE.show_dialogue("Click this coin.")
			return
		return
	
	# make sure we can afford this coin
	if Global.souls < price:
		_DIALOGUE.show_dialogue("Not enough souls...")
		return 
	
	if _COIN_ROW.get_child_count() == Global.COIN_LIMIT:
		_DIALOGUE.show_dialogue("Too many coins...")
		return
	
	# disconnect charon hand signals
	coin.hovered.disconnect(_on_coin_hovered)
	coin.unhovered.disconnect(_on_coin_unhovered)
	_on_coin_unhovered(coin)
	
	_gain_coin_from_shop(coin) # move coin to player row
	_SHOP.purchase_coin(coin) # charge the shop
	
	if Global.tutorialState == Global.TutorialState.ROUND1_SHOP_AFTER_BUYING_COIN:
		_LEFT_HAND.unlock()
		_LEFT_HAND.unpoint()
		_DIALOGUE.show_dialogue("Excellent. Exit the shop to proceed to the next round.")
		_SHOP_CONTINUE_TEXTBOX.enable()
		Global.tutorialState = Global.TutorialState.ROUND2_INTRO

func _make_and_gain_coin(coin_family: Global.CoinFamily, denomination: Global.Denomination, initial_position: Vector2, during_round: bool = false) -> Coin:
	var new_coin: Coin = _COIN_SCENE.instantiate()
	_init_new_coin_signals(new_coin)
	_COIN_ROW.add_child(new_coin)
	new_coin.global_position = initial_position
	new_coin.init_coin(coin_family, denomination, Coin.Owner.PLAYER)
	if during_round and Global.is_passive_active(Global.PATRON_POWER_FAMILY_HERMES) and new_coin.can_upgrade() and Global.RNG.randi_range(1, 5) == 5:
		new_coin.upgrade()
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_HERMES)
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_DIONYSUS):
		new_coin.make_lucky()
		Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_DIONYSUS)
	_update_payoffs()
	return new_coin

func _gain_coin_from_shop(coin: Coin) -> void:
	var cur_pos = coin.global_position
	_SHOP_COIN_ROW.remove_child(coin)
	_COIN_ROW.add_child(coin)
	coin.global_position = cur_pos
	coin.mark_owned_by_player()
	_init_new_coin_signals(coin)
	_update_payoffs()

func _init_new_coin_signals(coin: Coin) -> void:
	coin.clicked.connect(_on_coin_clicked)
	coin.flip_complete.connect(_on_flip_complete)
	coin.turn_complete.connect(_on_turn_complete)
	coin.hovered.connect(_on_coin_hovered)
	coin.unhovered.connect(_on_coin_unhovered)

func _remove_coin_from_row(coin: Coin) -> void:
	assert(coin.get_parent() is CoinRow)
	var destroyed_global_pos = coin.global_position # store the coin's global position, so we can restore it after removing from row
	coin.get_parent().remove_child(coin) # remove from row and add to scene root
	add_child(coin)
	coin.position = destroyed_global_pos

# remove a coin from its row, then move it to a specified point, then destroy it
func _remove_coin_from_row_move_then_destroy(coin: Coin, point: Vector2) -> void:
	_remove_coin_from_row(coin)
	var tween = create_tween()
	tween.tween_property(coin, "position", point, Global.COIN_TWEEN_TIME)
	tween.tween_callback(destroy_coin.bind(coin)) 

func downgrade_coin(coin: Coin) -> void:
	if coin.is_being_destroyed():
		return
	if coin.get_denomination() == Global.Denomination.OBOL:
		destroy_coin(coin)
	else:
		coin.downgrade()
		_update_payoffs()

func destroy_coin(coin: Coin) -> void:
	if coin.is_being_destroyed():
		return
	
	if coin.is_monster_coin():
		Global.monsters_destroyed_this_round += 1
	
	if coin.get_parent() is CoinRow:
		_remove_coin_from_row(coin)
	# play destruction animation (coin will free itself after finishing)
	coin.destroy()
	_update_payoffs()
	
	# if nemesis round and the row is now empty, go ahead and end the round
	if _ENEMY_COIN_ROW.get_child_count() == 0 and Global.current_round_type() == Global.RoundType.NEMESIS:
		_on_end_round_button_pressed()
		return

func _get_row_for(coin: Coin) -> CoinRow:
	if _COIN_ROW.has_coin(coin):
		return _COIN_ROW
	if _ENEMY_COIN_ROW.has_coin(coin):
		return _ENEMY_COIN_ROW
	assert(false, "Not in either row!")
	return null

func _disable_interaction_coins_and_patron() -> void:
	for row in [_COIN_ROW, _ENEMY_COIN_ROW, _CHARON_COIN_ROW, _SHOP_COIN_ROW]:
		row.disable_interaction()
	_patron_token.disable_interaction()
	for arrow in _ARROWS.get_children():
		arrow.disable_interaction()

func _enable_interaction_coins_and_patron() -> void:
	for row in [_COIN_ROW, _ENEMY_COIN_ROW, _CHARON_COIN_ROW, _SHOP_COIN_ROW]:
		row.enable_interaction()
	_patron_token.enable_interaction()
	for arrow in _ARROWS.get_children():
		arrow.enable_interaction()

func _on_coin_clicked(coin: Coin):
	if _DIALOGUE.is_waiting() or _tutorial_fading:
		return

	if Global.state == Global.State.TOLLGATE:
		# if this coin cannot be offered at a toll, error message and return
		if coin.get_coin_family() in Global.TOLL_EXCLUDE_COIN_FAMILIES:
			_DIALOGUE.show_dialogue("Don't want that...")
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
		# prevent upgrading coins before tutorial is ready
		var no_upgrade_tutorial = [Global.TutorialState.ROUND1_SHOP_AFTER_BUYING_COIN,  Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN, Global.TutorialState.ROUND2_POWER_INTRO, Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE]
		if Global.tutorialState in no_upgrade_tutorial:
			return
		# prevent upgrading Zeus coin as first upgrade
		if Global.tutorialState == Global.TutorialState.ROUND2_SHOP_AFTER_UPGRADE and coin.is_power_coin():
			_DIALOGUE.show_dialogue("Click the other coin.")
			return
		
		# if we're in the shop, sell this coin
		if Global.is_character(Global.Character.MERCHANT):
			# don't sell if this is the last coin
			if _COIN_ROW.get_child_count() == 1:
				_DIALOGUE.show_dialogue("Can't sell last coin...")
				return
			_earn_souls(coin.get_sell_price())
			destroy_coin(coin)
			return
		
		if not coin.can_upgrade():
			if coin.get_denomination() == Global.Denomination.TETROBOL or coin.get_denomination() == Global.Denomination.DRACHMA:
				_DIALOGUE.show_dialogue("Can't upgrade more...")
			else:
				_DIALOGUE.show_dialogue("Can't upgrade that...")
		elif Global.souls >= coin.get_upgrade_price():
			Global.souls -= coin.get_upgrade_price()
			coin.upgrade()
			coin.reset_power_uses()
			
			if Global.tutorialState == Global.TutorialState.ROUND2_SHOP_AFTER_UPGRADE:
				await _tutorial_fade_in([_COIN_ROW, _SOUL_FRAGMENTS, _SOUL_LABEL, _SHOP_COIN_ROW])
				await _wait_for_dialogue("The coin has been upgraded from Obol to Diobol.")
				await _wait_for_dialogue("There are four denominations of increasing value...")
				await _wait_for_dialogue("Obol, Diobol, Triobol, and Tetrobol.")
				await _wait_for_dialogue("Coins of higher denominations are stronger.")
				await _wait_for_dialogue(Global.replace_placeholders("This coin's payoff(SOULS) has increased."))
				_PLAYER_TEXTBOXES.make_invisible()
				await _COIN_ROW.get_child(0).turn()
				await _wait_for_dialogue(Global.replace_placeholders("But the penalty(LIFE) has increased as well."))
				_PLAYER_TEXTBOXES.make_invisible()
				await _COIN_ROW.get_child(0).turn()
				_LEFT_HAND.unlock()
				_LEFT_HAND.move_to_retracted_position()
				_LEFT_HAND.lock()
				await _wait_for_dialogue(Global.replace_placeholders("Risk... reward..."))
				await _wait_for_dialogue("Lastly, from now on...")
				await _wait_for_dialogue("When you leave this shop...")
				await _wait_for_dialogue(Global.replace_placeholders("I will take your remaining souls(SOULS)."))
				await _wait_for_dialogue(Global.replace_placeholders("So I advise you to spend your souls(SOULS) wisely..."))
				await _wait_for_dialogue("Will you purchase new coins...")
				await _wait_for_dialogue("Or upgrading existing ones?")
				await _wait_for_dialogue("The decision is yours.")
				await _tutorial_fade_out()
				_SHOP_COIN_ROW.expand()
				_LEFT_HAND.unlock()
				_DIALOGUE.show_dialogue("Buying or upgrading...?")
				_SHOP_CONTINUE_TEXTBOX.enable()
				Global.tutorialState = Global.TutorialState.ROUND3_INTRO
			else:
				_DIALOGUE.show_dialogue("More power...")
		else:
			_DIALOGUE.show_dialogue("Not enough souls...")
		return
	
	# try to appease a coin in enemy row
	if coin.is_appeaseable() and Global.active_coin_power_family == null:
		var no_appease_states = [Global.TutorialState.ROUND4_MONSTER_INTRO, Global.TutorialState.ROUND4_MONSTER_AFTER_TOSS]
		if Global.tutorialState in no_appease_states:
			return
		
		if Global.souls >= coin.get_appeasal_price():
			_DIALOGUE.show_dialogue("Very good...")
			Global.monsters_destroyed_this_round += 1
			Global.souls -= coin.get_appeasal_price()
			if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ARES) and coin.is_tails():
				Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_ARES)
			destroy_coin(coin)
		else:
			_DIALOGUE.show_dialogue("Not enough souls...")
		return
	
	# only use coin powers during after flip
	if Global.state != Global.State.AFTER_FLIP:
		return
	
	var row = _get_row_for(coin)
	var left = row.get_left_of(coin)
	var right = row.get_right_of(coin)
	
	# if we have a coin power active, we're using a power on this coin; do that
	if Global.active_coin_power_family != null:
		var spent_power_use = false # some coins need to spend their charges before they activate to work properly
		
		# using a coin on itself deactivates it
		if coin == Global.active_coin_power_coin:
			_deactivate_active_power()
			return
		
		# powers can't be used on trial coins
		if coin.is_trial_coin(): 
			_DIALOGUE.show_dialogue("Can't use a power on that...")
			return
		
		# make sure we have a valid target
		if coin.is_monster_coin() and not Global.active_coin_power_family.can_target_monster_coins():
			_DIALOGUE.show_dialogue("Can't target monsters with that...")
			return
		
		if coin.is_owned_by_player() and not Global.active_coin_power_family.can_target_player_coins():
			_DIALOGUE.show_dialogue("Can't target your own coins with that...")
			return
		
		# trial of blood - using powers costs 1 life (excluding arrows)
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_BLOOD) and not Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP: 
			var life_cost = Global.BLOOD_COST
			# in the extremely rare case the power we're using itself has a life cost, factor that in before taking life...
			if Global.active_coin_power_family == Global.POWER_FAMILY_DOWNGRADE_FOR_LIFE:
				if coin.is_monster_coin():
					life_cost += Global.HADES_MONSTER_COST[Global.active_coin_power_coin.get_value() - 1]
			if Global.lives - life_cost < 0:
				_DIALOGUE.show_dialogue("Not enough life...")
				return
			Global.lives -= Global.BLOOD_COST
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_BLOOD)
		if Global.is_patron_power(Global.active_coin_power_family):
			match(Global.active_coin_power_family):
				Global.PATRON_POWER_FAMILY_CHARON:
					coin.turn()
					coin.make_lucky()
				Global.PATRON_POWER_FAMILY_ZEUS:
					if not coin.can_flip():
						_DIALOGUE.show_dialogue("Can't flip a stoned coin...")
						return
					_safe_flip(coin, false)
				Global.PATRON_POWER_FAMILY_HERA:
					if (not coin.can_flip()) and (not left or (left and not left.can_flip())) and (not right or (right and not right.can_flip())):
						_DIALOGUE.show_dialogue("Can't flip stoned coins...")
						return
					_safe_flip(coin, false)
					if left:
						left.play_power_used_effect(Global.active_coin_power_family)
						_safe_flip(left, false)
					if right:
						right.play_power_used_effect(Global.active_coin_power_family)
						_safe_flip(right, false)
				Global.PATRON_POWER_FAMILY_POSEIDON:
					coin.freeze()
				Global.PATRON_POWER_FAMILY_ATHENA:
					if not coin.can_reduce_life_penalty():
						_DIALOGUE.show_dialogue("No need...")
						return
					coin.change_life_penalty_permanently(-2)
				Global.PATRON_POWER_FAMILY_APOLLO:
					if not coin.has_status():
						_DIALOGUE.show_dialogue("No need...")
						return
					coin.clear_statuses()
				Global.PATRON_POWER_FAMILY_HEPHAESTUS:
					if row == _ENEMY_COIN_ROW:
						_DIALOGUE.show_dialogue("Can't upgrade that...")
						return
					if not coin.can_upgrade():
						_DIALOGUE.show_dialogue("Can't upgrade further...")
						return
					coin.upgrade()
					coin.reset_power_uses(true)
				Global.PATRON_POWER_FAMILY_HERMES:
					if row == _ENEMY_COIN_ROW:
						_DIALOGUE.show_dialogue("Can't trade that...")
						return
					var new_coin = _make_and_gain_coin(Global.random_coin_family_excluding([coin.get_coin_family()] + Global.TRANSFORM_OR_GAIN_EXCLUDE_COIN_FAMILIES), coin.get_denomination(), _CHARON_NEW_COIN_POSITION, true)
					new_coin.get_parent().move_child(new_coin, coin.get_index())
					new_coin.play_power_used_effect(Global.active_coin_power_family)
					_remove_coin_from_row_move_then_destroy(coin, _CHARON_NEW_COIN_POSITION)
				Global.PATRON_POWER_FAMILY_HESTIA:
					if not coin.can_make_lucky():
						_DIALOGUE.show_dialogue("No need...")
						return
					coin.make_lucky()
				Global.PATRON_POWER_FAMILY_HADES:
					if _COIN_ROW.get_child_count() == 1: #destroying itself, and last coin
						_DIALOGUE.show_dialogue("Can't destroy last coin...")
						return
					destroy_coin(coin)
					_heal_life(Global.HADES_PATRON_MULTIPLIER * coin.get_value())
					_earn_souls(Global.HADES_PATRON_MULTIPLIER * coin.get_value())
			coin.play_power_used_effect(Global.active_coin_power_family)
			_patron_token.play_power_used_effect(Global.patron.power_family)
			Global.patron_uses -= 1
			Global.patron_used_this_toss = true
			if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ZEUS):
				if not coin.is_being_destroyed():
					coin.charge()
					Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_ZEUS)
			_patron_token.deactivate()
			_update_payoffs()
			if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_USED:
				_map_is_disabled = false
				Global.restore_z(_LEFT_HAND)
				await _tutorial_fade_in([_COIN_ROW, _patron_token])
				await _wait_for_dialogue("Useful, isn't it?")
				await _wait_for_dialogue("This token doesn't simply flip coins...")
				await _wait_for_dialogue("Instead, it directly turns them to their other face.")
				await _wait_for_dialogue(Global.replace_placeholders("It also bestows the (LUCKY) Status."))
				await _wait_for_dialogue("Coins can be affected by many Statuses...")
				await _wait_for_dialogue(Global.replace_placeholders("(LUCKY) makes the coin land heads(HEADS) more often."))
				await _wait_for_dialogue(Global.replace_placeholders("Mouse over the (LUCKYICON)icon below the coin for details."))
				await _wait_for_dialogue("A patron token has a limited number of charges.")
				await _wait_for_dialogue("The charges are replenished between rounds.")
				await _wait_for_dialogue("Lastly, it may be used only once each toss.")
				await _tutorial_fade_out()
				_DIALOGUE.show_dialogue("Now, I will leave you to it.")
				_ACCEPT_TEXTBOX.enable()
				Global.tutorialState = Global.TutorialState.ROUND4_MONSTER_INTRO
			return
		match(Global.active_coin_power_family):
			Global.POWER_FAMILY_REFLIP:
				# clicking obol when you've been told to click Zeus to deactivate it
				if Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE:
					_DIALOGUE.show_dialogue("Click the power coin to deactivate it.")
					return
				elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_USED:
					_LEFT_HAND.unlock()
					_LEFT_HAND.unpoint()
					_safe_flip(coin, false, 1000000)
				elif not coin.can_flip():
					_DIALOGUE.show_dialogue("Can't flip stoned coin...")
					return
				elif Global.tutorialState != Global.TutorialState.INACTIVE and not Global.tutorial_warned_zeus_reflip and coin.is_heads() and not coin.is_monster_coin():
					await _tutorial_fade_in([_COIN_ROW])
					await _wait_for_dialogue("Wait!")
					_LEFT_HAND.point_at(_hand_point_for_coin(Global.active_coin_power_coin))
					_LEFT_HAND.lock()
					await _wait_for_dialogue("This power coin is still active.")
					_LEFT_HAND.unlock()
					_LEFT_HAND.point_at(_hand_point_for_coin(coin))
					_LEFT_HAND.lock()
					await _wait_for_dialogue("If you didn't intend to reflip this coin...")
					_LEFT_HAND.unlock()
					_LEFT_HAND.point_at(_hand_point_for_coin(Global.active_coin_power_coin))
					_LEFT_HAND.lock()
					await _wait_for_dialogue("Deactivate the power by clicking this coin...")
					await _wait_for_dialogue("...or by right clicking anywhere.")
					await _tutorial_fade_out()
					_LEFT_HAND.unlock()
					_LEFT_HAND.unpoint()
					Global.tutorial_warned_zeus_reflip = true
					return
				else:
					_safe_flip(coin, false)
			Global.POWER_FAMILY_FREEZE:
				if coin.is_frozen():
					_DIALOGUE.show_dialogue(Global.replace_placeholders("It's already (FROZEN)..."))
					return
				coin.freeze()
			Global.POWER_FAMILY_REFLIP_AND_NEIGHBORS:
				if (not coin.can_flip()) and (not left or (left and not left.can_flip())) and (not right or (right and not right.can_flip())):
					_DIALOGUE.show_dialogue("Can't flip stoned coin...")
					return
				# flip coin and neighbors
				# necessary in case hera reflips itself
				Global.active_coin_power_coin.spend_power_use()
				spent_power_use = true
				_safe_flip(coin, false)
				if left:
					left.play_power_used_effect(Global.active_coin_power_family)
					_safe_flip(left, false)
				if right:
					right.play_power_used_effect(Global.active_coin_power_family)
					_safe_flip(right, false)
			Global.POWER_FAMILY_TURN_AND_BLURSE:
				coin.turn()
				coin.curse() if coin.is_heads() else coin.bless()
			Global.POWER_FAMILY_REDUCE_PENALTY:
				if not coin.can_reduce_life_penalty():
					_DIALOGUE.show_dialogue("No need...")
					return
				coin.change_life_penalty_for_round(-1)
			Global.POWER_FAMILY_UPGRADE_AND_IGNITE:
				if not coin.can_upgrade():
					if coin.get_denomination() == Global.Denomination.TETROBOL or coin.get_denomination() == Global.Denomination.PENTOBOL:
						_DIALOGUE.show_dialogue("Can't upgrade further...")
					else:
						_DIALOGUE.show_dialogue("Can't upgrade that...")
					return
				# Heph Obol can only upgrade Obols; Diobol can only upgrade Obol + Diobol
				if Global.active_coin_power_coin.get_denomination() < coin.get_denomination():
					_DIALOGUE.show_dialogue("This coin can't upgrade %ss..." % Global.denom_to_string(coin.get_denomination()))
					return
				coin.upgrade()
				coin.ignite()
			Global.POWER_FAMILY_COPY_FOR_TOSS:
				if not coin.can_copy_power():
					_DIALOGUE.show_dialogue("Can't copy that...")
					return
				Global.active_coin_power_coin.overwrite_active_face_power_for_toss(coin.get_copied_power_family())
				Global.active_coin_power_family = Global.active_coin_power_coin.get_active_power_family() #overwrite with new power..
				if Global.active_coin_power_family.power_type == Global.PowerType.POWER_NON_TARGETTING: # if we copied a non-targetting power, deactivate
					Global.active_coin_power_coin = null
					Global.active_coin_power_family = null
				spent_power_use = true
			Global.POWER_FAMILY_EXCHANGE:
				var new_coin = _make_and_gain_coin(Global.random_coin_family_excluding([coin.get_coin_family()] + Global.TRANSFORM_OR_GAIN_EXCLUDE_COIN_FAMILIES), coin.get_denomination(), _CHARON_NEW_COIN_POSITION, true)
				new_coin.get_parent().move_child(new_coin, coin.get_index())
				new_coin.play_power_used_effect(Global.active_coin_power_family)
				_remove_coin_from_row_move_then_destroy(coin, _CHARON_NEW_COIN_POSITION)
			Global.POWER_FAMILY_MAKE_LUCKY:
				if not coin.can_make_lucky():
					_DIALOGUE.show_dialogue(Global.replace_placeholders("No need..."))
					return
				coin.make_lucky()
			Global.POWER_FAMILY_DOWNGRADE_FOR_LIFE:
				if coin.is_monster_coin():
					downgrade_coin(coin)
					Global.lives -= Global.HADES_MONSTER_COST[Global.active_coin_power_coin.get_value() - 1]
				elif coin.is_owned_by_player():
					if _COIN_ROW.get_child_count() == 1 and coin.get_denomination() == Global.Denomination.OBOL:
						_DIALOGUE.show_dialogue("Can't destroy last coin...")
						return
					downgrade_coin(coin)
					_heal_life(Global.HADES_SELF_GAIN[Global.active_coin_power_coin.get_value() - 1])
				else:
					assert(false, "Shouldn't be able to get here...")
			Global.POWER_FAMILY_STONE:
				if coin.is_stone():
					coin.clear_material()
				else:
					if not coin.can_stone():
						_DIALOGUE.show_dialogue("Can't (STONE) that...")
						return
					coin.stone()
			Global.POWER_FAMILY_BLANK_TAILS:
				if not coin.is_tails():
					_DIALOGUE.show_dialogue(Global.replace_placeholders("Can't use on (HEADS) coins..."))
					return
				if not coin.can_blank():
					_DIALOGUE.show_dialogue(Global.replace_placeholders("Can't (BLANK) that..."))
					return
				coin.blank()
			Global.POWER_FAMILY_TURN_TAILS_FREEZE_REDUCE_PENALTY:
				if not coin.can_reduce_life_penalty() and not coin.can_freeze() and coin.is_tails():
					_DIALOGUE.show_dialogue("No need...")
					return
				coin.freeze()
				if coin.is_owned_by_player():
					coin.change_life_penalty_for_round(-500000)
				if coin.is_heads():
					coin.turn()
			Global.POWER_FAMILY_IGNITE_BLESS_LUCKY:
				if not coin.can_ignite() and not coin.can_bless() and not coin.can_make_lucky():
					_DIALOGUE.show_dialogue("No need...")
					return
				coin.ignite()
				coin.bless()
				coin.make_lucky()
			Global.POWER_FAMILY_ARROW_REFLIP:
				if not coin.can_flip():
					_DIALOGUE.show_dialogue(Global.replace_placeholders("Can't flip a (STONE) coin..."))
					return
				_safe_flip(coin, false)
				coin.play_power_used_effect(Global.active_coin_power_family)
				Global.arrows -= 1
				if Global.arrows == 0:
					Global.active_coin_power_family = null
				return #special case - this power is not from a coin, so just exit immediately
		coin.play_power_used_effect(Global.active_coin_power_family)
		powers_used.append(Global.active_coin_power_family)
		Global.powers_this_round += 1
		if not spent_power_use:
			Global.active_coin_power_coin.spend_power_use()
		if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ZEUS):
			if not coin.is_being_destroyed():
				coin.charge()
				Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_ZEUS)
		if Global.active_coin_power_coin.get_active_power_charges() == 0 or not Global.active_coin_power_coin.is_active_face_power():
			Global.active_coin_power_coin = null
			Global.active_coin_power_family = null
		
		Global.malice += Global.MALICE_INCREASE_ON_POWER_USED * Global.current_round_malice_multiplier()
		if Global.malice >= Global.MALICE_ACTIVATION_THRESHOLD_AFTER_POWER:
			await activate_malice(MaliceActivation.DURING_POWERS)
		_update_payoffs()
	
	# non targetting coins
	# otherwise we're attempting to activate a coin
	elif coin.can_activate_power() and coin.get_active_power_charges() > 0:
		# if this is a power which does not target, resolve it
		if coin.get_active_power_family().power_type == Global.PowerType.POWER_NON_TARGETTING:
			# trial of blood - using powers costs 1 life
			if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_BLOOD): 
				var life_cost = Global.BLOOD_COST
				if Global.lives - life_cost < 0:
					_DIALOGUE.show_dialogue("Not enough life...")
					return
				Global.lives -= Global.BLOOD_COST
				Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_BLOOD)
			
			# resolve the power
			var spent_use = false
			match coin.get_active_power_family():
				Global.POWER_FAMILY_GAIN_LIFE:
					_heal_life(1 + ((coin.get_denomination()+1) * 2))
				Global.POWER_FAMILY_GAIN_ARROW:
					if Global.arrows == Global.ARROWS_LIMIT:
						_DIALOGUE.show_dialogue("Too many arrows...")
						return
					Global.arrows = min(Global.arrows + (coin.get_denomination()+1), Global.ARROWS_LIMIT)
				Global.POWER_FAMILY_REFLIP_ALL:
					# reflip all coins
					coin.spend_power_use() # do this ahead of time here since it might get flipped over...
					spent_use = true
					for c in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
						c = c as Coin
						c.play_power_used_effect(coin.get_active_power_family())
						_safe_flip(c, false)
				Global.POWER_FAMILY_GAIN_COIN:
					if _COIN_ROW.get_child_count() == Global.COIN_LIMIT:
						_DIALOGUE.show_dialogue("Too many coins...")
						return
					var new_coin = _make_and_gain_coin(Global.random_coin_family_excluding(Global.TRANSFORM_OR_GAIN_EXCLUDE_COIN_FAMILIES), Global.Denomination.OBOL, coin.global_position, true)
					new_coin.play_power_used_effect(coin.get_active_power_family())
				Global.POWER_FAMILY_DESTROY_FOR_REWARD:
					_earn_souls(Global.PHAETHON_REWARD_SOULS[coin.get_denomination()])
					_heal_life(Global.PHAETHON_REWARD_LIFE[coin.get_denomination()])
					Global.arrows = min(Global.arrows + Global.PHAETHON_REWARD_ARROWS[coin.get_denomination()], Global.ARROWS_LIMIT)
					Global.patron_uses = Global.patron.get_uses_per_round()
					destroy_coin(coin)
				_:
					assert(false, "No matching power")
			if not spent_use:
				coin.spend_power_use()
			coin.play_power_used_effect(coin.get_active_power_family())
			powers_used.append(coin.get_active_power_family())
			Global.powers_this_round += 1
			Global.malice += Global.MALICE_INCREASE_ON_POWER_USED * Global.current_round_malice_multiplier()
			if Global.malice >= Global.MALICE_ACTIVATION_THRESHOLD_AFTER_POWER:
				await activate_malice(MaliceActivation.DURING_POWERS)
			_update_payoffs()
		else: # otherwise, make this the active coin and coin power and await click on target
			# prevent reactivating the coin after deactivating
			if Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE:
				_DIALOGUE.show_dialogue("Accept the result.")
				return
			
			Global.active_coin_power_coin = coin
			Global.active_coin_power_family = coin.get_active_power_family()
			
			if Global.tutorialState == Global.TutorialState.ROUND2_POWER_ACTIVATED:
				var icon = _COIN_ROW.get_child(1).get_heads_icon() 
				await _tutorial_fade_in([_COIN_ROW])
				await _wait_for_dialogue("Now, this coin's power,[img=10x13]%s[/img], is active." % icon)
				await _wait_for_dialogue("This power can reflip other coins.")
				await _tutorial_fade_out()
				_DIALOGUE.show_dialogue("Click your other coin to use the power on it.")
				_LEFT_HAND.unlock()
				_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(0)))
				_LEFT_HAND.lock()
				Global.tutorialState = Global.TutorialState.ROUND2_POWER_USED

func _on_arrow_pressed():
	assert(Global.arrows >= 0)
	if Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
		Global.active_coin_power_family = null
		return
	if _patron_token.is_activated():
		_patron_token.deactivate()
	Global.active_coin_power_family = Global.POWER_FAMILY_ARROW_REFLIP
	Global.active_coin_power_coin = null # if there is an active coin, unactivate it

func _on_patron_token_clicked():
	if _DIALOGUE.is_waiting():
		return
	
	if Global.state != Global.State.AFTER_FLIP:
		return
	
	if not _patron_token.can_activate():
		if Global.patron_uses > 0:
			_DIALOGUE.show_dialogue("Only once per toss...")
		else:
			_DIALOGUE.show_dialogue("No more aid!")
		return
	
	if _patron_token.is_activated():
		if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_USED:
			_DIALOGUE.show_dialogue("Click on a coin.")
			return
		
		_patron_token.deactivate()
		return
	
	if Global.patron.power_family in Global.immediate_patron_powers:
		_patron_token.FX.flash(Color.GOLD)
		Global.active_coin_power_coin = null
		Global.active_coin_power_family = null
	
	# immediate patron powers
	match(Global.patron.power_family):
		Global.PATRON_POWER_FAMILY_DEMETER:
			for coin in _COIN_ROW.get_children():
				var as_coin: Coin = coin
				if as_coin.is_tails() and as_coin.get_active_power_family().power_type == Global.PowerType.PAYOFF_LOSE_LIFE:
					_heal_life(as_coin.get_active_power_charges())
					as_coin.play_power_used_effect(Global.patron.power_family)
			Global.patron_uses -= 1
			Global.patron_used_this_toss = true
		Global.PATRON_POWER_FAMILY_ARTEMIS:
			for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				var as_coin: Coin = coin
				as_coin.turn()
				as_coin.play_power_used_effect(Global.patron.power_family)
			Global.patron_uses -= 1
			Global.patron_used_this_toss = true
		Global.PATRON_POWER_FAMILY_ARES:
			for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				_safe_flip(coin, false)
				coin.play_power_used_effect(Global.patron.power_family)
			Global.patron_uses -= 1
			Global.patron_used_this_toss = true
		Global.PATRON_POWER_FAMILY_APHRODITE:
			for coin in _COIN_ROW.get_children():
				var as_coin: Coin = coin
				if as_coin.is_active_face_power():
					as_coin.recharge_power_uses_by(2)
					as_coin.play_power_used_effect(Global.patron.power_family)
			Global.patron_uses -= 1
			Global.patron_used_this_toss = true
		Global.PATRON_POWER_FAMILY_DIONYSUS: # smart random behavior
			var tails = _COIN_ROW.get_tails()
			tails.shuffle()
			var tails_powers = tails.filter(CoinRow.FILTER_POWER)
			var heads = _COIN_ROW.get_heads()
			heads.shuffle()
			var _heads_powers = heads.filter(CoinRow.FILTER_POWER)
			var n_coins = _COIN_ROW.get_child_count()
			
			# savior check - if a lot of coins are tails, assist with that directly
			if heads.size() == 0 or (n_coins >= floor(Global.COIN_LIMIT / 2.0) and heads.size() <= 1) or (n_coins >= Global.COIN_LIMIT and heads.size() <= 2):
				var roll = Global.RNG.randi_range(1, 3)
				if heads.size() <= 3:
					roll = 1
				match(roll):
					1: # turn 2 powers to heads
						for coin in Global.choose_x(tails_powers, 2):
							coin.turn()
							coin.play_power_used_effect(Global.patron.power_family)
					2: # reflip 4 tails coins
						for coin in Global.choose_x(tails, 4):
							_safe_flip(coin, false)
							coin.play_power_used_effect(Global.patron.power_family)
					3: # reflip all coins
						for coin in _COIN_ROW.get_children():
							_safe_flip(coin, false)
							coin.play_power_used_effect(Global.patron.power_family)
			else:  # otherwise, choose 2-3 helpful actions
				var boons = 0
				while boons < Global.RNG.randi_range(2, 3):
					match(Global.RNG.randi_range(1, 12)):
						1: # gain a coin
							if _COIN_ROW.get_child_count() != Global.COIN_LIMIT and _COIN_ROW.get_child_count() != Global.COIN_LIMIT - 1:
								var new_coin = _make_and_gain_coin(Global.random_coin_family_excluding(Global.TRANSFORM_OR_GAIN_EXCLUDE_COIN_FAMILIES), Global.Denomination.OBOL, _PATRON_TOKEN_POSITION)
								if Global.RNG.randi_range(1, 3) == 1:
									new_coin.make_lucky()
								if Global.RNG.randi_range(1, 2) == 1:
									new_coin.bless()
								new_coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						2: # make coins lucky
							var not_lucky = _COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_LUCKY)
							if not_lucky.size() != 0:
								for coin in Global.choose_x(not_lucky, Global.RNG.randi_range(1, 3)):
									coin.make_lucky()
									coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						3: # make coins blessed
							var not_blessed = _COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_BLESSED)
							if not_blessed.size() != 0:
								for coin in Global.choose_x(not_blessed, Global.RNG.randi_range(1, 3)):
									coin.bless()
									coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						4: # freeze heads coins
							var not_frozen_heads = heads.filter(CoinRow.FILTER_NOT_FROZEN)
							if not_frozen_heads.size() != 0:
								for coin in Global.choose_x(not_frozen_heads, Global.RNG.randi_range(1, 3)):
									coin.freeze()
									coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						5: # clear ignite or frozen on tails
							var ignited = _COIN_ROW.get_filtered(CoinRow.FILTER_IGNITED)
							var frozen_tails = _COIN_ROW.get_filtered(CoinRow.FILTER_FROZEN).filter(CoinRow.FILTER_TAILS)
							if ignited.size() + frozen_tails.size() >= floor(_COIN_ROW.get_child_count() / 2.0):
								for coin in Global.choose_x(ignited, Global.RNG.randi_range(2, 3)):
									coin.clear_freeze_ignite()
									coin.play_power_used_effect(Global.patron.power_family)
								for coin in Global.choose_x(frozen_tails, Global.RNG.randi_range(2, 3)):
									coin.clear_freeze_ignite()
									coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						6: # clear unlucky, cursed, or blank
							var unlucky = _COIN_ROW.get_filtered(CoinRow.FILTER_UNLUCKY)
							var cursed = _COIN_ROW.get_filtered(CoinRow.FILTER_CURSED)
							var blank = _COIN_ROW.get_filtered(CoinRow.FILTER_BLANK)
							if unlucky.size() + cursed.size() + blank.size() >= floor(_COIN_ROW.get_child_count() / 2.0):
								for coin in Global.choose_x(unlucky, Global.RNG.randi_range(2, 3)):
									coin.clear_lucky_unlucky()
									coin.play_power_used_effect(Global.patron.power_family)
								for coin in Global.choose_x(cursed, Global.RNG.randi_range(2, 3)):
									coin.clear_blessed_cursed()
									coin.play_power_used_effect(Global.patron.power_family)
								for coin in Global.choose_x(blank, Global.RNG.randi_range(2, 3)):
									coin.unblank()
									coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						7: # gain arrows
							if Global.arrows <= Global.ARROWS_LIMIT - floor(Global.ARROWS_LIMIT / 2.0):
								var bonus_arrows = Global.RNG.randi_range(1, 3)
								Global.arrows = min(Global.ARROWS_LIMIT, Global.arrows + bonus_arrows)
								boons += 1
						8: # blank a monster
							if not Global.is_current_round_trial() and _ENEMY_COIN_ROW.get_child_count() != 0:
								for coin in Global.choose_x(_ENEMY_COIN_ROW.get_children(), Global.RNG.randi_range(1, 2)):
									coin.blank()
									coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						9: # downgrade a monster
							if _ENEMY_COIN_ROW.get_child_count() != 0:
								for coin in Global.choose_x(_ENEMY_COIN_ROW.get_children(), Global.RNG.randi_range(2, 3)):
									downgrade_coin(coin)
									coin.play_power_used_effect(Global.patron.power_family)
								boons += 1
						10: # gain souls/life, just a generic bonus
							match(Global.RNG.randi_range(1, 2)):
								1:
									_earn_souls(max(4, Global.RNG.randi_range(Global.round_count, 2 * Global.round_count)))
								2:
									_heal_life(max(6, Global.RNG.randi_range(Global.round_count * 2, 3 * Global.round_count)))
							boons += 1
						11: # recharge coins
							var rechargable = _COIN_ROW.get_filtered(CoinRow.FILTER_RECHARGABLE)
							if rechargable.size() >= 3:
								for i in Global.RNG.randi_range(2, 4):
									var coin = Global.choose_one(rechargable)
									coin.recharge_power_uses_by(1)
									coin.play_power_used_effect(Global.patron.power_family)
						12: # charge coins
							var chargeable = _COIN_ROW.get_filtered(CoinRow.FILTER_NOT_CHARGED)
							if chargeable.size() >= 3:
								for coin in Global.choose_x(chargeable, Global.RNG.randi_range(2, 3)):
									coin.charge()
									coin.play_power_used_effect(Global.patron.power_family)
			_patron_token.play_power_used_effect(Global.patron.power_family)
			Global.patron_uses -= 1
			Global.patron_used_this_toss = true
		_: # if not immediate, activate the token
			if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_ACTIVATED:
				_DIALOGUE.show_dialogue("Now click a coin to use the patron's power.")
				_LEFT_HAND.unlock()
				_LEFT_HAND.unpoint()
				Global.tutorialState = Global.TutorialState.ROUND3_PATRON_USED
			_patron_token.activate()

func _input(event):
	# right click with a god power disables it
	# right click with the map open closes it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if Global.active_coin_power_family != null:
				_deactivate_active_power()
			if _map_open and not Global.state == Global.State.VOYAGE:
				_hide_voyage_map()

func _deactivate_active_power() -> void:
	# clicking Zeus a second time when you've been told to use on obol
	if Global.tutorialState == Global.TutorialState.ROUND2_POWER_USED:
		_DIALOGUE.show_dialogue("Click the other coin.")
		return
	
	Global.active_coin_power_family = null
	Global.active_coin_power_coin = null
	if _patron_token.is_activated():
		_patron_token.deactivate()
	
	# after deactivating the Zeus power
	if Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE:
		_DIALOGUE.show_dialogue("Now accept the result.")
		_ACCEPT_TEXTBOX.enable()

func _on_shop_reroll_button_clicked():
	if Global.souls < Global.reroll_cost():
		_DIALOGUE.show_dialogue("Not enough souls...")
		return
	_PLAYER_TEXTBOXES.make_invisible()
	Global.souls -= Global.reroll_cost()
	await _SHOP.retract()
	randomize_and_show_shop()
	Global.shop_rerolls += 1
	_PLAYER_TEXTBOXES.make_visible()

func randomize_and_show_shop() -> void:
	_SHOP.randomize_and_show_shop()
	
	# connect each shop coin to charon hand for hovering...
	for coin in _SHOP_COIN_ROW.get_children():
		coin.unhovered.connect(_on_coin_unhovered)
		coin.hovered.connect(_on_coin_hovered)
	
	_update_payoffs()

enum MaliceActivation {
	AFTER_PAYOFF, DURING_POWERS
}
enum MaliceAction {
	NONE, 
	CURSE,
	UNLUCKY, IGNITE, INCREASE_PENALTY, THORNS, STONE_POWERS, STRENGTHEN_MONSTERS, 
	TURN_PAYOFFS, DRAIN_POWERS, SPAWN_MONSTERS, REFLIP_SCRAMBLE_ALL, FREEZE_TAILS, NUKE_VALUABLE, 
}
var previous_malice_action = MaliceAction.NONE
func activate_malice(activation_type: MaliceActivation) -> void:
	const delay = 1.0
	
	# remove excess elements from recent powers used
	while powers_used.size() > 30:
		powers_used.pop_front()
	
	_disable_interaction_coins_and_patron()
	_map_is_disabled = true
	
	_MALICE_DUST.emitting = false
	_MALICE_DUST_RED.emitting = false
	_LEFT_HAND.disable_hovering()
	_RIGHT_HAND.disable_hovering()
	_LEFT_HAND.slam()
	_RIGHT_HAND.slam()
	_CHARON_FOG_FX.fade_in(_TINT_TIME) # aggressive fog wave
	# screen shake
	
	await _wait_for_dialogue("Enough!", delay)
	if malice_activations_this_game == 0:
		await _wait_for_dialogue("So, do you think yourself clever?")
		await _wait_for_dialogue("You hope to beat me at my own game?")
		await _wait_for_dialogue("I will prove to you...")
		await _wait_for_dialogue("Just how weak you truly are!")
	else:
		await _wait_for_dialogue("You dare stand against me?")
	
	# wait for all flips to finish - this is a pretty lazy way of doing it but whatever
	_PLAYER_TEXTBOXES.make_invisible()
	while flips_pending != 0:
		await Global.delay(0.05)
	
	_CHARON_FOG_FX.fade_out(_TINT_TIME)
	_LEFT_HAND.move_to_forward_position()
	_RIGHT_HAND.move_to_forward_position()
	
	var skew_tween = create_tween().set_loops()
	skew_tween.tween_property(_LEFT_HAND, "skew", PI/8, 0.5)
	skew_tween.parallel().tween_property(_RIGHT_HAND, "skew", -PI/8, 0.5)
	skew_tween.tween_property(_LEFT_HAND, "skew", 0, 0.5)
	skew_tween.parallel().tween_property(_RIGHT_HAND, "skew", 0, 0.5)
	_LEFT_HAND.activate_malice_active_tint()
	_RIGHT_HAND.activate_malice_active_tint()
	
	
	# create a bunch of heuristics to reference
	# helper functions
	var count_tag = func(arr: Array, tag: Global.PowerFamily.Tag) -> int:
		var c = 0
		for power_family in arr:
			if power_family.has_tag(tag):
				c += 1
		return c

	var powers_reflip = count_tag.call(powers_used, Global.PowerFamily.Tag.REFLIP)
	var powers_freeze = count_tag.call(powers_used, Global.PowerFamily.Tag.FREEZE)
	var powers_lucky = count_tag.call(powers_used, Global.PowerFamily.Tag.LUCKY)
	var _powers_upgrade = count_tag.call(powers_used, Global.PowerFamily.Tag.UPGRADE)
	var powers_gain = count_tag.call(powers_used, Global.PowerFamily.Tag.GAIN)
	var powers_destroy = count_tag.call(powers_used, Global.PowerFamily.Tag.DESTROY)
	var powers_heal = count_tag.call(powers_used, Global.PowerFamily.Tag.HEAL)
	var powers_positioning = count_tag.call(powers_used, Global.PowerFamily.Tag.POSITIONING)
	var powers_bless = count_tag.call(powers_used, Global.PowerFamily.Tag.BLESS)
	
	var lucky_coins = _COIN_ROW.get_filtered(CoinRow.FILTER_LUCKY).size()
	var percentage_lucky = lucky_coins / float(_COIN_ROW.num_coins())
	var percentage_unlucky = _COIN_ROW.get_filtered(CoinRow.FILTER_UNLUCKY).size() / float(_COIN_ROW.num_coins())
	
	var frozen_on_heads_coins = _COIN_ROW.get_multi_filtered([CoinRow.FILTER_HEADS, CoinRow.FILTER_FROZEN]).size() 
	var percentage_frozen_on_heads = frozen_on_heads_coins / float(_COIN_ROW.num_coins())
	var percentage_ignited = _COIN_ROW.get_filtered(CoinRow.FILTER_IGNITED).size() / float(_COIN_ROW.num_coins())
	
	var blessed_coins = _COIN_ROW.get_filtered(CoinRow.FILTER_BLESSED).size()
	var percentage_blessed = blessed_coins / float(_COIN_ROW.num_coins())
	var percentage_cursed = _COIN_ROW.get_filtered(CoinRow.FILTER_CURSED).size() / float(_COIN_ROW.num_coins())
	
	var percentage_stoned = _COIN_ROW.get_filtered(CoinRow.FILTER_STONE).size() / float(_COIN_ROW.num_coins())
	
	var num_coins = _COIN_ROW.num_coins()
	
	var heads_coins = _COIN_ROW.get_filtered(CoinRow.FILTER_HEADS).size()
	var percentage_heads = heads_coins / float(_COIN_ROW.num_coins())
	var tails_coins = _COIN_ROW.get_filtered(CoinRow.FILTER_TAILS).size()
	var percentage_tails = tails_coins / float(_COIN_ROW.num_coins())
	
	var usable_powers = _COIN_ROW.get_filtered(CoinRow.FILTER_USABLE_POWER).size()
	var heads_payoffs = _COIN_ROW.get_filtered(CoinRow.FILTER_ACTIVE_PAYOFF).size()
	
	var empty_spaces = Global.COIN_LIMIT - _COIN_ROW.num_coins()
	var num_monsters = _ENEMY_COIN_ROW.num_coins()
	
	var highest_valued_arr = _COIN_ROW.get_highest_valued()
	var highest_valued = highest_valued_arr[0]
	var is_highest_valued_singular = highest_valued_arr.size() == 0
	var is_highest_valued_heads_power = highest_valued_arr[0].is_active_face_power()
	var highest_denom = highest_valued_arr[0].get_denomination()
	var _drachmas = _COIN_ROW.get_filtered(CoinRow.FILTER_DRACHMA)
	var _pentobols = _COIN_ROW.get_filtered(CoinRow.FILTER_PENTOBOL)
	var _tetrobols = _COIN_ROW.get_filtered(CoinRow.FILTER_TETROBOL)
	var _triobols = _COIN_ROW.get_filtered(CoinRow.FILTER_TRIOBOL)
	var _diobols = _COIN_ROW.get_filtered(CoinRow.FILTER_DIOBOL)
	var _obols = _COIN_ROW.get_filtered(CoinRow.FILTER_OBOL)
	
	# choose the action
	var actions = []
	var final_action = MaliceAction.NONE
	
	# perform calculations for effects that may happen in either case
	var curse_weight = 1 + (10 * (min(percentage_blessed, 0.5))) +\
		(2 if powers_bless > 0 else 0) + (2 if powers_bless >= 10 else 0) +\
		(2 if percentage_heads >= 0.7 else 0) + (2 if percentage_heads >= 0.9 else 0)
	if percentage_cursed >= 0.5: # if a lot are already cursed, reduce back to minimum
		curse_weight = 0
	
	var spawn_monsters_weight = 1 + (3 * Global.monsters_destroyed_this_round) +\
		(2 if num_monsters == 1 else 0) + (4 if num_monsters == 0.0 else 0)
	if num_monsters >= 4:
		spawn_monsters_weight = 0
	if Global.monsters_destroyed_this_round <= 1:
		spawn_monsters_weight = 0
	
	if activation_type == MaliceActivation.AFTER_PAYOFF:
		# calculate a bunch of weights 
		var unlucky_weight = 1 + (5 * percentage_lucky) +\
			(1 if powers_reflip >= 5 else 0) + (1 if powers_reflip >= 10 else 0) + (1 if powers_reflip >= 15 else 0) +\
			(1 if powers_lucky >= 4 else 0) +\
			(2 if Global.arrows >= 5 else 0)
		if percentage_unlucky > 0.5: # if a lot are already unlucky, reduce back down to minimum
			unlucky_weight = 1
		
		var ignite_weight = 1 + (10 * (min(percentage_frozen_on_heads, 0.5))) +\
			(1 if powers_freeze >= 3 else 0) + (1 if powers_freeze >= 6 else 0) + (1 if powers_freeze >= 9 else 0) +\
			(1 if powers_heal >= 3 else 0) + (1 if powers_heal >= 7 else 0) + (1 if powers_reflip >= 12 else 0) +\
			(2 if Global.lives >= 50 else 0) + (3 if Global.lives >= 100 else 0)
		if percentage_ignited > 0.5: # if a lot are already ignited, reduce back to minimum
			ignite_weight = 1

		var increase_penalty_weight = 1 + (5 * percentage_tails) +\
			(2 if tails_coins != 0 else 0) + (2 if tails_coins >= 4 else 0)
		var legal_coins = 0
		for coin in _COIN_ROW.get_children():
			if coin.can_change_life_penalty():
				legal_coins += 1
		if legal_coins/float(num_coins) < 0.5:
			increase_penalty_weight = 0
		
		var thorns_weight = 1 + (0.7 * empty_spaces) +\
			(3 if powers_gain != 0 else 0) + (3 if powers_gain >= 6 else 0) + (3 if powers_gain >= 12 else 0) +\
			(-8 if powers_destroy != 0 else 0)
		if num_coins <= 3 or num_coins == 9: 
			thorns_weight = 1
		if num_coins == 9:
			thorns_weight = 0
		thorns_weight = max(0, thorns_weight)
		
		var stone_powers_weight = 1 + (usable_powers) +\
			(2 if percentage_tails <= 0.2 else 0) + (4 if percentage_tails == 0.0 else 0)
		if percentage_stoned >= 0.3: # if a lot are already stoned, reduce back to minimum
			stone_powers_weight = 1
		if num_coins <= 5: # don't happen if very few coins
			stone_powers_weight = 0

		var strengthen_monsters_weight = 1 + (2 * num_monsters)
		var upgradable_monsters = 0
		for monster in _ENEMY_COIN_ROW.get_children():
			if monster.can_upgrade():
				upgradable_monsters += 1
		if upgradable_monsters <= 2: #don't happen if not enough monsters
			strengthen_monsters_weight = 0
		if Global.is_current_round_nemesis(): #don't happen during nemesis rounds
			strengthen_monsters_weight = 0
		
		print("Curse weight: %d" % curse_weight)
		print("Unlucky weight: %d" % unlucky_weight)
		print("Ignite weight: %d" % ignite_weight)
		print("Increase penalty weight: %d" % increase_penalty_weight)
		print("Thorns weight: %d" % thorns_weight)
		print("Stone powers weight: %d" % stone_powers_weight)
		print("Strengthen monsters weight: %d" % strengthen_monsters_weight)
		print("Spawn monsters weight: %d" % spawn_monsters_weight)
		
		actions = [
			[MaliceAction.CURSE, curse_weight],
			[MaliceAction.UNLUCKY, unlucky_weight],
			[MaliceAction.IGNITE, ignite_weight],
			[MaliceAction.INCREASE_PENALTY, increase_penalty_weight],
			[MaliceAction.THORNS, thorns_weight],
			[MaliceAction.STONE_POWERS, stone_powers_weight],
			[MaliceAction.STRENGTHEN_MONSTERS, strengthen_monsters_weight],
			[MaliceAction.SPAWN_MONSTERS, spawn_monsters_weight]
		]
	elif activation_type == MaliceActivation.DURING_POWERS:
		var turn_payoffs_weight = 1 + (2 * heads_payoffs) +\
			(3 if heads_payoffs >= 3 else 0) +\
			(3 if powers_freeze >= 7 else 0)
		if heads_payoffs < 2:
			turn_payoffs_weight = 1
		if heads_payoffs == 0:
			turn_payoffs_weight = 0
		
		var drain_powers_weight = 1 + (1.5 * usable_powers) +\
			(2 if usable_powers >= 3 else 0) + (3 if usable_powers >= 5 else 0)
		if usable_powers < 2:
			drain_powers_weight = 1
		if usable_powers == 0:
			drain_powers_weight = 0
		
		var reflip_scramble_all_weight = 1 + (2 * heads_coins) - (2 * tails_coins) +\
			(2 if powers_positioning >= 3 else 0) + (3 if powers_positioning >= 10 else 0) +\
			(3 * percentage_unlucky) - (5 * percentage_lucky) +\
			(2 * percentage_cursed) - (3 * percentage_blessed)
		
		var freeze_tails_weight = 1 + (3 * tails_coins) - (5 * percentage_ignited)
		if percentage_heads < 0.5: # I'm not thaaaat mean, give you some counterplay
			freeze_tails_weight = 0
		
		var nuke_valuable_weight = 0
		if is_highest_valued_singular and is_highest_valued_heads_power:
			nuke_valuable_weight = 7
		
		print("Curse weight: %d" % curse_weight)
		print("Turn powers weight: %d" % turn_payoffs_weight)
		print("Drain powers weight: %d" % drain_powers_weight)
		print("Reflip scramble weight: %d" % reflip_scramble_all_weight)
		print("Freeze tails weight: %d" % freeze_tails_weight)
		print("Spawn monsters weight: %d" % spawn_monsters_weight)
		print("Nuke valuable weight: %d" % nuke_valuable_weight)
		
		actions = [
			[MaliceAction.CURSE, curse_weight],
			[MaliceAction.TURN_PAYOFFS, turn_payoffs_weight],
			[MaliceAction.DRAIN_POWERS, drain_powers_weight],
			[MaliceAction.REFLIP_SCRAMBLE_ALL, reflip_scramble_all_weight],
			[MaliceAction.FREEZE_TAILS, freeze_tails_weight],
			[MaliceAction.SPAWN_MONSTERS, spawn_monsters_weight],
			[MaliceAction.NUKE_VALUABLE, nuke_valuable_weight]
		]
	
	# now take the top 3...
	var sort_pairs = func(one: Array, two: Array) -> bool: # custom sort
		return one[1] > two[1]
	actions.sort_custom(sort_pairs)
	
	if actions.size() == 0: # if there are NO valid options, default to curse - this should be really rare or impossible
		assert(false, "This really shouldn't happen.")
		final_action = MaliceAction.CURSE
	elif actions.size() == 1: # if there is only a single valid option, take it, ignoring duplication
		final_action = actions[0][0]
	else: # take the top 3 if possible (otherwise 2) and choose from them, avoiding the last action taken
		actions = actions.slice(0, min(3, actions.size()))
		
		# now choose one based on weights... but don't allow the same action as last time
		var acts = [] # array of possible actions
		var weights = [] # array of corresponding weights
		for i in range(0, actions.size()):
			acts.append(actions[i][0])
			weights.append(actions[i][1])
		final_action = Global.choose_one_weighted(acts, weights)
		while final_action == previous_malice_action:
			final_action = Global.choose_one_weighted(acts, weights)
	
	previous_malice_action = final_action
	
	# perform the action
	match final_action:
		MaliceAction.UNLUCKY:
			var unlucky_remaining = max(1, floor(num_coins/2.0))
			# aim for lucky coins if we can
			for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_LUCKY), unlucky_remaining):
				target.make_unlucky()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
				unlucky_remaining -= 1
			# now take other coins
			for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_UNLUCKY), unlucky_remaining):
				target.make_unlucky()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("Your luck falters!", delay)
		MaliceAction.CURSE:
			var curses_remaining = max(1, floor(num_coins/2.0))
			# aim for blessed coins if we can
			for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_BLESSED), curses_remaining):
				target.curse()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
				curses_remaining -= 1 
			for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_CURSED), curses_remaining):
				target.curse()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("Bear a heavy curse!", delay)
		MaliceAction.IGNITE:
			var ignites_remaining = max(1, floor(num_coins/2.0))
			# attempt to ignite frozen coins if we can
			for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_FROZEN), ignites_remaining):
				target.ignite()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
				ignites_remaining -= 1 
			for target in Global.choose_x(_COIN_ROW.get_filtered_randomized(CoinRow.FILTER_NOT_IGNITED), ignites_remaining):
				target.ignite()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("You shall burn!", delay)
		MaliceAction.INCREASE_PENALTY:
			for target in _COIN_ROW.get_children():
				if target.can_change_life_penalty():
					target.change_life_penalty_for_round(2)
					target.change_life_penalty_permanently(1)
					target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("May your pain be amplified!", delay)
		MaliceAction.THORNS:
			_make_and_gain_coin(Global.THORNS_FAMILY, highest_denom, _CHARON_NEW_COIN_POSITION)
			await _wait_for_dialogue("I have a gift for you...", delay)
		MaliceAction.STONE_POWERS:
			for target in Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_USABLE_POWER, CoinRow.FILTER_NOT_STONE]), max(1, floor(num_coins/4.0))):
				target.stone()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("Be turned to stone!", delay)
		MaliceAction.STRENGTHEN_MONSTERS:
			for monster in _ENEMY_COIN_ROW.get_children():
				if monster.can_upgrade():
					monster.upgrade()
					monster.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("My minions grow stronger!", delay)
		MaliceAction.TURN_PAYOFFS:
			for target in _COIN_ROW.get_filtered(CoinRow.FILTER_ACTIVE_PAYOFF):
				target.turn()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("The souls are mine! None for you!", delay)
		MaliceAction.DRAIN_POWERS:
			for target in _COIN_ROW.get_filtered(CoinRow.FILTER_USABLE_POWER):
				target.drain_power_uses_by(2)
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("I shall render you powerless!", delay)
		MaliceAction.SPAWN_MONSTERS:
			var denom = Global.Denomination.OBOL
			if Global.current_round_wave_strength() >= 12:
				denom = Global.Denomination.DIOBOL
			elif Global.current_round_wave_strength() >= 24:
				denom = Global.Denomination.TRIOBOL
			for i in range(0, 2):
				spawn_enemy(Global.get_standard_monster(), denom)
			await _wait_for_dialogue("Rise, monsters of the underworld!", delay)
		MaliceAction.REFLIP_SCRAMBLE_ALL:
			for c in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				c = c as Coin
				c.play_power_used_effect(Global.CHARON_POWER_DEATH)
				_safe_flip(c, false)
			_COIN_ROW.shuffle()
			_ENEMY_COIN_ROW.shuffle()
			await _wait_for_dialogue("Scatter and fall!", delay)
		MaliceAction.FREEZE_TAILS:
			for target in _COIN_ROW.get_filtered(CoinRow.FILTER_TAILS):
				target.freeze()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			await _wait_for_dialogue("Your blood runs cold!", delay)
		MaliceAction.NUKE_VALUABLE:
			if highest_valued.is_heads():
				highest_valued.turn()
			highest_valued.freeze()
			highest_valued.curse()
			highest_valued.unlucky()
			await _wait_for_dialogue("I can read your intentions...", delay)
		_:
			assert(false)
	
	skew_tween.kill()
	var fix_tween = create_tween()
	fix_tween.tween_property(_LEFT_HAND, "skew", 0, 0.1)
	fix_tween.tween_property(_RIGHT_HAND, "skew", 0, 0.1)
	_LEFT_HAND.move_to_default_position()
	_RIGHT_HAND.move_to_default_position()
	_LEFT_HAND.enable_hovering()
	_RIGHT_HAND.enable_hovering()
	_LEFT_HAND.deactivate_malice_active_tint()
	_RIGHT_HAND.deactivate_malice_active_tint()
	Global.malice = 0.0
	
	# done, ending dialogue
	if malice_activations_this_game == 0:
		await _wait_for_dialogue("You look rather surprised.")
	await _wait_for_dialogue("I never said I would play fair...")
	await _wait_for_dialogue("So what will you do now?")
	_DIALOGUE.show_dialogue("Entertain me.")
	
	malice_activations_this_game += 1
	
	_update_payoffs()
	
	_PLAYER_TEXTBOXES.make_visible()
	_enable_interaction_coins_and_patron()
	_map_is_disabled = false

@onready var _MALICE_DUST : GPUParticles2D = $MaliceDust
@onready var _MALICE_DUST_RED : GPUParticles2D = $MaliceDustRed
func _on_malice_changed() -> void:
	#print(Global.malice)
	if Global.malice >= 40:
		_MALICE_DUST.emitting = true
		_MALICE_DUST.amount = lerp(15, 40, (Global.malice-40)/60.0)
	else:
		_MALICE_DUST.emitting = false
		
	if Global.malice >= 60:
		_MALICE_DUST_RED.emitting = true
		_MALICE_DUST_RED.amount = lerp(10, 25, (Global.malice-60)/40.0)
	else:
		_MALICE_DUST_RED.emitting = false
	
	# during trials, start glowing slightly earlier because otherwise it's easy to get skipped over due to doubled malice
	if Global.malice >= (90 if not Global.is_current_round_trial else 80):
		_LEFT_HAND.activate_malice_glow_intense()
		_RIGHT_HAND.activate_malice_glow_intense()
	elif Global.malice >= (75 if not Global.is_current_round_trial else 63):
		_LEFT_HAND.activate_malice_glow()
		_RIGHT_HAND.activate_malice_glow()
	else:
		_LEFT_HAND.deactivate_malice_glow()
		_RIGHT_HAND.deactivate_malice_glow()

func _update_payoffs() -> void:
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children() + _SHOP_COIN_ROW.get_children():
		coin.update_payoff(_COIN_ROW, _ENEMY_COIN_ROW, _SHOP_COIN_ROW)
