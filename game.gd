class_name Game
extends Node2D

signal game_ended

@onready var _COIN_ROW: CoinRow = $Table/CoinRow
@onready var _SHOP: Shop = $Table/Shop
@onready var _SHOP_MAT = $Table/ShopMat
@onready var _SHOP_COIN_ROW: CoinRow = $Table/Shop/ShopRow
@onready var _ENEMY_ROW: EnemyRow = $Table/EnemyRow
@onready var _ENEMY_COIN_ROW: CoinRow = $Table/EnemyRow/CoinRow;
@onready var _CHARON_COIN_ROW: CoinRow = $Table/CharonObolRow

@onready var _LIFE_LABEL = $Table/LivesLabel
@onready var _LIFE_DELTA_LABEL = $Table/LivesDeltaLabel
@onready var _SOUL_LABEL = $Table/SoulsLabel
@onready var _SOUL_DELTA_LABEL = $Table/SoulsDeltaLabel
@onready var _LIFE_FRAGMENTS = $Table/LifeFragments
@onready var _SOUL_FRAGMENTS = $Table/SoulFragments
@onready var _DELETING_FRAGMENTS = $Table/DeletingFragments
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
@onready var _CHARON_SHOOTER = $Table/CharonShooter
@onready var _PLAYER_POINT: Vector2 = $Points/Player.position
@onready var _PLAYER_NEW_COIN_POSITION: Vector2 = _PLAYER_POINT - Vector2(22, 0)
@onready var _PLAYER_FLIP_POSITION: Vector2 = _PLAYER_NEW_COIN_POSITION - Vector2(0, 25)
@onready var CHARON_NEW_COIN_POSITION: Vector2 = _CHARON_POINT - Vector2(22, 0)
@onready var _CHARON_FLIP_POSITION: Vector2 = CHARON_NEW_COIN_POSITION
@onready var _LIFE_FRAGMENT_PILE_POINT: Vector2 = $Points/LifeFragmentPile.position
@onready var _SOUL_FRAGMENT_PILE_POINT: Vector2 = $Points/SoulFragmentPile.position
@onready var _ARROW_PILE_POINT: Vector2 = $Points/ArrowPile.position
@onready var _MAP_SHOWN_POINT = $Points/MapShown.position
@onready var _MAP_HIDDEN_POINT = $Points/MapHidden.position
@onready var _MAP_INITIAL_POINT = $Points/MapInitial.position
@onready var _DEEP_BREATH_REGEN_POINT = $Points/DeepBreathRegen.position

@onready var _DEATH_SPIRALS = [$DeathSpiral, $DeathSpiral2, $DeathSpiral3, $DeathSpiral4, $DeathSpiral5, $DeathSpiral6]
@onready var _TRIAL_TINT_FX = $TrialTint/FX
@onready var _NEMESIS_TINT_FX = $NemesisTint/FX
@onready var _CHARON_TINT_FX = $CharonTint/FX
const _TINT_TIME = 0.25
const _TINT_ALPHA = 0.075
@onready var _CHARON_FOG_FX = $CharonFog/FX
@onready var _VIGNETTE_FX = $VignetteLayer/FX
@onready var _VIGNETTE_PULSATE_FX = $VignettePulsateLayer/FX
@onready var _VIGNETTE_CHARON_FX = $VignetteCharonLayer/FX
@onready var _VIGNETTE_DEATH_FX = $VignetteDeathLayer/FX

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

@onready var PATRON_TOKEN_POSITION: Vector2 = $Table/PatronToken.position

@onready var _TABLE = $Table
@onready var _DIALOGUE: DialogueSystem = $UI/DialogueSystem

@onready var _patron_token: PatronToken = $Table/PatronToken

@onready var _LEFT_HAND: CharonHand = $Table/CharonHandLeft
@onready var _RIGHT_HAND: CharonHand = $Table/CharonHandRight

@onready var _SPEEDRUN_TIMER: SpeedrunTimer = $UI/SpeedrunTimer

@onready var _EMBERS_PARTICLES = $Embers
@onready var _TRIAL_EMBERS_PARTICLES = $TrialEmbers

@onready var _SOUL_TOOLTIP_EMITTER = $Table/SoulTooltipEmitter
@onready var _LIFE_TOOLTIP_EMITTER = $Table/LifeTooltipEmitter

@onready var _CAMERA = $Camera

const _SHOP_CONTINUE_DELAY_TIMER = "SHOP_CONTINUE_DELAY_TIMER"
const _SHOP_CONTINUE_DELAY = 0.5#seconds

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
func last_coin_power_used_this_round() -> PF.PowerFamily:
	if Global.powers_this_round == 0: #if no powers have been used, nothing is the last power used this round
		return null
	
	# this is lazy but whatever
	var rev = powers_used.duplicate()
	rev.reverse()
	
	for power in rev:
		# arrows don't count for this
		if power != Global.POWER_FAMILY_ARROW_REFLIP:
			return power 
	return null

var malice_activations_this_game := 0

func _ready() -> void:
	assert(_COIN_ROW)
	assert(_SHOP)
	assert(_SHOP_MAT)
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
	assert(_CHARON_SHOOTER)
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
	assert(_VIGNETTE_FX)
	assert(_VIGNETTE_PULSATE_FX)
	assert(_VIGNETTE_CHARON_FX)
	assert(_VIGNETTE_DEATH_FX)
	
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
	_VIGNETTE_FX.get_parent().show() #...and this vignette!
	_VIGNETTE_FX.hide()
	_VIGNETTE_PULSATE_FX.get_parent().show() #...and this vignette!
	_VIGNETTE_PULSATE_FX.hide()
	_VIGNETTE_CHARON_FX.get_parent().show() #...and this vignette!
	_VIGNETTE_CHARON_FX.hide()
	_VIGNETTE_DEATH_FX.get_parent().show() #...and this vignette!
	_VIGNETTE_DEATH_FX.hide()
	_CHARON_FOG_FX.hide()
	_TRIAL_TINT_FX.hide()
	_NEMESIS_TINT_FX.hide()
	_CHARON_TINT_FX.hide()
	_LIFE_DELTA_LABEL.hide()
	_SOUL_DELTA_LABEL.hide()
	_SOUL_DELTA_LABEL.disable()
	_LIFE_DELTA_LABEL.disable()
	
	_SHOP.set_coin_spawn_point(CHARON_NEW_COIN_POSITION)
	_ENEMY_ROW.set_coin_spawn_point(CHARON_NEW_COIN_POSITION)
	
	_VOYAGE_MAP.position = _MAP_INITIAL_POINT #offscreen
	_VOYAGE_MAP.rotation_degrees = -90
	
	# delete all existing coins
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		coin.queue_free()
		coin.get_parent().remove_child(coin)
	
	# kinda a hack making these global but w/e
	Global._coin_row = _COIN_ROW
	Global._enemy_row = _ENEMY_COIN_ROW
	Global._shop_row = _SHOP_COIN_ROW
	Global._game = self
	
	Global.state_changed.connect(_on_state_changed)
	Global.life_count_changed.connect(_on_life_count_changed)
	Global.souls_count_changed.connect(_on_soul_count_changed)
	Global.arrow_count_changed.connect(_on_arrow_count_changed)
	Global.toll_coins_changed.connect(_show_toll_dialogue)
	Global.malice_changed.connect(_on_malice_changed)
	Global.active_coin_power_family_changed.connect(_on_active_coin_power_family_changed)

func _on_active_coin_power_family_changed() -> void:
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		if Global.active_coin_power_family == null:
			coin.set_can_target(false)
		else:
			var row = coin.get_parent()
			var left = row.get_left_of(coin)
			var right = row.get_right_of(coin)
			coin.set_can_target(Global.active_coin_power_family.can_use(self, coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW).can_use)

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
		arrow.position = _ARROW_PILE_POINT
		_ARROWS.add_child(arrow)

func _on_soul_count_changed(change: int) -> void:
	_SOUL_TOOLTIP_EMITTER.enable() if Global.souls > 0 else _SOUL_TOOLTIP_EMITTER.disable()
	_update_fragment_pile(Global.souls, _SOUL_FRAGMENT_SCENE, _SOUL_FRAGMENTS, _CHARON_POINT, _CHARON_POINT, _SOUL_FRAGMENT_PILE_POINT, Vector2(16, 9))
	_SOUL_DELTA_LABEL.add_delta(change)
	_LIFE_DELTA_LABEL.refresh()
	
	while change > 0:
		Audio.play_sfx(SFX.PayoffGainSouls)
		change -= 5

