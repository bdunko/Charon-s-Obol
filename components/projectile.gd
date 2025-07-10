class_name Projectile
extends Node2D

signal impact_finished

@onready var _TRAIL_PARTICLES = $FancyTrail
@onready var _SPRITE = $Sprite
@onready var _SPRITE_FX = $Sprite/FX

@export var curve_height: float = 50.0
@export var curve_offset: Vector2 = Vector2.ZERO

@export_range(0.0, 1.0, 0.01)
var fade_in_fraction := 0.15

@export_range(0.0, 1.0, 0.01)
var fade_out_fraction := 0.15

var _t_internal := 0.0

var t:
	get:
		return _t_internal
	set(value):
		_t_internal = value
		global_position = quadratic_bezier(_start_position, _control_point, _target_position, _t_internal)
		look_at(_target_position)

var _start_position := Vector2.ZERO
var _target_position := Vector2.ZERO
var _control_point := Vector2.ZERO

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	var u = 1.0 - t
	return u * u * p0 + 2 * u * t * p1 + t * t * p2

func launch(from: Vector2, to: Vector2, speed: float = 180.0) -> void:
	_start_position = from
	_target_position = to

	var distance = from.distance_to(to)
	var duration = distance / speed

	var mid_point = (from + to) * 0.5
	var direction = (to - from).normalized()
	var perpendicular = Vector2(-direction.y, direction.x)

	var diff = to - from

	var max_horizontal_distance := 300.0
	var curve_direction_factor = clamp(diff.x / max_horizontal_distance, -1.0, 1.0)

	_control_point = mid_point + perpendicular * curve_height * curve_direction_factor + curve_offset

	global_position = quadratic_bezier(_start_position, _control_point, _target_position, 0.0)
	look_at(_target_position)

	_TRAIL_PARTICLES.modulate.a = 0.0
	_SPRITE_FX.hide()

	var fade_in_time = clamp(fade_in_fraction, 0.0, 1.0) * duration
	var fade_out_time = clamp(fade_out_fraction, 0.0, 1.0) * duration

	create_tween().tween_property(_TRAIL_PARTICLES, "modulate:a", 1.0, fade_in_time)
	_SPRITE_FX.fade_in(fade_in_time)
	create_tween().tween_property(self, "t", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await Global.delay(duration - fade_out_time)
	_SPRITE_FX.disintegrate(fade_out_time)
	#create_tween().tween_property(_SPRITE, "modulate:a", 0.0, fade_out_time)
	await Global.delay(fade_out_time)

	emit_signal("impact_finished")
	
	_TRAIL_PARTICLES.emitting = false
	await Global.delay(duration / 2.0) #chea ta bit; delay so particles don't vanish suddenly
	queue_free()
