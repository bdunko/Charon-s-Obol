class_name FX
extends AnimationPlayer

signal tween_finished

const _UNIFORM_MOUSE := "MOUSE"

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
	VEC3_AUTO_FLASH_COLOR, FLOAT_AUTO_FLASH_SPEED, FLOAT_AUTO_FLASH_BOUND1, FLOAT_AUTO_FLASH_BOUND2, FLOAT_AUTO_FLASH_START_TIME,
	
	FLOAT_RED_CORRECT, FLOAT_GREEN_CORRECT, FLOAT_BLUE_CORRECT, FLOAT_GRAY_CORRECT, 
	FLOAT_BRIGHTNESS_CORRECT, FLOAT_CONTRAST_CORRECT, FLOAT_SATURATION_CORRECT,
	
	VEC3_SCANLINE_COLOR, FLOAT_SCANLINE_STRENGTH,
	FLOAT_SCANLINE_LEFT_TO_RIGHT_POSITION, 
	BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_ON, BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_REVERSE,
	FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_START_TIME, FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_SCAN_DURATION, FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_DELAY,
	FLOAT_SCANLINE_TOP_TO_BOTTOM_POSITION,
	BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_ON, BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_REVERSE,
	FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_START_TIME, FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_SCAN_DURATION, FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_DELAY,
	FLOAT_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_POSITION,
	BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_ON, BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_REVERSE,
	FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_START_TIME, FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_SCAN_DURATION, FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_DELAY,
	FLOAT_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_POSITION,
	BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_ON, BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_REVERSE,
	FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_START_TIME, FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_SCAN_DURATION, FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_DELAY,
	
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
	Uniform.BOOL_USE_EXCLUDE_COLORS : "use_exclude_colors", 
	Uniform.VEC3_EXCLUDE_COLOR1 : "exclude_color1", 
	Uniform.VEC3_EXCLUDE_COLOR2 : "exclude_color2", 
	Uniform.VEC3_EXCLUDE_COLOR3 : "exclude_color3", 
	Uniform.VEC3_EXCLUDE_COLOR4 : "exclude_color4",
	
	Uniform.INT_DISPLACE_X : "displace_x", 
	Uniform.INT_DISPLACE_Y : "displace_y", 
	Uniform.BOOL_DISPLACE_REPEAT : "displace_repeat", 
	Uniform.VEC2_AUTO_PAN_SPEED : "auto_pan_speed",
	
	Uniform.VEC3_REPLACE_COLOR1 : "replace_color1", 
	Uniform.VEC3_REPLACE_WITH_COLOR1 : "replace_with_color1", 
	Uniform.VEC3_REPLACE_COLOR2: "replace_color2", 
	Uniform.VEC3_REPLACE_WITH_COLOR2 : "replace_with_color2", 
	Uniform.VEC3_REPLACE_COLOR3 : "replace_color3", 
	Uniform.VEC3_REPLACE_WITH_COLOR3 : "replace_with_color3", 
	Uniform.VEC3_REPLACE_COLOR4 : "replace_color4", 
	Uniform.VEC3_REPLACE_WITH_COLOR4 : "replace_with_color4", 
	Uniform.VEC3_REPLACE_COLOR5 : "replace_color5", 
	Uniform.VEC3_REPLACE_WITH_COLOR5 : "replace_with_color5", 
	Uniform.VEC3_REPLACE_COLOR_OUTLINE : "replace_color_outline", 
	Uniform.VEC3_REPLACE_WITH_COLOR_OUTLINE : "replace_with_color_outline",
	
	Uniform.VEC3_TINT_COLOR : "tint_color", 
	Uniform.FLOAT_TINT_STRENGTH : "tint_strength",
	
	Uniform.VEC3_FLASH_COLOR : "flash_color", 
	Uniform.FLOAT_FLASH_STRENGTH : "flash_strength", 
	Uniform.VEC3_AUTO_FLASH_COLOR : "auto_flash_color", 
	Uniform.FLOAT_AUTO_FLASH_SPEED : "auto_flash_speed", 
	Uniform.FLOAT_AUTO_FLASH_BOUND1 : "auto_flash_bound1", 
	Uniform.FLOAT_AUTO_FLASH_BOUND2 : "auto_flash_bound2", 
	Uniform.FLOAT_AUTO_FLASH_START_TIME : "auto_flash_start_time",
	
	Uniform.FLOAT_RED_CORRECT : "red_correct", 
	Uniform.FLOAT_GREEN_CORRECT : "green_correct", 
	Uniform.FLOAT_BLUE_CORRECT : "blue_correct", 
	Uniform.FLOAT_GRAY_CORRECT : "gray_correct", 
	Uniform.FLOAT_BRIGHTNESS_CORRECT : "brightness_correct", 
	Uniform.FLOAT_CONTRAST_CORRECT : "contrast_correct", 
	Uniform.FLOAT_SATURATION_CORRECT : "saturation_correct",
	
	Uniform.VEC3_SCANLINE_COLOR : "scanline_color", 
	Uniform.FLOAT_SCANLINE_STRENGTH : "scanline_strength", 
	Uniform.FLOAT_SCANLINE_LEFT_TO_RIGHT_POSITION : "scanline_left_to_right_position", 
	Uniform.FLOAT_SCANLINE_TOP_TO_BOTTOM_POSITION : "scanline_top_to_bottom_position", 
	Uniform.FLOAT_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_POSITION : "scanline_topleft_to_bottomright_position", 
	Uniform.FLOAT_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_POSITION : "scanline_topright_to_bottomleft_position",
	Uniform.BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_ON : "auto_scanline_left_to_right_on", 
	Uniform.BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_REVERSE : "auto_scanline_left_to_right_reverse", 
	Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_START_TIME : "auto_scanline_left_to_right_start_time", 
	Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_SCAN_DURATION : "auto_scanline_left_to_right_scan_duration", 
	Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_DELAY : "auto_scanline_left_to_right_delay",
	Uniform.BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_ON : "auto_scanline_top_to_bottom_on", 
	Uniform.BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_REVERSE : "auto_scanline_top_to_bottom_reverse", 
	Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_START_TIME : "auto_scanline_top_to_bottom_start_time",
	Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_SCAN_DURATION : "auto_scanline_top_to_bottom_scan_duration", 
	Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_DELAY : "auto_scanline_top_to_bottom_delay",
	Uniform.BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_ON : "auto_scanline_topleft_to_bottomright_on", 
	Uniform.BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_REVERSE : "auto_scanline_topleft_to_bottomright_reverse", Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_START_TIME : "auto_scanline_topleft_to_bottomright_start_time", Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_SCAN_DURATION : "auto_scanline_topleft_to_bottomright_scan_duration", Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_DELAY : "auto_scanline_topleft_to_bottomright_delay",
	Uniform.BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_ON : "auto_scanline_topright_to_bottomleft_on", 
	Uniform.BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_REVERSE : "auto_scanline_topright_to_bottomleft_reverse", 
	Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_START_TIME : "auto_scanline_topright_to_bottomleft_start_time", 
	Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_SCAN_DURATION : "auto_scanline_topright_to_bottomleft_scan_duration", 
	Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_DELAY : "auto_scanline_topright_to_bottomleft_delay",
	
	Uniform.INT_DISINTEGRATE_SEED : "disintegrate_seed", 
	Uniform.VEC3_DISINTEGRATE_COLOR : "disintegrate_color",  
	Uniform.FLOAT_DISINTEGRATE_STRENGTH : "disintegrate_strength", 
	Uniform.FLOAT_DISINTEGRATE_ALPHA_BOUND1 : "disintegrate_alpha_bound1",
	Uniform.FLOAT_DISINTEGRATE_ALPHA_BOUND2 : "disintegrate_alpha_bound2", 
	Uniform.BOOL_DISINTEGRATE_AS_STATIC : "disintegrate_as_static",  
	Uniform.FLOAT_AUTO_DISINTEGRATE_RANDOM_SEED_SPEED : "auto_disintegrate_random_seed_speed",
	
	Uniform.VEC4_GLOW_COLOR : "glow_color", 
	Uniform.INT_GLOW_THICKNESS : "glow_thickness", 
	Uniform.BOOL_GLOW_DIAGONALS : "glow_diagonals", 
	Uniform.FLOAT_AUTO_GLOW_SPEED : "auto_glow_speed", 
	Uniform.FLOAT_AUTO_GLOW_BOUND : "auto_glow_bound", 
	Uniform.FLOAT_AUTO_GLOW_START_TIME : "auto_glow_start_time", 
	
	Uniform.BOOL_FOG_ENABLED : "fog_enabled", 
	Uniform.SAMPLER2D_FOG_NOISE_TEXTURE : "fog_noise_texture", 
	Uniform.FLOAT_FOG_OPACITY : "fog_opacity", 
	Uniform.FLOAT_FOG_DENSITY : "fog_density", 
	Uniform.VEC2_FOG_SPEED : "fog_speed",
	
	Uniform.VEC3_VERTICAL_COLORLINE_COLOR : "vertical_colorline_color", 
	Uniform.INT_VERTICAL_COLORLINE_SPACING : "vertical_colorline_spacing", 
	Uniform.FLOAT_VERTICAL_COLORLINE_STRENGTH : "vertical_colorline_strength",
	Uniform.VEC3_HORIZONTAL_COLORLINE_COLOR : "horizontal_colorline_color", 
	Uniform.INT_HORIZONTAL_COLORLINE_SPACING : "horizontal_colorline_spacing", 
	Uniform.FLOAT_HORIZONTAL_COLORLINE_STRENGTH : "horizontal_colorline_strength",
	
	Uniform.VEC3_CHECKER_COLOR : "checker_color", 
	Uniform.FLOAT_CHECKER_STRENGTH : "checker_strength", 
	Uniform.INT_CHECKER_X_SIZE : "checker_x_size", 
	Uniform.INT_CHECKER_Y_SIZE : "checker_y_size", 
	Uniform.INT_CHECKER_X_PATTERN : "checker_x_pattern", 
	Uniform.INT_CHECKER_Y_PATTERN : "checker_y_pattern", 
	Uniform.FLOAT_CHECKER_CONTRAST_AMOUNT : "checker_contrast_amount", 
	Uniform.FLOAT_CHECKER_CONTRAST_RATIO : "checker_contrast_ratio",
	
	Uniform.BOOL_MOUSELIGHT_ON : "mouselight_on", 
	Uniform.VEC3_MOUSELIGHT_COLOR : "mouselight_color", 
	Uniform.FLOAT_MOUSELIGHT_STRENGTH : "mouselight_strength", 
	Uniform.INT_MOUSELIGHT_SIZE : "mouselight_size", 
	Uniform.BOOL_MOUSELIGHT_SOFTEN_EDGES : "mouselight_soften_edges", 
	Uniform.BOOL_MOUSELIGHT_CHECKER : "mouselight_checker", 
	Uniform.FLOAT_AUTO_MOUSELIGHT_FLICKER_SPEED : "auto_mouselight_flicker_speed", 
	Uniform.FLOAT_AUTO_MOUSELIGHT_FLICKER_BOUND : "auto_mouselight_flicker_bound",
	
	Uniform.FLOAT_CUT_LEFT : "cut_left", 
	Uniform.FLOAT_CUT_RIGHT : "cut_right", 
	Uniform.FLOAT_CUT_TOP : "cut_top", 
	Uniform.FLOAT_CUT_BOTTOM : "cut_bottom",
	
	Uniform.BOOL_VIGNETTE_ON : "vignette_on", 
	Uniform.BOOL_VIGNETTE_IGNORE_TRANSPARENT : "vignette_ignore_transparent", 
	Uniform.VEC3_VIGNETTE_COLOR : "vignette_color", 
	Uniform.FLOAT_VIGNETTE_RADIUS : "vignette_radius",
	
	Uniform.FLOAT_TRANSPARENCY : "transparency", 
	Uniform.FLOAT_AUTO_FLICKER_SPEED : "auto_flicker_speed", 
	Uniform.FLOAT_AUTO_FLICKER_BOUND : "auto_flicker_bound", 
	Uniform.FLOAT_AUTO_FLICKER_START_TIME : "auto_flicker_start_time"
}

