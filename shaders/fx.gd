class_name FX
extends AnimationPlayer

func _ready() -> void:
	assert(get_parent().material) # precondition - parent's material is shader.gdshader
	assert(get_parent().material is ShaderMaterial)

func flash(color: Color) -> void:
	get_parent().material.set_shader_parameter("flash_color", color)
	play("flash")

func slow_flash(color: Color) -> void:
	get_parent().material.set_shader_parameter("flash_color", color)
	play("slow_flash")

func tint(color: Color, strength: float) -> void:
	assert(strength >= 0.0 and strength <= 1.0)
	get_parent().material.set_shader_parameter("tint_color", color)
	get_parent().material.set_shader_parameter("tint_strength", strength)

func clear_tint() -> void:
	get_parent().material.set_shader_parameter("tint_strength", 0.0)

func glow(color: Color, thickness: int = 1, initial: bool = true) -> void:
	if initial: # start glow from outline_glow_min if true
		get_parent().material.set_shader_parameter("outline_start", Time.get_ticks_msec()/1000.0)
	get_parent().material.set_shader_parameter("outline_thickness", thickness)
	get_parent().material.set_shader_parameter("outline_color", color)
	get_parent().material.set_shader_parameter("outline_glow_min", 0.75)

func clear_glow() -> void:
	get_parent().material.set_shader_parameter("outline_thickness", 0)
	get_parent().material.set_shader_parameter("outline_glow_min", 1.0)

func outline(color: Color) -> void:
	get_parent().material.set_shader_parameter("replace_with_color5", color)

func clear_outline() -> void:
	get_parent().material.set_shader_parameter(get_parent().material.get_shader_parameter("replace_color5"))

func clear_all() -> void:
	clear_glow()
	clear_tint()
	clear_outline()
