// Ben's Uber Pixel Shader
// WARNING - Shader expects uniform inputs in the range 0.0 - 1.0 for Colors. 
//           Therefore, be sure that Colors being passed in are in the correct range of (0-1, 0-1, 0-1, 0-1).
shader_type canvas_item;

// --- Utilty Functions --- //
const bool DEBUG = true;
const float TIME_OFFSET = 10.0; //offset all start times by this... for some reason things line up better with expectations
const vec2 HORIZONTAL_VERTICAL_OFFSETS[4] = {vec2(0, 1), vec2(-1, 0), vec2(1, 0), vec2(0, -1)};
const vec2 DIAGONAL_OUTLINE_OFFSETS[4] = {vec2(1, 1), vec2(-1, 1), vec2(1, -1), vec2(-1, -1)};

// checks if two values are 'equal' (within EPSILON of each other)
// necessary when doing float calculations since it's not perfectly precise
const float EPSILON = 0.001;
bool floateq(float val1, float val2) { return val1 >= val2 - EPSILON && val1 <= val2 + EPSILON; }
bool vec3eq(vec3 val1, vec3 val2) { return floateq(val1.r, val2.r) && floateq(val1.g, val2.g) && floateq(val1.b, val2.b); }

// Author: Michael Pohoreski https://stackoverflow.com/questions/5149544/can-i-generate-a-random-number-inside-a-pixel-shader
float random(vec2 seed){ return fract(cos(dot(seed, vec2(23.14069263277926, 2.665144142690225))) * 12345.6789); }
float snoise3(vec2 seed) { return fract(sin(dot(seed, vec2(12.9898, 78.233))) * 43758.5453); }
float randf_range(vec2 seed, float b1, float b2) { return mix(b1, b2, random(seed)); }
int randi_range(vec2 seed, int b1, int b2) { return int(randf_range(seed, float(b1), float(b2))); }
float sin0to1(float time) { return (sin(time)+1.0)/2.0; }
float cos0to1(float time) { return (cos(time)+1.0)/2.0; } 
float vary0to1(float time) { return 1.0-(cos(time)+1.0)/2.0; } // a transformed cos function that varies from 0 to 1. f(0) = 0, f(pi) = 1, f(2pi) = 0. 

// unused but may be useful someday
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// pass in the mouse position here
uniform vec2 MOUSE = vec2(20, 20);


// --- Effects --- //
// EXCLUDE
// If use_exclude_colors, pixels of these colors are excluded from tint, color correction, scanline, and vignette effects.
uniform bool use_exclude_colors = true;
uniform vec3 exclude_color1: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 exclude_color2: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 exclude_color3: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 exclude_color4: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders

// PAN/DISPLACE
// Displaces all pixels by (displace_x, displace_y). Texture repeats if displace_repeat.
// WARNING - Offsetting beyond the bounds of the texture will result in the texture being cut off
group_uniforms PanAndDisplacement;
uniform int displace_x = 0;
uniform int displace_y = 0;
uniform bool displace_repeat = true;
// Texture will automatically scroll if auto_pan_speed is nonzero.
// Set auto_pan_speed to a positive number for left/up panning; negative number for right/down panning
// WARNING - Repeat generally should be true for auto_pan_speed, otherwise it will immediately pan out of view
uniform vec2 auto_pan_speed = vec2(0, 0);

// RECOLOR
// Replaces replace_colorN with replace_with_colorN.
group_uniforms Recolor;
uniform vec3 replace_color1: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color1: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color2: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color2: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color3: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color3: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color4: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color4: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color5: source_color = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color5: source_color = vec3(0.0, 0.0, 0.0);

// special extra uniform specifically intended to recolor outlines
uniform vec3 replace_color_outline: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 replace_with_color_outline: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392);

// TINT
// Tint the texture with tint_color.
// The strength of the tint is controlled by tint_strength.
group_uniforms Tint;
uniform vec3 tint_color: source_color = vec3(0.0, 0.0, 0.0);
uniform float tint_strength: hint_range(0.0, 1.0) = 0.0;

