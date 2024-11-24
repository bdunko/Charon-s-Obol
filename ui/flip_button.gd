extends Textbox

func _ready() -> void:
	super._ready()
	Global.state_changed.connect(_on_state_changed)
	Global.strain_changed.connect(_on_strain_changed)

func _on_state_changed() -> void:
	if Global.state == Global.State.BEFORE_FLIP or Global.state == Global.State.CHARON_OBOL_FLIP:
		show()
	else:
		hide()

const _FORMAT = "[center][color=#e12f3b]%d[/color][img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] Toss[/center]"
const _FORMAT_0 = "[center]Toss[/center]"
func _on_strain_changed() -> void:
	var strain_cost = Global.strain_cost()
	_TEXT.text = _FORMAT_0 if strain_cost == 0 else _FORMAT % strain_cost