func _on_life_count_changed(change: int) -> void:
	_LIFE_TOOLTIP_EMITTER.enable() if Global.lives > 0 else _LIFE_TOOLTIP_EMITTER.disable()
	_update_fragment_pile(Global.lives, _LIFE_FRAGMENT_SCENE, _LIFE_FRAGMENTS, _PLAYER_POINT, _CHARON_POINT, _LIFE_FRAGMENT_PILE_POINT, Vector2(16, 13))
	if not (Global.lives == 0 and change > 0): # don't show delta label for 'restoring' back to 0 life after surviving second chance flip
		_LIFE_DELTA_LABEL.add_delta(change)
		_SOUL_DELTA_LABEL.refresh()
	
	if Global.state == Global.State.BEFORE_FLIP or Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.CHARON_OBOL_FLIP:
		if change < 0:
			Audio.play_sfx(SFX.LoseLife)
		
		# vignette flash
		if Global.lives <= 0:
			_VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.SEVERE)
		elif Global.lives <= 20:
			_VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.HEAVY)
		elif Global.lives <= 50:
			_VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.MODERATE)
		elif change < 0:
			_VIGNETTE_FX.flash_vignette(FX.VignetteSeverity.SLIGHT)
		
		# update vignette pulsate
		if Global.lives > 0 and Global.lives <= 20:
			_VIGNETTE_PULSATE_FX.start_vignette_pulsate(FX.VignettePulsateSeverity.MINOR)
		else:
			_VIGNETTE_PULSATE_FX.stop_vignette_pulsate()
	
	# if we ran out of life, initiate last chance flip
	if Global.lives < 0:
		await _wait_for_dialogue("You are out of life...")
		if Global.is_current_round_trial() or Global.is_current_round_nemesis():
			Global.state = Global.State.GAME_OVER
		else:
			Global.state = Global.State.CHARON_OBOL_FLIP

