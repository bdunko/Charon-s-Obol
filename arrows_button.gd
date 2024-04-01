extends Button

func _ready():
	Global.arrow_count_changed.connect(_on_arrow_count_changed)
	Global.state_changed.connect(_on_state_changed)
	
func _on_arrow_count_changed() -> void:
	visible = Global.arrows != 0
	text = "Arrows: %d" % Global.arrows

func _on_state_changed() -> void:
	if Global.state != Global.State.AFTER_FLIP:
		disabled = true
