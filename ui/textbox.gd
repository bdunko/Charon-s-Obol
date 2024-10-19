class_name Textbox
extends MarginContainer

# factory method
static func create(txtColor: Color = _DEFAULT_TEXT_COLOR, bgColor: Color = _DEFAULT_BACKGROUND_COLOR, brdrColor: Color = _DEFAULT_BORDER_COLOR, shldFloat: bool = false, clickable: bool = true) -> Textbox:
	var textbox = load("res://ui/textbox.tscn").instantiate()
	textbox.text_color = txtColor
	textbox.background_color = bgColor
	textbox.border_color = brdrColor
	textbox.should_float = shldFloat
	textbox.click_enabled = clickable
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

const _DEFAULT_DISABLED_TEXT_COLOR = Color("#747474")
@export var disabled_text_color = _DEFAULT_DISABLED_TEXT_COLOR:
	set(val):
		disabled_text_color = val
		_update_style()

const _DEFAULT_DISABLED_BACKGROUND_COLOR = Color("#141013")
@export var disabled_background_color = _DEFAULT_DISABLED_BACKGROUND_COLOR:
	set(val):
		disabled_background_color = val
		_update_style()

const _DEFAULT_DISABLED_BORDER_COLOR = Color("#747474")
@export var disabled_border_color = _DEFAULT_DISABLED_BORDER_COLOR:
	set(val):
		disabled_border_color = val
		_update_style()

const _DEFAULT_TEXT_HOVER_COLOR = Color.AQUAMARINE
@export var text_hover_color = _DEFAULT_TEXT_HOVER_COLOR:
	set(val):
		text_hover_color = val
		_update_style()

@export var should_float = false

@export var disabled = false:
	set(val):
		disabled = val
		disable_clicks() if disabled else enable_clicks()
		_update_style()
	
@export var click_enabled = true:
	set(val):
		click_enabled = val
		_update_style()
		
@onready var _STARTING_Y = position.y
@onready var _TEXT = $TextMargin/Text
@onready var _FX = $FX
@onready var _MOUSE = $Mouse

func _ready():
	assert(_TEXT)
	assert(_FX)
	assert(_MOUSE)

func _update_style() -> void:
	material.set_shader_parameter("replace_color1", _DEFAULT_TEXT_COLOR)
	material.set_shader_parameter("replace_with_color1", disabled_text_color if disabled else (text_hover_color if (_mouse_over and click_enabled) else text_color))
	material.set_shader_parameter("replace_color2", _DEFAULT_BACKGROUND_COLOR)
	material.set_shader_parameter("replace_with_color2", disabled_background_color if disabled else background_color)
	material.set_shader_parameter("replace_color3", _DEFAULT_BORDER_COLOR)
	material.set_shader_parameter("replace_with_color3", disabled_border_color if disabled else border_color)

func disable() -> void:
	disabled = true

func enable() -> void:
	disabled = false

func disable_clicks() -> void:
	click_enabled = false

func enable_clicks() -> void:
	click_enabled = true

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

var _mouse_over = false:
	set(val):
		_mouse_over = val
		_update_style()
	
var _mouse_down = false
func _gui_input(event):
	if not click_enabled or disabled:
		return
	
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				_mouse_down = true
			else:
				_mouse_down = false
				emit_signal("clicked")
				_FX.clear_replace_color()

func _on_mouse_entered():
	_mouse_over = true

func _on_mouse_exited():
	_mouse_over = false
	_mouse_down = false
