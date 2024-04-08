class_name CharonTextbox
extends BoxContainer

@onready var _TEXTBOX: Textbox = $Textbox

func _ready():
	assert(_TEXTBOX)

#func _input(_event: InputEvent) -> void:
#	if Input.is_anything_pressed():
#		print("pressed")
#	else:
#		print("unpressed!")

func hide_dialogue() -> void:
	hide()

func show_dialogue(dialogue: String) -> void:
	show()
	_TEXTBOX.set_text(dialogue)

func flash_dialogue(dialogue: String) -> void:
	show_dialogue(dialogue)
	await Global.delay(0.1)
	hide()
