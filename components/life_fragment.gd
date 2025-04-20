extends Control

@onready var _SPRITE = $Sprite
#@onready var _FX = $Sprite/FX

func _ready():
	# randomize appearance
	_SPRITE.frame = Global.RNG.randi_range(0, 4)
	#_FX.start_glowing(Color.RED)

func _on_mouse_entered():
	pass
	#UITooltip.create(self, "[color=crimson]Life Fragment[img=10x13]res://assets/icons/soul_fragment_red_icon.png[/img] (%d)[/color]\nDon't run out..." % Global.lives, get_global_mouse_position(), get_tree().root)
