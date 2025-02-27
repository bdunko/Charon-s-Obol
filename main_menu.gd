extends Node2D

signal start_game

@onready var _MAIN_UI = $MainUI
@onready var _CHARACTER_SELECTOR: ArrowSelector = $MainUI/Selector/Character
@onready var _CHARACTER_DESCRIPTION: RichTextLabel = $MainUI/DescriptionContainer/CharacterDescription
@onready var _DIFFICULTY_SELECTOR = $MainUI/Selector/Difficulty
@onready var _MAIN_UI_EMBERS_CHARACTER = $MainUI/EmbersCharacter

@onready var _MAIN_UI_EMBERS_RED = $MainUI/EmbersRed
@onready var _MAIN_UI_EMBERS_PURPLE = $MainUI/EmbersPurple
@onready var _MAIN_UI_EMBERS_MORE_RED = $MainUI/EmbersMoreRed
@onready var _MAIN_UI_EMBERS_MORE_PURPLE = $MainUI/EmbersMorePurple

@onready var _UNLOCK_UI = $UnlockUI

@onready var _UNLOCK_CHARACTER_UI = $UnlockUI/CharacterUI
@onready var _UNLOCK_CHARACTER_LABEL = $UnlockUI/CharacterUI/Character
@onready var _UNLOCK_CHARACTER_DESCRIPTION_LABEL = $UnlockUI/CharacterUI/CharacterDescription
@onready var _UNLOCK_CHARACTER_EMBERS_FANCY = $UnlockUI/CharacterUI/CharacterEmbersFancy
@onready var _UNLOCK_CHARACTER_EMBERS = $UnlockUI/CharacterUI/CharacterEmbers

@onready var _UNLOCK_COIN_UI = $UnlockUI/CoinUI
@onready var _UNLOCK_COIN_FAMILY_LABEL = $UnlockUI/CoinUI/Family
@onready var _UNLOCK_COIN_SUBTITLE_LABEL = $UnlockUI/CoinUI/Subtitle
@onready var _UNLOCK_COIN_TIP_LABEL = $UnlockUI/CoinUI/Tip
@onready var _UNLOCK_OBOL = $UnlockUI/CoinUI/Coins/Obol
@onready var _UNLOCK_DIOBOL = $UnlockUI/CoinUI/Coins/Diobol
@onready var _UNLOCK_TRIOBOL = $UnlockUI/CoinUI/Coins/Triobol
@onready var _UNLOCK_TETROBOL = $UnlockUI/CoinUI/Coins/Tetrobol

@onready var _UNLOCK_FEATURE_UI = $UnlockUI/FeatureUI
@onready var _UNLOCK_FEATURE_LABEL = $UnlockUI/FeatureUI/Feature
@onready var _UNLOCK_FEATURE_DESCRIPTION = $UnlockUI/FeatureUI/FeatureDescription
@onready var _UNLOCK_FEATURE_SPRITE = $UnlockUI/FeatureUI/FeatureSprite

@onready var _UNLOCK_DIFFICULTY_UI = $UnlockUI/DifficultyUI
@onready var _UNLOCK_DIFFICULTY_LABEL = $UnlockUI/DifficultyUI/Difficulty
@onready var _UNLOCK_DIFFICULTY_DESCRIPTION = $UnlockUI/DifficultyUI/DifficultyDescription
@onready var _UNLOCK_DIFFICULTY_SPRITE = $UnlockUI/DifficultyUI/DifficultySprite

@onready var _UNLOCK_TEXTBOXES = $UnlockUI/UnlockTextboxes

@onready var _FALLING_COINS = $UnlockUI/FallingCoins
@onready var _SPARKLE = $UnlockUI/Sparkle

var _queued_unlocks = []

