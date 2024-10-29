shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;
uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform sampler2D density_texture: hint_default_white;
uniform float min_density;
uniform vec3 a;
uniform vec3 b;
uniform vec3 c;
uniform vec3 d;

void vertex() {
	POSITION = vec4(VERTEX.xy, 1.0, 1.0);
}

void fragment() {
	vec4 screen = texture(screen_texture, SCREEN_UV);

	float depth_raw = texture(depth_texture, SCREEN_UV).x;
	vec3 ndc = vec3(SCREEN_UV * 2.0 - 1.0, depth_raw);
	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 position_world = world.xyz / world.w;
	vec2 density_uv = vec2(
		(position_world.x - a.x) / (b.x - a.x),
		(position_world.z - b.z) / (c.z - b.z)
	);
	float density = max(min_density, texture(density_texture, density_uv).r);
	ALBEDO.rgb = screen.rgb * density;
}
