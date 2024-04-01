extends Button

func _ready():
	Global.state_changed.connect(_on_state_changed)

func _on_state_changed() -> void:
	if Global.state == Global.State.AFTER_FLIP or Global.state == Global.State.SHOP:
		show()
	else:
		hide()
