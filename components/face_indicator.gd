extends AnimatedSprite2D

func update(next_heads: bool, is_trial: bool) -> void:
	if is_trial:
		play("trial")
		return
	play("heads") if next_heads else play("tails")
