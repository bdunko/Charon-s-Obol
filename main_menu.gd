extends Node2D

signal start_game

@onready var _CHARACTER_SELECTOR: ArrowSelector = $Selector/Character
@onready var _CHARACTER_DESCRIPTION: RichTextLabel = $DescriptionContainer/CharacterDescription
@onready var _DIFFICULTY_SELECTOR = $Selector/Difficulty
@onready var _TEXTBOXES = $Textboxes

func _ready() -> void:
	assert(_CHARACTER_SELECTOR)
	assert(_CHARACTER_DESCRIPTION)
	assert(_DIFFICULTY_SELECTOR)
	assert(_TEXTBOXES)
	assert(Global.Character.size() == Global.CHARACTERS.size())
	
	var names = []
	for character in Global.CHARACTERS:
		names.append(character.name)
	_CHARACTER_SELECTOR.init(names)
	
	for difficultySkull in _DIFFICULTY_SELECTOR.get_children():
		difficultySkull.selected.connect(_on_difficulty_changed)
	_DIFFICULTY_SELECTOR.get_child(0).select()

func _on_embark_button_clicked():
	emit_signal("start_game")

func _on_quit_button_clicked():
	get_tree().quit()

func _on_character_changed(characterName: String) -> void:
	const FORMAT = "[center]%s[/center]"
	for character in Global.CHARACTERS:
		if character.name == characterName:
			_CHARACTER_DESCRIPTION.text = FORMAT % character.description
			Global.character = character
			return
	assert(false, "Did not find character with name %s!" % characterName)

func _on_difficulty_changed(changed: Control, newDifficulty: Global.Difficulty):
	Global.difficulty = newDifficulty
	
	# graphically unselect each other skull
	for difficultySkull in _DIFFICULTY_SELECTOR.get_children():
		if difficultySkull != changed:
			difficultySkull.unselect()
