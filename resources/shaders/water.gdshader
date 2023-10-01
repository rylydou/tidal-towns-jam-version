shader_type spatial;
render_mode blend_mix,depth_draw_opaque,diffuse_toon,specular_toon;

uniform sampler2D water_texture : filter_nearest, repeat_enable, hint_roughness_gray;

uniform vec4 WATER_COL : source_color = vec4(0.176471, 0.635294, 0.85098, 1.0);
uniform vec4 WATER2_COL : source_color = vec4(0.0588235, 0.529412, 0.776471, 1.0);
uniform vec4 FOAM_COL : source_color = vec4(0.87451, 0.988235, 1, 1.0);

uniform float distortion_speed = 2.0;
uniform vec2 tile = vec2(5.0, 5.0);
uniform vec2 offset = vec2(0, 0);
uniform vec2 size = vec2(32., 32.);
uniform float pixel_factor = 500.0;

const float TWOPI = 6.283185307;
const float SIXPI = 18.84955592;

float circ(vec2 pos, vec2 c, float s) {
	c = abs(pos - c);
	c = min(c, 1.0 - c);
	
	return step(0.0, sqrt(s) - sqrt(dot(c, c))) * -1.0;
}

float waterlayer(vec2 uv) {
	return step(0.5, texture(water_texture, uv).r);
}

vec3 water(vec2 uv, vec3 cdir, float iTime) {
	uv *= vec2(0.25);
	
	// Parallax height distortion with two directional waves at
	// slightly different angles.
	vec2 a = 0.025 * cdir.xz / cdir.y; // Parallax offset
	float h = sin(uv.x + iTime); // Height at UV
	uv += a * h;
	h = sin(0.841471 * uv.x - 0.540302 * uv.y + iTime);
	uv += a * h;
	
	// Texture distortion
	float d1 = mod(uv.x + uv.y, TWOPI);
	float d2 = mod((uv.x + uv.y + 0.25) * 1.3, SIXPI);
	d1 = iTime * 0.07 + d1;
	d2 = iTime * 0.5 + d2;
	vec2 dist = vec2(
		sin(d1) * 0.15 + sin(d2) * 0.05,
		cos(d1) * 0.15 + cos(d2) * 0.05
	);
	
	vec3 ret = WATER_COL.rgb;
	ret = mix(ret, WATER2_COL.rgb, waterlayer(uv + dist.xy));
	ret = mix(ret, FOAM_COL.rgb, waterlayer(vec2(1.0) - uv - dist.yx));
	return ret;
}

varying vec3 globalposition;
void vertex() {
	globalposition = (MODEL_MATRIX*vec4(VERTEX, 0.)).xyz;
}

void fragment() {
	float t = distance(globalposition, vec3(0, 0, 0))/25.;
	t = min(t, 1.);
	
	vec2 uv = globalposition.xz/size;
	uv = round(uv*pixel_factor)/pixel_factor;
	
	vec3 water = water(uv*tile + offset, vec3(0., 1., 0.), TIME*distortion_speed);
	ALBEDO.rgb = mix(water, WATER_COL.rgb, t);
}