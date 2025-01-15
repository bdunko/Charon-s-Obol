extends Sprite2D

@onready var _FX: FX = $FX

# Called when the node enters the scene tree for the first time.
func _ready():
	Global.state_changed.connect(_on_state_changed)
	hide()
	hide_mat()

func _on_state_changed() -> void:
	if Global.state == Global.State.SHOP:
		show_mat()
	else:
		hide_mat()

func hide_mat() -> void:
	await _FX.disintegrate(0.2)
	hide()

func show_mat() -> void:
	show()
	await _FX.disintegrate_in(0.2)
