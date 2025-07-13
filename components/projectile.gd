class_name Projectile
extends Node2D

signal impact_finished

@onready var _TRAIL_PARTICLES = $FancyTrail
@onready var _SPRITE = $Sprite
@onready var _SPRITE_FX = $Sprite/FX

static var PARAMS_GREEN = ProjectileParams.new().recolor(Projectile.RecolorParams.GREEN_RECOLOR())
static var PARAMS_RED = ProjectileParams.new().recolor(Projectile.RecolorParams.RED_RECOLOR())
static var PARAMS_BLUE  = ProjectileParams.new().recolor(Projectile.RecolorParams.BLUE_RECOLOR())
static var PARAMS_YELLOW = ProjectileParams.new().recolor(Projectile.RecolorParams.YELLOW_RECOLOR())
static var PARAMS_BROWN = ProjectileParams.new().recolor(Projectile.RecolorParams.BROWN_RECOLOR())
static var PARAMS_GRAY = ProjectileParams.new().recolor(Projectile.RecolorParams.GRAY_RECOLOR())
static var PARAMS_WHITE = ProjectileParams.new().recolor(Projectile.RecolorParams.WHITE_RECOLOR())

enum TrajectoryType {
	STRAIGHT,
	CURVED,
	PARABOLIC,
	WOBBLE,
	DELAYED_HOP
}

class RecolorParams:
	var swaps := [] # Array of dictionaries with keys "from" and "to"

	func add_swap(color_from: Color, color_to: Color) -> RecolorParams:
		swaps.append({"from": color_from, "to": color_to})
		return self

	func set_swaps(
		color1: Color, to1: Color,
		color2: Color = FX.NULL_COLOR, to2: Color = FX.NULL_COLOR,
		color3: Color = FX.NULL_COLOR, to3: Color = FX.NULL_COLOR,
		color4: Color = FX.NULL_COLOR, to4: Color = FX.NULL_COLOR,
		color5: Color = FX.NULL_COLOR, to5: Color = FX.NULL_COLOR
	) -> RecolorParams:
		swaps.clear()
		if color1 != FX.NULL_COLOR and to1 != FX.NULL_COLOR:
			swaps.append({"from": color1, "to": to1})
		if color2 != FX.NULL_COLOR and to2 != FX.NULL_COLOR:
			swaps.append({"from": color2, "to": to2})
		if color3 != FX.NULL_COLOR and to3 != FX.NULL_COLOR:
			swaps.append({"from": color3, "to": to3})
		if color4 != FX.NULL_COLOR and to4 != FX.NULL_COLOR:
			swaps.append({"from": color4, "to": to4})
		if color5 != FX.NULL_COLOR and to5 != FX.NULL_COLOR:
			swaps.append({"from": color5, "to": to5})
		return self
	
	const _LIGHT_PURPLE = Color("#e86a73")
	const _PURPLE = Color("#bc4a9b")
	const _DARK_PURPLE = Color("#793a80")
	
	static func GREEN_RECOLOR() -> RecolorParams:
		var recolor = RecolorParams.new()
		return recolor.set_swaps(
			_LIGHT_PURPLE, Color("#9cdb43"),
			_PURPLE, Color("#59c135"),
			_DARK_PURPLE, Color("#14a02e")
		)
	
	static func RED_RECOLOR() -> RecolorParams:
		var recolor = RecolorParams.new()
		return recolor.set_swaps(
			_LIGHT_PURPLE, Color("#f9a31b"),
			_PURPLE, Color("#fa6a0a"),
			_DARK_PURPLE, Color("#df3e23")
		)
	
	static func YELLOW_RECOLOR() -> RecolorParams:
		var recolor = RecolorParams.new()
		return recolor.set_swaps(
			_LIGHT_PURPLE, Color("#fffc40"),
			_PURPLE, Color("#ffd541"),
			_DARK_PURPLE, Color("#f9a31b")
		)
	
	static func BLUE_RECOLOR() -> RecolorParams:
		var recolor = RecolorParams.new()
		return recolor.set_swaps(
			_LIGHT_PURPLE, Color("#a6fcdb"),
			_PURPLE, Color("#20d6c7"),
			_DARK_PURPLE, Color("#249fde")
		)

	static func GRAY_RECOLOR() -> RecolorParams:
		var recolor = RecolorParams.new()
		return recolor.set_swaps(
			_LIGHT_PURPLE, Color("#b3b9d1"),
			_PURPLE, Color("#8b93af"),
			_DARK_PURPLE, Color("#6d758d")
		)

	static func BROWN_RECOLOR() -> RecolorParams:
		var recolor = RecolorParams.new()
		return recolor.set_swaps(
			_LIGHT_PURPLE, Color("#e9b5a3"),
			_PURPLE, Color("#ba756a"),
			_DARK_PURPLE, Color("#8e5252")
		)
	
	static func WHITE_RECOLOR() -> RecolorParams:
		var recolor = RecolorParams.new()
		return recolor.set_swaps(
			_LIGHT_PURPLE, Color("#ffffff"),
			_PURPLE, Color("#dae0ea"),
			_DARK_PURPLE, Color("#b3b9d1")
		)

