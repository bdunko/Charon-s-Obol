extends Label

@onready var _FX : FX = $FX

func _ready():
	Global.life_count_changed.connect(_on_life_count_changed)
	Global.state_changed.connect(_on_state_changed)

func _on_life_count_changed(change: int) -> void:
	text = str(max(0, Global.lives))

func _on_state_changed() -> void:
	if Global.state == Global.State.BOARDING:
		_FX.hide()
	elif Global.lives != 0:
		fade_in()

func fade_in() -> void:
	_FX.fade_in(1.0)