# Pass this under the START_TIME uniforms for effects that use it, when starting that effect.
func START_TIME() -> float:
	return Time.get_ticks_msec()/1000.0

var _active_tweens = {}
var _outline_color = Color(20.0/255.0, 16.0/255.0, 19.0/255.0)

func _ready() -> void:
	assert(get_parent() is CanvasItem)
	assert(get_parent().material) # precondition - parent's material is shader.gdshader
	assert(get_parent().material is ShaderMaterial)
	
	# debug check for uniform dictionary - 
	# however note that assertions here can fail if new uniforms are added, causing scenes using this shader to need a refresh.
	# in the case of unexpected assertion failure, open the scene containing the printed path and resave it.
#	for uniform in Uniform.values():
#		assert(_UNIFORM_TO_STR.has(uniform))
#		if not uniform in [Uniform.SAMPLER2D_FOG_NOISE_TEXTURE]:
#			if get_parent().material.get_shader_parameter(_UNIFORM_TO_STR[uniform]) == null:
#				print(self.get_path())
#				print(("%s = " % _UNIFORM_TO_STR[uniform]) + str(get_parent().material.get_shader_parameter(_UNIFORM_TO_STR[uniform])))
#				assert(get_parent().material.get_shader_parameter(_UNIFORM_TO_STR[uniform]) != null)

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