func _ready() -> void:
	assert(_MAIN_UI)
	assert(_CHARACTER_SELECTOR)
	assert(_CHARACTER_DESCRIPTION)
	assert(_DIFFICULTY_SELECTOR)

	assert(_MAIN_UI_EMBERS_CHARACTER)
	assert(_MAIN_UI_EMBERS_RED)
	assert(_MAIN_UI_EMBERS_PURPLE)
	assert(_MAIN_UI_EMBERS_MORE_RED)
	assert(_MAIN_UI_EMBERS_MORE_PURPLE)
	
	assert(_UNLOCK_UI)

	assert(_UNLOCK_CHARACTER_UI)
	assert(_UNLOCK_CHARACTER_LABEL)
	assert(_UNLOCK_CHARACTER_DESCRIPTION_LABEL)
	assert(_UNLOCK_CHARACTER_EMBERS_FANCY)
	assert(_UNLOCK_CHARACTER_EMBERS)
	
	assert(_UNLOCK_COIN_UI)
	assert(_UNLOCK_COIN_FAMILY_LABEL)
	assert(_UNLOCK_COIN_SUBTITLE_LABEL)
	assert(_UNLOCK_OBOL)
	assert(_UNLOCK_DIOBOL)
	assert(_UNLOCK_TRIOBOL)
	assert(_UNLOCK_TETROBOL)
	assert(_UNLOCK_COIN_TIP_LABEL)
	
	assert(_UNLOCK_FEATURE_UI)
	assert(_UNLOCK_FEATURE_LABEL)
	assert(_UNLOCK_FEATURE_DESCRIPTION)
	assert(_UNLOCK_FEATURE_SPRITE)
	
	assert(_UNLOCK_DIFFICULTY_LABEL)
	assert(_UNLOCK_DIFFICULTY_UI)
	assert(_UNLOCK_DIFFICULTY_SPRITE)
	assert(_UNLOCK_DIFFICULTY_DESCRIPTION)
	
	assert(_UNLOCK_TEXTBOXES)
	
	assert(_FALLING_COINS)
	_FALLING_COINS.show()
	_FALLING_COINS.modulate.a = 0.0
	assert(_SPARKLE)
	_SPARKLE.show()
	_SPARKLE.modulate.a = 0.0

	assert(Global.Character.size() == Global.CHARACTERS.size())

	_UNLOCK_OBOL.init_coin(Global.GENERIC_FAMILY, Global.Denomination.OBOL, Coin.Owner.PLAYER)
	_UNLOCK_DIOBOL.init_coin(Global.GENERIC_FAMILY, Global.Denomination.DIOBOL, Coin.Owner.PLAYER)
	_UNLOCK_TRIOBOL.init_coin(Global.GENERIC_FAMILY, Global.Denomination.TRIOBOL, Coin.Owner.PLAYER)
	_UNLOCK_TETROBOL.init_coin(Global.GENERIC_FAMILY, Global.Denomination.TETROBOL, Coin.Owner.PLAYER)

	setup_character_selector()

	for difficultySkull in _DIFFICULTY_SELECTOR.get_children():
		difficultySkull.selected.connect(_on_difficulty_changed)
	_DIFFICULTY_SELECTOR.get_child(0).select()

	switch_to_main_ui()

	Global.game_loaded.connect(setup_character_selector)
	
	
	#var TEST_DIFFICULTY_UNLOCK = UnlockedDifficulty.new(Global.Character.ELEUSINIAN, Global.Difficulty.CRUEL3)
	
	# DEBUG UNLOCK
	#queue_unlocks([Global.TEST_DIFFICULTY_UNLOCK, Global.APOLLO_FAMILY, Global.ARTEMIS_FAMILY, Global.HEPHAESTUS_FAMILY, Global.Character.MERCHANT, Global.Character.ELEUSINIAN,\
	#Global.UNLOCKED_FEATURE_SCALES_OF_THEMIS, Global.UNLOCKED_FEATURE_ORPHIC_TABLETS, Global.UNLOCKED_FEATURE_ORPHIC_PAGE1,\
	#])

func setup_character_selector() -> void:
	var names = []
	for character in Global.CHARACTERS.values():
		if Global.is_character_unlocked(character.character):
			names.append(character.name)
	assert(names.size() != 0)
	_CHARACTER_SELECTOR.init(names)

func set_character(chara: Global.Character) -> void:
	_CHARACTER_SELECTOR.set_to(Global.CHARACTERS[chara].name)

func _on_embark_button_clicked():
	emit_signal("start_game")

func _on_quit_button_clicked():
	get_tree().quit()

