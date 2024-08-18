shader_type canvas_item;

group_uniforms outline;
uniform vec4 outline_color: source_color = vec4(1.0);
uniform int outline_thickness: hint_range(0, 10) = 0;
uniform bool outline_diagonals = false;
const vec2 HORIZONTAL_VERTICAL_OFFSETS[4] = {
	vec2(0, 1), vec2(-1, 0), vec2(1, 0), vec2(0, -1)
};
const vec2 DIAGONAL_OUTLINE_OFFSETS[4] = {
	vec2(1, 1), vec2(-1, 1), vec2(1, -1), vec2(-1, -1)
};

// displacement
group_uniforms displace;
uniform bool displace_x = true;
uniform bool displace_y = true;
uniform float displace_amount: hint_range(-1.0, 1.0) = 0.0;


void fragment() {
	vec2 outline_size = TEXTURE_PIXEL_SIZE * float(outline_thickness);
	float outline = 0.0;
	
	for (int i = 0; i < HORIZONTAL_VERTICAL_OFFSETS.length(); i++) {
		outline += texture(TEXTURE, UV + outline_size * HORIZONTAL_VERTICAL_OFFSETS[i]).a;
	}
	
	if (outline_diagonals) {
		for (int i = 0; i < DIAGONAL_OUTLINE_OFFSETS.length(); i++) {
			outline += texture(TEXTURE, UV + outline_size * DIAGONAL_OUTLINE_OFFSETS[i]).a;
		}
	}
	
	outline = min(outline, 1.0);
	
	vec4 color = texture(TEXTURE, UV);
	COLOR = mix(color, outline_color, outline - color.a);
}