## PREBAKED SHADER EFFECTS ##
enum ScanDirection {
	LEFT_TO_RIGHT, RIGHT_TO_LEFT,
	BOTTOM_TO_TOP, TOP_TO_BOTTOM,
	DIAGONAL_TOPLEFT_TO_BOTTOMRIGHT, DIAGONAL_BOTTOMRIGHT_TO_TOPLEFT,
	DIAGONAL_TOPRIGHT_TO_BOTTOMLEFT, DIAGONAL_BOTTOMLEFT_TO_TOPRIGHT
}

func disable_exclude_colors() -> void:
	set_uniform(Uniform.BOOL_USE_EXCLUDE_COLORS, false)

func enable_exclude_colors() -> void:
	set_uniform(Uniform.BOOL_USE_EXCLUDE_COLORS, true)

func flash(color: Color, time: float = 0.1) -> void:
	assert(time >= 0.0, "Time must be non-negative.")
	
	set_uniform(Uniform.VEC3_FLASH_COLOR, color)
	set_uniform(Uniform.FLOAT_FLASH_STRENGTH, 0.0) 
	
	# play the flash in/out
	await tween_uniform(Uniform.FLOAT_FLASH_STRENGTH, 1.0, time)
	await tween_uniform(Uniform.FLOAT_FLASH_STRENGTH, 0.0, time)

