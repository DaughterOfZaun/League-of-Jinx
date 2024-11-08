shader_type canvas_item;
render_mode unshaded, blend_mix;

const int MAX_LIGHTS = 200;
const int MAX_RAYMATCH_STEPS = 32;

uniform int light_n = 0;
uniform vec2 light_pos[MAX_LIGHTS];
uniform float light_rng[MAX_LIGHTS];

uniform mat4 comp_mat;
uniform vec2 zoom;

varying vec2 pos;
void vertex() {
	pos = VERTEX;
}

void fragment() {
	vec2 g_at = screen_uv_to_sdf(SCREEN_UV);
	float g_dist = texture_sdf(g_at);
	bool white = false;
	for(int n = 0; n < light_n && !white; n++) {
		vec2 l_pos = light_pos[n];
		vec2 p_pos = (inverse(comp_mat) * vec4(pos, 0.0, 1.0)).xy;
		float l_rng = light_rng[n];
		vec2 p2l = l_pos - p_pos;
		float p2l_len = length(p2l);
		if(p2l_len >= l_rng){
			continue;
		}
		vec2 dir = p2l / p2l_len;
		float accum = g_dist;
		for(int i = 0; i < MAX_RAYMATCH_STEPS && !white; i++){
			if(accum >= p2l_len){
				white = true;
				break;
			}
			vec2 at = g_at + dir * accum;
			float dist = texture_sdf(at);
			if(dist < 0.01){
				break;
			}
			accum += dist;
		}
	}
	COLOR = vec4(vec3(1, 1, 1) * float(white), 1);
}