func _on_character_changed(characterName: String) -> void:
	const CHARACTER_FORMAT = "[center]%s[/center]"
	for character in Global.CHARACTERS.values():
		if character.name == characterName:
			Global.character = character
			_CHARACTER_DESCRIPTION.text = CHARACTER_FORMAT % character.description
			
			# update appearance of other skulls based on character...
			_DIFFICULTY_SELECTOR.visible = not Global.is_character(Global.Character.LADY) # no difficulties for LADY
			var highest_difficulty_unlocked = Global.get_highest_difficulty_unlocked_for(Global.get_character())
			for skull in _DIFFICULTY_SELECTOR.get_children():
				skull.visible = skull.difficulty <= highest_difficulty_unlocked
				skull.set_vanquished(skull.difficulty < highest_difficulty_unlocked)
				# and default to highest
				if skull.difficulty <= highest_difficulty_unlocked:
					skull.select()
			
			_update_sparks()
			return
	assert(false, "Did not find character with name %s!" % characterName)

func _on_difficulty_changed(changed: Control, newDifficulty: Global.Difficulty):
	Global.difficulty = newDifficulty
	
	# graphically unselect each other skull
	for difficultySkull in _DIFFICULTY_SELECTOR.get_children():
		if difficultySkull != changed:
			difficultySkull.unselect()
	
	_update_sparks()

func _update_sparks() -> void:
	_MAIN_UI_EMBERS_CHARACTER.process_material.color_ramp.gradient.set_color(0, Color(Global.get_character_color()))
	_MAIN_UI_EMBERS_RED.emitting = Global.difficulty >= Global.Difficulty.HOSTILE2 and not Global.is_character(Global.Character.LADY)
	_MAIN_UI_EMBERS_PURPLE.emitting = Global.difficulty >= Global.Difficulty.CRUEL3 and not Global.is_character(Global.Character.LADY)
	_MAIN_UI_EMBERS_MORE_RED.emitting = Global.difficulty >= Global.Difficulty.GREEDY4 and not Global.is_character(Global.Character.LADY)
	_MAIN_UI_EMBERS_MORE_PURPLE.emitting = Global.difficulty >= Global.Difficulty.UNFAIR5 and not Global.is_character(Global.Character.LADY)

func queue_unlocks(unlocks) -> void:
	# remove any unlocks that are already unlocked
	var true_unlocks = []
	for unlock in unlocks:
		assert(unlock is Global.Character or unlock is Global.CoinFamily or unlock is Global.UnlockedFeature or unlock is Global.UnlockedDifficulty)
		if unlock is Global.Character and Global.is_character_unlocked(unlock):
			continue
		elif unlock is Global.CoinFamily and Global.is_coin_unlocked(unlock):
			continue
		true_unlocks.append(unlock)
	if true_unlocks.size() == 0:
		return
	
	# add all the valid unlocks to the queue
	for unlock in true_unlocks:
		_queued_unlocks.append(unlock)
	switch_to_unlock_ui()
	do_unlock()

const _FADE_TIME = 0.3
const _DELAY_TIME = 0.7