func _update_fragment_pile(amount: int, scene: Resource, pile: Node, give_pos: Vector2, take_pos: Vector2, pile_pos: Vector2, pile_size: Vector2) -> void:
	var delta = pile.get_child_count() - max(0, amount) if pile.get_child_count() > max(0, amount) else amount - pile.get_child_count()
	
	# helper lambda to calculate delay time
	var calc_delay = func(i) -> float:
		if delta <= 30:
			return i * 0.01
		return i * 30 * 0.01 / delta
	
	# helper lambda to spawn a fragment
	var spawn_frag = func(i):
		var fragment = scene.instantiate()
		pile.add_child(fragment)
		fragment.start_trail_particles()
		fragment.position = give_pos
		
		var target_pos = Global.get_random_point_in_ellipse(pile_pos, pile_size)
		
		# move from player to pile
		var tween = create_tween()
		tween.tween_interval(calc_delay.call(i))
		tween.tween_property(fragment, "position", target_pos, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		
		await tween.finished
		fragment.stop_trail_particles()
	
	var fragment_count = 0
	
	# we have too many; move from pile to charon
	while pile.get_child_count() > max(0, amount):
		fragment_count += 1
		
		var fragment = pile.get_child(0)
		fragment.start_trail_particles()
		pile.remove_child(fragment)
		_DELETING_FRAGMENTS.add_child(fragment)
		
		# visually move it from pile to charon
		var tween = create_tween()
		tween.tween_interval(calc_delay.call(fragment_count))
		tween.tween_property(fragment, "position", take_pos, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN_OUT)
		tween.tween_callback(fragment.queue_free)
	
	# we have too few; spawn some in and move to this pile
	while pile.get_child_count() < amount:
		fragment_count += 1
		spawn_frag.call(fragment_count)

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
	
	# remove vigentte life pulsating outside of round
	if Global.state != Global.State.AFTER_FLIP and Global.state != Global.State.BEFORE_FLIP and Global.state != Global.State.CHARON_OBOL_FLIP:
		_VIGNETTE_PULSATE_FX.stop_vignette_pulsate()
	
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
		_CHARON_COIN_ROW.retract(CHARON_NEW_COIN_POSITION)
	else:
		_COIN_ROW.retract(_PLAYER_NEW_COIN_POSITION)
	_CHARON_COIN_ROW.visible = Global.state == Global.State.CHARON_OBOL_FLIP
	
	if Global.state == Global.State.CHARON_OBOL_FLIP:
		if Global.DEBUG_SKIP_LAST_CHANCE_FLIP:
			_on_game_end() # for debugging - comment out below and make this active to skip obol flip
		else:
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
			_VIGNETTE_CHARON_FX.start_vignette_pulsate(FX.VignettePulsateSeverity.MINOR
			)
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
		_VIGNETTE_DEATH_FX.flash_vignette(FX.VignetteSeverity.SLIGHT)
		await _wait_for_dialogue("You were a fool to come here.")
		_VIGNETTE_DEATH_FX.flash_vignette(FX.VignetteSeverity.MODERATE)
		await _wait_for_dialogue("And now...")
		_VIGNETTE_DEATH_FX.flash_vignette(FX.VignetteSeverity.HEAVY)
		await _wait_for_dialogue("Your soul is mine!")
		
		var skew_tween = _activate_charon_malice_hands()
		_disable_interaction_coins_and_patron()
		UITooltip.disable_all_tooltips()
		_PLAYER_TEXTBOXES.make_invisible()
		_map_is_disabled = true
		_CHARON_FOG_FX.fade_in(_TINT_TIME) # aggressive fog wave
		for spiral in _DEATH_SPIRALS:
			spiral.show()
		_DEATH_SPIRALS[0].emitting = true
		_VIGNETTE_DEATH_FX.flash_vignette(FX.VignetteSeverity.SEVERE)
		await Global.delay(1.0)
		_DEATH_SPIRALS[1].emitting = true
		_VIGNETTE_DEATH_FX.flash_vignette(FX.VignetteSeverity.SEVERE)
		await Global.delay(0.9)
		_DEATH_SPIRALS[2].emitting = true
		_VIGNETTE_DEATH_FX.start_vignette_pulsate(FX.VignettePulsateSeverity.STRONG)
		await Global.delay(0.8)
		_DEATH_SPIRALS[3].emitting = true
		await Global.delay(0.7)
		_DEATH_SPIRALS[4].emitting = true
		await Global.delay(0.5)
		_DEATH_SPIRALS[5].emitting = true
		await Global.delay(1.0)
		skew_tween.kill()
		_disable_charon_malice_hands()
	_LEFT_HAND.unlock()
	_LEFT_HAND.move_offscreen()
	_RIGHT_HAND.unlock()
	_RIGHT_HAND.move_offscreen()
	Global.state = Global.State.INACTIVE
	emit_signal("game_ended", victory)

func on_start() -> void: #reset
	_CAMERA.make_current()
	# tried this but not really digging it
	#_CAMERA.zoom = Vector2(4, 4)
	#create_tween().tween_property(_CAMERA, "zoom", Vector2(1, 1), 0.25)
	
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
	Global.tutorial_pointed_out_can_destroy_monster = false
	
	var charons_obol = _COIN_SCENE.instantiate()
	_CHARON_COIN_ROW.add_child(charons_obol)
	charons_obol.flip_complete.connect(_on_flip_complete)
	charons_obol.turn_complete.connect(_on_turn_complete)
	charons_obol.init_coin(Global.CHARON_OBOL_FAMILY, Global.Denomination.OBOL, Coin.Owner.NEMESIS)
	_CHARON_COIN_ROW.hide()
	
	# randomize and set up the nemesis & trials
	Global.randomize_voyage()
	Global.generate_coinpool()
	_VOYAGE_MAP.update()
	
	if Global.patron == null: # tutorial - use Charon
		Global.patron = Global.patron_for_enum(Global.PatronEnum.CHARON)
	_make_patron_token()
	if Global.patron == Global.patron_for_enum(Global.PatronEnum.CHARON): # tutorial - starts offscreen
		_patron_token.position = _CHARON_POINT

	_SOUL_TOOLTIP_EMITTER.disable()
	_LIFE_TOOLTIP_EMITTER.disable()
	
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
	Global.ignite_damage = Global.DEFAULT_IGNITE_DAMAGE
	Global.shop_rerolls = 0
	Global.toll_coins_offered = []
	Global.toll_index = 0
	Global.malice = 0
	_COIN_ROW.expand()
	for spiral in _DEATH_SPIRALS:
		spiral.emitting = false
		spiral.hide()
	_VIGNETTE_DEATH_FX.stop_vignette_pulsate()
	_VIGNETTE_CHARON_FX.stop_vignette_pulsate()
	_VIGNETTE_PULSATE_FX.stop_vignette_pulsate()
	_MALICE_DUST.hide()
	_MALICE_DUST_RED.hide()
	Global.flame_boost = 0.0
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
		await _wait_for_dialogue("I am the ferryman Charon, shepherd of the dead!")
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
	_patron_token.position = PATRON_TOKEN_POSITION
	_patron_token.clicked.connect(_on_patron_token_clicked)
	_patron_token.name = "PatronToken"
	_TABLE.add_child(_patron_token)
	Global._patron_token = _patron_token # uppowerdate global's ref to this...

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
			_VIGNETTE_CHARON_FX.stop_vignette_pulsate()
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
			_CHARON_COIN_ROW.retract(CHARON_NEW_COIN_POSITION)
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
				await _wait_for_dialogue(Global.replace_placeholders("You can use its (POWER) before accepting payoff."))
				await _tutorial_fade_out()
				_DIALOGUE.show_dialogue(Global.replace_placeholders("Activate the (POWER) by clicking this coin."))
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
				tween.tween_property(_patron_token, "position", PATRON_TOKEN_POSITION, 0.5).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
				await _wait_for_dialogue("Take this...")
				await _wait_for_dialogue("This is a patron token.")
				await _wait_for_dialogue("It calls upon the power of a higher being.")
				await _wait_for_dialogue("Patron tokens are always available.")
				await _wait_for_dialogue(Global.replace_placeholders("Tokens have both an activated (POWER_PATRON) and a (PASSIVE)."))
				await _wait_for_dialogue(Global.replace_placeholders("For its (PASSIVE), which is always active..."))
				await _wait_for_dialogue(Global.replace_placeholders("If all your coins end on (HEADS), you'll earn an extra 5(SOULS)."))
				await _wait_for_dialogue(Global.replace_placeholders("And for its (POWER_PATRON)..."))
				await _wait_for_dialogue(Global.replace_placeholders("This one turns a coin over and makes it (LUCKY)."))
				await _wait_for_dialogue(Global.replace_placeholders("Try using the patron's (POWER_PATRON) now."))
				await _tutorial_fade_out()
				Global.temporary_set_z(_LEFT_HAND, _COIN_ROW.z_index + 1) # make sure hand appears over coins
				_LEFT_HAND.point_at(PATRON_TOKEN_POSITION + Vector2(22, 5)) # $hack$ this is hardcoded, whatever
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
				await _wait_for_dialogue("As monsters are coins, powers can be used on them.")
				await _wait_for_dialogue("Reflipping it may change its action, for example.")
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
		Global.earn_souls(coin.get_active_souls_payoff())
		coin.turn()

func _play_charon_life_grab() -> void:
	await _LEFT_HAND.move_to_life_grab_position(0.2)
	_reset_hands_during_round(0.4)

func _on_toss_button_clicked() -> void:
	if Global.state == Global.State.CHARON_OBOL_FLIP:
		for coin in _CHARON_COIN_ROW.get_children():
			safe_flip(coin, true)
		return
	
	if _COIN_ROW.get_child_count() == 0:
		_DIALOGUE.show_dialogue("No coins...")
		return
	
	# take life from player
	var ante = Global.ante_cost()
	
	# don't allow player to kill themselves here if continue isn't disabled (ie if this isn't a trial or nemesis round)
	if Global.lives < ante and not _END_ROUND_TEXTBOX.disabled: 
		_DIALOGUE.show_dialogue("Not enough life...")
		return
	
	Global.lives -= ante
	if ante > 0:
		_play_charon_life_grab()
		LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % ante, _DEEP_BREATH_REGEN_POINT, self)
	
	if Global.lives < 0:
		return

	_PLAYER_TEXTBOXES.make_invisible()
	_map_is_disabled = true
	#_ENEMY_COIN_ROW.retract_for_toss(_CHARON_FLIP_POSITION)
	await _COIN_ROW.retract_for_toss(_PLAYER_FLIP_POSITION)
	_COIN_ROW.expand_for_toss()
	_ENEMY_COIN_ROW.expand_for_toss()
	
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_FATE): #just a graphical flourish
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_FATE)
	
	# flip all the coins
	for coin in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		coin = coin as Coin
		coin.on_toss_initiated()
		
		if Global.tutorialState == Global.TutorialState.ROUND1_FIRST_HEADS:
			safe_flip(coin, true, 1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND1_FIRST_TAILS:
			safe_flip(coin, true, -1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_INTRO or (Global.tutorialState == Global.TutorialState.ROUND2_SHOP_BEFORE_UPGRADE and Global.tosses_this_round % 2 == 0):
			if coin.get_coin_family() == Global.ZEUS_FAMILY:
				safe_flip(coin, true, 1000000)
			else:
				safe_flip(coin, true, -1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE:
			safe_flip(coin, true, -1000000)
		elif Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
			safe_flip(coin, true, -1000000)
		else:
			safe_flip(coin, true)

func safe_flip(coin: Coin, is_toss: bool, bonus: int = 0) -> void:
	flips_pending += 1
	_map_is_disabled = true
	_PLAYER_TEXTBOXES.make_invisible()
	coin.flip(is_toss, bonus)

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
	for c in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		# skip over coins that have been destroyed
		if not is_instance_valid(c) or c.is_being_destroyed():
			continue
		
		var payoff_coin: Coin = c as Coin
		var payoff_power_family: PF.PowerFamily = payoff_coin.get_active_power_family()
		var charges = payoff_coin.get_active_power_charges()
		var row = payoff_coin.get_parent()
		var left = row.get_left_of(payoff_coin)
		var right = row.get_right_of(payoff_coin)
		var is_last_player_coin = _COIN_ROW.get_child(_COIN_ROW.get_child_count()-1) == payoff_coin
		
		if payoff_power_family.is_payoff() and (not payoff_coin.is_stone() and not payoff_coin.is_blank() and not payoff_coin.is_buried()) and charges > 0:
			await payoff_coin.payoff_move_up()
			
			var can_use_result: PF.PowerFamily.CanUseResult = payoff_power_family.can_use(self, payoff_coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW)
			
			if not can_use_result.can_use:
				payoff_coin.play_shake_effect()
			else:
				# actually do the power
				payoff_coin.play_power_used_effect(payoff_coin.get_active_power_family())
				await payoff_power_family.use_power(self, payoff_coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW)
			
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
			
			if payoff_coin.is_fleeting():
				payoff_coin.FX.flash(Color.WHITE)
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
					possibly_ignited_coin.payoff_move_up()
					Global.lives -= Global.ignite_damage
					_update_payoffs()
					await Global.delay(0.15)
					possibly_ignited_coin.payoff_move_down()
					await Global.delay(0.15)
					if Global.lives < 0:
						Global.payoffs_this_round += 1
						return
			resolved_ignite = true
	
	# post payoff actions
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_TORTURE): # every payoff, downgrade highest value coin
		var targets = []
		
		var coins = _COIN_ROW.get_highest_valued_heads_that_can_be_targetted()
		var is_only_obol = coins.size() == 1 and _COIN_ROW.get_child_count() == 1 and coins[0].get_denomination() == Global.Denomination.OBOL

		if not coins.is_empty() and not is_only_obol:
			targets.append(Global.choose_one(coins))
		var callback = func(target):
			downgrade_coin(target)
			target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_TORTURE)

		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_TORTURE)
		await ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_TORTURE), targets, callback)
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_MISFORTUNE): # every payoff, unlucky coins
		var targets = Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]), Global.MISFORTUNE_QUANTITY)
		var callback = func(target):
			target.make_unlucky()
			target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_MISFORTUNE)
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_MISFORTUNE)
		await ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_MISFORTUNE), targets, callback)
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_VENGEANCE): # every payoff, curse highest value heads
		var targets = Global.choose_x(_COIN_ROW.get_highest_valued_heads_that_can_be_targetted(), 1)
		var callback = func(target):
			target.curse()
			target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_VENGEANCE)
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_VENGEANCE)
		await ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_VENGEANCE), targets, callback)
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_SILENCE): # every payoff, bury leftmost coin for 10 tosses
		var targets = []
		for c in _COIN_ROW.get_leftmost_to_rightmost():
			if c.can_target():
				targets.append(c)
				break
		var callback = func(target):
			target.bury(10)
			target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_SILENCE)
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_SILENCE)
		await ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_SILENCE), targets, callback)
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_COLLAPSE): # collapse trial - each tails becomes cursed + frozen
		for coin in _COIN_ROW.get_children():
			if coin.is_tails():
				coin.desecrate()
				Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_COLLAPSE)
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_OVERLOAD): # overload trial - lose 1 life per unused power charge
		var passive_coin = Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_OVERLOAD)
		for coin in _COIN_ROW.get_children():
			if coin.is_active_face_power():
				coin.FX.flash(Color.DARK_SLATE_BLUE)
				Global.lives -= coin.get_active_power_charges()
				LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % coin.get_active_power_charges(), passive_coin.get_label_origin(), self)
				Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_OVERLOAD)
	
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_CHARON) and Global.tutorial_patron_passive_active:
		if _COIN_ROW.get_filtered(CoinRow.FILTER_HEADS).size() == _COIN_ROW.get_child_count():
			if Global.tutorialState != Global.TutorialState.INACTIVE and not Global.tutorial_pointed_out_patron_passive:
				await _tutorial_fade_in([_COIN_ROW, _patron_token, _SOUL_FRAGMENTS, _SOUL_LABEL])
				_patron_token.disable_interaction_enable_tooltip()
				await _wait_for_dialogue(Global.replace_placeholders("Ah, all your coins are heads(HEADS)!"))
				_LEFT_HAND.point_at(PATRON_TOKEN_POSITION + Vector2(22, 5)) # $hack$ this is hardcoded, whatever
				_LEFT_HAND.lock()
				await _wait_for_dialogue(Global.replace_placeholders("Your patron has a (PASSIVE) bonus for that..."))
				_LEFT_HAND.unlock()
				_LEFT_HAND.unpoint()
			Global.earn_souls(5)
			LabelSpawner.spawn_label(Global.SOUL_UP_PAYOFF_FORMAT % 5, _patron_token.get_label_origin(), self)
			if Global.tutorialState != Global.TutorialState.INACTIVE and not Global.tutorial_pointed_out_patron_passive:
				await _wait_for_dialogue(Global.replace_placeholders("You earn 5 extra souls(SOULS)."))
				await _wait_for_dialogue(Global.replace_placeholders("Well done."))
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
		await _wait_for_dialogue(Global.replace_placeholders("You must pay an Ante ofF %d(LIFE) for this toss." % Global.ante_cost()))
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
	
	if Global.tutorialState != Global.TutorialState.INACTIVE and Global.tutorial_pointed_out_can_destroy_monster == false and _ENEMY_COIN_ROW.get_child_count() != 0 and Global.souls >= _ENEMY_COIN_ROW.get_child(0).get_appeasal_price():
		await _tutorial_fade_in([_ENEMY_ROW, _SOUL_FRAGMENTS, _SOUL_LABEL])
		await _wait_for_dialogue(Global.replace_placeholders("Ah, you've acquired a decent number of souls(SOULS)..."))
		_LEFT_HAND.point_at(_hand_point_for_coin(_ENEMY_COIN_ROW.get_child(0)))
		_LEFT_HAND.lock()
		await _wait_for_dialogue(Global.replace_placeholders("Souls(SOULS) can be used to destroy monsters."))
		_LEFT_HAND.unlock()
		_LEFT_HAND.unpoint()
		await _wait_for_dialogue("You may click on this monster to banish it.")
		var price = _ENEMY_COIN_ROW.get_child(0).get_appeasal_price()
		await _wait_for_dialogue(Global.replace_placeholders("Of course, that will cost you %d souls(SOULS)..." % price))
		await _wait_for_dialogue("Is the benefit worth the price?")
		await _wait_for_dialogue("You may prefer to save your souls for the shop.")
		await _wait_for_dialogue("This choice is yours to make.")
		await _wait_for_dialogue("Now then...")
		await _tutorial_fade_out()
		Global.tutorial_pointed_out_can_destroy_monster = true
	
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
	Audio.play_sfx(SFX.OpenMap)
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
	Audio.play_sfx(SFX.CloseMap)
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

