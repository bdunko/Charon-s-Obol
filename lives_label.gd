extends Label

func _ready():
	Global.life_count_changed.connect(_on_life_count_changed)

func _on_life_count_changed() -> void:
	text = str(Global.lives)
