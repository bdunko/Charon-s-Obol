extends Node2D

signal start_pressed

@onready var _CHARACTER_SELECTOR: ArrowSelector = $Selector/Character
@onready var _CHARACTER_DESCRIPTION: RichTextLabel = $Container/CharacterDescription

class CharacterData:
	var character: Global.Character
	var name: String
	var description: String
	
	func _init(characterEnum: Global.Character, nameStr: String, descriptionStr):
		self.character = characterEnum
		self.name = nameStr
		self.description = descriptionStr

var _CHARACTERS = [
	CharacterData.new(Global.Character.ELEUSINIAN, "[color=green]The Eleusinian[/color]", ""),
]

func _ready() -> void:
	var names = []
	for character in _CHARACTERS:
		names.append(character.name)
	_CHARACTER_SELECTOR.init(names)

func _on_start_button_pressed() -> void:
	emit_signal("start_pressed")

func _on_quit_button_pressed() -> void:
	get_tree().quit()


func _on_character_changed(characterName: String) -> void:
	const FORMAT = "[center]%s[/center]"
	for character in _CHARACTERS:
		if character.name == characterName:
			_CHARACTER_DESCRIPTION.text = FORMAT % character.description
			return
	assert(false, "Did not find character with name %s!" % characterName)