func spawn_enemy(family: Global.CoinFamily, denom: Global.Denomination, index: int = -1) -> Coin:
	var new_enemy = _ENEMY_ROW.spawn_enemy(family, denom, index)
	connect_enemy_coins()
	_reset_hands_during_round()
	return new_enemy

func can_spawn_enemy() -> bool:
	return _ENEMY_ROW.can_spawn_enemy()

func _advance_round() -> void:
	Global.state = Global.State.VOYAGE
	_DIALOGUE.show_dialogue("Now let us sail...")
	_PLAYER_TEXTBOXES.make_invisible()
	_RIVER_LEFT.play_movement_animation()
	_RIVER_RIGHT.play_movement_animation()
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
		await _wait_for_dialogue(Global.replace_placeholders("To pass, you must pay a certain value(VALUE) worth of coins(COIN)."))
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
				var wait_and_destroy = func(tooltip) -> void:
					await Global.delay(0.1)
					await Global.left_click_input
					tooltip.destroy_tooltip()
				
				if Global.is_difficulty_active(Global.Difficulty.CRUEL3) and (rnd.roundType == Global.RoundType.TRIAL1 or rnd.roundType == Global.RoundType.TRIAL2):
					await _LEFT_HAND.point_at(_VOYAGE_MAP.node_position(i) + Vector2(3, -2)) # point at upper
					await wait_and_destroy.call(_VOYAGE_MAP.make_tooltip(i, 0))
					_PLAYER_TEXTBOXES.make_invisible() # hide while moving hand...
					await _LEFT_HAND.point_at(_VOYAGE_MAP.node_position(i) + Vector2(8, 5)) # point at lower
					await wait_and_destroy.call(_VOYAGE_MAP.make_tooltip(i, 1))
				else:
					await _LEFT_HAND.point_at(_VOYAGE_MAP.node_position(i) + Vector2(6, 3))
					await wait_and_destroy.call(_VOYAGE_MAP.make_tooltip(i, 0))
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
	
	match colorStyle: # also recolor the particles, and charon's hand
		River.ColorStyle.PURPLE:
			create_tween().tween_property(_EMBERS_PARTICLES, "modulate", Color("#bc4a9b"), 0.5)
			create_tween().tween_property(_TRIAL_EMBERS_PARTICLES, "modulate", Color("#bc4a9b"), 0.5)
			_LEFT_HAND.recolor(CharonHand.ColorStyle.PURPLE)
			_RIGHT_HAND.recolor(CharonHand.ColorStyle.PURPLE)
		River.ColorStyle.GREEN:
			create_tween().tween_property(_EMBERS_PARTICLES, "modulate", Color("#cdf7e2"), 0.5)
			create_tween().tween_property(_TRIAL_EMBERS_PARTICLES, "modulate", Color("#cdf7e2"), 0.5)
			_LEFT_HAND.recolor(CharonHand.ColorStyle.GREEN)
			_RIGHT_HAND.recolor(CharonHand.ColorStyle.GREEN)
		River.ColorStyle.RED:
			create_tween().tween_property(_EMBERS_PARTICLES, "modulate", Color("#df3e23"), 0.5)
			create_tween().tween_property(_TRIAL_EMBERS_PARTICLES, "modulate", Color("#df3e23"), 0.5)
			_LEFT_HAND.recolor(CharonHand.ColorStyle.RED)
			_RIGHT_HAND.recolor(CharonHand.ColorStyle.RED)

func _on_board_button_clicked():
	assert(Global.state == Global.State.BOARDING)
	_advance_round()

func _on_continue_button_pressed():
	assert(Global.state == Global.State.SHOP)
	
	if Global.get_timer(_SHOP_CONTINUE_DELAY_TIMER).time_left > 0.0:
		return # can't continue before a certain delay
	
	_RIGHT_HAND.move_to_default_position()
	_LEFT_HAND.move_to_default_position()
	_LEFT_HAND.set_appearance(CharonHand.Appearance.NORMAL)
	
	var no_lose_souls_states = [Global.TutorialState.ROUND2_POWER_INTRO]
	if not Global.tutorialState in no_lose_souls_states:
		if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
			_SHOP_COIN_ROW.retract(CHARON_NEW_COIN_POSITION)
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
		Global.heal_life(pity_life)
		if pity_life != 0:
			LabelSpawner.spawn_label(Global.LIFE_UP_PAYOFF_FORMAT % pity_life, _DEEP_BREATH_REGEN_POINT, self)

		if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_INTRO:
			await _wait_for_dialogue(Global.replace_placeholders("Let's continue onwards."))
			await _tutorial_fade_out()

	await _advance_round()

func _on_end_round_button_pressed():
	assert(Global.state == Global.State.BEFORE_FLIP or Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.CHARON_OBOL_FLIP)
	_PLAYER_TEXTBOXES.make_invisible()
	_enable_interaction_coins_and_patron()
	for coin in _COIN_ROW.get_children():
		# doomed coins destroyed at this point
		if coin.is_doomed():
			coin.FX.flash(Color.BLACK)
			destroy_coin(coin)
		
		if coin.is_primed():
			coin.FX.flash(Color.ORANGE)
			if coin.can_upgrade():
				coin.upgrade()
		
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
		await _wait_for_dialogue("Now let us continue.")
	
	# if we just won by defeating the nemesis
	if Global.current_round_type() == Global.RoundType.NEMESIS:
		await _wait_for_dialogue("So, you have triumphed.")
		await _wait_for_dialogue("This outcome is most surprising.")
		await _wait_for_dialogue("And it seems our voyage is nearing its end...")
		_advance_round()
		return
	
	Global.powers_this_round = 0
	Global.tosses_this_round = 0
	Global.ignite_damage = Global.DEFAULT_IGNITE_DAMAGE
	Global.ante_modifier_this_round = 0
	Global.souls_earned_this_round = 0
	Global.monsters_destroyed_this_round = 0
	Global.powers_this_round = 0
	_update_payoffs()
	
	Global.state = Global.State.SHOP
	LabelSpawner.destroy_all_labels()
	randomize_and_show_shop()
	
	_RIGHT_HAND.move_offscreen()
	_LEFT_HAND.move_to_retracted_position()
	
	if Global.tutorialState == Global.TutorialState.ROUND1_SHOP_BEFORE_BUYING_COIN:
		_LEFT_HAND.set_appearance(CharonHand.Appearance.NORMAL)
		_LEFT_HAND.lock()
		_SHOP_COIN_ROW.get_child(0).hide_price()
		await _tutorial_fade_in([_SHOP_COIN_ROW, _SOUL_FRAGMENTS, _SOUL_LABEL, _SHOP_MAT])
		await _wait_for_dialogue("Now we move to the next part of the game...")
		await _wait_for_dialogue("Welcome to the shop.")
		await _wait_for_dialogue("Between each round of tosses...")
		await _wait_for_dialogue("You may purchase new coins here.")
		await _wait_for_dialogue(Global.replace_placeholders("I shall accept souls(SOULS) in exchange."))
		await _wait_for_dialogue("Let me show you a new type of coin...")
		_PLAYER_TEXTBOXES.make_invisible() # necessary since wait for dialogue makes em visible...
		await _SHOP.expand()
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
		
	Global.create_timer(_SHOP_CONTINUE_DELAY_TIMER, _SHOP_CONTINUE_DELAY, true) # create a 1sec delay before we can advance
	_PLAYER_TEXTBOXES.make_visible()

func _hand_point_for_coin(coin: Coin) -> Vector2:
	return coin.global_position + Vector2(20, 0)

func _on_coin_hovered(coin: Coin) -> void:
	# hovering coin in shop updates mouse cursor, and if shop coin, charon points
	if not _map_open and Global.state == Global.State.SHOP:
		if coin.is_owned_by_player():
			if not Global.tutorialState in Global.TUTORIAL_NO_UPGRADE:
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
		_DIALOGUE.show_dialogue(Global.replace_placeholders("%d(VALUE) more..." % toll_price_remaining))

