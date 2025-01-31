extends Node2D

signal start_game

@onready var _MAIN_UI = $UI/MainUI
@onready var _CHARACTER_SELECTOR: ArrowSelector = $UI/MainUI/Selector/Character
@onready var _CHARACTER_DESCRIPTION: RichTextLabel = $UI/MainUI/DescriptionContainer/CharacterDescription
@onready var _DIFFICULTY_SELECTOR = $UI/MainUI/Selector/Difficulty

@onready var _UNLOCK_UI = $UI/UnlockUI

@onready var _UNLOCK_CHARACTER_UI = $UI/UnlockUI/CharacterUI
@onready var _UNLOCK_CHARACTER_LABEL = $UI/UnlockUI/CharacterUI/Character
@onready var _UNLOCK_CHARACTER_DESCRIPTION_LABEL = $UI/UnlockUI/CharacterUI/CharacterDescription

@onready var _UNLOCK_COIN_UI = $UI/UnlockUI/CoinUI
@onready var _UNLOCK_COIN_FAMILY_LABEL = $UI/UnlockUI/CoinUI/Family
@onready var _UNLOCK_COIN_SUBTITLE_LABEL = $UI/UnlockUI/CoinUI/Subtitle
@onready var _UNLOCK_OBOL = $UI/UnlockUI/CoinUI/Coins/Obol
@onready var _UNLOCK_DIOBOL = $UI/UnlockUI/CoinUI/Coins/Diobol
@onready var _UNLOCK_TRIOBOL = $UI/UnlockUI/CoinUI/Coins/Triobol
@onready var _UNLOCK_TETROBOL = $UI/UnlockUI/CoinUI/Coins/Tetrobol

@onready var _UI_LAYER = $UI
@onready var _POST_PROCESS_LAYER = $PostProcess

var _queued_unlocks = []

func _ready() -> void:
	assert(_MAIN_UI)
	assert(_CHARACTER_SELECTOR)
	assert(_CHARACTER_DESCRIPTION)
	assert(_DIFFICULTY_SELECTOR)

	assert(_UNLOCK_UI)

	assert(_UNLOCK_CHARACTER_UI)
	assert(_UNLOCK_CHARACTER_LABEL)
	assert(_UNLOCK_CHARACTER_DESCRIPTION_LABEL)

	assert(_UNLOCK_COIN_UI)
	assert(_UNLOCK_COIN_FAMILY_LABEL)
	assert(_UNLOCK_COIN_SUBTITLE_LABEL)
	assert(_UNLOCK_OBOL)
	assert(_UNLOCK_DIOBOL)
	assert(_UNLOCK_TRIOBOL)
	assert(_UNLOCK_TETROBOL)

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
	
	visibility_changed.connect(_on_visibility_changed)
	_on_visibility_changed()

func _on_visibility_changed() -> void:
	_UI_LAYER.visible = visible
	_POST_PROCESS_LAYER.visible = visible

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
			_CHARACTER_DESCRIPTION.text = CHARACTER_FORMAT % character.description
			Global.character = character
			_DIFFICULTY_SELECTOR.visible = not Global.is_character(Global.Character.LADY) # no difficulties for LADY
			return
	assert(false, "Did not find character with name %s!" % characterName)

func _on_difficulty_changed(changed: Control, newDifficulty: Global.Difficulty):
	Global.difficulty = newDifficulty
	
	# graphically unselect each other skull
	for difficultySkull in _DIFFICULTY_SELECTOR.get_children():
		if difficultySkull != changed:
			difficultySkull.unselect()

func queue_unlocks(unlocks) -> void:
	# remove any unlocks that are already unlocked
	var true_unlocks = []
	for unlock in unlocks:
		assert(unlock is Global.Character or unlock is Global.CoinFamily)
		if unlock is Global.Character and Global.is_character_unlocked(unlock):
			continue
		elif unlock is Global.CoinFamily and Global.is_coin_unlocked(unlock):
			continue
		true_unlocks.append(unlock)
	if true_unlocks.size() == 0:
		return
	
	_queued_unlocks = true_unlocks
	switch_to_unlock_ui()
	do_unlock()

func do_unlock() -> void:
	if _queued_unlocks.size() == 0:
		return
	
	var unlocked = _queued_unlocks.pop_front()
	assert(unlocked is Global.Character or unlocked is Global.CoinFamily)
	
	if unlocked is Global.Character:
		# todo - cleaner transition here
		_UNLOCK_CHARACTER_UI.show()
		_UNLOCK_COIN_UI.hide()
		
		_UNLOCK_CHARACTER_LABEL.text = "[center]%s[/center]" % Global.CHARACTERS[unlocked].name
		_UNLOCK_CHARACTER_DESCRIPTION_LABEL.text = "[center]%s[/center]" % Global.CHARACTERS[unlocked].description
		Global.unlock_character(unlocked)
		setup_character_selector()
		
		if unlocked == Global.Character.ELEUSINIAN: # Move the selector over to Eleusinian right away after finishing Lady
			set_character(Global.Character.ELEUSINIAN)
	elif unlocked is Global.CoinFamily:
		# todo - cleaner transition here
		_UNLOCK_COIN_UI.show()
		_UNLOCK_CHARACTER_UI.hide()
		
		_UNLOCK_COIN_FAMILY_LABEL.text = "[center]%s[/center]" % unlocked.coin_name.replace("(DENOM)", "Obol")
		_UNLOCK_COIN_SUBTITLE_LABEL.text = "[center]%s[/center]" % unlocked.subtitle
		_UNLOCK_OBOL.init_coin(unlocked, Global.Denomination.OBOL, Coin.Owner.PLAYER)
		_UNLOCK_DIOBOL.init_coin(unlocked, Global.Denomination.DIOBOL, Coin.Owner.PLAYER)
		_UNLOCK_TRIOBOL.init_coin(unlocked, Global.Denomination.TRIOBOL, Coin.Owner.PLAYER)
		_UNLOCK_TETROBOL.init_coin(unlocked, Global.Denomination.TETROBOL, Coin.Owner.PLAYER)
		Global.unlock_coin(unlocked)

func _on_unlock_continue_button_clicked():
	if _queued_unlocks.size() != 0:
		do_unlock()
	else:
		switch_to_main_ui()

func switch_to_main_ui() -> void:
	# todo - cleaner transition here
	_MAIN_UI.show()
	_UNLOCK_UI.hide()

func switch_to_unlock_ui() -> void:
	# todo - cleaner transition here
	_UNLOCK_UI.show()
	_MAIN_UI.hide()

func _on_debug_unlock_everything_pressed():
	Global.unlock_all()
	setup_character_selector()
