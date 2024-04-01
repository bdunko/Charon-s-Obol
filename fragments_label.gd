extends Label

func _ready():
	Global.fragments_count_changed.connect(_on_fragments_count_changed)
	
func _on_fragments_count_changed() -> void:
	text = "%s" % Global.fragments
