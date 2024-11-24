extends Textbox

func _ready() -> void:
	super._ready()
	Global.state_changed.connect(_on_state_changed)

func _on_state_changed() -> void:
	if Global.state == Global.State.BEFORE_FLIP:
		show()
	else:
		hide()
