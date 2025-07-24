extends Node2D

@export var tween_speed: float = 10.0
@export var tween_trans: Tween.TransitionType = Tween.TransitionType.TRANS_LINEAR
@export var tween_ease: Tween.EaseType = Tween.EaseType.EASE_IN_OUT

var _target_offset: Vector2 = Vector2.ZERO
var _tween: Tween

func set_offset(new_offset: Vector2) -> void:
	_target_offset = new_offset
	
	# Restart tween to new offset smoothly
	if _tween:
		_tween.kill()  # Cancel any existing tween
	_tween = create_tween()
	_tween.tween_property(self, "position", _target_offset, 1.0 / tween_speed).set_trans(tween_trans).set_ease(tween_ease)