func do_unlock() -> void:
	if _queued_unlocks.size() == 0:
		return
	
	var unlocked = _queued_unlocks.pop_front()
	
	_UNLOCK_TEXTBOXES.make_invisible()
	
	# perform the unlock. update ui, then fade it in.
	if unlocked is Global.Character:
		# update the ui and perform the unlock
		_UNLOCK_CHARACTER_LABEL.text = "[center]%s[/center]" % Global.CHARACTERS[unlocked].name
		_UNLOCK_CHARACTER_DESCRIPTION_LABEL.text = "[center]%s[/center]" % Global.CHARACTERS[unlocked].description
		_UNLOCK_CHARACTER_EMBERS.process_material.color_ramp.gradient.set_color(0, Color(Global.CHARACTERS[unlocked].color))
		_UNLOCK_CHARACTER_EMBERS_FANCY.process_material.color_ramp.gradient.set_color(0, Color(Global.CHARACTERS[unlocked].color))
		Global.unlock_character(unlocked)
		setup_character_selector()
		if unlocked == Global.Character.ELEUSINIAN: # Move the selector over to Eleusinian right away after finishing Lady
			set_character(Global.Character.ELEUSINIAN)
		
		# fade it in
		_UNLOCK_CHARACTER_UI.show()
		_UNLOCK_CHARACTER_UI.modulate.a = 0.0
		await Global.fade_in(_UNLOCK_CHARACTER_UI, _FADE_TIME)
	elif unlocked is Global.CoinFamily:
		# update the ui and perform the unlock
		_UNLOCK_COIN_FAMILY_LABEL.text = "[center]%s[/center]" % unlocked.coin_name.replace("(DENOM)", "Obol")
		_UNLOCK_COIN_SUBTITLE_LABEL.text = "[center]%s[/center]" % unlocked.subtitle
		_UNLOCK_COIN_TIP_LABEL.text = "[center]%s[center]" % Global.replace_placeholders(unlocked.unlock_tip)
		_UNLOCK_COIN_TIP_LABEL.visible = unlocked.unlock_tip != Global.NO_UNLOCK_TIP
		_UNLOCK_OBOL.init_coin(unlocked, Global.Denomination.OBOL, Coin.Owner.PLAYER)
		_UNLOCK_DIOBOL.init_coin(unlocked, Global.Denomination.DIOBOL, Coin.Owner.PLAYER)
		_UNLOCK_TRIOBOL.init_coin(unlocked, Global.Denomination.TRIOBOL, Coin.Owner.PLAYER)
		_UNLOCK_TETROBOL.init_coin(unlocked, Global.Denomination.TETROBOL, Coin.Owner.PLAYER)
		Global.unlock_coin(unlocked)
		
		# fade it in
		_UNLOCK_COIN_UI.show()
		_UNLOCK_COIN_UI.modulate.a = 0.0
		# dumb hack but we need to do it this way for coins since they have a shader
		_UNLOCK_OBOL.FX.hide()
		_UNLOCK_DIOBOL.FX.hide()
		_UNLOCK_TRIOBOL.FX.hide()
		_UNLOCK_TETROBOL.FX.hide()
		_UNLOCK_OBOL.FX.fade_in(_FADE_TIME * 2)
		_UNLOCK_DIOBOL.FX.fade_in(_FADE_TIME * 2)
		_UNLOCK_TRIOBOL.FX.fade_in(_FADE_TIME * 2)
		_UNLOCK_TETROBOL.FX.fade_in(_FADE_TIME * 2)
		Global.fade_in(_FALLING_COINS, _FADE_TIME)
		await Global.fade_in(_UNLOCK_COIN_UI, _FADE_TIME)
	elif unlocked is Global.UnlockedFeature:
		#update the ui
		_UNLOCK_FEATURE_LABEL.text = "[center]%s[/center]" % unlocked.name
		_UNLOCK_FEATURE_DESCRIPTION.text = "[center]%s[/center]" % unlocked.description
		_UNLOCK_FEATURE_SPRITE.texture = load(unlocked.sprite_path)
		
		# TODO UNLOCKS
		match unlocked.feature_type:
			Global.UnlockedFeature.FeatureType.SCALES_OF_THEMIS:
				pass
				#Global.unlock_scales_of_themis()
			Global.UnlockedFeature.FeatureType.ORPHIC_TABLETS:
				pass
				#Global.unlock_orphic_tablets()
			Global.UnlockedFeature.FeatureType.ORPHIC_TABLET_PAGE:
				assert(unlocked is Global.UnlockedOrphicPageFeature)
				pass
				#Global.unlock_orphic_tablet_page(unlocked.page)
		
		_UNLOCK_FEATURE_UI.show()
		_UNLOCK_FEATURE_UI.modulate.a = 0.0
		Global.fade_in(_SPARKLE, _FADE_TIME)
		await Global.fade_in(_UNLOCK_FEATURE_UI, _FADE_TIME)
	elif unlocked is Global.UnlockedDifficulty:
		# update the ui
		_UNLOCK_DIFFICULTY_LABEL.text = "[center]Harder Difficulty Unlocked for %s[/center]" % Global.CHARACTERS[unlocked.character].name
		_UNLOCK_DIFFICULTY_DESCRIPTION.text = "[center]%s[/center]" % Global.difficulty_tooltip_for(unlocked.difficulty)
		
		var atlas_texture = AtlasTexture.new()
		atlas_texture.atlas = load("res://assets/main_menu/difficulty_skulls/difficulty_skull_spritesheet.png")
		
		match unlocked.difficulty:
			Global.Difficulty.INDIFFERENT1:
				atlas_texture.region = Rect2(Vector2(32, 0), Vector2(16, 16))
			Global.Difficulty.HOSTILE2:
				atlas_texture.region = Rect2(Vector2(32, 16), Vector2(16, 16))
			Global.Difficulty.CRUEL3:
				atlas_texture.region = Rect2(Vector2(32, 48), Vector2(16, 16))
			Global.Difficulty.GREEDY4:
				atlas_texture.region = Rect2(Vector2(32, 32), Vector2(16, 16))
			Global.Difficulty.UNFAIR5:
				atlas_texture.region = Rect2(Vector2(32, 64), Vector2(16, 16))
			_:
				assert(false)
		_UNLOCK_DIFFICULTY_SPRITE.texture = atlas_texture
		
		# do the unlock
		Global.unlock_difficulty(unlocked.character, unlocked.difficulty)
		
		_UNLOCK_DIFFICULTY_UI.show()
		_UNLOCK_DIFFICULTY_UI.modulate.a = 0.0
		await Global.fade_in(_UNLOCK_DIFFICULTY_UI, _FADE_TIME)
	
	_UNLOCK_TEXTBOXES.make_visible()