func slow_flash(color: Color) -> void:
	var time = 0.2
	flash(color, time)

func recolor(i: int, color: Color, with: Color) -> void:
	assert(i >= 1 and i <= 5, "We only support replacing up to 5 colors.")
		
	var recolor_lookup = [[Uniform.VEC3_REPLACE_COLOR1, Uniform.VEC3_REPLACE_WITH_COLOR1],
		[Uniform.VEC3_REPLACE_COLOR2, Uniform.VEC3_REPLACE_WITH_COLOR2],
		[Uniform.VEC3_REPLACE_COLOR3, Uniform.VEC3_REPLACE_WITH_COLOR3],
		[Uniform.VEC3_REPLACE_COLOR4, Uniform.VEC3_REPLACE_WITH_COLOR4],
		[Uniform.VEC3_REPLACE_COLOR5, Uniform.VEC3_REPLACE_WITH_COLOR5]]
	
	set_uniform(recolor_lookup[i][0], color) #VEC3_REPLACE_COLORi
	set_uniform(recolor_lookup[i][1], with) #VEC3_REPLACE_WITH_COLORi

func recolor_outline(color: Color, base_outline_color = _outline_color) -> void:
	_outline_color = base_outline_color # allows a new outline color to be provided if default does not suffice
	set_uniform(Uniform.VEC3_REPLACE_COLOR_OUTLINE, _outline_color) 
	set_uniform(Uniform.VEC3_REPLACE_WITH_COLOR_OUTLINE, color)

