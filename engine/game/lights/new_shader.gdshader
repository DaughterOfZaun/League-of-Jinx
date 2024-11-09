shader_type canvas_item;
render_mode unshaded, skip_vertex_transform;

varying vec2 world_pos;
varying mat4 model_matrix;
varying mat4 canvas_matrix;
varying mat4 screen_matrix;

void vertex() {
	vec4 v = vec4(VERTEX, 0.0, 1.0);
	v = inverse(CANVAS_MATRIX) * inverse(SCREEN_MATRIX) * v;
	VERTEX = v.xy;
	world_pos = v.xy;
	model_matrix = MODEL_MATRIX;
	canvas_matrix = CANVAS_MATRIX;
	screen_matrix = SCREEN_MATRIX;
}

const int MAX_LIGHTS = 200;

uniform int light_n = 0;
uniform vec2 light_pos[MAX_LIGHTS];
uniform float light_rng[MAX_LIGHTS];

void fragment() {
	COLOR = vec4(0, 0, 0, 1);
	for(int n = 0; n < light_n; n++){
		vec2 p_pos = world_pos;
		vec2 l_pos = light_pos[n];
		float l_rng = light_rng[n];

		if(distance(l_pos, p_pos) >= l_rng){
			continue;
		}

		bool hit;
		float dist;
		vec2 end_pos;
		{
			#define world_to_screen_uv(pos) (((screen_matrix * (canvas_matrix * vec4((pos), 0, 1))).xy + vec2(1, 1)) * 0.5)
			vec2 from_pos = screen_uv_to_sdf(world_to_screen_uv(l_pos));
			vec2 to_pos = screen_uv_to_sdf(SCREEN_UV);

			vec2 at = from_pos;
			float max_dist = distance(from_pos, to_pos);
			vec2 dir = normalize(to_pos - from_pos);

			float accum = 0.0f;
			while(accum < max_dist) {
				float d = texture_sdf(at);
				/*
				float off = 1.0; d +=
				texture_sdf(at + vec2(-off, -off)) +
				texture_sdf(at + vec2(off, -off)) +
				texture_sdf(at + vec2(-off, off)) +
				texture_sdf(at + vec2(off, off)) +
				texture_sdf(at + vec2(0.0, -off)) +
				texture_sdf(at + vec2(0.0, off)) +
				texture_sdf(at + vec2(-off, 0.0)) +
				texture_sdf(at + vec2(off, 0.0));
				d /= 9.0;
				*/
				accum += d;
				if (d < 0.01f) {
					break;
				}
				at += d * dir;
			}
			hit = accum < max_dist;
			dist = min(max_dist, accum);
			end_pos = from_pos + dir * dist;
		}

		if(!hit){
			COLOR = vec4(1, 1, 1, 1);
			break;
		}
	}
}