class ProjectileParams:
	var _speed: float = 170.0
	var _trajectory: int = TrajectoryType.DELAYED_HOP

	# Trajectory-specific options (prefixed with _)
	var _parabola_height: float = 20.0
	var _wobble_amplitude: float = 6.0
	var _wobble_frequency: float = 1.0
	var _hop_height: float = 30.0
	var _hop_delay: float = 0.3

	# Optional recolor params
	var recolor_params: RecolorParams = null

	func speed(value: float) -> ProjectileParams:
		_speed = value
		return self

	func trajectory(value: int) -> ProjectileParams:
		_trajectory = value
		return self

	func parabola_height(value: float) -> ProjectileParams:
		_parabola_height = value
		return self

	func wobble_amplitude(value: float) -> ProjectileParams:
		_wobble_amplitude = value
		return self

	func wobble_frequency(value: float) -> ProjectileParams:
		_wobble_frequency = value
		return self

	func hop_height(value: float) -> ProjectileParams:
		_hop_height = value
		return self

	func hop_delay(value: float) -> ProjectileParams:
		_hop_delay = value
		return self

	func recolor(value: RecolorParams) -> ProjectileParams:
		recolor_params = value
		return self

@export var curve_height: float = 50.0
@export var curve_offset: Vector2 = Vector2.ZERO

@export_range(0.0, 1.0, 0.01)
var fade_in_fraction := 0.15

@export_range(0.0, 1.0, 0.01)
var fade_out_fraction := 0.15

var _t_internal := 0.0
var _trajectory_type: TrajectoryType = TrajectoryType.STRAIGHT
var _params := ProjectileParams.new()

var t:
	get:
		return _t_internal
	set(value):
		_t_internal = value
		match _trajectory_type:
			TrajectoryType.CURVED:
				global_position = quadratic_bezier(_start_position, _control_point, _target_position, _t_internal)
			TrajectoryType.STRAIGHT:
				global_position = linear_interpolate(_start_position, _target_position, _t_internal)
			TrajectoryType.PARABOLIC:
				global_position = parabolic_path(_start_position, _target_position, _t_internal, _params._parabola_height)
			TrajectoryType.WOBBLE:
				global_position = wobble_path(_start_position, _target_position, _t_internal, _params._wobble_amplitude, _params._wobble_frequency)
			TrajectoryType.DELAYED_HOP:
				pass # controlled in launch()
		if _trajectory_type != TrajectoryType.DELAYED_HOP:
			look_at(_target_position)

var _start_position := Vector2.ZERO
var _target_position := Vector2.ZERO
var _control_point := Vector2.ZERO

func quadratic_bezier(p0: Vector2, p1: Vector2, p2: Vector2, time: float) -> Vector2:
	var u = 1.0 - time
	return u * u * p0 + 2 * u * time * p1 + time * time * p2

func linear_interpolate(p0: Vector2, p1: Vector2, time: float) -> Vector2:
	return p0.lerp(p1, time)

func parabolic_path(p0: Vector2, p1: Vector2, time: float, height: float) -> Vector2:
	var mid = p0.lerp(p1, time)
	var arc = -4.0 * height * time * (time - 1.0)
	return mid + Vector2(0, arc)

