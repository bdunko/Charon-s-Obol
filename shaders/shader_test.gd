extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	#$Peaceful.material.set_shader_parameter("replace_color1", Global.vec3(Color(93.0, 174.0, 140.0)))
	#$Peaceful.material.set_shader_parameter("replace_with_color1", Color(0, 0, 0))
	#$Peaceful.material.set_shader_parameter("tint_color", Global.vec3(Color(93, 174, 140)))
	#$Peaceful.material.set_shader_parameter("tint_strength", 0.5)
	
	#$Textbox.material.set_shader_parameter("tint_strength", 0.5)
	$Textbox.material.set_shader_parameter("replace_color1", Color(20, 16, 19))
	$Textbox.material.set_shader_parameter("replace_with_color1", Color(255, 0, 0))
	$Textbox.material.set_shader_parameter("replace_color2", Color(255, 255, 255))
	$Textbox.material.set_shader_parameter("replace_with_color2", Color(0, 255, 0))
	$Textbox.material.set_shader_parameter("replace_color3", Color(230, 255, 255))
	$Textbox.material.set_shader_parameter("replace_with_color3", Color(0, 0, 255))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	$CanvasLayer/ColorRect.material.set_shader_parameter("MOUSE", get_global_mouse_position())
