extends Control

@onready var _SPRITE = $Sprite

func _ready():
	# randomize appearance
	_SPRITE.frame = Global.RNG.randi_range(0, 4)
