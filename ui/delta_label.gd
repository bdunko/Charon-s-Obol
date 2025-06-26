class_name DeltaLabel
extends RichTextLabel

@export var display_duration := 1.5    # Seconds to stay visible after flash
@export var fade_duration := 0.5       # Seconds to fade out alpha
@export var flash_duration := 0.25     # Duration of the flash tween

@export var format_string := "[center]{value}[/center]"

@export var positive_value_color: Color = Color(0, 1, 0)         # green
@export var negative_value_color: Color = Color(1, 0, 0)         # red
@export var flash_positive_value_color: Color = Color(0.6, 1, 0.6)  # brighter green
@export var flash_negative_value_color: Color = Color(1, 0.6, 0.6)  # brighter red

var _current_value: int = 0
var _fade_id: int = 0
var _tween: Tween = null

func _ready():
	hide()
	modulate.a = 1.0
	bbcode_enabled = true
	_tween = create_tween()
	_tween.kill()

func add_delta(delta: int) -> void:
	if delta == 0:
		return  # Ignore zero delta, no changes

	_current_value += delta
	_fade_id += 1
	var my_id = _fade_id

	_update_text_and_color()
	show()
	modulate.a = 1.0

	_tween.kill()

	await _play_flash_animation(my_id)
	if my_id != _fade_id or !is_inside_tree():
		return

	await Global.delay(display_duration)
	if my_id != _fade_id or !is_inside_tree():
		return

	await _play_fade_animation(my_id)
	if my_id != _fade_id or !is_inside_tree():
		return

	hide()
	_current_value = 0
	modulate.a = 1.0

func _update_text_and_color() -> void:
	var value_str := ("+" if _current_value >= 0 else "") + str(_current_value)
	var flash_color := flash_positive_value_color if _current_value >= 0 else flash_negative_value_color

	var formatted := format_string.format({
		"value": value_str,
	})

	clear()
	append_text(formatted)
	add_theme_color_override("default_color", flash_color)

func _play_flash_animation(my_id: int) -> void:
	var normal_color := positive_value_color if _current_value >= 0 else negative_value_color
	_tween = create_tween()
	_tween.tween_property(self, "theme_override_colors/default_color", normal_color, flash_duration)
	await _tween.finished

func _play_fade_animation(my_id: int) -> void:
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	await _tween.finished

func reset() -> void:
	_fade_id += 1
	_tween.kill()
	_current_value = 0
	hide()
	modulate.a = 1.0