func _on_voyage_continue_button_clicked():
	_hide_voyage_map()
	_PLAYER_TEXTBOXES.make_invisible()
	_RIVER_LEFT.stop_movement_animation()
	_RIVER_RIGHT.stop_movement_animation()
	await Global.delay(0.1)
	var first_round = Global.round_count == Global.FIRST_ROUND
	
	# if this is the first round, give an obol
	if first_round:
		if Global.tutorialState != Global.TutorialState.ROUND1_OBOL_INTRODUCTION:
			await _wait_for_dialogue("Place your payment on the table...")
			make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, _PLAYER_NEW_COIN_POSITION) # make a single starting coin
		
			# removed, but kept potentially for later - generate a random bonus starting coin from patron
			#make_and_gain_coin(Global.patron.get_random_starting_coin_family(), Global.Denomination.OBOL)
	
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
			await _wait_for_dialogue(Global.replace_placeholders("To pass, you must pay %d(VALUE)." % Global.current_round_toll()))
			await _wait_for_dialogue(Global.replace_placeholders("Obols are worth 1(VALUE), Diobols 2(VALUE)..."))
			await _wait_for_dialogue(Global.replace_placeholders("Triobols are worth 3(VALUE), and Tetrobols 4(VALUE)."))
			await _tutorial_fade_out()
			_DIALOGUE.show_dialogue("Add a coin to your payment by clicking it.")
			Global.tutorialState = Global.TutorialState.ENDING
		else:
			if Global.toll_index == 0:
				await _wait_for_dialogue("First tollgate...")
			await _wait_for_dialogue(Global.replace_placeholders("You must pay %d(VALUE)..." % Global.current_round_toll()))
			_show_toll_dialogue()
		return
	
	if Global.tutorialState == Global.TutorialState.ROUND1_OBOL_INTRODUCTION:
		_PLAYER_TEXTBOXES.make_invisible()
		await _tutorial_fade_in([_COIN_ROW, _SOUL_FRAGMENTS, _SOUL_LABEL, _LIFE_FRAGMENTS, _LIFE_LABEL])
		await _wait_for_dialogue("Let's begin.")
		await _wait_for_dialogue("The rules are simple.")
		var coin = make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, CHARON_NEW_COIN_POSITION) # make a single starting coin
		_tutorial_show(coin)
		await _wait_for_dialogue("Take this Coin...")
		await _wait_for_dialogue("This is a game about tossing coins.")
		await _wait_for_dialogue("Each Round will consist of multiple Tosses.")
		_LEFT_HAND.point_at(_hand_point_for_coin(_COIN_ROW.get_child(0)))
		var souls_earned = _COIN_ROW.get_child(0).get_active_power_charges()
		Global.souls += souls_earned
		_SOUL_LABEL.fade_in()
		await _wait_for_dialogue(Global.replace_placeholders("If the coin lands on Heads(HEADS), the payoff is +%d Souls(SOULS)." % souls_earned))
		_COIN_ROW.get_child(0).turn()
		Global.souls -= souls_earned
		var life_loss = _COIN_ROW.get_child(0).get_active_power_charges()
		Global.lives += life_loss
		_LIFE_LABEL.fade_in()
		await _wait_for_dialogue(Global.replace_placeholders("If it lands on Tails(TAILS), the penalty is -%d Life(LIFE)." % life_loss))
		var life_regen = Global.current_round_life_regen()
		Global.lives += life_regen - life_loss
		_LEFT_HAND.unpoint()
		_COIN_ROW.get_child(0).turn()
		await _wait_for_dialogue(Global.replace_placeholders("Each round, you will gain %d Life(HEAL)." % life_regen))
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
		_LIFE_LABEL.fade_in()
		_SOUL_LABEL.fade_in()
		
		# refresh lives
		if not Global.is_passive_active(Global.TRIAL_POWER_FAMILY_FAMINE): # famine trial prevents life regen
			Global.lives += Global.current_round_life_regen()
			LabelSpawner.spawn_label(Global.LIFE_UP_PAYOFF_FORMAT % Global.current_round_life_regen(), _DEEP_BREATH_REGEN_POINT, self)
		else:
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_FAMINE)
		
		if Global.current_round_type() == Global.RoundType.NEMESIS: # nemesis - regen an additional 100
			await _wait_for_dialogue("...and steel your nerves...")
			Global.lives += Global.current_round_life_regen()
			LabelSpawner.spawn_label(Global.LIFE_UP_PAYOFF_FORMAT % Global.current_round_life_regen(), _DEEP_BREATH_REGEN_POINT, self)
	
	# for now, disabling...
	#_SOUL_DELTA_LABEL.enable()
	#_LIFE_DELTA_LABEL.enable()
	
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
		await _wait_for_dialogue("Let's begin the third round.")
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
		await _wait_for_dialogue("This is a Monster coin.")
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
					make_and_gain_coin(Global.THORNS_FAMILY, Global.Denomination.OBOL, CHARON_NEW_COIN_POSITION)
					make_and_gain_coin(Global.THORNS_FAMILY, Global.Denomination.OBOL, CHARON_NEW_COIN_POSITION)
					await _wait_for_dialogue("You shall be bound in iron!")
				Global.TRIAL_MISFORTUNE_FAMILY:
					await _wait_for_dialogue("Be shrouded in misfortune!")
				Global.TRIAL_PAIN_FAMILY:
					await _wait_for_dialogue("You flesh writhes in pain!")
				Global.TRIAL_BLOOD_FAMILY:
					await _wait_for_dialogue("Your blood shall boil!")
				Global.TRIAL_EQUIVALENCE_FAMILY:
					await _wait_for_dialogue("Each flip will be one of equivalence!")
				Global.TRIAL_FAMINE_FAMILY:
					await _wait_for_dialogue("Feel the hunger of famine!")
				Global.TRIAL_TORMENT_FAMILY:
					await _wait_for_dialogue("You shall be tormented!")
				Global.TRIAL_MALAISE_FAMILY:
					await _wait_for_dialogue("Feel a deep malaise!")
				Global.TRIAL_VIVISEPULTURE_FAMILY:
					var targets = []
					targets += _COIN_ROW.get_leftmost_to_rightmost().slice(0, 2)
					var callback = func(target):
						target.bury(20)
						target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_VIVISEPULTURE)
					ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_VIVISEPULTURE), targets, callback)
					Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_VIVISEPULTURE)
					await _wait_for_dialogue("Perish by vivisepulture!")
				Global.TRIAL_IMMOLATION_FAMILY:
					await _wait_for_dialogue("Be immolated in flames!")
				Global.TRIAL_VENGEANCE_FAMILY:
					await _wait_for_dialogue("You must fear my vengeance!")
				Global.TRIAL_TORTURE_FAMILY:
					await _wait_for_dialogue("Can you withstand this torture?")
				Global.TRIAL_LIMITATION_FAMILY:
					await _wait_for_dialogue("It is time to feel mortal limitation!")
				Global.TRIAL_COLLAPSE_FAMILY:
					await _wait_for_dialogue("Beware an untimely collapse!")
				Global.TRIAL_SAPPING_FAMILY:
					await _wait_for_dialogue("Your energy shall be sapping.")
				Global.TRIAL_OVERLOAD_FAMILY:
					await _wait_for_dialogue("You may have power, but fear the overload!")
				Global.TRIAL_PETRIFICATION_FAMILY:
					var targets = _COIN_ROW.get_filtered(CoinRow.FILTER_POWER)
					targets += _COIN_ROW.get_leftmost_to_rightmost().slice(0, 2)
					var callback = func(target):
						target.stone()
						target.play_power_used_effect(Global.TRIAL_POWER_FAMILY_PETRIFICATION)
					ProjectileManager.fire_projectiles(Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_PETRIFICATION), targets, callback)
					await _wait_for_dialogue("Feel the strain of petrification!")
				Global.TRIAL_SILENCE_FAMILY:
					await _wait_for_dialogue("All is still. All is silent.")
				Global.TRIAL_POLARIZATION_FAMILY:
					await _wait_for_dialogue("Your coins shall be polarized!")
				Global.TRIAL_SINGULARITY_FAMILY:
					for c in _COIN_ROW.get_children():
						c.reset_power_uses(true)
					Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_SINGULARITY)
					await _wait_for_dialogue("The singularity beckons...")
				Global.TRIAL_GATING_FAMILY:
					await _wait_for_dialogue("You must pass through the gate!")
				Global.TRIAL_FATE_FAMILY:
					await _wait_for_dialogue("Leave it all up to fate!")
				Global.TRIAL_ADVERSITY_FAMILY:
					spawn_enemy(Global.get_standard_monster(), Global.Denomination.TETROBOL)
					spawn_enemy(Global.get_elite_monster(), Global.Denomination.TETROBOL)
					spawn_enemy(Global.get_standard_monster(), Global.Denomination.TETROBOL)
					Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_ADVERSITY)
					await _wait_for_dialogue("Before you stands adversity!")
				Global.TRIAL_VAINGLORY_FAMILY:
					await _wait_for_dialogue("Beware the insidious vainglory!")
	
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
					await _wait_for_dialogue("Behold! The grim visage of the gorgon sisters!")
				Global.SCYLLA_FAMILY:
					await _wait_for_dialogue("Be dashed upon the rocks of Scylla and Charybdis!")
				Global.ECHIDNA_FAMILY:
					await _wait_for_dialogue("The progenitor of all monsters stands before you!")
				Global.CERBERUS_MIDDLE_FAMILY:
					await _wait_for_dialogue("The three-headed beast hungers for blood!")
				Global.MINOTAUR_FAMILY:
					await _wait_for_dialogue("Can you escape the Minotaur's pursuit?")
		
		await _wait_for_dialogue("To continue your voyage...")
		await _wait_for_dialogue("You must defeat the nemesis!")
		await _wait_for_dialogue("Your fate lies with the coins now.")
		await _wait_for_dialogue("Let the final challenge commence!")
	
	if Global.current_round_type() == Global.RoundType.NEMESIS:
		for coin in _ENEMY_COIN_ROW.get_children():
			coin.show_price() # bit of a $HACK$ to prevent nemesis price from being shown... reshow now
	
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
				var coin = make_and_gain_coin(Global.GENERIC_FAMILY, Global.Denomination.TETROBOL, CHARON_NEW_COIN_POSITION)
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