// FLASH
// Flash the texture with flash_color. Essentially, this is a second layer of tint.
// flash_strength controls how much color is the original and how much is the flash_color.
group_uniforms Flash;
uniform vec3 flash_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float flash_strength: hint_range(0.0, 1.0) = 0.0;
// auto_flash_speed will cause infinite and repeated flashing if nonzero and controls the speed of this flashing.
// auto_flash_bound provides the second bound (alongside flash_strength) for the auto flash effect.
// To prevent the auto flash from starting in the middle of the animation, set auto_flash_start_time to the global time when enabling auto flash.
uniform float auto_flash_speed: hint_range(0.0, 20.0) = 0.0;
uniform float auto_flash_bound: hint_range(0.0, 1.0) = 0.0;
uniform float auto_flash_start_time = 0.0;

// COLOR CORRECTION
group_uniforms ColorCorrection;
// Applies red, green, or blue color correction with red_correct, green_correct, and blue_correct. 
// Applies grayscale with gray_correct.
// Modify brightness, contrast, or saturation with brightness_correct, contrast_correct, and saturation_correct.
// TIP - these values can actually go higher or lower, if you want a more extreme effect
uniform float red_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float green_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float blue_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float gray_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float brightness_correct: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float contrast_correct: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float saturation_correct: hint_range(0.0, 2.0, 0.01) = 1.0;

// TODO - more funky color options
// rg swap - swaps the original (before any other swaps) value of r and g
// gb swap
// br swap
// r_eq_g - sets r = g
// r_eq_b
// g_eq_r
// g_eq_b
// b_eq_r
// b_eq_g

// TODO - ROUGHEN - applies randomized brightness modifications across the texture (both positive and negative) to 'roughen' it up

// SCANLINES
// Create a line across the canvas of scanline_color. scanline_strength controls the alpha of the line.
// Define the position of the line with scanline_left_to_right_position, scanline_top_to_bottom_position,
// scanline_topleft_to_bottomright_position, and scanline_topright_to_bottomleft_position.
// The line is vertical if going left to right, horizontal if going top to bottom, and diagonal for the other two.
group_uniforms Scanline;
uniform vec3 scanline_color: source_color = vec3(0.98, 0.69, 0.23);
uniform float scanline_strength: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float scanline_left_to_right_position: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_top_to_bottom_position: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_topleft_to_bottomright_position: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_topright_to_bottomleft_position: hint_range(-0.001, 1.0, 0.001) = -0.001;
// auto_scanline_DIRECTION_on will enable automatic repeating scanlines in that direction.
// auto_scanline_DIRECTION_reverse will flip the direction.
// The scan will be visible for auto_scanline_DIRECTION_scan_duration, with a delay of 
// auto_scanline_DIRECTION_scan_duration before the next scan begins.
// To prevent the scanline from starting in the middle of the texture, provide the global time to auto_scanline_DIRECTION_start_time.
uniform bool auto_scanline_left_to_right_on = false;
uniform bool auto_scanline_left_to_right_reverse = false;
uniform float auto_scanline_left_to_right_start_time = 0.0;
uniform float auto_scanline_left_to_right_scan_duration: hint_range(0.1, 5.0, 0.01) = 0.5;
uniform float auto_scanline_left_to_right_delay: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform bool auto_scanline_top_to_bottom_on = false;
uniform bool auto_scanline_top_to_bottom_reverse = false;
uniform float auto_scanline_top_to_bottom_start_time = 0.0;
uniform float auto_scanline_top_to_bottom_scan_duration: hint_range(0.1, 5.0, 0.01) = 0.5;
uniform float auto_scanline_top_to_bottom_delay: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform bool auto_scanline_topleft_to_bottomright_on = false;
uniform bool auto_scanline_topleft_to_bottomright_reverse = false;
uniform float auto_scanline_topleft_to_bottomright_start_time = 0.0;
uniform float auto_scanline_topleft_to_bottomright_scan_duration: hint_range(0.1, 5.0, 0.01) = 0.5;
uniform float auto_scanline_topleft_to_bottomright_delay: hint_range(0.0, 10.0, 0.1) = 1.0;
uniform bool auto_scanline_topright_to_bottomleft_on = false;
uniform bool auto_scanline_topright_to_bottomleft_reverse = false;
uniform float auto_scanline_topright_to_bottomleft_start_time = 0.0;
uniform float auto_scanline_topright_to_bottomleft_scan_duration: hint_range(0.1, 5.0, 0.01) = 0.5;
uniform float auto_scanline_topright_to_bottomleft_delay: hint_range(0.0, 10.0, 0.1) = 1.0;