func recolor_outline_to_default() -> void:
	set_uniform(Uniform.VEC3_REPLACE_WITH_COLOR_OUTLINE, _outline_color)

func tint(color: Color, strength: float) -> void:
	assert(strength >= 0.0 and strength <= 1.0)
	
	set_uniform(Uniform.VEC3_TINT_COLOR, color)
	set_uniform(Uniform.FLOAT_TINT_STRENGTH, strength)

func clear_tint() -> void:
	set_uniform(Uniform.FLOAT_TINT_STRENGTH, 0.0)

static var DEFAULT_GLOW_SPEED := 2.0
static var DEFAULT_GLOW_THICKNESS := 1
static var DEFAULT_GLOW_MINIMUM := 0.8
static var DEFAULT_GLOW_RESTART := true
# FX.DEFAULT_GLOW_SPEED, FX.DEFAULT_GLOW_THICKNESS, FX.DEFAULT_GLOW_MINIMUM
func start_glowing(color: Color, speed: float = DEFAULT_GLOW_SPEED, thickness: int = DEFAULT_GLOW_THICKNESS, minimum: float = DEFAULT_GLOW_MINIMUM, restart: bool = DEFAULT_GLOW_RESTART) -> void:
	assert(thickness > 0, "Thickness must be larger than 0.")
	assert(minimum >= 0.0 and minimum <= 1.0, "Minimum must be between 0 and 1.")
	
	if restart:
		set_uniform(Uniform.FLOAT_AUTO_GLOW_START_TIME, START_TIME())
	set_uniform(Uniform.VEC4_GLOW_COLOR, color)
	set_uniform(Uniform.INT_GLOW_THICKNESS, thickness)
	set_uniform(Uniform.FLOAT_AUTO_GLOW_SPEED, speed)
	set_uniform(Uniform.FLOAT_AUTO_GLOW_BOUND, minimum)

func start_glowing_solid(color: Color, speed: float = DEFAULT_GLOW_SPEED, thickness: int = DEFAULT_GLOW_THICKNESS, restart: bool = true) -> void:
	start_glowing(color, speed, thickness, 1.0, restart)

func stop_glowing() -> void:
	set_uniform(Uniform.INT_GLOW_THICKNESS, 0)

func fade_out(time: float = 1.0) -> void:
	assert(time >= 0.0)
	await tween_uniform(Uniform.FLOAT_TRANSPARENCY, 0.0, time)

func fade_in(time: float = 1.0) -> void:
	assert(time >= 0.0)
	await tween_uniform(Uniform.FLOAT_TRANSPARENCY, 1.0, time)

