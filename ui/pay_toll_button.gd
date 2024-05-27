extends Textbox

func _ready() -> void:
	Global.state_changed.connect(_on_state_changed)
	Global.toll_coins_changed.connect(_update_text)

func _on_state_changed() -> void:
	if Global.state == Global.State.TOLLGATE:
		show()
	else:
		hide()

const _FORMAT = "Pay Toll (%d/%d[img=12x13]res://assets/icons/coin_icon.png[/img])"
func _update_text() -> void:
	_TEXT.text = _FORMAT % [Global.calculate_toll_coin_value(), Global.TOLLGATE_PRICES[Global.toll_index]]
