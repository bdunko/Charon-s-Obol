class_name Projectile
extends Node2D

signal impact_finished

func launch(from: Vector2, to: Vector2, duration := 0.5) -> void:
	global_position = from
	look_at(to)

	# === Entry: Pop in with scale + fade ===
	scale = Vector2(0.3, 0.3)
	modulate.a = 0.0
	var entry = create_tween()
	entry.tween_property(self, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	entry.tween_property(self, "scale", Vector2(1.0, 1.0), 0.05)
	entry.parallel().tween_property(self, "modulate:a", 1.0, 0.08)

	await entry.finished

	# === Travel: Linear motion, no easing ===
	var move = create_tween()
	move.tween_property(self, "global_position", to, duration).set_trans(Tween.TRANS_LINEAR)

	await move.finished

	# === Exit: Scale + fade out ===
	var exit = create_tween()
	exit.tween_property(self, "scale", Vector2(0.0, 0.0), 0.12).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	exit.parallel().tween_property(self, "modulate:a", 0.0, 0.12)

	await exit.finished

	emit_signal("impact_finished")
	queue_free()
