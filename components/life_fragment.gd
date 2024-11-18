extends Control

@onready var _SPRITE = $Sprite
#@onready var _FX = $Sprite/FX

func _ready():
	# randomize appearance
	_SPRITE.frame = Global.RNG.randi_range(0, 4)
	#_FX.start_glowing(Color.RED)

func _on_mouse_entered():
	UITooltip.create(self, "[color=crimson]Life Fragment (%d)[/color]\nDon't run out..." % Global.lives, get_global_mouse_position(), get_tree().root)
