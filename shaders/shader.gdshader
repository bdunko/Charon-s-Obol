// Ben's Uber Pixel Shader
// WARNING - Shader expects uniform inputs in the range 0.0 - 1.0 for Colors. 
//           Therefore, be sure that Colors being passed in are in the correct range of (0-1, 0-1, 0-1, 0-1).
shader_type canvas_item;

// --- Utilty Functions --- //
const bool DEBUG = true;
// checks if two values are 'equal' (within EPSILON of each other)
// necessary when doing float calculations since it's not perfectly precise
const float EPSILON = 0.001;
bool floateq(float val1, float val2) { return val1 >= val2 - EPSILON && val1 <= val2 + EPSILON; }
bool vec3eq(vec3 val1, vec3 val2) { return floateq(val1.r, val2.r) && floateq(val1.g, val2.g) && floateq(val1.b, val2.b); }

float sin0to1(float time) { return (sin(time)+1.0)/2.0; }
float cos0to1(float time) { return (cos(time)+1.0)/2.0; }

// unused but may be useful someday
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

// pass in the mouse position here
uniform vec2 MOUSE = vec2(20, 20);


// --- Effects --- //
// EXCLUDE
// Pixels of these colors are excluded from tint, color correction, scanline, and vignette effects
uniform bool use_exclude_colors = true;
uniform vec3 exclude_color: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 exclude_color2: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 exclude_color3: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 exclude_color4: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders

// PAN/DISPLACE
// Displaces all pixels by (displace_x, displace_y)
// Controls texture left/right/up/down panning (the texture will be repeated if repeat)
// Set to a positive number for left/up panning; negative number for right/down panning
// WARNING - Offsetting beyond the bounds of the texture will result in the texture being cut off
// WARNING - Repeat must be true for pan_speed to work, otherwise it will immediately pan off screen
group_uniforms PanAndDisplacement;
uniform int displace_x = 0;
uniform int displace_y = 0;
uniform vec2 pan_speed = vec2(0, 0);
uniform bool repeat = true;

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
uniform vec3 replace_color5: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392); // these floats are the numbers I like to use for borders
uniform vec3 replace_with_color5: source_color = vec3(0.07843137254, 0.06274509803, 0.07450980392);

// TINT
// Tint the texture with tint_color (rbg) 
// The strength of the tint is controlled by tint_strength (0-1)
group_uniforms Tint;
uniform vec3 tint_color: source_color = vec3(0.0, 0.0, 0.0);
uniform float tint_strength: hint_range(0.0, 1.0) = 0.0;

// FLASH
group_uniforms Flash;
uniform vec3 flash_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float flash_strength: hint_range(0.0, 1.0) = 0.0;
uniform float flash_speed: hint_range(0.0, 20.0) = 0.0;

// COLOR CORRECTION
group_uniforms ColorCorrection;
// TIP - these values can actually go higher or lower, if you want a more extreme effect
uniform float red_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float green_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float blue_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float gray_correct: hint_range(-1.0, 1.0, 0.01) = 0.0;
uniform float brightness_correct: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float contrast_correct: hint_range(0.0, 5.0, 0.01) = 1.0;
uniform float saturation_correct: hint_range(0.0, 2.0, 0.01) = 1.0;

// SCANLINES
group_uniforms Scanline;
uniform vec3 scanline_color: source_color = vec3(0.98, 0.69, 0.23);
uniform float scanline_strength: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float scanline_left_to_right: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_top_to_bottom: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_topleft_to_bottomright: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_topright_to_bottomleft: hint_range(-0.001, 1.0, 0.001) = -0.001;

// DISINTEGRATE
group_uniforms Disintegrate;
uniform sampler2D disintegrate_noise_texture: repeat_enable, filter_nearest;
uniform float disintegrate_strength: hint_range(0.0, 1.0) = 0.0;

