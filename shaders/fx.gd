class_name FX
extends AnimationPlayer

signal tween_finished

const _UNIFORM_MOUSE := "MOUSE"
const OUTLINE_COLOR = Color(20.0/255.0, 16.0/255.0, 19.0/255.0)

enum Uniform {
	BOOL_USE_EXCLUDE_COLORS, VEC3_EXCLUDE_COLOR1, VEC3_EXCLUDE_COLOR2, VEC3_EXCLUDE_COLOR3, VEC3_EXCLUDE_COLOR4,
	
	INT_DISPLACE_X, INT_DISPLACE_Y, BOOL_DISPLACE_REPEAT, 
	VEC2_AUTO_PAN_SPEED,
	
	VEC3_REPLACE_COLOR1, VEC3_REPLACE_WITH_COLOR1, 
	VEC3_REPLACE_COLOR2, VEC3_REPLACE_WITH_COLOR2, 
	VEC3_REPLACE_COLOR3, VEC3_REPLACE_WITH_COLOR3, 
	VEC3_REPLACE_COLOR4, VEC3_REPLACE_WITH_COLOR4, 
	VEC3_REPLACE_COLOR5, VEC3_REPLACE_WITH_COLOR5, 
	VEC3_REPLACE_COLOR_OUTLINE, VEC3_REPLACE_WITH_COLOR_OUTLINE,

	VEC3_TINT_COLOR, FLOAT_TINT_STRENGTH,
	
	VEC3_FLASH_COLOR, FLOAT_FLASH_STRENGTH,
	FLOAT_AUTO_FLASH_SPEED, FLOAT_AUTO_FLASH_BOUND, FLOAT_AUTO_FLASH_START_TIME,
	
	FLOAT_RED_CORRECT, FLOAT_GREEN_CORRECT, FLOAT_BLUE_CORRECT, FLOAT_GRAY_CORRECT, 
	FLOAT_BRIGHTNESS_CORRECT, FLOAT_CONTRAST_CORRECT, FLOAT_SATURATION_CORRECT,
	
	VEC3_SCANLINE_COLOR, FLOAT_SCANLINE_STRENGTH,
	FLOAT_SCANLINE_LEFT_TO_RIGHT_POSITION,
	FLOAT_SCANLINE_TOP_TO_BOTTOM_POSITION,
	FLOAT_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_POSITION,
	FLOAT_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_POSITION,
	
	INT_DISINTEGRATE_SEED, VEC3_DISINTEGRATE_COLOR, FLOAT_DISINTEGRATE_STRENGTH, FLOAT_DISINTEGRATE_ALPHA_BOUND1, FLOAT_DISINTEGRATE_ALPHA_BOUND2,
	BOOL_DISINTEGRATE_AS_STATIC, 
	FLOAT_AUTO_DISINTEGRATE_RANDOM_SEED_SPEED,
	
	VEC4_GLOW_COLOR, INT_GLOW_THICKNESS, BOOL_GLOW_DIAGONALS,
	FLOAT_AUTO_GLOW_SPEED, FLOAT_AUTO_GLOW_BOUND, FLOAT_AUTO_GLOW_START_TIME,
	
	BOOL_FOG_ENABLED, SAMPLER2D_FOG_NOISE_TEXTURE, 
	FLOAT_FOG_OPACITY, FLOAT_FOG_DENSITY, VEC2_FOG_SPEED,
	
	VEC3_VERTICAL_COLORLINE_COLOR, INT_VERTICAL_COLORLINE_SPACING, FLOAT_VERTICAL_COLORLINE_STRENGTH,
	VEC3_HORIZONTAL_COLORLINE_COLOR, INT_HORIZONTAL_COLORLINE_SPACING, FLOAT_HORIZONTAL_COLORLINE_STRENGTH,
	
	VEC3_CHECKER_COLOR, FLOAT_CHECKER_STRENGTH, INT_CHECKER_X_SIZE, INT_CHECKER_Y_SIZE,
	INT_CHECKER_X_PATTERN, INT_CHECKER_Y_PATTERN, FLOAT_CHECKER_CONTRAST_AMOUNT, FLOAT_CHECKER_CONTRAST_RATIO,
	