func wobble_path(p0: Vector2, p1: Vector2, time: float, amplitude: float, frequency: float) -> Vector2:
	var base = p0.lerp(p1, time)
	var tangent = (p1 - p0).normalized()
	var normal = Vector2(-tangent.y, tangent.x)
	var wobble = sin(time * TAU * frequency) * amplitude
	return base + normal * wobble

func apply_recolor(params: ProjectileParams) -> void:
	if params.recolor_params == null or params.recolor_params.swaps.size() == 0:
		return

	var swaps = params.recolor_params.swaps
	var from_colors = []
	var to_colors = []

	for i in range(min(swaps.size(), 5)):
		from_colors.append(swaps[i]["from"])
		to_colors.append(swaps[i]["to"])

	while from_colors.size() < 5:
		from_colors.append(FX.NULL_COLOR)
		to_colors.append(FX.NULL_COLOR)

	_SPRITE_FX.multi_recolor(
		from_colors[0], to_colors[0],
		from_colors[1], to_colors[1],
		from_colors[2], to_colors[2],
		from_colors[3], to_colors[3],
		from_colors[4], to_colors[4],
	)
	
	_TRAIL_PARTICLES.process_material.color = to_colors[0]

func launch(from: Vector2, to: Vector2, params := ProjectileParams.new()) -> void:
	_start_position = from
	_target_position = to
	_params = params
	_trajectory_type = params._trajectory

	var distance = from.distance_to(to)
	var duration = distance / params._speed

	if _trajectory_type == TrajectoryType.CURVED:
		var mid_point = (from + to) * 0.5
		var direction = (to - from).normalized()
		var perpendicular = Vector2(-direction.y, direction.x)

		var diff = to - from
		var max_horizontal_distance := 300.0
		var curve_direction_factor = clamp(diff.x / max_horizontal_distance, -1.0, 1.0)

		_control_point = mid_point + perpendicular * curve_height * curve_direction_factor + curve_offset

	match _trajectory_type:
		TrajectoryType.CURVED:
			global_position = quadratic_bezier(_start_position, _control_point, _target_position, 0.0)
		TrajectoryType.STRAIGHT, TrajectoryType.PARABOLIC, TrajectoryType.WOBBLE, TrajectoryType.DELAYED_HOP:
			global_position = _start_position

	look_at(_target_position)

	# Apply recolor here:
	apply_recolor(params)

	_TRAIL_PARTICLES.modulate.a = 0.0
	_SPRITE_FX.hide()

	var fade_in_time = clamp(fade_in_fraction, 0.0, 1.0) * duration
	var fade_out_time = clamp(fade_out_fraction, 0.0, 1.0) * duration

	create_tween().tween_property(_TRAIL_PARTICLES, "modulate:a", 1.0, fade_in_time)
	_SPRITE_FX.fade_in(fade_in_time)

	match _trajectory_type:
		TrajectoryType.DELAYED_HOP:
			var hop_up_time = params._hop_delay * 0.5
			var hang_time = params._hop_delay * 0.5
			var fall_time = duration - (hop_up_time + hang_time)
			var hop_peak = _start_position + Vector2(0, -params._hop_height)

			create_tween().tween_property(self, "global_position", hop_peak, hop_up_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
			await Global.delay(hop_up_time + hang_time)

			create_tween().tween_property(self, "global_position", _target_position, fall_time).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await Global.delay(fall_time)
		_:
			create_tween().tween_property(self, "t", 1.0, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
			await Global.delay(duration)

	if _trajectory_type != TrajectoryType.DELAYED_HOP:
		await Global.delay(-fade_out_fraction * duration + fade_out_time)

	emit_signal("impact_finished")

	_SPRITE_FX.disintegrate(fade_out_time)
	await Global.delay(fade_out_time)
	
	_TRAIL_PARTICLES.emitting = false
	_wait_for_particles_and_delete(duration)

# a bit of a hack here
func _wait_for_particles_and_delete(duration):
	await Global.delay(duration / 2.0)
	queue_free()
