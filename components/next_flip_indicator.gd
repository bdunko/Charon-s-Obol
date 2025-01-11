extends AnimatedSprite2D

func _ready() -> void:
	Global.patron_changed.connect(_update_visibility)
	Global.state_changed.connect(_update_visibility)
	call_deferred("_update_visibility")

func update(next_heads: bool, is_trial: bool) -> void:
	if is_trial:
		play("trial")
		return
	play("heads") if next_heads else play("tails")

func _update_visibility() -> void:
	if Global.is_passive_active(Global.PATRON_POWER_FAMILY_ATHENA) and Global.state != Global.State.CHARON_OBOL_FLIP:
		show()
	else:
		hide()
