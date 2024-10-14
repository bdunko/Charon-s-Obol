// Ben's General Purpose Pixel Shader
// WARNING - Shader expects uniform inputs in the range 0.0 - 1.0 for Colors. 
//           Therefore, be sure that Colors being passed in are in the correct range of (0-1, 0-1, 0-1, 0-1).
shader_type canvas_item;

// --- Utilty Functions --- //
// checks if two values are 'equal' (within EPSILON of each other)
// necessary when doing float calculations since it's not perfectly precise
const float EPSILON = 0.001;
bool floateq(float val1, float val2) { return val1 >= val2 - EPSILON && val1 <= val2 + EPSILON; }
bool vec3eq(vec3 val1, vec3 val2) { return floateq(val1.r, val2.r) && floateq(val1.g, val2.g) && floateq(val1.b, val2.b); }
float sin0to1(float time) { return (sin(time)+1.0)/2.0; }
float cos0to1(float time) { return (cos(time)+1.0)/2.0; }
// unused but may be useful someday
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;


// --- Effects --- //
// EXCLUDE
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
// If tint_auto_flash, the tint will oscillate between the original color and tint color at tint_auto_flash_speed
// If use_exclude_tint, the tint ignores pixels whose color matches excude_tint (useful for ignoring borders)
// Can also be used to create flashing effects (flash_color/strength is identical to tint_color/strength, but provides another layer for flexibility)
// Flash is applied after tint.
group_uniforms TintAndFlash;
uniform vec3 tint_color: source_color = vec3(0.0, 0.0, 0.0);
uniform float tint_strength: hint_range(0.0, 1.0) = 0.0;
uniform float tint_auto_flash_speed = 0;
uniform vec3 flash_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float flash_strength: hint_range(0.0, 1.0);

// COLOR CORRECTION
group_uniforms ColorCorrection;
uniform float red_correct: hint_range(-1.0, 1.0) = 0.0;
uniform float green_correct: hint_range(-1.0, 1.0) = 0.0;
uniform float blue_correct: hint_range(-1.0, 1.0) = 0.0;
uniform float gray_correct: hint_range(0.0, 1.0) = 0.0;

// SCANLINES
//LR
//UD
//DIAG

// DISINTEGRATE

// CRACK

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

// DITHER
// DITHERLIGHT

// TRANSPARENCY
// Controls transparency of the texture.
// If transparency_flicker, modulates between the given transparency and transparency_flicker_min at transparency_flicker_speed
group_uniforms TransparencyAndFlicker;
uniform float transparency: hint_range(0.0, 1.0) = 1.0;
uniform bool transparency_glow = false;
uniform float transparency_glow_min: hint_range(0.0, 1.0) = 0.0;
uniform float transparency_glow_speed = 2.0;


// --- Fragment Shader --- //
void fragment() 
{
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
	
	// TINT
	if (!use_exclude_colors || !vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color) || !vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color2) || !vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color3) || !vec3eq(texture(TEXTURE, adjUV).rgb, exclude_color4)) {
		float glowing_tint_str = tint_strength;
		glowing_tint_str *= cos0to1(TIME * tint_auto_flash_speed);
		COLOR.rgb = mix(COLOR.rgb, tint_color, glowing_tint_str);
		COLOR.rgb = mix(COLOR.rgb, flash_color, flash_strength);
	}
	
	// COLOR CORRECTION
	COLOR.r = mix(COLOR.r, 1.0, red_correct);
	COLOR.g = mix(COLOR.g, 1.0, green_correct);
	COLOR.b = mix(COLOR.b, 1.0, blue_correct);
	COLOR.rgb = mix(COLOR.rgb, vec3(0.2126 * COLOR.r + 0.7152 * COLOR.g + 0.0722 * COLOR.b), gray_correct);
	
	
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
	
	// TRANSPARENCY
	if (COLOR.a != 0.0) {
		float transparency_actual = transparency;
		if (transparency_glow)
			transparency_actual = mix(transparency, transparency_glow_min, sin0to1(TIME * transparency_glow_speed));
		COLOR.a = mix(COLOR.a, 0.0, 1.0 - transparency_actual);
	}
}

void vertex()
{
	
}