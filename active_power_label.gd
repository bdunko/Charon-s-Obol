extends RichTextLabel

func _ready() -> void:
	Global.active_coin_power_family_changed.connect(_on_active_coin_power_family_changed)
	hide()

const _FORMAT = "[center]%s[/center]"
func _on_active_coin_power_family_changed() -> void:
	if Global.active_coin_power_family == null:
		hide()
	else:
		if Global.active_coin_power_family == Global.POWER_FAMILY_ARROW_REFLIP:
			text = _FORMAT % "[color=purple]Arrow of Night[/color]"
		elif Global.is_patron_power(Global.active_coin_power_family):
			text = _FORMAT % "Call upon %s!" % Global.patron.god_name
		else:
			text = _FORMAT % Global.active_coin_power_coin.get_subtitle()
		show()
