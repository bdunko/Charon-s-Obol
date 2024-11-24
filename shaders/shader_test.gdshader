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


// unused but may be useful someday
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, repeat_disable, filter_nearest;

uniform bool POST_PROCESSING = true;

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
	
	int SIZE_X = POST_PROCESSING ? SSIZE_X : PSIZE_X;
	int SIZE_Y = POST_PROCESSING ? SSIZE_Y : PSIZE_Y;
	int X = POST_PROCESSING ? SX : PX;
	int Y = POST_PROCESSING ? SY : PY;
	vec2 ADJ_UV = POST_PROCESSING ? SCREEN_UV : UV;
	
	if (POST_PROCESSING) {
		COLOR = texture(SCREEN_TEXTURE, ADJ_UV);
	}
	else {
		COLOR = texture(TEXTURE, ADJ_UV);
	}
	
	COLOR.r = 0.0;
}