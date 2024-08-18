shader_type canvas_item;

group_uniforms Outline;
uniform float outline_size: hint_range(0, 5);
uniform vec4 outline_color : source_color;

// expand the size of the canvas
varying vec2 o;
varying vec2 f;
void vertex()
{
	o = VERTEX;
	vec2 uv = (UV - 0.5);
	VERTEX += uv * 100.0; //modify this number if more canvas space is needed...
	f = VERTEX;
}

void fragment()
{
	// calculate the 'normal' UV for use
	ivec2 t = textureSize(TEXTURE, 0);
	vec2 nUV;
	nUV.x = UV.x + (f.x - o.x)/float(t.x);
	nUV.y = UV.y + (f.y - o.y)/float(t.y);
	
	vec4 regular_color = texture(TEXTURE, nUV);
	if((nUV.x < 0.0 || nUV.x > 1.0) || (nUV.y < 0.0 || nUV.y > 1.0) || regular_color.a <=0.25){
		regular_color = vec4(0.0); 
	}
	
	vec2 ps = TEXTURE_PIXEL_SIZE * float(outline_size);
	
	vec4 final_color = regular_color;
	if (regular_color.a <= 0.0)
	{
		for(int x = -1; x <= 1; x += 1){
			for(int y = -1; y <= 1; y += 1){
				//Get the X and Y offset from this
				if (x==0 && y==0)
					continue;
					
				vec2 outline_uv = nUV + vec2(float(x) * ps.x, float(y) * ps.y); 
				
				//Sample here, if we are out of bounds then fail
				vec4 outline_sample = texture(TEXTURE, outline_uv);
				if((outline_uv.x < 0.0 || outline_uv.x > 1.0) || (outline_uv.y < 0.0 || outline_uv.y > 1.0)){
				//	//We aren't a real color
					outline_sample = vec4(0);
				}
				
				//Is our sample empty? Is there something nearby?
				if(outline_sample.a > final_color.a){
					final_color = outline_color;
				}
			}
		}
	}
	COLOR = final_color; 
}