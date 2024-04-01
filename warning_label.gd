extends Label

@onready var _TIMER = $Timer

func _ready():
	Global.warning.connect(_on_warning)
	Global.state_changed.connect(_on_state_changed)

func _on_warning(warning_msg: String) -> void:
	text = warning_msg
	_TIMER.start()
	show()

func _on_state_changed() -> void:
	hide()

func _on_timer_timeout():
	hide()
