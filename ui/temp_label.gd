class_name TempLabel
extends RichTextLabel

signal ready_for_destroy

@onready var _FX = $FX

@export var move_time = 0.3
@export var scale_time = 0.1
const _PAUSE_TIME = 1.0
const _FADE_TIME = 0.1
@export var y_amount = 17
@export var starting_scale = Vector2(1.0, 1.0)

var _destroying := false
var _tween: Tween

func _ready():
	hide()
	await get_tree().process_frame
	size.x += 2  # Add 2 pixels for border padding to avoid clipping
	pivot_offset = size / 2.0
	position -= (size / 2.0)
	scale = starting_scale
	show()
	
	var start_y = position.y
	_tween = create_tween()

	_tween.tween_property(self, "position:y", start_y - y_amount, scale_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.parallel().tween_property(self, "scale", Vector2.ONE, move_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_tween.tween_interval(_PAUSE_TIME)
	await _tween.finished
	await _FX.disintegrate(_FADE_TIME)
	if _destroying:
		return
	_destroying = true
	emit_signal("ready_for_destroy")


func destroy():
	if _destroying:
		return
	_destroying = true

	if _tween and _tween.is_running():
		_tween.kill()

	_tween = create_tween()
	_tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 0), 0.1)
	await _tween.finished

	emit_signal("ready_for_destroy")
