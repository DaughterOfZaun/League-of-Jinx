shader_type canvas_item;
render_mode unshaded, blend_disabled, world_vertex_coords;

const int MAX_LIGHTS = 200;
const int MAX_RAYMATCH_STEPS = 32;

uniform int light_n = 0;
uniform vec2 light_pos[MAX_LIGHTS];
uniform float light_rng[MAX_LIGHTS];

uniform mat4 comp_mat;
uniform vec2 zoom;

varying vec2 vertex_vector;
varying mat4 model_matrix;
varying mat4 canvas_matrix;
varying mat4 screen_matrix;
void vertex() {
	model_matrix = MODEL_MATRIX;
	canvas_matrix = CANVAS_MATRIX;
	screen_matrix = SCREEN_MATRIX;
	vertex_vector = VERTEX;
}

vec2 world_to_sdf(vec2 v){
	return v;
}

vec2 sdf_to_world(vec2 v){
	return v;
}

void fragment() {
	vec2 g_at = screen_uv_to_sdf(SCREEN_UV);
	float g_dist = texture_sdf(g_at);
	//COLOR = vec4(vec3(1, 1, 1) * fract(g_dist * 0.01), 1);
	COLOR = vec4(0, 0, 0, 1);
	for(int n = 0; n < light_n; n++){
		vec2 l_pos = light_pos[n];
		vec4 screen_pos = inverse(screen_matrix) * vec4(SCREEN_UV * 2.0 - vec2(1, 1), 0.0, 1.0);
		vec2 p_pos = (inverse(model_matrix) * inverse(canvas_matrix) * screen_pos).xy;
		float l_rng = light_rng[n];
		if(distance(l_pos, p_pos) <= l_rng) {
			COLOR = vec4(1, 1, 1, 1);
			break;
		}
	}
	/*
	float dist;
	bool hit;
	vec2 end_pos;
	{
		vec2 from_pos = n_out3p0;
		vec2 to_pos = n_out4p0;

		vec2 at = from_pos;
		float max_dist = distance(from_pos, to_pos);
		vec2 dir = normalize(to_pos - from_pos);

		float accum = 0.0f;
		while(accum < max_dist) {
			float d = texture_sdf(at);
			accum += d;
			if (d < 0.01f) {
				break;
			}
			at += d * dir;
		}
		dist = min(max_dist, accum);
		hit = accum < max_dist;
		end_pos = from_pos + dir * dist;
	}
	*/
}
