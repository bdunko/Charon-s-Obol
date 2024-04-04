extends Textbox

func _ready() -> void:
	Global.state_changed.connect(_on_state_changed)
	Global.shop_reroll_count_changed.connect(_update_text)
	Global.fragments_count_changed.connect(_update_text)

func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		show()
	else:
		hide()

const _FORMAT = "[color=%s]%d[/color][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img] Reroll Shop"
func _update_text() -> void:
	var reroll_price = Global.reroll_price()
	if reroll_price == 0:
		_TEXT.text = "Reroll Shop"
	else:
		var text_color = Global.AFFORDABLE_COLOR if reroll_price <= Global.fragments else Global.UNAFFORDABLE_COLOR
		_TEXT.text = _FORMAT % [text_color, Global.reroll_price()]
