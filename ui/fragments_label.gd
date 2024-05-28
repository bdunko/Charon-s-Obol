extends Label

func _ready():
	Global.souls_count_changed.connect(_on_souls_count_changed)
	
func _on_souls_count_changed() -> void:
	text = str(Global.souls)
