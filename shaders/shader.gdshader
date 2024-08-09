// NOTE - Shader expects uniform inputs in the range 0.0 - 1.0 for Colors.
// Therefore, be sure that Colors being passed in are in the correct range of (0-1, 0-1, 0-1, 0-1).

shader_type canvas_item;

// --- Utilty Functions --- //
// checks if two values are 'equal' (within EPSILON of each other)
// necessary when doing float calculations since it's not perfectly precise
const float EPSILON = 0.001;

bool floateq(float val1, float val2) {
	return val1 >= val2 - EPSILON && val1 <= val2 + EPSILON;
}

bool vec3eq(vec3 val1, vec3 val2) {
	return floateq(val1.r, val2.r) && floateq(val1.g, val2.g) && floateq(val1.b, val2.b);
}

// Glow - Create Border of Color and Size

// Sway

// Squish

// Shadow (copy of the existing sprite drawn behind it, with a given shadow color and offset)
// basically for each pixel, move it by offset, then if transparent, draw pixel of that color

// --- Effects --- //
// RECOLOR
// Replaces replace_colorN with replace_with_colorN.
group_uniforms Recolor;
uniform vec3 replace_color1 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color1 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color2 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color2 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color3 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color3 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color4 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color4 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_color5 = vec3(0.0, 0.0, 0.0);
uniform vec3 replace_with_color5 = vec3(0.0, 0.0, 0.0);

// TINT
// Tint the texture with tint_color (rbg) 
// The strength of the tint is controlled by tint_strength (0-1)
// If use_exclude_tint, the tint ignores pixels whose color matches excude_tint (useful for ignoring borders)
// Can also be used to create flashing effects.
group_uniforms Tint;
uniform vec3 tint_color = vec3(0.0, 0.0, 0.0);
uniform float tint_strength = 0.0;
uniform bool use_exclude_tint = false;
uniform vec3 exclude_tint = vec3(0.0, 0.0, 0.0);

// PAN
// Controls texture left/right/up/down panning (the texture will be repeated)
// Set to a positive number for left/up panning; negative number for right/down panning
group_uniforms Pan;
uniform vec2 pan_speed = vec2(0, 0);

// TRANSPARENCY
// Controls transparency of the texture.
group_uniforms Transparency;
uniform float transparency = 1.0;

// --- Fragment Shader --- //
void fragment() {
	// PAN
	COLOR = texture(TEXTURE, mod(UV + TIME * pan_speed, 1.0)); //since this reads from texture, it has to go first; otherwise we rewrite changes
	
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
	if (!use_exclude_tint || !vec3eq(texture(TEXTURE, UV).rgb, exclude_tint))
		COLOR.rgb = mix(COLOR.rgb, tint_color, tint_strength);
	
	// TRANSPARENCY
	if (COLOR.a != 0.0)
		COLOR.a = transparency;
}

// --- Vertex Shader --- //
void vertex() {
	
}