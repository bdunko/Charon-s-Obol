shader_type canvas_item;

// --- Utilty Functions --- //
// checks if two values are 'equal' (within EPSILON of each other)
// necessary when doing float calculations since it's not perfectly precise
const float EPSILON = 0.001;
bool floateq(float val1, float val2) { return val1 >= val2 - EPSILON && val1 <= val2 + EPSILON; }
bool vec3eq(vec3 val1, vec3 val2) { return floateq(val1.r, val2.r) && floateq(val1.g, val2.g) && floateq(val1.b, val2.b); }
float sin0to1(float time) { return (sin(time)+1.0)/2.0; }
float cos0to1(float time) { return (cos(time)+1.0)/2.0; }

const bool DEBUG = true;

// pass in the mouse position here
uniform vec2 MOUSE = vec2(20, 20);

// lines
group_uniforms COLORLINES;
uniform vec3 vertical_colorline_color: source_color = vec3(1.0, 1.0, 1.0);
uniform int vertical_colorline_spacing = 2;
uniform float vertical_colorline_strength: hint_range(0.0, 1.0, 0.01) = 0.0;
uniform vec3 horizontal_colorline_color: source_color = vec3(1.0, 1.0, 1.0);
uniform int horizontal_colorline_spacing = 2;
uniform float horizontal_colorline_strength: hint_range(0.0, 1.0, 0.01) = 0.0;

group_uniforms CHECKER;
uniform vec3 checker_color: source_color = vec3(0.2, 0.2, 0.2);
uniform float checker_strength: hint_range(0.0, 1.0, 0.01) = 0.0; //0.3 is a good one

group_uniforms MOUSELIGHT;
uniform bool mouselight_on = false;
uniform bool mouselight_checker = false;
uniform vec3 mouselight_color: source_color = vec3(1.0, 1.0, 1.0);
uniform float mouselight_strength = 0.5;
uniform int mouselight_size = 8;
uniform float mouselight_flicker_size = 3;
uniform float mouselight_flicker_speed = 10;

group_uniforms CUT;
uniform float cut_left: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_right: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_top: hint_range(0.0, 1.0, 0.001) = 0.0;
uniform float cut_bottom: hint_range(0.0, 1.0, 0.001) = 0.0;

group_uniforms SCANLINE;
uniform vec3 scanline_color: source_color = vec3(0.98, 0.69, 0.23);
uniform float scanline_strength: hint_range(0.0, 1.0, 0.01) = 1.0;
uniform float scanline_left_to_right: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_top_to_bottom: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_topleft_to_bottomright: hint_range(-0.001, 1.0, 0.001) = -0.001;
uniform float scanline_topright_to_bottomleft: hint_range(-0.001, 1.0, 0.001) = -0.001;

// sat - figure out how to handle colormodes - it's pretty messy;
// maybe use the mix function?
// switch to using vec3 instead of vec4 and provide an int param for 'strength'

// sat - Disintegrate
// provide a noise texture and delete from?

// sat - Vignette - base off of https://www.shadertoy.com/view/lsKSWR

// later - 
// neat ripple https://godotshaders.com/shader/ripple-shader/

void fragment() {
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
	
	// screen stuff
	//if (SSIZE_X == 320 && SSIZE_Y == 180 || DEBUG)
	//	COLOR.r = 1.0;
	
	//if (SX == 100 || DEBUG)
	//	COLOR.g = 1.0;
}