const _SCAN_LOOKUP = {
	# direction: [uniform, start, end, [auto_on, auto_reverse, auto_start_time, auto_duration, auto_delay], auto_reverse]
	ScanDirection.LEFT_TO_RIGHT : [Uniform.FLOAT_SCANLINE_LEFT_TO_RIGHT_POSITION, 0.0, 1.0, [Uniform.BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_ON, Uniform.BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_DELAY], false],
	ScanDirection.RIGHT_TO_LEFT : [Uniform.FLOAT_SCANLINE_LEFT_TO_RIGHT_POSITION, 1.0, 0.0, [Uniform.BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_ON, Uniform.BOOL_AUTO_SCANLINE_LEFT_TO_RIGHT_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_LEFT_TO_RIGHT_DELAY], true],
	ScanDirection.TOP_TO_BOTTOM : [Uniform.FLOAT_SCANLINE_TOP_TO_BOTTOM_POSITION, 0.0, 1.0, [Uniform.BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_ON, Uniform.BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_DELAY], false],
	ScanDirection.BOTTOM_TO_TOP : [Uniform.FLOAT_SCANLINE_TOP_TO_BOTTOM_POSITION, 1.0, 0.0, [Uniform.BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_ON, Uniform.BOOL_AUTO_SCANLINE_TOP_TO_BOTTOM_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_TOP_TO_BOTTOM_DELAY], true],
	ScanDirection.DIAGONAL_TOPLEFT_TO_BOTTOMRIGHT : [Uniform.FLOAT_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_POSITION, 0.0, 1.0, [Uniform.BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_ON, Uniform.BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_DELAY], false],
	ScanDirection.DIAGONAL_BOTTOMRIGHT_TO_TOPLEFT : [Uniform.FLOAT_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_POSITION, 1.0, 0.0, [Uniform.BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_ON, Uniform.BOOL_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_TOPLEFT_TO_BOTTOMRIGHT_DELAY], true],
	ScanDirection.DIAGONAL_TOPRIGHT_TO_BOTTOMLEFT : [Uniform.FLOAT_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_POSITION, 0.0, 1.0, [Uniform.BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_ON, Uniform.BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_DELAY], false],
	ScanDirection.DIAGONAL_BOTTOMLEFT_TO_TOPRIGHT : [Uniform.FLOAT_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_POSITION, 1.0, 0.0, [Uniform.BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_ON, Uniform.BOOL_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_REVERSE, Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_START_TIME, Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_SCAN_DURATION, Uniform.FLOAT_AUTO_SCANLINE_TOPRIGHT_TO_BOTTOMLEFT_DELAY], true],
}

func scan(direction: ScanDirection, color: Color, strength: float = 1.0, time: float = 1.0) -> void:
	assert(strength >= 0 and strength <= 1, "Strength must be between 0 and 1.")
	assert(time >= 0.0, "Time must be non-negative.")
	
	var uniform: Uniform = _SCAN_LOOKUP[direction][0]
	var start: float = _SCAN_LOOKUP[direction][1]
	var end: float = _SCAN_LOOKUP[direction][2]
	
	set_uniform(Uniform.VEC3_SCANLINE_COLOR, color)
	set_uniform(Uniform.FLOAT_SCANLINE_STRENGTH, strength)
	set_uniform(uniform, start)
	
	await tween_uniform(uniform, end, time)

func disintegrate(time: float) -> void:
	assert(time >= 0.0, "Time must be non-negative.")
	
	set_uniform(Uniform.FLOAT_DISINTEGRATE_ALPHA_BOUND1, 0.0)
	set_uniform(Uniform.FLOAT_DISINTEGRATE_ALPHA_BOUND1, 0.0)
	set_uniform(Uniform.FLOAT_DISINTEGRATE_STRENGTH, 0.0)
	
	await tween_uniform(Uniform.FLOAT_DISINTEGRATE_STRENGTH, 1.0, time)

func start_flickering(speed: float, alpha_bound1: float = 0.0, alpha_bound2: float = 1.0, restart: bool = true) -> void:
	assert(speed >= 0, "Speed must be non-negative.")
	assert(alpha_bound1 >= 0 and alpha_bound1 <= 1, "Bounds must be between 0 and 1.")
	assert(alpha_bound2 >= 0 and alpha_bound2 <= 1, "Bounds must be between 0 and 1.")
	
	set_uniform(Uniform.FLOAT_TRANSPARENCY, alpha_bound1)
	set_uniform(Uniform.FLOAT_AUTO_FLICKER_BOUND, alpha_bound2)
	set_uniform(Uniform.FLOAT_AUTO_FLICKER_SPEED, speed)
	if restart:
		set_uniform(Uniform.FLOAT_AUTO_FLICKER_START_TIME, START_TIME())