func _on_unlock_continue_button_clicked():
	# fade out the current unlock
	_UNLOCK_TEXTBOXES.make_invisible()
	Global.fade_out(_UNLOCK_CHARACTER_UI)
	_UNLOCK_OBOL.FX.fade_out(_FADE_TIME * 2)
	_UNLOCK_DIOBOL.FX.fade_out(_FADE_TIME * 2)
	_UNLOCK_TRIOBOL.FX.fade_out(_FADE_TIME * 2)
	_UNLOCK_TETROBOL.FX.fade_out(_FADE_TIME * 2)
	
	Global.fade_out(_UNLOCK_DIFFICULTY_UI)
	Global.fade_out(_UNLOCK_FEATURE_UI)
	
	# if the previous unlock was a coin and the next is also a coin, keep the falling coins effect
	if not _is_next_unlock_coin():
		Global.fade_out(_FALLING_COINS, _FADE_TIME)
	if not _is_next_unlock_feature():
		Global.fade_out(_SPARKLE)
	await Global.fade_out(_UNLOCK_COIN_UI)
	_UNLOCK_CHARACTER_UI.hide()
	_UNLOCK_COIN_UI.hide()
	_UNLOCK_DIFFICULTY_UI.hide()
	_UNLOCK_FEATURE_UI.hide()
	
	await Global.delay(_DELAY_TIME)
	
	# now either do (fade in) the next unlock or switch back to main menu
	if _queued_unlocks.size() != 0:
		do_unlock()
	else:
		switch_to_main_ui()

func _is_next_unlock_coin() -> bool:
	return _queued_unlocks.size() != 0 and _queued_unlocks[0] is Global.CoinFamily

func _is_next_unlock_feature() -> bool:
	return _queued_unlocks.size() != 0 and _queued_unlocks[0] is Global.UnlockedFeature

func switch_to_main_ui() -> void:
	# main menu needs to fade in
	_UNLOCK_UI.hide()
	_MAIN_UI.show()
	_MAIN_UI.modulate.a = 0.0
	await Global.fade_in(_MAIN_UI, _FADE_TIME)

func switch_to_unlock_ui() -> void:
	_MAIN_UI.hide()
	_UNLOCK_CHARACTER_UI.hide()
	_UNLOCK_COIN_UI.hide()
	_UNLOCK_DIFFICULTY_UI.hide()
	_UNLOCK_FEATURE_UI.hide()
	_UNLOCK_UI.show()

func _on_debug_unlock_everything_pressed():
	Global.unlock_all()
	setup_character_selector()
