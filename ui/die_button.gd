extends Textbox

func _ready():
	Global.state_changed.connect(_on_state_changed)

func _on_state_changed() -> void:
	if Global.state == Global.State.TOLLGATE:
		show()
	else:
		hide()