func stop_flickering(ending_alpha: float = 1.0) -> void:
	assert(ending_alpha >= 0 and ending_alpha <= 1, "Alpha must be between 0 and 1.")
	
	set_uniform(Uniform.FLOAT_AUTO_FLICKER_SPEED, 0.0)
	set_uniform(Uniform.FLOAT_TRANSPARENCY, ending_alpha)

static var DEFAULT_FLASH_SPEED = 10
static var DEFAULT_FLASH_BOUND1 = 0.4
static var DEFAULT_FLASH_BOUND2 = 0.7
func start_flashing(color: Color, speed: float = DEFAULT_FLASH_SPEED, strength_bound1: float = DEFAULT_FLASH_BOUND1, strength_bound2: float = DEFAULT_FLASH_BOUND2, restart: bool = true) -> void:
	assert(speed >= 0, "Speed must be non-negative.")
	assert(strength_bound1 >= 0 and strength_bound1 <= 1, "Bounds must be between 0 and 1.")
	assert(strength_bound2 >= 0 and strength_bound2 <= 1, "Bounds must be between 0 and 1.")
	
	set_uniform(Uniform.VEC3_AUTO_FLASH_COLOR, color)
	set_uniform(Uniform.FLOAT_AUTO_FLASH_BOUND1, strength_bound1)
	set_uniform(Uniform.FLOAT_AUTO_FLASH_BOUND2, strength_bound2)
	set_uniform(Uniform.FLOAT_AUTO_FLASH_SPEED, speed)
	if restart:
		set_uniform(Uniform.FLOAT_AUTO_FLASH_START_TIME, START_TIME())

func stop_flashing() -> void:
	set_uniform(Uniform.FLOAT_AUTO_FLASH_SPEED, 0.0)

static var DEFAULT_SCAN_STRENGTH = 1.0
static var DEFAULT_SCAN_DURATION = 1.0
static var DEFAULT_SCAN_DELAY = 2.0
func start_scanning(direction: ScanDirection, color: Color, strength: float = DEFAULT_SCAN_STRENGTH, scan_duration: float = DEFAULT_SCAN_DURATION, delay: float = DEFAULT_SCAN_DELAY, restart: bool = true) -> void:
	assert(scan_duration >= 0, "Scan duration must be non-negative.")
	assert(delay >= 0, "Delay must be non-negative.")
	assert(strength >= 0 and strength <= 1, "Strength must be between 1 and 0.")
	
	set_uniform(Uniform.VEC3_SCANLINE_COLOR, color)
	set_uniform(Uniform.FLOAT_SCANLINE_STRENGTH, strength)
	
	var uniform_on: Uniform = _SCAN_LOOKUP[direction][3][0]
	var uniform_reverse: Uniform = _SCAN_LOOKUP[direction][3][1]
	var uniform_start_time: Uniform = _SCAN_LOOKUP[direction][3][2]
	var uniform_scan_duration: Uniform = _SCAN_LOOKUP[direction][3][3]
	var uniform_delay: Uniform = _SCAN_LOOKUP[direction][3][4]
	var reverse: bool = _SCAN_LOOKUP[direction][4]
	
	set_uniform(uniform_on, true)
	set_uniform(uniform_reverse, reverse)
	if restart:
		set_uniform(uniform_start_time, START_TIME())
	set_uniform(uniform_scan_duration, scan_duration)
	set_uniform(uniform_delay, delay)

func set_scan_color(color: Color) -> void:
	set_uniform(Uniform.VEC3_SCANLINE_COLOR, color)

func stop_scanning(direction: ScanDirection) -> void: 
	var uniform_on: Uniform = _SCAN_LOOKUP[direction][3][0]
	set_uniform(uniform_on, false)

func stop_all() -> void:
	stop_flashing()
	stop_flickering()
	stop_glowing()
	for direction in ScanDirection.values():
		stop_scanning(direction)
