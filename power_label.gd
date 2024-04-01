extends Label

func _ready() -> void:
	Global.active_coin_power_changed.connect(_on_active_coin_power_changed)

func _on_active_coin_power_changed() -> void:
	if Global.active_coin_power != Global.Power.NONE:
		if Global.active_coin_power == Global.Power.ARROW_REFLIP: # special case - arrow power has no coin
			text = "Power: Arrow Reflip"
		else:
			text = "Power: %s" % Global.active_coin_power_coin.get_power_string()
		show()
	else:
		hide()