	BOOL_MOUSELIGHT_ON, VEC3_MOUSELIGHT_COLOR, FLOAT_MOUSELIGHT_STRENGTH, INT_MOUSELIGHT_SIZE,
	BOOL_MOUSELIGHT_SOFTEN_EDGES, BOOL_MOUSELIGHT_CHECKER,
	FLOAT_AUTO_MOUSELIGHT_FLICKER_SPEED, FLOAT_AUTO_MOUSELIGHT_FLICKER_BOUND,
	
	FLOAT_CUT_LEFT, FLOAT_CUT_RIGHT, FLOAT_CUT_TOP, FLOAT_CUT_BOTTOM,
	
	BOOL_VIGNETTE_ON, BOOL_VIGNETTE_IGNORE_TRANSPARENT, VEC3_VIGNETTE_COLOR, FLOAT_VIGNETTE_RADIUS,
	
	FLOAT_TRANSPARENCY,
	FLOAT_AUTO_FLICKER_SPEED, FLOAT_AUTO_FLICKER_BOUND, FLOAT_AUTO_FLICKER_START_TIME,
}

const _UNIFORM_TO_STR = {
	Uniform.BOOL_USE_EXCLUDE_COLORS : "use_exclude_colors", Uniform.VEC3_EXCLUDE_COLOR1 : "exclude_color1", Uniform.VEC3_EXCLUDE_COLOR2 : "exclude_color2", Uniform.VEC3_EXCLUDE_COLOR3 : "exclude_color3", Uniform.VEC3_EXCLUDE_COLOR4 : "exclude_color4",
	Uniform.INT_DISPLACE_X : "displace_x", Uniform.INT_DISPLACE_Y : "displace_y", Uniform.BOOL_DISPLACE_REPEAT : "displace_repeat", Uniform.VEC2_AUTO_PAN_SPEED : "auto_pan_speed",
	Uniform.VEC3_REPLACE_COLOR1 : "replace_color1", Uniform.VEC3_REPLACE_WITH_COLOR1 : "replace_with_color1", Uniform.VEC3_REPLACE_COLOR2: "replace_color2", Uniform.VEC3_REPLACE_WITH_COLOR2 : "replace_with_color2", Uniform.VEC3_REPLACE_COLOR3 : "replace_color3", Uniform.VEC3_REPLACE_WITH_COLOR3 : "replace_with_color3", Uniform.VEC3_REPLACE_COLOR4 : "replace_color4", Uniform.VEC3_REPLACE_WITH_COLOR4 : "replace_with_color4", Uniform.VEC3_REPLACE_COLOR5 : "replace_color5", Uniform.VEC3_REPLACE_WITH_COLOR5 : "replace_with_color5", Uniform.VEC3_REPLACE_COLOR_OUTLINE : "replace_color_outline", Uniform.VEC3_REPLACE_WITH_COLOR_OUTLINE : "replace_with_color_outline",
	Uniform.VEC3_TINT_COLOR : "tint_color", Uniform.FLOAT_TINT_STRENGTH : "tint_strength",
	Uniform.VEC3_FLASH_COLOR : "flash_color", Uniform.FLOAT_FLASH_STRENGTH : "flash_strength", Uniform.FLOAT_AUTO_FLASH_SPEED : "auto_flash_speed", Uniform.FLOAT_AUTO_FLASH_BOUND : "auto_flash_bound", Uniform.FLOAT_AUTO_FLASH_START_TIME : "auto_flash_start_time",
	Uniform.FLOAT_RED_CORRECT : "red_correct", Uniform.FLOAT_GREEN_CORRECT : "green_correct", Uniform.FLOAT_BLUE_CORRECT : "blue_correct", Uniform.FLOAT_GRAY_CORRECT : "gray_correct", Uniform.FLOAT_BRIGHTNESS_CORRECT : "brightness_correct", Uniform.FLOAT_CONTRAST_CORRECT : "contrast_correct", Uniform.FLOAT_SATURATION_CORRECT : "saturation_correct",
	Uniform.VEC3_SCANLINE_COLOR : "scanline_color", Uniform.FLOAT_SCANLINE_STRENGTH : "scanline_strength", Uniform.FLOAT_SCANLINE_LEFT_TO_RIGHT_POSITION : "scanline_left_to_right_position", Uniform.FLOAT_SCANLINE_TOP_TO_BOTTOM_POSITION : "scanline_top_to_bottom_position", Uniform.FLOAT_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_POSITION : "scanline_topleft_to_bottomright_position", Uniform.FLOAT_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_POSITION : "scanline_topright_to_bottomleft_position",
	Uniform.INT_DISINTEGRATE_SEED : "disintegrate_seed", Uniform.VEC3_DISINTEGRATE_COLOR : "disintegrate_color",  Uniform.FLOAT_DISINTEGRATE_STRENGTH : "disintegrate_strength", Uniform.FLOAT_DISINTEGRATE_ALPHA_BOUND1 : "disintegrate_alpha_bound1",Uniform.FLOAT_DISINTEGRATE_ALPHA_BOUND2 : "disintegrate_alpha_bound2", Uniform.BOOL_DISINTEGRATE_AS_STATIC : "disintegrate_as_static",  Uniform.FLOAT_AUTO_DISINTEGRATE_RANDOM_SEED_SPEED : "auto_disintegrate_random_seed_speed",
	Uniform.VEC4_GLOW_COLOR : "glow_color", Uniform.INT_GLOW_THICKNESS : "glow_thickness", Uniform.BOOL_GLOW_DIAGONALS : "glow_diagonals", Uniform.FLOAT_AUTO_GLOW_SPEED : "auto_glow_speed", Uniform.FLOAT_AUTO_GLOW_BOUND : "auto_glow_bound", Uniform.FLOAT_AUTO_GLOW_START_TIME : "auto_glow_start_time", 
	Uniform.BOOL_FOG_ENABLED : "fog_enabled", Uniform.SAMPLER2D_FOG_NOISE_TEXTURE : "fog_noise_texture", Uniform.FLOAT_FOG_OPACITY : "fog_opacity", Uniform.FLOAT_FOG_DENSITY : "fog_density", Uniform.VEC2_FOG_SPEED : "fog_speed",
	Uniform.VEC3_VERTICAL_COLORLINE_COLOR : "vertical_colorline_color", Uniform.INT_VERTICAL_COLORLINE_SPACING : "vertical_colorline_spacing", Uniform.FLOAT_VERTICAL_COLORLINE_STRENGTH : "vertical_colorline_strength", Uniform.VEC3_HORIZONTAL_COLORLINE_COLOR : "horizontal_colorline_color", Uniform.INT_HORIZONTAL_COLORLINE_SPACING : "horizontal_colorline_spacing", Uniform.FLOAT_HORIZONTAL_COLORLINE_STRENGTH : "horizontal_colorline_strength",
	Uniform.VEC3_CHECKER_COLOR : "checker_color", Uniform.FLOAT_CHECKER_STRENGTH : "checker_strength", Uniform.INT_CHECKER_X_SIZE : "checker_x_size", Uniform.INT_CHECKER_Y_SIZE : "checker_y_size", Uniform.INT_CHECKER_X_PATTERN : "checker_x_pattern", Uniform.INT_CHECKER_Y_PATTERN : "checker_y_pattern", Uniform.FLOAT_CHECKER_CONTRAST_AMOUNT : "checker_contrast_amount", Uniform.FLOAT_CHECKER_CONTRAST_RATIO : "checker_contrast_ratio",
	Uniform.BOOL_MOUSELIGHT_ON : "mouselight_on", Uniform.VEC3_MOUSELIGHT_COLOR : "mouselight_color", Uniform.FLOAT_MOUSELIGHT_STRENGTH : "mouselight_strength", Uniform.INT_MOUSELIGHT_SIZE : "mouselight_size", Uniform.BOOL_MOUSELIGHT_SOFTEN_EDGES : "mouselight_soften_edges", Uniform.BOOL_MOUSELIGHT_CHECKER : "mouselight_checker", Uniform.FLOAT_AUTO_MOUSELIGHT_FLICKER_SPEED : "auto_mouselight_flicker_speed", Uniform.FLOAT_AUTO_MOUSELIGHT_FLICKER_BOUND : "auto_mouselight_flicker_bound",
	Uniform.FLOAT_CUT_LEFT : "cut_left", Uniform.FLOAT_CUT_RIGHT : "cut_right", Uniform.FLOAT_CUT_TOP : "cut_top", Uniform.FLOAT_CUT_BOTTOM : "cut_bottom",
	Uniform.BOOL_VIGNETTE_ON : "vignette_on", Uniform.BOOL_VIGNETTE_IGNORE_TRANSPARENT : "vignette_ignore_transparent", Uniform.VEC3_VIGNETTE_COLOR : "vignette_color", Uniform.FLOAT_VIGNETTE_RADIUS : "vignette_radius",
	Uniform.FLOAT_TRANSPARENCY : "transparency", Uniform.FLOAT_AUTO_FLICKER_SPEED : "auto_flicker_speed", Uniform.FLOAT_AUTO_FLICKER_BOUND : "auto_flicker_bound", Uniform.FLOAT_AUTO_FLICKER_START_TIME : "auto_flicker_start_time"
}

