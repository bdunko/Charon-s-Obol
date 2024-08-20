class_name FX
extends AnimationPlayer

func _ready() -> void:
	# precondition - parent's material is shader.gdshader
	assert(get_parent().material)
	assert(get_parent().material is ShaderMaterial)

func flash(color: Color) -> void:
	get_parent().material.set_shader_parameter("flash_color", color)
	play("flash")

func tint(color: Color, strength: float) -> void:
	assert(strength >= 0.0 and strength <= 1.0)
	get_parent().material.set_shader_parameter("tint_color", color)
	get_parent().material.set_shader_parameter("tint_strength", strength)

func clear_tint() -> void:
	get_parent().material.set_shader_parameter("tint_strength", 0.0)

func glow(color: Color) -> void:
	get_parent().material.set_shader_parameter("outline_thickness", 1)
	get_parent().material.set_shader_parameter("outline_color", color)
	get_parent().material.set_shader_parameter("outline_glow_min", 0.65)
	
func clear_glow() -> void:
	get_parent().material.set_shader_parameter("outline_thickness", 0)
	get_parent().material.set_shader_parameter("outline_glow_min", 1.0)

func outline(color: Color) -> void:
	get_parent().material.set_shader_parameter("replace_with_color5", color)

func clear_outline() -> void:
	get_parent().material.set_shader_parameter(get_parent().material.get_shader_parameter("replace_color5"))
