class_name Textbox
extends MarginContainer

# factory method
static func create(txtColor: Color = _DEFAULT_TEXT_COLOR, bgColor: Color = _DEFAULT_BACKGROUND_COLOR, brdrColor: Color = _DEFAULT_BORDER_COLOR, shldFloat: bool = false) -> Textbox:
	var textbox = load("res://ui/textbox.tscn").instantiate()
	textbox.text_color = txtColor
	textbox.background_color = bgColor
	textbox.border_color = brdrColor
	textbox.should_float = shldFloat
	return textbox

signal clicked

const _DEFAULT_TEXT_COLOR = Color.WHITE
@export var text_color = _DEFAULT_TEXT_COLOR:
	set(val):
		text_color = val
		_update_style()

const _DEFAULT_BACKGROUND_COLOR = Color("#141013")
@export var background_color = _DEFAULT_BACKGROUND_COLOR:
	set(val):
		background_color = val
		_update_style()

const _DEFAULT_BORDER_COLOR = Color("#feffff")
@export var border_color = _DEFAULT_BORDER_COLOR:
	set(val):
		border_color = val
		_update_style()

@export var should_float = false

var _click_enabled = true
@onready var _STARTING_Y = position.y
@onready var _TEXT = $TextMargin/Text

func _ready():
	assert(_TEXT)

func _update_style() -> void:
	material.set_shader_parameter("replace_color1", _DEFAULT_TEXT_COLOR)
	material.set_shader_parameter("replace_with_color1", text_color)
	material.set_shader_parameter("replace_color2", _DEFAULT_BACKGROUND_COLOR)
	material.set_shader_parameter("replace_with_color2", background_color)
	material.set_shader_parameter("replace_color3", _DEFAULT_BORDER_COLOR)
	material.set_shader_parameter("replace_with_color3", border_color)

func disable() -> void:
	_click_enabled = false

func enable() -> void:
	_click_enabled = true

func set_text(txt: String) -> void:
	_TEXT.text = txt

func fade_and_free() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(self, "scale", Vector2(0, 0), 0.1)
	tween.tween_callback(self.queue_free)

# make it drift up and down a bit
var _time = 0
func _process(delta) -> void:
	#print(position)
	
	#can improve this a bit...
	#calculate a float_offset and change _STARTING_Y by that
	#instead of adding
	_time += delta * 3
	if should_float:
		position.y += (4 * delta * sin(_time))
	else:
		position.y = _STARTING_Y

func _gui_input(event):
	if not _click_enabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				emit_signal("clicked")
