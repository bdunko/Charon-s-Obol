class_name SpeedrunTimer
extends Label

var _start_time_msec := 0
var _finished := false

func _ready():
	start()

func finish() -> void:
	_finished = true
	self.set("theme_override_colors/font_color", Color.GOLD)

func start() -> void:
	_finished = false
	_start_time_msec = Time.get_ticks_msec()
	self.set("theme_override_colors/font_color", Color.WHITE)

func _process(_delta):
	if not _finished:
		var msec_elapsed = Time.get_ticks_msec() - _start_time_msec
		var secs_elapsed = int(msec_elapsed / 1000.0)
		var mins = floor(secs_elapsed / 60.0)
		var secs = secs_elapsed % 60
		text = "%02d:%02d" % [mins, secs]

func get_time() -> String:
	return text