// OUTLINE
// Adds a pixel outline to the texture, with outline_color and outline_thickness.
// outline_dialgonals controls if we also create this outline diagonally, which makes it thicker.
// Can also be used to create glowing effects which fluctuate alpha between outline_glow_min to outline_glow_max.
// WARNING - Shaders cannot draw outside of the bounds of the canvas, so the canvas may need extra transparent space on the sides.
// WARNING - Can have some odd effects with sprites containing partial transparency.
group_uniforms OutlineAndGlow;
uniform vec4 outline_color: source_color = vec4(1.0);
uniform int outline_thickness: hint_range(0, 10) = 0;
uniform bool outline_diagonals = false;
uniform float outline_start_time = 0;
uniform float outline_glow_speed = 2.5;
uniform float outline_glow_min = 1.0;
uniform float outline_glow_max = 1.0;
const vec2 HORIZONTAL_VERTICAL_OFFSETS[4] = {vec2(0, 1), vec2(-1, 0), vec2(1, 0), vec2(0, -1)};
const vec2 DIAGONAL_OUTLINE_OFFSETS[4] = {vec2(1, 1), vec2(-1, 1), vec2(1, -1), vec2(-1, -1)};

// FOG
// Applies a fog_noise_texture filter over the texture with modifiable opacity and density, moving at speed
// Mostly used to create fog effects by assigning to a ColorRect (color is changable by changing ColorRect color too!)
group_uniforms Fog;
uniform bool fog_enabled = false;
uniform sampler2D fog_noise_texture: repeat_enable, filter_nearest;
uniform float fog_opacity: hint_range(0.0, 1.0) = 0.5;
uniform float fog_density: hint_range(0.0, 1.0) = 0.25;
uniform vec2 fog_speed = vec2(0.02, 0.01);

// COLORLINES
group_uniforms Colorlines;
uniform vec3 vertical_colorline_color: source_color = vec3(1.0, 1.0, 1.0);
uniform int vertical_colorline_spacing = 2;
uniform float vertical_colorline_strength: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec3 horizontal_colorline_color: source_color = vec3(1.0, 1.0, 1.0);
uniform int horizontal_colorline_spacing = 2;
uniform float horizontal_colorline_strength: hint_range(0.0, 1.0, 0.01) = 0.0;

// CHECKER
group_uniforms CHECKER;
uniform vec3 checker_color: source_color = vec3(0.2, 0.2, 0.2);
uniform float checker_strength: hint_range(0.0, 1.0, 0.01) = 0.0; //0.3 is a good one

// MOUSELIGHT
group_uniforms Mouselight;
uniform bool mouselight_on = false;
uniform bool mouselight_checker = false;
uniform vec3 mouselight_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float mouselight_strength = 0.5;
uniform int mouselight_size = 8;
uniform float mouselight_flicker_size = 3;
uniform float mouselight_flicker_speed: hint_range(0.0, 20.0) = 10;

// CUT
group_uniforms Cut;
uniform float cut_left: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_right: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_top: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_bottom: hint_range(0.0, 1.0, 0.001) = 0.0;

// VIGNETTE
group_uniforms Vignette;
uniform bool vignette_on = false;
uniform bool vignette_ignore_transparent = false;
uniform vec3 vignette_color: source_color = vec3(0.0, 0.0, 0.0);
uniform float vignette_radius: hint_range(0.001, 5.0, 0.01) = 1.0;

