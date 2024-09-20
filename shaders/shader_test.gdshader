shader_type canvas_item;

// image blend
group_uniforms texture_blend;
uniform sampler2D blend_texture: source_color;
uniform float blend_strength: hint_range(0.0, 1.0) = 0.0;

// displacement
group_uniforms displace;
uniform int displace_x: hint_range(-10, 10) = 0;
uniform int displace_y: hint_range(-10, 10) = 0;



void fragment() {

}

// image blend shader
