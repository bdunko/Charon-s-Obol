extends Control

@onready var _SPRITE = $Sprite

func _ready():
	# randomize appearance
	_SPRITE.frame = Global.RNG.randi_range(0, 4)

func _on_mouse_entered():
	UITooltip.create(self, "[color=crimson]Life Fragment (%d)[/color]\nIf you run out, you'll die." % Global.lives, get_global_mouse_position(), get_tree().root)
