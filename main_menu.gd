extends Node2D

signal start_pressed

@onready var _CHARACTER_SELECTOR: ArrowSelector = $Selector/Character
@onready var _CHARACTER_DESCRIPTION: RichTextLabel = $DescriptionContainer/CharacterDescription
@onready var _DIFFICULTY_SELECTOR = $Selector/Difficulty

class CharacterData:
	var character: Global.Character
	var name: String
	var description: String
	
	func _init(characterEnum: Global.Character, nameStr: String, descriptionStr):
		self.character = characterEnum
		self.name = nameStr
		self.description = descriptionStr

var _CHARACTERS = [
	CharacterData.new(Global.Character.LADY, "[color=brown]The Lady[/color]", "Learn the rules of Charon's game."),
	CharacterData.new(Global.Character.ELEUSINIAN, "[color=green]The Eleusinian[/color]", "The standard game.\n10 Rounds, 3 Tollgates, 2 Trials, 1 Nemesis."),
]

func _ready() -> void:
	assert(_CHARACTER_SELECTOR)
	assert(_CHARACTER_DESCRIPTION)
	assert(_DIFFICULTY_SELECTOR)
	assert(Global.Character.size() == _CHARACTERS.size())
	
	var names = []
	for character in _CHARACTERS:
		names.append(character.name)
	_CHARACTER_SELECTOR.init(names)
	
	for difficultySkull in _DIFFICULTY_SELECTOR.get_children():
		difficultySkull.selected.connect(_on_difficulty_changed)
	_DIFFICULTY_SELECTOR.get_child(0).select()

func _on_start_button_pressed() -> void:
	emit_signal("start_pressed")

func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_character_changed(characterName: String) -> void:
	const FORMAT = "[center]%s[/center]"
	for character in _CHARACTERS:
		if character.name == characterName:
			_CHARACTER_DESCRIPTION.text = FORMAT % character.description
			Global.character = character.character
			return
	assert(false, "Did not find character with name %s!" % characterName)


func _on_difficulty_changed(changed: Control, newDifficulty: Global.Difficulty):
	Global.difficulty = newDifficulty
	
	# graphically unselect each other skull
	for difficultySkull in _DIFFICULTY_SELECTOR.get_children():
		if difficultySkull != changed:
			difficultySkull.unselect()
