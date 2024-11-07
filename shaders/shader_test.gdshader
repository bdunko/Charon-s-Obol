shader_type canvas_item;

// --- Utilty Functions --- //
// checks if two values are 'equal' (within EPSILON of each other)
// necessary when doing float calculations since it's not perfectly precise
const float EPSILON = 0.001;
bool floateq(float val1, float val2) { return val1 >= val2 - EPSILON && val1 <= val2 + EPSILON; }
bool vec3eq(vec3 val1, vec3 val2) { return floateq(val1.r, val2.r) && floateq(val1.g, val2.g) && floateq(val1.b, val2.b); }
float sin0to1(float time) { return (sin(time)+1.0)/2.0; }
float cos0to1(float time) { return (cos(time)+1.0)/2.0; }

const int COLOR_MODE_MULTIPLY = 1;
const int COLOR_MODE_ADDITIVE = 2;
const int COLOR_MODE_SUBTRACT = 3;
const int COLOR_MODE_REPLACE = 4;

uniform vec2 MOUSE = vec2(160, 100);

const bool DEBUG = true;

// lines
group_uniforms COLORLINES;
uniform vec4 vertical_colorline_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int vertical_colorline_spacing = 2;
uniform int vertical_colorline_mode = 1; // multiply
uniform vec4 horizontal_colorline_color: source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform int horizontal_colorline_spacing = 2;
uniform int horizontal_colorline_mode = 1; //multiply

group_uniforms CHECKERBOARD;
uniform vec4 checkerboard_color: source_color = vec4(0.2, 0.2, 0.2, 0.0);
uniform int checkerboard_mode = 3; 
uniform bool checkerboard_mouselight_on = true;
uniform vec4 checkerboard_mouselight_color: source_color = vec4(0.2, 0.2, 0.2, 0.2);
uniform int checkerboard_mouselight_size = 10;



// todo - cut off shader - may be useful for certain effects

// todo - vignette - base off of https://www.shadertoy.com/view/lsKSWR

// neat ripple https://godotshaders.com/shader/ripple-shader/

// Applies the color new onto orig with the given mode (multiply, additive, replacement)
vec4 apply_color(int mode, vec4 orig, vec4 new) {
	switch(mode) {
		case COLOR_MODE_MULTIPLY:
			return orig * new;
		case COLOR_MODE_ADDITIVE:
			return orig + new;
		case COLOR_MODE_SUBTRACT:
			return orig - new;
		case COLOR_MODE_REPLACE:
			return new;
	}
}

void fragment() {
	// the size of this canvas in pixels (
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
	
	
	// COLORLINES
	if (PX % vertical_colorline_spacing == 0) {
		COLOR = apply_color(vertical_colorline_mode, COLOR, vertical_colorline_color);
	}
	
	if (PY % horizontal_colorline_spacing == 0) {
		COLOR = apply_color(horizontal_colorline_mode, COLOR, horizontal_colorline_color);
	}
	
	// CHECKERBOARD
	if (PX % 2 != PY % 2) {
		float strength = (COLOR.r + COLOR.g + COLOR.b) / 3.0;
		vec4 adj_cbcolor = checkerboard_color.rgba;
		adj_cbcolor.r *= strength;
		adj_cbcolor.g *= strength;
		adj_cbcolor.b *= strength;
		COLOR = apply_color(checkerboard_mode, COLOR, adj_cbcolor);
	} else {
		if (checkerboard_mouselight_on) {
			float dist_from_mouse = sqrt(pow(float(SX - int(MOUSE.x)), 2.0) + pow(float(SY - int(MOUSE.y)), 2.0));
			if (dist_from_mouse <= float(checkerboard_mouselight_size))
				COLOR = apply_color(COLOR_MODE_ADDITIVE, COLOR, checkerboard_mouselight_color);
		}
	}

	
	// screen stuff
	//if (SSIZE_X == 320 && SSIZE_Y == 180 || DEBUG)
	//	COLOR.r = 1.0;
	
	//if (SX == 100 || DEBUG)
	//	COLOR.g = 1.0;
}