func make_and_gain_coin(coin_family: Global.CoinFamily, denomination: Global.Denomination, initial_position: Vector2, during_round: bool = false) -> Coin:
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
	coin.play_flip_animation(false)

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
func remove_coin_from_row_move_then_destroy(coin: Coin, point: Vector2) -> void:
	_remove_coin_from_row(coin)
	var tween = create_tween()
	tween.tween_property(coin, "position", point, Global.COIN_TWEEN_TIME)
	tween.tween_callback(destroy_coin.bind(coin)) 

func downgrade_coin(coin: Coin) -> void:
	# safety check
	if _COIN_ROW.get_child_count() == 1 and _COIN_ROW.has_coin(coin) and coin.get_denomination() == Global.Denomination.OBOL:
		assert(false, "trying to downgrade last coin and it's an obol!")
		return
	
	if coin.is_being_destroyed():
		return
	if coin.get_denomination() == Global.Denomination.OBOL:
		destroy_coin(coin)
	else:
		coin.downgrade()
		_update_payoffs()

func destroy_coin(coin: Coin) -> void:
	if _COIN_ROW.get_child_count() == 1 and _COIN_ROW.has_coin(coin) and coin.get_denomination() == Global.Denomination.OBOL:
		assert(false, "trying to destroy last coin!")
		return
	
	if coin.is_being_destroyed():
		return
	
	var is_monster = coin.is_monster_coin()
	if is_monster:
		Global.monsters_destroyed_this_round += 1
	
	# take now before removing
	var global_pos = coin.global_position
	var family = coin.get_coin_family()
	var index = coin.get_index() 
	var denom = coin.get_denomination()
	
	var destroyed_monster = coin.is_monster_coin()
	var destroyed_echidna = coin.get_coin_family() == Global.ECHIDNA_FAMILY
	var reborn_on_destroy = coin.get_coin_family().has_tag(Global.CoinFamily.Tag.REBORN_ON_DESTROY)
	var is_labyrinth_wall = coin.get_coin_family().has_tag(Global.CoinFamily.Tag.LABYRINTH_WALL)
	var gain_coin_on_destroy = coin.get_coin_family().has_tag(Global.CoinFamily.Tag.GAIN_COIN_ON_DESTROY)
	
	if coin.get_parent() is CoinRow:
		_remove_coin_from_row(coin)
	# play destruction animation (coin will free itself after finishing)
	coin.destroy()
	_update_payoffs()
	
	if is_labyrinth_wall and Global.is_passive_active(Global.NEMESIS_POWER_FAMILY_LOST_IN_THE_LABYRINTH):
		# find coin...
		var lost_in_lab_coin = _ENEMY_COIN_ROW.find_first_of_family(Global.LABYRINTH_PASSIVE_FAMILY)
		assert(lost_in_lab_coin)
		if lost_in_lab_coin.get_active_power_charges() <= 0:
			return # prevent bad recursion when clearing row...
		
		# subtract a charge
		lost_in_lab_coin.spend_active_face_power_use()
		
		# if we are done, destroy everything
		if lost_in_lab_coin.get_active_power_charges() <= 0:
			# we win. remove all coins from enemy coin row.
			for c in _ENEMY_COIN_ROW.get_children():
				destroy_coin(c)
		# otherweise make a new wall
		else:
			var new_family = [Global.LABYRINTH_WALLS1_FAMILY, Global.LABYRINTH_WALLS2_FAMILY, Global.LABYRINTH_WALLS3_FAMILY, Global.LABYRINTH_WALLS4_FAMILY][Global.RNG.randi_range(0, 3)]
			spawn_enemy(new_family, denom, index)
	
	if gain_coin_on_destroy and _COIN_ROW.get_child_count() != Global.COIN_LIMIT:
		make_and_gain_coin(Global.random_coin_family(), denom, global_pos, true)
	
	if reborn_on_destroy:
		spawn_enemy(family, denom, index)
				
	# search for enrages (hamadryad and typhon)
	for c in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
		if c.get_coin_family().has_tag(Global.CoinFamily.Tag.MELIAE_ON_MONSTER_DESTROYED) and destroyed_monster:
			c.init_coin(Global.MONSTER_MELIAE_FAMILY, c.get_denomination(), Coin.Owner.NEMESIS) # transform into Meliae
		if c.get_coin_family().has_tag(Global.CoinFamily.Tag.ENRAGE_ON_ECHIDNA_DESTROYED) and destroyed_echidna:
			c.init_coin(Global.TYPHON_ENRAGED_FAMILY, c.get_denomination(), Coin.Owner.NEMESIS) # transform into mad Typhon
	
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
	_LIFE_TOOLTIP_EMITTER.disable()
	_SOUL_TOOLTIP_EMITTER.disable()

func _enable_interaction_coins_and_patron() -> void:
	for row in [_COIN_ROW, _ENEMY_COIN_ROW, _CHARON_COIN_ROW, _SHOP_COIN_ROW]:
		row.enable_interaction()
	_patron_token.enable_interaction()
	for arrow in _ARROWS.get_children():
		arrow.enable_interaction()
	_LIFE_TOOLTIP_EMITTER.enable() if Global.lives > 0 else _LIFE_TOOLTIP_EMITTER.disable()
	_SOUL_TOOLTIP_EMITTER.enable() if Global.souls > 0 else _SOUL_TOOLTIP_EMITTER.disable()

