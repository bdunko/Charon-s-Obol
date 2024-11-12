class_name FX
extends AnimationPlayer

# api for general effects
# enum for each possible shader parameter "uniform"
# set(enum, value)
# clear(enum, value)
# tween(enum, value_from, value_to, time) <- awaitable; emits signal tween_completed(enum) as well
# oscillate(enum, value_from, value_to, time)
# stop(enum) <- kills any tweens or oscillations

# prebaked effects -
# flash <- need start time
# slow_flash
# recolor (renamed replace_color)
# recolor_outline
# set_tint / clear_tint
# set_glow / clear_glow
# fade_out
# fade_in
# alpha (REMOVE - replaced by flicker mostly)

# - added -
# scan (pass scan direction as enum)
# disintegrate
# flicker <- needs start time


const OUTLINE_COLOR = Color(20.0/255.0, 16.0/255.0, 19.0/255.0)

func _ready() -> void:
	assert(get_parent().material) # precondition - parent's material is shader.gdshader
	assert(get_parent().material is ShaderMaterial)

func flash(color: Color) -> void:
	get_parent().material.set_shader_parameter("flash_color", color)
	play("flash")

func slow_flash(color: Color) -> void:
	get_parent().material.set_shader_parameter("flash_color", color)
	play("slow_flash")

func replace_color(i: int, color: Color, with: Color) -> void:
	assert(i >= 1 and i <= 5, "We only support replacing up to 5 colors.")
	if i < 1 or i > 5:
		return
	get_parent().material.set_shader_parameter("replace_color%d" % i, color)
	get_parent().material.set_shader_parameter("replace_with_color%d" % i, with)

func clear_replace_color() -> void:
	for i in range(1, 5):
		get_parent().material.set_shader_parameter("replace_color%d" % i, Color.BLACK)
		get_parent().material.set_shader_parameter("replace_with_color%d" % i, Color.BLACK)

func tint(color: Color, strength: float, auto_flash_speed: float = 0.0) -> void:
	assert(strength >= 0.0 and strength <= 1.0)
	get_parent().material.set_shader_parameter("tint_color", color)
	get_parent().material.set_shader_parameter("tint_strength", strength)
	get_parent().material.set_shader_parameter("tint_auto_flash_speed", auto_flash_speed)

func clear_tint() -> void:
	get_parent().material.set_shader_parameter("tint_strength", 0.0)

func glow(color: Color, thickness: int = 1, initial: bool = true) -> void:
	if initial: # start glow from outline_glow_min if true
		get_parent().material.set_shader_parameter("outline_start_time", Time.get_ticks_msec()/1000.0)
	get_parent().material.set_shader_parameter("outline_thickness", thickness)
	get_parent().material.set_shader_parameter("outline_color", color)
	get_parent().material.set_shader_parameter("outline_glow_min", 0.75)

func clear_glow() -> void:
	get_parent().material.set_shader_parameter("outline_thickness", 0)
	get_parent().material.set_shader_parameter("outline_glow_min", 1.0)

func outline(color: Color) -> void:
	get_parent().material.set_shader_parameter("replace_with_color5", color)

func clear_outline() -> void:
	get_parent().material.set_shader_parameter("replace_with_color5", OUTLINE_COLOR)

func alpha(transparency: float, should_glow: bool = false, glow_min: float = 0.0, glow_speed: float = 1.0) -> void:
	get_parent().material.set_shader_parameter("transparency", transparency)
	get_parent().material.set_shader_parameter("transparency_glow", should_glow)
	get_parent().material.set_shader_parameter("transparency_glow_min", glow_min)
	get_parent().material.set_shader_parameter("transparency_glow_speed", glow_speed)

func clear_alpha() -> void:
	get_parent().material.set_shader_parameter("transparency", 1.0)
	get_parent().material.set_shader_parameter("transparency_glow", false)

func clear_all() -> void:
	clear_replace_color()
	clear_glow()
	clear_tint()
	clear_outline()
	clear_alpha()
