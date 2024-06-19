shader_type particles;

//const int COLOR_LOOKUP_TYPE_CONSTANT = 0;
const int COLOR_LOOKUP_TYPE_LIFETIME = 1;
const int COLOR_LOOKUP_TYPE_VELOCITY = 2;
const int COLOR_LOOKUP_BIRTH_RANDOM = 3;
const int COLOR_LOOKUP_TYPE_COUNT = 4;

#define TEXTURE_FILTER filter_nearest

uniform uint amount = 8;

uniform float p_life_i = 1;
uniform sampler2D p_life_p: hint_default_white, TEXTURE_FILTER;

uniform float p_linger = 0;

uniform sampler2D p_rgba: TEXTURE_FILTER;
uniform ivec2 p_colortype;
uniform vec2 p_coloroffset;
uniform vec2 p_colorscale = vec2(1, 1);

uniform float p_bindweight;

uniform vec3 p_scale_i;
uniform sampler2D p_scale_p: hint_default_white, TEXTURE_FILTER;

#define AMOUNT amount
#define TIME_PASSED CUSTOM.y
#define E_LIFE LIFETIME
#define MAX_VELOCITY 1.0 // Temporary hack

float rand_from_seed(inout uint seed) {
	int k;
	int s = int(seed);
	//if (s == 0) s = 305420679;
	k = s / 127773;
	s = 16807 * (s - k * 127773) - 2836 * k;
	s += 2147483647 * int(s < 0);
	seed = uint(s);
	return float(seed % uint(65536)) / 65535.0;
}
float rand_from_seed_m1_p1(inout uint seed) {
	return rand_from_seed(seed) * 2.0 - 1.0;
}
uint hash(uint x) {
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = ((x >> uint(16)) ^ x) * uint(73244475);
	x = (x >> uint(16)) ^ x;
	return x;
}

// Called when a particle is spawned.
void start() {

	if (RESTART_CUSTOM){
		CUSTOM = vec4(0.);
	}
	if (RESTART_COLOR){
		COLOR = vec4(0.);
	}
	if (RESTART_ROT_SCALE){
		TRANSFORM[0].xyz = vec3(1.0, 0.0, 0.0);
		TRANSFORM[1].xyz = vec3(0.0, 1.0, 0.0);
		TRANSFORM[2].xyz = vec3(0.0, 0.0, 1.0);
	}
	if (RESTART_POSITION){
		TRANSFORM[3].xyz = vec3(0.);
		TRANSFORM = EMISSION_TRANSFORM * TRANSFORM;
	}
	if (RESTART_VELOCITY){
		VELOCITY = vec3(0.);
	}
}

// Called every frame on existing particles (according to the Fixed FPS property).
void process() {

	uint alt_seed = hash(NUMBER + uint(1) + RANDOM_SEED);
	float p_life = p_life_i * texture(p_life_p, vec2(rand_from_seed(alt_seed), 1.0)).r;
	vec3 p_scale = p_scale_i * vec3(
        texture(p_scale_p, vec2(rand_from_seed(alt_seed), 1.0)).r,
        texture(p_scale_p, vec2(rand_from_seed(alt_seed), 1.0)).g,
        texture(p_scale_p, vec2(rand_from_seed(alt_seed), 1.0)).b
    );
    p_scale = sign(p_scale) * max(abs(p_scale), 0.01);

	TIME_PASSED += DELTA;
	if(TIME_PASSED >= p_life)
		ACTIVE = false;

	vec2 coords = vec2(0, 0);
	#define COMPARE_IVEC2_WITH_INT_AND_RETURN_VEC2(v, w) vec2(float(v.x == w), float(v.y == w))
	//coords += COMPARE_IVEC2_WITH_INT_AND_RETURN_VEC2(p_colortype, COLOR_LOOKUP_TYPE_CONSTANT) * (0.0);
	coords += COMPARE_IVEC2_WITH_INT_AND_RETURN_VEC2(p_colortype, COLOR_LOOKUP_TYPE_LIFETIME) * (TIME_PASSED / p_life);
	coords += COMPARE_IVEC2_WITH_INT_AND_RETURN_VEC2(p_colortype, COLOR_LOOKUP_TYPE_VELOCITY) * (length(VELOCITY) / MAX_VELOCITY);
	coords.x += float(p_colortype.x == COLOR_LOOKUP_BIRTH_RANDOM && RESTART) * rand_from_seed(alt_seed);
	coords.y += float(p_colortype.y == COLOR_LOOKUP_BIRTH_RANDOM && RESTART) * rand_from_seed(alt_seed);
	coords += COMPARE_IVEC2_WITH_INT_AND_RETURN_VEC2(p_colortype, COLOR_LOOKUP_TYPE_VELOCITY) * (length(VELOCITY) / MAX_VELOCITY);
	coords += COMPARE_IVEC2_WITH_INT_AND_RETURN_VEC2(p_colortype, COLOR_LOOKUP_TYPE_COUNT) * (float(INDEX) / float(AMOUNT));
	COLOR = texture(p_rgba, p_coloroffset + (coords * p_colorscale));

	VELOCITY = (EMISSION_TRANSFORM[3].xyz - TRANSFORM[3].xyz) * (p_bindweight / DELTA);

	TRANSFORM[0].xyz = normalize(TRANSFORM[0].xyz) * p_scale.x;
	TRANSFORM[1].xyz = normalize(TRANSFORM[1].xyz) * p_scale.y;
	TRANSFORM[2].xyz = normalize(TRANSFORM[2].xyz) * p_scale.z;
}