// OUTLINE
// Adds a pixel outline to the texture, with glow_color and glow_thickness.
// glow_dialgonals controls if we also create this outline diagonally, which makes it thicker.
// This can be used to create a solid outline if auto_glow_speed is left at 0.
// WARNING - Shaders cannot draw outside of the bounds of the canvas, so the canvas may need extra transparent space on the sides.
// WARNING - Can have some odd effects with sprites containing partial transparency.
group_uniforms GlowAndOutline;
uniform vec4 glow_color: source_color = vec4(1.0);
uniform int glow_thickness: hint_range(0, 10) = 0;
uniform bool glow_diagonals = false;
// auto_glow_speed defines the speed of a glow fluctuating alpha between the outline's alpha and auto_glow_bound at auto_glow_speed.
// To prevent the auto glow from starting in the middle of the animation, set auto_glow_start_time to the global time when enabling auto glow.
uniform float auto_glow_speed: hint_range(0.0, 30.0) = 0.0;
uniform float auto_glow_bound: hint_range(0.0, 1.0) = 0.75;
uniform float auto_glow_start_time = 0.0;

// DISINTEGRATE
// Sets 'random' pixels in the canvas to disintegrate_color with alpha between disintegrate_alpha_bound1 and disintegrate_alpha_bound2.
// By default, since these bounds are 0, the pixels will be made fully transparent and therefore disintegrate_color is unused.
// disintegrate_strength controls the amount of pixels affected, from none (0) to all of them (1).
// Change the pattern via disintegrate_seed.
// disintegrate_as_static changes the purpose of disintegrate to not affect the alpha of the texture.
// Instead, it layers a static-looking pattern on top using disintegrate_color, where the color is based on disintegrate_color
// and the alpha of the static pattern ranges randomly between disintegrate_alpha_bound1 and disintegrate_alpha_bound2 per pixel.
// Note that with the default bounds of 0 and 0, this setting creates no effect whatsoever.
// If auto_disintegrate_random_seed_speed is nonzero, applies randomization to the seed over time based on speed.
// In this case, disintegrate_seed has no effect.
group_uniforms Disintegrate;
uniform int disintegrate_seed = 1;
uniform vec3 disintegrate_color : source_color = vec3(0.0, 0.0, 0.0);
uniform float disintegrate_strength: hint_range(0.0, 1.0) = 0.0;
uniform float disintegrate_alpha_bound1 = 0.0;
uniform float disintegrate_alpha_bound2 = 0.0;
uniform bool disintegrate_as_static = false;
uniform float auto_disintegrate_random_seed_speed: hint_range(0.0, 1.0) = 0.0;

// FOG
// Applies a fog_noise_texture filter over the texture with modifiable fog_opacity and fog_density, moving at fog_speed
// Mostly used to create fog effects by assigning to a ColorRect (color is changable by changing ColorRect color too!)
group_uniforms Fog;
uniform bool fog_enabled = false;
uniform sampler2D fog_noise_texture: repeat_enable, filter_nearest;
uniform float fog_opacity: hint_range(0.0, 1.0) = 0.5;
uniform float fog_density: hint_range(0.0, 1.0) = 0.25;
uniform vec2 fog_speed = vec2(-0.02, 0.0);

// COLORLINES
// Creates vertical/horizontal lines of colorline_color spaced colorline_spacing pixels apart 
// with colorline_strength alpha across the texture.
group_uniforms Colorlines;
uniform vec3 vertical_colorline_color: source_color = vec3(1.0, 1.0, 1.0);
uniform int vertical_colorline_spacing = 2;
uniform float vertical_colorline_strength: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec3 horizontal_colorline_color: source_color = vec3(1.0, 1.0, 1.0);
uniform int horizontal_colorline_spacing = 2;
uniform float horizontal_colorline_strength: hint_range(0.0, 1.0, 0.01) = 0.0;