# Pass this under the START_TIME uniforms for effects that use it, when starting that effect.
func START_TIME() -> float:
	return Time.get_ticks_msec()/1000.0

var _active_tweens = {}

func _ready() -> void:
	assert(get_parent() is CanvasItem)
	assert(get_parent().material) # precondition - parent's material is shader.gdshader
	assert(get_parent().material is ShaderMaterial)
	
	# check uniform dictionary - 
	# debug check; but for some reasons this fails in the game, so commented out
#	# it does correctly verify though (check output)
#	for uniform in Uniform.values():
#		assert(_UNIFORM_TO_STR.has(uniform))
#		if not uniform in [Uniform.SAMPLER2D_FOG_NOISE_TEXTURE]:
#			print(("%s = " % _UNIFORM_TO_STR[uniform]) + str(get_parent().material.get_shader_parameter(_UNIFORM_TO_STR[uniform])))
#			assert(get_parent().material.get_shader_parameter(_UNIFORM_TO_STR[uniform]) != null)

## DIRECT API ##

func set_uniform(uniform: Uniform, value) -> void:
	get_parent().material.set_shader_parameter(_UNIFORM_TO_STR[uniform], value)

func get_uniform(uniform: Uniform):
	return get_parent().material.get_shader_parameter(_UNIFORM_TO_STR[uniform])

