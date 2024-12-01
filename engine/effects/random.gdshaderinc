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

#define GET_RAND_COLOR(tex_p) texture(tex_p, vec2(rand_from_seed(alt_seed), 1.0))
#define GET_RAND_FLOAT(tex_p) GET_RAND_COLOR(tex_p).r
#define GET_RAND1_VEC3(tex_p) (GET_RAND_FLOAT(tex_p) * vec3(1, 1, 1))
#define GET_RAND3_VEC3(tex_p) vec3(GET_RAND_COLOR(tex_p).r, GET_RAND_COLOR(tex_p).g, GET_RAND_COLOR(tex_p).b)