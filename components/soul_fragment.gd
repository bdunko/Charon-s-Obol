extends Control

@onready var _SPRITE = $Sprite

func _ready():
	# randomize appearance
	_SPRITE.frame = Global.RNG.randi_range(0, 4)

func _on_mouse_entered():
	UITooltip.create(self, "[color=aquamarine]Soul Fragment (%d)[/color]\nSpent to buy new coins.\nEarn as many as you can." % Global.souls, get_global_mouse_position(), get_tree().root)
