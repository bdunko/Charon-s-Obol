shader_type canvas_item;

// Fog density
uniform sampler2D fog_noise_texture: repeat_enable, filter_nearest;
uniform float fog_opacity: hint_range(0.0, 1.0) = 0.5;
uniform float fog_density: hint_range(0.0, 1.0) = 0.25;
uniform vec2 fog_speed = vec2(0.02, 0.01);

void fragment() {
	// Fog
	vec2 fog_uv = UV + fog_speed * TIME;
	float noise_alpha = texture(fog_noise_texture, fog_uv).r;
	// Convert noise from (0.0, 1.0) to (-1.0, 1.0)
	float fog = clamp((noise_alpha * 2.0 - 1.0) + (fog_density * 2.0), 0.0, 1.0);
	COLOR.a *= fog * fog_opacity;
}