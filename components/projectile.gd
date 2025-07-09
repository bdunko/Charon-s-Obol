class_name Projectile
extends Node2D

signal impact_finished

@export_range(0.0, 1.0, 0.01)
var fade_fraction := 0.1

var _t_internal := 0.0

var t:
	get:
		return _t_internal
	set(value):
		_t_internal = value
		global_position = quadratic_bezier(_start_position, _control_point, _target_position, _t_internal)
		look_at(_target_position)

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	return u * u * p0 + 2 * u * t * p1 + t * t * p2

var _start_position := Vector2.ZERO
var _target_position := Vector2.ZERO
var _control_point := Vector2.ZERO

func launch(from: Vector2, to: Vector2, duration := 0.5) -> void:
	_start_position = from
	_target_position = to

	var mid_point = (from + to) * 0.5
	var direction = (to - from).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)
	var curve_height = 50.0
	_control_point = mid_point + perpendicular * curve_height

	# Set initial position exactly on the curve start point
	global_position = quadratic_bezier(_start_position, _control_point, _target_position, 0.0)
	look_at(_target_position)

	modulate.a = 0.0

	var fade_time = clamp(fade_fraction, 0.0, 1.0) * duration

	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 1.0, fade_time)
	tween.tween_property(self, "t", 1.0, duration)
	tween.parallel().tween_property(self, "modulate:a", 0.0, fade_time).set_delay(duration - fade_time)

	await tween.finished

	emit_signal("impact_finished")
	queue_free()