// TRANSPARENCY
// Controls transparency of the texture.
// If transparency_flicker, modulates between the given transparency and transparency_flicker_min at transparency_flicker_speed
group_uniforms Transparency;
uniform float transparency: hint_range(0.0, 1.0) = 1.0;
uniform bool flicker_on = false;
uniform float flicker_min: hint_range(0.0, 1.0) = 0.0;
uniform float flicker_speed: hint_range(0.0, 20.0) = 2.0;

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
	if (repeat) {
		adjUV = mod(vec2(displaceUVX, displaceUVY) + TIME * pan_speed, 1.0);
	} else {
		adjUV = vec2(displaceUVX, displaceUVY) + TIME * pan_speed;
	}
	
	COLOR = texture(TEXTURE, adjUV); //since this reads from texture, it has to go first; otherwise we rewrite changes
	
	bool is_exclude_color = use_exclude_colors && (vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color) || vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color2) || vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color3) || vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color4));
	
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
	
	// TINT, COLOR CORRECTION, and SCANLINE ignore excluded colors
	if (!is_exclude_color) {
		// TINT
		COLOR.rgb = mix(COLOR.rgb, tint_color, tint_strength);
		
		// FLASH
		COLOR.rgb = mix(COLOR.rgb, flash_color, cos0to1(TIME * flash_speed) * flash_strength);
	
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
			if (PX == int(floor(scanline_left_to_right / TEXTURE_PIXEL_SIZE.x)))
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
			if (PY == int(floor(scanline_top_to_bottom / TEXTURE_PIXEL_SIZE.y)))
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
			int scanline_target_tlbr = int(floor(scanline_topleft_to_bottomright * float(PSIZE_X + PSIZE_Y)));
			int scanline_target_trbl = int(floor(scanline_topright_to_bottomleft * float(PSIZE_X + PSIZE_Y))) - PSIZE_Y;
			if (PX+PY == scanline_target_tlbr)
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
			if (PX-PY == scanline_target_trbl)
				COLOR.rgb = mix(COLOR.rgb, scanline_color, scanline_strength);
		}
	}
	
	// DISINTEGRATE
	if (COLOR.a != 0.0) {
		float disintegrate_alpha = texture(disintegrate_noise_texture, UV).r;
		if (disintegrate_alpha < disintegrate_strength)
			COLOR.a = 0.0;
	}
	
	// OUTLINE
	if (outline_thickness != 0) {
		vec2 outline_size = TEXTURE_PIXEL_SIZE * float(outline_thickness);
		float outline = 0.0;
		for (int i = 0; i < HORIZONTAL_VERTICAL_OFFSETS.length(); i++) {
			outline += texture(TEXTURE, adjUV + outline_size * HORIZONTAL_VERTICAL_OFFSETS[i]).a;
		}
		if (outline_diagonals) {
			for (int i = 0; i < DIAGONAL_OUTLINE_OFFSETS.length(); i++) {
				outline += texture(TEXTURE, adjUV + outline_size * DIAGONAL_OUTLINE_OFFSETS[i]).a;
			}
		}
		outline = min(outline, 1.0);
		
		float glow_alpha = mix(outline_glow_min, outline_glow_max, abs(cos0to1((TIME - outline_start_time) * outline_glow_speed)));
		COLOR = mix(COLOR, outline_color * glow_alpha, outline - COLOR.a);
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
	if (PX % 2 != PY % 2) {
		float strength = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
		vec3 adj_cbcolor = checker_color.rgb;
		adj_cbcolor.r *= strength;
		adj_cbcolor.g *= strength;
		adj_cbcolor.b *= strength;
		COLOR.rgb = mix(COLOR.rgb, adj_cbcolor, checker_strength);
	}
	
	// MOUSELIGHT
	if (mouselight_on && (!mouselight_checker || PX % 2 == PY % 2)) {
		float mouse_with_flicker = float(mouselight_size + int(mouselight_flicker_size * sin0to1(TIME * mouselight_flicker_speed)));
		float dist_from_mouse = sqrt(pow(float(SX - int(MOUSE.x)), 2.0) + pow(float(SY - int(MOUSE.y)), 2.0));
		if (dist_from_mouse <= float(mouse_with_flicker)) {
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
		float x = abs(UV.x-.5)*2.0;
		float y = abs(UV.y-.5)*2.0;
		float v = (sqrt((x*x)+(y*y))/vignette_radius);
		COLOR = mix(COLOR, vec4(vignette_color.r, vignette_color.g, vignette_color.b, 1.0), v);
	}
	
	// TRANSPARENCY
	if (COLOR.a != 0.0) {
		float transparency_actual = transparency;
		if (flicker_on)
			transparency_actual = mix(transparency, flicker_min, sin0to1(TIME * flicker_speed));
		COLOR.a = mix(COLOR.a, 0.0, 1.0 - transparency_actual);
	}
}

void vertex()
{
	
}