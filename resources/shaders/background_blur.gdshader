shader_type canvas_item;

uniform float blur_amount : hint_range(-2.0, 10.0);

uniform sampler2D SCREEN_TEXTURE: hint_screen_texture, filter_linear_mipmap;

void fragment() {
	vec4 blurred = textureLod(SCREEN_TEXTURE, SCREEN_UV, blur_amount);
	vec4 fin = blurred;
	
	COLOR.rgb = mix(fin.rgb, COLOR.rgb, COLOR.a);
	COLOR.a = 1.0;
}