// CHECKER
// Creates a checkerboard pattern across the texture of checker_color with checker_strength alpha.
// checker_x_size and checker_y_size defines the size of each rectangular checker
// checker_x_pattern and checker_y_pattern affect the pattern of the checker pattern (which
// can stop looking checkered with different values).
// checker_contrast_amount applies a darkening effect to pixels of the checkerboard that are already dark.
// checker_contrast_ratio increases the contrast of the darkening effect between light and dark colored pixels,
// ie dark pixels become even darker.
group_uniforms CHECKER;
uniform vec3 checker_color: source_color = vec3(0.2, 0.2, 0.2);
uniform float checker_strength: hint_range(0.0, 1.0, 0.01) = 0.0; //0.3 is a good one
uniform int checker_x_size: hint_range(1, 64, 1) = 1;
uniform int checker_y_size: hint_range(1, 64, 1) = 1;
uniform int checker_x_pattern: hint_range(1, 32, 1) = 2;
uniform int checker_y_pattern: hint_range(1, 32, 1) = 2;
uniform float checker_contrast_amount: hint_range(-10.0, 10.0, 0.1) = 1.0;
uniform float checker_contrast_ratio: hint_range(0.0, 10.0, 0.01) = 0.5;
// TODO - experiment a bit more with the contrast calculation here - maybe subtract 0.5 and LIGHTEN lighter areas?

// MOUSELIGHT
// Creates a circular lighting effect at the mouse's position if mouselight_on, of mouselight_color and mouselight_strength alpha.
// Mouselight size defines the radius of the light effect.
// If mouselight_soften_edges, pixels further from the center of the light are more transparent.
// If mouselight_checker, the effect will be checkered in a way that interacts with the CHECKER effect.
// If auto_mouselight_flicker_speed is non-zero, the light will oscillate in size between mouselight_size and auto_mouselight_flicker_speed
group_uniforms Mouselight;
uniform bool mouselight_on = false;
uniform vec3 mouselight_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float mouselight_strength = 0.5;
uniform int mouselight_size = 8;
uniform bool mouselight_soften_edges = true;
uniform bool mouselight_checker = false;
uniform float auto_mouselight_flicker_speed: hint_range(0.0, 20.0) = 8;
uniform float auto_mouselight_flicker_bound = 10;

// CUT
// Cuts off all pixels of the texture from left/right/top/bottom.
group_uniforms Cut;
uniform float cut_left: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_right: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_top: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_bottom: hint_range(0.0, 1.0, 0.001) = 0.0;

// VIGNETTE
// Applies a circular vignette effect on the canvas if vignette_on.
// The vignette has a vignette_radius and a vignette_color.
// If vignette_ignore_transparent, transparent pixels will not have the vignette applied.
// This is generally useful if you want to apply a vignette on something besides the entire screen.
group_uniforms Vignette;
uniform bool vignette_on = false;
uniform bool vignette_ignore_transparent = false;
uniform vec3 vignette_color: source_color = vec3(0.0, 0.0, 0.0);
uniform float vignette_radius: hint_range(0.001, 10.0, 0.01) = 1.0;

// TRANSPARENCY
// Controls transparency of the texture.
// If auto_flicker_speed is not zero, oscillates between transparency and auto_flicker_bounds at auto_flicker_speed.
// To prevent the auto flicker from starting in the middle of the animation, set auto_flicker_start_time to the global time when enabling auto flicker.
group_uniforms Transparency;
uniform float transparency: hint_range(0.0, 1.0) = 1.0;
uniform float auto_flicker_speed: hint_range(0.0, 20.0) = 0.0;
uniform float auto_flicker_bound: hint_range(0.0, 1.0) = 0.0;
uniform float auto_flicker_start_time = 0.0;