func _on_coin_clicked(coin: Coin):
	if _DIALOGUE.is_waiting() or _tutorial_fading:
		return

	if Global.state == Global.State.TOLLGATE:
		# if this coin cannot be offered at a toll, error message and return
		if coin.get_coin_family().has_tag(Global.CoinFamily.Tag.NO_TOLL):
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

	# ignore clicks on monsters after the round ends... (they are still visible while receeding)
	if Global.state == Global.State.SHOP and coin.is_monster_coin():
		return 

	if Global.state == Global.State.SHOP:
		# prevent upgrading coins before tutorial is ready
		if Global.tutorialState in Global.TUTORIAL_NO_UPGRADE:
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
			Global.earn_souls(coin.get_sell_price())
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
			_update_payoffs()
			
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
			if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ARTEMIS) and Global.arrows != Global.ARROWS_LIMIT:
				var arrows_before = Global.arrows
				Global.arrows = min(Global.ARROWS_LIMIT, Global.arrows + 2)
				LabelSpawner.spawn_label(Global.ARROW_UP_PAYOFF_FORMAT % (Global.arrows - arrows_before), _patron_token.get_label_origin(), self)
				Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_ARTEMIS)
			destroy_coin(coin)
			_reset_hands_during_round()
		else:
			_DIALOGUE.show_dialogue("Not enough souls...")
		return
	
	# only use coin powers during after flip
	if Global.state != Global.State.AFTER_FLIP:
		return
	
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_TORMENT) and last_coin_power_used_this_round() == coin.get_active_face_power().power_family\
		and Global.active_coin_power_family == null:
		_DIALOGUE.show_dialogue("Can't activate that power due to trial...")
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_TORMENT)
		return
	
	var row = _get_row_for(coin)
	var left = row.get_left_of(coin)
	var right = row.get_right_of(coin)
	var used_face_power: Coin.FacePower
	
	# if we have a coin power active, we're using a power on this coin; do that
	if Global.active_coin_power_family != null:
		
		# EXCEPTION - patron and arrows do not have an associated active_coin_power_coin, so face_power will be null.
		# in these cases, we early return and don't call after_coin_apower_used.
		if Global.active_coin_power_coin != null:
			used_face_power = Global.active_coin_power_coin.get_active_face_power()
		
		# using a coin on itself deactivates it
		if coin == Global.active_coin_power_coin:
			_deactivate_active_power()
			return
		
		# powers can't be used on trial coins
		if coin.is_trial_coin(): 
			_DIALOGUE.show_dialogue("Can't use a power on that...")
			return
		
		if not coin.can_target():
			if coin.is_buried():
				_DIALOGUE.show_dialogue("Can't target a buried coin...")
				return
			_DIALOGUE.show_dialogue("Can't target that...")
			return
		
		# make sure we have a valid target
		if coin.is_monster_coin() and not Global.active_coin_power_family.can_target_monster_coins():
			_DIALOGUE.show_dialogue("Can't target monsters with that...")
			return
		if coin.is_owned_by_player() and not Global.active_coin_power_family.can_target_player_coins():
			_DIALOGUE.show_dialogue("Can't target your own coins with that...")
			return
		
		# make sure we can't kill ourselves with this activation
		var life_cost = 0
		if Global.active_coin_power_family == Global.POWER_FAMILY_DOWNGRADE_FOR_LIFE:
			if coin.is_monster_coin():
				life_cost += Global.HADES_MONSTER_COST[Global.active_coin_power_coin.get_value() - 1]
		elif Global.active_coin_power_family == Global.POWER_FAMILY_INFINITE_TURN_HUNGER:
			life_cost += Global.active_coin_power_coin.get_active_face_metadata(Coin.METADATA_ERYSICHTHON, 0)
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_BLOOD) and not Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
			life_cost += Global.BLOOD_COST
		if Global.lives - life_cost < 0:
			_DIALOGUE.show_dialogue("Not enough life...")
			return
		
		# trial of blood - using powers costs 1 life (excluding arrows)
		if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_BLOOD) and not Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
			var passive_coin = Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_BLOOD)
			Global.lives -= Global.BLOOD_COST
			Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_BLOOD)
			LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % Global.BLOOD_COST, passive_coin.get_label_origin(), self)
		
		# check if this power can be used on the given target, and show error if not
		var can_use_result: PF.PowerFamily.CanUseResult = Global.active_coin_power_family.can_use(self, coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW)
		if not can_use_result.can_use:
			_DIALOGUE.show_dialogue(Global.replace_placeholders(can_use_result.error_message))
			return
		
		# attempt to activate a patron power
		if Global.is_patron_power(Global.active_coin_power_family):
			Global.active_coin_power_family.use_power(self, coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW, _patron_token)
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
				await _wait_for_dialogue("Coins can be affected by many statuses...")
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
			# needs special handling for tutorial...
			Global.POWER_FAMILY_REFLIP:
				# clicking obol when you've been told to click Zeus to deactivate it
				if Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE:
					_DIALOGUE.show_dialogue("Click the power coin to deactivate it.")
					return
				elif Global.tutorialState == Global.TutorialState.ROUND2_POWER_USED:
					_LEFT_HAND.unlock()
					_LEFT_HAND.unpoint()
					safe_flip(coin, false, 1000000)
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
					Global.active_coin_power_family.use_power(self, coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW)
			Global.POWER_FAMILY_ARROW_REFLIP: # special handling for arrows...
				Global.active_coin_power_family.use_power(self, coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW)
				coin.play_power_used_effect(Global.active_coin_power_family) #manaully play effect since we're returning early
				Global.arrows -= 1
				if Global.arrows == 0:
					Global.active_coin_power_family = null
				return #special case - this power is not from a coin, so just exit immediately
			_:
				Global.active_coin_power_family.use_power(self, coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW)
		after_coin_power_used(Global.active_coin_power_coin, coin, used_face_power)
		
	# otherwise we're attempting to activate a coin
	elif coin.can_activate_power():
		used_face_power = coin.get_active_face_power()
		
		# if this is a power which does not target, resolve it
		if coin.get_active_power_family().power_type == PF.PowerType.POWER_NON_TARGETTING:
			# make sure we can't kill ourselves - this is duplicate code and pretty ugly tbh
			# trial of blood - using powers costs life
			if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_BLOOD): 
				var life_cost = Global.BLOOD_COST
				if Global.lives - life_cost < 0:
					_DIALOGUE.show_dialogue("Not enough life...")
					return
				Global.lives -= Global.BLOOD_COST
				Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_BLOOD)
				var passive_coin = Global.find_passive_coin(Global.TRIAL_POWER_FAMILY_BLOOD)
				LabelSpawner.spawn_label(Global.LIFE_DOWN_PAYOFF_FORMAT % Global.BLOOD_COST, passive_coin.get_label_origin(), self)
			
			coin.get_active_power_family().use_power(self, coin, left, right, row, _COIN_ROW, _ENEMY_COIN_ROW)
			after_coin_power_used(coin, coin, used_face_power)
		
		# otherwise, make this the active coin and coin power and await click on target
		else: 
			if Global.tutorialState == Global.TutorialState.ROUND2_POWER_UNUSABLE: # prevent reactivating the coin after deactivating
				_DIALOGUE.show_dialogue("Accept the result.")
				return
			
			Global.active_coin_power_coin = coin
			Global.active_coin_power_family = coin.get_active_power_family()
			coin.on_coin_power_selected()
			
			if Global.tutorialState == Global.TutorialState.ROUND2_POWER_ACTIVATED:
				var icon = _COIN_ROW.get_child(1).get_heads_icon() 
				await _tutorial_fade_in([_COIN_ROW])
				await _wait_for_dialogue(Global.replace_placeholders("Now, this coin's (POWER),[img=10x13]%s[/img], is active." % icon))
				await _wait_for_dialogue(Global.replace_placeholders("This (POWER) can reflip other coins."))
				await _tutorial_fade_out()
				_DIALOGUE.show_dialogue(Global.replace_placeholders("Click your other coin to use the (POWER) on it."))
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
	
	# if this power does not target, attempt to activate its effect
	if Global.patron.power_family.power_type == PF.PowerType.POWER_NON_TARGETTING:
		var can_use_result: PF.PowerFamily.CanUseResult = Global.patron.power_family.can_use(self, null, null, null, null, _COIN_ROW, _ENEMY_COIN_ROW)
		if not can_use_result.can_use:
			_DIALOGUE.show_dialogue(Global.replace_placeholders(can_use_result.error_message))
			return
		
		Global.active_coin_power_coin = null
		Global.active_coin_power_family = null
		
		Global.patron.power_family.use_power(self, null, null, null, null, _COIN_ROW, _ENEMY_COIN_ROW, _patron_token)
		_patron_token.FX.flash(Color.GOLD)
		_patron_token.play_power_used_effect(Global.patron.power_family)
		Global.patron_uses -= 1
		Global.patron_used_this_toss = true
	else:
		if Global.tutorialState == Global.TutorialState.ROUND3_PATRON_ACTIVATED:
			_DIALOGUE.show_dialogue("Now click a coin to use the patron's power.")
			_LEFT_HAND.unlock()
			_LEFT_HAND.unpoint()
			Global.tutorialState = Global.TutorialState.ROUND3_PATRON_USED
		_patron_token.activate()

func _input(event):
	# right click with a god power disables ith
	# right click with the map open closes it
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if Global.active_coin_power_family != null:
				_deactivate_active_power()
			if _map_open and not Global.state == Global.State.VOYAGE:
				_hide_voyage_map()

func _deactivate_active_power() -> void:
	if _DIALOGUE.is_waiting() or _tutorial_fading:
		return
	
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

func _activate_charon_malice_hands() -> Tween:
	var skew_tween = create_tween().set_loops()
	skew_tween.tween_property(_LEFT_HAND, "skew", PI/8, 0.5)
	skew_tween.parallel().tween_property(_RIGHT_HAND, "skew", -PI/8, 0.5)
	skew_tween.tween_property(_LEFT_HAND, "skew", 0, 0.5)
	skew_tween.parallel().tween_property(_RIGHT_HAND, "skew", 0, 0.5)
	_LEFT_HAND.activate_malice_active_tint()
	_RIGHT_HAND.activate_malice_active_tint()
	_LEFT_HAND.disable_hovering()
	_RIGHT_HAND.disable_hovering()
	_LEFT_HAND.move_to_forward_position()
	_RIGHT_HAND.move_to_forward_position()
	return skew_tween

func _disable_charon_malice_hands() -> void:
	create_tween().tween_property(_LEFT_HAND, "skew", 0, 0.1)
	create_tween().tween_property(_RIGHT_HAND, "skew", 0, 0.1)
	_LEFT_HAND.deactivate_malice_active_tint()
	_RIGHT_HAND.deactivate_malice_active_tint()
	_LEFT_HAND.enable_hovering()
	_RIGHT_HAND.enable_hovering()
	_reset_hands_during_round()

