shader_type canvas_item;

// Util funcs
// checks if two values are 'equal' (within EPSILON of each other)
// necessary when doing float calculations since it's not perfectly precise
const float EPSILON = 0.01;

bool floateq(float val1, float val2) {
	return val1 >= val2 - EPSILON && val1 <= val2 + EPSILON;
}

bool vec3eq(vec3 val1, vec3 val2) {
	return floateq(val1.r, val2.r) && floateq(val1.g, val2.g) && floateq(val1.b, val2.b);
}

// Color Replacement (5 colors)

// Outline Recolor

// Fade in/out

// Flash

// Glow

// Sway

// Squish

// Shadow (copy of the existing sprite drawn behind it, with a given shadow color and offset)
// basically for each pixel, move it by offset, then if transparent, draw pixel of that color

// --- Uniforms --- //
// TINT
group_uniforms Tint;
// Tint the texture with tint_color (rbg) 
// The strength of the tint is controlled by tint_strength (0-1)
uniform vec3 tint_color = vec3(1.0, 1.0, 1.0);
uniform float tint_strength = 0.0;

// PAN
// Controls texture left/right/up/down panning (the texture will be repeated)
// Set to a positive number for left/up panning; negative number for right/down panning
group_uniforms Pan;
uniform vec2 pan_speed = vec2(0, 0);

group_uniforms Transparency;
uniform float transparency = 1.0;

// --- Functions --- //
void fragment() {
	
	// PAN
	COLOR = texture(TEXTURE, mod(UV + TIME * pan_speed, 1.0));
	
	if (COLOR.a != 0.0)
		COLOR.a = transparency;
	
	// TINT
	COLOR.rgb = mix(COLOR.rgb, tint_color, tint_strength);
	
	//COLOR.a = 0.5;
	//COLOR.a = texture(TEXTUR)
}
