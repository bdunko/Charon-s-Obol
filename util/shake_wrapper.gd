class_name ShakeWrapper
extends Node2D

# some recommended values
const STRONG_DURATION := 0.25
const STRONG_STRENGTH := 3.0
const WEAK_DURATION := 0.1
const WEAK_STRENGTH := 1.25

@export var default_duration := 0.15
@export var default_strength := 1.5

var _elapsed := 0.0
var _is_shaking := false

var _current_duration := default_duration
var _current_strength := default_strength

func _process(delta):
	if _is_shaking:
		_elapsed += delta
		if _elapsed >= _current_duration:
			_is_shaking = false
			position = Vector2.ZERO
		else:
			position = Vector2(
				randf_range(-_current_strength, _current_strength),
				randf_range(-_current_strength, _current_strength)
			)
	elif position != Vector2.ZERO:
		position = Vector2.ZERO

func start_shake(new_duration: float = default_duration, new_strength: float = default_strength):
	_current_duration = new_duration
	_current_strength = new_strength
	_elapsed = 0.0
	_is_shaking = true
