class_name DeltaLabel
extends RichTextLabel

@onready var _FX = $FX

@export var fade_in_duration := 0.05  # quick fade-in duration
@export var display_duration := 2.0    # Seconds to stay visible after flash
@export var fade_duration := 0.1       # Seconds to fade out alpha
@export var flash_duration := 0.1     # Duration of the flash tween

@export var format_string := "[center]{value}[/center]"

@export var positive_value_color: Color = Color(0, 1, 0)         # green
@export var negative_value_color: Color = Color(1, 0, 0)         # red
@export var flash_positive_value_color: Color = Color(0.6, 1, 0.6)  # brighter green
@export var flash_negative_value_color: Color = Color(1, 0.6, 0.6)  # brighter red

var _current_value: int = 0
var _fade_id: int = 0
var _tween: Tween = null
var _fade_deadline_msec: int = -1
var _enabled: bool = true

func _ready():
	hide()
	modulate.a = 1.0
	bbcode_enabled = true
	_tween = create_tween()
	_kill_tweens()

func add_delta(delta: int) -> void:
	if not _enabled or delta == 0:
		return  # Ignore if disabled or zero delta

	_current_value += delta
	_fade_id += 1
	var my_id = _fade_id

	_update_text_and_color()
	
	# Begin fade-in
	modulate.a = 0.0
	show()
	_kill_tweens()
	_FX.disintegrate_in(0)
	_tween = create_tween()
	_tween.tween_property(self, "modulate:a", 1.0, fade_in_duration)
	await _tween.finished

	await _play_flash_animation()
	if my_id != _fade_id or !is_inside_tree():
		return 

	_fade_deadline_msec = Time.get_ticks_msec() + int(display_duration * 1000)
	while true:
		var now = Time.get_ticks_msec()
		var wait_time = (_fade_deadline_msec - now) / 1000.0
		if wait_time <= 0:
			break
		await Global.delay(min(wait_time, 0.1))  # Wait in small slices
		if my_id != _fade_id or !is_inside_tree():
			return


	await _play_fade_animation()
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

func _play_flash_animation() -> void:
	var normal_color := positive_value_color if _current_value >= 0 else negative_value_color
	_tween = create_tween()
	_tween.tween_property(self, "theme_override_colors/default_color", normal_color, flash_duration)
	await _tween.finished

func _play_fade_animation() -> void:
	await _FX.disintegrate(fade_duration)

func reset() -> void:
	_fade_id += 1
	_kill_tweens()
	_current_value = 0
	hide()
	modulate.a = 1.0

func soft_reset() -> void:
	if !_enabled:
		return
	
	_fade_id += 1
	var my_id = _fade_id
	_kill_tweens()
	_current_value = 0
	
	await _play_fade_animation()
	if my_id != _fade_id or !is_inside_tree():
		return  # Interrupted by another delta or destroyed

	hide()
	modulate.a = 1.0

func _kill_tweens():
	_tween.kill()
	_FX.kill_tweens()

func disable() -> void:
	_enabled = false

func enable() -> void:
	_enabled = true

func refresh() -> void:
	if _fade_deadline_msec > 0:
		_fade_deadline_msec = Time.get_ticks_msec() + int(display_duration * 1000)