func _reset_hands_during_round(time: float = -1) -> void:
	if _ENEMY_COIN_ROW.get_child_count() == 0:
		_LEFT_HAND.move_to_default_position(time)
		_RIGHT_HAND.move_to_default_position(time)
	else:
		_LEFT_HAND.move_to_retracted_position(time)
		_RIGHT_HAND.move_to_retracted_position(time)

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
	var malice_projectile_params = Projectile.ProjectileParams.new().trajectory(Projectile.TrajectoryType.WOBBLE)
	const charon_delay = 1.0
	
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
	_VIGNETTE_CHARON_FX.start_vignette_pulsate(FX.VignettePulsateSeverity.MINOR)
	# todo - screen shake
	
	await _wait_for_dialogue("Enough!", charon_delay)
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
	
	var skew_tween = _activate_charon_malice_hands()
	
	# create a bunch of heuristics to reference
	# helper functions
	var count_tag = func(arr: Array, tag: PF.PowerFamily.Tag) -> int:
		var c = 0
		for power_family in arr:
			if power_family.has_tag(tag):
				c += 1
		return c

	var powers_reflip = count_tag.call(powers_used, PF.PowerFamily.Tag.REFLIP)
	var powers_freeze = count_tag.call(powers_used, PF.PowerFamily.Tag.FREEZE)
	var powers_lucky = count_tag.call(powers_used, PF.PowerFamily.Tag.LUCKY)
	var _powers_upgrade = count_tag.call(powers_used, PF.PowerFamily.Tag.UPGRADE)
	var powers_gain = count_tag.call(powers_used, PF.PowerFamily.Tag.GAIN)
	var powers_destroy = count_tag.call(powers_used, PF.PowerFamily.Tag.DESTROY)
	var powers_heal = count_tag.call(powers_used, PF.PowerFamily.Tag.HEAL)
	var powers_positioning = count_tag.call(powers_used, PF.PowerFamily.Tag.POSITIONING)
	var powers_bless = count_tag.call(powers_used, PF.PowerFamily.Tag.BLESS)
	
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
	
	var highest_valued_arr = _COIN_ROW.get_highest_valued_that_can_be_targetted()
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
			var targets = []
			
			# aim for lucky coins if we can
			for target in Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_LUCKY, CoinRow.FILTER_CAN_TARGET]), unlucky_remaining):
				targets.append(target)
				unlucky_remaining -= 1
			# now take other coins
			for target in Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_NOT_UNLUCKY, CoinRow.FILTER_CAN_TARGET]), unlucky_remaining):
				targets.append(target)
			
			var callback = func(target):
				target.make_unlucky()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("Your luck falters!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.CURSE:
			var curses_remaining = max(1, floor(num_coins/2.0))
			var targets = []
			
			# aim for blessed coins if we can
			for target in Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_BLESSED, CoinRow.FILTER_CAN_TARGET]), curses_remaining):
				targets.append(target)
				curses_remaining -= 1 
			for target in Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_NOT_CURSED, CoinRow.FILTER_CAN_TARGET]), curses_remaining):
				targets.append(target)
			
			var callback = func(target):
				target.curse()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("Bear a heavy curse!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.IGNITE:
			var ignites_remaining = max(1, floor(num_coins/2.0))
			var targets = []
			
			# attempt to ignite frozen coins if we can
			for target in Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_FROZEN, CoinRow.FILTER_CAN_TARGET]), ignites_remaining):
				targets.append(target)
				ignites_remaining -= 1 
			for target in Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_NOT_IGNITED, CoinRow.FILTER_CAN_TARGET]), ignites_remaining):
				targets.append(target)
			
			var callback = func(target):
				target.ignite()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("You shall burn!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.INCREASE_PENALTY:
			var targets = []
			
			for target in _COIN_ROW.get_children():
				if target.can_change_life_penalty():
					targets.append(target)
			
			var callback = func(target):
				target.change_life_penalty_for_round(2)
				target.change_life_penalty_permanently(1)
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("I shall amplify your pain!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.THORNS:
			make_and_gain_coin(Global.THORNS_FAMILY, highest_denom, CHARON_NEW_COIN_POSITION)
			await _wait_for_dialogue("A gift for you...", charon_delay)
		MaliceAction.STONE_POWERS:
			var targets = Global.choose_x(_COIN_ROW.get_multi_filtered_randomized([CoinRow.FILTER_USABLE_POWER, CoinRow.FILTER_NOT_STONE, CoinRow.FILTER_CAN_TARGET]), max(1, floor(num_coins/4.0)))
			
			var callback = func(target):
				target.stone()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("Be turned to stone!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.STRENGTHEN_MONSTERS:
			var targets = []
			
			for monster in _ENEMY_COIN_ROW.get_children():
				if monster.can_upgrade():
					targets.append(monster)
			
			var callback = func(target):
				target.upgrade()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("My minions grow stronger!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.TURN_PAYOFFS:
			var targets = _COIN_ROW.get_multi_filtered([CoinRow.FILTER_ACTIVE_PAYOFF, CoinRow.FILTER_CAN_TARGET])
			
			var callback = func(target):
				target.turn()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("No souls for you!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.DRAIN_POWERS:
			var targets = _COIN_ROW.get_multi_filtered([CoinRow.FILTER_USABLE_POWER, CoinRow.FILTER_CAN_TARGET])
			
			var callback = func(target):
				target.drain_power_uses_by(2)
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)
			
			_DIALOGUE.show_dialogue("I shall render you powerless!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.SPAWN_MONSTERS:
			var denom = Global.Denomination.OBOL
			if Global.current_round_wave_strength() >= 10:
				denom = Global.Denomination.DIOBOL
			elif Global.current_round_wave_strength() >= 20:
				denom = Global.Denomination.TRIOBOL
			for i in range(0, 2):
				spawn_enemy(Global.get_standard_monster(), denom)
			await _wait_for_dialogue("Rise, thralls of the underworld!", charon_delay)
		MaliceAction.REFLIP_SCRAMBLE_ALL:
			for c in _COIN_ROW.get_children() + _ENEMY_COIN_ROW.get_children():
				c = c as Coin
				c.play_power_used_effect(Global.CHARON_POWER_DEATH)
				safe_flip(c, false)
			_COIN_ROW.shuffle()
			_ENEMY_COIN_ROW.shuffle()
			await _wait_for_dialogue("Scatter and fall!", charon_delay)
		MaliceAction.FREEZE_TAILS:
			var targets = _COIN_ROW.get_multi_filtered([CoinRow.FILTER_TAILS, CoinRow.FILTER_CAN_TARGET])
			
			var callback = func(target):
				target.freeze()
				target.play_power_used_effect(Global.CHARON_POWER_DEATH)

			_DIALOGUE.show_dialogue("Your blood runs cold!")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		MaliceAction.NUKE_VALUABLE:
			var targets = [highest_valued]
			
			var callback = func(target):
				if target.is_heads():
					target.turn()
				target.freeze()
				target.curse()
				target.unlucky()
			
			_DIALOGUE.show_dialogue("So this one is your favorite...?")
			await ProjectileManager.fire_projectiles(_CHARON_SHOOTER, targets, callback, malice_projectile_params)
			await _DIALOGUE.make_current_dialogue_advancable_and_wait()
		_:
			assert(false)
	
	skew_tween.kill()
	_disable_charon_malice_hands()
	Global.malice = 0.0
	_VIGNETTE_CHARON_FX.stop_vignette_pulsate()
	
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
	if Global.malice >= 40:
		_MALICE_DUST.emitting = true
		_MALICE_DUST.show()
	else:
		_MALICE_DUST.emitting = false
		
	if Global.malice >= 60:
		_MALICE_DUST_RED.emitting = true
		_MALICE_DUST.show()
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

func after_coin_power_used(used_coin: Coin, target_coin: Coin, used_face_power: Coin.FacePower):
	assert(used_face_power != null)
	assert(used_coin != null)
	assert(target_coin != null)
	
	used_coin.on_power_used()
	
	powers_used.append(used_face_power.power_family)
	Global.powers_this_round += 1
	
	# malaise trial - subtracts from ALL coins
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_MALAISE):
		for coin in _COIN_ROW.get_children():
			if coin.get_active_face_power().power_family.is_power():
				coin.get_active_face_power().spend_charges(1)
				Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_MALAISE)
	else:
		used_face_power.spend_charges(1)
	
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_IMMOLATION):
		used_coin.ignite()
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_IMMOLATION)
	
	target_coin.play_power_used_effect(used_face_power.power_family)
	
	# remove proteus metadata to stop transforming, if this was Proteus
	if used_face_power.get_metadata(Coin.METADATA_PROTEUS, false): 
		used_coin.FX.flash(Color.AQUA)
		used_face_power.clear_metadata(Coin.METADATA_PROTEUS)
	
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ZEUS):
		if not target_coin.is_being_destroyed():
			target_coin.charge()
			Global.emit_signal("passive_triggered", Global.PATRON_POWER_FAMILY_ZEUS)
	
	_update_payoffs()
	
	# if we're out of charges or no longer a power, cancel
	# also, always cancel for torment trial
	if Global.active_coin_power_coin and (Global.active_coin_power_coin.get_active_power_charges() == 0 or not Global.active_coin_power_coin.is_active_face_power() or Global.active_coin_power_coin.is_being_destroyed()):
		Global.active_coin_power_coin = null
		Global.active_coin_power_family = null
	
	# update to ensure that the power family matches the active face, in case the coin turned but is still a power
	# or in case the power was transformed
	if Global.active_coin_power_coin:
		Global.active_coin_power_family = Global.active_coin_power_coin.get_active_power_family()
	
	# now, in the case where the power or face changed and the new power family does not target, deselect coin.
	if Global.active_coin_power_family != null and Global.active_coin_power_family.power_type == PF.PowerType.POWER_NON_TARGETTING: # if we copied a non-targetting power, deactivate
		Global.active_coin_power_coin = null
		Global.active_coin_power_family = null
	
	# torment trial - if the last coin power used matches the current power, deactivate
	if Global.is_passive_active(Global.TRIAL_POWER_FAMILY_TORMENT) and last_coin_power_used_this_round() == Global.active_coin_power_family:
		Global.active_coin_power_coin = null
		Global.active_coin_power_family = null
		Global.emit_signal("passive_triggered", Global.TRIAL_POWER_FAMILY_TORMENT)
	
	Global.malice += Global.MALICE_INCREASE_ON_POWER_USED * Global.current_round_malice_multiplier()
	if Global.malice >= Global.MALICE_ACTIVATION_THRESHOLD_AFTER_POWER:
		await activate_malice(MaliceActivation.DURING_POWERS)
