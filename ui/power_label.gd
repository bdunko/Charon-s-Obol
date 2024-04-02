extends Label

func _ready() -> void:
	Global.power_text_changed.connect(_on_power_text_changed)
	hide()

func _on_power_text_changed() -> void:
	show()
	text = Global.power_text
