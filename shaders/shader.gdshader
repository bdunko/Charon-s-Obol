shader_type canvas_item;

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

// PAN
// Controls texture left/right/up/down panning (the texture will be repeated). 
// Set to a positive number for left/up panning; negative number for right/down panning.
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
	
	//COLOR.a = 0.5;
	//COLOR.a = texture(TEXTUR)
}
