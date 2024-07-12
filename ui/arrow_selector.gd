class_name ArrowSelector
extends HBoxContainer

signal changed()

var _options: Array
var _index: int = 0

@onready var _TEXT = $TextContainer/Text
@onready var _LEFT_ARROW = $LeftArrow
@onready var _RIGHT_ARROW = $RightArrow

func _ready() -> void:
	_TEXT.text = ""

func init(options: Array):
	assert(options.size() != 0)
	_options = options
	_LEFT_ARROW.disabled = options.size() == 1
	_RIGHT_ARROW.disabled = options.size() == 1
	_index = 0
	_update_text()

func _update_text() -> void:
	const FORMAT = "[center]%s[/center]"
	_TEXT.text = FORMAT % _options[_index]
	emit_signal("changed", _options[_index])

func _on_left_arrow_pressed():
	_index = _index - 1 if _index != 0 else _options.size() - 1
	_update_text()

func _on_right_arrow_pressed():
	_index = _index + 1 if _index != _options.size() - 1 else 0
	_update_text()
