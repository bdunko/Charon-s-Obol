class_name Textbox
extends MarginContainer

enum ArrowStyle {
	PURPLE, GOLDEN
}

# factory method
static func create(txtColor: Color = _DEFAULT_TEXT_COLOR, bgColor: Color = _DEFAULT_BACKGROUND_COLOR, brdrColor: Color = _DEFAULT_BORDER_COLOR, flashClr: Color = _DEFAULT_FLASH_COLOR, shldFloat: bool = false, clickable: bool = true, shldFlash: bool = false, shldArrow: bool = false, arrwStyle: ArrowStyle = ArrowStyle.PURPLE) -> Textbox:
	var textbox = load("res://ui/textbox.tscn").instantiate()
	textbox.flashing = shldFlash
	textbox.text_color = txtColor
	textbox.background_color = bgColor
	textbox.border_color = brdrColor
	textbox.flash_color = flashClr
	textbox.should_float = shldFloat
	textbox.click_enabled = clickable
	textbox.show_arrow = shldArrow
	textbox.arrow_style = arrwStyle
	return textbox

signal clicked

@export var arrow_style = ArrowStyle.PURPLE:
	set(val):
		arrow_style = val
		_update_style()

@export var show_arrow = false:
	set(val):
		show_arrow = val
		_update_style()

@export var default_text := ""

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

const _DEFAULT_FLASH_COLOR = Color("#e86a73")
@export var flash_color = _DEFAULT_FLASH_COLOR:
	set(val):
		flash_color = val
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

@export var flashing = false
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

@export var sound_family = SoundFamily.NONE
enum SoundFamily {
	NONE, EMBARK
}

@onready var _STARTING_Y = position.y
@onready var _TEXT = $TextMargin/Text
@onready var _TEXT_MARGIN = $TextMargin
const _RIGHT_MARGIN_NO_ARROW = 4
const _RIGHT_MARGIN_ARROW = 17
@onready var _ARROW = $ArrowSprite
@onready var _FX : FX = $FX
@onready var _MOUSE = $Mouse

const _TIMER_KEY = "TEXTBOX_FLASH_TIMER"
const _FLASH_TIMER_TIME = 0.1

func _ready():
	assert(_TEXT)
	assert(_ARROW)
	assert(_FX)
	assert(_MOUSE)
	_MOUSE.mouse_entered.connect(_on_mouse_entered)
	_MOUSE.mouse_exited.connect(_on_mouse_exited)
	set_text(default_text)
	_update_style()
	var timer = Global.create_timer(_TIMER_KEY, _FLASH_TIMER_TIME)
	timer.timeout.connect(_on_flash_timer_timeout)

func _update_arrow() -> void:
	if _ARROW:
		_ARROW.visible = show_arrow
		_ARROW.position.x = _TEXT.position.x + _TEXT.size.x + 2
		_ARROW.play("purple" if arrow_style == ArrowStyle.PURPLE else "golden")

func _update_style() -> void:
	if _FX:
		_FX.recolor(1, _DEFAULT_TEXT_COLOR, disabled_text_color if disabled else (text_hover_color if (_MOUSE.is_over() and click_enabled) else text_color))
		_FX.recolor(2, _DEFAULT_BACKGROUND_COLOR, disabled_background_color if disabled else background_color)
		_FX.recolor(3, _DEFAULT_BORDER_COLOR, disabled_border_color if disabled else (flash_color if flashing else border_color))
	if _TEXT_MARGIN:
		_TEXT_MARGIN.add_theme_constant_override("margin_right", _RIGHT_MARGIN_ARROW if show_arrow else _RIGHT_MARGIN_NO_ARROW)
	call_deferred("_update_arrow")

func _reset_colors() -> void:
	_FX.recolor(1, _DEFAULT_TEXT_COLOR, _DEFAULT_TEXT_COLOR)
	_FX.recolor(2, _DEFAULT_BACKGROUND_COLOR, _DEFAULT_BACKGROUND_COLOR)
	_FX.recolor(3, _DEFAULT_BORDER_COLOR, _DEFAULT_BORDER_COLOR)

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
	_update_style()

func get_text() -> String:
	return _TEXT.text

func fade_and_free() -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.1)
	tween.parallel().tween_property(self, "scale", Vector2(0, 0), 0.1)
	tween.tween_callback(self.queue_free)

# make it drift up and down a bit
var _time = 0
func _process(delta) -> void:
	#can improve this a bit...
	#calculate a float_offset and change _STARTING_Y by that
	#instead of adding
	_time += delta * 3
	if should_float:
		position.y += (4 * delta * sin(_time))
	else:
		position.y = _STARTING_Y

var _flash_on = false
func _on_flash_timer_timeout():
	if flashing and _FX != null:
		var clr = disabled_border_color if disabled else (border_color if _flash_on else flash_color)
		_FX.recolor(3, _DEFAULT_BORDER_COLOR, clr)
		
		#var clr = disabled_text_color if disabled else (text_hover_color if (_MOUSE.is_over() and click_enabled) else (text_color if _flash_on else flash_color))
		_flash_on = not _flash_on
		#_FX.recolor(1, _DEFAULT_TEXT_COLOR, clr)
	
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
				if _MOUSE.is_over():
					emit_signal("clicked")
					match(sound_family):
						SoundFamily.NONE:
							pass
						SoundFamily.EMBARK:
							Audio.play_sfx(SFX.EmbarkButtonClicked)
					_reset_colors()

func _on_mouse_entered():
	_update_style()
	Audio.play_sfx(SFX.Hovered)

func _on_mouse_exited():
	_update_style()
	_mouse_down = false