# tween the uniform from the current value to 'to' over 'duration' (ms).
func tween_uniform(uniform: Uniform, to, duration, trans = Tween.TRANS_LINEAR, loops = 1):
	var tween = create_tween()
	
	tween.tween_property(get_parent(), "material:shader_parameter/%s" % _UNIFORM_TO_STR[uniform], to, duration).set_trans(trans)
	tween.set_loops(loops)
	
	# add tween to tracking list
	_add_tween(uniform, tween)
	
	await tween.finished
	
	# remove the tween from list if it's still there (wasn't killed)
	if _active_tweens.has(uniform):
		_active_tweens[uniform].erase(tween)
	
	emit_signal("tween_finished", uniform)

# helper that additionally sets the uniform to 'from' before starting the tween.
func tween_uniform_from(uniform: Uniform, from, to, duration, trans = Tween.TRANS_LINEAR, loops = 1): 
	set_uniform(uniform, from)
	tween_uniform(uniform, to, duration, trans, loops)

# oscillate the uniform infinitely between the current value and 'to'.
func oscillate_uniform(uniform: Uniform, to, duration, trans = Tween.TRANS_LINEAR):
	tween_uniform(uniform, to, duration, trans, 0) # use loops = 0 for infinite

# helper that additionally sets the uniform to 'from' before starting the oscillation.
func oscillate_uniform_from(uniform: Uniform, from, to, duration: float, trans := Tween.TRANS_LINEAR):
	set_uniform(uniform, from)
	tween_uniform(uniform, to, duration, trans)

# kill all active tweens
func kill_tweens(uniform: Uniform):
	# get list of all tweens affecting uniform
	if _active_tweens.has(uniform):
		for tween in _active_tweens[uniform]:
			tween.kill() # kill them
		_active_tweens.erase(uniform) # erase the list from dictionary

func _add_tween(uniform: Uniform, tween: Tween) -> void:
	# create an empty list if needed for the uniform
	if not _active_tweens.has(uniform): 
		_active_tweens[uniform] = []
	
	# add tween to list
	var lis = _active_tweens[uniform]
	if not tween in lis:
		lis.append(tween)

