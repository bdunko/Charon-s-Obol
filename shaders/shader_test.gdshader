shader_type canvas_item;

// image blend
group_uniforms texture_blend;
uniform sampler2D blend_texture: source_color;
uniform float blend_strength: hint_range(0.0, 1.0) = 0.0;

// displacement
group_uniforms displace;
uniform bool displace_x = true;
uniform bool displace_y = true;
uniform float displace_amount: hint_range(-1.0, 1.0) = 0.0;

// glitch effects
group_uniforms glitch;
uniform sampler2D displace_glitch_texture: source_color;
uniform float abberationAmt: hint_range(-0.1, 0.1) = 0.0;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	
	// glitch
	vec4 glitch = texture(displace_glitch_texture, UV);
	vec2 displacedUV = UV;
	if (displace_x)
		displacedUV.x = UV.x + glitch.x * displace_amount;
	if (displace_y)
		displacedUV.y = UV.y + glitch.y * displace_amount;
	COLOR.rgb = texture(TEXTURE, displacedUV).rgb;
	
	COLOR.r = texture(TEXTURE, displacedUV + abberationAmt).r;
	COLOR.g = texture(TEXTURE, displacedUV).g;
	COLOR.b = texture(TEXTURE, displacedUV - abberationAmt).b;
	COLOR.a = 1.0;
	
		// image blend
	if (COLOR.a != 0.0)
		COLOR = mix(COLOR, texture(blend_texture, SCREEN_UV), blend_strength);
}

// image blend shader
