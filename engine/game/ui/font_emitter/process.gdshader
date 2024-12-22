shader_type particles;
render_mode disable_velocity;

uniform float inherit_emitter_velocity_ratio = 0.0;
uniform sampler2D alpha_curve : repeat_disable;

void start() {
	COLOR.a = texture(alpha_curve, vec2(0.0)).r;
	//VELOCITY = (EMISSION_TRANSFORM * vec4(VELOCITY, 0.0)).xyz;
}

void process() {

	CUSTOM.y += DELTA / LIFETIME;
	CUSTOM.y = mix(CUSTOM.y, 1.0, INTERPOLATE_TO_END);
	float lifetime_percent = CUSTOM.y / CUSTOM.w;
	if (CUSTOM.y > CUSTOM.w) {
		ACTIVE = false;
	}

	TRANSFORM[3].xyz += (VELOCITY + EMITTER_VELOCITY * inherit_emitter_velocity_ratio) * DELTA;

	COLOR.a = texture(alpha_curve, vec2(lifetime_percent)).r;
}
