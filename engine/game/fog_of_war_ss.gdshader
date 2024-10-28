shader_type spatial;
render_mode unshaded, fog_disabled;

uniform sampler2D screen_texture : source_color, hint_screen_texture;
uniform sampler2D depth_texture : source_color, hint_depth_texture;
uniform sampler2D density_texture: hint_default_white;
uniform vec2 density_texture_offset;
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
	vec4 position_view = INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	position_view.xyz /= position_view.w;
	float linear_depth = -position_view.z;

	vec4 world = INV_VIEW_MATRIX * INV_PROJECTION_MATRIX * vec4(ndc, 1.0);
	vec3 position_world = world.xyz / world.w;

	const float GD_3D_to_2D = (70. / 50.) * (512. / 294.);
	//vec2 position_world_2D = (position_world.xz * vec2(1, -1) * GD_3D_to_2D) + density_texture_offset;
	//ivec2 texture_size = textureSize(density_texture, 0);
	//vec2 texture_uv = position_world_2D / vec2(texture_size);
	//float density = max(min_density, texture(density_texture, texture_uv).r);

	//vec3 world_camera = (INV_VIEW_MATRIX * vec4(0.0, 0.0, 0.0, 1.0)).xyz;
	//vec2 position_world_2D = (position_world.xz - world_camera.xz) * GD_3D_to_2D;
	//ivec2 texture_size = textureSize(density_texture, 0);
	//vec2 texture_uv = (position_world_2D / vec2(texture_size)) + vec2(0.5, 0.5);

	vec2 density_uv = vec2(
		(position_world.x - a.x) / (b.x - a.x),
		(position_world.z - b.z) / (c.z - b.z)
	);
	float density = max(min_density, texture(density_texture, density_uv).r);

	//ALBEDO.rgb = screen.rgb * texture(density_texture, vec2(SCREEN_UV.x, SCREEN_UV.y)).x;
	ALBEDO.rgb = screen.rgb * density;
}
