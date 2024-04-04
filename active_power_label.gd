extends Label

func _ready() -> void:
	Global.active_coin_power_changed.connect(_on_active_coin_power_changed)
	hide()

func _on_active_coin_power_changed() -> void:
	if Global.active_coin_power == Global.Power.NONE:
		hide()
	else:
		if Global.active_coin_power == Global.Power.ARROW_REFLIP:
			text = "Arrow of Light"
		else:
			text = Global.active_coin_power_coin.get_subtitle()
		show()
