extends MarginContainer

@onready var _TEXT = $TextMargin/Text

func _ready():
	assert(_TEXT)

func set_text(str: String) -> void:
	_TEXT.text = str
