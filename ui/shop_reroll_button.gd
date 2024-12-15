extends Textbox

func _ready():
	super._ready()
	Global.state_changed.connect(_on_state_changed)
	Global.rerolls_changed.connect(_on_rerolls_changed)


const _FORMAT = "[center][color=#e12f3b]-%d[/color][img=10x13]res://assets/icons/soul_fragment_blue_icon.png[/img] Reroll[/center]"
const _FORMAT_0 = "[center]Reroll Stock[/center]"
func _on_ante_changed() -> void:
	var ante_cost = Global.ante_cost()
	_TEXT.text = _FORMAT_0 if ante_cost == 0 else _FORMAT % ante_cost

func _on_rerolls_changed() -> void:
	var reroll_cost = Global.reroll_cost()
	_TEXT.text = _FORMAT_0 if reroll_cost == 0 else _FORMAT % reroll_cost
	pass

func _on_state_changed() -> void:
	if Global.tutorialState != Global.TutorialState.INACTIVE:
		hide()
		return
	
	if Global.state == Global.State.SHOP:
		show()
	else:
		hide()
