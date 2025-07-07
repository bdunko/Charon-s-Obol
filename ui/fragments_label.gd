extends Control

@onready var _FX : FX = $FX
@onready var _LABEL : AnimatedLabel = $AnimatedLabel

func _ready():
	Global.souls_count_changed.connect(_on_souls_count_changed)
	Global.state_changed.connect(_on_state_changed)
	
func _on_souls_count_changed(_change: int) -> void:
	_LABEL.set_text("[center]%d[/center]" % Global.souls)

func _on_state_changed() -> void:
	if Global.state == Global.State.BOARDING:
		_FX.hide()

func fade_in() -> void:
	_FX.show()
	_FX.disintegrate_in(0.2)
