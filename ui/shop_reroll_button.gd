extends Textbox

func _ready():
	Global.state_changed.connect(_on_state_changed)
	Global.rerolls_changed.connect(_on_rerolls_changed)


const _FORMAT = "[center][color=#e12f3b]-%d[/color][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img] Reroll[/center]"
const _FORMAT_0 = "[center]Reroll Stock[/center]"
func _on_strain_changed() -> void:
	var strain_cost = Global.strain_cost()
	_TEXT.text = _FORMAT_0 if strain_cost == 0 else _FORMAT % strain_cost

func _on_rerolls_changed() -> void:
	var reroll_cost = Global.reroll_cost()
	_TEXT.text = _FORMAT_0 if reroll_cost == 0 else _FORMAT % reroll_cost
	pass

func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		show()
	else:
		hide()
