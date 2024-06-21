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