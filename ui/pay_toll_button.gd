extends Textbox

func _ready() -> void:
	super._ready()
	Global.state_changed.connect(_on_state_changed)
	Global.toll_coins_changed.connect(_on_toll_coins_changed)

func _on_state_changed() -> void:
	if Global.state == Global.State.TOLLGATE:
		_on_toll_coins_changed()
		show()
	else:
		hide()

const _FORMAT = "Pay Toll (%d/%d[img=12x13]res://assets/icons/coin_icon.png[/img])"
func _on_toll_coins_changed() -> void:
	var offered = Global.calculate_toll_coin_value()
	_TEXT.text = _FORMAT % [offered, Global.current_round_toll()]
	enable() if offered >= Global.current_round_toll() else disable()
