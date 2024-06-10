extends RichTextLabel

func _ready() -> void:
	Global.active_coin_power_changed.connect(_on_active_coin_power_changed)
	hide()

const _FORMAT = "[center]%s[/center]"
func _on_active_coin_power_changed() -> void:
	if Global.active_coin_power == Global.Power.NONE:
		hide()
	else:
		if Global.active_coin_power == Global.Power.ARROW_REFLIP:
			text = _FORMAT % "[color=yellow]Arrow of Light[/color]"
		elif Global.is_patron_power(Global.active_coin_power):
			text = _FORMAT % "Call upon %s!" % Global.patron.god_name
		else:
			text = _FORMAT % Global.active_coin_power_coin.get_subtitle()
		show()