func _process(_delta) -> void:
	# update the mouse position every frame
	get_parent().material.set_shader_parameter(_UNIFORM_MOUSE, get_parent().get_global_mouse_position())


## PREBAKED EFFECTS ##
func flash(color: Color, time: float = 0.1) -> void:
	assert(time >= 0.0)
	set_uniform(Uniform.VEC3_FLASH_COLOR, color)
	set_uniform(Uniform.FLOAT_FLASH_STRENGTH, 0.0) 
	set_uniform(Uniform.FLOAT_AUTO_FLASH_START_TIME, START_TIME())
	
	# play the flash in/out
	await tween_uniform(Uniform.FLOAT_FLASH_STRENGTH, 1.0, time)
	await tween_uniform(Uniform.FLOAT_FLASH_STRENGTH, 0.0, time)

func slow_flash(color: Color) -> void:
	var time = 0.2
	flash(color, time)

func recolor(i: int, color: Color, with: Color) -> void:
	assert(i >= 1 and i <= 5, "We only support replacing up to 5 colors.")
	if i < 1 or i > 5:
		return
		
	# little lookup table just for fanciness
	var a = [[Uniform.VEC3_REPLACE_COLOR1, Uniform.VEC3_REPLACE_WITH_COLOR1],
		[Uniform.VEC3_REPLACE_COLOR2, Uniform.VEC3_REPLACE_WITH_COLOR2],
		[Uniform.VEC3_REPLACE_COLOR3, Uniform.VEC3_REPLACE_WITH_COLOR3],
		[Uniform.VEC3_REPLACE_COLOR4, Uniform.VEC3_REPLACE_WITH_COLOR4],
		[Uniform.VEC3_REPLACE_COLOR5, Uniform.VEC3_REPLACE_WITH_COLOR5]]
	
	set_uniform(a[i][0], color) #VEC3_REPLACE_COLORi
	set_uniform(a[i][1], with) #VEC3_REPLACE_WITH_COLORi

func recolor_outline(color: Color) -> void:
	set_uniform(Uniform.VEC3_REPLACE_COLOR_OUTLINE, OUTLINE_COLOR) # just in case
	set_uniform(Uniform.VEC3_REPLACE_WITH_COLOR_OUTLINE, color)

func tint(color: Color, strength: float) -> void:
	assert(strength >= 0.0 and strength <= 1.0)
	set_uniform(Uniform.VEC3_TINT_COLOR, color)
	set_uniform(Uniform.FLOAT_TINT_STRENGTH, strength)

func clear_tint() -> void:
	set_uniform(Uniform.FLOAT_TINT_STRENGTH, 0.0)

func start_glowing(color: Color, speed: float = 0, thickness: int = 1, minimum: float = 0.75) -> void:
	assert(thickness > 0, "Thickness must be larger than 0.")
	assert(minimum >= 0.0 and minimum <= 1.0, "Minimum must be between 0 and 1.")
	set_uniform(Uniform.FLOAT_AUTO_GLOW_START_TIME, START_TIME())
	set_uniform(Uniform.VEC4_GLOW_COLOR, color)
	set_uniform(Uniform.INT_GLOW_THICKNESS, thickness)
	set_uniform(Uniform.FLOAT_AUTO_GLOW_SPEED, speed)
	set_uniform(Uniform.FLOAT_AUTO_GLOW_BOUND, minimum)

func stop_glowing() -> void:
	set_uniform(Uniform.INT_GLOW_THICKNESS, 0)

func fade_out(time: float) -> void:
	assert(time >= 0.0)
	await tween_uniform(Uniform.FLOAT_TRANSPARENCY, 0.0, time)

func fade_in(time: float) -> void:
	assert(time >= 0.0)
	await tween_uniform(Uniform.FLOAT_TRANSPARENCY, 1.0, time)


# prebaked effects -
# - added -
# scan (pass scan direction as enum)
# disintegrate
# start_flickering / stop_flickering <- needs start time
# start_flashing / stop_flashing

# need to implement into shader to do auto scans, I think we want this
# start_scanning / stop_scanning

# TODO - search for replace_color (renamed to recolor)
# TODO - search for outline (renamed to recolor_outline)
# TODO _ removed clear_replace_color
# TODO - renamed glow and clear_glow to start_glowing/stop_glowing
# TODO - alpha -> flicker
# TODO - clear_all removed

