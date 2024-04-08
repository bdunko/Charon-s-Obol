extends Textbox

func _ready() -> void:
	Global.state_changed.connect(_on_state_changed)
	Global.coin_value_changed.connect(_update_text)

func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		_update_text()
		show()
	else:
		hide()

const _FORMAT = "Pay Toll (%d/%d)"
func _update_text() -> void:
	_TEXT.text = _FORMAT % [Global.coin_value, Global.goal_coin_value]
