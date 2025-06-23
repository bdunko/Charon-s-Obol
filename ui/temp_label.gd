class_name TempLabel
extends RichTextLabel

@export var move_time = 0.5
const _PAUSE_TIME = 0.5
const _FADE_TIME = 0.1
@export var y_amount = 18

func _ready():
	# wait a frame and recenter
	hide()
	await get_tree().process_frame
	size.x += 2 # make space for border...
	position -= (size / 2.0) #center label
	show()
	
	# start moving upwards
	var start_y = position.y
	var pause_time = _PAUSE_TIME

	var tween = create_tween()

	# Move up and scale up simultaneously
	tween.tween_property(self, "position:y", start_y - y_amount, move_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, move_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

	# Pause for 0.5 seconds (no movement)
	tween.tween_interval(pause_time)

	# Fade out
	tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 0), _FADE_TIME).set_trans(Tween.TRANS_LINEAR)

	await tween.finished
	queue_free()