// --- Fragment Shader --- //
void fragment() 
{
	// --- CALCULATE CONSTANTS ---
	// the size of this canvas in pixels
	int PSIZE_X = int(floor(1.0 / TEXTURE_PIXEL_SIZE.x));
	int PSIZE_Y = int(floor(1.0 / TEXTURE_PIXEL_SIZE.y));
	
	// the specific x and y pixel coordinates
	int PX = int(floor(UV.x / TEXTURE_PIXEL_SIZE.x));
	int PY = int(floor(UV.y / TEXTURE_PIXEL_SIZE.y));
	
	// screen size (ex 320x180)
	int SSIZE_X = int(floor(1.0 / SCREEN_PIXEL_SIZE.x));
	int SSIZE_Y = int(floor(1.0 / SCREEN_PIXEL_SIZE.y));
	int SX = int(floor(SCREEN_UV.x / SCREEN_PIXEL_SIZE.x));
	int SY = int(floor(SCREEN_UV.y / SCREEN_PIXEL_SIZE.y));
	// ---
	
	
	// DISPLACE & PAN
	vec2 adjUV = vec2(0, 0); // WARNING - Use this instead of UV below, otherwise effects break with panning & displace
	
	float displaceUVX = UV.x + (TEXTURE_PIXEL_SIZE.x * float(displace_x));
	float displaceUVY = UV.y + (TEXTURE_PIXEL_SIZE.y * float(displace_y));
	if (displace_repeat) {
		adjUV = mod(vec2(displaceUVX, displaceUVY) + TIME * auto_pan_speed, 1.0);
	} else {
		adjUV = vec2(displaceUVX, displaceUVY) + TIME * auto_pan_speed;
	}
	
	COLOR = texture(TEXTURE, adjUV); //since this reads from texture, it has to go first; otherwise we rewrite changes
	
	// EXCLUDE COLORS
	bool is_exclude_color = use_exclude_colors && (vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color1) || vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color2) || vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color3) || vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color4));
	
	// RECOLOR
	if (vec3eq(COLOR.rgb, replace_color1)) 
		COLOR.rgb = replace_with_color1;
	if (vec3eq(COLOR.rgb, replace_color2)) 
		COLOR.rgb = replace_with_color2;
	if (vec3eq(COLOR.rgb, replace_color3)) 
		COLOR.rgb = replace_with_color3;
	if (vec3eq(COLOR.rgb, replace_color4)) 
		COLOR.rgb = replace_with_color4;
	if (vec3eq(COLOR.rgb, replace_color5)) 
		COLOR.rgb = replace_with_color5;
	if (vec3eq(COLOR.rgb, replace_color_outline))
		COLOR.rgb = replace_with_color_outline;
	
	// TINT, COLOR CORRECTION, and SCANLINE ignore excluded colors
	if (!is_exclude_color) {
		// TINT
		COLOR.rgb = mix(COLOR.rgb, tint_color, tint_strength);
		
		// FLASH
		float flash_mix = flash_strength;
		if (auto_flash_speed != 0.0)
			flash_mix = mix(auto_flash_bound, flash_strength, abs(vary0to1((TIME-auto_flash_start_time + TIME_OFFSET) * auto_flash_speed)));
		COLOR.rgb = mix(COLOR.rgb, flash_color, flash_mix);
	
		// COLOR CORRECTION
		COLOR.r = mix(COLOR.r, 1.0, red_correct);
		COLOR.g = mix(COLOR.g, 1.0, green_correct);
		COLOR.b = mix(COLOR.b, 1.0, blue_correct);
		COLOR.rgb = mix(COLOR.rgb, vec3(0.2126 * COLOR.r + 0.7152 * COLOR.g + 0.0722 * COLOR.b), gray_correct);
		COLOR.rgb = mix(vec3(0.0), COLOR.rgb, brightness_correct);
		COLOR.rgb = mix(vec3(0.5), COLOR.rgb, contrast_correct);
		COLOR.rgb = mix(vec3(dot(vec3(1.0), COLOR.rbg)), COLOR.rgb, saturation_correct);
	
		// SCANLINE
		if (COLOR.a != 0.0) {
			float l_to_r_pos = !auto_scanline_left_to_right_on ? scanline_left_to_right_position : abs((auto_scanline_left_to_right_reverse ? 1.0 : 0.0) - mix(0.0, 1.0, float(clamp(mod(TIME - auto_scanline_left_to_right_start_time + TIME_OFFSET, auto_scanline_left_to_right_delay + auto_scanline_left_to_right_scan_duration), 0.0, auto_scanline_left_to_right_scan_duration)/auto_scanline_left_to_right_scan_duration)));
			float t_to_b_pos = !auto_scanline_top_to_bottom_on ? scanline_top_to_bottom_position : abs((auto_scanline_top_to_bottom_reverse ? 1.0 : 0.0) - mix(0.0, 1.0, float(clamp(mod(TIME - auto_scanline_top_to_bottom_start_time + TIME_OFFSET, auto_scanline_top_to_bottom_delay + auto_scanline_top_to_bottom_scan_duration), 0.0, auto_scanline_top_to_bottom_scan_duration)/auto_scanline_top_to_bottom_scan_duration)));
			float tl_to_br_pos = !auto_scanline_topleft_to_bottomright_on ? scanline_topleft_to_bottomright_position : abs((auto_scanline_topleft_to_bottomright_reverse ? 1.0 : 0.0) - mix(0.0, 1.0, float(clamp(mod(TIME - auto_scanline_topleft_to_bottomright_start_time + TIME_OFFSET, auto_scanline_topleft_to_bottomright_delay + auto_scanline_topleft_to_bottomright_scan_duration), 0.0, auto_scanline_topleft_to_bottomright_scan_duration)/auto_scanline_topleft_to_bottomright_scan_duration)));
			float tr_to_bl_pos = !auto_scanline_topright_to_bottomleft_on ? scanline_topright_to_bottomleft_position : abs((auto_scanline_topright_to_bottomleft_reverse ? 1.0 : 0.0) - mix(0.0, 1.0, float(clamp(mod(TIME - auto_scanline_topright_to_bottomleft_start_time + TIME_OFFSET, auto_scanline_topright_to_bottomleft_delay + auto_scanline_topright_to_bottomleft_scan_duration), 0.0, auto_scanline_topright_to_bottomleft_scan_duration)/auto_scanline_topright_to_bottomleft_scan_duration)));
			
			if (PX == int(floor(l_to_r_pos / TEXTURE_PIXEL_SIZE.x)))
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
			if (PY == int(floor(t_to_b_pos / TEXTURE_PIXEL_SIZE.y)))
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
			int scanline_target_tlbr = int(floor(tl_to_br_pos * float(PSIZE_X + PSIZE_Y)));
			int scanline_target_trbl = int(floor(tr_to_bl_pos * float(PSIZE_X + PSIZE_Y))) - PSIZE_Y;
			if (PX+PY == scanline_target_tlbr)
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
			if (PX-PY == scanline_target_trbl)
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
		}
	}
	
	// GLOW
	if (glow_thickness != 0) {
		vec2 outline_size = TEXTURE_PIXEL_SIZE * float(glow_thickness);
		float outline = 0.0;
		for (int i = 0; i < HORIZONTAL_VERTICAL_OFFSETS.length(); i++) {
			outline += texture(TEXTURE, adjUV + outline_size * HORIZONTAL_VERTICAL_OFFSETS[i]).a;
		}
		if (glow_diagonals) {
			for (int i = 0; i < DIAGONAL_OUTLINE_OFFSETS.length(); i++) {
				outline += texture(TEXTURE, adjUV + outline_size * DIAGONAL_OUTLINE_OFFSETS[i]).a;
			}
		}
		outline = min(outline, 1.0);
		// this is a bit of a coding $HACK$ to make auto_glow_bound do nothing if auto_glow_speed is 0, but it definitely works
		float alp = auto_glow_speed == 0.0 ? 1.0 : mix(auto_glow_bound, glow_color.a, vary0to1((TIME - auto_glow_start_time + TIME_OFFSET) * auto_glow_speed));
		COLOR = mix(COLOR, glow_color * alp, outline - COLOR.a);
	}
	
	// DISINTEGRATE
	if (COLOR.a != 0.0) {
		vec2 s = adjUV * vec2(float(disintegrate_seed));
		s *= auto_disintegrate_random_seed_speed != 0.0 ? float(int(TIME / mix(1.0, 0.001, auto_disintegrate_random_seed_speed))) : 1.0;
		float r = random(s);
		if (r < disintegrate_strength) {
			float r_alpha = randf_range(s, disintegrate_alpha_bound1, disintegrate_alpha_bound2);
			COLOR.rgb = mix(COLOR.rgb, disintegrate_color, r_alpha);
			if (!disintegrate_as_static)
				COLOR.a = r_alpha;
		}
	}
	
	// FOG
	if (fog_enabled) {
		vec2 fog_uv = UV + fog_speed * TIME;
		float noise_alpha = texture(fog_noise_texture, fog_uv).r;
		// Convert noise from (0.0, 1.0) to (-1.0, 1.0)
		float fog = clamp((noise_alpha * 2.0 - 1.0) + (fog_density * 2.0), 0.0, 1.0);
		COLOR.a *= fog * fog_opacity;
	}
	
	// COLORLINES
	if (PX % vertical_colorline_spacing == 0) {
		COLOR.rgb = mix(COLOR.rgb, vertical_colorline_color, vertical_colorline_strength);
	}
	if (PY % horizontal_colorline_spacing == 0) {
		COLOR.rgb = mix(COLOR.rgb, horizontal_colorline_color, horizontal_colorline_strength);
	}
	
	// CHECKER
	if (PX/checker_x_size % checker_x_pattern != PY/checker_y_size % checker_y_pattern) {
		float pixel_darkness = (3.0 - (COLOR.r + COLOR.g + COLOR.b)) * checker_contrast_ratio; // calculates 0.0 to 1.0 where 1.0 is pure black and 0.0 is pure white
		vec3 cbcolor = mix(checker_color.rgb, vec3(0.0), pixel_darkness * checker_contrast_amount);
		COLOR.rgb = mix(COLOR.rgb, cbcolor, checker_strength);
	}
	
	// MOUSELIGHT
	if (mouselight_on && (!mouselight_checker || PX % 2 == PY % 2)) {
		float mouse_with_flicker = mix(auto_mouselight_flicker_bound, float(mouselight_size), vary0to1(TIME * auto_mouselight_flicker_speed));
		float dist_from_mouse = sqrt(pow(float(SX - int(MOUSE.x)), 2.0) + pow(float(SY - int(MOUSE.y)), 2.0));
		if (dist_from_mouse <= float(mouse_with_flicker)) {
			//todo - make softening with distance optional as uniform
			float distance_mod = clamp((mouse_with_flicker - dist_from_mouse) / mouse_with_flicker, 0.0, 1.0);
			COLOR.rgb = mix(COLOR.rgb, mouselight_color, distance_mod * mouselight_strength);
		}
	}
	
	// CUT
	if (UV.x < cut_left)
		COLOR.a = 0.0;
	if (UV.x > 1.0-cut_right)
		COLOR.a = 0.0;
	if (UV.y < cut_top)
		COLOR.a = 0.0;
	if (UV.y > 1.0-cut_bottom)
		COLOR.a = 0.0;
		
	// VIGNETTE
	if (vignette_on && ((!vignette_ignore_transparent || COLOR.a != 0.0)) && !is_exclude_color) {
		float x = abs(adjUV.x-.5)*2.0;
		float y = abs(adjUV.y-.5)*2.0;
		float v = (sqrt((x*x)+(y*y))/vignette_radius);
		COLOR = mix(COLOR, vec4(vignette_color.r, vignette_color.g, vignette_color.b, 1.0), v);
	}
	
	// TRANSPARENCY
	if (COLOR.a != 0.0) {
		COLOR.a = mix(COLOR.a * transparency, auto_flicker_bound, vary0to1((TIME-auto_flicker_start_time + TIME_OFFSET) * auto_flicker_speed));
	}
}

void vertex()
{
	
}